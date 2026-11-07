## devlog: 07 Nov 2026 F | Designing tabelline 0.1 | Twenty-four small groups of gt in one go: what 0.1 adds, how each became an OpenSpec change, where tabelline follows R's gt, where Python's Great Tables, and where Nim asked for something of its own.
## A dated post: it tells how 0.1 was designed and built, and is not updated afterwards.
import std/[os, strutils, strformat, sequtils]
import nimib except md
import tabelline, tabelline/nimib
import ../quaderno

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "designing-0-1" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Devlog", classe = "post · 7 November 2026",
               title = "Designing tabelline 0.1", homeHref = "../")

nbText: """
<p class="kicker">Devlog · 7 November 2026</p>

# Designing tabelline 0.1

<p class="lede">Twenty-four small groups of gt in one go: what 0.1 adds, how each became an
OpenSpec change, where tabelline follows R's gt, where Python's Great Tables, and where Nim asked
for something of its own.</p>

The [coverage map](../../coverage/) split gt and Great Tables into 85 feature groups and marked
24 of them for 0.1: the ones that take hours, not days, because the machinery is already there.
This is the first of the three threads of a release, as the post
[Three threads for every release](../three-threads/) planned: build it, then write down how.
"""

nbIndice()

nbText: """
## What 0.1 adds

Each row is one OpenSpec change, archived into the [specs](../../specs/) with an example that
runs. Under each group are its names in R's gt (Python's are the same, when Great Tables has
them).
"""

block:
  type G = object
    area, group, gt, nim: string
  let rows = @[
    G(area: "Parts of a table", group: "Spanners from column names", gt: "tab_spanner_delim()", nim: "tabSpannerDelim(delim, columns, split, limit, reverse): \"a.b\" names become spanners and labels, on several levels."),
    G(area: "Parts of a table", group: "Caption", gt: "tab_caption()", nim: "tabCaption(text): an HTML <caption>, a first line in text, an italic line in Markdown."),
    G(area: "Parts of a table", group: "Remove parts", gt: "rm_header(), rm_spanners(), rm_footnotes(), rm_source_notes(), rm_stubhead(), rm_caption()", nim: "rmHeader, rmSpanners(labels, levels), rmFootnotes(indices), rmSourceNotes(indices), rmStubhead, rmCaption."),
    G(area: "Formats", group: "Engineering, SI prefixes", gt: "fmt_engineering(), fmt_number_si()", nim: "fmtEngineering (× 10³ steps of three), fmtNumberSi(unit) from quecto to quetta."),
    G(area: "Formats", group: "Parts per", gt: "fmt_partsper()", nim: "fmtPartsper: ‰, ‱, pcm, ppm, ppb, ppt, ppq."),
    G(area: "Formats", group: "Bytes", gt: "fmt_bytes()", nim: "fmtBytes: kB, MB (decimal) or KiB, MiB (binary)."),
    G(area: "Formats", group: "Index letters, spelled numbers", gt: "fmt_index(), fmt_spelled_num()", nim: "fmtIndex (repeat or excel), fmtSpelledNum (English, zero to one hundred)."),
    G(area: "Formats", group: "Times and datetimes", gt: "fmt_time(), fmt_datetime()", nim: "fmtTime, fmtDatetime, with named time styles; no time zones."),
    G(area: "Formats", group: "Durations", gt: "fmt_duration()", nim: "fmtDuration: narrow, wide, colon-sep and iso styles, from any input unit."),
    G(area: "Formats", group: "Booleans", gt: "fmt_tf()", nim: "fmtTf with gt's ten styles, naText, colors and html."),
    G(area: "Formats", group: "URLs and emails", gt: "fmt_url(), fmt_email()", nim: "fmtUrl, fmtEmail: links or buttons; Markdown links in cells are read."),
    G(area: "Formats", group: "Flags", gt: "fmt_flag()", nim: "fmtFlag: two-letter codes as emoji (regional indicators), nothing to load."),
    G(area: "Formats", group: "Formats for single values", gt: "vec_fmt_*(), vals.fmt_*()", nim: "A public formatX for every format: formatEngineering, formatBytes, formatDuration, formatFlag, ..."),
    G(area: "Substitutions and text", group: "Small, large and given values", gt: "sub_small_vals(), sub_large_vals(), sub_values()", nim: "subSmallVals, subLargeVals, subValues(values or a proc)."),
    G(area: "Substitutions and text", group: "Text transforms", gt: "text_transform(), text_replace(), text_case_match(), text_case_when()", nim: "textTransform(proc, locations), textReplace (plain text), textCaseMatch; textCaseWhen is a proc with case."),
    G(area: "Columns", group: "Labels from a function", gt: "cols_label_with()", nim: "colsLabelWith(columns, proc)."),
    G(area: "Columns", group: "Move to end, reorder", gt: "cols_move_to_end(), cols_reorder()", nim: "colsMoveToEnd; colsReorder sorts the given columns in their places."),
    G(area: "Rows", group: "Order of rows and groups", gt: "row_order(), row_group_order()", nim: "rowOrder(columns, reverse), rowGroupOrder(groups)."),
    G(area: "Styles and locations", group: "Any CSS", gt: "style.css()", nim: "style.css(\"declarations\")."),
    G(area: "Styles and locations", group: "Locations", gt: "cells_title(), cells_body(), cells_stub(), ...", nim: "Every location of Great Tables but the summary ones (with summary rows, 0.2): loc.header, loc.columnHeader, loc.footer are new."),
    G(area: "Options", group: "Padding, outline, lines", gt: "opt_vertical_padding(), opt_horizontal_padding(), opt_table_outline(), opt_table_lines()", nim: "optVerticalPadding, optHorizontalPadding, optTableOutline, optTableLines."),
    G(area: "Options", group: "Footnote marks", gt: "opt_footnote_marks(), opt_footnote_spec(), opt_footnote_order()", nim: "optFootnoteMarks (names or your own), optFootnoteSpec, optFootnoteOrder."),
    G(area: "Options", group: "Extra CSS", gt: "opt_css()", nim: "optCss(css, add), scoped to the table."),
    G(area: "Helpers, data and interop", group: "Text helpers", gt: "md(), html()", nim: "md() and html()."),
  ]
  type Row = object
    area, group, nim: string
  let shown = rows.mapIt(Row(area: it.area, nim: it.nim,
    group: "**" & it.group & "**<br>`" & it.gt.replace("(), ", "()` `") & "`"))
  let t = tabella(shown, groupnameCol = "area"):
    tabHeader "The 24 groups of 0.1", "one OpenSpec change each"
    colsLabel {"group": md("group, and its names in gt"), "nim": "in tabelline"}
    fmtMarkdown "group"
    colsWidth {"group": "45%"}
    tabOptions(tableWidth = "100%", tableFontSize = "14px")
    tabSourceNote md("From `docs/coverage/gt.json`, the coverage map, as it was when 0.1 was built.")
  nbTable t

nbText: """
## How they were built

The coverage map was the backlog, and each of its rows became a change in `openspec/changes/`: a
proposal (why, what, and the differences from gt and Great Tables), a requirement with a Nim
example, and tasks. The example was written first, with its output left empty; then the code;
then `nim r tools/specexamples.nim --update` wrote what the example prints, and that output was
read line by line before it went into the spec. It is how the spelled numbers stopped at one
hundred, and how `fmtIndex` showed that 42 is "PP" in gt's way of counting (A to Z, then AA, BB)
and "AP" in a spreadsheet's (there is `indexAlgo = "excel"` for that).

Most groups were a verb over machinery that was there: a format is a closure from a value to
text, resolved against the data when the verb is called and run when the table is rendered; a
substitution is the same closure that runs after the formats; a location is a list of keys
(`"title"`, `"col:mass"`, `"cell:3:moons"`) that styles and footnotes attach to. Five groups
needed something new:
"""

block:
  type N = object
    what, why: string
  let rows = @[
    N(what: "a **row order** in the spec (`rowOrder`)", why: "`rowOrder` sorts what is shown, not the data, so the formats and footnotes still point at the rows they were given"),
    N(what: "**text transforms** that run last", why: "`textTransform` on cells gets the text after formats and substitutions, as in gt; on labels it changes the label when it is called"),
    N(what: "a **footer** with an order", why: "the footer is a list of (mark, note) that `optFootnoteOrder` arranges: marked first, last, or as added"),
    N(what: "**marks with a look**", why: "`optFootnoteSpec` reads gt's little language: `^` raised, `i` italic, `b` bold, `(` and `[` around"),
    N(what: "**lines** as options", why: "left and right borders, border styles and vertical lines became options, so `optTableOutline` and `optTableLines` are presets like the others"),
  ]
  let t = tabella(rows):
    tabHeader "What was new machinery"
    colsLabel {"what": "", "why": ""}
    fmtMarkdown everything()
    colsWidth {"what": "34%"}
    tabOptions(tableWidth = "100%", tableFontSize = "14px")
  nbTable t

nbText: """
The others were small, and some found small bugs on the way: `tableData:` cut a quoted name
like `` `size.mass` `` at the dot (it reads the whole name now), and the "standard" footnote
marks were six symbols where gt has four (the six are now `"extended"`, as in gt).

## R, Python or Nim?

Where gt and Great Tables differ, tabelline mostly follows Great Tables, as the
[explainer](../../explainer/) says. 0.1 kept to that, and each proposal lists its differences.
A few choices came up again and again:
"""

block:
  type C = object
    choice, gt, tabelline: string
  let rows = @[
    C(choice: "Names", gt: "`tab_spanner_delim`, `fmt_number_si`, `opt_footnote_marks`",
      tabelline: "the same in camelCase: `tabSpannerDelim`, `fmtNumberSi`, `optFootnoteMarks`"),
    C(choice: "Where the proc goes", gt: "R: `text_transform(fn, locations)`; Python: `text_transform(locations, fn)`",
      tabelline: "`textTransform(fn, locations)`: locations are `varargs`, and Nim wants them last"),
    C(choice: "Regular expressions", gt: "`text_replace(pattern)`, `sub_values(pattern)` take a regex",
      tabelline: "plain text, or a proc: the core needs only Nim's standard library, and std/re needs PCRE"),
    C(choice: "Conditions", gt: "`text_case_when(x > 3 ~ \"big\")`, formulas",
      tabelline: "no `textCaseWhen`: a proc with `if` or `case` is Nim's formula"),
    C(choice: "Choices by name", gt: "strings: `marks = \"letters\"`, `extent = \"all\"`",
      tabelline: "strings too, checked when the verb is called; marks also take an enum (`fmLetters`)"),
    C(choice: "Counting", gt: "rows, footnotes, source notes from 1",
      tabelline: "from 0, as everything else in Nim"),
    C(choice: "Flags", gt: "SVG flags, two- and three-letter codes",
      tabelline: "emoji from two letters: nothing to load, and they work in text too"),
    C(choice: "Single values", gt: "R `vec_fmt_bytes(x)`, Python `vals.fmt_bytes(x)`",
      tabelline: "plain functions: `formatBytes(x)`"),
  ]
  let t = tabella(rows, groupnameCol = "choice"):
    tabHeader "Choices that came up again", "gt and Great Tables, and tabelline"
    colsLabel {"gt": "gt / Great Tables", "tabelline": "tabelline"}
    fmtMarkdown ["gt", "tabelline"]
    colsWidth {"gt": "50%"}
    tabOptions(tableWidth = "100%", tableFontSize = "14px")
  nbTable t

nbText: """
Two verbs have no twin. `colsReorder` puts some columns in a new order in the places they hold
(neither gt nor Great Tables has it; their moves cannot swap two columns in place). And `fmtTf`
keeps its old default, ✓ and ✗, where gt starts from "true" and "false": the ten named styles
are gt's.

### Side by side

Three examples in the three languages. Python and R are shown, not run; Nim runs, here.
"""

nbTabs(python = """
import polars as pl
from great_tables import GT

files = pl.DataFrame({
    "file": ["notes.txt", "photo.jpg", "film.mkv"],
    "size": [512, 2_400_000, 3_200_000_000],
    "signal": [0.000123, 12345.0, 1.5],
})
GT(files, rowname_col="file").fmt_bytes("size").fmt_engineering("signal")
""", r = """
library(gt)

files <- data.frame(
  file = c("notes.txt", "photo.jpg", "film.mkv"),
  size = c(512, 2.4e6, 3.2e9),
  signal = c(0.000123, 12345, 1.5)
)
gt(files, rowname_col = "file") |>
  fmt_bytes(size) |>
  fmt_engineering(signal)
"""):
  nbCode:
    let files = tableData:
      file: ["notes.txt", "photo.jpg", "film.mkv"]
      size: [512, 2_400_000, 3_200_000_000]
      signal: [0.000123, 12345.0, 1.5]
    let t1 = tabella(files, rownameCol = "file"):
      fmtBytes "size"
      fmtEngineering "signal"
  nbTable t1

nbTabs(python = """
from great_tables import GT, loc
from great_tables.data import gtcars

cars = gtcars.head(4)[["model", "mfr", "year"]]
GT(cars, rowname_col="model").text_transform(locations=loc.stub(), fn=lambda x: x.upper())
""", r = """
gtcars |>
  head(4) |>
  dplyr::select(model, mfr, year) |>
  gt(rowname_col = "model") |>
  text_transform(fn = toupper, locations = cells_stub())
"""):
  nbCode:
    let cars = tableData:
      model: ["GT", "458 Speciale", "458 Spider", "458 Italia"]
      mfr: ["Ford", "Ferrari", "Ferrari", "Ferrari"]
      year: [2017, 2015, 2015, 2014]
    let t2 = tabella(cars, rownameCol = "model"):
      textTransform toUpperAscii, loc.stub()
      fmtInteger "year", useSeps = false
  nbTable t2

nbTabs(python = "", r = """
library(gt)

orbits <- data.frame(
  planet = c("Earth", "Mars"),
  size.diameter = c(12756, 6792),
  orbit.period = c(365.2, 687),
  orbit.distance = c(149.6, 228)
)
gt(orbits, rowname_col = "planet") |>
  tab_spanner_delim(delim = ".")
"""):
  nbCode:
    let orbits = tableData:
      planet: ["Earth", "Mars"]
      `size.diameter`: [12756, 6792]
      `orbit.period`: [365.2, 687.0]
      `orbit.distance`: [149.6, 228.0]
    let t3 = tabella(orbits, rownameCol = "planet"):
      tabSpannerDelim()
  nbTable t3

nbText: """
The third has no Python tab: Great Tables has no `tab_spanner_delim`, and the tabs show only
the languages that have the example.

## The Nim sugar

Nothing in 0.1 needed a new macro. What made the verbs read well was Nim as it is:

- **A verb per line.** Inside `tabella(data): body` each line is a verb applied to the table,
  so `textTransform toUpperAscii, loc.stub()` needs no dots, no `|>` and no parentheses.
- **Procs are values.** `toUpperAscii` from std/strutils is passed as it is, where R passes
  `toupper` and Python a `lambda`; an anonymous proc works as well.
- **Table constructors.** `textCaseMatch({"yes": "rings!"})` and `colsLabel({"mass": "Mass"})`
  are Nim's `{key: value}` arrays of pairs, typed and in order.
- **Quoted names.** `` `size.mass`: [...] `` in `tableData:` gives a column a name that is not an
  identifier, which is what `tabSpannerDelim` reads.
- **Options checked when compiling.** `tabOptions(rowStriping = true)` is still the one macro
  for options: a typo in a field name does not compile.
"""

nbNota("""
**Still to do in this thread.** Open the release PR, which moves these lines of the changelog
under 0.1.0, and tag `v0.1.0` when Pietro says *vai*. The other two threads of 0.1 use the
release on a month of work and port the first references to the tabelline book.
""", "verde")

nbSave
