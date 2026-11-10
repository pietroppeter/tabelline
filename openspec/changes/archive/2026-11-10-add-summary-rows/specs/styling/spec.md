## MODIFIED Requirements

### Requirement: Styles at locations
`tabStyle(style, locations)` SHALL add CSS to the cells at each location. Styles SHALL be built
with `style.fill(color)`, `style.text(...)`, `style.borders(...)` and `style.css(...)` and joined
with `&`. Locations SHALL be `loc.header()` (title and subtitle), `loc.title()`, `loc.subtitle()`,
`loc.columnHeader()` (stub head, spanners and column labels), `loc.stubhead()`,
`loc.columnLabels(cols)`, `loc.spanners(labels)` (also `loc.spannerLabels`), `loc.stub(rows)`,
`loc.rowGroups(groups)`, `loc.body(cols, rows)`, `loc.footer()` (footnotes and source notes),
`loc.footnotes()`, `loc.sourceNotes()`, and for summary rows `loc.summary(groups, columns, rows)`,
`loc.summaryStub(groups, rows)`, `loc.grandSummary(columns, rows)` and `loc.grandSummaryStub(rows)`
(rows by their labels), as in Great Tables; `loc.body` SHALL target the data
cells only, not the stub (that is `loc.stub`). A later style SHALL win over an earlier one for the
same property, but a style at one part SHALL win over a style at a whole part that holds it
(header, column header, footer), as in Great Tables. A footnote at a whole part SHALL be marked on
its first element.

```nim
let t = tabella(tavolaPitagorica(3), rownameCol = "×")
  .tabStyle(style.fill("#FFF3B0") & style.text(weight = "bold"), loc.body(cols = "2", rows = [1]))
  .tabStyle(style.text(color = "#1F4E99"), loc.columnHeader())
echo "background-color: #FFF3B0; font-weight: bold" in t.toHtml
echo t.toHtml.count("color: #1F4E99")
```

```text
true
4
```
