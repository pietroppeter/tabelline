## Why

Labels made from names (`snake_case` to Title Case, units appended) are one proc. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `cols_label_with()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `colsLabelWith(columns, fn)` and `colsLabelWith(fn)`.

## Differences from gt and Great Tables

- None.

## Capabilities

### New requirement in `table-parts`
- Labels from a proc

## Impact

`src/tabelline/` (verbs.nim), the spec `table-parts`, the coverage map.
