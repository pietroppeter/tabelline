## The layout of a table as a picture: where every rule, letter and nanoplot goes, worked out
## from the same `Built` as `toHtml`, as Chrome lays out the HTML table. `drawing(t)` gives the
## marks to draw; painters turn them into a picture: `toSvg` (render_svg.nim, in the core),
## `tabelline/pixie` (a PNG). It needs only the standard library: letters are measured with the
## fonts tabelline ships (Inter 4.1 and DejaVu Sans Mono, in `fonts/` with their licences), read
## by `ttf.nim` (widths, kerning, tabular figures).
##
## The layout follows Chrome's: the same parts (heading, column labels, body, footer), the same
## paddings and rules (from the options), the styles of `tabStyle` and `dataColor` read from
## their CSS, the automatic column widths of a table (`table-layout: auto`), borders collapsed
## (the stronger wins), lines wrapped at spaces, `line-height: normal`. Nanoplots, already SVG,
## and pictures (`fmtImage`) are boxes placed in the line.

import std/[strutils, tables, base64, math, sequtils, algorithm, os]
export tables
from std/unicode import Rune, runes, toUpper, toLower, isAlpha, isWhiteSpace, `$`
import core, build, colors, ttf

# ------------------------------------------------------------------------------------- fonts

const fontDir = currentSourcePath().parentDir / "fonts"
const
  interRegular = staticRead(fontDir / "inter-regular.ttf")
  interBold = staticRead(fontDir / "inter-bold.ttf")
  interItalic = staticRead(fontDir / "inter-italic.ttf")
  interBoldItalic = staticRead(fontDir / "inter-bolditalic.ttf")
  dejavuMono = staticRead(fontDir / "dejavu-sans-mono.ttf")

type Face* = enum fRegular, fBold, fItalic, fBoldItalic, fMono  ## the five faces tabelline ships

var fonts: array[Face, Font]

proc faceFont*(f: Face): Font =
  if fonts[f] == nil:
    fonts[f] = case f
      of fRegular: readFont(interRegular, "Inter")
      of fBold: readFont(interBold, "Inter Bold")
      of fItalic: readFont(interItalic, "Inter Italic")
      of fBoldItalic: readFont(interBoldItalic, "Inter Bold Italic")
      of fMono: readFont(dejavuMono, "DejaVu Sans Mono")
  fonts[f]

# --------------------------------------------------------------------------------- CSS values

type
  Paint* = object
    color*: string      ## "" for none
    opacity*: float
  Border = object
    width: float
    style: string      ## solid, double, dashed, dotted ("" or none: no border)
    color: Paint

proc paint(css: string, vars: Table[string, string] = initTable[string, string]()): Paint =
  ## A CSS colour as an SVG fill: hex, a name, rgb() or rgba(), `transparent`, `var(--x, y)`.
  var c = css.strip
  if c.startsWith("var("):
    let inner = c[4 ..< c.rfind(')')]
    let parts = inner.split(',', 1)
    let name = parts[0].strip
    c = if name in vars: vars[name] elif parts.len > 1: parts[1].strip else: ""
    return paint(c, vars)
  if c.len == 0 or c in ["transparent", "none", "initial", "inherit"]: return Paint(color: "", opacity: 0)
  if c.startsWith("rgb"):
    let nums = c[c.find('(') + 1 ..< c.rfind(')')].replace("/", ",").split({',', ' '}).filterIt(it.len > 0)
    if nums.len >= 3:
      let rgb = nums[0 .. 2].mapIt(it.strip.parseFloat.round.int)
      var a = 1.0
      if nums.len > 3:
        let s = nums[3].strip
        a = if s.endsWith("%"): s[0 .. ^2].parseFloat / 100 else: s.parseFloat
      return Paint(color: "#" & rgb.mapIt(it.toHex(2)).join, opacity: a)
  try:
    let rgb = parseColor(c)
    if c.startsWith("#") and c.len == 9:   # #rrggbbaa
      return Paint(color: c[0 .. 6], opacity: parseHexInt(c[7 .. 8]) / 255)
    Paint(color: toHex(rgb), opacity: 1)
  except ValueError: Paint(color: "", opacity: 0)

proc length(s: string, em: float, percentOf = -1.0): float =
  ## A CSS length in pixels: px, em, rem (16px), %, pt; a bare number is pixels.
  let v = s.strip.toLowerAscii
  if v.len == 0 or v in ["auto", "initial", "inherit", "none", "normal"]: return 0
  try:
    if v.endsWith("px"): v[0 .. ^3].parseFloat
    elif v.endsWith("rem"): v[0 .. ^4].parseFloat * 16
    elif v.endsWith("em"): v[0 .. ^3].parseFloat * em
    elif v.endsWith("pt"): v[0 .. ^3].parseFloat * 4 / 3
    elif v.endsWith("%"): v[0 .. ^2].parseFloat / 100 * (if percentOf >= 0: percentOf else: em)
    else: v.parseFloat
  except ValueError: 0

proc fontSize(s: string, parent: float): float =
  case s.strip
  of "", "inherit", "initial": parent
  of "small": 13
  of "x-small": 10
  of "smaller": parent / 1.2
  of "larger": parent * 1.2
  of "medium": 16
  of "large": 18
  of "x-large": 24
  else: length(s, parent, parent)

func isBold(w: string): bool =
  let s = w.strip
  s in ["bold", "bolder"] or (s.len > 0 and s[0].isDigit and (try: s.parseInt >= 600 except ValueError: false))

proc border(s: string, vars: Table[string, string], em: float): Border =
  ## `2px solid #D3D3D3` (any order).
  result.style = "solid"
  result.width = 3                      # CSS's `medium`
  var color = ""
  for tok in s.splitWhitespace:
    let t = tok.toLowerAscii
    if t in ["none", "hidden", "solid", "double", "dashed", "dotted", "groove", "ridge", "inset", "outset"]:
      result.style = t
    elif t[0].isDigit or t.startsWith("."): result.width = length(t, em)
    elif t == "thin": result.width = 1
    elif t == "medium": result.width = 3
    elif t == "thick": result.width = 5
    else: color.add (if color.len > 0: " " else: "") & tok
  if result.style in ["none", "hidden"] or result.width <= 0: return Border()
  result.color = paint(if color.len > 0: color else: "currentColor", vars)

proc declarations(css: string): seq[(string, string)] =
  ## `a: b; c: d` as pairs; a `;` inside parentheses does not split.
  var depth = 0
  var cur = ""
  for ch in css & ";":
    if ch == '(': inc depth
    elif ch == ')': dec depth
    if ch == ';' and depth == 0:
      let kv = cur.split(':', 1)
      if kv.len == 2 and kv[0].strip.len > 0: result.add (kv[0].strip.toLowerAscii, kv[1].strip.replace("!important", "").strip)
      cur = ""
    else: cur.add ch

# -------------------------------------------------------------------------------- text runs

type
  TextStyle = object
    size: float
    bold, italic, mono, tabular: bool
    color: Paint
    underline, strike: bool
    transform: string
    href: string
    lift: float       ## baseline shift, up, in pixels
    nowrap: bool
    zeroLine: bool     ## `sup` and `sub`: `line-height: 0` in tabelline's CSS
  ItemKind = enum ikText, ikBox, ikBreak
  Item = object
    style: TextStyle
    case kind: ItemKind
    of ikText: text: string
    of ikBox:
      w, h: float
      svg: string      ## an `<svg>` element (drawn at x, y, w, h) or an `<image>` href
      image: bool
    of ikBreak: discard

func face(s: TextStyle): Face =
  if s.mono: fMono
  elif s.bold and s.italic: fBoldItalic
  elif s.bold: fBold
  elif s.italic: fItalic
  else: fRegular

proc applyTransform(s, how: string): string =
  case how
  of "uppercase": result = s.toUpper
  of "lowercase": result = s.toLower
  of "capitalize":
    var up = true
    for r in s.runes:
      result.add(if up and r.isAlpha: $r.toUpper else: $r)
      up = r.isWhiteSpace
  else: result = s

proc decodeEntities(s: string): string =
  var i = 0
  while i < s.len:
    if s[i] == '&':
      let e = s.find(';', i)
      if e > i and e - i < 12:
        let name = s[i + 1 ..< e]
        var rep = ""
        case name
        of "amp": rep = "&"
        of "lt": rep = "<"
        of "gt": rep = ">"
        of "quot": rep = "\""
        of "apos", "#39": rep = "'"
        of "nbsp": rep = " "
        of "thinsp": rep = " "
        of "mdash": rep = "—"
        of "ndash": rep = "–"
        of "minus": rep = "−"
        of "times": rep = "×"
        else:
          if name.startsWith("#x") or name.startsWith("#X"):
            try: rep = $Rune(parseHexInt(name[2 .. ^1])) except ValueError: discard
          elif name.startsWith("#"):
            try: rep = $Rune(parseInt(name[1 .. ^1])) except ValueError: discard
        if rep.len > 0:
          result.add rep
          i = e + 1
          continue
    result.add s[i]
    inc i

proc attr(tag, name: string): string =
  ## The value of attribute `name` in an HTML start tag.
  for q in ["\"", "'"]:
    let k = tag.find(" " & name & "=" & q)
    if k >= 0:
      let a = k + name.len + 3
      let b = tag.find(q, a)
      if b > a: return decodeEntities(tag[a ..< b])
  ""

proc imageSize(src: string): (float, float) =
  ## The size of a data URL's picture (PNG, JPEG, GIF, SVG), or (0, 0).
  if not src.startsWith("data:"): return (0, 0)
  let comma = src.find(',')
  let meta = src[5 ..< comma]
  let raw = if meta.endsWith(";base64"): decode(src[comma + 1 .. ^1]) else: src[comma + 1 .. ^1]
  proc be16(o: int): int = (ord(raw[o]) shl 8) or ord(raw[o + 1])
  proc be32(o: int): int = (be16(o) shl 16) or be16(o + 2)
  if meta.startsWith("image/png") and raw.len > 24: return (be32(16).float, be32(20).float)
  if meta.startsWith("image/gif") and raw.len > 10:
    return (float(ord(raw[6]) or (ord(raw[7]) shl 8)), float(ord(raw[8]) or (ord(raw[9]) shl 8)))
  if meta.startsWith("image/jpeg"):
    var p = 2
    while p + 9 < raw.len:
      if raw[p] != '\xFF': return (0, 0)
      let m = ord(raw[p + 1])
      if m in 0xC0 .. 0xCF and m notin [0xC4, 0xC8, 0xCC]: return (be16(p + 7).float, be16(p + 5).float)
      p += 2 + be16(p + 2)
  if meta.startsWith("image/svg"):
    let open = raw[raw.find("<svg") .. ^1]
    let tag = open[0 .. open.find('>')]
    let vb = attr(tag, "viewBox").replace(",", " ").splitWhitespace
    let (w, h) = (length(attr(tag, "width"), 16), length(attr(tag, "height"), 16))
    if w > 0 and h > 0: return (w, h)
    if vb.len == 4: return (vb[2].parseFloat, vb[3].parseFloat)
  (0, 0)

proc styleFrom(base: TextStyle, decls: seq[(string, string)], vars: Table[string, string]): TextStyle =
  ## A style changed by some CSS declarations (the ones about text).
  result = base
  for (k, v) in decls:
    case k
    of "color": result.color = paint(v, vars)
    of "font-weight": result.bold = v.isBold
    of "font-style": result.italic = v.strip in ["italic", "oblique"]
    of "font-size": result.size = fontSize(v, base.size)
    of "font-family": result.mono = "mono" in v.toLowerAscii
    of "text-decoration", "text-decoration-line":
      result.underline = "underline" in v
      result.strike = "line-through" in v
    of "text-transform": (if v != "inherit": result.transform = v)
    of "white-space": result.nowrap = v.strip in ["nowrap", "pre"]
    of "font-variant-numeric": result.tabular = "tabular-nums" in v
    of "vertical-align":
      let s = v.strip
      if s.len > 0 and (s[0].isDigit or s[0] == '-' or s[0] == '.'): result.lift = base.lift + length(s, result.size, result.size)
    else: discard

proc inlineItems(html: string, base: TextStyle, vars: Table[string, string]): seq[Item] =
  ## The runs of an HTML fragment as tabelline writes it in a cell: text, `strong`, `em`, `code`,
  ## `a`, `sup`, `sub`, `span` with a style or a footnote mark, `br`, nanoplots (`svg`) and
  ## pictures (`img`). Other tags are left out and their text kept, as gt's `as_gtable` does.
  var stack = @[base]
  var tags: seq[string]
  var i = 0
  var text = ""
  template flushText() =
    if text.len > 0:
      result.add Item(kind: ikText, text: decodeEntities(text), style: stack[^1])
      text = ""
  while i < html.len:
    if html[i] != '<':
      text.add html[i]
      inc i
      continue
    let e = html.find('>', i)
    if e < 0:
      text.add html[i .. ^1]
      break
    let tag = html[i .. e]
    flushText()
    let closing = tag.startsWith("</")
    let name = tag.strip(chars = {'<', '>', '/'}).splitWhitespace()[0].toLowerAscii
    if name == "svg" and not closing:
      # a nanoplot: the whole element, as it is
      var depth = 0
      var j = i
      var stop = html.len
      while j < html.len:
        let o = html.find("<svg", j)
        let c = html.find("</svg>", j)
        if c < 0: break
        if o >= 0 and o < c: (inc depth; j = o + 4)
        else:
          dec depth
          j = c + 6
          if depth == 0: (stop = j; break)
      let el = html[i ..< stop]
      let cur = stack[^1]
      var h = cur.size * 2
      for (k, v) in declarations(attr(tag, "style")):
        if k == "height": h = length(v, cur.size, cur.size)
      let vb = attr(tag, "viewBox").replace(",", " ").splitWhitespace
      let w = if vb.len == 4 and vb[3].parseFloat > 0: h * vb[2].parseFloat / vb[3].parseFloat else: h
      result.add Item(kind: ikBox, w: w, h: h, svg: el, style: cur)
      i = stop
      continue
    i = e + 1
    if name == "br":
      result.add Item(kind: ikBreak, style: stack[^1])
      continue
    if name == "img":
      let cur = stack[^1]
      let src = attr(tag, "src")
      var (iw, ih) = imageSize(src)
      var h, w = -1.0
      for (k, v) in declarations(attr(tag, "style")):
        if k == "height": h = length(v, cur.size, cur.size)
        if k == "width": w = length(v, cur.size, cur.size)
      if attr(tag, "height").len > 0 and h < 0: h = length(attr(tag, "height"), cur.size)
      if attr(tag, "width").len > 0 and w < 0: w = length(attr(tag, "width"), cur.size)
      if iw <= 0 or ih <= 0: (iw = 1; ih = 1)
      if h < 0 and w < 0: (w = iw; h = ih)
      elif h < 0: h = w * ih / iw
      elif w < 0: w = h * iw / ih
      result.add Item(kind: ikBox, w: w, h: h, svg: src, image: true, style: cur)
      continue
    if tag.endsWith("/>"): continue
    if closing:
      var k = -1
      for n in countdown(tags.high, 0):
        if tags[n] == name: (k = n; break)
      if k >= 0:
        tags.setLen k
        stack.setLen k + 1
      continue
    var s = stack[^1]
    case name
    of "strong", "b": s.bold = true
    of "em", "i": s.italic = true
    of "code", "kbd", "samp", "tt":
      if not s.mono: s.size = s.size * 13 / 16   # a browser's monospace size
      s.mono = true
    of "a":
      s.href = attr(tag, "href")
      s.color = paint("#0000EE")
      s.underline = true
    of "u": s.underline = true
    of "s", "del", "strike": s.strike = true
    of "sup":
      s.size = s.size / 1.2
      s.lift += stack[^1].size / 3
      s.zeroLine = true
    of "sub":
      s.size = s.size / 1.2
      s.lift -= stack[^1].size / 5
      s.zeroLine = true
    of "span", "div", "p":
      if "tb_footnote_marks" in attr(tag, "class"):
        s.size = s.size * 0.75
        s.lift += 0.4 * s.size
        s.bold = false
        s.italic = false
      s = styleFrom(s, declarations(attr(tag, "style")), vars)
    else: discard
    tags.add name
    stack.add s
  flushText()

# ----------------------------------------------------------------------------------- lines

type
  Frag = object       ## a piece of a line: text in one style, or a box
    item: Item
    text: string      ## the text, transformed
    raw: string       ## the text as written
    w: float
    adv: seq[float]   ## the advance of each letter (text)
  Word = object       ## what cannot be broken: fragments, and the space after them
    frags: seq[Frag]
    w, space: float
    spaceStyle: TextStyle
    hardBreak: bool   ## a line ends after it
  Line = object
    frags: seq[Frag]
    xs: seq[float]    ## where each fragment starts, from the line's left
    w, ascent, descent: float

proc measure(text: string, s: TextStyle): Frag =
  let f = faceFont(s.face)
  let t = text.applyTransform(s.transform)
  result.text = t
  result.adv = f.advances(t, s.size, kern = true, tabular = s.tabular)
  for a in result.adv: result.w += a

proc words(items: seq[Item]): seq[Word] =
  ## The items as words: breaks at spaces (collapsed, as `white-space: normal`), not inside
  ## `nowrap`; a `<br>` ends the line.
  var cur = Word()
  var pending = false                     # a space waits to be added
  var pendingStyle: TextStyle
  template endWord() =
    if cur.frags.len > 0:
      result.add cur
    cur = Word()
  for it in items:
    case it.kind
    of ikBreak:
      endWord()
      if result.len > 0: result[^1].hardBreak = true
      else: result.add Word(hardBreak: true)
      pending = false
    of ikBox:
      if pending:
        endWord()
        if result.len > 0:
          result[^1].space = measure(" ", pendingStyle).w
          result[^1].spaceStyle = pendingStyle
        pending = false
      cur.frags.add Frag(item: it, w: it.w)
      cur.w += it.w
    of ikText:
      var s = it.text.multiReplace(("\n", " "), ("\t", " "), ("\r", " "))
      var k = 0
      let parts = if it.style.nowrap: @[s.replace(" ", " ")] else: s.split(' ')
      for p in parts:
        if k > 0:       # a space between parts
          pending = true
          pendingStyle = it.style
        inc k
        if p.len == 0: continue
        if pending:
          endWord()
          if result.len > 0 and not result[^1].hardBreak:
            result[^1].space = measure(" ", pendingStyle).w
            result[^1].spaceStyle = pendingStyle
          pending = false
        var f = measure(p, it.style)
        f.item = it
        f.raw = p
        cur.frags.add f
        cur.w += f.w
  endWord()

proc lineMetrics(frags: seq[Frag], base: TextStyle): (float, float) =
  ## The ascent and descent of a line: the strut of the cell's font, and every fragment.
  let bf = faceFont(base.face)
  var asc = bf.ascent(base.size)
  var desc = bf.descent(base.size)
  let lh = bf.lineHeight(base.size)
  let extra = (lh - asc - desc) / 2
  asc += extra
  desc += extra
  for f in frags:
    if f.item.kind == ikBox:
      # vertical-align: middle, the box's middle at the baseline + half the x-height
      let mid = bf.xHeightPx(base.size) / 2
      asc = max(asc, mid + f.item.h / 2)
      desc = max(desc, f.item.h / 2 - mid)
    elif f.item.kind == ikText:
      let s = f.item.style
      let ff = faceFont(s.face)
      if s.zeroLine: continue
      asc = max(asc, ff.ascent(s.size) + s.lift)
      desc = max(desc, ff.descent(s.size) - s.lift)
  (asc, desc)

proc breakLines(ws: seq[Word], width: float, base: TextStyle): seq[Line] =
  var line = Line()
  var x = 0.0
  template finish() =
    (line.ascent, line.descent) = lineMetrics(line.frags, base)
    result.add line
    line = Line()
    x = 0
  var prevSpace = 0.0
  for k, w in ws:
    if line.frags.len > 0 and x + prevSpace + w.w > width + 0.01: finish()
    elif line.frags.len > 0: x += prevSpace
    for f in w.frags:
      line.xs.add x
      line.frags.add f
      x += f.w
    line.w = x
    prevSpace = w.space
    if w.hardBreak: finish()
  if line.frags.len > 0 or result.len == 0: finish()

proc minMax(ws: seq[Word]): (float, float) =
  ## The widest word, and the width of the longest line without wrapping.
  var line = 0.0
  var prevSpace = 0.0
  var first = true
  for w in ws:
    result[0] = max(result[0], w.w)
    if not first: line += prevSpace
    line += w.w
    first = false
    prevSpace = w.space
    result[1] = max(result[1], line)
    if w.hardBreak: (line = 0; first = true)

# ------------------------------------------------------------------------------------ cells

type
  Cell = object
    row, col, rowspan, colspan: int
    words: seq[Word]
    base: TextStyle
    align, valign: string
    pad: array[4, float]          ## top, right, bottom, left
    bg: Paint
    borders: array[4, Border]     ## top, right, bottom, left
    indent: float
    spanner: Border               ## the rule under a spanner's label
    fixedWidth: float             ## from `colsWidth` in pixels (0: none)
    percentWidth: float
    lines: seq[Line]
  Grid = object
    cells: seq[Cell]
    nrows, ncols: int
    tableBg: Paint
    tableBorders: array[4, Border]

func better(a, b: Border): bool =
  ## Whether border `a` wins over `b` where they meet (CSS's border conflict resolution).
  const rank = {"double": 8, "solid": 7, "dashed": 6, "dotted": 5, "ridge": 4, "outset": 3, "groove": 2, "inset": 1}.toTable
  if b.style.len == 0: return a.style.len > 0
  if a.style.len == 0: return false
  if a.width != b.width: return a.width > b.width
  rank.getOrDefault(a.style, 0) > rank.getOrDefault(b.style, 0)

type Ctx = object
  t: Tabella
  b: Built
  o: TabOptions
  vars: Table[string, string]
  baseSize: float
  base: TextStyle
  grid: Grid
  row: int

proc opt(c: Ctx, value: string, fallback = ""): string =
  if value.len > 0: value else: fallback

proc newCell(c: var Ctx, html: string, col, colspan: int, cls: TextStyle, align: string,
             pad: (float, float), valign = "middle", rowspan = 1): int =
  var cell = Cell(row: c.row, col: col, rowspan: rowspan, colspan: colspan, base: cls, align: align,
                  valign: valign)
  cell.pad = [pad[0], pad[1], pad[0], pad[1]]
  cell.words = words(inlineItems(html, cls, c.vars))
  c.grid.cells.add cell
  c.grid.cells.high

proc styleCell(c: var Ctx, k: int, key: string) =
  ## The styles of `tabStyle` and `dataColor` on a cell.
  let css = c.b.styles.getOrDefault(key)
  if css.len == 0: return
  let d = declarations(css)
  var cell = c.grid.cells[k]
  let em = cell.base.size
  let before = cell.base
  cell.base = styleFrom(cell.base, d, c.vars)
  for (k2, v) in d:
    case k2
    of "background-color", "background": cell.bg = paint(v, c.vars)
    of "text-align": cell.align = v.strip
    of "vertical-align": cell.valign = v.strip
    of "text-indent": cell.indent = length(v, em)
    of "border": (for s in 0 .. 3: cell.borders[s] = border(v, c.vars, em))
    of "border-top": cell.borders[0] = border(v, c.vars, em)
    of "border-right": cell.borders[1] = border(v, c.vars, em)
    of "border-bottom": cell.borders[2] = border(v, c.vars, em)
    of "border-left": cell.borders[3] = border(v, c.vars, em)
    of "padding":
      let ps = v.splitWhitespace.mapIt(length(it, em))
      case ps.len
      of 1: cell.pad = [ps[0], ps[0], ps[0], ps[0]]
      of 2: cell.pad = [ps[0], ps[1], ps[0], ps[1]]
      of 3: cell.pad = [ps[0], ps[1], ps[2], ps[1]]
      of 4: cell.pad = [ps[0], ps[1], ps[2], ps[3]]
      else: discard
    of "padding-top": cell.pad[0] = length(v, em)
    of "padding-right": cell.pad[1] = length(v, em)
    of "padding-bottom": cell.pad[2] = length(v, em)
    of "padding-left": cell.pad[3] = length(v, em)
    else: discard
  if cell.base != before:
    # the text changes with the cell's style: measure it again, in the new style
    var items: seq[Item]
    for w in cell.words:
      for f in w.frags:
        var it = f.item
        if it.style.color == before.color: it.style.color = cell.base.color
        if it.style.bold == before.bold: it.style.bold = cell.base.bold
        if it.style.italic == before.italic: it.style.italic = cell.base.italic
        if it.style.size == before.size: it.style.size = cell.base.size
        it.style.transform = cell.base.transform
        it.style.underline = it.style.underline or cell.base.underline
        it.style.strike = it.style.strike or cell.base.strike
        if it.kind == ikText:
          it.text = f.raw
        items.add it
      if w.space > 0: items.add Item(kind: ikText, text: " ", style: w.spaceStyle)
      if w.hardBreak: items.add Item(kind: ikBreak)
    cell.words = words(items)
  c.grid.cells[k] = cell

proc withMarks(c: Ctx, html, key: string): string = html & c.b.marksHtml(key, c.o)

proc buildGrid*(t: Tabella, vars: Table[string, string]): Grid =
  var c = Ctx(t: t, b: t.build(rcHtml), o: t.options, vars: vars)
  let o = c.o
  let b = c.b
  c.baseSize = fontSize(o.tableFontSize, 16)
  c.base = TextStyle(size: c.baseSize, color: paint(o.tableFontColor, vars),
                     bold: o.tableFontWeight.isBold, italic: o.tableFontStyle == "italic")
  let base = c.base
  let em = c.baseSize
  proc L(s: string): float = length(s, em)
  proc B(width, style, color: string): Border = border(width & " " & style & " " & color, vars, em)
  let asColumn = t.groupAsColumn
  let sw = t.stubWidth
  let ncols = max(1, b.columns.len + sw)
  c.grid.ncols = ncols
  c.grid.tableBg = paint(o.tableBackgroundColor, vars)
  c.grid.tableBorders = [B(o.tableBorderTopWidth, o.tableBorderTopStyle, o.tableBorderTopColor),
                         B(o.tableBorderRightWidth, o.tableBorderRightStyle, o.tableBorderRightColor),
                         B(o.tableBorderBottomWidth, o.tableBorderBottomStyle, o.tableBorderBottomColor),
                         B(o.tableBorderLeftWidth, o.tableBorderLeftStyle, o.tableBorderLeftColor)]
  let lineColor = o.tableBodyHlinesColor
  func alignOf(a: Align): string =
    case a
    of alCenter: "center"
    of alRight: "right"
    else: "left"
  proc textStyle(size, weight, transform: string, color = ""): TextStyle =
    result = base
    result.size = fontSize(size, em)
    if weight notin ["", "initial", "inherit"]: result.bold = weight.isBold
    elif weight == "initial": result.bold = false
    if transform notin ["", "inherit"]: result.transform = transform
    if color.len > 0: result.color = paint(color, vars)

  # heading
  if not t.title.isEmpty:
    let ts = textStyle(o.headingTitleFontSize, o.headingTitleFontWeight, "")
    let k = c.newCell(c.withMarks(t.title.renderText(rcHtml), "title"), 0, ncols, ts, o.headingAlign,
                      (L(o.headingPadding), L(o.headingPaddingHorizontal)))
    c.grid.cells[k].bg = paint(c.opt(o.headingBackgroundColor, o.tableBackgroundColor), vars)
    c.styleCell(k, "title")
    var last = k
    inc c.row
    if not t.subtitle.isEmpty:
      let ss = textStyle(o.headingSubtitleFontSize, o.headingSubtitleFontWeight, "")
      let k2 = c.newCell(c.withMarks(t.subtitle.renderText(rcHtml), "subtitle"), 0, ncols, ss, o.headingAlign,
                         (0.0, L(o.headingPaddingHorizontal)))
      c.grid.cells[k2].pad[2] = L(o.headingPadding)
      c.grid.cells[k2].bg = c.grid.cells[k].bg
      c.styleCell(k2, "subtitle")
      last = k2
      inc c.row
    c.grid.cells[last].borders[2] = B(o.headingBorderBottomWidth, o.headingBorderBottomStyle, o.headingBorderBottomColor)

  # column labels
  if not o.columnLabelsHidden:
    let levels = t.spannerLevels(b.columns)
    let ls = textStyle(o.columnLabelsFontSize, o.columnLabelsFontWeight, o.columnLabelsTextTransform)
    let lpad = (L(o.columnLabelsPadding), L(o.columnLabelsPaddingHorizontal))
    let lbg = paint(c.opt(o.columnLabelsBackgroundColor, o.tableBackgroundColor), vars)
    let lastBorder = B(o.columnLabelsBorderBottomWidth, o.columnLabelsBorderBottomStyle, o.columnLabelsBorderBottomColor)
    let topBorder = B(o.columnLabelsBorderTopWidth, o.columnLabelsBorderTopStyle, o.columnLabelsBorderTopColor)
    let firstRow = c.row
    var labelCells: seq[int]
    proc hasAnySpanner(col: ColInfo): bool =
      for lv in 1 .. levels:
        if t.spannerAt(col.name, lv) >= 0: return true
    if sw > 0:
      let k = c.newCell(c.withMarks(t.stubhead.renderLabel(rcHtml), "stubhead"), 0, sw, ls, "left", lpad,
                        "bottom", levels + 1)
      c.grid.cells[k].bg = lbg
      c.styleCell(k, "stubhead")
      labelCells.add k
    for lv in countdown(levels, 1):
      var j = 0
      while j < b.columns.len:
        let col = b.columns[j]
        if not col.hasAnySpanner:
          inc j
          continue
        let s = t.spannerAt(col.name, lv)
        var span = 1
        while j + span < b.columns.len and t.spannerAt(b.columns[j + span].name, lv) == s and
              (s >= 0 or b.columns[j + span].hasAnySpanner):
          inc span
        let html = if s >= 0: c.withMarks(t.spanners[s].label.renderLabel(rcHtml), spannerKey(t.spanners[s].label.s)) else: ""
        let k = c.newCell(html, sw + j, span, ls, "center", lpad, "bottom")
        c.grid.cells[k].bg = lbg
        if s >= 0:
          c.grid.cells[k].spanner = B("2px", "solid", o.columnLabelsBorderBottomColor)
          c.styleCell(k, spannerKey(t.spanners[s].label.s))
        if lv == levels: labelCells.add k
        j += span
      inc c.row
    for j, col in b.columns:
      let rs = if levels == 0 or col.hasAnySpanner: 1 else: levels + 1
      let r = if rs > 1: firstRow else: c.row
      let saved = c.row
      c.row = r
      var cls = ls
      cls.tabular = col.align == alRight     # `.tb_right` has tabular figures, labels too
      let k = c.newCell(c.withMarks(col.columnLabel(rcHtml, o.columnLabelsUnitsPattern), colKey(col.name)),
                        sw + j, 1, cls, alignOf(col.align), lpad, "bottom", rs)
      c.row = saved
      c.grid.cells[k].bg = lbg
      if col.width.endsWith("px"): c.grid.cells[k].fixedWidth = L(col.width)
      elif col.width.endsWith("%"): c.grid.cells[k].percentWidth = col.width[0 .. ^2].parseFloat
      c.styleCell(k, colKey(col.name))
      if r == firstRow: labelCells.add k
    inc c.row
    # the rule under the labels, and above them (when asked)
    for k in 0 .. c.grid.cells.high:
      let cell = c.grid.cells[k]
      if cell.row >= firstRow and cell.row + cell.rowspan == c.row and cell.borders[2].style.len == 0:
        c.grid.cells[k].borders[2] = lastBorder
    for k in labelCells:
      if c.grid.cells[k].borders[0].style.len == 0: c.grid.cells[k].borders[0] = topBorder

  # body
  let firstBodyRow = c.row
  let bodyPad = (L(o.dataRowPadding), L(o.dataRowPaddingHorizontal))
  let hline = B(o.tableBodyHlinesWidth, o.tableBodyHlinesStyle, lineColor)
  let vline = if o.tableBodyVlinesColor.len > 0: B(o.tableBodyVlinesWidth, o.tableBodyVlinesStyle, o.tableBodyVlinesColor) else: Border()
  let stubBorder = if o.stubSeparate: B(o.stubBorderWidth, o.stubBorderStyle, c.opt(o.stubBorderColor, lineColor)) else: Border()
  let stubStyle = textStyle(o.stubFontSize, o.stubFontWeight, o.stubTextTransform)
  let bodyStyle = base
  let stripe = paint(o.rowStripingBackgroundColor, vars)
  var groupCell = -1
  proc summaryRows(ss: seq[BuiltSummary], grand, top: bool) =
    let bg = paint(if grand: o.grandSummaryRowBackgroundColor else: o.summaryRowBackgroundColor, vars)
    let pad = if grand: (L(o.grandSummaryRowPadding), L(o.grandSummaryRowPaddingHorizontal))
              else: (L(o.summaryRowPadding), L(o.summaryRowPaddingHorizontal))
    let rule = if grand: B(o.grandSummaryRowBorderWidth, o.grandSummaryRowBorderStyle, o.grandSummaryRowBorderColor)
               else: B(o.summaryRowBorderWidth, o.summaryRowBorderStyle, o.summaryRowBorderColor)
    let transform = if grand: o.grandSummaryRowTextTransform else: o.summaryRowTextTransform
    let start = if grand or not asColumn: 0 else: 1
    let span = sw - start
    for k, s in ss:
      var st = stubStyle
      if transform != "inherit": st.transform = transform
      let first = c.newCell(c.withMarks(s.label, s.key), start, span, st, "left", pad)
      c.grid.cells[first].borders[1] = stubBorder
      for j, col in b.columns:
        var bs = bodyStyle
        if transform != "inherit": bs.transform = transform
        bs.tabular = col.align == alRight
        let key = s.key & col.name
        let x = c.newCell(c.withMarks(s.cells[j], key), sw + j, 1, bs, alignOf(col.align), pad)
        c.styleCell(x, key)
      c.styleCell(first, s.key)
      for x in first .. c.grid.cells.high:
        if c.grid.cells[x].bg.color.len == 0: c.grid.cells[x].bg = bg
        if not top and k == 0: c.grid.cells[x].borders[0] = rule
        if top and k == ss.high: c.grid.cells[x].borders[2] = rule
      inc c.row
  summaryRows(b.grandTop, true, true)
  var shown = 0
  for g in b.groups:
    let gk = groupKey(g.id)
    if asColumn:
      let n = g.summaryTop.len + g.rows.len + g.summaryBottom.len
      let gs = textStyle(o.stubRowGroupFontSize, o.stubRowGroupFontWeight, o.stubRowGroupTextTransform)
      groupCell = c.newCell(c.withMarks(g.label, gk), 0, 1, gs, "left", bodyPad, "top", max(1, n))
      c.grid.cells[groupCell].borders[1] = B(o.stubRowGroupBorderWidth, o.stubRowGroupBorderStyle, o.stubRowGroupBorderColor)
      if c.row > firstBodyRow: c.grid.cells[groupCell].borders[0] = hline
      c.styleCell(groupCell, gk)
    elif g.id.len > 0 or g.label.len > 0:
      let gs = textStyle(o.rowGroupFontSize, o.rowGroupFontWeight, o.rowGroupTextTransform)
      let k = c.newCell(c.withMarks(g.label, gk), 0, ncols, gs, "left",
                        (L(o.rowGroupPadding), L(o.rowGroupPaddingHorizontal)))
      c.grid.cells[k].bg = paint(c.opt(o.rowGroupBackgroundColor, o.tableBackgroundColor), vars)
      c.grid.cells[k].borders = [
        B(o.rowGroupBorderTopWidth, o.rowGroupBorderTopStyle, c.opt(o.rowGroupBorderTopColor, o.rowGroupBorderColor)),
        B(o.rowGroupBorderRightWidth, o.rowGroupBorderRightStyle, o.rowGroupBorderRightColor),
        B(o.rowGroupBorderBottomWidth, o.rowGroupBorderBottomStyle, c.opt(o.rowGroupBorderBottomColor, o.rowGroupBorderColor)),
        B(o.rowGroupBorderLeftWidth, o.rowGroupBorderLeftStyle, o.rowGroupBorderLeftColor)]
      c.styleCell(k, gk)
      inc c.row
    var striped = false
    summaryRows(g.summaryTop, false, true)
    for r in g.rows:
      inc shown
      let on = o.rowStriping and striped
      let first = c.grid.cells.len
      for k, sc in t.stubCols:
        if r.spans[k] == 0: continue
        let key = cellKey(r.index, sc)
        let x = c.newCell(c.withMarks(r.levels[k], key), (if asColumn: 1 else: 0) + k, 1, stubStyle, "left",
                          bodyPad, "top", r.spans[k])
        c.styleCell(x, key)
      if t.hasStub:
        let key = cellKey(r.index, t.rownameCol)
        let x = c.newCell(c.withMarks(r.stub, key), sw - 1, 1, stubStyle, "left", bodyPad)
        c.grid.cells[x].borders[1] = stubBorder
        c.grid.cells[x].indent = r.indent.float * length(o.stubIndentLength, stubStyle.size)
        if on and o.rowStripingIncludeStub: c.grid.cells[x].bg = stripe
        c.styleCell(x, key)
      for j, col in b.columns:
        let key = cellKey(r.index, col.name)
        var bs = bodyStyle
        bs.tabular = col.align == alRight
        let x = c.newCell(c.withMarks(r.cells[j], key), sw + j, 1, bs, alignOf(col.align), bodyPad)
        if on and o.rowStripingIncludeTableBody: c.grid.cells[x].bg = stripe
        c.grid.cells[x].borders[1] = vline
        c.grid.cells[x].borders[3] = vline
        c.styleCell(x, key)
      if c.row > firstBodyRow:
        for x in first .. c.grid.cells.high:
          if not better(c.grid.cells[x].borders[0], hline): c.grid.cells[x].borders[0] = hline
      inc c.row
      striped = not striped
    summaryRows(g.summaryBottom, false, false)
  if shown == 0 and b.grandTop.len == 0 and b.grandBottom.len == 0:
    var ns = base
    ns.italic = true
    discard c.newCell(o.tableNoDataMessage, 0, ncols, ns, "center", bodyPad)
    inc c.row
  summaryRows(b.grandBottom, true, false)

  # footer: footnotes, then source notes
  let footFirst = c.row
  let notes = b.footer.mapIt((if it[0] > 0: footMarkHtml(it[0], o) & " " else: "") & it[1])
  proc footRows(items: seq[string], multiline: bool, sep, size, pad, padH, bg, key: string) =
    let lines = if multiline or items.len == 0: items else: @[items.join(sep)]
    var fs = base
    fs.size = fontSize(size, em)
    for n in lines:
      let k = c.newCell(n, 0, ncols, fs, "left", (L(pad), L(padH)))
      c.grid.cells[k].bg = paint(c.opt(bg, o.tableBackgroundColor), vars)
      if c.row == footFirst: c.grid.cells[k].pad[0] = 8
      c.styleCell(k, key)
      inc c.row
  footRows(notes, o.footnotesMultiline, o.footnotesSep, o.footnotesFontSize, o.footnotesPadding,
           o.footnotesPaddingHorizontal, o.footnotesBackgroundColor, "footnotes")
  footRows(t.sourceNotes.mapIt(it.renderText(rcHtml)), o.sourceNotesMultiline, o.sourceNotesSep,
           o.sourceNotesFontSize, o.sourceNotesPadding, o.sourceNotesPaddingHorizontal,
           o.sourceNotesBackgroundColor, "source_notes")
  c.grid.nrows = c.row
  c.grid

# ----------------------------------------------------------------------------------- layout

type
  Layout* = object
    grid: Grid
    colW*, rowH*: seq[float]        ## content widths (padding included) and heights
    vLine*, hLine*: seq[float]      ## the thickness of each grid line
    hEdges: seq[seq[Border]]      ## [line][col]
    vEdges: seq[seq[Border]]      ## [row][line]
    xs, ys: seq[float]            ## where each grid line starts
    width, height: float

proc place*(g: Grid, maxWidth: float): Layout =
  result.grid = g
  let (nr, nc) = (g.nrows, g.ncols)
  # the borders where cells meet, the stronger winning
  result.hEdges = newSeqWith(nr + 1, newSeq[Border](nc))
  result.vEdges = newSeqWith(nr, newSeq[Border](nc + 1))
  template setH(r, c: int, b: Border) =
    if better(b, result.hEdges[r][c]): result.hEdges[r][c] = b
  template setV(r, c: int, b: Border) =
    if better(b, result.vEdges[r][c]): result.vEdges[r][c] = b
  for cell in g.cells:
    for c in cell.col ..< cell.col + cell.colspan:
      setH(cell.row, c, cell.borders[0])
      setH(cell.row + cell.rowspan, c, cell.borders[2])
    for r in cell.row ..< cell.row + cell.rowspan:
      setV(r, cell.col, cell.borders[3])
      setV(r, cell.col + cell.colspan, cell.borders[1])
  for c in 0 ..< nc:
    setH(0, c, g.tableBorders[0])
    setH(nr, c, g.tableBorders[2])
  for r in 0 ..< nr:
    setV(r, 0, g.tableBorders[3])
    setV(r, nc, g.tableBorders[1])
  result.hLine = newSeq[float](nr + 1)
  result.vLine = newSeq[float](nc + 1)
  for r in 0 .. nr:
    for c in 0 ..< nc: result.hLine[r] = max(result.hLine[r], result.hEdges[r][c].width)
  for c in 0 .. nc:
    for r in 0 ..< nr: result.vLine[c] = max(result.vLine[c], result.vEdges[r][c].width)
  # column widths, as an automatic table layout: each column between its narrowest (the widest
  # word) and its widest (no wrapping); spanning cells widen the columns they span
  var mins = newSeq[float](nc)
  var maxs = newSeq[float](nc)
  var fixed = newSeq[float](nc)
  var cellMin, cellMax: seq[float]
  for cell in g.cells:
    let (mn, mx) = minMax(cell.words)
    let pad = cell.pad[1] + cell.pad[3] + cell.indent
    cellMin.add mn + pad
    cellMax.add mx + pad
    if cell.colspan == 1:
      mins[cell.col] = max(mins[cell.col], mn + pad)
      maxs[cell.col] = max(maxs[cell.col], mx + pad)
      if cell.fixedWidth > 0: fixed[cell.col] = cell.fixedWidth
      if cell.percentWidth > 0: fixed[cell.col] = cell.percentWidth / 100 * maxWidth
  for c in 0 ..< nc:
    if fixed[c] > 0:
      mins[c] = max(mins[c], fixed[c])
      maxs[c] = mins[c]
  let order = toSeq(0 ..< g.cells.len).filterIt(g.cells[it].colspan > 1).sortedByIt(g.cells[it].colspan)
  for k in order:
    let cell = g.cells[k]
    let cols = toSeq(cell.col ..< cell.col + cell.colspan)
    var inner = 0.0
    for c in cols[1 .. ^1]: inner += result.vLine[c]
    for (arr, need) in [(addr mins, cellMin[k] - inner), (addr maxs, cellMax[k] - inner)]:
      var have = 0.0
      for c in cols: have += arr[][c]
      if need > have:
        let free = cols.filterIt(fixed[it] == 0)
        let target = if free.len > 0: free else: cols
        var weight = 0.0
        for c in target: weight += maxs[c]
        for c in target:
          arr[][c] += (need - have) * (if weight > 0: maxs[c] / weight else: 1 / target.len)
  for c in 0 ..< nc: maxs[c] = max(maxs[c], mins[c])
  var lines = 0.0
  for v in result.vLine: lines += v
  let avail = maxWidth - lines
  let (sumMin, sumMax) = (mins.sum, maxs.sum)
  result.colW = if sumMax <= avail: maxs
                elif sumMin >= avail: mins
                else: toSeq(0 ..< nc).mapIt(mins[it] + (maxs[it] - mins[it]) * (avail - sumMin) / (sumMax - sumMin))
  # grid lines, then lines of text and row heights
  result.xs = newSeq[float](nc + 1)
  var x = 0.0
  for c in 0 ..< nc:
    result.xs[c] = x
    x += result.vLine[c] + result.colW[c]
  result.xs[nc] = x
  result.width = x + result.vLine[nc]
  result.rowH = newSeq[float](nr)
  var heights: seq[float]
  for k, cell in result.grid.cells:
    var w = -result.vLine[cell.col]
    for c in cell.col ..< cell.col + cell.colspan: w += result.colW[c] + result.vLine[c]
    w -= cell.pad[1] + cell.pad[3] + cell.indent
    if cell.spanner.width > 0: w = max(w, 0)
    result.grid.cells[k].lines = breakLines(cell.words, w, cell.base)
    var h = cell.pad[0] + cell.pad[2]
    for l in result.grid.cells[k].lines: h += l.ascent + l.descent
    if cell.spanner.width > 0: h += 4 + cell.spanner.width
    heights.add h
    if cell.rowspan == 1: result.rowH[cell.row] = max(result.rowH[cell.row], h)
  for k, cell in result.grid.cells:
    if cell.rowspan <= 1: continue
    var have = 0.0
    for r in cell.row ..< cell.row + cell.rowspan: have += result.rowH[r] + (if r > cell.row: result.hLine[r] else: 0)
    if heights[k] > have: result.rowH[cell.row + cell.rowspan - 1] += heights[k] - have
  result.ys = newSeq[float](nr + 1)
  var y = 0.0
  for r in 0 ..< nr:
    result.ys[r] = y
    y += result.hLine[r] + result.rowH[r]
  result.ys[nr] = y
  result.height = y + result.hLine[nr]

# ---------------------------------------------------------------------------------- drawing

type
  MarkKind* = enum mkRect, mkLine, mkText, mkPlot, mkImage
  Mark* = object
    ## One thing to draw, in CSS pixels from the table's top left corner.
    case kind*: MarkKind
    of mkRect:
      fill*: Paint
    of mkLine:
      stroke*: Paint
      width*, dash*: float     ## `dash` is the length of a dash and of a gap (0: solid)
    of mkText:
      text*: string            ## the letters, as written after `text-transform`
      glyphs*: seq[int]        ## the glyph of each letter in `faceFont(face)` (tabular figures applied)
      xs*: seq[float]          ## where each letter starts
      face*: Face
      size*: float
      tabular*: bool
      color*: Paint
    of mkPlot:
      svg*: string             ## a nanoplot's `<svg>` element, as `toHtml` writes it
      fontSize*: float
    of mkImage:
      href*: string            ## a picture's address (a data URL, a path or a URL)
    x*, y*, w*, h*: float      ## a box; for a line, from (x, y) to (x + w, y + h); for text, its baseline at y
  Drawing* = object
    ## A table laid out: its size and the marks that draw it, backgrounds first, then rules
    ## (thin ones first), then text and pictures. Every painter (SVG, pixie) draws these.
    width*, height*: float
    background*: Paint
    marks*: seq[Mark]

proc rect(x, y, w, h: float, p: Paint): Mark = Mark(kind: mkRect, x: x, y: y, w: w, h: h, fill: p)

proc line(x0, y0, x1, y1, width: float, p: Paint, dash = 0.0): Mark =
  Mark(kind: mkLine, x: x0, y: y0, w: x1 - x0, h: y1 - y0, width: width, stroke: p, dash: dash)

proc drawing*(t: Tabella, width = 992.0, vars: Table[string, string] = initTable[string, string]()): Drawing =
  ## The table laid out as Chrome lays out `toHtml` in a page `width` CSS pixels wide, as marks
  ## to draw. `vars` gives the values of the page's CSS variables (`--primary`) for a table that
  ## takes them (`optCssTheme`).
  let lay = place(buildGrid(t, vars), width)
  result.width = lay.width
  result.height = lay.height
  result.background = lay.grid.tableBg
  # backgrounds
  for cell in lay.grid.cells:
    if cell.bg.color.len == 0: continue
    let x0 = lay.xs[cell.col] + lay.vLine[cell.col] / 2
    let x1 = lay.xs[cell.col + cell.colspan] + lay.vLine[cell.col + cell.colspan] / 2
    let y0 = lay.ys[cell.row] + lay.hLine[cell.row] / 2
    let y1 = lay.ys[cell.row + cell.rowspan] + lay.hLine[cell.row + cell.rowspan] / 2
    result.marks.add rect(x0, y0, x1 - x0, y1 - y0, cell.bg)
  # rules: thin ones first, so the strong ones are drawn over them
  type Seg = object
    b: Border
    x0, y0, x1, y1: float
    horizontal: bool
  var segs: seq[Seg]
  for r in 0 .. lay.grid.nrows:
    for c in 0 ..< lay.grid.ncols:
      let b = lay.hEdges[r][c]
      if b.style.len == 0: continue
      let y = lay.ys[r] + lay.hLine[r] / 2
      segs.add Seg(b: b, x0: lay.xs[c], x1: lay.xs[c + 1] + lay.vLine[c + 1], y0: y, y1: y, horizontal: true)
  for r in 0 ..< lay.grid.nrows:
    for c in 0 .. lay.grid.ncols:
      let b = lay.vEdges[r][c]
      if b.style.len == 0: continue
      let x = lay.xs[c] + lay.vLine[c] / 2
      segs.add Seg(b: b, x0: x, x1: x, y0: lay.ys[r], y1: lay.ys[r + 1] + lay.hLine[r + 1])
  segs.sort(proc (a, b: Seg): int = cmp(a.b.width, b.b.width))
  for s in segs:
    case s.b.style
    of "double":
      let w = s.b.width / 3
      let d = s.b.width / 2 - w / 2
      if s.horizontal:
        result.marks.add line(s.x0, s.y0 - d, s.x1, s.y1 - d, w, s.b.color)
        result.marks.add line(s.x0, s.y0 + d, s.x1, s.y1 + d, w, s.b.color)
      else:
        result.marks.add line(s.x0 - d, s.y0, s.x1 - d, s.y1, w, s.b.color)
        result.marks.add line(s.x0 + d, s.y0, s.x1 + d, s.y1, w, s.b.color)
    of "dashed": result.marks.add line(s.x0, s.y0, s.x1, s.y1, s.b.width, s.b.color, 3 * s.b.width)
    of "dotted": result.marks.add line(s.x0, s.y0, s.x1, s.y1, s.b.width, s.b.color, s.b.width)
    else: result.marks.add line(s.x0, s.y0, s.x1, s.y1, s.b.width, s.b.color)
  # text and pictures
  for cell in lay.grid.cells:
    let x0 = lay.xs[cell.col] + lay.vLine[cell.col]
    let x1 = lay.xs[cell.col + cell.colspan]
    let y0 = lay.ys[cell.row] + lay.hLine[cell.row]
    let y1 = lay.ys[cell.row + cell.rowspan]
    var contentH = 0.0
    for l in cell.lines: contentH += l.ascent + l.descent
    let spannerH = if cell.spanner.width > 0: 4 + cell.spanner.width else: 0.0
    let inner = (y1 - y0) - cell.pad[0] - cell.pad[2]
    var y = y0 + cell.pad[0] + (case cell.valign
      of "top": 0.0
      of "bottom": inner - contentH - spannerH
      else: (inner - contentH - spannerH) / 2)
    let left = x0 + cell.pad[3] + cell.indent
    let avail = x1 - cell.pad[1] - left
    for l in cell.lines:
      let baseline = y + l.ascent
      let lx = left + (case cell.align
        of "right": avail - l.w
        of "center": (avail - l.w) / 2
        else: 0.0)
      for k, f in l.frags:
        let fx = lx + l.xs[k]
        let s = f.item.style
        case f.item.kind
        of ikBox:
          let mid = faceFont(cell.base.face).xHeightPx(cell.base.size) / 2
          let by = baseline - mid - f.item.h / 2
          if f.item.image:
            result.marks.add Mark(kind: mkImage, x: fx, y: by, w: f.item.w, h: f.item.h, href: f.item.svg)
          else:
            result.marks.add Mark(kind: mkPlot, x: fx, y: by, w: f.item.w, h: f.item.h, svg: f.item.svg,
                                  fontSize: s.size)
        of ikBreak: discard
        of ikText:
          if f.text.len == 0: continue
          let fc = s.face
          let ty = baseline - s.lift
          var xs: seq[float]
          var ax = fx
          for a in f.adv:
            xs.add ax
            ax += a
          result.marks.add Mark(kind: mkText, x: fx, y: ty, w: f.w, h: s.size, text: f.text,
                                glyphs: faceFont(fc).glyphs(f.text, s.tabular), xs: xs, face: fc,
                                size: s.size, tabular: s.tabular and fc != fMono, color: s.color)
          if s.underline or s.strike:
            let uy = if s.underline: ty + s.size * 0.1 else: ty - s.size * 0.3
            result.marks.add line(fx, uy, fx + f.w, uy, max(1.0, s.size / 16), s.color)
      y += l.ascent + l.descent
    if cell.spanner.width > 0:
      let uy = y + 4 + cell.spanner.width / 2
      result.marks.add line(left, uy, left + avail, uy, cell.spanner.width, cell.spanner.color)
