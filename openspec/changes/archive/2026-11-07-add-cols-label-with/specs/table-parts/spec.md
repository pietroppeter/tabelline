## ADDED Requirements

### Requirement: Labels from a proc
`colsLabelWith(columns, fn)` SHALL relabel columns (by default all of them) with a proc over their
labels.

```nim
echo tabella(tavolaPitagorica(2), rownameCol = "×").colsLabelWith(proc (s: string): string = "×" & s)
```

```text
┌───┬────┬────┐
│   │ ×1 │ ×2 │
╞═══╪════╪════╡
│ 1 │  1 │  2 │
│ 2 │  2 │  4 │
└───┴────┴────┘
```
