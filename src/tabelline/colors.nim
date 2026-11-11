## Colours for `dataColor`: hex parsing, palettes, linear interpolation and the text colour that
## reads best on a fill (WCAG relative luminance).

import std/[strutils, math, tables]

type Rgb* = tuple[r, g, b: float]   ## 0..255

const namedColors = {
  # the 148 colour names of CSS (CSS Color Module Level 4), so `palette = @["darkgreen"]` works
  "aliceblue": "#F0F8FF", "antiquewhite": "#FAEBD7", "aqua": "#00FFFF", "aquamarine": "#7FFFD4",
  "azure": "#F0FFFF", "beige": "#F5F5DC", "bisque": "#FFE4C4", "black": "#000000",
  "blanchedalmond": "#FFEBCD", "blue": "#0000FF", "blueviolet": "#8A2BE2", "brown": "#A52A2A",
  "burlywood": "#DEB887", "cadetblue": "#5F9EA0", "chartreuse": "#7FFF00", "chocolate": "#D2691E",
  "coral": "#FF7F50", "cornflowerblue": "#6495ED", "cornsilk": "#FFF8DC", "crimson": "#DC143C",
  "cyan": "#00FFFF", "darkblue": "#00008B", "darkcyan": "#008B8B", "darkgoldenrod": "#B8860B",
  "darkgray": "#A9A9A9", "darkgreen": "#006400", "darkgrey": "#A9A9A9", "darkkhaki": "#BDB76B",
  "darkmagenta": "#8B008B", "darkolivegreen": "#556B2F", "darkorange": "#FF8C00",
  "darkorchid": "#9932CC", "darkred": "#8B0000", "darksalmon": "#E9967A",
  "darkseagreen": "#8FBC8F", "darkslateblue": "#483D8B", "darkslategray": "#2F4F4F",
  "darkslategrey": "#2F4F4F", "darkturquoise": "#00CED1", "darkviolet": "#9400D3",
  "deeppink": "#FF1493", "deepskyblue": "#00BFFF", "dimgray": "#696969", "dimgrey": "#696969",
  "dodgerblue": "#1E90FF", "firebrick": "#B22222", "floralwhite": "#FFFAF0",
  "forestgreen": "#228B22", "fuchsia": "#FF00FF", "gainsboro": "#DCDCDC", "ghostwhite": "#F8F8FF",
  "gold": "#FFD700", "goldenrod": "#DAA520", "gray": "#808080", "green": "#008000",
  "greenyellow": "#ADFF2F", "grey": "#808080", "honeydew": "#F0FFF0", "hotpink": "#FF69B4",
  "indianred": "#CD5C5C", "indigo": "#4B0082", "ivory": "#FFFFF0", "khaki": "#F0E68C",
  "lavender": "#E6E6FA", "lavenderblush": "#FFF0F5", "lawngreen": "#7CFC00",
  "lemonchiffon": "#FFFACD", "lightblue": "#ADD8E6", "lightcoral": "#F08080",
  "lightcyan": "#E0FFFF", "lightgoldenrodyellow": "#FAFAD2", "lightgray": "#D3D3D3",
  "lightgreen": "#90EE90", "lightgrey": "#D3D3D3", "lightpink": "#FFB6C1",
  "lightsalmon": "#FFA07A", "lightseagreen": "#20B2AA", "lightskyblue": "#87CEFA",
  "lightslategray": "#778899", "lightslategrey": "#778899", "lightsteelblue": "#B0C4DE",
  "lightyellow": "#FFFFE0", "lime": "#00FF00", "limegreen": "#32CD32", "linen": "#FAF0E6",
  "magenta": "#FF00FF", "maroon": "#800000", "mediumaquamarine": "#66CDAA",
  "mediumblue": "#0000CD", "mediumorchid": "#BA55D3", "mediumpurple": "#9370DB",
  "mediumseagreen": "#3CB371", "mediumslateblue": "#7B68EE", "mediumspringgreen": "#00FA9A",
  "mediumturquoise": "#48D1CC", "mediumvioletred": "#C71585", "midnightblue": "#191970",
  "mintcream": "#F5FFFA", "mistyrose": "#FFE4E1", "moccasin": "#FFE4B5", "navajowhite": "#FFDEAD",
  "navy": "#000080", "oldlace": "#FDF5E6", "olive": "#808000", "olivedrab": "#6B8E23",
  "orange": "#FFA500", "orangered": "#FF4500", "orchid": "#DA70D6", "palegoldenrod": "#EEE8AA",
  "palegreen": "#98FB98", "paleturquoise": "#AFEEEE", "palevioletred": "#DB7093",
  "papayawhip": "#FFEFD5", "peachpuff": "#FFDAB9", "peru": "#CD853F", "pink": "#FFC0CB",
  "plum": "#DDA0DD", "powderblue": "#B0E0E6", "purple": "#800080", "rebeccapurple": "#663399",
  "red": "#FF0000", "rosybrown": "#BC8F8F", "royalblue": "#4169E1", "saddlebrown": "#8B4513",
  "salmon": "#FA8072", "sandybrown": "#F4A460", "seagreen": "#2E8B57", "seashell": "#FFF5EE",
  "sienna": "#A0522D", "silver": "#C0C0C0", "skyblue": "#87CEEB", "slateblue": "#6A5ACD",
  "slategray": "#708090", "slategrey": "#708090", "snow": "#FFFAFA", "springgreen": "#00FF7F",
  "steelblue": "#4682B4", "tan": "#D2B48C", "teal": "#008080", "thistle": "#D8BFD8",
  "tomato": "#FF6347", "turquoise": "#40E0D0", "violet": "#EE82EE", "wheat": "#F5DEB3",
  "white": "#FFFFFF", "whitesmoke": "#F5F5F5", "yellow": "#FFFF00", "yellowgreen": "#9ACD32"}.toTable

func parseColor*(c: string): Rgb =
  ## `#rgb`, `#rrggbb` or any of the 148 CSS colour names (`darkgreen`, `rebeccapurple`).
  var h = c.strip.toLowerAscii
  if h in namedColors: h = namedColors[h].toLowerAscii
  if h.startsWith("#"): h = h[1 .. ^1]
  if h.len == 3: h = h[0] & h[0] & h[1] & h[1] & h[2] & h[2]
  if h.len != 6 or not h.allCharsInSet(HexDigits): raise newException(ValueError, "not a colour: " & c)
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
