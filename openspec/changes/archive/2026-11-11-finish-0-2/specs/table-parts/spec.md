## ADDED Requirements

### Requirement: Stub of several columns
`tabella(data, rownameCol = ["mfr", "model"])` SHALL make a stub of those columns, the leftmost
the highest level and the last the row names. A value of a higher level equal to the one above
it, under the same higher levels and in the same group, SHALL be drawn once: in HTML a `<th>`
spanning its rows, in text and Markdown a blank cell. The stubhead SHALL span the stub.
`loc.stub(rows, cols)` SHALL pick stub columns (all of them by default), `loc.body` SHALL leave
them out, and `stubColumns(t)` SHALL give them in order. `extractBody` SHALL give every level, on
every row.

```nim
let d = tableData:
  mfr: ["Ferrari", "Ferrari", "Ford", "Ford", "Fiat"]
  model: ["Roma", "Portofino", "GT", "Mustang", "500"]
  hp: [612, 600, 647, 450, 69]
let t = tabella(d, rownameCol = ["mfr", "model"]):
  tabStubhead "car"
  tabStyle style.text(weight = "bold"), loc.stub(cols = "mfr")
echo t
echo "stub: ", stubColumns(t).join(", "), "; cells over two rows: ", t.toHtml.count("rowspan=\"2\"")
```

```text
┌─────────┬───────────┬─────┐
│ car     │           │  hp │
╞═════════╪═══════════╪═════╡
│ Ferrari │ Roma      │ 612 │
│         │ Portofino │ 600 │
│ Ford    │ GT        │ 647 │
│         │ Mustang   │ 450 │
│ Fiat    │ 500       │  69 │
└─────────┴───────────┴─────┘
stub: mfr, model; cells over two rows: 2
```

### Requirement: Groups as a column
With `tabOptions(rowGroupAsColumn = true)`, or `tabella(data, rownameCol, groupnameCol,
rowGroupAsColumn = true)` (as gt's `row_group_as_column`), the label of each group SHALL be the
first column of the stub, spanning the group's rows and summary rows, instead of a row above
them; the grand summary rows' labels SHALL span the whole stub. In text and Markdown the label
SHALL be on the group's first row.

```nim
let d = tableData:
  model: ["GT", "Mustang", "Roma", "Portofino"]
  kind: ["sport", "sport", "touring", "touring"]
  hp: [647, 450, 612, 600]
let t = tabella(d, rownameCol = "model", groupnameCol = "kind", rowGroupAsColumn = true):
  summaryRows:
    total: agg.sum
echo t
```

```text
┌─────────┬───────────┬──────┐
│         │           │   hp │
╞═════════╪═══════════╪══════╡
│ sport   │ GT        │  647 │
│         │ Mustang   │  450 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┤
│         │ total     │ 1097 │
├─────────┼───────────┼──────┤
│ touring │ Roma      │  612 │
│         │ Portofino │  600 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┤
│         │ total     │ 1212 │
└─────────┴───────────┴──────┘
```

### Requirement: A spanner gathers its columns
`tabSpanner` SHALL move its columns next to the first of them, in the order given, so its label
spans them all, as gt's `gather = TRUE`; `gather = false` SHALL leave them where they are.

```nim
let t = tabella(planets(), rownameCol = "planet"):
  colsHide ["type", "density", "gravity", "day_length", "orbital_period", "mean_temp", "rings"]
  rowsHide 2 .. 7
  tabSpanner "size", ["mass", "diameter", "moons"]
echo t
```

```text
┌─────────┬──────┬──────────┬───────┬──────────┐
│         │          size           │          │
│         │ mass │ diameter │ moons │ distance │
╞═════════╪══════╪══════════╪═══════╪══════════╡
│ Mercury │ 0.33 │     4879 │     0 │     57.9 │
│ Venus   │ 4.87 │    12104 │     0 │    108.2 │
└─────────┴──────┴──────────┴───────┴──────────┘
```

### Requirement: Summary rows with the same label are one row
Two summary verbs that give a row of the same label, in the same group and on the same side,
SHALL make one row, each filling its own columns, as gt does. `extractSummary(t, values = true)`
SHALL give the values of the summary cells instead of their text, as gt's `extract_summary()`.

```nim
let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "diameter"]
  rowsHide 0 .. 3
  summaryRows:
    total: agg.sum
    columns = "moons"
  summaryRows:
    total: agg.sum
    columns = "mass"
    fmtNumber(decimals = 0)
echo t
echo extractSummary(t, values = true)["mass", 0].kind
```

```text
┌─────────┬────────┬───────┐
│         │   mass │ moons │
╞═════════╪════════╪═══════╡
│ Gas giant                │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter │ 1898.0 │    95 │
│ Saturn  │  568.0 │   146 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │  2,466 │   241 │
├─────────┼────────┼───────┤
│ Ice giant                │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus  │   86.8 │    28 │
│ Neptune │  102.0 │    16 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │    189 │    44 │
└─────────┴────────┴───────┘
vkFloat
```

### Requirement: A line break in Markdown
In `md(...)` text, two spaces before a newline, or a backslash before it, SHALL be a line break
(`<br>` in HTML, a space in text output), as in Markdown.

```nim
let t = tabella(planets()):
  colsHide ["type", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings", "diameter", "moons"]
  rowsHide 1 .. 7
  tabSpanner md("Mass  \n(10²⁴ kg)"), "mass"
echo t
echo "<br>" in t.toHtml
```

```text
┌─────────┬────────────────┐
│         │ Mass (10²⁴ kg) │
│ planet  │           mass │
╞═════════╪════════════════╡
│ Mercury │           0.33 │
└─────────┴────────────────┘
true
```
