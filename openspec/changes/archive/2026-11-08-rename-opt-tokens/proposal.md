## Why

`optTokens()` (PR #19) is the preset that makes a table take its colours from the page. Its name
said how it works ("tokens", the design-system word for the page's CSS variables) but nothing a
gt or Great Tables user knows, and the home page shows it in the first example. Pietro asked to
review the name and explain the preset (project thread "Explain and rename optTokens in
tabelline"); of `optPageTheme`, `optPageColors`, `optCssVars` and keeping `optTokens`, he chose
`optPageTheme`. Built in the PR that renames it and explains it on the home page and in The Great
Explainer.

## What Changes

- **BREAKING (before 0.1):** `optTokens()` is renamed `optPageTheme()`. Nothing else changes: the
  same options, the same variables, the same fallbacks.
- The requirement names the variables the preset reads.

## Differences from gt and Great Tables

- Neither has this preset. The name follows gt's `opt_*` presets (`opt_stylize()`,
  `opt_table_font()`): `opt`, then what it sets, the page's theme.

## Capabilities

### Modified requirements in `styling`
- Options and presets

## Impact

`src/tabelline/verbs.nim`, the spec `styling`, every page of the docs and the book (they take
the preset), AGENTS.md, BACKLOG.md.
