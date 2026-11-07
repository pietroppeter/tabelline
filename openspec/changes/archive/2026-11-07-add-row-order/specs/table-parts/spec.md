## ADDED Requirements

### Requirement: Order of rows and groups
`rowOrder(columns, reverse)` SHALL show the rows sorted by the columns (the first decides, the next
break ties), within their groups, with missing values last; `rowGroupOrder(groups)` SHALL show the
row groups in the given order, the others after them as they were.

```nim
echo tabella(planets(), rownameCol = "planet", groupnameCol = "type")
  .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .rowOrder("moons", reverse = true)
  .rowGroupOrder(["Ice giant", "Gas giant"])
```

```text
┌─────────┬───────┐
│         │ moons │
╞═════════╪═══════╡
│ Ice giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus  │    28 │
│ Neptune │    16 │
├─────────┼───────┤
│ Gas giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Saturn  │   146 │
│ Jupiter │    95 │
├─────────┼───────┤
│ Terrestrial     │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mars    │     2 │
│ Earth   │     1 │
│ Mercury │     0 │
│ Venus   │     0 │
└─────────┴───────┘
```
