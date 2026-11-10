## devlog: 10 Nov 2026 A | Designing tabelline 0.2 | tabelline 0.2 takes in what was planned for 0.3 and 0.4: summing up, rows and columns, more formats, every locale, pictures in cells. Each group from zero, simplest first, with the choices behind it and how it is built.
## A dated post, written while 0.2 is built: each group is added when its PR is ready for review.
import std/[os, sugar]
import nimib
import tabelline, tabelline/[nimib, datasets]
import ../[blocks, review]

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "designing-0-2" / "index.html"
nb.useTabelline(title = "Designing tabelline 0.2", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")
nbReview(tscript = sharedReviewScript(nb))

nbTitle "10 November 2026", "Designing tabelline 0.2", """
tabelline 0.2 takes in what was planned for 0.3 and 0.4: summing up, rows and columns, more formats, every locale, pictures in cells. Each group from zero, simplest first, with the choices behind it and how it is built.
"""

nbText: """
0.1 had the parts of a table, from the title to the footer, and the formats for single values.
0.2 was going to add rows and merges; on the day 0.1 shipped, it became the release that takes in
0.3 and 0.4 as well. That is five groups of features, built in five pull requests, each one
explained here when it is ready, from the simplest idea up.
"""

nbToc()

nbText: """
## Five groups

Each group needs the ones before it: summing up comes first because summary columns, in the
second group, reuse its aggregates; pictures come last because nanoplots need the formats and
the options of the groups before them.
"""

block:
  type G = object
    group, what, status: string
  let rows = @[
    G(group: "1 · Summing up", what: "summary rows for each group and for the whole table; aggregates", status: "built"),
    G(group: "2 · Rows and columns", what: "merged columns, added columns and rows, summary columns, hidden rows, stub indent, decimal alignment", status: "built"),
    G(group: "3 · More formats", what: "units, fractions, chemistry, bins, automatic formats, country names", status: "built"),
    G(group: "4 · Every locale", what: "numbers, currencies and dates from CLDR; rotated labels, more options, extract, preview, body styles, datasets", status: "planned"),
    G(group: "5 · Pictures in cells", what: "icons, images and nanoplots, all inlined", status: "planned"),
  ]
  let t = tabella(rows, rownameCol = "group"):
    tabHeader "0.2 in five groups"
    colsLabel {"what": "what it adds", "status": "now"}
    tabStyle style.css("white-space: nowrap"), loc.stub()
    tabStyle style.text(weight = "bold"), loc.body("status", where(it["status"] == "built"))
    optCssTheme()
  nbTable t

nbText: """
## 1 · Summing up

### One number for a group

The simplest summary is one number: the moons of each kind of planet. `summaryRows` adds a row
under each group, labelled in the stub, for each pair of a label and an aggregate:
"""

nbCode:
  let moons = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
    .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
    .summaryRows(fns = {"total": agg.sum})
  nbTable moons.optCssTheme()

nbNote("""
`fns = {"total": agg.sum}` is a list of pairs: the label of the row and how to sum up a column.
`columns` is not given, so every numeric column is summed up, here only `moons`.
""", nkCode)

nbText: """
### And one for the whole table

`grandSummaryRows` does the same for every row of the table, whatever its group, after a double
rule. Several aggregates give several rows:
"""

nbCode:
  nbTable moons
    .grandSummaryRows(fns = {"all moons": agg.sum, "most": agg.max, "planets": agg.count})
    .optCssTheme()

nbNote("""
The aggregates are `agg.sum`, `agg.mean`, `agg.median`, `agg.min`, `agg.max`, `agg.count` and
`agg.sd`. `aggregate(proc)` makes one from any proc of the column's values, such as the middle
value: `aggregate(proc (vs: seq[Value]): Value = vs[vs.len div 2])`.
""", nkCode)

nbText: """
### Formatted like their column

A summary cell is a number like the others in its column, so it takes the column's format: the
masses keep their three decimals, the diameters their thousands separator. A count is a count of
rows, not a mass, so it is always an integer; `fmt` gives the rows of one call a format of
their own:
"""

nbCode:
  let sizes = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
    .colsHide(["density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "moons"])
    .fmtNumber("mass", decimals = 3, dropTrailingZeros = true)
    .fmtInteger("diameter")
    .summaryRows(fns = {"total": agg.sum}, columns = "mass", missingText = "")
    .grandSummaryRows(fns = {"mean": agg.mean}, fmt = (x: float) => formatNumber(x, decimals = 0))
  nbTable sizes.optCssTheme()

nbNote("""
`missingText = ""` leaves the cells of the columns that are not summed up empty (gt writes a
dash, and so does tabelline by default). The grand mean is formatted by `fmt`, a proc of a
float, like Great Tables' `vals.fmt_*`.
""", nkCode)

nbText: """
### Choices

- **`agg.sum`, not `sum`.** gt takes `"sum"` or the function `sum`; in Nim `{"total": sum}`
  cannot compile, because Nim's own `sum`, `min` and `max` make the name ambiguous. A namespace,
  like `style.fill` and `loc.body`, keeps the names of gt and makes a typo a compile error.
- **The column's format by default.** gt and Great Tables leave a summary unformatted unless you
  say how; a table where the totals look different from the rows above them is rarely what you
  want, so tabelline uses the last format of the column.
- **A stub when there is none.** Summary rows need a place for their label; as in gt, a table
  without row names gets an empty stub.
- **Styles and notes.** Summary cells have their own locations, `loc.summary`,
  `loc.summaryStub`, `loc.grandSummary`, `loc.grandSummaryStub`, as in Great Tables, and
  footnote marks are numbered in reading order through them.
- **Not yet:** text transforms do not reach summary rows.

## 2 · Rows and columns

### Two columns in one cell

The simplest merge puts two values in one cell: a range, from the start to the end. The end
column is hidden, and an empty end leaves just the start:
"""

nbCode:
  let missions = tableData:
    mission: ["Voyager 1", "Galileo", "Cassini", "Juno"]
    launch: [1977, 1989, 1997, 2011]
    ended: [nil, 2003, 2017, nil]
    target: ["Jupiter, Saturn", "Jupiter", "Saturn", "Jupiter"]
    moon: [nil, "Io", "Titan", nil]
  nbTable tabella(missions, rownameCol = "mission")
    .colsMergeRange("launch", "ended")
    .colsMerge(["target", "moon"], pattern = "{1}<< and {2}>>")
    .optCssTheme()

nbNote("""
`colsMerge` writes the cells with a pattern: `{1}` and `{2}` are the columns, and the part
between `<<` and `>>` is left out when a value it names is missing (Voyager has no moon). Three
merges are ready-made: `colsMergeRange` (`1989–2003`), `colsMergeUncert` (`12.3 ± 0.4`) and
`colsMergeNPct` (`12 (4.5%)`). Each joins the *formatted* values, so formats still apply.
""", nkCode)

nbText: """
### Columns and rows of your own

A table can grow beyond its data: `colsAdd` adds a column, from values or from a proc of each
row, and `rowsAdd` adds rows, into a group when they name one. `rowsHide` takes rows out of view:
"""

nbCode:
  nbTable tabella(planets(), rownameCol = "planet", groupnameCol = "type")
    .colsHide(everything())
    .colsAdd("moons per Earth mass", proc (r: Row): Value =
      toValue(r["moons"].toFloat / r["mass"].toFloat * 5.97))
    .fmtNumber("moons per Earth mass", decimals = 1)
    .rowsHide(where(it["type"] == "Terrestrial"))
    .rowsAdd([(planet: "Pluto", `type`: "Dwarf planet", moons: 5, mass: 0.0130)])
    .optCssTheme()

nbNote("""
Pluto is added with only the columns it needs; the proc of `colsAdd` ran on the data before it,
so its cell is missing (add the row first to have it computed). The data the table started from
is never changed: a verb that adds a row or a column makes a new one, so other tables made from
the same data stay as they were.
""", nkCode)

nbText: """
### Totals across a row

Summary rows sum up down a column; `summaryColumns` sums up across a row, with the same
aggregates. Together they make the table of totals, where the corner is the grand total:
"""

nbCode:
  let medals = tableData:
    country: ["Norway", "Germany", "Italy", "United States"]
    gold: [16, 12, 7, 9]
    silver: [8, 10, 8, 10]
    bronze: [13, 5, 9, 6]
  nbTable tabella(medals, rownameCol = "country")
    .summaryColumns(fns = {"total": agg.sum})
    .grandSummaryRows(fns = {"all": agg.sum})
    .optCssTheme()

nbText: """
### Indents and decimal marks

Two small things make long tables read better. `tabStubIndent` indents row labels, for items
inside items; `colsAlignDecimal` lines numbers up on their decimal mark, whatever their number
of decimals:
"""

nbCode:
  let budget = tableData:
    item: ["Hardware", "Laptops", "Screens", "Travel", "Trains", "Hotels"]
    eur: [5200.0, 4000.0, 1200.0, 900.0, 312.5, 587.25]
  nbTable tabella(budget, rownameCol = "item")
    .tabStubIndent([1, 2, 4, 5], "increase")
    .fmtNumber("eur", decimals = 2, dropTrailingZeros = true)
    .colsAlignDecimal("eur")
    .optCssTheme()

nbNote("""
The alignment pads each number on the right with figure spaces, which are as wide as a digit
(and a punctuation space where there is no mark): it needs no CSS, so it works in the text and
Markdown outputs too.
""", nkCode)

nbText: """
### Choices

- **Merges at render time.** A merge is kept as a rule and run when the table is built, after
  the formats, like gt's; the merged columns are hidden, not removed, so a later format of
  theirs still shows.
- **`autohide`, for all four merges.** gt's `cols_merge` takes `hide_columns`, the other three
  `autohide`; one name is simpler.
- **One column at a time.** gt's `cols_add` takes several expressions of the data; in Nim, a name
  and a proc of the row reads well and needs no macro. Great Tables has no `cols_add` or
  `rows_add`.
- **Hidden rows are not summed up.** A summary sums up what the table shows.
- **Indents of 1em.** gt indents 5px a level, which is hard to see on a phone.

## 3 · More formats

### A unit in a label

The simplest unit is in a column label: a density in kilograms per cubic metre. Between `{{` and
`}}`, a label is written in gt's units notation, where `^` starts a power:
"""

nbCode:
  nbTable tabella(planets(), rownameCol = "planet")
    .colsHide(everything()).colsUnhide(["density", "gravity"])
    .colsLabel({"density": "density, {{kg/m^3}}", "gravity": "gravity, {{m s^-2}}"})
    .optCssTheme()

nbNote("""
`colsUnits({"density": "kg/m^3"})` does the same without touching the label, with a pattern for
where the units go (`unitsPattern = "{1} ({2})"`). Units work in spanners and in the stubhead too.
""", nkCode)

nbText: """
### Units in cells

When the units differ from row to row, they go in a column of their own, and `fmtUnits` reads
each cell. The notation has a few more signs: `_` starts a subscript, a unit after a lone `/` is
a power −1, `:mu:` and other names between colons are symbols, `degC` is °C:
"""

nbCode:
  let constants = tableData:
    constant: ["speed of light", "gravity", "Boltzmann", "vacuum permeability", "room"]
    value: [299792458.0, 9.80665, 1.380649e-23, 1.25663706e-6, 20.0]
    units: ["m /s", "m s^-2", "J /K", "N A^-2", "degC"]
  nbTable tabella(constants, rownameCol = "constant")
    .fmtAuto("value")
    .fmtUnits("units")
    .optCssTheme()

nbNote("""
`fmtAuto` picked a format for the values: scientific notation for the very large and the very
small, up to three decimals for the others. It looks at each column's values, and formats a
currency when the column's name ends with its code (`price_eur`).
""", nkCode)

nbText: """
### Chemistry

Chemical formulas are units with their own rules: a digit after an element is a subscript, a
number before a formula is a count, a charge follows a caret, and arrows join the two sides of a
reaction:
"""

nbCode:
  let reactions = tableData:
    name: ["water", "rust", "photosynthesis", "ammonia"]
    reaction: ["2H2 + O2 -> 2H2O", "4Fe + 3O2 -> 2Fe2O3", "6CO2 + 6H2O -> C6H12O6 + 6O2", "N2 + 3H2 <=> 2NH3"]
    ion: ["OH-", "Fe^3+", "HCO3-", "NH4+"]
  nbTable tabella(reactions, rownameCol = "name")
    .fmtChem(["reaction", "ion"])
    .optCssTheme()

nbText: """
### Fractions

A recipe reads better in fractions. `fmtFraction` finds the closest fraction with a small
denominator (up to 9, 99 or 999), or with a denominator you give, and writes it inline or
diagonal:
"""

nbCode:
  let flour = tableData:
    ingredient: ["flour", "sugar", "butter", "salt"]
    cups: [2.25, 0.333, 0.5, 0.0625]
  nbTable tabella(flour, rownameCol = "ingredient")
    .colsAdd("diagonal", flour["cups"].values)
    .colsAdd("in sixteenths", flour["cups"].values)
    .fmtFraction("cups")
    .fmtFraction("diagonal", layout = "diagonal")
    .fmtFraction("in sixteenths", denominator = 16, simplify = false)
    .optCssTheme()

nbText: """
### Bins and country names

Two formats turn codes into words. `fmtBins` reads intervals as R's `cut()` and pandas' `cut`
write them, `[10,20)`, and shows a range; `fmtCountry` reads country codes and shows their names,
from the Unicode CLDR:
"""

nbCode:
  let visitors = tableData:
    country: ["IT", "FRA", "DE", "JP"]
    stay: ["[1,3)", "[3,7)", "[7,14)", "[14,28)"]
    visits: [1200, 830, 610, 95]
  nbTable tabella(visitors)
    .colsAdd("flag", visitors["country"].values, before = "country")
    .fmtFlag("flag")
    .fmtCountry("country")
    .fmtBins("stay", fmt = proc (x: float): string = formatNumber(x, 0))
    .colsLabel({"flag": "", "stay": "nights"})
    .optCssTheme()

nbNote("""
`fmt` formats each end of an interval, here as an integer. `fmtCountry` takes two- and three-letter codes, in any case.
`fmtPassthrough` is the last of the group: it shows a value as it is, in a `pattern`.
""", nkCode)

nbText: """
### Choices

- **Unicode in text.** A table printed in a terminal or written as Markdown shows `kg/m³`, `H₂O`
  and `2¼`, with Unicode superscripts and subscripts; where a character has none (there is no
  subscript f) it writes `T_(eff)`. gt's text output keeps the notation as it was typed.
- **Symbols are characters.** `:mu:` is µ and `->` is →, plain characters in every output; gt
  draws reaction arrows as small SVG pictures. The three equilibrium arrows of gt are all ⇌.
- **One label helper.** Every renderer gets a column label from `columnLabel`, so `{{...}}` and
  `colsUnits` work the same in HTML, text and Markdown.
- **`accuracy` and `denominator`.** gt's `accuracy` takes "low", "med", "high" or a number; two
  arguments say which is which.
- **`fmt` is a proc of a float.** gt's `fmt_bins(fmt = ~ fmt_integer(.))` formats a small gt
  table; in Nim the proc that formats one number is simpler.
- **Country names from CLDR, at build time.** `tools/cldr.nim` reads CLDR's JSON and writes
  `countries.nim`, a constant table, so nothing is read at run time and the core still needs only
  Nim's standard library. Names are English until the locales of group 4.
- **Not yet:** a currency for every ISO code in `fmtAuto` (it knows the common ones until group
  4), and gt's `fmt_units` in LaTeX.

## 4 · Every locale

*Planned, PR 4.* Numbers, currencies and dates in the locales of CLDR, generated into a Nim
module at compile time; rotated labels, more options, extracting the built table as data, a
preview of a big table, body styles from a column, more datasets.

## 5 · Pictures in cells

*Planned, PR 5.* Icons and images inlined in the page, and nanoplots: lines, bars and boxes in
SVG inside a cell.

## How it is built

Everything above runs in one place, `build.nim`, the step every renderer shares. For each cell
it now does, in order:

1. **format** the value (`formatCell`: the last format that covers it, then any substitution);
2. **merge** it with other columns, when a merge rule starts at its column (`shownCell`, with
   `fillPattern` for the pattern and its `<<...>>` parts);
3. **transform** the text (`textTransform`).

Then, for the table as a whole:

4. the rows go in display order, without the hidden ones, into their groups;
5. each group gets its **summary rows**, and the table its grand ones: an aggregate gets the
   group's non-missing values of a column, and its result is formatted like the column
   (`summaryOf`, `formatSummary`);
6. the columns aligned on the decimal mark get their padding, summary cells included
   (`alignDecimals`);
7. the footnote marks are numbered in reading order, through the summary rows too.

The renderers only lay out the result: the HTML adds the classes `tb_summary_row`,
`tb_grand_summary_row` and `tb_indent_N`; the text draws a dotted rule before a group's
summary and a double one before the table's.

The formats of group 3 are plain functions, as the formats of 0.1 are, so they run in step 1.
Units are read in three passes (`units.nim`): a part between `%` signs goes to the chemistry
reader; the rest is split at spaces into tokens, and each token into a name, a subscript after
`_` and a power after `^` (`unitToken`); the tokens are joined again with spaces, none after an
opening bracket or around a lone `/` (`joinTokens`). Chemistry reads a token a character at a
time (`chemToken`): an isotope at the start, then a count, then elements, with digits after them
as subscripts and a sign at the end as a charge. A superscript or a subscript is `<sup>` or
`<sub>` in HTML and Unicode in text (`toSuperscript`, `toSubscript`). Labels go through
`renderLabel`, which formats what is between `{{` and `}}` and leaves the rest to the label's
own kind of text (plain or Markdown).
"""

nbSave
