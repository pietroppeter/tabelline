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
a slice or `where(cond)`, where `it` is the row and `it["col"]` its value.

```nim
let d = planets()
echo startsWith("d").resolve(d), " ", where(it["moons"] > 20).resolve(d), " ", toRowSel(1..2).resolve(d)
```
