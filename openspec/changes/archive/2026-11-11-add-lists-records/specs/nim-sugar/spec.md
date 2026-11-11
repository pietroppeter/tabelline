## ADDED Requirements

### Requirement: Values by name with a dot
`v.x` SHALL be the field `x` of a record (`v["x"]`) and, in a row predicate or a proc of a row,
`it.mass` SHALL be the column `mass` of that row (`it["mass"]`). A name that Value or Row already
has (`kind`, `len`, `items`, `fields`, `data`, `index`, ...) SHALL be that, not the field or
column, and a Nim keyword cannot follow a dot: both SHALL still be read with brackets. A name
the record or table does not have SHALL raise `KeyError` when the code runs.

```nim
let t = tabella(planets(), rownameCol = "planet"):
  colsHide ["type", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "diameter"]
  rowsHide where(it.moons < 10)
echo t
```

```text
┌─────────┬────────┬───────┐
│         │   mass │ moons │
╞═════════╪════════╪═══════╡
│ Jupiter │ 1898.0 │    95 │
│ Saturn  │  568.0 │   146 │
│ Uranus  │   86.8 │    28 │
│ Neptune │  102.0 │    16 │
└─────────┴────────┴───────┘
```
