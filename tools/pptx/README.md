# PowerPoint output: an experiment

Can tabelline put a table in a PowerPoint slide, styled as its spec says? Two ways were tried,
both in Nim with only the standard library (`src/tabelline/pptx.nim`, about 900 lines):

1. **A .pptx file** with a native, editable PowerPoint table: `t.savePptx "planets.pptx"`.
2. **Something to paste**: `t.toClipboardHtml`, HTML with every style inline on its cells, which
   Office reads when HTML is on the clipboard.

`nim r tools/pptx/demo.nim out/` writes three examples (the simplest table, the home page's
table, a table with every part) as .pptx, as HTML, and `copy.html`, a page with a Copy button
per table. `tests/test_pptx.nim` checks the pieces.

## From the simplest

**A .pptx is a zip of XML files.** A slide holds shapes; a table is a `p:graphicFrame` holding an
`a:tbl`: a grid of column widths, then rows of cells. Each cell has paragraphs of text runs (size,
colour, bold, italic, font), margins, a fill and four borders. Merged cells are `gridSpan` /
`rowSpan` with `hMerge` / `vMerge` placeholders. Around the slide, a minimal package: content
types, a presentation, one master, one blank layout, one theme.

**The zip is written by hand.** Stored, not compressed: same format, every reader opens it, and
it takes sixty lines and a CRC-32 table. Nim's standard library has no zip; nothing else was needed.

**The table goes through `build`**, the step every renderer shares, so formats, footnote marks,
groups and styles are the same as in HTML. `build(rcHtml)` gives each cell its inline HTML;
a small reader turns `<b>`, `<i>`, `<sup>`, `<sub>`, `<code>`, `<br>` and coloured `<span>`s
into runs (so `md("mass<br>10^24^ kg")` keeps its line break and its superscript).

**A cell grid in the middle.** Each part becomes rows of cells, and each cell gets one *look*:
first the table options (`tableFontSize`, `headingBackgroundColor`, `rowGroupBorderColor`, ...),
then the CSS of `tabStyle` and `dataColor` for its location, read declaration by declaration.
The .pptx and the clipboard HTML are two writers of the same grid.

## What maps cleanly

- Every part: title and subtitle, spanners (any level), stubhead, column labels, row groups,
  stub, body, footnotes (marks raised, in the cells and in the footer), source notes.
- Formatted text of every cell, and alignment (left, centre, right; labels at the bottom).
- Colours (`#hex`, names, `rgb()`/`rgba()` with alpha), sizes (px, pt, %, em), weights,
  italic, underline, strike, upper case (`optAllCaps`).
- Rules: table top and bottom, heading, column labels, row groups, lines between rows, the
  stub's rule, vertical lines, and `style.borders` (solid, dashed, dotted).
- `dataColor`, `optStylize`, row striping, and `optCssTheme()`.
- Tables wider than the slide are scaled (sizes, paddings, widths) to fit.

## What is approximated

- **CSS variables** (`optCssTheme`, `style.fill("var(--x)")`): a slide has no page. A variable
  takes its fallback, or a value given in `PptxOptions(vars: {"--ink": "#1C1C1C"}.toTable)`.
- **`color-mix(in oklab, ...)`** is mixed in sRGB: close, not equal.
- **Fonts**: a CSS font stack gives its first real font; `system-ui` and other generic names
  leave the theme's font. Pass a font PowerPoint has, with `optTableFont`.
- **Column widths** are estimated from the number of characters (no font metrics), so a
  column may be a little wide or wrap once; PowerPoint grows row heights to fit.
- **Spanner rules** are a cell border: they run the full width of the spanned cells.

## What is lost

- The caption, `extraCss`, `font-variant` (tabular figures: PowerPoint has no switch),
  `letter-spacing`, `white-space`, `colsWidth` other than px, `tableWidth = "100%"`.
- Links in cells (DrawingML can do `a:hlinkClick`: not done), images and plots in cells.
- Adding the table to a deck of your own: reading a .pptx needs inflate (not in the standard
  library: zippy, or ~200 lines). Today the table is a deck of its own; copy the slide or the table.

## The clipboard

Paste works by format. What PowerPoint pastes as a native table:

- **HTML** (`text/html`, `public.html` on macOS, `CF_HTML` on Windows): PowerPoint and Word turn
  an HTML `<table>` into a table of their own. They read inline styles most reliably, and know
  nothing of CSS variables or `color-mix`, so `toClipboardHtml` puts every style, resolved, on
  the cells. A browser button can write it (`navigator.clipboard.write` with a
  `text/html` blob); selecting a table on any page and copying it does the same, because the
  browser inlines the computed styles itself.
- **Office's own shape format** ("Art::GVML ClipFormat", a zip holding the same `graphicFrame`)
  is what PowerPoint uses between its own windows. It would paste exactly, but only from a native
  program (a browser cannot write it), and it is not documented as a public format. Not tried.

Not yet checked: opening the files and pasting in PowerPoint itself. LibreOffice opens the files
and renders them as in the screenshots; python-pptx reads every table.

## gt and Great Tables

- **gt** has `as_rtf()`, `as_word()` (a Word table, `w:tbl`) and `gtsave()` to .docx and .rtf.
  Its development version (after 1.4.0) adds `gtsave("x.pptx")`, from a new OOXML engine shared
  by Word and PowerPoint (gt #2158). It needs rmarkdown and pandoc for the package, and puts the
  title in a text box above the table. tabelline keeps the header in the table, so the slide holds
  one object to move or copy.
- **Great Tables** writes HTML, LaTeX (`as_latex`) and images (`save`, through a browser). No
  Word or PowerPoint.
- In R, **flextable** (with officer) is the established way to put tables in PowerPoint.
