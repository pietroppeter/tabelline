## Colours for `dataColor`: hex parsing, palettes, linear interpolation and the text colour that
## reads best on a fill (WCAG relative luminance).

import std/[strutils, math, tables]

type Rgb* = tuple[r, g, b: float]   ## 0..255

const namedColors = {"white": "#FFFFFF", "black": "#000000", "red": "#FF0000", "green": "#008000",
  "blue": "#0000FF", "yellow": "#FFFF00", "orange": "#FFA500", "purple": "#800080", "gray": "#808080",
  "grey": "#808080", "pink": "#FFC0CB", "lightblue": "#ADD8E6", "lightgreen": "#90EE90",
  "lightgray": "#D3D3D3", "steelblue": "#4682B4", "gold": "#FFD700", "tomato": "#FF6347"}.toTable

func parseColor*(c: string): Rgb =
  ## `#rgb`, `#rrggbb` or a few CSS names.
  var h = c.strip.toLowerAscii
  if h in namedColors: h = namedColors[h].toLowerAscii
  if h.startsWith("#"): h = h[1 .. ^1]
  if h.len == 3: h = h[0] & h[0] & h[1] & h[1] & h[2] & h[2]
  if h.len < 6: raise newException(ValueError, "not a colour: " & c)
  (float(parseHexInt(h[0..1])), float(parseHexInt(h[2..3])), float(parseHexInt(h[4..5])))

func toHex*(c: Rgb): string =
  "#" & toHex(int(round(c.r)), 2) & toHex(int(round(c.g)), 2) & toHex(int(round(c.b)), 2)

func mix*(a, b: Rgb, t: float): Rgb =
  (a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t)

func interpolate*(palette: openArray[string], t: float): string =
  ## The colour at `t` in 0..1 along a palette of evenly spaced stops.
  if palette.len == 0: return "#FFFFFF"
  if palette.len == 1: return palette[0]
  let x = clamp(t, 0.0, 1.0) * float(palette.len - 1)
  let i = min(int(floor(x)), palette.len - 2)
  mix(parseColor(palette[i]), parseColor(palette[i + 1]), x - float(i)).toHex

func luminance*(c: Rgb): float =
  func ch(v: float): float =
    let s = v / 255
    if s <= 0.03928: s / 12.92 else: pow((s + 0.055) / 1.055, 2.4)
  0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b)

func contrast*(a, b: Rgb): float =
  let (la, lb) = (luminance(a), luminance(b))
  (max(la, lb) + 0.05) / (min(la, lb) + 0.05)

func idealTextColor*(fill: string, dark = "#1a1a1a", light = "#FFFFFF"): string =
  ## Dark or light text, whichever contrasts more with `fill`.
  let f = parseColor(fill)
  if contrast(f, parseColor(dark)) >= contrast(f, parseColor(light)): dark else: light

const palettes* = {
  # pastelli: a box of school colouring pencils, light enough to write on
  "pastelli": @["#FFF3B0", "#FFD6A5", "#FFADAD", "#E4C1F9", "#A0C4FF", "#9BF6FF", "#CAFFBF"],
  "viridis": @["#440154", "#3B528B", "#21908C", "#5DC963", "#FDE725"],
  "blues": @["#F7FBFF", "#C6DBEF", "#6BAED6", "#2171B5", "#08306B"],
  "reds": @["#FFF5F0", "#FCBBA1", "#FB6A4A", "#CB181D", "#67000D"],
  "greens": @["#F7FCF5", "#C7E9C0", "#74C476", "#238B45", "#00441B"],
  "rdbu": @["#2166AC", "#92C5DE", "#F7F7F7", "#F4A582", "#B2182B"],
  "rdylgn": @["#D73027", "#FC8D59", "#FEE08B", "#D9EF8B", "#91CF60", "#1A9850"],
  "quaderno": @["#FFFFFF", "#DCEBFA", "#A9CCF0", "#6FA3DB", "#3C6FB6"],
  "matite": @["#E63946", "#F4A261", "#E9C46A", "#2A9D8F", "#457B9D", "#8E7DBE"]}.toTable

func palette*(name: string): seq[string] =
  ## A named palette (see `palettes`), or a comma-separated list of colours.
  if name in palettes: palettes[name] else: name.split(',')
