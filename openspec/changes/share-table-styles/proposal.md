## Why

Every table tabelline renders carries its own `<style>`, about 7 KB, with every rule scoped to the
table's id. A page with many tables repeats the same rules again and again: the API reference
(PR #65) has 156 tables, all with the same options, and their styles are 1.1 MB of its 1.9 MB.
Pietro, 11 Nov 2026 (thread "Build a styled API reference for tabelline"): "We should share CSS
as much as possible". The style of a table depends only on its options (and on whether it has
nanoplots), so tables with the same options can share one copy. This change comes from that
thread; the PR that builds it is still to be opened.

## What Changes

- The style of a table is scoped to a class named after a hash of the style itself
  (`tb-s-1a2b3c4d`), not to the table's id. Two tables with the same options get the same class
  and the same CSS. The `<div>` keeps its id (for links and `aria-labelledby`) and gets the class.
- `toHtml(t)` is unchanged for a reader: a fragment that works alone, with its `<style>` inside.
  `toHtml(t, withStyle = false)` leaves the `<style>` out, and `tableStyle(t)` gives it: the
  `<style>` element for the table's class, to be written once wherever the page wants it.
- `nbTable` writes each distinct style once per page: the first table with a class carries its
  `<style>`, the next ones with the same class do not. `nb.tableHtml(t)` does the same for a block
  that puts a table inside its own HTML (`nbParts`, `nbTabs`, `nbBeside` in the docs).
- **BREAKING (small)**: a selector that relied on `#id` having an id's weight (a page rule that
  lost to tabelline's rules, now wins or the other way round) may change result. The class has a
  class's weight, still written after the page's theme. The docs and the book are checked page by
  page (screenshots before and after).

## Differences from gt and Great Tables

- gt and Great Tables scope every table's CSS to its id (`#abcdefghij .gt_table`), one `<style>`
  per table; neither shares styles between tables. tabelline scopes by a class named after the
  style, so equal styles are written once.
- `withStyle` and `tableStyle` are new. Closest in gt: `as_raw_html(inline_css = TRUE)` (styles
  inlined on each element, no `<style>`) and in Great Tables `as_raw_html(inline_css = True)`;
  neither leaves the style out for the page to write once. Listed in *Not from gt* in the coverage
  map.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `rendering`: the HTML is scoped by a style class; `withStyle` and `tableStyle`.
- `nimib-integration`: `nbTable` writes each style once per page; `nb.tableHtml`.

## Impact

`src/tabelline/render_html.nim` (scoping, hash, `withStyle`, `tableStyle`, nanoplot rules),
`src/tabelline/nimib.nim` (the page's set of written classes, `tableHtml`), `docs/blocks.nim`
(blocks that call `toHtml` directly), `docs/coverage.nim` (*Not from gt*), tests, the specs page.
Page sizes: the reference page, the guide and the book should shrink; before and after sizes
go in the PR.
