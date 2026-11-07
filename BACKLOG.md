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
- **Text transforms** (S). `textTransform(loc, proc)`, `textCase`, `textReplace`.
- **Stub that does not wrap** (S). An option (or a `colsWidth` setting) to keep the stub on one
  line: "600 BCE" broke in two in diagrammari's era tables, fixed there with page CSS
  (`td.tb_stub{white-space:nowrap}`).
- **Stub indent and multi-column stubs** (S). `tabStubIndent`, `rownameCol` with several columns.
- **Rows** (S). `rowsAdd`, `rowGroupOrder`, hidden rows.

## Formats

- **More formatters** (M). `fmtUnits` (`m^2`, `kg/m^3`, gt's units syntax), `fmtDuration`,
  `fmtBytes`, `fmtFraction`, `fmtPartsper`, `fmtEngineering`, `fmtNumberSi`, `fmtDatetime`,
  `fmtTime`, `fmtUrl`, `fmtEmail`, `fmtIndex`, `fmtSpelledNum`.
- **Images, flags and icons** (M). `fmtImage` (inlined as data URLs so pages stay standalone),
  `fmtFlag`, `fmtIcon`, without loading anything remote. Also `fmtTf(..., html = true)`:
  `fmtTf` escapes its texts, so Isotype-style tables (an SVG symbol per boolean, as in
  diagrammari's series part 2) need a custom `fmt` on `RenderContext` today.
- **Locales** (M). Month and day names and number marks for more locales, from CLDR data
  generated into a Nim module at compile time.
- **Rounding** (S). `formatFloat` rounds half to even (2.25 → "2.2"); decide whether to round
  half away from zero as gt does in some cases.

## Plots in cells

- **Nanoplots** (L). `fmtNanoplot` / `colsNanoplot`: line, bar and box plots in SVG, with
  reference lines and areas, as in gt 0.10+. The tiny `fmtBar` is the first step.
- **`fmtBar` layout** (S). Bar only, or the value before the bar: with the value after it, a
  column of bars reads unevenly (diagrammari's series part 5).

## Options and building

- **Option presets** (S-M). A page that styles every table the same way repeats six or seven
  `tabOptions` fields per table. A user-defined preset (`let sea = tabOptions(...)`, then
  `tabOptions sea` or `optPreset sea`), like `optQuaderno` but your own; a docs theme would ship
  one.
- **Scroll on narrow screens** (S). Wrap wide tables in a container with `overflow-x: auto` by
  default (an option to turn it off), instead of each page adding it.
- **Columns from computed lists** (S). Building a table with one column per item of a list takes
  `TableData()` + `addColumn` + `toValue` today; a `withColumn(name, seq[T])` (or `tableData:`
  accepting a loop) would make it one line.

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

- **A gallery** (M). Rebuild well-known gt tables and Table Contest entries with tabelline.
- **API reference** (S). `nim doc` for `src/tabelline.nim`, published with the pages.
- **A Table Contest entry** (M). For the next Posit Table Contest.
