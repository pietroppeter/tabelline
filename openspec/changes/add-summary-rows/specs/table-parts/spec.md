## ADDED Requirements

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
