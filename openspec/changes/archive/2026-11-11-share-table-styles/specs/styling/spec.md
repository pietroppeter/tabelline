## MODIFIED Requirements

### Requirement: Options and presets
`TabOptions` SHALL hold the table-wide looks with defaults, and `tabOptions(name = value, ...)`
SHALL set any of them by name, checked when compiling. `optRowStriping`, `optAlignTableHeader`,
`optAllCaps`, `optTableFont`, `optStylize(style, color)` and `optCssTheme()` SHALL be presets.
`optCssTheme()` SHALL take every colour, and the font, from CSS variables of the page: `--ink`
(text, the rules above and below and under the column labels), `--paper` (behind the table),
`--line` (rules between rows), `--shade` (row groups and stripes), `--primary` (the rule under
the heading) and `--font`. Without them, `--ink`
SHALL fall back to `#1C1C1C` and `--paper` to `#FFFFFF`; `--line` and `--shade` SHALL be the ink
mixed into the paper (14% and 4%), and `--primary` the ink.
Each argument of `optCssTheme(ink, paper, line, shade, primary, font)` SHALL name the
variable to read when it starts with `--`, and SHALL be the CSS value itself otherwise.
`cssTheme(...)` SHALL make a `CssTheme` with the same arguments, which `optCssTheme(theme)` takes.
On a heading or column labels background that light text reads better on, the text SHALL be
white.

```nim
let t = tabella(planets()).tabOptions(rowStriping = true, headingAlign = "left")
echo t.options.rowStriping, " ", t.options.headingAlign, " ", t.options.tableFontSize
let s = tabella(planets()).tabHeader("Planets").optStylize(2, "red")
echo "--tb-heading-background-color: #8A1C1C" in s.toHtml and "--tb-heading-color: #FFFFFF" in s.toHtml
let o = tabella(planets()).optCssTheme().options
echo o.tableFontColor
echo o.tableBodyHlinesColor
let mine = tabella(planets()).optCssTheme(ink = "--foreground", primary = "#D64545").options
echo mine.tableFontColor, " ", mine.headingBorderBottomColor
```

```text
true left 16px
true
var(--ink, #1C1C1C)
var(--line, color-mix(in oklab, var(--ink, #1C1C1C) 14%, var(--paper, #FFFFFF)))
var(--foreground, #1C1C1C) #D64545
```

#### Scenario: A preset on a table
- **WHEN** a preset such as `optStylize(2, "red")` is applied
- **THEN** the table sets the options it changes as variables on its `<div>`, and white text on the dark heading

### Requirement: More options
`TabOptions` SHALL also hold gt's options for the container (`containerWidth`, `containerHeight`,
`containerOverflowY`, `containerPaddingX`, `containerPaddingY`), the table (`tableLayout`,
`tableFontWeight`, `tableFontStyle`), and the style, width and colour of the rules of the
heading, the column labels (top, bottom, sides, between labels), the row groups (top, bottom,
sides, with their size, padding and text transform), the body (lines between rows and columns,
top and bottom), the stub (with its size and text transform), the footnotes and the source notes
(with their background and padding). Their defaults SHALL draw the table as before.

```nim
let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp"]
  tabOptions(rowGroupBorderTopStyle = "dashed", stubBorderWidth = "1px", tableBodyHlinesStyle = "dotted")
echo styleVars(t.options).split("; ").join("\n")
```

```text
--tb-row-group-border-top-style: dashed
--tb-table-body-hlines-style: dotted
--tb-stub-border-width: 1px
```

#### Scenario: Defaults draw the table as before
- **WHEN** a table leaves an option at its default
- **THEN** the table sets no variable for it, and the stylesheet's fallback draws it as before
