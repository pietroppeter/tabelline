## Why

The last of five PRs for 0.2 (Pietro, 10 Nov 2026: bring 0.3 and 0.4 into 0.2): the pictures
of 0.4, *Pictures in cells*. Three rows of the Feature map that 0.1 lacked: icons
(`fmt_icon`), images (`fmt_image`) and plots in cells (`fmt_nanoplot`, `cols_nanoplot`). All of
them draw without loading anything remote, so a page stays one file.

## What Changes

- `fmtIcon(columns, rows, height, sep, strokeColor, strokeWidth, strokeAlpha, fillColor,
  fillColors, fillAlpha, marginLeft, marginRight, a11y)`: names of Font Awesome Free icons as
  inline SVG, several per cell separated by commas. Every free icon (2,163, solid, regular and
  brands, and 614 older names) is in `src/tabelline/data/fontawesome.tsv`, written by
  `tools/fontawesome.nim` from the npm package and read when compiling, only by a program that
  uses icons. `icon`, `hasIcon` and `iconSvg` give one icon on its own.
- `fmtImage(columns, rows, height, width, sep, path, filePattern, encode, alt)`: file names as
  images, local files read when the verb is called and inlined as data URLs; addresses are left
  as they are. `imageDataUrl(file)` gives one.
- `fmtNanoplot(columns, rows, plotType, plotHeight, missingVals, autoscale, referenceLine,
  referenceArea, expandY, options, alt)`: a line, bar or box plot of the values in each cell
  ("1 4 2 8", or "3, NA, 6"), or a horizontal bar or line per row for a column of numbers, with
  the values shown when the pointer is over the plot (CSS, no JavaScript). In text output, a
  sparkline. `nanoplotOptions(...)` holds the look, `nanoplotSvg` and `nanoplotText` draw one.
- `colsNanoplot(columns, ..., newColName, newColLabel, before, after, autohide)`: a new column
  of nanoplots of several columns, which are hidden.

## Differences from gt and Great Tables

- Nanoplots are a port of Great Tables' `_utils_nanoplots.py` (MIT): the same SVG, sizes,
  defaults and labels, and the box plot of both. Their style rules are in the table's CSS, once,
  not inside every SVG; colours can be CSS variables (moved into `style`). `referenceLine` and
  the two values of `referenceArea` are text: a number ("10") or a keyword ("mean", "q1", ...).
  Not yet: `columns_x_vals` and cells with x values, per-point options (a list of colours),
  `alt` from a column. *gt:* `fmt_nanoplot()` and `cols_nanoplot()`, both experimental, with
  `autohide`; *Great Tables:* `fmt_nanoplot()` only, with `missing_vals = "marker"` by default
  (gt and tabelline: `"gap"`).
- In text output a nanoplot is a sparkline ("▁▃▅█ 1–8"), a bar of blocks beside a zero line
  ("███│ −4"), or the five numbers of a box plot. gt and Great Tables draw nothing there.
- Icons: the same Font Awesome Free 7 set as Great Tables (gt: the fontawesome R package), the
  regular style when there are two, full names ("fas fa-star") and older names. `fillColors`
  colours them by name (gt and Great Tables: `fill_color` as a named list). `a11y` is
  "semantic" by default, as in gt (Great Tables: decorative). An unknown name raises
  `ValueError` when the verb is called.
- Images: inlined by default (`encode = true`), as gt and Great Tables; `alt` takes `{x}`. Not
  in: `local_image()`, `web_image()`, `ggplot_image()` (helpers for text cells), and loading
  addresses to inline them (tabelline loads nothing remote).

## Capabilities

### Modified Capabilities

- `formatting`: Icons, Images, Nanoplots (new).
- `table-parts`: Columns of nanoplots (new).
