## 1. tabelline under nim js

- [x] 1.1 `imageDataUrl` raises under JavaScript; the big const strings bound once with `let`
- [x] 1.2 `fixed(x, decimals)`: ties to even under JavaScript, used by every `formatFloat(..., ffDecimal, ...)`
- [x] 1.3 `colsAlignDecimal` through an iterator, not `ptr string`
- [x] 1.4 `tests/js.nim`, with a JavaScript branch for the tests that need files; CI runs it in Node

## 2. A lean build

- [x] 2.1 `-d:tabellineIcons=false` and `-d:tabellineDatasets=false`, with errors that name them
- [x] 2.2 `tests/lean.nim`, in C and JavaScript, in CI
- [x] 2.3 A line in *Not from gt*; README

## 3. Checks

- [x] 3.1 Run `nim r tests/all.nim`, `nim js -d:nodejs -r tests/js.nim` and `nim r tools/specexamples.nim --changes`
- [x] 3.2 Rebuild the docs
