## Pictures in cells: icons and images, drawn without loading anything remote.
##
## - `fmtIcon`: names of Font Awesome Free icons ("star", "fab fa-github") as inline SVG. Every
##   free icon (solid, regular and brands) is in `data/fontawesome.tsv`, written by
##   `tools/fontawesome.nim` and read when compiling, only by a program that uses icons. The
##   icons are under CC BY 4.0 (`licenses/fontawesome-LICENSE.txt`).
## - `fmtImage`: file names as images, inlined as data URLs (`encode`), so a page stays one file.

import std/[strutils, tables, base64, os, math]
import core, formats

# ----------------------------------------------------------------------------------------- icons

type
  Icon* = object
    ## A Font Awesome icon: its name, style ("solid", "regular" or "brands"), label and drawing
    ## (an SVG path on a canvas `width` wide and 512 high).
    name*, style*, label*, path*: string
    width*: int

const fontawesomeTsv = staticRead("data/fontawesome.tsv")

var iconTable: Table[string, seq[Icon]]
var iconAliases: Table[string, string]

proc loadIcons() =
  if iconTable.len > 0: return
  for line in fontawesomeTsv.splitLines:
    if line.len == 0 or line[0] == '#': continue
    let f = line.split('\t')
    if f.len == 3 and f[1] == "=": iconAliases[f[0]] = f[2]
    elif f.len == 5:
      iconTable.mgetOrPut(f[0], @[]).add Icon(name: f[0], style: f[1], width: parseInt(f[2]),
                                               label: f[3], path: f[4])

const stylePrefixes = {"fas": "solid", "fa-solid": "solid", "far": "regular",
                       "fa-regular": "regular", "fab": "brands", "fa-brands": "brands"}.toTable

proc findIcon*(name: string): (bool, Icon) =
  ## The icon for a name: a short name ("star", the regular style when there are two), a full
  ## name ("fas fa-star", "fa-solid fa-star") or an older name ("user-large" is "user").
  {.cast(gcsafe).}:
    loadIcons()
    var style = ""
    var short = name.strip
    let parts = short.splitWhitespace
    if parts.len == 2 and parts[0] in stylePrefixes:
      style = stylePrefixes[parts[0]]
      short = parts[1]
    if short.startsWith("fa-"): short = short[3 .. ^1]
    if short notin iconTable and short in iconAliases: short = iconAliases[short]
    if short notin iconTable: return (false, Icon())
    let icons = iconTable[short]
    let want = if style.len > 0: style else: "regular"
    for icon in icons:
      if icon.style == want: return (true, icon)
    if style.len > 0: return (false, Icon())
    (true, icons[0])

proc hasIcon*(name: string): bool =
  ## Whether `name` is a Font Awesome Free icon (see `findIcon`).
  findIcon(name)[0]

proc icon*(name: string): Icon =
  ## The icon for a name (see `findIcon`); raises `ValueError` for an unknown one.
  let (found, i) = findIcon(name)
  if not found: raise newException(ValueError, "no Font Awesome Free icon named " & name.escape)
  i

func cssLength(s: string): (float, string) =
  ## "1.5em" is (1.5, "em").
  var k = 0
  while k < s.len and s[k] in {'0'..'9', '.'}: inc k
  if k == 0 or k == s.len: raise newException(ValueError, "a length is a number and a unit, not " & s.escape)
  (parseFloat(s[0 ..< k]), s[k .. ^1])

func lengthText(x: float, unit: string): string =
  var s = formatFloat(round(x, 2), ffDecimal, 2)
  s = s.strip(leading = false, chars = {'0'}).strip(leading = false, chars = {'.'})
  s & unit

proc iconSvg*(name: string, height = "1em", fill = "", fillAlpha = NaN, stroke = "",
              strokeWidth = "", strokeAlpha = NaN, marginLeft = "", marginRight = "",
              verticalAlign = "-0.125em", title = "", a11y = "semantic"): string =
  ## An icon as inline SVG, `height` high and as wide as its shape: `iconSvg("star")`. The fill is
  ## the text's colour unless `fill` is given. With `a11y = "semantic"` a screen reader reads its
  ## label (or `title`), with "decorative" it skips it, with "none" nothing is added.
  let i = icon(name)
  let (h, unit) = cssLength(height)
  let width = lengthText(h * i.width.float / 512, unit)
  var attrs = "viewBox=\"0 0 " & $i.width & " 512\""
  case a11y
  of "semantic":
    attrs.add " role=\"img\" aria-label=\"" & escapeHtml(if title.len > 0: title else: i.label) & "\""
  of "decorative": attrs.add " aria-hidden=\"true\" role=\"img\""
  of "none": discard
  else: raise newException(ValueError, "a11y is \"semantic\", \"decorative\" or \"none\", not " & a11y.escape)
  var css = @["fill:" & (if fill.len > 0: fill else: "currentColor")]
  if not fillAlpha.isNaN: css.add "fill-opacity:" & $fillAlpha
  if stroke.len > 0: css.add "stroke:" & stroke
  if strokeWidth.len > 0: css.add "stroke-width:" & strokeWidth
  elif stroke.len > 0: css.add "stroke-width:1px"
  if not strokeAlpha.isNaN: css.add "stroke-opacity:" & $strokeAlpha
  css.add ["height:" & height, "width:" & width, "margin-left:" & (if marginLeft.len > 0: marginLeft else: "auto"),
           "margin-right:" & (if marginRight.len > 0: marginRight else: "auto"), "position:relative",
           "vertical-align:" & verticalAlign, "overflow:visible"]
  "<svg " & attrs & " class=\"tb_icon\" style=\"" & escapeHtml(css.join(";")) & "\">" &
    (if title.len > 0: "<title>" & escapeHtml(title) & "</title>" else: "") &
    "<path d=\"" & i.path & "\"/></svg>"

func iconNames(s: string): seq[string] =
  for part in s.split(','):
    let p = part.strip
    if p.len > 0: result.add p

proc fmtIcon*(t: sink Tabella, columns: ColSel, rows = allRows(), height = "1em", sep = " ",
              strokeColor = "", strokeWidth = "", strokeAlpha = NaN, fillColor = "",
              fillColors: openArray[(string, string)] = [], fillAlpha = NaN, marginLeft = "",
              marginRight = "", a11y = "semantic"): Tabella =
  ## Names of Font Awesome Free icons as icons: "star", or several separated by commas
  ## ("hard-drive, clock"), joined by `sep`. `fillColor` colours them all, `fillColors` by name
  ## (`{"circle-check": "green"}`); by default they take the colour of the text. In text output
  ## the names stay. An unknown name raises `ValueError` here, not when the table is rendered.
  if a11y notin ["semantic", "decorative", "none"]:
    raise newException(ValueError, "a11y is \"semantic\", \"decorative\" or \"none\", not " & a11y.escape)
  discard cssLength(height)
  let names = columns.resolve(t.data)
  let ix = rows.resolve(t.data)
  for n in names:
    for i in ix:
      let v = t.data[n, i]
      if v.isNull: continue
      for name in iconNames($v):
        if not hasIcon(name): raise newException(ValueError, "no Font Awesome Free icon named " & name.escape)
  var byName: Table[string, string]
  for (k, c) in fillColors: byName[k] = c
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    let list = iconNames($v)
    if ctx == rcText: return list.join(", ")
    var parts: seq[string]
    for name in list:
      parts.add iconSvg(name, height, byName.getOrDefault(name, fillColor), fillAlpha, strokeColor,
                      strokeWidth, strokeAlpha, marginLeft, marginRight, a11y = a11y)
    "<span style=\"white-space:nowrap;\">" & parts.join(escapeHtml(sep)) & "</span>", rows)

# ---------------------------------------------------------------------------------------- images

const imageTypes = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
                    ".gif": "image/gif", ".svg": "image/svg+xml", ".webp": "image/webp",
                    ".avif": "image/avif", ".bmp": "image/bmp", ".ico": "image/x-icon"}.toTable

func isUrl(s: string): bool =
  s.startsWith("http://") or s.startsWith("https://") or s.startsWith("data:")

proc imageDataUrl*(file: string): string =
  ## A file as a data URL, its type from its extension: `imageDataUrl("moon.png")` is
  ## "data:image/png;base64,...". Raises `ValueError` for a file that is not there.
  let ext = file.splitFile.ext.toLowerAscii
  if ext notin imageTypes: raise newException(ValueError, "not an image file (png, jpg, gif, svg, webp, avif, bmp, ico): " & file.escape)
  if not fileExists(file): raise newException(ValueError, "no image file " & file.escape)
  "data:" & imageTypes[ext] & ";base64," & encode(readFile(file))

proc fmtImage*(t: sink Tabella, columns: ColSel, rows = allRows(), height = "", width = "",
               sep = " ", path = "", filePattern = "{x}", encode = true, alt = ""): Tabella =
  ## File names as images: each cell holds one or more names (separated by commas), found in
  ## `path` and written with `filePattern` ("{x}.png" for a cell "moon"). With `encode` (the
  ## default) a local file is read now and inlined as a data URL, so the page needs nothing else;
  ## an address (`https://...`) is left as it is. Without `height` or `width` an image is 2em
  ## high. `alt` is the text a screen reader reads ("{x}" is the name); by default the name. In
  ## text output the names stay.
  let names = columns.resolve(t.data)
  let ix = rows.resolve(t.data)
  proc source(name: string): string =
    let file = filePattern.replace("{x}", name)
    if file.isUrl or path.isUrl: (if path.len > 0 and not file.isUrl: path.strip(leading = false, chars = {'/'}) & "/" & file else: file)
    elif path.len > 0: path / file
    else: file
  var urls: Table[string, string]
  for n in names:
    for i in ix:
      let v = t.data[n, i]
      if v.isNull: continue
      for name in iconNames($v):
        let s = source(name)
        if s notin urls: urls[s] = (if encode and not s.isUrl: imageDataUrl(s) else: s)
  let h = if height.len == 0 and width.len == 0: "2em" else: height
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    let list = iconNames($v)
    if ctx == rcText: return list.join(", ")
    var parts: seq[string]
    for name in list:
      var style: seq[string]
      if h.len > 0: style.add "height:" & h
      if width.len > 0: style.add "width:" & width
      style.add "vertical-align:middle"
      let a = if alt.len > 0: alt.replace("{x}", name) else: name
      parts.add "<img src=\"" & escapeHtml(urls.getOrDefault(source(name), source(name))) & "\" alt=\"" &
        escapeHtml(a) & "\" style=\"" & style.join(";") & "\">"
    "<span style=\"white-space:nowrap;\">" & parts.join(escapeHtml(sep)) & "</span>", rows)
