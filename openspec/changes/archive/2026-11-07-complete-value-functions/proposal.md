## Why

Great Tables' `vals.fmt_*` and gt's `vec_fmt_*` format single values, for text around a table. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `vec_fmt_*(), vals.fmt_*()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- Every format added in 0.1 comes with its public value function.

## Differences from gt and Great Tables

- Plain Nim functions, `formatX(value, ...)`, instead of a namespace (`vals.fmt_number`) or a prefix (`vec_fmt_number`).

## Capabilities

### Modified requirement in `formatting`
- Value functions

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
