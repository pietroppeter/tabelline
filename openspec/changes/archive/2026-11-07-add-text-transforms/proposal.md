## Why

The last step before a cell is shown: upper case, a word replaced, a code turned into a label. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `text_transform(), text_replace(), text_case_match(), text_case_when()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- Three verbs over the shown text; gt's `text_case_when` is `textTransform` with a Nim `case`.

## Differences from gt and Great Tables

- Locations come last (Nim varargs), so the proc comes first.
- `textReplace` takes plain text, not a regex, so the core stays free of PCRE.
- No `textCaseWhen`: a proc with `if` or `case` does the same.

## Capabilities

### New requirement in `formatting`
- Text transforms

## Impact

`src/tabelline/` (formats.nim, build.nim and the renderers), the spec `formatting`, the coverage map.
