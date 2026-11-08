## Why

`fmtBar` was tabelline's only format not in gt or Great Tables, and it drew the bar before the
number, so a bar seemed to belong to the column on its left. gt and Great Tables draw bars with
`fmt_nanoplot()`, which is experimental in gt. Pietro decided on 8 Nov 2026 (in the thread
"Explain Milano Cortina 2026 with tabelline") to remove `fmtBar` before 0.1 and to bring bars
back with `fmtNanoplot` after it.

## What Changes

- **Breaking (before 0.1)**: `fmtBar` and its CSS are removed.
- The pages that used it show the numbers (the coverage map shows its share as a percentage).
- BACKLOG: `fmtNanoplot`, with a first step of one value per cell, as in Great Tables.
- The coverage map gets a table *Not from gt*, and AGENTS.md a rule to keep it up to date.

## Differences from gt and Great Tables

- None left in formatting: tabelline has no bars until it has nanoplots.

## Capabilities

### Modified requirement in `formatting`
- Other formats

## Impact

`src/tabelline/formats.nim`, `src/tabelline/render_html.nim`, the spec `formatting`, the pages
that used `fmtBar` (home, explainer, design, coverage, and three dated devlog posts, whose code
must still build), BACKLOG, CHANGELOG, AGENTS.md.
