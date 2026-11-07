## The explainer: what gt and Great Tables are, how they work, who uses them, and a first
## tabelline built step by step. A living document: kept up to date as tabelline grows.
## Writes docs/explainer/index.html.
import std/[os, strutils, sequtils, sugar]
import nimib except md   # nimib's old `md` (deprecated) would clash with tabelline's
import tabelline, tabelline/[datasets, nimib]
import quaderno

let root = currentSourcePath().parentDir
nbInit
nb.doc.filename = root / "explainer" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Great tables, explained", classe = "1ª · living document",
               title = "tabelline explained: great tables for Nim",
               description = "What gt and Great Tables are, how they work inside, who uses them, and a first version of tabelline, great tables for Nim.",
               homeHref = "../")

nbText: """
<p class="kicker">Explainer · living document · started 7 November 2026</p>

# Great tables, for Nim

<p class="lede"><em>Tabelline</em> is what Italian children call the times tables, the little tables
learned by heart in primary school. It is also the name of a new Nim library for making
<strong>display tables</strong>: tables meant to be read by people, with a title, grouped rows,
labels over columns, formatted numbers, colours and notes. This page explains where the idea comes
from (R's <strong>gt</strong> and Python's <strong>Great Tables</strong>), how those libraries are
built, who uses them, and then builds a first, small tabelline, step by step.</p>

Here is the first table every Italian pupil meets, *la tavola pitagorica*, made with tabelline.
The code ran when this page was built:
"""

nbCode:
  let pitagora = tabella(tavolaPitagorica(10), rownameCol = "×"):
    tabHeader md("La *tavola pitagorica*"), "the times table, from 1 × 1 to 10 × 10"
    tabStubhead "×"
    dataColor everything(), palette = palette("quaderno")
    tabStyle style.text(weight = "bold", color = "#C62828"), loc.stub(), loc.columnLabels()
    tabSourceNote md("Every cell is `row × column`. The squares are on the diagonal.")
    optQuaderno()
    colsAlign alCenter
nbTable pitagora

nbIndice

nbText: """
## What is a great table?

A plot shows the shape of data; a table shows the values. Tables are older than plots by a few
thousand years (Sumerian clay tablets already had rows, columns, subtotals and a footer), and in
the middle of the twentieth century, typeset tables reached a peak: the US Census Bureau's
[*Manual of Tabular Presentation*](https://www2.census.gov/library/publications/1949/general/tabular-presentation.pdf)
(1949) named every part of a table and said how to use it. Then computers made tables easy to
compute and hard to make beautiful: a dataframe printed at the console, or a spreadsheet.

**gt** (R) and **Great Tables** (Python) bring the midcentury table back, from code. Their
authors call the problem the *great table dilemma*: analyse in code and show a poor table, or copy
the numbers into a spreadsheet to make a good one, and lose reproducibility. Their answer is a
grammar of tables: a small set of named parts, and verbs that add parts, format values and style
cells, one step at a time.

### gt, in R

[gt](https://gt.rstudio.com) is by Richard Iannone at RStudio (now Posit). Development started in
2018 and the first CRAN release (0.2) came out in 2020; today it is at version 1.4. It is big:
about 84,000 lines of R and 202 exported functions, among them 32 `fmt_*` formatters, 18 `vec_fmt_*`
versions of them for plain vectors, 17 `cols_*`, 14 `opt_*` and 13 `tab_*` verbs. It renders to
HTML, LaTeX, RTF and Word, and to images.

### Great Tables, in Python

[Great Tables](https://posit-dev.github.io/great-tables/) is the Python port, by Rich Iannone and
Michael Chow at Posit, announced in January 2024. It follows gt closely, with Python names
(`GT(df).tab_header(...)`), works with Pandas and Polars dataframes, and adds Polars selectors for
columns. It is about 42,000 lines of Python, MIT licensed, and peer reviewed by pyOpenSci. Its
blog post [The Design Philosophy of Great Tables](https://posit-dev.github.io/great-tables/blog/design-philosophy/)
is the best short read on why tables matter.

### The parts of a table

Both libraries describe a table as six parts. Here they are, each coloured on a tabelline table
(the planets of the Solar System, which we will meet again below):
"""

nbCode:
  let parts = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    tabHeader "Table header: title", "and subtitle"
    tabStubhead "stub head"
    tabSpanner "spanner label", ["diameter", "mass"]
    colsHide ["density", "gravity", "day_length", "orbital_period", "mean_temp", "rings"]
    colsLabel {"mass": "column", "diameter": "labels", "distance": "…", "moons": "…"}
    tabSourceNote "Table footer: source notes and footnotes"
    tabStyle style.fill("#FFF3B0"), loc.title(), loc.subtitle()
    tabStyle style.fill("#A0C4FF"), loc.columnLabels(), loc.spanners()
    tabStyle style.fill("#FFADAD"), loc.stubhead()
    tabStyle style.fill("#FFD6A5"), loc.stub()
    tabStyle style.fill("#E4C1F9"), loc.rowGroups()
    tabStyle style.fill("#CAFFBF"), loc.body()
    tabStyle style.fill("#9BF6FF"), loc.sourceNotes()
    fmtNumber "mass", decimals = 2
    fmtInteger "diameter"
nbTable parts

nbText: """
- the **table header** (yellow): a title and a subtitle;
- the **column labels** (blue): one per column, with **spanner labels** over groups of columns;
- the **stub head** (red): the top-left corner, a label for the stub;
- the **stub** (orange): row labels, and the **row group** labels (violet) that split the rows;
- the **table body** (green): the cells, where the data lives;
- the **table footer** (cyan): footnotes, marked in the table, and source notes.

## What they offer

The verbs come in families, named by prefix. Here is the menu, as a table (made with tabelline,
of course), with what the first version of tabelline already has:
"""

nbCode:
  type Verb = object
    family, verbs, does, tabelline: string
  let menu = @[
    Verb(family: "Create", verbs: "gt(), gt_preview(), gt_group()", does: "a table from a dataframe", tabelline: "tabella(), tableData:"),
    Verb(family: "Parts", verbs: "tab_header, tab_spanner, tab_stubhead, tab_row_group, tab_footnote, tab_source_note", does: "add the parts of a table", tabelline: "all six"),
    Verb(family: "Format", verbs: "fmt_number, fmt_percent, fmt_currency, fmt_date, fmt_scientific, fmt_roman, fmt_markdown, fmt_image, fmt_flag, fmt_units, fmt_nanoplot, … (32)", does: "turn values into text", tabelline: "11, and a tiny bar"),
    Verb(family: "Substitute", verbs: "sub_missing, sub_zero, sub_small_vals, sub_large_vals, sub_values", does: "replace some values", tabelline: "subMissing, subZero"),
    Verb(family: "Columns", verbs: "cols_label, cols_align, cols_width, cols_hide, cols_move, cols_merge, cols_nanoplot, … (17)", does: "change columns", tabelline: "label, align, width, hide, move"),
    Verb(family: "Rows", verbs: "summary_rows, grand_summary_rows, rows_add, row_group_order", does: "add or order rows", tabelline: "not yet"),
    Verb(family: "Style", verbs: "tab_style + cell_fill, cell_text, cell_borders; data_color; text_transform", does: "style cells by location or by value", tabelline: "tabStyle, dataColor"),
    Verb(family: "Options", verbs: "tab_options (about 200 settings), opt_stylize, opt_row_striping, opt_all_caps, opt_interactive, …", does: "change the whole table", tabelline: "tabOptions (40), 6 opt*"),
    Verb(family: "Output", verbs: "as_raw_html, gtsave (html, png, pdf, rtf, docx, tex), as_latex, as_rtf, as_word", does: "render", tabelline: "toHtml, toText, toMarkdown, save"),
  ]
  let menuTable = tabella(menu, rownameCol = "family"):
    tabHeader "The gt menu", "verb families of gt and Great Tables, and what tabelline has so far"
    colsLabel {"verbs": "gt / Great Tables verbs", "does": "what for", "tabelline": "tabelline today"}
    colsWidth {"verbs": "45%"}
    tabStyle style.text(font = "ui-monospace, Menlo, monospace", size = "85%"), loc.body(cols = "verbs")
    tabStyle style.text(color = "#1C7A4E", weight = "bold"), loc.body(cols = "tabelline")
    tabStyle style.text(color = "#C62828", weight = "bold"),
      loc.body(cols = "tabelline", rows = where(it["tabelline"] == "not yet"))
    optAllCaps()
nbTable menuTable

nbText: """
Beyond the verbs, both libraries ship datasets made for showing off tables (`exibble`,
`countrypops`, `gtcars`, `sp500`, `pizzaplace`, `towny`, ...), locales for numbers and dates in
hundreds of languages, colour palettes, Font Awesome icons and flags, and *nanoplots*: tiny
line and bar charts drawn in SVG inside a cell.

## How they work inside

Reading the sources of both (gt's `R/` folder and Great Tables' `great_tables/` package) shows
the same design. It is the design tabelline borrows.

### Two layers: the data and the spec

A gt table is not a table yet: it is the data plus a description of how to show it. In R, `gt()`
returns a list of small data frames, one per concern (`_data`, `_boxhead`, `_stub_df`,
`_row_groups`, `_heading`, `_spanners`, `_footnotes`, `_styles`, `_formats`, `_substitutions`,
`_summary`, `_options`, `_transforms`, `_locale`, ...), each set up by its own `dt_*_init()` and
read and written through `dt__get()` and `dt__set()`. In Python the same pieces are the fields of a
frozen dataclass, `GTData`, and every method returns a copy made with `_replace(...)`. The
**boxhead** is the list of columns with their label, alignment, width and role (data, stub, row
group, hidden).

### Nothing is computed until the end

Verbs only record what was asked. `fmt_number()` stores a formatting function together with the
columns and rows it covers (`FormatInfo` in Python, one function per output context: html,
latex, rtf, default). `tab_style()` stores the styles with a resolved *location* (`loc.body()`,
`loc.column_labels()`, ...). When the table is printed, `build_data()` runs: it applies the formats
cell by cell (the last one wins), the substitutions, column merges and text transforms, puts the
rows in display order, and numbers the footnotes in reading order.

### HTML with its own CSS

Then the HTML renderer writes each part as a component: the heading and column labels in
`<thead>` (spanners take one row per level, and labels without a spanner span those rows), the
row groups, stub and body in `<tbody>`, and the notes in a `<tfoot>`. The look comes from one
stylesheet template (`gt_styles_default.scss`) where every option is a variable: gt compiles it
with Sass, Great Tables fills the `$variables` with Python's `string.Template`. All the CSS is
prefixed with the table's id, so many tables on a page do not clash: that is why a gt table is a
`<div id="...">` holding a `<style>` and a `<table class="gt_table">`. Cell styles are written
inline. Other outputs (LaTeX, RTF, Word) reuse the built data with their own renderers.

### Dataframes, any kind

Great Tables does not depend on Pandas or Polars: `_tbl_data.py` puts a small set of operations
(column names, get a column, select rows, ...) behind `singledispatch` functions, with one version
per dataframe library, loaded only if that library is. gt does the same through R's generic
data frame verbs.

## Who uses them

### The Table Contest

Since 2020, RStudio and then Posit have run a **Table Contest**, the table cousin of their Shiny
and plotting contests. Entries are single tables or tutorials, static or interactive, and the
judges look at both *utility* and *beauty*. Since 2024 Python entries are in too.
"""

nbCode:
  let contest = tableData:
    year: [2020, 2021, 2022, 2024, 2025]
    winner: ["Niels van der Velden", "Vladislav Fridkin", "Karina Bartolome", "Melissa Van Bussel", "Martin Stavro"]
    entry: ["Editable data tables in Shiny with a SQL database", "Satellites: a table of the satellites in orbit",
            "The grammar of tables in Python (pandas) and R (gt)", "Today's Top Hits: a Spotify dashboard, with six tutorial videos",
            "United's fleet with fleetR: tables in a map, a dashboard and a book"]
    tools: ["DT, Shiny", "Shiny, reactable, gt", "gt, pandas", "Quarto", "R, fleetR"]
    note: ["over 80 entries; runner-up: a gt table generator for clinical data", "categories: interactive HTML, Shiny, static",
           "honourable mentions include a gt book and gtExtras tables", "first year open to Python; prizes for Great Tables and Polars",
           "runner-up: pixel art drawn with gt"]
  let contestTable = tabella(contest, rownameCol = "year"):
    tabHeader "Grand prizes of the Table Contest", "RStudio (2020-2022), then Posit (2024-2025); there was no 2023 edition"
    colsLabel {"winner": "grand prize", "entry": "the table", "tools": "made with", "note": "also"}
    tabStyle style.text(weight = "bold"), loc.body(cols = "winner")
    tabStyle style.text(size = "85%", color = "#5E6475"), loc.body(cols = "note")
    tabFootnote "The 2025 winners were announced on 10 November 2025.", loc.body(cols = "winner", rows = where(it["year"] == 2025))
    tabSourceNote md("Posit blog, [2020](https://www.r-bloggers.com/2020/12/winners-of-the-2020-rstudio-table-contest/), [2021](https://www.r-bloggers.com/2021/12/winners-of-the-2021-table-contest/), [2022](https://posit.co/blog/winners-of-the-2022-table-contest/), [2024](https://posit.co/blog/2024-table-contest-winners/), [2025](https://posit.co/blog/2025-table-contest-winners/)")
    optStylize(style = 1, color = "blue")
nbTable contestTable

nbText: """
The special prizes say even more about how people use these tables: the best gt table of 2024
summarised education in Córdoba; 2024's Great Tables prize showed transit patterns with
nanoplots, and its Polars prize the Euro NCAP safety ratings; in 2025 a tutorial rebuilt
24 tables of the APA Publication Manual, and the pharma prize went to submission-ready clinical
tables made with gt and gridify.

### Stories beyond the contest

- **Pharma and clinical trials.** gt's static outputs (PDF, RTF, Word) are what regulators
  receive, and the pharma community built on it: [gtsummary](https://www.danieldsjoberg.com/gtsummary/)
  (Daniel Sjoberg) turns models and data into publication tables with one call, and Posit's post
  [The many reasons that pharmas love gt](https://posit.co/blog/the-many-reasons-that-pharmas-love-gt)
  lists demographic tables, responder tables with subgroups, protocol deviations and listings.
- **An ecosystem of extensions.** [gtExtras](https://jthomasmock.github.io/gtExtras/) (Tom Mock)
  adds sparklines, bar charts and themes; [reactable](https://glin.github.io/reactable/) and
  reactablefmtr cover interactive tables, and gt itself gained `opt_interactive()`.
- **Books and teaching.** Albert Rapp's gt book, and many contest tutorials, teach table
  design (alignment, fewer lines, grouping) as much as the API.
- **Science.** Great Tables has posts on tables for scientific publishing, on LaTeX output, on
  the open transit data of SEPTA, and on plots inside tables.

## Wrap or write?

Could Nim just wrap one of them? Wrapping R or Python would mean shipping an interpreter with
every Nim program, and the value of gt is not in a piece of code that is hard to write (there is
no numerical kernel, as there is in Polars) but in its **design** and its **use cases**: the parts,
the verbs, the formats and the hundreds of options, collected over eight years from real tables.
A table library is mostly careful string building, which Nim does well, at compile time too.

So tabelline is **written from scratch, in plain Nim**, with no dependencies: the core uses only
the standard library, and nimib is needed only for the `nbTable` block. It copies the design of
gt and Great Tables (the two layers, lazy building, the parts, scoped CSS) and their names, in
camelCase, so that their documentation and gallery can be read as tabelline's: `tab_header`
is `tabHeader`, `fmt_number` is `fmtNumber`, `loc.body()` and `style.fill()` are the same. Where
Nim offers something better, it uses it.

## The data model in Nim

### Values and data

The data is a set of named columns of `Value`s. A `Value` is a Nim object variant, so a column
can hold a missing value next to numbers, and a renderer can tell an `int` from a `float`:

```nim
type
  ValueKind* = enum vkNull, vkBool, vkInt, vkFloat, vkString
  Value* = object
    case kind*: ValueKind
    of vkNull: discard
    of vkBool: b*: bool
    of vkInt: i*: int
    of vkFloat: f*: float
    of vkString: s*: string

  Column* = object
    name*: string
    values*: seq[Value]
  TableData* = ref object   # read once, never changed: copying a table never copies it
    columns*: seq[Column]
```

Data comes from Nim values with no ceremony: a `seq` of objects or named tuples (each field a
column, read with `fieldPairs`), a CSV text (types inferred), or the `tableData:` block, where
each value is converted on its own, so `nil` can stand for a missing number.

### The spec

A `Tabella` (Italian for *table*) holds the data and everything said about it: the boxhead,
title and subtitle, stub and groups, spanners, formats, substitutions, styles, footnotes, source
notes and options. It is a plain value. Every verb takes one and returns the new one, with `sink`
so that a chain moves it along instead of copying:

```nim
proc tabHeader*(t: sink Tabella, title: Text, subtitle: Text = toText("")): Tabella =
  result = t
  result.title = title
  result.subtitle = subtitle
```

So `tabella(data).tabHeader("Title").fmtNumber("x")` reads like gt's pipe and Great Tables'
method chain, and a table is never changed behind your back.

### Small types for small ideas

- `Text` is plain text, Markdown (`md("**bold**")`) or HTML (`html("<b>")`); a converter turns a
  `string` into plain `Text`, so most calls just take strings.
- `ColSel` selects columns: a name, an array of names, or a rule (`everything()`, `numeric()`,
  `startsWith("pop")`, ...). It is resolved when the verb is called, so a typo fails at once,
  with the list of the columns there are.
- `RowSel` selects rows: indices (`[0, 2]`, `0..3`) or a predicate,
  `where(it["type"] == "Gas giant")`, which reads like Nim's `filterIt`.
- `loc` and `style` are empty objects used as namespaces, so `loc.body(cols = "mass")` and
  `style.fill("#FFF3B0") & style.text(weight = "bold")` read exactly like Great Tables.
- `TabOptions` uses Nim 2's default field values for its 40 options.

### Two macros, and only where they help

- `tabOptions(rowStriping = true, ...)` sets options by name; a macro, because a proc with 40
  optional parameters would be worse, and a typo is still a compile error.
- `tabella(data): body` reads each line of `body` as a verb applied to the table, so a table
  reads like a recipe, with `for` loops and `if`s allowed in between. The verbs stay plain procs:
  the macro only rewrites `verb(args)` into `t = verb(t, args)`.

## A first table, step by step

The planets of the Solar System, from NASA's fact sheet, come with tabelline. Printed as they are,
they are a dataframe:
"""

nbCode:
  let p = planets()
  echo p.names
  echo tabella(p).colsHide(["density", "gravity", "day_length", "orbital_period", "rings"])

nbText: """
`echo` draws a text table, which is what `$` does for a `Tabella`. In a page, `nbTable` shows the
HTML. Step 1: name the planets as the stub, group them by type, and give the table a header.
"""

nbCode:
  var t = tabella(p, rownameCol = "planet", groupnameCol = "type")
    .tabHeader(md("The **planets** of the Solar System"), "from the smallest orbit to the largest")
    .tabStubhead("planet")
    .colsHide(["density", "gravity", "day_length", "rings"])
nbTable t

nbText: "Step 2: labels with units, and spanners to say what goes together."
nbCode:
  t = t.colsLabel({"mass": md("mass<br>10^24^ kg"), "diameter": md("diameter<br>km"),
                   "distance": md("from the Sun<br>10^6^ km"), "orbital_period": md("year<br>days"),
                   "mean_temp": md("mean<br>°C"), "moons": md("moons")})
    .tabSpanner("Size", ["mass", "diameter"])
    .tabSpanner("Orbit", ["distance", "orbital_period"])
nbTable t

nbText: "Step 3: format the numbers, so that they line up and say only what matters."
nbCode:
  t = t.fmtNumber("mass", decimals = 3, dropTrailingZeros = true)
    .fmtInteger(["diameter", "distance", "orbital_period"])
    .fmtNumber("mean_temp", decimals = 0, forceSign = true)
nbTable t

nbText: """
Step 4: colour by value, style a row, and add the notes. The footnote marks are numbered in
reading order, wherever they were added.
"""
nbCode:
  t = t.dataColor("mean_temp", palette = palette("rdbu"), domain = (-200.0, 200.0))
    .fmtBar("moons", color = "#A0C4FF", width = "5em")
    .tabStyle(style.fill("#FFF3B0") & style.text(weight = "bold"), loc.stub(rows = where(it["planet"] == "Earth")))
    .tabFootnote("Known moons as of 2024; the counts keep growing.", loc.columnLabels("moons"))
    .tabFootnote("Venus is hotter than Mercury: its thick atmosphere traps the heat.",
                 loc.body(cols = "mean_temp", rows = where(it["planet"] == "Venus")))
    .tabSourceNote(md("Source: NASA, [Planetary Fact Sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/)."))
nbTable t

nbText: """
Step 5: the same table in the quaderno look of this page (`optQuaderno`), one of the options
presets, next to `optStylize`:
"""
nbCode:
  nbTable t.optQuaderno()
  nbTable t.optStylize(style = 2, color = "gray").tabOptions(headingAlign = "left", tableFontSize = "14px")

nbText: """
The same steps can be written as a recipe, one verb per line, with the `tabella(data): body`
macro. This is the table above, in one go:

```nim
let planetsTable = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  tabHeader md("The **planets** of the Solar System"), "from the smallest orbit to the largest"
  colsHide ["density", "gravity", "day_length", "rings"]
  tabSpanner "Size", ["mass", "diameter"]
  fmtNumber "mass", decimals = 3, dropTrailingZeros = true
  dataColor "mean_temp", palette = palette("rdbu"), domain = (-200.0, 200.0)
  optQuaderno()
```

## A tour of the formats

gt's `exibble` is a tiny dataset with a column of each kind, made for showing formats. Here each
column gets its own:
"""

nbCode:
  let tour = tabella(exibble(), rownameCol = "row", groupnameCol = "group"):
    tabHeader "Formats on exibble", "one column, one format; missing values shown as —"
    fmtScientific "num", decimals = 2
    fmtCurrency "currency", currency = "EUR"
    fmtDate "date", dateStyle = "day_month_year"
    fmtMarkdown "char"
    subMissing everything(), missingText = "—"
    colsHide ["fctr", "time", "datetime"]
nbTable tour

nbText: """
The formatters are plain functions too, for use anywhere (Great Tables calls them `vals`), and
they know a few locales:
"""

nbCode:
  echo formatNumber(1234567.891)
  echo formatNumber(1234567.891, decimals = 1, sepMark = ".", decMark = ",")   # Italian
  echo formatCompact(1234567.891)
  echo formatScientific(5.97e24)
  echo formatPercent(0.1234)
  echo formatCurrency(-49.95, "EUR")
  echo formatRoman(2026)
  echo formatDate("2026-11-07", "wday_month_day_year")

nbText: """
A table can take a locale, so every number format follows it:
"""
nbCode:
  let italiano = tabella(exibble(), locale = "it")
    .colsHide(["char", "fctr", "date", "time", "datetime", "row", "group"])
    .fmtNumber("num", decimals = 2)
    .fmtCurrency("currency", currency = "EUR")
    .tabHeader("Numeri all'italiana")
  nbTable italiano

nbText: """
## Nim sugar

### Tables from Nim values

Any `seq` of objects or named tuples is a table, one field per column:
"""

nbCode:
  type Pupil = object
    name: string
    tabellina: int
    stars: int
    passed: bool
  let classe = @[Pupil(name: "Ada", tabellina: 7, stars: 3, passed: true),
                 Pupil(name: "Bruno", tabellina: 8, stars: 1, passed: false),
                 Pupil(name: "Carla", tabellina: 9, stars: 2, passed: true)]
  echo tabella(classe)
    .tabHeader("Who knows which tabellina")
    .fmt("stars", (v: Value) => "★".repeat(v.i))
    .fmtTf("passed", trueText = "bravo!", falseText = "ripassa")

nbText: """
`fmt` takes any proc from a `Value` to a string: here `sugar`'s `=>` makes stars.

### Columns written as columns

The `tableData:` macro takes one line per column, and converts each value on its own, so a
missing value is just `nil`:
"""
nbCode:
  let d = tableData:
    materia: ["matematica", "italiano", "scienze", "storia"]
    voto: [9, 8, nil, 7]
  echo tabella(d).subMissing(missingText = "assente")

nbText: """
### Loops inside a recipe

Inside `tabella(data): body`, any `for` or `if` works, and their verbs are rewritten too. One
style per row of the times table, picking out the squares:
"""
nbCode:
  let squares = tabella(tavolaPitagorica(6), rownameCol = "×"):
    tabHeader "Squares on the diagonal"
    for i in 1 .. 6:
      tabStyle style.fill("#FFF3B0") & style.text(weight = "bold"), loc.body(cols = $i, rows = [i - 1])
    optQuaderno()
nbTable squares

nbText: """
## In nimib

tabelline is made to live in [nimib](https://github.com/pietroppeter/nimib) notebooks like this
page. `import tabelline/nimib` adds one block, `nbTable t`, which keeps the HTML of the table and
its Markdown, so the same notebook renders to an HTML page and to a Markdown README:

```nim
import nimib, tabelline, tabelline/nimib
nbInit                         # or nbInitMd, for a README.md
nbCode:
  let t = tabella(planets()).tabHeader("The planets")
nbTable t
nbSave
```

Each table carries its own CSS, scoped to its id, so it looks the same in any nimib theme (this
page's theme, *quaderno*, is in the repository as `docs/quaderno.nim`). And because `echo` draws
a text table, a table printed in `nbCode` shows up in the output, as above.

## What comes next

This is a first version, a proof of concept: it already makes tables worth showing, but most of
gt is still ahead. The next steps are written down as specs in the repository (`openspec/`, shown
on the [specs page](../specs/)) and in the backlog; the main ones:

- **Summary rows** (`summaryRows`, `grandSummaryRows`), with aggregates from Nim procs.
- **Nanoplots**: small SVG line and bar charts in cells, the gt way.
- **More formats**: `fmtUnits` (`m^2`, `kg/m^3`), `fmtImage`, `fmtFlag`, `fmtDuration`, `fmtBytes`,
  `fmtFraction`, with more locales.
- **Column merges** (`colsMerge`, `colsMergeUncert`, `colsMergeRange`) and text transforms.
- **Interop** with Nim dataframes: [nanuq](https://github.com/pietroppeter/nanuq) (Polars for Nim)
  and [datamancer](https://github.com/SciNim/Datamancer), as optional modules.
- **Other outputs**: LaTeX first, then images; and an interactive mode (sort and filter) compiled
  from Nim to JavaScript.
- **A gallery** that rebuilds famous gt tables, and an entry for the next Table Contest.

<div class="nota verde"><span class="titolo">How this page was made</span>
This page is a nimib notebook, <code>docs/explainer.nim</code>: every table on it was made by the
code shown, when the page was built. The research behind it read the sources of gt and Great
Tables and the Posit blog. Corrections are welcome, as issues or pull requests.</div>
"""

nbSave
