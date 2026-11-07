## Why

A caption is how a table is named in a document and how screen readers announce it. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `tab_caption()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `tabCaption(text)` (plain, `md()` or `html()`), rendered by the three renderers.

## Differences from gt and Great Tables

- None in names; Great Tables keeps the caption for Quarto, tabelline renders it everywhere.

## Capabilities

### New requirement in `table-parts`
- Caption

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `table-parts`, the coverage map.
