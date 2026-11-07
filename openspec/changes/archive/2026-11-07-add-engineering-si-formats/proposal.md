## Why

Physics and engineering tables use powers of a thousand: 12.35 × 10³, or 12.35 kg. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_engineering(), fmt_number_si()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- Two formats and their value functions `formatEngineering` and `formatNumberSi`.

## Differences from gt and Great Tables

- `fmt_number_si` is gt only; Great Tables has `fmt_engineering` only.
- Exponents are written × 10³ (superscript), as `fmtScientific` already does.

## Capabilities

### New requirement in `formatting`
- Engineering notation and SI prefixes

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
