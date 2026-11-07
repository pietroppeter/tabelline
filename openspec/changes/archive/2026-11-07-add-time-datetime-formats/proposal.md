## Why

Dates are done; times and datetimes use the same machinery. One of the 24 small groups of gt marked for 0.1 in the coverage map
(`docs/coverage/gt.json`, gt: `fmt_time(), fmt_datetime()`), approved by Pietro on 7 Nov 2026 in the thread "Build
tabelline 0.1"; built in PR #10.

## What Changes

- `fmtTime`, `fmtDatetime`, `formatTime`, `formatDatetime`, `timeStyles`.

## Differences from gt and Great Tables

- Styles are named, not numbered (gt also takes numbers 1 to 25).
- No time zones: the text after the time (`Z`, `+01:00`) is ignored.

## Capabilities

### New requirement in `formatting`
- Times and datetimes

## Impact

`src/tabelline/` (formats.nim), the spec `formatting`, the coverage map.
