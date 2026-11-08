## 1. Build

- [x] 1.1 Rename `optTokens()` to `optPageTheme()` in `src/tabelline/verbs.nim`, with a doc comment that names the variables
- [x] 1.2 Every page of the docs and the book takes `optPageTheme()`
- [x] 1.3 Update the requirement "Options and presets" in `styling`
- [x] 1.4 Explain it: a comment in the home page's example, a section in The Great Explainer

## 2. Checks

- [x] 2.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim`
- [x] 2.2 Rebuild the docs (`nim r -d:release docs/all.nim`)
