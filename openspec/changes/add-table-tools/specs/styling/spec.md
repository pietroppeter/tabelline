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
