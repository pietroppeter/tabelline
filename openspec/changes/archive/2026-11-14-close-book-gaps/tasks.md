## 1. Data, parts, columns, rows

- [x] 1.1 Leading zeros stay text in `parseCsv`; nanuq list columns become lists
- [x] 1.2 `tabStub`; `tabRowGroup(label, id)` relabels
- [x] 1.3 `ofKind`, `named`, `matches`, `&`; mixed `colsLabel` blocks; negative row indices and `^1`

## 2. Formats and text

- [x] 2.1 `nSigfig`, `accounting`, `expStyle`, `formatStr`, Markdown in `subMissing`
- [x] 2.2 `fmtFlag`: name on hover, `round = true` (circle-flags, `tools/circleflags.nim`)
- [x] 2.3 The format functions take `pattern`, `locale`, `expStyle`
- [x] 2.4 Fuller Markdown in `md()`

## 3. Options, styles, look

- [x] 3.1 `optStylize` with gt's six styles; `optAllCaps(locations)`; light text on dark stub, groups, summaries
- [x] 3.2 `style.text(vAlign, indent)`, `style.fill(alpha)`; R's colour names (`tools/rcolors.nim`); `palette("great-tables")`
- [x] 3.3 `loc.stub(labels)`, `loc.rowGroups(rows)`, `loc.body(mask)`; spanner fill; `dataColor` leaves the stub
- [x] 3.4 `td.tb_right` does not wrap; `stubSticky`

## 4. Book, docs and checks

- [x] 4.1 Every chapter that worked around a gap uses the direct code; `book/gaps.md` moves 29 rows to *Closed by 0.2*
- [x] 4.2 The feature map, *Not from gt*, the Guide, CHANGELOG
- [x] 4.3 `nim r tests/all.nim`, `nim r tools/specexamples.nim`, the docs and the book rebuilt
