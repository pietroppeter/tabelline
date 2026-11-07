## Why

`style.fill`, `style.text` and `style.borders` do not cover every CSS property. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `style.css()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `style.css`, as in Great Tables.

## Differences from gt and Great Tables

- Great Tables' `style.css(rule)`; gt has no equivalent.

## Capabilities

### New requirement in `styling`
- Any CSS

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `styling`, the coverage map.
