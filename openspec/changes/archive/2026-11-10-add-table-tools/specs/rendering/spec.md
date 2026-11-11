## ADDED Requirements

### Requirement: The built table as data
`extractCells(t, columns, rows, ctx)` SHALL give the shown text of the body cells of `columns`
and `rows`, in the order the table shows them; `extractBody(t, ctx)` SHALL give the body as a
`TableData` of texts (a `group` column when there are row groups, a `rowname` column when there
is a stub, then every visible column); `extractSummary(t, ctx)` SHALL give the summary rows as a
`TableData` of texts (`group`, "" for a grand summary row, `label`, and the visible columns).
`ctx = rcHtml` SHALL give HTML.

```nim
let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  colsHide ["diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "moons"]
  fmtNumber "mass", decimals = 1
  summaryRows fns = {"total": agg.sum}
echo extractCells(t, "mass", rows = [0, 1]).join(" | ")
echo tabella(extractSummary(t))
```

```text
0.3 | 4.9
┌─────────────┬───────┬─────────┐
│ group       │ label │ mass    │
╞═════════════╪═══════╪═════════╡
│ Terrestrial │ total │ 11.8    │
│ Gas giant   │ total │ 2,466.0 │
│ Ice giant   │ total │ 188.8   │
└─────────────┴───────┴─────────┘
```
