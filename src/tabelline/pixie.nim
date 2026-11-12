## tabelline/pixie: a table painted as a PNG, with pixie (an optional module: the atlas feature
## `pixie`, so the core keeps needing only the standard library).
##
## ```nim
## import tabelline, tabelline/pixie
## let t = tabella(planets()): tabHeader "The planets"
## t.save "planets.png"              # scale 2: twice the pixels of the CSS size
## let img = t.toImage(scale = 3)    # a pixie Image
## let png = t.toPng                 # the bytes of a PNG file
## ```
##
## It paints the marks of `drawing(t)` (layout.nim), the same layout as `toSvg`, so the PNG and
## the SVG are the same picture. Letters are painted from their outlines in the fonts tabelline
## ships, each at the place the layout gave it: kerning and tabular figures come out as in the
## SVG, although pixie itself applies no OpenType features. Nanoplots go through pixie's SVG
## reader, after taking out what it cannot read: their text is painted apart, and the hatching
## under a line is drawn by hand.

import std/[strutils, tables, math, base64, os]
import pkg/pixie except Paint, Mark, Image
import pkg/pixie as px
import pkg/pixie/fileformats/svg
import core, ttf, layout, save

export px.Image

proc color(p: layout.Paint): Color =
  if p.color.len == 0: return color(0, 0, 0, 0)
  result = try: parseHtmlColor(p.color) except CatchableError: color(0, 0, 0, 1)
  result.a *= p.opacity.float32

var glyphPaths: Table[(Face, int), Path]

proc glyph(f: Face, g: int): Path =
  if (f, g) notin glyphPaths:
    let d = faceFont(f).glyphPath(g)
    glyphPaths[(f, g)] = if d.len > 0: parsePath(d) else: newPath()
  glyphPaths[(f, g)]

proc fillBox(img: px.Image, x, y, w, h: float, c: Color) =
  ## A rectangle, its edges on whole device pixels, so rules stay sharp.
  if c.a <= 0: return
  let (x0, y0) = (round(x), round(y))
  let (x1, y1) = (max(round(x + w), x0 + (if w > 0: 1.0 else: 0.0)), max(round(y + h), y0 + (if h > 0: 1.0 else: 0.0)))
  if x1 <= x0 or y1 <= y0: return
  let p = newPath()
  p.rect(x0.float32, y0.float32, (x1 - x0).float32, (y1 - y0).float32)
  img.fillPath(p, c)

proc attr(tag, name: string): string =
  let k = tag.find(" " & name & "=\"")
  if k < 0: return ""
  let a = k + name.len + 3
  tag[a ..< tag.find('"', a)]

func unescape(s: string): string =
  s.multiReplace(("&lt;", "<"), ("&gt;", ">"), ("&quot;", "\""), ("&#39;", "'"), ("&amp;", "&"))

type
  PlotText = object
    x, y, size: float
    text, anchor: string
    fill: Color
  Hatch = object
    d: string            ## the area's path, in the plot's own units
    color: Color
    opacity: float

proc readablePlot(svg: string, texts: var seq[PlotText], hatches: var seq[Hatch]): string =
  ## A nanoplot's SVG as pixie's reader takes it: no `<defs>` and no `<text>` (it fails on tags
  ## it does not know; the visible text is kept apart, to paint), no area filled with a pattern
  ## (kept apart, to hatch), no stroke width on a stroke that is `none` (pixie paints it black),
  ## whole numbers in the viewBox.
  result = svg
  let staticPlot = "tb_nanoplot_static" in svg[0 ..< svg.find('>')]
  var hatchColor = "#FF0000"
  let d0 = result.find("<defs>")
  if d0 >= 0:
    let d1 = result.find("</defs>", d0)
    let sc = result.find("stroke=\"", d0)
    if sc >= 0 and sc < d1: hatchColor = result[sc + 8 ..< result.find('"', sc + 8)]
    result = result[0 ..< d0] & result[d1 + 7 .. ^1]
  while true:
    let a = result.find("<text")
    if a < 0: break
    let gt = result.find('>', a)
    let b = result.find("</text>", gt)
    let tag = result[a ..< gt]
    var fill = attr(tag, "fill")
    if staticPlot and fill == "none": fill = "#212427"   # tabellaCss shows a static plot's values
    if fill.len > 0 and fill != "none":
      var t = PlotText(text: unescape(result[gt + 1 ..< b]), anchor: attr(tag, "text-anchor"),
                       fill: (try: parseHtmlColor(fill) except CatchableError: color(0, 0, 0, 1)))
      t.x = (try: parseFloat(attr(tag, "x")) except ValueError: 0.0)
      t.y = (try: parseFloat(attr(tag, "y")) except ValueError: 0.0)
      t.size = (try: parseFloat(attr(tag, "font-size").replace("px", "")) except ValueError: 16.0)
      texts.add t
    result = result[0 ..< a] & result[b + 7 .. ^1]
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
    i = e + 1
    if "fill=\"url(" in tag:
      let op = attr(tag, "fill-opacity")
      hatches.add Hatch(d: attr(tag, "d"), color: (try: parseHtmlColor(hatchColor) except CatchableError: color(1, 0, 0, 1)),
                        opacity: (try: parseFloat(op) except ValueError: 1.0))
      let close = result.find("</path>", i)
      if close == i: i += 7
      continue
    if "stroke=\"none\"" in tag:
      let sw = attr(tag, "stroke-width")
      if sw.len > 0: tag = tag.replace(" stroke-width=\"" & sw & "\"", "")
    outp.add tag
  result = outp
  let vb = attr(result[0 ..< result.find('>')], "viewBox")
  if vb.len > 0:
    var whole: seq[string]
    for v in vb.splitWhitespace: whole.add(try: $int(round(parseFloat(v))) except ValueError: v)
    result = result.replace("viewBox=\"" & vb & "\"", "viewBox=\"" & whole.join(" ") & "\"")

proc paintText(img: px.Image, f: Face, size: float, text: string, x, y: float, c: Color, s: float) =
  ## Text in a face, starting at `x` with its baseline at `y` (CSS pixels), measured by `ttf.nim`.
  let ft = faceFont(f)
  let gs = ft.glyphs(text)
  let adv = ft.advances(text, size)
  let k = size / ft.unitsPerEm.float
  var gx = x
  for i, g in gs:
    img.fillPath(glyph(f, g), c, translate(vec2((gx * s).float32, (y * s).float32)) * scale(vec2((k * s).float32, (-k * s).float32)))
    gx += adv[i]

proc paintPlot(img: px.Image, m: Mark, s: float) =
  var texts: seq[PlotText]
  var hatches: seq[Hatch]
  let svg = readablePlot(m.svg, texts, hatches)
  let w = max(1, int(round(m.w * s)))
  let h = max(1, int(round(m.h * s)))
  let (ox, oy) = (round(m.x * s), round(m.y * s))
  let vb = attr(m.svg[0 ..< m.svg.find('>')], "viewBox").splitWhitespace
  let k = if vb.len == 4: h.float / parseFloat(vb[3]) else: 1.0   # plot units to device pixels
  let at = translate(vec2(ox.float32, oy.float32)) * scale(vec2(k.float32, k.float32))
  # the hatched areas: lines 8 units apart, at 45°, kept inside the area
  for hc in hatches:
    if hc.d.len == 0: continue
    let mask = newImage(img.width, img.height)
    mask.fillPath(parsePath(hc.d), color(1, 1, 1, 1), at)
    let lines = newImage(img.width, img.height)
    let p = newPath()
    let span = (w.float + h.float) / k
    var u = -span
    while u < span:
      p.moveTo(u.float32, (span + 8).float32)
      p.lineTo((u + span + 8).float32, 0'f32)
      u += 8
    var c = hc.color
    c.a *= hc.opacity.float32
    lines.strokePath(p, c, at, strokeWidth = 1.5)
    lines.draw(mask, blendMode = MaskBlend)
    img.draw(lines)
  try:
    img.draw(newImage(parseSvg(svg, w, h)), translate(vec2(ox.float32, oy.float32)))
  except CatchableError as e:
    stderr.writeLine "tabelline/pixie: pixie could not read a nanoplot: ", e.msg
  # its text, in the monospace face, with a white halo (`paint-order: stroke` in tabellaCss)
  for t in texts:
    let size = t.size * k / s
    var tw = 0.0
    for a in faceFont(fMono).advances(t.text, size): tw += a
    let dx = if t.anchor == "middle": -tw / 2 elif t.anchor == "end": -tw else: 0.0
    let (tx, ty) = (m.x + t.x * k / s + dx, m.y + t.y * k / s)
    let ft = faceFont(fMono)
    let kk = size / ft.unitsPerEm.float
    var gx = tx
    let adv = ft.advances(t.text, size)
    for i, g in ft.glyphs(t.text):
      let tr = translate(vec2((gx * s).float32, (ty * s).float32)) * scale(vec2((kk * s).float32, (-kk * s).float32))
      img.strokePath(glyph(fMono, g), color(1, 1, 1, 1), tr, strokeWidth = (0.3 * size / kk).float32, lineJoin = RoundJoin)
      gx += adv[i]
    img.paintText(fMono, size, t.text, tx, ty, t.fill, s)

proc picture(href: string): px.Image =
  if href.startsWith("data:"):
    let comma = href.find(',')
    let raw = if href[0 ..< comma].endsWith(";base64"): decode(href[comma + 1 .. ^1]) else: href[comma + 1 .. ^1]
    if "image/svg" in href[0 ..< comma]: return newImage(parseSvg(raw))
    return decodeImage(raw)
  if fileExists(href):
    if href.endsWith(".svg"): return newImage(parseSvg(readFile(href)))
    return readImage(href)
  nil

proc toImage*(d: Drawing, scale = 2.0): px.Image =
  ## The marks of a drawing painted into a pixie `Image`, `scale` pixels to a CSS pixel.
  let s = scale
  result = newImage(max(1, int(ceil(d.width * s))), max(1, int(ceil(d.height * s))))
  result.fill(color(d.background))
  for m in d.marks:
    case m.kind
    of mkRect: result.fillBox(m.x * s, m.y * s, m.w * s, m.h * s, color(m.fill))
    of mkLine:
      let c = color(m.stroke)
      let horizontal = m.h == 0
      let len = if horizontal: m.w else: m.h
      let step = if m.dash > 0: 2 * m.dash else: len
      let piece = if m.dash > 0: m.dash else: len
      var p = 0.0
      while p < len - 0.01:
        let l = min(piece, len - p)
        if horizontal: result.fillBox((m.x + p) * s, (m.y - m.width / 2) * s, l * s, m.width * s, c)
        else: result.fillBox((m.x - m.width / 2) * s, (m.y + p) * s, m.width * s, l * s, c)
        p += step
    of mkText:
      let c = color(m.color)
      let ft = faceFont(m.face)
      let k = m.size / ft.unitsPerEm.float
      for i, g in m.glyphs:
        result.fillPath(glyph(m.face, g), c, translate(vec2((m.xs[i] * s).float32, (m.y * s).float32)) *
                        scale(vec2((k * s).float32, (-k * s).float32)))
    of mkPlot: result.paintPlot(m, s)
    of mkImage:
      let pic = try: picture(m.href) except CatchableError: nil
      if pic == nil: continue
      result.draw(pic, translate(vec2((m.x * s).float32, (m.y * s).float32)) *
                  scale(vec2((m.w * s / pic.width.float).float32, (m.h * s / pic.height.float).float32)))

proc toImage*(t: Tabella, scale = 2.0, width = 992.0,
              vars: Table[string, string] = initTable[string, string]()): px.Image =
  ## The table painted as a pixie `Image`, laid out as `toSvg` lays it out in a page `width` CSS
  ## pixels wide, at `scale` pixels to a CSS pixel (2: as a screenshot at zoom 2). `vars` gives
  ## the values of the page's CSS variables for a table that reads them (`optCssTheme`).
  t.drawing(width, vars).toImage(scale)

proc toPng*(t: Tabella, scale = 2.0, width = 992.0,
            vars: Table[string, string] = initTable[string, string]()): string =
  ## The table as the bytes of a PNG file.
  t.toImage(scale, width, vars).encodeImage(PngFormat)

addWriter(".png", proc (t: Tabella, path: string, scale, width: float) =
  writeFile(path, t.toPng(scale, width)), priority = 10)
