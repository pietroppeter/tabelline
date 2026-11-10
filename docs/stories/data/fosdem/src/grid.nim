## Expand HTML tables (rowspan/colspan aware) into grids of cell texts.
##
## Usage: grid <html file> [min_cols]   prints the tables as TSV rows, for inspection,
## or import it and call tables(path).

import std/[tables, unicode]
import common

type
  Cell = ref object
    text: string
    rs, cs: int
  Tab = object
    rows: seq[seq[Cell]]
    hasRow: bool
    cell: Cell

const rawText = ["script", "style", "xmp", "iframe", "noembed", "noframes", "textarea", "title"]

proc span(attrs, name: string): int =
  ## rowspan or colspan: its digits, 1 when missing or empty.
  let m = attrs.search(rx("(?i)(?:^|[\\s\"'])" & name & "\\s*=\\s*(\"[^\"]*\"|'[^']*'|[^\\s>]*)"))
  let digits = if m.ok: m.group(1).sub(rx"\D", "") else: ""
  if digits.len == 0: 1 else: parseInt(digits)

proc tagEnd(html: string, i: int): int =
  ## Where a start tag ends: its '>', outside quoted attribute values.
  var q = '\0'
  for j in i ..< html.len:
    if q != '\0':
      if html[j] == q: q = '\0'
    elif html[j] in {'"', '\''} and j > 0 and html[j - 1] == '=': q = html[j]
    elif html[j] == '>': return j
  -1

proc parse(html: string): seq[seq[seq[Cell]]] =
  ## The tables of a page, in the order they close, as rows of cells.
  var closed: seq[seq[seq[Cell]]]
  var stack: seq[Tab]
  var data = ""
  proc flush() =
    if data.len > 0 and stack.len > 0 and stack[^1].cell != nil:
      stack[^1].cell.text.add htmlUnescape(data)
    data = ""
  proc start(tag, attrs: string) =
    if tag == "table":
      stack.add Tab()
    elif stack.len == 0: return
    elif tag == "tr":
      stack[^1].rows.add @[]; stack[^1].hasRow = true
    elif tag in ["td", "th"]:
      if not stack[^1].hasRow:
        stack[^1].rows.add @[]; stack[^1].hasRow = true
      stack[^1].cell = Cell(rs: span(attrs, "rowspan"), cs: span(attrs, "colspan"))
      stack[^1].rows[^1].add stack[^1].cell
    elif tag == "br" and stack[^1].cell != nil:
      stack[^1].cell.text.add " / "
  proc stop(tag: string) =
    if tag == "table" and stack.len > 0:
      closed.add stack.pop.rows
    elif tag in ["td", "th"] and stack.len > 0:
      stack[^1].cell = nil
  let lower = html.toLowerAscii
  var i = 0
  while i < html.len:
    if html[i] != '<':
      data.add html[i]; inc i; continue
    if html.continuesWith("<!--", i):
      flush()
      let e = html.search(rx"--!?>", i + 4)
      i = if e.ok: e.stop else: html.len
    elif i + 1 < html.len and html[i + 1] in {'!', '?'}:
      flush()
      let e = html.find('>', i)
      i = if e < 0: html.len else: e + 1
    elif i + 1 < html.len and html[i + 1] == '/' and i + 2 < html.len and html[i + 2].isAlphaAscii:
      flush()
      let e = html.find('>', i)
      let name = html.sl(i + 2, e).search(rx"^[a-zA-Z][^\t\n\r\f />]*").group.toLowerAscii
      stop(name)
      i = if e < 0: html.len else: e + 1
    elif i + 1 < html.len and html[i + 1].isAlphaAscii:
      flush()
      let e = tagEnd(html, i)
      if e < 0: data.add html[i ..< html.len]; break
      let inner = html[i + 1 ..< e]
      let name = inner.search(rx"^[a-zA-Z][^\t\n\r\f />]*").group.toLowerAscii
      let attrs = inner[name.len .. ^1]
      start(name, attrs)
      if attrs.endsWith("/"): stop(name)
      i = e + 1
      if name in rawText and not attrs.endsWith("/"):
        let close = lower.find("</" & name, i)
        let j = if close < 0: html.len else: close
        if name in ["textarea", "title"]: data.add html[i ..< j] else: discard
        flush()
        i = j
    else:
      data.add '<'; inc i
  flush()
  closed

proc expand(rows: seq[seq[Cell]]): seq[seq[string]] =
  ## Rows of texts, each spanning cell copied into every row and column it covers.
  var pending: OrderedTable[(int, int), string]
  for r in rows:
    var line: seq[string]
    var c = 0
    var cells = r
    proc pendingRow(at: int): bool =
      for k in pending.keys:
        if k[0] == at: return true
    while cells.len > 0 or pendingRow(result.len):
      if pending.hasKey((result.len, c)):
        line.add pending[(result.len, c)]; pending.del((result.len, c)); inc c; continue
      if cells.len == 0:
        var later = false
        for k in pending.keys:
          if k[0] == result.len and k[1] > c: later = true
        if later:
          line.add ""; inc c; continue
        break
      let cell = cells[0]
      cells.delete(0)
      let txt = cell.text.split(" / ").mapIt(it.sub(spaces, " ").pyStrip).filterIt(it.len > 0).join(" / ")
      for j in 0 ..< cell.cs:
        for i in 1 ..< cell.rs:
          pending[(result.len + i, c + j)] = txt
        line.add txt
      c += cell.cs
    result.add line

proc tables*(path: string): seq[seq[seq[string]]] =
  ## The tables of an HTML file (UTF-8, or Windows-1252 when it is not), expanded.
  let raw = readFile(path)
  let txt = if raw.utf8Replace == raw: raw else: raw.fromCp1252
  for t in parse(txt): result.add expand(t)

when isMainModule:
  let minCols = if paramCount() > 1: parseInt(paramStr(2)) else: 3
  for i, g in tables(paramStr(1)):
    if g.mapIt(it.len).foldl(max(a, b), 0) >= minCols:
      echo "### table ", i
      for r in g: echo r.join("\t")
