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
