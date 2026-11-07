## ADDED Requirements

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
