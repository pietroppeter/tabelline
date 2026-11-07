## 1. Model

- [ ] 1.1 Add `SummaryRule` (groups, columns, fns, side, format) to the spec in `core.nim`
- [ ] 1.2 Add `summaryRows` and `grandSummaryRows` to `verbs.nim`, with the built-in aggregates
- [ ] 1.3 Add `loc.summary` and `loc.grandSummary`

## 2. Build and render

- [ ] 2.1 Compute summary rows in `build.nim` (per group and grand), formatted
- [ ] 2.2 Render them in HTML (`tb_summary_row`, `tb_grand_summary_row`), text and Markdown
- [ ] 2.3 Options: summary row background and font weight

## 3. Docs and checks

- [ ] 3.1 Add a step to the explainer and update its menu table
- [ ] 3.2 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [ ] 3.3 Rebuild the docs (`nim r -d:release docs/all.nim`)
