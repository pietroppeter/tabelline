## devlog: 08 Nov 2026 B | What the book found for 0.1 | Porting the Great Tables guide into the tabelline book turned up two bugs and a dozen gaps; 0.1 closed them. What the book found, from the simplest to the most complex, and what it still finds.
## A dated post: it tells what the port of the Great Tables guide found for 0.1, and is not updated afterwards.
import std/os
import nimib except md
import tabelline, tabelline/nimib
import ../quaderno

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "book-found" / "index.html"
nb.useQuaderno(nome = "tabelline",
               title = "What the book found for 0.1", homeHref = "../", backLabel = "Devlog", nameHref = "../../")

nbRawHtml: """<style>
.coppia { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 0 18px; align-items: start; }
.coppia .tabella table { font-size: 14px !important; }
.tabella td code { overflow-wrap: anywhere; }
</style>"""

nbText: """
<p class="kicker">8 November 2026</p>

# What the book found for 0.1

<p class="lede">Porting the Great Tables guide into the tabelline book turned up two bugs and a
dozen gaps; 0.1 closed them. What the book found, from the simplest to the most complex, and what
it still finds.</p>

While 0.1 was being built, a second piece of work ported the *Get Started* guide of Great Tables
into [the tabelline book](../../book/): fourteen pages, every example in Nim next to the original
Python and the same table in R with gt. Writing each example in tabelline is a test no spec
writes: the guide asks for what a user asks for, in the order a user meets it. Whatever
tabelline could not do went to a list, the list went to the build, and the build closed it
before the release. The book now uses what 0.1 added, and its list holds only what is still
open: [What the port found](../../book/gaps.html).

## What 0.1 gained from the book

From the simplest step to the most complex, as a table is made.
"""

block:
  type Found = object
    step, found, now: string
  let rows = @[
    Found(step: "Parts", found: "The subtitle was bold: it is a `th`, and nothing set its weight; in gt and Great Tables it is not",
          now: "Not bold (`headingSubtitleFontWeight`)"),
    Found(step: "Columns", found: "No `colsMoveToEnd`", now: "`colsMoveToEnd`, and `colsReorder`"),
    Found(step: "Formats", found: "No `fmtTime` or `fmtDatetime`; no function for every format",
          now: "`fmtTime`, `fmtDatetime`, and a `formatX` for every format"),
    Found(step: "Options", found: "No `optVerticalPadding`, `optHorizontalPadding`, `optTableOutline`",
          now: "All three, and `optTableLines`"),
    Found(step: "Options", found: "Dark text on a dark heading: `optStylize(style = 2, color = \"red\")` could not be read",
          now: "White text on dark heading and column label backgrounds"),
    Found(step: "Styles", found: "No composite locations: the header, the column header and the footer took their parts one by one",
          now: "`loc.header`, `loc.columnHeader`, `loc.footer`, under their parts as in gt; `loc.spannerLabels`"),
    Found(step: "Styles", found: "`dataColor` over number and text columns stopped with an `IndexDefect`",
          now: "Fixed"),
    Found(step: "Styles", found: "`dataColor` gave all its columns one range, and a domain from high to low one colour",
          now: "Each column on its own; `(90, 0)` runs the palette the other way")]
  let t = tabella(rows, rownameCol = "", groupnameCol = "step"):
    colsLabel {"found": "What the book found", "now": "In 0.1"}
    fmtMarkdown ["found", "now"]
  nbTable t

nbText: """
## Two of them, as tables

The colours of the data, each column on its own, numbers along the palette and text by
category, as Great Tables does by default; and the composite location of the column header,
which sits under its parts, so the blue of `num` given before it still shows.
"""

block:
  let simple = tableData:
    integer: [1, 2, 3, 4, 5]
    float: [2.3, 1.3, 5.1, nil, 4.4]
    category: ["one", "two", "three", "one", "three"]
  nbRawHtml: "<div class=\"coppia\">"
  nbTable tabella(simple).dataColor(everything(), palette = @["blue", "red"])
  let few = tableData:  # three rows of exibble
    num: [0.1111, 2.222, 5550.0]
    char: ["apricot", "banana", nil]
    fctr: ["one", "two", "five"]
  nbTable tabella(few)
    .tabSpanner("spanner", ["char", "fctr"])
    .tabStyle(style.fill("lightblue"), loc.columnLabels(cols = "num"))
    .tabStyle(style.fill("yellow"), loc.columnHeader())
  nbRawHtml: "</div>"

nbText: """
## How it worked

The port thread wrote each page in tabelline as the guide wrote it in Great Tables, and every
time a line could not be written it noted what was missing, where, and whether the
[coverage map](../../coverage/) had a plan for it. Two kinds of findings came out. Most were
gaps the map already had, so the book only moved them up: `fmtTime` or the composite locations
were planned for later, and the guide showed they belong in the basics. A few were new: the two
bugs, the colours of `dataColor`, the text on dark headings. Both went to the build thread, which
fixed or added them, and the book was rebuilt on the result: every change to tabelline reruns
every page of the book, so a page that breaks shows up in the pull request that broke it.

What is still open is in the book, step by step, with its plan: tables from Polars or pandas,
selections by position or by a condition on each cell, every CSS colour name, gt's six
`optStylize` styles. The next sources of the book (gt's own guide, the Great Tables examples
and blog, the Table Contest) will add to it.
"""

nbSave
