## The Design Ref, docs/design/index.html: how tabelline's pages look and why, and the reference
## for writing one. In three parts: the foundations (two looks, the rules, shapes, the palette by
## roles, type), the blocks a page is made of (each shown live, with its code), and how to write
## and build a page. A living document: it changes in the PR that changes the design
## (docs/stile.nim, docs/blocchi.nim); big design changes start as a devlog post that ends here.
import std/[os, strformat]
import nimib except md
import tabelline, tabelline/nimib
import blocchi

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "design" / "index.html"
nb.useTabelline(nome = "tabelline", materia = "Design Ref", classe = "living document",
               title = "tabelline Design Ref", homeHref = "../",
               description = "The design of tabelline's pages: two looks, shapes for kinds, a palette by roles, and the blocks every page is made of.")

nbTitolo "Design Ref · living document · started 8 November 2026", "How tabelline's pages look, and why", """
Every page of tabelline is made of a few pieces: two looks, three shapes, a palette by roles, one
typeface and a dozen blocks. This page shows each of them live, says what it means and when to
use it, and how it is built. It is the reference for writing a new page.
"""
nbText: """
The page is in the look you picked at the top: switch it to see every example in the other one.
It is in three parts, and each part's sections carry its colour, a way of showing a long page's
parts that this page tries first. The design comes from two devlog posts of 8 November 2026,
[Reviewing the design](../devlog/design-review/) and [Blocks, not HTML](../devlog/blocks-review/).
"""
nbIndice

# =========================================================================== part 1: foundations
nbParte 1, "Foundations", prPrimary
nbText: """
## Two looks

Every page carries two looks, and the reader picks one with the switch in the header; the choice
is remembered. Both are in the same standalone HTML file: fonts inlined, nothing loaded from
elsewhere.

- **Munari**, the default, after Bruno Munari's books on the square, the circle and the
  triangle: flat paper, one geometric sans, black rules, and colour only where it means something.
- **Quaderno**, an Italian school exercise book: squared paper, a red margin, headings in blue
  pen with a highlighter stroke, code on index cards, outputs on sticky notes, tables taped in.

Munari is the page itself: its rules need no script, so a page without JavaScript (or before
its script runs) is Munari. The quaderno is the other look, kept because it shows that a page and
its tables work just as well in a very different theme: everything it changes is scoped by
`html[data-tema="quaderno"]`.

## Three rules

1. **Simplest first.** A page starts from zero and goes from the simplest, most fundamental
   thing to the most complex; a living document ends with *How it is built*.
   *Complicare è facile, semplificare è difficile* (Munari).
2. **Shape for kind, colour for role.** A shape says what kind of thing it is; a colour says
   which role it plays. Each shape has a default colour and takes another only for a reason that
   can be said in words.
3. **Nothing that only decorates may look like something to press or drag.** No dots, holes or
   knobs on cards. What looks like a button is a button (the look switch, the tabs, *Show the
   parts*).

## Shapes

- **The circle is a place in the page**: every `##` section and its entry in the indice. Its
  default colour is the primary; in a page in parts, it takes the colour of its part (as here).
- **The triangle is a warning**, and only that: drawn as a road sign, yellow with an ink edge,
  so it shows on its own pale yellow note.
- **The square is a sheet set apart**: a note, a card, a card of a gallery. It is the shape of
  the sheet itself, drawn as its straight top edge in the colour of its kind (secondary unless a
  reason says otherwise), never as a separate mark that could look like a checkbox.
"""
nbNota "A warning: the triangle, on its note.", nkWarning
nbCards "a card and a note, to show the square":
  nbCard "A card", "", "1":
    nbText "A sheet set apart, with the square's top edge in the secondary."
  nbCard "A note of a kind", "", "2", nkDone:
    nbText "The edge takes the colour of the kind: here, done."

nbText: """
## The palette, by roles

Each look gives six values: **paper**, **ink**, and four colours with a role. Every other colour
is mixed from them in the browser (`color-mix(in oklab, …)`), so a palette is six values and the
devlog post [Munari meets Japan](../devlog/palettes/) can try others on the page. Munari's
default palette is **Haru**, spring, from Japan's traditional colour names; the quaderno's
primary is its blue pen and its secondary the red pen.

### Neutral

Ten steps from paper to ink (0, 4, 8, 14, 25, 40, 55, 65, 80 and 100% of ink), and
`--surface`, a sheet a little whiter than the paper, for code and tables. They do most of the
work: the page, the text, rules, code backgrounds, grey text.
"""
nbTinte [("--n-0", "`--n-0`", "the page"), ("--n-1", "`--n-1`", "outputs, plain notes"),
         ("--n-3", "`--n-3`", "rules, row lines"), ("--n-7", "`--n-7`", "grey text"),
         ("--n-9", "`--n-9`", "text, edges"), ("--surface", "`--surface`", "code, tables")]

nbText: """
### Four roles

Each role has the colour itself (`--primary`), for shapes and edges; a **soft** version mixed
into the paper (`--primary-soft`, 22%), for backgrounds; and a **text** version mixed with ink
(`--primary-text`, 50%), dark enough to read on paper and on its soft. The warning has no text
version: **the warning colour is never text**, a warning is ink on its soft, with the triangle.
"""
nbTinte [("--primary", "primary", "the circle: sections, kickers, link underlines, keywords"),
         ("--secondary", "secondary", "the square: information, living documents, strings, bars"),
         ("--warning", "warning", "the triangle: warnings, and the highlighter"),
         ("--success", "success", "what is done, what works; numbers in code"),
         ("--primary-soft", "`--primary-soft`", "a note of what is missing"),
         ("--secondary-text", "`--secondary-text`", "text in the secondary")]

nbText: """
**Data** colours come from the roles too: categorical (the seven tints of the parts of a table,
`partTints`), sequential (from `--n-0` to `--secondary`) and diverging (from `--secondary`
through the paper to `--primary`). A tabelline colour can be a CSS variable, so a table can use
them directly: `style.fill("var(--secondary)")`.

**Rule:** never write a fixed colour in a page. Name a token; if none fits, the token is missing
and goes in `docs/stile.nim`.

## Type

- **Munari**: one sans, [Jost](https://github.com/indestructible-type/Jost) (OFL), after the
  geometric types of the 1920s, for headings and text alike; big and plain.
- **Quaderno**: Patrick Hand for what is handwritten (headings, labels, the indice), Atkinson
  Hyperlegible for the text.
- **Code**: the system monospace at 13px, smaller than the text; 12.5px under a table.
"""

# ================================================================================ part 2: blocks
nbParte 2, "Blocks", prSecondary
nbText: """
## The page and its title

A page is a nimib notebook that calls `nb.useTabelline(...)` right after `nbInit`: both looks,
the header with the switch and the cover label, the footer. Then `nbTitolo` opens it with a
kicker (what it is and when; in a post, the date), the title, and a lede that says what the page
gives the reader. Everything below is a block: each section shows one live, with its code folded
under it.
"""
nbShowCode:
  nbTitolo "Living document", "A title", "The lede: what this page gives you, in a sentence or two."

nbText: """
## Headings and the indice

`##` is a section (the circle, in Munari) and goes in the indice; `###` is a subsection, in the
primary's text colour, indented in the indice. `nbIndice` puts the indice where it is called,
usually right after the title. Don't go deeper than `###`. A long page can be split in parts
with `nbParte(number, title, role)`: from there on, its sections take the part's colour.

## Notes

A note is a sheet set apart, beside the text, in Markdown. Its kind is an enum, `NotaKind`, so a
kind spelled wrong does not compile; its colour follows from the kind.
"""
nbShowCode:
  nbNota "**plain**: an aside."
  nbNota "**info**: information, a page to go to.", nkInfo
  nbNota "**done**: what is done, what works.", nkDone
  nbNota "**missing**: a gap, or a difference from gt and Great Tables.", nkMissing
  nbNota "**warning**: the API will change.", nkWarning, "A note can have a title"

nbText: """
## Cards

Cards in a grid: a menu of pages, as the living documents on the home page. A card has a title
(a link when it has an address), a small number, a kind (info by default) and any blocks inside.
"""
nbShowCode:
  nbCards "two living documents":
    nbCard "The Great Explainer", "../explainer/", "1":
      nbText "A card links somewhere and says in a line what is there."
    nbCard "Devlog", "../devlog/", "2":
      nbText "Cards of a grid share a kind when they are the same kind of thing."

nbText: """
## Code and its output

Code that ran is shown on a white sheet (Munari: a black edge; quaderno: an index card), its
output under it on grey paper (quaderno: a sticky note). Every block scrolls sideways rather than
spilling out of its box. Code fences in Markdown (Nim, Python, R) are highlighted the same way.
"""
nbCode:
  let answer = 6 * 7
  echo "the answer is ", answer

nbText: """
## Tabs: Nim, Python, R

The same example in three languages: Nim runs, Python (Great Tables) and R (gt) are shown. The
tab picked holds for the whole page.
"""
nbShowCode:
  nbTabs("print(6 * 7)", "print(6 * 7)"):
    nbCode:
      echo 6 * 7

nbText: """
## Tables

A tabelline table is placed with `nbTable` and takes `optPageTheme()`: its colours are the tokens,
so it follows the look (Munari: an ink rule above and below, the primary under the heading; the
quaderno: taped in, on squared paper). `nbShowCode` shows a table with its code folded under it,
and `nbParti` adds a switch that shows the parts of the table in their colours.
"""
nbShowCode:
  let tre = tableData:
    tabellina: ["2 × 3", "4 × 5", "6 × 7"]
    risultato: [6, 20, 42]
  let t = tabella(tre, rownameCol = "tabellina"):
    tabHeader "Three tabelline"
    optPageTheme()
  nbParti t

nbText: """
## Galleries

A row of cards to swipe sideways (or scroll with a trackpad): a sequence the reader steps
through, simplest first, without making the page long. Each card is one step with a number and a
title, and holds any blocks: text, code, the table it makes. Used in
[Designing tabelline 0.1](../devlog/designing-0-1/) and [Blocks, not HTML](../devlog/blocks-review/).
"""
nbShowCode:
  nbGalleria "a gallery: swipe or scroll sideways":
    nbScheda "One idea":
      nbText "A card holds one step, no more."
    nbScheda "Simplest first":
      nbText "The first card is the simplest; each adds one thing."
    nbScheda "Side by side":
      nbText "On a phone, one card and the edge of the next are in view."

nbText: """
## Swatches, quotes and highlights

`nbTinte` shows colours beside their names, as in the palette above: a token or any CSS colour,
a name and what it is for.

> A quote has a grey edge in Munari, and is a sticky note in the quaderno.

A highlight is the warning's soft yellow: a highlighter pen, never a shape, so it can't be taken
for the triangle.
"""

# ================================================================== part 3: writing and building
nbParte 3, "Writing and building", prSuccess
nbText: """
## Writing a page

- Order from the simplest and most fundamental to the most complex, from zero.
- Put small examples side by side, or in a gallery, rather than one long column.
- Write code in the order the reader meets it: define a value before using it.
- **Use blocks.** Markdown in `nbText`, nimib's blocks, `nbTable`, and the blocks above. No HTML
  in `nbText`, no CSS and no colours in a page. When something is needed a second time, it
  becomes a block in `docs/blocchi.nim`, with its CSS in `docs/stile.nim`. `nbRawHtml` is a last
  resort, for a one-off, with a comment that says why.
- Check every new element in both looks, and at phone width (390px): nothing may be wider than
  the screen.
- A living document is kept up to date; a devlog post is dated, and its numbers are frozen as
  snapshots so it does not change afterwards.

`nim r tools/drift.nim` counts, page by page, the HTML, styles, scripts and fixed colours written
outside the blocks and the style; CI fails when a page has more than its count in
`tools/drift.tsv` (the dated posts keep what they had, and the counts only go down).

## Open questions

- **Tables wider than a phone**: some tables of the explainer push the page wider than 390px;
  wide tables should scroll in their own box (a BACKLOG item).
- **Coloured parts**, tried first on this page: do they help a long page, or distract?
- **A Markdown backend** for the blocks, so a page can also be a README.

## How it is built

**The palette.** `docs/stile.nim` holds every styling decision. Each look is six values (a
`Look`): Munari's are CSS variables named after where they go (`--m-carta`, `--m-cerchio`, …) so a
palette can be swapped on the page; the quaderno's are fixed. From them, one rule on `html`
derives every token with `color-mix(in oklab, …)`: `--n-0` to `--n-9`, `--surface`, and a soft
and a text version of each role. The CSS of both looks and of every block uses only the tokens;
the quaderno keeps a few motifs of its own (the squares, the margin, the post-it, the tape).
Munari's rules are written plain, as the page's own; the quaderno's are written once without a
scope, and `stile.nim` puts `html[data-tema="quaderno"]` in front of every selector when it builds
the CSS, so they win over Munari only in the quaderno.

**The blocks.** `docs/blocchi.nim` makes each block with nimib's `newNbBlock`: a type with
fields and a `toHtml` that writes classes, never styles. A leaf block (`nbNota`, `nbTitolo`,
`nbTinte`) is a `func` that adds it and a template that calls the func. A container (`nbCards`,
`nbGalleria`, `nbTabs`, `nbShowCode`) inherits from `NbContainer`: its template opens it with
`nb.withContainer` so the blocks of its body go inside, and its `toHtml` renders them with
`nbContainerToHtml`. The indice is a block too: when the page is saved it reads every `##` and
`###` of the page's text blocks, and the part each is in.

**The page.** `useTabelline` puts the fonts (base64 `@font-face`) and the CSS into one `<style>`,
and replaces nimib's header, footer and text partials: the text partial adds ids to headings and
highlights code fences. A few lines of script in the `<head>` set `data-tema` on `<html>` before
the page is drawn (from `?tema=`, else `localStorage`, else `munari`); one script at the end makes
the switch, the tabs, *Show the parts* and the specs filter work.

**Tables.** `optPageTheme()` is a tabelline preset whose colours are the tokens, each with a plain
fallback (`var(--n-9, #1C1C1C)`), so a table follows the page it is on.
"""
nbSave
