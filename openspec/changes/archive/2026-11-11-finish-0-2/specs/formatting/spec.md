## ADDED Requirements

### Requirement: Images anywhere
`localImage(file, height = "2em", alt = "")` SHALL give an `<img>` as `Text` (HTML), the file
read when called and inlined as a data URL, and `webImage(url, height = "2em", alt = "")` the
same with the address left as it is, as gt's `local_image()` and `web_image()`; they go in a
title, a label, a note, or a cell through `fmtMarkdown` or `html`. `alt` SHALL be by default the
file's name (the last part of the address), and text output SHALL show it.

```nim
let t = tabella(planets()):
  colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "moons", "rings", "diameter", "type"]
  rowsHide [1, 2, 3, 4, 5, 6, 7]
  tabHeader webImage("https://example.org/sun.png", alt = "☉"), "The first planet"
echo t
echo t.toHtml.count("<img src=\"https://example.org/sun.png\"")
```

```text
        ☉
 The first planet
┌─────────┬──────┐
│ planet  │ mass │
╞═════════╪══════╡
│ Mercury │ 0.33 │
└─────────┴──────┘
1
```

### Requirement: Named font stacks
`systemFonts(name = "system-ui")` SHALL give one of Great Tables' fifteen font stacks
(`fontStackNames`: "system-ui", "transitional", "old-style", "humanist", "geometric-humanist",
"classical-humanist", "neo-grotesque", "monospace-slab-serif", "monospace-code", "industrial",
"rounded-sans", "slab-serif", "antique", "didone", "handwritten") as CSS text, for
`optTableFont`; another name SHALL raise `ValueError`. `defaultFonts()` SHALL give gt's default
stack.

```nim
echo systemFonts("old-style")
echo fontStackNames.len
let t = tabella(planets()):
  optTableFont systemFonts("humanist")
echo t.options.tableFontNames.startsWith("'Seravek'")
```

```text
'Iowan Old Style', 'Palatino Linotype', 'URW Palladio L', 'P052', serif
15
true
```

### Requirement: Nanoplot options for each point
The options of `nanoplotOptions` for points and bars (`dataPointRadius`,
`dataPointStrokeColor`, `dataPointStrokeWidth`, `dataPointFillColor`, `dataBarStrokeColor`,
`dataBarStrokeWidth`, `dataBarFillColor`) SHALL take a list as well as one value: the n-th point
or bar takes the n-th value, and the list repeats. The `x` of a record SHALL also take ISO dates
and times ("2026-11-11", "2026-11-11 10:30"), placed by time.

```nim
let d = tableData:
  week: ["one", "two"]
  steps: [toValue(@[4, 8, 6]), toValue((x: @["2026-11-02", "2026-11-03", "2026-11-09"], y: @[5, 7, 9]))]
let t = tabella(d, rownameCol = "week"):
  fmtNanoplot "steps", options = nanoplotOptions(dataPointFillColor = @["#D64545", "#2E7D32"])
echo t
let x = nanoplotXValues(d["steps", 1])
echo t.toHtml.count("fill=\"#2E7D32\""), " green points; the last is ", (x[2] - x[0]) / 86400, " days after the first"
```

```text
┌─────┬─────────┐
│     │ steps   │
╞═════╪═════════╡
│ one │ ▁█▅ 4–8 │
│ two │ ▁▅█ 5–9 │
└─────┴─────────┘
2 green points; the last is 7.0 days after the first
```
