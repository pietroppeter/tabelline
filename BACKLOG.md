# Backlog

Ideas for tabelline. A loose list, not a roadmap: nothing here is committed. When an idea is
picked up it becomes an OpenSpec change (`/opsx:propose`) and is marked *in progress* here with
the change name; when the change is archived, its entry is removed and a line goes to
[CHANGELOG.md](CHANGELOG.md).

Rough size: S (hours), M (a day or two), L (more).

## Parts

- **Summary rows** (M, *in progress*: `add-summary-rows`). `summaryRows`, `grandSummaryRows`.
- **Column merges** (M). `colsMerge` with a pattern (`"{1} ({2})"`), `colsMergeUncert`
  (value ± error), `colsMergeRange`, `colsMergeNPct`.
- **Stub that does not wrap** (S). An option (or a `colsWidth` setting) to keep the stub on one
  line: "600 BCE" broke in two in diagrammari's era tables, fixed there with page CSS
  (`td.tb_stub{white-space:nowrap}`).
- **Stub indent and multi-column stubs** (S). `tabStubIndent`, `rownameCol` with several columns.
- **Rows** (S). `rowsAdd`, hidden rows.

## Formats

- **Gaps from the month article** (S each, 0.1 use-it thread, [A month of building with Claude](https://pietroppeter.github.io/claude-artifacts/a-month-with-claude/)): an `html()` cell format
  (`fmtMarkdown` escapes every tag but `<br>`); Markdown in row group labels; a TSV or
  `quote = ""` option for `readCsv` (a `"` inside a field is taken as quoting and dropped);
  document that colours such as `style.fill("var(--x)")` can use the page's CSS variables.

- **Gaps from the Milano Cortina post** (S each, 0.1 use-it thread): a `head`/`rowsKeep` that cuts the rows after `rowOrder`, for a top ten
  by another column; a rank helper; `fmtNumberSi` with a powered unit (`m³`) writes cubic
  megametres; `textCaseMatch(cases, loc...)` needs `locations =` because `default` and `replace`
  come first; say in the docs that text transforms run after `fmtMarkdown` (Markdown in a
  replacement stays as text, HTML works); `subZero(zeroText = "")` cannot write an empty cell (an empty text means no
  substitution).

- **More formatters** (M). `fmtUnits` (`m^2`, `kg/m^3`, gt's units syntax), `fmtFraction`.
- **Images and icons** (M). `fmtImage` (inlined as data URLs so pages stay standalone),
  `fmtIcon`, without loading anything remote; SVG flags (emoji flags are in 0.1).
- **Locales** (M). Month and day names and number marks for more locales, from CLDR data
  generated into a Nim module at compile time.
- **Rounding** (S). `formatFloat` rounds half to even (2.25 → "2.2"); decide whether to round
  half away from zero as gt does in some cases.

## Plots in cells

- **Nanoplots** (L). `fmtNanoplot` / `colsNanoplot`: line, bar and box plots in SVG, with
  reference lines and areas, as in gt 0.10+ and Great Tables (experimental in gt, so not in 0.1).
  First step: one value per cell, a horizontal bar or line from a zero line shared by the rows,
  the value shown on hover (Great Tables' `_utils_nanoplots.py`). A draft of that step, with
  `nanoplotOptions`, was written on 8 Nov 2026 and set aside when `fmtBar` was removed before 0.1.

## Options and building

- **Show the parts** (S). The docs' `showParts` (docs/parti.nim) as a library preset, `optParts()`,
  with a legend: a way to learn the parts of a gt table on your own data.
- **Option presets** (S-M). A page that styles every table the same way repeats six or seven
  `tabOptions` fields per table. A user-defined preset (`let sea = tabOptions(...)`, then
  `tabOptions sea` or `optPreset sea`), like `optCssTheme` but your own; a docs theme would ship
  one.
- **Scroll on narrow screens** (S). Wrap wide tables in a container with `overflow-x: auto` by
  default (an option to turn it off), instead of each page adding it.

## Interop

- **nanuq** (S-M). `tabella(df)` for a nanuq (Polars) DataFrame, as an optional module
  `tabelline/nanuq`, so the core keeps no dependencies.
- **datamancer** (S). The same for SciNim's datamancer.
- **Arraymancer tensors** (S). A 2D tensor as a table.

## Outputs

- **LaTeX** (M). `toLatex`, booktabs style, as gt's `as_latex`.
- **Images** (M). `saveImage` with headless Chromium.
- **Tabellone** (L). A Tabella shown as a grid: `toGrid(t)` and `nbGrid`, with virtual rows,
  sort, filter, sticky header and stub, spanners as column groups, and the table's header and
  footer around the grid. In this repository as a module; rows served from Nim (a row model)
  later, maybe in its own repository. See the devlog post
  [Tabellone](https://pietroppeter.github.io/tabelline/devlog/tabellone/), which has a sketch.
  Optional: `tabelline/aggrid`, AG Grid column definitions from a Tabella.
- **RTF / Word** (L). For the pharma use case.

## nimib

- **Remove nimib's deprecated `md`** (S, in nimib). It clashes with `md` here; notebooks need
  `import nimib except md` until then.
- **nimibook and nimiSlides** (S). Check that tables look right in their themes.

## Docs

- **FOSDEM devroom picker** (M, Pietro, from the FOSDEM story): once the story is in Nim, a
  small widget (nimib JS block, data inlined) where a reader picks a devroom (its family, across
  renames) and sees its talks of the last three editions, plus the 2027 call for participation
  until the schedule is out. Goes with the parked interactive tables (`opt_interactive`).
- **A skill for users** (M). `skill.md` and `llms.txt` written from the specs and their examples
  while the pages are built, served from the site, as Great Docs does for Great Tables. From the
  skills part of [A month of building with Claude](https://pietroppeter.github.io/claude-artifacts/a-month-with-claude/#part-three) (0.1 use-it thread).
- **A small skill benchmark** (S). Five tasks with and without the user skill, graded by building
  the result.
- **Port the gt user guide** (M). A second part of the book: the guide of R's gt
  (gt.rstudio.com/articles), its text kept, with 👑 Nim, 🏴‍☠️ R (the original) and, where Great
  Tables has it, 🐍 Python. Check its licence (MIT) first.

- **A gallery** (M). Rebuild well-known gt tables and Table Contest entries with tabelline.
- **API reference** (S). `nim doc` for `src/tabelline.nim`, published with the pages.
- **A Table Contest entry** (M). For the next Posit Table Contest.

## From the tabelline book (0.1 port thread, book/gaps.md in PR #11)

- **Full Markdown in `md()`**: today `md()` reads inline marks only (bold, italic, code, links,
  sub- and superscripts), with no lists, paragraphs or HTML entities; the book expected full
  Markdown. Great Tables uses a Markdown library; tabelline would need a small block parser in the
  core, or an optional module.
- **`pattern`, `locale` and `expStyle` in the value functions**: the `formatX` functions lack
  arguments their `fmtX` verbs or gt's `vec_fmt_*` have.

- **Selectors** (S-M). Columns by position (also negative) and by a proc; combining rules
  (`|`, `&`, exclude); `matches()`; negative row indices; `loc.body(mask = ...)`; `loc.stub` by row
  label; `loc.rowGroups` by row index or condition.
- **Stub and spanners** (S). A `tabStub` verb; `tabSpanner` gathering its columns in the given
  order; the spanner's fill covering the whole cell.
- **Colours** (S). All CSS colour names (only 17 today: `rebeccapurple`, `bisque` raise
  ValueError); `dataColor` with a high-to-low domain (`(90, 0)` gives 0.5 for all); gt's
  `dataColor` defaults (palette, NA grey); white text on dark option backgrounds (stub, heading by
  colour name).
- **Presets** (S). `optStylize` with gt's six styles; `optAllCaps` on the stub and row groups.
- **CSV** (S). `readCsv` reads "0400" as 400: keep leading zeros as text.
