## Why

Lab and finance tables hide noise below a threshold, cap huge numbers, and mark sentinel values (−99). One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `sub_small_vals(), sub_large_vals(), sub_values()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- Three substitutions, applied after the formats as the others.

## Differences from gt and Great Tables

- `subValues` takes a list of values or a Nim proc; gt's `pattern` (a regex) is left out, so the core stays free of PCRE.
- Thresholds of 1000 and more are written short (`>=1T`).

## Capabilities

### New requirement in `formatting`
- Small, large and given values

## Impact

`src/tabelline/` (formats.nim, build.nim and the renderers), the spec `formatting`, the coverage map.
