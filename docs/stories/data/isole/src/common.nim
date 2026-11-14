## What fetch.nim and extract.nim share: the list of islands as Wikipedia has it, which of them
## are the story's main islands, wikitext as plain text, and CSV lines. Standard library only.
import std/[re, strutils, os, json, algorithm, math]
export re, strutils, os

type ListRow* = object
  title*, label*, town*: string   ## the island's page, its name in the list, its main town's page
  km2*: float                     ## its area in the list (0 when the list has none)

proc listRows*(list: string): seq[ListRow] =
  ## The rows of the list's table "By area", in its order.
  let byArea = list[list.find("== By area ==") ..< list.find("==By population")]
  for chunk in byArea.split("\n|-")[1 .. ^1]:
    var links, labels: seq[string]
    for m in chunk.findAll(re"\[\[[^\]]+\]\]"):
      let parts = m[2 .. ^3].split('|')
      if parts[0].toLowerAscii.startsWith("file"): continue
      links.add parts[0].strip
      labels.add parts[^1].strip
    if links.len == 0: continue
    var area: array[1, string]
    let km2 = if chunk.find(re"\{\{convert\|([\d,.]+)\|km2", area) >= 0: area[0].replace(",", "").parseFloat
              else: 0.0
    result.add ListRow(title: links[0], label: labels[0], town: links[^1], km2: km2)

proc isMain*(r: ListRow): bool =
  ## The story's main islands: the 35 largest, down to Elba (224 km²), Pietro's pick, so the
  ## story reaches the Tuscan islands. Cyprus has no area in the list.
  r.km2 >= 224 or r.title == "Geography of Cyprus"

const climateAlso* = [("Krk", "Rijeka"), ("Cres", "Mali Lošinj"), ("Brač", "Split, Croatia"), ("Pag (island)", "Zadar"),
                      ("Korčula", "Dubrovnik"), ("Andros, Greece", "Ermoupoli"), ("Ikaria", "Samos")]
  ## Islands whose town and page have no weather box: the closest page with one (by the page
  ## Wikidata knows: Pag (island), Ikaria).

const ihoSeas* = ["Strait of Gibraltar", "Alboran Sea", "Balearic Sea", "Ligurian Sea", "Tyrrhenian Sea",
                  "Mediterranean Sea - Western Basin", "Adriatic Sea", "Ionian Sea", "Aegean Sea",
                  "Mediterranean Sea - Eastern Basin", "Sea of Marmara"]
  ## The seas of the IHO's Limits of Oceans and Seas (1953) in the Mediterranean, west to east.

proc wktRings*(wkt: string): seq[seq[(float, float)]] =
  ## The rings of a WKT polygon or multipolygon (outer rings and holes alike), as (lon, lat).
  for m in wkt.findAll(re"\([^()]+\)"):
    var ring: seq[(float, float)]
    for pair in m[1 .. ^2].split(','):
      let xy = pair.splitWhitespace
      if xy.len >= 2: ring.add (xy[0].parseFloat, xy[1].parseFloat)
    if ring.len >= 3: result.add ring

proc csvLine*(fields: openArray[string]): string =
  ## One CSV line: a field with a comma or a quote goes in quotes.
  var cells: seq[string]
  for x in fields:
    cells.add(if ',' in x or '"' in x or '\n' in x: '"' & x.replace("\"", "\"\"") & '"' else: x)
  cells.join(",")

proc writeCsv*(path, comment: string, header: openArray[string], rows: seq[seq[string]]) =
  ## A CSV whose first line is a `#` comment naming its sources.
  var lines = @["# " & comment, header.csvLine]
  for r in rows: lines.add r.csvLine
  writeFile(path, lines.join("\n") & "\n")
  echo path.extractFilename, ": ", rows.len, " rows"

proc plain*(s: string): string =
  ## The text of some wikitext: links as their label, no templates, tags, refs or bold.
  s.replace(re"<ref[^>]*/>", "").replace(re"(?s)<ref.*?</ref>", "")
   .replacef(re"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", "$1")
   .replace(re"\{\{[^{}]*\}\}", "").replace(re"\{\{.*", "").replace(re"\[https?://[^\]]*\]", "")
   .replace(re"<[^>]+>", " ").replace(re"\(\s*\)", "").replace(re"'''?", "")
   .replace("&nbsp;", " ").replace(re"\s+", " ").strip

proc number*(s: string): string =
  ## The first number in a piece of wikitext, without thousands commas; "" when there is none.
  var m: array[1, string]
  let t = s.replace(re"<[^>]+>.*", "").replace("−", "-").replace("&minus;", "-")
  if t.find(re"(-?[\d,]*\.?\d+)", m) >= 0: m[0].replace(",", "") else: ""

type IhoGrid* = object
  ## The IHO's seas painted on a grid of 0.02 degrees (about 2 km), from 6° W and 30° N: each
  ## cell holds the index of its sea in `ihoSeas`, or -1 (land, or outside every sea).
  cells*: seq[int8]
const ihoStep* = 0.02
const (ihoX0*, ihoY0*, ihoW*, ihoH*) = (-6.0, 30.0, 2150, 850)

proc ihoGrid*(raw: string): IhoGrid =
  ## The grid, from the seas' polygons fetch.nim downloads from Marine Regions (`raw/iho/`):
  ## each row of cells is filled between the crossings of its middle with the polygons' edges.
  result.cells = newSeq[int8](ihoW * ihoH)
  for c in result.cells.mitems: c = -1
  for s, sea in ihoSeas:
    let doc = parseFile(raw / "iho" / sea.replace(' ', '_') & ".jsonld")
    let seaRings = wktRings(doc["mr:hasGeometry"][0]["gsp:asWKT"].getStr)
    var cross = newSeq[seq[float]](ihoH)
    for ring in seaRings:
      for i in 0 ..< ring.len:
        let (x1, y1) = ring[i]
        let (x2, y2) = ring[(i + 1) mod ring.len]
        let lo = max(0, int(ceil((min(y1, y2) - ihoY0) / ihoStep - 0.5)))
        let hi = min(ihoH - 1, int(floor((max(y1, y2) - ihoY0) / ihoStep - 0.5)))
        for row in lo .. hi:
          let y = ihoY0 + (row.float + 0.5) * ihoStep
          if (y1 > y) != (y2 > y): cross[row].add x1 + (y - y1) * (x2 - x1) / (y2 - y1)
    for row in 0 ..< ihoH:
      cross[row].sort
      for k in countup(0, cross[row].len - 2, 2):
        let a = max(0, int(ceil((cross[row][k] - ihoX0) / ihoStep - 0.5)))
        let b = min(ihoW - 1, int(floor((cross[row][k + 1] - ihoX0) / ihoStep - 0.5)))
        for col in a .. b: result.cells[row * ihoW + col] = s.int8

proc sea*(g: IhoGrid, row, col: int): int =
  ## The sea of a cell (-1 for land, outside every sea, or outside the grid).
  if row in 0 ..< ihoH and col in 0 ..< ihoW: g.cells[row * ihoW + col].int else: -1
