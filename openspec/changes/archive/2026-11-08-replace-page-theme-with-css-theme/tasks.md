## 1. Build

- [x] 1.1 Add `CssTheme`, `cssTheme(...)` and `optCssTheme(...)` to `src/tabelline/verbs.nim`, and remove `optPageTheme()`
- [x] 1.2 Tests for the defaults, the fallbacks, a renamed variable and a value
- [x] 1.3 Update the requirement "Options and presets" in `styling`
- [x] 1.4 Rename the tokens in `docs/stile.nim`, the pages, the book and `book/theme/edo.css`
- [x] 1.5 Explain it: the home page, the Great Explainer section "Tables that follow the page", the Design Ref

## 2. Checks

- [x] 2.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim`
- [x] 2.2 Rebuild the docs (`nim r -d:release docs/all.nim`), check both looks at 390px
