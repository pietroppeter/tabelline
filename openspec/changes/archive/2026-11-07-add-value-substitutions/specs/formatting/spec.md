## ADDED Requirements

### Requirement: Small, large and given values
`subSmallVals(columns, rows, threshold = 0.01, smallPattern = "<{x}", sign)` SHALL show numbers
closer to zero than the threshold (but not zero) as the pattern, with the threshold for `{x}`;
`subLargeVals(columns, rows, threshold = 1e12, largePattern = ">={x}", sign)` SHALL do the same for
numbers at or beyond the threshold; `sign = "-"` SHALL apply them to negative numbers.
`subValues(columns, rows, values, replacement)` SHALL show the given values, or the values for which
a proc `fn` holds, as a text.

```nim
let d = tableData:
  x: [0.004, 2.5, 3e13, -99.0]
echo tabella(d).fmtNumber("x").subSmallVals().subLargeVals().subValues(values = [-99], replacement = "n/a")
```

```text
┌───────┐
│     x │
╞═══════╡
│ <0.01 │
│  2.50 │
│  >=1T │
│   n/a │
└───────┘
```
