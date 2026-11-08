## MODIFIED Requirements

### Requirement: Data from Nim values
`toTableData` (and `tabella` directly) SHALL take a sequence of objects or named tuples, one
column per field in field order. `tableData:` SHALL take one `name: [values]` line per column,
converting each value on its own; a name MAY have dots (`size.mass: [...]`, read whole, as
`tabSpannerDelim` wants) or be quoted (`` `mass kg` ``, `"mass (kg)"`). `parseCsv` and `readCsv` SHALL read a CSV text with a header,
inferring ints, floats, bools and missing values (empty, `NA`), and a column mixing ints and
floats SHALL be a float column. With `comment = "#"` (or any prefix) they SHALL skip the lines
that start with it after any spaces; by default no line is a comment.

```nim
type Pupil = object
  name: string
  stars: int
echo tabella(@[Pupil(name: "Ada", stars: 3), Pupil(name: "Bruno", stars: 1)])
let d = tableData:
  subject: ["maths", "art"]
  mark: [9, nil]
echo tabella(d)
echo tabella(parseCsv("# from a notebook\na,b\n1,2.5\n2,3\n", comment = "#"))
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
┌───┬─────┐
│ a │   b │
╞═══╪═════╡
│ 1 │ 2.5 │
│ 2 │ 3.0 │
└───┴─────┘
```

#### Scenario: Comment lines
- **WHEN** a CSV text has lines starting with `#` and `comment = "#"` is given
- **THEN** those lines are skipped, and a `#` inside a value is kept

#### Scenario: No rows
- **WHEN** an empty sequence of objects is given
- **THEN** the data has the fields as columns and no rows

#### Scenario: A misspelt column
- **WHEN** a verb names a column that is not in the data
- **THEN** it raises a `KeyError` that lists the columns there are
