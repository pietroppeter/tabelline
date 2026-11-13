## Why

Pietro, 11 Nov 2026 (release thread of 0.2): the islands story should show "shapes of the
islands! Could we do them as nanoplots? (Of course their scale would be different)". A line
nanoplot sorts its points by x, so it cannot draw an outline. A shape is a small plot that fits
a cell as well as a line does: an island, a country, a lake, a running track, a floor plan.
Built in this PR, with the islands story (*Islands of the Mediterranean*) that uses it.

## What Changes

- `fmtNanoplot` and `nanoplotSvg` take `plotType = "shape"`: the cell is a record of `x` and
  `y` (as for a line plot), and the points are joined in their order and closed into one
  filled path, at the same scale across and up, in a square as high as the plot.
- With `autoscale` every shape of the column takes the scale of the largest one, so their sizes
  compare; without it each shape fills its square.
- A missing value (`NaN`, `nil`) in `x` or `y` starts a new ring: an island with its islets, a
  shape with a hole (filled even-odd).
- The fill and the line are `dataBarFillColor` and `dataBarStrokeColor` of `nanoplotOptions`;
  `showDataArea = false` and `showDataLine = false` leave them out. The line keeps its width
  whatever the scale.
- In text a shape is "◆ shape of N points"; a screen reader reads "Shape of N points" (or `alt`).
- `nanoplotSvg` gets `side` (the square's side in the data's units, 0 for the shape's own);
  `plotTypes` lists the four kinds; `shapeSide` gives a shape's side.

## Differences from gt and Great Tables

- gt's and Great Tables' nanoplots are line, bar and box plots; neither draws a shape. It gets
  a line in *Not from gt*. The closest is a `fmt_image()` of an outline drawn elsewhere, or
  gtExtras' `gt_plt_*` sparklines (all of them charts of values, none a shape).
- The arguments are those of a line plot; nothing new is needed but the `plotType`.

## Impact

`src/tabelline/nanoplots.nim`; tests in `tests/test_shape_nanoplot.nim`; the formatting spec;
the Feature map's *Not from gt*; the islands story and its data post use it.
