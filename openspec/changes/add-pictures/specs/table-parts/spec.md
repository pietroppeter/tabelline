## ADDED Requirements

### Requirement: Columns of nanoplots
`colsNanoplot(columns, rows, plotType, ..., newColName = "nanoplots", newColLabel, before,
after, autohide = true)` SHALL add a column with a nanoplot per row of the values of `columns`,
in their order (a missing value is `NA`), at the end or `before` or `after` a column, labelled
`newColLabel` (its name by default), and SHALL hide `columns` unless `autohide` is false. The
other arguments SHALL be those of `fmtNanoplot`.

```nim
let t = tabella(tavolaPitagorica(4), rownameCol = "×"):
  colsNanoplot ["1", "2", "3", "4"], newColLabel = "the row", autoscale = true
echo t
```

```text
┌───┬───────────┐
│   │ the row   │
╞═══╪═══════════╡
│ 1 │ ▁▁▂▂ 1–4  │
│ 2 │ ▁▂▃▄ 2–8  │
│ 3 │ ▂▃▅▆ 3–12 │
│ 4 │ ▂▄▆█ 4–16 │
└───┴───────────┘
```
