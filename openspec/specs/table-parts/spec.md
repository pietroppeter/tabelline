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
