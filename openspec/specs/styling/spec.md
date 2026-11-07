# styling Specification

## Purpose
How a table looks: styles on locations, colours by value, and table-wide options with presets.

## Requirements

### Requirement: Styles at locations
`tabStyle(style, locations)` SHALL add CSS to the cells at each location. Styles SHALL be built
with `style.fill(color)`, `style.text(...)` and `style.borders(...)` and joined with `&`.
Locations SHALL be `loc.title()`, `loc.subtitle()`, `loc.stubhead()`, `loc.columnLabels(cols)`,
`loc.spanners(labels)`, `loc.stub(rows)`, `loc.rowGroups(groups)`, `loc.body(cols, rows)`,
`loc.footnotes()` and `loc.sourceNotes()`, as in Great Tables; `loc.body` SHALL target the data
cells only, not the stub (that is `loc.stub`). A later style SHALL win over an
earlier one for the same property.

```nim
let t = tabella(tavolaPitagorica(3), rownameCol = "×")
  .tabStyle(style.fill("#FFF3B0") & style.text(weight = "bold"), loc.body(cols = "2", rows = [1]))
echo "background-color: #FFF3B0; font-weight: bold" in t.toHtml
```

```text
true
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
