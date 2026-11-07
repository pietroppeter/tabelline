## Why

Summary rows (subtotals per group and a grand total) are one of the most used features of gt,
from clinical tables to budgets, and the one part of a table tabelline does not have yet. It comes
from the BACKLOG.md entry "Summary rows" and the day-one thread; the PR that builds it is still to
be opened.

## What Changes

- `summaryRows(groups, columns, fns, side)` adds rows under (or above) each row group, one per
  aggregate, labelled in the stub.
- `grandSummaryRows(columns, fns, side)` adds rows for the whole table, at the bottom or the top.
- Aggregates are Nim procs from the column's values to a `Value` (`sum`, `mean`, `min`, `max`,
  `count` built in, any proc allowed), formatted with `fmt` like body cells, or with their own
  formatter.
- New locations `loc.summary(...)` and `loc.grandSummary(...)` for styles and footnotes.
- The renderers (HTML, text, Markdown) show the summary rows, styled apart from the body.

## Differences from gt and Great Tables

- gt's `fns` is a list of formulas or names (`list(mean = ~ mean(.))`); here it is a seq of
  `(label, proc)` pairs: `fns = @{"total": sum, "mean": mean}`.
- gt formats summary values with `fmt = list(~ fmt_number(.))`; here a `fmt` proc, or by default
  the last format of the column.
- Names follow gt in camelCase: `summary_rows` is `summaryRows`.

## Capabilities

### Modified Capabilities
- `table-parts`: adds the summary rows requirement.

## Impact

`src/tabelline/core.nim` (a SummaryRule in the spec), `build.nim` (computing the rows),
the three renderers, `verbs.nim` (the verbs and locations), the explainer's menu table.
