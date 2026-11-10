## The verbs that build a table spec, named after gt and Great Tables in camelCase:
## `tab*` add parts (header, spanners, notes, styles, options), `cols*` change columns,
## `dataColor` and `opt*` change the looks. Each takes a `Tabella` and returns the new one
## (`sink`, so a chain moves the spec along instead of copying it).

import std/[macros, strutils, sequtils, tables, math, algorithm]
import core, colors, formats

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
      # a missing (or empty) group value leaves the row out of every group
      if g.len > 0 and g notin result.groupLabels: result.groupLabels[g] = toText(g)

proc initTabella*[T: object | tuple](rows: openArray[T], rownameCol = "", groupnameCol = "", id = "",
                                 locale = ""): Tabella =
  ## A display table straight from Nim objects or named tuples, one field per column.
  initTabella(toTableData(rows), rownameCol, groupnameCol, id, locale)

proc initTabella*(t: sink Tabella): Tabella =
  ## A table already made, so that `tabella(t): body` adds verbs to it:
  ## `tabella(tabellaPreview(data)): colsHide "notes"`.
  t

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
func summary*(_: LocNs, groups: openArray[string] = [], columns: ColSel = everything(),
              rows: openArray[string] = []): Loc =
  ## The cells of the summary rows of `groups` (all, by default), in `columns`, for the rows
  ## labelled `rows` (all, by default).
  Loc(kind: lkSummary, names: @groups, cols: columns, labels: @rows)
func summaryStub*(_: LocNs, groups: openArray[string] = [], rows: openArray[string] = []): Loc =
  ## The labels of the summary rows, in the stub.
  Loc(kind: lkSummaryStub, names: @groups, labels: @rows)
func grandSummary*(_: LocNs, columns: ColSel = everything(), rows: openArray[string] = []): Loc =
  ## The cells of the grand summary rows.
  Loc(kind: lkGrandSummary, cols: columns, labels: @rows)
func grandSummaryStub*(_: LocNs, rows: openArray[string] = []): Loc =
  ## The labels of the grand summary rows, in the stub.
  Loc(kind: lkGrandSummaryStub, labels: @rows)

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
  of lkSummary, lkSummaryStub, lkGrandSummary, lkGrandSummaryStub:
    # the rows are found when the table is built, so the summary rows may come later
    result.names = l.names
    result.labels = l.labels
    if l.kind in {lkSummary, lkGrandSummary}:
      result.columns = l.cols.resolve(t.data).filterIt(it != t.rownameCol)
  of lkBody:   # the data cells: the stub column is loc.stub, as in gt
    let names = l.cols.resolve(t.data).filterIt(it != t.rownameCol)
    for i in l.rows.resolve(t.data):
      for n in names: result.cells.add (i, n)
  else: discard

proc tabStyleCells(t: var Tabella, st: CellStyle, target: Target)

proc tabStyle*(t: sink Tabella, style: CellStyle, locations: varargs[Loc]): Tabella =
  ## Styles the cells at `locations`: `tabStyle(style.fill("#FFF3B0"), loc.body(rows = [2]))`. A
  ## value may come from another column of each row: `style.fill(fromColumn("colour"))`.
  result = t
  for l in locations:
    result.tabStyleCells(style, l.resolve(result))

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
  of lkBody, lkStub, lkSummary, lkSummaryStub, lkGrandSummary, lkGrandSummaryStub: discard

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

# ------------------------------------------------------------------------------ summary rows

const agg* = AggNs()

func numbers(values: seq[Value]): seq[float] =
  for v in values:
    if v.isNumber: result.add v.toFloat

func sum*(_: AggNs): Aggregate =
  ## The sum of the numbers (an int when they are all ints).
  Aggregate(name: "sum", fn: proc (values: seq[Value]): Value =
    var ints = true
    var any = false
    var i = 0
    var f = 0.0
    for v in values:
      if not v.isNumber: continue
      any = true
      if v.kind == vkInt: i += v.i else: ints = false
      f += v.toFloat
    if not any: null() elif ints: toValue(i) else: toValue(f))

func mean*(_: AggNs): Aggregate =
  ## The mean of the numbers.
  Aggregate(name: "mean", fn: proc (values: seq[Value]): Value =
    let xs = numbers(values)
    if xs.len == 0: null() else: toValue(xs.sum / float(xs.len)))

func median*(_: AggNs): Aggregate =
  ## The median of the numbers (the mean of the two middle ones when they are even).
  Aggregate(name: "median", fn: proc (values: seq[Value]): Value =
    var xs = numbers(values)
    if xs.len == 0: return null()
    xs.sort
    let m = xs.len div 2
    toValue(if xs.len mod 2 == 1: xs[m] else: (xs[m - 1] + xs[m]) / 2))

func std*(_: AggNs): Aggregate =
  ## The standard deviation of the numbers, of a sample (divided by n - 1, as R's `sd` and
  ## Polars' `std`).
  Aggregate(name: "std", fn: proc (values: seq[Value]): Value =
    let xs = numbers(values)
    if xs.len < 2: return null()
    let m = xs.sum / float(xs.len)
    var s = 0.0
    for x in xs: s += (x - m) * (x - m)
    toValue(sqrt(s / float(xs.len - 1))))

func extreme(values: seq[Value], largest: bool): Value =
  result = null()
  for v in values:
    if v.isNull: continue
    if result.isNull or (if largest: result < v else: v < result): result = v

func min*(_: AggNs): Aggregate =
  ## The smallest value (of numbers, or of texts).
  Aggregate(name: "min", fn: proc (values: seq[Value]): Value = extreme(values, false))

func max*(_: AggNs): Aggregate =
  ## The largest value (of numbers, or of texts).
  Aggregate(name: "max", fn: proc (values: seq[Value]): Value = extreme(values, true))

func count*(_: AggNs): Aggregate =
  ## How many values are not missing. Shown as an integer, whatever the column's format.
  Aggregate(name: "count", fn: proc (values: seq[Value]): Value = toValue(values.len))

proc aggregate*[P: proc](fn: P, name = ""): Aggregate =
  ## An aggregate of your own, from a proc of the non-missing values to one value:
  ## `aggregate(proc (vs: seq[Value]): Value = toValue(vs.len * 2))`, or a value that converts to
  ## one (`proc (vs: seq[Value]): float`).
  let f = fn
  Aggregate(name: name, fn: proc (values: seq[Value]): Value = toValue(f(values)))

proc toFormatFn*[P: proc](fn: P): FormatFn =
  ## A format from a proc of a float (`(x: float) => formatNumber(x, 1)`), of a value
  ## (`(v: Value) => $v`), both giving plain text, or a `FormatFn` as it is.
  when P is FormatFn: fn
  else:
    let f = fn
    proc (v: Value, ctx: RenderContext): string =
      let s = when compiles(f(1.0)): (if v.isNumber: f(v.toFloat) else: $v)
              else: f(v)
      if ctx == rcHtml: escapeHtml(s) else: s

proc addSummary(t: var Tabella, grand: bool, groups: openArray[string], columns: ColSel,
                fns: openArray[(string, Aggregate)], fmt: FormatFn, side: Side, missingText: string) =
  if fns.len == 0: raise newException(ValueError, "no aggregates in fns")
  if side notin {sTop, sBottom}: raise newException(ValueError, "summary rows go at the top or the bottom")
  if not grand:
    if not t.hasGroups:
      raise newException(ValueError, "summaryRows needs row groups (groupnameCol, tabRowGroup); " &
        "for the whole table use grandSummaryRows")
    for g in groups:
      if g notin t.groupLabels: raise newException(KeyError, "no row group " & g.escape)
  t.summaries.add SummaryRule(grand: grand, groups: @groups, columns: columns.resolve(t.data),
    fns: @fns, top: side == sTop, fmt: fmt, missingText: missingText)

proc summaryRows*(t: sink Tabella, fns: openArray[(string, Aggregate)], groups: openArray[string] = [],
                  columns: ColSel = numeric(), side = sBottom, missingText = "—"): Tabella =
  ## Adds rows that sum up each row group (or the `groups` listed), one for each aggregate in
  ## `fns`, labelled in the stub: `summaryRows(fns = {"total": agg.sum}, columns = "moons")`.
  ## The summary rows go under the group, or above it with `side = sTop`. Each cell is
  ## formatted like its column (its last format), `agg.count` as an integer; a cell with
  ## nothing to sum up, and the columns not in `columns`, show `missingText`.
  result = t
  result.addSummary(false, groups, columns, fns, nil, side, missingText)

proc summaryRows*[P: proc](t: sink Tabella, fns: openArray[(string, Aggregate)], fmt: P,
                           groups: openArray[string] = [], columns: ColSel = numeric(),
                           side = sBottom, missingText = "—"): Tabella =
  ## Summary rows formatted by `fmt`, a proc of a float (`fmt = (x: float) => formatNumber(x, 1)`),
  ## of a value, or a `FormatFn` (see `toFormatFn`).
  result = t
  result.addSummary(false, groups, columns, fns, toFormatFn(fmt), side, missingText)

proc grandSummaryRows*(t: sink Tabella, fns: openArray[(string, Aggregate)], columns: ColSel = numeric(),
                       side = sBottom, missingText = "—"): Tabella =
  ## Adds rows that sum up the whole table, every row of every group, one for each aggregate in
  ## `fns`: at the bottom of the table, or at the top with `side = sTop`. Formatted as
  ## `summaryRows`.
  result = t
  result.addSummary(true, [], columns, fns, nil, side, missingText)

proc grandSummaryRows*[P: proc](t: sink Tabella, fns: openArray[(string, Aggregate)], fmt: P,
                                columns: ColSel = numeric(), side = sBottom, missingText = "—"): Tabella =
  ## Grand summary rows formatted by `fmt` (see `summaryRows`).
  result = t
  result.addSummary(true, [], columns, fns, toFormatFn(fmt), side, missingText)

# ---------------------------------------------------------------------------------- dataColor

proc dataColor*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(),
                palette: seq[string] = palette("blues"), domain = (NaN, NaN), reverse = false,
                naColor = "#F0F0F0", autoColorText = true, apply = "fill"): Tabella =
  ## Colours cells by value, each column on its own: a number column along `palette` from the low
  ## to the high end of `domain` (by default the range of its selected cells), any other column by
  ## category. A `domain` from high to low runs the palette the other way. `apply = "text"`
  ## colours the text instead of the fill.
  result = t
  let names = columns.resolve(result.data)
  let ix = rows.resolve(result.data)
  let pal = if reverse: palette.reversed else: palette
  for n in names:
    let numericCol = result.data[n].isNumeric
    var lo, hi = NaN
    var levels: seq[string]
    for i in ix:
      let v = result.data[n, i]
      if numericCol and v.isNumber:
        let x = v.toFloat
        if lo.isNaN or x < lo: lo = x
        if hi.isNaN or x > hi: hi = x
      elif not v.isNull and $v notin levels: levels.add $v
    if not domain[0].isNaN: lo = domain[0]
    if not domain[1].isNaN: hi = domain[1]
    for i in ix:
      let v = result.data[n, i]
      let c =
        if v.isNull: naColor
        elif numericCol and v.isNumber:
          interpolate(pal, if hi != lo: clamp((v.toFloat - lo) / (hi - lo), 0.0, 1.0) else: 0.5)
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

type CssTheme* = object
  ## Where a table takes its colours and font from (`optCssTheme`): for each, the name of a CSS
  ## variable of the page (`"--ink"`) or a CSS value (`"#1C1C1C"`).
  ink*, paper*, line*, shade*, primary*, font*: string

func cssTheme*(ink = "--ink", paper = "--paper", line = "--line", shade = "--shade",
               primary = "--primary", font = "--font"): CssTheme =
  ## A theme to keep and reuse with `optCssTheme(theme)`. Each argument starting with `--` names
  ## the variable to read; anything else is the CSS value itself.
  CssTheme(ink: ink, paper: paper, line: line, shade: shade, primary: primary, font: font)

func cssRef(x, fallback: string): string =
  ## A variable with its fallback, or the value as it is.
  if x.startsWith("--"): "var(" & x & ", " & fallback & ")" else: x

proc optCssTheme*(t: sink Tabella, theme: CssTheme): Tabella =
  ## Every colour of the table, and its font, from `theme`: see `optCssTheme()`.
  let
    ink = cssRef(theme.ink, "#1C1C1C")
    paper = cssRef(theme.paper, "#FFFFFF")
    line = cssRef(theme.line, "color-mix(in oklab, " & ink & " 14%, " & paper & ")")
    shade = cssRef(theme.shade, "color-mix(in oklab, " & ink & " 4%, " & paper & ")")
  result = t
  result.options.tableFontNames = cssRef(theme.font, "system-ui, sans-serif")
  result.options.tableFontColor = ink
  result.options.tableBackgroundColor = paper
  result.options.tableBorderTopColor = ink
  result.options.tableBorderTopWidth = "3px"
  result.options.tableBorderBottomColor = ink
  result.options.tableBorderBottomWidth = "3px"
  result.options.headingBorderBottomColor = cssRef(theme.primary, ink)
  result.options.columnLabelsBorderBottomColor = ink
  result.options.columnLabelsFontWeight = "bold"
  result.options.tableBodyHlinesColor = line
  result.options.rowGroupBackgroundColor = shade
  result.options.rowGroupBorderColor = ink
  result.options.rowStripingBackgroundColor = shade
  result.options.summaryRowBorderColor = ink
  result.options.summaryRowBorderWidth = "1px"
  result.options.grandSummaryRowBorderColor = ink
  result.options.grandSummaryRowBorderWidth = "4px"

proc optCssTheme*(t: sink Tabella, ink = "--ink", paper = "--paper", line = "--line",
                  shade = "--shade", primary = "--primary", font = "--font"): Tabella =
  ## The page's theme: every colour of the table, and its font, is a CSS variable of the page it
  ## is on, so the table follows the page's palette and changes with it. It reads `--ink` (text
  ## and the heavy rules), `--paper` (behind the table), `--line` (the rules between rows),
  ## `--shade` (row groups and stripes), `--primary` (the rule under the heading) and `--font`.
  ## Two are enough: without the others, line and shade are mixed from ink and paper, primary is
  ## the ink; without any, the table
  ## is black on white. An argument names another variable (`ink = "--foreground"`), or, when it
  ## does not start with `--`, is a value (`primary = "#D64545"`). gt and Great Tables have no
  ## such preset.
  optCssTheme(t, cssTheme(ink, paper, line, shade, primary, font))

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

# ------------------------------------------------------------------------------------ merges

proc addMerge(t: var Tabella, kind: MergeKind, columns: seq[string], rows: RowSel, pattern: string,
              autohide: bool) =
  for c in columns: discard t.data[c]       # raises on a column that does not exist
  let ix = if rows.kind == rsAll: @[] else: rows.resolve(t.data)
  t.merges.add MergeRule(kind: kind, columns: columns, rows: ix, pattern: pattern)
  if autohide:
    for c in t.boxhead.mitems:
      if c.name in columns[1 .. ^1]: c.hidden = true

proc colsMerge*(t: sink Tabella, columns: openArray[string], rows = allRows(), pattern = "",
                autohide = true): Tabella =
  ## Shows the formatted values of `columns` together, in the first one, with `pattern`:
  ## `{1}`, `{2}`, ... are the columns, and a part between `<<` and `>>` is left out when a value
  ## it names is missing: `colsMerge(["city", "country"], pattern = "{1}<< ({2})>>")`. Without a
  ## pattern the values are joined by spaces. The other columns are hidden (unless `autohide =
  ## false`).
  result = t
  var p = pattern
  if p.len == 0:
    for k in 1 .. columns.len: p.add (if k > 1: " " else: "") & "{" & $k & "}"
  result.addMerge(mkPattern, @columns, rows, p, autohide)

proc colsMergeUncert*(t: sink Tabella, colVal, colUncert: string, rows = allRows(), sep = " ± ",
                      autohide = true): Tabella =
  ## A value and its uncertainty in one cell: `12.3 ± 0.4` (just the value when the uncertainty
  ## is missing).
  result = t
  result.addMerge(mkUncert, @[colVal, colUncert], rows, "{1}<<" & sep & "{2}>>", autohide)

proc colsMergeRange*(t: sink Tabella, colBegin, colEnd: string, rows = allRows(), sep = "–",
                     autohide = true): Tabella =
  ## A range in one cell, with an en dash: `1990–2000` (just the start when the end is missing).
  result = t
  result.addMerge(mkRange, @[colBegin, colEnd], rows, "{1}<<" & sep & "{2}>>", autohide)

proc colsMergeNPct*(t: sink Tabella, colN, colPct: string, rows = allRows(), autohide = true): Tabella =
  ## A count and its percentage in one cell: `12 (4.5%)`; a zero count shows no percentage.
  ## Format the percentage column first (`fmtPercent`).
  result = t
  result.addMerge(mkNPct, @[colN, colPct], rows, "{1}<< ({2})>>", autohide)

# ------------------------------------------------------------------------------ adding columns

proc withData(t: var Tabella, d: TableData) =
  ## Replaces the data with a new one that has the same rows and more columns or more rows. The
  ## old data is never changed, so other tables made from it stay as they were.
  t.data = d

proc copyData(d: TableData): TableData = TableData(columns: d.columns)

proc colsAdd*(t: sink Tabella, name: string, values: seq[Value], before = "", after = ""): Tabella =
  ## Adds a column: at the end, or `before` or `after` another one. `colsAdd("ratio", ratios)`.
  result = t
  let names = result.boxhead.mapIt(it.name)
  var at = names.len
  if before.len > 0: at = names.find(before)
  elif after.len > 0: at = names.find(after) + (if names.find(after) >= 0: 1 else: -names.len - 1)
  if at < 0: raise newException(KeyError, "no column named " & (before & after).escape)
  let d = copyData(result.data)
  d.addColumn(name, values)
  result.withData d
  let info = ColInfo(name: name, label: toText(name),
                     align: if d[name].isNumeric: alRight else: alLeft)
  result.boxhead.insert(info, at)

proc colsAdd*[T](t: sink Tabella, name: string, values: openArray[T], before = "", after = ""): Tabella =
  ## A column from Nim values: `colsAdd("visited", [true, false, ...])`.
  colsAdd(t, name, toValues(values), before, after)

proc colsAdd*(t: sink Tabella, name: string, fn: proc (r: Row): Value, before = "", after = ""): Tabella =
  ## A column computed from each row: `colsAdd("density", proc (r: Row): Value =
  ## toValue(r["mass"].toFloat / r["volume"].toFloat))`.
  var vs: seq[Value]
  for i in 0 ..< t.data.nrows: vs.add fn(Row(data: t.data, index: i))
  colsAdd(t, name, vs, before, after)

proc addSummaryColumns(t: var Tabella, columns: ColSel, fns: openArray[(string, Aggregate)],
                       fmt: FormatFn, side: Side, missingText: string) =
  if fns.len == 0: raise newException(ValueError, "no aggregates in fns")
  if side notin {sLeft, sRight}: raise newException(ValueError, "summary columns go at the left or the right")
  let names = columns.resolve(t.data).filterIt(it != t.rownameCol and it != t.groupnameCol)
  # the format of the new columns: the call's, or the last one of the first summed-up column
  var f = fmt
  if f == nil and names.len > 0:
    for k in countdown(t.formats.high, 0):
      if names[0] in t.formats[k].columns and t.formats[k].rows.len == 0:
        f = t.formats[k].fn
        break
  let firstData = block:
    var k = 0
    while k < t.boxhead.len and t.boxhead[k].role != crData: inc k
    k
  for k, (label, agg) in fns:
    var vs: seq[Value]
    for i in 0 ..< t.data.nrows:
      var row: seq[Value]
      for n in names:
        let v = t.data[n, i]
        if not v.isNull: row.add v
      vs.add agg.fn(row)
    let d = copyData(t.data)
    d.addColumn(label, vs)
    t.withData d
    let info = ColInfo(name: label, label: toText(label), align: alRight)
    if side == sRight: t.boxhead.add info
    else: t.boxhead.insert(info, firstData + k)
    if f != nil and agg.name != "count":
      t.formats.add FormatRule(columns: @[label], fn: f)
    let mt = missingText
    t.substitutions.add FormatRule(columns: @[label], nullsToo: true,
      fn: proc (v: Value, ctx: RenderContext): string = mt)

proc summaryColumns*(t: sink Tabella, fns: openArray[(string, Aggregate)], columns: ColSel = numeric(),
                     side = sRight, missingText = "—"): Tabella =
  ## Adds a column for each aggregate in `fns`, summing up `columns` across each row:
  ## `summaryColumns(fns = {"total": agg.sum}, columns = ["gold", "silver", "bronze"])`, at the
  ## right of the table (or at the left of the data with `side = sLeft`). The new column is
  ## formatted like the first column it sums up, or by `fmt`; summary rows sum it up like any
  ## other column, so a table of totals gets its grand total.
  result = t
  result.addSummaryColumns(columns, fns, nil, side, missingText)

proc summaryColumns*[P: proc](t: sink Tabella, fns: openArray[(string, Aggregate)], fmt: P,
                              columns: ColSel = numeric(), side = sRight, missingText = "—"): Tabella =
  ## Summary columns formatted by `fmt` (see `summaryRows`).
  result = t
  result.addSummaryColumns(columns, fns, toFormatFn(fmt), side, missingText)

# --------------------------------------------------------------------------------- adding rows

proc rowsAdd*(t: sink Tabella, rows: TableData, before = -1, after = -1): Tabella =
  ## Adds rows, given as a table of some of the columns (the others are missing): at the end, or
  ## `before` or `after` a row (by its index in the data). A value of `groupnameCol` puts the row
  ## in that group (made when new). `rowsAdd(tableData(planet = ["Pluto"], moons = [5]))`.
  result = t
  let old = result.data
  for c in rows.columns:
    if not old.hasColumn(c.name):
      raise newException(KeyError, "no column named " & c.name.escape & " (columns: " & old.names.join(", ") & ")")
  let n0 = old.nrows
  let n = rows.nrows
  let d = copyData(old)
  for col in d.columns.mitems:
    let k = rows.colIndex(col.name)
    for i in 0 ..< n: col.values.add(if k >= 0: rows.columns[k].values[i] else: null())
  result.withData d
  var order = if result.rowOrder.len > 0: result.rowOrder else: toSeq(0 ..< n0)
  let newRows = toSeq(n0 ..< n0 + n)
  let at = if before >= 0: order.find(before)
           elif after >= 0: order.find(after) + 1
           else: order.len
  if (before >= 0 and at < 0) or (after >= 0 and at < 1):
    raise newException(IndexDefect, "row " & $(max(before, after)) & " out of 0..<" & $n0)
  order.insert(newRows, at)
  result.rowOrder = order
  for i in newRows:
    var g = ""
    if result.groupnameCol.len > 0: g = $d[result.groupnameCol, i]
    result.rowGroups.add g
    if g.len > 0 and g notin result.groupLabels: result.groupLabels[g] = toText(g)

proc rowsAdd*[T: object | tuple](t: sink Tabella, rows: openArray[T], before = -1, after = -1): Tabella =
  ## Rows as Nim objects or named tuples: `rowsAdd([(planet: "Pluto", moons: 5)])`.
  rowsAdd(t, toTableData(rows), before, after)

proc rowsHide*(t: sink Tabella, rows: RowSel): Tabella =
  ## Hides rows: they are not shown, nor summed up by summary rows, but stay in the data.
  result = t
  for i in rows.resolve(result.data):
    if i notin result.hiddenRows: result.hiddenRows.add i

proc rowsUnhide*(t: sink Tabella, rows = allRows()): Tabella =
  ## Shows hidden rows again (all of them, by default).
  result = t
  let ix = rows.resolve(result.data)
  result.hiddenRows.keepItIf(it notin ix)

# ------------------------------------------------------------------------- stub and alignment

proc tabStubIndent*(t: sink Tabella, rows: RowSel, indent: int): Tabella =
  ## Indents the stub cells of `rows` at a level from 0 (none) to 5.
  result = t
  for i in rows.resolve(result.data): result.indents[i] = clamp(indent, 0, 5)

proc tabStubIndent*(t: sink Tabella, rows: RowSel, indent = "increase"): Tabella =
  ## Indents the stub cells of `rows` one level more (`"increase"`) or less (`"decrease"`).
  if indent notin ["increase", "decrease"]:
    raise newException(ValueError, "indent is \"increase\", \"decrease\" or a level from 0 to 5")
  result = t
  for i in rows.resolve(result.data):
    let now = result.indents.getOrDefault(i, 0)
    result.indents[i] = clamp(now + (if indent == "increase": 1 else: -1), 0, 5)

proc colsAlignDecimal*(t: sink Tabella, columns: ColSel = numeric(), decMark = "", locale = ""): Tabella =
  ## Aligns the numbers of `columns` on their decimal mark, by padding each formatted cell on the
  ## right with figure spaces (a number without decimals gets a space for the mark, too). The
  ## columns are aligned right. The mark is `decMark`, or the locale's (`"."` by default).
  result = t
  let mark = if decMark.len > 0: decMark
             else: localeMarks(if locale.len > 0: locale else: result.locale).dec
  for n in columns.resolve(result.data):
    let k = result.decimalAligned.find(n)
    if k >= 0: result.decimalMarks[k] = mark
    else:
      result.decimalAligned.add n
      result.decimalMarks.add mark
    for c in result.boxhead.mitems:
      if c.name == n: c.align = alRight

# ------------------------------------------------------------------------- rotated labels

proc colsLabelRotate*(t: sink Tabella, columns: ColSel = everything(), dir = "sideways-lr"): Tabella =
  ## Turns the labels of `columns` on their side, for narrow columns: read from the bottom up
  ## (`"sideways-lr"`) or from the top down (`"sideways-rl"`). HTML only: text and Markdown keep
  ## the labels as they are.
  let css = case dir
            of "sideways-lr": "writing-mode: vertical-rl; transform: rotate(180deg); text-align: left; vertical-align: middle"
            of "sideways-rl": "writing-mode: vertical-rl; text-align: left; vertical-align: middle"
            else: raise newException(ValueError, "dir is \"sideways-lr\" or \"sideways-rl\", not " & dir.escape)
  result = t
  let names = columns.resolve(result.data).filterIt(it != result.rownameCol and it != result.groupnameCol)
  result.styles.add StyleRule(target: Target(kind: lkColumnLabels, names: names), style: style.css(css))

# ---------------------------------------------------------------- styles from the data

const fromColumnMark = "\x1Bfrom-column:"

func fromColumn*(column: string, naValue = ""): string =
  ## A style value taken, for each cell, from `column` of the same row:
  ## `tabStyle(style.fill(fromColumn("colour")), loc.body("name"))`. A missing value is
  ## `naValue` ("" leaves that property out). Works in any style for body and stub cells.
  fromColumnMark & column & "\x1F" & naValue

proc perCell(t: Tabella, st: CellStyle, row: int): CellStyle =
  ## `st` with every `fromColumn` value read from `row`.
  for (k, v) in st.css:
    if v.startsWith(fromColumnMark):
      let parts = v[fromColumnMark.len .. ^1].split('\x1F', 1)
      if not t.data.hasColumn(parts[0]):
        raise newException(KeyError, "fromColumn: no column " & parts[0].escape)
      let x = t.data[parts[0], row]
      let s = if x.isNull: parts[1] else: $x
      if s.len > 0: result.css.add (k, s)
    else: result.css.add (k, v)

func hasFromColumn(st: CellStyle): bool = st.css.anyIt(it[1].startsWith(fromColumnMark))

proc tabStyleCells(t: var Tabella, st: CellStyle, target: Target) =
  if st.hasFromColumn and target.kind in {lkBody, lkStub}:
    for (i, n) in target.cells:
      t.styles.add StyleRule(target: Target(kind: target.kind, cells: @[(i, n)]), style: t.perCell(st, i))
  elif st.hasFromColumn:
    raise newException(ValueError, "fromColumn works in loc.body and loc.stub only")
  else:
    t.styles.add StyleRule(target: target, style: st)

proc tabStyle*(t: sink Tabella, fn: proc (r: Row): CellStyle, locations: varargs[Loc]): Tabella =
  ## Styles each body or stub cell at `locations` with a style computed from its row:
  ## `tabStyle((r: Row) => (if r["moons"] > 10: style.fill("var(--x-soft)") else: CellStyle()), loc.body())`.
  result = t
  for l in locations:
    let target = l.resolve(result)
    if target.kind notin {lkBody, lkStub}:
      raise newException(ValueError, "a style from a proc of the row works in loc.body and loc.stub only")
    for (i, n) in target.cells:
      let st = fn(Row(data: result.data, index: i))
      if st.css.len > 0:
        result.styles.add StyleRule(target: Target(kind: target.kind, cells: @[(i, n)]), style: st)

proc tabStyleBody*(t: sink Tabella, style: CellStyle, columns: ColSel = everything(), rows = allRows(),
                   values: openArray[string] = [], pattern = "", fn: proc (v: Value): bool = nil,
                   targets = "cell"): Tabella =
  ## Styles the body cells whose value is one of `values` (compared as text, or as numbers),
  ## contains `pattern`, or makes `fn` true; `targets = "row"` styles their whole row, `"column"`
  ## their whole column: `tabStyleBody(style.fill("var(--x-soft)"), values = ["Earth"])`.
  if targets notin ["cell", "row", "column"]:
    raise newException(ValueError, "targets is \"cell\", \"row\" or \"column\", not " & targets.escape)
  if values.len == 0 and pattern.len == 0 and fn.isNil:
    raise newException(ValueError, "tabStyleBody needs values, a pattern or fn")
  result = t
  let vals = @values
  proc matches(v: Value): bool =
    if v.isNull: return false
    for s in vals:
      if $v == s: return true
      if v.isNumber:
        try:
          if v.toFloat == parseFloat(s): return true
        except ValueError: discard
    if pattern.len > 0 and pattern in $v: return true
    if not fn.isNil and fn(v): return true
  let names = columns.resolve(result.data).filterIt(it != result.rownameCol)
  let all = result.data.names.filterIt(it != result.rownameCol and it != result.groupnameCol)
  let ix = rows.resolve(result.data)
  var cells: seq[(int, string)]
  for i in ix:
    for n in names:
      if not matches(result.data[n, i]): continue
      case targets
      of "cell": cells.add (i, n)
      of "row":
        for m in all: cells.add (i, m)
      else:
        for j in 0 ..< result.data.nrows: cells.add (j, n)
  var seen: seq[(int, string)]
  for c in cells:
    if c notin seen: seen.add c
  if seen.len > 0:
    result.tabStyleCells(style, Target(kind: lkBody, cells: seen))

# --------------------------------------------------------------------------------- preview

proc tabellaPreview*(data: TableData, topN = 5, bottomN = 1, inclRownums = true): Tabella =
  ## A preview of a big table: its first `topN` rows, a row that says which rows are left out
  ## ("6..99"), and its last `bottomN` rows, numbered from 1 in the stub (`inclRownums`), as
  ## gt's `gt_preview()`.
  let n = data.nrows
  var keep: seq[int]
  if n <= topN + bottomN + 1:
    for i in 0 ..< n: keep.add i
  else:
    for i in 0 ..< topN: keep.add i
    keep.add -1
    for i in n - bottomN ..< n: keep.add i
  const stub = "\x1Fpreview-row"
  var cols: seq[(string, seq[Value])]
  if inclRownums or keep.contains(-1):
    var nums: seq[Value]
    for i in keep:
      nums.add(if i >= 0: (if inclRownums: toValue($(i + 1)) else: toValue(""))
               else: toValue($(topN + 1) & ".." & $(n - bottomN)))
    cols.add (stub, nums)
  for c in data.columns:
    var vs: seq[Value]
    for i in keep: vs.add(if i >= 0: c.values[i] else: null())
    cols.add (c.name, vs)
  result = initTabella(toTableData(cols), rownameCol = if cols.len > 0 and cols[0][0] == stub: stub else: "")
  let gap = keep.find(-1)
  if gap >= 0:
    result.styles.add StyleRule(target: Target(kind: lkBody, cells: data.names.mapIt((gap, it))),
                                style: style.fill("rgba(128, 128, 128, 0.12)"))
    result.styles.add StyleRule(target: Target(kind: lkStub, cells: @[(gap, stub)]),
                                style: style.fill("rgba(128, 128, 128, 0.12)") & style.text(size = "smaller"))
