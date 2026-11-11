# table-data Specification

## Purpose
The data a table shows: named columns of values, read once from Nim values, columns or CSV, and
never changed by the table.

## Requirements

### Requirement: Values
A cell SHALL hold a `Value`: missing (`vkNull`), a bool, an int, a float or a string. `toValue`
SHALL convert Nim values, with `nil`, `none(T)` and a float NaN as missing. A `Value` SHALL compare
with plain Nim numbers and strings, so row predicates read naturally.

```nim
echo toValue(3) == 3.0, " ", toValue(2.5) > 2, " ", toValue(none(int)).isNull
```

```text
true true true
```

#### Scenario: A missing number
- **WHEN** a column holds `1`, `nil` and `3`
- **THEN** it is an int column whose second value is missing

### Requirement: Data from Nim values
`toTableData` (and `tabella` directly) SHALL take a sequence of objects or named tuples, one
column per field in field order. `tableData:` SHALL take one `name: [values]` line per column,
converting each value on its own; a name MAY have dots (`size.mass: [...]`, read whole, as
`tabSpannerDelim` wants) or be quoted (`` `mass kg` ``, `"mass (kg)"`). The values MAY be any list
(such as a `collect`). A `for` or `if` in the body SHALL add the columns of its own lines, and a
name MAY be computed when the line runs: `$j: [...]`, or any expression in parentheses. `parseCsv` and `readCsv` SHALL read a CSV text with a header,
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
let tavola = tableData:
  `×`: collect(for i in 1 .. 3: i)
  for j in 1 .. 3:
    $j: collect(for i in 1 .. 3: i * j)
echo tabella(tavola, rownameCol = "×")
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

#### Scenario: Comment lines
- **WHEN** a CSV text has lines starting with `#` and `comment = "#"` is given
- **THEN** those lines are skipped, and a `#` inside a value is kept

#### Scenario: No rows
- **WHEN** an empty sequence of objects is given
- **THEN** the data has the fields as columns and no rows

#### Scenario: A misspelt column
- **WHEN** a verb names a column that is not in the data
- **THEN** it raises a `KeyError` that lists the columns there are

### Requirement: Datasets
`tabelline/datasets` SHALL provide `planets()` (NASA's planetary fact sheet), `exibble()` (gt's
example table), `tavolaPitagorica(n)` (the n×n times table), `isole()` (the islands of the
Mediterranean, the twin of gt's `islands`) and `citta()` (the largest cities of the European
Union, the twin of gt's `towny`), built into the module.

```nim
echo tabella(tavolaPitagorica(4), rownameCol = "×")
echo isole().nrows, " islands, ", citta().nrows, " cities; the largest: ", isole()["island", 0], ", ", citta()["city", 0]
```

```text
┌───┬───┬───┬────┬────┐
│   │ 1 │ 2 │  3 │  4 │
╞═══╪═══╪═══╪════╪════╡
│ 1 │ 1 │ 2 │  3 │  4 │
│ 2 │ 2 │ 4 │  6 │  8 │
│ 3 │ 3 │ 6 │  9 │ 12 │
│ 4 │ 4 │ 8 │ 12 │ 16 │
└───┴───┴───┴────┴────┘
194 islands, 95 cities; the largest: Sicily, Berlin
```

### Requirement: Lists and records in a cell
A cell SHALL hold a list (`vkList`, items in order) or a record (`vkRecord`, named fields in
order). `toValue` SHALL make a list from a seq or an array and a record from an object or a
named tuple, so `tableData:` and `toTableData` take them as they are; CSV SHALL never make them.
`v[i]` SHALL be an item and `v["x"]` a field (`KeyError` when there is none), `len` their count.
`$` SHALL write a list as "1, 4, 2" and a record as "x: 1, y: 2"; `==` SHALL compare item by
item; `<` SHALL order lists item by item; a list or record SHALL NOT be a number, and `toFloat`
SHALL raise `ValueError` on it. A column of them SHALL have the kind of its cells and not be
numeric.

```nim
let moons = tableData:
  planet: ["Earth", "Mars", "Jupiter"]
  moons: [@["Moon"], @["Phobos", "Deimos"], @["Io", "Europa", "Ganymede", "Callisto"]]
  biggest: [(name: "Moon", km: 3474.8), (name: "Phobos", km: 22.5), (name: "Ganymede", km: 5268.2)]
echo tabella(moons, rownameCol = "planet")
let r = moons["biggest", 2]
echo r.name, " ", r.km, " ", moons["moons", 1][0], " ", moons["moons", 2].len
```

```text
┌─────────┬────────────────────────────────┬────────────────────────────┐
│         │ moons                          │ biggest                    │
╞═════════╪════════════════════════════════╪════════════════════════════╡
│ Earth   │ Moon                           │ name: Moon, km: 3474.8     │
│ Mars    │ Phobos, Deimos                 │ name: Phobos, km: 22.5     │
│ Jupiter │ Io, Europa, Ganymede, Callisto │ name: Ganymede, km: 5268.2 │
└─────────┴────────────────────────────────┴────────────────────────────┘
Ganymede 5268.2 Phobos 4
```

### Requirement: gt's datasets
`tabelline/datasets` SHALL have four of gt's datasets as Great Tables ships them (MIT):
`gtcars()` (47 cars, 15 columns), `countrypops()` (the population of every country, 1960 to
2022), `illness()` (a patient's tests, days 3 to 9) and `metro()` (the stations of the Paris
Metro).

```nim
let cars = gtcars()
echo cars.nrows, " ", cars.ncols, " ", cars["model", 0]
echo "countrypops: ", countrypops().names.join(", "), "; illness: ", illness().nrows, " rows, metro: ", metro().nrows, " rows"
```

```text
47 15 GT
countrypops: country_name, country_code_2, country_code_3, year, population; illness: 39 rows, metro: 314 rows
```

### Requirement: Data frames of nanuq
`import tabelline/nanuq` SHALL make `toTableData(df)` and `tabella(df)` (so `tabella(df): body`)
work for a nanuq DataFrame, copying every column in order: integers as ints, floats as floats,
booleans as bools, strings as text, any other type as the text Polars writes for it, and a null
as a missing value. It SHALL be the only module of tabelline that imports nanuq; nanuq SHALL be
part of the `docs` feature, so the core keeps needing only Nim's standard library.

#### Scenario: A summary made in nanuq
- **WHEN** a DataFrame is grouped and summarised in nanuq and given to `tabella(df): body`
- **THEN** the table has the frame's columns in order, numbers aligned right, and the body's verbs apply as for any data

#### Scenario: Nulls
- **WHEN** a column of the DataFrame holds a null
- **THEN** that cell is missing (`isNull`), and `subMissing` shows it as for any data
