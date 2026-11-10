## Building a table for display: the step every renderer shares, after gt's `build_data()`.
## It runs the formats and substitutions, puts the rows in display order (groups), places the
## footnote marks and gathers the styles of every location. The renderers (HTML, text, Markdown)
## only lay out a `Built`.

import std/[tables, sequtils, strutils, algorithm]
from std/unicode import runeLen
import core, formats

type
  BuiltRow* = object
    index*: int                  ## row in the data
    stub*: string                ## the stub cell, formatted ("" without a stub)
    indent*: int                 ## indent level of the stub cell (0 to 5)
    cells*: seq[string]          ## formatted cells of the visible data columns
  BuiltSummary* = object
    label*: string               ## the label in the stub, rendered
    key*: string                 ## the location key of its stub cell (`summaryKey`)
    cells*: seq[string]          ## formatted cells of the visible data columns
  BuiltGroup* = object
    id*: string
    label*: string               ## rendered label ("" for rows outside any group)
    rows*: seq[BuiltRow]
    summaryTop*, summaryBottom*: seq[BuiltSummary]   ## the group's summary rows
  Built* = object
    ctx*: RenderContext
    columns*: seq[ColInfo]       ## visible data columns, in order
    groups*: seq[BuiltGroup]
    grandTop*, grandBottom*: seq[BuiltSummary]       ## the grand summary rows
    marks*: Table[string, seq[int]]    ## location key -> footnote numbers
    notes*: seq[string]                ## rendered footnotes, by number - 1
    plainNotes*: seq[string]           ## footnotes without a mark
    footer*: seq[(int, string)]        ## the footnotes in the order shown: (mark number or 0, text)
    styles*: Table[string, string]     ## location key -> CSS

func cellKey*(row: int, col: string): string = "cell:" & $row & ":" & col
func colKey*(col: string): string = "col:" & col
func spannerKey*(label: string): string = "spanner:" & label
func groupKey*(id: string): string = "group:" & id
func summaryKey*(group, label: string, col = ""): string =
  ## A cell of a group's summary row (the stub cell when `col` is "").
  "summary:" & group & ":" & label & ":" & col
func grandKey*(label: string, col = ""): string = "grand:" & label & ":" & col

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
  of lkSummary, lkSummaryStub, lkGrandSummary, lkGrandSummaryStub:
    let grand = target.kind in {lkGrandSummary, lkGrandSummaryStub}
    let cols = if target.kind in {lkSummaryStub, lkGrandSummaryStub}: @[""]
               else: columns.mapIt(it.name).filterIt(it in target.columns)
    var keys: seq[string]
    for rule in t.summaries:
      if rule.grand != grand: continue
      let groups = if grand: @[""]
                   elif rule.groups.len > 0: rule.groups
                   else: toSeq(t.groupLabels.keys)
      for g in groups:
        if not grand and target.names.len > 0 and g notin target.names: continue
        for (label, _) in rule.fns:
          if target.labels.len > 0 and label notin target.labels: continue
          for c in cols:
            let k = if grand: grandKey(label, c) else: summaryKey(g, label, c)
            if k notin keys: keys.add k
    keys

proc displayOrder*(t: Tabella): seq[int] =
  ## The rows of the data in the order they are shown (before grouping), without hidden rows.
  result = if t.rowOrder.len > 0: t.rowOrder else: toSeq(0 ..< t.data.nrows)
  if t.hiddenRows.len > 0: result = result.filterIt(it notin t.hiddenRows)

func fillPattern*(pattern: string, texts: seq[string], missing: seq[bool]): string =
  ## `pattern` with `{1}`, `{2}`, ... replaced by `texts`; a part in `<<...>>` is dropped when a
  ## value it names is missing (as in gt's `cols_merge`).
  proc refs(part: string): seq[int] =
    var i = 0
    while i < part.len:
      if part[i] == '{':
        let j = part.find('}', i)
        if j > i:
          try: result.add parseInt(part[i + 1 ..< j]) - 1
          except ValueError: discard
          i = j
      inc i
  proc fill(part: string): string =
    result = part
    for k in countdown(texts.high, 0): result = result.replace("{" & $(k + 1) & "}", texts[k])
  var i = 0
  while i < pattern.len:
    let a = pattern.find("<<", i)
    if a < 0:
      result.add fill(pattern[i .. ^1])
      break
    let b = pattern.find(">>", a + 2)
    if b < 0:
      result.add fill(pattern[i .. ^1])
      break
    result.add fill(pattern[i ..< a])
    let part = pattern[a + 2 ..< b]
    if not part.refs.anyIt(it >= 0 and it < missing.len and missing[it]): result.add fill(part)
    i = b + 2

proc mergedCell(t: Tabella, m: MergeRule, row: int, ctx: RenderContext): string =
  var texts, missing: seq[string]
  var isMissing: seq[bool]
  for c in m.columns:
    texts.add t.formatCell(row, c, ctx)
    isMissing.add t.data[c, row].isNull
  if m.kind == mkNPct and m.columns.len > 1:   # no percentage after a zero count
    let n = t.data[m.columns[0], row]
    if n.isNumber and n.toFloat == 0: isMissing[1] = true
  discard missing
  fillPattern(m.pattern, texts, isMissing)

proc shownCell*(t: Tabella, row: int, col: string, ctx: RenderContext): string =
  ## The text of a body cell: merged with other columns (`colsMerge`) or formatted.
  for k in countdown(t.merges.high, 0):
    let m = t.merges[k]
    if m.columns.len > 0 and m.columns[0] == col and (m.rows.len == 0 or row in m.rows):
      return t.mergedCell(m, row, ctx)
  t.formatCell(row, col, ctx)

proc transformCell*(t: Tabella, row: int, col: string, shown: string): string =
  ## The shown text of a cell after the text transforms that cover it, in the order given.
  result = shown
  for tr in t.transforms:
    if (row, col) in tr.target.cells: result = tr.fn(result)

proc columnFormat(t: Tabella, col: string): FormatRule =
  ## The last format given to the whole column `col` (`fn` is nil when there is none).
  for k in countdown(t.formats.high, 0):
    let f = t.formats[k]
    if col in f.columns and f.rows.len == 0: return f

proc formatSummary(t: Tabella, rule: SummaryRule, agg: Aggregate, v: Value, col: string,
                   ctx: RenderContext): string =
  if v.isNull: return (if ctx == rcHtml: escapeHtml(rule.missingText) else: rule.missingText)
  if rule.fmt != nil: return rule.fmt(v, ctx)
  if agg.name != "count":
    let f = t.columnFormat(col)
    if f.fn != nil: return f.fn(v, ctx)
  let s = if v.kind == vkFloat: formatNumber(v.f, decimals = 2) else: $v
  if ctx == rcHtml: escapeHtml(s) else: s

proc summaryOf(t: Tabella, rule: SummaryRule, rows: seq[int], columns: seq[ColInfo],
               group: string, ctx: RenderContext): seq[BuiltSummary] =
  ## The summary rows of `rule` over the data `rows`, one per aggregate.
  for (label, agg) in rule.fns:
    var s = BuiltSummary(label: if ctx == rcHtml: escapeHtml(label) else: label,
                         key: if rule.grand: grandKey(label) else: summaryKey(group, label))
    for c in columns:
      if c.name notin rule.columns:
        s.cells.add(if ctx == rcHtml: escapeHtml(rule.missingText) else: rule.missingText)
        continue
      var values: seq[Value]
      for i in rows:
        let v = t.data[c.name, i]
        if not v.isNull: values.add v
      s.cells.add t.formatSummary(rule, agg, agg.fn(values), c.name, ctx)
    result.add s

func fractionWidth(s, mark: string): int =
  ## How many characters, the mark included, come after the integer part of `s`.
  if '<' in s: return -1          # HTML: left as it is
  let p = s.rfind(mark)
  if p < 0: 0 else: s[p .. ^1].runeLen

proc alignDecimals(b: var Built, j: int, mark: string) =
  var cells: seq[ptr string]
  for g in b.groups.mitems:
    for r in g.rows.mitems: cells.add addr r.cells[j]
    for s in g.summaryTop.mitems: cells.add addr s.cells[j]
    for s in g.summaryBottom.mitems: cells.add addr s.cells[j]
  for s in b.grandTop.mitems: cells.add addr s.cells[j]
  for s in b.grandBottom.mitems: cells.add addr s.cells[j]
  var widest = 0
  for c in cells: widest = max(widest, fractionWidth(c[], mark))
  for c in cells:
    let w = fractionWidth(c[], mark)
    if w < 0 or c[].len == 0 or w == widest: continue
    var pad = widest - w
    if w == 0:    # no mark: a punctuation space stands for it
      c[].add "\u2008"
      dec pad
    for _ in 1 .. pad: c[].add "\u2007"

proc build*(t: Tabella, ctx: RenderContext): Built =
  result.ctx = ctx
  result.columns = t.visibleData
  # rows in display order: ungrouped rows first, then each group in order
  var order = @[""] & toSeq(t.groupLabels.keys).filterIt(it.len > 0)
  for gid in order:
    var g = BuiltGroup(id: gid, label: if gid.len > 0: t.groupLabels[gid].renderText(ctx) else: "")
    for i in t.displayOrder:
      if t.rowGroups[i] != gid: continue
      var r = BuiltRow(index: i, indent: t.indents.getOrDefault(i, 0))
      if t.hasRowNames: r.stub = t.transformCell(i, t.rownameCol, t.shownCell(i, t.rownameCol, ctx))
      for c in result.columns: r.cells.add t.transformCell(i, c.name, t.shownCell(i, c.name, ctx))
      g.rows.add r
    if g.rows.len > 0:
      for rule in t.summaries:
        if rule.grand or gid.len == 0 or (rule.groups.len > 0 and gid notin rule.groups): continue
        let rows = g.rows.mapIt(it.index)
        if rule.top: g.summaryTop.add t.summaryOf(rule, rows, result.columns, gid, ctx)
        else: g.summaryBottom.add t.summaryOf(rule, rows, result.columns, gid, ctx)
      result.groups.add g
  for rule in t.summaries:
    if not rule.grand: continue
    let rows = t.displayOrder
    if rule.top: result.grandTop.add t.summaryOf(rule, rows, result.columns, "", ctx)
    else: result.grandBottom.add t.summaryOf(rule, rows, result.columns, "", ctx)

  # decimal alignment: pad each cell after its mark with figure spaces, so the marks line up
  for j, c in result.columns:
    let k = t.decimalAligned.find(c.name)
    if k < 0: continue
    result.alignDecimals(j, t.decimalMarks[k])

  # footnote marks, numbered in reading order of their locations
  var keysInOrder = @["title", "subtitle"] & (if t.hasStub: @["stubhead"] else: @[])
  for s in t.spanners.sortedByIt(-it.level): keysInOrder.add spannerKey(s.label.s)
  for c in result.columns: keysInOrder.add colKey(c.name)
  proc addSummaryKeys(keys: var seq[string], rows: seq[BuiltSummary], columns: seq[ColInfo]) =
    for s in rows:
      keys.add s.key
      for c in columns: keys.add s.key & c.name
  keysInOrder.addSummaryKeys(result.grandTop, result.columns)
  for g in result.groups:
    keysInOrder.add groupKey(g.id)
    keysInOrder.addSummaryKeys(g.summaryTop, result.columns)
    for r in g.rows:
      if t.hasRowNames: keysInOrder.add cellKey(r.index, t.rownameCol)
      for c in result.columns: keysInOrder.add cellKey(r.index, c.name)
    keysInOrder.addSummaryKeys(g.summaryBottom, result.columns)
  keysInOrder.addSummaryKeys(result.grandBottom, result.columns)
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
  # a whole part (header, column header, footer) goes first, so its own parts' styles win, as in
  # Great Tables
  let composite = {lkHeader, lkColumnHeader, lkFooter}
  for s in t.styles.filterIt(it.target.kind in composite) & t.styles.filterIt(it.target.kind notin composite):
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
