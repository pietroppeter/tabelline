## Why

0.2 is "Rows and merges", and Pietro asked (10 Nov 2026, 0.2 build thread) to bring into 0.2
everything planned for 0.3 and 0.4. This change is the second of five PRs: what a table does with
its rows and columns beyond 0.1. It comes from the BACKLOG.md entries "Column merges", "Stub
indent and multi-column stubs" and "Rows", the Feature map rows of 0.2 (merge columns, add rows,
hide rows, add columns, stub indent, decimal alignment) and of 0.3 (summary columns). It is
built in the PR stacked on #53 (summary rows), because summary columns reuse its aggregates.

## What Changes

- `colsMerge(columns, rows, pattern, autohide)` shows the formatted values of several columns in
  the first one, with a pattern (`"{1} ({2})"`, `<<...>>` for a part left out when a value is
  missing); `colsMergeUncert`, `colsMergeRange`, `colsMergeNPct` for the usual three.
- `colsAdd(name, values | proc of a row, before, after)` adds a column.
- `summaryColumns(fns, columns, fmt, side, missingText)` adds a column for each aggregate, summing up
  columns across each row.
- `rowsAdd(rows, before, after)` adds rows (a `TableData` or Nim objects), into a group when the
  group column has a value; `rowsHide(rows)` and `rowsUnhide(rows)`.
- `tabStubIndent(rows, indent)` indents stub cells (a level from 0 to 5, or `"increase"`,
  `"decrease"`).
- `colsAlignDecimal(columns, decMark, locale)` aligns numbers on their decimal mark.

## Differences from gt and Great Tables

- `colsMerge` hides the other columns with `autohide = true`, as the three special merges do,
  instead of gt's `hide_columns = columns[-1]`; Great Tables has `cols_merge` with the same pattern
  syntax.
- `colsMergeUncert` writes ` ± ` (gt's default `" +/- "`, shown as ± in HTML).
- Merges hide the other columns, so their formats still apply: a merged cell joins the formatted
  values, as in gt.
- `colsAdd` takes one column at a time, from values or from a proc of the row (gt's `...` takes
  expressions of the data); Great Tables has no `cols_add`.
- `summaryColumns` is gt's `summary_columns()` (new in gt; not in Great Tables) with the aggregates
  of `summaryRows`; the label of each pair is the new column's name and label (gt's
  `new_col_names`, `new_col_labels`). `side` is `sRight` or `sLeft`.
- `rowsAdd` takes a `TableData` or a seq of objects or tuples, and `before`/`after` by row index
  (gt: `...` of name = value pairs, `.before`/`.after`; Great Tables has no `rows_add`).
- `rowsHide` (gt's `rows_hide()`, not in Great Tables): hidden rows are not summed up by summary
  rows either.
- `tabStubIndent` indents by 1em a level (gt: 5px a level, in `gt_indent_*`).
- `colsAlignDecimal` pads with figure spaces (U+2007) and a punctuation space (U+2008) for a
  missing mark, as gt does; it works in text output too.

## Capabilities

### Modified Capabilities
- `table-parts`: merged columns, added columns and summary columns, added and hidden rows, stub
  indent, decimal alignment.

## Impact

`core.nim` (`MergeRule`, `hiddenRows`, `indents`, `decimalAligned`), `verbs.nim` (the verbs),
`build.nim` (merging, hiding, indent, alignment), the renderers (indent), the docs.
