## Why

Pietro's review of the post "Designing tabelline 0.2" (10 Nov 2026): the verbs that take a list
of pairs read badly (`summaryRows fns = {"total": agg.sum}, fmt = (x: float) => ...`), and he
asked for an indented form, "grandSummaryRows: mean: agg.mean fmtNumber(…)", for every such verb.
He chose (decision card, 10 Nov 2026) to have it for all of them, with the pair form kept.

## What Changes

- Inside `tabella(data): body`, a verb may end with an indented block:
  - in the verbs whose first argument is a list of pairs (`colsLabel`, `colsWidth`, `colsUnits`,
    `textCaseMatch`, `summaryRows`, `grandSummaryRows`, `summaryColumns`), a line
    `label: value` is a pair (`total: agg.sum`; a label with spaces is a string or in
    backquotes);
  - in any verb, a line `name = value` is that named argument (`columns = "mass"`);
  - in the summary verbs, a line `fmtNumber(decimals = 1)` (any `fmt*` with a `format*`
    function) is `fmt`, a proc of a float that calls `formatNumber(x, decimals = 1)`;
  - `tabOptions:` takes lines `name = value`.
- `tableData:` is already the block form of `toTableData`, the eighth verb with a list of pairs.
- The pair form stays as it is: a block is another way to write the same call.

## Differences from gt and Great Tables

- None in R or Python: named lists and dicts are how gt and Great Tables write pairs
  (`fns = list(total = "sum")`, `fns={"total": ...}`). The block is Nim's own: an indented body,
  as `tableData:` and `tabella(data): body` are. It is not from gt, so it gets a line in the
  table *Not from gt* of the Feature map.

## Capabilities

### Modified Capabilities

- `nim-sugar`: Blocks for lists of pairs (new).

## Impact

- `src/tabelline.nim` (`rewriteVerbs`, `blockArgs`); tests in `tests/test_pair_blocks.nim`.
