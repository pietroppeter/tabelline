## MODIFIED Requirements

### Requirement: Colour by value
`dataColor(columns, rows, palette, domain, reverse, naColor, autoColorText, apply)` SHALL colour
cells along a palette, each column on its own: a number column from the low to the high end of
`domain` (by default the range of that column's selected cells), any other column by category,
missing values with `naColor`. A `domain` given from high to low SHALL run the palette the other
way. With `autoColorText` the text SHALL be dark or light, whichever contrasts more with the
fill. `palette(name)` SHALL give named palettes (including `pastelli`, `quaderno`, `blues`,
`rdbu`, `viridis`) or split a comma-separated list of colours.

```nim
let d = tableData:
  small: [1, 2]
  large: [100, 200]
  word: ["a", "b"]
let t = tabella(d).dataColor(everything(), palette = @["#FFFFFF", "#000000"])
echo t.toHtml.count("background-color: #000000; color: #FFFFFF")
let r = tabella(d).dataColor("small", palette = @["#FFFFFF", "#000000"], domain = (2.0, 1.0))
echo "background-color: #000000; color: #FFFFFF" in r.toHtml
```

```text
3
true
```

### Requirement: Options and presets
`TabOptions` SHALL hold the table-wide looks with defaults, and `tabOptions(name = value, ...)`
SHALL set any of them by name, checked when compiling. `optRowStriping`, `optAlignTableHeader`,
`optAllCaps`, `optTableFont`, `optStylize(style, color)` and `optQuaderno()` SHALL be presets.
On a heading or column labels background that light text reads better on, the text SHALL be
white.

```nim
let t = tabella(planets()).tabOptions(rowStriping = true, headingAlign = "left")
echo t.options.rowStriping, " ", t.options.headingAlign, " ", t.options.tableFontSize
let s = tabella(planets()).tabHeader("Planets").optStylize(2, "red")
echo "background-color: #8A1C1C; text-align: center; color: #FFFFFF" in s.toHtml
```

```text
true left 16px
true
```
