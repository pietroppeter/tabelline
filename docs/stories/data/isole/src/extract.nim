## Step 1 of the islands' data: flattens the raw downloads of fetch.nim into staging CSVs, which
## process.nim (nanuq) cleans, joins and counts.
##
##   nim r -d:release extract.nim <raw dir> <stage dir>
##
## What needs geometry is done here, with the standard library: each island's outline from
## OpenStreetMap (the land polygon that holds its point on Wikidata), simplified to at most 120
## points, in kilometres; which island each World Heritage Site and each airport is on; and
## what needs reading wikitext: the weather boxes, the regions' unemployment and GDP.
import std/[json, math, algorithm, sequtils, tables, sets, parsecsv, streams, memfiles]
import common

let raw = paramStr(1)
let stage = paramStr(2)
createDir(stage)

proc wikiText(title: string): string =
  ## A page fetch.nim saved, following its redirects ("" when there is none).
  let path = raw / "wiki" / title.replace(' ', '_').replace('/', '_') & ".wiki"
  if not fileExists(path): return ""
  result = readFile(path)
  var target: array[1, string]
  if result.startsWith("#REDIRECT") and result.find(re"\[\[([^\]|#]+)", target) >= 0:
    result = wikiText(target[0].strip)

proc readRows(path: string): seq[Table[string, string]] =
  ## A CSV (Wikidata's) as rows of strings.
  var p: CsvParser
  p.open(newStringStream(readFile(path)), path)
  p.readHeaderRow()
  while p.readRow():
    var r: Table[string, string]
    for c in p.headers: r[c] = p.rowEntry(c)
    result.add r

proc point(wkt: string): (float, float) =
  ## "Point(14.01 37.6)" as (longitude, latitude).
  let xy = wkt.multiReplace(("Point(", ""), (")", "")).splitWhitespace
  (xy[0].parseFloat, xy[1].parseFloat)

func qid(uri: string): string = uri.rsplit('/', 1)[^1]

# ------------------------------------------------------------------------- the islands

let rows = listRows(wikiText("List of islands in the Mediterranean"))
var page: Table[string, string]   # the list's title -> the page Wikidata knows
for r in readRows(raw / "redirects.csv"): page[r["title"]] = r["page"]
for r in rows:
  if r.title notin page: page[r.title] = r.title

type Island = object
  row: ListRow
  item, archipelago, italian: string
  native: seq[string]
  lon, lat, elevation: float
var islands: seq[Island]
var byPage: Table[string, int]
for r in rows:
  byPage[page[r.title]] = islands.len
  islands.add Island(row: r, lon: NaN, lat: NaN, elevation: NaN)
for w in readRows(raw / "wd_islands.csv"):
  if w["title"] notin byPage: continue
  var isl = addr islands[byPage[w["title"]]]
  if isl.item.len == 0:   # the first of several coordinates
    isl.item = w["item"].qid
    (isl.lon, isl.lat) = point(w["coord"])
  if w["elevation"].len > 0 and isl.elevation.isNaN: isl.elevation = w["elevation"].parseFloat
  if w["archipelagoLabel"].len > 0 and isl.archipelago.len == 0: isl.archipelago = w["archipelagoLabel"]
  if w["native"].len > 0 and w["native"] notin isl.native: isl.native.add w["native"]

# ------------------------------------------------------------------------- the seas

# The sea each island is in. Wikidata says, for most (P206, "located in or next to body of
# water"), often a gulf or a strait: each is taken to the sea it is part of. Islands it puts only
# in "the Mediterranean", or nowhere, take the seas Wikipedia's article on them names, written
# below by Claude (seaOf), or else the sea of the closest island that has one, within 30 km. An
# island on more than one sea lists them all. The Îles d'Hyères and La Galite are left in the
# open Mediterranean, as their articles leave them.
const seas = ["Alboran Sea", "Balearic Sea", "Sea of Sardinia", "Ligurian Sea", "Tyrrhenian Sea",
              "Strait of Sicily", "Ionian Sea", "Adriatic Sea", "Aegean Sea", "Libyan Sea",
              "Levantine Sea", "Sea of Marmara"]
const partOf = {"Sea of Sicily": "Strait of Sicily", "Sea of Crete": "Aegean Sea",
                "Carpathian Sea": "Aegean Sea", "Icarian Sea": "Aegean Sea", "Thracian Sea": "Aegean Sea",
                "Myrtoan Sea": "Aegean Sea", "Lycian Sea": "Levantine Sea"}.toTable
const seaOf = {"Sicily": "Tyrrhenian Sea; Strait of Sicily; Ionian Sea",
               "Sardinia": "Tyrrhenian Sea; Sea of Sardinia", "Corsica": "Ligurian Sea; Tyrrhenian Sea",
               "Geography of Cyprus": "Levantine Sea", "Mallorca": "Balearic Sea", "Menorca": "Balearic Sea",
               "Ibiza": "Balearic Sea", "Formentera": "Balearic Sea", "Cabrera, Balearic Islands": "Balearic Sea",
               "Malta (island)": "Strait of Sicily", "Gozo": "Strait of Sicily", "Pantelleria": "Strait of Sicily",
               "Lampedusa": "Strait of Sicily", "Marettimo": "Strait of Sicily", "Levanzo": "Strait of Sicily",
               "Favignana": "Strait of Sicily", "Gavdos": "Libyan Sea", "Avsa": "Sea of Marmara",
               "La Maddalena (island)": "Tyrrhenian Sea", "Megalonisos Petalion": "Aegean Sea"}.toTable

proc major(name: string): string =
  if name in seas: name elif name in partOf: partOf[name] else: ""

var seaNames = newSeq[seq[string]](islands.len)
var seaHow = newSeq[string](islands.len)
# The Italian name: Wikidata's Italian label, without "isola di" in front (Isola Lunga is a
# name), else the English one. Cyprus's page is its geography's, labelled in Italian by Claude.
for w in readRows(raw / "wd_italian.csv"):
  if w["title"] notin byPage or w["italian"].len == 0: continue
  var name = w["italian"]
  for prefix in ["isola di ", "isola d'", "isola del ", "isola "]:
    if name.toLowerAscii.startsWith(prefix) and name != "Isola Lunga": name = name[prefix.len .. ^1]
  if name[0].isLowerAscii: name[0] = name[0].toUpperAscii
  islands[byPage[w["title"]]].italian = name
for isl in islands.mitems:
  if isl.row.title == "Geography of Cyprus": isl.italian = "Cipro"
  if isl.italian.len == 0: isl.italian = isl.row.label

for w in readRows(raw / "wd_waters.csv"):
  if w["title"] notin byPage: continue
  let i = byPage[w["title"]]
  var s = major(w["waterLabel"])
  if s.len == 0: s = major(w["parentLabel"])
  if s.len > 0 and s notin seaNames[i]:
    seaNames[i].add s
    seaHow[i] = "Wikidata"
for i, isl in islands:
  if seaNames[i].len == 0 and isl.row.title in seaOf:
    seaNames[i] = seaOf[isl.row.title].split("; ")
    seaHow[i] = "Wikipedia's article"
let known = toSeq(0 ..< islands.len).filterIt(seaHow[it] == "Wikidata")
for i, isl in islands:
  if seaNames[i].len > 0 or isl.lon.isNaN: continue
  var (best, d) = (-1, 30.0)
  for k in known:
    let dk = hypot((islands[k].lon - isl.lon) * 111.32 * cos(isl.lat.degToRad), (islands[k].lat - isl.lat) * 110.574)
    if dk < d: (best, d) = (k, dk)
  if best >= 0:
    seaNames[i] = seaNames[best]
    seaHow[i] = "as " & islands[best].row.title & ", " & formatFloat(d, ffDecimal, 0) & " km away"

# ------------------------------------------------------------------------- the outlines

type Ring = object
  pts: seq[(float, float)]        # longitude, latitude
  source: string                  # osm: one of OpenStreetMap's land polygons
  lo, hi: (float, float)          # the bounding box
  km2, coastKm: float
  island: int                     # the island it belongs to, -1 for none

const kmLat = 110.574
proc kmLon(lat: float): float = 111.320 * cos(lat.degToRad)

proc project(r: Ring): seq[(float, float)] =
  ## The ring in kilometres from the middle of its bounding box (x east, y north).
  let lon0 = (r.lo[0] + r.hi[0]) / 2
  let lat0 = (r.lo[1] + r.hi[1]) / 2
  r.pts.mapIt(((it[0] - lon0) * kmLon(lat0), (it[1] - lat0) * kmLat))

proc measure(r: var Ring) =
  r.lo = (r.pts.mapIt(it[0]).min, r.pts.mapIt(it[1]).min)
  r.hi = (r.pts.mapIt(it[0]).max, r.pts.mapIt(it[1]).max)
  let p = r.project
  var a, c = 0.0
  for i in 0 ..< p.len:
    let (x1, y1) = p[i]
    let (x2, y2) = p[(i + 1) mod p.len]
    a += x1 * y2 - x2 * y1
    c += hypot(x2 - x1, y2 - y1)
  r.km2 = abs(a) / 2
  r.coastKm = c

proc contains(r: Ring, lon, lat: float): bool =
  ## Whether the point is inside the ring (ray casting).
  if lon < r.lo[0] or lon > r.hi[0] or lat < r.lo[1] or lat > r.hi[1]: return false
  var j = r.pts.high
  for i in 0 .. r.pts.high:
    let (xi, yi) = r.pts[i]
    let (xj, yj) = r.pts[j]
    if (yi > lat) != (yj > lat) and lon < (xj - xi) * (lat - yi) / (yj - yi) + xi:
      result = not result
    j = i

proc distanceKm(r: Ring, lon, lat: float): float =
  ## The distance from the point to the closest vertex of the ring.
  result = Inf
  for (x, y) in r.pts:
    result = min(result, hypot((x - lon) * kmLon(lat), (y - lat) * kmLat))

# OpenStreetMap's land polygons are a shapefile: `.shx` holds where each record starts (big
# endian, in 16-bit words), and each record of `.shp` its box, its parts and its points (little
# endian doubles). A polygon is kept when its box is around the Mediterranean and not wider than
# 6 degrees (Sicily is 3.4); its outline is its largest ring (the others are holes).
proc be32(p: pointer): int =
  let b = cast[ptr array[4, uint8]](p)
  int((b[0].uint32 shl 24) or (b[1].uint32 shl 16) or (b[2].uint32 shl 8) or b[3].uint32)
template at(base: pointer, off: int): pointer = cast[pointer](cast[int](base) + off)
template i32(p: pointer): int = cast[ptr int32](p)[].int

var rings: seq[Ring]
var shx = memfiles.open(raw / "osm" / "land_polygons.shx")
var shp = memfiles.open(raw / "osm" / "land_polygons.shp")
for k in 0 ..< (shx.size - 100) div 8:
  let rec = at(shp.mem, be32(at(shx.mem, 100 + 8 * k)) * 2 + 8)
  let box = cast[ptr array[4, float64]](at(rec, 4))
  if box[2] < -6 or box[0] > 37 or box[3] < 30 or box[1] > 46.5 or box[2] - box[0] > 6: continue
  let (nParts, nPts) = (i32(at(rec, 36)), i32(at(rec, 40)))
  let pts = at(rec, 44 + 4 * nParts)
  var best = Ring(island: -1)
  for q in 0 ..< nParts:
    let last = if q + 1 < nParts: i32(at(rec, 44 + 4 * (q + 1))) else: nPts
    var r = Ring(source: "osm", island: -1)
    for i in i32(at(rec, 44 + 4 * q)) ..< last:
      let c = cast[ptr array[2, float64]](at(pts, 16 * i))
      r.pts.add (c[0], c[1])
    if r.pts.len > 1 and r.pts[0] == r.pts[^1]: r.pts.setLen(r.pts.len - 1)
    if r.pts.len < 3: continue
    r.measure
    if r.km2 > best.km2: best = r
  if best.pts.len > 0: rings.add best
shx.close; shp.close
echo rings.len, " outlines around the Mediterranean"

# Each island gets the ring that holds its point, if its area is not far from the list's; else
# the closest such ring within 5 km (a point on Wikidata can fall in a bay, the sea, or on an
# islet beside the island, as Ilovik's does).
var how = newSeq[string](islands.len)
for i, isl in islands:
  if isl.lon.isNaN: continue
  var best = -1
  for k, r in rings:
    if r.island < 0 and r.contains(isl.lon, isl.lat) and (best < 0 or r.km2 < rings[best].km2): best = k
  if best >= 0 and isl.row.km2 > 0 and rings[best].km2 / isl.row.km2 notin 0.33 .. 3.0: best = -1
  if best >= 0: how[i] = "inside"
  else:
    var d = 5.0
    for k, r in rings:
      if r.island >= 0: continue
      let ratio = r.km2 / max(isl.row.km2, 0.01)
      if isl.row.km2 > 0 and (ratio < 0.33 or ratio > 3): continue   # the list may have no area
      let dk = r.distanceKm(isl.lon, isl.lat)
      if dk < d: (d, best) = (dk, k)
    if best >= 0: how[i] = "closest, " & formatFloat(d, ffDecimal, 1) & " km"
  if best >= 0: rings[best].island = i

proc perpendicular(p, a, b: (float, float)): float =
  let (dx, dy) = (b[0] - a[0], b[1] - a[1])
  let l = hypot(dx, dy)
  if l == 0: hypot(p[0] - a[0], p[1] - a[1]) else: abs(dy * p[0] - dx * p[1] + b[0] * a[1] - b[1] * a[0]) / l

proc douglasPeucker(p: seq[(float, float)], tol: float): seq[(float, float)] =
  ## The points of an open line that keep its shape within `tol`.
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
  for i, k in keep:
    if k: result.add p[i]

proc simplify(ring: seq[(float, float)], most = 120): seq[(float, float)] =
  ## The closed ring with at most `most` points: split at its two farthest points, each half
  ## simplified with the smallest tolerance that is enough (found by halving).
  if ring.len <= most: return ring
  var far = 0
  for i, q in ring:
    if hypot(q[0] - ring[0][0], q[1] - ring[0][1]) > hypot(ring[far][0] - ring[0][0], ring[far][1] - ring[0][1]): far = i
  let a = ring[0 .. far]
  let b = ring[far .. ^1] & @[ring[0]]
  var (lo, hi) = (0.0, 1000.0)
  for _ in 0 ..< 40:
    let mid = (lo + hi) / 2
    if douglasPeucker(a, mid).len + douglasPeucker(b, mid).len - 2 > most: lo = mid else: hi = mid
  douglasPeucker(a, hi) & douglasPeucker(b, hi)[1 .. ^2]

proc nums(xs: seq[float], decimals: int): string = xs.mapIt(formatFloat(it, ffDecimal, decimals)).join(" ")

var islandRows, shapeRows: seq[seq[string]]
for k, r in rings:
  if r.island < 0: continue
  let s = simplify(r.project)
  let d = if r.km2 < 50: 2 else: 1
  shapeRows.add @[islands[r.island].row.title, r.source, how[r.island], formatFloat(r.km2, ffDecimal, 1),
                  formatFloat(r.coastKm, ffDecimal, 1), $r.pts.len, $s.len,
                  formatFloat(r.hi[0] - r.lo[0], ffDecimal, 3), formatFloat(r.hi[1] - r.lo[1], ffDecimal, 3),
                  s.mapIt(it[0]).nums(d), s.mapIt(it[1]).nums(d)]
shapeRows.sort(proc (a, b: seq[string]): int = cmp(a[0], b[0]))
writeCsv(stage / "shapes.csv", "Island outlines: OpenStreetMap's land polygons (© OpenStreetMap contributors, ODbL), the ring holding each island's point on Wikidata, simplified to at most 120 points, in km from the middle of the ring's box (x east, y north).",
  ["title", "source", "matched", "outline_km2", "coast_km", "points_full", "points", "width_deg", "height_deg", "x", "y"], shapeRows)

for i, isl in islands:
  islandRows.add @[$(i + 1), isl.row.title, isl.row.label, page[isl.row.title], isl.item,
                   (if isl.lon.isNaN: "" else: $isl.lon), (if isl.lat.isNaN: "" else: $isl.lat),
                   (if isl.elevation.isNaN: "" else: $isl.elevation), isl.archipelago,
                   isl.native.join(" / "), isl.italian, $isl.row.km2, isl.row.town, $isl.row.isMain,
                   seaNames[i].join("; "), seaHow[i]]
writeCsv(stage / "islands.csv", "The islands of Wikipedia's List of islands in the Mediterranean (table By area, in its order), with their Wikidata item, coordinates, highest point, archipelago, native name, Italian name and sea (Wikidata P206, or the closest island's, or Wikipedia's article).",
  ["rank", "title", "label", "page", "wikidata", "lon", "lat", "elevation", "archipelago", "native", "italian", "list_km2", "town", "main", "sea", "sea_how"], islandRows)

# ------------------------------------------------------------------------- what is on them

proc islandAt(lon, lat: float, near = 0.0): string =
  ## The island whose outline holds the point; or, within `near` km, the closest island of
  ## 100 km² or more (a coastline can leave a pier or a runway out); or "". (Natural Earth needed
  ## 2 km here; OpenStreetMap's coastline needs much less.)
  for r in rings:
    if r.island >= 0 and r.contains(lon, lat): return islands[r.island].row.title
  var d = near
  for r in rings:
    if r.island >= 0 and r.km2 >= 100 and r.distanceKm(lon, lat) < d:
      d = r.distanceKm(lon, lat)
      result = islands[r.island].row.title

var siteRows, propertyRows: seq[seq[string]]
var seen = initHashSet[string]()
for s in readRows(raw / "wd_heritage.csv"):
  if '-' notin s["whsId"] and s["listed"].len > 0 and s["whsId"] notin seen:
    seen.incl s["whsId"]
    propertyRows.add @[s["whsId"], s["siteLabel"], s["listed"].split('-')[0]]
  let (lon, lat) = point(s["coord"])
  let isl = islandAt(lon, lat, near = 0.5)   # a site on the shore can sit just past the coastline
  let key = s["site"] & isl
  if isl.len == 0 or key in seen: continue
  seen.incl key
  siteRows.add @[isl, s["site"].qid, s["siteLabel"], s["whsId"], s["listed"].split('-')[0]]
writeCsv(stage / "heritage.csv", "World Heritage Sites (and their parts) on the islands: Wikidata (P757, coordinates P625, listed P580), placed on an island by its outline.",
  ["title", "wikidata", "site", "whs_id", "listed"], siteRows)
writeCsv(stage / "heritage_properties.csv", "World Heritage properties around the Mediterranean (the Wikidata items whose P757 has no part number), their name and the year they were listed.",
  ["whs_id", "name", "listed"], propertyRows)

var airportRows: seq[seq[string]]
var onIsland = initHashSet[string]()
for a in readRows(raw / "wd_airports.csv"):
  let (lon, lat) = point(a["coord"])
  let isl = islandAt(lon, lat, near = 0.5)   # a runway can run just past the coastline
  if isl.len == 0 or a["iata"] in onIsland: continue
  onIsland.incl a["iata"]
  airportRows.add @[isl, a["iata"], a["airportLabel"], a["airport"].qid]
writeCsv(stage / "airports.csv", "Airports with an IATA code on the islands: Wikidata (P238, P625), placed on an island by its outline.",
  ["title", "iata", "airport", "wikidata"], airportRows)

var paxRows: seq[seq[string]]
for p in readRows(raw / "wd_passengers.csv"):
  if p["iata"] in onIsland:
    paxRows.add @[p["iata"], p["passengers"], p["date"][0 ..< 10], p["precision"]]
writeCsv(stage / "passengers.csv", "Passengers of the islands' airports, every count on Wikidata (P3872 with its date P585 and the date's precision: 9 a year, 10 a month).",
  ["iata", "passengers", "date", "precision"], paxRows)

var popRows: seq[seq[string]]
for p in readRows(raw / "wd_population.csv"):
  for r in rows:
    if page[r.title] == p["title"]:
      popRows.add @[r.title, p["population"], (if p["date"].len >= 10: p["date"][0 ..< 10] else: ""), p["precision"]]
writeCsv(stage / "population.csv", "The islands' population, every count on Wikidata (P1082, with its date P585 and precision).",
  ["title", "population", "date", "precision"], popRows)

# ------------------------------------------------------------------------- the climate

const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const measures = [("high C", "high_c"), ("mean C", "mean_c"), ("low C", "low_c"),
                  ("precipitation mm", "rain_mm"), ("rain mm", "rain_mm"), ("sun", "sun_hours"),
                  ("precipitation days", "rain_days"), ("rain days", "rain_days")]

proc weatherBox(text: string): string =
  ## The first weather box of a page ("" when it has none).
  let a = text.toLowerAscii.find("{{weather box")
  if a < 0: return ""
  var depth = 0
  var i = a
  while i < text.len - 1:
    if text[i] == '{' and text[i + 1] == '{': (inc depth; inc i)
    elif text[i] == '}' and text[i + 1] == '}':
      dec depth; inc i
      if depth == 0: return text[a .. i]
    inc i
  text[a .. ^1]

proc seaTemperatures(text: string): seq[string] =
  ## The twelve months of a table row "Average sea temperature", when the page has one.
  let a = text.find(re"(?i)!\s*Average sea temperature")
  if a < 0: return
  for line in text[a .. ^1].splitLines[1 .. ^1]:
    if line.startsWith("|-") or line.startsWith("!") or line.startsWith("|}"): break
    let cell = line.split('|')[^1]
    let n = number(cell)
    if n.len > 0: result.add n
  result = if result.len < 12: @[] else: result[0 ..< 12]   # a 13th cell is the year's

var climateRows, stationRows: seq[seq[string]]
for r in rows:
  if not r.isMain: continue
  var pages = @[r.town, r.title]
  for (isl, other) in climateAlso:
    if page[r.title] == isl: pages.add other
  var found = false
  var sea: seq[string]
  var seaPage = ""
  for p in pages:
    let text = wikiText(p)
    if sea.len == 0:
      sea = seaTemperatures(text)
      if sea.len > 0: seaPage = p
    let box = weatherBox(text)
    if box.len == 0 or found: continue
    found = true
    var fields: Table[string, string]
    for line in box.replace(re"\n[ \t]+\|", "\n|").split("\n|"):   # some boxes indent their fields
      let kv = line.split('=', 1)
      if kv.len == 2: fields[kv[0].strip.toLowerAscii] = kv[1].strip
    stationRows.add @[r.title, p, plain(fields.getOrDefault("location"))]
    for (key, name) in measures:
      for m, mon in months:
        var v = number(fields.getOrDefault((mon & " " & key).toLowerAscii))
        if v.len == 0:   # a box in Fahrenheit and inches (Ermoupoli, Lefkada): to °C and mm
          if key.endsWith(" C"):
            let f = number(fields.getOrDefault((mon & " " & key[0 .. ^2] & "F").toLowerAscii))
            if f.len > 0: v = formatFloat((f.parseFloat - 32) * 5 / 9, ffDecimal, 1)
          elif key.endsWith(" mm"):
            let inch = number(fields.getOrDefault((mon & " " & key[0 .. ^3] & "inch").toLowerAscii))
            if inch.len > 0: v = formatFloat(inch.parseFloat * 25.4, ffDecimal, 0)
        if v.len > 0: climateRows.add @[r.title, name, $(m + 1), v]
  if sea.len > 0:
    for m, v in sea: climateRows.add @[r.title, "sea_c", $(m + 1), v]
    stationRows.add @[r.title, seaPage, "sea temperature"]
writeCsv(stage / "climate.csv", "Monthly normals of the main islands: the first weather box of the island's main town, of the island, or of the closest page with one (Wikipedia), and a row Average sea temperature where a page has one.",
  ["title", "measure", "month", "value"], climateRows)
writeCsv(stage / "stations.csv", "Where each island's climate comes from: the Wikipedia page and the weather box's location.",
  ["title", "page", "location"], stationRows)

# ------------------------------------------------------------------------- the regions

proc cells(line: string): seq[string] = line.split("||").mapIt(it.strip)

proc regionName(cell: string): string =
  ## A region's name in a cell: the label of its link or of its flag.
  var m: array[1, string]
  if cell.find(re"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", m) >= 0: return m[0].strip
  if cell.find(re"\{\{flag\|([^}|]+)", m) >= 0: return m[0].strip
  plain(cell)

var gdpRows: seq[seq[string]]
let gdp = wikiText("List of European Union regions by GDP")
let gdp2024 = gdp[gdp.find("== 2024 list ==") ..< gdp.find("==See also")]
var country = ""
for line in gdp2024.splitLines:
  if not line.startsWith("|") or line.startsWith("|-") or line.startsWith("|}") or line.startsWith("|+"): continue
  let c = line[1 .. ^1].cells
  if c.len < 6: continue
  if c.len >= 7: country = regionName(c[1].replace(re"rowspan=""?\d+""?\s*\|", ""))
  let n = c[^5 .. ^1].mapIt(number(it))
  let name = regionName(c[0])
  gdpRows.add @[(if name == "Toscana": "Tuscany" else: name), country] & n   # the other list's name
writeCsv(stage / "gdp.csv", "GDP of the EU's NUTS 2 regions in 2024: Wikipedia, List of European Union regions by GDP (Eurostat). Nominal million EUR, PPS million EUR, PPS per person, PPS per person as % of the EU, population in millions (2025).",
  ["region", "country", "gdp_meur", "pps_meur", "pps_per_person", "pps_index", "population_m"], gdpRows)

var jobRows: seq[seq[string]]
let jobs = wikiText("List of European regions by unemployment rate")
for (head, first) in [("== 2016 to 2025 list ==", 2016), ("== 2006 to 2015 list ==", 2006)]:
  let a = jobs.find(head)
  let part = jobs[a ..< jobs.find("|}", a)]
  for chunk in part.split("\n|-")[1 .. ^1]:
    let lines = chunk.splitLines.filterIt(it.startsWith("|"))
    if lines.len < 12: continue
    let region = regionName(lines[0])
    var cc: array[1, string]
    let code = if lines[1].find(re"\{\{([A-Z]{3})\}\}", cc) >= 0: cc[0] else: plain(lines[1][1 .. ^1])
    for k in 0 ..< 10:
      let v = number(lines[2 + k][1 .. ^1])
      if v.len > 0: jobRows.add @[region, code, $(first + k), v]
writeCsv(stage / "unemployment.csv", "Unemployment rate (%) of Europe's NUTS 2 regions, 2006-2025: Wikipedia, List of European regions by unemployment rate (Eurostat).",
  ["region", "country", "year", "rate"], jobRows)
