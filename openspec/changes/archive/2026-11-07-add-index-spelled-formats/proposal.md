## Why

Lists of options (a, b, c) and prose-like tables ("three moons") need numbers as words. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_index(), fmt_spelled_num()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `fmtIndex`, `fmtSpelledNum` and their value functions.

## Differences from gt and Great Tables

- Only English for spelled numbers (gt has a dozen languages): locales come in 0.3.

## Capabilities

### New requirement in `formatting`
- Letters and spelled numbers

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
