## A first taste of a `paesi` dataset: the countries with the most World Heritage Sites, with their
## population. Writes unesco.csv. Run: nim r -d:ssl unesco.nim
##
## - Sites: the bar chart of the countries with the most sites in Wikipedia's "World Heritage Site"
##   (read as wikitext, action=raw, which the REST API's rate limits don't block as often).
## - Population: Great Tables' `countrypops` (World Bank, via the great_tables package, MIT), year 2022,
##   its last year. Countries are joined on their ISO code, since the names differ
##   (Russia / Russian Federation, Turkey / Türkiye, Iran / Iran (Islamic Republic)).
import std/[httpclient, os, parsecsv, re, streams, strutils, tables]

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

const iso = {"Italy": "IT", "China": "CN", "France": "FR", "Germany": "DE", "Spain": "ES", "India": "IN",
             "Mexico": "MX", "United Kingdom": "GB", "Russia": "RU", "Iran": "IR", "Japan": "JP",
             "United States": "US", "Brazil": "BR", "Canada": "CA", "Turkey": "TR", "Australia": "AU",
             "Greece": "GR", "Poland": "PL", "Czech Republic": "CZ", "Portugal": "PT", "South Korea": "KR",
             "Belgium": "BE", "Sweden": "SE"}.toTable

let wiki = get("https://en.wikipedia.org/w/index.php?title=World_Heritage_Site&action=raw")
var asof: array[2, string]
discard wiki.find(re"\{\{As of\|(\d{4})\|(\w+)\}\}", asof)

var population: Table[string, string]
var csv: CsvParser
csv.open(newStringStream(get("https://raw.githubusercontent.com/posit-dev/great-tables/main/great_tables/data/01-countrypops.csv")), "countrypops")
csv.readHeaderRow()
while csv.readRow():
  if csv.rowEntry("year") == "2022" and csv.rowEntry("population").len > 0:
    population[csv.rowEntry("country_code_2")] = csv.rowEntry("population")

var lines = @["# World Heritage Sites: Wikipedia, World Heritage Site, as of " & asof[1] & " " & asof[0] &
              "; population: Great Tables' countrypops (World Bank), 2022. Written by unesco.nim on 8 Nov 2026",
              "country,code,sites,population"]
for m in wiki.findAll(re"""text:"[^"]*" \(\d+\)"""):
  var parts: array[2, string]
  discard m.find(re"""text:"([^"]*)" \((\d+)\)""", parts)
  let name = parts[0].replacef(re"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", "$1")
  lines.add [name, iso[name], parts[1], population[iso[name]]].csvLine
writeFile(currentSourcePath().parentDir / "unesco.csv", lines.join("\n") & "\n")
echo lines.len - 2, " countries"
