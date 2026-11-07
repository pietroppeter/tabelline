## ADDED Requirements

### Requirement: Spanners from column names
`tabSpannerDelim(delim = ".", columns, split = "last", limit = -1, reverse = false)` SHALL split
column names at `delim`: the last part SHALL become the label and the parts before it spanners,
the first part highest. Next to each other, columns with the same parts SHALL share a spanner.
`limit` SHALL cap the number of splits, counted from the `split` side; `reverse` SHALL read the
parts the other way round.

```nim
let d = tableData:
  planet: ["Earth", "Mars"]
  `size.diameter`: [12756, 6792]
  `size.mass`: [5.97, 0.642]
  `orbit.period.days`: [365.2, 687.0]
  `orbit.period.years`: [1.0, 1.88]
  `orbit.distance`: [149.6, 228.0]
echo tabella(d, rownameCol = "planet").tabSpannerDelim()
```

```text
┌───────┬──────────┬───────┬───────┬───────┬──────────┐
│       │                  │          orbit           │
│       │       size       │    period     │          │
│       │ diameter │  mass │  days │ years │ distance │
╞═══════╪══════════╪═══════╪═══════╪═══════╪══════════╡
│ Earth │    12756 │  5.97 │ 365.2 │   1.0 │    149.6 │
│ Mars  │     6792 │ 0.642 │ 687.0 │  1.88 │    228.0 │
└───────┴──────────┴───────┴───────┴───────┴──────────┘
```

#### Scenario: A name with no delimiter
- **WHEN** a selected column has no `delim` in its name
- **THEN** its label stays and it gets no spanner
