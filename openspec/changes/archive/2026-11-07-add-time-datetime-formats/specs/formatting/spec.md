## ADDED Requirements

### Requirement: Times and datetimes
`fmtTime(columns, rows, timeStyle)` SHALL show times ("14:35", "14:35:07", or the time part of an
ISO datetime) in a named style (`timeStyles`: `"iso"`, `"iso-short"`, `"h_m_s_p"`, `"h_m_p"`,
`"h_p"`, ...); `fmtDatetime(columns, rows, dateStyle, timeStyle, sep)` SHALL show ISO datetimes as
a date and a time, each in its style. Text that is not a time SHALL be left as it is.

```nim
let d = tableData:
  launch: ["1969-07-16T13:32:00", "2026-11-07 09:05", "soon"]
echo tabella(d).fmtDatetime("launch", dateStyle = "day_m_year", timeStyle = "h_m_p")
echo formatTime("14:35:07", "iso-short"), " ", formatTime("14:35", "h_p")
```

```text
┌─────────────────────┐
│ launch              │
╞═════════════════════╡
│ 16 Jul 1969 1:32 PM │
│ 7 Nov 2026 9:05 AM  │
│ soon                │
└─────────────────────┘
14:35 2 PM
```
