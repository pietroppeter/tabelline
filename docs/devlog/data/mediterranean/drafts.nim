## The drawings of the post "Designing a Mediterranean look": a draft of a shape or motif for
## each source, in its six colours, and the palettes on a plane (from `clusters.json`). The
## colours come from `mediterraneanSources` (docs/theme.nim); the page only names the sources.

import std/[algorithm, json, math, os, strformat, strutils]
import ../../../theme

type Pal = object
  paper, ink, primary, secondary, warning, success: string

func pal(key: string): Pal =
  let c = sourceColours(key)
  Pal(paper: c[0].hex, ink: c[1].hex, primary: c[2].hex, secondary: c[3].hex, warning: c[4].hex, success: c[5].hex)

func mix(a, b: string, t: float): string =
  ## `a` mixed with `b`, `t` of `b`.
  result = "#"
  for i in [1, 3, 5]:
    let (x, y) = (parseHexInt(a[i .. i + 1]).float, parseHexInt(b[i .. i + 1]).float)
    result.add toHex(int(round(x + (y - x) * t)), 2)

const W = 200
const H = 100

func svg(p: Pal, body: string): string =
  &"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">""" &
    &"""<rect width="{W}" height="{H}" fill="{p.paper}"/>{body}</svg>"""

func f(x: float): string = formatFloat(x, ffDecimal, 1)

# ------------------------------------------------------------------------------------- drafts

func minoan(p: Pal): string =
  ## a meander between two rules, on a terracotta band, and a row of waves under it
  var d = ""
  for k in 0 ..< 8:
    let x = 8 + k * 23
    d.add &"M{x} 52 V24 H{x + 18} V44 H{x + 6} V34 H{x + 12} "
  var waves = ""
  for k in 0 ..< 9:
    let x = 6 + k * 21
    waves.add &"""<path d="M{x} 84 c0 -10 14 -10 14 -2 c0 5 -7 5 -7 0" fill="none" stroke="{p.secondary}" stroke-width="2.4"/>"""
  svg(p, &"""<rect x="0" y="14" width="{W}" height="48" fill="{p.primary}"/>""" &
    &"""<path d="{d}" fill="none" stroke="{p.ink}" stroke-width="3" stroke-linejoin="miter"/>""" &
    &"""<path d="M0 18 H{W} M0 58 H{W}" stroke="{p.ink}" stroke-width="2"/>{waves}""")

func casale(p: Pal): string =
  ## a floor of tesserae: a border of two rows, a field inside
  var r = ""
  let (s, g) = (10.0, 1.6)
  for row in 0 ..< 9:
    for col in 0 ..< 18:
      let edge = min(min(row, 8 - row), min(col, 17 - col))
      let c = case edge
        of 0: p.ink
        of 1: (if (row + col) mod 2 == 0: p.primary else: p.warning)
        of 2: p.paper
        else: (if (row + col) mod 3 == 0: p.secondary else: mix(p.paper, p.secondary, 0.25))
      r.add &"""<rect x="{f(2 + col.float * (s + g))}" y="{f(2 + row.float * (s + g))}" width="{s}" height="{s}" fill="{c}"/>"""
  svg(p, &"""<rect width="{W}" height="{H}" fill="{mix(p.paper, p.ink, 0.25)}"/>{r}""")

func isolari(p: Pal): string =
  ## a compass rose with its rhumb lines, beside an island drawn from above
  let (cx, cy) = (62.0, 50.0)
  var lines = ""
  for k in 0 ..< 16:
    let a = k.float * PI / 8
    lines.add &"""<path d="M{f(cx)} {f(cy)} L{f(cx + 140 * cos(a))} {f(cy + 140 * sin(a))}" stroke="{p.ink}" stroke-width="0.6" opacity=".55"/>"""
  var star = ""
  for k in 0 ..< 8:
    let a = k.float * PI / 4 - PI / 2
    let len = (if k mod 2 == 0: 30.0 else: 18.0)
    let (b1, b2) = (a - 0.3, a + 0.3)
    let c = (if k mod 2 == 0: p.primary else: p.ink)
    star.add &"""<path d="M{f(cx)} {f(cy)} L{f(cx + 7 * cos(b1))} {f(cy + 7 * sin(b1))} L{f(cx + len * cos(a))} {f(cy + len * sin(a))} L{f(cx + 7 * cos(b2))} {f(cy + 7 * sin(b2))} Z" fill="{c}"/>"""
  svg(p, lines & &"""<circle cx="{cx}" cy="{cy}" r="22" fill="none" stroke="{p.ink}" stroke-width="1"/>""" & star &
    &"""<path d="M140 30 q16 -10 30 2 q12 10 4 26 q-6 14 -24 10 q-18 -4 -18 -18 q0 -14 8 -20 Z" fill="{p.warning}" stroke="{p.ink}" stroke-width="1.2"/>""" &
    &"""<path d="M150 46 l6 -8 l6 8 Z" fill="{p.success}"/><circle cx="{cx}" cy="{cy}" r="3" fill="{p.paper}"/>""")

func maiolica(p: Pal): string =
  ## two tiles: a cobalt four-petal flower, yellow centre, green leaves, terracotta corners
  var r = ""
  for t in 0 ..< 2:
    let (x, y) = (10.0 + t.float * 92, 8.0)
    let (cx, cy) = (x + 42, y + 42)
    r.add &"""<rect x="{x}" y="{y}" width="84" height="84" fill="{p.paper}" stroke="{mix(p.paper, p.ink, 0.3)}" stroke-width="1"/>"""
    for (dx, dy) in [(0.0, 0.0), (84.0, 0.0), (0.0, 84.0), (84.0, 84.0)]:
      r.add &"""<path d="M{x + dx} {y + dy + (if dy == 0: 16.0 else: -16.0)} Q{x + dx + (if dx == 0: 16.0 else: -16.0)} {y + dy + (if dy == 0: 16.0 else: -16.0)} {x + dx + (if dx == 0: 16.0 else: -16.0)} {y + dy} L{x + dx} {y + dy} Z" fill="{p.secondary}"/>"""
    for k in 0 ..< 4:
      let a = k.float * PI / 2 + PI / 4
      r.add &"""<ellipse cx="{f(cx + 20 * cos(a))}" cy="{f(cy + 20 * sin(a))}" rx="9" ry="4.5" transform="rotate({f(a * 180 / PI)} {f(cx + 20 * cos(a))} {f(cy + 20 * sin(a))})" fill="{p.success}"/>"""
    for k in 0 ..< 4:
      let a = k.float * PI / 2
      r.add &"""<ellipse cx="{f(cx + 15 * cos(a))}" cy="{f(cy + 15 * sin(a))}" rx="15" ry="9" transform="rotate({f(a * 180 / PI)} {f(cx + 15 * cos(a))} {f(cy + 15 * sin(a))})" fill="{p.primary}"/>"""
    r.add &"""<circle cx="{cx}" cy="{cy}" r="8" fill="{p.warning}" stroke="{p.ink}" stroke-width="1"/>"""
  svg(p, r)

func bauer(p: Pal): string =
  ## a leaf in a hairline, numbers that stand for colours, and the table of colours beside it
  var r = &"""<path d="M30 86 C40 50 70 20 112 14 C104 52 78 80 30 86 Z" fill="none" stroke="{p.ink}" stroke-width="0.9"/>""" &
    &"""<path d="M30 86 C58 62 82 40 112 14" fill="none" stroke="{p.ink}" stroke-width="0.6"/>"""
  for (x, y, n) in [(58.0, 48.0, "23"), (84.0, 34.0, "7"), (52.0, 70.0, "41")]:
    r.add &"""<text x="{x}" y="{y}" font-family="Georgia, serif" font-style="italic" font-size="9" fill="{p.ink}">{n}</text>"""
  for i, (n, c) in [("7", p.success), ("23", mix(p.success, p.paper, 0.4)), ("41", p.primary), ("52", p.secondary), ("60", p.warning)]:
    let y = 12.0 + i.float * 16
    r.add &"""<rect x="140" y="{y}" width="12" height="11" fill="{c}"/><text x="158" y="{y + 9}" font-family="Georgia, serif" font-size="9" fill="{p.ink}">{n}</text>"""
  svg(p, r)

func luzzu(p: Pal): string =
  ## the bow of a luzzu: bands of colour along the hull, and the eye
  svg(p, &"""<path d="M6 30 H170 Q196 30 192 14 L198 14 Q200 60 160 84 H24 Q10 60 6 30 Z" fill="{p.primary}"/>""" &
    &"""<path d="M7 38 H186 Q182 48 176 54 H12 Q9 46 7 38 Z" fill="{p.warning}"/>""" &
    &"""<path d="M12 54 H176 Q172 60 168 62 H14 Z" fill="{p.success}"/>""" &
    &"""<path d="M18 74 H158 Q154 80 150 84 H24 Z" fill="{p.secondary}"/>""" &
    &"""<path d="M130 46 Q146 34 162 46 Q146 58 130 46 Z" fill="{p.paper}" stroke="{p.ink}" stroke-width="1.5"/>""" &
    &"""<circle cx="146" cy="46" r="5" fill="{p.ink}"/><path d="M4 30 H198" stroke="{p.ink}" stroke-width="2"/>""")

func matisse(p: Pal): string =
  ## cut paper: a seaweed and a star that miss their lines a little
  svg(p, &"""<path d="M40 92 C34 70 52 66 44 50 C36 34 56 30 50 12 C62 26 54 38 62 50 C70 62 52 70 60 92 Z" fill="{p.primary}"/>""" &
    &"""<path d="M70 92 C76 78 64 72 74 60 C82 50 70 44 78 32 C88 46 80 54 86 64 C92 74 80 80 84 92 Z" fill="{p.success}"/>""" &
    &"""<path d="M140 22 L147 42 L168 40 L152 54 L160 74 L141 62 L124 76 L130 55 L114 42 L135 41 Z" fill="{p.secondary}"/>""" &
    &"""<circle cx="182" cy="20" r="10" fill="{p.warning}"/>""" &
    &"""<path d="M98 80 C110 72 122 88 136 80 C150 72 162 88 176 80" fill="none" stroke="{p.primary}" stroke-width="4"/>""")

func lionni(p: Pal): string =
  ## a school of small red fish that swim as one big fish, and one black fish for its eye
  var r = &"""<rect width="{W}" height="{H}" fill="{mix(p.paper, p.secondary, 0.18)}"/>"""
  proc fish(x, y: float, c: string): string =
    &"""<ellipse cx="{f(x)}" cy="{f(y)}" rx="4.6" ry="2.6" fill="{c}"/><path d="M{f(x - 4)} {f(y)} l-4 -3 v6 Z" fill="{c}"/>"""
  for row in 0 ..< 8:
    for col in 0 ..< 14:
      let (x, y) = (40.0 + col.float * 10 + (row mod 2).float * 5, 16.0 + row.float * 9)
      let dx = (x - 105) / 72
      let dy = (y - 48) / 34
      let tail = x < 52 and abs(y - 48) < 26 - (x - 34)
      if dx * dx + dy * dy <= 1 or tail:
        r.add fish(x, y, (if row == 3 and col == 11: p.ink else: p.primary))
  svg(p, r & &"""<path d="M0 94 C30 86 50 98 80 92 S140 86 200 94 V100 H0 Z" fill="{p.success}"/>""")

func luzzati(p: Pal): string =
  ## a little stage: an arch, curtains, a painted backdrop, black outlines
  svg(p, &"""<rect x="22" y="16" width="156" height="78" fill="{p.secondary}" stroke="{p.ink}" stroke-width="2"/>""" &
    &"""<circle cx="140" cy="38" r="10" fill="{p.warning}" stroke="{p.ink}" stroke-width="1.5"/>""" &
    &"""<path d="M22 78 Q60 58 100 76 T178 70 V94 H22 Z" fill="{p.success}" stroke="{p.ink}" stroke-width="1.5"/>""" &
    &"""<path d="M14 94 V22 Q100 -6 186 22 V94 H172 V30 Q100 8 28 30 V94 Z" fill="{p.warning}" stroke="{p.ink}" stroke-width="2"/>""" &
    &"""<path d="M28 30 Q48 50 34 94 H28 Z M172 30 Q152 50 166 94 H172 Z" fill="{p.primary}" stroke="{p.ink}" stroke-width="1.5"/>""" &
    &"""<path d="M28 30 Q100 8 172 30 Q100 26 28 30 Z" fill="{p.primary}" stroke="{p.ink}" stroke-width="1.5"/>""")

func lai(p: Pal): string =
  ## houses tied by a blue ribbon, and a stitched rule under them
  var r = ""
  for i, x in [20.0, 64, 108, 152]:
    let y = (if i mod 2 == 0: 40.0 else: 30.0)
    r.add &"""<path d="M{x} {y + 22} V{y + 6} L{x + 12} {y - 4} L{x + 24} {y + 6} V{y + 22} Z" fill="{mix(p.paper, p.secondary, 0.35)}" stroke="{p.ink}" stroke-width="1"/>"""
  r.add &"""<path d="M6 30 C20 60 40 10 56 44 S90 14 104 44 S140 18 150 40 S180 30 196 50" fill="none" stroke="{p.primary}" stroke-width="3"/>"""
  r.add &"""<path d="M8 82 H192" stroke="{p.ink}" stroke-width="1.6" stroke-dasharray="6 4"/>"""
  r.add &"""<path d="M8 88 H192" stroke="{p.secondary}" stroke-width="1" stroke-dasharray="2 4"/>"""
  svg(p, r)

func vitali(p: Pal): string =
  ## a beach seen from above: shallow sea, sand, a crowd of small marks and umbrellas
  var r = &"""<path d="M0 0 H{W} V34 C150 40 60 28 0 38 Z" fill="{p.primary}"/>""" &
    &"""<path d="M0 38 C60 28 150 40 200 34 V40 C150 46 60 34 0 44 Z" fill="{mix(p.primary, p.paper, 0.6)}"/>"""
  var seed = 7
  proc rnd(): float =
    seed = (seed * 1103515245 + 12345) mod 2147483648
    seed.float / 2147483648.0
  for _ in 0 ..< 90:
    let (x, y) = (4 + rnd() * 192, 46 + rnd() * 50)
    let c = [p.ink, p.secondary, mix(p.ink, p.paper, 0.4), p.success][int(rnd() * 4) mod 4]
    r.add &"""<circle cx="{f(x)}" cy="{f(y)}" r="1.4" fill="{c}"/>"""
  for (x, y, c) in [(30.0, 60.0, p.secondary), (90.0, 72.0, p.warning), (150.0, 58.0, p.secondary), (170.0, 84.0, p.warning), (60.0, 88.0, p.warning)]:
    r.add &"""<circle cx="{x}" cy="{y}" r="6" fill="{c}"/>"""
  for _ in 0 ..< 18:
    r.add &"""<circle cx="{f(4 + rnd() * 192)}" cy="{f(10 + rnd() * 22)}" r="1.2" fill="{p.paper}"/>"""
  svg(p, r)

func mediterraneo(p: Pal): string =
  ## a harbour front: whitewash, plaster houses on the water, and a title widely spaced
  var r = &"""<rect y="62" width="{W}" height="38" fill="{p.primary}"/>"""
  for i, (w, c) in [(26.0, p.secondary), (20.0, p.warning), (30.0, p.paper), (22.0, p.secondary), (24.0, p.warning), (28.0, p.paper), (26.0, p.secondary)]:
    var x = 4.0
    for j in 0 ..< i: x += [26.0, 20, 30, 22, 24, 28, 26][j] + 2
    let h = 22.0 + (i mod 3).float * 6
    r.add &"""<rect x="{x}" y="{62 - h}" width="{w}" height="{h}" fill="{c}" stroke="{mix(p.ink, p.paper, 0.6)}" stroke-width=".6"/>"""
    r.add &"""<rect x="{x + w / 2 - 3}" y="{62 - h + 6}" width="6" height="8" fill="{p.success}"/>"""
  r.add &"""<text x="100" y="86" text-anchor="middle" font-family="Georgia, serif" font-size="11" letter-spacing="7" fill="{p.paper}">MEDITERRANEO</text>"""
  svg(p, r)

func procida(p: Pal): string =
  ## Corricella: houses side by side, each its own pastel, arches and green shutters, on the water
  var r = &"""<rect y="80" width="{W}" height="20" fill="{mix(p.secondary, p.paper, 0.35)}"/>"""
  let tints = [mix(p.primary, p.paper, 0.55), mix(p.warning, p.paper, 0.45), mix(p.secondary, p.paper, 0.6),
               mix(p.primary, p.paper, 0.75), mix(p.warning, p.paper, 0.25), mix(p.success, p.paper, 0.7), p.paper]
  var x = 2.0
  for i, c in tints:
    let (w, h) = (26.0 + (i mod 2).float * 4, 46.0 + ((i * 7) mod 4).float * 7)
    r.add &"""<rect x="{x}" y="{80 - h}" width="{w}" height="{h}" fill="{c}" stroke="{mix(p.ink, p.paper, 0.7)}" stroke-width=".5"/>"""
    r.add &"""<path d="M{x + w / 2 - 6} 80 V72 A6 6 0 0 1 {x + w / 2 + 6} 72 V80 Z" fill="{mix(p.ink, p.paper, 0.35)}"/>"""
    for wy in [80 - h + 8, 80 - h + 22]:
      if wy < 62:
        r.add &"""<rect x="{x + 5}" y="{wy}" width="5" height="8" fill="{p.success}"/><rect x="{x + w - 10}" y="{wy}" width="5" height="8" fill="{p.success}"/>"""
    x += w + 0.5
  svg(p, r)

func djerba(p: Pal): string =
  ## a menzel: a plain outside with no windows, domes, and colour only at the door; pots of clay
  svg(p, &"""<rect width="{W}" height="{H}" fill="{mix(p.paper, p.warning, 0.25)}"/>""" &
    &"""<path d="M20 86 V48 H70 V40 A16 16 0 0 1 102 40 V48 H150 V58 A12 12 0 0 1 174 58 V86 Z" fill="{p.paper}" stroke="{mix(p.ink, p.paper, 0.5)}" stroke-width="1"/>""" &
    &"""<path d="M78 86 V66 A8 8 0 0 1 94 66 V86 Z" fill="{p.primary}"/>""" &
    &"""<path d="M6 86 Q2 70 10 62 L8 56 H16 L14 62 Q22 70 18 86 Z" fill="{p.secondary}"/>""" &
    &"""<path d="M180 86 Q176 74 184 66 L182 62 H190 L188 66 Q196 74 192 86 Z" fill="{p.secondary}"/>""" &
    &"""<path d="M120 48 V30 M120 30 q-12 -6 -18 0 M120 30 q12 -6 18 0 M120 30 q-6 -12 -14 -12 M120 30 q6 -12 14 -12" stroke="{p.success}" stroke-width="3" fill="none"/>""" &
    &"""<rect y="86" width="{W}" height="14" fill="{mix(p.warning, p.secondary, 0.3)}"/>""")

const motifs* = [("minoan", "a meander between two rules, and waves"), ("casale", "a floor of tesserae, its border in two rows"),
  ("isolari", "the compass rose and its rhumb lines, an island from above"), ("maiolica", "two tiles, a flower and corners"),
  ("bauer", "a leaf in a hairline, numbers for colours, the table of colours"), ("luzzu", "bands along the hull, and the eye"),
  ("matisse", "cut paper: seaweed, a star"), ("lionni", "small fish that swim as one"), ("luzzati", "a little stage"),
  ("lai", "houses tied by a ribbon, a stitched rule"), ("vitali", "a beach from above, a crowd of small marks"),
  ("mediterraneo", "a harbour front, a title widely spaced"), ("procida", "houses side by side, each its own pastel"),
  ("djerba", "a plain outside, domes, colour at the door")]

func motif*(key: string): string =
  let p = pal(key)
  case key
  of "minoan": minoan(p)
  of "casale": casale(p)
  of "isolari": isolari(p)
  of "maiolica": maiolica(p)
  of "bauer": bauer(p)
  of "luzzu": luzzu(p)
  of "matisse": matisse(p)
  of "lionni": lionni(p)
  of "luzzati": luzzati(p)
  of "lai": lai(p)
  of "vitali": vitali(p)
  of "mediterraneo": mediterraneo(p)
  of "procida": procida(p)
  of "djerba": djerba(p)
  else: ""

proc writeMotifs*(dir: string) =
  ## Every draft as `<key>.svg` in `dir`.
  createDir dir
  for (key, _) in motifs: writeFile(dir / key & ".svg", motif(key))

# ------------------------------------------------------------------------------ the palettes' map

const shortNames* = [("minoan", "Minoan"), ("isolari", "Isolari"), ("matisse", "Matisse"), ("miro", "Miró"),
  ("list", "List, Manos"), ("maiolica", "Maiolica"), ("scianna", "Scianna"), ("vitali", "Vitali"), ("luzzu", "Luzzu"),
  ("lionni", "Lionni"), ("luzzati", "Luzzati"), ("lai", "Lai"), ("casale", "Casale"), ("bauer", "Bauer"),
  ("procida", "Procida"), ("mediterraneo", "Mediterraneo"), ("djerba", "Djerba"), ("ghirri", "Ghirri")]

func shortName*(key: string): string =
  for (k, n) in shortNames:
    if k == key: return n
  key

proc palettesMap*(clusters: JsonNode, discarded: openArray[string]): string =
  ## Every palette as a small wheel of its six colours, where the two principal components put
  ## it; the exemplar of each cluster ringed, its name in bold; the discarded in italic; each
  ## cluster's points joined to their exemplar. A cluster of one, far from the rest, is drawn at
  ## the edge, with an arrow that says it lies further out, so the others keep their room.
  const (w, h, m) = (360.0, 340.0, 30.0)
  var size: seq[int]
  for pt in clusters["points"]:
    let c = pt["cluster"].getInt
    while size.len <= c: size.add 0
    inc size[c]
  var (x0, x1, y0, y1) = (Inf, -Inf, Inf, -Inf)
  for pt in clusters["points"]:
    if size[pt["cluster"].getInt] == 1: continue
    x0 = min(x0, pt["x"].getFloat); x1 = max(x1, pt["x"].getFloat)
    y0 = min(y0, pt["y"].getFloat); y1 = max(y1, pt["y"].getFloat)
  proc px(v: float): float = m + 6 + (v - x0) / (x1 - x0) * (w - 2 * m - 12)
  proc py(v: float): float = h - m - 8 - (v - y0) / (y1 - y0) * (h - 2 * m - 30)
  var pos: seq[(string, float, float, int, bool)]
  var r = &"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" font-family="Jost, Arimo, sans-serif">"""
  for pt in clusters["points"]:
    var (x, y) = (px(pt["x"].getFloat), py(pt["y"].getFloat))
    if size[pt["cluster"].getInt] == 1:   # far out: at the edge, with an arrow toward where it is
      let (cx, cy) = (clamp(x, m + 20, w - 20), clamp(y, 22.0, h - m - 8))
      let (dx, dy) = (x - cx, y - cy)
      let d = max(1e-9, sqrt(dx * dx + dy * dy))
      let (ux, uy) = (dx / d, dy / d)
      r.add &"""<path d="M{f(cx + 13 * ux)} {f(cy + 13 * uy)} L{f(cx + 22 * ux)} {f(cy + 22 * uy)}" stroke="currentColor" stroke-width="1.2"/>"""
      r.add &"""<path d="M{f(cx + 25 * ux)} {f(cy + 25 * uy)} L{f(cx + 19 * ux - 3 * uy)} {f(cy + 19 * uy + 3 * ux)} L{f(cx + 19 * ux + 3 * uy)} {f(cy + 19 * uy - 3 * ux)} Z" fill="currentColor"/>"""
      (x, y) = (cx, cy)
    pos.add (pt["key"].getStr, x, y, pt["cluster"].getInt, pt["exemplar"].getBool)
  r.add &"""<path d="M{m - 12} {h - 16} H{w - 4} M{m - 12} {h - 16} V4" stroke="currentColor" stroke-width=".8" opacity=".5" fill="none"/>"""
  let ex = clusters["explained"]
  r.add &"""<text x="{w - 4}" y="{h - 4}" text-anchor="end" font-size="10" fill="currentColor" opacity=".75">first component: {int(round(ex[0].getFloat * 100))}% of the differences</text>"""
  r.add &"""<text transform="translate({m - 20} 4) rotate(90)" font-size="10" fill="currentColor" opacity=".75">second: {int(round(ex[1].getFloat * 100))}%</text>"""
  for (k, x, y, c, isEx) in pos:
    if isEx: continue
    for (k2, x2, y2, c2, isEx2) in pos:
      if isEx2 and c2 == c:
        r.add &"""<path d="M{f(x)} {f(y)} L{f(x2)} {f(y2)}" stroke="currentColor" stroke-width=".7" opacity=".3"/>"""
  for (k, x, y, c, isEx) in pos:
    let cols = sourceColours(k)
    for i in 0 ..< 6:
      let (a0, a1) = (i.float * PI / 3 - PI / 2, (i + 1).float * PI / 3 - PI / 2)
      let rr = 7.0
      r.add &"""<path d="M{f(x)} {f(y)} L{f(x + rr * cos(a0))} {f(y + rr * sin(a0))} A{rr} {rr} 0 0 1 {f(x + rr * cos(a1))} {f(y + rr * sin(a1))} Z" fill="{cols[i].hex}"/>"""
    r.add &"""<circle cx="{f(x)}" cy="{f(y)}" r="7" fill="none" stroke="currentColor" stroke-width="{(if isEx: 2.0 else: 0.6)}"/>"""
    if isEx: r.add &"""<circle cx="{f(x)}" cy="{f(y)}" r="10.5" fill="none" stroke="currentColor" stroke-width=".8"/>"""
  # the names: the first free place around the wheel, nearest first; a thin line to a far one
  var boxes: seq[(float, float, float, float)]
  for (k, x, y, c, isEx) in pos: boxes.add (x - 8, y - 8, x + 8, y + 8)
  func hit(a, b: (float, float, float, float)): bool = a[0] < b[2] and b[0] < a[2] and a[1] < b[3] and b[1] < a[3]
  var order = pos
  order.sort(proc (a, b: (string, float, float, int, bool)): int = cmp(b[4], a[4]))   # exemplars first
  for (k, x, y, c, isEx) in order:
    let name = shortName(k)
    let tw = name.len.float * 5.4 + (if isEx: 5.0 else: 0.0)
    var placed = false
    for dist in [11.0, 22, 34, 48, 64]:
      for step in 0 ..< 16:
        let a = step.float * PI / 8
        let (lx, ly) = (x + dist * cos(a), y + dist * sin(a))
        let anchor = (if cos(a) > 0.3: "start" elif cos(a) < -0.3: "end" else: "middle")
        let left = (if anchor == "start": lx elif anchor == "end": lx - tw else: lx - tw / 2)
        let b = (left - 1, ly - 5.5, left + tw + 1, ly + 5.5)
        if b[0] < 0 or b[2] > w or b[1] < 0 or b[3] > h - 18: continue
        var ok = true
        for o in boxes:
          if hit(b, o): ok = false; break
        if not ok: continue
        if dist > 11:
          r.add &"""<path d="M{f(x + 8 * cos(a))} {f(y + 8 * sin(a))} L{f(lx - 2 * cos(a))} {f(ly - 2 * sin(a))}" stroke="currentColor" stroke-width=".5" opacity=".6"/>"""
        let style = (if isEx: " font-weight=\"700\"" else: "") & (if k in discarded: " font-style=\"italic\" opacity=\".7\"" else: "")
        r.add &"""<text x="{f(lx)}" y="{f(ly + 3.5)}" text-anchor="{anchor}" font-size="10"{style} fill="currentColor">{name}</text>"""
        boxes.add b; placed = true; break
      if placed: break
  r & "</svg>"
