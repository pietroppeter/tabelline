# nim-sugar Specification

## Purpose
Where tabelline uses Nim to read better than gt and Great Tables: a recipe macro, converters,
row predicates and namespaces, with macros only where plain procs cannot do the job.

## Requirements

### Requirement: Chains and recipes
Verbs SHALL chain (`tabella(d).tabHeader("x").fmtNumber("y")`), each moving the spec along
(`sink`). `tabella(data, ...): body` SHALL apply the verbs of `body`, one per line, to the new
table: a call `verb(args)` stands for `t = verb(t, args)`, inside `for`, `if`, `when` and `block`
too, and other statements are left as they are. The two forms SHALL make the same table.

```nim
let t = tabella(tavolaPitagorica(4), rownameCol = "×"):
  tabHeader "Squares"
  for i in 1 .. 4:
    tabFootnote "a square", loc.body(cols = $i, rows = [i - 1])
echo t
```

```text
           Squares
┌───┬─────┬─────┬─────┬──────┐
│   │   1 │   2 │   3 │    4 │
╞═══╪═════╪═════╪═════╪══════╡
│ 1 │ 1^1 │   2 │   3 │    4 │
│ 2 │   2 │ 4^1 │   6 │    8 │
│ 3 │   3 │   6 │ 9^1 │   12 │
│ 4 │   4 │   8 │  12 │ 16^1 │
└───┴─────┴─────┴─────┴──────┘
1 a square
```

### Requirement: Selectors that read like Nim
Columns SHALL be selected by a name, an array or seq of names, or a rule (`everything()`,
`numeric()`, `textual()`, `startsWith`, `endsWith`, `containing`); rows by an index, an array,
a slice or `where(cond)`, where `it` is the row and `it.col` its value.

```nim
let d = planets()
echo startsWith("d").resolve(d), " ", where(it.moons > 20).resolve(d), " ", toRowSel(1..2).resolve(d)
```

### Requirement: Blocks for lists of pairs
Inside `tabella(data): body`, a verb whose first argument is a list of pairs (`colsLabel`,
`colsWidth`, `colsUnits`, `textCaseMatch`, `summaryRows`, `grandSummaryRows`, `summaryColumns`)
SHALL also take an indented block, where a line `label: value` is a pair; in any verb a line
`name = value` SHALL be that named argument; in a summary verb a line `fmtX(args)` SHALL be
`fmt`, a proc of a float calling `formatX(x, args)`; `tabOptions:` SHALL take lines
`name = value`. A block SHALL make the same call as the pair form.

```nim
let t = tabella(planets(), rownameCol = "planet"):
  colsHide ["type", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "moons"]
  colsLabel:
    mass: "mass, {{10^24 kg}}"
    diameter: "diameter, {{km}}"
  grandSummaryRows:
    mean: agg.mean
    "largest one": agg.max
    fmtNumber(decimals = 0)
  tabOptions:
    rowStriping = true
echo t
echo t.options.rowStriping
```

```text
┌─────────────┬───────────────┬──────────────┐
│             │ mass, 10²⁴ kg │ diameter, km │
╞═════════════╪═══════════════╪══════════════╡
│ Mercury     │          0.33 │         4879 │
│ Venus       │          4.87 │        12104 │
│ Earth       │          5.97 │        12756 │
│ Mars        │         0.642 │         6792 │
│ Jupiter     │        1898.0 │       142984 │
│ Saturn      │         568.0 │       120536 │
│ Uranus      │          86.8 │        51118 │
│ Neptune     │         102.0 │        49528 │
╞═════════════╪═══════════════╪══════════════╡
│ mean        │           333 │       50,087 │
│ largest one │         1,898 │      142,984 │
└─────────────┴───────────────┴──────────────┘
true
```

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
