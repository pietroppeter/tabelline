## Why

The design review (devlog, 8 November 2026, PR #17) gave the pages a palette by roles: six values
per look, and every other colour mixed from them as CSS variables (`--n-0` … `--n-9`,
`--surface`, `--primary`, …). `optQuaderno()` painted tables in the quaderno's fixed colours, and
the Munari look painted them again with `!important`. Pietro chose to replace it with a preset
that reads the tokens and to keep `optQuaderno` out of 0.1 (choice 5). Built in the docs
migration PR, after the blocks review (PR #18).

## What Changes

- **BREAKING (before 0.1):** `optQuaderno()` is removed.
- `optTokens()` is a new preset: every colour of the table is a CSS variable of the page, with a
  plain fallback (`var(--n-9, #1C1C1C)`), so the table follows whichever look and palette the
  page has, and looks like a plain table on a page that has none of them.

## Differences from gt and Great Tables

- Neither has `optTokens`; it is a preset like `opt_stylize()`, for pages that define their colours
  as CSS variables. Any colour argument of gt can be a CSS colour, and so a variable, in both.

## Capabilities

### Modified requirements in `styling`
- Options and presets

## Impact

`src/tabelline/verbs.nim`, the spec `styling`, every page of the docs (they take `optTokens()`),
`docs/stile.nim` (the tokens).
