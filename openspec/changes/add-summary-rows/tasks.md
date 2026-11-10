## 1. Model

- [x] 1.1 Add `SummaryRule` and `Aggregate` to the spec in `core.nim`
- [x] 1.2 Add `summaryRows` and `grandSummaryRows` to `verbs.nim`, with the built-in aggregates (`agg.*`) and `aggregate`
- [x] 1.3 Add `loc.summary`, `loc.summaryStub`, `loc.grandSummary`, `loc.grandSummaryStub`

## 2. Build and render

- [x] 2.1 Compute summary rows in `build.nim` (per group and grand), formatted, in the footnotes' reading order
- [x] 2.2 Render them in HTML (`tb_summary_row`, `tb_grand_summary_row`), text and Markdown
- [x] 2.3 Options: the 14 `summaryRow*` and `grandSummaryRow*` options of gt; `optCssTheme` sets the rules

## 3. Docs and checks

- [x] 3.1 Add a step to the explainer and update its menu table; the Feature map
- [x] 3.2 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [x] 3.3 Rebuild the docs (`nim r -d:release docs/all.nim`)
