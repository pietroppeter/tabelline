# table-parts Specification

## Purpose
The parts of a display table, after gt and Great Tables: the header, the column labels and
spanners, the stub and its head, row groups, the body, and the footer with footnotes and source
notes; and the verbs that set them.

## Requirements

### Requirement: A table spec for the data
`tabella(data)` SHALL make a table spec (`Tabella`) for the data: one boxhead entry per column,
labelled with its name, numbers aligned right and text left. `rownameCol` SHALL make a column the
stub, `groupnameCol` SHALL group the rows by a column in order of first appearance. Every verb
SHALL take a `Tabella` and return a new one, leaving the data untouched.

```nim
let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
  .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
echo t
```

```text
┌─────────┬───────┐
│         │ moons │
╞═════════╪═══════╡
│ Terrestrial     │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mercury │     0 │
│ Venus   │     0 │
│ Earth   │     1 │
│ Mars    │     2 │
├─────────┼───────┤
│ Gas giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter │    95 │
│ Saturn  │   146 │
├─────────┼───────┤
│ Ice giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus  │    28 │
│ Neptune │    16 │
└─────────┴───────┘
```

#### Scenario: Verbs do not change their input
- **WHEN** `let b = a.tabHeader("x")`
- **THEN** `a` has no title and `b` has

### Requirement: Header, stubhead and source notes
`tabHeader(title, subtitle)`, `tabStubhead(label)` and `tabSourceNote(note)` SHALL set the title
and subtitle, the stub's label, and add a source note. Labels and notes SHALL be plain text, or
Markdown with `md(...)`, or HTML with `html(...)`.

```nim
echo tabella(tavolaPitagorica(3), rownameCol = "×")
  .tabHeader("Times table", "from 1 to 3").tabStubhead("×").tabSourceNote(md("Learned **by heart**"))
```

```text
   Times table
   from 1 to 3
┌───┬───┬───┬───┐
│ × │ 1 │ 2 │ 3 │
╞═══╪═══╪═══╪═══╡
│ 1 │ 1 │ 2 │ 3 │
│ 2 │ 2 │ 4 │ 6 │
│ 3 │ 3 │ 6 │ 9 │
└───┴───┴───┴───┘
Learned by heart
```

### Requirement: Column labels and spanners
`colsLabel` SHALL relabel columns, `colsAlign`, `colsWidth`, `colsHide`, `colsMove` and
`colsMoveToStart` SHALL align, size, hide and reorder them. `tabSpanner(label, columns, level = 1)`
SHALL put a label over columns; spanners of a higher level sit above lower ones, and two spanners
of one level SHALL NOT overlap.

```nim
echo tabella(planets(), rownameCol = "planet")
  .colsHide(["type", "density", "gravity", "day_length", "mean_temp", "rings", "moons"])
  .colsLabel({"orbital_period": "year"})
  .tabSpanner("Size", ["mass", "diameter"])
  .tabSpanner("Orbit", ["distance", "orbital_period"])
```

```text
┌─────────┬────────┬──────────┬──────────┬─────────┐
│         │       Size        │       Orbit        │
│         │   mass │ diameter │ distance │    year │
╞═════════╪════════╪══════════╪══════════╪═════════╡
│ Mercury │   0.33 │     4879 │     57.9 │    88.0 │
│ Venus   │   4.87 │    12104 │    108.2 │   224.7 │
│ Earth   │   5.97 │    12756 │    149.6 │   365.2 │
│ Mars    │  0.642 │     6792 │    228.0 │   687.0 │
│ Jupiter │ 1898.0 │   142984 │    778.5 │  4331.0 │
│ Saturn  │  568.0 │   120536 │   1432.0 │ 10747.0 │
│ Uranus  │   86.8 │    51118 │   2867.0 │ 30589.0 │
│ Neptune │  102.0 │    49528 │   4515.0 │ 59800.0 │
└─────────┴────────┴──────────┴──────────┴─────────┘
```

#### Scenario: Overlapping spanners
- **WHEN** a second level-1 spanner covers a column of the first
- **THEN** `tabSpanner` raises a `ValueError`

### Requirement: Row groups
Rows SHALL be grouped by `groupnameCol` or by `tabRowGroup(label, rows)`. Groups SHALL show in
the order they are made, after the rows that are in no group.

```nim
echo tabella(planets(), rownameCol = "planet")
  .colsHide(["type", "mass", "diameter", "density", "gravity", "day_length", "orbital_period", "mean_temp", "rings"])
  .tabRowGroup("Giants", where(it["type"] != "Terrestrial"))
```

```text
┌─────────┬──────────┬───────┐
│         │ distance │ moons │
╞═════════╪══════════╪═══════╡
│ Mercury │     57.9 │     0 │
│ Venus   │    108.2 │     0 │
│ Earth   │    149.6 │     1 │
│ Mars    │    228.0 │     2 │
├─────────┼──────────┼───────┤
│ Giants                     │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter │    778.5 │    95 │
│ Saturn  │   1432.0 │   146 │
│ Uranus  │   2867.0 │    28 │
│ Neptune │   4515.0 │    16 │
└─────────┴──────────┴───────┘
```

### Requirement: Footnotes
`tabFootnote(note, locations)` SHALL add a note in the footer and mark it at each location. Marks
SHALL be numbered in reading order of their locations (title, spanners, column labels, then the
groups, stub and body row by row), whatever the order the notes were added; the same note at
several places SHALL get one mark. `footnotesMarks` SHALL choose numbers, letters, capitals or
the symbols \*, †, ‡, §.

```nim
echo tabella(planets(), rownameCol = "planet")
  .colsHide(["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "rings"])
  .tabFootnote("Hotter than Mercury.", loc.body(cols = "mean_temp", rows = where(it["planet"] == "Venus")))
  .tabFootnote("As of 2024.", loc.columnLabels("moons"))
```

```text
┌─────────┬───────────┬─────────┐
│         │ mean_temp │ moons^1 │
╞═════════╪═══════════╪═════════╡
│ Mercury │       167 │       0 │
│ Venus   │     464^2 │       0 │
│ Earth   │        15 │       1 │
│ Mars    │       -65 │       2 │
│ Jupiter │      -110 │      95 │
│ Saturn  │      -140 │     146 │
│ Uranus  │      -195 │      28 │
│ Neptune │      -200 │      16 │
└─────────┴───────────┴─────────┘
1 As of 2024.
2 Hotter than Mercury.
```

### Requirement: Spanners from column names
`tabSpannerDelim(delim = ".", columns, split = "last", limit = -1, reverse = false)` SHALL split
column names at `delim`: the last part SHALL become the label and the parts before it spanners,
the first part highest. Next to each other, columns with the same parts SHALL share a spanner.
`limit` SHALL cap the number of splits, counted from the `split` side; `reverse` SHALL read the
parts the other way round.

```nim
let d = tableData:
  planet: ["Earth", "Mars"]
  size.diameter: [12756, 6792]
  size.mass: [5.97, 0.642]
  orbit.period.days: [365.2, 687.0]
  orbit.period.years: [1.0, 1.88]
  orbit.distance: [149.6, 228.0]
echo tabella(d, rownameCol = "planet").tabSpannerDelim()
```

```text
┌───────┬──────────┬───────┬───────┬───────┬──────────┐
│       │                  │          orbit           │
│       │       size       │    period     │          │
│       │ diameter │  mass │  days │ years │ distance │
╞═══════╪══════════╪═══════╪═══════╪═══════╪══════════╡
│ Earth │    12756 │  5.97 │ 365.2 │   1.0 │    149.6 │
│ Mars  │     6792 │ 0.642 │ 687.0 │  1.88 │    228.0 │
└───────┴──────────┴───────┴───────┴───────┴──────────┘
```

#### Scenario: A name with no delimiter
- **WHEN** a selected column has no `delim` in its name
- **THEN** its label stays and it gets no spanner

### Requirement: Caption
`tabCaption(caption)` SHALL give the table a caption: an HTML `<caption>` above the table (for
screen readers, and for figures in documents), a first line in text, an italic line in Markdown.
`rmCaption()` SHALL take it away.

```nim
let t = tabella(tavolaPitagorica(2)).tabCaption("Table 1: the times table of 2")
echo "<caption class=\"tb_caption\">Table 1: the times table of 2</caption>" in t.toHtml
echo t
```

```text
true
Table 1: the times table of 2
┌───┬───┬───┐
│ × │ 1 │ 2 │
╞═══╪═══╪═══╡
│ 1 │ 1 │ 2 │
│ 2 │ 2 │ 4 │
└───┴───┴───┘
```

### Requirement: Removing parts
`rmHeader()`, `rmStubhead()`, `rmCaption()`, `rmSpanners(spanners, levels)`, `rmFootnotes(indices)`
and `rmSourceNotes(indices)` SHALL take parts away, so tables built from a shared start can drop
what they do not need. With no arguments, `rmSpanners`, `rmFootnotes` and `rmSourceNotes` SHALL
remove all of them; indices SHALL count from 0 in the order the parts were added.

```nim
let base = tabella(tavolaPitagorica(2), rownameCol = "×").tabHeader("Times", "of two")
  .tabSourceNote("One.").tabSourceNote("Two.")
echo base.rmHeader().rmSourceNotes([0])
```

```text
┌───┬───┬───┐
│   │ 1 │ 2 │
╞═══╪═══╪═══╡
│ 1 │ 1 │ 2 │
│ 2 │ 2 │ 4 │
└───┴───┴───┘
Two.
```

### Requirement: Labels from a proc
`colsLabelWith(columns, fn)` SHALL relabel columns (by default all of them) with a proc over their
labels.

```nim
echo tabella(tavolaPitagorica(2), rownameCol = "×").colsLabelWith(proc (s: string): string = "×" & s)
```

```text
┌───┬────┬────┐
│   │ ×1 │ ×2 │
╞═══╪════╪════╡
│ 1 │  1 │  2 │
│ 2 │  2 │  4 │
└───┴────┴────┘
```

### Requirement: Moving columns
`colsMove(columns, after)`, `colsMoveToStart(columns)` and `colsMoveToEnd(columns)` SHALL move
columns; `colsReorder(columns)` SHALL put the given columns in the given order in the places they
hold, leaving the other columns where they are.

```nim
let d = tableData:
  a: [1]
  b: [2]
  c: [3]
  d: [4]
echo tabella(d).colsMoveToEnd("a").colsReorder(["d", "b"])
```

```text
┌───┬───┬───┬───┐
│ d │ c │ b │ a │
╞═══╪═══╪═══╪═══╡
│ 4 │ 3 │ 2 │ 1 │
└───┴───┴───┴───┘
```

### Requirement: Order of rows and groups
`rowOrder(columns, reverse)` SHALL show the rows sorted by the columns (the first decides, the next
break ties), within their groups, with missing values last; `rowGroupOrder(groups)` SHALL show the
row groups in the given order, the others after them as they were.

```nim
echo tabella(planets(), rownameCol = "planet", groupnameCol = "type")
  .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .rowOrder("moons", reverse = true)
  .rowGroupOrder(["Ice giant", "Gas giant"])
```

```text
┌─────────┬───────┐
│         │ moons │
╞═════════╪═══════╡
│ Ice giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus  │    28 │
│ Neptune │    16 │
├─────────┼───────┤
│ Gas giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Saturn  │   146 │
│ Jupiter │    95 │
├─────────┼───────┤
│ Terrestrial     │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mars    │     2 │
│ Earth   │     1 │
│ Mercury │     0 │
│ Venus   │     0 │
└─────────┴───────┘
```

### Requirement: Text helpers
Labels and notes SHALL be plain text (escaped in HTML), `md(text)` (inline Markdown: `**bold**`,
`*italic*`, `` `code` ``, links, `^sup^` and `~sub~` when closed with no space inside, so "~50"
stays as it is) or `html(text)` (used as is in HTML, its tags stripped in text and Markdown).

```nim
let t = tabella(tavolaPitagorica(2))
  .tabHeader(md("The **times** table"), html("of <span style=\"color: red\">two</span>"))
echo "<strong>times</strong>" in t.toHtml, " ", "<span style=\"color: red\">two</span>" in t.toHtml
echo t
```

```text
true true
The times table
   of two
┌───┬───┬───┐
│ × │ 1 │ 2 │
╞═══╪═══╪═══╡
│ 1 │ 1 │ 2 │
│ 2 │ 2 │ 4 │
└───┴───┴───┘
```

### Requirement: Summary rows
`summaryRows(fns, groups, columns, side, missingText)` SHALL add, under each row group (or
each of `groups`), one row for each aggregate of `fns`, labelled in the stub; `fns` SHALL be
pairs of a label and an aggregate, `{"total": agg.sum}`. `columns` SHALL say which columns are
summed up (the numeric ones by default); the other visible columns, and a cell with nothing to
sum up, SHALL show `missingText` (by default "—"). With `side = sTop` the rows SHALL come right
after the group's label, before its rows. A table with summary rows and no row names SHALL get
a stub, for the labels. `summaryRows` SHALL raise a `ValueError` on a table without row groups.

```nim
echo tabella(planets(), rownameCol = "planet", groupnameCol = "type")
  .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .summaryRows(fns = {"total": agg.sum})
```

```text
┌─────────┬───────┐
│         │ moons │
╞═════════╪═══════╡
│ Terrestrial     │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mercury │     0 │
│ Venus   │     0 │
│ Earth   │     1 │
│ Mars    │     2 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │     3 │
├─────────┼───────┤
│ Gas giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter │    95 │
│ Saturn  │   146 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │   241 │
├─────────┼───────┤
│ Ice giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus  │    28 │
│ Neptune │    16 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │    44 │
└─────────┴───────┘
```

#### Scenario: Summary above the group
- **WHEN** `side = sTop` is given
- **THEN** the summary rows come right after the group's label, before its rows

#### Scenario: Some groups only
- **WHEN** `groups = ["Ice giant"]` is given
- **THEN** only that group gets summary rows, and a group that does not exist raises a `KeyError`

#### Scenario: A group with no numbers
- **WHEN** every value of a summarised column in a group is missing
- **THEN** its summary cell shows `missingText`

### Requirement: Grand summary rows
`grandSummaryRows(fns, columns, side, missingText)` SHALL add rows that sum up every row of the
table, whatever its group, at the bottom (or at the top with `side = sTop`), set apart from the
body by a double rule.

```nim
echo tabella(planets(), rownameCol = "planet", groupnameCol = "type")
  .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .summaryRows(fns = {"total": agg.sum})
  .grandSummaryRows(fns = {"all moons": agg.sum})
```

```text
┌───────────┬───────┐
│           │ moons │
╞═══════════╪═══════╡
│ Terrestrial       │
├┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mercury   │     0 │
│ Venus     │     0 │
│ Earth     │     1 │
│ Mars      │     2 │
├┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total     │     3 │
├───────────┼───────┤
│ Gas giant         │
├┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter   │    95 │
│ Saturn    │   146 │
├┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total     │   241 │
├───────────┼───────┤
│ Ice giant         │
├┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus    │    28 │
│ Neptune   │    16 │
├┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total     │    44 │
╞═══════════╪═══════╡
│ all moons │   288 │
└───────────┴───────┘
```

### Requirement: Aggregates and their format
An aggregate SHALL be a proc from the column's non-missing values to a `Value`. `agg.sum`,
`agg.mean`, `agg.median`, `agg.min`, `agg.max`, `agg.count` and `agg.sd` (of a sample) SHALL be
built in, and `aggregate(proc)` SHALL make one from any proc that returns a value or something
`toValue` converts. A summary cell SHALL be formatted with the last format given to its whole
column, `agg.count` as an integer, and a number with no format with two decimals; `fmt` SHALL
format the rows of one call instead, from a proc of a float, of a value, or a `FormatFn`.

```nim
let middle = aggregate(proc (vs: seq[Value]): Value = vs[vs.len div 2])
echo tabella(planets(), rownameCol = "planet")
  .colsHide(["type", "mass", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .fmtInteger("diameter")
  .grandSummaryRows(fns = {"planets": agg.count, "largest": agg.max, "middle one": middle})
  .grandSummaryRows(fns = {"mean": agg.mean}, fmt = (x: float) => formatNumber(x, decimals = 1))
```

```text
┌────────────┬──────────┬───────┐
│            │ diameter │ moons │
╞════════════╪══════════╪═══════╡
│ Mercury    │    4,879 │     0 │
│ Venus      │   12,104 │     0 │
│ Earth      │   12,756 │     1 │
│ Mars       │    6,792 │     2 │
│ Jupiter    │  142,984 │    95 │
│ Saturn     │  120,536 │   146 │
│ Uranus     │   51,118 │    28 │
│ Neptune    │   49,528 │    16 │
╞════════════╪══════════╪═══════╡
│ planets    │        8 │     8 │
│ largest    │  142,984 │   146 │
│ middle one │  142,984 │    95 │
│ mean       │ 50,087.1 │  36.0 │
└────────────┴──────────┴───────┘
```

### Requirement: The look of summary rows
Summary rows SHALL be drawn apart from the body: in HTML with the classes `tb_summary_row` and
`tb_grand_summary_row`, a rule above the first row (below the last, when they come first) and the
options `summaryRowBackgroundColor`, `summaryRowTextTransform`, `summaryRowPadding`,
`summaryRowPaddingHorizontal`, `summaryRowBorderStyle`, `summaryRowBorderWidth`,
`summaryRowBorderColor`, and the same with `grandSummaryRow`, as gt's; in text with a dotted
rule (a group's) or a double rule (the table's); in Markdown with the label in italics (a
group's) or in bold (the table's).

```nim
let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
  .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .summaryRows(fns = {"total": agg.sum}, groups = ["Ice giant"])
  .grandSummaryRows(fns = {"all moons": agg.sum})
  .tabOptions(grandSummaryRowBackgroundColor = "#FFF3B0")
  .tabStyle(style.text(weight = "bold"), loc.grandSummary())
echo t.toMarkdown
echo "background-color: #FFF3B0" in t.toHtml
```

```text
|  | moons |
|:--|--:|
| **Terrestrial** |  |
| Mercury | 0 |
| Venus | 0 |
| Earth | 1 |
| Mars | 2 |
| **Gas giant** |  |
| Jupiter | 95 |
| Saturn | 146 |
| **Ice giant** |  |
| Uranus | 28 |
| Neptune | 16 |
| *total* | 44 |
| **all moons** | 288 |
true
```
