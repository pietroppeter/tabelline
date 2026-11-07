## devlog: 07 Nov 2026 F | Designing tabelline 0.1 | Twenty-four small groups of gt in one go: what 0.1 adds, how each became an OpenSpec change, where tabelline follows R's gt, where Python's Great Tables, and where Nim asked for something of its own.
## A dated post: it tells how 0.1 was designed and built, and is not updated afterwards.
import std/[os, strutils, strformat, sequtils]
import nimib except md
import tabelline, tabelline/[nimib, datasets]
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

Twenty-four groups, in seven areas. In short:
"""

block:
  type A = object
    area: string
    groups: int
    enables: string
  let rows = @[
    A(area: "Parts of a table", groups: 3, enables: "headers from `a.b` names, a caption, taking parts away"),
    A(area: "Formats", groups: 10, enables: "kW and µg, ‰ and ppm, kB and GiB, A B C, *forty-two*, 2:35 PM, 2h 5m, ●○, links, 🇮🇹"),
    A(area: "Substitutions and text", groups: 2, enables: "<0.01 for noise, n/a for −99, text changed as it is shown"),
    A(area: "Columns", groups: 2, enables: "labels from a proc, columns moved to the end or swapped in place"),
    A(area: "Rows", groups: 1, enables: "rows sorted and groups ordered, without touching the data"),
    A(area: "Styles", groups: 2, enables: "any CSS, on the whole header, column header or footer"),
    A(area: "Options", groups: 4, enables: "compact or roomy, boxed or bare, footnote marks your way, your own CSS"),
  ]
  let t = tabella(rows, rownameCol = "area"):
    tabHeader "0.1 in seven lines"
    colsLabel {"groups": "groups", "enables": "what it lets you do"}
    fmtMarkdown "enables"
    tabStubhead "area"
    tabOptions(tableWidth = "100%", tableFontSize = "14px")
  nbTable t

nbText: """
And one by one: a card for each group, with the smallest example that shows it. Swipe the
cards sideways (or scroll them with a trackpad); every table is made by the code above it.
"""

nbRawHtml: """<style>
.galleria { display: flex; align-items: flex-start; gap: .8rem; overflow-x: auto; scroll-snap-type: x mandatory;
  padding: .2rem 0 .8rem; -webkit-overflow-scrolling: touch; }
.galleria::after { content: ""; flex: 0 0 .2rem; }
.scheda { flex: 0 0 min(86%, 26rem); scroll-snap-align: start; overflow-x: auto; padding: .7rem .9rem .8rem;
  border: 1px solid color-mix(in srgb, currentColor 18%, transparent); }
.scheda .numero { font: 700 .72rem/1.2 system-ui, sans-serif; letter-spacing: .14em; text-transform: uppercase; opacity: .6; }
.scheda h3 { margin: .15rem 0 .3rem !important; font-size: 1.1rem !important; line-height: 1.25 !important; }
.scheda p { margin: 0 0 .5rem; font-size: .92rem; line-height: 1.45; }
.scheda pre { margin: .4rem 0 !important; }
body .scheda pre > code { font-size: 12.5px !important; }
.scheda .tabella { margin: .4rem 0 0; }
.scheda .tabella table { font-size: 14px !important; }
</style>"""

var schede: seq[string]
var numero = 0

template scheda(titolo, abilita: string, body: untyped) =
  ## A card of the gallery: what a group lets you do, and the blocks `body` adds (code and table).
  inc numero
  let first = nb.blocks.len
  block:
    body
  var inner = ""
  for i in first ..< nb.blocks.len: inner.add nb.render(nb.blocks[i])
  nb.blocks.setLen(first)
  schede.add "<div class=\"scheda\"><div class=\"numero\">" & $numero & " / 24</div><h3>" & titolo &
    "</h3><p>" & abilita & "</p>" & inner & "</div>"

let pianeti {.used.} = tableData:
  planet: ["Mercury", "Venus", "Earth", "Mars"]
  moons: [0, 0, 1, 2]
  rings: [false, false, false, true]

scheda "Spanners from column names", "Data with names like <code>size.mass</code> gets its headers for free.":
  nbCode:
    let d = tableData:
      planet: ["Earth", "Mars"]
      size.mass: [5.97, 0.64]
      size.radius: [6371, 3390]
    let t = tabella(d, rownameCol = "planet"):
      tabSpannerDelim()
  nbTable t

scheda "Caption", "A table that names itself, for screen readers and for figures in a document.":
  nbCode:
    let t = tabella(pianeti):
      tabCaption "Table 1. The rocky planets."
  nbTable t

scheda "Removing parts", "One house-style table, and variants that drop what they do not need.":
  nbCode:
    let base = tabella(pianeti):
      tabHeader "Rocky planets", "and their moons"
      tabSourceNote "NASA"
    let t = base.rmHeader().rmSourceNotes()
  nbTable t

scheda "Engineering notation and SI prefixes", "Physics-sized numbers: powers of a thousand, or k, M, µ before a unit.":
  nbCode:
    let d = tableData:
      plant: ["kettle", "wind turbine", "phone"]
      power: [2000.0, 3.6e6, 0.005]
    let t = tabella(d):
      fmtNumberSi "power", unit = "W", decimals = 1
  nbTable t

scheda "Parts per", "Concentrations in the unit people use: ppm for CO₂, ‰ for salt.":
  nbCode:
    let d = tableData:
      year: [1850, 2025]
      co2: [0.000285, 0.000425]
    let t = tabella(d):
      fmtPartsper "co2", toUnits = "ppm", decimals = 0
      fmtInteger "year", useSeps = false
  nbTable t

scheda "Bytes", "File and memory sizes that read at a glance, in kB or KiB.":
  nbCode:
    let d = tableData:
      file: ["notes.txt", "photo.jpg", "film.mkv"]
      size: [512, 2_400_000, 3_200_000_000]
    let t = tabella(d):
      fmtBytes "size"
  nbTable t

scheda "Letters and spelled numbers", "Lists labelled a, b, c, and small numbers in words, as in prose.":
  nbCode:
    let d = tableData:
      option: [1, 2, 3]
      moons: [0, 1, 2]
    let t = tabella(d):
      fmtIndex "option", upper = false
      fmtSpelledNum "moons"
  nbTable t

scheda "Times and datetimes", "Clock times and timestamps in the style of your readers.":
  nbCode:
    let d = tableData:
      event: ["launch", "landing"]
      utc: ["1969-07-16T13:32:00", "1969-07-20T20:17:40"]
    let t = tabella(d):
      fmtDatetime "utc", dateStyle = "day_m_year", timeStyle = "h_m_p"
  nbTable t

scheda "Durations", "A column of seconds becomes race times or run times.":
  nbCode:
    let d = tableData:
      race: ["5 km", "half marathon", "marathon"]
      seconds: [1145, 5400, 12_420]
    let t = tabella(d):
      fmtDuration "seconds"
  nbTable t

scheda "Booleans", "True and false as symbols or words, in colour if you like.":
  nbCode:
    let t = tabella(pianeti):
      fmtTf "rings", tfStyle = "circles", colors = ["#B5446E", "#999999"]
  nbTable t

scheda "Links", "Addresses become links, or small buttons; Markdown links keep their label.":
  nbCode:
    let d = tableData:
      project: ["Nim", "nimib"]
      site: ["https://nim-lang.org", "[repo](https://github.com/pietroppeter/nimib)"]
    let t = tabella(d):
      fmtUrl "site"
  nbTable t

scheda "Flags", "Country codes as flags, with nothing to load.":
  nbCode:
    let d = tableData:
      city: ["Roma", "Tokyo", "Paris"]
      country: ["IT", "JP", "FR"]
    let t = tabella(d):
      fmtFlag "country"
  nbTable t

scheda "Value functions", "The same formats outside tables, for the sentence that talks about one.":
  nbCode:
    echo "the film is ", formatBytes(3.2e9), " and lasts ", formatDuration(8100)
    echo "CO₂ went from ", formatPartsper(0.000285, "ppm", 0), " to ", formatPartsper(0.000425, "ppm", 0)

scheda "Small, large and given values", "Hide noise below a threshold, cap huge numbers, mark sentinel values.":
  nbCode:
    let d = tableData:
      sample: ["a", "b", "c"]
      dose: [0.004, 2.5, -99.0]
    let t = tabella(d):
      fmtNumber "dose"
      subSmallVals "dose"
      subValues "dose", values = [-99], replacement = "n/a"
  nbTable t

scheda "Text transforms", "The last word on what a cell says: upper case, a word replaced, a code turned into a label.":
  nbCode:
    let t = tabella(pianeti, rownameCol = "planet"):
      textTransform toUpperAscii, loc.stub()
      fmtTf "rings", tfStyle = "yes-no"
      textCaseMatch {"yes": "rings!", "no": ""}, locations = loc.body("rings")
  nbTable t

scheda "Labels from a proc", "Every label made from its name at once: capitals, units, translations.":
  nbCode:
    let t = tabella(pianeti):
      colsLabelWith capitalizeAscii
  nbTable t

scheda "Moving columns", "The key column at the end, two columns swapped in place.":
  nbCode:
    let t = tabella(pianeti):
      colsMoveToEnd "planet"
      colsReorder ["rings", "moons"]
  nbTable t

scheda "Order of rows and groups", "Rows sorted and groups in your order, while the data stays as it is.":
  nbCode:
    let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
      colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance",
                "orbital_period", "mean_temp", "rings"]
      rowOrder "moons", reverse = true
      rowGroupOrder ["Gas giant"]
  nbTable t

scheda "Any CSS", "Any CSS property, where <code>style.fill</code> and <code>style.text</code> stop.":
  nbCode:
    let t = tabella(pianeti):
      tabStyle style.css("font-variant: small-caps; letter-spacing: .08em"), loc.body("planet")
  nbTable t

scheda "Whole parts as locations", "Style the whole header, column header or footer in one call.":
  nbCode:
    let t = tabella(pianeti):
      tabHeader "Rocky planets"
      tabStyle style.fill("#F6E3EA"), loc.header(), loc.columnHeader()
  nbTable t

scheda "Padding, outline and lines", "Compact or roomy, boxed, with or without lines between cells.":
  nbCode:
    let t = tabella(pianeti):
      optVerticalPadding 0.4
      optTableLines "all"
      optTableOutline color = "#555555", width = "2px"
  nbTable t

scheda "Footnote marks, look and order", "Marks your way: symbols, letters or your own, raised or in brackets.":
  nbCode:
    let t = tabella(pianeti, rownameCol = "planet"):
      tabFootnote "The only one with a ring in this list.", loc.body("rings", rows = [3])
      tabFootnote "Moons known in 2024.", loc.columnLabels("moons")
      optFootnoteMarks ["🌑", "🌓"]
      optFootnoteSpec "^", "("
  nbTable t

scheda "Extra CSS", "A rule of your own, scoped to this table only.":
  nbCode:
    let t = tabella(pianeti):
      optCss "td.tb_row:hover { background: #FFF3B0; }"
  nbTable t

scheda "Markdown and HTML text", "Labels and notes with emphasis, code, sub- and superscripts, or raw HTML.":
  nbCode:
    let t = tabella(pianeti):
      tabHeader md("The **rocky** planets"), html("<i>and their moons</i>")
      colsLabel {"moons": md("moons (*n*)")}
  nbTable t

nbRawHtml: "<div class=\"galleria\" tabindex=\"0\" aria-label=\"the 24 groups: swipe or scroll sideways\">" &
  schede.join("") & "</div>"

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
like `` `size.mass` `` at the dot (now it reads `size.mass:` with no quotes at all, see below), and the "standard" footnote
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
      size.diameter: [12756, 6792]
      orbit.period: [365.2, 687.0]
      orbit.distance: [149.6, 228.0]
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
- **Dotted names, no quotes.** `tableData:` is a macro, so it sees the code before Nim checks
  it: `size.mass: [...]` is a field access to Nim, and to the macro a column named "size.mass",
  which is what `tabSpannerDelim` reads. Names with spaces go in quotes: `"mass (kg)": [...]`.
- **Options checked when compiling.** `tabOptions(rowStriping = true)` is still the one macro
  for options: a typo in a field name does not compile.
"""

nbNota("""
**Still to do in this thread.** Open the release PR, which moves these lines of the changelog
under 0.1.0, and tag `v0.1.0` when Pietro says *vai*. The other two threads of 0.1 use the
release on a month of work and port the first references to the tabelline book.
""", "verde")

nbSave
