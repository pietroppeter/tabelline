## Why

Compact tables, boxed tables and tables with no lines are one call in gt. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `opt_vertical_padding(), opt_horizontal_padding(), opt_table_outline(), opt_table_lines()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #10.

## What Changes

- Four presets over new and old options.

## Differences from gt and Great Tables

- None in names; the padding scale is a float (gt: 0 to 3).

## Capabilities

### New requirement in `styling`
- Padding, outline and lines

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `styling`, the coverage map.
