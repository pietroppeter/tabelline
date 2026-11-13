## What fetch.nim and extract.nim share: the list of islands as Wikipedia has it, which of them
## are the story's main islands, wikitext as plain text, and CSV lines. Standard library only.
import std/[re, strutils, os]
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
