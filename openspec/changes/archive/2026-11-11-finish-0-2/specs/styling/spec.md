## ADDED Requirements

### Requirement: The other options for an HTML table
`tabOptions` SHALL take the options of gt's `tab_options()` that change an HTML table and that
0.1 did not have, in camelCase: `tableAlign` ("center", "left", "right"),
`tableNoDataMessage` (shown in the body when no row is shown), `tableAdditionalCss` (added as
`optCss` adds), `tableFontColorLight` (text on dark cells: `dataColor`, dark headings),
`columnLabelsHidden`, `columnLabelsUnitsPattern` (for the units of `colsUnits` that give no
pattern), `rowGroupDefaultLabel` (a heading for the rows outside any group), `rowGroupAsColumn`,
`stubIndentLength` (one level of `tabStubIndent`), `stubSeparate` (the rule after the stub), the
six `stubRowGroup*` (font size and weight, text transform, border style, width and colour of the
groups as a column), `footnotesMultiline` and `footnotesSep`, `sourceNotesMultiline` and
`sourceNotesSep` (all notes on one line, with a separator), `rowStripingIncludeStub` (stripes in
the stub too, off by default as in gt) and `rowStripingIncludeTableBody`. The text and Markdown
output SHALL follow the ones that are not about looks (hidden labels, the units pattern, the
default group label, groups as a column, the notes on one line, the no-data message).

```nim
let d = tableData:
  name: ["Io", "Europa", "Titan"]
  planet: ["Jupiter", "Jupiter", ""]
  radius: [1821.6, 1560.8, 2574.7]
let t = tabella(d, rownameCol = "name", groupnameCol = "planet"):
  colsUnits:
    radius: "km"
  tabFootnote "Galilean moons.", loc.rowGroups()
  tabSourceNote "NASA"
  tabSourceNote "JPL"
  tabOptions:
    columnLabelsUnitsPattern = "{1} ({2})"
    rowGroupDefaultLabel = "Other moons"
    sourceNotesMultiline = false
    sourceNotesSep = " · "
echo t
let empty = tabella(d):
  rowsHide [0, 1, 2]
  tabOptions(tableNoDataMessage = "No moons")
echo empty
```

```text
┌────────┬─────────────┐
│        │ radius (km) │
╞════════╪═════════════╡
│ Other moons          │
├┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┄┄┄┤
│ Titan  │      2574.7 │
├────────┼─────────────┤
│ Jupiter^1            │
├┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┄┄┄┤
│ Io     │      1821.6 │
│ Europa │      1560.8 │
└────────┴─────────────┘
1 Galilean moons.
NASA · JPL
┌──────┬────────┬────────┐
│ name │ planet │ radius │
╞══════╪════════╪════════╡
│ No moons               │
└──────┴────────┴────────┘
```
