## Why

The `extraCss` option had no verb. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `opt_css()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `optCss`, as gt's `opt_css`.

## Differences from gt and Great Tables

- gt asks for the table id to be in the CSS; tabelline scopes each rule itself.

## Capabilities

### New requirement in `styling`
- Extra CSS

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `styling`, the coverage map.
