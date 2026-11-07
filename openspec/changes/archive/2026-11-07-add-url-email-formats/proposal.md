## Why

Tables of projects, people and sources need links in cells. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_url(), fmt_email()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #9.

## What Changes

- `fmtUrl`, `fmtEmail`.

## Differences from gt and Great Tables

- gt's `button_fill`, `button_width` and `button_outline` are one `color` here.

## Capabilities

### New requirement in `formatting`
- Links

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
