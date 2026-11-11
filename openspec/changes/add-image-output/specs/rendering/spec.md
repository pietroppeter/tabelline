## MODIFIED Requirements

### Requirement: HTML with scoped CSS
`toHtml` SHALL render a `<div class="tabella">` with an id, holding a `<style>` with
`tabellaCss` and a `<table class="tb_table">`: the heading and column labels in `<thead>`,
groups, stub and body in `<tbody>`, footnotes then source notes in one `<tfoot>`. Without an
explicit `id`, the id SHALL come from a hash of the table, so the same table always renders the
same HTML. `toHtml(makePage = true)` SHALL return a standalone page holding the table, titled
after it, and `save(path)` SHALL write that page to a file when `path` ends in `.html` (other
extensions: the image-output spec).

```nim
let t = tabella(planets(), id = "planets"):
  tabHeader "Planets"
let h = t.toHtml
echo h.startsWith("<div id=\"planets\" class=\"tabella\""), " ", tabellaCss in h, " ", h == t.toHtml
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
- **THEN** each table looks as its own options say
