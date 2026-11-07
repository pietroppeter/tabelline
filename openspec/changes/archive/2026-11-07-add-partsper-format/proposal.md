## Why

Concentrations (CO₂ in ppm, salinity in ‰) read best in their own units. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_partsper()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #10.

## What Changes

- `fmtPartsper` and `formatPartsper`.

## Differences from gt and Great Tables

- `inclSpace` is a string (`"auto"`, `"true"`, `"false"`), as gt's `incl_space = "auto"`.

## Capabilities

### New requirement in `formatting`
- Parts per

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
