## Why

The Great Explainer's first table, *la tavola pitagorica*, used the dataset `tavolaPitagorica(10)`.
Pietro asked to build it from scratch instead, to show Nim's sugar that works with `for` (project
thread "Build the tavola pitagorica from scratch"). Building one column per factor took
`TableData()`, `addColumn` and `toValue`; he asked whether it could be one `tableData` call. It
could not: `tableData:` took only fixed `name: [values]` lines. This is the BACKLOG entry
"Columns from computed lists". Built in PR #30.

## What Changes

- In a `tableData:` body, a `for` or `if` adds the columns of its own lines.
- A column name can be computed when the line runs: `$j: [...]`, or any expression in
  parentheses, `(k & "!"): [...]`. A plain name is still read as text (`mass`, `size.mass`,
  `` `mass kg` ``, `"mass (kg)"`).
- The values can be any list, such as a `collect` (this already worked, now it is in the spec).
- `tableData:` builds the table with `addColumn`, so lengths and duplicate names are checked as before.

```nim
let tavola = tableData:
  `×`: collect(for i in 1 .. 10: i)
  for j in 1 .. 10:
    $j: collect(for i in 1 .. 10: i * j)
```

## Differences from gt and Great Tables

- None in names: neither has a `tableData` builder. In R one would build a tibble, in Python a
  DataFrame (`pl.DataFrame({str(j): [i * j for i in range(1, 11)] for j in range(1, 11)})`, a dict
  comprehension, is the closest).

## Capabilities

### Modified requirements in `table-data`
- Data from Nim values

## Impact

`src/tabelline.nim` (the `tableData` macro), the spec `table-data`, `tests/test_core.nim`,
`tools/specexamples.nim` (examples import `std/sugar`), The Great Explainer, BACKLOG.md.
