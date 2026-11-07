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

func markText*(n: int, marks: FootnoteMarks): string =
  case marks
  of fmNumbers: $n
  of fmLetters: $chr(ord('a') + (n - 1) mod 26)
  of fmCapitals: $chr(ord('A') + (n - 1) mod 26)
  of fmStandard: ["*", "†", "‡", "§", "‖", "¶"][(n - 1) mod 6].repeat((n - 1) div 6 + 1)

proc build*(t: Tabella, ctx: RenderContext): Built =
  result.ctx = ctx
  result.columns = t.visibleData
  # rows in display order: ungrouped rows first, then each group in order
  var order = @[""] & toSeq(t.groupLabels.keys)
  for gid in order:
    var g = BuiltGroup(id: gid, label: if gid.len > 0: t.groupLabels[gid].renderText(ctx) else: "")
    for i in 0 ..< t.data.nrows:
      if t.rowGroups[i] != gid: continue
      var r = BuiltRow(index: i)
      if t.hasStub: r.stub = t.formatCell(i, t.rownameCol, ctx)
      for c in result.columns: r.cells.add t.formatCell(i, c.name, ctx)
      g.rows.add r
    if g.rows.len > 0: result.groups.add g

  # footnote marks, numbered in reading order of their locations
  var keysInOrder = @["title", "subtitle", "stubhead"]
  for s in t.spanners.sortedByIt(-it.level): keysInOrder.add spannerKey(s.label.s)
  for c in result.columns: keysInOrder.add colKey(c.name)
  for g in result.groups:
    keysInOrder.add groupKey(g.id)
    for r in g.rows:
      if t.hasStub: keysInOrder.add cellKey(r.index, t.rownameCol)
      for c in result.columns: keysInOrder.add cellKey(r.index, c.name)
  var keysOfNote: seq[seq[string]]
  for f in t.footnotes:
    var ks: seq[string]
    case f.target.kind
    of lkTitle: ks = @["title"]
    of lkSubtitle: ks = @["subtitle"]
    of lkStubhead: ks = @["stubhead"]
    of lkSpanners: ks = f.target.names.mapIt(spannerKey(it))
    of lkColumnLabels: ks = f.target.names.mapIt(colKey(it))
    of lkRowGroups: ks = f.target.names.mapIt(groupKey(it))
    of lkBody, lkStub: ks = f.target.cells.mapIt(cellKey(it[0], it[1]))
    else: discard
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
  numbered.sort
  var byText: Table[string, int]
  for (_, k) in numbered:
    let txt = t.footnotes[k].note.renderText(ctx)
    var n = byText.getOrDefault(txt, 0)
    if n == 0:
      result.notes.add txt
      n = result.notes.len
      byText[txt] = n
    for key in keysOfNote[k]:
      if n notin result.marks.getOrDefault(key): result.marks.mgetOrPut(key, @[]).add n

  # styles: later rules come later in the declaration list, so they win
  for s in t.styles:
    var ks: seq[string]
    case s.target.kind
    of lkTitle: ks = @["title"]
    of lkSubtitle: ks = @["subtitle"]
    of lkStubhead: ks = @["stubhead"]
    of lkSpanners: ks = s.target.names.mapIt(spannerKey(it))
    of lkColumnLabels: ks = s.target.names.mapIt(colKey(it))
    of lkRowGroups: ks = s.target.names.mapIt(groupKey(it))
    of lkBody, lkStub: ks = s.target.cells.mapIt(cellKey(it[0], it[1]))
    of lkSourceNotes: ks = @["source_notes"]
    of lkFootnotes: ks = @["footnotes"]
    for key in ks:
      let css = s.style.toCss
      if css.len == 0: continue
      result.styles[key] = (if key in result.styles: result.styles[key] & "; " else: "") & css

proc marksHtml*(b: Built, key: string, marks: FootnoteMarks): string =
  let ms = b.marks.getOrDefault(key)
  if ms.len == 0: return ""
  "<span class=\"tb_footnote_marks\">" & ms.mapIt(markText(it, marks)).join(",") & "</span>"

proc marksText*(b: Built, key: string, marks: FootnoteMarks): string =
  let ms = b.marks.getOrDefault(key)
  if ms.len == 0: "" else: "^" & ms.mapIt(markText(it, marks)).join(",")

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
