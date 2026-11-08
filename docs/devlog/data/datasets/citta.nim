## The largest cities of the European Union, the twin of gt's `towny`: writes citta.csv.
## Run: nim r -d:ssl citta.nim
##
## From Wikipedia's "List of cities in the European Union by population within city limits", read
## as wikitext (action=raw): city, member state (Wikipedia's three-letter flag template), official
## population and the date it was counted (each country counts on its own day).
import std/[httpclient, os, re, strformat, strutils]

const url = "https://en.wikipedia.org/w/index.php?title=" &
  "List_of_cities_in_the_European_Union_by_population_within_city_limits&action=raw"
const months = ["January", "February", "March", "April", "May", "June", "July",
                "August", "September", "October", "November", "December"]

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

let text = get(url)
var lines = @["# EU cities by population within city limits: Wikipedia, read 8 Nov 2026 by citta.nim",
              "city,state,population,counted"]
for chunk in text.split("\n|-")[1 .. ^1]:
  var city, state, pop, day: array[3, string]
  if chunk.find(re"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", city) >= 0 and
     chunk.find(re"\{\{([A-Z]{3})\}\}", state) >= 0 and
     chunk.find(re"\{\{nts\|(\d+)\}\}", pop) >= 0:
    var counted = ""
    if chunk.find(re"\{\{dts\|format=dmy\|(\d{4})\|(\w+)\|(\d+)", day) >= 0:
      counted = &"{day[0]}-{months.find(day[1]) + 1:02}-{parseInt(day[2]):02}"
    lines.add [city[0], state[0], pop[0], counted].csvLine
writeFile(currentSourcePath().parentDir / "citta.csv", lines.join("\n") & "\n")
echo lines.len - 2, " cities"
