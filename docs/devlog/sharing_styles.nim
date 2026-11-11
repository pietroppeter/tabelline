## devlog: 11 Nov 2026 A | One stylesheet for every table | Every tabelline table carries its own 6 KB of CSS, and a page with many tables carries it many times: a quarter of the site is repeated CSS. What a table's HTML holds, three ways to share its style, the one we chose (fixed rules, options as CSS variables), and a CSS trick that keeps a page's theme winning and losing exactly as before.
## A dated post: it tells why and how tables share their style (change `share-table-styles`), and is not updated afterwards.
import std/os
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "sharing-styles" / "index.html"
nb.useTabelline(title = "One stylesheet for every table", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026", "One stylesheet for every table", """
Every tabelline table carries its own 6 KB of CSS, and a page with many tables carries it many
times: a quarter of the site is repeated CSS. What a table's HTML holds, three ways to share its
style, the one we chose, and a CSS trick that keeps a page's theme winning and losing exactly as
before.
"""

nbText: """
The [API reference](https://github.com/pietroppeter/tabelline/pull/65) being built has 156 tables, one for every proc, and weighs 1.9 MB.
1.1 MB of it is CSS, the same rules 156 times. Pietro: "We should share CSS as much as possible,
how to do that?" This post is the answer, from what a table is made of to how the change is
built. It is planned in the OpenSpec change `share-table-styles` and not built yet.

## What a table's HTML holds

`toHtml(t)` writes three things, one inside the other: a `div` with an id, a `style` element,
and the `table` itself.

```html
<div id="tabella-8f3a" class="tabella">
<style>
#tabella-8f3a .tb_table { font-size: 16px; border-top: 2px solid gray; ... }
#tabella-8f3a .tb_title { font-size: 125%; ... }
...                                      (about 90 rules, 6 KB)
</style>
<table class="tb_table"> ... the cells ... </table>
</div>
```

The style is the table's look, made from its options: fonts, borders, colours, paddings. Every
rule starts with the table's id, so it reaches only that table: two tables with different
options on one page do not disturb each other. That is how gt and Great Tables do it too.

What is not in it: the data, and the styles of single cells (`tabStyle`), which sit on the cells
themselves. So the 90 rules are the same for every table; only the values change, and the id.

## How much of the site it is

Measured on the built site of 10 November (23 pages, the book not counted).
"""

block:
  type Size = object
    page: string
    size, styles: float
    tables, looks: int
  let rows = @[
    Size(page: "Specs", size: 695, styles: 401, tables: 72, looks: 2),
    Size(page: "Designing tabelline 0.1", size: 461, styles: 282, tables: 51, looks: 7),
    Size(page: "Milano Cortina", size: 512, styles: 194, tables: 32, looks: 5),
    Size(page: "Guide", size: 489, styles: 159, tables: 27, looks: 8),
    Size(page: "Designing tabelline 0.2", size: 335, styles: 148, tables: 24, looks: 2),
    Size(page: "Rethinking the datasets", size: 289, styles: 97, tables: 16, looks: 1)]
  let t = tabella(rows, rownameCol = "page"):
    tabHeader "Repeated CSS", "the six pages with the most table styles"
    colsLabel {"size": "page (KB)", "styles": "table styles (KB)", "tables": "tables", "looks": "different looks"}
    fmtNumber ["size", "styles"], decimals = 0
    tabSourceNote "All 23 pages: 6.68 MB, of which 1.71 MB table styles."
    optCssTheme()
  nbTable t

nbText: """
The specs page has 72 tables and only two looks: 400 KB of CSS where 12 KB would do.

## Three ways to share

**A class for each look.** Name each table's style after a hash of it (`tb-s-1a2b3c4d`), scope
the rules to that class, and write each style once per page. Tables with the same options share
it. It works, but it needs hashes, a list of the styles already written, and three new procs, and
every different look still costs 6 KB.

**Merge after the page is built.** Read every table's CSS once the page is done, and merge the
rules that are the same. It keeps everything as it is, but needs a CSS parser and a step after
nimib saves the page: the most work for the same result.

**One stylesheet, options as variables.** The 90 rules become one fixed stylesheet,
`tabellaCss`, the same for every table, and each value is read from a CSS variable with the
default as fallback:

```css
.tabella .tb_title { font-size: var(--tb-heading-title-font-size, 125%); }
.tabella .tb_table { font-size: var(--tb-table-font-size, 16px); }
```

A table carries only the options it changes, on its `div`; a table with the default options
carries nothing.

```html
<div id="planets" class="tabella" style="--tb-table-font-size: 14px">
<table class="tb_table"> ... </table>
</div>
```

We chose the third. It is the simplest to explain (one stylesheet, options as variables), there is
nothing to keep track of, and the 156 tables of the reference page cost one stylesheet and a few
variables each. It also gives something new: a page can set an option for all its tables at once,
`.tabella { --tb-table-font-size: 14px }`.
"""

nbNote """
In nimib nothing changes: `nbTable t` writes `tabellaCss` with the first
table of a page and leaves it out of the others. Alone, `t.toHtml` works as today: the stylesheet
comes in front of the table, ready to paste anywhere. A page or a tool of your own writes
`tabellaCss` once, or links it as a file for a whole site, and then `t.toHtml(withStyle = false)`
for every table.
""", nkInfo, "Using it"

nbText: """
## The risk, and a trick

When two CSS rules set the same thing on the same element, the one with the heavier selector
wins: an id weighs more than any number of classes, a class more than any number of element
names. Only when the weights are equal does the later rule win.

Today every tabelline rule names an id, so it beats almost any rule of a page's theme. The
plain version of the stylesheet names only classes (`.tabella .tb_title`), which is lighter: a
theme rule that lost before could now win, and a table would change its look on some page, with
no change to the table.

The fix is a CSS idiom. `:not(#_)` matches every element whose id is not `_`, that is every
element, and it weighs as much as an id. `:where(...)` matches what is inside it and weighs
nothing. So every rule of the stylesheet starts with

```css
:where(.tabella):not(#_) .tb_title { font-size: var(--tb-heading-title-font-size, 125%); }
```

which matches every table and weighs exactly what `#tabella-8f3a .tb_title` weighs today.
"""

nbText: """
Weights, from light to heavy: `.tabella .tb_title` is two classes; `#tabella-8f3a .tb_title`
and `:where(.tabella):not(#_) .tb_title` are one id and one class. Here is what happens to two
rules a page's theme could have, against the table's own rule for the title.
"""

block:
  type Weight = object
    rule, today, plain, trick: string
  let rows = @[
    Weight(rule: "`main .tabella .tb_title`", today: "loses", plain: "wins", trick: "loses"),
    Weight(rule: "`#page .tabella .tb_title`", today: "wins", plain: "wins", trick: "wins")]
  let t = tabella(rows, rownameCol = "rule"):
    tabHeader "Who wins", "a theme's rule against the table's"
    colsLabel {"today": "today", "plain": "plain classes", "trick": "with the trick"}
    tabStubhead "theme rule"
    fmtMarkdown ["rule"]
    tabSourceNote "Checked in Chromium; :where is in every browser since 2021."
    optCssTheme()
  nbTable t

nbText: """
The screenshots of every page of the site and the book, before and after, still check it: a
difference is a bug in the stylesheet.

## How it is built

From the change `share-table-styles`, in the order it will be written.

1. `tabellaCss`, a constant in `render_html.nim`: the rules of today's `tableCss`, each starting
   with `:where(.tabella):not(#_)`, each value `var(--tb-<option>, <default>)`, where the option
   is the field of `TabOptions` in kebab-case (`tableFontSize` is `--tb-table-font-size`). An
   option that falls back to another nests: `var(--tb-heading-background-color,
   var(--tb-table-background-color, white))`. The nanoplot rules are in it too.
2. `toHtml` compares the table's options with the defaults and writes each one that differs as a
   variable on the `div`. What Nim works out today (white text on a dark heading) it still works
   out, and writes as a variable.
3. `toHtml(t, withStyle = true)`: with the stylesheet in front, as today; `false` without.
4. `optCss`, a table's own extra rules, stays in a `style` of that table, scoped to its id.
5. `nbTable` keeps a flag in the page's context: the first table writes `tabellaCss`, the others
   do not. `nb.tableHtml(t)` does the same for blocks that put a table inside their own HTML.
"""

nbSave
