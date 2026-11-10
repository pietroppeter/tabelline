## 1. Columns

- [x] 1.1 `colsMerge`, `colsMergeUncert`, `colsMergeRange`, `colsMergeNPct` (`MergeRule`, `fillPattern`)
- [x] 1.2 `colsAdd` (values, Nim values, a proc of the row)
- [x] 1.3 `summaryColumns` (the aggregates of summary rows)
- [x] 1.4 `colsAlignDecimal` (figure spaces, the locale's mark)

## 2. Rows

- [x] 2.1 `rowsAdd` (a TableData or objects; before, after; groups)
- [x] 2.2 `rowsHide`, `rowsUnhide` (hidden rows are not summed up)
- [x] 2.3 `tabStubIndent` (HTML `tb_indent_N`, text and Markdown spaces)

## 3. Docs and checks

- [x] 3.1 Tests in `tests/test_rows_cols.nim`
- [ ] 3.2 The guide, the Feature map, the devlog post "Designing tabelline 0.2"
- [ ] 3.3 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`; rebuild the docs
