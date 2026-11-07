## ADDED Requirements

### Requirement: Booleans
`fmtTf(columns, rows, tfStyle, trueText, falseText, naText, colors, html)` SHALL show booleans in
a named style (`tfStyles`: `"true-false"`, `"yes-no"`, `"up-down"`, `"check-mark"`, `"circles"`,
`"squares"`, `"diamonds"`, `"arrows"`, `"triangles"`, `"triangles-lr"`) or as two texts of your
own, with `naText` for missing values and `colors` for true and false in HTML. With `html = true`
the texts SHALL be HTML (an SVG symbol, say), not escaped.

```nim
let d = tableData:
  rings: [false, true, nil]
echo tabella(d).fmtTf("rings", tfStyle = "circles", naText = "?")
let t = tabella(d).fmtTf("rings", trueText = "<b>yes</b>", falseText = "no", html = true, colors = ["green", "gray"])
echo "<span style=\"color: green\"><b>yes</b></span>" in t.toHtml
```

```text
┌───────┐
│ rings │
╞═══════╡
│ ○     │
│ ●     │
│ ?     │
└───────┘
true
```
