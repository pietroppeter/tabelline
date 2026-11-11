## ADDED Requirements

### Requirement: Columns by place, and rules combined
`positions(0, 2)` and `positions(2 .. 4)` SHALL select columns by their place in the data, from
0 as rows are, a negative place counting from the end; a place past the end SHALL raise
`KeyError`. `startsWith`, `endsWith` and `containing` SHALL take several parts, any of them, in brackets
(`startsWith(["ma", "mo"])`: with two texts, `startsWith` is `strutils.startsWith`).
`a + b` SHALL select the columns of either, in the order of the data, and `a - b` those of `a`
that are not in `b`.

```nim
let d = planets()
echo positions(0, -1).resolve(d).join(", ")
echo startsWith(["ma", "mo"]).resolve(d).join(", ")
echo (positions(2 .. 4) + "moons").resolve(d).join(", ")
echo (numeric() - startsWith(["d", "o"])).resolve(d).join(", ")
```

```text
planet, rings
mass, moons
mass, diameter, density, moons
mass, gravity, mean_temp, moons
```
