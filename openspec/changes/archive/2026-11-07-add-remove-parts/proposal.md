## Why

Tables made from one shared start (a house style, a template) need to drop parts as well as add them. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `rm_header(), rm_spanners(), rm_footnotes(), rm_source_notes(), rm_stubhead(), rm_caption()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- The `rm*` verbs of gt.

## Differences from gt and Great Tables

- Indices are 0-based, as everywhere in Nim (gt counts from 1).
- `rmSpanners` takes labels (gt takes spanner ids, which tabelline does not have) or levels.

## Capabilities

### New requirement in `table-parts`
- Removing parts

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `table-parts`, the coverage map.
