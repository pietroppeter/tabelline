## story: 0.2 | Islands of the Mediterranean | 195 islands, from Sicily down to islands of 5.5 km²: their shapes, who ruled them, how they live now and when to go. The data from Wikipedia, Wikidata and OpenStreetMap, gathered with nanuq; every table made with tabelline 0.2.
## A story, kept up to date (first written on 11 November 2026, with tabelline 0.2). It shows
## what 0.2 added that the FOSDEM story does not use, and the new shape nanoplot. The data is in
## docs/stories/data/isole/, made by its src/ (fetch.nim, extract.nim, process.nim with nanuq);
## how, in the story *The islands' data, made with nanuq* (isole_data.nim). This page reads the
## CSV files with tabelline's `readCsv` and shapes them with Nim's standard library.
import std/[os, strutils, strformat, sequtils, algorithm, tables, sets, math, json]
import nimib
import tabelline, tabelline/nimib
import ../blocks, ../theme

when not declared(lang):
  const lang = "en"   # the page's language: isole_it.nim includes this file with "it"

let docs = currentSourcePath().parentDir.parentDir
let data = docs / "stories" / "data" / "isole"

# ------------------------------------------------------------------------------ in two languages
# The story is written in English, and every text a reader sees goes through `tr`: in the English
# page it is the text itself, in the Italian one its translation, from data/isole/italiano.txt
# (an English text, `en:`, then its Italian, `it:`, or nothing for the same; spaces and line
# breaks do not count). A text
# without one is listed in data/isole/italiano-missing.txt, and the Italian page fails to build.
var italian: Table[string, string]
var missing: seq[string]
var used: HashSet[string]   # the texts looked up, so the ones no longer on the page can be found
proc key(s: string): string = s.splitWhitespace.join(" ")
when lang == "it":
  var (english, translated, side) = ("", "", "")
  proc flush() =
    if english.strip.len > 0:   # an empty translation keeps the English: a name, a number
      italian[key(english)] = if translated.strip.len == 0: english.strip else: translated.strip(chars = {'\n'})
    (english, translated) = ("", "")
  for line in lines(data / "italiano.txt"):
    if line.startsWith("en:"): (flush(); side = "en"; english = line[3 .. ^1].strip & "\n")
    elif line.startsWith("it:"): (side = "it"; translated = line[3 .. ^1].strip & "\n")
    elif side == "en": english.add line & "\n"
    elif side == "it": translated.add line & "\n"
  flush()

var readings: seq[Source]
  ## The books the story quotes, numbered in this order: a text cites one with `[^key]` where it
  ## first quotes it (`citing`), and "To read more" lists them (`nbSources`).

proc tr(s: string): string =
  ## `s` in the page's language, with its citations.
  when lang == "en": result = s
  else:
    if key(s) in italian: (used.incl key(s); result = italian[key(s)])
    else:
      if s notin missing: missing.add s
      result = s
  if "[^" in result: result = citing(result, readings)

nbInit
nb.doc.filename = docs / "stories" / (if lang == "it": "isole-it" else: "isole") / "index.html"
nb.useTabelline(title = tr"Islands of the Mediterranean", homeHref = "../", backLabel = tr"Stories", wordmarkHref = "../../",
  looks = ["munari", "minoan"], firstLook = "minoan",
  lang = lang, languages = [("en", "../isole/index.html"), ("it", "../isole-it/index.html")])

readings = @[
  source("braudel", tr"""Fernand Braudel, *The Mediterranean and the Mediterranean World in the Age of Philip II* (1949), and *La Méditerranée* (1977): the sea as a history of slow times. [Braudel on Wikipedia](https://en.wikipedia.org/wiki/Fernand_Braudel)."""),
  source("matvejevic", tr"""Predrag Matvejević, *Mediterranean: A Cultural Landscape* (1987, *Mediteranski brevijar*; in Italian *Breviario mediterraneo*): ports, lighthouses, winds and islands, a geography told as poetry. He also wrote an *Isolario Mediterraneo* (2000), after the old books of islands. [Matvejević on Wikipedia](https://en.wikipedia.org/wiki/Predrag_Matvejevi%C4%87)."""),
  source("mediterraneo", tr"""[*Mediterraneo*](https://thepassenger.iperborea.com/titoli/mediterraneo/), The Passenger (Iperborea, 2023): today's sea in essays and photographs, with essays by David Abulafia, author of [*The Great Sea*](https://en.wikipedia.org/wiki/The_Great_Sea:_A_Human_History_of_the_Mediterranean) (2011), Nick Hunt on the winds, Annalisa Camilli, Rachel Roddy and others; and its books on Sicily (2024) and Sardinia (2026)."""),
  source("ramondino", tr"""Fabrizia Ramondino, *Guerra di infanzia e di Spagna* (Einaudi, 2001): a childhood in Mallorca, where the islands have the shapes of fish and mermaids. [Ramondino on Wikipedia](https://it.wikipedia.org/wiki/Fabrizia_Ramondino)."""),
  source("sicilia", tr"""[*Sicilia*](https://thepassenger.iperborea.com/titoli/sicilia/), The Passenger (Iperborea, 2024): its introduction, on the island that looks like a world of its own on a map; and Giacomo Di Girolamo's "Tropico di Sicilia", on a climate turning tropical ([an excerpt in Il Post](https://www.ilpost.it/2024/04/17/sicilia-coltivazione-frutta-esotica/))."""),
  source("deleuze", tr"""Gilles Deleuze, *L'isola deserta e altri scritti* (Einaudi, 2007): his early essay on desert islands, where the island is what the sea surrounds. [Deleuze on Wikipedia](https://en.wikipedia.org/wiki/Gilles_Deleuze)."""),
  source("lawrence", tr"""D. H. Lawrence, [*Sea and Sardinia*](https://en.wikipedia.org/wiki/Sea_and_Sardinia) (1921): a week's journey from Sicily to Sardinia and back, in the winter of 1921."""),
  source("anedda", tr"""Antonella Anedda, *Isolatria. Viaggio nell'arcipelago della Maddalena* (Laterza, 2013): the islands off Sardinia where her family comes from. [Anedda on Wikipedia](https://it.wikipedia.org/wiki/Antonella_Anedda)."""),
  source("hunt", tr"""Nick Hunt, on the winds, in *Mediterraneo* (above): [an excerpt in Il Post](https://www.ilpost.it/2023/06/09/mistral-vento-mediterraneo/)."""),
  source("schildt", tr"""Göran Schildt, *In the Wake of Odysseus* (1953; in Swedish *I Odysseus kölvatten*, 1951), one of his books on the voyages of the *Daphne*, the boat he sailed around the Mediterranean after the Winter War, with the architect Alvar Aalto among his guests. [Schildt on Wikipedia](https://en.wikipedia.org/wiki/G%C3%B6ran_Schildt).""")]

# ------------------------------------------------------------------- this story's own helpers

let italianOf = block:   # each island's English name -> its Italian one
  let all = readCsv(data / "islands.csv", comment = "#")
  var names: Table[string, string]
  for i in 0 ..< all.nrows: names[$all["island", i]] = $all["italian", i]
  names

proc story(name: string): TableData =
  ## A table of this story, from data/isole/, skipping the line that says where it comes from,
  ## with its islands, countries, regions and languages in the page's language.
  result = readCsv(data / name, comment = "#")
  when lang == "it":
    var d = TableData()
    for c in result.columns:
      d.addColumn(c.name, c.values.mapIt(
        if it.isNull: it
        elif c.name == "island": toValue(if $it in italianOf: italianOf[$it] else: tr($it))
        elif c.name in ["country", "region", "language"]: toValue(tr($it))
        else: it))
    result = d

proc nums(v: Value): seq[float] =
  ## A cell of numbers separated by spaces ("1.5 -2 3") as floats.
  ($v).splitWhitespace.mapIt(it.parseFloat)

let photos = parseFile(data / "photos" / "photos.json")

proc photoHeading(title, file, name: string, level = 2) =
  ## A section's heading over the photo picked for it (`data/isole/photos/story/<file>.jpg`),
  ## credited from `photos.json`: who, when, the licence and a link to the source.
  var credit = ""
  for p in photos:
    if p["name"].getStr == name:
      credit = tr(name) & ": " & p["who"].getStr & (if p["when"].getStr.len > 0: ", " & p["when"].getStr else: "") &
        " · " & p["license"].getStr & " · [" & tr"source" & "](" & p["link"].getStr & ")"
  doAssert credit.len > 0, "no credit for " & name
  nbPhotoHeading tr(title), data / "photos" / "story" / (file & ".jpg"), credit, tr(name), level

proc outline(d: TableData, i: int): Value =
  ## Row `i`'s outline as a record of x and y (km), for a shape nanoplot; nothing without one.
  if d["x", i].isNull: return toValue(nil)
  toValue((x: nums(d["x", i]), y: nums(d["y", i])))

proc withColumn(d: TableData, name: string, fn: proc (i: int): Value): TableData =
  ## `d` with the column `name` made from each row's index by `fn` (in place of the old one, or
  ## at the end): for a column the table is grouped by or labelled with, made before the table.
  var vs: seq[Value]
  for i in 0 ..< d.nrows: vs.add fn(i)
  result = TableData()
  for c in d.columns: result.addColumn(c.name, if c.name == name: vs else: c.values)
  if not d.hasColumn(name): result.addColumn(name, vs)

proc keep(d: TableData, ok: proc (i: int): bool): TableData =
  ## The rows of `d` for which `ok` is true.
  let ix = toSeq(0 ..< d.nrows).filterIt(ok(it))
  result = TableData()
  for c in d.columns: result.addColumn(c.name, ix.mapIt(c.values[it]))

let sea = nanoplotOptions(dataBarFillColor = tint("--secondary"), dataBarStrokeColor = tint("--secondary-text"))
let islands = story("islands.csv")
let main = story("main.csv")

proc mainRow(title: string): int =
  for i in 0 ..< main.nrows:
    if main["title", i] == title: return i
  -1

# ------------------------------------------------------------------------------------ the story

nbTitle tr"A story · tabelline 0.2", tr"Islands of the Mediterranean", tr"""
The Mediterranean has thousands of islands, and Wikipedia lists 195 of them by area, from
Sicily down to islands of 5.5 km². This is a tour of them in tables: their shapes and
sizes, who ruled them, how they live now, how people get there, and when to go.
"""

nbNote(tr"""
Green cards like this one are about how the tables are made. Every table here is made with
tabelline 0.2: this story uses what 0.2 added that the [FOSDEM story](../fosdem/) does not, and
a new kind of nanoplot made for it, the *shape*. The data was gathered and shaped with
[nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim, in a story of its own,
[The islands' data, made with nanuq](../isole-data/); this page only reads its CSV files.
*Show code* under a table opens the Nim that made it. The green cards can be skipped: the rest
of the text is about the islands.
""", nkCode, tr"Reading the code")

nbToc()

photoHeading "A thousand things at once", "night-south-up", "Southern Italy and Sicily, south at the top"
nbText: tr"""
> Qu'est-ce que la Méditerranée ? Mille choses à la fois.

*What is the Mediterranean? A thousand things at once*, wrote Fernand Braudel, the historian
who spent his life on this sea, in *La Méditerranée* (1977)[^braudel]. Not one landscape, he went on, but
countless landscapes; in his great book of 1949 it is not one sea but a complex of seas, full of
islands. Braudel looked at it in three times: the slow time of the land, the sea and the
climate, the long time of states, economies and peoples, and the quick time of events. The
tables below follow him in three parts, each with the colour of its circles: first the islands'
shapes, then who ruled them and how they live, then getting there and when to go, where events
show up as a dip in a line.

Braudel is the first of the voices that guide this story: along the way it quotes passages from
books about the Mediterranean and its islands (Matvejević, *The Passenger*[^mediterraneo], Ramondino, Deleuze,
Lawrence, Anedda), and the tables answer them. Pietro suggested some of the books, Claude found
the others, and each passage was checked against its source. Göran Schildt[^schildt], who sailed this
sea in his boat, the *Daphne*, and wrote books about it, is a guide of another kind, for
whoever travels it. They are all listed under
[To read more](#to-read-more), at the end. The photos over the headings were chosen the same way:
Claude gathered openly licensed pictures for each section, Pietro picked one, and each is
credited under it; all of them, with the ones left out, are in
[Photos of the Mediterranean, by the story](../isole-photos/).

Braudel's complex of seas, west and east: the 35 main islands of this story in blue, with their
names, and the other 160 a dot in the colour of the circles.
"""

nbDrawing data / (if lang == "it": "map-west-it.svg" else: "map-west.svg"), tr"The western Mediterranean, from the Alboran Sea to the Adriatic and Malta"
nbDrawing data / (if lang == "it": "map-east-it.svg" else: "map-east.svg"), tr"The eastern Mediterranean, from the Ionian Sea to Cyprus"

nbNote(tr"""
The maps are not tables: they are two drawings made with the data, by
[map.nim](https://github.com/pietroppeter/tabelline/blob/main/docs/stories/data/isole/src/map.nim),
from OpenStreetMap's coast and the islands' places on Wikidata. Where each name goes was
written by Claude, the AI that wrote this story. Their colours are the page's, so they change
with its look.
""", nkCode)

nbText: tr"""
### How many there are

No one knows how many islands the Mediterranean has: it depends on how small an island may be.
The sea holds more than 10,000, by an estimate of 2022, and 2,217 of them are larger than a
hectare. Each country counts its own, by its own rules. Greece has somewhere between 1,200 and
6,000, by the smallest size counted, and people live on 166 to 227 of them. Croatia's statistics
office counts 1,185: 718 islands, 48 of them lived on, 389 rocks and 78 reefs. Italy has nearly
450, with those of its lakes and rivers, and Turkey about 500, in four seas and its lakes.

This story's 195 are the islands Wikipedia's list gives an area for, from Sicily down to Ilovik
and Petalas, 5.5 km² each. Its 35 main islands are the largest of them, down to Elba, so that the
last two are Malta, an island that is a country, and Elba, the largest of the Tuscan islands.

The end of the list is not rocks, then, but small islands with a story each. Levanzo, 5.8 km²,
has 208 people and the Grotta del Genovese, a cave with Neolithic paintings. Tavolara is one
limestone mountain off Sardinia, where a handful of families live; in 1836 the king of Sardinia
gave it, as a kingdom of make-believe, to the Bertoleoni family. Veli Brijun was Tito's summer
residence from 1947 to 1979, where he received heads of state, and is now a national park.
Sazan, Albania's largest island, is a military zone. Petalas, the last, is the largest private
island of Greece, with 4,000 olive trees and nobody living there.

Counted from OpenStreetMap's coastline, which draws every islet, the sea has 2,345 islands of a
hectare or more, near the estimate. Here they are by country, with the 195 of the list among them:
"""

const countryKm2 = {"IT": 302_068.0, "CY": 9_251.0, "FR": 551_695.0, "GR": 131_957.0, "ES": 505_990.0,
                    "TN": 163_610.0, "HR": 56_594.0, "MT": 316.0, "TR": 783_562.0, "AL": 28_748.0,
                    "EG": 1_010_408.0, "LY": 1_759_541.0, "DZ": 2_381_741.0}.toTable
  ## Each country's area (Wikipedia; France: metropolitan; Cyprus: the whole island).

nbShowCode:
  let every = story("countries.csv")
  let d = every.keep(proc (i: int): bool = every["km2", i].toFloat >= 1)
               .withColumn("share", proc (i: int): Value =
                 toValue(every["km2", i].toFloat / countryKm2[$every["code", i]]))
  let t = tabella(d, rownameCol = "code", locale = lang):
    optCssTheme()
    colsHide ["islands", "peopled", "main"]
    fmtCountry "code"
    textTransform tr, loc.stub()
    fmtInteger ["hectare", "listed", "km2", "people"]
    subZero "people", zeroText = "—"
    tabOptions(tableFontSize = "14px", dataRowPaddingHorizontal = "3px", columnLabelsPaddingHorizontal = "3px")
    fmtFraction "share", accuracy = "low"
    subSmallVals "share", threshold = 0.01, smallPattern = "<1/100"
    tabSpanner tr"islands", ["hectare", "listed"]
    colsLabel:
      hectare: tr"all"
      listed: tr"listed"
      km2: tr"area, {{km^2}}"
      people: tr"population"
      share: tr"of its land"
    grandSummaryRows:
      total: agg.sum
      columns = ["hectare", "listed", "km2", "people"]
      missingText = ""
      fmtInteger(sepMark = localeMarks(lang).sep)
    textTransform tr, loc.grandSummaryStub()
    tabFootnote tr"Islands of a hectare or more; the area and the people are those of every island, of any size.",
      loc.columnLabels(cols("hectare"))
    tabFootnote tr"From Wikipedia's list for its 195 islands, and from Wikidata for the others, where it has a count: most small islands have none, and few people.",
      loc.columnLabels(cols("people"))
    tabSourceNote md(tr"Every island: OpenStreetMap's land polygons (© [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors, ODbL), not the Peloponnese and Kassandra, cut off by canals, nor islands in lakes; the country from [Natural Earth](https://www.naturalearthdata.com/); Wikipedia, [List of islands in the Mediterranean](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean) (area, population); Wikidata. Nine other countries have islets under 1 km² in all.")
  nbTable t

nbNote(tr"""
This table counts every island, not only the list's: [extract.nim](https://github.com/pietroppeter/tabelline/blob/main/docs/stories/data/isole/src/extract.nim)
takes each of OpenStreetMap's land polygons in the sea and finds its country, and
[process.nim](https://github.com/pietroppeter/tabelline/blob/main/docs/stories/data/isole/src/process.nim)
adds them up by country, with nanuq. `tabSpanner` puts the two counts under one label, and
`fmtFraction` writes the share again, as in the table of the main islands.
""", nkCode)

nbText: tr"""
Italy has the most land on islands, a sixth of the country, almost all of it Sicily and
Sardinia; Greece has the most islands, 871 of a hectare or more, and a fifth of its land. Croatia
has 604, more than Italy, France and Spain together, and they are a seventeenth of its land.
Cyprus and Malta are islands and nothing else.
"""

photoHeading "One island to start", "etna-plume", "Etna's plume"
nbText: tr"""

Predrag Matvejević's *Mediterranean Breviary* (1987)[^matvejevic] opens with a choice:

> Scegliamo innanzitutto un punto di partenza: riva o scena, porto o evento, navigazione o racconto.

*First of all, let us choose a starting point: a shore or a scene, a port or an event, a voyage
or a tale.* This story starts from an island: the largest of the Mediterranean, in one row: its outline, how big it is, how many live
there, and how high it goes.
"""

nbShowCode:
  let sicily = islands.keep(proc (i: int): bool = islands["title", i] == "Sicily")
                      .withColumn("shape", proc (i: int): Value = islands.outline(0))
  let t = tabella(sicily, rownameCol = "island", locale = lang):
    optCssTheme()
    colsHide everything()
    colsUnhide ["shape", "km2", "population", "elevation"]
    colsMove ["shape"], after = "island"
    fmtNanoplot "shape", plotType = "shape", plotHeight = "4.5em", options = sea
    fmtInteger ["km2", "population", "elevation"]
    colsLabel:
      population: tr"population"
      shape: ""
      km2: tr"area, {{km^2}}"
      elevation: tr"highest, {{m}}"
    tabSourceNote md(tr"Wikipedia, [List of islands in the Mediterranean](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean); [Wikidata](https://www.wikidata.org/); the outline © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors ([ODbL](https://opendatacommons.org/licenses/odbl/)).")
  nbTable t

nbNote(tr"""
The outline is a nanoplot of a new kind, `plotType = "shape"`: the cell holds a record of `x` and
`y` (here kilometres east and north of the island's middle), and the shape joins the points in
their order, closes them and fills them, at the same scale across and up. OpenStreetMap's
coastline has 56,300 points around Sicily; the data's extract step kept 120. The units in the labels,
`{{km^2}}` and `{{m}}`, are gt's units syntax, new in 0.2: "km²" in HTML and in text.
""", nkCode)

nbText: tr"""
Sicily is a triangle of 25,834 km² with five million people, and its highest point is Etna,
3,340 m, the highest active volcano in Europe outside the Caucasus.

"""
photoHeading "Thirty-five islands", "dolphins-knossos", "The dolphins of Knossos"
nbText: tr"""

Most of the 195 are small: half of them are under 27 km². The 35 largest, down to Elba, 224 km², the largest of the Tuscan
islands, with Malta, the island of a country, just before it, are the *main islands* of this
story, each drawn with its outline.

> Ci sono isole che hanno forma di pesci, di delfino, ad esempio o di torpedine, altre che hanno
> forma di coralli, altre di sirena.

*There are islands shaped like fish, a dolphin, say, or a torpedo ray, others shaped like
corals, others like a mermaid*, wrote Fabrizia Ramondino of Mallorca, in *Guerra di infanzia e
di Spagna* (2001)[^ramondino].
"""

nbShowCode:
  let d = main.withColumn("shape", proc (i: int): Value =
    islands.outline(toSeq(0 ..< islands.nrows).filterIt(islands["title", it] == main["title", i])[0]))
  let t = tabella(d, rownameCol = "island", locale = lang):
    optCssTheme()
    colsHide everything()
    colsUnhide ["shape", "code", "km2", "population"]
    colsMove ["shape"], after = "island"
    colsMove ["code"], after = "population"
    fmtNanoplot "shape", plotType = "shape", plotHeight = "2.4em", options = sea
    # the stub's rule moves after the shape, so the name and its outline read as one
    tabOptions(stubBorderStyle = "none")
    tabStyle style.borders({sRight}, color = tint("--line"), weight = "2px"),
      [loc.body(cols("shape")), loc.columnLabels(cols("shape")), loc.grandSummary(cols("shape"))]
    fmtCountry "code"
    textTransform tr, loc.body(cols("code"))   # the country's name in the page's language
    fmtInteger ["km2", "population"]
    subMissing ["population"], missingText = "—"
    colsLabel:
      population: tr"population"
      shape: ""
      code: tr"country"
      km2: tr"area, {{km^2}}"
    grandSummaryRows:
      total: agg.sum
      columns = ["km2", "population"]
      missingText = ""
      fmtInteger(sepMark = localeMarks(lang).sep)   # a summary's format does not take the table's locale
    textTransform tr, loc.grandSummaryStub()
    tabFootnote tr"Wikipedia's list gives no population for Cyprus, divided since 1974: 918,100 in the Republic's areas (census 2021) and 382,836 in the north (estimate 2021), from Wikipedia's articles.", loc.body(cols("population"), 2)
    tabSourceNote md(tr"Wikipedia, [List of islands in the Mediterranean](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean) (area, population); outlines © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors ([ODbL](https://opendatacommons.org/licenses/odbl/)).")
  nbTable t

nbNote(tr"""
`fmtCountry` writes a country's name from its code (`IT` is Italy), from CLDR, so the data keeps
the code. The rule after the stub moves past the shape: `tabOptions(stubBorderStyle = "none")`
takes it away, and `style.borders` on the shape's cells draws it again. The total row is
`grandSummaryRows`, formatted with `fmtInteger()` in its block. Each shape here is drawn at its
own scale, as large as the cell allows.
""", nkCode)

nbText: tr"""
Together the 35 are 97,297 km² with 11.4 million people, about as much land, and as many people,
as Portugal (92,225 km², 11.4 million in 2025). Sicily alone is a quarter of the land and almost
half of the people.

Malta is the most crowded of them by far: 1,664 people on each km², more than eight times
Sicily. Cres and Krk have the same area in the list, 405.78 km², but Krk has 19,383 people and
Cres 3,079, one for every 13 hectares. Among all the islands where people live, ordered by
how many live on each km², Malta is still first, with two islands of the Gulf of Naples after
it; at the other end, a few people on a lot of rock, and on Asinara, the old prison island, one (the census of 2001
counted a single man). Sicily, Krk and Cres are shown in their places:
"""

nbShowCode:
  let peopled = islands.keep(proc (i: int): bool = not islands["population", i].isNull and
    islands["population", i].toFloat > 0 and islands["km2", i].toFloat > 0)
  var d = peopled.withColumn("density", proc (i: int): Value =
    toValue(peopled["population", i].toFloat / peopled["km2", i].toFloat))
  d = d.withColumn("shape", proc (i: int): Value = d.outline(i))
  let order = toSeq(0 ..< d.nrows).sortedByIt(-d["density", it].toFloat)
  var sorted = TableData()
  for c in d.columns: sorted.addColumn(c.name, order.mapIt(c.values[it]))
  var t = tabellaPreview(sorted, topN = 3, bottomN = 3,
                         moreRows = where($it.title in ["Sicily", "Krk (island)", "Cres (island)"])):
    optCssTheme()
    colsHide everything()
    colsUnhide ["island", "shape", "population", "density"]
    colsMove ["shape"], after = "island"
    fmtNanoplot "shape", plotType = "shape", plotHeight = "1.8em", options = sea
    fmtInteger ["population", "density"]
    fmtNumber "density", rows = where(it["density"].toFloat < 1), decimals = 2
    subMissing "shape", missingText = ""
    dataColor "density", palette = palette("reds"), domain = (0.0, 1700.0)
    colsLabel:
      population: tr"population"
      shape: ""
      density: tr"per {{km^2}}"
    tabSourceNote md(tr"Wikipedia, [List of islands in the Mediterranean](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean): the islands where people live.")
  t.locale = lang   # tabellaPreview takes no locale
  nbTable t

nbNote(tr"""
The density is computed before the table, and the rows are put in its order: `tabellaPreview`
shows the first and the last rows of the data as it is, and with `moreRows` (new in 0.2, not
from gt) the rows the text talks about, here chosen by their page with `where`, wherever they
fall; each run of rows left out is a grey row that says which. `dataColor` colours each density on a
scale from white to red, with the same `domain` for every row, 0 to 1,700 people a km².
""", nkCode)

photoHeading "At the same scale", "lemnos-piri-reis", "Lemnos, in Piri Reis's Book of the Sea"
nbText: tr"""

Drawn at their own scale, Malta looks as large as Sicily. With `autoscale`, every shape takes
the scale of the largest one in the column, and the sizes can be compared: Sicily is a hundred
times Malta. Grouped by country, each with the share of its country's land it is. Alone, an
outline looks like a world of its own; *The Passenger*'s book on Sicily (Iperborea, 2024)[^sicilia]
warns against that look:

> Guardando una cartina, un'isola ci dà l'illusione di essere un piccolo mondo a sé. […] Ma si
> tratta di una mistificazione.

*Looking at a map, an island gives us the illusion of being a small world of its own. […] But
it is a mystification.*
"""

nbShowCode:
  var d = main.withColumn("shape", proc (i: int): Value =
    islands.outline(toSeq(0 ..< islands.nrows).filterIt(islands["title", it] == main["title", i])[0]))
  d = d.withColumn("share", proc (i: int): Value = toValue(main["km2", i].toFloat / countryKm2[$main["code", i]]))
  let t = tabella(d, rownameCol = "island", groupnameCol = "country", rowGroupAsColumn = true, locale = lang):
    optCssTheme()
    colsHide everything()
    colsUnhide ["shape", "km2", "share"]
    colsMove ["shape"], after = "island"
    rowGroupOrder ["Italy", "Cyprus", "France", "Greece", "Spain", "Tunisia", "Croatia", "Turkey", "Malta"].mapIt(tr(it))
    fmtNanoplot "shape", plotType = "shape", plotHeight = "3em", autoscale = true, options = sea
    fmtInteger ["km2"]
    fmtFraction "share", accuracy = "med"
    subSmallVals "share", threshold = 0.01, smallPattern = "<1/100"
    colsLabel:
      shape: ""
      km2: tr"area, {{km^2}}"
      share: tr"of its country"
    summaryRows:
      all: agg.sum
      columns = ["km2", "share"]
      groups = ["Italy", "Greece", "Spain", "Croatia"].mapIt(tr(it))   # the countries with more than one
      missingText = ""
    textTransform tr, loc.summaryStub()
    tabSourceNote md(tr"Areas: Wikipedia, [List of islands in the Mediterranean](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean); the countries' areas from their articles (France: metropolitan).")
  nbTable t

nbNote(tr"""
`rowGroupAsColumn = true` puts the country in a column of its own, left of the islands, instead
of a row above them. `fmtFraction` writes the share as a fraction, with up to two digits
below (`accuracy = "med"`): Sicily is 1/12 of Italy, Crete 1/16 of Greece; `subSmallVals` writes
"<1/100" for the small ones, which as fractions would be 0. `summaryRows` adds them up
for each country with more than one (`groups`), in the format of their column.
""", nkCode)

nbText: tr"""
Greece has eighteen of the 35, and together they are a sixth of its land; Croatia has six.
Cyprus and Malta are the islands of their countries: Cyprus all of it, Malta the larger of its
three.

"""
photoHeading "All 195", "strombolicchio", "Strombolicchio"
nbText: tr"""

*Non c'è alcuna unità oggettiva nell'insieme delle isole*, there is no objective unity in the
set of islands, wrote Gilles Deleuze in *L'isola deserta*[^deleuze]. The whole list is long. A preview shows its two ends, the largest and the smallest islands,
with the place of each in the list:
"""

nbShowCode:
  let d = islands.withColumn("shape", proc (i: int): Value = islands.outline(i))
  var t = tabellaPreview(d, topN = 4, bottomN = 4):
    optCssTheme()
    colsHide everything()
    colsUnhide ["island", "shape", "country", "km2"]
    colsMove ["shape"], after = "island"
    fmtNanoplot "shape", plotType = "shape", plotHeight = "1.8em", options = sea
    fmtNumber "km2", decimals = 2, dropTrailingZeros = true
    subMissing "shape", missingText = ""
    colsLabel:
      country: tr"country"
      shape: ""
      km2: tr"{{km^2}}"
  t.locale = lang   # tabellaPreview takes no locale
  nbTable t

nbNote(tr"""
`tabellaPreview(data, topN, bottomN)` makes a table of the first and last rows of a big one,
with the place of each row and a line for the rows left out between them. Three islands have no
outline: Wikidata has no place for them, so there is no point to find their coast from.
""", nkCode)

nbText: tr"""
And here they all are, in the order of the list, each at its own scale and with its place: the
35 main islands in blue, the first seven rows, down to Elba; the others in the colour of the
circles.
"""

nbShowCode:
  const across = 5
  var shapeCols, nameCols: array[across, seq[Value]]
  var mainCells: seq[(int, int)]   # (row, place in the row) of each main island
  for i in 0 ..< islands.nrows:
    let (row, k) = (i div across, i mod across)
    shapeCols[k].add islands.outline(i)
    nameCols[k].add toValue($islands["rank", i] & ".\u00A0" & $islands["island", i])   # no break after the number
    if $islands["main", i] == "true": mainCells.add (row, k)
  for k in islands.nrows mod across ..< across:   # the last row's empty places
    if islands.nrows mod across == 0: break
    shapeCols[k].add toValue(nil)
    nameCols[k].add toValue("")
  var grid = TableData()
  for k in 0 ..< across:
    grid.addColumn("s" & $k, shapeCols[k])
    grid.addColumn("n" & $k, nameCols[k])
  let shapes = toSeq(0 ..< across).mapIt("s" & $it)
  let pink = nanoplotOptions(dataBarFillColor = tint("--primary-soft"), dataBarStrokeColor = tint("--primary-text"))
  var t = tabella(grid):
    optCssTheme()
    fmtNanoplot shapes, plotType = "shape", plotHeight = "2.2em", options = pink
    subMissing shapes, missingText = ""
    tabOptions(columnLabelsHidden = true, tableFontSize = "9px", dataRowPadding = "4px",
               dataRowPaddingHorizontal = "1px")
    tabSourceNote md(tr"Wikipedia, [List of islands in the Mediterranean](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean), by area. Outlines © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors ([ODbL](https://opendatacommons.org/licenses/odbl/)); the three without one have no place on Wikidata.")
  for (row, k) in mainCells:
    t = t.fmtNanoplot("s" & $k, rows = row, plotType = "shape", plotHeight = "2.2em", options = sea)
  for k in 0 ..< across:
    t = t.colsMerge(["s" & $k, "n" & $k], pattern = "{1}<br>{2}")
  t = t.colsAlign(alCenter, shapes)
  nbTable t

nbNote(tr"""
A grid is a table too: 195 islands in rows of five, each cell a shape over its place and name.
The data is built for it, a column of shapes and one of names for each place in the row;
`colsMerge` puts the two in one cell with the pattern `{1}<br>{2}`. `fmtNanoplot` takes `rows`,
and a later format of a cell replaces an earlier one, so the main islands are drawn again in
blue, one cell at a time. `columnLabelsHidden` leaves out the labels a grid does not need.
""", nkCode)

nbText: tr"""
By country, the islands' sizes make a box plot each, for the countries with three or more: the
box holds the middle half of a country's islands, the whiskers the rest, and dots the islands
far larger than the others. Each box has its own scale, up to the country's largest island:
everywhere most islands are small and a few are very large.

Braudel called the islands *isolated worlds* and *lands of hunger*, and then qualified it:
isolation is relative, and Sicily, a granary of the whole sea, was no such world. The
small islands still are: only 45 of the 195 have an airport or a World Heritage site, and past
the hundredth in size only Lampedusa and Kastellorizo have an airport.
"""

nbShowCode:
  var byCountry: OrderedTable[string, seq[float]]
  for i in 0 ..< islands.nrows:
    if not islands["country", i].isNull:
      byCountry.mgetOrPut($islands["country", i], @[]).add islands["km2", i].toFloat
  var rows: seq[tuple[country: string, islands: int, sizes: string, largest: float, total: float]]
  for c, ks in byCountry:
    if ks.len >= 3: rows.add (c, ks.len, ks.mapIt($it).join(" "), ks.max, ks.sum)
  rows.sort(proc (a, b: auto): int = cmp(b.islands, a.islands))
  let t = tabella(rows, rownameCol = "country", locale = lang):
    optCssTheme()
    colsHide ["total"]
    fmtNanoplot "sizes", plotType = "boxplot", plotHeight = "2em",
      options = nanoplotOptions(dataBarFillColor = tint("--secondary-soft"), dataBarStrokeColor = tint("--secondary-text"))
    fmtInteger ["largest"]
    colsLabel:
      islands: tr"islands"
      sizes: tr"their areas, {{km^2}}"
      largest: tr"largest"
      total: tr"together"
    grandSummaryRows:
      all: agg.sum
      columns = ["islands"]
      missingText = ""
      fmtInteger(sepMark = localeMarks(lang).sep)   # a summary's format does not take the table's locale
    textTransform tr, loc.grandSummaryStub()
    tabSourceNote md(tr"Wikipedia, [List of islands in the Mediterranean](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean), by area.")
  nbTable t

nbNote(tr"""
A box plot is one of the three nanoplots ported from Great Tables (`plotType = "boxplot"`); the
cell holds every value, here the areas as a text of numbers. Without `autoscale` each box has
its own axis. Hover over a box to read its quartiles.
""", nkCode)

# ------------------------------------------------------------------------------------ history

nbPart 2, "", prSuccess   # Braudel's long time: rulers, heritage, how they live
photoHeading "Who ruled them", "venice-bordone", "Venice, in Bordone's book of islands"
nbText: tr"""

Islands in the middle of a sea are crossroads, and every power of the Mediterranean took its
turn. Braudel saw them for the parts they played as much as for their land: lairs of fishermen
and pirates, places people left and places people came to. The powers that ruled each main island, a dot each, in the order they came, from the first
peoples to the last empires, and the state each island is in today; the islands from the largest:
"""

const powers = [   # each column: the rulers of history.csv it stands for, and its age
  ("first peoples", @["Nuragic", "Talaiotic", "Minoans", "Mycenaeans", "Cycladic", "Illyrians", "Temple builders",
                      "Etruscans", "Thracians"], "ancient"),
  ("Greeks", @["Greeks", "Greeks and Phoenicians", "Greeks and Etruscans", "Athens", "Ptolemies"], "ancient"),
  ("Phoenicians, Carthage", @["Phoenicians", "Carthage", "Greeks and Phoenicians"], "ancient"),
  ("Rome", @["Rome"], "ancient"),
  ("Byzantium", @["Byzantium"], "medieval"),
  ("Arabs", @["Arabs", "Moors", "Hafsids"], "medieval"),
  ("Normans, Franks", @["Normans", "Angevins", "Lusignans"], "medieval"),
  ("Venice", @["Venice", "Duchy of the Archipelago"], "medieval"),
  ("Genoa, Pisa", @["Genoa", "Pisa"], "medieval"),
  ("Aragon, Spain", @["Aragon", "Aragon and Spain", "Bourbons", "Medici and Spain"], "modern"),
  ("Knights", @["Knights Hospitaller"], "modern"),
  ("Ottomans", @["Ottomans"], "modern"),
  ("France", @["France"], "modern"),
  ("Britain", @["Britain"], "modern"),
  ("Hungary, Austria", @["Croatia and Hungary", "Frankopans", "Austria"], "modern")]

nbShowCode:
  let h = story("history.csv")
  let label = proc (s: string): string = tr(s).replace(" ", "\u00A0")   # one line, turned on its side
  var d = h.withColumn("island", proc (i: int): Value =
    let own = if h["language", i].isNull: "" else: "  \n*" & $h["language", i] & "*"
    toValue($main["island", mainRow($h["title", i])] & own))
  d = d.withColumn("today", proc (i: int): Value = toValue(tr(($h["rulers", i]).split(';')[^1])))
  for (power, names, age) in powers:
    d = d.withColumn(label(power), proc (i: int): Value =
      toValue(if ($h["rulers", i]).split(';').anyIt(it in names): "●" else: ""))
  let byAge = proc (age: string): seq[string] = powers.filterIt(it[2] == age).mapIt(label(it[0]))
  let stripes = toSeq(0 ..< powers.len).filterIt(it mod 2 == 0).mapIt(label(powers[it][0]))
  let t = tabella(d, rownameCol = "island"):
    optCssTheme()
    colsHide ["title", "page", "joined_how", "language", "rulers", "venice_from", "venice_to", "rule"]
    colsMove ["today", "joined"], after = label(powers[^1][0])
    fmtMarkdown "island"
    colsMerge ["today", "joined"], pattern = tr"{1}<br>since&nbsp;{2}"
    colsLabel:
      today: tr"today"
    colsLabelRotate powers.mapIt(label(it[0]))
    colsAlign alCenter, powers.mapIt(label(it[0]))
    tabSpanner tr"ancient", byAge("ancient")
    tabSpanner tr"middle ages", byAge("medieval")
    tabSpanner tr"modern", byAge("modern")
    tabStyle style.text(color = tint("--success")), loc.body(cols(byAge("ancient")))
    tabStyle style.text(color = tint("--secondary")), loc.body(cols(byAge("medieval")))
    tabStyle style.text(color = tint("--primary")), loc.body(cols(byAge("modern")))
    tabStyle style.fill(tint("--shade")), loc.columnLabels(cols(stripes)), loc.body(cols(stripes))
    # a rule where an age begins, and before today, through the labels and the dots
    let starts = @[byAge("medieval")[0], byAge("modern")[0], "today"]
    tabStyle style.borders({sLeft}, color = tint("--ink"), weight = "1.5px"),
      [loc.body(cols(starts)), loc.columnLabels(cols(starts))]
    tabStyle style.borders({sLeft}, color = tint("--ink"), weight = "1.5px"),
      loc.spanners(tr"middle ages", tr"modern")
    # each age's name in its dots' colour, so the key is over the dots
    tabStyle style.text(color = tint("--success-text"), weight = "bold"), loc.spanners(tr"ancient")
    tabStyle style.text(color = tint("--secondary-text"), weight = "bold"), loc.spanners(tr"middle ages")
    tabStyle style.text(color = tint("--primary-text"), weight = "bold"), loc.spanners(tr"modern")
    tabStyle style.text(size = "11px"), loc.body(cols("today"))
    tabOptions(tableFontSize = "12.5px", columnLabelsFontSize = "75%",
               dataRowPaddingHorizontal = "1px", columnLabelsPaddingHorizontal = "1px")
    tabSourceNote tr"Each island's history on Wikipedia, read and summed up by Claude, the AI that wrote this story: a dot, not the whole story."
  nbTable t

nbNote(tr"""
One column for each power, a dot where it ruled: the dots are made before the table, a "●" or
nothing, and `colsLabelRotate` turns the fifteen labels on their side so the columns stay as
narrow as a dot (`label` keeps each one on a single line, with no-break spaces). The three `tabSpanner`s name the ages over them, `tabStyle` colours each
age's dots, and shades every other column, label and dots, so each label stays with its dots. `colsMerge` writes the state and the year in one cell, with the pattern
`{1}<br>since&nbsp;{2}`, and the table is set a size smaller (`tabOptions`) to fit a phone. Under each island's name, in
italics, its own language, beside the state's: the stub is Markdown (`fmtMarkdown`).
""", nkCode)

nbText: tr"""
*They say neither Romans nor Phoenicians, Greeks nor Arabs ever subdued Sardinia*, wrote D. H.
Lawrence in *Sea and Sardinia* (1921)[^lawrence]. The table says otherwise: Carthage, Rome, Byzantium,
Aragon and Savoy all came. Rome and Byzantium ruled almost all of them. The last to join the state they are in were the
islands that became states: Cyprus in 1960, Malta in 1964, and the six Croatian islands with
Croatia in 1991. Before them, Rhodes, Kos and Karpathos joined Greece in 1947, after thirty-five
years under Italy, and Gökçeada, the Greek Imbros, went to Turkey at Lausanne in 1923.

"""
photoHeading "World Heritage", "palermo-cathedral", "Palermo cathedral, about 1900", level = 3
nbText: tr"""

UNESCO lists 28 World Heritage properties on the islands. Sicily has six, Malta three, Cyprus
three. Some are one place; others are several, a serial property in UNESCO's words: the late
Baroque towns of the Val di Noto are eight towns, and Malta's megalithic temples are seven, on Malta and Gozo.
"""

nbShowCode:
  let sites = story("heritage.csv")
  type Line = object
    name: string
    icon: string
    listed: Value
    parts: Value
    level: int
  var lines: seq[Line]
  var last = ""
  for i in 0 ..< sites.nrows:
    if $sites["island", i] != last:
      last = $sites["island", i]
      lines.add Line(name: last, listed: toValue(nil), parts: toValue(nil))
    let natural = $sites["property", i] in ["1427", "258", "908"]
    lines.add Line(name: $sites["site", i], icon: if natural: "mountain-sun" else: "landmark",
                   listed: sites["listed", i], parts: sites["parts", i], level: 1)
  let t = tabella(lines, rownameCol = "name", locale = lang):
    optCssTheme()
    colsHide ["level"]
    colsMove ["icon"], after = "name"
    fmtIcon "icon", height = "1em", fillColor = tint("--success")
    tabStubIndent toSeq(0 ..< lines.len).filterIt(lines[it].level == 1), "increase"
    tabStyle style.text(weight = "bold"), loc.stub(toSeq(0 ..< lines.len).filterIt(lines[it].level == 0))
    subMissing ["listed", "parts"], missingText = ""
    colsLabel:
      icon: ""
      listed: tr"listed"
      parts: tr"places"
    tabSourceNote md(tr"[UNESCO's list](https://whc.unesco.org/en/list/) as Wikidata has it; a property is placed on an island by the outline that holds its places. A mountain marks a natural property.")
  nbTable t

nbNote(tr"""
One table, two levels: each island is a row with its name in bold, and its properties follow,
indented with `tabStubIndent` (new in 0.2), which moves a stub's text in by a step. The icons are
Font Awesome's `landmark` and `mountain-sun`. Gozo, Lipari, Patmos and Čiovo are not
among the 35 main islands, but have a property too.
""", nkCode)

# ------------------------------------------------------------------------------------ economy

photoHeading "How they live now", "luzzus-marsaxlokk", "Luzzus in Marsaxlokk, Malta"
nbText: tr"""

Eurostat measures the European Union by regions, and most of the main islands are a region of
their own, or part of one: the Balearic Islands, the North and South Aegean, the Ionian Islands,
Adriatic Croatia. Djerba, in Tunisia, is outside these numbers, and Gökçeada, in Turkey, has only
its unemployment. The richness of a region is its gross domestic
product per person, in *purchasing power standards*, euros that buy the same everywhere; each
region's amount is written here the way its own language writes money.
"""

nbShowCode:
  var seen = initHashSet[string]()
  var d = main.keep(proc (i: int): bool =
    result = not main["region", i].isNull and $main["region", i] notin seen
    if result: seen.incl $main["region", i])
  d = d.withColumn("label", proc (i: int): Value =
    let isl = toSeq(0 ..< main.nrows).filterIt(main["region", it] == d["region", i]).mapIt($main["island", it])
    toValue(if isl == @[$d["region", i]]: $d["region", i] else: $d["region", i] & "  \n*" & isl.join(", ") & "*"))
  var t = tabella(d, rownameCol = "label", locale = lang):
    optCssTheme()
    colsHide everything()
    colsUnhide ["pps_per_person", "pps_index", "jobless_2025"]
    fmtMarkdown "label"
    rowOrder "pps_index", reverse = true
    fmtNanoplot "pps_index", plotHeight = "1.1em", referenceLine = "100",
      options = nanoplotOptions(dataBarFillColor = tint("--secondary"), dataBarStrokeColor = tint("--secondary"))
    fmtPercent "jobless_2025", decimals = 1, scaleValues = false
    colsLabel:
      pps_per_person: tr"per person"
      pps_index: tr"EU = 100"
      jobless_2025: tr"jobless"
    tabSpanner tr"GDP in PPS, 2024", ["pps_per_person", "pps_index"]
    tabStyle proc (r: Row): CellStyle = (if r.pps_index.toFloat < 75: style.fill(tint("--primary-soft")) else: CellStyle()),
      [loc.stub(), loc.body()]
    tabSourceNote md(tr"Eurostat, as Wikipedia lists it: [GDP of the NUTS 2 regions](https://en.wikipedia.org/wiki/List_of_European_Union_regions_by_GDP) in 2024, [unemployment](https://en.wikipedia.org/wiki/List_of_European_regions_by_unemployment_rate) in 2025.")
  # each region's money in its own language: one locale for the rows of each
  for l in ["it", "el_CY", "fr", "el", "ca", "hr", "mt"]:   # Turkey's region has no GDP here
    let rowsOf = toSeq(0 ..< d.nrows).filterIt(d["locale", it] == l)
    t = t.fmtCurrency("pps_per_person", rows = rowsOf, currency = "EUR", decimals = 0, locale = l)
  nbTable t

nbNote(tr"""
The amounts are formatted in each region's locale: "24.500 €" in Italian, "34 500 €" in French,
"€43,900" in Maltese English. tabelline 0.2 has every locale of CLDR (657 of them), and
`fmtCurrency` takes `locale` and `rows`, so one column can speak several languages. The
index is a nanoplot of single values: one bar per row from a shared zero, with a dashed line at
the EU's 100. The rows below 75, where the EU's cohesion funds go first, are highlighted:
`tabStyle` with a proc of the row, on the stub and the body.
""", nkCode)

nbText: tr"""
The Balearic Islands and Malta are as rich as the European average, or richer, from tourism and,
in Malta, finance and gaming. Elba and Kythira look rich too, but their regions, Tuscany and
Attica, are mostly Florence and Athens. The North Aegean, Lesbos, Chios, Lemnos, Samos and Icaria,
is among the poorest regions of the Union, at 42, with Eastern Macedonia and Thrace, Thasos's
region on the mainland, at 45.

### Twenty years of work

Unemployment, every year from 2006 to 2025: the line of each region against the median of the
300 or so regions of Europe, its mean over the twenty years, and how much it moved around it.
"""

nbShowCode:
  let jobs = story("unemployment.csv")
  let years = toSeq(2006 .. 2025).mapIt("y" & $it)
  let t = tabella(jobs, rownameCol = "region", locale = lang):
    optCssTheme()
    summaryColumns:
      mean: agg.mean
      sd: agg.std
      columns = years
    colsNanoplot years, autoscale = true, plotHeight = "1.2em", newColName = "trend",
      newColLabel = "2006–2025", xVals = toSeq(2006 .. 2025).mapIt(it.float), referenceX = @["2013"],
      options = nanoplotOptions(dataLineStrokeColor = tint("--secondary"),
        dataPointRadius = 0, dataAreaFillColor = tint("--secondary-soft"))
    colsUnhide ["y2025"]
    colsMove ["trend"], after = "region"
    fmtNumber ["mean", "sd", "y2025"], decimals = 1
    colsMergeUncert "mean", "sd"
    tabStyle style.css("white-space: nowrap"), loc.body(cols("mean"))
    rowOrder "y2025", reverse = true
    colsLabel:
      mean: tr"mean ± sd"
      y2025: tr"2025"
    let median = where(it["region"] == tr"All regions (median)")
    tabStyle style.fill(tintMix("--ink", 10)) & style.text(weight = "bold"), loc.stub(rows = median), loc.body(rows = median)
    tabOptions(dataRowPaddingHorizontal = "4px", columnLabelsPaddingHorizontal = "4px")   # to fit a phone
    tabSourceNote md(tr"Eurostat, as Wikipedia lists it: [List of European regions by unemployment rate](https://en.wikipedia.org/wiki/List_of_European_regions_by_unemployment_rate) (%).")
  nbTable t

nbNote(tr"""
`summaryColumns` adds a column for each aggregate, computed across the columns of each row:
here the mean and the standard deviation of the twenty years. `colsMergeUncert` writes them as
one value, "14.2 ± 4.1". `colsNanoplot` draws the twenty columns as a line in a new column and
hides them; `colsUnhide` shows 2025 again. `xVals` gives each column its year, so `referenceX`
can draw the dashed line at 2013 (both not from gt). The median of Europe's regions, a yardstick
and not a region, is the shaded row in bold: `tabStyle` on the stub and the body of the rows
`where` the region is the median's.
""", nkCode)

var sicily14 = ""
nbShowCode:
  let jobs = story("unemployment.csv")
  let sicilyRow = toSeq(0 ..< jobs.nrows).filterIt(jobs["region", it] == tr"Sicily")
  sicily14 = extractCells(tabella(jobs, rownameCol = "region", locale = lang), "y2014", rows = sicilyRow)[0]
  nbText tr"Sicily in 2014, as the table writes it: **{sicily14}**".replace("{sicily14}", sicily14)

nbNote(tr"""
Sicily's rate in 2014, in the next paragraph, is not typed: `extractCells` takes it from the
table's cell, formatted as the table writes it, and the paragraph puts it in its text.
""", nkCode)

nbText: tr"""
The crisis of the 2010s is a hill on every line, and the dashed line is 2013, the year the
European Union had the most people out of work: in 2014 Sicily had {sicily14}% of its people
out of work, the South Aegean more than one in five in 2013. Every region is back down now, and
Malta, at 3.1%, has fewer out of work than almost anywhere in Europe.
""".replace("{sicily14}", sicily14)

nbPart 3, "", prSecondary   # the quick time: getting there, when to go, what to see
photoHeading "Getting there", "capri-harbour", "Capri's harbour, about 1880"
nbText: tr"""

> La prima lezione delle isole è che non puoi andartene a piedi. Acqua, aria, vento, onde, corde,
> bitte, sartie. Devi prendere una nave o un aereo.

*The first lesson of islands is that you can't leave on foot. Water, air, wind, waves, ropes,
bollards, shrouds. You have to take a ship or a plane*: the first lines of Antonella Anedda's
*Isolatria* (2013)[^anedda], on the Maddalena islands. Most visitors fly. Wikidata has the passengers of 64 airports on the islands, year by year,
some since the 1960s; for each island, the sum of its airports (an island that has a large
airport leaves its airstrips out). Every line starts in 2000 and ends in 2025, and the dashed
line is 11 March 2020, when the World Health Organization called COVID-19 a pandemic: the dip
right after it is the year without travel.
"""

nbShowCode:
  let pax = story("passengers.csv")
  var series: OrderedTable[string, seq[(int, float)]]
  for i in 0 ..< pax.nrows:
    series.mgetOrPut($pax["island", i], @[]).add (pax["year", i].toFloat.int, pax["passengers", i].toFloat)
  var rows: seq[tuple[island: string, years: Value, latest: float, year: int, dip: float]]
  for name, s in series:
    if s.len < 8: continue
    let y19 = s.filterIt(it[0] == 2019)
    let y20 = s.filterIt(it[0] == 2020)
    let dip = if y19.len > 0 and y20.len > 0: y20[0][1] / y19[0][1] - 1 else: NaN
    rows.add (name, toValue((x: s.mapIt(&"{it[0]}-07-01"), y: s.mapIt(it[1]))), s[^1][1], s[^1][0], dip)
  rows.sort(proc (a, b: auto): int = cmp(b.latest, a.latest))
  let t = tabella(rows[0 ..< 14], rownameCol = "island", locale = lang):
    optCssTheme()
    fmtNanoplot "years", plotHeight = "1.2em", expandX = @[946_684_800.0, 1_751_328_000.0],
      referenceX = @["2020-03-11"],
      options = nanoplotOptions(dataLineStrokeColor = tint("--secondary"), dataPointRadius = 0,
        dataAreaFillColor = tint("--secondary-soft"))
    fmtNumberSi "latest", decimals = 1
    colsHide ["year"]
    tabStyle style.css("white-space: nowrap") & style.text(size = "12px"), loc.body(cols(["latest", "dip"]))
    fmtPercent "dip", decimals = 0
    subMissing "dip", missingText = ""
    colsLabel:
      years: tr"passengers a year, 2000 on"
      latest: tr"last count"
      dip: tr"2020"
    tabSourceNote md(tr"Wikidata ([P3872](https://www.wikidata.org/wiki/Property:P3872)), the yearly counts of each airport, added up for each island; the last count is of 2022, of 2025 for Mallorca and Ibiza.")
  nbTable t

nbNote(tr"""
The points of each line are placed by date (`x` is a list of ISO dates, "2019-07-01"), so a year
without a count leaves a gap of the right width, and `expandX` makes every axis run from 2000
to 2025: on an axis shared by the rows every plot has the same width, so the years line up.
`referenceX` (new in tabelline 0.2, and not in gt or Great Tables) draws the dashed line at a date, with the date on hover. Each line has its own y axis, from its lowest year to its highest, so the dip of 2020
shows on the small islands too.
`fmtNumberSi` writes "33.8 M"; the last count is of 2022 for most islands.
""", nkCode)

# ------------------------------------------------------------------------------------ climate

photoHeading "When to go", "lussinpiccolo", "Lussinpiccolo, about 1900"
nbText: tr"""

Every main island has a Mediterranean climate: hot dry summers, mild wet winters. The highest
temperature of an average day, month by month, from the weather box of each island's main town
on Wikipedia; and the sea, where a page has it. The Mediterranean is a sea of seas, and the
islands are grouped by theirs: Wikidata puts each island in or beside a sea, a gulf or a strait,
and the gulfs and straits are taken to the sea they are part of. Ten seas and the Strait of
Sicily hold all but four of the 195 (the Îles d'Hyères and La Galite are in the open sea), the
Aegean alone 90 of them; Sicily is on three, and here goes with the first. These are averages of the past, and the past is
moving, as Giacomo Di Girolamo writes in *The Passenger*'s Sicily:

> Una volta, dire Sicilia significava dire Mediterraneo. […] Adesso, dire Sicilia significa
> quasi dire Tropici.

*Once, to say Sicily was to say the Mediterranean. […] Now, to say Sicily is almost to say the
Tropics.*
"""

const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

nbShowCode:
  let clim = story("climate.csv")
  let ms = toSeq(1 .. 12).mapIt(&"m{it:02}")
  let highs = clim.keep(proc (i: int): bool = clim["measure", i] == "high_c")
  var d = highs.withColumn("sea", proc (i: int): Value =
    let s = toSeq(0 ..< clim.nrows).filterIt(clim["title", it] == highs["title", i] and clim["measure", it] == "sea_c")
    if s.len == 0: toValue(nil) else: clim["m08", s[0]])
  d = d.withColumn("rank", proc (i: int): Value = main["rank", mainRow($highs["title", i])])
  d = d.withColumn("waters", proc (i: int): Value =   # the first of an island's seas
    toValue(tr(($main["seas", mainRow($highs["title", i])]).split("; ")[0].replace(" Sea", "").replace("Sea of ", ""))))
  let t = tabella(d, rownameCol = "island", groupnameCol = "waters", locale = lang):
    optCssTheme()
    colsHide ["title", "measure", "rank"]
    rowOrder "rank"
    rowGroupOrder ["Balearic", "Ligurian", "Tyrrhenian", "Strait of Sicily", "Adriatic", "Ionian",
                   "Aegean", "Levantine"].mapIt(tr(it))
    fmtNumber ms, decimals = 0
    fmtNumber "sea", decimals = 0
    dataColor ms, palette = palette("rdbu"),
      domain = (5.0, 38.0)
    colsLabel toSeq(0 ..< 12).mapIt((ms[it], tr(monthNames[it])))
    colsLabelRotate ms, dir = "slanted"
    subMissing "sea", missingText = ""
    colsLabel:
      sea: tr"sea in Aug"
    colsUnits:
      sea: "degC"
    tabSpanner tr"high of an average day, {{degC}}", ms
    tabOptions(tableFontSize = "11.5px", dataRowPadding = "3px", dataRowPaddingHorizontal = "2px",
               columnLabelsPaddingHorizontal = "2px")
    tabSourceNote tr"Wikipedia, the weather box of each island's main town (Krk: Rijeka; Cres: Mali Lošinj; Brač: Split; Pag: Zadar; Korčula: Dubrovnik; Andros: Ermoupoli, on Syros; Icaria: Samos; Cyprus: Nicosia, inland); the sea from tables beside them."
  nbTable t

nbNote(tr"""
The islands are grouped by their sea (`groupnameCol`), from west to east with `rowGroupOrder`,
and in each sea by size. Twelve narrow columns: `colsLabelRotate(dir = "slanted")` (new in tabelline 0.2, and not in gt or Great Tables) turns their
labels at 45 degrees, so the months keep their names and the columns stay as narrow as their
numbers. `dataColor` colours each cell on a scale from cool blue to hot red
over 5–38 °C, with the palette `rdbu`. `colsUnits` puts the unit after the sea's label; in the
spanner it is written inside the label, `{{degC}}`.
""", nkCode)

nbText: tr"""
Nicosia, inland, reaches 37 °C in August. The coolest in winter are the islands of the north:
Krk and Cres at the top of the Adriatic, when the [bora](https://en.wikipedia.org/wiki/Bora_(wind))
comes down from the mountains, Gökçeada and Thasos at the top of the Aegean, and Elba. The sea is warmest in August, 26 to 28 °C in the south, and in the Aegean the
[meltemi](https://en.wikipedia.org/wiki/Meltemi) blows all summer. The winds are a sea of their
own, as Nick Hunt[^hunt] writes in *Mediterraneo*, The Passenger's book on this sea (Iperborea, 2023,
in Tommaso Stella's Italian):

> Al di sopra del Mediterraneo esiste un altro mare: un turbolento e palpitante oceano gassoso
> anziché liquido.

*Above the Mediterranean there is another sea: a turbulent, throbbing ocean of air instead of
water.*

"""
photoHeading "Something to see, a beach, a taste", "rabbit-beach", "Rabbit Beach, Lampedusa"
nbText: tr"""

To end, one thing to see, a beach and a taste for each main island: a starting point, chosen
by Claude, the AI that wrote this story, from what Wikipedia says of each island, each with its
page on Wikipedia. Predrag Matvejević, whose *Mediterranean Breviary*
(1987) is a tour of the sea's shores, ports and islands, wrote later a whole book on bread,
*Pane nostro* (2010). A taste is a good way in.
"""

nbShowCode:
  let hl = story("highlights.csv")
  proc wiki(text, page: Value): Value =
    if text.isNull or ($text).len == 0: toValue(nil)
    else:
      let slug = ($page).multiReplace((" ", "_"), ("(", "%28"), (")", "%29"))
      toValue("[" & tr($text) & "](https://en.wikipedia.org/wiki/" & slug & ")")
  var d = hl.withColumn("island", proc (i: int): Value = main["island", mainRow($hl["title", i])])
  d = d.withColumn("see", proc (i: int): Value = wiki(hl["see", i], hl["see_page", i]))
  d = d.withColumn("beach", proc (i: int): Value = wiki(hl["beach", i], hl["beach_page", i]))
  d = d.withColumn("taste", proc (i: int): Value = wiki(hl["taste", i], hl["taste_page", i]))
  let t = tabella(d, rownameCol = "island"):
    optCssTheme()
    colsHide ["title", "see_page", "beach_page", "taste_page"]
    fmtMarkdown ["see", "beach", "taste"]
    subMissing ["taste"], missingText = ""
    colsLabel:
      see: html(iconSvg("landmark", height = "1em") & " " & tr"see")
      beach: html(iconSvg("umbrella-beach", height = "1em") & " " & tr"swim")
      taste: html(iconSvg("utensils", height = "1em") & " " & tr"taste")
    tabStyle style.text(size = "13px"), loc.body()
    tabSourceNote tr"Chosen by Claude, the AI that wrote this story; links to Wikipedia."
  nbTable t

nbNote(tr"""
The links are Markdown, `[Knossos](https://...)`, shown by `fmtMarkdown`; the icons in the
labels are Font Awesome's, as SVG, from `iconSvg`, inside `html()` so the label keeps them.
""", nkCode)

# ------------------------------------------------------------------------------------ how

nbPart 4, "", prPrimary   # the closing sections: readings, how it is built
photoHeading "To read more", "al-idrisi", "Al-Idrisi's map, south at the top"
nbText: tr"""

Every book this story quotes or names, in the order it first meets them: the number is the one
beside that first mention, and ↩ goes back to it.
"""
nbSources readings

nbText: tr"""
## How this story is built

From zero, in four layers. How the data was gathered, cleaned and checked is a story of its
own: [The islands' data, made with nanuq](../isole-data/).

**1. The sources** are open: Wikipedia's [*List of islands in the Mediterranean*](https://en.wikipedia.org/wiki/List_of_islands_in_the_Mediterranean) (the 195 islands,
their area, population and main town), Wikidata (each island's place and highest point, World
Heritage sites, airports and their passengers), the outlines of OpenStreetMap (© OpenStreetMap contributors, ODbL),
the weather boxes of the islands' towns, and two Wikipedia lists of Eurostat's regional figures
(Eurostat's own site could not be read where this was made).

**2. The tables of the data** are made in three steps, in `docs/stories/data/isole/src/`:
`fetch.nim` downloads, `extract.nim` (standard library) finds each island's outline and what is
on it and reads the wikitext, and `process.nim`, written with
[nanuq](https://github.com/pietroppeter/nanuq) (Polars for Nim), joins, cleans and counts
them into the CSV files this page reads. Three small tables are written by Claude, not gathered: the regions,
the history and the highlights.

**3. The shapes** are OpenStreetMap's land polygons, which follow the coast to a few metres: for each island, the polygon
that holds its point on Wikidata, in kilometres from its middle, simplified to at most 120
points with the [Douglas–Peucker algorithm](https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm):
it joins the two ends of a coastline with a straight line, keeps the point farthest from it, and
does the same again on each side, until no point left out is farther than a set distance, so
the capes and bays that give an island its shape stay and the small wiggles go. It was written
for this story, with the standard library, in `extract.nim` (`douglasPeucker` and `simplify`;
[the data story](../isole-data/#outlines) shows the whole file). The outlines are numbers in two columns, `x`
and `y`, and a record of the two is a cell of a shape nanoplot.

**4. The tables on this page** are tabelline 0.2, with `nbShowCode` running a cell of Nim and
showing the table it makes, its code folded under it. What 0.2 brought that they use:
"""

nbShowCode:
  var used = tableData:
    feature: ["shape nanoplots, `referenceX`, slanted labels (new)", "box, line and bar nanoplots, `colsNanoplot`",
              "units in labels, `colsUnits`", "`fmtCountry`, `fmtFraction`, `fmtNumberSi`",
              "every locale of CLDR", "`colsLabelRotate`",
              "`summaryRows`, `grandSummaryRows`, `summaryColumns`",
              "`colsMergeRange`, `colsMergeUncert`, `colsMerge`", "`rowGroupAsColumn`, `tabStubIndent`",
              "`tabellaPreview`, `extractCells`", "`tabStyle` with a proc, `tabStyleBody`",
              "lists and records in a cell", "`fmtIcon`, `iconSvg`"]
    where: ["every outline, getting there, when to go", "sizes by country, unemployment, passengers, GDP",
            "most tables", "thirty-five islands, the same scale, getting there",
            "how they live now", "when to go",
            "thirty-five islands, the same scale, all 195, twenty years of work",
            "who ruled them, twenty years of work, all 195", "the same scale, World Heritage",
            "all 195, twenty years of work", "how they live now, twenty years of work",
            "the outlines, who ruled them", "World Heritage, something to see"]
  for c in ["feature", "where"]:
    used = used.withColumn(c, proc (i: int): Value = toValue(tr($used[c, i])))
  let t = tabella(used, rownameCol = "feature"):
    optCssTheme()
    fmtMarkdown everything()
    colsLabel:
      where: tr"where"
    tabStyle style.text(size = "12.5px"), loc.body()
  nbTable t

nbText: tr"""
**5. The look and the photos.** The page opens in its own look, the Minoan one, after the frescoes
of Crete and Thera and the vases of Athens (the switch at the top goes back to Munari). It was
chosen in rounds, from eighteen sources, in the devlog post
[Designing a Mediterranean look](../../devlog/mediterranean/). The photos over the headings were
picked from the gallery [Photos of the Mediterranean, by the story](../isole-photos/), which
says for each where it is from, who made it, its licence and why it could go there; the page
holds a copy of each pick, made smaller, with its credit under it.

**6. Two languages.** This page and the Italian one are the same file, `isole.nim`: the Italian
page, `isole_it.nim`, includes it with `lang = "it"`. Every text a reader sees goes through `tr`,
which leaves it as it is in English and looks it up in `data/isole/italiano.txt` in Italian (the
English text, then its Italian); when a translation is missing, the Italian page does not build.
The islands' Italian names come from Wikidata, the numbers follow `locale = lang` in every
table, and EN · IT at the top goes to the other language, remembered; a first visit opens the
browser's language.
"""

when lang == "it":   # every text needs its Italian: the ones missing are listed for translation
  if missing.len > 0:
    writeFile(data / "italiano-missing.txt", missing.mapIt("en:\n" & it.strip & "\nit:\n").join("\n"))
  else: removeFile(data / "italiano-missing.txt")
  doAssert missing.len == 0, $missing.len & " texts have no Italian: see data/isole/italiano-missing.txt"

nbSave

when lang == "it":   # after the page is written, when the tables have used their texts too
  let unused = toSeq(italian.keys).filterIt(it notin used)
  doAssert unused.len == 0, $unused.len & " texts of italiano.txt are no longer on the page: " & $unused
