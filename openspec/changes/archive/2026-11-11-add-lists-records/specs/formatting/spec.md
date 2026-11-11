## ADDED Requirements

### Requirement: Formats on lists and records
A format SHALL apply to a list item by item and to a record field by field, keeping the
separators of `$` ("1.2, 1.6", "lo: 0.8, hi: 1.6"); an item that the format does not take
SHALL be shown as it is. `fmtIcon`, `fmtImage` and `fmtFlag` SHALL take a list of names as
they take names separated by commas.

```nim
let d = tableData:
  sensor: ["north", "south"]
  readings: [@[1.24, 1.56], @[12.71]]
  span: [(lo: 0.82, hi: 1.56), (lo: 9.13, hi: 12.71)]
let t = tabella(d, rownameCol = "sensor"):
  fmtNumber ["readings", "span"], decimals = 1
echo t
```

```text
┌───────┬──────────┬───────────────────┐
│       │ readings │ span              │
╞═══════╪══════════╪═══════════════════╡
│ north │ 1.2, 1.6 │ lo: 0.8, hi: 1.6  │
│ south │ 12.7     │ lo: 9.1, hi: 12.7 │
└───────┴──────────┴───────────────────┘
```

### Requirement: Nanoplots of lists and of x and y
`fmtNanoplot` SHALL read a list of numbers as the values of a cell, and a record as its field
`y`, with its field `x` (as many) the places of the values on the x axis of a line plot, in the
order of `x`; a bar or box plot SHALL leave `x` out. With `autoscale` the rows SHALL share the x
axis too, and `expandX` SHALL widen it. A record without `y`, or with an `x` of another length,
SHALL raise `ValueError` when the verb is called. In text output the sparkline SHALL follow the
order of `x`.

```nim
let d = tableData:
  runner: ["Anna", "Bruno"]
  laps: [(x: @[0.0, 1, 2, 5], y: @[62.0, 60, 61, 58]), (x: @[0.0, 3, 4, 5], y: @[65.0, 63, 66, 59])]
  kit: [@["person-running", "stopwatch"], @["person-biking"]]
let t = tabella(d, rownameCol = "runner"):
  fmtNanoplot "laps", autoscale = true
  fmtIcon "kit"
echo t
echo nanoplotXValues(d["laps", 1]), " ", t.toHtml.count("class=\"tb_nanoplot\"")
```

```text
┌───────┬────────────┬───────────────────────────┐
│       │ laps       │ kit                       │
╞═══════╪════════════╪═══════════════════════════╡
│ Anna  │ ▅▃▄▁ 58–62 │ person-running, stopwatch │
│ Bruno │ ▇▅█▂ 59–66 │ person-biking             │
└───────┴────────────┴───────────────────────────┘
@[0.0, 3.0, 4.0, 5.0] 2
```
