## ADDED Requirements

### Requirement: Moving columns
`colsMove(columns, after)`, `colsMoveToStart(columns)` and `colsMoveToEnd(columns)` SHALL move
columns; `colsReorder(columns)` SHALL put the given columns in the given order in the places they
hold, leaving the other columns where they are.

```nim
let d = tableData:
  a: [1]
  b: [2]
  c: [3]
  d: [4]
echo tabella(d).colsMoveToEnd("a").colsReorder(["d", "b"])
```

```text
┌───┬───┬───┬───┐
│ d │ c │ b │ a │
╞═══╪═══╪═══╪═══╡
│ 4 │ 3 │ 2 │ 1 │
└───┴───┴───┴───┘
```
