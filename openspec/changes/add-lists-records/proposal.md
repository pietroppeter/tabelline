## Why

Pietro, 11 Nov 2026 (book thread): build lists and records now, in 0.2. The book's port of the
Great Tables blog found that Great Tables draws a nanoplot from a Polars list column, and from a
dict of x and y values, and tabelline could only read numbers from a text ("1 4 2"). A cell that
holds several values, as a list or as named fields, serves nanoplots, icons, images and flags,
and the data frames planned for 0.3. Pietro also asked for the dot: `v.x` for a field and
`it.mass` for a column of a row, used in every example from now on.

## What Changes

- `ValueKind` gets `vkList` (`items: seq[Value]`) and `vkRecord` (`fields: seq[(string, Value)]`,
  in order). `toValue` makes a list from a seq or an array, and a record from an object or a
  named tuple, reading its fields as `toTableData` does; `list(...)` and `record(...)` make them
  by hand. So `tableData:` takes a column of lists or records as it is.
- `v[i]` is an item, `v["x"]` a field, `"x" in v` says whether it is there, `len` counts them,
  `isList` and `isRecord` tell them apart. `$` writes "1, 4, 2" and "x: 1, y: 2"; `==` compares
  them item by item; `<` orders lists as words are ordered; `isNumber` is false and `toFloat`
  raises `ValueError`. CSV never makes them.
- The dot: `v.x` is `v["x"]` and, on a row, `it.mass` is `it["mass"]` (a dot operator, the
  experimental `dotOperators` of Nim, turned on in the library only). A name that Value or Row
  already has (`kind`, `len`, `items`, `index`, ...) is that, not the field; a Nim keyword
  (`type`) cannot follow a dot. Both still have the brackets. Every example in the docs and the
  specs now uses the dot where it can.
- A format applies to a list or a record item by item, field by field ("1.2, 1.6"; "low: 0.8,
  high: 1.6"). The formats that take several names (`fmtIcon`, `fmtImage`, `fmtFlag`) and
  `fmtNanoplot` take a list whole: a list of names is the same as names separated by commas.
- `fmtNanoplot` reads a list of numbers, and a record whose field `y` holds the values and `x`
  their places on the x axis (Great Tables' dict), for line plots: the points are spaced as `x`
  says, in its order, and with `autoscale` every row shares the x axis too. `expandX` widens it.
  `nanoplotXValues` reads the places; `nanoplotSvg` takes `x` and `expandX`.
- `dataColor` leaves list and record cells uncoloured; summaries count only numbers, as before.

## Differences from gt and Great Tables

- gt keeps one value per cell; its `fmt_nanoplot` and `cols_nanoplot` read numbers from a text
  or from several columns, and gtExtras draws from tibble list-columns. Great Tables reads Polars
  list columns for nanoplots and, for x and y, a dict (`{"x": [...], "y": [...]}`). tabelline
  reads all of these: a list, a record of `x` and `y`, a text of numbers, several columns.
- Records shown as text and formatted field by field are not from gt (closest: `cols_merge`, a
  pattern of several columns in one cell); they get a line in *Not from gt*.
- The dot is Nim sugar: gt and Great Tables select by name in strings, Polars with `pl.col("x")`.
- Great Tables' x values also take dates; tabelline's are numbers for now.

## Impact

`src/tabelline/core.nim` (Value, Row, `cellNames`), `build.nim` (formats item by item),
`nanoplots.nim`, `pictures.nim`, `formats.nim` (`fmtFlag`), `verbs.nim` (`dataColor`); tests in
`tests/test_lists_records.nim`; the guide's Nim sugar, section 6 of *Designing tabelline 0.2*,
the Feature map and *Not from gt*; every `it["x"]` of the docs and specs is now `it.x`.
