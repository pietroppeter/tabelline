## PowerPoint output, an experiment: a tabelline table as a native PowerPoint table.
##
## A .pptx file is a zip of XML files (Office Open XML). A slide holds shapes; a table is a
## `graphicFrame` holding an `a:tbl` (DrawingML), with a grid of column widths and rows of cells,
## each cell with its text runs (font, size, colour, bold), its fill and its four borders. This
## module turns a `Built` table (the step every renderer shares) into that XML, and writes a
## one-slide .pptx with nothing but the standard library: the zip is written by hand, stored
## (not compressed), which every reader accepts.
##
## What maps cleanly: the parts of the table (title, subtitle, spanners, stubhead, column labels,
## row groups, stub, body, footnotes, source notes) as rows and merged cells; the formatted text
## of every cell; alignment; the table options that are colours, sizes, weights and rules; the
## styles of `tabStyle` and `dataColor` that are fill, text colour, size, weight, italic,
## underline, strike and borders. What is lost or approximated is listed in `tools/pptx/README.md`.
##
## ```nim
## import tabelline, tabelline/pptx
## let t = tabella(planets(), rownameCol = "planet"):
##   tabHeader "The planets", "of the Solar System"
## t.savePptx "planets.pptx"
## echo t.toPptxTable     # the <a:graphicFrame> alone, to put in a slide of your own
## ```

import std/[strutils, sequtils, tables, math, times, unicode]
import core, formats, build, colors

# --------------------------------------------------------------------------------- CSS, resolved

type
  PptxColor* = object
    ## A colour as DrawingML wants it: six hex digits and an alpha (100000 is opaque).
    hex*: string
    alpha*: int
    none*: bool      ## transparent: no fill or no line

  PptxOptions* = object
    ## How CSS that only a page can resolve becomes a value: `vars` gives the page's CSS
    ## variables (`{"--ink": "#1C1C1C"}`); a variable not given takes its fallback. The slide is
    ## 16:9 (`slideWidth` x `slideHeight`, in points); a table wider than the slide is scaled.
    vars*: Table[string, string]
    slideWidth* = 960.0
    slideHeight* = 540.0
    margin* = 24.0

func noColor(): PptxColor = PptxColor(none: true)

proc resolveVars(css: string, o: PptxOptions): string =
  ## `var(--x, fallback)` becomes the value of `--x` in `o.vars`, or its fallback.
  result = css
  var guard = 0
  while "var(" in result and guard < 20:
    inc guard
    let a = result.find("var(")
    var depth = 0
    var b = a + 3
    while b < result.len:
      if result[b] == '(': inc depth
      elif result[b] == ')':
        dec depth
        if depth == 0: break
      inc b
    let inner = result[a + 4 ..< b]
    var name, fallback: string
    var d = 0
    var cut = -1
    for k, ch in inner:
      if ch == '(': inc d
      elif ch == ')': dec d
      elif ch == ',' and d == 0:
        cut = k
        break
    if cut < 0: name = inner.strip
    else: (name = inner[0 ..< cut].strip; fallback = inner[cut + 1 .. ^1].strip)
    let value = o.vars.getOrDefault(name, fallback)
    result = result[0 ..< a] & value & result[b + 1 .. ^1]

proc splitTop(s: string, sep: char): seq[string] =
  ## `s` split on `sep` outside parentheses.
  var d = 0
  var cur = ""
  for ch in s:
    if ch == '(': inc d
    elif ch == ')': dec d
    if ch == sep and d == 0:
      result.add cur.strip
      cur = ""
    else: cur.add ch
  if cur.strip.len > 0: result.add cur.strip

proc toColor*(css: string, o = PptxOptions()): PptxColor =
  ## A CSS colour as DrawingML: `#rgb`, `#rrggbb`, a few names, `rgb()`/`rgba()`, `transparent`,
  ## `var()` (see `PptxOptions`) and `color-mix()` (mixed in sRGB, not in the space it names).
  let c = css.resolveVars(o).strip.toLowerAscii
  if c.len == 0 or c in ["transparent", "none", "initial", "inherit", "currentcolor"]:
    return noColor()
  if c.startsWith("rgb"):
    let parts = c[c.find('(') + 1 ..< c.rfind(')')].replace("/", ",").split({',', ' '}).filterIt(it.len > 0)
    if parts.len < 3: return noColor()
    let rgb = (parseFloat(parts[0]), parseFloat(parts[1]), parseFloat(parts[2]))
    let alpha = if parts.len > 3: parseFloat(parts[3].strip(chars = {'%'})) else: 1.0
    return PptxColor(hex: toHex(rgb)[1 .. ^1], alpha: int(round(alpha * 100000)))
  if c.startsWith("color-mix("):
    # color-mix(in <space>, A p%, B [q%])
    let args = c["color-mix(".len ..< c.rfind(')')].splitTop(',')
    if args.len < 3: return noColor()
    proc part(s: string): (PptxColor, float) =
      let words = s.splitTop(' ')
      var p = NaN
      var col = s
      if words.len > 1 and words[^1].endsWith("%"):
        p = parseFloat(words[^1][0 ..< ^1]) / 100
        col = words[0 ..< ^1].join(" ")
      (toColor(col, o), p)
    let (a, pa) = part(args[1])
    let (b, pb) = part(args[2])
    if a.none or b.none: return (if a.none: b else: a)
    let wa = if not pa.isNaN: pa elif not pb.isNaN: 1 - pb else: 0.5
    let m = mix(parseColor("#" & b.hex), parseColor("#" & a.hex), wa)
    return PptxColor(hex: toHex(m)[1 .. ^1], alpha: 100000)
  try:
    PptxColor(hex: toHex(parseColor(c))[1 .. ^1], alpha: 100000)
  except ValueError:
    noColor()

func toPoints*(css: string, base: float): float =
  ## A CSS length or font size in points: px (3/4 pt), pt, em and % of `base`, a few keywords.
  let s = css.strip.toLowerAscii
  try:
    if s.endsWith("px"): parseFloat(s[0 ..< ^2]) * 0.75
    elif s.endsWith("pt"): parseFloat(s[0 ..< ^2])
    elif s.endsWith("em"): parseFloat(s[0 ..< ^2]) * base
    elif s.endsWith("%"): parseFloat(s[0 ..< ^1]) / 100 * base
    elif s == "small": base * 0.83
    elif s == "smaller": base * 0.83
    elif s == "large" or s == "larger": base * 1.2
    elif s == "x-large": base * 1.5
    else: parseFloat(s)
  except ValueError: base

const emuPerPt = 12700

# ---------------------------------------------------------------------------- the cell model

type
  Line = object
    width: float     ## points, 0 for none
    color: PptxColor
    dash: string     ## "" solid, "dash", "sysDot"
  Look = object
    ## Everything a cell can show, after the table options and then its styles.
    size: float      ## points
    color: PptxColor
    fill: PptxColor
    bold, italic, underline, strike: bool
    font: string
    align: string    ## "l", "ctr", "r"
    anchor: string   ## "t", "ctr", "b"
    upper: bool
    padV, padH: float
    lines: array[4, Line]   ## left, right, top, bottom
  Cell = object
    text: string     ## inline HTML, as the HTML renderer has it
    mark: string     ## footnote marks, raised, after the text
    lead: string     ## a footnote's own mark, raised, before the text
    look: Look
    span, rowSpan: int
    hMerge, vMerge: bool

func isBold(w: string): bool =
  let s = w.strip.toLowerAscii
  s in ["bold", "bolder"] or (s.len > 0 and s[0].isDigit and parseInt(s) >= 600)

proc parseLine(css: string, o: PptxOptions, base: float): Line =
  ## `1px solid #333` (any order) as a line.
  for w in css.resolveVars(o).splitTop(' '):
    let x = w.toLowerAscii
    if x in ["solid", "double"]: discard
    elif x == "dashed": result.dash = "dash"
    elif x == "dotted": result.dash = "sysDot"
    elif x in ["none", "hidden"]: return Line()
    elif x.len > 0 and (x[0].isDigit or x[0] == '.'): result.width = toPoints(x, base)
    elif x in ["thin"]: result.width = 0.75
    elif x in ["medium"]: result.width = 2.25
    elif x in ["thick"]: result.width = 3.75
    else: result.color = toColor(x, o)
  if result.color.none: result.width = 0

proc firstFont(names: string): string =
  ## The first font a slide can use from a CSS font list ("" for the theme's font).
  for f in names.splitTop(','):
    let n = f.strip(chars = {' ', '\'', '"'})
    if n.toLowerAscii in ["system-ui", "-apple-system", "blinkmacsystemfont", "ui-sans-serif",
                          "sans-serif", "serif", "monospace", "ui-monospace", "inherit", "initial"]:
      continue
    if n.startsWith("var("): continue
    return n
  ""

proc applyCss(l: var Look, css: string, o: PptxOptions, base: float) =
  ## The declarations of a style (a cell's or a part's) on top of a look.
  for d in css.split(';'):
    let kv = d.split(':', 1)
    if kv.len < 2: continue
    let k = kv[0].strip.toLowerAscii
    let v = kv[1].strip
    case k
    of "color": l.color = toColor(v, o)
    of "background-color", "background": l.fill = toColor(v, o)
    of "font-size": l.size = toPoints(v.resolveVars(o), base)
    of "font-weight": l.bold = isBold(v)
    of "font-style": l.italic = v.toLowerAscii in ["italic", "oblique"]
    of "font-family":
      let f = firstFont(v.resolveVars(o))
      if f.len > 0: l.font = f
    of "text-decoration":
      l.underline = "underline" in v
      l.strike = "line-through" in v
    of "text-transform": l.upper = v.toLowerAscii == "uppercase"
    of "text-align":
      l.align = case v.toLowerAscii
                of "center": "ctr"
                of "right": "r"
                else: "l"
    of "vertical-align":
      l.anchor = case v.toLowerAscii
                 of "top": "t"
                 of "bottom": "b"
                 else: "ctr"
    of "border-left": l.lines[0] = parseLine(v, o, base)
    of "border-right": l.lines[1] = parseLine(v, o, base)
    of "border-top": l.lines[2] = parseLine(v, o, base)
    of "border-bottom": l.lines[3] = parseLine(v, o, base)
    of "border":
      for s in 0..3: l.lines[s] = parseLine(v, o, base)
    else: discard   # lost: letter-spacing, font-variant, white-space, indents, ...

func alignOf(a: Align): string =
  case a
  of alCenter: "ctr"
  of alRight: "r"
  else: "l"

# ------------------------------------------------------------------------- inline HTML, as runs

type Run = object
  ## A piece of text with one look, from the inline HTML of a cell or a label.
  text: string
  bold, italic, sup, sub, code: bool
  color: string

func entity(s: string): string =
  case s
  of "amp": "&"
  of "lt": "<"
  of "gt": ">"
  of "quot": "\""
  of "apos", "#39": "'"
  of "nbsp": "\u00A0"
  of "minus": "\u2212"
  else:
    if s.startsWith("#x"): (try: $Rune(parseHexInt(s[2 .. ^1])) except ValueError: "&" & s & ";")
    elif s.startsWith("#"): (try: $Rune(parseInt(s[1 .. ^1])) except ValueError: "&" & s & ";")
    else: "&" & s & ";"

proc runs(html: string): seq[seq[Run]] =
  ## Paragraphs (split at `<br>`) of runs: `<b>`/`<strong>`, `<i>`/`<em>`, `<sup>`, `<sub>`,
  ## `<code>` and `<span style="color: ...">` are kept, other tags are dropped, their text kept.
  type Open = tuple[tag: string, color: string]
  var stack: seq[Open]
  var cur = Run()
  var para: seq[Run]
  proc look(): Run =
    for (tag, color) in stack:
      case tag
      of "b", "strong": result.bold = true
      of "i", "em": result.italic = true
      of "sup": result.sup = true
      of "sub": result.sub = true
      of "code": result.code = true
      else: discard
      if color.len > 0: result.color = color
  proc flush() =
    if cur.text.len > 0: para.add cur
    cur = look()
  var i = 0
  cur = look()
  while i < html.len:
    let ch = html[i]
    if ch == '<':
      let j = html.find('>', i)
      if j < 0: (cur.text.add html[i .. ^1]; break)
      let inside = html[i + 1 ..< j].strip
      let closing = inside.startsWith("/")
      let name = inside.strip(chars = {'/'}).split({' ', '\t'})[0].toLowerAscii
      flush()
      if name == "br":
        result.add para
        para = @[]
      elif closing:
        for k in countdown(stack.high, 0):
          if stack[k].tag == name:
            stack.delete(k)
            break
      elif not inside.endsWith("/"):
        var color = ""
        let st = inside.find("color:")
        if name == "span" and st >= 0:
          var e = st + 6
          while e < inside.len and inside[e] notin {';', '"', '\''}: inc e
          color = inside[st + 6 ..< e].strip
        stack.add (name, color)
      cur = look()
      i = j + 1
    elif ch == '&':
      let j = html.find(';', i)
      if j > i and j - i < 10:
        cur.text.add entity(html[i + 1 ..< j])
        i = j + 1
      else:
        cur.text.add ch
        inc i
    elif ch == '\n':
      flush()
      result.add para
      para = @[]
      inc i
    else:
      cur.text.add ch
      inc i
  flush()
  result.add para

proc plainLines(html: string): seq[string] =
  for p in html.runs: result.add p.mapIt(it.text).join

# ------------------------------------------------------------------------------- the grid

func runeLenSafe(s: string): int =
  ## Characters, not bytes, so "€" and "†" count once.
  for ch in s:
    if (ord(ch) and 0xC0) != 0x80: inc result


proc grid(t: Tabella, b: Built, o: PptxOptions): (seq[seq[Cell]], seq[float]) =
  ## The table as rows of cells, with merged cells marked, and the column widths in points.
  let m = t.options
  let base = toPoints(m.tableFontSize, 12)
  let hasStub = t.hasStub
  let ncols = b.columns.len + (if hasStub: 1 else: 0)
  var root = Look(size: base, color: toColor(m.tableFontColor, o), fill: toColor(m.tableBackgroundColor, o),
                  font: firstFont(m.tableFontNames.resolveVars(o)), align: "l", anchor: "ctr",
                  padV: toPoints(m.dataRowPadding, base), padH: toPoints(m.dataRowPaddingHorizontal, base))
  let hline = Line(width: 0.75, color: toColor(m.tableBodyHlinesColor, o))
  let vline = if m.tableBodyVlinesColor.len == 0: Line()
              else: Line(width: 0.75, color: toColor(m.tableBodyVlinesColor, o))
  proc heavy(c: string, w = "2px"): Line =
    result = Line(width: toPoints(w, base), color: toColor(c, o))
    if result.color.none: result.width = 0
  proc styled(look: Look, key: string): Look =
    result = look
    let css = b.styles.getOrDefault(key)
    if css.len > 0: result.applyCss(css, o, base)
  proc marks(key: string): string =
    let ms = b.marks.getOrDefault(key)
    if ms.len == 0: "" else: wrapMark(ms.mapIt(markText(it, m)).join(","), m.footnotesSpecRef)
  proc full(text: string, look: Look, key = ""): seq[Cell] =
    result.add Cell(text: text, mark: marks(key), look: look, span: ncols, rowSpan: 1)
    for k in 1 ..< ncols: result.add Cell(hMerge: true, look: look)
  var rows: seq[seq[Cell]]

  # the heading
  let headingFill = if m.headingBackgroundColor.len > 0: toColor(m.headingBackgroundColor, o) else: root.fill
  let headingColor = if m.headingBackgroundColor.len == 7 and idealTextColor(m.headingBackgroundColor) == "#FFFFFF":
                       toColor("#FFFFFF") else: root.color
  var heading = root
  heading.fill = headingFill
  heading.color = headingColor
  heading.align = (case m.headingAlign
                   of "left": "l"
                   of "right": "r"
                   else: "ctr")
  heading.padV = toPoints(m.headingPadding, base)
  heading.padH = toPoints(m.headingPaddingHorizontal, base)
  if not t.title.isEmpty:
    var l = heading
    l.size = toPoints(m.headingTitleFontSize, base)
    l.bold = isBold(m.headingTitleFontWeight)
    rows.add full(t.title.renderText(rcHtml), l.styled("title"), "title")
    if not t.subtitle.isEmpty:
      var s = heading
      s.size = toPoints(m.headingSubtitleFontSize, base)
      s.bold = isBold(m.headingSubtitleFontWeight)
      s.padV = 0
      rows.add full(t.subtitle.renderText(rcHtml), s.styled("subtitle"), "subtitle")
    for c in rows[^1].mitems: c.look.lines[3] = heavy(m.headingBorderBottomColor)

  # the column labels, under the spanners
  var label = root
  if m.columnLabelsBackgroundColor.len > 0:
    label.fill = toColor(m.columnLabelsBackgroundColor, o)
    if m.columnLabelsBackgroundColor.len == 7 and idealTextColor(m.columnLabelsBackgroundColor) == "#FFFFFF":
      label.color = toColor("#FFFFFF")
  label.size = toPoints(m.columnLabelsFontSize, base)
  label.bold = isBold(m.columnLabelsFontWeight)
  label.upper = m.columnLabelsTextTransform == "uppercase"
  label.anchor = "b"
  label.padV = toPoints(m.columnLabelsPadding, base)
  label.padH = toPoints(m.columnLabelsPaddingHorizontal, base)
  let levels = t.spannerLevels(b.columns)
  let headerStart = rows.len
  for lv in countdown(levels, 1):
    var row: seq[Cell]
    if hasStub:
      if lv == levels:
        row.add Cell(text: t.stubhead.renderText(rcHtml), mark: marks("stubhead"),
                     look: label.styled("stubhead"), span: 1, rowSpan: levels + 1)
      else: row.add Cell(vMerge: true, look: label)
    var j = 0
    while j < b.columns.len:
      let k = t.spannerAt(b.columns[j].name, lv)
      var span = 1
      while j + span < b.columns.len and t.spannerAt(b.columns[j + span].name, lv) == k: inc span
      if k >= 0:
        let s = t.spanners[k]
        var l = label.styled(spannerKey(s.label.s))
        l.align = "ctr"
        l.lines[3] = heavy(m.columnLabelsBorderBottomColor)
        row.add Cell(text: s.label.renderText(rcHtml), mark: marks(spannerKey(s.label.s)), look: l,
                     span: span, rowSpan: 1)
        for q in 1 ..< span: row.add Cell(hMerge: true, look: l)
      else:
        # columns without a spanner at this level: their label spans down from the top level
        for q in 0 ..< span:
          let c = b.columns[j + q]
          var hasAny = false
          for l2 in 1 .. levels:
            if t.spannerAt(c.name, l2) >= 0: hasAny = true
          if not hasAny and lv == levels:
            var l = label.styled(colKey(c.name))
            l.align = alignOf(c.align)
            row.add Cell(text: c.label.renderText(rcHtml), mark: marks(colKey(c.name)), look: l,
                         span: 1, rowSpan: levels + 1)
          elif not hasAny: row.add Cell(vMerge: true, look: label)
          else: row.add Cell(text: "", look: label, span: 1, rowSpan: 1)
      j += span
    rows.add row
  block:
    var row: seq[Cell]
    if hasStub:
      if levels == 0:
        row.add Cell(text: t.stubhead.renderText(rcHtml), mark: marks("stubhead"),
                     look: label.styled("stubhead"), span: 1, rowSpan: 1)
      else: row.add Cell(vMerge: true, look: label)
    for c in b.columns:
      var hasAny = false
      for l2 in 1 .. levels:
        if t.spannerAt(c.name, l2) >= 0: hasAny = true
      if levels > 0 and not hasAny: row.add Cell(vMerge: true, look: label)
      else:
        var l = label.styled(colKey(c.name))
        l.align = alignOf(c.align)
        row.add Cell(text: c.label.renderText(rcHtml), mark: marks(colKey(c.name)), look: l, span: 1, rowSpan: 1)
    rows.add row
  # the rule under the column labels runs under every cell of the last header row
  let labelRule = heavy(m.columnLabelsBorderBottomColor, m.columnLabelsBorderBottomWidth)
  for c in rows[^1].mitems: c.look.lines[3] = labelRule
  for r in headerStart ..< rows.len:     # cells that span down keep the rule at their bottom
    for k, c in rows[r]:
      if c.rowSpan > 1: rows[r][k].look.lines[3] = labelRule

  # the body, group by group
  var group = root
  if m.rowGroupBackgroundColor.len > 0: group.fill = toColor(m.rowGroupBackgroundColor, o)
  group.bold = isBold(m.rowGroupFontWeight)
  group.lines[2] = heavy(m.rowGroupBorderColor)
  group.lines[3] = heavy(m.rowGroupBorderColor)
  let stripe = toColor(m.rowStripingBackgroundColor, o)
  var firstBody = true
  for g in b.groups:
    if g.id.len > 0:
      rows.add full(g.label, group.styled(groupKey(g.id)), groupKey(g.id))
      firstBody = true
    var striped = false
    for r in g.rows:
      var row: seq[Cell]
      var cellLook = root
      if not firstBody: cellLook.lines[2] = hline
      cellLook.lines[0] = vline
      cellLook.lines[1] = vline
      if m.rowStriping and striped and not stripe.none: cellLook.fill = stripe
      if hasStub:
        var l = cellLook
        if m.stubBackgroundColor.len > 0: l.fill = toColor(m.stubBackgroundColor, o)
        l.bold = isBold(m.stubFontWeight)
        l.lines[1] = heavy(m.tableBodyHlinesColor)
        let k = cellKey(r.index, t.rownameCol)
        row.add Cell(text: r.stub, mark: marks(k), look: l.styled(k), span: 1, rowSpan: 1)
      for j, c in b.columns:
        var l = cellLook
        l.align = alignOf(c.align)
        let k = cellKey(r.index, c.name)
        row.add Cell(text: r.cells[j], mark: marks(k), look: l.styled(k), span: 1, rowSpan: 1)
      rows.add row
      striped = not striped
      firstBody = false

  # the footer
  var foot = root
  foot.padV = 3
  for (k, n) in b.footer:
    var l = foot
    l.size = toPoints(m.footnotesFontSize, base)
    let mark = if k > 0: wrapMark(markText(k, m), m.footnotesSpecFtr) else: ""
    var cs = full(n, l.styled("footnotes"))
    cs[0].lead = mark
    rows.add cs
  for n in t.sourceNotes:
    var l = foot
    l.size = toPoints(m.sourceNotesFontSize, base)
    rows.add full(n.renderText(rcHtml), l.styled("source_notes"))

  # the rules around the whole table
  for c in rows[0].mitems: c.look.lines[2] = heavy(m.tableBorderTopColor, m.tableBorderTopWidth)
  if m.tableBorderBottomStyle != "none":
    for c in rows[^1].mitems: c.look.lines[3] = heavy(m.tableBorderBottomColor, m.tableBorderBottomWidth)
  if m.tableBorderLeftStyle != "none":
    for r in rows.mitems: r[0].look.lines[0] = heavy(m.tableBorderLeftColor, m.tableBorderLeftWidth)
  if m.tableBorderRightStyle != "none":
    for r in rows.mitems: r[^1].look.lines[1] = heavy(m.tableBorderRightColor, m.tableBorderRightWidth)

  # widths: from the longest text of each column (a cell spanning many columns does not count),
  # or the width the column asks for
  var widths = newSeq[float](ncols)
  for r in rows:
    for k, c in r:
      if c.span == 1 and not c.hMerge and not c.vMerge:
        var longest = 0
        for line in c.text.plainLines: longest = max(longest, line.runeLenSafe)
        # an average glyph is about 0.6 of the size (0.65 in bold); a little slack, as renderers differ
        let w = float(longest + c.mark.len + c.lead.len) * c.look.size * (if c.look.bold: 0.65 else: 0.6) +
                2 * c.look.padH + 4
        widths[k] = max(widths[k], w)
  for j, c in b.columns:
    let k = j + (if hasStub: 1 else: 0)
    if c.width.endsWith("px"): widths[k] = toPoints(c.width, base)
  (rows, widths)

# ------------------------------------------------------------------------------- DrawingML

func xmlEsc(s: string): string =
  s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"), ("\"", "&quot;"))

func emu(pt: float): int = int(round(pt * emuPerPt))

func colorXml(c: PptxColor): string =
  if c.none: "<a:noFill/>"
  elif c.alpha >= 100000: "<a:solidFill><a:srgbClr val=\"" & c.hex & "\"/></a:solidFill>"
  else: "<a:solidFill><a:srgbClr val=\"" & c.hex & "\"><a:alpha val=\"" & $c.alpha & "\"/></a:srgbClr></a:solidFill>"

func lineXml(tag: string, l: Line): string =
  if l.width <= 0 or l.color.none:
    "<a:" & tag & " w=\"0\"><a:noFill/></a:" & tag & ">"
  else:
    "<a:" & tag & " w=\"" & $emu(l.width) & "\" cmpd=\"sng\">" & colorXml(l.color) &
      (if l.dash.len > 0: "<a:prstDash val=\"" & l.dash & "\"/>" else: "<a:prstDash val=\"solid\"/>") &
      "</a:" & tag & ">"

func runProps(l: Look, raised = false, lowered = false, scale = 1.0): string =
  result = "<a:rPr lang=\"en-US\" sz=\"" & $int(round(l.size * scale * 100)) & "\"" &
    (if l.bold: " b=\"1\"" else: " b=\"0\"") & (if l.italic: " i=\"1\"" else: "") &
    (if l.underline: " u=\"sng\"" else: "") & (if l.strike: " strike=\"sngStrike\"" else: "") &
    (if raised: " baseline=\"30000\"" elif lowered: " baseline=\"-25000\"" else: "") & " dirty=\"0\">" & colorXml(l.color)
  if l.font.len > 0:
    result.add "<a:latin typeface=\"" & xmlEsc(l.font) & "\"/><a:cs typeface=\"" & xmlEsc(l.font) & "\"/>"
  result.add "</a:rPr>"

proc cellXml(c: Cell): string =
  let l = c.look
  var attrs = ""
  if c.span > 1: attrs.add " gridSpan=\"" & $c.span & "\""
  if c.rowSpan > 1: attrs.add " rowSpan=\"" & $c.rowSpan & "\""
  if c.hMerge: attrs.add " hMerge=\"1\""
  if c.vMerge: attrs.add " vMerge=\"1\""
  result = "<a:tc" & attrs & "><a:txBody><a:bodyPr/><a:lstStyle/>"
  # a line break in a cell is a new paragraph
  let paras = if c.hMerge or c.vMerge: @[newSeq[Run]()] else: c.text.runs
  for k, p in paras:
    result.add "<a:p><a:pPr algn=\"" & l.align & "\"/>"
    if k == 0 and c.lead.len > 0:
      result.add "<a:r>" & runProps(l, raised = true) & "<a:t>" & xmlEsc(c.lead) & "</a:t></a:r>" &
                 "<a:r>" & runProps(l) & "<a:t> </a:t></a:r>"
    for r in p:
      var rl = l
      rl.bold = l.bold or r.bold
      rl.italic = l.italic or r.italic
      if r.color.len > 0: rl.color = toColor(r.color)
      if r.code: rl.font = "Menlo"
      let txt = if l.upper: r.text.toUpperAscii else: r.text
      result.add "<a:r>" & runProps(rl, raised = r.sup, lowered = r.sub) & "<a:t>" & xmlEsc(txt) & "</a:t></a:r>"
    if k == paras.high and c.mark.len > 0:
      result.add "<a:r>" & runProps(l, raised = true) & "<a:t>" & xmlEsc(c.mark) & "</a:t></a:r>"
    result.add "<a:endParaRPr lang=\"en-US\" sz=\"" & $int(round(l.size * 100)) & "\" dirty=\"0\"/></a:p>"
  result.add "</a:txBody><a:tcPr marL=\"" & $emu(l.padH) & "\" marR=\"" & $emu(l.padH) &
    "\" marT=\"" & $emu(l.padV) & "\" marB=\"" & $emu(l.padV) & "\" anchor=\"" & l.anchor & "\">"
  result.add lineXml("lnL", l.lines[0]) & lineXml("lnR", l.lines[1]) &
             lineXml("lnT", l.lines[2]) & lineXml("lnB", l.lines[3])
  result.add colorXml(l.fill) & "</a:tcPr></a:tc>"

proc tableXml(t: Tabella, o: PptxOptions, x, y: var float, w, h: var float): string =
  let b = t.build(rcHtml)
  var (rows, widths) = t.grid(b, o)
  # scale down to fit the slide: sizes, paddings, widths
  let room = o.slideWidth - 2 * o.margin
  let total = widths.foldl(a + b, 0.0)
  let k = if total > room: room / total else: 1.0
  if k < 1:
    for w in widths.mitems: w *= k
    for r in rows.mitems:
      for c in r.mitems:
        c.look.size *= k
        c.look.padH *= k
        c.look.padV *= k
        for s in 0..3: c.look.lines[s].width = max(c.look.lines[s].width * k, 0.5)
  w = widths.foldl(a + b, 0.0)
  var heights: seq[float]
  for r in rows:
    var hh = 0.0
    for c in r:
      if c.hMerge or c.vMerge: continue
      let lines = max(1, c.text.plainLines.len)
      hh = max(hh, float(lines) * c.look.size * 1.2 + 2 * c.look.padV)
    heights.add hh
  h = heights.foldl(a + b, 0.0)
  x = (o.slideWidth - w) / 2
  y = max(o.margin, (o.slideHeight - h) / 2)
  result = "<a:tbl><a:tblPr/><a:tblGrid>"
  for wd in widths: result.add "<a:gridCol w=\"" & $emu(wd) & "\"/>"
  result.add "</a:tblGrid>"
  for i, r in rows:
    result.add "<a:tr h=\"" & $emu(heights[i]) & "\">"
    for c in r: result.add cellXml(c)
    result.add "</a:tr>"
  result.add "</a:tbl>"

proc toPptxTable*(t: Tabella, o = PptxOptions(), id = 2): string =
  ## The table as a `<p:graphicFrame>`: a native PowerPoint table, placed in the middle of a
  ## 16:9 slide, ready to put in a slide's shape tree.
  var x, y, w, h: float
  let tbl = t.tableXml(o, x, y, w, h)
  let name = if t.title.isEmpty: "tabella" else: textToPlain(t.title)
  "<p:graphicFrame><p:nvGraphicFramePr><p:cNvPr id=\"" & $id & "\" name=\"" & xmlEsc(name) &
    "\"/><p:cNvGraphicFramePr><a:graphicFrameLocks noGrp=\"1\"/></p:cNvGraphicFramePr><p:nvPr/></p:nvGraphicFramePr>" &
    "<p:xfrm><a:off x=\"" & $emu(x) & "\" y=\"" & $emu(y) & "\"/><a:ext cx=\"" & $emu(w) & "\" cy=\"" & $emu(h) &
    "\"/></p:xfrm><a:graphic><a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">" &
    tbl & "</a:graphicData></a:graphic></p:graphicFrame>"

# ---------------------------------------------------------------------- for the clipboard

func cssColor(c: PptxColor): string =
  if c.none: "transparent"
  elif c.alpha >= 100000: "#" & c.hex
  else:
    let rgb = parseColor("#" & c.hex)
    "rgba(" & $int(rgb.r) & "," & $int(rgb.g) & "," & $int(rgb.b) & "," & formatFloat(c.alpha / 100000, ffDecimal, 2) & ")"

func cssLine(l: Line): string =
  if l.width <= 0 or l.color.none: "none"
  else: formatFloat(l.width, ffDecimal, 2) & "pt " & (if l.dash == "dash": "dashed" elif l.dash == "sysDot": "dotted" else: "solid") &
        " " & cssColor(l.color)

proc toClipboardHtml*(t: Tabella, o = PptxOptions()): string =
  ## The table as HTML with every style inline on its cells (no `<style>`, no classes, no CSS
  ## variables), the form Office reads when HTML is pasted: put it on the clipboard as HTML
  ## (`text/html`, `public.html` on macOS, `CF_HTML` on Windows) and PowerPoint, Word, Keynote or
  ## Google Slides paste it as a table of their own. It comes from the same cells as the .pptx.
  let b = t.build(rcHtml)
  let (rows, widths) = t.grid(b, o)
  result = "<table style=\"border-collapse:collapse\">\n"
  result.add "<colgroup>" & widths.mapIt("<col style=\"width:" & formatFloat(it, ffDecimal, 1) & "pt\">").join & "</colgroup>\n"
  for r in rows:
    result.add "<tr>"
    for c in r:
      if c.hMerge or c.vMerge: continue
      let l = c.look
      let tag = "td"
      var css = @["font-size:" & formatFloat(l.size, ffDecimal, 1) & "pt", "color:" & cssColor(l.color),
                  "background:" & cssColor(l.fill),
                  "text-align:" & (case l.align
                                   of "ctr": "center"
                                   of "r": "right"
                                   else: "left"),
                  "vertical-align:" & (case l.anchor
                                       of "t": "top"
                                       of "b": "bottom"
                                       else: "middle"),
                  "padding:" & formatFloat(l.padV, ffDecimal, 1) & "pt " & formatFloat(l.padH, ffDecimal, 1) & "pt",
                  "border-left:" & cssLine(l.lines[0]), "border-right:" & cssLine(l.lines[1]),
                  "border-top:" & cssLine(l.lines[2]), "border-bottom:" & cssLine(l.lines[3])]
      if l.bold: css.add "font-weight:bold"
      if l.italic: css.add "font-style:italic"
      if l.underline: css.add "text-decoration:underline"
      if l.strike: css.add "text-decoration:line-through"
      if l.upper: css.add "text-transform:uppercase"
      if l.font.len > 0: css.add "font-family:'" & l.font & "'"
      let spans = (if c.span > 1: " colspan=\"" & $c.span & "\"" else: "") &
                  (if c.rowSpan > 1: " rowspan=\"" & $c.rowSpan & "\"" else: "")
      let lead = if c.lead.len > 0: "<sup>" & escapeHtml(c.lead) & "</sup> " else: ""
      let mark = if c.mark.len > 0: "<sup>" & escapeHtml(c.mark) & "</sup>" else: ""
      result.add "<" & tag & spans & " style=\"" & css.join(";").replace("\"", "'") & "\">" & lead & c.text & mark & "</" & tag & ">"
    result.add "</tr>\n"
  result.add "</table>\n"

# ------------------------------------------------------------------------------- the zip

var crcTable: array[256, uint32]
for n in 0 ..< 256:
  var c = uint32(n)
  for k in 0 ..< 8:
    c = if (c and 1) != 0: 0xEDB88320'u32 xor (c shr 1) else: c shr 1
  crcTable[n] = c

proc crc32*(s: string): uint32 =
  result = 0xFFFFFFFF'u32
  for ch in s: result = crcTable[(result xor uint32(ord(ch))) and 0xFF] xor (result shr 8)
  result = result xor 0xFFFFFFFF'u32

proc le(s: var string, v: uint32, n: int) =
  for k in 0 ..< n: s.add chr(int((v shr (8 * k)) and 0xFF))

proc zipStored*(files: openArray[(string, string)]): string =
  ## A zip archive of `files` (name, content), stored without compression: the format is the
  ## same, so any reader opens it, and it needs nothing but these sixty lines.
  var central = ""
  for (name, data) in files:
    let offset = uint32(result.len)
    let crc = crc32(data)
    result.le 0x04034b50'u32, 4
    result.le 20, 2                       # version needed
    result.le 0, 2                        # flags
    result.le 0, 2                        # stored
    result.le 0, 2                        # time
    result.le 0x21, 2                     # date: 1980-01-01
    result.le crc, 4
    result.le uint32(data.len), 4
    result.le uint32(data.len), 4
    result.le uint32(name.len), 2
    result.le 0, 2
    result.add name
    result.add data
    central.le 0x02014b50'u32, 4
    central.le 20, 2
    central.le 20, 2
    central.le 0, 2
    central.le 0, 2
    central.le 0, 2
    central.le 0x21, 2
    central.le crc, 4
    central.le uint32(data.len), 4
    central.le uint32(data.len), 4
    central.le uint32(name.len), 2
    central.le 0, 2                       # extra
    central.le 0, 2                       # comment
    central.le 0, 2                       # disk
    central.le 0, 2                       # internal attributes
    central.le 0, 4                       # external attributes
    central.le offset, 4
    central.add name
  let cdOffset = uint32(result.len)
  result.add central
  result.le 0x06054b50'u32, 4
  result.le 0, 2
  result.le 0, 2
  result.le uint32(files.len), 2
  result.le uint32(files.len), 2
  result.le uint32(central.len), 4
  result.le cdOffset, 4
  result.le 0, 2

# ------------------------------------------------------------------------------- the package

const
  nsA = "http://schemas.openxmlformats.org/drawingml/2006/main"
  nsR = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  nsP = "http://schemas.openxmlformats.org/presentationml/2006/main"
  relBase = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/"
  xmlHead = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n"
  nsAll = " xmlns:a=\"" & nsA & "\" xmlns:r=\"" & nsR & "\" xmlns:p=\"" & nsP & "\""

func rels(items: openArray[(string, string, string)]): string =
  result = xmlHead & "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
  for (id, kind, target) in items:
    let typ = if kind.startsWith("http"): kind else: relBase & kind
    result.add "<Relationship Id=\"" & id & "\" Type=\"" & typ & "\" Target=\"" & target & "\"/>"
  result.add "</Relationships>"

const emptyTree = "<p:nvGrpSpPr><p:cNvPr id=\"1\" name=\"\"/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr>" &
  "<p:grpSpPr><a:xfrm><a:off x=\"0\" y=\"0\"/><a:ext cx=\"0\" cy=\"0\"/><a:chOff x=\"0\" y=\"0\"/>" &
  "<a:chExt cx=\"0\" cy=\"0\"/></a:xfrm></p:grpSpPr>"

const themeXml = xmlHead & "<a:theme xmlns:a=\"" & nsA & "\" name=\"tabelline\"><a:themeElements>" &
  "<a:clrScheme name=\"tabelline\"><a:dk1><a:srgbClr val=\"1C1C1C\"/></a:dk1><a:lt1><a:srgbClr val=\"FFFFFF\"/></a:lt1>" &
  "<a:dk2><a:srgbClr val=\"333333\"/></a:dk2><a:lt2><a:srgbClr val=\"F2F2F2\"/></a:lt2>" &
  "<a:accent1><a:srgbClr val=\"004D80\"/></a:accent1><a:accent2><a:srgbClr val=\"D64545\"/></a:accent2>" &
  "<a:accent3><a:srgbClr val=\"1D5C2E\"/></a:accent3><a:accent4><a:srgbClr val=\"8C1D52\"/></a:accent4>" &
  "<a:accent5><a:srgbClr val=\"00666B\"/></a:accent5><a:accent6><a:srgbClr val=\"A8A8A8\"/></a:accent6>" &
  "<a:hlink><a:srgbClr val=\"004D80\"/></a:hlink><a:folHlink><a:srgbClr val=\"8C1D52\"/></a:folHlink></a:clrScheme>" &
  "<a:fontScheme name=\"tabelline\"><a:majorFont><a:latin typeface=\"Helvetica Neue\"/><a:ea typeface=\"\"/><a:cs typeface=\"\"/></a:majorFont>" &
  "<a:minorFont><a:latin typeface=\"Helvetica Neue\"/><a:ea typeface=\"\"/><a:cs typeface=\"\"/></a:minorFont></a:fontScheme>" &
  "<a:fmtScheme name=\"tabelline\"><a:fillStyleLst>" &
  "<a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill><a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill>" &
  "<a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill></a:fillStyleLst><a:lnStyleLst>" &
  "<a:ln w=\"6350\"><a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill></a:ln>" &
  "<a:ln w=\"12700\"><a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill></a:ln>" &
  "<a:ln w=\"19050\"><a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill></a:ln></a:lnStyleLst>" &
  "<a:effectStyleLst><a:effectStyle><a:effectLst/></a:effectStyle><a:effectStyle><a:effectLst/></a:effectStyle>" &
  "<a:effectStyle><a:effectLst/></a:effectStyle></a:effectStyleLst><a:bgFillStyleLst>" &
  "<a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill><a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill>" &
  "<a:solidFill><a:schemeClr val=\"phClr\"/></a:solidFill></a:bgFillStyleLst></a:fmtScheme></a:themeElements>" &
  "<a:objectDefaults/><a:extraClrSchemeLst/></a:theme>"

proc pptxFiles*(slides: openArray[string], o = PptxOptions()): seq[(string, string)] =
  ## The parts of a presentation whose slides hold the given shapes (`toPptxTable` gives one):
  ## one master, one blank layout, one theme.
  let cx = emu(o.slideWidth)
  let cy = emu(o.slideHeight)
  var types = xmlHead & "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" &
    "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>" &
    "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" &
    "<Override PartName=\"/ppt/presentation.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml\"/>" &
    "<Override PartName=\"/ppt/slideMasters/slideMaster1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.slideMaster+xml\"/>" &
    "<Override PartName=\"/ppt/slideLayouts/slideLayout1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.slideLayout+xml\"/>" &
    "<Override PartName=\"/ppt/theme/theme1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.theme+xml\"/>" &
    "<Override PartName=\"/ppt/presProps.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.presProps+xml\"/>" &
    "<Override PartName=\"/ppt/viewProps.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.viewProps+xml\"/>" &
    "<Override PartName=\"/ppt/tableStyles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.tableStyles+xml\"/>" &
    "<Override PartName=\"/docProps/core.xml\" ContentType=\"application/vnd.openxmlformats-package.core-properties+xml\"/>" &
    "<Override PartName=\"/docProps/app.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.extended-properties+xml\"/>"
  for k in 1 .. slides.len:
    types.add "<Override PartName=\"/ppt/slides/slide" & $k & ".xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.slide+xml\"/>"
  types.add "</Types>"
  result.add ("[Content_Types].xml", types)
  result.add ("_rels/.rels", rels([
    ("rId1", "officeDocument", "ppt/presentation.xml"),
    ("rId2", "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties", "docProps/core.xml"),
    ("rId3", "extended-properties", "docProps/app.xml")]))
  let now = now().utc.format("yyyy-MM-dd'T'HH:mm:ss'Z'")
  result.add ("docProps/core.xml", xmlHead & "<cp:coreProperties xmlns:cp=\"http://schemas.openxmlformats.org/package/2006/metadata/core-properties\" " &
    "xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" " &
    "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><dc:title>tabelline</dc:title><dc:creator>tabelline</dc:creator>" &
    "<dcterms:created xsi:type=\"dcterms:W3CDTF\">" & now & "</dcterms:created></cp:coreProperties>")
  result.add ("docProps/app.xml", xmlHead & "<Properties xmlns=\"http://schemas.openxmlformats.org/officeDocument/2006/extended-properties\">" &
    "<Application>tabelline</Application><Slides>" & $slides.len & "</Slides></Properties>")
  var presRels = @[("rId1", "slideMaster", "slideMasters/slideMaster1.xml"), ("rId2", "theme", "theme/theme1.xml"),
                   ("rId3", "presProps", "presProps.xml"), ("rId4", "viewProps", "viewProps.xml"),
                   ("rId5", "tableStyles", "tableStyles.xml")]
  var sldIds = ""
  for k in 1 .. slides.len:
    presRels.add ("rId" & $(10 + k), "slide", "slides/slide" & $k & ".xml")
    sldIds.add "<p:sldId id=\"" & $(255 + k) & "\" r:id=\"rId" & $(10 + k) & "\"/>"
  result.add ("ppt/presentation.xml", xmlHead & "<p:presentation" & nsAll & " saveSubsetFonts=\"1\">" &
    "<p:sldMasterIdLst><p:sldMasterId id=\"2147483648\" r:id=\"rId1\"/></p:sldMasterIdLst>" &
    "<p:sldIdLst>" & sldIds & "</p:sldIdLst><p:sldSz cx=\"" & $cx & "\" cy=\"" & $cy & "\"/>" &
    "<p:notesSz cx=\"6858000\" cy=\"9144000\"/><p:defaultTextStyle/></p:presentation>")
  result.add ("ppt/_rels/presentation.xml.rels", rels(presRels))
  result.add ("ppt/presProps.xml", xmlHead & "<p:presentationPr" & nsAll & "/>")
  result.add ("ppt/viewProps.xml", xmlHead & "<p:viewPr" & nsAll & "><p:normalViewPr/><p:slideViewPr><p:cSldViewPr>" &
    "<p:cViewPr><p:scale><a:sx n=\"100\" d=\"100\"/><a:sy n=\"100\" d=\"100\"/></p:scale><a:origin x=\"0\" y=\"0\"/></p:cViewPr>" &
    "</p:cSldViewPr></p:slideViewPr><p:gridSpacing cx=\"76200\" cy=\"76200\"/></p:viewPr>")
  result.add ("ppt/tableStyles.xml", xmlHead & "<a:tblStyleLst xmlns:a=\"" & nsA & "\" def=\"{5C22544A-7EE6-4342-B048-85BDC9FD1C3A}\"/>")
  result.add ("ppt/theme/theme1.xml", themeXml)
  result.add ("ppt/slideMasters/slideMaster1.xml", xmlHead & "<p:sldMaster" & nsAll & "><p:cSld><p:bg><p:bgRef idx=\"1001\">" &
    "<a:schemeClr val=\"bg1\"/></p:bgRef></p:bg><p:spTree>" & emptyTree & "</p:spTree></p:cSld>" &
    "<p:clrMap bg1=\"lt1\" tx1=\"dk1\" bg2=\"lt2\" tx2=\"dk2\" accent1=\"accent1\" accent2=\"accent2\" accent3=\"accent3\" " &
    "accent4=\"accent4\" accent5=\"accent5\" accent6=\"accent6\" hlink=\"hlink\" folHlink=\"folHlink\"/>" &
    "<p:sldLayoutIdLst><p:sldLayoutId id=\"2147483649\" r:id=\"rId1\"/></p:sldLayoutIdLst>" &
    "<p:txStyles><p:titleStyle/><p:bodyStyle/><p:otherStyle/></p:txStyles></p:sldMaster>")
  result.add ("ppt/slideMasters/_rels/slideMaster1.xml.rels", rels([
    ("rId1", "slideLayout", "../slideLayouts/slideLayout1.xml"), ("rId2", "theme", "../theme/theme1.xml")]))
  result.add ("ppt/slideLayouts/slideLayout1.xml", xmlHead & "<p:sldLayout" & nsAll & " type=\"blank\" preserve=\"1\">" &
    "<p:cSld name=\"Blank\"><p:spTree>" & emptyTree & "</p:spTree></p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sldLayout>")
  result.add ("ppt/slideLayouts/_rels/slideLayout1.xml.rels", rels([
    ("rId1", "slideMaster", "../slideMasters/slideMaster1.xml")]))
  for k, shapes in slides:
    result.add ("ppt/slides/slide" & $(k + 1) & ".xml", xmlHead & "<p:sld" & nsAll & "><p:cSld><p:spTree>" &
      emptyTree & shapes & "</p:spTree></p:cSld><p:clrMapOvr><a:masterClrMapping/></p:clrMapOvr></p:sld>")
    result.add ("ppt/slides/_rels/slide" & $(k + 1) & ".xml.rels", rels([
      ("rId1", "slideLayout", "../slideLayouts/slideLayout1.xml")]))

proc toPptx*(tables: openArray[Tabella], o = PptxOptions()): string =
  ## A presentation (the bytes of a .pptx) with one table per slide.
  zipStored(pptxFiles(tables.mapIt(it.toPptxTable(o)), o))

proc savePptx*(t: Tabella, path: string, o = PptxOptions()) =
  ## Writes the table as a one-slide PowerPoint file, as a native (editable) table.
  writeFile(path, toPptx([t], o))

proc savePptx*(tables: openArray[Tabella], path: string, o = PptxOptions()) =
  ## Writes a PowerPoint file with one table per slide.
  writeFile(path, toPptx(tables, o))
