## devlog: 10 Nov 2026 A | Designing tabelline 0.2 | tabelline 0.2 takes in what was planned for 0.3 and 0.4: summing up, rows and columns, more formats, every locale, pictures in cells. Each group from zero, simplest first, with the choices behind it and how it is built.
## A dated post, written while 0.2 is built: each group is added when its PR is ready for review.
import std/[os, sugar]
import nimib
import tabelline, tabelline/[nimib, datasets]
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "designing-0-2" / "index.html"
nb.useTabelline(title = "Designing tabelline 0.2", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

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
    G(group: "3 · More formats", what: "units, fractions, chemistry, bins, automatic formats, country names", status: "planned"),
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

*Planned, PR 3.* Units (`m^2`, `kg/m^3`, gt's syntax), fractions, chemical formulas, bins, an
automatic format that picks one per column, and country names.

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
"""

nbSave
