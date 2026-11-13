## The maps of the story: the Mediterranean, its seas and its islands, as two SVG drawings, the
## west and the east, so the names can be read on a phone.
##
##   nim r -d:release map.nim <raw> <folder>     (writes map-west.svg and map-east.svg, and the
##                                                Italian page's map-west-it.svg and map-east-it.svg)
##
## The land is OpenStreetMap's (the land polygons fetch.nim downloads, © OpenStreetMap
## contributors, ODbL), cut to the box of each map and simplified; the islands are islands.csv's
## points, the main ones filled and named, the others a dot. Where each name of a sea or an
## island goes was written by Claude, the AI that wrote the story. The drawing names its parts
## (sea, land, main, dot, sea-name, name) and the page's theme colours them (`.map` in
## docs/theme.nim), so the maps change with the look.
import std/[math, strutils, strformat, sequtils, parsecsv, memfiles, os]

let raw = paramStr(1)
let output = paramStr(2)
let here = currentSourcePath().parentDir.parentDir

# ------------------------------------------------------------------------------ the islands
type Island = object
  name, italian: string
  lon, lat: float
  main: bool
var islands: seq[Island]
var csv: CsvParser
csv.open(here / "islands.csv")
csv.readHeaderRow()   # the first line is the description
csv.readHeaderRow()
while csv.readRow():
  if csv.rowEntry("lat") == "": continue   # three islands have no place on Wikidata
  islands.add Island(name: csv.rowEntry("island"), italian: csv.rowEntry("italian"), lon: csv.rowEntry("lon").parseFloat,
                     lat: csv.rowEntry("lat").parseFloat, main: csv.rowEntry("main") == "true")
csv.close

# ------------------------------------------------------------------------------ the land
# Every ring of OpenStreetMap's land that has a point around the sea, its points held inside
# that box (outside it they only run along the edge, which is not drawn) and simplified
# (Douglas–Peucker, as in extract.nim) to a hundredth of a degree, about a kilometre.
const (west, east, south, north) = (-6.0, 36.5, 30.0, 46.5)

proc be32(p: pointer): int =
  let b = cast[ptr array[4, uint8]](p)
  int((b[0].uint32 shl 24) or (b[1].uint32 shl 16) or (b[2].uint32 shl 8) or b[3].uint32)
template at(base: pointer, off: int): pointer = cast[pointer](cast[int](base) + off)
template i32(p: pointer): int = cast[ptr int32](p)[].int

proc perpendicular(p, a, b: (float, float)): float =
  let (dx, dy) = (b[0] - a[0], b[1] - a[1])
  let l = hypot(dx, dy)
  if l == 0: hypot(p[0] - a[0], p[1] - a[1]) else: abs(dy * p[0] - dx * p[1] + b[0] * a[1] - b[1] * a[0]) / l

proc douglasPeucker(p: seq[(float, float)], tol: float): seq[(float, float)] =
  if p.len < 3: return p
  var keep = newSeq[bool](p.len)
  keep[0] = true; keep[^1] = true
  var stack = @[(0, p.high)]
  while stack.len > 0:
    let (a, b) = stack.pop
    var (far, d) = (-1, tol)
    for i in a + 1 ..< b:
      let di = perpendicular(p[i], p[a], p[b])
      if di > d: (far, d) = (i, di)
    if far >= 0:
      keep[far] = true
      stack.add [(a, far), (far, b)]
  for i, kept in keep:
    if kept: result.add p[i]

proc contains(p: seq[(float, float)], q: (float, float)): bool =
  var j = p.high
  for i in 0 .. p.high:
    if (p[i][1] > q[1]) != (p[j][1] > q[1]) and
       q[0] < (p[j][0] - p[i][0]) * (q[1] - p[i][1]) / (p[j][1] - p[i][1]) + p[i][0]:
      result = not result
    j = i

type Ring = object
  pts: seq[(float, float)]   # longitude, latitude
  main: bool                 # it holds a main island
var rings: seq[Ring]
var shx = memfiles.open(raw / "osm" / "land_polygons.shx")
var shp = memfiles.open(raw / "osm" / "land_polygons.shp")
for r in 0 ..< (shx.size - 100) div 8:
  let rec = at(shp.mem, be32(at(shx.mem, 100 + 8 * r)) * 2 + 8)
  let box = cast[ptr array[4, float64]](at(rec, 4))
  if box[2] < west or box[0] > east or box[3] < south or box[1] > north: continue
  let (nParts, nPts) = (i32(at(rec, 36)), i32(at(rec, 40)))
  let pts = at(rec, 44 + 4 * nParts)
  for q in 0 ..< nParts:
    let last = if q + 1 < nParts: i32(at(rec, 44 + 4 * (q + 1))) else: nPts
    var ring: seq[(float, float)]
    var inside = false
    for i in i32(at(rec, 44 + 4 * q)) ..< last:
      let c = cast[ptr array[2, float64]](at(pts, 16 * i))
      inside = inside or (c[0] in west .. east and c[1] in south .. north)
      let p = (clamp(c[0], west, east), clamp(c[1], south, north))
      if ring.len == 0 or p != ring[^1]: ring.add p
    if not inside or ring.len < 4: continue
    ring = douglasPeucker(ring, 0.01)
    if ring.len < 4: continue
    rings.add Ring(pts: ring, main: islands.anyIt(it.main and ring.contains((it.lon, it.lat))))
shx.close; shp.close

# ------------------------------------------------------------------------------ the names
# Where the names go, written by Claude: a sea's name by the longitude and latitude of its
# middle, on one or two lines; a main island's from its point, moved by so many points of the
# drawing (1000 wide) and running from there to the right (start), both ways (middle) or to
# the left (end).
# The Italian names of the seas are Claude's too, as in italiano.txt.
const seas = [("Alboran Sea", "Mare di Alborán", -2.8, 36.1), ("Balearic|Sea", "Mare delle|Baleari", 5.2, 41.25),
              ("Sea of|Sardinia", "Mare di|Sardegna", 6.5, 38.6), ("Ligurian Sea", "Mar Ligure", 8.3, 43.65),
              ("Tyrrhenian|Sea", "Mar|Tirreno", 12.4, 39.9), ("Adriatic|Sea", "Mare|Adriatico", 17.15, 42.15),
              ("Strait of|Sicily", "Canale di|Sicilia", 12.2, 36.3), ("the Mediterranean", "Mediterraneo", 6.0, 37.3),
              ("Ionian Sea", "Mar Ionio", 19.2, 36.6), ("Aegean Sea", "Mar Egeo", 25.0, 35.95),
              ("Libyan Sea", "Mar Libico", 24.0, 33.9), ("Levantine Sea", "Mar di Levante", 30.6, 33.6),
              ("Sea of Marmara", "Mar di Marmara", 28.4, 40.82)]
const names = [("Sicily", 0.0, 0.0, "middle"), ("Sardinia", 0.0, 0.0, "middle"),
               ("Corsica", 0.0, 0.0, "middle"), ("Cyprus", 0.0, 0.0, "middle"),
               ("Crete", 0.0, 0.0, "middle"), ("Mallorca", 0.0, -30.0, "middle"),
               ("Menorca", 16.0, 0.0, "start"), ("Ibiza", -14.0, 6.0, "end"),
               ("Malta", 0.0, 30.0, "middle"), ("Djerba", -14.0, 4.0, "end"),
               ("Corfu", -14.0, 0.0, "end"), ("Cephalonia", -14.0, 0.0, "end"),
               ("Zakynthos", -14.0, 12.0, "end"), ("Cres", -14.0, 14.0, "end"),
               ("Krk", 14.0, -6.0, "start"), ("Euboea", -14.0, -20.0, "end"),
               ("Lemnos", 0.0, -24.0, "middle"), ("Lesbos", 16.0, 0.0, "start"),
               ("Chios", 16.0, 4.0, "start"), ("Samos", 16.0, 12.0, "start"),
               ("Naxos", 0.0, 32.0, "middle"), ("Rhodes", 16.0, 10.0, "start")]

# ------------------------------------------------------------------------------ the drawings
# Equirectangular, east-west shrunk by the cosine of the map's middle latitude, 1000 wide.
proc draw(file: string, w, e, s, n: float, italian = false) =
  let c = cos(((s + n) / 2).degToRad)
  let k = 1000 / ((e - w) * c)
  let height = round((n - s) * k).int
  proc xy(p: (float, float)): (float, float) = ((p[0] - w) * c * k, (n - p[1]) * k)
  proc f(v: float): string = formatFloat(v, ffDecimal, 1)
  proc path(ring: seq[(float, float)]): string =
    var last = (NaN, NaN)
    for p in ring:
      let q = xy(p)
      if abs(q[0] - last[0]) + abs(q[1] - last[1]) < 0.8: continue   # under a point of the drawing
      result.add (if result == "": "M" else: "L") & f(q[0]) & " " & f(q[1])
      last = q
    result.add "Z"
  var land, mainLand: string
  for r in rings:
    if r.pts.allIt(it[0] < w or it[0] > e or it[1] < s or it[1] > n): continue
    if r.main: mainLand.add r.pts.path else: land.add r.pts.path
  var svg = &"""<svg xmlns="http://www.w3.org/2000/svg" class="map" viewBox="0 0 1000 {height}" width="1000" height="{height}" font-size="27">
<rect class="sea" width="100%" height="100%"/>
<path class="land" d="{land}"/>
<path class="main" d="{mainLand}"/>
"""
  let inside = proc (i: Island): bool = i.lon in w .. e and i.lat in s .. n
  for i in islands:
    if i.main or not inside(i): continue
    let (x, y) = xy((i.lon, i.lat))
    svg.add &"""<circle cx="{f x}" cy="{f y}" r="5" class="dot"/>""" & "\n"
  for (english, italiano, lon, lat) in seas:
    if lon notin w .. e or lat notin s .. n: continue
    let (x, y) = xy((lon, lat))
    let lines = (if italian: italiano else: english).split('|')
    let size = if english == "Sea of Marmara": 22 else: 27   # a small sea between islands
    for i, line in lines:
      let dy = (i.float - (lines.len - 1) / 2) * 32 + 9
      svg.add &"""<text x="{f x}" y="{f y + dy}" text-anchor="middle" font-size="{size}" class="sea-name">{line}</text>""" & "\n"
  for (name, dx, dy, anchor) in names:
    let i = islands.filterIt(it.name == name)[0]
    if not inside(i): continue
    let (x, y) = xy((i.lon, i.lat))
    svg.add &"""<text x="{f x + dx}" y="{f y + dy + 9}" text-anchor="{anchor}" class="name">{(if italian: i.italian else: i.name)}</text>""" & "\n"
  svg.add "</svg>\n"
  writeFile(output / file, svg)
  echo file, ": ", svg.len div 1024, " kB"

draw("map-west.svg", -6.0, 18.9, 32.6, 46.0)
draw("map-east.svg", 17.2, 36.3, 31.3, 41.5)
draw("map-west-it.svg", -6.0, 18.9, 32.6, 46.0, italian = true)
draw("map-east-it.svg", 17.2, 36.3, 31.3, 41.5, italian = true)
