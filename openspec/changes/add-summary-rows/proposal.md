## Why

Summary rows (subtotals per group and a grand total) are one of the most used features of gt,
from clinical tables to budgets, and the one part of a table tabelline 0.1 does not have. It comes
from the BACKLOG.md entry "Summary rows" and the 0.2 build thread ("Build tabelline 0.2"), and is
built in the PR that opens 0.2.

## What Changes

- `summaryRows(fns, groups, columns, side, missingText)` adds rows under (or above) each row
  group, one per aggregate, labelled in the stub.
- `grandSummaryRows(fns, columns, side, missingText)` adds rows for the whole table, at the
  bottom or the top.
- Aggregates are values of the `agg` namespace (`agg.sum`, `agg.mean`, `agg.median`, `agg.min`,
  `agg.max`, `agg.count`, `agg.sd`), or `aggregate(proc)` for one of your own. A summary cell is
  formatted like its column (its last format), `agg.count` as an integer, or with the `fmt` of
  the call.
- New locations `loc.summary`, `loc.summaryStub`, `loc.grandSummary`, `loc.grandSummaryStub`, for
  styles and footnotes; footnote marks follow the reading order through the summary rows.
- The renderers (HTML, text, Markdown) show the summary rows apart from the body, and 14 options
  after gt's (`summaryRow*`, `grandSummaryRow*`) set their look; `optCssTheme` draws their rules
  in the page's ink.
- A table with summary rows and no row names gets a stub, for the labels, as in gt.

## Differences from gt and Great Tables

- gt's `fns` is a list of names, functions or formulas (`list(total = "sum")`), Great Tables' a
  dict of a label to a Polars expression or a callable of the data frame; here it is a list of
  pairs of a label and an aggregate, `fns = {"total": agg.sum}`. An aggregate gets one column's
  non-missing values, not the data frame. `agg.sum` and not `sum`: Nim's own `sum`, `min` and
  `max` would be ambiguous in `{"total": sum}`.
- `columns` is `numeric()` by default (gt: `everything()`; Great Tables does not have it yet and
  picks the columns in the expression).
- gt formats summary values with `fmt = list(~ fmt_number(.))` and Great Tables with
  `fmt = vals.fmt_number`; here `fmt` is a proc of a float, of a value, or a `FormatFn`
  (`fmt = (x: float) => formatNumber(x, 1)`), and without it a cell takes the last format of its
  column (gt and Great Tables leave it unformatted). gt's per-group `fmt` (`"a" ~ fmt_number(.)`)
  is two calls here, one per group.
- `side` is `sBottom` or `sTop` (the `Side` of `style.borders`), gt's `"bottom"` and `"top"`.
- `missingText` is "—" by default: gt's and Great Tables' "---", which they show as an em dash.
- `summaryRows` on a table without row groups raises a `ValueError` (as Great Tables does).
- Text transforms do not reach summary rows yet.
- Names follow gt in camelCase: `summary_rows` is `summaryRows`; locations follow Great Tables
  (`loc.summary_stub` is `loc.summaryStub`; gt's `cells_stub_summary`).

## Capabilities

### Modified Capabilities
- `table-parts`: adds summary rows, grand summary rows, aggregates and their look.
- `styling`: the summary locations.

## Impact

`src/tabelline/core.nim` (`SummaryRule`, `Aggregate`, options, `hasStub`), `verbs.nim` (the
verbs, `agg`, locations), `build.nim` (computing and formatting the rows, footnote order), the
three renderers, the explainer (a step and the menu), the Feature map.
