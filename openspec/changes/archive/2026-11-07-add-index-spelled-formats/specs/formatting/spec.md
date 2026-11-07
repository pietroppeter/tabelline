## ADDED Requirements

### Requirement: Letters and spelled numbers
`fmtIndex(columns, rows, upper, indexAlgo)` SHALL show whole numbers as letters (1 is A, 26 is Z,
27 is AA, then BB with `"repeat"` or AB with `"excel"`); `fmtSpelledNum(columns, rows)` SHALL
spell numbers from zero to one hundred in English, and leave others as digits.

```nim
let d = tableData:
  n: [1, 3, 27, 42]
echo tabella(d).fmtIndex("n", upper = false)
echo tabella(d).fmtSpelledNum("n")
```

```text
┌────┐
│  n │
╞════╡
│  a │
│  c │
│ aa │
│ pp │
└────┘
┌──────────────┐
│            n │
╞══════════════╡
│          one │
│        three │
│ twenty-seven │
│    forty-two │
└──────────────┘
```
