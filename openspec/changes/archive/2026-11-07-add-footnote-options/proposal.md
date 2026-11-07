## Why

Marks were set by an option only, and the footer order was fixed. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `opt_footnote_marks(), opt_footnote_spec(), opt_footnote_order()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- Three verbs, the `extended` marks and custom marks.

## Differences from gt and Great Tables

- `optFootnoteMarks` takes gt's names or a Nim enum (`fmStandard`).
- The spec letters are gt's; the default is `"^"` (raised, upright), gt's is `"^i"`.

## Capabilities

### New requirement in `styling`
- Footnote marks, look and order

## Impact

`src/tabelline/` (verbs.nim, build.nim and the renderers), the spec `styling`, the coverage map.
