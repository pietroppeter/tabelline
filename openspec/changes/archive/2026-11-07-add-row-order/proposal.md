## Why

Groups showed in the order they were made, rows in the order of the data. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `row_order(), row_group_order()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #10.

## What Changes

- `rowOrder` and `rowGroupOrder`; the data is not changed, only the order rows are shown in.

## Differences from gt and Great Tables

- gt's `row_order()` takes expressions; here columns and `reverse`.

## Capabilities

### New requirement in `table-parts`
- Order of rows and groups

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `table-parts`, the coverage map.
