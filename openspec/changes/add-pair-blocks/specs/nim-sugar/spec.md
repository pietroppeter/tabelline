## ADDED Requirements

### Requirement: Blocks for lists of pairs
Inside `tabella(data): body`, a verb whose first argument is a list of pairs (`colsLabel`,
`colsWidth`, `colsUnits`, `textCaseMatch`, `summaryRows`, `grandSummaryRows`, `summaryColumns`)
SHALL also take an indented block, where a line `label: value` is a pair; in any verb a line
`name = value` SHALL be that named argument; in a summary verb a line `fmtX(args)` SHALL be
`fmt`, a proc of a float calling `formatX(x, args)`; `tabOptions:` SHALL take lines
`name = value`. A block SHALL make the same call as the pair form.

```nim
let t = tabella(planets(), rownameCol = "planet"):
  colsHide ["type", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "moons"]
  colsLabel:
    mass: "mass, {{10^24 kg}}"
    diameter: "diameter, {{km}}"
  grandSummaryRows:
    mean: agg.mean
    "largest one": agg.max
    fmtNumber(decimals = 0)
  tabOptions:
    rowStriping = true
echo t
echo t.options.rowStriping
```

```text
┌─────────────┬───────────────┬──────────────┐
│             │ mass, 10²⁴ kg │ diameter, km │
╞═════════════╪═══════════════╪══════════════╡
│ Mercury     │          0.33 │         4879 │
│ Venus       │          4.87 │        12104 │
│ Earth       │          5.97 │        12756 │
│ Mars        │         0.642 │         6792 │
│ Jupiter     │        1898.0 │       142984 │
│ Saturn      │         568.0 │       120536 │
│ Uranus      │          86.8 │        51118 │
│ Neptune     │         102.0 │        49528 │
╞═════════════╪═══════════════╪══════════════╡
│ mean        │           333 │       50,087 │
│ largest one │         1,898 │      142,984 │
└─────────────┴───────────────┴──────────────┘
true
```
