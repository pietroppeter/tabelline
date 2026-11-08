## The islands of the Mediterranean, the twin of gt's `islands`: writes isole.csv.
## Run: nim r -d:ssl isole.nim
##
## From Wikipedia's "List of islands in the Mediterranean", table "By area", read as wikitext
## (action=raw). Each row: name, country, area in km², population, main city. Cyprus's area is a
## template there, so it is written in here (9,251 km², Wikipedia's Cyprus).
import std/[httpclient, os, re, strutils]

const url = "https://en.wikipedia.org/w/index.php?title=List_of_islands_in_the_Mediterranean&action=raw"

proc csvLine(fields: openArray[string]): string =
  ## One CSV line: a field with a comma or a quote goes in quotes.
  var cells: seq[string]
  for x in fields:
    cells.add(if ',' in x or '"' in x: '"' & x.replace("\"", "\"\"") & '"' else: x)
  cells.join(",")

proc get(url: string): string =
  ## A page over HTTPS, through the proxy in HTTPS_PROXY when there is one.
  let proxy = getEnv("HTTPS_PROXY")
  let client = newHttpClient(userAgent = "tabelline-docs/0.1",
                             proxy = if proxy.len > 0: newProxy(proxy) else: nil)
  defer: client.close()
  client.getContent(url)

proc link(s: string): string =
  ## The text of a cell: links as their label, no line breaks, tags or bold.
  s.replacef(re"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", "$1").replace(re"<br\s*/?>.*", "")
   .replace(re"<[^>]+>|'''?", "").strip

proc number(s: string): string =
  ## The first number in a cell, without commas (templates left out).
  var m: array[1, string]
  if s.replace(re"\{\{[^}]*\}\}", "").find(re"([\d,]+(?:\.\d+)?)", m) >= 0: m[0].replace(",", "")
  else: ""

let text = get(url)
let table = text[text.find("== By area ==") ..< text.find("==By population")]
var lines = @["# Islands of the Mediterranean by area: Wikipedia, List of islands in the Mediterranean, read 8 Nov 2026 by isole.nim",
              "island,country,area,population,city"]
for chunk in table.split("\n|-")[1 .. ^1]:
  var cells: seq[string]
  for c in chunk.split(re"\n\||\|\|"):
    if c.strip.len > 0: cells.add c.strip
  if cells.len == 0 or cells[0].startsWith("!"): continue
  let name = link(cells[0])
  var country, area: array[1, string]
  discard chunk.find(re"\{\{flag\|([^}|]+)", country)
  if chunk.find(re"\{\{convert\|([\d,.]+)\|km2", area) >= 0: area[0] = area[0].replace(",", "")
  elif name == "Cyprus": area[0] = "9251"
  var rest: seq[string]
  for c in cells:
    if not (c.toLowerAscii.startsWith("[[file") or c.startsWith("{{flag") or c.startsWith("{{convert")): rest.add c
  let pop = if rest.len > 1: number(rest[1]) else: ""
  let city = if rest.len > 2: link(rest[2]) else: ""
  if name.len > 0 and area[0].len > 0 and not name.startsWith("class="):
    lines.add [name, country[0], area[0], pop, city].csvLine
writeFile(currentSourcePath().parentDir / "isole.csv", lines.join("\n") & "\n")
echo lines.len - 2, " islands"
