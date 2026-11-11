## Why

A table should also be a picture: for a slide, a chat, a README, a PDF. gt has `gtsave("x.png")`
(through a headless browser) and Great Tables `GT.save()` and the new `GT.gtsave()` (Chrome over
the DevTools protocol, with nokap). tabelline writes only HTML, text and Markdown. The devlog
posts *A table as a picture* and *Three pictures of a table* (PR #91) compared ten ways and tried
three in proofs of concept (draft PRs #92 Chrome, #93 pixie, #94 native SVG). Pietro approved
their plan on 11 Nov 2026 (thread "Research image output for tabelline tables": "Layout + SVG,
pixie and Chrome", then "Approved you can start, don't stop until you have done all 5"). It comes
from the BACKLOG entry *Images* and the feature map's row *Images and PDF* (plan 0.3). The build
is in the PR of the thread "Build image output for tabelline 0.3".

## What Changes

1. **A layout in the core** (`src/tabelline/layout.nim`, standard library only, from #94):
   `drawing(t, width)` lays the table out as Chrome lays out `toHtml` (cells from `build`, the
   options' look, `tabStyle` and `dataColor` CSS read, runs of text, automatic column widths,
   line breaks at spaces, collapsed borders) and gives a `Drawing`: its size and a list of marks
   (rectangles, lines, letters with their places, nanoplots, images). Letters are measured with
   fonts tabelline ships: Inter 4.1 (OFL) and DejaVu Sans Mono, read by `ttf.nim` (widths,
   kerning, tabular figures, outlines, a subsetter).
2. **`toSvg(t)` in the core** (`render_svg.nim`): the marks as an SVG, with the letters as text
   and a subset of the font inside (`stFont`, the default, for browsers: text can be selected),
   or as their outlines (`stPaths`, for Inkscape, LibreOffice, PowerPoint, resvg: no font needed).
3. **`save(t, path)` by the extension**, as `gtsave`: `.html` (as today) and `.svg` in the core;
   other extensions from optional modules that add a writer when imported (`addWriter`). An
   extension nobody writes is an error that says which module to import.
4. **`tabelline/pixie`**, optional (pixie 6.1 as the atlas feature `pixie`): the same marks
   painted into a pixie `Image`, `toPng(t)`, and `.png` for `save` (scale 2 by default). Tabular
   figures are placed one by one at their own widths; the hatching under a line nanoplot is
   drawn by hand.
5. **`tabelline/chrome`**, optional, standard library only (from #92): starts a headless Chrome
   and talks to it over the DevTools protocol (a small WebSocket client), for the exact look of
   the HTML: `.png`, `.jpg`, `.webp` and `.pdf` for `save` (`.png` only when pixie is not
   imported). It is also the reference the tests compare the layout with, when Chrome is there.
6. **Nanoplots write `none`, not `transparent`**, for `fill` and `stroke`: `transparent` is CSS,
   not SVG 1.1, and LibreOffice drew the hover boxes black.

Not in this change: right-to-left and shaped scripts (Arabic, Devanagari: they need HarfBuzz,
or Chrome), links that can be clicked in a picture, `html()` cells beyond their text, other
fonts than the two shipped, LaTeX, RTF and Word.

## Differences from gt and Great Tables

- gt's `gtsave()` writes `.html`, `.png`, `.pdf`, `.tex`, `.rtf`, `.docx`; Great Tables' `save()`
  and `gtsave()` write `.png`, `.bmp`, `.pdf` (and HTML through `write_raw_html`). tabelline's
  `save` writes `.html` and `.svg` alone, `.png` with `tabelline/pixie`, and `.png`, `.jpg`,
  `.webp`, `.pdf` with `tabelline/chrome`. Same name for the verb as Great Tables' method, `save`
  (gt's `gtsave` names the package).
- gt and Great Tables always draw through a browser (webshot2/chromote, Selenium, nokap).
  tabelline draws SVG and PNG with its own layout, no program needed; Chrome only when asked.
- `scale` is Great Tables' `scale` and gt's `zoom` (default 2 in both); `width` is the width of
  the page the table is laid out in, as Great Tables' `window_size` width (gt: `vwidth`).
  `expand` (gt, Great Tables) is not there: a picture is the table's box, with no margin.
- New, listed in *Not from gt*: `toSvg` with its two ways of writing letters (closest: none, gt's
  `as_gtable()` is a grid graphics object for R only), `drawing(t)` (closest: `as_gtable()`), and
  `addWriter` (closest: none).

## Capabilities

### New Capabilities

- `image-output`: the layout, SVG, `save` by the extension, the pixie and Chrome modules.

### Modified Capabilities

- `rendering`: `save` picks the format from the extension (the HTML requirement names it).
- `formatting`: nanoplots are valid SVG 1.1 (`none`, never `transparent`).

## Impact

New: `src/tabelline/ttf.nim`, `layout.nim`, `render_svg.nim`, `save.nim`, `pixie.nim`,
`chrome.nim`, `src/tabelline/fonts/` (five TTF files, 1.9 MB, with their licences). Changed:
`render_html.nim` (`save` moves to `save.nim`), `nanoplots.nim`, `tabelline.nimble` (the feature
`pixie`), `atlas.lock`, `tools/setup.sh`, tests, `docs/coverage.nim` and `docs/coverage/gt.json`,
the guide (a section on pictures), README. The core's binary grows by the fonts only in a
program that calls `toSvg` (they are read with `staticRead`).
