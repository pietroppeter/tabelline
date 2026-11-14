## MODIFIED Requirements

### Requirement: Preview of a big table
`tabellaPreview(data, topN, bottomN, inclRownums, moreRows)` SHALL make a table of the first
`topN` rows, the rows of `moreRows` (a row selector, not from gt: indices from 0, a range, a set
such as `{4, 6..7}`, or `where(...)`) and the last `bottomN` rows of `data`, in their order, with a
shaded row for each run of rows left out that names them ("6..99"), and the row numbers (from 1)
in the stub when `inclRownums`. A run of a single row SHALL be shown, not left out, so a table with
no more than `topN + bottomN + 1` rows is shown whole. Like `tabella`, it SHALL take a body of
verbs.

```nim
let preview = tabellaPreview(planets(), topN = 2, bottomN = 1):
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

```nim
let preview = tabellaPreview(planets(), topN = 2, bottomN = 1, moreRows = where(it.planet == "Jupiter")):
  colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp"]
echo preview
```

```text
┌──────┬─────────┬─────────────┬───────┬───────┐
│      │ planet  │ type        │ moons │ rings │
╞══════╪═════════╪═════════════╪═══════╪═══════╡
│ 1    │ Mercury │ Terrestrial │     0 │ false │
│ 2    │ Venus   │ Terrestrial │     0 │ false │
│ 3..4 │         │             │       │       │
│ 5    │ Jupiter │ Gas giant   │    95 │ true  │
│ 6..7 │         │             │       │       │
│ 8    │ Neptune │ Ice giant   │    16 │ true  │
└──────┴─────────┴─────────────┴───────┴───────┘
```

