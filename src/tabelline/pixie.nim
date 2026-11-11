## tabelline/pixie: a table painted as a picture (PNG), with `pixie <https://github.com/treeform/pixie>`_.
## A proof of concept for tabelline 0.3 (research post "A table as a picture"):
##
## ```nim
## import tabelline, tabelline/pixie
## let t = tabella(planets(), rownameCol = "planet"):
##   tabHeader "Planets"
## t.savePng("planets.png")              # scale 2, as a screenshot of the HTML at zoom 2
## let img = t.toImage(scale = 3)        # a pixie Image, to draw on or encode
## ```
##
## pixie is an optional dependency (the `pixie` feature of `tabelline.nimble`): only this module
## needs it, and the core of tabelline still needs only Nim's standard library.
##
## How it works, in three steps:
##
## 1. **Cells.** The table is built as for HTML (`build(rcHtml)`), and laid out as a grid of cells
##    the way `toHtml` writes its `<table>`: the title, the spanners and column labels, the groups
##    and rows, the summary rows, the notes. Each cell gets the look `tabellaCss` gives its classes
##    (read from the options), then its own styles (`tabStyle`, `dataColor`), read by a small CSS
##    reader. Its HTML (Markdown turned into `<strong>`, `<em>`, `<code>`; footnote marks;
##    nanoplots' `<svg>`; images' `<img>`) becomes runs of text and pictures.
## 2. **Layout.** Every run is measured with the fonts (Inter and DejaVu Sans Mono, vendored, so
##    the picture is the same on every machine), lines are broken at spaces, the columns get their
##    widths as a browser's automatic table layout does (between the longest word and the longest
##    line), then the rows their heights. Borders collapse as in CSS: on a line between two cells,
##    the wider border wins.
## 3. **Paint.** Backgrounds, text (pixie places each glyph, with kerning), borders, nanoplots
##    (pixie's SVG reader, which has no `<text>`, so their labels are drawn apart) and images.

import std/[strutils, tables, math, base64, sequtils, os, uri]
from std/unicode import Rune, runes, isWhiteSpace, toUpper, toLower, `$`, `==`
from std/htmlparser import entityToUtf8
import pkg/pixie, pkg/pixie/fileformats/svg
import ./core, ./build, ./render_html, ./formats

const fontDir = currentSourcePath().parentDir / "fonts"

type
  PictureFonts* = object
    ## The typefaces a picture is drawn with: one for each of the four styles of the text, and a
    ## monospaced one (`code`, nanoplot labels). Each may have `fallbacks` for the letters it
    ## lacks (pixie looks there for any rune the typeface does not have).
    regular*, bold*, italic*, boldItalic*, mono*: Typeface

  RunStyle = object
    bold, italic, mono, underline, strike: bool
    color: Color
    hasColor: bool
    size: float32          ## font size, as a factor of the cell's
    shift: float32         ## baseline shift up, in em of the cell's font

  PieceKind = enum pkText, pkSpace, pkBreak, pkSvg, pkImage
  Piece = object
    kind: PieceKind
    text: string
    style: RunStyle
    svg: string                       ## pkSvg: the nanoplot, as written
    image: Image                      ## pkImage: the decoded picture (or nil)
    heightCss, widthCss: string       ## pkSvg, pkImage: from the `style`
    w, h: float32                     ## measured (px)

  Side = object
    width: float32
    style: string
    color: Color

  Line = object
    pieces: seq[Piece]   ## spaces kept, but not at the start or the end
    width, ascent, descent: float32

  Cell = object
    row, col, rowSpan, colSpan: int
    pieces: seq[Piece]
    size: float32
    bold, italic, mono: bool
    color: Color
    bg: Color
    hasBg: bool
    align, valign: string
    pad: array[4, float32]       ## top, right, bottom, left
    border: array[4, Side]       ## top, right, bottom, left
    indent: float32
    transform: string            ## uppercase, lowercase, capitalize
    width: float32               ## a column's own width (`colsWidth`), in px; 0 for none
    widthPct: float32            ## or in % of the table
    spannerRule: Side            ## the rule under a spanner's label
    minW, maxW: float32
    lines: seq[Line]
    contentH: float32

  Picture* = object
    ## A laid-out table: its size in CSS pixels, before it is painted at a scale.
    width*, height*: float32

proc loadFont(name: string): Typeface = parseTtf(readFile(fontDir / name))

var pictureFontsCache {.threadvar.}: PictureFonts

proc pictureFonts*(): PictureFonts =
  ## Inter 4.1 (regular, bold, italic, bold italic; SIL Open Font License) and DejaVu Sans Mono,
  ## from `src/tabelline/fonts/`: the fonts Chrome draws the HTML table with in a Linux sandbox
  ## (`system-ui` is Inter there), so the two pictures can be compared.
  if pictureFontsCache.regular == nil:
    pictureFontsCache = PictureFonts(regular: loadFont("Inter-Regular.ttf"), bold: loadFont("Inter-Bold.ttf"),
                              italic: loadFont("Inter-Italic.ttf"), boldItalic: loadFont("Inter-BoldItalic.ttf"),
                              mono: loadFont("DejaVuSansMono.ttf"))
  pictureFontsCache

proc withFallbacks*(f: PictureFonts, fallbacks: seq[Typeface]): PictureFonts =
  ## The same fonts, each looking in `fallbacks` for the letters it does not have (CJK, Hebrew...).
  ## A typeface is a reference: this changes `f`'s typefaces too (the default ones included).
  result = f
  for tf in [result.regular, result.bold, result.italic, result.boldItalic, result.mono]:
    tf.fallbacks = fallbacks

# ---------------------------------------------------------------------------------------------
# CSS values

proc resolveVars(v: string, vars: Table[string, string]): string =
  ## `var(--name, fallback)` replaced by `vars["--name"]`, or else by the fallback.
  result = v.strip
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
    let inner = result[a + 4 ..< min(b, result.len)]
    let comma = inner.find(',')
    let name = (if comma < 0: inner else: inner[0 ..< comma]).strip
    let fallback = if comma < 0: "" else: inner[comma + 1 .. ^1].strip
    let value = vars.getOrDefault(name, fallback)
    result = result[0 ..< a] & value & result[min(b + 1, result.len) .. ^1]

proc cssColor(v: string, fallback: Color, ok: var bool): Color =
  let s = v.strip.toLowerAscii
  ok = true
  if s.len == 0 or s in ["inherit", "initial", "currentcolor"]:
    ok = false
    return fallback
  if s == "transparent" or s == "none": return color(0, 0, 0, 0)
  if s.startsWith("#") and s.len == 9:
    result = parseHtmlHex(s[0 .. 6])
    result.a = fromHex[int](s[7 .. 8]).float32 / 255
    return
  try: parseHtmlColor(s)
  except CatchableError:
    ok = false
    fallback

proc cssColor(v: string, fallback = color(0, 0, 0, 1)): Color =
  var ok: bool
  cssColor(v, fallback, ok)

proc cssLength(v: string, fontSize: float32, base = 0'f32): float32 =
  ## A length in px: px, pt, em, rem, %, or a bare number.
  let s = v.strip.toLowerAscii
  try:
    if s.endsWith("px"): parseFloat(s[0 .. ^3]).float32
    elif s.endsWith("rem"): parseFloat(s[0 .. ^4]).float32 * 16
    elif s.endsWith("em"): parseFloat(s[0 .. ^3]).float32 * fontSize
    elif s.endsWith("pt"): parseFloat(s[0 .. ^3]).float32 * 4 / 3
    elif s.endsWith("%"): parseFloat(s[0 .. ^2]).float32 / 100 * base
    elif s.len > 0: parseFloat(s).float32
    else: 0
  except ValueError: 0

proc fontSize(v: string, parent: float32): float32 =
  let s = v.strip.toLowerAscii
  case s
  of "", "inherit", "initial", "medium": parent
  of "small": 13
  of "smaller": parent * 0.83
  of "larger": parent * 1.2
  of "large": 18
  of "x-small": 10
  of "x-large": 24
  else: cssLength(s, parent, parent)

proc isBold(v: string, current: bool): bool =
  case v.strip.toLowerAscii
  of "bold", "bolder", "600", "700", "800", "900": true
  of "normal", "initial", "lighter", "100", "200", "300", "400", "500": false
  else: current

proc parseSide(v: string, cellSize: float32): Side =
  ## `2px solid #D3D3D3` (in any order).
  result = Side(style: "solid", color: cssColor("#000000"))
  for part in v.splitWhitespace:
    let p = part.toLowerAscii
    if p in ["none", "hidden"]: return Side()
    elif p in ["solid", "double", "dashed", "dotted", "groove", "ridge", "inset", "outset"]: result.style = p
    elif p[0].isDigit or p[0] == '.': result.width = cssLength(p, cellSize)
    elif p == "thin": result.width = 1
    elif p == "medium": result.width = 3
    elif p == "thick": result.width = 5
    else: result.color = cssColor(p, result.color)
  if result.width == 0 and result.style.len > 0 and v.strip.len > 0 and
     not v.splitWhitespace.anyIt(it[0].isDigit): result.width = 3

proc sideOf(width, style, color: string, vars: Table[string, string], size: float32): Side =
  parseSide(resolveVars(width, vars) & " " & resolveVars(style, vars) & " " & resolveVars(color, vars), size)

proc boxValues(v: string, size: float32): seq[float32] =
  for p in v.splitWhitespace: result.add cssLength(p, size)

proc applyCss(c: var Cell, css: string, vars: Table[string, string]) =
  ## The declarations of a `style` (later ones win), on a cell.
  for decl in css.split(';'):
    let k = decl.find(':')
    if k < 0: continue
    let name = decl[0 ..< k].strip.toLowerAscii
    let value = resolveVars(decl[k + 1 .. ^1].replace("!important", ""), vars)
    case name
    of "color": c.color = cssColor(value, c.color)
    of "background-color", "background":
      var ok: bool
      let col = cssColor(value, c.bg, ok)
      if ok:
        c.bg = col
        c.hasBg = col.a > 0
    of "font-weight": c.bold = isBold(value, c.bold)
    of "font-style": c.italic = value.strip.toLowerAscii in ["italic", "oblique"]
    of "font-size": c.size = fontSize(value, c.size)
    of "font-family":
      c.mono = "mono" in value.toLowerAscii or "courier" in value.toLowerAscii
    of "text-align": c.align = value.strip.toLowerAscii
    of "vertical-align": c.valign = value.strip.toLowerAscii
    of "text-transform": c.transform = value.strip.toLowerAscii
    of "text-indent": c.indent = cssLength(value, c.size)
    of "padding":
      let b = boxValues(value, c.size)
      case b.len
      of 1: c.pad = [b[0], b[0], b[0], b[0]]
      of 2: c.pad = [b[0], b[1], b[0], b[1]]
      of 3: c.pad = [b[0], b[1], b[2], b[1]]
      of 4: c.pad = [b[0], b[1], b[2], b[3]]
      else: discard
    of "padding-top": c.pad[0] = cssLength(value, c.size)
    of "padding-right": c.pad[1] = cssLength(value, c.size)
    of "padding-bottom": c.pad[2] = cssLength(value, c.size)
    of "padding-left": c.pad[3] = cssLength(value, c.size)
    of "border":
      let s = parseSide(value, c.size)
      for i in 0 .. 3: c.border[i] = s
    of "border-top": c.border[0] = parseSide(value, c.size)
    of "border-right": c.border[1] = parseSide(value, c.size)
    of "border-bottom": c.border[2] = parseSide(value, c.size)
    of "border-left": c.border[3] = parseSide(value, c.size)
    else: discard   # not drawn: letter-spacing, font-variant, text-decoration on the cell...

# ---------------------------------------------------------------------------------------------
# HTML of a cell -> pieces

proc decodeEntities(s: string): string =
  var i = 0
  while i < s.len:
    if s[i] == '&':
      let j = s.find(';', i)
      if j > i and j - i < 12:
        let name = s[i + 1 ..< j]
        var r = ""
        if name.startsWith("#x") or name.startsWith("#X"):
          try: r = $Rune(fromHex[int](name[2 .. ^1])) except ValueError: discard
        elif name.startsWith("#"):
          try: r = $Rune(parseInt(name[1 .. ^1])) except ValueError: discard
        else: r = entityToUtf8(name)
        if r.len > 0:
          result.add r
          i = j + 1
          continue
    result.add s[i]
    inc i

proc attr(tag, name: string): string =
  ## The value of an attribute in an opening tag (`"` or `'` quotes).
  var i = 0
  while true:
    i = tag.find(name & "=", i)
    if i < 0: return ""
    if i > 0 and tag[i - 1] notin {' ', '\t', '\n'}:
      inc i
      continue
    let q = tag[i + name.len + 1]
    if q in {'"', '\''}:
      let e = tag.find(q, i + name.len + 2)
      return decodeEntities(tag[i + name.len + 2 ..< e])
    return ""

proc styleProp(style, name: string): string =
  for decl in style.split(';'):
    let k = decl.find(':')
    if k > 0 and decl[0 ..< k].strip.toLowerAscii == name: return decl[k + 1 .. ^1].strip

proc decodeDataUrl(src: string): Image =
  ## A picture from a data URL (PNG, JPEG, GIF, BMP, QOI; SVG through pixie's reader) or a file.
  try:
    if src.startsWith("data:"):
      let comma = src.find(',')
      let meta = src[5 ..< comma]
      let raw = if meta.endsWith(";base64"): base64.decode(src[comma + 1 .. ^1])
                else: decodeUrl(src[comma + 1 .. ^1])
      if "svg" in meta: return newImage(parseSvg(raw))
      return decodeImage(raw)
    elif fileExists(src):
      if src.endsWith(".svg"): return newImage(parseSvg(readFile(src)))
      return readImage(src)
  except CatchableError: discard
  nil

proc addText(res: var seq[Piece], st: RunStyle, s: string) =
  ## Text as words and spaces (white space collapses, as in HTML; no-break, figure and
  ## punctuation spaces stay in their word).
  var word = ""
  for r in decodeEntities(s).runes:
    if r.isWhiteSpace and r != Rune(0xA0) and r != Rune(0x2007) and r != Rune(0x2008):
      if word.len > 0: res.add Piece(kind: pkText, text: word, style: st)
      word = ""
      if res.len == 0 or res[^1].kind != pkSpace: res.add Piece(kind: pkSpace, text: " ", style: st)
    else: word.add $r
  if word.len > 0: res.add Piece(kind: pkText, text: word, style: st)

proc parseCellHtml(html: string, vars: Table[string, string]): seq[Piece] =
  ## The HTML that tabelline writes in a cell, as pieces: text runs with their style, spaces,
  ## line breaks, nanoplots and images. Tags it does not know keep their text.
  var stack = @[RunStyle(size: 1)]
  var closers: seq[string]    # the tag each stack level was opened by
  var i = 0
  while i < html.len:
    if html[i] == '<':
      let e = html.find('>', i)
      if e < 0: (result.addText(stack[^1], html[i .. ^1]); break)
      let tag = html[i + 1 ..< e]
      let name = tag.split({' ', '/', '\n'})[0].toLowerAscii
      if tag.startsWith("/"):
        let closing = tag[1 .. ^1].strip.toLowerAscii
        var k = closers.high
        while k >= 0 and closers[k] != closing: dec k
        if k >= 0:
          stack.setLen(k + 1)
          closers.setLen(k)
        if closing == "p": result.add Piece(kind: pkBreak)
        i = e + 1
        continue
      case name
      of "svg":
        let close = html.find("</svg>", e)
        let stop = if close < 0: html.len else: close + 6
        let svg = html[i ..< stop]
        result.add Piece(kind: pkSvg, svg: svg, style: stack[^1],
                         heightCss: styleProp(attr(tag, "style"), "height"),
                         widthCss: styleProp(attr(tag, "style"), "width"))
        i = stop
        continue
      of "img":
        let st = attr(tag, "style")
        var h = styleProp(st, "height")
        var w = styleProp(st, "width")
        if h.len == 0 and attr(tag, "height").len > 0: h = attr(tag, "height") & "px"
        if w.len == 0 and attr(tag, "width").len > 0: w = attr(tag, "width") & "px"
        result.add Piece(kind: pkImage, image: decodeDataUrl(attr(tag, "src")), style: stack[^1],
                         heightCss: h, widthCss: w)
      of "br":
        result.add Piece(kind: pkBreak)
      else:
        if not tag.endsWith("/"):
          var st = stack[^1]
          case name
          of "strong", "b": st.bold = true
          of "em", "i", "cite": st.italic = true
          of "code", "kbd", "samp", "tt": st.mono = true
          of "u", "ins": st.underline = true
          of "s", "del", "strike": st.strike = true
          of "sup":
            st.shift += 0.33 * st.size
            st.size *= 0.83
          of "sub":
            st.shift -= 0.2 * st.size
            st.size *= 0.83
          of "span", "a", "div", "p", "small", "mark":
            if name == "small": st.size *= 0.83
            let cls = attr(tag, "class")
            if "tb_footnote_marks" in cls:   # as tabellaCss: 75%, raised by 0.4em, plain
              st.size *= 0.75
              st.shift += 0.4 * st.size
              st.bold = false
              st.italic = false
            let style = attr(tag, "style")
            for decl in style.split(';'):
              let k = decl.find(':')
              if k < 0: continue
              let n = decl[0 ..< k].strip.toLowerAscii
              let v = resolveVars(decl[k + 1 .. ^1], vars)
              case n
              of "color": (st.color = cssColor(v, st.color); st.hasColor = true)
              of "font-weight": st.bold = isBold(v, st.bold)
              of "font-style": st.italic = v.strip.toLowerAscii in ["italic", "oblique"]
              of "font-size":
                let px = fontSize(v, 16 * st.size)
                st.size = px / 16
              of "vertical-align":
                if v.strip == "baseline": st.shift = 0
              of "font-family": st.mono = "mono" in v.toLowerAscii
              else: discard
          else: discard
          stack.add st
          closers.add name
      i = e + 1
    else:
      let e = html.find('<', i)
      let stop = if e < 0: html.len else: e
      result.addText(stack[^1], html[i ..< stop])
      i = stop

# ---------------------------------------------------------------------------------------------
# Measuring and breaking lines

proc fontOf(f: PictureFonts, c: Cell, st: RunStyle, px: float32): Font =
  let bold = c.bold or st.bold
  let italic = c.italic or st.italic
  let tf = if c.mono or st.mono: f.mono
           elif bold and italic: f.boldItalic
           elif bold: f.bold
           elif italic: f.italic
           else: f.regular
  result = newFont(tf)
  result.size = px
  result.paint.color = if st.hasColor: st.color else: c.color
  result.underline = st.underline
  result.strikethrough = st.strike

proc transformText(s, how: string): string =
  case how
  of "uppercase": s.toUpper
  of "lowercase": s.toLower
  of "capitalize": (if s.len > 0: s[0].toUpperAscii & s[1 .. ^1] else: s)
  else: s

proc ascentOf(font: Font): float32 = round(font.typeface.ascent * font.scale)
  ## Rounded to a pixel, as Chrome rounds a font's ascent and descent: Inter at 16px has a line
  ## of 16 + 4 = 20px, not 19.4
proc descentOf(font: Font): float32 = round(-font.typeface.descent * font.scale)

proc measure(f: PictureFonts, c: var Cell) =
  ## The size of every piece, and the cell's narrowest (longest word) and widest (no breaks)
  ## content.
  var word, line: float32
  c.minW = 0
  c.maxW = 0
  for p in c.pieces.mitems:
    case p.kind
    of pkText, pkSpace:
      let font = fontOf(f, c, p.style, c.size * p.style.size)
      p.text = transformText(p.text, c.transform)
      p.w = font.layoutBounds(p.text).x
    of pkSvg, pkImage:
      let em = c.size * p.style.size
      var h = if p.heightCss.len > 0: cssLength(p.heightCss, em) else: 0
      var w = if p.widthCss.len > 0: cssLength(p.widthCss, em) else: 0
      var ratio = 1'f32
      if p.kind == pkSvg:
        let vb = attr(p.svg[0 ..< p.svg.find('>')], "viewBox").splitWhitespace
        if vb.len == 4:
          try: ratio = parseFloat(vb[2]) / parseFloat(vb[3]) except ValueError: discard
      elif p.image != nil: ratio = p.image.width / p.image.height
      if h == 0 and w == 0: h = (if p.kind == pkSvg: 2 * em else: (if p.image != nil: p.image.height.float32 else: em))
      if w == 0: w = h * ratio
      if h == 0: h = w / ratio
      p.w = w
      p.h = h
    of pkBreak: discard
    case p.kind
    of pkSpace, pkBreak:
      c.minW = max(c.minW, word)
      word = 0
      if p.kind == pkBreak:
        c.maxW = max(c.maxW, line)
        line = 0
      else: line += p.w
    else:
      word += p.w
      line += p.w
  c.minW = max(c.minW, word) + c.indent
  c.maxW = max(c.maxW, line) + c.indent

proc lineMetrics(f: PictureFonts, c: Cell, l: var Line) =
  ## The line's ascent and descent: the cell's font (the strut), then each piece.
  let strut = fontOf(f, c, RunStyle(size: 1), c.size)
  l.ascent = strut.ascentOf
  l.descent = strut.descentOf
  let xh = c.size * 0.27     # half the x-height of Inter (0.546 em): where `middle` aligns
  for p in l.pieces:
    case p.kind
    of pkText:
      let font = fontOf(f, c, p.style, c.size * p.style.size)
      l.ascent = max(l.ascent, font.ascentOf + p.style.shift * c.size)
      l.descent = max(l.descent, font.descentOf - p.style.shift * c.size)
    of pkSvg, pkImage:
      l.ascent = max(l.ascent, xh + p.h / 2)
      l.descent = max(l.descent, p.h / 2 - xh)
    else: discard

proc breakLines(f: PictureFonts, c: var Cell, width: float32) =
  ## Greedy line breaking at spaces, in `width` (the content box).
  c.lines = @[Line()]
  var i = 0
  let ps = c.pieces
  proc finish(l: var Line) =
    while l.pieces.len > 0 and l.pieces[^1].kind == pkSpace:
      l.width -= l.pieces[^1].w
      l.pieces.setLen(l.pieces.len - 1)
  while i < ps.len:
    let p = ps[i]
    case p.kind
    of pkBreak:
      finish(c.lines[^1])
      c.lines.add Line()
      inc i
    of pkSpace:
      if c.lines[^1].pieces.len > 0:
        c.lines[^1].pieces.add p
        c.lines[^1].width += p.w
      inc i
    else:
      # a word: the pieces up to the next space or break
      var j = i
      var w = 0'f32
      while j < ps.len and ps[j].kind notin {pkSpace, pkBreak}:
        w += ps[j].w
        inc j
      let indent = if c.lines.len == 1: c.indent else: 0
      if c.lines[^1].pieces.len > 0 and c.lines[^1].width + w + indent > width + 0.01:
        finish(c.lines[^1])
        c.lines.add Line()
      for k in i ..< j:
        c.lines[^1].pieces.add ps[k]
      c.lines[^1].width += w
      i = j
  finish(c.lines[^1])
  c.contentH = 0
  for l in c.lines.mitems:
    lineMetrics(f, c, l)
    c.contentH += l.ascent + l.descent
  if c.lines.len == 1 and c.lines[0].pieces.len == 0 and c.pieces.len == 0:
    c.contentH = 0   # an empty cell: no line box
    c.lines = @[]
  if c.spannerRule.width > 0: c.contentH += 4 + c.spannerRule.width

# ---------------------------------------------------------------------------------------------
# Cells, as toHtml writes them

type Grid = object
  cells: seq[Cell]
  nrows, ncols: int
  tableBg: Color
  outer: array[4, Side]   ## the table's own borders: top, right, bottom, left

proc newCell(row, col: int, html: string, size: float32, color: Color, vars: Table[string, string],
             rowSpan = 1, colSpan = 1): Cell =
  Cell(row: row, col: col, rowSpan: rowSpan, colSpan: colSpan, pieces: parseCellHtml(html, vars),
       size: size, color: color, align: "left", valign: "middle")

proc alignOf(a: Align): string =
  case a
  of alLeft, alAuto: "left"
  of alCenter: "center"
  of alRight: "right"

proc grid(t: Tabella, vars: Table[string, string]): Grid =
  let b = t.build(rcHtml)
  let o = t.options
  proc v(s: string, fallback = ""): string =
    ## An option's value, with page variables resolved; "" falls back.
    let r = resolveVars(s, vars)
    if r.len == 0: resolveVars(fallback, vars) else: r
  let base = cssLength(v(o.tableFontSize), 16, 16)
  let ink = cssColor(v(o.tableFontColor), cssColor("#333333"))
  let tableBg = cssColor(v(o.tableBackgroundColor), cssColor("#FFFFFF"))
  result.tableBg = tableBg
  let ncols = max(1, b.columns.len + t.stubWidth)
  result.ncols = ncols
  let tableBold = isBold(v(o.tableFontWeight), false)
  let tableItalic = v(o.tableFontStyle) == "italic"
  proc side(w, s, c: string, size = base): Side = sideOf(w, s, c, vars, size)
  proc pct(s: string): float32 = fontSize(v(s), base)
  proc bgOf(s: string, fallback = ""): (bool, Color) =
    var ok: bool
    let c = cssColor(v(s, fallback), tableBg, ok)
    (ok and c.a > 0, c)
  var g = addr result
  var row = 0
  proc add(c: var Cell, key = "") =
    c.bold = c.bold or tableBold
    c.italic = c.italic or tableItalic
    if key.len > 0 and key in b.styles: c.applyCss(b.styles[key], vars)
    g.cells.add c

  result.outer[0] = side(o.tableBorderTopWidth, o.tableBorderTopStyle, o.tableBorderTopColor)
  result.outer[2] = side(o.tableBorderBottomWidth, o.tableBorderBottomStyle, o.tableBorderBottomColor)
  result.outer[3] = side(o.tableBorderLeftWidth, o.tableBorderLeftStyle, o.tableBorderLeftColor)
  result.outer[1] = side(o.tableBorderRightWidth, o.tableBorderRightStyle, o.tableBorderRightColor)

  # the heading
  let headBg = bgOf(o.headingBackgroundColor, o.tableBackgroundColor)
  let headingRule = side(o.headingBorderBottomWidth, o.headingBorderBottomStyle, o.headingBorderBottomColor)
  let hp = cssLength(v(o.headingPadding), base)
  let hph = cssLength(v(o.headingPaddingHorizontal), base)
  if not t.title.isEmpty:
    var c = newCell(row, 0, t.title.renderText(rcHtml) & b.marksHtml("title", o), pct(o.headingTitleFontSize), ink, vars, colSpan = ncols)
    c.align = v(o.headingAlign)
    c.bold = isBold(v(o.headingTitleFontWeight), false)
    c.pad = [hp, hph, hp, hph]
    (c.hasBg, c.bg) = headBg
    if t.subtitle.isEmpty: c.border[2] = headingRule
    add(c, "title")
    inc row
    if not t.subtitle.isEmpty:
      var s = newCell(row, 0, t.subtitle.renderText(rcHtml) & b.marksHtml("subtitle", o), pct(o.headingSubtitleFontSize), ink, vars, colSpan = ncols)
      s.align = v(o.headingAlign)
      s.bold = isBold(v(o.headingSubtitleFontWeight), false)
      s.pad = [0'f32, hph, hp, hph]
      (s.hasBg, s.bg) = headBg
      s.border[2] = headingRule
      add(s, "subtitle")
      inc row

  # the column labels
  let sw = t.stubWidth
  if not o.columnLabelsHidden:
    let levels = t.spannerLevels(b.columns)
    let labelBg = bgOf(o.columnLabelsBackgroundColor, o.tableBackgroundColor)
    let lsize = pct(o.columnLabelsFontSize)
    let lp = cssLength(v(o.columnLabelsPadding), base)
    let lph = cssLength(v(o.columnLabelsPaddingHorizontal), base)
    let lastRule = side(o.columnLabelsBorderBottomWidth, o.columnLabelsBorderBottomStyle, o.columnLabelsBorderBottomColor)
    let topRule = side(o.columnLabelsBorderTopWidth, o.columnLabelsBorderTopStyle, o.columnLabelsBorderTopColor)
    let lblBold = isBold(v(o.columnLabelsFontWeight), false)
    let transform = v(o.columnLabelsTextTransform)
    proc label(c: var Cell, r: int) =
      c.pad = [lp, lph, lp, lph]
      c.valign = "bottom"
      c.bold = lblBold
      c.transform = transform
      (c.hasBg, c.bg) = labelBg
      if r == row and (not t.title.isEmpty or true): c.border[0] = topRule
    proc hasAnySpanner(c: ColInfo): bool =
      for lv in 1 .. levels:
        if t.spannerAt(c.name, lv) >= 0: return true
    let first = row
    for lv in countdown(levels, 1):
      if lv == levels and sw > 0:
        var c = newCell(row, 0, t.stubhead.renderLabel(rcHtml) & b.marksHtml("stubhead", o), lsize, ink, vars,
                        rowSpan = levels + 1, colSpan = sw)
        label(c, first)
        add(c, "stubhead")
      var j = 0
      while j < b.columns.len:
        let col = b.columns[j]
        if not col.hasAnySpanner:
          if lv == levels:
            var c = newCell(row, sw + j, col.columnLabel(rcHtml, o.columnLabelsUnitsPattern) & b.marksHtml(colKey(col.name), o),
                            lsize, ink, vars, rowSpan = levels + 1)
            label(c, first)
            c.align = alignOf(col.align)
            c.border[2] = lastRule
            if col.width.endsWith("%"): c.widthPct = cssLength(col.width, base, 100)
            elif col.width.len > 0: c.width = cssLength(col.width, base)
            add(c, colKey(col.name))
          inc j
          continue
        let k = t.spannerAt(col.name, lv)
        var span = 1
        while j + span < b.columns.len and t.spannerAt(b.columns[j + span].name, lv) == k and
              (k >= 0 or b.columns[j + span].hasAnySpanner):
          inc span
        if k >= 0:
          let s = t.spanners[k]
          let key = spannerKey(s.label.s)
          var c = newCell(row, sw + j, s.label.renderLabel(rcHtml) & b.marksHtml(key, o), lsize, ink, vars, colSpan = span)
          label(c, first)
          c.align = "center"
          c.spannerRule = Side(width: 2, style: "solid", color: cssColor(v(o.columnLabelsBorderBottomColor), cssColor("#D3D3D3")))
          add(c, key)
        j += span
      inc row
    if levels == 0 and sw > 0:
      var c = newCell(row, 0, t.stubhead.renderLabel(rcHtml) & b.marksHtml("stubhead", o), lsize, ink, vars, colSpan = sw)
      label(c, first)
      c.border[2] = lastRule
      add(c, "stubhead")
    for j, col in b.columns:
      if levels == 0 or col.hasAnySpanner:
        var c = newCell(row, sw + j, col.columnLabel(rcHtml, o.columnLabelsUnitsPattern) & b.marksHtml(colKey(col.name), o), lsize, ink, vars)
        label(c, first)
        c.align = alignOf(col.align)
        c.border[2] = lastRule
        if col.width.endsWith("%"): c.widthPct = cssLength(col.width, base, 100)
        elif col.width.len > 0: c.width = cssLength(col.width, base)
        add(c, colKey(col.name))
    inc row

  # the body
  let rp = cssLength(v(o.dataRowPadding), base)
  let rph = cssLength(v(o.dataRowPaddingHorizontal), base)
  let hline = side(o.tableBodyHlinesWidth, o.tableBodyHlinesStyle, o.tableBodyHlinesColor)
  let vline = if o.tableBodyVlinesColor.len > 0: side(o.tableBodyVlinesWidth, o.tableBodyVlinesStyle, o.tableBodyVlinesColor) else: Side()
  let stubRule = if o.stubSeparate: side(o.stubBorderWidth, o.stubBorderStyle, v(o.stubBorderColor, o.tableBodyHlinesColor)) else: Side()
  let stubBg = bgOf(o.stubBackgroundColor)
  let stubBold = isBold(v(o.stubFontWeight), false)
  let stripe = bgOf(o.rowStripingBackgroundColor)
  let asColumn = t.groupAsColumn
  let stubSpan = 1 + t.stubCols.len
  let bodyTop = side(o.tableBodyBorderTopWidth, o.tableBodyBorderTopStyle, o.tableBodyBorderTopColor)
  let bodyBottom = side(o.tableBodyBorderBottomWidth, o.tableBodyBorderBottomStyle, o.tableBodyBorderBottomColor)
  let firstBody = row
  var firstTr = true
  proc bodyCell(r, col: int, html: string, align: string, rowSpan = 1, colSpan = 1): Cell =
    result = newCell(r, col, html, base, ink, vars, rowSpan, colSpan)
    result.pad = [rp, rph, rp, rph]
    result.align = align
    if not firstTr: result.border[0] = hline
    result.border[1] = vline
    result.border[3] = vline
  proc stubCell(c: var Cell) =
    c.bold = stubBold
    c.size = pct(o.stubFontSize)
    c.transform = v(o.stubTextTransform)
    c.border[1] = stubRule
    (c.hasBg, c.bg) = stubBg
  var pendingGroup: (bool, Cell)
  proc summaryRows(ss: seq[BuiltSummary], grand, top: bool) =
    let span = if grand: sw else: stubSpan
    let (rule, pad, padh, bg) =
      if grand: (side(o.grandSummaryRowBorderWidth, o.grandSummaryRowBorderStyle, o.grandSummaryRowBorderColor),
                 cssLength(v(o.grandSummaryRowPadding), base), cssLength(v(o.grandSummaryRowPaddingHorizontal), base),
                 bgOf(o.grandSummaryRowBackgroundColor))
      else: (side(o.summaryRowBorderWidth, o.summaryRowBorderStyle, o.summaryRowBorderColor),
             cssLength(v(o.summaryRowPadding), base), cssLength(v(o.summaryRowPaddingHorizontal), base),
             bgOf(o.summaryRowBackgroundColor))
    let transform = v(if grand: o.grandSummaryRowTextTransform else: o.summaryRowTextTransform)
    for k, s in ss:
      var col0 = 0
      if not grand and pendingGroup[0]:
        add(pendingGroup[1], groupKey(""))
        pendingGroup[0] = false
      if not grand and asColumn: col0 = 1
      proc dress(c: var Cell) =
        c.pad = [pad, padh, pad, padh]
        c.transform = transform
        (c.hasBg, c.bg) = bg
        if not top and k == 0: c.border[0] = rule
        if top and k == ss.high: c.border[2] = rule
      var st = newCell(row, col0, s.label & b.marksHtml(s.key, o), base, ink, vars, colSpan = max(1, span))
      stubCell(st)
      dress(st)
      add(st, s.key)
      for j, col in b.columns:
        let key = s.key & col.name
        var c = newCell(row, sw + j, s.cells[j] & b.marksHtml(key, o), base, ink, vars)
        c.align = alignOf(col.align)
        dress(c)
        add(c, key)
      inc row
      firstTr = false
  summaryRows(b.grandTop, true, true)
  let groupBg = bgOf(o.rowGroupBackgroundColor, o.tableBackgroundColor)
  for gr in b.groups:
    let gk = groupKey(gr.id)
    var striped = false
    if asColumn:
      let n = gr.summaryTop.len + gr.rows.len + gr.summaryBottom.len
      var c = bodyCell(row, 0, gr.label & b.marksHtml(gk, o), "left", rowSpan = max(1, n))
      c.size = pct(o.stubRowGroupFontSize)
      c.bold = isBold(v(o.stubRowGroupFontWeight), false)
      c.transform = v(o.stubRowGroupTextTransform)
      c.valign = "top"
      c.border[1] = side(o.stubRowGroupBorderWidth, o.stubRowGroupBorderStyle, o.stubRowGroupBorderColor)
      if b.styles.hasKey(gk): c.applyCss(b.styles[gk], vars)
      pendingGroup = (true, c)
    elif gr.id.len > 0 or gr.label.len > 0:
      var c = newCell(row, 0, gr.label & b.marksHtml(gk, o), pct(o.rowGroupFontSize), ink, vars, colSpan = ncols)
      c.bold = isBold(v(o.rowGroupFontWeight), false)
      c.transform = v(o.rowGroupTextTransform)
      let gp = cssLength(v(o.rowGroupPadding), base)
      let gph = cssLength(v(o.rowGroupPaddingHorizontal), base)
      c.pad = [gp, gph, gp, gph]
      (c.hasBg, c.bg) = groupBg
      c.border[0] = side(o.rowGroupBorderTopWidth, o.rowGroupBorderTopStyle, v(o.rowGroupBorderTopColor, o.rowGroupBorderColor))
      c.border[2] = side(o.rowGroupBorderBottomWidth, o.rowGroupBorderBottomStyle, v(o.rowGroupBorderBottomColor, o.rowGroupBorderColor))
      c.border[3] = side(o.rowGroupBorderLeftWidth, o.rowGroupBorderLeftStyle, o.rowGroupBorderLeftColor)
      c.border[1] = side(o.rowGroupBorderRightWidth, o.rowGroupBorderRightStyle, o.rowGroupBorderRightColor)
      add(c, gk)
      inc row
      firstTr = false
    summaryRows(gr.summaryTop, false, true)
    for r in gr.rows:
      var col = 0
      if pendingGroup[0]:
        add(pendingGroup[1])
        pendingGroup[0] = false
      if asColumn: col = 1
      let on = o.rowStriping and striped
      for k, sc in t.stubCols:
        if r.spans[k] == 0:
          inc col
          continue
        let key = cellKey(r.index, sc)
        var c = bodyCell(row, col, r.levels[k] & b.marksHtml(key, o), "left", rowSpan = r.spans[k])
        stubCell(c)
        c.border[1] = Side()
        c.valign = "top"
        add(c, key)
        inc col
      if t.hasStub:
        let key = cellKey(r.index, t.rownameCol)
        var c = bodyCell(row, col, r.stub & b.marksHtml(key, o), "left")
        stubCell(c)
        if r.indent > 0: c.indent = r.indent.float32 * cssLength(v(o.stubIndentLength), base)
        if on and o.rowStripingIncludeStub: (c.hasBg, c.bg) = stripe
        add(c, key)
      for j, column in b.columns:
        let key = cellKey(r.index, column.name)
        var c = bodyCell(row, sw + j, r.cells[j] & b.marksHtml(key, o), alignOf(column.align))
        if on and o.rowStripingIncludeTableBody: (c.hasBg, c.bg) = stripe
        add(c, key)
      inc row
      firstTr = false
      striped = not striped
    summaryRows(gr.summaryBottom, false, false)
  summaryRows(b.grandBottom, true, false)
  if row == firstBody:
    var c = bodyCell(row, 0, escapeHtml(o.tableNoDataMessage), "center", colSpan = ncols)
    c.italic = true
    add(c)
    inc row
  # the body's own top and bottom rules
  for c in result.cells.mitems:
    if c.row == firstBody and bodyTop.width > 0 and c.border[0].width < bodyTop.width: c.border[0] = bodyTop
    if c.row + c.rowSpan == row and bodyBottom.width > 0 and c.border[2].width < bodyBottom.width: c.border[2] = bodyBottom

  # the footer: footnotes, then source notes
  if b.footer.len > 0 or t.sourceNotes.len > 0:
    let notes = b.footer.mapIt((if it[0] > 0: footMarkHtml(it[0], o) & " " else: "") & it[1])
    var firstFoot = true
    proc footRows(items: seq[string], multiline: bool, sep: string, size, pad, padh, bgOpt: string, key: string,
                  lastRule: Side) =
      let lines = if multiline or items.len == 0: items else: @[items.join(escapeHtml(sep))]
      for k, n in lines:
        var c = newCell(row, 0, n, pct(size), ink, vars, colSpan = ncols)
        let p = cssLength(v(pad), base)
        let ph = cssLength(v(padh), base)
        c.pad = [(if firstFoot: 8'f32 else: p), ph, p, ph]
        (c.hasBg, c.bg) = bgOf(bgOpt, o.tableBackgroundColor)
        if k == lines.high: c.border[2] = lastRule
        add(c, key)
        inc row
        firstFoot = false
    footRows(notes, o.footnotesMultiline, o.footnotesSep, o.footnotesFontSize, o.footnotesPadding,
             o.footnotesPaddingHorizontal, o.footnotesBackgroundColor, "footnotes",
             side(o.footnotesBorderBottomWidth, o.footnotesBorderBottomStyle, o.footnotesBorderBottomColor))
    footRows(t.sourceNotes.mapIt(it.renderText(rcHtml)), o.sourceNotesMultiline, o.sourceNotesSep,
             o.sourceNotesFontSize, o.sourceNotesPadding, o.sourceNotesPaddingHorizontal,
             o.sourceNotesBackgroundColor, "source_notes",
             side(o.sourceNotesBorderBottomWidth, o.sourceNotesBorderBottomStyle, o.sourceNotesBorderBottomColor))
  result.nrows = row

# ---------------------------------------------------------------------------------------------
# Layout

type Layout = object
  g: Grid
  colW, rowH: seq[float32]            ## content + padding of each column and row
  hLine: seq[seq[Side]]               ## horizontal rules: line 0 .. nrows, one per column
  vLine: seq[seq[Side]]               ## vertical rules: line 0 .. ncols, one per row
  hT, vT: seq[float32]                ## thickness of each line
  x, y: seq[float32]                  ## where each column and row starts (after its line)
  width, height: float32

func stylePriority(s: string): int =
  case s
  of "double": 8
  of "solid": 7
  of "dashed": 6
  of "dotted": 5
  of "ridge": 4
  of "outset": 3
  of "groove": 2
  of "inset": 1
  else: 0

proc merge(a: var Side, b: Side) =
  ## Collapsing borders: the wider wins, then the style that weighs more; else the first stays.
  if b.width <= 0 or b.style.len == 0: return
  if b.width > a.width or (b.width == a.width and stylePriority(b.style) > stylePriority(a.style)): a = b

proc distribute(widths: var seq[float32], first, n: int, need: float32, weights: seq[float32]) =
  ## Grows columns `first ..< first + n` so that they add up to `need`, in proportion to `weights`.
  var have = 0'f32
  var total = 0'f32
  for j in first ..< first + n:
    have += widths[j]
    total += weights[j]
  if need <= have: return
  for j in first ..< first + n:
    let share = if total > 0: weights[j] / total else: 1 / n.float32
    widths[j] += (need - have) * share

proc layout(t: Tabella, f: PictureFonts, vars: Table[string, string], maxWidth: float32): Layout =
  result.g = grid(t, vars)
  let nr = result.g.nrows
  let nc = result.g.ncols
  for c in result.g.cells.mitems: measure(f, c)
  # rules: every cell puts its borders on the lines around it
  result.hLine = newSeqWith(nr + 1, newSeq[Side](nc))
  result.vLine = newSeqWith(nc + 1, newSeq[Side](nr))
  for j in 0 ..< nc:
    result.hLine[0][j].merge result.g.outer[0]
    result.hLine[nr][j].merge result.g.outer[2]
  for i in 0 ..< nr:
    result.vLine[0][i].merge result.g.outer[3]
    result.vLine[nc][i].merge result.g.outer[1]
  for c in result.g.cells:
    for j in c.col ..< c.col + c.colSpan:
      result.hLine[c.row][j].merge c.border[0]
      result.hLine[c.row + c.rowSpan][j].merge c.border[2]
    for i in c.row ..< c.row + c.rowSpan:
      result.vLine[c.col][i].merge c.border[3]
      result.vLine[c.col + c.colSpan][i].merge c.border[1]
  result.hT = result.hLine.mapIt(it.mapIt(it.width).foldl(max(a, b), 0'f32))
  result.vT = result.vLine.mapIt(it.mapIt(it.width).foldl(max(a, b), 0'f32))
  # column widths, as CSS's automatic table layout: each column between its narrowest and its
  # widest content; cells that span columns spread what they need over them
  var minW = newSeq[float32](nc)
  var maxW = newSeq[float32](nc)
  var fixed = newSeq[float32](nc)
  var pctW = newSeq[float32](nc)
  for c in result.g.cells:
    if c.colSpan != 1: continue
    let pads = c.pad[1] + c.pad[3]
    minW[c.col] = max(minW[c.col], c.minW + pads)
    maxW[c.col] = max(maxW[c.col], c.maxW + pads)
    if c.width > 0: fixed[c.col] = max(fixed[c.col], c.width)
    if c.widthPct > 0: pctW[c.col] = max(pctW[c.col], c.widthPct)
  for j in 0 ..< nc:
    if fixed[j] > 0:
      minW[j] = max(minW[j], fixed[j])
      maxW[j] = max(minW[j], fixed[j])
  for c in result.g.cells:
    if c.colSpan == 1: continue
    let pads = c.pad[1] + c.pad[3]
    let inner = sum(result.vT[c.col + 1 ..< c.col + c.colSpan])
    distribute(minW, c.col, c.colSpan, c.minW + pads - inner, maxW)
    distribute(maxW, c.col, c.colSpan, c.maxW + pads - inner, maxW)
  for j in 0 ..< nc: maxW[j] = max(maxW[j], minW[j])
  let lines = sum(result.vT)
  let sumMin = sum(minW)
  let sumMax = sum(maxW)
  var tableW = t.options.tableWidth.strip
  var target = if tableW.endsWith("%"): cssLength(tableW, 16, maxWidth) - lines
               elif tableW.len > 0 and tableW != "auto": cssLength(tableW, 16) - lines
               else: min(sumMax, maxWidth - lines)
  if pctW.anyIt(it > 0):   # a width in % of the table: the table grows until each is met
    for j in 0 ..< nc:
      if pctW[j] > 0 and pctW[j] < 100: target = max(target, min(maxWidth - lines, maxW[j] * 100 / pctW[j]))
  target = max(target, sumMin)
  result.colW = newSeq[float32](nc)
  if target >= sumMax:
    for j in 0 ..< nc: result.colW[j] = maxW[j] + (if sumMax > 0: (target - sumMax) * maxW[j] / sumMax else: 0)
  else:
    let k = if sumMax > sumMin: (target - sumMin) / (sumMax - sumMin) else: 0
    for j in 0 ..< nc: result.colW[j] = minW[j] + (maxW[j] - minW[j]) * k
  for j in 0 ..< nc:
    if pctW[j] > 0 and fixed[j] == 0:
      result.colW[j] = max(minW[j], pctW[j] / 100 * (target + lines))
  # rows: break each cell's lines in its width, then the rows take the tallest
  result.x = newSeq[float32](nc + 1)
  var x = result.vT[0]
  for j in 0 ..< nc:
    result.x[j] = x
    x += result.colW[j] + result.vT[j + 1]
  result.x[nc] = x
  result.width = x
  result.rowH = newSeq[float32](nr)
  for c in result.g.cells.mitems:
    let w = result.x[c.col + c.colSpan - 1] + result.colW[c.col + c.colSpan - 1] - result.x[c.col] - c.pad[1] - c.pad[3]
    breakLines(f, c, w)
    if c.rowSpan == 1: result.rowH[c.row] = max(result.rowH[c.row], c.contentH + c.pad[0] + c.pad[2])
  for c in result.g.cells:
    if c.rowSpan > 1:
      let have = sum(result.rowH[c.row ..< c.row + c.rowSpan]) + sum(result.hT[c.row + 1 ..< c.row + c.rowSpan])
      let need = c.contentH + c.pad[0] + c.pad[2]
      if need > have: result.rowH[c.row + c.rowSpan - 1] += need - have
  result.y = newSeq[float32](nr + 1)
  var y = result.hT[0]
  for i in 0 ..< nr:
    result.y[i] = y
    y += result.rowH[i] + result.hT[i + 1]
  result.y[nr] = y
  result.height = y

# ---------------------------------------------------------------------------------------------
# Painting

proc fillBox(img: Image, x, y, w, h: float32, c: Color) =
  if w <= 0 or h <= 0 or c.a <= 0: return
  let ctx = newContext(img)
  ctx.fillStyle = c
  ctx.fillRect(rect(x, y, w, h))

proc paintRule(img: Image, s: Side, x, y, w, h: float32, horizontal: bool) =
  ## A rule, `w` × `h` (device pixels): two thin ones for `double`, dashes for `dashed`/`dotted`.
  if s.width <= 0: return
  case s.style
  of "double":
    if horizontal:
      let t = max(1'f32, h / 3)
      img.fillBox(x, y, w, t, s.color)
      img.fillBox(x, y + h - t, w, t, s.color)
    else:
      let t = max(1'f32, w / 3)
      img.fillBox(x, y, t, h, s.color)
      img.fillBox(x + w - t, y, t, h, s.color)
  of "dashed", "dotted":
    let step = if s.style == "dashed": 3 * max(w, h).float32 else: 2 * min(w, h)
    var p = 0'f32
    let total = if horizontal: w else: h
    while p < total:
      let len = min(step / 2, total - p)
      if horizontal: img.fillBox(x + p, y, len, h, s.color)
      else: img.fillBox(x, y + p, w, len, s.color)
      p += step
  else: img.fillBox(x, y, w, h, s.color)

type SvgLabel = object
  x, y, size: float32
  text, anchor: string
  fill: Color

proc prepareSvg(svg: string, labels: var seq[SvgLabel]): string =
  ## A nanoplot's SVG made readable for pixie: its `<text>` taken out (pixie skips no tag it does
  ## not know: it fails on them) and kept apart when visible, `<defs>` dropped, `transparent`
  ## written as `none`, and a fill with a pattern (the hatched area under a line) written as a
  ## pale fill of the pattern's colour.
  result = svg
  # a static nanoplot shows its values (tabellaCss colours them: dark text, a white halo)
  let staticPlot = "tb_nanoplot_static" in svg[0 ..< svg.find('>')]
  var patternColor = "#FF0000"
  let d0 = result.find("<defs>")
  if d0 >= 0:
    let d1 = result.find("</defs>", d0)
    let defs = result[d0 ..< d1 + 7]
    let sc = defs.find("stroke=\"")
    if sc >= 0: patternColor = defs[sc + 8 ..< defs.find('"', sc + 8)]
    result = result[0 ..< d0] & result[d1 + 7 .. ^1]
  while true:
    let a = result.find("<text")
    if a < 0: break
    let gt = result.find('>', a)
    let b = result.find("</text>", gt)
    let tag = result[a ..< gt]
    var fill = attr(tag, "fill")
    if staticPlot and fill == "transparent": fill = "#212427"
    if fill.len > 0 and fill != "transparent" and fill != "none":
      var lbl = SvgLabel(text: decodeEntities(result[gt + 1 ..< b]), anchor: attr(tag, "text-anchor"),
                         fill: cssColor(fill))
      try:
        lbl.x = parseFloat(attr(tag, "x"))
        lbl.y = parseFloat(attr(tag, "y"))
      except ValueError: discard
      lbl.size = cssLength(attr(tag, "font-size"), 16)
      if lbl.size == 0: lbl.size = 16
      labels.add lbl
    result = result[0 ..< a] & result[b + 7 .. ^1]
  # tag by tag: a pattern fill becomes a pale fill; `transparent` becomes `none`, and a stroke
  # that is `none` loses its width (pixie's reader paints a stroke with a width black)
  var outp = ""
  var i = 0
  while i < result.len:
    let a = result.find('<', i)
    if a < 0:
      outp.add result[i .. ^1]
      break
    let e = result.find('>', a)
    outp.add result[i ..< a]
    var tag = result[a .. e]
    if "fill=\"url(" in tag:
      let p = tag.find("fill=\"url(")
      let q = tag.find('"', p + 6)
      tag = tag[0 ..< p] & "fill=\"" & patternColor & "\"" & tag[q + 1 .. ^1]
      let fo = attr(tag, "fill-opacity")
      let pale = (try: $(0.25 * parseFloat(fo)) except ValueError: "0.18")
      if fo.len > 0: tag = tag.replace("fill-opacity=\"" & fo & "\"", "fill-opacity=\"" & pale & "\"")
      else: tag = tag.replace("fill=\"" & patternColor & "\"", "fill=\"" & patternColor & "\" fill-opacity=\"" & pale & "\"")
    tag = tag.replace("\"transparent\"", "\"none\"")
    if "stroke=\"none\"" in tag:
      let sw = attr(tag, "stroke-width")
      if sw.len > 0: tag = tag.replace("stroke-width=\"" & sw & "\"", "")
    outp.add tag
    i = e + 1
  result = outp
  # pixie's reader wants integers in the viewBox, and no `role`/`style` it cannot use
  let vb = attr(result[0 ..< result.find('>')], "viewBox")
  if vb.len > 0:
    result = result.replace("viewBox=\"" & vb & "\"", "viewBox=\"" & vb.splitWhitespace.mapIt(
      (try: $int(round(parseFloat(it))) except ValueError: it)).join(" ") & "\"")

proc paintPieces(img: Image, f: PictureFonts, c: Cell, l: Line, x0, baseline, s: float32) =
  ## One line of a cell, its baseline at `baseline` (device pixels), starting at `x0`.
  var x = x0
  for p in l.pieces:
    case p.kind
    of pkText, pkSpace:
      if p.kind == pkText:
        let font = fontOf(f, c, p.style, c.size * p.style.size * s)
        let top = baseline - p.style.shift * c.size * s - round(font.typeface.ascent * font.scale)
        img.fillText(font, p.text, translate(vec2(x, top)))
      x += p.w * s
    of pkSvg:
      let w = max(1, int(round(p.w * s)))
      let h = max(1, int(round(p.h * s)))
      let top = baseline - (c.size * 0.27 + p.h / 2) * s
      var labels: seq[SvgLabel]
      try:
        let svg = parseSvg(prepareSvg(p.svg, labels), w, h)
        img.draw(newImage(svg), translate(vec2(round(x), round(top))))
        let vb = attr(p.svg[0 ..< p.svg.find('>')], "viewBox").splitWhitespace
        let k = if vb.len == 4: h.float32 / parseFloat(vb[3]) else: 1
        for lb in labels:
          let font = newFont(f.mono)
          font.size = lb.size * k
          font.paint.color = lb.fill
          let tw = font.layoutBounds(lb.text).x
          let dx = if lb.anchor == "middle": -tw / 2 elif lb.anchor == "end": -tw else: 0
          let at = translate(vec2(x + lb.x * k + dx, top + lb.y * k - round(font.typeface.ascent * font.scale)))
          let halo = font.copy()   # the white halo under the text: `paint-order: stroke`
          halo.paint = newPaint(SolidPaint)
          halo.paint.color = color(1, 1, 1, 1)
          img.strokeText(halo, lb.text, at, strokeWidth = 0.3 * font.size, lineJoin = RoundJoin)
          img.fillText(font, lb.text, at)
      except CatchableError as e:
        stderr.writeLine "tabelline/pixie: a nanoplot pixie could not read: ", e.msg
      x += p.w * s
    of pkImage:
      if p.image != nil:
        let top = baseline - (c.size * 0.27 + p.h / 2) * s
        let k = p.h * s / p.image.height.float32
        img.draw(p.image, translate(vec2(x, top)) * scale(vec2(k, k)))
      x += p.w * s
    of pkBreak: discard

proc paint(lay: Layout, f: PictureFonts, s: float32, transparent: bool): Image =
  let W = max(1, int(ceil(lay.width * s)))
  let H = max(1, int(ceil(lay.height * s)))
  result = newImage(W, H)
  if not transparent: result.fill(lay.g.tableBg)
  let nr = lay.g.nrows
  let nc = lay.g.ncols
  # backgrounds, under the rules
  for c in lay.g.cells:
    if not c.hasBg: continue
    let x0 = lay.x[c.col] - lay.vT[c.col] / 2
    let x1 = lay.x[c.col + c.colSpan] - lay.vT[c.col + c.colSpan] / 2
    let y0 = lay.y[c.row] - lay.hT[c.row] / 2
    let y1 = lay.y[c.row + c.rowSpan] - lay.hT[c.row + c.rowSpan] / 2
    result.fillBox(round(x0 * s), round(y0 * s), round(x1 * s) - round(x0 * s), round(y1 * s) - round(y0 * s), c.bg)
  # text and pictures
  for c in lay.g.cells:
    let cx = lay.x[c.col] + c.pad[3]
    let cw = lay.x[c.col + c.colSpan] - lay.vT[c.col + c.colSpan] - lay.x[c.col] - c.pad[1] - c.pad[3]
    let cy = lay.y[c.row] + c.pad[0]
    let ch = lay.y[c.row + c.rowSpan] - lay.hT[c.row + c.rowSpan] - lay.y[c.row] - c.pad[0] - c.pad[2]
    var y = case c.valign
            of "top": cy
            of "bottom": cy + ch - c.contentH
            else: cy + (ch - c.contentH) / 2
    for k, l in c.lines:
      let indent = if k == 0: c.indent else: 0
      let x = case c.align
              of "center": cx + (cw - l.width) / 2
              of "right": cx + cw - l.width
              else: cx + indent
      y += l.ascent
      result.paintPieces(f, c, l, x * s, round(y * s), s)
      y += l.descent
    if c.spannerRule.width > 0:
      result.paintRule(c.spannerRule, round(cx * s), round((y + 4) * s), round(cw * s), round(c.spannerRule.width * s), true)
  # rules: horizontal ones, then vertical ones
  for i in 0 .. nr:
    for j in 0 ..< nc:
      let sd = lay.hLine[i][j]
      if sd.width <= 0: continue
      let x0 = lay.x[j] - lay.vT[j]
      let x1 = lay.x[j + 1]
      let y0 = (if i < nr: lay.y[i] else: lay.height) - lay.hT[i]
      result.paintRule(sd, round(x0 * s), round(y0 * s), round(x1 * s) - round(x0 * s), round(lay.hT[i] * s), true)
  for j in 0 .. nc:
    for i in 0 ..< nr:
      let sd = lay.vLine[j][i]
      if sd.width <= 0: continue
      let x0 = (if j < nc: lay.x[j] else: lay.width) - lay.vT[j]
      let y0 = lay.y[i]
      let y1 = lay.y[i + 1] - lay.hT[i + 1]
      result.paintRule(sd, round(x0 * s), round(y0 * s), round(lay.vT[j] * s), round(y1 * s) - round(y0 * s), false)

proc measure*(t: Tabella, fonts = pictureFonts(), vars = initTable[string, string](), maxWidth = 800'f32): Picture =
  ## The size of the picture of `t` at scale 1 (CSS pixels).
  let lay = layout(t, fonts, vars, maxWidth)
  Picture(width: lay.width, height: lay.height)

proc toImage*(t: Tabella, scale = 2'f32, fonts = pictureFonts(), vars = initTable[string, string](),
              maxWidth = 800'f32, transparent = false): Image =
  ## The table painted as a pixie `Image`, at `scale` device pixels per CSS pixel (2 is what a
  ## screenshot of the HTML at zoom 2 gives). `maxWidth` is the room the table has, in CSS
  ## pixels: longer notes and labels wrap in it. `vars` gives the values of the page's CSS
  ## variables a table refers to (`optCssTheme()`'s `var(--ink)`...): without them each takes its
  ## fallback. `transparent` leaves the background out.
  let lay = layout(t, fonts, vars, maxWidth)
  paint(lay, fonts, scale, transparent)

proc toPng*(t: Tabella, scale = 2'f32, fonts = pictureFonts(), vars = initTable[string, string](),
            maxWidth = 800'f32): string =
  ## The table as the bytes of a PNG file.
  t.toImage(scale, fonts, vars, maxWidth).encodeImage(PngFormat)

proc savePng*(t: Tabella, path: string, scale = 2'f32, fonts = pictureFonts(),
              vars = initTable[string, string](), maxWidth = 800'f32) =
  ## Writes the table as a PNG file (or QOI, BMP, PPM: by the extension, as pixie's `writeFile`).
  t.toImage(scale, fonts, vars, maxWidth).writeFile(path)
