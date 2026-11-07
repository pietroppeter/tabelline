# Changelog

## Unreleased

- Docs: a coverage map of tabelline against gt and Great Tables (85 feature groups), with the
  plan for the next releases, as a living document (#8).
- Fix: `loc.body()` targets the data cells only, not the stub, as in gt (#8).
- Docs: the parts of a table in Haru colours, in the explainer and, with a "Show the parts"
  button, on the home page's planets table (#8).
- Docs: the roadmap (living document, from `docs/piano.nim`): releases 0.1 to 0.5 and three
  threads for each (build it, use it, port the references); the devlog post *Three threads for
  every release*; tabs on the pages for the same example in 👑 Nim, 🐍 Python and 🏴‍☠️ R
  (`nbTabs`) (#8).

- Docs: the Munari colours are named by role (`--m-cerchio`, `--m-quadrato`, `--m-triangolo`,
  `--m-quarto`), code highlighting follows the palette, and the palettes post is compact: a
  summary of what each colour does, a swipe gallery that picks the palette, the anatomy of a page
  and the stories of the names; Haru (spring) is the default palette (#7).

- Docs: the Munari look takes a softer palette of Japanese traditional colours (six variables), and
  loses decorations that looked pressable; same-day devlog posts take a letter (A, B, C); a post
  on the palettes, to compare and try them (#6).

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
- Docs: a second look for the pages, after Bruno Munari, and the default; the quaderno is a
  switch away in every header, and the choice is remembered. Devlog post *Two looks*. (#5)
