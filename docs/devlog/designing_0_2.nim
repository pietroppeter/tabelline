## devlog: 10 Nov 2026 A | Designing tabelline 0.2 | tabelline 0.2: summing up, rows and columns, more formats, every locale, pictures in cells, cells with more than one value. Each group from zero, simplest first, with the choices behind it and how it is built.
## A dated post, written while 0.2 is built: each group is added when its PR is ready for review.
import std/[os, sugar, strutils, sequtils, tables, algorithm]
import nimib
import tabelline, tabelline/[nimib, datasets]
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "designing-0-2" / "index.html"
nb.useTabelline(title = "Designing tabelline 0.2", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "10 November 2026", "Designing tabelline 0.2", """
tabelline 0.2: summing up, rows and columns, more formats, every locale, pictures in cells, cells with more than one value. Each group from zero, simplest first, with the choices behind it and how it is built.
"""

nbText: """
0.1 had the parts of a table, from the title to the footer, and the formats for single values.
0.2 was going to add rows and merges; on the day 0.1 shipped, it grew to hold every format,
every locale and pictures in cells too, then cells that hold more than one value, and last the
tails of what was still partial. That is seven groups of features, each built in its own pull request and explained here when it is ready,
from the simplest idea up. Every name they add is in the [Reference](../../api/), and
[A reference in our own style](../reference/) tells how that page was made.
"""

nbToc()

nbText: """
## Seven groups

Each group needs the ones before it: summing up comes first because summary columns, in the
second group, reuse its aggregates; pictures come last because nanoplots need the formats and
the options of the groups before them, and lists and records come after them because they feed
the pictures. The tails come last: they finish what the others began.
"""

block:
  type G = object
    group, what, status: string
  let rows = @[
    G(group: "1 · Summing up", what: "summary rows for each group and for the whole table; aggregates", status: "built"),
    G(group: "2 · Rows and columns", what: "merged columns, added columns and rows, summary columns, hidden rows, stub indent, decimal alignment", status: "built"),
    G(group: "3 · More formats", what: "units, fractions, chemistry, bins, automatic formats, country names", status: "built"),
    G(group: "4 · Every locale", what: "numbers, currencies and dates from CLDR; rotated labels, more options, extract, preview, body styles, datasets", status: "built"),
    G(group: "5 · Pictures in cells", what: "icons, images and nanoplots, all inlined", status: "built"),
    G(group: "6 · More than one value", what: "lists and records in a cell, the dot (v.x, it.mass), nanoplots of x and y", status: "built"),
    G(group: "7 · The tails", what: "a stub of several columns, groups as a column, the other options, images anywhere, font stacks, gt's datasets", status: "built"),
  ]
  let t = tabella(rows, rownameCol = "group"):
    tabHeader "0.2 in seven groups"
    colsLabel:
      what: "what it adds"
      status: "now"
    tabStyle style.css("white-space: nowrap"), loc.stub()
    tabStyle style.text(weight = "bold"), loc.body("status", where(it.status == "built"))
    optCssTheme()
  nbTable t

nbText: """
## 1 · Summing up

### One number for a group

The simplest summary is one number: the moons of each kind of planet. `summaryRows` adds a row
under each group, labelled in the stub, for each pair of a label and an aggregate:
"""

nbCode:
  let moons = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
    summaryRows:
      total: agg.sum
    optCssTheme()
  nbTable moons

nbNote("""
Under `summaryRows:` each line is a pair: the label of the row and how to sum up a column. It is the same call as `summaryRows fns = {"total": agg.sum}`, the list of pairs gt calls `fns`. `columns` is not given, so every numeric column is summed up, here only `moons`.
""", nkCode)

nbText: """
### And one for the whole table

`grandSummaryRows` does the same for every row of the table, whatever its group, after a double
rule. Several aggregates give several rows:
"""

nbCode:
  let allMoons = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
    summaryRows:
      total: agg.sum
    grandSummaryRows:
      "all moons": agg.sum
      most: agg.max
      planets: agg.count
    optCssTheme()
  nbTable allMoons

nbNote("""
The aggregates are `agg.sum`, `agg.mean`, `agg.median`, `agg.min`, `agg.max`, `agg.count` and
`agg.std`. `aggregate(proc)` makes one from any proc of the column's values, such as the middle
value: `aggregate((vs: seq[Value]) => vs[vs.len div 2])`.
""", nkCode)

nbText: """
### Formatted like their column

A summary cell is a number like the others in its column, so it takes the column's format: the
masses keep their three decimals, the diameters their thousands separator. A count is a count of
rows, not a mass, so it is always an integer; `fmt` gives the rows of one call a format of
their own:
"""

nbCode:
  let sizes = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "moons"]
    fmtNumber "mass", decimals = 3, dropTrailingZeros = true
    fmtInteger "diameter"
    summaryRows:
      total: agg.sum
      columns = "mass"
      missingText = ""
    grandSummaryRows:
      mean: agg.mean
      fmtNumber(decimals = 0)
    optCssTheme()
  nbTable sizes

nbNote("""
`missingText = ""` leaves the cells of the columns that are not summed up empty (gt writes a
dash, and so does tabelline by default). A line `name = value` in a block is a named argument. The grand mean is formatted by the line `fmtNumber(decimals = 0)`: in a summary block it stands for `fmt = (x: float) => formatNumber(x, decimals = 0)`, a proc of a float, like Great Tables' `vals.fmt_*`.
""", nkCode)

nbText: """
### Choices

Each choice says what gt (R) and Great Tables (Python) do.

- **`agg.sum`, not `sum`.** In Nim `{"total": sum}` cannot compile, because Nim's own `sum`,
  `min` and `max` make the name ambiguous. A namespace, like `style.fill` and `loc.body`, keeps
  the names and makes a typo a compile error. An aggregate gets one column's values, without the
  missing ones. *gt:* `fns = list(total = "sum")`, a name, a function or a formula. *Great
  Tables:* `fns = {"total": pl.col("mass").sum()}`, a Polars expression or a function of the
  data frame.
- **Pairs as a block.** Inside `tabella(data): body`, `summaryRows:` takes its pairs one per
  line, as every verb with a list of pairs does (`colsLabel:`, `colsWidth:`, `colsUnits:`,
  `textCaseMatch:`, `summaryColumns:`, ...), with named arguments as `name = value` lines; the
  pair form `fns = {"total": agg.sum}` makes the same call. The name `fns` is gt's and Great
  Tables', and the block hides it. *gt:* a named list. *Great Tables:* a dict.
- **The column's format by default.** A table where the totals look different from the rows
  above them is rarely what you want, so tabelline uses the last format of the column; `fmt` is
  a proc of a float. *gt:* unformatted unless `fmt = list(~ fmt_number(.))`. *Great Tables:*
  unformatted unless `fmt = vals.fmt_number`.
- **Numeric columns by default.** `columns` is `numeric()`, since a sum of names is no sum.
  *gt:* `everything()`. *Great Tables:* the columns named in the expressions.
- **A stub when there is none.** Summary rows need a place for their label, so a table without
  row names gets an empty stub. *gt:* the same. *Great Tables:* the same; `summary_rows` without
  row groups is an error, as here.
- **Styles and notes.** Summary cells have their own locations, `loc.summary`,
  `loc.summaryStub`, `loc.grandSummary`, `loc.grandSummaryStub`, and footnote marks are numbered
  in reading order through them. *gt:* `cells_summary()`, `cells_stub_summary()` and the grand
  ones. *Great Tables:* `loc.summary()`, `loc.summary_stub()`, the names tabelline follows.
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
  let merged = tabella(missions, rownameCol = "mission"):
    colsMergeRange "launch", "ended"
    colsMerge ["target", "moon"], pattern = "{1}<< and {2}>>"
    optCssTheme()
  nbTable merged

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
  let grown = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    colsHide everything()
    colsAdd "moons per Earth mass", (r: Row) => toValue(r.moons.toFloat / r.mass.toFloat * 5.97)
    fmtNumber "moons per Earth mass", decimals = 1
    rowsHide where(it["type"] == "Terrestrial")
    rowsAdd [(planet: "Pluto", `type`: "Dwarf planet", moons: 5, mass: 0.0130)]
    optCssTheme()
  nbTable grown

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
  let totals = tabella(medals, rownameCol = "country"):
    summaryColumns:
      total: agg.sum
    grandSummaryRows:
      all: agg.sum
    optCssTheme()
  nbTable totals

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
  let aligned = tabella(budget, rownameCol = "item"):
    tabStubIndent [1, 2, 4, 5], "increase"
    fmtNumber "eur", decimals = 2, dropTrailingZeros = true
    colsAlignDecimal "eur"
    optCssTheme()
  nbTable aligned

nbNote("""
The alignment pads each number on the right with figure spaces, which are as wide as a digit
(and a punctuation space where there is no mark): it needs no CSS, so it works in the text and
Markdown outputs too.
""", nkCode)

nbText: """
### Choices

- **Merges at render time.** A merge is kept as a rule and run when the table is built, after
  the formats; the merged columns are hidden, not removed, so a later format of theirs still
  shows. *gt* and *Great Tables:* the same, with the same `{1}<< ({2})>>` patterns.
- **`autohide`, for all four merges.** One name is simpler. *gt* and *Great Tables:*
  `cols_merge` takes `hide_columns`, the other three `autohide`.
- **One column at a time.** A name and a proc of the row reads well in Nim and needs no macro.
  *gt:* `cols_add` takes several expressions of the data. *Great Tables:* no `cols_add`; you add
  the column to the data frame.
- **Rows of your own, from data.** `rowsAdd` takes a `TableData` or objects. *gt:* `rows_add`
  takes name = value pairs. *Great Tables:* no `rows_add`.
- **Hidden rows are not summed up.** A summary sums up what the table shows. *gt:* `rows_hide`
  is new. *Great Tables:* no `rows_hide`.
- **Summary columns.** The aggregates of `summaryRows`, across a row. *gt:* `summary_columns`,
  new. *Great Tables:* not yet.
- **Indents of 1em.** 5px is hard to see on a phone. *gt:* 5px a level. *Great Tables:*
  `tab_stub_indent` too.
- **Decimal marks with figure spaces.** No CSS, so it works in text too. *gt* and *Great
  Tables:* the same characters.

## 3 · More formats

### A unit in a label

The simplest unit is in a column label: a density in kilograms per cubic metre. Between `{{` and
`}}`, a label is written in gt's units notation, where `^` starts a power:
"""

nbCode:
  let labelled = tabella(planets(), rownameCol = "planet"):
    colsHide everything()
    colsUnhide ["density", "gravity"]
    colsLabel:
      density: "density, {{kg/m^3}}"
      gravity: "gravity, {{m s^-2}}"
    optCssTheme()
  nbTable labelled

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
  let physics = tabella(constants, rownameCol = "constant"):
    fmtAuto "value"
    fmtUnits "units"
    optCssTheme()
  nbTable physics

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
  let chemistry = tabella(reactions, rownameCol = "name"):
    fmtChem ["reaction", "ion"]
    optCssTheme()
  nbTable chemistry

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
  let recipe = tabella(flour, rownameCol = "ingredient"):
    colsAdd "diagonal", flour["cups"].values
    colsAdd "in sixteenths", flour["cups"].values
    fmtFraction "cups"
    fmtFraction "diagonal", layout = "diagonal"
    fmtFraction "in sixteenths", denominator = 16, simplify = false
    optCssTheme()
  nbTable recipe

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
  let visits = tabella(visitors):
    colsAdd "flag", visitors["country"].values, before = "country"
    fmtFlag "flag"
    fmtCountry "country"
    fmtBins "stay", fmt = x => formatNumber(x, 0)
    colsLabel:
      flag: ""
      stay: "nights"
    optCssTheme()
  nbTable visits

nbNote("""
`fmt` formats each end of an interval, here as an integer. `fmtCountry` takes two- and three-letter codes, in any case.
`fmtPassthrough` is the last of the group: it shows a value as it is, in a `pattern`.
""", nkCode)

nbText: """
### Choices

- **Unicode in text.** A table printed in a terminal or written as Markdown shows `kg/m³`, `H₂O`
  and `2¼`, with Unicode superscripts and subscripts; where a character has none (there is no
  subscript f) it writes `T_(eff)`. *gt:* the text output keeps the notation as it was typed.
  *Great Tables:* `fmt_units` in HTML and LaTeX.
- **Symbols are characters.** `:mu:` is µ and `->` is →, plain characters in every output.
  *gt:* reaction arrows drawn as small SVG pictures, and three equilibrium arrows (all ⇌ here).
  *Great Tables:* `fmt_chem` too.
- **One label helper.** Every renderer gets a column label from `columnLabel`, so `{{...}}` and
  `colsUnits` work the same in HTML, text and Markdown. *gt:* `cols_units` and `{{...}}` in
  `cols_label`. *Great Tables:* `{{...}}` in `cols_label` and `define_units`, no `cols_units`.
- **`accuracy` and `denominator`.** Two arguments say which is which. *gt:* one `accuracy`
  takes "low", "med", "high" or a number. *Great Tables:* `fmt_fraction`, the same `accuracy`.
- **`fmt` is a proc of a float.** The proc that formats one number is simpler in Nim. *gt:*
  `fmt_bins(fmt = ~ fmt_integer(.))`, a formula that formats a small gt table. *Great Tables:*
  no `fmt_bins`.
- **Country names from CLDR, generated once.** The data is stable, so `tools/cldr.nim` reads
  CLDR's JSON once and writes `countries.nim`, a constant table committed with the code: nothing
  is downloaded when you build or run, and the core still needs only Nim's standard library. It
  is run again for a new CLDR release. Names are English until the locales of group 4. *gt:*
  CLDR data stored in the package, in every locale. *Great Tables:* no `fmt_country`.
- **Not yet:** a currency for every ISO code in `fmtAuto` (it knows the common ones until group
  4), and gt's `fmt_units` in LaTeX. *Great Tables* has `fmt_passthrough`, no `fmt_auto`.

## 4 · Every locale

### A number in another language

The simplest thing a locale changes is the marks of a number: which character groups the
thousands, which one starts the decimals. A table takes a locale, and every format follows it:
"""

nbCode:
  let amounts = tableData:
    n: [1234567.891, 0.5]
    share: [0.256, 0.5]
  let italian = tabella(amounts, locale = "it"):
    fmtNumber "n", decimals = 2
    fmtPercent "share"
    optCssTheme()
  nbTable italian

nbText: """
A format can also take a locale of its own, which wins over the table's. That is how one table
can show the same number in four languages, one column each:
"""

nbCode:
  let marks = tabella(amounts):
    colsHide "share"
    colsAdd "it", amounts["n"].values
    colsAdd "de_CH", amounts["n"].values
    colsAdd "fr", amounts["n"].values
    fmtNumber "n", decimals = 2
    fmtNumber "it", decimals = 2, locale = "it"
    fmtNumber "de_CH", decimals = 2, locale = "de-CH"
    fmtNumber "fr", decimals = 2, locale = "fr"
    colsLabel:
      n: "en"
    optCssTheme()
  nbTable marks

nbNote("""
`locale` is a tag of Unicode CLDR, in any case, with `-` or `_`. An unknown region falls back to its language (`"it-XX"` is `"it"`) and an unknown language to English. The French group mark is a narrow no-break space, as CLDR has it.
""", nkCode)

nbText: """
### Money

A currency adds a symbol, a number of decimals and a place for the symbol, which depends on the
language, not on the currency: the euro goes before the amount in English and after it in
Italian. Every code of ISO 4217 that CLDR knows (305 of them) has its symbol and its decimals:
"""

nbCode:
  let prices = tableData:
    item: ["espresso", "pizza", "refund"]
    eur: [1.3, 7.04, -2.5]
    jpy: [480, 1600, -300]
    bhd: [0.6, 2.9, -0.8]
  let money = tabella(prices, rownameCol = "item", locale = "it"):
    fmtCurrency "eur", currency = "EUR"
    fmtCurrency "jpy", currency = "JPY", accounting = true
    fmtCurrency "bhd", currency = "BHD", placement = "left"
    optCssTheme()
  nbTable money

nbNote("""
The yen has no decimals and the Bahraini dinar three, as CLDR says. `accounting = true` writes a negative amount in brackets; `placement = "left"` puts the symbol first whatever the locale.
""", nkCode)

nbText: """
### Dates in their own words

A date needs more: the names of months and days, and an order. gt has two kinds of date style:
fixed ones, with an order of their own and the names in the locale's language
(`"day_month_year"`), and flexible ones, named by the parts they show (`"yMMMd"`: year, short
month, day), which each language writes in its own order:
"""

nbCode:
  type Way = object
    locale, fixed, flexible, time: string
  var ways: seq[Way]
  for l in ["en", "it", "de", "ja", "ru"]:
    ways.add Way(locale: l, fixed: formatDate("2026-11-07", "wday_day_month_year", l),
                 flexible: formatDate("2026-11-07", "yMMMEd", l), time: formatTime("14:35", "hm", l))
  let dates = tabella(ways, rownameCol = "locale"):
    colsLabel:
      fixed: "wday_day_month_year"
      flexible: "yMMMEd"
      time: "hm"
    optCssTheme()
  nbTable dates

nbNote("""
`formatDate` and `formatTime` are the plain functions under `fmtDate` and `fmtTime`; a table's `locale` reaches them through the verbs. The fixed style keeps its order in every language (so Japanese reads oddly); the flexible one is CLDR's own pattern for each locale.
""", nkCode)

nbText: """
### Big tables, and tables as data

The rest of the group is small tools that gt has and 0.1 did not. A long table can be previewed,
its first and last rows with a row that names the rows left out; and a style can
come from the data:
"""

nbCode:
  let islands = tabellaPreview(isole(), topN = 5, bottomN = 1):
    colsHide "city"
    fmtInteger ["area", "population"]
    tabStyleBody style.text(weight = "bold"), columns = "country", values = ["Italy"], targets = "row"
    optCssTheme()
  nbTable islands

nbNote("""
`tabellaPreview` takes a body of verbs, as `tabella` does. `tabStyleBody` styles the cells whose value is one of `values` (or contains a `pattern`, or makes a proc true), or here their whole row. `fromColumn("colour")` inside any style takes the value from another column of the same row: `style.fill(fromColumn("colour"))`.
""", nkCode)

nbText: """
A label can lie on its side where many narrow columns have long names: a column of check marks
needs one character, its label a word or two.
"""

nbCode:
  let traits = tabella(planets(), rownameCol = "planet"):
    colsAdd "rocky", proc (r: Row): Value = toValue(r["type"].s == "Terrestrial")
    colsAdd "has moons", proc (r: Row): Value = toValue(r.moons.i > 0)
    colsAdd "has rings", proc (r: Row): Value = r.rings
    colsHide ["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "moons", "rings"]
    fmtTf ["rocky", "has moons", "has rings"]
    colsAlign alCenter, ["rocky", "has moons", "has rings"]
    colsLabelRotate ["rocky", "has moons", "has rings"]
    optCssTheme()
  nbTable traits

nbText: """
Once built, a table can be read back as data: `extractCells` gives the shown text of some cells,
`extractBody` the whole body and `extractSummary` the summary rows, each as a `TableData`:
"""

nbCode:
  let back = tabella(extractSummary(sizes)):
    optCssTheme()
  nbTable back

nbText: """
The group also adds 72 of gt's options (142 in all: every rule of the heading, the labels, the
groups, the body, the stub and the footer, with its style, width and colour), two datasets
(`isole()`, the islands of the Mediterranean, and `citta()`, the cities of the European Union,
from [Rethinking tabelline's datasets](../datasets/)), and renames `agg.sd` to `agg.std`.

### Choices

- **CLDR, generated once.** `tools/cldr.nim` reads CLDR 49 and writes `locales.nim` (657
  locales) and `currencies.nim`, committed with the code: nothing is read when you build or run.
  A locale keeps only what differs from its parent (`en-AU` from `en-001`, from `en`), and each
  value is written once, however many locales share it (10,209 values for 27,287 fields), so the
  data of 657 locales is 199 KB in a program (290 KB before the values were shared). *gt:* its
  own tables from CLDR, 574 locales, in its internal data (576 KB compressed, with its other
  tables). *Great Tables:* 574 locales for numbers, in a CSV of 256 KB; the names and patterns
  of dates come from Babel, a package of about 10 MB.
- **The symbol where the language puts it.** `fmtCurrency` follows the locale's pattern; `placement`
  chooses. *gt:* the symbol on the left unless `placement = "right"`. *Great Tables:* the same.
- **ISO codes.** `currency` is a code ("EUR"). *gt:* a code or a name ("euro"). *Great Tables:*
  a code.
- **Grouped by three.** CLDR's minimum grouping (Spanish writes 1234) and the Indian grouping
  (12,34,567) are left out, so a column lines up. *gt:* the same, with `system = "ind"` for the
  Indian one (not yet here). *Great Tables:* the same.
- **Latin digits.** Every locale writes 0-9. *gt:* the same. *Great Tables:* the same.
- **A style from the data is a value.** `fromColumn` goes inside any style, and a proc of the
  row covers the rest. *gt:* `from_column(column, na_value, fn)`. *Great Tables:* `from_column`
  too.
- **`pattern` is plain text.** `tabStyleBody` looks for it in the value; a regular expression
  would need PCRE. *gt:* a regular expression. *Great Tables:* `tab_style_body` too.
- **The preview is a table.** `tabellaPreview` returns a `Tabella` and takes a body of verbs, as `tabella`.
  *gt:* `gt_preview()` returns a gt table too. *Great Tables:* no preview.
- **`agg.std`.** The name of Great Tables and Polars, short and plain. *gt:* `"sd"`, R's name.
  *Great Tables:* `std`, through Polars.
- **Not yet:** country names in other languages, `system = "ind"`, flexible styles with a time
  zone (`"Hmv"`), hidden column labels, groups as a column, a multiline footer.

## 5 · Pictures in cells

### An icon for a word

The simplest picture is an icon: a cell says its name, and the table draws it. gt and Great
Tables both take the icons of Font Awesome, and so does tabelline, all 2,163 free ones:
"""

nbCode:
  let outputs = tableData:
    output: ["HTML", "text", "Markdown"]
    icon: ["globe", "terminal", "fab fa-markdown"]
    verb: ["toHtml", "toText", "toMarkdown"]
  let goes = tabella(outputs, rownameCol = "output"):
    fmtIcon "icon", height = "1.5em"
    optCssTheme()
  nbTable goes

nbNote("""
A name is a short name ("globe": the regular style when there are two), a full one ("fab fa-markdown", the brands style) or an older name ("user-large" is "user"). An icon takes the colour of the text unless `fillColor` says otherwise; `fillColors` colours each name its own way. In a text table the names stay.
""", nkCode)

nbText: """
### A picture of your own

A file is a picture too. `fmtImage` reads it when the verb is called and puts it in the page
as a data URL, so the page still needs nothing else:
"""

nbCode:
  let pictures = tableData:
    what: ["la tavola pitagorica, to 3"]
    picture: ["tavola"]
  let own = tabella(pictures, rownameCol = "what"):
    fmtImage "picture", path = "docs/devlog/data/designing-0-2", filePattern = "{x}.svg", height = "3em"
    optCssTheme()
  nbTable own

nbNote("""
`path` and `filePattern` turn the cell "tavola" into the file `docs/devlog/data/designing-0-2/tavola.svg`. An address (`https://...`) is left as it is: tabelline loads nothing remote.
""", nkCode)

nbText: """
### A plot as small as a word

A nanoplot is a plot in a cell. With one number per row it is a bar, and the bars of a column
share their zero line, so they can be compared up and down the column. Here the five largest
cities of the EU, by people:
"""

nbCode:
  let big = tabellaPreview(citta(), topN = 5, bottomN = 0, inclRownums = false):
    colsHide "counted"
    colsAdd "bar", proc (r: Row): Value = r.population
    fmtInteger "population"
    fmtNanoplot "bar", plotType = "bar",
      options = nanoplotOptions(dataBarFillColor = "var(--primary)", dataBarStrokeColor = "var(--primary)")
    colsLabel:
      bar: ""
    optCssTheme()
  nbTable big

nbNote("""
`fmtNanoplot` on a column of numbers draws one bar per row. The bar shows its value when the pointer is over it (or a finger taps it): the SVG carries the text, and the table's CSS shows it on `:hover`, without JavaScript.
""", nkCode)

nbText: """
### Many values in a cell

A cell can hold many values, "1 4 2 8", and then a nanoplot is a line, a bar or a box plot of
them. The box plot is the one that says most about a group: here the people of the large cities
of each country, in thousands. The box holds the middle half, the whiskers the rest, and each
dot far away is a capital:
"""

nbCode:
  type Country = object
    state: string
    cities: int
    people: string
  var byState: OrderedTable[string, seq[string]]
  let eu = citta()
  for i in 0 ..< eu.nrows:
    byState.mgetOrPut(eu["state", i].s, @[]).add $(eu["population", i].toFloat / 1000)
  var countries: seq[Country]
  for state, people in byState:
    if people.len >= 4: countries.add Country(state: state, cities: people.len, people: people.join(" "))
  countries.sort((a, b) => cmp(b.cities, a.cities))
  let boxes = tabella(countries, rownameCol = "state"):
    fmtNanoplot "people", plotType = "boxplot",
      options = nanoplotOptions(dataBarStrokeColor = "var(--primary)")
    colsLabel:
      people: "people, thousands"
    optCssTheme()
  nbTable boxes
  echo boxes

nbNote("""
A cell of nanoplot values is a text of numbers separated by spaces, commas or semicolons, with `NA` for a missing one (or, since group 6, a list of numbers). The box plots of a column share their scale. `echo` prints the table as text, where a box plot is its five numbers: whisker, quartile, median, quartile, whisker.
""", nkCode)

nbText: """
`colsNanoplot` makes such a cell from several columns of a row, and hides them; a line or bar
plot can have a reference line (a number, or "mean", "median", "q1" ...) and a reference area,
and with `autoscale` every plot of the column shares its y axis. The [guide](../../explainer/#pictures-in-cells)
draws the times table that way.

### Choices

- **Every free icon, inlined.** `tools/fontawesome.nim` reads the npm package of Font Awesome
  Free 7 and writes `fontawesome.tsv` (1.5 MB: 2,163 icons and 614 older names), read when
  compiling and only by a program that draws icons. *gt:* the fontawesome R package.
  *Great Tables:* the same icons, in its own CSV files.
- **The regular style first.** "star" is the outlined star; "fas fa-star" the solid one. *gt:*
  the same (fontawesome's `prefer_type = "regular"`). *Great Tables:* the same.
- **Icons are read aloud.** By default a screen reader says the icon's label ("Star").
  *gt:* the same (`a11y = "semantic"`). *Great Tables:* hidden from screen readers.
- **Images inlined, addresses kept.** A local file becomes a data URL; an address stays an
  address, never downloaded. *gt:* `encode = TRUE` inlines local files too. *Great Tables:* the
  same.
- **Nanoplots ported, not redrawn.** The SVG is Great Tables' (`_utils_nanoplots.py`, MIT): the
  same sizes, colours, labels and box plot, so a nanoplot looks the same in both. Its hover rules
  go once in the table's CSS, not in every SVG, and a colour can be a CSS variable. *gt:*
  `fmt_nanoplot()` and `cols_nanoplot()`, experimental. *Great Tables:* `fmt_nanoplot()` only.
- **Missing values make a gap.** `missingVals = "gap"` by default. *gt:* "gap". *Great
  Tables:* "marker".
- **A reference is text.** `referenceLine = "mean"` or `"10"`, one type for both. *gt:* a
  number or a keyword. *Great Tables:* the same.
- **Sparklines in text.** A text table draws a nanoplot with blocks (`▁▃▅█`), so it still says
  something in a terminal or a test. *gt:* nothing in text. *Great Tables:* nothing.
- **Not yet:** a colour per point, `alt` from a column, SVG
  flags, gt's `local_image()` and `web_image()`.

## 6 · More than one value

### A list in a cell

Until now a cell held one value: a number, a text, a date. Nanoplots needed several, and read
them from a text, "1 4 2 8". Now a cell can hold a list, made from any `seq`:
"""

nbCode:
  let sistema = tableData:
    planet: ["Earth", "Mars", "Jupiter"]
    moons: [@["Moon"], @["Phobos", "Deimos"], @["Io", "Europa", "Ganymede", "Callisto"]]
  echo tabella(sistema, rownameCol = "planet")
  echo sistema["moons", 2][0], " ", sistema["moons", 2].len

nbNote("""
A list is shown as its items, separated by commas. `v[0]` is its first item and `v.len` how many it has. A list is not a number: `numeric()` leaves a list column out, and `toFloat` refuses a list.
""", nkCode)

nbText: """
A format applied to a list works on each item, and the verbs that take several names (icons,
images, flags) take a list as they take names separated by commas.

### A record, and the dot

A record is a cell with named fields, made from an object or a named tuple, as a row of
`toTableData` is. Its fields are read by name, with brackets or with a dot:
"""

nbCode:
  let sensors = tableData:
    sensor: ["north", "south"]
    span: [(lo: 0.82, hi: 1.56), (lo: 9.13, hi: 12.71)]
  let ranges = tabella(sensors, rownameCol = "sensor"):
    fmtNumber "span", decimals = 1
  echo ranges
  echo sensors["span", 0].hi, " ", sensors["span", 0]["lo"]

nbNote("""
`fmtNumber` formats each field of the record. `.hi` reads a field by name; on a row, the same dot reads a column, so `where(it.mass > 1)` is the way to write a row predicate from now on.
""", nkCode)

nbText: """
"lo: 0.8, hi: 1.6" says what each number is, but a range reads better as "0.8–1.6". A merge
pattern reads the fields of a record by name, so one column of records is enough:
"""

nbCode:
  let spans = tabella(sensors, rownameCol = "sensor"):
    fmtNumber "span", decimals = 1
    colsMerge ["span"], pattern = "{lo}–{hi}"
  echo spans

nbNote("""
In a `colsMerge` pattern, `{lo}` is the field `lo` of the first column and `{2.lo}` of the second; each is formatted as its column is, and a missing field drops its `<<...>>` part. A field that is not in every record fails when the verb is called.
""", nkCode)

nbText: """
### A plot of x and y

A record of two lists, `x` and `y`, is what Great Tables takes for a nanoplot whose points are
not evenly spaced: each value is drawn at its place on the x axis. Two runners and their lap
times, measured at different laps:
"""

nbCode:
  let laps = tableData:
    runner: ["Anna", "Bruno"]
    times: [(x: @[0.0, 1, 2, 5], y: @[62.0, 60, 61, 58]), (x: @[0.0, 3, 4, 5], y: @[65.0, 63, 66, 59])]
  let race = tabella(laps, rownameCol = "runner"):
    fmtNanoplot "times", autoscale = true,
      options = nanoplotOptions(dataLineStrokeColor = "var(--primary)", dataPointFillColor = "var(--primary)")
    colsLabel:
      times: "lap times, seconds"
    optCssTheme()
  nbTable race
  echo race

nbNote("""
`autoscale` gives both plots the same axes, x and y. In text, the sparkline follows the order of `x` and leaves out its spacing.
""", nkCode)

nbText: """
### Choices

- **A list and a record, nothing more.** Two kinds of value, `vkList` and `vkRecord`, made by
  `toValue` from a seq, an array, an object or a tuple. *gt:* one value per cell; gtExtras
  draws from tibble list-columns. *Great Tables:* Polars list columns, for nanoplots.
- **Records are not from gt.** A record shows as "lo: 0.8, hi: 1.6", formatted field by
  field. The closest thing is a merge (group 2): `colsMerge` shows several columns in one cell
  with a pattern, and `colsMergeRange` writes "0.8–1.6". The two do different jobs. A merge
  keeps the values in their own columns, which sort, style and add up on their own, and joins
  them only when the table is shown; a record is one value, which is how the data came (a
  range, a point, a pair of lists for a nanoplot). A merge takes a record column as it takes
  any other: it joins the record's text, and its pattern reads the record's fields: `{lo}` is
  the field `lo` of the first column, `{2.lo}` of the second, each formatted as its column is.
  So `colsMerge ["span"], pattern = "{lo}–{hi}"` shows a record as "0.8–1.6". *gt:* `cols_merge`
  and its three variants, with patterns of columns only (`{1}`, `{2}`). *Great Tables:* the same.
- **x and y as Great Tables has them.** A record with fields `x` and `y`. *gt:* x values come
  from another column (`columns_x_vals` in `cols_nanoplot`). *Great Tables:* a dict
  `{"x": [...], "y": [...]}`; its x values can be dates too, and so can tabelline's (group 7).
- **The dot is Nim sugar.** In a row predicate `it` is the row: the Nim idiom of `filterIt`
  and `mapIt` (`std/sequtils`), where a template names the current element `it`, and
  `where(cond)` turns `cond` into a proc of a row named `it`. `it.mass` and `v.hi` are a Nim
  *dot operator*: when a name is not
  a field or a proc of the value, the dot reads it by name. A name the value already has
  (`kind`, `len`, `index`) is that, a keyword (`type`) needs brackets, and a misspelled name is
  found when the code runs. *gt:* names are strings (`"mass"`) or bare names in the tidyverse.
  *Great Tables:* strings, or Polars' `pl.col("mass")`.
- **Formats item by item.** A format on a list formats each item; the verbs that need the whole
  list (icons, images, flags, nanoplots) say so. *gt:* no lists to format. *Great Tables:* the
  same.

## 7 · The tails

### A stub of several columns

The stub held one column, the row names. Now it can hold a few, the highest level first, and a
value equal to the one above it is drawn once, over all the rows that repeat it:
"""

nbCode:
  let garage = tableData:
    maker: ["Ferrari", "Ferrari", "Fiat", "Fiat", "Lancia"]
    model: ["Roma", "Purosangue", "500e", "Panda", "Ypsilon"]
    hp: [612, 725, 118, 70, 156]
  let cars = tabella(garage, rownameCol = ["maker", "model"]):
    optCssTheme()
  nbTable cars

nbNote("""
`rownameCol` takes a list instead of a name. `loc.stub(cols = "maker")` styles one level; `stubColumns(cars)` is `@["maker", "model"]`. In text the repeated value is left blank.
""", nkCode)

nbText: """
### Groups as a column

A group's label can be a column of the stub too, beside its rows, instead of a row above them:
"""

nbCode:
  let fleet = tableData:
    model: ["Roma", "Purosangue", "500e", "Panda"]
    kind: ["sport", "sport", "city", "city"]
    hp: [612, 725, 118, 70]
  let byKind = tabella(fleet, rownameCol = "model", groupnameCol = "kind", rowGroupAsColumn = true):
    summaryRows:
      most: agg.max
    optCssTheme()
  nbTable byKind

nbNote("""
`rowGroupAsColumn = true` when the table is made, or `tabOptions(rowGroupAsColumn = true)` later. The label spans the group's rows and its summary rows.
""", nkCode)

nbText: """
### The other options, images and fonts

`tabOptions` now has 164 options, 160 of gt's 196: hidden column labels, a units pattern for all
columns, a label for the rows outside any group, notes on one line, a message for a table with
no rows, the indent of a level, stripes in the stub. An image can go in a title or a label
(`localImage`, `webImage`), a font stack has a name (`systemFonts("old-style")`), and a nanoplot
can give each point its own colour. gt's `gtcars`, `countrypops`, `illness` and `metro` are in
`tabelline/datasets`.

### Choices

- **A list of columns, not a second argument.** `rownameCol = ["maker", "model"]`. *gt:* the
  same, `rowname_col = c("maker", "model")`. *Great Tables:* a list too,
  `rowname_col=["maker", "model"]`.
- **Repeats are drawn once.** A level spans the rows that repeat it, under the same higher
  levels and in the same group. *gt:* the same idea.
- **Options that mean nothing in HTML wait.** The 36 options left are for interactive tables,
  pages, LaTeX and Quarto: they come with those outputs. *gt:* all 196 in `tab_options()`.
- **Stripes leave the stub alone.** As in gt, `rowStripingIncludeStub` is off: the stub is no
  longer striped by default. *Great Tables:* the same.
- **No `google_font()`.** tabelline loads nothing remote; inline a font in the page instead.
  *gt* and *Great Tables:* `google_font()` links Google's servers.
- **A list of options repeats.** `dataPointFillColor = @["red", "blue"]` colours the points
  red, blue, red, ... *Great Tables:* a list must have one value or one per point.
"""

nbText: """
## Next to gt and Great Tables

tabelline began on a Saturday night, four days before this release, as a port of gt and Great
Tables. With 0.2 it is worth counting again, against the newest of each: Great Tables 1.1 and
gt 1.4, by their references. The [feature map](../../coverage/) has every group.

### Feature by feature
"""

block:
  type Side = object
    side, what: string
  let rows = @[
    Side(side: "only tabelline", what: "rowsAdd, rowsHide, rowOrder, colsAdd, summaryColumns; fmtSpelledNum, fmtBins, fmtAuto, fmtCountry (31 formats to 28); tabellaPreview, tabCaption, extractCells, optTableLines; 657 CLDR locales to 574; text and Markdown output, nimib"),
    Side(side: "both", what: "summary rows, nanoplots, icons, images, units, chemistry, fractions, merged columns, stub indent, a stub of several columns, body styles, colour by value, every location, about as many options (164 to 175)"),
    Side(side: "only Great Tables", what: "interactive tables, LaTeX, PNG and PDF, Google fonts, Shiny, tables from Pandas and Polars, 16 datasets"),
  ]
  let t = tabella(rows, rownameCol = "side"):
    tabHeader "tabelline 0.2 and Great Tables 1.1"
    colsLabel:
      what: "what it has"
    tabStyle style.css("white-space: nowrap"), loc.stub()
    optCssTheme()
  nbTable t

nbText: """
So, feature by feature, tabelline 0.2 does more to a table than Great Tables does; Great Tables
still takes a table to more places. gt is still ahead of both in features: it has the first two
rows above, all but the text, Markdown and nimib output, and also LaTeX, RTF and Word, groups of
tables, and 36 options tabelline does not have yet. Those outputs are the next release, *Out of
the browser*. tabelline has two things of Great Tables that gt does not: rotated labels
(`colsLabelRotate`) and any CSS in a style (`style.css`).

### Where it goes its own way

Some things are in neither of them. They came from writing these pages, and they make
tabelline a little different, not only a port:
"""

block:
  type Own = object
    what, tabelline, theirs: string
  let rows = @[
    Own(what: "many tables on a page", tabelline: "one stylesheet, `tabellaCss`, written once; each table writes only the options it changes, as CSS variables, and a page can set an option for all its tables", theirs: "each table carries its whole stylesheet in a style element scoped to its id (gt compiles it with sass for every table); `as_raw_html(inline_css = TRUE)` writes styles on every element"),
    Own(what: "a table in a terminal", tabelline: "`echo t` prints it as text, `toMarkdown` for a README; units, formulas and fractions in Unicode, nanoplots as sparklines", theirs: "HTML (and LaTeX, RTF, Word in gt)"),
    Own(what: "a table that follows the page", tabelline: "`optCssTheme()`: colours and font from the page's CSS variables", theirs: "`opt_stylize()` and `tab_options()`, with fixed colours"),
    Own(what: "several values in a cell", tabelline: "lists and records (`@[1, 4, 2]`, `(lo: 0.8, hi: 1.6)`), formatted item by item, read with the dot (`v.hi`), named in merge patterns (`{lo}–{hi}`)", theirs: "list columns for nanoplots; `cols_merge` names columns only"),
    Own(what: "what it needs", tabelline: "Nim's standard library, nothing else; nothing loaded from the network", theirs: "gt imports 20 R packages, Great Tables 8 Python ones"),
  ]
  let t = tabella(rows, rownameCol = "what"):
    tabHeader "Not in gt or Great Tables"
    colsLabel:
      tabelline: "tabelline"
      theirs: "gt and Great Tables"
    fmtMarkdown ["tabelline", "theirs"]
    optCssTheme()
  nbTable t

nbText: """
The first row is the one of [One stylesheet for every table](../sharing-styles/): the
[API reference](../../api/) has 152 tables, and sharing their style took it from 1.71 MB to 0.88 MB.

### A syntax of its own

The verbs are gt's, in camelCase. The way they are written is Nim's: a table is a block, one
verb per line, and a verb that takes pairs takes them as an indented block. A row is `it`, and
a condition on rows is plain Nim:
"""

nbTabs """(
    GT(planets, rowname_col="planet", groupname_col="type")
    .cols_hide(["mass", "diameter", "density", "gravity", "day_length",
                "distance", "orbital_period", "mean_temp", "rings"])
    .tab_style(style.text(weight="bold"),
               loc.body(columns="moons", rows=pl.col("moons") > 10))
    .summary_rows(fns={"total": pl.col("moons").sum()})
)""", """gt(planets, rowname_col = "planet", groupname_col = "type") |>
  cols_hide(c(mass, diameter, density, gravity, day_length,
              distance, orbital_period, mean_temp, rings)) |>
  tab_style(cell_text(weight = "bold"),
            cells_body(columns = moons, rows = moons > 10)) |>
  summary_rows(fns = list(total = ~ sum(.)))""":
  nbCode:
    let syntax = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
      colsHide ["mass", "diameter", "density", "gravity", "day_length",
                "distance", "orbital_period", "mean_temp", "rings"]
      tabStyle style.text(weight = "bold"), loc.body("moons", where(it.moons > 10))
      summaryRows:
        total: agg.sum
      optCssTheme()
    nbTable syntax

nbNote("""
`tabella(data): body` is a macro: each line of the body is a verb called on the table, with no
dots and no pipes. `where(it.moons > 10)` is a template that makes a proc of the row, checked by
the compiler like any Nim code; `summaryRows:` takes its pairs one per line. Without the sugar it is a chain of procs:
`initTabella(...)`, then `.colsHide(...)`, `.tabStyle(...)` and
`.summaryRows(fns = {"total": agg.sum})`.
""", nkCode)

nbText: """
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

The locales of group 4 are three tables (`locales.nim`): every value once, in one long string
(`localeValues`); for each locale, the fields it says differently from its parent, each a field
number and a value number (`localeCellField`, `localeCellValue`); and where each locale's fields
start (`localeTable`). `getLocale` finds the locale by binary search, fills the fields it does
not have from its parents, and
gives a `Locale` object: marks, patterns, names. A format reads it once, when its verb is
called. Dates are written by `formatPattern`, which reads a CLDR pattern a letter at a time:
`y` the year, `MMMM` the month's name, `LLLL` its name standing alone (Russian has both),
`EEE` the short weekday, `h` and `a` the hour and AM or PM, and text between quotes as it is.

The pictures of group 5 are formats too, so they also run in step 1. An icon is a line of
`fontawesome.tsv` (name, style, width, label, the SVG path), found by name in a table built the
first time an icon is needed (`findIcon`), and written as an `<svg>` as high as the text and as
wide as its shape (`iconSvg`). An image is read and encoded in base64 when its verb is called
(`imageDataUrl`), once per file. A nanoplot is drawn in `nanoplots.nim` as Great Tables draws it:
the values are scaled to a box 100 units high, with the reference line, the area and zero in the
same scale; then layer after layer is written from the bottom up (the reference area, the area
under the line, the line, as Bézier curves, the bars, the reference line, the points, and last
the guides that show a value on hover). A box plot computes its quartiles by linear
interpolation and its whiskers by Tukey's rule (the farthest values within 1.5 boxes). The verb
reads every cell of the column first, so the plots of a column share their scale.

Lists and records of group 6 are two more branches of `Value`, the object every cell is
(`core.nim`): `items`, a seq of values, and `fields`, a seq of names and values in order.
`toValue` makes a record by walking an object's fields with `fieldPairs`, as `toTableData` does
for a row. The dot is a template, `` `.` ``, under Nim's experimental `dotOperators`: the
compiler calls it only when a name is neither a field nor a proc, and it turns `v.hi` into
`v["hi"]`; the same template on `Row` turns `it.mass` into `it["mass"]`. A format meets a list in
step 1: `formatCell` gives each item (or field) to the format and joins the results, unless the
format takes the list whole (`wholeValue`, set by the pictures). A nanoplot reads `y` and `x` from
the record, sorts the pairs by `x`, and places each point at its share of the x axis.

How the HTML of every table shares one stylesheet, also in 0.2, has a post of its own:
[One stylesheet for every table](../sharing-styles/).
"""

nbSave
