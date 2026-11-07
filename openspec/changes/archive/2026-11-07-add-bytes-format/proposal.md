## Why

File and memory sizes are a common column, and easy to get wrong by hand. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_bytes()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `fmtBytes` and `formatBytes`.

## Differences from gt and Great Tables

- None in names; gt's `n_sigfig` and `force_sign` are not there yet.

## Capabilities

### New requirement in `formatting`
- Bytes

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
