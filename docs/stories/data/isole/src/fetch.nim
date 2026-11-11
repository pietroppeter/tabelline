## Downloads the raw sources of the islands story into a folder (nothing here is committed):
##
##   nim r -d:ssl fetch.nim <raw dir>
##
## Hosts: en.wikipedia.org (wikitext, `action=raw`), query.wikidata.org (SPARQL, CSV) and
## raw.githubusercontent.com (Natural Earth). A file already in the folder is not downloaded
## again, so a run that stops can be started again. Standard library only.
import std/[httpclient, uri, net, sequtils]
import common

let raw = if paramCount() >= 1: paramStr(1) else: "raw"
createDir(raw / "wiki")

proc client(): HttpClient =
  ## A client through the proxy in HTTPS_PROXY, when there is one.
  let proxy = getEnv("HTTPS_PROXY")
  newHttpClient(userAgent = "tabelline-docs/0.2 (islands story)", timeout = 120_000,
                proxy = if proxy.len > 0: newProxy(proxy) else: nil)

proc save(path, url: string, body = "", accept = "") =
  ## Writes `url` (POSTed with `body` when there is one) to `path`, unless it is already there.
  if fileExists(path): return
  let c = client()
  defer: c.close()
  if accept.len > 0: c.headers["Accept"] = accept
  var tries = 0
  while true:
    try:
      let r = if body.len > 0:
                c.headers["Content-Type"] = "application/x-www-form-urlencoded"
                c.request(url, HttpPost, body)
              else: c.request(url)
      if r.status.startsWith("404"):   # a red link: no page
        writeFile(path, ""); return
      if not r.status.startsWith("200"): raise newException(IOError, r.status & " " & url)
      writeFile(path, r.body)
      echo "  ", path.extractFilename, " ", r.body.len, " bytes"
      sleep 1500   # Wikipedia limits how fast a client reads
      return
    except IOError, OSError, HttpRequestError, TimeoutError:
      inc tries
      if tries >= 4: raise
      sleep 5000 * tries

proc wiki(title: string): string =
  ## The wikitext of a Wikipedia page, saved as wiki/<title>.wiki.
  let path = raw / "wiki" / title.replace(' ', '_').replace('/', '_') & ".wiki"
  save(path, "https://en.wikipedia.org/w/index.php?title=" & encodeUrl(title.replace(' ', '_')) & "&action=raw")
  readFile(path)

proc redirect(text: string): string =
  ## The page a redirect leads to, or "".
  var target: array[1, string]
  if text.startsWith("#REDIRECT") and text.find(re"\[\[([^\]|#]+)", target) >= 0: target[0].strip else: ""

proc page(title: string): string =
  ## The wikitext of a page, following its redirects.
  result = wiki(title)
  if redirect(result).len > 0: result = page(redirect(result))

proc sparql(name, query: string) =
  ## A Wikidata query, as CSV, saved as <name>.csv; its text is kept beside it, <name>.rq.
  writeFile(raw / name & ".rq", query)
  save(raw / name & ".csv", "https://query.wikidata.org/sparql", "query=" & encodeUrl(query), "text/csv")

# ------------------------------------------------------------------ 1. the list of islands

let rows = listRows(wiki("List of islands in the Mediterranean"))
let titles = rows.mapIt(it.title)
echo titles.len, " islands in the list, ", rows.countIt(it.isMain), " main ones"

# ------------------------------------------------------------------ 2. Wikidata

proc valuesOf(ts: openArray[string]): string =
  for t in ts: result.add "\"" & t.replace("\"", "\\\"") & "\"@en "

# Wikidata knows a page by its title, not by its redirects: first the titles it knows, then the
# others are followed on Wikipedia to the page they redirect to (redirects.csv).
sparql "wd_sitelinks", """
SELECT ?title ?item WHERE {
  VALUES ?title { $1 }
  ?article schema:about ?item; schema:isPartOf <https://en.wikipedia.org/>; schema:name ?title.
}""" % valuesOf(titles)
var known: seq[string]
for line in readFile(raw / "wd_sitelinks.csv").splitLines[1 .. ^1]:
  if line.len > 0: known.add line.rsplit(',', 1)[0].strip(chars = {'"'})
var pages: seq[string]
var redirects = @["title,page"]
for t in titles:
  if t in known: pages.add t; continue
  let to = redirect(wiki(t))
  let p = if to.len > 0: to else: t
  pages.add p
  redirects.add "\"" & t & "\",\"" & p & "\""
writeFile(raw / "redirects.csv", redirects.join("\n") & "\n")
let values = @[valuesOf(pages)]
let island = """
  VALUES ?title { $1 }
  ?article schema:about ?item; schema:isPartOf <https://en.wikipedia.org/>; schema:name ?title.""" % values.join(" ")

# Each island: its coordinates, highest point, archipelago and name in its own language.
sparql "wd_islands", """
SELECT ?title ?item ?coord ?elevation ?archipelagoLabel ?native WHERE {""" & island & """
  OPTIONAL { ?item wdt:P625 ?coord }
  OPTIONAL { ?item wdt:P2044 ?elevation }
  OPTIONAL { ?item wdt:P361 ?archipelago . ?archipelago wdt:P31/wdt:P279* wd:Q33837 }
  OPTIONAL { ?item wdt:P1705 ?native }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
}"""

# Each island's population, every time it was counted.
sparql "wd_population", """
SELECT ?title ?item ?population ?date ?precision WHERE {""" & island & """
  ?item p:P1082 ?st . ?st ps:P1082 ?population .
  OPTIONAL { ?st pqv:P585 ?t . ?t wikibase:timeValue ?date; wikibase:timePrecision ?precision }
}"""

# The World Heritage Sites around the Mediterranean, with their coordinates and year of listing.
sparql "wd_heritage", """
SELECT ?site ?siteLabel ?whsId ?coord ?listed WHERE {
  ?site wdt:P757 ?whsId; p:P625 ?cst . ?cst ps:P625 ?coord ; psv:P625 [ wikibase:geoLatitude ?lat; wikibase:geoLongitude ?lon ] .
  FILTER(?lat > 30 && ?lat < 46.5 && ?lon > -6 && ?lon < 37)
  OPTIONAL { ?site p:P1435 ?h . ?h ps:P1435 wd:Q9259 . ?h pq:P580 ?listed }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
}"""

# The airports around the Mediterranean that have an IATA code.
sparql "wd_airports", """
SELECT ?airport ?airportLabel ?iata ?coord WHERE {
  ?airport wdt:P238 ?iata; p:P625 ?cst . ?cst ps:P625 ?coord ; psv:P625 [ wikibase:geoLatitude ?lat; wikibase:geoLongitude ?lon ] .
  FILTER(?lat > 30 && ?lat < 46.5 && ?lon > -6 && ?lon < 37)
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
}"""

# Their passengers, every count Wikidata has (by year, by month, from several sources).
sparql "wd_passengers", """
SELECT ?iata ?passengers ?date ?precision WHERE {
  ?airport wdt:P238 ?iata; p:P625 ?cst . ?cst psv:P625 [ wikibase:geoLatitude ?lat; wikibase:geoLongitude ?lon ] .
  FILTER(?lat > 30 && ?lat < 46.5 && ?lon > -6 && ?lon < 37)
  ?airport p:P3872 ?st . ?st ps:P3872 ?passengers ; pqv:P585 ?t . ?t wikibase:timeValue ?date; wikibase:timePrecision ?precision .
}"""

# ------------------------------------------------------------------ 3. Wikipedia

# The regions' unemployment and GDP: Eurostat's figures, as Wikipedia lists them.
discard wiki("List of European regions by unemployment rate")
discard wiki("List of European Union regions by GDP")

# The climate of the main islands: the weather box of the island's main town, of the island, or
# of the closest page that has one (`climateAlso`).
for r in rows:
  if not r.isMain: continue
  discard page(r.title)
  if r.town != r.title: discard page(r.town)
for (isl, other) in climateAlso: discard page(other)

# ------------------------------------------------------------------ 4. Natural Earth

const ne = "https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/"
for f in ["ne_10m_land", "ne_10m_minor_islands"]:
  save(raw / f & ".geojson", ne & f & ".geojson")
echo "done"
