## 1. Values

- [x] 1.1 `vkList` and `vkRecord`, `toValue` of seq, array, object and tuple, `list`, `record`
- [x] 1.2 `v[i]`, `v["x"]`, `in`, `len`, `isList`, `isRecord`, `$`, `==`, `<`, `toFloat` raises
- [x] 1.3 The dot on Value and Row; examples rewritten to `it.x`

## 2. Verbs

- [x] 2.1 Formats item by item (`FormatRule.wholeValue` for the ones that take a list whole)
- [x] 2.2 `fmtIcon`, `fmtImage`, `fmtFlag` take a list (`cellNames`)
- [x] 2.3 `fmtNanoplot` reads lists and records of x and y; `nanoplotXValues`; `x` and `expandX`
- [x] 2.4 `dataColor` skips lists and records

## 3. Docs and checks

- [x] 3.1 Tests in `tests/test_lists_records.nim`
- [x] 3.2 The guide (Nim sugar), section 6 of the devlog post "Designing tabelline 0.2", the Feature map, *Not from gt*
- [x] 3.3 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`; rebuild the docs
