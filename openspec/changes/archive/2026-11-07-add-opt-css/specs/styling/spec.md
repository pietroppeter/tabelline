## ADDED Requirements

### Requirement: Extra CSS
`optCss(css, add = true)` SHALL add CSS for the table, every rule scoped to it (rules that start
with `#` are left as they are); `add = false` SHALL replace what was given before.

```nim
let t = tabella(tavolaPitagorica(2), id = "tp").optCss(".tb_title { color: red; }")
echo "#tp .tb_title { color: red; }" in t.toHtml
```

```text
true
```
