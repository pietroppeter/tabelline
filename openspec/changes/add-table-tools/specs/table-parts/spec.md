## ADDED Requirements

### Requirement: Rotated labels
`colsLabelRotate(columns, dir)` SHALL turn the column labels of `columns` on their side in HTML,
read from the bottom up (`"sideways-lr"`, the default) or from the top down (`"sideways-rl"`);
the text and Markdown outputs SHALL keep them as they are. Another `dir` SHALL raise a
`ValueError`.

```nim
let t = tabella(planets(), rownameCol = "planet"):
  colsHide ["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp"]
  colsLabelRotate ["moons", "rings"]
echo t.toHtml.count("writing-mode: vertical-rl; transform: rotate(180deg)")
```

```text
2
```

### Requirement: Preview of a big table
`tabellaPreview(data, topN, bottomN, inclRownums)` SHALL make a table of the first `topN` rows
and the last `bottomN` rows of `data`, with a shaded row between them that names the rows left
out ("6..99"), and the row numbers (from 1) in the stub when `inclRownums`. A table with no more
than `topN + bottomN + 1` rows SHALL be shown whole.

```nim
let preview = tabella(tabellaPreview(planets(), topN = 2, bottomN = 1)):
  colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp"]
echo preview
```

```text
┌──────┬─────────┬─────────────┬───────┬───────┐
│      │ planet  │ type        │ moons │ rings │
╞══════╪═════════╪═════════════╪═══════╪═══════╡
│ 1    │ Mercury │ Terrestrial │     0 │ false │
│ 2    │ Venus   │ Terrestrial │     0 │ false │
│ 3..7 │         │             │       │       │
│ 8    │ Neptune │ Ice giant   │    16 │ true  │
└──────┴─────────┴─────────────┴───────┴───────┘
```

## MODIFIED Requirements

### Requirement: Aggregates and their format
An aggregate SHALL be a proc from the column's non-missing values to a `Value`. `agg.sum`,
`agg.mean`, `agg.median`, `agg.min`, `agg.max`, `agg.count` and `agg.std` (of a sample) SHALL be
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
