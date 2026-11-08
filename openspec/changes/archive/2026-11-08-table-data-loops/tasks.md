## 1. Build

- [x] 1.1 `tableData:` reads `for` and `if` bodies, and computed names (`$j:`, `(expr):`), building with `addColumn`
- [x] 1.2 A test with loops and computed names
- [x] 1.3 Update the requirement "Data from Nim values" in `table-data`, with the times table as example
- [x] 1.4 The Great Explainer builds its first table with one `tableData` call

## 2. Checks

- [x] 2.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim`
- [x] 2.2 Rebuild the docs (`nim r -d:release docs/all.nim`)
