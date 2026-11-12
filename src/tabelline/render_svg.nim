## Rendering to SVG: `toSvg(t)` draws the marks of `drawing(t)` (layout.nim) as rectangles,
## lines, letters and the nanoplots' own `<svg>`. Standard library only.
##
## The letters are drawn in one of two ways. `stFont` (the default) writes text, with a subset of
## the font inside the SVG (only the letters the table uses), so the text can be selected and
## every browser draws the letters that were measured. `stPaths` writes each letter as its
## outline from the font: no font at all, and the same picture in every program that reads SVG
## (resvg, Inkscape, LibreOffice, PowerPoint), at the price of text that cannot be selected.

import std/[strutils, tables, base64, math]
import core, ttf, layout
from render_html import nanoplotCss

type SvgText* = enum
  ## How `toSvg` writes the letters.
  stFont = "font"    ## text, with a subset of the font inside the SVG
  stPaths = "paths"  ## each letter's outline: no font needed to draw it

func num(x: float): string =
  let r = round(x * 100) / 100
  if r == r.trunc: $int(r) else: $r

func esc(s: string): string = s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"), ("\"", "&quot;"))

proc paintAttr(p: Paint, name = "fill"): string =
  if p.color.len == 0: return " " & name & "=\"none\""
  result = " " & name & "=\"" & p.color & "\""
  if p.opacity < 1: result.add " " & name & "-opacity=\"" & num(p.opacity) & "\""

const faceFamily: array[Face, (string, string, string)] = [
  ("tb-sans", "400", "normal"), ("tb-sans", "700", "normal"), ("tb-sans", "400", "italic"),
  ("tb-sans", "700", "italic"), ("tb-mono", "400", "normal")]

proc placedPlot(m: Mark): string =
  ## A nanoplot's own `<svg>`, at its place and size instead of its style. `transparent` is CSS,
  ## not SVG 1.1 (LibreOffice and PowerPoint draw it black): it becomes `none`.
  let el = m.svg
  let e = el.find('>')
  var tag = el[0 .. e]
  let i = tag.find(" style=\"")
  if i >= 0: tag = tag[0 ..< i] & tag[tag.find('"', i + 8) + 1 .. ^1]
  tag[0 .. ^2] & " x=\"" & num(m.x) & "\" y=\"" & num(m.y) & "\" width=\"" & num(m.w) &
    "\" height=\"" & num(m.h) & "\" overflow=\"visible\" font-size=\"" & num(m.fontSize) &
    "\" font-family=\"tb-mono, 'DejaVu Sans Mono', monospace\">" &
    el[e + 1 .. ^1].replace("=\"transparent\"", "=\"none\"")

proc toSvg*(d: Drawing, text = stFont): string =
  ## The marks of a drawing as a standalone SVG picture.
  var body = "<rect width=\"" & num(d.width) & "\" height=\"" & num(d.height) & "\"" & paintAttr(d.background) & "/>\n"
  var used: array[Face, array[bool, string]]   # the letters of each face, plain and tabular
  var glyphDefs = initOrderedTable[(Face, int), string]()
  var plots = false
  for m in d.marks:
    case m.kind
    of mkRect:
      body.add "<rect x=\"" & num(m.x) & "\" y=\"" & num(m.y) & "\" width=\"" & num(m.w) & "\" height=\"" &
        num(m.h) & "\"" & paintAttr(m.fill) & "/>\n"
    of mkLine:
      body.add "<line x1=\"" & num(m.x) & "\" y1=\"" & num(m.y) & "\" x2=\"" & num(m.x + m.w) & "\" y2=\"" &
        num(m.y + m.h) & "\" stroke-width=\"" & num(m.width) & "\"" & paintAttr(m.stroke, "stroke") &
        (if m.dash > 0: " stroke-dasharray=\"" & num(m.dash) & "\"" else: "") & "/>\n"
    of mkImage:
      body.add "<image x=\"" & num(m.x) & "\" y=\"" & num(m.y) & "\" width=\"" & num(m.w) & "\" height=\"" &
        num(m.h) & "\" preserveAspectRatio=\"none\" href=\"" & esc(m.href) & "\" xlink:href=\"" & esc(m.href) & "\"/>\n"
    of mkPlot:
      plots = true
      body.add placedPlot(m) & "\n"
    of mkText:
      case text
      of stPaths:
        let ft = faceFont(m.face)
        let scale = m.size / ft.unitsPerEm.float
        var g = ""
        for i, gid in m.glyphs:
          if (m.face, gid) notin glyphDefs: glyphDefs[(m.face, gid)] = ft.glyphPath(gid)
          if glyphDefs[(m.face, gid)].len > 0:
            let id = "g" & $ord(m.face) & "-" & $gid
            g.add "<use href=\"#" & id & "\" xlink:href=\"#" & id & "\" x=\"" & num(m.xs[i] / scale) &
              "\" y=\"" & num(-m.y / scale) & "\"/>"
        body.add "<g" & paintAttr(m.color) & " transform=\"scale(" & $scale & " " & $(-scale) & ")\">" & g & "</g>\n"
      of stFont:
        used[m.face][m.tabular].add m.text
        var xs: seq[string]
        for x in m.xs: xs.add num(x)
        let (fam, weight, fstyle) = faceFamily[m.face]
        var t = "<text x=\"" & xs.join(" ") & "\" y=\"" & num(m.y) & "\" font-size=\"" & num(m.size) & "\""
        if fam != "tb-sans": t.add " font-family=\"" & fam & ", 'DejaVu Sans Mono', monospace\""
        elif m.tabular: t.add " font-family=\"tb-sans-tnum, tb-sans, Inter, sans-serif\" style=\"font-variant-numeric: tabular-nums\""
        if weight != "400": t.add " font-weight=\"" & weight & "\""
        if fstyle != "normal": t.add " font-style=\"" & fstyle & "\""
        body.add t & paintAttr(m.color) & ">" & esc(m.text) & "</text>\n"
  # the style: fonts and the nanoplots' rules
  var style = ""
  if text == stFont:
    for fc in Face:
      for tabular in [false, true]:
        let letters = used[fc][tabular]
        if letters.len == 0 and not (fc == fMono and not tabular and plots): continue
        # a nanoplot draws its own numbers, in the monospace face
        let data = faceFont(fc).subset(letters & (if fc == fMono: "0123456789.,-−+%$€ " else: ""), tabular = tabular)
        let (fam, weight, fstyle) = faceFamily[fc]
        style.add "@font-face { font-family: " & fam & (if tabular: "-tnum" else: "") & "; font-weight: " & weight &
          "; font-style: " & fstyle & "; src: url(data:font/ttf;base64," & encode(data) & ") format('truetype'); }\n"
  if plots:
    style.add nanoplotCss.replace("[i] ", "").replace("font-family: ui-monospace,", "font-family: tb-mono, ui-monospace,")
  var defs = ""
  if glyphDefs.len > 0:
    defs.add "<defs>"
    for (k, p) in glyphDefs.pairs:
      if p.len > 0: defs.add "<path id=\"g" & $ord(k[0]) & "-" & $k[1] & "\" d=\"" & p & "\"/>"
    defs.add "</defs>\n"
  "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"" & num(d.width) &
    "\" height=\"" & num(d.height) & "\" viewBox=\"0 0 " & num(d.width) & " " & num(d.height) &
    "\" font-family=\"tb-sans, Inter, sans-serif\">\n" &
    (if style.len > 0: "<style>\n" & style & "</style>\n" else: "") & defs & body & "</svg>\n"

proc toSvg*(t: Tabella, width = 992.0, text = stFont,
            vars: Table[string, string] = initTable[string, string]()): string =
  ## The table as a standalone SVG picture, laid out as Chrome lays out `toHtml` in a page
  ## `width` CSS pixels wide (a table narrower than that keeps its own width). `text` says how
  ## the letters are written (`stFont` or `stPaths`). `vars` gives the values of the page's CSS
  ## variables for a table that reads them (`optCssTheme`): `{"--primary": "#D64545"}`.
  t.drawing(width, vars).toSvg(text)
