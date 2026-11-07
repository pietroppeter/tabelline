# styling Specification

## Purpose
How a table looks: styles on locations, colours by value, and table-wide options with presets.

## Requirements

### Requirement: Styles at locations
`tabStyle(style, locations)` SHALL add CSS to the cells at each location. Styles SHALL be built
with `style.fill(color)`, `style.text(...)`, `style.borders(...)` and `style.css(...)` and joined
with `&`. Locations SHALL be `loc.header()` (title and subtitle), `loc.title()`, `loc.subtitle()`,
`loc.columnHeader()` (stub head, spanners and column labels), `loc.stubhead()`,
`loc.columnLabels(cols)`, `loc.spanners(labels)` (also `loc.spannerLabels`), `loc.stub(rows)`,
`loc.rowGroups(groups)`, `loc.body(cols, rows)`, `loc.footer()` (footnotes and source notes),
`loc.footnotes()` and `loc.sourceNotes()`, as in Great Tables; `loc.body` SHALL target the data
cells only, not the stub (that is `loc.stub`). A later style SHALL win over an earlier one for the
same property, but a style at one part SHALL win over a style at a whole part that holds it
(header, column header, footer), as in Great Tables. A footnote at a whole part SHALL be marked on
its first element.

```nim
let t = tabella(tavolaPitagorica(3), rownameCol = "×")
  .tabStyle(style.fill("#FFF3B0") & style.text(weight = "bold"), loc.body(cols = "2", rows = [1]))
  .tabStyle(style.text(color = "#1F4E99"), loc.columnHeader())
echo "background-color: #FFF3B0; font-weight: bold" in t.toHtml
echo t.toHtml.count("color: #1F4E99")
```

```text
true
4
```

### Requirement: Colour by value
`dataColor(columns, rows, palette, domain, reverse, naColor, autoColorText, apply)` SHALL colour
cells along a palette: numbers from the low to the high end of `domain` (by default the range of
the selected cells), text by category, missing values with `naColor`. With `autoColorText` the
text SHALL be dark or light, whichever contrasts more with the fill. `palette(name)` SHALL give
named palettes (including `pastelli`, `quaderno`, `blues`, `rdbu`, `viridis`) or split a
comma-separated list of colours.

```nim
let t = tabella(tavolaPitagorica(2)).dataColor(everything(), palette = @["#FFFFFF", "#000000"])
echo "background-color: #000000; color: #FFFFFF" in t.toHtml
```

```text
true
```

### Requirement: Options and presets
`TabOptions` SHALL hold the table-wide looks with defaults, and `tabOptions(name = value, ...)`
SHALL set any of them by name, checked when compiling. `optRowStriping`, `optAlignTableHeader`,
`optAllCaps`, `optTableFont`, `optStylize(style, color)` and `optQuaderno()` SHALL be presets.

```nim
let t = tabella(planets()).tabOptions(rowStriping = true, headingAlign = "left")
echo t.options.rowStriping, " ", t.options.headingAlign, " ", t.options.tableFontSize
```

```text
true left 16px
```

### Requirement: Any CSS
`style.css(declarations)` SHALL make a style from any CSS declarations (`"letter-spacing: 0.1em;
font-variant: small-caps"`), joinable with the other styles.

```nim
let t = tabella(tavolaPitagorica(2)).tabStyle(style.css("font-variant: small-caps; letter-spacing: 1px"), loc.columnLabels())
echo "font-variant: small-caps; letter-spacing: 1px" in t.toHtml
```

```text
true
```

### Requirement: Padding, outline and lines
`optVerticalPadding(scale)` and `optHorizontalPadding(scale)` SHALL scale the padding of the
heading, the column labels and the rows; `optTableOutline(style, width, color)` SHALL draw a line
all around the table; `optTableLines(extent)` SHALL add vertical lines (`"all"`), take every line
away (`"none"`) or bring back the defaults (`"default"`). New options SHALL hold what they set
(`dataRowPaddingHorizontal`, `tableBorderLeftStyle`, `tableBodyVlinesColor`, ...).

```nim
let t = tabella(tavolaPitagorica(2)).optVerticalPadding(0.5).optTableOutline(color = "#333333")
echo t.options.dataRowPadding, " ", t.options.tableBorderLeftStyle, " ", t.options.tableBorderLeftColor
echo tabella(tavolaPitagorica(2)).optTableLines("none").options.tableBodyHlinesColor
```

```text
4px solid #333333
transparent
```

### Requirement: Footnote marks, look and order
`optFootnoteMarks(marks)` SHALL set the marks: `"numbers"`, `"letters"`, `"LETTERS"`, `"standard"`
(\*, †, ‡, §), `"extended"` (with ‖, ¶) or a list of your own, repeated (\*\*) when they run out.
`optFootnoteSpec(specRef, specFtr)` SHALL set how marks look in the table and in the footer (`^`
raised, `i` italic, `b` bold, `(` or `[` around). `optFootnoteOrder(order)` SHALL put marked notes
first (`"marks_first"`, the default), last (`"marks_last"`), or keep the order notes were added in
(`"preserve_order"`, which numbers the marks in that order too).

```nim
echo tabella(tavolaPitagorica(2), rownameCol = "×")
  .tabFootnote("A note with no mark.")
  .tabFootnote("Two twos.", loc.body(cols = "2", rows = [1]))
  .tabFootnote("The first row.", loc.stub(rows = [0]))
  .optFootnoteMarks("standard").optFootnoteSpec("^", "(").optFootnoteOrder("marks_last")
```

```text
┌─────┬───┬─────┐
│     │ 1 │   2 │
╞═════╪═══╪═════╡
│ 1^* │ 1 │   2 │
│ 2   │ 2 │ 4^† │
└─────┴───┴─────┘
A note with no mark.
(*) The first row.
(†) Two twos.
```

#### Scenario: More notes than marks
- **WHEN** a table has five notes and the standard marks
- **THEN** the fifth is marked \*\*

### Requirement: Extra CSS
`optCss(css, add = true)` SHALL add CSS for the table, every rule scoped to it (rules that start
with `#` are left as they are); `add = false` SHALL replace what was given before.

```nim
let t = tabella(tavolaPitagorica(2), id = "tp").optCss(".tb_title { color: red; }")
echo "#tp .tb_title { color: red; }" in t.toHtml
```

```text
true
```
