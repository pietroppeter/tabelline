## Why

Data files with a line saying where they come from were written as TSV, because `readCsv` read
every line as data. People expect CSV. Pietro asked on 8 Nov 2026 for a `comment` option in 0.1, so
a CSV file can carry its source in `#` lines.

## What Changes

- `parseCsv` and `readCsv` take `comment = ""`: with a prefix such as `"#"`, a line that starts with
  it (after any spaces) is skipped. By default nothing changes.
- BACKLOG: the `comment` item of the Milano Cortina gaps is done.

## Differences from gt and Great Tables

- gt and Great Tables read no files: R's `read.csv(comment.char = "#")`, readr's `comment` and
  Polars' `comment_prefix` do this before `gt()` / `GT()`. tabelline follows Polars: only whole
  lines are comments, so a `#` inside a value is kept (readr and pandas also cut a line at the
  prefix). Already listed in *Not from gt* with `parseCsv` and `readCsv`.

## Capabilities

### Modified requirement in `table-data`
- Data from Nim values

## Impact

`src/tabelline/core.nim`, `tests/test_core.nim`, the spec `table-data`, BACKLOG, CHANGELOG.
