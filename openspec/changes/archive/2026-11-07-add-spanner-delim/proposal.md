## Why

Wide tables often come with names like `size.mass` (from a pivot, a join or a CSV export). One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `tab_spanner_delim()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `tabSpannerDelim` makes spanners and labels from such names, on several levels.

## Differences from gt and Great Tables

- Great Tables has no `tab_spanner_delim`; this follows gt.
- gt's `split` and `limit` are kept; `reverse` is gt's `reverse`.

## Capabilities

### New requirement in `table-parts`
- Spanners from column names

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `table-parts`, the coverage map.
