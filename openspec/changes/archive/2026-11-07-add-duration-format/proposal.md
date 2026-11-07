## Why

Race times, run times, half-lives: durations in a column of seconds are unreadable. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_duration()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #10.

## What Changes

- `fmtDuration` and `formatDuration`.

## Differences from gt and Great Tables

- gt reads difftime values; Nim has `Duration`, but a column holds numbers, so `inputUnits` says what they are.

## Capabilities

### New requirement in `formatting`
- Durations

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
