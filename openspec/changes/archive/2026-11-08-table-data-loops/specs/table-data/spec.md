## MODIFIED Requirements

### Requirement: Data from Nim values
`toTableData` (and `tabella` directly) SHALL take a sequence of objects or named tuples, one
column per field in field order. `tableData:` SHALL take one `name: [values]` line per column,
converting each value on its own; a name MAY have dots (`size.mass: [...]`, read whole, as
`tabSpannerDelim` wants) or be quoted (`` `mass kg` ``, `"mass (kg)"`). The values MAY be any list
(such as a `collect`). A `for` or `if` in the body SHALL add the columns of its own lines, and a
name MAY be computed when the line runs: `$j: [...]`, or any expression in parentheses. `parseCsv` and `readCsv` SHALL read a CSV text with a header,
inferring ints, floats, bools and missing values (empty, `NA`), and a column mixing ints and
floats SHALL be a float column.

```nim
type Pupil = object
  name: string
  stars: int
echo tabella(@[Pupil(name: "Ada", stars: 3), Pupil(name: "Bruno", stars: 1)])
let d = tableData:
  subject: ["maths", "art"]
  mark: [9, nil]
echo tabella(d)
let tavola = tableData:
  `×`: collect(for i in 1 .. 3: i)
  for j in 1 .. 3:
    $j: collect(for i in 1 .. 3: i * j)
echo tabella(tavola, rownameCol = "×")
echo tabella(parseCsv("a,b\n1,2.5\n2,3\n"))
```

```text
┌───────┬───────┐
│ name  │ stars │
╞═══════╪═══════╡
│ Ada   │     3 │
│ Bruno │     1 │
└───────┴───────┘
┌─────────┬──────┐
│ subject │ mark │
╞═════════╪══════╡
│ maths   │    9 │
│ art     │      │
└─────────┴──────┘
┌───┬───┬───┬───┐
│   │ 1 │ 2 │ 3 │
╞═══╪═══╪═══╪═══╡
│ 1 │ 1 │ 2 │ 3 │
│ 2 │ 2 │ 4 │ 6 │
│ 3 │ 3 │ 6 │ 9 │
└───┴───┴───┴───┘
┌───┬─────┐
│ a │   b │
╞═══╪═════╡
│ 1 │ 2.5 │
│ 2 │ 3.0 │
└───┴─────┘
```

#### Scenario: No rows
- **WHEN** an empty sequence of objects is given
- **THEN** the data has the fields as columns and no rows

#### Scenario: A misspelt column
- **WHEN** a verb names a column that is not in the data
- **THEN** it raises a `KeyError` that lists the columns there are
