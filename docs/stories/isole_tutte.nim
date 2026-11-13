## All 195 islands of *Islands of the Mediterranean*, one table for each of the IHO's seas, from
## west to east: every island of the list with what the story knows of it. A page beside the
## story (isole.nim), in English and, through isole_tutte_it.nim, in Italian (its texts in
## data/isole/tutte-italiano.txt). Written to stories/isole-tutte/ and stories/isole-tutte-it/.
import std/[os, strutils, sequtils, tables, sets, math]
import nimib
import tabelline, tabelline/nimib
import ../blocks, ../theme

when not declared(lang):
  const lang = "en"   # isole_tutte_it.nim includes this file with "it"

let docs = currentSourcePath().parentDir.parentDir
let data = docs / "stories" / "data" / "isole"
const catalog = "tutte-italiano.txt"   # the Italian of every text of the page, in data/isole/
include isole_tr

nbInit
nb.doc.filename = docs / "stories" / (if lang == "it": "isole-tutte-it" else: "isole-tutte") / "index.html"
nb.useTabelline(title = tr"All 195 islands", homeHref = (if lang == "it": "../isole-it/index.html" else: "../isole/index.html"),
  backLabel = tr"Islands of the Mediterranean", wordmarkHref = "../../", looks = ["munari", "minoan"], firstLook = "minoan",
  lang = lang, languages = [("en", "../isole-tutte/index.html"), ("it", "../isole-tutte-it/index.html")], codeSwitch = true)

nbTitle tr"Islands of the Mediterranean", tr"All 195 islands",
  tr"Every island of Wikipedia's list, sea by sea from west to east: where it is, its outline, how big it is, how many live there and how high it goes."
nbToc

nbText: tr"""
This is the long list behind the story [Islands of the Mediterranean](../isole/index.html): its 195
islands, each in the sea around most of its coast, as the International Hydrographic Organization
drew the seas in 1953. It is one big table, made for a large screen: the seas from west to east,
each with its map and where its name comes from, and its islands from the largest down, each with
a small map of where it is in its sea and its outline at its own scale.
"""

nbNote(tr"""
The green cards are about the code, as in the story: the table is one `tabella`, made from
`islands.csv`.
""", nkCode)

# ------------------------------------------------------------------------------ the data
let islands = readCsv(data / "islands.csv", comment = "#")

proc outline(i: int): Value =
  ## Row `i`'s outline as a record of x and y (km), for a shape nanoplot.
  if islands["x", i].isNull: return toValue(nil)
  let nums = proc (v: Value): seq[float] = ($v).splitWhitespace.mapIt(it.parseFloat)
  toValue((x: nums(islands["x", i]), y: nums(islands["y", i])))

proc length(i: int): float =
  ## The island's length: the longest line between two points of its outline, in km.
  if islands["x", i].isNull: return NaN
  let nums = proc (v: Value): seq[float] = ($v).splitWhitespace.mapIt(it.parseFloat)
  let (xs, ys) = (nums(islands["x", i]), nums(islands["y", i]))
  for a in 0 ..< xs.len:
    for b in a + 1 ..< xs.len: result = max(result, hypot(xs[a] - xs[b], ys[a] - ys[b]))

proc name(i: int): string =
  ## The island's name in the page's language.
  if lang == "it" and ($islands["italian", i]).len > 0: $islands["italian", i] else: $islands["island", i]

proc text(v: Value): string = (if v.isNull: "" else: $v)

type Row = object
  rank: int
  sea, code, island, native, country, archipelago, map: string
  shape: Value
  km2, length, coast, people, density, highest: float
  heritage, airports: int

var rows: seq[Row]
for i in 0 ..< islands.nrows:
  let km2 = islands["km2", i].toFloat
  let people = if islands["population", i].isNull: NaN else: islands["population", i].toFloat
  let num = proc (c: string): float = (if islands[c, i].isNull: NaN else: islands[c, i].toFloat)
  rows.add Row(rank: ($islands["rank", i]).parseInt, sea: $islands["iho_sea", i], island: name(i),
               native: (let n = text(islands["native", i]); if n == name(i) or n == $islands["island", i]: "" else: n), code: $islands["code", i], country: $islands["code", i],
               archipelago: (let a = text(islands["archipelago", i]); if a.len > 0: tr(a) else: ""), map: $islands["rank", i], shape: outline(i),
               km2: km2, length: length(i), coast: num("coast_km"), people: people,
               density: (if people.isNaN: NaN else: people / km2), highest: num("elevation"),
               heritage: islands["heritage", i].toFloat.int, airports: islands["airports", i].toFloat.int)

let sea = nanoplotOptions(dataBarFillColor = tint("--secondary"), dataBarStrokeColor = tint("--secondary-text"))

# ------------------------------------------------------------------------------ the seas
const seas = [
  ("Balearic Sea", """The sea of the Balearic Islands, between them and Spain's coast; the IHO also calls it the Iberian Sea."""),
  ("Mediterranean Sea - Western Basin", """What the IHO leaves of the west once its seas are named: the open water from Spain and Africa to Corsica, Sardinia and the line from Sicily to Cape Bon. The Sea of Sardinia is in it, a name with no limits of its own."""),
  ("Tyrrhenian Sea", """The sea of the Tyrrhenians, the Greeks' name for the Etruscans."""),
  ("Adriatic Sea", """Named after Adria, an Etruscan town near the mouth of the Po; the Romans also called it the upper sea, *Mare Superum*."""),
  ("Ionian Sea", """Where the name comes from is not known; Aeschylus tied it to Io, who swam across it."""),
  ("Aegean Sea", """The ancients explained the name in several ways: Aegeus, the father of Theseus, who threw himself into it, an Amazon queen, a sea god, Poseidon."""),
  ("Mediterranean Sea - Eastern Basin", """The open sea of the east, from the line between Sicily and Cape Bon to the Levant. The Libyan Sea is in it, south of Crete, named after ancient Libya, North Africa west of the Nile; and the Levantine Sea, the sea where the sun rises."""),
  ("Sea of Marmara", """Named after its largest island, Marmara, rich in marble, *mármaron* in Greek.""")]

# ------------------------------------------------------------------------------ the table
proc smallDecimals(v: Value): string =
  ## Areas and people per km²: whole numbers, the small ones with a decimal or two.
  let x = v.toFloat
  let marks = localeMarks(lang)
  formatNumber(x, (if x < 1: 2 elif x < 10: 1 else: 0), sepMark = marks.sep, decMark = marks.dec)

nbWide:
  var t = tabella(rows, rownameCol = "rank", locale = lang):
    tabHeader tr"All 195 islands", tr"by the IHO's seas, from west to east"
    optCssTheme()
    colsHide ["sea"]
    colsMove ["map", "shape"], after = "archipelago"
    fmtFlag "code"
    fmtCountry "country"
    textTransform tr, loc.body(cols("country"))   # the country's name in the page's language
    fmtImage "map", path = data / "locators", filePattern = "{x}.svg", height = "2.5em", alt = ""
    fmtNanoplot "shape", plotType = "shape", plotHeight = "2.5em", options = sea
    fmt ["km2", "density"], smallDecimals
    fmtInteger ["length", "coast", "people", "highest", "heritage", "airports"]
    subMissing ["people", "density", "highest", "coast", "length"], missingText = "—"
    subZero ["people", "density", "heritage", "airports"], zeroText = "·"
    subZero ["highest"], zeroText = "—"   # Wikidata's 0 m for Antikythera is no height
    colsLabel:
      code: ""
      island: tr"island"
      native: tr"its own name"
      country: tr"country"
      archipelago: tr"archipelago"
      map: tr"where"
      shape: tr"outline"
      km2: tr"area, {{km^2}}"
      length: tr"length, km"
      coast: tr"coast, km"
      people: tr"people"
      density: tr"per {{km^2}}"
      highest: tr"highest, {{m}}"
      heritage: tr"World Heritage"
      airports: tr"airports"
    tabSpanner tr"the island", ["map", "shape", "km2", "length", "coast", "highest"]
    tabSpanner tr"who lives there", ["people", "density", "heritage", "airports"]
    tabFootnote tr"The longest straight line between two points of its coast: its diameter, in geometry, measured on the outline.", loc.columnLabels(cols("length"))
    tabFootnote tr"The length of the outline drawn from OpenStreetMap's coast, a little shorter than the true coast, which has every cove.", loc.columnLabels(cols("coast"))
    tabFootnote tr"The name in the island's own language, from Wikidata; · no one lives there, — a number nobody gave.", loc.columnLabels(cols("native"))
    tabOptions(footnotesMarks = fmStandard, rowGroupPadding = "10px")
  for (name, origin) in seas:
    let picks = toSeq(0 ..< rows.len).filterIt(rows[it].sea == name)
    let short = tr(name.replace("Mediterranean Sea - ", ""))
    t = t.tabRowGroup(besidePicture(data / "seas" / (name.replace(' ', '_') & ".svg"),
                                    "**" & short & "**, " & $picks.len & " " & tr"islands" & ". " & tr(origin),
                                    height = "4.5em", alt = short), picks, id = name)
  # each sea's total, once the seas are groups
  let sep = localeMarks(lang).sep
  t = t.summaryRows({"total": agg.sum}, fmt = proc (x: float): string = formatNumber(x, 0, sepMark = sep),
                    columns = ["km2", "people", "heritage", "airports"], missingText = "")
  t = t.textTransform(tr, loc.summaryStub())
  nbTable t

nbNote(tr"""
**Length.** An island's length here is the longest straight line between two points of its coast.
Geometry calls it the *diameter* of a shape, whatever the shape; the study of particles and
images calls it the *maximum Feret diameter*, or caliper diameter, the widest a caliper opens
around it as it turns; geography just says length, as in Wikipedia's box of an island. It is
measured on the simplified outline, so it can be a little short of the true one.
""", nkInfo)

nbNote(tr"""
One table, an island a row, grouped by sea with `tabRowGroup`, whose label can be any text: here
`besidePicture`, a block of these pages, puts the sea's map before its name. `fmtFlag` writes the
country's code as its flag, and `fmtCountry` the same code as the country's name. The map of each
island is a small picture of its sea, drawn by `map.nim`, shown with `fmtImage`, which reads the
file and puts it in the page; the outline is a shape nanoplot, as in the story. `summaryRows` adds
up each sea. The table sits in `nbWide`, wider than the text: it is made for a large screen.
""", nkCode)

nbText: tr"""
## Where it comes from

The list and its areas and populations: Wikipedia, [List of islands in the Mediterranean](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean).
The seas: the IHO's *Limits of Oceans and Seas* (1953), from [Marine Regions](https://www.marineregions.org/) (CC BY 4.0).
The outlines and the maps: © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors ([ODbL](https://opendatacommons.org/licenses/odbl/)).
The archipelagos, the highest points, World Heritage and the airports: [Wikidata](https://www.wikidata.org/).
The origins of the seas' names: their articles on Wikipedia. How the data is made is told in
[The islands' data, made with nanuq](../isole-data/index.html).
"""

when lang == "it":   # every text needs its Italian: the ones missing are listed for translation
  if missing.len > 0:
    writeFile(data / "tutte-italiano-missing.txt", missing.mapIt("en:\n" & it.strip & "\nit:\n").join("\n"))
  else: removeFile(data / "tutte-italiano-missing.txt")
  doAssert missing.len == 0, $missing.len & " texts have no Italian: see data/isole/tutte-italiano-missing.txt"

nbSave

when lang == "it":
  let unused = toSeq(italian.keys).filterIt(it notin used)
  doAssert unused.len == 0, $unused.len & " texts of tutte-italiano.txt are no longer on the page: " & $unused
