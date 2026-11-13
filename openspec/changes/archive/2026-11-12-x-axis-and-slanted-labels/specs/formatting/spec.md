## ADDED Requirements

### Requirement: Vertical reference lines
`fmtNanoplot` SHALL take `referenceX`, a list of places on the x axis (numbers, or ISO dates
such as "2020-03-11"), and in a line plot of records of `x` and `y` SHALL draw a dashed vertical
line at each place inside the axis, its text shown on hover. A place outside the axis SHALL
draw nothing; a place that is neither a number nor a date SHALL raise `ValueError` when the verb
is called. Text output SHALL be unchanged.

```nim
let d = tableData:
  airport: ["north", "south"]
  flights: [(x: @["2018-07-01", "2019-07-01", "2020-07-01", "2021-07-01"], y: @[6.8, 7.3, 1.8, 2.7]),
            (x: @["2019-07-01", "2020-07-01", "2021-07-01"], y: @[3.4, 1.0, 1.9])]
let t = tabella(d, rownameCol = "airport"):
  fmtNanoplot "flights", autoscale = true, referenceX = @["2020-03-11"]
echo t
echo t.toHtml.count("2020-03-11"), " lines"
```

```text
┌───────┬────────────────┐
│       │ flights        │
╞═══════╪════════════════╡
│ north │ ▇█▂▃ 1.80–7.30 │
│ south │ ▄▁▂ 1.00–3.40  │
└───────┴────────────────┘
2 lines
```

## MODIFIED Requirements

### Requirement: Nanoplots of lists and of x and y
`fmtNanoplot` SHALL read a list of numbers as the values of a cell, and a record as its field
`y`, with its field `x` (as many) the places of the values on the x axis of a line plot, in the
order of `x`; a bar or box plot SHALL leave `x` out. With `autoscale` the rows SHALL share the x
axis too, and `expandX` SHALL widen it; on a shared x axis every row's plot SHALL have the same
width, so the axes line up. A record without `y`, or with an `x` of another length,
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

