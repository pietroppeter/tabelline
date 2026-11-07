## ADDED Requirements

### Requirement: Parts per
`fmtPartsper(columns, rows, toUnits, decimals, scaleValues, inclSpace)` SHALL show fractions as
parts per thousand (`"per-mille"`, ‰), ten thousand (`"per-myriad"`, ‱), hundred thousand
(`"pcm"`), million (`"ppm"`), billion (`"ppb"`), trillion (`"ppt"`) or quadrillion (`"ppq"`).
With `inclSpace = "auto"` there SHALL be a space before letters and none before ‰ and ‱.

```nim
let d = tableData:
  co2: [0.000421, 0.000280]
echo tabella(d).fmtPartsper("co2", toUnits = "ppm", decimals = 0)
echo tabella(d).fmtPartsper("co2", decimals = 3)
```

```text
┌─────────┐
│     co2 │
╞═════════╡
│ 421 ppm │
│ 280 ppm │
└─────────┘
┌────────┐
│    co2 │
╞════════╡
│ 0.421‰ │
│ 0.280‰ │
└────────┘
```
