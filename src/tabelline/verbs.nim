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

proc tabSpannerDelim*(t: sink Tabella, delim = ".", columns: ColSel = everything(), split = "last",
                      limit = -1, reverse = false): Tabella =
  ## Spanners and labels from column names: `"size.mass"` gets the label "mass" under a spanner
  ## "size". Names with more parts get more levels; next to each other, the same parts make one
  ## spanner. `limit` caps the splits, counted from the `split` side ("last" or "first");
  ## `reverse` reads the parts the other way round.
  result = t
  let names = columns.resolve(result.data)
  var paths: seq[(string, seq[string])]    # column, spanner parts from the top level down
  for c in result.boxhead:
    if c.name notin names or delim notin c.name: continue
    var parts =
      if limit < 0: c.name.split(delim)
      elif split == "first": c.name.split(delim, limit)
      else: c.name.rsplit(delim, limit)
    if reverse: parts.reverse
    for b in result.boxhead.mitems:
      if b.name == c.name: b.label = toText(parts[^1])
    paths.add (c.name, parts[0 ..< ^1])
  # columns next to each other with the same top part share a depth: their top spanner sits
  # highest, and part i of a name is at level depth - i
  var depthOf = newSeq[int](paths.len)
  var k = 0
  while k < paths.len:
    var j = k
    var depth = 0
    while j < paths.len and paths[j][1][0] == paths[k][1][0]:
      depth = max(depth, paths[j][1].len)
      inc j
    for x in k ..< j: depthOf[x] = depth
    k = j
  var maxDepth = 0
  for d in depthOf: maxDepth = max(maxDepth, d)
  for level in 1 .. maxDepth:
    var k = 0
    while k < paths.len:
      let i = depthOf[k] - level           # the part at this level
      let p = paths[k][1]
      if i < 0 or i >= p.len: (inc k; continue)
      let key = p[0 .. i]
      var run = @[paths[k][0]]
      var j = k + 1
      while j < paths.len and depthOf[j] == depthOf[k] and paths[j][1].len > i and
            paths[j][1][0 .. i] == key:
        run.add paths[j][0]
        inc j
      result = result.tabSpanner(toText(key[^1]), run, level)
      k = j

proc tabCaption*(t: sink Tabella, caption: Text): Tabella =
  ## A caption for the table (an HTML `<caption>`), for screen readers and for figures.
  result = t
  result.caption = caption

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

proc rmHeader*(t: sink Tabella): Tabella =
  ## Removes the title and the subtitle.
  result = t
  result.title = toText("")
  result.subtitle = toText("")

proc rmStubhead*(t: sink Tabella): Tabella =
  result = t
  result.stubhead = toText("")

proc rmCaption*(t: sink Tabella): Tabella =
  result = t
  result.caption = toText("")

proc rmSpanners*(t: sink Tabella, spanners: openArray[string] = [], levels: openArray[int] = []): Tabella =
  ## Removes the spanners with these labels, or at these levels; with neither, every spanner.
  result = t
  let (labels, lvs) = (@spanners, @levels)
  result.spanners.keepItIf(not ((labels.len == 0 or it.label.s in labels) and (lvs.len == 0 or it.level in lvs)))

proc rmFootnotes*(t: sink Tabella, footnotes: openArray[int] = []): Tabella =
  ## Removes the footnotes at these indices (0-based, in the order they were added), or all.
  result = t
  if footnotes.len == 0: result.footnotes = @[]
  else:
    var kept: seq[Footnote]
    for k, f in result.footnotes:
      if k notin footnotes: kept.add f
    result.footnotes = kept

proc rmSourceNotes*(t: sink Tabella, sourceNotes: openArray[int] = []): Tabella =
  ## Removes the source notes at these indices (0-based), or all.
  result = t
  if sourceNotes.len == 0: result.sourceNotes = @[]
  else:
    var kept: seq[Text]
    for k, n in result.sourceNotes:
      if k notin sourceNotes: kept.add n
    result.sourceNotes = kept

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
func header*(_: LocNs): Loc = Loc(kind: lkHeader)
  ## The title and the subtitle together.
func columnHeader*(_: LocNs): Loc = Loc(kind: lkColumnHeader)
  ## The stub head, the spanners and the column labels together.
func footer*(_: LocNs): Loc = Loc(kind: lkFooter)
  ## The footnotes and the source notes together.
func spannerLabels*(_: LocNs, labels: varargs[string]): Loc = Loc(kind: lkSpanners, names: @labels)
  ## The same as `loc.spanners`, by Great Tables' name.
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
  of lkBody:   # the data cells: the stub column is loc.stub, as in gt
    let names = l.cols.resolve(t.data).filterIt(it != t.rownameCol)
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

# ------------------------------------------------------------------------------------- text

proc mapLabels(t: var Tabella, l: Loc, fn: proc (s: string): string) =
  ## Applies `fn` to the texts of a location that is not made of cells.
  template change(x: var Text) = x.s = fn(x.s)
  case l.kind
  of lkTitle: change t.title
  of lkSubtitle: change t.subtitle
  of lkHeader: (change t.title; change t.subtitle)
  of lkStubhead: change t.stubhead
  of lkColumnLabels, lkColumnHeader:
    let names = if l.kind == lkColumnLabels: l.cols.resolve(t.data) else: t.data.names
    for c in t.boxhead.mitems:
      if c.name in names: change c.label
    if l.kind == lkColumnHeader:
      change t.stubhead
      for s in t.spanners.mitems: change s.label
  of lkSpanners:
    for s in t.spanners.mitems:
      if l.names.len == 0 or s.label.s in l.names: change s.label
  of lkRowGroups:
    for k, v in t.groupLabels.mpairs:
      if l.names.len == 0 or k in l.names: change v
  of lkSourceNotes, lkFooter, lkFootnotes:
    if l.kind != lkFootnotes:
      for n in t.sourceNotes.mitems: change n
    if l.kind != lkSourceNotes:
      for f in t.footnotes.mitems: change f.note
  of lkBody, lkStub: discard

proc textTransform*(t: sink Tabella, fn: proc (s: string): string, locations: varargs[Loc]): Tabella =
  ## Changes the shown text at `locations` (by default the body) with a proc: for cells the proc
  ## gets the formatted text when the table is rendered (HTML in HTML), for labels and notes their
  ## text now. `textTransform(toUpperAscii, loc.stub())`.
  result = t
  let ls = if locations.len == 0: @[loc.body()] else: @locations
  for l in ls:
    if l.kind in {lkBody, lkStub}: result.transforms.add TransformRule(target: l.resolve(result), fn: fn)
    else: result.mapLabels(l, fn)

proc textReplace*(t: sink Tabella, pattern, replacement: string, locations: varargs[Loc]): Tabella =
  ## Replaces every `pattern` (plain text, not a regex) with `replacement`.
  let (p, r) = (pattern, replacement)
  textTransform(t, proc (s: string): string = s.replace(p, r), locations)

proc textCaseMatch*(t: sink Tabella, cases: openArray[(string, string)], default = "",
                    replace = "all", locations: varargs[Loc]): Tabella =
  ## Changes texts by cases, `{"old": "new"}`: with `replace = "all"` a text equal to a case
  ## becomes its new text (and any other `default`, when given); with `"partial"` each case is
  ## replaced inside the text.
  let cs = @cases
  let (d, partial) = (default, replace == "partial")
  textTransform(t, proc (s: string): string =
    if partial:
      result = s
      for (a, b) in cs: result = result.replace(a, b)
    else:
      for (a, b) in cs:
        if s == a: return b
      result = if d.len > 0: d else: s, locations)

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

proc colsLabelWith*(t: sink Tabella, columns: ColSel, fn: proc (s: string): string): Tabella =
  ## Relabels columns with a proc over their labels: `colsLabelWith(everything(), capitalizeAscii)`.
  result = t
  let names = columns.resolve(result.data)
  for c in result.boxhead.mitems:
    if c.name in names: c.label.s = fn(c.label.s)

proc colsLabelWith*(t: sink Tabella, fn: proc (s: string): string): Tabella =
  ## Every column relabelled with `fn`.
  colsLabelWith(t, everything(), fn)

proc colsMoveToEnd*(t: sink Tabella, columns: ColSel): Tabella =
  result = t
  let names = columns.resolve(result.data)
  let moving = names.mapIt(result.colInfo(it))
  result.boxhead.keepItIf(it.name notin names)
  result.boxhead.add moving

proc colsReorder*(t: sink Tabella, columns: ColSel): Tabella =
  ## Puts `columns` in the given order, in the places they hold: the other columns stay put.
  result = t
  let names = columns.resolve(result.data)
  var k = 0
  let infos = names.mapIt(result.colInfo(it))
  for c in result.boxhead.mitems:
    if c.name in names:
      c = infos[k]
      inc k

proc colsMoveToStart*(t: sink Tabella, columns: ColSel): Tabella =
  result = t
  let names = columns.resolve(result.data)
  let moving = names.mapIt(result.colInfo(it))
  result.boxhead.keepItIf(it.name notin names)
  result.boxhead.insert(moving, 0)

# -------------------------------------------------------------------------------------- rows

func cmpValues(a, b: Value): int =
  ## Missing values last; numbers before text.
  if a.isNull or b.isNull: return cmp(a.isNull, b.isNull)
  if a.isNumber and b.isNumber: return cmp(a.toFloat, b.toFloat)
  if a.isNumber != b.isNumber: return cmp(b.isNumber, a.isNumber)
  cmp($a, $b)

proc rowOrder*(t: sink Tabella, columns: ColSel, reverse = false): Tabella =
  ## Shows the rows sorted by `columns` (the first decides, the next break ties), within their
  ## groups; `reverse` sorts from high to low. Missing values go last.
  result = t
  let names = columns.resolve(result.data)
  let d = result.data
  var ix = toSeq(0 ..< d.nrows)
  ix.sort(proc (a, b: int): int =
    for n in names:
      let c = cmpValues(d[n, a], d[n, b])
      if c != 0:
        let missing = d[n, a].isNull or d[n, b].isNull
        return (if reverse and not missing: -c else: c)
    0)
  result.rowOrder = ix

proc rowGroupOrder*(t: sink Tabella, groups: openArray[string]): Tabella =
  ## Shows the row groups in this order; groups not listed follow, as they were.
  result = t
  var labels: OrderedTable[string, Text]
  for g in groups:
    if g notin result.groupLabels: raise newException(KeyError, "no row group " & g.escape)
    labels[g] = result.groupLabels[g]
  for k, v in result.groupLabels:
    if k notin labels: labels[k] = v
  result.groupLabels = labels

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

func px(x: float): string =
  var s = formatFloat(x, ffDecimal, 1)
  if s.endsWith(".0"): s.setLen(s.len - 2)
  s & "px"

proc optVerticalPadding*(t: sink Tabella, scale = 1.0): Tabella =
  ## Scales the vertical padding of the heading, the column labels and the rows (gt: 0 to 3).
  result = t
  result.options.headingPadding = px(4 * scale)
  result.options.columnLabelsPadding = px(5 * scale)
  result.options.dataRowPadding = px(8 * scale)

proc optHorizontalPadding*(t: sink Tabella, scale = 1.0): Tabella =
  ## Scales the horizontal padding of the heading, the column labels and the rows (gt: 0 to 3).
  result = t
  result.options.headingPaddingHorizontal = px(5 * scale)
  result.options.columnLabelsPaddingHorizontal = px(5 * scale)
  result.options.dataRowPaddingHorizontal = px(5 * scale)

proc optTableOutline*(t: sink Tabella, style = "solid", width = "3px", color = "#D3D3D3"): Tabella =
  ## A line all around the table.
  result = t
  result.options.tableBorderTopStyle = style
  result.options.tableBorderTopWidth = width
  result.options.tableBorderTopColor = color
  result.options.tableBorderBottomStyle = style
  result.options.tableBorderBottomWidth = width
  result.options.tableBorderBottomColor = color
  result.options.tableBorderLeftStyle = style
  result.options.tableBorderLeftWidth = width
  result.options.tableBorderLeftColor = color
  result.options.tableBorderRightStyle = style
  result.options.tableBorderRightWidth = width
  result.options.tableBorderRightColor = color

proc optTableLines*(t: sink Tabella, extent = "default"): Tabella =
  ## The table's lines: `"all"` adds vertical lines between cells, `"none"` takes every line away,
  ## `"default"` brings back the defaults.
  result = t
  let d = TabOptions()
  template set(field, value: untyped) = result.options.field = value
  case extent
  of "none":
    for side in ["top", "bottom"]: discard side
    set(tableBorderTopStyle, "none"); set(tableBorderBottomStyle, "none")
    set(tableBorderLeftStyle, "none"); set(tableBorderRightStyle, "none")
    set(headingBorderBottomColor, "transparent"); set(columnLabelsBorderBottomColor, "transparent")
    set(rowGroupBorderColor, "transparent"); set(tableBodyHlinesColor, "transparent")
    set(tableBodyVlinesColor, "")
  of "all":
    set(tableBorderTopStyle, "solid"); set(tableBorderBottomStyle, "solid")
    set(tableBorderLeftStyle, "solid"); set(tableBorderRightStyle, "solid")
    set(headingBorderBottomColor, d.headingBorderBottomColor)
    set(columnLabelsBorderBottomColor, d.columnLabelsBorderBottomColor)
    set(rowGroupBorderColor, d.rowGroupBorderColor); set(tableBodyHlinesColor, d.tableBodyHlinesColor)
    set(tableBodyVlinesColor, "#D3D3D3")
  else:
    set(tableBorderTopStyle, d.tableBorderTopStyle); set(tableBorderBottomStyle, d.tableBorderBottomStyle)
    set(tableBorderLeftStyle, d.tableBorderLeftStyle); set(tableBorderRightStyle, d.tableBorderRightStyle)
    set(headingBorderBottomColor, d.headingBorderBottomColor)
    set(columnLabelsBorderBottomColor, d.columnLabelsBorderBottomColor)
    set(rowGroupBorderColor, d.rowGroupBorderColor); set(tableBodyHlinesColor, d.tableBodyHlinesColor)
    set(tableBodyVlinesColor, d.tableBodyVlinesColor)

proc optFootnoteMarks*(t: sink Tabella, marks: FootnoteMarks): Tabella =
  result = t
  result.options.footnotesMarks = marks
  result.options.footnotesMarksCustom = @[]

proc optFootnoteMarks*(t: sink Tabella, marks: string): Tabella =
  ## By gt's names: "numbers", "letters", "LETTERS", "standard" (*, †, ‡, §) or "extended"
  ## (with ‖, ¶).
  let m = case marks
          of "numbers": fmNumbers
          of "letters": fmLetters
          of "LETTERS": fmCapitals
          of "standard": fmStandard
          of "extended": fmExtended
          else: raise newException(ValueError, "unknown footnote marks " & marks.escape)
  optFootnoteMarks(t, m)

proc optFootnoteMarks*(t: sink Tabella, marks: openArray[string]): Tabella =
  ## Marks of your own, used in turn: `optFootnoteMarks(["🌑", "🌓", "🌕"])`.
  result = t
  result.options.footnotesMarksCustom = @marks

proc optFootnoteSpec*(t: sink Tabella, specRef = "^", specFtr = "^"): Tabella =
  ## How marks look, in the table (`specRef`) and in the footer (`specFtr`): "^" raised, "i"
  ## italic, "b" bold, "(" or "[" around the mark: `optFootnoteSpec("^i", "(")`.
  result = t
  result.options.footnotesSpecRef = specRef
  result.options.footnotesSpecFtr = specFtr

proc optFootnoteOrder*(t: sink Tabella, order = "marks_first"): Tabella =
  ## The order of the footnotes: marked ones first (the default), last ("marks_last"), or as
  ## they were added ("preserve_order", which also numbers the marks in that order).
  if order notin ["marks_first", "marks_last", "preserve_order"]:
    raise newException(ValueError, "unknown footnote order " & order.escape)
  result = t
  result.options.footnotesOrder = order

proc optCss*(t: sink Tabella, css: string, add = true): Tabella =
  ## CSS for the table, scoped to it (rules that start with `#` are left as they are); `add = false`
  ## replaces what was given before.
  result = t
  result.options.extraCss = (if add and result.options.extraCss.len > 0: result.options.extraCss & "\n" else: "") & css
