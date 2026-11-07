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
  if t.hasStub:
    headers.add t.stubhead.renderText(rcText) & b.marksText("stubhead", m)
    aligns.add alLeft
  for c in b.columns:
    headers.add c.label.renderText(rcText) & b.marksText(colKey(c.name), m)
    aligns.add c.align
  var rows: seq[seq[string]]
  var groupBefore: seq[string]     # group label shown above a row ("" for none)
  for g in b.groups:
    for k, r in g.rows:
      var cells: seq[string]
      if t.hasStub: cells.add r.stub & b.marksText(cellKey(r.index, t.rownameCol), m)
      for j, c in b.columns: cells.add r.cells[j] & b.marksText(cellKey(r.index, c.name), m)
      rows.add cells
      groupBefore.add(if k == 0 and g.id.len > 0: g.label & b.marksText(groupKey(g.id), m) else: "")
  var widths = headers.mapIt(it.width)
  for r in rows:
    for j, c in r: widths[j] = max(widths[j], c.width)
  # spanners: one line per level, above the labels
  let levels = t.spannerLevels(b.columns)
  let off = if t.hasStub: 1 else: 0
  var spannerLines: seq[seq[(string, int)]]  # (label, number of columns)
  for lv in countdown(levels, 1):
    var line: seq[(string, int)]
    if t.hasStub: line.add ("", 1)
    var j = 0
    while j < b.columns.len:
      let k = t.spannerAt(b.columns[j].name, lv)
      var span = 1
      while j + span < b.columns.len and t.spannerAt(b.columns[j + span].name, lv) == k: inc span
      let label = if k >= 0: t.spanners[k].label.renderText(rcText) else: ""
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
  lines.add "│" & toSeq(0 ..< headers.len).mapIt(" " & pad(headers[it], widths[it], aligns[it]) & " ").join("│") & "│"
  lines.add rule("╞", "╪", "╡").replace("─", "═")
  for k, r in rows:
    if groupBefore[k].len > 0:
      if k > 0: lines.add rule("├", "┼", "┤")
      lines.add "│ " & pad(groupBefore[k], inner, alLeft) & " │"
      lines.add rule("├", "┼", "┤").replace("─", "┄")
    lines.add "│" & toSeq(0 ..< r.len).mapIt(" " & pad(r[it], widths[it], aligns[it]) & " ").join("│") & "│"
  lines.add rule("└", "┴", "┘")
  for (k, n) in b.footer: lines.add (if k > 0: footMarkText(k, m) & " " else: "") & n
  for n in t.sourceNotes: lines.add n.renderText(rcText)
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
  if t.hasStub: (header.add mdEscape(t.stubhead.renderText(rcText)); sep.add ":--")
  for c in b.columns:
    header.add mdEscape(c.label.renderText(rcText) & b.marksText(colKey(c.name), m))
    sep.add(case c.align
            of alRight: "--:"
            of alCenter: ":-:"
            else: ":--")
  lines.add "| " & header.join(" | ") & " |"
  lines.add "|" & sep.join("|") & "|"
  for g in b.groups:
    if g.id.len > 0:
      var cells = @["**" & mdEscape(g.label) & "**"]
      for _ in 1 ..< header.len: cells.add ""
      lines.add "| " & cells.join(" | ") & " |"
    for r in g.rows:
      var cells: seq[string]
      if t.hasStub: cells.add mdEscape(r.stub)
      for j, c in b.columns: cells.add mdEscape(r.cells[j] & b.marksText(cellKey(r.index, c.name), m))
      lines.add "| " & cells.join(" | ") & " |"
  if b.notes.len > 0 or b.plainNotes.len > 0 or t.sourceNotes.len > 0: lines.add ""
  for (k, n) in b.footer: lines.add (if k > 0: "<sup>" & footMarkText(k, m) & "</sup> " else: "") & n & "  "
  for n in t.sourceNotes: lines.add n.renderText(rcText) & "  "
  lines.join("\n")
