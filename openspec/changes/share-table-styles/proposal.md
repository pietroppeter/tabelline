## Why

Every table tabelline renders carries its own `<style>`, about 7 KB, with every rule scoped to the
table's id. A page with many tables repeats the same rules again and again: the API reference
(PR #65) has 156 tables, all with the same options, and their styles are 1.1 MB of its 1.9 MB.
Pietro, 11 Nov 2026 (thread "Build a styled API reference for tabelline"): "We should share CSS
as much as possible". The style of a table depends only on its options (and on whether it has
nanoplots), so the rules can be shared and only the values differ. This change comes from that
thread; the PR that builds it is still to be opened.

## What Changes

- The ~90 rules of a table become one fixed stylesheet, `tabellaCss`, the same for every table:
  rules on `.tabella` and the `tb_` classes, each value read from a CSS variable named after its
  option, with the default as fallback (`font-size: var(--tb-heading-title-font-size, 125%)`).
  The nanoplot rules are part of it.
- A table carries only the options it changes, as variables in a `style` attribute on its
  `<div>` (`style="--tb-table-font-size: 14px"`); a table with default options carries none.
  The `<div>` keeps its id. `optCss` stays as today, a `<style>` of its own scoped to the id.
- `toHtml(t)` still gives a fragment that works alone: `tabellaCss` in a `<style>` in front of the
  table. `toHtml(t, withStyle = false)` leaves it out, for a page that writes `tabellaCss` once
  or links it as a file.
- `nbTable` writes `tabellaCss` once per page, with the first table; `nb.tableHtml(t)` does the
  same for a block that puts a table inside its own HTML.
- The rules keep the weight they have today, as if they named an id: each starts with
  `:where(.tabella):not(#_)`, which matches every table and weighs exactly what `#id` weighs. So a
  page's theme wins or loses against tabelline's rules as it does now. The docs and the book are
  still checked page by page (screenshots before and after).
- Not chosen: scoping each table by a class named after a hash of its style (the first version of
  this proposal), and merging the rules of all tables after the page is built. Both work; both
  are harder to explain and to use (design.md).

## Differences from gt and Great Tables

- gt and Great Tables scope every table's CSS to its id (`#abcdefghij .gt_table`), one `<style>`
  per table; neither shares styles between tables. tabelline has one stylesheet for all tables.
- gt and Great Tables write every value into the CSS; tabelline writes fixed rules and passes
  the values as CSS variables. A page can set a variable for all its tables
  (`.tabella { --tb-table-font-size: 14px }`).
- `tabellaCss` and `withStyle` are new. Closest in gt: `as_raw_html(inline_css = TRUE)` (styles
  inlined on each element), and the same in Great Tables; neither leaves the style out for the
  page to write once. Listed in *Not from gt* in the coverage map.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `rendering`: one stylesheet, `tabellaCss`; options as CSS variables; `withStyle`.
- `nimib-integration`: `nbTable` writes `tabellaCss` once per page; `nb.tableHtml`.

## Impact

`src/tabelline/render_html.nim` (`tabellaCss`, the variables of each table, `withStyle`),
`src/tabelline/nimib.nim` (`tabellaCss` once per page, `tableHtml`), `docs/blocks.nim`
(blocks that call `toHtml` directly), `docs/coverage.nim` (*Not from gt*), tests, the specs page.
Page sizes: the reference page, the guide and the book should shrink; before and after sizes
go in the PR.
