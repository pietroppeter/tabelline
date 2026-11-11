## ADDED Requirements

### Requirement: Shape nanoplots
`fmtNanoplot(columns, plotType = "shape", ...)` SHALL draw each cell's record of `x` and `y` as
one outline: the points joined in their order and closed, filled, at the same scale across and
up, in a square as high as the plot (not from gt or Great Tables). With `autoscale` every shape
of the column SHALL have the scale of the largest one; a missing value SHALL start a new ring.
The fill and the line SHALL be `dataBarFillColor` and `dataBarStrokeColor`. A cell that is not
a record of `x` and `y` SHALL raise `ValueError`. In text a shape SHALL be "◆ shape of N points".

```nim
let d = tableData:
  field: ["square", "strip"]
  outline: [toValue((x: @[0, 2, 2, 0], y: @[0, 0, 2, 2])), toValue((x: @[0, 4, 4, 0], y: @[0, 0, 1, 1]))]
let t = tabella(d, rownameCol = "field"):
  fmtNanoplot "outline", plotType = "shape", autoscale = true
echo t
echo t.toHtml.count("class=\"tb_shape\""), " shapes; the square is ", shapeSide(@[0.0, 0, 2, 2], @[0.0, 2, 2, 0]), " wide"
```

```text
┌────────┬─────────────────────┐
│        │ outline             │
╞════════╪═════════════════════╡
│ square │ ◆ shape of 4 points │
│ strip  │ ◆ shape of 4 points │
└────────┴─────────────────────┘
2 shapes; the square is 2.0 wide
```
