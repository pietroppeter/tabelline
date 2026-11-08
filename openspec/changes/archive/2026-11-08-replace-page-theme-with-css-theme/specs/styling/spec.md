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
echo "background-color: #8A1C1C; text-align: center; color: #FFFFFF" in s.toHtml
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
