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
