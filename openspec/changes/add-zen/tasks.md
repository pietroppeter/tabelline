## 1. Build

- [x] 1.1 `src/tabelline/zen.nim`: `pep20`, `aphorisms`, `zenText`, `faithfulness`, `zenData`, `zenTable`
- [x] 1.2 `src/tabelline/this.nim`: prints `zenText` on import
- [x] 1.3 Page `docs/zen.nim`, its card on the home page, README, llms.txt, a row in the feature map
- [x] 1.4 Tests in `tests/`

## 2. Checks

- [x] 2.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [x] 2.2 Rebuild the docs (`nim r -d:release docs/all.nim`)

## 3. Release

- [ ] 3.1 Archive the change: add a CHANGELOG line
