## Building a table for display: the step every renderer shares, after gt's `build_data()`.
## It runs the formats and substitutions, puts the rows in display order (groups), places the
## footnote marks and gathers the styles of every location. The renderers (HTML, text, Markdown)
## only lay out a `Built`.

import std/[tables, sequtils, strutils, algorithm]
import core, formats

type
  BuiltRow* = object
    index*: int                  ## row in the data
    stub*: string                ## the stub cell, formatted ("" without a stub)
    cells*: seq[string]          ## formatted cells of the visible data columns
  BuiltGroup* = object
    id*: string
    label*: string               ## rendered label ("" for rows outside any group)
    rows*: seq[BuiltRow]
  Built* = object
    ctx*: RenderContext
    columns*: seq[ColInfo]       ## visible data columns, in order
    groups*: seq[BuiltGroup]
    marks*: Table[string, seq[int]]    ## location key -> footnote numbers
    notes*: seq[string]                ## rendered footnotes, by number - 1
    plainNotes*: seq[string]           ## footnotes without a mark
    footer*: seq[(int, string)]        ## the footnotes in the order shown: (mark number or 0, text)
    styles*: Table[string, string]     ## location key -> CSS

func cellKey*(row: int, col: string): string = "cell:" & $row & ":" & col
func colKey*(col: string): string = "col:" & col
func spannerKey*(label: string): string = "spanner:" & label
func groupKey*(id: string): string = "group:" & id

func renderText*(t: Text, ctx: RenderContext): string =
  if ctx == rcHtml: textToHtml(t) else: textToPlain(t)

proc formatCell*(t: Tabella, row: int, col: string, ctx: RenderContext): string =
  ## The shown text of one cell: the last format that covers it, then any substitution.
  let v = t.data[col, row]
  var done = false
  if not v.isNull:
    for k in countdown(t.formats.high, 0):
      let f = t.formats[k]
      if col in f.columns and (f.rows.len == 0 or row in f.rows):
        result = f.fn(v, ctx)
        done = true
        break
    if not done:
      result = (if ctx == rcHtml: escapeHtml($v) else: $v)
  for s in t.substitutions:
    if col in s.columns and (s.rows.len == 0 or row in s.rows) and (s.nullsToo == v.isNull):
      let r = s.fn(v, ctx)
      if r.len > 0 or s.nullsToo: result = r

func markText*(n: int, marks: FootnoteMarks, custom: seq[string] = @[]): string =
  ## The mark of footnote `n` (from 1): numbers, letters, capitals, the four standard symbols
  ## (*, †, ‡, §) or six extended ones (with ‖, ¶), or marks of your own; symbols repeat (**) when
  ## they run out.
  if custom.len > 0: return custom[(n - 1) mod custom.len].repeat((n - 1) div custom.len + 1)
  case marks
  of fmNumbers: $n
  of fmLetters: $chr(ord('a') + (n - 1) mod 26)
  of fmCapitals: $chr(ord('A') + (n - 1) mod 26)
  of fmStandard: ["*", "†", "‡", "§"][(n - 1) mod 4].repeat((n - 1) div 4 + 1)
  of fmExtended: ["*", "†", "‡", "§", "‖", "¶"][(n - 1) mod 6].repeat((n - 1) div 6 + 1)

func markText*(n: int, o: TabOptions): string = markText(n, o.footnotesMarks, o.footnotesMarksCustom)

func wrapMark*(s, spec: string): string =
  ## `s` inside the brackets that `spec` asks for: "(" gives "(1)", "[" gives "[1]".
  if '(' in spec: "(" & s & ")" elif '[' in spec: "[" & s & "]" else: s

func markSpanHtml*(s, spec: string): string =
  ## A mark (or marks) as HTML: raised with "^", italic with "i", bold with "b".
  var css: seq[string]
  if '^' notin spec: css.add "vertical-align: baseline; font-size: 100%"
  if 'i' in spec: css.add "font-style: italic"
  if 'b' in spec: css.add "font-weight: bold"
  "<span class=\"tb_footnote_marks\"" & (if css.len > 0: " style=\"" & css.join("; ") & "\"" else: "") &
    ">" & wrapMark(s, spec) & "</span>"

proc keysOf*(t: Tabella, target: Target, columns: seq[ColInfo]): seq[string] =
  ## The location keys a target covers, as the renderers name them.
  case target.kind
  of lkTitle: @["title"]
  of lkSubtitle: @["subtitle"]
  of lkHeader: @["title", "subtitle"]
  of lkStubhead: @["stubhead"]
  of lkSpanners: target.names.mapIt(spannerKey(it))
  of lkColumnLabels: target.names.mapIt(colKey(it))
  of lkColumnHeader:
    @["stubhead"] & t.spanners.mapIt(spannerKey(it.label.s)) & columns.mapIt(colKey(it.name))
  of lkRowGroups: target.names.mapIt(groupKey(it))
  of lkBody, lkStub: target.cells.mapIt(cellKey(it[0], it[1]))
  of lkSourceNotes: @["source_notes"]
  of lkFootnotes: @["footnotes"]
  of lkFooter: @["footnotes", "source_notes"]

proc displayOrder*(t: Tabella): seq[int] =
  ## The rows of the data in the order they are shown (before grouping).
  if t.rowOrder.len > 0: t.rowOrder else: toSeq(0 ..< t.data.nrows)

proc transformCell*(t: Tabella, row: int, col: string, shown: string): string =
  ## The shown text of a cell after the text transforms that cover it, in the order given.
  result = shown
  for tr in t.transforms:
    if (row, col) in tr.target.cells: result = tr.fn(result)

proc build*(t: Tabella, ctx: RenderContext): Built =
  result.ctx = ctx
  result.columns = t.visibleData
  # rows in display order: ungrouped rows first, then each group in order
  var order = @[""] & toSeq(t.groupLabels.keys)
  for gid in order:
    var g = BuiltGroup(id: gid, label: if gid.len > 0: t.groupLabels[gid].renderText(ctx) else: "")
    for i in t.displayOrder:
      if t.rowGroups[i] != gid: continue
      var r = BuiltRow(index: i)
      if t.hasStub: r.stub = t.transformCell(i, t.rownameCol, t.formatCell(i, t.rownameCol, ctx))
      for c in result.columns: r.cells.add t.transformCell(i, c.name, t.formatCell(i, c.name, ctx))
      g.rows.add r
    if g.rows.len > 0: result.groups.add g

  # footnote marks, numbered in reading order of their locations
  var keysInOrder = @["title", "subtitle"] & (if t.hasStub: @["stubhead"] else: @[])
  for s in t.spanners.sortedByIt(-it.level): keysInOrder.add spannerKey(s.label.s)
  for c in result.columns: keysInOrder.add colKey(c.name)
  for g in result.groups:
    keysInOrder.add groupKey(g.id)
    for r in g.rows:
      if t.hasStub: keysInOrder.add cellKey(r.index, t.rownameCol)
      for c in result.columns: keysInOrder.add cellKey(r.index, c.name)
  var keysOfNote: seq[seq[string]]
  for f in t.footnotes:
    var ks = if f.target.kind in {lkFootnotes, lkSourceNotes, lkFooter}: @[]
             else: t.keysOf(f.target, result.columns)
    if f.target.kind in {lkHeader, lkColumnHeader}:   # a whole part: marked on its first element
      ks = ks.filterIt(it in keysInOrder)
      ks = if ks.len == 0: @[] else: @[ks[ks.mapIt(keysInOrder.find(it)).minIndex]]
    keysOfNote.add ks
  var numbered: seq[(int, int)]   # (first position, footnote index)
  for k, ks in keysOfNote:
    if ks.len == 0:
      result.plainNotes.add t.footnotes[k].note.renderText(ctx)
      continue
    var first = high(int)
    for key in ks:
      let p = keysInOrder.find(key)
      if p >= 0: first = min(first, p)
    numbered.add (first, k)
  if t.options.footnotesOrder == "preserve_order": numbered.sort(proc (a, b: (int, int)): int = cmp(a[1], b[1]))
  else: numbered.sort
  var byText: Table[string, int]
  var firstOf: seq[int]          # for each mark number - 1, the footnote that made it
  for (_, k) in numbered:
    let txt = t.footnotes[k].note.renderText(ctx)
    var n = byText.getOrDefault(txt, 0)
    if n == 0:
      result.notes.add txt
      firstOf.add k
      n = result.notes.len
      byText[txt] = n
    for key in keysOfNote[k]:
      if n notin result.marks.getOrDefault(key): result.marks.mgetOrPut(key, @[]).add n
  let marked = toSeq(0 ..< result.notes.len).mapIt((it + 1, result.notes[it]))
  let plain = result.plainNotes.mapIt((0, it))
  case t.options.footnotesOrder
  of "marks_last": result.footer = plain & marked
  of "preserve_order":   # as they were added
    var items: seq[(int, (int, string))]
    for n, k in firstOf: items.add (k, (n + 1, result.notes[n]))
    var p = 0
    for k, ks in keysOfNote:
      if ks.len == 0: (items.add (k, (0, result.plainNotes[p])); inc p)
    items.sort(proc (a, b: (int, (int, string))): int = cmp(a[0], b[0]))
    result.footer = items.mapIt(it[1])
  else: result.footer = marked & plain

  # styles: later rules come later in the declaration list, so they win
  for s in t.styles:
    let ks = t.keysOf(s.target, result.columns)
    for key in ks:
      let css = s.style.toCss
      if css.len == 0: continue
      result.styles[key] = (if key in result.styles: result.styles[key] & "; " else: "") & css

proc marksHtml*(b: Built, key: string, o: TabOptions): string =
  let ms = b.marks.getOrDefault(key)
  if ms.len == 0: return ""
  markSpanHtml(ms.mapIt(markText(it, o)).join(","), o.footnotesSpecRef)

proc marksText*(b: Built, key: string, o: TabOptions): string =
  let ms = b.marks.getOrDefault(key)
  if ms.len == 0: return ""
  (if '^' in o.footnotesSpecRef: "^" else: "") & wrapMark(ms.mapIt(markText(it, o)).join(","), o.footnotesSpecRef)

proc footMarkHtml*(n: int, o: TabOptions): string = markSpanHtml(markText(n, o), o.footnotesSpecFtr)
proc footMarkText*(n: int, o: TabOptions): string = wrapMark(markText(n, o), o.footnotesSpecFtr)

func spannerLevels*(t: Tabella, columns: seq[ColInfo]): int =
  ## How many rows of spanners sit over the visible columns.
  let visible = columns.mapIt(it.name)
  for s in t.spanners:
    if s.columns.anyIt(it in visible): result = max(result, s.level)

func spannerAt*(t: Tabella, col: string, level: int): int =
  ## The index of the spanner over `col` at `level`, or -1.
  for k, s in t.spanners:
    if s.level == level and col in s.columns: return k
  -1
