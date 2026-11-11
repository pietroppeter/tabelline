## Rendering to plain text (box drawing, for terminals and `echo`) and to Markdown (a GitHub pipe
## table, for nimib's Markdown backend and READMEs). Both use the same built table as HTML, so
## the formats, groups and footnote marks agree.

import std/[strutils, unicode, sequtils, math]
import core, build

func width(s: string): int = s.runeLen

func pad(s: string, w: int, a: Align): string =
  let n = max(0, w - s.width)
  case a
  of alRight: " ".repeat(n) & s
  of alCenter: " ".repeat(n div 2) & s & " ".repeat(n - n div 2)
  else: s & " ".repeat(n)

proc toText*(t: Tabella): string =
  ## The table drawn with box characters, like a dataframe printed at the console, but with the
  ## formats, the stub, the groups and the notes.
  let b = t.build(rcText)
  let m = t.options
  var headers: seq[string]
  var aligns: seq[Align]
  let asColumn = t.groupAsColumn
  let sw = t.stubWidth
  for k in 0 ..< sw:   # the stubhead over the first column of the stub
    headers.add(if k == 0: t.stubhead.renderLabel(rcText) & b.marksText("stubhead", m) else: "")
    aligns.add alLeft
  for c in b.columns:
    headers.add c.columnLabel(rcText, m.columnLabelsUnitsPattern) & b.marksText(colKey(c.name), m)
    aligns.add c.align
  # the body as a list of lines to draw: rows of cells, group labels, and rules
  type
    EntryKind = enum ekRow, ekLabel, ekRule
    Entry = object
      kind: EntryKind
      cells: seq[string]
      text: string     # the label, or the rule's kind: "group" (├─┼), "dots" (├┄┼), "grand" (╞═╪)
  var entries: seq[Entry]
  var groupCell = ""   # the group's label, for the first of its rows (as a column)
  proc summaryEntries(ss: seq[BuiltSummary], grand = false) =
    for s in ss:
      var cells: seq[string]
      if asColumn and not grand: (cells.add groupCell; groupCell = "")
      cells.add s.label & b.marksText(s.key, m)
      while cells.len < sw: cells.add ""
      for j, c in b.columns: cells.add s.cells[j] & b.marksText(s.key & c.name, m)
      entries.add Entry(kind: ekRow, cells: cells)
  if b.grandTop.len > 0:
    summaryEntries(b.grandTop, grand = true)
    entries.add Entry(kind: ekRule, text: "grand")
  var bodyStart = entries.len
  var shown = 0
  for g in b.groups:
    if asColumn:
      if entries.len > bodyStart: entries.add Entry(kind: ekRule, text: "group")
      groupCell = g.label & b.marksText(groupKey(g.id), m)
    elif g.id.len > 0 or g.label.len > 0:
      if entries.len > bodyStart: entries.add Entry(kind: ekRule, text: "group")
      entries.add Entry(kind: ekLabel, text: g.label & b.marksText(groupKey(g.id), m))
      entries.add Entry(kind: ekRule, text: "dots")
    if g.summaryTop.len > 0:
      summaryEntries(g.summaryTop)
      entries.add Entry(kind: ekRule, text: "dots")
    for r in g.rows:
      inc shown
      var cells: seq[string]
      if asColumn: (cells.add groupCell; groupCell = "")
      for k, c in t.stubCols:   # a level the row above covers is left blank
        cells.add(if r.spans[k] == 0: "" else: r.levels[k] & b.marksText(cellKey(r.index, c), m))
      if t.hasStub: cells.add "  ".repeat(r.indent) & r.stub & b.marksText(cellKey(r.index, t.rownameCol), m)
      for j, c in b.columns: cells.add r.cells[j] & b.marksText(cellKey(r.index, c.name), m)
      entries.add Entry(kind: ekRow, cells: cells)
    if g.summaryBottom.len > 0:
      entries.add Entry(kind: ekRule, text: "dots")
      summaryEntries(g.summaryBottom)
  if shown == 0 and b.grandTop.len == 0 and b.grandBottom.len == 0:
    entries.add Entry(kind: ekLabel, text: m.tableNoDataMessage)
  if b.grandBottom.len > 0:
    entries.add Entry(kind: ekRule, text: "grand")
    summaryEntries(b.grandBottom, grand = true)
  if m.columnLabelsHidden: headers = headers.mapIt("")
  let rows = entries.filterIt(it.kind == ekRow).mapIt(it.cells)
  var widths = headers.mapIt(it.width)
  for r in rows:
    for j, c in r: widths[j] = max(widths[j], c.width)
  # spanners: one line per level, above the labels
  let levels = if m.columnLabelsHidden: 0 else: t.spannerLevels(b.columns)
  let off = if t.hasStub: 1 else: 0
  var spannerLines: seq[seq[(string, int)]]  # (label, number of columns)
  for lv in countdown(levels, 1):
    var line: seq[(string, int)]
    if sw > 0: line.add ("", sw)
    var j = 0
    while j < b.columns.len:
      let k = t.spannerAt(b.columns[j].name, lv)
      var span = 1
      while j + span < b.columns.len and t.spannerAt(b.columns[j + span].name, lv) == k: inc span
      let label = if k >= 0: t.spanners[k].label.renderLabel(rcText) else: ""
      line.add (label, span)
      j += span
    spannerLines.add line
  # widen columns so that each spanner label fits over its columns
  for line in spannerLines:
    var j = 0
    for (label, span) in line:
      let have = toSeq(j ..< j + span).mapIt(widths[it]).sum + 3 * (span - 1)
      if label.width > have: widths[j + span - 1] += label.width - have
      j += span
  let inner = widths.sum + 3 * (widths.len - 1)
  func rule(l, mid, r: string): string =
    l & widths.mapIt("─".repeat(it + 2)).join(mid) & r
  var lines: seq[string]
  if not t.caption.isEmpty: lines.add t.caption.renderText(rcText)
  let title = t.title.renderText(rcText)
  if title.len > 0: lines.add pad(title & b.marksText("title", m), inner + 4, alCenter).strip(leading = false)
  let subtitle = t.subtitle.renderText(rcText)
  if subtitle.len > 0: lines.add pad(subtitle & b.marksText("subtitle", m), inner + 4, alCenter).strip(leading = false)
  lines.add rule("┌", "┬", "┐")
  for line in spannerLines:
    var s = "│"
    var j = 0
    for (label, span) in line:
      let w = toSeq(j ..< j + span).mapIt(widths[it]).sum + 3 * (span - 1)
      s.add " " & pad(label, w, alCenter) & " │"
      j += span
    lines.add s
  if not m.columnLabelsHidden:
    lines.add "│" & toSeq(0 ..< headers.len).mapIt(" " & pad(headers[it], widths[it], aligns[it]) & " ").join("│") & "│"
    lines.add rule("╞", "╪", "╡").replace("─", "═")
  for e in entries:
    case e.kind
    of ekLabel: lines.add "│ " & pad(e.text, inner, alLeft) & " │"
    of ekRule:
      lines.add(case e.text
                of "dots": rule("├", "┼", "┤").replace("─", "┄")
                of "grand": rule("╞", "╪", "╡").replace("─", "═")
                else: rule("├", "┼", "┤"))
    of ekRow:
      let r = e.cells
      lines.add "│" & toSeq(0 ..< r.len).mapIt(" " & pad(r[it], widths[it], aligns[it]) & " ").join("│") & "│"
  lines.add rule("└", "┴", "┘")
  let notes = b.footer.mapIt((if it[0] > 0: footMarkText(it[0], m) & " " else: "") & it[1])
  if m.footnotesMultiline: lines.add notes
  elif notes.len > 0: lines.add notes.join(m.footnotesSep)
  let sources = t.sourceNotes.mapIt(it.renderText(rcText))
  if m.sourceNotesMultiline: lines.add sources
  elif sources.len > 0: lines.add sources.join(m.sourceNotesSep)
  discard off
  lines.join("\n")

proc `$`*(t: Tabella): string = t.toText
  ## `echo t` draws the table.

func mdEscape(s: string): string = s.replace("|", "\\|")

proc toMarkdown*(t: Tabella): string =
  ## A GitHub-flavoured Markdown table, with the title above and the notes below. Spanners and
  ## group headings, which pipe tables cannot hold, become a line of text.
  let b = t.build(rcText)
  let m = t.options
  var lines: seq[string]
  if not t.caption.isEmpty: lines.add @["*" & t.caption.renderText(rcText) & "*", ""]
  let title = t.title.renderText(rcText)
  if title.len > 0: lines.add "**" & title & "**" & b.marksText("title", m)
  let subtitle = t.subtitle.renderText(rcText)
  if subtitle.len > 0: lines.add "*" & subtitle & "*"
  if lines.len > 0: lines.add ""
  var header, sep: seq[string]
  let asColumn = t.groupAsColumn
  let sw = t.stubWidth
  for k in 0 ..< sw:
    header.add(if k == 0: mdEscape(t.stubhead.renderLabel(rcText)) else: "")
    sep.add ":--"
  for c in b.columns:
    header.add mdEscape(c.columnLabel(rcText, m.columnLabelsUnitsPattern) & b.marksText(colKey(c.name), m))
    sep.add(case c.align
            of alRight: "--:"
            of alCenter: ":-:"
            else: ":--")
  if m.columnLabelsHidden: header = header.mapIt("")   # a pipe table needs its header line
  lines.add "| " & header.join(" | ") & " |"
  lines.add "|" & sep.join("|") & "|"
  var groupCell = ""
  proc summaryLines(ss: seq[BuiltSummary], mark: string) =
    # summary rows: the label in italics (a group's) or bold (the table's)
    for s in ss:
      var cells: seq[string]
      if asColumn and mark == "*": (cells.add groupCell; groupCell = "")
      cells.add mark & mdEscape(s.label) & mark & b.marksText(s.key, m)
      while cells.len < sw: cells.add ""
      for j, c in b.columns: cells.add mdEscape(s.cells[j] & b.marksText(s.key & c.name, m))
      lines.add "| " & cells.join(" | ") & " |"
  summaryLines(b.grandTop, "**")
  var shown = 0
  for g in b.groups:
    if asColumn: groupCell = "**" & mdEscape(g.label) & "**"
    elif g.id.len > 0 or g.label.len > 0:
      var cells = @["**" & mdEscape(g.label) & "**"]
      for _ in 1 ..< header.len: cells.add ""
      lines.add "| " & cells.join(" | ") & " |"
    summaryLines(g.summaryTop, "*")
    for r in g.rows:
      inc shown
      var cells: seq[string]
      if asColumn: (cells.add groupCell; groupCell = "")
      for k, c in t.stubCols: cells.add(if r.spans[k] == 0: "" else: mdEscape(r.levels[k]))
      if t.hasStub: cells.add "\u00A0\u00A0".repeat(r.indent) & mdEscape(r.stub)
      for j, c in b.columns: cells.add mdEscape(r.cells[j] & b.marksText(cellKey(r.index, c.name), m))
      lines.add "| " & cells.join(" | ") & " |"
    summaryLines(g.summaryBottom, "*")
  if shown == 0 and b.grandTop.len == 0 and b.grandBottom.len == 0:
    lines.add "| *" & mdEscape(m.tableNoDataMessage) & "* |" & " |".repeat(max(0, header.len - 1))
  summaryLines(b.grandBottom, "**")
  if b.notes.len > 0 or b.plainNotes.len > 0 or t.sourceNotes.len > 0: lines.add ""
  let notes = b.footer.mapIt((if it[0] > 0: "<sup>" & footMarkText(it[0], m) & "</sup> " else: "") & it[1])
  let sources = t.sourceNotes.mapIt(it.renderText(rcText))
  for (items, multi, sep) in [(notes, m.footnotesMultiline, m.footnotesSep),
                              (sources, m.sourceNotesMultiline, m.sourceNotesSep)]:
    if multi: (for n in items: lines.add n & "  ")
    elif items.len > 0: lines.add items.join(sep) & "  "
  lines.join("\n")
