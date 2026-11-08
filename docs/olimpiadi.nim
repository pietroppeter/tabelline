## The data of the story "Milano Cortina 2026, in small numbers" (docs/stories/milano_cortina.nim).
##
## Two kinds of data:
## - tables from Wikipedia, in docs/stories/data/milano-cortina/*.tsv, written by fetch.py
##   beside them (CC BY-SA 4.0; each file names the article and revision it was read from);
## - facts reported by Il Post (https://www.ilpost.it), written here by hand, each with the
##   article it comes from. Only the numbers and the facts are taken, never the text.
import std/[os, strutils, sequtils, algorithm]
import tabelline

const dataDir* = currentSourcePath().parentDir / "stories" / "data" / "milano-cortina"

proc readTsv*(name: string): TableData =
  ## A TSV of dataDir, without its comment lines (the ones starting with `#`).
  var lines: seq[string]
  for line in readFile(dataDir / name).splitLines:
    if not line.startsWith("#"): lines.add line
  parseCsv(lines.join("\n"), sep = '\t')

proc pick*(d: TableData, rows: openArray[int]): TableData =
  ## The rows `rows` of `d`, in that order.
  result = TableData()
  for name in d.names:
    var vs: seq[Value]
    for i in rows: vs.add d[name, i]
    result.addColumn(name, vs)

proc top*(d: TableData, n: int, by: openArray[string]): TableData =
  ## The `n` rows with the highest values of `by` (the first decides, the next break ties).
  var ix = toSeq(0 ..< d.nrows)
  let names = @by
  ix.sort(proc (a, b: int): int =
    for c in names:
      let r = cmp(d[c, b].toFloat, d[c, a].toFloat)
      if r != 0: return r
    cmp(a, b))
  d.pick(ix[0 ..< min(n, ix.len)])

proc keep*(d: TableData, cond: proc (i: int): bool): TableData =
  ## The rows of `d` for which `cond(index)` holds.
  d.pick(toSeq(0 ..< d.nrows).filterIt(cond(it)))

const ilpost* = "https://www.ilpost.it/"

func post*(path: string): string = ilpost & path
  ## An Il Post article from its path, "2026/02/24/...".

# ------------------------------------------------------------------------------------ the articles

type Article* = object
  date*, title*, path*, angle*: string

const articles* = [
  Article(date: "2025-03-07", title: "Il futuro delle Olimpiadi invernali è farle “diffuse”?",
          path: "2025/03/07/olimpiadi-invernali-diffuse-2026-piu-luoghi-sostenibilita/",
          angle: "why the Games were spread over eight places, and what environmental groups say about it"),
  Article(date: "2025-10-17", title: "Quanto costa vedere dal vivo le Olimpiadi di Milano Cortina?",
          path: "2025/10/17/prezzi-biglietti-alloggi-olimpiadi-milano-cortina/",
          angle: "tickets and rooms, the two costs of watching a race"),
  Article(date: "2025-10-29", title: "Le Olimpiadi di Milano Cortina Bormio Livigno Tesero Predazzo Anterselva Verona",
          path: "2025/10/29/olimpiadi-milano-cortina-bormio-livigno-tesero-predazzo-anterselva-verona/",
          angle: "a tour of the places, sport by sport, and the distances between them"),
  Article(date: "2025-10-30", title: "Che fine fanno gli impianti olimpici",
          path: "2025/10/30/impianti-strutture-olimpiadi-che-fine-fanno/",
          angle: "what happened to almost a thousand Olympic venues since 1896"),
  Article(date: "2026-01-22", title: "A Cortina ci sono più cantieri che neve",
          path: "2026/01/22/a-cortina-ci-sono-piu-cantieri-che-neve/",
          angle: "two weeks before the Games, the town still under construction"),
  Article(date: "2026-02-02", title: "Come le Olimpiadi invernali sono arrivate a Milano e a Cortina",
          path: "2026/02/02/olimpiadi-invernali-milano-cortina-come-ci-siamo-arrivati/",
          angle: "six and a half years, from the vote in Lausanne to the opening"),
  Article(date: "2026-02-06", title: "Dove si vedono le Olimpiadi invernali di Milano Cortina",
          path: "2026/02/06/dove-e-come-vedere-olimpiadi-invernali-milano-cortina-tv-streaming/",
          angle: "free channels, paid platforms and what each one shows"),
  Article(date: "2026-02-17", title: "Come mai tutte queste medaglie?",
          path: "2026/02/17/medaglie-italia-record-perche/",
          angle: "more events, home advantage, a long plan, or luck"),
  Article(date: "2026-02-23", title: "Ogni paese conta le medaglie un po’ come vuole",
          path: "2026/02/23/criteri-classifica-olimpiadi-medaglie/",
          angle: "golds first or total first, and the tables nobody makes"),
  Article(date: "2026-02-23", title: "Quanto si guadagna vincendo una medaglia alle Olimpiadi",
          path: "2026/02/23/quandi-soldi-medaglie-olimpiadi-premio-guadagno/",
          angle: "what each country pays for a medal, and what the medal itself is worth"),
  Article(date: "2026-02-24", title: "Le Olimpiadi di Milano Cortina hanno nascosto bene i problemi",
          path: "2026/02/24/milano-cortina-2026-olimpiadi-invernali-bilancio-insostenibilita-problemi/",
          angle: "a first balance: the Games liked, the problems still there"),
  Article(date: "2026-02-25", title: "Cosa rimarrà a Milano delle Olimpiadi invernali",
          path: "2026/02/25/milano-olimpiadi-eredita-cosa-rimane/",
          angle: "what each building in Milan becomes"),
  Article(date: "2026-03-10", title: "Come la Cina è diventata così forte alle Paralimpiadi invernali",
          path: "2026/03/10/cina-paralimpiadi-ori-medagliere-forte/",
          angle: "from no medal in 2014 to first in the table"),
  Article(date: "2026-05-05", title: "La Corte dei conti sta indagando su possibili irregolarità nella costruzione dell’Arena Santa Giulia di Milano",
          path: "2026/05/05/corte-conti-indagine-arena-santa-giulia-milano/",
          angle: "who pays the extra costs of the hockey arena"),
  Article(date: "2026-10-08", title: "Per tenere aperta la pista da bob di Cortina servono 800mila euro all’anno",
          path: "2026/10/08/spese-pista-bob-cortina/",
          angle: "the sliding track's yearly accounts, line by line"),
]

# ------------------------------------------------------------------------------------- the Games

type SportFacts* = object
  sport*, kind*, new*: string   ## kind: on snow, on ice, or sliding; new: the events added in 2026

const sportFacts* = [
  ## From Wikipedia's 2026 Winter Olympics § Sports: 116 events in 16 sports, seven more than
  ## Beijing 2022. Eleven are new, four were dropped (alpine combined, the mixed team parallel,
  ## luge's open doubles).
  SportFacts(sport: "Alpine skiing", kind: "snow", new: "team combined, men and women"),
  SportFacts(sport: "Biathlon", kind: "snow"),
  SportFacts(sport: "Cross-country skiing", kind: "snow"),
  SportFacts(sport: "Freestyle skiing", kind: "snow", new: "dual moguls, men and women"),
  SportFacts(sport: "Nordic combined", kind: "snow"),
  SportFacts(sport: "Ski jumping", kind: "snow", new: "women's large hill"),
  SportFacts(sport: "Ski mountaineering", kind: "snow", new: "the whole sport: two sprints and a mixed relay"),
  SportFacts(sport: "Snowboarding", kind: "snow"),
  SportFacts(sport: "Curling", kind: "ice"),
  SportFacts(sport: "Figure skating", kind: "ice"),
  SportFacts(sport: "Ice hockey", kind: "ice"),
  SportFacts(sport: "Short-track speed skating", kind: "ice"),
  SportFacts(sport: "Speed skating", kind: "ice"),
  SportFacts(sport: "Bobsleigh", kind: "sliding"),
  SportFacts(sport: "Luge", kind: "sliding", new: "doubles for men and for women, instead of open doubles"),
  SportFacts(sport: "Skeleton", kind: "sliding", new: "mixed team"),
]

const kindLabels* = {"snow": "❄️ on snow", "ice": "⛸️ on ice", "sliding": "🛷 sliding"}
  ## The three kinds of sport, each with its emoji: the labels of the row groups.

proc kindMark*(kind: string): string =
  ## The emoji of a kind of sport.
  for (k, label) in kindLabels:
    if k == kind: return label.split(' ')[0]

proc sportMarks*(): seq[(string, string)] =
  ## Each sport with the emoji of its kind in front, for `textCaseMatch(replace = "partial")`.
  for f in sportFacts: result.add (f.sport, kindMark(f.kind) & " " & f.sport)
  result.add ("Short track speed skating", kindMark("ice") & " Short track speed skating")  # the venues' spelling

type Trip* = object
  ## A trip between two places of the Games, in hours (lowest and highest).
  trip*, by*: string
  low*, high*: float

const trips* = [
  Trip(trip: "Bormio → Cortina", by: "car", low: 5, high: 6),
  Trip(trip: "Bormio → Cortina", by: "public transport", low: 10, high: 11),
  Trip(trip: "Milan → Bormio", by: "train and bus", low: 3, high: 3),
  Trip(trip: "Bormio → Livigno", by: "road, in winter", low: 1, high: 1),
  Trip(trip: "Santa Giulia → Rho (two hockey arenas)", by: "public transport", low: 1, high: 1),
]
const tripsSource* = "2025/03/07/olimpiadi-invernali-diffuse-2026-piu-luoghi-sostenibilita/"
const tripsSource2* = "2025/10/29/olimpiadi-milano-cortina-bormio-livigno-tesero-predazzo-anterselva-verona/"

type Edition* = object
  ## The Winter Games, then and now. 0 is a number Il Post does not give.
  year*: int
  host*: string
  athletes*, countries*, events*: int

const editions* = [
  Edition(year: 1924, host: "Chamonix", athletes: 258, countries: 16, events: 0),
  Edition(year: 1994, host: "Lillehammer", athletes: 1700, countries: 67, events: 61),
  Edition(year: 2006, host: "Turin", athletes: 2500, countries: 80, events: 84),
  Edition(year: 2022, host: "Beijing", athletes: 3000, countries: 90, events: 109),
  Edition(year: 2026, host: "Milano Cortina", athletes: 2884, countries: 92, events: 116),
]
  ## 1924 to 2022 from Il Post, rounded as it gives them ("about 1,700", "over 90"); 2026 from
  ## Wikipedia's article on the Games.
const editionsSources* = ["2026/01/09/olimpiadi-invernali-storia-sviluppo/", "2026/02/17/medaglie-italia-record-perche/"]

type Channel* = object
  ## Where to watch, in Italy.
  channel*, how*: string
  free*, allEvents*: bool

const channels* = [
  Channel(channel: "Rai 2, Rai Sport, RaiPlay", how: "free to air and streaming", free: true, allEvents: false),
  Channel(channel: "Eurosport (six channels)", how: "with Discovery+, DAZN, TimVision or HBO Max", free: false, allEvents: true),
  Channel(channel: "Sky, Now", how: "no races, four talk shows a day", free: false, allEvents: false),
]
const channelsSource* = "2026/02/06/dove-e-come-vedere-olimpiadi-invernali-milano-cortina-tv-streaming/"

# ------------------------------------------------------------------------------------- the money

type Price* = object
  what*: string
  euro*: float
const prices* = [
  Price(what: "The cheapest ticket", euro: 30),
  Price(what: "Women's downhill at Cortina, hospitality", euro: 375),
  Price(what: "The same, with a night in a hotel", euro: 795),
  Price(what: "Figure skating gala", euro: 1200),
  Price(what: "Men's ice hockey final", euro: 1400),
  Price(what: "Opening or closing ceremony, the dearest seat", euro: 2900),
]
const pricesSource* = "2025/10/17/prezzi-biglietti-alloggi-olimpiadi-milano-cortina/"

type Share* = object
  what*: string
  share*: float
const ticketShares* = [
  Share(what: "Tickets sold, of those on sale (1.3 million)", share: 0.88),
  Share(what: "Tickets under €100", share: 0.57),
  Share(what: "Tickets between €30 and €40", share: 0.20),
  Share(what: "Spectators from abroad", share: 0.63),
]
const sharesSource* = "2026/02/24/milano-cortina-2026-olimpiadi-invernali-bilancio-insostenibilita-problemi/"

type Prize* = object
  ## What a country pays its athletes for a medal (Il Post, from the national committees).
  country*, code*, currency*: string
  gold*, silver*, bronze*: float
const prizes* = [
  Prize(country: "Singapore", code: "SG", currency: "USD", gold: 740_000, silver: 370_000, bronze: 185_000),
  Prize(country: "Hong Kong", code: "HK", currency: "USD", gold: 715_000, silver: 357_000, bronze: 178_000),
  Prize(country: "Poland", code: "PL", currency: "EUR", gold: 300_000, silver: 150_000, bronze: 100_000),
  Prize(country: "Italy", code: "IT", currency: "EUR", gold: 180_000, silver: 90_000, bronze: 60_000),
  Prize(country: "Spain", code: "ES", currency: "EUR", gold: 94_000, silver: 48_000, bronze: 30_000),
  Prize(country: "France", code: "FR", currency: "EUR", gold: 80_000, silver: 40_000, bronze: 20_000),
  Prize(country: "United States", code: "US", currency: "USD", gold: 37_500, silver: 22_500, bronze: 15_000),
  Prize(country: "Germany", code: "DE", currency: "EUR", gold: 20_000, silver: 15_000, bronze: 10_000),
  Prize(country: "Norway", code: "NO", currency: "EUR", gold: 0, silver: 0, bronze: 0),
  Prize(country: "Great Britain", code: "GB", currency: "EUR", gold: 0, silver: 0, bronze: 0),
]
const prizesSource* = "2026/02/23/quandi-soldi-medaglie-olimpiadi-premio-guadagno/"

type MedalMetal* = object
  ## What a medal is made of, and what its metal is worth (0 when the article gives no figure).
  medal*: string
  grams*, goldGrams*, euro*: float
const metals* = [
  MedalMetal(medal: "gold", grams: 506, goldGrams: 6, euro: 2000),
  MedalMetal(medal: "silver", grams: 0, goldGrams: 0, euro: 1200),
  MedalMetal(medal: "bronze", grams: 420, goldGrams: 0, euro: 0),
]
  ## The gold medal is silver with 6 g of gold on it; the bronze, copper, is worth "a few euros".

type Estimate* = object
  ## A work of the Games, from its first estimate to the last figure, in millions of euros
  ## (`last` is 0 when only the growth is known, in `times`).
  work*, place*, fate*: string
  first*, last*, times*: float
const estimates* = [
  Estimate(work: "Ski jumps, rebuilt", place: "Predazzo", fate: "built", first: 8.7, last: 0, times: 5),
  Estimate(work: "Palasharp arena", place: "Milan", fate: "dropped", first: 13, last: 46, times: 46 / 13),
  Estimate(work: "Skating oval, roofed", place: "Baselga di Piné", fate: "dropped", first: 50, last: 75, times: 75 / 50),
  Estimate(work: "Sliding track", place: "Cortina", fate: "built", first: 60, last: 118, times: 118 / 60),
]
  ## Predazzo: Il Post (after the TV programme Report) says the cost went up five times.
const estimatesSources* = ["2025/03/07/olimpiadi-invernali-diffuse-2026-piu-luoghi-sostenibilita/",
                           "2026/02/02/olimpiadi-invernali-milano-cortina-come-ci-siamo-arrivati/",
                           "2026/10/08/spese-pista-bob-cortina/"]

type Step* = object
  ## The sliding track's cost, step by step, in millions of euros.
  date*, what*, path*: string
  millions*: float
const trackSteps* = [
  Step(date: "2021-12-30", what: "The Veneto region's feasibility project", millions: 60.75,
       path: "https://it.wikipedia.org/wiki/XXV_Giochi_olimpici_invernali"),
  Step(date: "2023-09-21", what: "The tender's figure; nobody wants to build it", millions: 81,
       path: post("2023/09/21/nessuno-costruire-pista-bob-cortina-olimpiadi/")),
  Step(date: "2024-02-02", what: "A builder, for fewer stands and no car park", millions: 81.6,
       path: post("2024/02/02/accordo-pista-bob-cortina/")),
  Step(date: "2026-01-22", what: "The track, finished, as the Games begin", millions: 118,
       path: post("2026/01/22/a-cortina-ci-sono-piu-cantieri-che-neve/")),
]

type Line* = object
  ## One line of the sliding track's yearly accounts for 2027 (KPMG for the Veneto region).
  side*, item*: string
  euro*: float
const trackYear* = [
  Line(side: "In", item: "Training runs (€35 to €60 a run)", euro: 292_000),
  Line(side: "In", item: "Sponsors and the Italian winter sports federation", euro: 115_000),
  Line(side: "In", item: "“Taxi bob” rides for tourists", euro: 106_000),
  Line(side: "In", item: "Two official races", euro: 14_000),
  Line(side: "Out", item: "Electricity, mostly to keep the ice", euro: 490_000),
  Line(side: "Out", item: "Ice crew: a foreman and ten people, five months", euro: 368_000),
  Line(side: "Out", item: "Ambulances, insurance, advertising", euro: 200_000),
  Line(side: "Out", item: "Maintenance and the unexpected", euro: 149_000),
  Line(side: "Out", item: "Office staff", euro: 126_000),
]
  ## Il Post gives the totals too: €527,000 in, €1.33 million out, €805,000 lost in 2027.

type Claim* = object
  who*, says*: string
  millions*: float
const santaGiulia* = [
  Claim(who: "Planned cost of the arena", says: "before the works", millions: 177),
  Claim(who: "CTS Eventim, the owner", says: "extra costs, from materials, energy and haste", millions: 134),
  Claim(who: "The city of Milan", says: "extra costs", millions: 53),
  Claim(who: "The state, so far", says: "21 direct, about 30 in services over the years", millions: 51),
]
const santaGiuliaSource* = "2026/05/05/corte-conti-indagine-arena-santa-giulia-milano/"

# ------------------------------------------------------------------------------------- what stays

type Amount* = object
  what*: string
  value*: float
  unit*, note*: string
const snow* = [
  Amount(what: "Artificial snow made for the Games", value: 1.6e6, unit: "m³", note: "as much as 640 Olympic pools"),
  Amount(what: "Water for the snow at Cortina alone", value: 1.2e6, unit: "m³", note: "before the Games"),
]
const snowSources* = ["2026/02/24/milano-cortina-2026-olimpiadi-invernali-bilancio-insostenibilita-problemi/",
                      "2026/01/22/a-cortina-ci-sono-piu-cantieri-che-neve/"]

type Footprint* = object
  part*, what*: string
  tonnes*, snowKm2*, iceMt*: float   ## tonnes of CO2 equivalent; future loss of snow cover (km²) and glacier ice (Mt)

const footprint* = [
  ## Scientists for Global Responsibility and New Weather Institute, "Olympics Torched", January 2026,
  ## as summarised by its authors: estimates from the organisers' official data, plus the emissions
  ## that three sponsorship deals induce. Spectator travel and Eni are parts of the rows above them;
  ## NaN where the summary gives no figure (a missing value, shown blank).
  Footprint(part: "The Games", what: "all of it", tonnes: 930_000, snowKm2: 2.3, iceMt: 14),
  Footprint(part: "The Games", what: "spectators' travel", tonnes: 410_000, snowKm2: NaN, iceMt: NaN),
  Footprint(part: "Sponsors", what: "Eni, Stellantis, ITA", tonnes: 1_300_000, snowKm2: 3.2, iceMt: 20),
  Footprint(part: "Sponsors", what: "Eni alone", tonnes: 700_000, snowKm2: 1.7, iceMt: 11),
]
const footprintSource* = "https://www.sgr.org.uk/resources/hidden-carbon-footprint-winter-olympics"
const footprintReport* = "https://www.sgr.org.uk/publications/olympics-torched"

type Afterwards* = object
  venue*, built*, becomes*: string
const afterwards* = [
  Afterwards(venue: "Speed skating hall, Rho", built: "temporary", becomes: "an arena for events and concerts"),
  Afterwards(venue: "Ice hockey rink, Rho", built: "temporary", becomes: "moved to another hall of the fair, open again in the autumn"),
  Afterwards(venue: "Arena Santa Giulia, Milan", built: "new", becomes: "concerts, volleyball, basketball, tennis"),
  Afterwards(venue: "Olympic village, Porta Romana", built: "new", becomes: "student housing; 450 beds at €592 a month"),
  Afterwards(venue: "Trampolino Italia, Cortina", built: "restored", becomes: "a monument at the entrance of the valley; no jumping"),
  Afterwards(venue: "Sliding track, Cortina", built: "rebuilt", becomes: "training and tourist rides, at a loss of €800,000 a year"),
]
const afterwardsSources* = ["2026/02/25/milano-olimpiadi-eredita-cosa-rimane/",
                            "2026/01/22/a-cortina-ci-sono-piu-cantieri-che-neve/",
                            "2026/10/08/spese-pista-bob-cortina/"]

type VenueFate* = object
  fate*: string
  venues*: int
const ioc* = [
  VenueFate(fate: "Temporary", venues: 115),
  VenueFate(fate: "Permanent, still in use", venues: 743),
  VenueFate(fate: "Permanent, gone (demolished or replaced)", venues: 94),
  VenueFate(fate: "Permanent, abandoned", venues: 30),
]
  ## The IOC's study of 982 venues of 53 Games, 1896 to 2022, as reported by Il Post.
const iocSource* = "2025/10/30/impianti-strutture-olimpiadi-che-fine-fanno/"

type Event* = object
  date*, what*, path*: string
const after* = [
  Event(date: "2026-02-22", what: "The Games close in the Arena of Verona", path: "2026/02/22/cerimonia-chiusura-olimpiadi-2026-ospiti-durata/"),
  Event(date: "2026-03-15", what: "The Paralympics close: Italy 16 medals, 7 gold, both records", path: "2026/03/15/italia-medaglie-paralimpiadi-ultimo-giorno-milano-cortina/"),
  Event(date: "2026-05-05", what: "The Court of Auditors looks into the Santa Giulia arena", path: "2026/05/05/corte-conti-indagine-arena-santa-giulia-milano/"),
  Event(date: "2026-05-08", what: "…and into the sliding track of Cortina", path: "2026/05/08/corte-dei-conti-veneto-indagine-pista-da-bob-cortina-d-ampezzo/"),
  Event(date: "2026-07-08", what: "Nordic combined will not be at the next Winter Games", path: "2026/07/08/la-combinata-nordica-non-sara-piu-alle-olimpiadi-invernali/"),
  Event(date: "2026-10-08", what: "KPMG: the sliding track loses €800,000 a year", path: "2026/10/08/spese-pista-bob-cortina/"),
  Event(date: "2026-12-08", what: "The Socrepes cable car is due to open, at half the planned capacity", path: "2026/10/08/spese-pista-bob-cortina/"),
]
