## The Design Ref, docs/design/index.html: the graphical choices of tabelline's pages, and the
## reference for writing one. The two looks, the shapes and what they mean, the colours, the type,
## and every component, each shown live with a rule for when to use it. A living document: it
## changes in the PR that changes the design (docs/quaderno.nim, docs/munari.nim), and big design
## changes start as a devlog post that ends here.
import std/[os, strformat]
import nimib except md
import tabelline, tabelline/nimib
import quaderno

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "design" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Design Ref", classe = "living document",
               title = "tabelline Design Ref", homeHref = "../",
               description = "The design of tabelline's pages: two looks, shapes that carry meaning, colours, type and every component, with when to use each.")

nbRawHtml: """<style>
.tinte-ref { list-style: none; padding: 0; margin: 1rem 0; }
.tinte-ref li { display: grid; grid-template-columns: 2.4rem 1fr; gap: 0 .8rem; padding: .5rem 0; border-top: 1px solid var(--rule, #C9D9EC); }
.tinte-ref li:last-child { border-bottom: 1px solid var(--rule, #C9D9EC); }
.tinte-ref .tinta { grid-row: span 2; width: 2.4rem; height: 2.4rem; outline: 1px solid rgba(0,0,0,.12); }
.tinte-ref .cerchio-t { border-radius: 50%; } .tinte-ref .triangolo-t { clip-path: polygon(50% 0, 100% 100%, 0 100%); outline: 0; }
.tinte-ref code { font-size: .8em; }
.tinte-ref .usi { font-size: .92rem; line-height: 1.4; }
.forme-ref { display: flex; gap: 1.6rem; flex-wrap: wrap; margin: 1rem 0; }
.forme-ref div { display: flex; gap: .7rem; align-items: center; flex: 1 1 12rem; font-size: .95rem; line-height: 1.35; }
.forme-ref i { flex: 0 0 2rem; height: 2rem; display: block; }
.forme-ref .c { border-radius: 50%; background: var(--m-cerchio, #E53935); }
.forme-ref .q { background: var(--m-quadrato, #1F4E99); }
.forme-ref .t { background: var(--m-triangolo, #F2C200); clip-path: polygon(50% 0, 100% 100%, 0 100%); }
.galleria { display: flex; align-items: flex-start; gap: .8rem; overflow-x: auto; scroll-snap-type: x mandatory;
  padding: .2rem 0 .8rem; -webkit-overflow-scrolling: touch; }
.galleria::after { content: ""; flex: 0 0 .2rem; }
.scheda { flex: 0 0 min(80%, 18rem); scroll-snap-align: start; padding: .7rem .9rem .8rem;
  border: 1px solid color-mix(in srgb, currentColor 18%, transparent); }
.scheda .numero { font: 700 .72rem/1.2 system-ui, sans-serif; letter-spacing: .14em; text-transform: uppercase; opacity: .6; }
.scheda h3 { margin: .15rem 0 .3rem !important; font-size: 1.1rem !important; }
.scheda p { margin: 0; font-size: .92rem; line-height: 1.45; }
.esempio { border: 1px dashed color-mix(in srgb, currentColor 30%, transparent); padding: .2rem 1rem; margin: 1rem 0; }
.esempio > .parte { font: 700 .66rem/1.4 system-ui, sans-serif; letter-spacing: .18em; text-transform: uppercase; opacity: .55; margin: .4rem 0 0; }
</style>"""

nbText: """
<p class="kicker">Design Ref · living document · started 8 November 2026</p>

# How tabelline's pages look, and why

<p class="lede">Every page of tabelline is drawn from a few pieces: two looks, three shapes, six
colours, one typeface and a dozen components. This page shows each of them, says what it means
and when to use it. It is the reference for writing a new page.</p>

The page is in the look you picked at the top: switch it to see every example in the other one.
This first version records the design as it is on 8 November 2026; the devlog post that reviews
it (palette by roles, every component) will change it.
"""
nbIndice

nbText: """
## Two looks

Every page carries two looks, and the reader picks one with the switch in the header; the choice
is remembered. Both are in the same standalone HTML file: fonts inlined, nothing loaded from
elsewhere.

- **Munari**, the default, after Bruno Munari's books on the square, the circle and the
  triangle: flat paper, one geometric sans, black rules, and colour only where it means something.
- **Quaderno**, an Italian school exercise book: squared paper, a red margin, headings in blue
  pen with a highlighter stroke, code on index cards, outputs on sticky notes, tables taped in.

Without JavaScript a page shows as a quaderno. Everything Munari does is scoped by
`html[data-tema="munari"]`, so the quaderno rules are untouched by it.

## Three rules

1. **Simplest first.** A page starts from zero and goes from the simplest, most fundamental
   thing to the most complex; a living document ends with *How it is built*.
   *Complicare è facile, semplificare è difficile* (Munari).
2. **Shapes carry meaning.** In Munari each shape has one job, everywhere:
"""

nbRawHtml: """<div class="forme-ref">
<div><i class="c"></i><span><strong>circle</strong>: a section. Every <code>##</code> heading and every entry of the indice.</span></div>
<div><i class="t"></i><span><strong>triangle</strong>: a warning, and only that. (The big triangle on the cover is the one exception.)</span></div>
<div><i class="q"></i><span><strong>square</strong>: on the cover only, for now. Free for a meaning the review gives it.</span></div>
</div>"""

nbText: """
3. **Nothing that only decorates may look like something to press or drag.** No dots, holes or
   knobs on cards. What looks like a button is a button (the look switch, the tabs, *Show the
   parts*).

## Colours

A Munari page is drawn with six colours, named after where they go rather than their hue, so a
palette is six values. The default palette is **Haru** (spring), from Japan's traditional colour
names; the devlog post [Munari meets Japan](../devlog/palettes/) tells how it was chosen and lets
you try five others on the page. Everything else is mixed from the six with `color-mix`: tints
for notes, rules, greys, and darker versions of the colours used as text.
"""

nbRawHtml: """<ul class="tinte-ref">
<li><span class="tinta" style="background:var(--m-carta, #FCFAF2)"></span><span><strong>paper</strong> <code>--m-carta</code></span><span class="usi">the page; mixed into every tint</span></li>
<li><span class="tinta" style="background:var(--m-inchiostro, #1C1C1C)"></span><span><strong>ink</strong> <code>--m-inchiostro</code></span><span class="usi">text, headings, links, rules, code edges, the look switch, the tabs</span></li>
<li><span class="tinta cerchio-t" style="background:var(--m-cerchio, #E16B8C)"></span><span><strong>circle</strong> <code>--m-cerchio</code></span><span class="usi">section markers and the indice; kickers, <code>###</code> headings, link underlines; code keywords; the rosa note; the line under a table's heading</span></li>
<li><span class="tinta" style="background:var(--m-quadrato, #7DB9DE)"></span><span><strong>square</strong> <code>--m-quadrato</code></span><span class="usi">code strings; the azzurra note (living documents)</span></li>
<li><span class="tinta triangolo-t" style="background:var(--m-triangolo, #F7D94C)"></span><span><strong>triangle</strong> <code>--m-triangolo</code></span><span class="usi">never text (too light); the plain note, table group headings, quotes, link hover, highlights</span></li>
<li><span class="tinta" style="background:var(--m-quarto, #86C166)"></span><span><strong>fourth</strong> <code>--m-quarto</code></span><span class="usi">the verde note; numbers and literals in code</span></li>
</ul>"""

nbText: """
The quaderno has its own fixed colours: blue pen `#1F4E99`, red margin `#E53935`, squares
`#DCEBFA`, post-it yellow, and pastel notes (`#DDF7DA`, `#FDE0EA`, `#DDEEFF`).

**Rule:** in Munari, never write a fixed colour in a page; mix it from the six variables. A
tabelline colour can be a variable too: `fmtBar(color = "var(--m-quadrato)")`.

## Type

- **Munari**: one sans, [Jost](https://github.com/indestructible-type/Jost) (OFL), after the
  geometric types of the 1920s, for headings and text alike; big and plain.
- **Quaderno**: Patrick Hand for what is handwritten (headings, labels, the indice), Atkinson
  Hyperlegible for the text.
- **Code**: the system monospace at 13.5px, smaller than the text; in a gallery card 12.5px.

## Components

From the simplest to the most complex. Each one shows live in the current look.

### Kicker, title and lede

A page opens with a kicker (what it is and when), a `#` title and a lede: one paragraph that says
what the page gives the reader.
"""

nbRawHtml: """<div class="esempio"><p class="parte">example</p>
<p class="kicker">Living document</p><p style="font-size:1.6rem;font-weight:700;margin:.2rem 0">A title</p>
<p class="lede">The lede: what this page gives you, in one or two sentences.</p></div>"""

nbText: """
**Use** `<p class="kicker">` and `<p class="lede">` in an `nbText`; in a devlog post the kicker
is the date.

### Headings and the indice

`##` is a section (with the circle in Munari) and goes in the indice; `###` is a subsection,
in the circle's colour, indented in the indice. `nbIndice` puts the indice where you call it,
usually right after the lede. Don't go deeper than `###`.

### Notes

A note is a piece of flat coloured paper: a remark next to the text, or a card. `nbNota(text,
color)` makes one; the colours today:
"""

nbNota("**plain** (`\"\"`): a remark, an aside.")
nbNota("**azzurra**: a living document, or a page to go to.", "azzurra")
nbNota("**verde**: what is done, what works.", "verde")
nbNota("**rosa**: what is missing, or a difference from gt and Great Tables.", "rosa")

nbText: """
The meaning of the colours is a habit more than a rule yet; the review will fix it.

### Cards

Notes in a grid (`<div class="cards">`), each with a title (`<span class="titolo">`): a menu of
pages, as on the home page.
"""

nbRawHtml: """<div class="cards">
<div class="nota azzurra"><span class="titolo"><a href="../explainer/">The Great Explainer</a></span>A card links somewhere and says in a line what is there.</div>
<div class="nota azzurra"><span class="titolo"><a href="../devlog/">Devlog</a></span>Cards of a grid share one colour when they are the same kind of thing.</div>
</div>"""

nbText: """
### Code and its output

Code that ran is shown on a white sheet (Munari: a black edge; quaderno: an index card), its
output under it on grey paper (quaderno: a sticky note). Every `pre` scrolls sideways rather than
spilling out of its box. Code that is shown and not run (Python, R) is highlighted the same way.
"""

nbCode:
  let answer = 6 * 7
  echo "the answer is ", answer

nbText: """
### Tabs: Nim, Python, R

The same example in three languages: Nim runs, Python (Great Tables) and R (gt) are shown. The
choice holds for the whole page. `nbTabs(python, r): body`.
"""

nbTabs("""print(6 * 7)""", """print(6 * 7)"""):
  nbCode:
    echo 6 * 7

nbText: """
### Tables

A tabelline table is placed with `nbTable`. In Munari it gets a black rule above and below and
nothing else; in the quaderno it is taped in, on squared paper. Today the tables of the docs add
`optQuaderno()`, the quaderno's own colours, and Munari dresses them again with `!important`
rules: the review will replace this with a preset that follows the look.
"""

nbCode:
  let tre = tableData:
    tabellina: ["2 × 3", "4 × 5", "6 × 7"]
    risultato: [6, 20, 42]
  let t = tabella(tre, rownameCol = "tabellina"):
    tabHeader "Three tabelline"
    optQuaderno()
nbTable t

nbText: """
### Galleries

A row of small cards to swipe sideways (or scroll with a trackpad): a sequence the reader steps
through, simplest first, without making the page long. Each card is one step with a number, a
title, a line and, often, code and the table it makes. Used in
[Designing tabelline 0.1](../devlog/designing-0-1/) and
[Munari meets Japan](../devlog/palettes/).
"""

var cards = ""
for i, (title, line) in [("One idea", "A card holds one step, no more."),
                         ("Simplest first", "The first card is the simplest; each adds one thing."),
                         ("A number", "The number says where you are in the row."),
                         ("Side by side", "On a phone, one card and the edge of the next are in view.")]:
  cards.add &"""<div class="scheda"><span class="numero">{i + 1} of 4</span><h3>{title}</h3><p>{line}</p></div>"""
nbRawHtml: &"""<div class="galleria" tabindex="0" aria-label="a gallery: swipe or scroll sideways">{cards}</div>"""

nbText: """
Each post copies the gallery's CSS today; it will move into the theme.

### Quotes and highlights

> A quote has a triangle-yellow edge in Munari, and is a sticky note in the quaderno.

A <mark>highlight</mark> marks a word in the text.

## Writing a page

- Order from the simplest and most fundamental to the most complex, from zero.
- Put small examples side by side, or in a gallery, rather than one long column.
- Write code in the order the reader meets it: define a value before using it.
- One marker for headings and the indice (the circle); the triangle only marks warnings.
- Check every new element in both looks, and at phone width (390px): nothing may be wider than
  the screen.
- A living document is kept up to date; a devlog post is dated and not updated afterwards.

## Open questions, for the review

What the design review (a devlog post) will look at and decide:

- **A palette by roles**: a neutral scale, a primary, a secondary and accents (warning,
  success, info), covering every component, instead of six colours named after shapes.
- **What the note colours mean**, and whether a warning note (the triangle) is needed.
- **Galleries** in the theme, as a component with its own helper, not copied per post.
- **A table preset that follows the look**, instead of `optQuaderno()` dressed again by Munari.
- **Tables wider than a phone**: some tables of the explainer push the page wider than 390px;
  wide tables should scroll in their own box (a BACKLOG item).
- **The quaderno's fixed colours**, mixed from variables as Munari's are.

## How it is built

A page calls `nb.useQuaderno(...)` right after `nbInit` (`docs/quaderno.nim`). That replaces
nimib's header, footer and text partials and puts into the `<head>` one `<style>` with both
looks: the fonts as base64 `@font-face` rules, the quaderno CSS, and the Munari CSS
(`docs/munari.nim`), all of whose rules start with `html[data-tema="munari"]`.

A few lines of script in the `<head>` set `data-tema` on `<html>` before the page is drawn: from
`?tema=` in the link, else from `localStorage` (`tabelline-tema`), else `munari`. The switch in
the header changes it and remembers it.

The six colours are CSS variables on `html[data-tema="munari"]`; every other colour is a
`color-mix` of them, so a palette is changed in one place. Components are plain HTML with
classes (`nota`, `cards`, `indice`, `lingue`) and a few nimib templates that write them
(`nbNota`, `nbIndice`, `nbTabs`).
"""
nbSave
