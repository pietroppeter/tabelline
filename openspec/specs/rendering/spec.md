# rendering Specification

## Purpose
How a table spec becomes output: one build step (formats, substitutions, display order, footnote
marks, styles) shared by an HTML, a text and a Markdown renderer.

## Requirements

### Requirement: HTML with scoped CSS
`toHtml` SHALL render a `<div>` with an id, holding a `<style>` whose rules are all prefixed with
that id and a `<table class="tb_table">`: the heading and column labels in `<thead>`, groups, stub
and body in `<tbody>`, footnotes then source notes in one `<tfoot>`. Without an explicit `id`,
the id SHALL come from a hash of the table, so the same table always renders the same HTML.
`toHtml(makePage = true)` SHALL return a standalone page holding the table, titled after it,
and `save(path)` SHALL write that page to a file.

```nim
let t = tabella(planets(), id = "planets").tabHeader("Planets")
let h = t.toHtml
echo h.startsWith("<div id=\"planets\""), " ", "#planets .tb_table" in h, " ", h == t.toHtml
let page = t.toHtml(makePage = true)
echo page.startsWith("<!doctype html>"), " ", "<title>Planets</title>" in page, " ", h in page
```

```text
true true true
true true true
```

#### Scenario: A whole page
- **WHEN** `toHtml(makePage = true)` is called, or `save("x.html")`
- **THEN** the result is a whole HTML page with the table's fragment in its body

#### Scenario: Two tables on a page
- **WHEN** a page holds two tables with different options
- **THEN** each table's CSS applies only to it

### Requirement: Text
`toText` (and `$`, so `echo t`) SHALL draw the table with box characters: title and subtitle
centred above, spanners and column labels, group labels as rows, the formatted cells aligned as
in HTML, and the footnotes and source notes below.

```nim
echo tabella(tavolaPitagorica(3), rownameCol = "×").tabHeader("Tabellina").tabFootnote("by heart", loc.title())
```

```text
   Tabellina^1
┌───┬───┬───┬───┐
│   │ 1 │ 2 │ 3 │
╞═══╪═══╪═══╪═══╡
│ 1 │ 1 │ 2 │ 3 │
│ 2 │ 2 │ 4 │ 6 │
│ 3 │ 3 │ 6 │ 9 │
└───┴───┴───┴───┘
1 by heart
```

### Requirement: Markdown
`toMarkdown` SHALL write a GitHub pipe table, with the title in bold above, group labels as bold
rows, and the notes below.

```nim
echo tabella(planets(), rownameCol = "planet").colsHide(["type", "mass", "diameter", "density",
  "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .tabHeader("Moons").toMarkdown
```

```text
**Moons**

|  | moons |
|:--|--:|
| Mercury | 0 |
| Venus | 0 |
| Earth | 1 |
| Mars | 2 |
| Jupiter | 95 |
| Saturn | 146 |
| Uranus | 28 |
| Neptune | 16 |
```

### Requirement: The built table as data
`extractCells(t, columns, rows, ctx)` SHALL give the shown text of the body cells of `columns`
and `rows`, in the order the table shows them; `extractBody(t, ctx)` SHALL give the body as a
`TableData` of texts (a `group` column when there are row groups, a `rowname` column when there
is a stub, then every visible column); `extractSummary(t, ctx)` SHALL give the summary rows as a
`TableData` of texts (`group`, "" for a grand summary row, `label`, and the visible columns).
`ctx = rcHtml` SHALL give HTML.

```nim
let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  colsHide ["diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "moons"]
  fmtNumber "mass", decimals = 1
  summaryRows fns = {"total": agg.sum}
echo extractCells(t, "mass", rows = [0, 1]).join(" | ")
echo tabella(extractSummary(t))
```

```text
0.3 | 4.9
┌─────────────┬───────┬─────────┐
│ group       │ label │ mass    │
╞═════════════╪═══════╪═════════╡
│ Terrestrial │ total │ 11.8    │
│ Gas giant   │ total │ 2,466.0 │
│ Ice giant   │ total │ 188.8   │
└─────────────┴───────┴─────────┘
```
