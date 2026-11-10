## 1. Units and chemistry

- [x] 1.1 `formatUnits`, `fmtUnits` (gt's notation, Unicode in text)
- [x] 1.2 `colsUnits` and `{{...}}` in labels (`renderLabel`, `columnLabel`)
- [x] 1.3 `formatChem`, `fmtChem`, `%...%` in units

## 2. Other formats

- [x] 2.0 `fmtFlag` takes three-letter codes

- [x] 2.1 `formatFraction`, `fmtFraction`
- [x] 2.2 `formatBins`, `fmtBins`
- [x] 2.3 `fmtPassthrough`
- [x] 2.4 `fmtAuto`
- [x] 2.5 `countryName`, `formatCountry`, `fmtCountry`; `tools/cldr.nim` writes `countries.nim`

## 3. Docs and checks

- [x] 3.1 Tests in `tests/test_more_formats.nim`
- [x] 3.2 The guide, the Feature map, section 3 of the devlog post "Designing tabelline 0.2"
- [x] 3.3 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`; rebuild the docs
