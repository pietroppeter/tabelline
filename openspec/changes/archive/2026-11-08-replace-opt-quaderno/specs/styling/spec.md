## MODIFIED Requirements

### Requirement: Options and presets
`TabOptions` SHALL hold the table-wide looks with defaults, and `tabOptions(name = value, ...)`
SHALL set any of them by name, checked when compiling. `optRowStriping`, `optAlignTableHeader`,
`optAllCaps`, `optTableFont`, `optStylize(style, color)` and `optTokens()` SHALL be presets.
`optTokens()` SHALL take every colour from CSS variables of the page, each with a fallback.
On a heading or column labels background that light text reads better on, the text SHALL be
white.

```nim
let t = tabella(planets()).tabOptions(rowStriping = true, headingAlign = "left")
echo t.options.rowStriping, " ", t.options.headingAlign, " ", t.options.tableFontSize
let s = tabella(planets()).tabHeader("Planets").optStylize(2, "red")
echo "background-color: #8A1C1C; text-align: center; color: #FFFFFF" in s.toHtml
echo tabella(planets()).optTokens().options.tableBorderTopColor
```

```text
true left 16px
true
var(--n-9, #1C1C1C)
```
