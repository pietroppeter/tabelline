## 1. Data

- [x] 1.1 `tools/cldr.nim` writes `locales.nim` and `currencies.nim` from CLDR 49
- [x] 1.2 `localize.nim`: `getLocale`, `currencyInfo`, `formatPattern`

## 2. Formats

- [x] 2.1 `localeMarks` and `fmtPercent` from CLDR
- [x] 2.2 `fmtCurrency`: every ISO code, the locale's placement, `accounting`, `useSubunits`
- [x] 2.3 `fmtDate`, `fmtTime`, `fmtDatetime` with `locale`; gt's fixed and flexible styles
- [x] 2.4 `fmtAuto` with every currency code

## 3. Docs and checks

- [x] 3.1 Tests in `tests/test_locales.nim`
- [ ] 3.2 The guide, the Feature map, section 4 of the devlog post "Designing tabelline 0.2"
- [ ] 3.3 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`; rebuild the docs
