## ADDED Requirements

### Requirement: Columns by kind and by a test, rows from the end
`ofKind(vkBool, ...)` SHALL select the columns whose values are of these kinds (a missing value
counts as any), as Great Tables' `cs.by_dtype()` and gt's `where(is.logical)`. `named(cond)`
SHALL select the columns whose name `it` passes `cond`, and `matches(proc)` those whose name
passes a proc, as gt's `matches()` does with a regular expression. `a & b` SHALL select the
columns of both. A negative row index SHALL count from the end (`-1` is the last row), and so
SHALL Nim's `^1`. A block of `colsLabel` SHALL take plain labels and `html`/`md` ones together.

```nim
let d = planets()
echo ofKind(vkBool).resolve(d).join(", ")
echo named(it.len == 4).resolve(d).join(", ")
echo (numeric() & startsWith("d")).resolve(d).join(", ")
echo toRowSel(-1).resolve(d), " ", toRowSel(^2).resolve(d)
let t = tabella(planets()):
  colsLabel:
    planet: "Planet"
    moons: md"*Moons*"
echo t.toHtml.contains("<em>Moons</em>"), " ", t.toHtml.contains(">Planet<")
```

```text
rings
type, mass
diameter, density, day_length, distance
@[7] @[6]
true true
```
