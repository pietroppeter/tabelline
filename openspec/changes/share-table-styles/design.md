# Design

## Context

`render_html.nim` writes `tableCss(id, options)`: about 90 rules, each prefixed with `#id`, plus
the nanoplot rules when the body has a nanoplot, plus `extraCss` (`optCss`) scoped the same way
unless a rule already starts with `#`. Cell styles (`tabStyle`) are inline `style=""` attributes
and do not take part. So the `<style>` of a table is a function of its options and of one bit
(nanoplots or not); the id only changes the prefix. `nbTable` stores `t.toHtml` in a block.
Some docs blocks (`nbParts`, `nbTabs` and others in `docs/blocks.nim`) call `toHtml` themselves.

Measured on `main` today (23 built pages of the docs, book not counted): 6.68 MB of HTML, 1.71 MB
of it table styles; with one style per distinct set of options per page, 0.26 MB. The specs page
goes from 695 KB to 306 KB (gzip: 78 to 53 KB), designing-0-1 from 461 to 217 KB. The reference
page of PR #65 has 156 tables with one set of options: 1.1 MB of styles become about 7 KB.

## Goals / Non-Goals

**Goals:**
- A page holds each distinct table style once.
- `toHtml(t)` alone still gives a fragment that works anywhere, as today.
- Built pages stay stable: the same table gives the same class and the same HTML.

**Non-Goals:**
- One stylesheet for the whole site (`docs/assets/tables.css`). Possible later on top of
  `tableStyle`, but it ties pages to a build step; once per page is the step Pietro asked for.
- Smaller rules (dropping rules equal to the browser's defaults). A separate idea for BACKLOG.
- Inline CSS on every element (gt's `inline_css`), for e-mail.

## Decisions

1. **Scope by a class named after the style.** The CSS is written with a placeholder selector,
   hashed (`std/hashes`, as the id is today), and the placeholder replaced by `.tb-s-<8 hex>`.
   Hashing the CSS text, not the options, means anything that changes the CSS (an option, the
   nanoplot rules, `extraCss`) changes the class, and nothing else does. Alternative: hash
   `$t.options` — misses the nanoplot bit, and changes the class when an option that writes no CSS
   (a locale) changes.
2. **The div keeps its id.** `<div id="planets" class="tabella tb-s-1a2b3c4d">`: links,
   `aria-labelledby` and the docs' anchors keep working; `id = "..."` keeps its meaning.
3. **`toHtml(t, makePage = false, withStyle = true)`**, **`tableStyle(t): string`** (the
   `<style>` element) and **`styleClass(t): string`**. `withStyle = false` is the building block;
   the core keeps no state.
4. **Once per page lives in `tabelline/nimib`.** `nb.table(t)` looks up `styleClass(t)` in a set
   kept in the page's context (`nb.doc.context`, a JsonNode, so a new `nbInit` starts empty) and
   adds the style only the first time. `nb.tableHtml(t)` is the same rule for blocks that render
   a table inside their own HTML; the docs' blocks switch to it. The style stays inside the first
   table's `<div>`: a `<style>` in the body applies to the whole page, so a later table of the
   same class is styled, also when the first sits in a tab or a fold that is closed.
5. **`#` rules of `extraCss` are kept as written.** As today; they name one table and still apply
   only to it. They do change the class, so such a table gets a style of its own.

## Risks / Trade-offs

- **Specificity drops** from an id (1,1,0) to a class (0,2,0). A page rule such as
  `.tabella .tb_title` (docs theme) ties instead of losing, and since the table's `<style>` comes
  after the theme, tabelline still wins the tie; a page rule stronger than two classes
  (`.content .tabella table tr` in the book) now wins over tabelline's rule on the same property.
  Mitigation: screenshot every page of the docs and the book before and after (390 px, Munari)
  and compare; fix the page rule, not the scoping.
- **Order on the page.** A table further down a page depends on a `<style>` above it. If a block
  is moved or deleted by hand in the built HTML the style can go with it; nimib pages are
  rebuilt, not edited, so this is accepted.
- **Hash collisions** between two different styles on one page: 32 bits over a handful of
  styles per page; accepted, as for ids today.
- **The review mode and copy of a table**: copying one table's HTML from a page (not the first)
  gives it without style. `toHtml(t)` alone is still the way to get a table to paste elsewhere.
