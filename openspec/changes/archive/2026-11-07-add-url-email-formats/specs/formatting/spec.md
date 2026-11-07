## ADDED Requirements

### Requirement: Links
`fmtUrl(columns, rows, label, asButton, color, target, showUnderline)` SHALL make links of
addresses, with the address as text unless `label` is given or the cell is a Markdown link
`[label](address)`; `fmtEmail` SHALL do the same with `mailto:` links. In text, the label SHALL be
shown.

```nim
let d = tableData:
  site: ["https://nim-lang.org", "[nimib](https://github.com/pietroppeter/nimib)"]
let t = tabella(d).fmtUrl("site")
echo t
echo "<a href=\"https://github.com/pietroppeter/nimib\">nimib</a>" in t.toHtml
```

```text
┌──────────────────────┐
│ site                 │
╞══════════════════════╡
│ https://nim-lang.org │
│ nimib                │
└──────────────────────┘
true
```
