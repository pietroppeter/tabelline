## MODIFIED Requirements

### Requirement: Columns of nanoplots
`colsNanoplot(columns, rows, plotType, ..., newColName = "nanoplots", newColLabel, before,
after, autohide = true)` SHALL add a column with a nanoplot per row of the values of `columns`,
in their order (a missing value is `NA`), at the end or `before` or `after` a column, labelled
`newColLabel` (its name by default), and SHALL hide `columns` unless `autohide` is false. The
other arguments SHALL be those of `fmtNanoplot`. With `xVals` (not from gt), one place on the x
axis for each of `columns`, the same in every row, each cell SHALL be a record of `x` and `y`, so
that `referenceX` draws its vertical lines; `xVals` of another length than `columns` SHALL raise
`ValueError`.

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

```nim
let d = tableData:
  region: ["north", "south"]
  y2012: [8.1, 18.4]
  y2013: [9.0, 21.0]
  y2014: [8.6, 20.2]
  y2015: [7.7, 17.9]
let t = tabella(d, rownameCol = "region"):
  colsNanoplot ["y2012", "y2013", "y2014", "y2015"], newColLabel = "2012–2015", autoscale = true,
    xVals = @[2012.0, 2013.0, 2014.0, 2015.0], referenceX = @["2013"]
echo t
echo t.toHtml.count("stroke-dasharray"), " lines"
```

```text
┌───────┬────────────────┐
│       │ 2012–2015      │
╞═══════╪════════════════╡
│ north │ ▁▂▁▁ 7.70–9.00 │
│ south │ ▇██▆ 17.9–21.0 │
└───────┴────────────────┘
2 lines
```

