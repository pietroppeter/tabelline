## 1. Colour names

- [x] 1.1 The 148 CSS names in `namedColors` (checked against Chromium); `parseColor` strict
- [x] 1.2 White text on a dark options background given by name (`onDark`)
- [x] 1.3 Tests; the v0.2.0 chapter writes `"darkgreen"`

## 2. nbTable data: body

- [x] 2.1 `nbTable` as a macro: a table, data, data and a body, `tabella`'s other arguments
- [x] 2.2 Tests in `tests/test_nimib.nim`

## 3. tabelline/nanuq

- [x] 3.1 `src/tabelline/nanuq.nim`: `toTableData(df)`, `initTabella(df, ...)`
- [x] 3.2 nanuq in the `docs` feature, pinned; `tests/test_nanuq.nim`, run by CI
- [ ] 3.3 The clinical case study shapes its data with nanuq

## 4. Docs and checks

- [ ] 4.1 The guide, the Reference, *Not from gt*, the book's gaps, BACKLOG, CHANGELOG, README
- [ ] 4.2 `nim r tests/all.nim`, `nim r tools/specexamples.nim --changes`, rebuild docs and book
