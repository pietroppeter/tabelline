## Why

The header, the column header and the footer as a whole were missing. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `cells_title(), cells_body(), cells_stub(), ...`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `loc.header`, `loc.columnHeader`, `loc.footer`, and `loc.spannerLabels` as an alias.

## Differences from gt and Great Tables

- Names follow Great Tables (`loc.header`, `loc.column_header`, `loc.footer`) in camelCase; gt's are `cells_title(groups = c(...))` and others.
- The summary locations come with summary rows (0.2).

## Capabilities

### Modified requirement in `styling`
- Styles at locations

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `styling`, the coverage map.
