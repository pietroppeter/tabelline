## PowerPoint output: a tabelline table as a native PowerPoint table, written with xoffy.
##
## The table goes through `build`, the step every renderer shares, then becomes a grid of cells:
## each part (title, subtitle, spanners, stubhead, column labels, row groups, stub, body,
## footnotes, source notes) is rows of cells, merged where a label spans, and each cell gets one
## *look*: first the table options (`tableFontSize`, `headingBackgroundColor`, ...), then the CSS of
## `tabStyle` and `dataColor` for its location. That grid becomes xoffy's `Grid` (DrawingML's
## `a:tbl`), and xoffy writes the slide, the package and the zip.
##
## What is lost or approximated (CSS variables, `color-mix`, fonts, widths) is listed in
## `tools/pptx/README.md`.
##
## ```nim
## import tabelline, tabelline/pptx
## let t = tabella(planets(), rownameCol = "planet"):
##   tabHeader "The planets", "of the Solar System"
## t.savePptx "planets.pptx"           # one slide, the table in the middle
## let g = t.toGrid                    # xoffy's Grid, to place on a slide of your own
## ```

import std/[strutils, sequtils, tables, math, unicode]
import core, formats, build, colors
import xoffy

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

func noPptxColor(): PptxColor = PptxColor(none: true)

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
    return noPptxColor()
  if c.startsWith("rgb"):
    let parts = c[c.find('(') + 1 ..< c.rfind(')')].replace("/", ",").split({',', ' '}).filterIt(it.len > 0)
    if parts.len < 3: return noPptxColor()
    let rgb = (parseFloat(parts[0]), parseFloat(parts[1]), parseFloat(parts[2]))
    let alpha = if parts.len > 3: parseFloat(parts[3].strip(chars = {'%'})) else: 1.0
    return PptxColor(hex: toHex(rgb)[1 .. ^1], alpha: int(round(alpha * 100000)))
  if c.startsWith("color-mix("):
    # color-mix(in <space>, A p%, B [q%])
    let args = c["color-mix(".len ..< c.rfind(')')].splitTop(',')
    if args.len < 3: return noPptxColor()
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
    noPptxColor()

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


# ---------------------------------------------------------------------------- the cell model

type
  CssLine = object
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
    lines: array[4, CssLine]   ## left, right, top, bottom
  TCell = object
    text: string     ## inline HTML, as the HTML renderer has it
    mark: string     ## footnote marks, raised, after the text
    lead: string     ## a footnote's own mark, raised, before the text
    look: Look
    span, rowSpan: int
    hMerge, vMerge: bool

func isBold(w: string): bool =
  let s = w.strip.toLowerAscii
  s in ["bold", "bolder"] or (s.len > 0 and s[0].isDigit and parseInt(s) >= 600)

proc parseLine(css: string, o: PptxOptions, base: float): CssLine =
  ## `1px solid #333` (any order) as a line.
  for w in css.resolveVars(o).splitTop(' '):
    let x = w.toLowerAscii
    if x in ["solid", "double"]: discard
    elif x == "dashed": result.dash = "dash"
    elif x == "dotted": result.dash = "sysDot"
    elif x in ["none", "hidden"]: return CssLine()
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

type HtmlRun = object
  ## A piece of text with one look, from the inline HTML of a cell or a label.
  text: string
  bold, italic, sup, sub, code: bool
  color: string
  link: string

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

proc runs(html: string): seq[seq[HtmlRun]] =
  ## Paragraphs (split at `<br>`) of runs: `<b>`/`<strong>`, `<i>`/`<em>`, `<sup>`, `<sub>`,
  ## `<code>` and `<span style="color: ...">` are kept, other tags are dropped, their text kept.
  type Open = tuple[tag: string, color: string, href: string]
  var stack: seq[Open]
  var cur = HtmlRun()
  var para: seq[HtmlRun]
  proc look(): HtmlRun =
    for (tag, color, href) in stack:
      if href.len > 0: result.link = href
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
        var href = ""
        let hr = inside.find("href=")
        if name == "a" and hr >= 0:
          let q = inside[hr + 5]
          let e = inside.find(q, hr + 6)
          if e > hr: href = inside[hr + 6 ..< e].replace("&amp;", "&")
        stack.add (name, color, href)
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


proc grid(t: Tabella, b: Built, o: PptxOptions): (seq[seq[TCell]], seq[float]) =
  ## The table as rows of cells, with merged cells marked, and the column widths in points.
  let m = t.options
  let base = toPoints(m.tableFontSize, 12)
  let hasStub = t.hasStub
  let ncols = b.columns.len + (if hasStub: 1 else: 0)
  var root = Look(size: base, color: toColor(m.tableFontColor, o), fill: toColor(m.tableBackgroundColor, o),
                  font: firstFont(m.tableFontNames.resolveVars(o)), align: "l", anchor: "ctr",
                  padV: toPoints(m.dataRowPadding, base), padH: toPoints(m.dataRowPaddingHorizontal, base))
  let hline = CssLine(width: 0.75, color: toColor(m.tableBodyHlinesColor, o))
  let vline = if m.tableBodyVlinesColor.len == 0: CssLine()
              else: CssLine(width: 0.75, color: toColor(m.tableBodyVlinesColor, o))
  proc heavy(c: string, w = "2px"): CssLine =
    result = CssLine(width: toPoints(w, base), color: toColor(c, o))
    if result.color.none: result.width = 0
  proc styled(look: Look, key: string): Look =
    result = look
    let css = b.styles.getOrDefault(key)
    if css.len > 0: result.applyCss(css, o, base)
  proc marks(key: string): string =
    let ms = b.marks.getOrDefault(key)
    if ms.len == 0: "" else: wrapMark(ms.mapIt(markText(it, m)).join(","), m.footnotesSpecRef)
  proc full(text: string, look: Look, key = ""): seq[TCell] =
    result.add TCell(text: text, mark: marks(key), look: look, span: ncols, rowSpan: 1)
    for k in 1 ..< ncols: result.add TCell(hMerge: true, look: look)
  var rows: seq[seq[TCell]]

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
    var row: seq[TCell]
    if hasStub:
      if lv == levels:
        row.add TCell(text: t.stubhead.renderText(rcHtml), mark: marks("stubhead"),
                     look: label.styled("stubhead"), span: 1, rowSpan: levels + 1)
      else: row.add TCell(vMerge: true, look: label)
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
        row.add TCell(text: s.label.renderText(rcHtml), mark: marks(spannerKey(s.label.s)), look: l,
                     span: span, rowSpan: 1)
        for q in 1 ..< span: row.add TCell(hMerge: true, look: l)
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
            row.add TCell(text: c.label.renderText(rcHtml), mark: marks(colKey(c.name)), look: l,
                         span: 1, rowSpan: levels + 1)
          elif not hasAny: row.add TCell(vMerge: true, look: label)
          else: row.add TCell(text: "", look: label, span: 1, rowSpan: 1)
      j += span
    rows.add row
  block:
    var row: seq[TCell]
    if hasStub:
      if levels == 0:
        row.add TCell(text: t.stubhead.renderText(rcHtml), mark: marks("stubhead"),
                     look: label.styled("stubhead"), span: 1, rowSpan: 1)
      else: row.add TCell(vMerge: true, look: label)
    for c in b.columns:
      var hasAny = false
      for l2 in 1 .. levels:
        if t.spannerAt(c.name, l2) >= 0: hasAny = true
      if levels > 0 and not hasAny: row.add TCell(vMerge: true, look: label)
      else:
        var l = label.styled(colKey(c.name))
        l.align = alignOf(c.align)
        row.add TCell(text: c.label.renderText(rcHtml), mark: marks(colKey(c.name)), look: l, span: 1, rowSpan: 1)
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
      var row: seq[TCell]
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
        row.add TCell(text: r.stub, mark: marks(k), look: l.styled(k), span: 1, rowSpan: 1)
      for j, c in b.columns:
        var l = cellLook
        l.align = alignOf(c.align)
        let k = cellKey(r.index, c.name)
        row.add TCell(text: r.cells[j], mark: marks(k), look: l.styled(k), span: 1, rowSpan: 1)
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

# ---------------------------------------------------------------------- for the clipboard

func cssColor(c: PptxColor): string =
  if c.none: "transparent"
  elif c.alpha >= 100000: "#" & c.hex
  else:
    let rgb = parseColor("#" & c.hex)
    "rgba(" & $int(rgb.r) & "," & $int(rgb.g) & "," & $int(rgb.b) & "," & formatFloat(c.alpha / 100000, ffDecimal, 2) & ")"

func cssLine(l: CssLine): string =
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


# ------------------------------------------------------------------------------- with xoffy

func toXoffy(c: PptxColor): Color =
  if c.none: noColor
  elif c.hex.len == 0: inherit       # a look that never got this colour
  elif c.alpha >= 100000: rgb(c.hex)
  else: rgb(c.hex).withAlpha(c.alpha / 100000)

func toXoffy(l: CssLine): Line =
  if l.width <= 0 or l.color.none: noLine
  else: line(toXoffy(l.color), l.width.pt, (if l.dash == "dash": dsDash elif l.dash == "sysDot": dsDot else: dsSolid))

func textAlign(a: string): TextAlign =
  case a
  of "ctr": taCenter
  of "r": taRight
  else: taLeft

func anchorOf(a: string): Anchor =
  case a
  of "t": anTop
  of "b": anBottom
  else: anMiddle

func fontOf(l: Look, raised = false, lowered = false): Font =
  Font(size: l.size, bold: l.bold, italic: l.italic, underline: l.underline, strike: l.strike,
       color: toXoffy(l.color), typeface: l.font, caps: l.upper,
       baseline: (if raised: 30 elif lowered: -25 else: 0))

proc toGridCell(c: TCell): GridCell =
  ## One cell of the grid as xoffy's cell: its text as paragraphs of runs (a `<br>` starts a new
  ## paragraph), the footnote marks raised, then its margins, fill and four borders.
  let l = c.look
  result = cell(frame())
  result.span = c.span
  result.rowSpan = c.rowSpan
  result.hMerge = c.hMerge
  result.vMerge = c.vMerge
  result.anchor = anchorOf(l.anchor)
  result.fill = toXoffy(l.fill)
  result.margins = [l.padH.pt, l.padH.pt, l.padV.pt, l.padV.pt]
  for e, k in [edLeft: 0, edRight: 1, edTop: 2, edBottom: 3]: result.borders[e] = toXoffy(l.lines[k])
  if c.hMerge or c.vMerge: return
  let paras = c.text.runs
  for k, p in paras:
    var para = Paragraph(align: textAlign(l.align), endFont: Font(size: l.size))
    if k == 0 and c.lead.len > 0:
      para.runs.add run(c.lead, fontOf(l, raised = true))
      para.runs.add run(" ", fontOf(l))
    for r in p:
      var rl = l
      rl.bold = l.bold or r.bold
      rl.italic = l.italic or r.italic
      if r.color.len > 0: rl.color = toColor(r.color)
      if r.code: rl.font = "Menlo"
      para.runs.add run(r.text, fontOf(rl, raised = r.sup, lowered = r.sub), link = r.link)
    if k == paras.high and c.mark.len > 0:
      para.runs.add run(c.mark, fontOf(l, raised = true))
    result.text.paragraphs.add para

proc toGrid*(t: Tabella, o = PptxOptions(), maxWidth = 0.0): Grid =
  ## The table as xoffy's `Grid`, a native PowerPoint table to place on a slide of your own
  ## (`tableFrame(g, x, y)`). With `maxWidth` (in points), a wider table is scaled down: sizes,
  ## paddings, rules and widths.
  let b = t.build(rcHtml)
  var (rows, widths) = t.grid(b, o)
  let total = widths.foldl(a + b, 0.0)
  let k = if maxWidth > 0 and total > maxWidth: maxWidth / total else: 1.0
  if k < 1:
    for w in widths.mitems: w *= k
    for r in rows.mitems:
      for c in r.mitems:
        c.look.size *= k
        c.look.padH *= k
        c.look.padV *= k
        for s in 0..3: c.look.lines[s].width = max(c.look.lines[s].width * k, 0.5)
  for w in widths: result.cols.add w.pt
  for r in rows:
    var h = 0.0
    for c in r:
      if c.hMerge or c.vMerge: continue
      h = max(h, float(max(1, c.text.plainLines.len)) * c.look.size * 1.2 + 2 * c.look.padV)
    var row = GridRow(height: h.pt)
    for c in r: row.cells.add toGridCell(c)
    result.rows.add row

proc toShape*(t: Tabella, o = PptxOptions()): Shape =
  ## The table on a slide of `o`'s size: scaled to fit between the margins, in the middle.
  let g = t.toGrid(o, maxWidth = o.slideWidth - 2 * o.margin)
  let x = (o.slideWidth.pt - g.width) / 2
  let y = max(o.margin.pt, (o.slideHeight.pt - g.height) / 2)
  result = tableFrame(g, x, y)
  result.name = if t.title.isEmpty: "tabella" else: textToPlain(t.title)

proc toPresentation*(tables: openArray[Tabella], o = PptxOptions()): Presentation =
  ## A presentation with one table per slide.
  result = newPresentation(size = (o.slideWidth.pt, o.slideHeight.pt))
  for t in tables: result.add slide(t.toShape(o))

proc toPptx*(tables: openArray[Tabella], o = PptxOptions()): string =
  ## The bytes of a .pptx with one table per slide.
  toPresentation(tables, o).toPptx

proc savePptx*(t: Tabella, path: string, o = PptxOptions()) =
  ## Writes the table as a one-slide PowerPoint file, as a native (editable) table.
  toPresentation([t], o).save(path)

proc savePptx*(tables: openArray[Tabella], path: string, o = PptxOptions()) =
  ## Writes a PowerPoint file with one table per slide.
  toPresentation(tables, o).save(path)
