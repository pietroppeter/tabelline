## ADDED Requirements

### Requirement: Durations
`fmtDuration(columns, rows, inputUnits, outputUnits, durationStyle, trimZeroUnits, maxOutputUnits)`
SHALL show numbers as lengths of time in weeks, days, hours, minutes and seconds, in the styles
`"narrow"` (2h 5m), `"wide"` (2 hours 5 minutes), `"colon-sep"` (02:05:03) and `"iso"` (PT2H5M).
The smallest output unit SHALL be rounded.

```nim
let d = tableData:
  secs: [7503.0, 90061.0, 45.0]
echo tabella(d).fmtDuration("secs")
echo tabella(d).fmtDuration("secs", durationStyle = "colon-sep")
echo formatDuration(1.5, inputUnits = "days", durationStyle = "wide")
```

```text
┌─────────────┐
│        secs │
╞═════════════╡
│    2h 5m 3s │
│ 1d 1h 1m 1s │
│         45s │
└─────────────┘
┌──────────┐
│     secs │
╞══════════╡
│ 02:05:03 │
│ 25:01:01 │
│ 00:00:45 │
└──────────┘
1 day 12 hours
```
