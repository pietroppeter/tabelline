## Why

Pietro's review of the islands story (version 8, 12 Nov 2026), on the unemployment table:
"The crisis of the 2010s is a hill on every line": "Let's add a vertical line then". That table
draws twenty columns (`y2006` ... `y2025`) with `colsNanoplot`, whose cells were a text of
numbers with no places on x, so `referenceX` had no axis to mark.

## What Changes

- `colsNanoplot(xVals = @[2006.0, ..., 2025.0])`: one place on the x axis for each column, the
  same in every row. Each cell is then a record of `x` and `y`, and `referenceX` (passed on to
  `fmtNanoplot`) draws its dashed vertical lines. `xVals` of another length than the columns
  raises `ValueError`. Without `xVals` nothing changes.

## Differences from gt and Great Tables

- gt's `cols_nanoplot()` has `columns_x_vals`, columns that hold the x places, read row by row;
  `xVals` is one list for every row, the case of columns named by year. It gets a line in
  *Not from gt*. Great Tables' `cols_nanoplot()` has no x places.
- `referenceX` is not from gt either (see the change `2026-11-12-x-axis-and-slanted-labels`).
