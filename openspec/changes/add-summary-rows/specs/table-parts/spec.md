## ADDED Requirements

### Requirement: Summary rows
`summaryRows(groups, columns, fns, side = "bottom")` SHALL add, for each listed row group, one row
per aggregate in `fns`, labelled in the stub; `grandSummaryRows(columns, fns, side = "bottom")`
SHALL add the same for the whole table. An aggregate SHALL be a proc from the column's non-missing
values to a `Value`; `sum`, `mean`, `min`, `max` and `count` SHALL be built in. Summary cells SHALL
be formatted with the last format of their column, unless the verb gives its own.

```nim
echo tabella(planets(), rownameCol = "planet", groupnameCol = "type")
  .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  .summaryRows(columns = "moons", fns = @{"total": sum})
  .grandSummaryRows(columns = "moons", fns = @{"all moons": sum})
```

```text
┌─────────────┬───────┐
│             │ moons │
╞═════════════╪═══════╡
│ Terrestrial         │
├┄┄┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mercury     │     0 │
│ Venus       │     0 │
│ Earth       │     1 │
│ Mars        │     2 │
│ total       │     3 │
├─────────────┼───────┤
│ Gas giant           │
├┄┄┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter     │    95 │
│ Saturn      │   146 │
│ total       │   241 │
├─────────────┼───────┤
│ Ice giant           │
├┄┄┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus      │    28 │
│ Neptune     │    16 │
│ total       │    44 │
╞═════════════╪═══════╡
│ all moons   │   288 │
└─────────────┴───────┘
```

#### Scenario: Summary above the group
- **WHEN** `side = "top"` is given
- **THEN** the summary rows come right after the group's label, before its rows

#### Scenario: A group with no numbers
- **WHEN** every value of a summarised column in a group is missing
- **THEN** its summary cell is missing too (blank, or as `subMissing` says)
