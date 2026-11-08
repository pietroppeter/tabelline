## MODIFIED Requirements

### Requirement: Other formats
`fmtDate` SHALL format ISO dates in a named style or a std/times pattern; `fmtTf` SHALL show
booleans as two texts; `fmtMarkdown` SHALL read cells as inline Markdown; `fmt(columns, proc)`
SHALL take any proc from a `Value` to a string.

```nim
let d = tableData:
  day: ["2026-11-07", "2015-01-15"]
  ok: [true, false]
  stars: [3, 1]
echo tabella(d).fmtDate("day", dateStyle = "day_month_year").fmtTf("ok", trueText = "yes", falseText = "no")
  .fmt("stars", proc (v: Value): string = "*".repeat(v.i))
```

```text
┌─────────────────┬─────┬───────┐
│ day             │ ok  │ stars │
╞═════════════════╪═════╪═══════╡
│ 7 November 2026 │ yes │   *** │
│ 15 January 2015 │ no  │     * │
└─────────────────┴─────┴───────┘
```
