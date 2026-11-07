## ADDED Requirements

### Requirement: Engineering notation and SI prefixes
`fmtEngineering(columns, rows, decimals)` SHALL show numbers in scientific notation with exponents
in steps of three; `fmtNumberSi(columns, rows, unit, decimals, inclSpace)` SHALL show them with an
SI prefix (from quecto to quetta) before an optional unit.

```nim
let d = tableData:
  x: [12345.0, 0.000123, 1.5]
echo tabella(d).fmtEngineering("x")
echo tabella(d).fmtNumberSi("x", unit = "g")
```

```text
┌───────────────┐
│             x │
╞═══════════════╡
│   12.35 × 10³ │
│ 123.00 × 10⁻⁶ │
│          1.50 │
└───────────────┘
┌───────────┐
│         x │
╞═══════════╡
│  12.35 kg │
│ 123.00 µg │
│    1.50 g │
└───────────┘
```
