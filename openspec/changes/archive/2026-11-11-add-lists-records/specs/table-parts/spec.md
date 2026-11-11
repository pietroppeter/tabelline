## ADDED Requirements

### Requirement: Fields of a record in a merge pattern
A `colsMerge` pattern SHALL read the fields of a record: `{2.lo}` is the field `lo` of the record
in column 2, and `{lo}` the field `lo` of column 1. Each field SHALL be formatted as its column
is, and SHALL count as missing for a `<<...>>` part when it is missing. A pattern of one column
SHALL show that column's records in the pattern. The verb SHALL raise `ValueError` when a field
the pattern names is not in every record of its column, or the column does not hold records.

```nim
let d = tableData:
  sensor: ["north", "south"]
  span: [(lo: 0.82, hi: 1.56), (lo: 9.13, hi: 12.71)]
  unit: ["mm", "cm"]
let t = tabella(d, rownameCol = "sensor"):
  fmtNumber "span", decimals = 1
  colsMerge ["span", "unit"], pattern = "{lo}–{hi}<< {2}>>"
echo t
```

```text
┌───────┬─────────────┐
│       │ span        │
╞═══════╪═════════════╡
│ north │ 0.8–1.6 mm  │
│ south │ 9.1–12.7 cm │
└───────┴─────────────┘
```
