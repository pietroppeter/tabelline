## The verbs that build a table spec, named after gt and Great Tables in camelCase:
## `tab*` add parts (header, spanners, notes, styles, options), `cols*` change columns,
## `dataColor` and `opt*` change the looks. Each takes a `Tabella` and returns the new one
## (`sink`, so a chain moves the spec along instead of copying it).

import std/[macros, strutils, sequtils, tables, math, algorithm]
import core, colors

# ---------------------------------------------------------------------------------- creating

proc initTabella*(data: TableData, rownameCol = "", groupnameCol = "", id = "", locale = "",
              autoAlign = true): Tabella =
  ## A display table for `data`. `rownameCol` makes a column the stub (row labels),
  ## `groupnameCol` groups the rows by a column, in order of first appearance.
  result = Tabella(data: data, rownameCol: rownameCol, groupnameCol: groupnameCol, id: id, locale: locale)
  for c in data.columns:
    var info = ColInfo(name: c.name, label: toText(c.name), align: alAuto)
    if autoAlign: info.align = if c.isNumeric: alRight else: alLeft
    if c.name == rownameCol: info.role = crStub
    elif c.name == groupnameCol: info.role = crGroup
    result.boxhead.add info
  for name in [rownameCol, groupnameCol]:
    if name.len > 0 and not data.hasColumn(name):
      raise newException(KeyError, "no column named " & name.escape & " (columns: " & data.names.join(", ") & ")")
  result.rowGroups = newSeq[string](data.nrows)
  if groupnameCol.len > 0:
    for i in 0 ..< data.nrows:
      let g = $data[groupnameCol, i]
      result.rowGroups[i] = g
      if g notin result.groupLabels: result.groupLabels[g] = toText(g)

proc initTabella*[T: object | tuple](rows: openArray[T], rownameCol = "", groupnameCol = "", id = "",
                                 locale = ""): Tabella =
  ## A display table straight from Nim objects or named tuples, one field per column.
  initTabella(toTableData(rows), rownameCol, groupnameCol, id, locale)

# ------------------------------------------------------------------------------------- parts

proc tabHeader*(t: sink Tabella, title: Text, subtitle: Text = toText("")): Tabella =
  result = t
  result.title = title
  result.subtitle = subtitle

proc tabStubhead*(t: sink Tabella, label: Text): Tabella =
  result = t
  result.stubhead = label

proc tabSpanner*(t: sink Tabella, label: Text, columns: ColSel, level = 1): Tabella =
  ## A label over `columns` (shown together; keep them next to each other). Higher `level`s sit
  ## above lower ones.
  result = t
  let names = columns.resolve(result.data)
  for s in result.spanners:
    if s.level == level and s.columns.anyIt(it in names):
      raise newException(ValueError, "spanner " & label.s.escape & " overlaps spanner " & s.label.s.escape)
  result.spanners.add Spanner(label: label, columns: names, level: level)

proc tabSourceNote*(t: sink Tabella, note: Text): Tabella =
  result = t
  result.sourceNotes.add note

proc tabRowGroup*(t: sink Tabella, label: Text, rows: RowSel, id = ""): Tabella =
  ## Puts `rows` in a group (made when it is new). Groups show in the order they are made, and
  ## rows in no group come first.
  result = t
  let gid = if id.len > 0: id else: label.s
  for i in rows.resolve(result.data): result.rowGroups[i] = gid
  if gid notin result.groupLabels: result.groupLabels[gid] = label

# --------------------------------------------------------------------------------- locations

func title*(_: LocNs): Loc = Loc(kind: lkTitle)
func subtitle*(_: LocNs): Loc = Loc(kind: lkSubtitle)
func stubhead*(_: LocNs): Loc = Loc(kind: lkStubhead)
func columnLabels*(_: LocNs, cols: ColSel = everything()): Loc = Loc(kind: lkColumnLabels, cols: cols)
func spanners*(_: LocNs, labels: varargs[string]): Loc = Loc(kind: lkSpanners, names: @labels)
func stub*(_: LocNs, rows = allRows()): Loc = Loc(kind: lkStub, rows: rows)
func rowGroups*(_: LocNs, groups: varargs[string]): Loc = Loc(kind: lkRowGroups, names: @groups)
func body*(_: LocNs, cols: ColSel = everything(), rows = allRows()): Loc =
  Loc(kind: lkBody, cols: cols, rows: rows)
func sourceNotes*(_: LocNs): Loc = Loc(kind: lkSourceNotes)
func footnotes*(_: LocNs): Loc = Loc(kind: lkFootnotes)

proc resolve*(l: Loc, t: Tabella): Target =
  result = Target(kind: l.kind)
  case l.kind
  of lkColumnLabels: result.names = l.cols.resolve(t.data)
  of lkSpanners:
    result.names = if l.names.len > 0: l.names else: t.spanners.mapIt(it.label.s)
  of lkRowGroups:
    result.names = if l.names.len > 0: l.names else: toSeq(t.groupLabels.keys)
  of lkStub:
    for i in l.rows.resolve(t.data): result.cells.add (i, t.rownameCol)
  of lkBody:
    let names = l.cols.resolve(t.data)
    for i in l.rows.resolve(t.data):
      for n in names: result.cells.add (i, n)
  else: discard

proc tabStyle*(t: sink Tabella, style: CellStyle, locations: varargs[Loc]): Tabella =
  ## Styles the cells at `locations`: `tabStyle(style.fill("#FFF3B0"), loc.body(rows = [2]))`.
  result = t
  for l in locations:
    result.styles.add StyleRule(target: l.resolve(result), style: style)

proc tabFootnote*(t: sink Tabella, note: Text, locations: varargs[Loc]): Tabella =
  ## A note in the footer, marked at each of `locations` (no location: a plain footnote, no mark).
  result = t
  if locations.len == 0:
    result.footnotes.add Footnote(note: note, target: Target(kind: lkFootnotes))
  for l in locations:
    result.footnotes.add Footnote(note: note, target: l.resolve(result))

# -------------------------------------------------------------------------------------- cols

proc colsLabel*(t: sink Tabella, column: string, label: Text): Tabella =
  result = t
  discard result.data[column]
  for c in result.boxhead.mitems:
    if c.name == column: c.label = label

proc colsLabel*(t: sink Tabella, labels: openArray[(string, string)]): Tabella =
  ## `colsLabel({"mass": "Mass", "diameter": "Diameter"})`.
  result = t
  for (n, l) in labels: result = colsLabel(result, n, toText(l))

proc colsLabel*(t: sink Tabella, labels: openArray[(string, Text)]): Tabella =
  ## `colsLabel({"mass": md("Mass (10^24^ kg)"), "density": md("Density (kg/m^3^)")})`.
  result = t
  for (n, l) in labels: result = colsLabel(result, n, l)

proc colsAlign*(t: sink Tabella, align: Align, columns: ColSel = everything()): Tabella =
  result = t
  let names = columns.resolve(result.data)
  for c in result.boxhead.mitems:
    if c.name in names: c.align = align

proc colsWidth*(t: sink Tabella, widths: openArray[(string, string)]): Tabella =
  ## CSS widths: `colsWidth({"name": "120px", "notes": "30%"})`.
  result = t
  for (n, w) in widths:
    discard result.data[n]
    for c in result.boxhead.mitems:
      if c.name == n: c.width = w

proc colsHide*(t: sink Tabella, columns: ColSel): Tabella =
  result = t
  let names = columns.resolve(result.data)
  for c in result.boxhead.mitems:
    if c.name in names: c.hidden = true

proc colsUnhide*(t: sink Tabella, columns: ColSel): Tabella =
  result = t
  let names = columns.resolve(result.data)
  for c in result.boxhead.mitems:
    if c.name in names: c.hidden = false

proc colsMove*(t: sink Tabella, columns: ColSel, after: string): Tabella =
  ## Moves `columns` (in their given order) right after the column `after`.
  result = t
  let names = columns.resolve(result.data)
  discard result.data[after]
  let moving = names.mapIt(result.colInfo(it))
  result.boxhead.keepItIf(it.name notin names)
  var at = 0
  for i, c in result.boxhead:
    if c.name == after: at = i + 1
  result.boxhead.insert(moving, at)

proc colsMoveToStart*(t: sink Tabella, columns: ColSel): Tabella =
  result = t
  let names = columns.resolve(result.data)
  let moving = names.mapIt(result.colInfo(it))
  result.boxhead.keepItIf(it.name notin names)
  result.boxhead.insert(moving, 0)

# ---------------------------------------------------------------------------------- dataColor

proc dataColor*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(),
                palette: seq[string] = palette("blues"), domain = (NaN, NaN), reverse = false,
                naColor = "#F0F0F0", autoColorText = true, apply = "fill"): Tabella =
  ## Colours cells by value: numbers along `palette` from the low to the high end of `domain`
  ## (by default the range of the selected cells), text by category. `apply = "text"` colours the
  ## text instead of the fill.
  result = t
  let names = columns.resolve(result.data)
  let ix = rows.resolve(result.data)
  let pal = if reverse: palette.reversed else: palette
  var lo, hi = NaN
  var levels: seq[string]
  var numericCols = true
  for n in names:
    if not result.data[n].isNumeric: numericCols = false
  for n in names:
    for i in ix:
      let v = result.data[n, i]
      if v.isNumber:
        let x = v.toFloat
        if lo.isNaN or x < lo: lo = x
        if hi.isNaN or x > hi: hi = x
      elif not v.isNull and $v notin levels: levels.add $v
  if not domain[0].isNaN: lo = domain[0]
  if not domain[1].isNaN: hi = domain[1]
  for n in names:
    for i in ix:
      let v = result.data[n, i]
      let c =
        if v.isNull: naColor
        elif numericCols and v.isNumber:
          interpolate(pal, if hi > lo: (v.toFloat - lo) / (hi - lo) else: 0.5)
        else:
          let k = levels.find($v)
          if levels.len <= 1: pal[0]
          elif pal.len >= levels.len: pal[k]
          else: interpolate(pal, k / (levels.len - 1))
      var s = if apply == "text": style.text(color = c) else: style.fill(c)
      if autoColorText and apply != "text": s = s & style.text(color = idealTextColor(c))
      result.styles.add StyleRule(target: Target(kind: lkBody, cells: @[(i, n)]), style: s)

# ----------------------------------------------------------------------------------- options

macro tabOptions*(t: Tabella, args: varargs[untyped]): Tabella =
  ## Sets any of `TabOptions`' fields by name, checked when compiling:
  ## `t.tabOptions(rowStriping = true, headingAlign = "left")`.
  let res = genSym(nskVar, "res")
  result = newStmtList(newVarStmt(res, t))
  for a in args:
    if a.kind != nnkExprEqExpr:
      error("tabOptions takes named arguments, like rowStriping = true", a)
    result.add newAssignment(newDotExpr(newDotExpr(res, ident"options"), a[0]), a[1])
  result.add res
  result = newBlockStmt(result)

proc optRowStriping*(t: sink Tabella, on = true): Tabella =
  result = t
  result.options.rowStriping = on

proc optAlignTableHeader*(t: sink Tabella, align = "left"): Tabella =
  result = t
  result.options.headingAlign = align

proc optAllCaps*(t: sink Tabella, on = true): Tabella =
  ## Column labels, row group labels and the stubhead in small capitals.
  result = t
  if on:
    result.options.columnLabelsTextTransform = "uppercase"
    result.options.columnLabelsFontSize = "80%"
    result.options.columnLabelsFontWeight = "bolder"
  else:
    result.options.columnLabelsTextTransform = "inherit"
    result.options.columnLabelsFontSize = "100%"
    result.options.columnLabelsFontWeight = "normal"

proc optTableFont*(t: sink Tabella, font: string): Tabella =
  result = t
  result.options.tableFontNames = font

proc optStylize*(t: sink Tabella, style = 1, color = "blue"): Tabella =
  ## A ready-made look, after gt's `opt_stylize()`: `style` 1 to 3, in one of `color`
  ## "blue", "cyan", "pink", "green", "red", "gray".
  const tints = {"blue": ("#004D80", "#D5E8F7"), "cyan": ("#00666B", "#D0F0EE"),
                 "pink": ("#8C1D52", "#FADBEA"), "green": ("#1D5C2E", "#D9F0DE"),
                 "red": ("#8A1C1C", "#F9DADA"), "gray": ("#333333", "#E5E5E5")}.toTable
  let (dark, light) = tints.getOrDefault(color, tints["blue"])
  result = t
  result.options.tableBorderTopColor = dark
  result.options.tableBorderBottomColor = dark
  result.options.columnLabelsBorderBottomColor = dark
  case style
  of 1:
    result.options.rowStriping = true
    result.options.rowStripingBackgroundColor = light
  of 2:
    result.options.columnLabelsBackgroundColor = dark
    result.options.headingBackgroundColor = dark
    result.options.rowGroupBackgroundColor = light
    result.options.stubBackgroundColor = light
  else:
    result.options.columnLabelsBackgroundColor = light
    result.options.rowStriping = true
    result.options.rowStripingBackgroundColor = light
    result.options.tableBodyHlinesColor = "transparent"

proc optQuaderno*(t: sink Tabella, ink = "#1F4E99"): Tabella =
  ## The school-notebook look of tabelline's own pages: a graph-paper body, a blue-pen header and
  ## a red margin rule, as in an Italian *quaderno a quadretti*.
  result = t
  result.options.tableFontNames = "'Atkinson Hyperlegible', 'Comic Neue', 'Chalkboard SE', system-ui, sans-serif"
  result.options.tableFontColor = "#24324A"
  result.options.tableBackgroundColor = "#FFFFFF"
  result.options.tableBorderTopColor = ink
  result.options.tableBorderBottomColor = ink
  result.options.columnLabelsBorderBottomColor = ink
  result.options.columnLabelsFontWeight = "bold"
  result.options.headingBorderBottomColor = "#E53935"
  result.options.tableBodyHlinesColor = "#BFD7EF"
  result.options.rowGroupBackgroundColor = "#FFF3B0"
  result.options.extraCss = """
 .tb_table { background-image: linear-gradient(#DCEBFA 1px, transparent 1px),
    linear-gradient(90deg, #DCEBFA 1px, transparent 1px); background-size: 12px 12px; }
 .tb_title { color: """ & ink & """; font-family: 'Patrick Hand', 'Comic Neue', 'Chalkboard SE', 'Comic Sans MS', cursive; font-size: 150%; }
 .tb_col_heading, .tb_spanner { color: """ & ink & """; }
"""
