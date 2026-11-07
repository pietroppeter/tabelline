## ADDED Requirements

### Requirement: Caption
`tabCaption(caption)` SHALL give the table a caption: an HTML `<caption>` above the table (for
screen readers, and for figures in documents), a first line in text, an italic line in Markdown.
`rmCaption()` SHALL take it away.

```nim
let t = tabella(tavolaPitagorica(2)).tabCaption("Table 1: the times table of 2")
echo "<caption class=\"tb_caption\">Table 1: the times table of 2</caption>" in t.toHtml
echo t
```

```text
true
Table 1: the times table of 2
┌───┬───┬───┐
│ × │ 1 │ 2 │
╞═══╪═══╪═══╡
│ 1 │ 1 │ 2 │
│ 2 │ 2 │ 4 │
└───┴───┴───┘
```
