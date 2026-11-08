## Why

`optPageTheme()` (PR #21) makes a table take its colours from the page, but the names it reads
are our pages' own: `--n-9`, `--n-3`, `--n-1`, `--surface`, `--text`. They say nothing to a
reader (what is `n-3`?), and another page must rename its variables, or map them, to use it.
Pietro asked to rethink it from scratch, natural and simple yet powerful (project thread
"Redesign the tabelline page theme API"), and chose this design. Built in the PR that renames
the preset and the tokens of the pages.

## What Changes

- **BREAKING (before 0.1):** `optPageTheme()` is replaced by `optCssTheme()`, beside `optCss()`.
- It reads seven names that say what they are: `--ink` (text and heavy rules), `--paper` (behind
  the table), `--line` (rules between rows), `--shade` (row groups, stripes), `--primary` (the
  rule under the heading), `--secondary` (the rules of the row groups) and `--font`.
- Two make a table: without `--line` and `--shade`, they are mixed from ink and paper
  (`color-mix`); without `--primary` and `--secondary`, they are the ink; without ink and paper,
  the table is black on white.
- Every name can be changed, or replaced by a value: an argument starting with `--` names a
  variable, anything else is a CSS value (`optCssTheme(ink = "--foreground", primary = "#D64545")`).
- `cssTheme(...)` makes a `CssTheme` to keep and reuse: `t.optCssTheme(mine)`.
- The docs: the tokens of `docs/stile.nim` take the same names, so tables follow the pages with
  no arguments. `--n-0` and `--n-9` were the paper and the ink; `--n-1` is `--shade`, `--n-3`
  `--line`, `--n-7` `--muted`; the whole scale is `--neutral-0` … `--neutral-9`; the font
  `--text` is `--font`. Tables now sit on `--paper` (was `--surface`), and their row groups are
  ruled in the secondary colour.

## Differences from gt and Great Tables

- Neither has this preset. The name follows gt's `opt_*` presets and sits beside `opt_css()`
  (`optCss`): `opt`, then what it sets, a theme made of CSS variables.

## Capabilities

### Modified requirements in `styling`
- Options and presets

## Impact

`src/tabelline/verbs.nim`, the spec `styling`, `docs/stile.nim`, every page of the docs and the
book, `book/theme/edo.css`, the Design Ref, AGENTS.md, BACKLOG.md. Dated devlog posts change only
where they must to build and draw.
