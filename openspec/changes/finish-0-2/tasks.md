## 1. Table parts and options

- [x] 1.1 `stubCols`, `stubColumns`, `initTabella(data, rownameCol = [...])`; spans in `build` (`BuiltRow.levels`, `spans`)
- [x] 1.2 Groups as a column (`rowGroupAsColumn`, `groupAsColumn`, `stubWidth`) in HTML, text and Markdown
- [x] 1.3 `loc.stub(rows, cols)`; `loc.body` and other verbs leave every stub column out; `extractBody`
- [x] 1.4 The 22 options in `TabOptions`, `tabellaCss`, `styleVars`, `ownCss` and the text renderers

## 2. Formats and data

- [x] 2.1 `localImage`, `webImage`; `alt` of an image in text output
- [x] 2.2 `systemFonts`, `fontStackNames`, `defaultFonts`
- [x] 2.3 Per-point options of `nanoplotOptions`; dates on x
- [x] 2.4 `gtcars`, `countrypops`, `illness`, `metro` in `tabelline/datasets`; the book reads them from there

## 3. Docs and checks

- [x] 3.1 Tests in `tests/test_finish_0_2.nim`
- [x] 3.2 The Guide (a stub of several columns, images, per-point options, 164 options), the Feature map, *Not from gt*, the devlog post "Designing tabelline 0.2"
- [x] 3.3 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`; rebuild the docs
