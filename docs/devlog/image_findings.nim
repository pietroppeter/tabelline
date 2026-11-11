## devlog: 11 Nov 2026 E | Three pictures of a table | Three proofs of concept drew the same tables as pictures: Chrome driven from Nim, an SVG written by tabelline, a PNG painted with pixie. How close each came to the HTML, what it costs, what it cannot do, and the plan they point to: one layout of our own, with an SVG painter and a pixie painter on top, and Chrome for the exact look.
## A dated post: the findings of the three proofs of concept of "A table as a picture" (PRs #92,
## #93, #94), written once and not updated afterwards. Pictures in docs/devlog/data/image-findings/.
import std/os
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
let shots = docs / "devlog" / "data" / "image-findings"
nbInit
nb.doc.filename = docs / "devlog" / "image-findings" / "index.html"
nb.useTabelline(title = "Three pictures of a table", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026 · findings", "Three pictures of a table", """
Three proofs of concept drew the same tables as pictures: Chrome driven from Nim, an SVG written
by tabelline, a PNG painted with pixie. How close each came to the HTML, what it costs, what it
cannot do, and the plan they point to.
"""

nbText: """
[A table as a picture](../image-output/) compared ten ways to turn a tabelline table into an image
and chose three to try. Each was built in a thread of its own, as a draft PR that is not meant to
be merged, and each drew the same four tables: the inner planets (a title, a stub, numbers); some
of gt's cars (spanners, row groups, summary rows, footnotes, source notes); hot and cold worlds
(`tabStyle`, `dataColor`, striping, Markdown); and pictures in cells (images, nanoplots). The SVG
proof drew a fifth one, the shapes of the islands of the Mediterranean.

## The three, in one table
"""

block:
  type Poc = object
    poc, pr, how, code, needs: string
  let rows = @[
    Poc(poc: "A. Chrome from Nim", pr: "#92", how: "starts Chrome, talks to it over a WebSocket (the DevTools protocol, as Great Tables' nokap), screenshots the table's box",
        code: "212 lines; the WebSocket client is 57", needs: "Chrome"),
    Poc(poc: "B. Native SVG", pr: "#94", how: "lays the table out itself, measuring text with the font's own widths, and writes rectangles, lines and letters",
        code: "about 1,500 lines: fonts 460, layout and SVG 1,060", needs: "nothing: the standard library"),
    Poc(poc: "C. PNG with pixie", pr: "#93", how: "lays the table out itself, measuring with pixie, and paints pixels with pixie",
        code: "about 1,060 lines", needs: "pixie (an optional module), and two fonts"),
  ]
  let t = tabella(rows, rownameCol = "poc"):
    tabHeader "Three proofs of concept", "draft PRs, std lib only unless said"
    colsLabel {"pr": "PR", "how": "how", "code": "code", "needs": "needs"}
    colsWidth {"how": "45%"}
    optCssTheme()
  nbTable t

nbText: """
## How close they came

**Chrome** is the HTML table, so it is exact by definition: everything is drawn, spanners,
summaries, footnote marks, Markdown, colours, nanoplots, pictures. It is the reference for
the other two.

**The SVG** lands within 1 to 4 CSS pixels of Chrome on all five tables; column widths and row
heights agree to a tenth of a pixel, and on a 380-pixel page it breaks lines at the same words.
That took a few details found by comparing: Chrome's `system-ui` was Inter on that machine, so the
SVG measures with Inter; ascent and descent are rounded to whole pixels, as Chrome does; numbers
in right-aligned cells use tabular figures (the font's `tnum` digits, all of one width); a
footnote mark makes its line taller; monospace text is 13/16 of the size.
"""

nbPicture shots / "svg-planets.jpg", "The inner planets: Chrome's picture of the HTML on top, the SVG (drawn by Chrome) below"

nbText: """
**The PNG with pixie** is within 3 pixels in height and 1% in width: the cars are 1052 × 1887
pixels against Chrome's 1050 × 1890. Every part of the table is right. What differs: digits are
not tabular, because pixie applies no OpenType features; the hatching under a line nanoplot
becomes a pale fill, because pixie's SVG reader has no `<pattern>`; and thin guide lines drawn
with `vector-effect` come out thinner still.
"""

nbPicture shots / "pixie-styles.jpg", "Hot and cold worlds: Chrome on the left, pixie on the right, 12 pixels wider"
nbPicture shots / "pixie-plots.jpg", "Pictures in cells: the same, with pixie's pale fill where Chrome hatches"

nbText: """
## What it costs

Sizes and times for the cars, the biggest table, at scale 2 (pictures twice the CSS size):
"""

block:
  type Cost = object
    way, file, first, next: string
  let rows = @[
    Cost(way: "Chrome, PNG", file: "215 KB", first: "0.7 s (start Chrome, draw, stop)", next: "123 ms with Chrome running"),
    Cost(way: "Chrome, PDF", file: "101 KB", first: "as above", next: "36 ms"),
    Cost(way: "SVG, font subset inside", file: "97 KB", first: "169 ms (reading the fonts)", next: "2 ms"),
    Cost(way: "SVG, letters as paths", file: "97 KB", first: "as above", next: "2 ms"),
    Cost(way: "pixie, PNG", file: "268 KB", first: "6 ms for the fonts", next: "15 ms to draw, 85 ms to encode"),
  ]
  let t = tabella(rows, rownameCol = "way"):
    tabHeader "The cars, five ways", "sizes and times from the three PRs"
    colsLabel {"file": "file", "first": "first picture", "next": "each next one"}
    tabSourceNote "The planets, the smallest table: Chrome 60 KB, SVG 46 KB with the font (11 KB without it, 37 KB as paths), pixie 74 KB. A program using pixie is 1 MB bigger; its two fonts are 1.9 MB, read at run time."
    optCssTheme()
  nbTable t

nbNote """
**About the code.** The PoCs' numbers are typed in as records here; the tables are plain
tabelline, one verb per line, with a source note for what does not fit in a row.
""", nkCode

nbText: """
## Where an SVG opens

An SVG with the font inside is perfect in a browser, and only there: resvg and LibreOffice ignore
the `@font-face` and draw with an installed font. The letters stay where they were measured
(each has its own position), but the digits lose their tabular widths. Written with **letters as
paths** (each letter's outline, from the font), the SVG is exact in Chrome, resvg and LibreOffice,
and resvg turns it into a PNG: that is the mode for PowerPoint, Inkscape and Figma, at the price of
text that cannot be selected. Inkscape and PowerPoint were not there to try.

The SVG proof also found a bug in tabelline itself: interactive nanoplots write
`fill="transparent"`, which is CSS but not SVG, and LibreOffice drew their hover boxes black. SVG's
word is `none`.

## Scripts

All three draw Latin with accents, Greek and Cyrillic. Chrome draws everything, because it has
HarfBuzz and every font on the machine. The two layouts of our own place letters one by one: with
fallback fonts pixie draws Chinese, Japanese, Korean and Thai too, but Arabic and Hebrew come out
left to right, Arabic letters do not join, Devanagari's vowel sign lands in the wrong place, and
colour emoji are missing. The SVG proof has the same limits.
"""

nbPicture shots / "pixie-scripts.jpg", "One city in eleven scripts: Chrome, pixie with Inter only, pixie with fallback fonts"

nbText: """
## What they found in common

**The font is the picture.** Chrome draws with whatever the machine resolves for `system-ui`:
Inter in the sandbox, San Francisco on a Mac, Segoe UI on Windows, so the same table makes
different pictures on different machines. The other two need a font file, and draw the same
everywhere. Both chose Inter (open, OFL); a picture should name its font rather than borrow one.

**Page themes do not travel.** A table styled with `optCssTheme()` reads the page's CSS
variables. Chrome needs that page's CSS passed in; the layouts of our own need the values.

**One layout fits both painters.** The SVG proof's layout (`buildGrid` and `place`) needs only
the advance widths of letters, and its painter is the last 170 lines. The pixie proof found the
same split in its own code, and measured the SVG's layout as closer to Chrome than its own (a
tenth of a pixel against 1%). Its thread offered to put its painter, about 200 lines, on top of
the SVG's layout.

## The plan they point to

The plan for 0.3, which Pietro approved on 11 November; it becomes an OpenSpec change:

1. **A layout in the core**, from the SVG proof: `build`, then cells, a CSS reader, runs of text,
   column widths, line breaks, collapsed borders. It measures through a small font interface
   (advance widths, kerning, `tnum`), read from a vendored Inter with the standard library.
2. **`toSvg(t)` in the core**, two modes: a font subset inside (selectable text, for browsers)
   and letters as paths (for everything else). `save(t, "t.svg")` by the extension, as `gtsave`.
3. **`tabelline/pixie`**, optional: the pixie painter on the same layout, for `save(t, "t.png")`
   with no program installed: tabular digits drawn one by one at their `tnum` widths, hatching
   drawn by hand.
4. **`tabelline/chrome`**, optional: the exact HTML look, PDF too, for whoever has Chrome, and
   the reference picture in tests that check the other two.
5. Fix nanoplots' `transparent` to `none`, now, whatever else happens.

What stays open: right-to-left and shaped scripts (they need HarfBuzz, or Chrome), links in
pictures, and `html()` cells, which show only their text.

## Sources

- The PRs: [#92](https://github.com/pietroppeter/tabelline/pull/92) (Chrome from Nim),
  [#93](https://github.com/pietroppeter/tabelline/pull/93) (pixie),
  [#94](https://github.com/pietroppeter/tabelline/pull/94) (native SVG), each with its
  pictures and numbers.
- The research: [A table as a picture](../image-output/).
"""

nbSave
