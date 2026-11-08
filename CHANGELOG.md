# Changelog

## Unreleased

- Docs: a new structure. The home page keeps one simple table and lists the living documents
  in reading order (The Great Explainer, Devlog, Book, Roadmap, Coverage map, Design Ref,
  Agents, Specs); the devlog lists only posts; new pages Design Ref (`docs/design.nim`) and
  Agents (`docs/agents.nim`, with the rules from AGENTS.md and a `llms.txt`); the explainer is
  now The Great Explainer.
- Docs: three devlog posts from the 0.1 use-it thread: *A month of building, as an operetta*
  (Pietro's seven weeks of open source with Claude, from GitHub data), *Operetta, a first sketch*
  and *Skills, from the beginning*; their data in `docs/mese.nim` and `docs/devlog/data/` (#9).

The 24 small groups of gt marked for 0.1 in the coverage map, one OpenSpec change each (#10):

- Parts: `tabSpannerDelim` (spanners from `a.b` names), `tabCaption`, and `rmHeader`,
  `rmSpanners`, `rmFootnotes`, `rmSourceNotes`, `rmStubhead`, `rmCaption`.
- Formats: `fmtEngineering`, `fmtNumberSi`, `fmtPartsper`, `fmtBytes`, `fmtIndex`,
  `fmtSpelledNum`, `fmtTime`, `fmtDatetime`, `fmtDuration`, `fmtUrl`, `fmtEmail`, `fmtFlag`
  (emoji, nothing loaded); `fmtTf` takes gt's ten styles, `naText`, `colors` and `html`; every
  format has a public value function (`formatBytes`, `formatDuration`, ...).
- Substitutions and text: `subSmallVals`, `subLargeVals`, `subValues`; `textTransform`,
  `textReplace`, `textCaseMatch`.
- Columns and rows: `colsLabelWith`, `colsMoveToEnd`, `colsReorder`, `rowOrder`, `rowGroupOrder`.
- Styles: `style.css`; the locations `loc.header`, `loc.columnHeader`, `loc.footer` and
  `loc.spannerLabels`.
- Options: `optVerticalPadding`, `optHorizontalPadding`, `optTableOutline`, `optTableLines`,
  `optFootnoteMarks` (with `"extended"` marks and marks of your own), `optFootnoteSpec`,
  `optFootnoteOrder`, `optCss`; `md()` and `html()` have a spec.
- Fix: the standard footnote marks are gt's four (\*, †, ‡, §); the six are `"extended"`.
- Fix: in Markdown, `~` and `^` make a subscript or superscript only when closed with no space
  inside, so "~50 PRs" stays as it is (found by the 0.1 use-it thread).
- Fix: `dataColor` over number and text columns in one call no longer raises; the subtitle is not
  bold (`headingSubtitleFontWeight`); a style at a part wins over one at its whole part (found by
  the 0.1 port thread).
- `tableData:` reads dotted names without quotes (`size.mass: [...]`), and quoted names whole.
- Docs: the devlog post *Designing tabelline 0.1*; the coverage map marks the 24 groups done.

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
