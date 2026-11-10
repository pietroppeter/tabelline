## Why

The second part of the fourth of five PRs for 0.2 (Pietro, 10 Nov 2026: bring 0.3 and 0.4 into
0.2). Four gt features of the Feature map that 0.1 lacked: rotated labels (`cols_label_rotate`),
body styles from the data (`tab_style_body`, `from_column`), the preview of a big table
(`gt_preview`), the built table as data (`extract_body`, `extract_cells`,
`extract_summary`), more of `tab_options()`, and two more datasets. It also renames `agg.sd`
to `agg.std` (Pietro's review of the post, 10 Nov 2026: be consistent).

## What Changes

- `colsLabelRotate(columns, dir = "sideways-lr" | "sideways-rl")`: labels on their side, in HTML.
- `fromColumn(column, naValue)`: a style value read from another column of the same row, in any
  style of `tabStyle` for body and stub cells: `style.fill(fromColumn("colour"))`.
- `tabStyle(proc (r: Row): CellStyle, locations)`: a style computed from each row.
- `tabStyleBody(style, columns, rows, values, pattern, fn, targets = "cell" | "row" | "column")`:
  styles the cells whose value matches, or their row, or their column.
- `tabellaPreview(data, topN = 5, bottomN = 1, inclRownums = true)`: the first and last rows of a
  big table, with a row saying which rows are left out ("6..99").
- `extractCells(t, columns, rows, ctx)`, `extractBody(t, ctx)`, `extractSummary(t, ctx)`: the
  shown text of the cells, the body as a `TableData`, the summary rows as a `TableData`.

- 72 more options of gt's `tab_options()` (142 in all): the container, the table's layout and
  font, and the rules, sizes and paddings of the heading, column labels, row groups, body, stub,
  footnotes and source notes.
- Datasets `isole()` (194 islands of the Mediterranean) and `citta()` (95 cities of the EU),
  from the devlog post "Rethinking tabelline's datasets".
- `agg.sd` is `agg.std`. It is unreleased, so there is no old name to keep.

## Differences from gt and Great Tables

- `colsLabelRotate` draws in HTML with `writing-mode: vertical-rl` (and a half turn for
  `"sideways-lr"`), which every browser supports; gt writes `writing-mode: sideways-lr`. The text
  outputs keep labels as they are. *Great Tables:* `cols_label_rotate` too.
- `fromColumn` is a value inside a style, as gt's `from_column()`; its `fn` is replaced by
  `tabStyle` with a proc of the row, which reads any column. *Great Tables:* `from_column()` too.
- `tabStyleBody`'s `pattern` is a plain text that the value contains, not a regular expression
  (std/re needs PCRE); `fn` is a proc of the value. `extents` (gt: also the stub) is not yet.
  *Great Tables:* no `tab_style_body`.
- `tabellaPreview` takes the data, like `gt_preview()`, and returns a `Tabella` that takes more
  verbs; the gap row is shaded. The name follows `tabella`, tabelline's `gt()`. *Great Tables:*
  `GT.show()` has no preview; `gt_preview` is R only.
- The extract procs return Nim values: `seq[string]` and `TableData` of texts (gt: a vector and
  data frames; `extract_summary` gives a list of data frames). `ctx = rcHtml` gives HTML, gt's
  `output = "html"`. *Great Tables:* none yet.

- Options: `containerPaddingX` and `Y` are 0 by default (gt: 0px and 10px), so a table looks as
  it did. Still not in: `column_labels_hidden`, `row_group_as_column`, `row_group_default_label`,
  `footnotes_multiline`, `footnotes_sep`, `source_notes_multiline`, `source_notes_sep`,
  `stub_indent_length`, the `*_include` switches, the LaTeX, page, Quarto and interactive ones.
- `agg.std`: gt's `"sd"`, Great Tables' (Polars') `std`; Nim's std/stats calls it
  `standardDeviation`.

## Capabilities

### Modified Capabilities

- `table-parts`: Rotated labels, Preview of a big table (new).
- `styling`: Styles from the data, More options (new).
- `table-data`: Datasets.
- `table-parts`: Aggregates and their format (`agg.std`).
- `rendering`: The built table as data (new).

## Impact

- New: `src/tabelline/extract.nim`; new verbs in `verbs.nim`; `tests/test_table_tools.nim`.
