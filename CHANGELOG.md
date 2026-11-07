# Changelog

## Unreleased

## 0.1.0 (7 Nov 2026)

The first release: a proof of concept. The API will change.

- The table data (`Value`, `TableData`, `tableData:`, CSV), the table spec (`Tabella`) with the
  six parts of gt (header, column labels and spanners, stub and stub head, row groups, body,
  footer), 11 formatters and `fmtBar`, substitutions, styles at locations, `dataColor`,
  `tabOptions` and presets (`optStylize`, `optQuaderno`, ...), HTML / text / Markdown renderers
  and the nimib block `nbTable`. Datasets: `planets`, `exibble`, `tavolaPitagorica`. (#1)
- Repository setup: OpenSpec specs with runnable examples, the spec page, the explainer, the
  devlog, the quaderno theme and CI for tests, examples and pages. (#1)
- Dependencies with atlas (`atlas.lock`, `nim.cfg`, nimib as the optional `docs` feature) and
  `tools/setup.sh`, which sets up a laptop, CI or a fresh coding-agent sandbox. Needs Nim 2.2
  or later. (#2)
- Docs: an "R or Python?" section and a note on `sink` in the explainer (#2); the devlog post
  *Tabellone: when a table becomes a grid* (#3); backlog ideas from using tabelline in
  diagrammari (#4).
