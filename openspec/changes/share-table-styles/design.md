# Design

## Context

`render_html.nim` writes `tableCss(id, options)`: about 90 rules, each prefixed with `#id`, with
the option values written into them, plus the nanoplot rules when the body has a nanoplot, plus
`extraCss` (`optCss`) scoped the same way unless a rule already starts with `#`. Cell styles
(`tabStyle`) are inline `style=""` attributes and do not take part. So the rules are the same for
every table; only the values and the id change. `nbTable` stores `t.toHtml` in a block. Some docs
blocks (`nbParts`, `nbTabs` and others in `docs/blocks.nim`) call `toHtml` themselves.

Measured on `main` today (23 built pages of the docs, book not counted): 6.68 MB of HTML, 1.71 MB
of it table styles. With the rules written once per page, about 6 KB a page plus a few variables
per table: about 0.15 MB. The specs page goes from 695 KB to about 300 KB, designing-0-1 from 461
to about 210 KB; the reference page of PR #65 (156 tables) loses about 1.1 MB.

## Goals / Non-Goals

**Goals:**
- A page holds the rules of its tables once; each table holds only what it changes.
- Simple to explain: one stylesheet, options as variables.
- `toHtml(t)` alone still gives a fragment that works anywhere, as today.
- Built pages stay stable: the same table gives the same HTML.

**Non-Goals:**
- Smaller rules (dropping rules equal to the browser's defaults). A separate idea for BACKLOG.
- Inline CSS on every element (gt's `inline_css`), for e-mail.

## Decisions

1. **One stylesheet, `tabellaCss*: string`, a constant.** The rules of `tableCss` today, with
   `#id` replaced by `.tabella` and every option value by `var(--tb-<option>, <default>)`, where
   `<option>` is the field of `TabOptions` in kebab-case (`tableFontSize` is
   `--tb-table-font-size`). Defaults that come from another option nest:
   `var(--tb-heading-background-color, var(--tb-table-background-color, #FFFFFF))`, as
   `tableCss` falls back today. The nanoplot rules are in it too (they only match a nanoplot).
2. **A table's variables on its `<div>`.** `toHtml` compares the table's options with the
   defaults and writes each one that differs as `--tb-<option>: <value>` in the `style` of the
   `<div>`. Values Nim works out today (the white text on a dark heading, `onDark`) are worked
   out the same way and written as a variable. The div keeps its id; links and
   `aria-labelledby` keep working.
3. **`toHtml(t, makePage = false, withStyle = true)`.** With `withStyle`, the fragment starts with
   `<style>` + `tabellaCss`, so it works alone, as today. `withStyle = false` leaves it out. A
   site can write `tabellaCss` to a file and link it.
4. **`optCss` stays per table.** Its rules are the table's own, so they stay in a `<style>` in the
   table's div, scoped to `#id` as today (`#` rules as written). It is rare in the docs.
5. **Once per page lives in `tabelline/nimib`.** `nb.table(t)` writes `withStyle = true` for the
   first table of the page and `false` after, with a flag in the page's context
   (`nb.doc.context`, so a new `nbInit` starts again). `nb.tableHtml(t)` is the same rule for
   blocks that render a table inside their own HTML; the docs' blocks switch to it. A `<style>`
   in the body applies to the whole page, so a later table is styled even when the first sits in
   a tab or a fold that is closed.

## Alternatives considered

- **A class named after a hash of each table's style** (the first version of this proposal):
  each distinct style written once. Smaller when a page has one or two looks, but every distinct
  look still costs ~6 KB, and it needs hashes, a set of classes per page and three new procs.
- **Merge the rules of all tables after the page is built**: needs a CSS parser and a step after
  nimib saves the page. The most work for the same result.

## Risks / Trade-offs

- **Specificity drops** from an id (1,1,0) to classes (0,2,0). A page rule such as
  `.tabella .tb_title` (docs theme) ties instead of losing, and since `tabellaCss` comes after the
  theme in the page, tabelline still wins the tie; a page rule stronger than two classes
  (`.content .tabella table tr` in the book) now wins over tabelline's rule on the same property.
  Mitigation: screenshot every page of the docs and the book before and after (390 px, Munari)
  and compare; fix the page rule, not the stylesheet.
- **Variables inherit.** A `--tb-…` variable set on a page (`.tabella { --tb-table-font-size:
  14px }` or on `body`) reaches every table that does not set it itself. That is a feature (a
  page theme in one line) and is documented as such; nothing in the docs sets `--tb-` today.
- **Order on the page.** Tables further down depend on the `<style>` of the first. nimib pages
  are rebuilt, not edited, so this is accepted. Copying a table other than the first out of a
  built page gives it without the rules; `toHtml(t)` is the way to get a table to paste.
