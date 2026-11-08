## devlog: 08 Nov 2026 A | Milano Cortina 2026, in small numbers | The Winter Olympics and Paralympics of 2026 told in tables made with tabelline 0.1, in three parts of three: the Games, the money, what stays. Learning from Il Post's coverage, with data from Wikipedia and Il Post.
## A dated post: it tells the Games as known on 8 November 2026, and is not updated afterwards.
## The data is in docs/olimpiadi.nim (facts from Il Post, by hand) and docs/devlog/data/milano-cortina/
## (tables from Wikipedia, written by fetch.py there).
import std/[os, strutils, strformat, sequtils, algorithm]
import nimib except md
import tabelline, tabelline/nimib
import ../blocchi, ../olimpiadi

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "milano-cortina" / "index.html"
nb.useTabelline(nome = "tabelline",
                title = "Milano Cortina 2026, in small numbers", homeHref = "../", backLabel = "Devlog", nameHref = "../../")

let bar = tinta("--secondary")               # bars in the page's secondary colour
const soft = @[haru.paper, haru.secondary]    # Haru's paper to its forget-me-not blue
const metal = @[haru.paper, haru.warning]     # paper to rapeseed yellow
let gilt = tinta("--warning")                 # Italy's row

proc link(path, label: string): string = &"[{label}]({post(path)})"

proc medal(s: string): string =
  ## "gold" as "🥇 Gold": the medal's emoji, then its name.
  let emoji = case s.toLowerAscii
    of "gold": "🥇"
    of "silver": "🥈"
    of "bronze": "🥉"
    else: ""
  (if emoji.len > 0: emoji & " " else: "") & s.capitalizeAscii

nbTitolo "8 November 2026", "Milano Cortina 2026, in small numbers", """
The Winter Olympics and Paralympics of 2026, told in tables: in three parts of three, from the
simplest fact to the bills that are still arriving.
"""

nbText: """
Between 6 February and 15 March 2026 Italy held the Winter Olympics and then the Paralympics,
in eight places from Milan to the Dolomites. Nine months later they can be told with numbers,
and the numbers fit in tables. This post tells them, and makes every table with
[tabelline](../../), whose 0.1 is about to be released: it is the *use it* post of 0.1 (see the
[roadmap](../../roadmap/)), the one that uses the library as a user would, on data from outside.

It learns from the coverage of [Il Post](https://www.ilpost.it/tag/milano-cortina-2026/), which
followed the Games for seven years, from the bid to the Court of Auditors. Il Post explains with
questions (*how did we get here?*, *why so many medals?*, *what is left?*), puts a number next
to another that gives it a size, and comes back to a story when there is news. This post asks
its questions the same way, takes the numbers Il Post reported (each table links the article),
and the rest from Wikipedia (and the air from NOAA). The words are this post's own.
"""

nbIndice()

nbText: """
## One row to start

The least one can say about the Games fits in one row: which ones, where, when, how big.
"""

nbShowCode:
  let games = tableData:
    edition: [25]
    opening: ["2026-02-06"]
    closing: ["2026-02-22"]
    events: [116]
    athletes: [2884]
    nations: [92]
  let t = tabella(games, rownameCol = "edition"):
    optTokens()
    tabHeader "Milano Cortina 2026", "the Olympic Winter Games"
    fmtRoman "edition"
    fmtDate ["opening", "closing"], dateStyle = "d MMM"
    fmtInteger ["athletes"]
    colsLabel {"opening": "from", "closing": "to"}
    tabOptions(tableFontSize = "14px")
    tabSourceNote md("From Wikipedia's [2026 Winter Olympics](https://en.wikipedia.org/wiki/2026_Winter_Olympics); 92 teams counting the neutral athletes.")
  nbTable t

nbText: """
They were the 25th Winter Games, and the roman numeral is how the Games count themselves:
`fmtRoman` turns 25 into XXV. The dates are
ISO dates in the data, `"2026-02-06"`, and `fmtDate` shows them as a reader wants them. Everything
else in this post adds one idea at a time to a table like this one.

## Three parts of three

What happened is too much for one table, so the post splits it in three, and every part in three
again: three questions each, nine tables to answer them, simplest first.
"""

nbShowCode:
  type PartRow = object
    n: int
    part, questions: string
  let rows = @[
    PartRow(n: 1, part: "🏅 The Games", questions: "Where were they? Who won? How was Italy?"),
    PartRow(n: 2, part: "💶 The money", questions: "What did a seat cost? What is a medal worth? What did the works cost?"),
    PartRow(n: 3, part: "🏔️ What stays", questions: "Snow, buildings, and what came after"),
  ]
  let t = tabella(rows, rownameCol = "n"):
    optTokens()
    fmtIndex "n"
    colsLabel {"part": "part", "questions": "three questions"}
    tabStyle style.text(weight = "bold"), loc.body(cols("part"))
  nbTable t

nbText: """
`fmtIndex` writes 1, 2, 3 as A, B, C, so the parts below are A, B and C.

## A · The Games

### Where were they?

"The most spread out ever": over 22,000 km², in Milan, Cortina d'Ampezzo, Bormio, Livigno,
Anterselva, Tesero, Predazzo, and Verona for the closing. Milan had the ice, the mountains had the
snow. Each row of the table is a venue with its sports, grouped by cluster, as the organisers
called the four areas of the races (Verona, with the closing ceremony, is a fifth). The data has
one row per venue and sport, so the page joins them first; `textCaseMatch` rewrites the "before"
column and `textReplace` drops "Milano" from the venue names, after formatting.
"""

nbShowCode:
  let raw = readTsv("venues.tsv")
  type VenueRow = object
    cluster, venue, events: string
    capacity: int
    status: string
  var rows: seq[VenueRow]
  for i in 0 ..< raw.nrows:   # one row per venue: its sports joined
    let venue = $raw["venue", i]
    if rows.len > 0 and rows[^1].venue == venue: rows[^1].events.add ", " & $raw["events", i]
    else: rows.add VenueRow(cluster: $raw["cluster", i], venue: venue, events: $raw["events", i],
                            capacity: int(raw["capacity", i].toFloat), status: $raw["status", i])
  let t = tabella(rows, rownameCol = "venue", groupnameCol = "cluster"):
    optTokens()
    tabHeader "Fourteen venues, five clusters", "and what each was before the Games"
    colsLabel {"events": "for", "capacity": "seats", "status": "before"}
    fmtInteger "capacity"
    textCaseMatch {"Existing": "existing", "New": "<b>new</b>", "Existing with temporary stands": "existing, temporary stands"},
      locations = loc.body(cols("status"))
    textReplace "Milano ", "", loc.stub()
    rowGroupOrder ["Milan", "Valtellina", "Val di Fiemme", "Cortina d'Ampezzo", "Verona"]
    tabFootnote "Anterselva is in South Tyrol, but belongs to Cortina's cluster.",
      loc.stub(rows = where(it["venue"] == "Anterselva Biathlon Arena"))
    tabSourceNote md("Wikipedia, [2026 Winter Olympics § Venues](https://en.wikipedia.org/wiki/2026_Winter_Olympics#Venues).")
    tabOptions(tableFontSize = "14px")
  nbTable t

nbText: &"""
Two venues are new, the hockey arena of Santa Giulia in Milan and the sliding track of Cortina;
the others existed, some rebuilt so much that "existing" says little, as part B shows. The price of
spreading the Games is distance. Ester Ledecká, who won gold in skiing and in snowboarding in
2018, could not try again: the two races were on the same day, four hours apart by car
({link(tripsSource2, "Il Post")}).
"""

nbShowCode:
  let t = tabella(@trips, rownameCol = "trip"):
    optTokens()
    tabHeader "How far apart"
    colsLabel {"by": "by", "low": "from", "high": "to"}
    fmtDuration ["low", "high"], inputUnits = "hours"
    tabSourceNote md(&"Il Post, {link(tripsSource, \"7 March 2025\")} and {link(tripsSource2, \"29 October 2025\")}, after the organisers' tables and the Washington Post.")
  nbTable t

nbText: """
`fmtDuration` takes hours and writes them as a length of time, "10h", so it reads as a trip,
not as a number. Ten hours on buses and trains, from the men's downhill to the women's.

### Who won?

The medal table is the table everyone looks at, and the one the Olympic Charter says does not
exist: the Games are "competitions between athletes, not between countries". Here is its top ten
as Wikipedia gives it, in the three languages of tabelline's pages: Nim with tabelline, Python
with Great Tables, R with gt.
"""

nbTabs(python = &"""
import polars as pl
from great_tables import GT, loc, style

medals = pl.read_csv("docs/devlog/data/milano-cortina/medals.tsv",
                     separator="\t", comment_prefix="#").head(10)
(GT(medals, rowname_col="team")
    .tab_header("Medal table", "Milano Cortina 2026, top ten")
    .cols_hide("rank")
    .fmt_flag("code")
    .cols_label(code="", gold="🥇", silver="🥈", bronze="🥉")
    .tab_spanner("medals", columns=["gold", "silver", "bronze"])
    .data_color(["gold", "silver", "bronze"], palette=["{haru.paper}", "{haru.warning}"])
    .tab_style(style.text(weight="bold"), loc.body(columns="total")))
""", r = &"""
library(gt)

medals <- read.delim("docs/devlog/data/milano-cortina/medals.tsv", comment.char = "#")
gt(head(medals, 10), rowname_col = "team") |>
  tab_header("Medal table", "Milano Cortina 2026, top ten") |>
  cols_hide(rank) |>
  fmt_flag(code) |>
  cols_label(code = "", gold = "🥇", silver = "🥈", bronze = "🥉") |>
  tab_spanner("medals", columns = c(gold, silver, bronze)) |>
  data_color(c(gold, silver, bronze), palette = c("{haru.paper}", "{haru.warning}")) |>
  tab_style(cell_text(weight = "bold"), cells_body(columns = total))
"""):
  nbCode:
    let medals = readTsv("medals.tsv").top(10, ["gold", "silver", "bronze"])
    let t = tabella(medals, rownameCol = "team"):
      optTokens()
      tabHeader "Medal table", "Milano Cortina 2026, top ten"
      colsHide "rank"
      fmtFlag "code"
      colsLabel {"code": "", "gold": "🥇", "silver": "🥈", "bronze": "🥉"}
      tabSpanner "medals", ["gold", "silver", "bronze"]
      dataColor ["gold", "silver", "bronze"], palette = metal
      tabStyle style.text(weight = "bold"), loc.body(cols("total"))
      tabOptions(tableFontSize = "14px")
  nbTable t

nbText: """
`readTsv` and `top` are this post's own: the first drops the comment lines naming the Wikipedia
revision, then calls `parseCsv`; the second keeps the ten rows with most golds. Each country gets its flag from a two-letter code, `fmtFlag`, as an
emoji, so nothing is loaded. `dataColor` shades each medal column on its own, from the page's
paper to yellow (with tabelline 0.1 each column has its own range, as in gt).

But a table of medals can be read two ways, Il Post explains: golds first, as the IOC (and Il
Post, and China) do, or total first, as the United States do. At Milano Cortina Norway is first
either way; below it, the order changes. The same data, two `rowOrder` calls:
"""

nbShowCode:
  proc topTen(byTotal: bool): Tabella =
    let by = if byTotal: @["total", "gold", "silver"] else: @["gold", "silver", "bronze"]
    let medals = readTsv("medals.tsv").top(10, by)
    let order = cols(by)
    result = tabella(medals, rownameCol = "team"):
      optTokens()
      tabHeader (if byTotal: "Total first" else: "Golds first")
      colsHide ["rank", "code"]
      colsLabel {"gold": "🥇", "silver": "🥈", "bronze": "🥉", "total": "all"}
      rowOrder order, reverse = true
      tabStyle style.text(weight = "bold"), loc.body(cols(if byTotal: "total" else: "gold"))
      tabStyle style.fill(gilt), loc.body(rows = where(it["team"] == "Italy"))
      tabOptions(tableFontSize = "13px", dataRowPadding = "3px")

  nbAccanto:
    nbTable topTen(false)
    nbTable topTen(true)

nbText: &"""
Italy is fourth by golds (ten, like the Netherlands, but one silver fewer) and third by total
(thirty). The Netherlands drop from third to ninth: all their twenty medals came from two sports,
speed skating and short track. Germany won nineteen in the three sliding sports, Japan
twenty-one where judges give the score ({link("2026/02/23/criteri-classifica-olimpiadi-medaglie/", "Il Post")}).

### How was Italy?

Thirty medals: ten gold, six silver, fourteen bronze. Before the Games CONI, the Italian Olympic
committee, had hoped for eighteen. Is it a lot? Il Post answers by putting the number next to
others, so here is every Games Italy went to since the record of 1994:
"""

nbShowCode:
  let all = readTsv("italy-history.tsv")
  let h = all.keep(proc (i: int): bool = all["year", i].toFloat >= 1994)
  let t = tabella(h, rownameCol = "year"):
    optTokens()
    tabHeader "Italy at the Winter Games", "since Lillehammer 1994, the old record"
    colsHide ["gold", "silver", "bronze"]
    colsLabel {"host": "", "athletes": "athletes", "total": "🏅", "rank": "rank"}
    fmtBar "total", color = bar, width = "3.5em"
    tabStyle style.text(weight = "bold"), loc.body(rows = where(it["year"].toFloat == 2026))
    tabStyle style.text(weight = "bold"), loc.stub(rows = where(it["year"].toFloat == 2026))
    tabFootnote "At home, and fewer medals than four years before.",
      loc.stub(rows = where(it["year"].toFloat == 2006))
    tabSourceNote md("Wikipedia, [Italy at the Winter Olympics](https://en.wikipedia.org/wiki/Italy_at_the_Winter_Olympics); rank by golds.")
    tabOptions(tableFontSize = "13px", dataRowPadding = "4px")
  nbTable t

nbText: &"""
Three things make thirty, Il Post argues ({link("2026/02/17/medaglie-italia-record-perche/", "Come mai tutte queste medaglie?")}).
There are more events every time (61 in 1994, 116 now), so records fall anyway. Hosts do better:
the United States went from 13 to 34 at Salt Lake City in 2002. And it is a trend that started
before: 5, 8, 10, 17, 30. Turin 2006 is the warning that home is not enough.

The thirty, one row each, grouped by colour. Relays and team events count as one medal, however
many athletes are on the podium:
"""

nbShowCode:
  let m = readTsv("italy-medals.tsv")
  let t = tabella(m, groupnameCol = "medal"):
    optTokens()
    tabHeader "Italy's thirty medals"
    colsLabel {"date": "", "sport": "sport", "event": "event", "athletes": "who"}
    fmtDate "date", dateStyle = "d MMM"
    textTransform(medal, loc.rowGroups())
    tabStyle style.css("white-space: nowrap"), loc.body(cols("date"))
    tabStyle style.text(size = "12px"), loc.body(cols("athletes"))
    tabSourceNote md("Wikipedia, [Italy at the 2026 Winter Olympics § Medalists](https://en.wikipedia.org/wiki/Italy_at_the_2026_Winter_Olympics).")
    tabOptions(tableFontSize = "13px", dataRowPadding = "3px")
  nbTable t

nbText: """
Ten sports out of sixteen gave a medal, from luge to curling to freestyle skiing: in 1994 nine
of the twenty came from cross-country skiing alone.

Then, from 6 to 15 March, the Paralympics: 79 events in six sports, about 660 athletes from 50
countries, in Milan, Cortina and Tesero. Italy won sixteen medals, seven gold: both records. China,
which won its first Winter Paralympic medal only in 2018, was first again, as in Beijing 2022.
The two tables, side by side:
"""

nbShowCode:
  proc small(file, title: string): Tabella =
    let d = readTsv(file).top(6, ["gold", "silver", "bronze"])
    result = tabella(d, rownameCol = "team"):
      optTokens()
      tabHeader title
      colsHide ["rank", "silver", "bronze"]
      fmtFlag "code"
      colsLabel {"code": "", "gold": "🥇", "total": "all"}
      colsMoveToEnd "code"
      tabStyle style.fill(gilt), loc.body(rows = where(it["team"] == "Italy"))
      tabOptions(tableFontSize = "13px", dataRowPadding = "3px")

  nbAccanto:
    nbTable small("medals.tsv", "Olympics")
    nbTable small("paralympics.tsv", "Paralympics")

nbText: &"""
Russia, banned from the Olympics, where some of its athletes came as neutrals, competed under
its own name at the Paralympics and was third; Ukraine boycotted the opening ceremony. How China
built its team in seven years is the subject of one of Il Post's best pieces
({link("2026/03/10/cina-paralimpiadi-ori-medagliere-forte/", "Come la Cina è diventata così forte")}).

### How were they seen?

In Italy the Games were free on Rai and complete on Eurosport, which meant a subscription. In the
United States NBC had 94% more viewers than for Beijing 2022, and for the first time in a Winter
Games every race could be streamed.
"""

nbShowCode:
  let t = tabella(@channels, rownameCol = "channel"):
    optTokens()
    tabHeader "Where to watch, in Italy"
    colsLabel {"how": "", "free": "free", "allEvents": "every race"}
    fmtTf ["free", "allEvents"], tfStyle = "check-mark"
    tabSourceNote md(&"Il Post, {link(channelsSource, \"6 February 2026\")}; NBC's audience from Il Post, {link(sharesSource, \"24 February 2026\")}.")
  nbTable t

nbText: """
`fmtTf` turns `true` and `false` into ✓ and ✗, one of gt's ten styles. The table could say more
about media (Rai Sport's director left after his commentary of the opening was widely mocked) but
a check mark is what the reader came for.

## B · The money

### What did a seat cost?

A seat was cheap or very dear: €30 for the cheapest, €1,400 for the men's hockey final, up to
€2,900 for a ceremony. Two tables: the prices, and how they were spread.
"""

nbShowCode:
  nbAccanto:
    block:
      let t = tabella(@prices, rownameCol = "what"):
        optTokens()
        tabHeader "Prices"
        colsLabel {"euro": ""}
        fmtCurrency "euro", currency = "EUR", decimals = 0
        tabSourceNote md(link(pricesSource, "Il Post, 17 Oct 2025"))
        tabOptions(tableFontSize = "13px")
      nbTable t
    block:
      let t = tabella(@ticketShares, rownameCol = "what"):
        optTokens()
        tabHeader "Shares"
        colsLabel {"share": ""}
        fmtPercent "share", decimals = 0
        tabSourceNote md(link(sharesSource, "Il Post, 24 Feb 2026"))
        tabOptions(tableFontSize = "13px")
      nbTable t

nbText: &"""
1.3 million tickets were sold, 88% of those on sale, and almost two spectators in three came from
abroad: Dutch fans in orange at the speed skating, Americans at the curling. Sofia Goggia
missed the Italian crowds of the World Cup at Cortina, and blamed the prices and the roads. The
dearest part was the night: for two people, two nights at a venue went from €325 in January to
€1,275 in February, Altroconsumo found ({link(pricesSource, "Il Post")}).

### What is a medal worth?

The IOC pays nothing for a medal; the countries do, if they want. Italy is among the most generous:
€180,000 for a gold, tax free for the first time. The thirty medals cost CONI over €5.5 million,
against the €4 million it had set aside.
"""

nbShowCode:
  let t = tabella(@prizes, rownameCol = "country"):
    optTokens()
    tabHeader "What a medal pays", "to the athlete, from their country's committee"
    colsHide "currency"
    fmtFlag "code"
    colsLabel {"code": "", "gold": "🥇", "silver": "🥈", "bronze": "🥉"}
    colsMoveToEnd "code"
    fmtCurrency ["gold", "silver", "bronze"], currency = "EUR", decimals = 0,
      rows = where(it["currency"] == "EUR")
    fmtCurrency ["gold", "silver", "bronze"], currency = "USD", decimals = 0,
      rows = where(it["currency"] == "USD")
    subZero ["gold", "silver", "bronze"], zeroText = "nothing"
    dataColor "gold", palette = soft
    tabFootnote "Poland's figures are approximate.", loc.stub(rows = where(it["country"] == "Poland"))
    tabFootnote "Paid in dollars.", loc.stub(rows = where(it["currency"] == "USD"))
    tabFootnote "No prize: private sponsors fund the athletes.", loc.stub(rows = where(it["gold"].toFloat == 0))
    tabSourceNote md(&"Il Post, {link(prizesSource, \"23 February 2026\")}.")
    tabOptions(tableFontSize = "14px")
  nbTable t

nbText: """
The table mixes euros and dollars. `fmtCurrency` takes `rows`, so each row is formatted in its
own currency, and `subZero` says "nothing" where a country pays nothing: Norway, first in the
medal table, pays no prizes at all. Singapore and Hong Kong pay the most, and won nothing.

The medal itself is worth less than one would think. A gold medal is silver with six grams of gold:
"""

nbShowCode:
  let t = tabella(@metals, rownameCol = "medal"):
    optTokens()
    tabHeader "The medal as metal"
    colsLabel {"grams": "weighs", "goldGrams": "of gold", "euro": "worth"}
    fmtNumberSi ["grams", "goldGrams"], unit = "g", decimals = 0
    fmtCurrency "euro", currency = "EUR", decimals = 0
    subZero ["grams"], zeroText = "—"
    subZero ["goldGrams"], zeroText = "none"
    subZero ["euro"], zeroText = "a few euros"
    textTransform(medal, loc.stub())
    tabStyle style.css("white-space: nowrap"), loc.stub()
    tabSourceNote md(&"Il Post, {link(prizesSource, \"23 February 2026\")}, at February's prices; the silver medal's weight is not given.")
  nbTable t

nbText: """
### What did the works cost?

Here the coverage was hardest to follow, because the numbers moved for years. Il Post kept
writing down each work's first figure and each new one. Four of them, from the first estimate to
the last, in millions of euros:
"""

nbShowCode:
  let t = tabella(@estimates, rownameCol = "work"):
    optTokens()
    tabHeader "From the first estimate to the last", "millions of euros"
    colsLabel {"place": "", "fate": "", "first": "first", "last": "last", "times": "×"}
    fmtNumber ["first", "last"], decimals = 1, dropTrailingZeros = true
    fmtNumber "times", decimals = 1, pattern = "×{x}"
    subZero "last", zeroText = "?"
    textCaseMatch {"dropped": "<i>dropped</i>"}, locations = loc.body(cols("fate"))
    dataColor "times", palette = soft, domain = (1.0, 5.0)
    tabFootnote "Il Post, after the TV programme Report: from refurbishing to demolishing, five times the cost.",
      loc.body(cols("times"), rows = where(it["place"] == "Predazzo"))
    tabSourceNote md(&"Il Post: {link(estimatesSources[0], \"7 Mar 2025\")}, {link(estimatesSources[1], \"2 Feb 2026\")}, {link(estimatesSources[2], \"8 Oct 2026\")}.")
    tabOptions(tableFontSize = "14px")
  nbTable t

nbText: &"""
Two works were dropped when they grew too much; two were built anyway. The sliding track of
Cortina is the most discussed work of the Games: the IOC suggested racing abroad, on an existing
track, and the government and the Veneto region chose to rebuild it. A forest was cut for it.
Its cost, step by step:
"""

nbShowCode:
  let t = tabella(@trackSteps, rownameCol = "date"):
    optTokens()
    tabHeader "The sliding track of Cortina", "its cost, in millions of euros"
    colsLabel {"what": "", "millions": "€ m"}
    colsHide "path"
    fmtDate "date", dateStyle = "MMM yyyy"
    fmtBar "millions", color = bar, width = "4em", decimals = 1
    colsReorder ["what", "millions"]
    tabSourceNote md(&"Italian Wikipedia ([XXV Giochi olimpici invernali](https://it.wikipedia.org/wiki/XXV_Giochi_olimpici_invernali)); Il Post, {link(\"2023/09/21/nessuno-costruire-pista-bob-cortina-olimpiadi/\", \"Sep 2023\")}, {link(\"2024/02/02/accordo-pista-bob-cortina/\", \"Feb 2024\")}, {link(\"2026/01/22/a-cortina-ci-sono-piu-cantieri-che-neve/\", \"Jan 2026\")}.")
  nbTable t

nbText: """
Building it was the first bill. Keeping it is the second, every year. In October Il Post read the
business plan KPMG wrote for the region: in 2027 the track takes in €527,000 and spends €1.33
million. One line per item, in and out:
"""

nbShowCode:
  let t = tabella(@trackYear, rownameCol = "item", groupnameCol = "side"):
    optTokens()
    tabHeader "One year of the sliding track", "2027, as planned"
    colsLabel {"euro": ""}
    fmtCurrency "euro", currency = "EUR", decimals = 0
    textCaseMatch {"In": "In: €527,000", "Out": "Out: €1,333,000"}, locations = loc.rowGroups()
    tabSourceNote md(&"KPMG for the Veneto region, via Il Post, {link(\"2026/10/08/spese-pista-bob-cortina/\", \"8 October 2026\")}. The loss: €805,000 in 2027, €889,000 in 2032, about €5 million in six years.")
    tabOptions(tableFontSize = "14px")
  nbTable t

nbText: &"""
Electricity alone costs almost as much as all the income. The town counts on six other
"legacy" works to cover the rest, a cable car first, which was not ready for the Games.

The hockey arena of Santa Giulia is private (it belongs to CTS Eventim, which owns TicketOne) but
the state pays for its extra costs, and how much those are depends on who is asked:
"""

nbShowCode:
  let t = tabella(@santaGiulia, rownameCol = "who"):
    optTokens()
    tabHeader "Santa Giulia's extra costs", "millions of euros, as each side tells them"
    colsLabel {"says": "", "millions": "€ m"}
    fmtBar "millions", color = bar, width = "4em"
    tabStyle style.text(style = "italic"), loc.body(rows = where(it.index == 0))
    tabSourceNote md(&"Il Post, {link(santaGiuliaSource, \"5 May 2026\")}; the Court of Auditors is investigating.")
  nbTable t

nbText: """
## C · What stays

### Snow

The Games were sold as sustainable; Il Post's verdict, the day after, is that they "hid the problems
well". It snowed on almost every outdoor venue during the races, which hid the first problem: the
snow had been made.
"""

nbShowCode:
  let t = tabella(@snow, rownameCol = "what"):
    optTokens()
    colsLabel {"value": "", "unit": "", "note": ""}
    fmtNumber "value", decimals = 1, compact = true
    colsMoveToEnd "note"
    tabSourceNote md(&"Il Post, {link(snowSources[0], \"24 Feb 2026\")} and {link(snowSources[1], \"22 Jan 2026\")}. Over 90% of Italy's ski slopes were snowed artificially in 2025, 98% in the Dolomites (Legambiente, via {link(\"2025/03/07/olimpiadi-invernali-diffuse-2026-piu-luoghi-sostenibilita/\", \"Il Post\")}).")
  nbTable t

nbText: """
`fmtNumber(compact = true)` writes 1.6M. The unit stays in a column of its own:
`fmtNumberSi(unit = "m³", decimals = 1)` would write "1.6 Mm³", which reads as cubic megametres (more about this at the end).

### Air

Snow has to be made because winters are warmer, and the cause is in the air. Carbon dioxide is
a tiny part of it, so it is counted in parts per million (ppm): how many molecules in every
million. Here it is in February of each Italian Winter Games that was measured (the record, at
Mauna Loa in Hawaii, starts in 1958, two years after Cortina 1956):
"""

nbShowCode:
  let air = readTsv("co2.tsv")
  let first = air["co2", 0].toFloat
  var more: seq[Value]
  for i in 0 ..< air.nrows: more.add toValue(air["co2", i].toFloat / first - 1)
  var d = air
  d.addColumn("more", more)
  let t = tabella(d, rownameCol = "year"):
    optTokens()
    tabHeader "CO₂ in the air", "in February, at Mauna Loa"
    colsLabel {"games": "", "co2": "CO₂", "more": "more than 1959"}
    fmtPartsper "co2", toUnits = "ppm", decimals = 0
    fmtPercent "more", decimals = 0
    subZero "more", zeroText = "—"
    tabStyle style.css("white-space: nowrap"), loc.body(cols("co2"))
    tabStyle style.text(weight = "bold"), loc.body(rows = where(it["year"].toFloat == 2026))
    tabSourceNote md("NOAA GML and Scripps, [monthly means at Mauna Loa](https://gml.noaa.gov/ccgg/trends/data.html), public data.")
    tabOptions(tableFontSize = "14px")
  nbTable t

nbText: """
The data has the share as a fraction of the air, 0.00042935, which no one wants to read:
`fmtPartsper(toUnits = "ppm")` writes it as 429 ppm. Between Turin and Milano Cortina, twenty
years, the air gained 47 ppm; it took the forty-seven years before Turin to gain 66.

How much did the Games themselves add? Il Post gives no figure. In January 2026 two British
groups, Scientists for Global Responsibility and the New Weather Institute, estimated it from the
organisers' own data: about 930,000 tonnes of CO₂ equivalent, almost half of it from spectators'
travel. They added what the official accounts leave out, the emissions that three sponsors'
advertising brings (an oil company, a carmaker, an airline), and what all of it will melt:
"""

nbShowCode:
  let t = tabella(@footprint, rownameCol = "what", groupnameCol = "part"):
    optTokens()
    tabHeader "The Games' footprint", "estimated before the Games, and what it will melt"
    colsLabel {"tonnes": "CO₂e", "snowKm2": "snow cover", "iceMt": "glacier ice"}
    fmtNumber "tonnes", compact = true, pattern = "{x} t"
    fmtNumber "snowKm2", decimals = 1, pattern = "{x} km²"
    fmtNumber "iceMt", decimals = 0, pattern = "{x} Mt"
    tabStyle style.text(style = "italic"), loc.body(rows = where($it["what"] in ["spectators' travel", "Eni alone"]))
    tabStyle style.text(style = "italic"), loc.stub(rows = where($it["what"] in ["spectators' travel", "Eni alone"]))
    tabStyle style.css("white-space: nowrap"), loc.body()
    tabFootnote "Over 14 Mt and over 20 Mt: the report gives lower bounds.", loc.columnLabels(cols("iceMt"))
    tabSourceNote md(&"SGR and New Weather Institute, [Olympics Torched]({footprintReport}), January 2026; figures from [its summary]({footprintSource}).")
    tabOptions(tableFontSize = "13px")
  nbTable t

nbText: """
The rows in italics are part of the row above. The sponsors add about 40% more than the Games'
own footprint, and the report puts the total loss at 5.5 km² of snow cover and over 34 million
tonnes of glacier ice. `fmtNumber(compact = true, pattern = "{x} t")` writes 930K t; the same
`pattern` puts each unit after its number.

### Buildings

What happens to Olympic venues afterwards? In 2025 the IOC published a study of almost a thousand,
in every Games from 1896 to 2022. Most are still used:
"""

nbShowCode:
  var d = TableData()
  d.addColumn("fate", ioc.mapIt(toValue(it.fate)))
  d.addColumn("venues", ioc.mapIt(toValue(it.venues)))
  d.addColumn("share", ioc.mapIt(toValue(it.venues / 982)))
  let t = tabella(d, rownameCol = "fate"):
    optTokens()
    tabHeader "982 Olympic venues, 1896 to 2022", "what became of them"
    colsLabel {"venues": "", "share": ""}
    fmtPercent "share", decimals = 0
    subSmallVals "share", threshold = 0.05, smallPattern = "under 5%"
    fmtBar "venues", color = bar, width = "6em"
    tabFootnote "Two of them from Turin 2006: the ski jumps of Pragelato and the sliding track of Cesana.",
      loc.stub(rows = where(it["fate"] == "Permanent, abandoned"))
    tabSourceNote md(&"The IOC, via Il Post, {link(iocSource, \"30 October 2025\")}.")
  nbTable t

nbText: """
`subSmallVals` hides the precise small shares behind "under 5%", gt's way to say a number is too
small to matter, here used to say the abandoned venues are few. Few, but the ones that are
abandoned are exactly the kind Milano Cortina built again: a ski jump and a sliding track.

And what each new or rebuilt place becomes:
"""

nbShowCode:
  let t = tabella(@afterwards, rownameCol = "venue"):
    optTokens()
    tabHeader "After the Games"
    colsLabel {"built": "", "becomes": "becomes"}
    textTransform(proc (s: string): string = s.toUpperAscii, loc.body(cols("built")))
    tabStyle style.text(size = "11px", weight = "bold"), loc.body(cols("built"))
    tabSourceNote md(&"Il Post, {link(afterwardsSources[0], \"25 Feb 2026\")}, {link(afterwardsSources[1], \"22 Jan 2026\")}, {link(afterwardsSources[2], \"8 Oct 2026\")}.")
    tabOptions(tableFontSize = "14px")
  nbTable t

nbText: """
Milan built little on purpose, to avoid "cathedrals in the desert", with the paradox that it still
has no public ice rink. The 450 cheaper beds of the village cost €592 a month, still a lot for a
student.

### After

The Games ended on 22 February, the Paralympics on 15 March. The news did not:
"""

nbShowCode:
  let t = tabella(after.mapIt((date: it.date, what: it.what, path: post(it.path))), rownameCol = "date"):
    optTokens()
    tabHeader "Since the Games"
    colsLabel {"what": "", "path": ""}
    fmtDate "date", dateStyle = "d MMM yyyy"
    fmtUrl "path", label = "Il Post ↗"
    tabStyle style.css("white-space: nowrap"), loc.body(cols("path"))
    tabStyle style.css("white-space: nowrap"), loc.stub()
    tabStyle style.text(style = "italic"), loc.body(rows = where(it["date"] == "2026-12-08"))
    tabFootnote "Not yet: planned.", loc.stub(rows = where(it["date"] == "2026-12-08"))
    tabOptions(tableFontSize = "14px")
  nbTable t

nbText: """
The last row is in the future: the cable car of Socrepes, built on a landslide that stopped the
works in 2025, is due to open on 8 December, a month from today.

## The articles

The Il Post articles this post learned from, with the angle each takes. `fmtUrl` makes the links:
"""

nbShowCode:
  var d = TableData()
  d.addColumn("date", articles.mapIt(toValue(it.date)))
  d.addColumn("title", articles.mapIt(toValue(it.title)))
  d.addColumn("url", articles.mapIt(toValue(post(it.path))))
  d.addColumn("angle", articles.mapIt(toValue(it.angle)))
  let t = tabella(d, rownameCol = "date"):
    optTokens()
    tabHeader "Fifteen articles", "from Il Post's coverage, 2025–2026"
    colsLabel {"title": "", "url": "", "angle": "its angle"}
    fmtDate "date", dateStyle = "d MMM yy"
    fmtUrl "url", label = "read ↗"
    tabStyle style.css("white-space: nowrap"), loc.body(cols("url"))
    tabStyle style.css("white-space: nowrap"), loc.stub()
    tabStyle style.text(style = "italic"), loc.body(cols("title"))
    tabOptions(tableFontSize = "13px")
  nbTable t

nbText: """
## How this post is built

The page is a nimib notebook, `docs/devlog/milano_cortina.nim`, built with the others by
`nim r -d:release docs/all.nim`. From zero, in four layers.

**1. The data from Wikipedia** is six TSV files in `docs/devlog/data/milano-cortina/`: the medal
tables of the Olympics and the Paralympics, Italy at every Winter Games, Italy's thirty medals, the
venues and the sports. A short Python script beside them, `fetch.py`, reads five Wikipedia articles
through the REST API (slowly: Wikipedia limits fast clients) and writes the tables with pandas.
Each file starts with a comment line naming the article and its revision, so the numbers can be
checked against the exact page they came from. Wikipedia's text is under CC BY-SA 4.0. One more
file, `co2.tsv`, comes from NOAA's public Mauna Loa record, written by `co2.py` beside it.

**2. The facts from Il Post** are typed by hand in `docs/olimpiadi.nim`: Nim objects, one `const`
array per table, each with the path of the article it comes from. Il Post is a newspaper and its
articles are its own, so only facts and numbers are taken, each linked; the text of this post is
written from scratch. Where an article gives no number (the silver medal's weight, Predazzo's
final cost), the field is 0 and the table says so (`subZero`), rather than inventing one.

**3. The tables** are tabelline. Each `tabella(data, ...)` takes a `TableData` (from `readTsv`, or
built column by column with `addColumn`) or a `seq` of objects, one field per column. `tabella`
is a macro: it makes the table with `initTabella`, then reads its indented body one line at a
time, so that `fmtFlag "code"` becomes `t = t.fmtFlag("code")`. The verbs themselves are procs,
and a format such as `fmtCurrency` only records what to do: it runs when the table is rendered,
so the HTML, text and Markdown renderers all agree. Two small helpers belong to this page:
`readTsv`, which skips comment lines, and `medal`, which puts 🥇 before "gold". The page is made
of the docs' blocks (`docs/blocchi.nim`): `nbAccanto` puts small tables side by side (they wrap
to one column on a phone), and under every table *show code* opens the code that made it:
`nbShowCode` runs its block, reads the
block's own source back with nimib's `getCode`, and folds it under the tables the block made.

**4. Nothing is fetched while the page is built.** The TSV files and the facts are in the
repository, so the page builds offline and the same way every time; `fetch.py` and `co2.py`
are run by hand when the data should change.

## What tabelline was missing

Used on someone else's data, tabelline 0.1 held up. These are the places where it made the page
do extra work, sent to the thread that builds it:
"""

nbShowCode:
  type Gap = object
    what, how: string
  let rows = @[
    Gap(what: "Comment lines in CSV",
        how: "`readCsv` has no `comment` option, so `readTsv` strips `#` lines first; Polars has `comment_prefix`, R `comment.char`."),
    Gap(what: "The first n rows, after sorting",
        how: "`rowOrder` sorts what is shown, but a top ten by total needs the data sorted and cut before `tabella` (this page's `top`). Python and R do it in the data frame; without one, a `head` after `rowOrder` would help."),
    Gap(what: "Totals in a group",
        how: "The track's in and out totals are written in the group labels by hand: summary rows are planned (`add-summary-rows`)."),
    Gap(what: "SI prefixes and powered units",
        how: "`fmtNumberSi(1.6e6, \"m³\")` writes \"1.6 Mm³\", which is cubic megametres. A unit with a power needs the prefix inside it, or a warning in the docs."),
    Gap(what: "Markdown in a replacement",
        how: "`textCaseMatch` and `textReplace` run on the formatted text, after `fmtMarkdown`, so a `**new**` they put in stays as it is; HTML works. Worth a line in the docs (gt behaves the same)."),
    Gap(what: "`locations` after defaults",
        how: "`textCaseMatch(cases, loc.body(...))` does not compile: `default` and `replace` come first, so the location needs `locations = `. Moving `locations` before them would read as gt does."),
    Gap(what: "Ranks from the data",
        how: "`rowOrder` sorts golds-first or total-first, but a rank column must be computed outside; a `rank` helper over the shown order would make the two tables complete."),
    Gap(what: "A blank instead of zero",
        how: "`subZero(zeroText = \"\")` leaves the zero as it is, because an empty text means no substitution; the footprint table stores NaN (a missing value, blank by default) instead."),
  ]
  let t = tabella(rows, rownameCol = "what"):
    optTokens()
    tabHeader "Gaps found by this post"
    colsLabel {"how": ""}
    fmtMarkdown "how"
    colsWidth {"what": "30%"}
  nbTable t

nbSave
