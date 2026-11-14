## MODIFIED Requirements

### Requirement: Options and presets
`TabOptions` SHALL hold the table-wide looks with defaults, and `tabOptions(name = value, ...)`
SHALL set any of them by name, checked when compiling. `optRowStriping`, `optAlignTableHeader`,
`optAllCaps`, `optTableFont`, `optStylize(style, color)` and `optCssTheme()` SHALL be presets.
`optStylize(style, color, addRowStriping)` SHALL draw gt's and Great Tables' six styles (1 to
6) in their six colours (blue, cyan, pink, green, red, gray), with the same values for the
lines, fills and stripes, and the light outline of styles 2, 4 and 5; any other style or colour
SHALL raise `ValueError`. `optAllCaps(on, locations)` SHALL put the column labels, the stub and
the row group labels in small capitals, or only the `locations` named (`"column_labels"`,
`"stub"`, `"row_group"`).
`optCssTheme()` SHALL take every colour, and the font, from CSS variables of the page: `--ink`
(text, the rules above and below and under the column labels), `--paper` (behind the table),
`--line` (rules between rows), `--shade` (row groups and stripes), `--primary` (the rule under
the heading) and `--font`. Without them, `--ink`
SHALL fall back to `#1C1C1C` and `--paper` to `#FFFFFF`; `--line` and `--shade` SHALL be the ink
mixed into the paper (14% and 4%), and `--primary` the ink.
Each argument of `optCssTheme(ink, paper, line, shade, primary, font)` SHALL name the
variable to read when it starts with `--`, and SHALL be the CSS value itself otherwise.
`cssTheme(...)` SHALL make a `CssTheme` with the same arguments, which `optCssTheme(theme)` takes.
On a background of the heading, the column labels, the stub, the row groups or the summary rows
that light text reads better on, the text SHALL be white.

```nim
let t = tabella(planets()):
  tabOptions:
    rowStriping = true
    headingAlign = "left"
echo t.options.rowStriping, " ", t.options.headingAlign, " ", t.options.tableFontSize
let s = tabella(planets(), rownameCol = "planet"):
  optStylize 1, "red"
echo s.options.stubBackgroundColor, " ", "--tb-stub-color: #FFFFFF" in s.toHtml
let caps = tabella(planets()):
  optAllCaps locations = ["stub"]
echo caps.options.stubTextTransform, " ", caps.options.columnLabelsTextTransform
let themed = tabella(planets()):
  optCssTheme()
let o = themed.options
echo o.tableFontColor
echo o.tableBodyHlinesColor
let mine = tabella(planets()):
  optCssTheme ink = "--foreground", primary = "#D64545"
echo mine.options.tableFontColor, " ", mine.options.headingBorderBottomColor
```

```text
true left 16px
#E4220C true
uppercase inherit
var(--ink, #1C1C1C)
var(--line, color-mix(in oklab, var(--ink, #1C1C1C) 14%, var(--paper, #FFFFFF)))
var(--foreground, #1C1C1C) #D64545
```

#### Scenario: A preset on a table
- **WHEN** a preset such as `optStylize(2, "red")` is applied
- **THEN** the table sets the options it changes as variables on its `<div>`, and white text on the dark column labels

## ADDED Requirements

### Requirement: The arguments of gt's styles
`style.text` SHALL take `vAlign` (`vertical-align`) and `indent` (`text-indent`), and
`style.fill(color, alpha)` an opacity from 0 to 1, as gt's `cell_text(v_align, indent)` and
`cell_fill(alpha)`. A colour SHALL also be one of R's colour names that CSS does not have
(`sienna4`, `grey50`: 518 more, as gt and Great Tables take them), written as its hex value in
the HTML; `palette("great-tables")` SHALL be Great Tables' default palette for `dataColor`.

```nim
echo style.text(vAlign = "top", indent = "2em").css
echo style.fill("red", alpha = 0.5).css, " ", style.fill("sienna4").css
echo rColor("grey50"), " ", palette("great-tables").len
```

```text
@[("vertical-align", "top"), ("text-indent", "2em")]
@[("background-color", "rgba(255, 0, 0, 0.5)")] @[("background-color", "#8B4726")]
#7F7F7F 8
```

### Requirement: Locations by label, by the rows of a group, and by cell
`loc.stub(rows, labels)` SHALL take the rows whose stub reads one of `labels`, with the `rows`
given, as Great Tables' `loc.stub(["apricot", 2])`. `loc.rowGroups(rows = ...)` SHALL take the
groups of these rows (by index or by `where`). `loc.body(cols, rows, mask)` SHALL take only the
cells that pass `mask`, a proc of the cell's value, or of its value and its column, as Great
Tables' `loc.body(mask = ...)`. A fill on a spanner SHALL fill its whole cell. `dataColor` SHALL
leave the stub's columns alone, as Great Tables does.

```nim
let t = tabella(planets(), rownameCol = "planet"):
  tabStyle style.fill("#FFF3B0"), loc.stub(labels = ["Venus"])
  tabStyle style.fill("#DDEEFF"), loc.body(cols = "moons", mask = proc (v: Value): bool = v > 20)
  tabStyle style.fill("#EEDDFF"),
    loc.body(cols = ["mass", "moons"], mask = proc (v: Value, col: Column): bool = v == agg.max.fn(col.values))
let h = t.toHtml
echo h.count("#FFF3B0"), " ", h.count("#DDEEFF"), " ", h.count("#EEDDFF")
```

```text
1 3 2
```
