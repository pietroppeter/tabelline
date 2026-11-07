## Why

Flags in tables of countries, without images to load (pages stay standalone). One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_flag()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `fmtFlag` and `formatFlag`.

## Differences from gt and Great Tables

- gt draws SVG flags and also reads three-letter codes; tabelline uses emoji and two-letter codes. Some systems (Windows) show emoji flags as two letters.

## Capabilities

### New requirement in `formatting`
- Flags

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
