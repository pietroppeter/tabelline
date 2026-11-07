## Why

Moving a column to the end is common; swapping two in place is not possible with moves alone. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `cols_move_to_end()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #10.

## What Changes

- `colsMoveToEnd` and `colsReorder`.

## Differences from gt and Great Tables

- gt and Great Tables have no `cols_reorder`; here it sorts the given columns in place.

## Capabilities

### New requirement in `table-parts`
- Moving columns

## Impact

`src/tabelline/` (verbs.nim), the spec `table-parts`, the coverage map.
