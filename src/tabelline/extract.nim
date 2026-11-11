## The built table as data: what a reader sees, cell by cell, as gt's `extract_body()`,
## `extract_cells()` and `extract_summary()` give it.

import std/[sequtils, strutils]
import core, build

proc extractCells*(t: Tabella, columns: ColSel, rows = allRows(), ctx = rcText): seq[string] =
  ## The shown text of the body cells of `columns` and `rows`, column by column, each in the
  ## order the table shows its rows: `extractCells(t, "mass")`. `ctx = rcHtml` gives HTML.
  let b = t.build(ctx)
  let wanted = rows.resolve(t.data)
  for name in columns.resolve(t.data):
    let j = b.columns.mapIt(it.name).find(name)
    for g in b.groups:
      for r in g.rows:
        if r.index notin wanted: continue
        result.add(if j >= 0: r.cells[j]
                   elif name == t.rownameCol: r.stub
                   elif name in t.stubCols: r.levels[t.stubCols.find(name)]
                   else: t.shownCell(r.index, name, ctx))

proc extractBody*(t: Tabella, ctx = rcText): TableData =
  ## The body as a table of texts, in the order shown: a column `group` (when the table has row
  ## groups), the stub (`rowname`, when it has one) and every visible column, with the formats,
  ## merges and substitutions applied.
  let b = t.build(ctx)
  var cols: seq[(string, seq[Value])]
  if t.hasGroups: cols.add ("group", newSeq[Value]())
  for c in t.stubCols: cols.add (c, newSeq[Value]())
  if t.hasRowNames: cols.add ("rowname", newSeq[Value]())
  for c in b.columns: cols.add (c.name, newSeq[Value]())
  for g in b.groups:
    for r in g.rows:
      var k = 0
      if t.hasGroups:
        cols[k][1].add toValue(g.label)
        inc k
      for v in r.levels:   # every row says its levels, as the data does
        cols[k][1].add toValue(v)
        inc k
      if t.hasRowNames:
        cols[k][1].add toValue(r.stub)
        inc k
      for j, s in r.cells: cols[k + j][1].add toValue(s)
  toTableData(cols)

proc extractSummary*(t: Tabella, ctx = rcText): TableData =
  ## The summary rows as a table of texts: `group` ("" for a grand summary row), `label`, and a
  ## cell for each visible column, as shown.
  let b = t.build(ctx)
  var cols: seq[(string, seq[Value])] = @[("group", newSeq[Value]()), ("label", newSeq[Value]())]
  for c in b.columns: cols.add (c.name, newSeq[Value]())
  proc add(gid: string, rows: seq[BuiltSummary]) =
    for s in rows:
      cols[0][1].add toValue(gid)
      cols[1][1].add toValue(s.label)
      for j, x in s.cells: cols[2 + j][1].add toValue(x)
  for g in b.groups:
    add(g.id, g.summaryTop)
    add(g.id, g.summaryBottom)
  add("", b.grandTop)
  add("", b.grandBottom)
  toTableData(cols)
