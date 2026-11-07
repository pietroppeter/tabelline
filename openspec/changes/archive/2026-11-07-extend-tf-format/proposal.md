## Why

`fmtTf` had two texts only; gt's styles and an HTML option were in BACKLOG.md (Isotype-style tables in diagrammari's series needed them). One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_tf()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- Named styles, `naText`, `colors`, `html`.

## Differences from gt and Great Tables

- The default is `"check-mark"` (✓ ✗), as before in tabelline; gt's default is `"true-false"`.
- `html` is new: gt does it with `true_val = html(...)`.

## Capabilities

### New requirement in `formatting`
- Booleans

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
