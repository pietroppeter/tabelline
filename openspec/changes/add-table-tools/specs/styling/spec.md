## ADDED Requirements

### Requirement: Styles from the data
A style value MAY be `fromColumn(column, naValue)`: each body or stub cell SHALL take it from
`column` of its own row (a missing value is `naValue`, and "" leaves the property out).
`tabStyle(proc (r: Row): CellStyle, locations)` SHALL style each body or stub cell with the style
its row gives. `tabStyleBody(style, columns, rows, values, pattern, fn, targets)` SHALL style the
body cells whose value is one of `values`, contains `pattern` or makes `fn` true, or their whole
row (`targets = "row"`) or column (`"column"`).

```nim
let d = tableData:
  name: ["Mercury", "Earth", "Mars"]
  colour: ["#b1adad", "#4f7cac", nil]
let t = tabella(d):
  tabStyle style.fill(fromColumn("colour", naValue = "#eee")), loc.body("name")
  tabStyleBody style.text(weight = "bold"), values = ["Earth"], targets = "row"
let html = t.toHtml
echo html.count("background-color: #4f7cac"), " ", html.count("background-color: #eee"), " ", html.count("font-weight: bold")
```

```text
1 1 2
```

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
let css = t.toHtml
echo "2px dashed" in css, " ", "1px solid #D3D3D3" in css, " ", "1px dotted" in css
```

```text
true true true
```
