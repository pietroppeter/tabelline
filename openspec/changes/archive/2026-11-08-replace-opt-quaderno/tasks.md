## 1. Build

- [x] 1.1 `optTokens()` in `src/tabelline/verbs.nim`; remove `optQuaderno()`
- [x] 1.2 Every page of the docs takes `optTokens()`; the tokens are in `docs/stile.nim`
- [x] 1.3 Update the requirement "Options and presets" in `styling`

## 2. Checks

- [x] 2.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim`
- [x] 2.2 Rebuild the docs (`nim r -d:release docs/all.nim`)
