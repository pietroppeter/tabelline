## ADDED Requirements

### Requirement: Text helpers
Labels and notes SHALL be plain text (escaped in HTML), `md(text)` (inline Markdown: `**bold**`,
`*italic*`, `` `code` ``, links, `^sup^`, `~sub~`) or `html(text)` (used as is in HTML, its tags
stripped in text and Markdown).

```nim
let t = tabella(tavolaPitagorica(2))
  .tabHeader(md("The **times** table"), html("of <span style=\"color: red\">two</span>"))
echo "<strong>times</strong>" in t.toHtml, " ", "<span style=\"color: red\">two</span>" in t.toHtml
echo t
```

```text
true true
The times table
   of two
┌───┬───┬───┐
│ × │ 1 │ 2 │
╞═══╪═══╪═══╡
│ 1 │ 1 │ 2 │
│ 2 │ 2 │ 4 │
└───┴───┴───┘
```
