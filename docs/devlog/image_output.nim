## devlog: 11 Nov 2026 D | A table as a picture | gt and Great Tables save a table as a PNG by asking a browser to take a screenshot. What an image of a table is, every way tabelline could make one (a browser, SVG, pixie, Typst, a layout of its own), what each costs and gets, and the three proofs of concept that will try the most promising: the browser driven from Nim as Great Tables' new gtsave() does, an SVG written by tabelline, and a PNG painted with pixie.
## A dated post: the research behind image output (planned for 0.3), written once and not updated
## afterwards. What the proofs of concept find goes in a second post.
import std/os
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "image-output" / "index.html"
nb.useTabelline(title = "A table as a picture", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026 · research", "A table as a picture", """
gt and Great Tables save a table as a PNG by asking a browser to take a screenshot. What an image
of a table is, every way tabelline could make one, what each costs and gets, and the three proofs
of concept that will try the most promising: the browser driven from Nim, an SVG written by
tabelline, and a PNG painted with pixie.
"""

nbText: """
Pietro, opening 0.3: "For 0.3 we might want to add image generation. There are many ways we could
do that (eg generating a SVG); one way could be to use the pixie library." A table that is a
picture can go where HTML cannot: a slide, a chat message, a social post, a README, a paper, an
email. gt and Great Tables both have it, and people use it a lot: `gtsave("table.png")` is how many
gt tables end up on the web.

This post looks at every way tabelline could do it, from the simplest to the most work, and picks
three to try. It starts from zero.

## Two kinds of picture

A **raster** image (PNG, JPEG, WebP) is a grid of coloured pixels. It looks the same everywhere,
but it has a fixed size: zoom in and the text gets blurry, so a table for a slide is made at two or
three times its size on screen.

A **vector** image (SVG, PDF) is a list of shapes: a line from here to there, a rectangle filled
with this colour, these letters in this font at this point. It stays sharp at any size, it is
small, and its text can be searched and selected. But whoever shows it has to draw it, so it looks
right only if the viewer draws everything it uses: SVG in a browser is perfect, SVG in PowerPoint or
Inkscape is good, SVG in a program that reads only part of SVG can lose the text.

A table in HTML is neither: it is a description that the browser *lays out* (how wide is each
column, where does a line of text wrap, how tall is each row) and then draws. That layout is the
heart of the problem. Whoever makes the image has to do it, and a browser has been doing it, very
well, for thirty years.

## What gt and Great Tables do

Both hand the work to a browser.
"""

nbShowCode:
  type Way = object
    library, call, how: string
  let rows = @[
    Way(library: "gt (R)", call: "gtsave(\"t.png\")", how: "webshot2 drives a headless Chrome (through chromote) and crops the screenshot to the table: `expand` pixels around it, `zoom` for the resolution. Also `.pdf`; `.html`, `.tex`, `.rtf` and `.docx` gt writes itself."),
    Way(library: "gt (R)", call: "as_gtable(t)", how: "since gt 0.11 (July 2024), a second renderer: the table becomes R `grid` graphics, which any R device draws (`.png`, `.svg`, `.pdf`, inside a ggplot). CSS styles are read into colours and fonts; nanoplots are rasterized with rsvg."),
    Way(library: "Great Tables (Python)", call: "GT.gtsave(\"t.png\")", how: "new: nokap, a small Python package by Rich Iannone (gt's author), starts Chrome and drives it through its DevTools protocol over a WebSocket: open the HTML, measure the table, screenshot only its box at `zoom` 2. Also `.jpg`, `.webp`, `.pdf`."),
    Way(library: "Great Tables (Python)", call: "GT.save(\"t.png\")", how: "deprecated (to go in mid-2027): Selenium drives Chrome (or Firefox, Safari, Edge) in a 6000 × 6000 window, zooms the table by `scale`, takes a screenshot and crops it with Pillow.")]
  let t = tabella(rows, rownameCol = "call", groupnameCol = "library"):
    tabHeader "How they save a picture", "gt 1.4 and Great Tables, read in their sources on 11 November 2026"
    colsLabel {"how": "how"}
    fmtMarkdown "how"
    optCssTheme()
  nbTable t

nbText: """
The browser way gives a picture that is exactly the HTML table, since it *is* the HTML table. It
also gives the complaints that fill the gt and Great Tables issue trackers: Chrome is not
installed, the driver does not match the browser, no free port, a container where Chrome will not
start without `--no-sandbox`. A picture of five rows needs a browser of a few hundred megabytes.

Great Tables has just made that way lighter. Its `save()` needed Selenium and Pillow; the new
`gtsave()` (the name of gt's) needs only `nokap` and a Chrome. nokap talks to Chrome the way
webshot2 and Playwright do, through the DevTools protocol: it starts Chrome with a debugging port,
sends JSON over a WebSocket (`Page.navigate`, `Emulation.setDeviceMetricsOverride` for the zoom,
`Runtime.evaluate` to read the table's box, `Page.captureScreenshot` with that box as the clip,
`Page.printToPDF`), and gets the PNG back as base64. It is about 1,600 lines of Python with its
command line; the protocol part is a few hundred. Nothing in it needs Python: it could be written
in Nim.

gt's `as_gtable` is the other way, and it is a precedent worth reading: gt lays the table out
itself, on top of R's `grid`, and lets R draw it. It does not support everything (HTML inside a
cell is drawn as plain text unless `gridtext` is used), and it needed 1,600 lines.

## The ways, from the simplest

Every way is in one of four families: a browser draws the HTML; tabelline lays the table out and
something draws it; tabelline writes the table in another language that can make pictures; or a C
graphics library draws what tabelline lays out.
"""

nbShowCode:
  type Option = object
    way, family, what, needs: string
  let rows = @[
    Option(way: "1. Browser, command line", family: "a browser draws",
           what: "save the HTML, run `chrome --headless --screenshot` on it: PNG or PDF of the whole window, not cropped to the table",
           needs: "Chrome"),
    Option(way: "2. Browser, remote control", family: "a browser draws",
           what: "as gt and Great Tables: drive Chrome through its DevTools protocol, measure the table, screenshot only its box",
           needs: "Chrome, and a small WebSocket client in Nim: nokap's job"),
    Option(way: "3. SVG around the HTML", family: "a browser draws",
           what: "put the table's HTML inside an SVG `foreignObject`: right in a browser, blank in PowerPoint, Inkscape, rsvg",
           needs: "nothing to make it, a browser to see it"),
    Option(way: "4. Text as a picture", family: "tabelline lays out",
           what: "draw `toText(t)`, the table as monospaced text, into an image: no colours, styles or nanoplots",
           needs: "a monospaced font"),
    Option(way: "5. Native SVG", family: "tabelline lays out",
           what: "a renderer next to `toHtml` and `toText`: lay the table out, write rectangles, lines and text",
           needs: "the standard library, and the widths of the font's letters"),
    Option(way: "6. PNG with pixie", family: "tabelline lays out",
           what: "the same layout, painted on pixels: pixie typesets the text, fills and strokes the boxes, writes a PNG",
           needs: "pixie (pure Nim, 7 small packages) and a TTF or OTF font"),
    Option(way: "7. One layout, many painters", family: "tabelline lays out",
           what: "5 and 6 sharing one layout of boxes, as `as_gtable` shares R's grid; later a PDF or PowerPoint painter",
           needs: "the layout in the core, pixie in an optional module"),
    Option(way: "8. Typst", family: "another language",
           what: "write the table as Typst markup (tables with spans, strokes, fills) and run `typst compile` to PNG, SVG or PDF",
           needs: "the typst program, one binary"),
    Option(way: "9. LaTeX", family: "another language",
           what: "as `as_latex` in gt and Great Tables, then pdflatex and a converter: the LaTeX look, not the HTML one",
           needs: "a TeX installation (gigabytes)"),
    Option(way: "10. Cairo or Skia", family: "another library",
           what: "a C graphics library through Nim bindings: one drawing API, PNG, SVG and PDF, with text shaping",
           needs: "the C library on every machine"),
  ]
  let t = tabella(rows, rownameCol = "way", groupnameCol = "family"):
    tabHeader "Ten ways to make a picture of a table", "from the simplest to the most work"
    colsLabel {"what": "what", "needs": "needs"}
    colsWidth {"what": "55%"}
    fmtMarkdown "what"
    optCssTheme()
  nbTable t

nbText: """
I tried the first on this sandbox, with the four inner planets as the table: Chrome took 1.5 seconds
and drew a PNG of 1,200 × 800 pixels at scale 2, with the table, 460 pixels wide, in the middle of
an empty window. That is the browser way in one picture: the table is perfect, and everything
around it is work.

## The hard parts

The ways in the first family get the layout for free. The others have to do it, and the same six
problems come back in each of them.

**Measuring text.** Everything depends on how wide a piece of text is: the column widths, where a
line wraps, how tall a row is. To measure it you need the font, the very file, and its table of
letter widths. tabelline's default font is a list, `system-ui, -apple-system, 'Segoe UI', Roboto,
Helvetica, Arial, sans-serif`, which the browser resolves to whatever the reader's machine has.
A picture cannot: it needs one font that we ship. [diagrammari](https://pietroppeter.github.io/diagrammari/) met the same problem with Pele,
which measures with Arial's widths, and draws its diagrams in Arimo, a free font with Arial's
widths.

**Wrapping.** HTML wraps a long cell for you; SVG `<text>` never wraps. The layout has to break
lines itself, at spaces, as wide as the column allows, and choose the column widths first (gt's
`cols_width` gives them; otherwise, as the browser does, from the longest word and the longest line).

**Styles are CSS.** `tabStyle` and `dataColor` keep their styles as CSS declarations, and the
options too (since 0.2, as CSS variables). A picture needs a small CSS reader: colour, background,
font weight, style, size and family, alignment, borders, padding, text decoration and case. gt's
`as_gtable` does exactly this. Colours that are CSS variables of the page (`var(--primary)`, from
`optCssTheme`) have no page to read them from: a picture needs them as values.

**Rich text.** `md("**Earth**")` becomes HTML in `toHtml` and plain text in `toText`. A picture
needs a third thing: runs of text, each with its font (bold, italic, code), its colour, and maybe
a link. `html("...")` cannot be drawn without a browser: like gt, show its text.

**Nanoplots and images.** tabelline's nanoplots are already SVG (circles, lines, paths,
polylines, rectangles, a few labels): an SVG table can put them in as they are. pixie reads a part
of SVG (paths, lines, polylines, rectangles, circles, groups) and skips `<text>`, so it can draw a
nanoplot's shapes but not its labels. Pictures (`fmtImage`, `localImage`) are PNG or JPEG files:
pixie reads them; an SVG embeds them as data URLs.

**Scripts.** pixie places the letters of a font one by one, with kerning. It does not shape text
the way a browser does with HarfBuzz: Latin, Greek and Cyrillic are fine, but Arabic letters that
join and Devanagari that reorders need shaping, and colour emoji need a colour font. The proof of
concept will tell how far it goes; a table of FOSDEM devrooms is safe.
"""

nbText: """
## What each way gets

Four questions decide it: does it need something installed beyond Nim (what is installed has to be
installed in CI and in every sandbox too), does it look like the HTML table, which formats does it
make (an SVG can be edited in Inkscape, Figma or PowerPoint), and how much work is it.
"""

nbShowCode:
  type Score = object
    way, install, looks, formats, work: string
  let rows = @[
    Score(way: "2. Browser, remote control", install: "Chrome", looks: "exactly", formats: "PNG, PDF", work: "small: nokap in Nim"),
    Score(way: "3. SVG around the HTML", install: "nothing", looks: "only in a browser", formats: "SVG", work: "tiny"),
    Score(way: "5. Native SVG", install: "nothing", looks: "close", formats: "SVG, editable", work: "a layout and a CSS reader"),
    Score(way: "6. PNG with pixie", install: "nothing outside Nim", looks: "close", formats: "PNG", work: "the same layout, a painter"),
    Score(way: "8. Typst", install: "typst", looks: "its own", formats: "PNG, PDF; SVG, editable", work: "a Typst writer"),
    Score(way: "10. Cairo or Skia", install: "libcairo", looks: "close", formats: "PNG, PDF; SVG, editable", work: "the same layout, a painter"),
  ]
  let t = tabella(rows, rownameCol = "way"):
    tabHeader "What each way gets", "six of the ten ways above, with their numbers"
    colsLabel {"install": "installs", "looks": "like the HTML", "formats": "makes", "work": "work"}
    optCssTheme()
  nbTable t

nbNote """
**About the code.** The three tables of this post are records turned into tabelline tables, one
verb per line. The first two group their rows by a field (`groupnameCol`), in the order they first
appear, and read the long column as Markdown (`fmtMarkdown`), so that code shows as code. Each
table's code is folded under it: *show code* opens it.
""", nkCode

nbText: """
## The choice: three proofs of concept

A small one comes first, because it is the reference for the other two: the browser itself, done
as Great Tables now does it. Then two ways stand out, and they are the two Pietro named: they are
written in Nim, need nothing installed, run in CI, and teach us how to lay a table out ourselves,
which every way but the browser needs.

**A. The browser, as nokap does it, in Nim.** The smallest of the three, and the reference for
the other two: a Nim module (`std/net` and a WebSocket handshake, no packages) that starts Chrome,
opens the table's HTML and takes a screenshot of the table's box, as Great Tables' new `gtsave()`
does. It would be the `save(t, "t.png")` for whoever has Chrome, and the picture that B and C are
compared with. Questions it answers: how small can the client be? How fast is a second picture
when Chrome is already running? Does it work in CI?

**B. Native SVG, standard library only.** A new renderer, `toSvg(t)`, next to `toHtml` and
`toText`, reading the same `Built` table. It measures text with the widths of a font we ship,
read from the font file itself (an OpenType file has a table of widths, `hmtx`, that a hundred
lines of Nim can read), and embeds that font in the SVG, so every viewer draws the letters we
measured. Nanoplots go in as they are. Questions it answers: how close to the HTML can it get?
How big is the file with the font in it? Does it open in Inkscape, PowerPoint, GitHub and on a
phone? Can resvg or a browser make a good PNG of it?

**C. PNG with pixie.** An optional module, `tabelline/pixie`, like `tabelline/nanuq`, so the core
keeps only the standard library. pixie measures, wraps and draws the text (`typeset`, spans for
bold and italic), fills and strokes the boxes, reads nanoplots' shapes through its SVG reader and
pictures through its image readers, and writes a PNG at any scale. Questions it answers: how close
to the HTML? How fast, and how big a binary? What breaks: wrapping, nanoplot labels, scripts?

Every proof of concept draws the same tables, puts its picture beside A's, and says where they
differ.

## How the proofs will be judged

Four tables, from the simplest to the hardest, are drawn by both:

1. the inner planets, as above: a title, a stub, numbers;
2. a table with spanners, row groups, summary rows, footnotes and source notes (gtcars);
3. styles: `tabStyle`, `dataColor`, striping, `md()` text with bold and italic;
4. nanoplots and an image (the islands' shapes, or a line nanoplot).

For each: the picture beside Chrome's, the size of the file, the time it takes, the lines of code,
and what is missing. The threads are told what the others are doing, so that the layout (column
widths, wrapping, row heights) is written once if it can be shared. The findings, and the choice
for 0.3, go in a second post.

## What gt and Great Tables do not have

None of the ways above is new, but two of them would be new for a gt family library: a vector
picture that is not a screenshot (gt's `as_gtable` can make one, through R's SVG device), and a
picture made without any program installed. If a proof of concept works, `save(t, "table.svg")`
and `save(t, "table.png")` would join `save(t, "table.html")`, chosen by the extension as in
`gtsave`, and both would get a line in the table *Not from gt* of the feature map.

## Sources

- gt: [`gtsave()`](https://gt.rstudio.com/reference/gtsave.html) and
  [`as_gtable()`](https://gt.rstudio.com/reference/as_gtable.html); the code read is
  `R/gtsave.R`, `R/export.R` and `R/utils_render_grid.R` of gt 1.4.
- Great Tables: [`GT.gtsave()`](https://posit-dev.github.io/great-tables/reference/GT.gtsave.html)
  and the deprecated `GT.save()`, in `great_tables/_export.py` and `_utils_selenium.py` (main, 10
  November 2026); [nokap](https://github.com/posit-dev/nokap) 0.1.0 (`_cdp.py`, `_session.py`,
  `_screenshot.py`).
- [pixie](https://github.com/treeform/pixie) 6.1: `fonts.nim` (`typeset`, `fillText`,
  `layoutBounds`), `fileformats/svg.nim` (the SVG it reads), `pixie.nimble` (its dependencies).
- [webshot2](https://github.com/rstudio/webshot2) (headless Chrome through chromote),
  [Typst](https://typst.app/docs/reference/model/table/) tables,
  [resvg](https://github.com/linebender/resvg) (an SVG renderer, Rust).
"""

nbSave
