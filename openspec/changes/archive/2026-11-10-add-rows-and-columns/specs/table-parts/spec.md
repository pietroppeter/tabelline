## ADDED Requirements

### Requirement: Merged columns
`colsMerge(columns, rows, pattern, autohide = true)` SHALL show the formatted values of `columns`
in the first one, by `pattern`: `{1}`, `{2}`, ... SHALL be the columns' cells, and a part between
`<<` and `>>` SHALL be left out when a value it names is missing. Without a pattern the cells
SHALL be joined by spaces. The other columns SHALL be hidden unless `autohide = false`.
`colsMergeUncert(colVal, colUncert)` SHALL show `value ± uncertainty`, `colsMergeRange(colBegin,
colEnd)` SHALL show `begin–end` and `colsMergeNPct(colN, colPct)` SHALL show `n (pct)`, with no
percentage after a zero count; each SHALL show just the first value when the second is missing.

```nim
let d = tableData:
  mission: ["Voyager 1", "Galileo", "Cassini"]
  launch: [1977, 1989, 1997]
  ended: [nil, 2003, 2017]
  target: ["Jupiter, Saturn", "Jupiter", "Saturn"]
  moon: [nil, "Io", "Titan"]
echo tabella(d, rownameCol = "mission")
  .colsMergeRange("launch", "ended")
  .colsMerge(["target", "moon"], pattern = "{1}<< and {2}>>")
```

```text
┌───────────┬───────────┬──────────────────┐
│           │    launch │ target           │
╞═══════════╪═══════════╪══════════════════╡
│ Voyager 1 │      1977 │ Jupiter, Saturn  │
│ Galileo   │ 1989–2003 │ Jupiter and Io   │
│ Cassini   │ 1997–2017 │ Saturn and Titan │
└───────────┴───────────┴──────────────────┘
```

### Requirement: Added columns
`colsAdd(name, values, before, after)` SHALL add a column, at the end or before or after another
one, from `Value`s, from Nim values, or from a proc of each row. The data of the table it was
added to SHALL stay as it was.

```nim
echo tabella(planets(), rownameCol = "planet")
  .colsHide(everything())
  .colsAdd("moons per Earth mass", proc (r: Row): Value = toValue(r["moons"].toFloat / r["mass"].toFloat * 5.97))
  .fmtNumber("moons per Earth mass", decimals = 1)
```

```text
┌─────────┬──────────────────────┐
│         │ moons per Earth mass │
╞═════════╪══════════════════════╡
│ Mercury │                  0.0 │
│ Venus   │                  0.0 │
│ Earth   │                  1.0 │
│ Mars    │                 18.6 │
│ Jupiter │                  0.3 │
│ Saturn  │                  1.5 │
│ Uranus  │                  1.9 │
│ Neptune │                  0.9 │
└─────────┴──────────────────────┘
```

### Requirement: Summary columns
`summaryColumns(fns, columns, fmt, side = sRight, missingText)` SHALL add a column for each
aggregate of `fns`, its label the name, summing up `columns` (the numeric ones by default) across
each row, at the right of the table or at the left of the data. The new column SHALL be formatted
like the first column it sums up, or by `fmt`. Summary rows SHALL sum it up like any column.

```nim
let medals = tableData:
  country: ["Norway", "Germany", "Italy"]
  gold: [16, 12, 7]
  silver: [8, 10, 8]
  bronze: [13, 5, 9]
echo tabella(medals, rownameCol = "country")
  .summaryColumns(fns = {"total": agg.sum})
  .grandSummaryRows(fns = {"all": agg.sum})
```

```text
┌─────────┬──────┬────────┬────────┬───────┐
│         │ gold │ silver │ bronze │ total │
╞═════════╪══════╪════════╪════════╪═══════╡
│ Norway  │   16 │      8 │     13 │    37 │
│ Germany │   12 │     10 │      5 │    27 │
│ Italy   │    7 │      8 │      9 │    24 │
╞═════════╪══════╪════════╪════════╪═══════╡
│ all     │   35 │     26 │     27 │    88 │
└─────────┴──────┴────────┴────────┴───────┘
```

### Requirement: Added and hidden rows
`rowsAdd(rows, before, after)` SHALL add rows, from a `TableData` of some of the columns or from
Nim objects, the other columns missing, at the end or before or after a row of the data; a value
of the group column SHALL put a row in its group, made when new. `rowsHide(rows)` SHALL hide rows,
which summary rows then leave out, and `rowsUnhide(rows)` SHALL show them again.

```nim
echo tabella(planets(), rownameCol = "planet", groupnameCol = "type")
  .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .rowsHide(where(it["type"] != "Ice giant"))
  .rowsAdd([(planet: "Pluto", `type`: "Dwarf planet", moons: 5)])
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
│ Dwarf planet    │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Pluto   │     5 │
└─────────┴───────┘
```

### Requirement: Stub indent
`tabStubIndent(rows, indent)` SHALL indent the stub cells of `rows` by a level from 0 to 5, given
as a number or as `"increase"` or `"decrease"` (one level more or less than now).

```nim
let budget = tableData:
  item: ["Hardware", "Laptops", "Screens", "Travel"]
  eur: [5200, 4000, 1200, 900]
echo tabella(budget, rownameCol = "item")
  .tabStubIndent([1, 2], "increase")
  .fmtInteger("eur")
```

```text
┌───────────┬───────┐
│           │   eur │
╞═══════════╪═══════╡
│ Hardware  │ 5,200 │
│   Laptops │ 4,000 │
│   Screens │ 1,200 │
│ Travel    │   900 │
└───────────┴───────┘
```

### Requirement: Aligned on the decimal mark
`colsAlignDecimal(columns, decMark, locale)` SHALL align the formatted numbers of `columns` on
their decimal mark (the locale's by default), padding each on the right with figure spaces, and a
punctuation space for a number with no mark, and SHALL align the columns right.

```nim
let d = tableData:
  x: [1.5, 10.25, 3.0, 120.125]
echo tabella(d).fmtNumber("x", decimals = 3, dropTrailingZeros = true).colsAlignDecimal("x").toMarkdown
```

```text
| x |
|--:|
| 1.5   |
| 10.25  |
| 3     |
| 120.125 |
```
