## devlog: 07 Nov 2026 F | Designing tabelline 0.1 | tabelline 0.1 from zero: what a table needs, from the data to the last style, simplest first; where tabelline follows R's gt, where Python's Great Tables and where Nim asked for something of its own; and how it is built.
## A dated post: it tells how 0.1 was designed and built, and is not updated afterwards.
import std/[os, strutils, strformat, sequtils]
import nimib
import tabelline, tabelline/[nimib, datasets]
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "designing-0-1" / "index.html"
nb.useTabelline(title = "Designing tabelline 0.1", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "7 November 2026", "Designing tabelline 0.1", """
tabelline 0.1 from zero: what a table needs, from the data to the last style, simplest first; where tabelline follows R's gt, where Python's Great Tables and where Nim asked for something of its own; and how it is built.
"""
nbText: """
What is the least a library of tables has to do? This post answers with 0.1 itself, built up one
idea at a time: the data first, then a table that shows it as it is, then everything that
changes what it looks like, each idea only after the ones it needs. Every step is a card with the
smallest example that shows it.
"""

nbToc()

nbText: """
## 0.1 from zero

Nine ideas, each built on the ones before it:
"""

block:
  type A = object
    step: int
    idea, what: string
  let rows = @[
    A(step: 1, idea: "1 · Data", what: "columns of values: numbers, text, true or false, missing; from `tableData:`, objects or CSV"),
    A(step: 2, idea: "2 · A table", what: "the data shown as it is, in HTML, text or Markdown"),
    A(step: 3, idea: "3 · Parts", what: "title, notes and caption; a stub and row groups; spanners over columns; footnotes"),
    A(step: 4, idea: "4 · Columns", what: "labels, alignment, widths; hidden, moved, reordered"),
    A(step: 5, idea: "5 · Rows", what: "sorted and grouped, while the data stays as it is"),
    A(step: 6, idea: "6 · Formats", what: "a value becomes text: 1,234.50, 25%, €3, ✓, 🇮🇹, links, ii, 2 kB, 5 kW, dates, 2h 5m"),
    A(step: 7, idea: "7 · Text", what: "**Markdown** and HTML; missing, zero, tiny or sentinel values replaced; the text changed last"),
    A(step: 8, idea: "8 · Options", what: "the whole table at once: size, padding, lines, footnote marks, ready-made looks, your CSS"),
    A(step: 9, idea: "9 · Styles", what: "one part at a time: a location (where) and a style (how), colours from the data"),
  ]
  let t = tabella(rows, rownameCol = "idea"):
    tabHeader "0.1 in nine steps"
    colsLabel {"what": "what it is"}
    colsHide "step"
    tabStyle style.css("white-space: nowrap"), loc.stub()
    fmtMarkdown "what"
    tabOptions(tableWidth = "100%", tableFontSize = "14px")
  nbTable t

nbText: """
And one by one, simplest first. Swipe the cards sideways (or scroll them with a trackpad);
every table is made by the code above it.
"""


let galleriaPassi = newNbGallery(label = "0.1 step by step: swipe or scroll sideways")

template scheda(passo, titolo, abilita: string, body: untyped) =
  ## A card of the gallery: one step, what it lets you do, and the blocks `body` adds.
  ## Tables that follow each other sit side by side.
  nb.withContainer(galleriaPassi):
    let card = newNbGalleryCard(title = titolo, label = passo)
    nb.withContainer(card):
      nbText abilita
      block:
        body
    placeBeside(card)
    nb.add card

let pianeti {.used.} = tableData:
  planet: ["Mercury", "Venus", "Earth", "Mars"]
  moons: [0, 0, 1, 2]
  rings: [false, false, false, true]

# 1. Data

scheda "1 data", "Columns of values", "The data is columns of the same length. Each value is a number, a text, true or false, or missing.":
  nbCode:
    let pianeti = tableData:
      planet: ["Mercury", "Venus", "Earth", "Mars"]
      moons: [0, 0, 1, 2]
      rings: [false, false, false, true]
    echo pianeti.names
    echo pianeti.nrows, " rows"

scheda "1 data", "Objects and CSV", "A seq of objects or named tuples is data too, one column per field; so is a CSV text or file.":
  nbCode:
    let moons = @[(name: "Moon", planet: "Earth"), (name: "Phobos", planet: "Mars")]
    let fromCsv = parseCsv("planet,moons\nEarth,1\nMars,2")
    let t1 = tabella(moons)
    let t2 = tabella(fromCsv)
  nbTable t1
  nbTable t2

# 2. A table

scheda "2 table", "A table", "`tabella(data)` is the table: every value shown as it is, with the column names as labels.":
  nbCode:
    let t = tabella(pianeti)
  nbTable t

scheda "2 table", "Text and Markdown", "The same table also prints as text, for the terminal and for tests, or as Markdown.":
  nbCode:
    let t = tabella(pianeti)
    echo t
    echo t.toMarkdown

# 3. Parts

scheda "3 parts", "Title and notes", "A title and a subtitle above, a source note below.":
  nbCode:
    let t = tabella(pianeti):
      tabHeader "Rocky planets", "and their moons"
      tabSourceNote "Source: NASA."
  nbTable t

scheda "3 parts", "Caption", "A table that names itself, for screen readers and for figures in a document.":
  nbCode:
    let t = tabella(pianeti):
      tabCaption "Table 1. The rocky planets."
  nbTable t

scheda "3 parts", "Stub and row groups", "A column that names the rows goes to the left, the stub; another groups them under a heading.":
  nbCode:
    let d = tableData:
      planet: ["Earth", "Mars", "Jupiter", "Saturn"]
      kind: ["rocky", "rocky", "giant", "giant"]
      moons: [1, 2, 95, 146]
    let t = tabella(d, rownameCol = "planet", groupnameCol = "kind"):
      tabStubhead "planet"
  nbTable t

scheda "3 parts", "Spanners", "A label over some columns, at as many levels as you need.":
  nbCode:
    let d = tableData:
      planet: ["Earth", "Mars"]
      mass: [5.97, 0.64]
      radius: [6371, 3390]
    let t = tabella(d, rownameCol = "planet"):
      tabSpanner "size", ["mass", "radius"]
  nbTable t

scheda "3 parts", "Spanners from column names", "Data with names like `size.mass` gets its spanners for free.":
  nbCode:
    let d = tableData:
      planet: ["Earth", "Mars"]
      size.mass: [5.97, 0.64]
      size.radius: [6371, 3390]
    let t = tabella(d, rownameCol = "planet"):
      tabSpannerDelim()
  nbTable t

scheda "3 parts", "Footnotes", "A note at the bottom, and its mark wherever it applies: a cell, a label, the title. Marks are numbered in reading order, top to bottom.":
  nbCode:
    let t = tabella(pianeti, rownameCol = "planet"):
      tabFootnote "Moons known in 2024.", loc.columnLabels("moons")
      tabFootnote "The only one with a ring in this list.", loc.body("rings", rows = [3])
  nbTable t

scheda "3 parts", "Removing parts", "One house-style table, and variants that drop what they do not need.":
  nbCode:
    let base = tabella(pianeti):
      tabHeader "Rocky planets", "and their moons"
      tabSourceNote "Source: NASA."
    let t = base.rmHeader().rmSourceNotes()
  nbTable t

# 4. Columns

scheda "4 columns", "Column labels", "Labels other than the names: one by one, or all at once from a proc.":
  nbCode:
    let t = tabella(pianeti):
      colsLabelWith capitalizeAscii
      colsLabel {"rings": "Rings?"}
  nbTable t

scheda "4 columns", "Alignment, widths, hiding", "Where the text sits, how wide a column is, and which columns are not shown.":
  nbCode:
    let t = tabella(pianeti):
      colsAlign alCenter, "moons"
      colsWidth {"planet": "8em"}
      colsHide "rings"
  nbTable t

scheda "4 columns", "Moving columns", "To the start, after another, to the end, or swapped in place.":
  nbCode:
    let t = tabella(pianeti):
      colsMoveToStart "moons"
      colsMoveToEnd "planet"
      colsReorder ["rings", "moons"]
  nbTable t

# 5. Rows

scheda "5 rows", "Order of rows and groups", "Rows sorted and groups in your order, while the data stays as it is.":
  nbCode:
    let d = tableData:
      planet: ["Earth", "Mars", "Jupiter", "Saturn"]
      kind: ["rocky", "rocky", "giant", "giant"]
      moons: [1, 2, 95, 146]
    let t = tabella(d, rownameCol = "planet", groupnameCol = "kind"):
      rowOrder "moons", reverse = true
      rowGroupOrder ["giant"]
  nbTable t

# 6. Formats

scheda "6 formats", "Numbers", "Decimals, digit grouping, a unit around the number, percentages.":
  nbCode:
    let d = tableData:
      planet: ["Earth", "Mars"]
      distance: [149.6, 227.9]
      water: [0.71, 0.0]
    let t = tabella(d):
      fmtNumber "distance", decimals = 1, pattern = "{x} Gm"
      fmtPercent "water", decimals = 0
  nbTable t

scheda "6 formats", "Integers and currency", "Whole numbers with separators, and money with its sign.":
  nbCode:
    let d = tableData:
      item: ["telescope", "eyepiece"]
      sold: [12500, 840]
      price: [349.0, 39.9]
    let t = tabella(d):
      fmtInteger "sold"
      fmtCurrency "price", currency = "EUR"
  nbTable t

scheda "6 formats", "Booleans", "True and false as symbols or words, in colour if you like.":
  nbCode:
    let t = tabella(pianeti):
      fmtTf "rings", tfStyle = "circles", colors = ["#B5446E", "#999999"]
  nbTable t

scheda "6 formats", "Flags", "Country codes as flags, with nothing to load.":
  nbCode:
    let d = tableData:
      city: ["Roma", "Tokyo", "Paris"]
      country: ["IT", "JP", "FR"]
    let t = tabella(d):
      fmtFlag "country"
  nbTable t

scheda "6 formats", "Links", "Addresses become links, or small buttons; Markdown links keep their label.":
  nbCode:
    let d = tableData:
      project: ["Nim", "nimib"]
      site: ["https://nim-lang.org", "[repo](https://github.com/pietroppeter/nimib)"]
    let t = tabella(d):
      fmtUrl "site"
  nbTable t

scheda "6 formats", "Letters, Roman numerals, words", "Lists labelled a, b, c or i, ii, iii, and small numbers in words, as in prose.":
  nbCode:
    let d = tableData:
      option: [1, 2, 3]
      chapter: [1, 2, 3]
      moons: [0, 1, 2]
    let t = tabella(d):
      fmtIndex "option", upper = false
      fmtRoman "chapter", upper = false
      fmtSpelledNum "moons"
  nbTable t

scheda "6 formats", "Parts per", "Concentrations in the unit people use: ppm for CO₂, ‰ for salt.":
  nbCode:
    let d = tableData:
      year: [1850, 2025]
      co2: [0.000285, 0.000425]
    let t = tabella(d):
      fmtPartsper "co2", toUnits = "ppm", decimals = 0
      fmtInteger "year", useSeps = false
  nbTable t

scheda "6 formats", "Bytes", "File and memory sizes that read at a glance, in kB or KiB.":
  nbCode:
    let d = tableData:
      file: ["notes.txt", "photo.jpg", "film.mkv"]
      size: [512, 2_400_000, 3_200_000_000]
    let t = tabella(d):
      fmtBytes "size"
  nbTable t

scheda "6 formats", "Scientific, engineering, SI", "Physics-sized numbers: powers of ten, powers of a thousand, or k, M, µ before a unit.":
  nbCode:
    let d = tableData:
      what: ["kettle", "wind turbine", "phone"]
      power: [2000.0, 3.6e6, 0.005]
      same: [2000.0, 3.6e6, 0.005]
    let t = tabella(d):
      fmtNumberSi "power", unit = "W", decimals = 1
      fmtScientific "same", decimals = 1
  nbTable t

scheda "6 formats", "Dates and times", "Dates, clock times and timestamps in the style of your readers.":
  nbCode:
    let d = tableData:
      event: ["launch", "landing"]
      day: ["1969-07-16", "1969-07-20"]
      utc: ["1969-07-16T13:32:00", "1969-07-20T20:17:40"]
    let t = tabella(d):
      fmtDate "day", dateStyle = "day_m_year"
      fmtDatetime "utc", dateStyle = "iso", timeStyle = "h_m_p"
  nbTable t

scheda "6 formats", "Durations", "A column of seconds becomes race times or run times.":
  nbCode:
    let d = tableData:
      race: ["5 km", "half marathon", "marathon"]
      seconds: [1145, 5400, 12_420]
    let t = tabella(d):
      fmtDuration "seconds"
  nbTable t

scheda "6 formats", "A format of your own", "Any proc from a value to a text is a format.":
  nbCode:
    let t = tabella(pianeti):
      fmt "moons", proc (v: Value): string = repeat("🌑", v.i)
  nbTable t

scheda "6 formats", "Formats outside tables", "Every format is also a function, for the sentence that talks about one value.":
  nbCode:
    echo "the film is ", formatBytes(3.2e9), " and lasts ", formatDuration(8100)
    echo "CO₂ went from ", formatPartsper(0.000285, "ppm", 0), " to ", formatPartsper(0.000425, "ppm", 0)

# 7. Text

scheda "7 text", "Markdown and HTML", "Cells, labels and notes with emphasis, code, sub- and superscripts, or raw HTML.":
  nbCode:
    let d = tableData:
      gas: ["CO~2~", "CH~4~"]
      note: ["the **main** one", "*shorter* lived"]
    let t = tabella(d):
      tabHeader md("Greenhouse **gases**"), html("<i>two of them</i>")
      fmtMarkdown ["gas", "note"]
  nbTable t

scheda "7 text", "Missing, zero, tiny and given values", "A word for zero, a threshold for noise, n/a for a sentinel value; `subMissing` does the same for missing ones.":
  nbCode:
    let d = tableData:
      sample: ["a", "b", "c", "d"]
      dose: [0.004, 0.0, -99.0, 2.5]
    let t = tabella(d):
      fmtNumber "dose"
      subZero "dose", zeroText = "none"
      subSmallVals "dose"
      subValues "dose", values = [-99], replacement = "n/a"
  nbTable t

scheda "7 text", "Text transforms", "The last word on what a cell says: upper case, a word replaced, a code turned into a label.":
  nbCode:
    let t = tabella(pianeti, rownameCol = "planet"):
      textTransform toUpperAscii, loc.stub()
      fmtTf "rings", tfStyle = "yes-no"
      textCaseMatch {"yes": "rings!", "no": ""}, locations = loc.body("rings")
  nbTable t

# 8. Options

scheda "8 options", "Options by name", "Every option of gt by name, checked when compiling: sizes, colours, fonts, stripes.":
  nbCode:
    let t = tabella(pianeti):
      tabOptions(tableFontSize = "13px", rowStriping = true, headingBackgroundColor = "#F6E3EA")
      tabHeader "Rocky planets"
  nbTable t

scheda "8 options", "Ready-made looks", "A preset sets many options at once.":
  nbCode:
    let t = tabella(pianeti):
      tabHeader "Rocky planets"
      optStylize 3, "red"
  nbTable t

scheda "8 options", "Padding, outline and lines", "Compact or roomy, boxed, with or without lines between cells.":
  nbCode:
    let t = tabella(pianeti):
      optVerticalPadding 0.4
      optTableLines "all"
      optTableOutline color = "#555555", width = "2px"
  nbTable t

scheda "8 options", "Footnote marks, look and order", "Marks your way: symbols, letters or your own, raised or in brackets.":
  nbCode:
    let t = tabella(pianeti, rownameCol = "planet"):
      tabFootnote "Moons known in 2024.", loc.columnLabels("moons")
      tabFootnote "The only one with a ring in this list.", loc.body("rings", rows = [3])
      optFootnoteMarks ["🌑", "🌓"]
      optFootnoteSpec "^", "("
  nbTable t

scheda "8 options", "Extra CSS", "A rule of your own, scoped to this table only.":
  nbCode:
    let t = tabella(pianeti):
      optCss "td.tb_row:hover { background: #FFF3B0; }"
  nbTable t

# 9. Styles

scheda "9 styles", "A style at a location", "Where (a location: cells, labels, title, ...) and how (a fill, the text, borders).":
  nbCode:
    let t = tabella(pianeti):
      tabStyle style.fill("#FFF3B0"), loc.body(rows = [2])
      tabStyle style.text(weight = "bold"), loc.columnLabels()
      tabStyle style.borders({sBottom}, color = "#B5446E", weight = "2px"), loc.body("planet")
  nbTable t

scheda "9 styles", "Whole parts as locations", "Style the whole header, column header or footer in one call.":
  nbCode:
    let t = tabella(pianeti):
      tabHeader "Rocky planets"
      tabStyle style.fill("#F6E3EA"), loc.header(), loc.columnHeader()
  nbTable t

scheda "9 styles", "Any CSS", "Any CSS property, where `style.fill` and `style.text` stop.":
  nbCode:
    let t = tabella(pianeti):
      tabStyle style.css("font-variant: small-caps; letter-spacing: .08em"), loc.body("planet")
  nbTable t

scheda "9 styles", "Colours from the data", "Each cell coloured by its value, along a palette.":
  nbCode:
    let d = tableData:
      planet: ["Earth", "Mars", "Jupiter", "Saturn"]
      moons: [1, 2, 95, 146]
    let t = tabella(d):
      dataColor "moons", palette = @["#FFF3B0", "#B5446E"]
  nbTable t

nb.add galleriaPassi

nbText: """
## R, Python or Nim?

Where gt and Great Tables differ, tabelline mostly follows Great Tables, as the
[explainer](../../explainer/) says. 0.1 kept to that, and each proposal lists its differences.
A few choices came up again and again.
"""

nbText: """
Eight of them. In short: where gt and Great Tables agree, tabelline agrees too; where they
differ, it sides with one of them; and in four places Nim offers a way of its own.
"""

block:
  type V = object
    side, choice, r, python, nim: string
  let rows = @[
    V(side: "the same as both", choice: "Names", r: "tab_header", python: "tab_header", nim: "tabHeader"),
    V(side: "the same as both", choice: "Options", r: "\"letters\"", python: "\"letters\"", nim: "\"letters\""),
    V(side: "with Python", choice: "First row", r: "1", python: "0", nim: "0"),
    V(side: "with R", choice: "Proc or places first?", r: "proc", python: "places", nim: "proc"),
    V(side: "its own way", choice: "Flags", r: "SVG", python: "SVG", nim: "emoji"),
    V(side: "its own way", choice: "One value", r: "vec_fmt_", python: "vals.fmt_", nim: "formatX"),
    V(side: "its own way", choice: "Replace text", r: "regex", python: "—", nim: "plain text"),
    V(side: "its own way", choice: "Conditions", r: "formula", python: "—", nim: "proc"),
  ]
  let t = tabella(rows, rownameCol = "choice", groupnameCol = "side"):
    tabHeader "R, Python and tabelline", "eight choices, grouped by whom tabelline sides with"
    colsLabel {"r": "🏴‍☠️ R", "python": "🐍 Python", "nim": "👑 Nim"}
    tabStyle style.text(weight = "bold"), loc.body("nim")
    tabStyle style.fill("#F6E3EA"), loc.rowGroups()
    tabSourceNote "— : not in Great Tables."
    tabOptions(tableWidth = "100%", tableFontSize = "14px")
  nbTable t

nbText: """
And one card for each: the same thing written in R, in Python and in tabelline, and why
tabelline chose what it did. Swipe sideways.
"""

let galleriaScelte = newNbGallery(label = "eight choices: swipe or scroll sideways")

template scelta(titolo, domanda: string, body: untyped) =
  ## A card of the second gallery: one choice, the code in three languages and the verdict.
  nb.withContainer(galleriaScelte):
    let card = newNbGalleryCard(title = titolo)
    nb.withContainer(card):
      nbText domanda
      body
    nb.add card

scelta "Names", "What is a verb called?":
  nbText: """
🏴‍☠️ R
```r
tab_header(title = "Planets")
```
🐍 Python
```python
.tab_header(title="Planets")
```
👑 Nim
```nim
tabHeader "Planets"
```
**tabelline:** gt's names in camelCase, the Nim way. Inside `tabella(data):` there is one verb per line, with no `|>` and no dots.
"""

scelta "Choices by name", "How do you pick one of a few options?":
  nbText: """
🏴‍☠️ R
```r
opt_footnote_marks(marks = "letters")
```
🐍 Python
```python
.opt_footnote_marks(marks="letters")
```
👑 Nim
```nim
optFootnoteMarks "letters"
optFootnoteMarks fmLetters
```
**tabelline:** the same strings, checked when the verb is called, so a typo fails at once; marks also take an enum, which Nim checks when compiling.
"""

scelta "Counting", "Which row is the first?":
  nbText: """
🏴‍☠️ R
```r
cells_body(rows = 1)
```
🐍 Python
```python
loc.body(rows=[0])
```
👑 Nim
```nim
loc.body(rows = [0])
```
**tabelline:** from 0, like Python and like everything else in Nim. R counts from 1.
"""

scelta "Where the proc goes", "When a verb takes a function and places, which comes first?":
  nbText: """
🏴‍☠️ R
```r
text_transform(fn = toupper, locations = cells_stub())
```
🐍 Python
```python
.text_transform(locations=loc.stub(), fn=str.upper)
```
👑 Nim
```nim
textTransform toUpperAscii, loc.stub()
```
**tabelline:** the proc first, as in R. The places come last because there can be several (`loc.stub(), loc.body()`), and Nim takes such a list only at the end.
"""

scelta "Flags", "How does a country code become a flag?":
  nbText: """
🏴‍☠️ R
```r
fmt_flag(columns = country)
```
🐍 Python
```python
.fmt_flag(columns="country")
```
👑 Nim
```nim
fmtFlag "country"
```
**tabelline:** emoji (🇮🇹) instead of SVG pictures: nothing to load, and they show in text tables too. Some systems (Windows) draw them as two letters.
"""

scelta "Single values", "How do you format one number, outside a table?":
  nbText: """
🏴‍☠️ R
```r
vec_fmt_bytes(3.2e9)
```
🐍 Python
```python
vals.fmt_bytes(3.2e9)
```
👑 Nim
```nim
formatBytes(3.2e9)
```
**tabelline:** plain functions, one per format. Nim needs no namespace (`vals.`) or prefix (`vec_`) to tell them apart.
"""

scelta "Regular expressions", "How do you replace a piece of text in cells?":
  nbText: """
🏴‍☠️ R
```r
text_replace(pattern = "^Merc", replacement = "☿ ")
```
🐍 Python: not in Great Tables.

👑 Nim
```nim
textReplace "Mercury", "☿ Mercury"
```
**tabelline:** plain text, not a regex. Nim's regex module needs the PCRE library, and the core of tabelline needs nothing but the standard library. For more, `textTransform` takes any proc.
"""

scelta "Conditions", "How do you change a text depending on its value?":
  nbText: """
🏴‍☠️ R
```r
text_case_when(x == "0" ~ "none", .default = "some")
```
🐍 Python: not in Great Tables.

👑 Nim
```nim
textTransform proc (s: string): string =
  if s == "0": "none" else: "some"
```
**tabelline:** no `textCaseWhen`. R needs formulas (`~`) for this; Nim already has `if` and `case`, so a small proc does it.
"""

nb.add galleriaScelte

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

nbText: """
The second has no Python tab: Great Tables has no `tab_spanner_delim`, and the tabs show only
the languages that have the example.

## The Nim sugar

tabelline has three macros, each where a proc could not do the job: `tabella(data):` with a
body of verbs, `tableData:` for data written as columns, and `tabOptions` for options by name.
The rest is Nim as it is. Eight things, one card each, with code that runs and what it makes.
Swipe sideways.
"""

let galleriaZucchero = newNbGallery(label = "Nim sugar: swipe or scroll sideways")

template zucchero(titolo, cosa: string, body: untyped) =
  ## A card of the third gallery: one piece of Nim sugar, code that runs and what it makes.
  nb.withContainer(galleriaZucchero):
    let card = newNbGalleryCard(title = titolo)
    nb.withContainer(card):
      nbText cosa
      block:
        body
    nb.add card

zucchero "A verb per line", "Inside `tabella(data):` each line is a verb applied to the table: no dots, no `|>`, no parentheses.":
  nbCode:
    let t = tabella(pianeti, rownameCol = "planet"):
      tabHeader "Rocky planets"
      fmtTf "rings", tfStyle = "yes-no"
  nbTable t

zucchero "Pairs in braces", "`{key: value}` is Nim's list of pairs: typed, in order, one argument.":
  nbCode:
    let t = tabella(pianeti):
      colsLabel {"planet": "Planet", "moons": "Moons", "rings": "Rings?"}
      textCaseMatch {"true": "yes", "false": "no"}, locations = loc.body("rings")
  nbTable t

zucchero "Objects straight in", "A seq of objects or named tuples is a table: one column per field.":
  nbCode:
    type Moon = object
      name: string
      km: float
    let moons = @[
      Moon(name: "Moon", km: 1737.4),
      Moon(name: "Phobos", km: 11.3),
      Moon(name: "Deimos", km: 6.2)]
    let t = tabella(moons):
      fmtNumber "km", decimals = 1
  nbTable t

zucchero "Dotted names, no quotes", "`tableData:` is a macro: it reads `size.mass` as a column name before Nim sees a field access.":
  nbCode:
    let d = tableData:
      planet: ["Earth", "Mars"]
      size.mass: [5.97, 0.64]
      size.radius: [6371, 3390]
      "moons (n)": [1, 2]
    let t = tabella(d, rownameCol = "planet"):
      tabSpannerDelim()
  nbTable t

zucchero "Procs are values", "A proc from the standard library goes in as it is; an anonymous one works too.":
  nbCode:
    let t = tabella(pianeti):
      colsLabelWith capitalizeAscii
      textTransform proc (s: string): string = s & "!", loc.body("planet", rows = [2])
  nbTable t

zucchero "Loops and ifs in the body", "The body is Nim code: a `for` or an `if` can hold verbs too.":
  nbCode:
    let compact = true
    let t = tabella(pianeti):
      for c in ["moons", "rings"]:
        colsAlign alCenter, c
      if compact:
        optVerticalPadding 0.4
  nbTable t

zucchero "Rows by condition", "`where` takes any Nim condition over the row `it`.":
  nbCode:
    let t = tabella(pianeti):
      tabStyle style.fill("#FFF3B0"), loc.body(rows = where(it["moons"] > 0))
  nbTable t

zucchero "Options checked when compiling", "`tabOptions` sets any option by name; a misspelt name does not compile.":
  nbCode:
    let t = tabella(pianeti):
      tabOptions(rowStriping = true)
    echo compiles(t.tabOptions(rowStripping = true))
  nbTable t

nb.add galleriaZucchero

nbText: """
## How it is built

The same nine steps, seen from inside. The whole core is plain Nim with only the standard
library; nimib is needed only for `nbTable` and these pages.

**1 · Data.** A `Value` is a variant object: missing, bool, int, float or string. A `TableData`
is a list of named columns of values, all of the same length; it is a `ref`, so a table shares
its data instead of copying it. `tableData:` is a macro that turns `name: [values]` lines into
columns, and reads a name as Nim parses it: a plain word, `` `two words` ``, `"a string"`, or
`size.mass`, which Nim sees as a field access and the macro joins back into one name. A seq of
objects or tuples becomes columns with `fieldPairs`, at compile time; CSV is parsed by hand,
quotes included.

**2 · A table.** A `Tabella` is a plain value: the data and everything said about how to show
it, kept as lists of rules (formats, substitutions, styles, transforms, footnotes). Every verb is
a proc that takes the table as `sink` and returns the new one, so a chain of verbs moves one
value along and copies nothing. `tabella(data): body` is a macro: it rewrites each line of the
body that is a call into `t = verb(t, ...)`, and walks into `for`, `if` and `block`, so the
body can hold any Nim. Nothing is computed until the table is rendered.

**3 · Parts.** The header, the stub, row groups, spanners and notes are fields of the table.
Every place you can point at has a key: `"title"`, `"col:moons"`, `"spanner:size"`,
`"group:giant"`, `"cell:3:rings"`. A footnote is a text and where it applies; at render time
that becomes keys, and marks are numbered in the order the keys are read on the page.

**4 · Columns and 5 · Rows.** The boxhead is a list of columns in display order, each with its
label, alignment, width and whether it is hidden: moving a column is moving an entry of that
list. Rows are never moved in the data: `rowOrder` keeps the order in which rows are shown, so
a format or a footnote that named row 3 still means the same row after sorting.

**6 · Formats.** A format is a closure from a value to text (`FormatFn`), for some columns and
rows. The verb resolves which columns and rows it covers when it is called, so a misspelt column
fails right there; the closure runs only when the table is rendered, once for HTML and once for
text, so every renderer shows the same numbers. The last format that covers a cell wins. The
value functions (`formatBytes`, ...) are the same closures, called on one value.

**7 · Text.** Substitutions are formats that run after the formats and see missing values too.
Text transforms run after both, on the text, so they have the last word. Labels and notes are a
`Text`: plain (escaped), `md()` (a small Markdown parser for inline marks, no dependency) or
`html()` (used as it is).

**8 · Options.** `TabOptions` is one object with a field for every gt option, each with gt's
default. `tabOptions` is the third macro: it turns `rowStriping = true` into an assignment to
that field, so a misspelt option does not compile. The `opt*` verbs are presets that set
several fields at once.

**9 · Styles.** A style is a list of CSS declarations at a location, which becomes a set of
keys like the footnotes. Styles at a whole part (the header) are applied before styles at one
of its parts (the title), so the more precise one wins. `dataColor` is a style per cell,
computed from the values.

**Rendering.** `build` turns a table into a `Built`: the visible columns, the groups with their
rows in order, every cell already formatted, the marks, the footer and the CSS of each key.
The HTML, text and Markdown renderers only lay a `Built` out, so they cannot disagree. The HTML
gets an id from a hash of its content, and its CSS is scoped to that id, so two tables on one
page never touch each other.

**In phases.** 0.1 came in two steps. The first version (#1) built the core: data, the table,
parts, eleven formats, styles and options. Then the [coverage map](../../coverage/)
split gt and Great Tables into 85 feature groups, and the 24 that the core made cheap became
one OpenSpec change each (#10): a proposal with its differences from gt and Great Tables, a
requirement with an example that runs, and its tasks. The example was written first and its
output read line by line before it went into the spec; that is how the spelled numbers stopped
at one hundred, and how `fmtIndex` showed that 42 is "PP" in gt's way of counting and "AP" in a
spreadsheet's (`indexAlgo = "excel"`).
"""

nbNote("""
**Still to do in this thread.** Open the release PR, which moves these lines of the changelog
under 0.1.0, and tag `v0.1.0` when Pietro says *vai*. The other two threads of 0.1 use the
release on a month of work and port the first references to the tabelline book.
""", nkDone)

nbSave
