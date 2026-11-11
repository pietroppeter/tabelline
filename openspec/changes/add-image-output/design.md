# Design

## Context

`build(t, ctx)` gives the cells of a table, formatted, with their styles; `render_html.nim` writes
them as a `<table>`, `render_text.nim` as box characters. A picture needs one more thing that HTML
leaves to the browser: where everything goes. The proofs of concept found that a layout of our own
can match Chrome's to a tenth of a pixel (#94), with only the advance widths of the letters, and
that the same layout can feed both an SVG and a pixie painter (#93's addendum). Chrome itself
(#92) is exact by definition and became the reference.

## Goals / Non-Goals

**Goals:**
- `save(t, "t.svg")` with nothing installed; `save(t, "t.png")` with one optional import.
- The same picture on every machine: the font is ours, not the machine's.
- One layout, two painters; Chrome for the exact look and PDF.
- The core keeps needing only the standard library.

**Non-Goals:**
- Shaping (Arabic joined, Devanagari, right to left), colour emoji: HarfBuzz territory; Chrome draws them.
- Fonts other than Inter and DejaVu Sans Mono (a later change could take a TTF from the user).
- Clickable links in an SVG, `html()` cells beyond their text.

## Decisions

1. **Three layers.** `ttf.nim` reads a font (cmap, hmtx, GPOS pair kerning, GSUB `tnum`, glyf
   outlines, a subsetter that renumbers glyphs). `layout.nim` turns a table into a `Drawing`
   (`drawing(t, width, vars)`): its width, height, background, and marks: `mkRect`, `mkLine`
   (with a dash length), `mkText` (letters, their glyphs and the x of each, the baseline, face,
   size, colour, whether digits are tabular), `mkPlot` (a nanoplot's own `<svg>` in a box) and
   `mkImage`. Painters only draw marks: they know nothing of tables. Double rules are two lines,
   underlines a line, so a painter has five things to draw.
2. **Every letter has its x.** The layout places each letter (kerning and tabular figures
   included), so a painter never measures, and a viewer's own kerning cannot move a letter.
3. **Fonts in the binary, only when used.** The five TTF files are read with `staticRead` by
   `layout.nim`. A program that never calls `drawing`, `toSvg` or `save` does not carry them; one
   that calls `save` does (1.9 MB), because `save` can write `.svg`. Accepted: `save` is the verb
   for pictures. A program that wants only HTML, and a small binary, writes
   `t.toHtml(makePage = true)` itself.
4. **`toSvg` writes the font subset by default.** `stFont`: `<text>` with an `x` for every letter,
   and a subset of each face used as `@font-face` data (tabular figures as a face of their own,
   `tb-sans-tnum`, because the subset puts the `tnum` glyphs in place of the digits). `stPaths`:
   each glyph's outline once in `<defs>`, then `<use>`. The PoCs: planets 44 KB with the font,
   36 KB as paths.
5. **`save` dispatches on the extension, with writers added by imports.** `save.nim` keeps a
   table from extension to writer; `tabelline/pixie` and `tabelline/chrome` add theirs at import
   (`addWriter(".png", ..., priority)`). Of two writers, the higher priority wins whatever the
   order of imports: pixie's `.png` (priority 10) over Chrome's (0), because pixie draws the same
   picture everywhere; Chrome's own `saveImage` is there for its `.png`. Not chosen: overloads of
   `save` in each module (two imported modules make the call ambiguous), and a `format` argument
   (gtsave reads the extension).
6. **pixie paints marks.** A mark becomes a pixie path or `fillText`; text is drawn glyph by
   glyph at the layout's x, so tabular figures and kerning come out as in the SVG, although pixie
   applies no OpenType features (the glyph ids come from `ttf.nim`; pixie draws each letter as
   a one-letter span at its place, with the `tnum` digit's outline taken from `ttf.nim` when it
   differs). A nanoplot is read by pixie's SVG reader after the fixes #93 found (no `<text>` or
   `<pattern>`: values drawn as text marks, hatching drawn as lines clipped to the area).
7. **Chrome as in #92, behind `save`.** The module starts Chrome (found by `CHROME_PATH`, then on
   the PATH, then in the usual places), shows `toHtml(makePage = true)`, measures the
   `.tabella > table` box and takes a screenshot of it, or prints it to PDF. `startChrome()` keeps
   one Chrome for many pictures. Without Chrome, a clear error.
8. **The reference test.** `tests/test_image.nim` checks the layout without Chrome (sizes of the
   four PoC tables, marks, both SVG modes are well formed). `tools/image/compare.nim` draws the
   same tables with Chrome and compares the boxes: widths and heights within 4 px, run by hand
   and in CI where Chrome is installed.

## Risks / Trade-offs

- The layout follows tabelline's own CSS; a page theme (`optCssTheme`) needs its variables
  passed as `vars`, or the fallbacks are used. Documented.
- Chrome's own `system-ui` differs per machine, so Chrome pictures differ from the SVG where the
  machine's font is not Inter. Documented: the SVG and PNG always use Inter.
- Repository size: +1.9 MB of fonts.
- First call reads the fonts (about 150 ms, kerning pairs expanded); later calls take 1–3 ms.
