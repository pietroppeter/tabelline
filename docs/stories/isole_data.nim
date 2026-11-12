## story: 0.2 | The islands' data, made with nanuq | 195 islands from a Wikipedia list, their outlines from OpenStreetMap, and what Wikidata and Wikipedia know about them, joined into tidy tables with nanuq, Polars for Nim. The three steps, the nanuq code, the checks the tables pass, and what nanuq did well.
## A story, kept up to date (first written on 11 November 2026): how the data of the islands
## story (docs/stories/data/isole/) was made, told in tables made with tabelline 0.2. It reads the
## committed CSVs with tabelline's readCsv and quotes the nanuq code of src/process.nim as text;
## the checks run on the data every time the page is built.
import std/[os, strutils, sequtils, tables, math, algorithm]
import nimib
import tabelline, tabelline/nimib
import ../blocks, ../theme

let docs = currentSourcePath().parentDir.parentDir
let isole = docs / "stories" / "data" / "isole"
let process = readFile(isole / "src" / "process.nim")
nbInit
nb.doc.filename = docs / "stories" / "isole-data" / "index.html"
nb.useTabelline(title = "The islands' data, made with nanuq", homeHref = "../", backLabel = "Stories", wordmarkHref = "../../",
  looks = ["munari", "minoan"], firstLook = "minoan")

proc story(name: string): TableData = readCsv(isole / name, comment = "#")

proc excerpt(start: string): string =
  ## The code of src/process.nim from the line that starts with `start` to the next blank line.
  let lines = process.splitLines
  var i = 0
  while not lines[i].startsWith(start): inc i
  var j = i
  while j < lines.len and lines[j].strip.len > 0: inc j
  "```nim\n" & lines[i ..< j].join("\n") & "\n```"

proc about(name: string): string =
  ## The `#` line of a CSV: what it is and where it comes from.
  readFile(isole / name).splitLines[0][2 .. ^1]

let islands = story("islands.csv")
let main = story("main.csv")

proc islandRow(title: Value): int =
  ## The row of islands.csv of an island's page.
  for i in 0 ..< islands.nrows:
    if islands["title", i] == title: return i

nbTitle "A story · tabelline 0.2", "The islands' data, made with nanuq", """
195 islands from a Wikipedia list, their outlines from OpenStreetMap, and what Wikidata and
Wikipedia know about them, joined into a few tidy tables with nanuq, Polars for Nim.
"""

nbNote("""
Green cards like this one are about how the page is made. The tables of the
[islands story](../isole/) are made from CSV files; this page tells how those files were made,
and its own tables are tabelline 0.2 too. It does not run nanuq: it reads the files nanuq wrote,
and quotes the nanuq code from `src/process.nim` as it is.
""", nkCode, "Reading the code")

nbToc()

nbText: """
## One island, four sources

No single source has everything about an island. Here is Sicily as each of the four sources
of this story sees it:
"""

nbShowCode:
  let i = toSeq(0 ..< islands.nrows).filterIt(islands["island", it] == "Sicily")[0]
  let m = toSeq(0 ..< main.nrows).filterIt(main["island", it] == "Sicily")[0]
  let rows = @[
    (source: "Wikipedia, the list", says: "area " & insertSep($main["km2", m].toFloat.int) & " km², population " & insertSep($islands["population", i].toFloat.int) & ", main town " & $islands["town", i]),
    (source: "Wikidata", says: "item " & $islands["wikidata", i] & ", at " & formatFloat(islands["lat", i].toFloat, ffDecimal, 2) & " N " & formatFloat(islands["lon", i].toFloat, ffDecimal, 2) & " E, up to " & insertSep($islands["elevation", i].toFloat.int) & " m"),
    (source: "OpenStreetMap", says: "an outline of " & $islands["points", i] & " points (simplified), " & insertSep($islands["outline_km2", i].toFloat.int) & " km², " & $islands["coast_km", i].toFloat.int & " km of coast"),
    (source: "Wikipedia, the rest", says: "Palermo's weather box, the region's GDP and unemployment")]
  let t = tabella(rows, rownameCol = "source"):
    optCssTheme()
    colsLabel:
      says: "what it says about Sicily"
    tabStyle style.text(size = "13px"), loc.body()
  nbTable t

nbText: """
They meet on names. The list names each island by a link to its page; Wikidata knows the page
(and not its redirects, so 24 links are followed first to the page they lead to); OpenStreetMap's
land polygons have no names, only polygons, and an island gets the polygon that holds its point on Wikidata.

## Three steps, one of them nanuq

The data goes from the web to the story's tables in three steps, as the FOSDEM data did:
"""

nbShowCode:
  let steps = @[
    (step: "1. fetch", tool: "Nim, standard library", does: "downloads the list and about 70 other Wikipedia pages, 6 Wikidata queries and OpenStreetMap's land polygons, about 900 MB (unzipped to 1.3 GB, not committed)"),
    (step: "2. extract", tool: "Nim, standard library", does: "finds each island's outline and what is on it, reads the weather boxes and the regions' tables"),
    (step: "3. process", tool: "Nim with nanuq", does: "joins, cleans and counts: the eight tables the story reads")]
  let t = tabella(steps, rownameCol = "step"):
    optCssTheme()
    colsLabel:
      step: ""
      does: "what it does"
  nbTable t

nbText: """
The first two steps only gather and place: what is downloaded is wikitext, CSV from Wikidata
and GeoJSON, and what needs geometry, an island's outline and which island a place is on, is
plain Nim. Everything that needs a decision (which count of passengers to keep, which airports
to add up, which heritage parts make one property) happens in the third step, in nanuq. The
downloads are not committed; the tables are. Here are the scripts, whole:
"""

for f in ["fetch.nim", "extract.nim", "process.nim", "common.nim"]:
  nbFoldCode isole / "src" / f, title = "`src/" & f & "`"

nbText: """
## Outlines

OpenStreetMap's land polygons (© OpenStreetMap contributors, under the
[ODbL](https://opendatacommons.org/licenses/odbl/)) follow the coast to a few metres, and are
rebuilt every day by [osmdata.openstreetmap.de](https://osmdata.openstreetmap.de/data/land-polygons.html)
as one shapefile of the world. `extract.nim` reads it with the standard library (`memfiles`, the
file's boxes first, so only the polygons around the Mediterranean are read) and finds about 25,000
of them. An island takes the one that holds its point on Wikidata, when its area is not far from
the list's; else the closest such polygon within 5 km (a point can fall in a bay, just off the
coast, or on an islet beside the island, as Ilovik's does). Then each outline is simplified to at
most 120 points and written in kilometres from its middle, so a shape keeps its proportions.
The outlines first came from Natural Earth at 1:10 million, which draws a small island with a
couple of dozen points and left 23 islands without one: compared side by side, OpenStreetMap
was much better for every island under about 50 km².
"""

nbShowCode:
  var counts = initOrderedTable[string, int]()
  for i in 0 ..< islands.nrows:
    let how = if islands["matched", i].isNull: "no outline" elif ($islands["matched", i]).startsWith("closest"): "the closest, within 5 km" else: "the polygon holds its point"
    counts.mgetOrPut(how, 0).inc
  var rows: seq[tuple[outline: string, islands: int, share: float]]
  for k, v in counts: rows.add (k, v, v / islands.nrows)
  let t = tabella(rows, rownameCol = "outline"):
    optCssTheme()
    colsAdd "bar", rows.mapIt(toValue(it.islands))
    fmtNanoplot "bar", plotType = "bar", plotHeight = "1.1em",
      options = nanoplotOptions(dataBarFillColor = tint("--secondary"), dataBarStrokeColor = tint("--secondary"))
    fmtPercent "share", decimals = 0
    colsLabel:
      outline: ""
      bar: ""
    grandSummaryRows:
      all: agg.sum
      columns = ["islands", "share"]
      missingText = ""
  nbTable t

nbText: """
A check that the right polygon was found: its area against the area in the list. For the 22
main islands they agree within a few percent; the polygon is a drawing at one scale, so it
misses bays and rocks, and the list's areas are rounded or come from other surveys.
"""

nbShowCode:
  var d = TableData()
  d.addColumn("island", toSeq(0 ..< main.nrows).mapIt(main["island", it]))
  d.addColumn("list", toSeq(0 ..< main.nrows).mapIt(main["km2", it]))
  var outlines, ratio: seq[Value]
  for k in 0 ..< main.nrows:
    let i = islandRow(main["title", k])
    outlines.add islands["outline_km2", i]
    ratio.add toValue(islands["outline_km2", i].toFloat / main["km2", k].toFloat - 1)
  d.addColumn("outline", outlines)
  d.addColumn("difference", ratio)
  let t = tabella(d, rownameCol = "island"):
    optCssTheme()
    fmtInteger ["list", "outline"]
    fmtPercent "difference", decimals = 1
    dataColor "difference", palette = palette("rdbu"), domain = (-0.1, 0.1)
    tabSpanner "area, {{km^2}}", ["list", "outline"]
    rowOrder "difference"
  nbTable t

nbNote("""
`dataColor` colours the difference on a blue–white–red scale fixed at ±10%, so a pale cell
is a good match: blue where the outline is smaller than the list says, red where it is larger. The spanner's label has gt's
units syntax, `{{km^2}}`.
""", nkCode)

nbText: """
## Counting passengers

Wikidata has 15,637 counts of passengers for the airports around the Mediterranean: by year, by
month, and sometimes the same year twice, from different sources. Of the islands' 64 airports,
3,679 counts; 1,409 of them are for a whole year. A year counts once, with its largest count,
since a smaller one is usually part of the year:
""" & excerpt("let yearly = ") & """

An island's passengers are the sum of its airports. Airfields and air bases are counted for a
few years only, and would leave holes in every line, so an island that has an airport with a
million passengers in some year leaves out those that never had one; and a year counts only
when every airport left has a count. One expression of nanuq, with a window (`over`), says
which airports stay:
""" & excerpt("let active = ") & """

## Long to wide

The weather boxes give one number per island, measure and month: 1,506 rows. The story wants a
row per island and measure, and a column per month, for a heat table and a nanoplot. That is a
`pivot`, as in Polars:
""" & excerpt("rd(stage / \"climate.csv\")") & """

The same turns twenty years of unemployment into twenty columns, with one more row: the median
of all the regions of the list, a group by year.
"""

nbText: """
## The tables

Eight files, in `docs/stories/data/isole/`, each with a first line that says what it is made
from; and three written by hand.
"""

nbShowCode:
  var files: seq[tuple[file: string, rows: int, columns: int, about: string]]
  for f in ["islands.csv", "main.csv", "heritage.csv", "airports.csv", "passengers.csv",
            "climate.csv", "stations.csv", "unemployment.csv", "regions.csv", "history.csv", "highlights.csv"]:
    let d = story(f)
    files.add (f, d.nrows, d.ncols, about(f).split(": ")[0].split(". ")[0].split(" (")[0].split(", with")[0].split(", one")[0])
  let t = tabella(files, rownameCol = "file"):
    optCssTheme()
    fmtInteger ["rows", "columns"]
    colsLabel:
      file: ""
      about: ""
    tabStyle style.text(size = "12px") & style.css("overflow-wrap: anywhere"), loc.body(cols("about"))
    tabRowGroup "made by process.nim", toSeq(0 .. 7)
    tabRowGroup "written by hand", [8, 9, 10]
    rowGroupOrder ["made by process.nim", "written by hand"]
  nbTable t

nbText: """
The largest is `islands.csv`, a row per island of the list, with its outline as two columns of
numbers. A preview of its first and last rows, every column formatted by what is in it:
"""

nbShowCode:
  let t = tabellaPreview(islands, topN = 3, bottomN = 2):
    optCssTheme()
    colsHide ["rank", "title", "x", "y", "wikidata", "native", "matched", "town", "archipelago", "main",
              "lat", "lon", "elevation", "coast_km", "points", "heritage", "airports"]
    fmtAuto(lgNumPref = "suf")
    subMissing everything(), missingText = ""
    tabOptions(tableFontSize = "12px")
  nbTable t

nbNote("""
`fmtAuto` picks a format for each column from its values: integers with separators, decimals as
many as needed. `tabellaPreview` shows the first and last rows of a big table, with the place
of each and a line for the rest; seventeen of the 22 columns are hidden to fit a phone.
""", nkCode)

nbText: """
## Checked

Every time this page is built, it checks the tables against each other. A check that fails
shows a cross:
"""

nbShowCode:
  let pax = story("passengers.csv")
  let clim = story("climate.csv")
  let sites = story("heritage.csv")
  proc has(d: TableData, col, v: string): bool = toSeq(0 ..< d.nrows).anyIt($d[col, it] == v)
  let mains = toSeq(0 ..< main.nrows).mapIt($main["title", it])
  let worst = toSeq(0 ..< main.nrows).mapIt(abs(islands["outline_km2", islandRow(main["title", it])].toFloat / main["km2", it].toFloat - 1)).max
  var siteSum = 0
  for i in 0 ..< islands.nrows: siteSum += islands["heritage", i].toFloat.int
  let checks = @[
    ("the list has 195 islands, in order of area", islands.nrows == 195 and toSeq(1 ..< islands.nrows).allIt(islands["km2", it].toFloat <= islands["km2", it - 1].toFloat)),
    ("every main island has an outline", toSeq(0 ..< main.nrows).allIt(not islands["x", islandRow(main["title", it])].isNull)),
    ("their outlines' areas are within 10% of the list's", worst < 0.10),
    ("every main island has twelve monthly highs", mains.allIt(clim.has("title", it))),
    ("every main island but Djerba has a region", toSeq(0 ..< main.nrows).allIt(main["region", it].isNull == (main["island", it] == "Djerba"))),
    ("the heritage table and the islands' counts agree", siteSum == sites.nrows),
    ("passengers are counted once per island and year", toSeq(1 ..< pax.nrows).allIt(pax["title", it] != pax["title", it - 1] or pax["year", it].toFloat > pax["year", it - 1].toFloat))]
  var d = TableData()
  d.addColumn("ok", checks.mapIt(toValue(if it[1]: "circle-check" else: "circle-xmark")))
  d.addColumn("check", checks.mapIt(toValue(it[0])))
  let t = tabella(d):
    optCssTheme()
    fmtIcon "ok", fillColor = tint("--success")
    tabStyle style.text(color = tint("--primary-text")), loc.body(rows = where(it.ok == "circle-xmark"))
    colsLabel:
      ok: ""
      check: ""
  nbTable t

nbText: """
## What nanuq did well, and where it pinched

This is nanuq's second dataset made end to end, after FOSDEM's, and a smaller one: about 150
lines of nanuq, which run in under a second.

**Well.** Joins on names read as in Polars, and a left join keeps every island when a source
has nothing for it. A window, `col.most.max.over(col.title)`, says in one line which airports
an island keeps. `pivot` turned the long weather and unemployment tables wide, with
`PivotAgg.First` and sorted columns. Reading every column as text (`inferSchemaLength =
some(0)`) and casting with `strict = false` gave each column the type decided here, not
guessed from its first rows.

**Pinched.** `pivot` on a lazy frame needs the new columns listed beforehand, so the climate goes
through `collect` first. `sort` with several keys takes `nullsLast` as a list, even when one value is
meant for all of them. And `writeCsv` writes no comment line, so `save` adds it afterwards, as in FOSDEM's
`process.nim`.
"""

nbSave
