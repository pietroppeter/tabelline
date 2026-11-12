## Why

Pietro's third review of the islands story (12 Nov 2026), on the passengers table: "Is it
possible to have the x axis aligned? And what about a dotted vertical line with a reference date
on the pandemic?" And on the climate table: "Can they be rotated not vertical but slanted?",
with the months' names. The rows shared an x axis (`expandX`) but each plot was as wide as its number
of points, so a short series drew a short line, and its curve could turn back on itself where
points were closer than the usual step. A date that matters to every row (a pandemic, a law,
a release) had no way to be marked.

## What Changes

- On a shared x axis (`autoscale` or `expandX` with records of `x` and `y`) every row's line
  plot has the same width, so the axes line up. Plots without places on x are unchanged.
- A curved line takes its control points from the real step between two points, so it never
  turns back. Evenly spaced plots draw exactly as before.
- `fmtNanoplot(referenceX = @["2020-03-11"])`: a dashed vertical line at each place (a number
  or an ISO date) inside the axis, its text on hover; a place that is neither raises
  `ValueError`. `nanoplotSvg` takes the places as `referenceX` (value and label).

- `colsLabelRotate(dir = "slanted")`: labels at 45 degrees, read upwards to the right, for a
  longer label over a narrow column (a month's name over two digits).

## Differences from gt and Great Tables

- gt and Great Tables have a horizontal `reference_line` only; `referenceX` is not from them and
  gets a line in *Not from gt*. The closest is `reference_area`, also horizontal.
- In Great Tables a nanoplot of x and y values is also as wide as its points; here a shared axis
  is one width, which is what "shared" promises.
- gt's `cols_label_rotate()` turns labels sideways only; `"slanted"` is not from gt and gets a
  line in *Not from gt*.
