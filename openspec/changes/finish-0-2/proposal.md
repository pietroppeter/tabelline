## Why

Pietro, 11 Nov 2026 (thread "Release tabelline 0.2", decision card): the rows of the Feature map
that are still *partial* for 0.2 are finished before v0.2.0 is tagged. They are the tails of
features 0.2 already ships: a stub of several columns, the options of gt that change an HTML
table, two image helpers, named font stacks, a colour for each point of a nanoplot, and the gt
datasets that the book already uses. Built in the release PR, #78.

## What Changes

- **A stub of several columns.** `tabella(data, rownameCol = ["mfr", "model"])`: the stub is
  those columns, the leftmost the highest level. A value equal to the one above it, under the
  same higher levels and in the same group, is drawn once, spanning its rows (HTML) or left blank
  (text, Markdown). `loc.stub(rows, cols)` picks stub columns. `stubColumns(t)` gives them.
- **Groups as a column.** `tabOptions(rowGroupAsColumn = true)` draws each group's label as the
  first column of the stub, spanning its rows, instead of a row above them; the
  `stubRowGroup*` options (font size and weight, text transform, border style, width and colour)
  style that column. `tabella(data, groupnameCol = "type", rowGroupAsColumn = true)` says the
  same when the table is made, as gt's `row_group_as_column`.
- **The other options of gt that change an HTML table**, 22 of them: `tableAlign`,
  `tableNoDataMessage`, `tableAdditionalCss`, `tableFontColorLight`, `columnLabelsHidden`,
  `columnLabelsUnitsPattern`, `rowGroupDefaultLabel`, `rowGroupAsColumn`, `stubIndentLength`,
  `stubSeparate`, the six `stubRowGroup*`, `footnotesMultiline`, `footnotesSep`,
  `sourceNotesMultiline`, `sourceNotesSep`, `rowStripingIncludeStub`,
  `rowStripingIncludeTableBody`. That makes 164 options. The 36 of gt's that are left are for
  interactive tables (`ihtml.*`), pages and LaTeX (`page.*`, `latex.*`) and Quarto: they mean
  nothing for an HTML table and come later, with the outputs that need them.
- **Images anywhere.** `localImage(file, height = "2em")` and `webImage(url, height = "2em")`
  give an `<img>` as `Text` (a local file inlined as a data URL), for a label, a note or a cell
  of `fmtMarkdown`/`html`, as gt's `local_image()` and `web_image()`.
- **Named font stacks.** `systemFonts(name = "system-ui")` gives one of Great Tables' fifteen
  font stacks ("system-ui", "transitional", "old-style", "humanist", ...) as CSS text, for
  `optTableFont`; `defaultFonts()` gives gt's default stack.
- **A value for each point.** The options of `nanoplotOptions` for points and bars (radius,
  stroke colour and width, fill; bar stroke colour and width, fill) take a list as well as one
  value: the n-th point or bar takes the n-th value, and the list repeats. The `x` of a record
  takes ISO dates and times too, placed by time.
- **gt's datasets.** `gtcars()`, `countrypops()`, `illness()` and `metro()` in
  `tabelline/datasets`, from gt (MIT), the same rows and columns as the book uses today; the book
  reads them from there.

## Differences from gt and Great Tables

- Multi-column stubs: as gt (`rowname_col = c(...)`, gt 1.x). Great Tables has one stub column.
  `loc.stub(columns = ...)` is gt's `cells_stub(columns = ...)`, with the name `cols` of tabelline's other locations.
- Options: the same names in camelCase. `tableAdditionalCss` is `optCss` written as an option
  (both add). `tableFontColorLight` is the text colour on dark cells, used by `dataColor` and
  `optStylize`, as in gt. Not in: `ihtml.*` (interactive tables are left aside), `page.*`,
  `latex.*` and `quarto.*`.
- Images: no `ggplot_image()` (an R plot). `localImage` reads the file when called, as gt.
  Great Tables has neither helper.
- Fonts: `systemFonts` as Great Tables' `system_fonts()`, returning one CSS string, not a list;
  no `google_font()`, because tabelline loads nothing remote (inline a font in the page instead).
- Nanoplots: lists as Great Tables' `nanoplot_options()` (gt: vectors); Great Tables raises for
  a list that is neither one value nor one per point, tabelline repeats it.
- Datasets: the four that the book's ports use, not all of gt's eighteen; the others come when a
  page needs them, and tabelline's own twins (`isole`, `citta`) stay.

## Capabilities

### Modified Capabilities

- `table-parts`: Stub of several columns, Groups as a column (new).
- `styling`: The other options for an HTML table (new).
- `formatting`: Images anywhere, Named font stacks, Nanoplot options for each point (new).
- `table-data`: gt's datasets (new).
