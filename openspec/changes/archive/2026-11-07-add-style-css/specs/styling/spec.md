## ADDED Requirements

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
