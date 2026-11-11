## story: 0.2 | FOSDEM, twenty-six times | Brussels' free software weekend from OSDEM 2001 to FOSDEM 2027, in three parts of three: the editions, the devrooms, the people. The data from FOSDEM's own schedules, read with nanuq; the tables made with tabelline 0.2, ported from the R and gt they were first written in.
## A story, kept up to date (first written on 8 November 2026, in R with gt, ahead of tabelline
## 0.2; ported to Nim on 10 November 2026, when 0.2 was built). Every table is tabelline. The gt
## version of each one, its R code and its HTML, is kept in
## docs/stories/data/fosdem/story/fosdem-gt.json, to compare with. The data is in
## docs/stories/data/fosdem/ (see its README); the small tables of this story are in story/,
## written by src/insights.nim (nanuq); the two series of the nanoplots are counted here, with the
## standard library, from the tidy tables.
import std/[os, strutils, strformat, sequtils, algorithm, tables, sets, json]
import nimib
import tabelline, tabelline/nimib
import ../blocks, ../theme

let docs = currentSourcePath().parentDir.parentDir
let data = docs / "stories" / "data" / "fosdem"
nbInit
nb.doc.filename = docs / "stories" / "fosdem" / "index.html"
nb.useTabelline(title = "FOSDEM, twenty-six times", homeHref = "../", backLabel = "Stories", wordmarkHref = "../../")

# ------------------------------------------------------------------- this story's own helpers

proc story(name: string): TableData =
  ## A small table of this story, from story/, skipping the line that says where it comes from.
  readCsv(data / "story" / name, comment = "#")

proc withColumn(d: TableData, name: string, fn: proc (it: Row): Value): TableData =
  ## `d` with the column `name` made from each row by `fn`: in place of the old one, or at the
  ## end. For the columns a table is grouped by, or has as its stub, which `colsAdd` comes too
  ## late for.
  var vs: seq[Value]
  for i in 0 ..< d.nrows: vs.add fn(Row(data: d, index: i))
  result = TableData()
  for c in d.columns: result.addColumn(c.name, if c.name == name: vs else: c.values)
  if not d.hasColumn(name): result.addColumn(name, vs)

proc sortedBy[K](d: TableData, key: proc (it: Row): K): TableData =
  ## The rows of `d` in the order of `key` (rows with the same key keep their order).
  var ix = toSeq(0 ..< d.nrows)
  ix.sort(proc (a, b: int): int = cmp(key(Row(data: d, index: a)), key(Row(data: d, index: b))))
  result = TableData()
  for c in d.columns: result.addColumn(c.name, ix.mapIt(c.values[it]))

func link(text, url: string): Value =
  ## A Markdown link, for `fmtMarkdown`; just the text without an address.
  toValue(if url.len == 0: text else: &"[{text}]({url})")

const held = toSeq(2001 .. 2026)   # the editions with a schedule: the x axis of the nanoplots

func series(counts: CountTable[int], years: openArray[int]): string =
  ## The counts of `years` as one nanoplot cell: "0 3 1 ...".
  years.mapIt($counts[it]).join(" ")

proc talksPerEdition(people: openArray[string]): Table[string, string] =
  ## For each person, the events they spoke at in each edition, from event_speakers.csv: their
  ## names are matched to the folded key of people.csv, as the story's numbers are.
  let byName = readCsv(data / "people.csv", comment = "#")
  var key: Table[string, string]
  for i in 0 ..< byName.nrows:
    if $byName["person", i] in people and byName["is_person", i] == true:
      key[$byName["person_key", i]] = $byName["person", i]
  let spoke = readCsv(data / "event_speakers.csv", comment = "#")
  var counts: Table[string, CountTable[int]]
  var seen: HashSet[string]
  for i in 0 ..< spoke.nrows:
    let k = $spoke["person_key", i]
    if k notin key: continue
    let event = $spoke["event_id", i] & " " & k
    if event in seen: continue        # one talk, even with the same person twice on it
    seen.incl event
    counts.mgetOrPut(key[k], initCountTable[int]()).inc spoke["year", i].toFloat.int
  for name, c in counts: result[name] = c.series(held)

proc talksPerYear(names: openArray[string]): string =
  ## The events of a devroom in each edition, from tracks.csv, under any of its `names`.
  let tracks = readCsv(data / "tracks.csv", comment = "#")
  var c: CountTable[int]
  for i in 0 ..< tracks.nrows:
    if $tracks["track", i] in names and tracks["kind", i] == "devroom" and tracks["events", i].isNumber:
      c.inc tracks["year", i].toFloat.int, tracks["events", i].toFloat.int
  c.series(toSeq(2002 .. 2026))

proc gtCell(start: string): string =
  ## The R code of a table of the first version, from story/fosdem-gt.json.
  for c in parseFile(data / "story" / "fosdem-gt.json")["cells"]:
    if c.getStr.startsWith(start): return c.getStr
  raise newException(KeyError, "no R cell starting with " & start)

let bars = nanoplotOptions(dataBarFillColor = tint("--primary"), dataBarStrokeColor = tint("--primary"))

# ------------------------------------------------------------------------------------ the story

nbTitle "A story · tabelline 0.2", "FOSDEM, twenty-six times", """
Every year, on a weekend at the start of February, a few thousand people who make free software
fill the campus of the Université Libre de Bruxelles. There is no ticket and no registration.
This is FOSDEM in tables, from OSDEM in 2001 to the edition of 2027, in three parts of three:
the editions, the devrooms, the people.
"""

nbNote("""
Green cards like this one are about how the tables are made. Every table here is made with
tabelline 0.2, the release that brings summary rows, merged columns, units, icons and nanoplots:
it is the *use it* story of 0.2. It was first written in **R with gt**, ahead of the release, and
then ported to Nim table by table; the last part of the story says what the port found. The
numbers are computed in Nim with [nanuq](https://github.com/pietroppeter/nanuq) and saved as
small CSV files; the page reads them and draws the tables. *Show code* under a table opens the
Nim that made it. The green cards can be skipped: the rest of the text is about FOSDEM.
""", nkCode, "Reading the code")

nbToc()

nbText: """
## One row to start

The least one can say about FOSDEM: when the next one is, how many devrooms it will have, and
how many came before it.
"""

nbShowCode:
  let t = tabella(story("dates.csv"), rownameCol = "name"):
    optCssTheme()
    rowsHide where(it.year != 2027)
    tabHeader "FOSDEM 2027", "the 27th edition, as announced"
    colsHide ["year", "edition", "format", "day_of_year", "in_window", "url"]
    colsAdd "devrooms", proc (r: Row): Value = toValue(78)
    colsAdd "before", proc (r: Row): Value = toValue(26)
    fmtDate ["start", "end"], dateStyle = "day_m"
    colsMergeRange "start", "end"
    textReplace " (Université Libre de Bruxelles)", "", loc.body(cols("venue"))
    colsLabel:
      start: "when"
      venue: "where"
      before: "editions before"
    tabSourceNote "fosdem.org, news of 2027: the dates and the accepted developer rooms."
  nbTable t

nbNote("""
`colsMergeRange` puts the two dates in one column, "30 Jan–31 Jan", and hides the second:
merged columns are new in tabelline 0.2. `rowsHide` keeps only 2027 of the 27 rows, and `colsAdd`
adds the two numbers of the news. `optCssTheme()` gives the table the page's colours and font.
""", nkCode)

nbText: """
FOSDEM 2027 will be the earliest one yet, on 30 January as in 2016, and the 27th: OSDEM, the first, was in
2001, and the F (for *Free*) came the year after.

## Three parts of three

Twenty-six editions are too many for one table, so the story splits them in three, and every
part in three again: three questions each, nine tables, simplest first. A coda, at the end, is
about Nim.
"""

nbShowCode:
  let parts = tableData:
    icon: ["calendar-days", "door-open", "microphone"]
    part: ["The editions", "The devrooms", "The people"]
    questions: ["When is it? How big is it? What did the online years change?",
                "Which devrooms come in 2027? Which ran the longest? How many are new each year?",
                "Who gives the keynotes? Who keeps coming back? How many speak for the first time?"]
  let t = tabella(parts):
    optCssTheme()
    fmtIcon "icon", height = "1.1em", fillColor = tint("--primary")
    colsLabel:
      icon: ""
      questions: "three questions"
    tabStyle style.text(weight = "bold"), loc.body(cols("part"))
  nbTable t

nbNote("""
The icons are Font Awesome's, drawn by `fmtIcon` from their names (`calendar-days`,
`door-open`, `microphone`): in the R version they were emoji. An icon is SVG inside the page, so
nothing is loaded, and it takes the colour given, here the page's own red.
""", nkCode)

nbText: """
## Where the numbers come from

FOSDEM publishes its schedule, and keeps every past one at archive.fosdem.org: since 2012 as an
XML file of every event, before that as web pages. Its website's source keeps the calls for
participation of each devroom, and its mailing list has been archived since 2006. From these,
ten tables, in `docs/stories/data/fosdem/`:
"""

nbShowCode:
  var files: seq[tuple[table: string, rows: int, about: string]]
  for f in ["editions", "events", "event_speakers", "people", "tracks", "rooms",
            "cfp_listings", "cfp_posts", "mailing_list_years", "stands"]:
    let path = data / f & ".csv"
    let firstLine = readFile(path).splitLines[0]     # "# What it is. Where it comes from."
    files.add (f & ".csv", readCsv(path, comment = "#").nrows, firstLine[2 .. ^1].split(". ")[0])
  let t = tabella(files, rownameCol = "table"):
    optCssTheme()
    tabHeader "The data", "ten tables, one row per ..."
    fmtInteger "rows"
    colsLabel:
      about: ""
    tabStyle style.text(size = "12px") & style.css("overflow-wrap: anywhere"), loc.body(cols("about"))
    tabSourceNote "archive.fosdem.org, FOSDEM's website on GitHub, lists.fosdem.org; see the folder's README."
  nbTable t

nbNote("""
Every file starts with a line naming its sources, so `readCsv(path, comment = "#")` skips it; its
first sentence is the column *about*. The table is made from Nim values: a sequence of named tuples, one
field per column. The story's own small tables are in `story/`, made from these by
`src/insights.nim`.
""", nkCode)

nbText: """
The schedules are complete from 2011. Before that the old sites show the main tracks and, for
most years, the devroom pages; the first three editions only have their printed main grid. The
tables below say where a year is partial.
"""

nbPart 1, "", prSuccess   # no label: the headings name the parts, the circles take its colour
nbText: """
## A · The editions

### When is it?

FOSDEM is a weekend in winter, but which one has changed. The first editions moved around
February; from 2004 to 2008 they were at the end of the month. Since 2011 the Saturday has always
fallen between 30 January and 5 February, the first weekend of February or the last of
January, except in 2021, online. In green, the years in that week:
"""

nbShowCode:
  let dates = story("dates.csv")
    .withColumn("era", proc (it: Row): Value =
      let y = it.year.toFloat
      toValue(if y <= 2003: "the first ones" elif y <= 2008: "late February"
              elif y <= 2010: "moving" else: "the week of 1 February"))
    .withColumn("edition", proc (it: Row): Value = link($it.year, $it.url))   # the year opens its site
  let inWindow = where(it.in_window == true)
  let t = tabella(dates, rownameCol = "edition", groupnameCol = "era"):
    optCssTheme()
    tabHeader "Every FOSDEM", "Saturday and Sunday, 2001 to 2027"
    colsHide ["year", "venue", "day_of_year", "in_window", "url"]
    fmtMarkdown "edition"
    fmtDate ["start", "end"], dateStyle = "day_month"
    colsMergeRange "start", "end", sep = " – "
    textCaseMatch:
      "in person": ""
      locations = loc.body(cols("format"))
    textCaseMatch:
      FOSDEM: ""
      locations = loc.body(cols("name"))
    colsLabel:
      name: ""
      start: "weekend"
      format: ""
    tabStyle style.fill(tint("--success-soft")), loc.body(rows = inWindow), loc.stub(rows = inWindow)
    tabSourceNote md("FOSDEM's archived sites ([archive.fosdem.org](https://archive.fosdem.org/)); 2027 from [fosdem.org](https://fosdem.org/2027/). A year opens its edition's site.")
    tabOptions(tableFontSize = "13px", dataRowPadding = "2px")
  nbTable t

nbNote("""
The row groups come from a column made from the year (`withColumn`, this story's own helper:
the column a table is grouped by must be there before `tabella`), and the stub is the year as a
Markdown link, `fmtMarkdown`. `colsMergeRange` puts Saturday and Sunday in one cell.
`textCaseMatch` empties "in person", so only "online" stands out, and "FOSDEM", so only OSDEM
does; its cases are an indented block, one per line.
""", nkCode)

nbText: """
Nothing in the data states the rule; the dates show it, and 2027 keeps it.

### How big is it?

Thirty-one talks in three rooms in 2001; over a thousand in 2025 and 2026. The growth is in the
devrooms: rooms that a community runs for a day, with its own call for talks. In 2001 there were
none; in 2026, 65 of them held 926 of the 1,079 events.
"""

nbShowCode:
  let t = tabella(story("sizes.csv"), rownameCol = "year", groupnameCol = "decade"):
    optCssTheme()
    tabHeader "How big", "events, devrooms and speakers of every edition"
    colsHide ["coverage", "lightning_talks"]
    tabSpanner "talks", ["devroom_talks", "main_track_talks"]
    colsLabel:
      devroom_talks: "devroom"
      main_track_talks: "main"
    fmtInteger ["events", "devrooms", "devroom_talks", "main_track_talks", "speakers"]
    summaryRows:
      total: agg.sum
      columns = ["events", "devroom_talks", "main_track_talks"]
      missingText = ""
    grandSummaryRows:
      "all 26": agg.sum
      columns = ["events", "devroom_talks", "main_track_talks"]
      missingText = ""
    tabFootnote "Partial: until 2006 the devroom talks are known only where a devroom page is archived.",
      loc.stub(rows = where(2004 <= it.year and it.year <= 2006))
    tabSourceNote "FOSDEM's schedules; an event is anything on them, with stands and BOFs."
    tabOptions(tableFontSize = "12px", dataRowPadding = "2px", columnLabelsPaddingHorizontal = "3px",
               dataRowPaddingHorizontal = "3px", summaryRowPadding = "2px", summaryRowPaddingHorizontal = "3px")
  nbTable t

nbNote("""
`summaryRows` adds a total under each decade, and `grandSummaryRows` one for all the years:
summary rows are the first feature of tabelline 0.2. Both are written as a block: a line
`total: agg.sum` is a row and its aggregate, a line `columns = ...` an argument. The totals take
the columns' own format, `fmtInteger`, so they have the thousands' comma too. The speakers have
no total on purpose: the same person speaks in many years, so they do not add up; `missingText`
leaves those cells empty instead of a dash.
""", nkCode)

nbText: """
The main tracks stayed small: 18 talks a year from 2007 to 2011, never more than 45. What grew,
grew in the devrooms: a third of the events in 2004, more than eight in ten since 2010.

The stands grew too: the halls where projects show themselves, hand out stickers and sell
T-shirts. The archived stands pages list 23 in 2008 and 96 in 2026. A few have been there almost
every year:
"""

nbShowCode:
  let t = tabella(story("stands_top.csv"), rownameCol = "stand"):
    optCssTheme()
    tabHeader "The stands that keep coming", "present at the most editions, 2008 to 2026"
    colsMergeRange "first", "last"
    colsLabel:
      first: "years"
    tabStyle style.text(weight = "bold"), loc.body(cols("editions"))
    tabSourceNote md("The stands pages of [archive.fosdem.org](https://archive.fosdem.org/2026/stands/), 2008–2026; a name matched across years with case folded.")
    tabOptions(tableFontSize = "13px", dataRowPadding = "2px")
  nbTable t

nbNote("""
The stands are a table of their own in the data, `stands.csv`, one row per stand and year:
the pages were a list until 2012, tables by building from 2013, cards online in 2021 and 2022.
`colsMergeRange` again for the years.
""", nkCode)

nbText: """
Debian and PostgreSQL had a stand at all nineteen editions since 2008; GNOME, KDE and Mozilla
missed one or two.

### What did the online years change?

In 2021 and 2022 FOSDEM was online, because of the pandemic. It did not shrink much: about as
many talks as in 2019, recorded in advance and streamed in about a hundred virtual rooms, one
for every devroom and track. A talk was 30 minutes, as in 2019, against 25 in the other
years.
"""

nbShowCode:
  let online = where(it.format == "online")
  let t = tabella(story("online.csv"), rownameCol = "year"):
    optCssTheme()
    tabHeader "Online and back", "the editions of 2018 to 2026"
    colsHide ["devrooms", "format"]
    fmtInteger ["events", "rooms", "speakers"]
    fmtNumber "median_minutes", decimals = 0
    fmtPercent "with_video", decimals = 0
    colsLabel:
      median_minutes: "a talk"
      with_video: "on video"
    colsUnits:
      median_minutes: "min"
    tabStyle style.fill(tint("--secondary-soft")), loc.body(rows = online), loc.stub(rows = online)
    tabFootnote "The median length of a talk: keynotes, main tracks, devrooms, lightning talks.",
      loc.columnLabels(cols("median_minutes"))
    tabFootnote "Online.", loc.stub(rows = online)
    tabSourceNote "FOSDEM's schedules."
    tabOptions(tableFontSize = "13px")
  nbTable t

nbNote("""
`colsUnits` writes the unit beside the column's label, "a talk, min" (units are new in 0.2), and
`fmtPercent` the share of events with a video. The online years are shaded, with a footnote
instead of a column: one row selection, `online`, picks the rows for both.
""", nkCode)

nbText: """
The rooms column says what changed: a hundred rooms online, about 35 at the ULB. The video
column says what did not: since 2017 about nine events in ten are recorded, so FOSDEM was
already half online before it went online.
"""

nbText: """
## B · The devrooms

### Which devrooms come in 2027?

A devroom is proposed again every year, and accepted or not; so every year some are new, some
return, and some do not. 78 were accepted for 2027. Matched with every earlier year, by name and
through their renames (Jabber became XMPP, then Real Time Communications), they fall into five
groups:
"""

nbShowCode:
  const groups = ["since before 2013", "since 2013–2022", "since 2023 or later",
                  "back after a pause", "new in 2027"]
  let rooms = story("devrooms_2027.csv")
    .sortedBy(proc (it: Row): (int, float, string) =
      (groups.find($it.group), it.first.toFloat, toLowerAscii($it.devroom)))
    .withColumn("devroom", proc (it: Row): Value = link($it.devroom, $it.cfp))   # its call for talks
  let t = tabella(rooms, rownameCol = "devroom", groupnameCol = "group"):
    optCssTheme()
    tabHeader "The devrooms of 2027", "and the year each first ran"
    rowGroupOrder groups
    colsHide "cfp"
    fmtMarkdown "devroom"
    colsLabel:
      first: "since"
      was: "in 2026"
    subMissing "was", missingText = ""
    summaryRows:
      devrooms: agg.count
      columns = "editions"
      missingText = ""
    tabStyle style.fill(tint("--success-soft")), loc.rowGroups("new in 2027")
    tabStyle style.text(size = "12px"), loc.body(cols("was"))
    tabSourceNote md("fosdem.org, [accepted developer rooms of 2027](https://fosdem.org/2027/news/accepted-developer-rooms/); a name opens its call for participation. Earlier years from the schedules.")
    tabOptions(tableFontSize = "13px", dataRowPadding = "2px", summaryRowPadding = "2px")
  nbTable t

nbNote("""
The summary row of each group counts its devrooms, `agg.count`, under the editions column. The
groups are computed in nanuq (`src/insights.nim`): a devroom's *family* is its name folded to a
key, plus 49 renames matched by hand, and its status is new, back (missing the year before) or
continuing. `rowGroupOrder` puts the five groups in the order of the text.
""", nkCode)

nbText: """
Twenty-one are new. Eleven return after a pause, and among them are some of the oldest: Free
Java, PostgreSQL, PHP, Perl, Ruby and the office suites (LibreOffice's devroom, now *FOSS
Office*) all had no room in 2026. Of the devrooms of the first years, 2002 to 2005, only
Embedded comes to 2027 without a pause.

### Which ran the longest?

Twenty-four editions, almost all of them, for two devrooms: Mozilla's, which ran every year from
2002 to 2025, and Embedded's. Here are those held ten times or more, with their talks year by
year, 2002 to 2026:
"""

nbShowCode:
  let longest = story("devrooms_longest.csv")
    .withColumn("now", proc (it: Row): Value =
      toValue(if it.in_2027 == true: "in 2027 too" else: "no longer held"))
  let t = tabella(longest, rownameCol = "devroom", groupnameCol = "now"):
    optCssTheme()
    tabHeader "The longest-running devrooms", "held in ten editions or more"
    colsAdd "per_year", proc (r: Row): Value = toValue(talksPerYear(($r.names).split("; ")))
    colsHide ["names", "n_names", "in_2027"]
    rowGroupOrder ["in 2027 too", "no longer held"]
    colsMergeRange "first", "last"
    fmtInteger "talks"
    fmtNanoplot "per_year", plotType = "bar", plotHeight = "1em", options = bars
    colsLabel:
      first: "years"
      longest_run: "in a row"
      per_year: "by year"
    tabStyle style.text(whitespace = "nowrap"), loc.body(cols("first"))
    tabStyle style.text(weight = "bold"), loc.body(cols("editions"))
    tabFootnote "Its talks in each edition, 2002 to 2026.", loc.columnLabels(cols("per_year"))
    tabSourceNote "FOSDEM's schedules and devroom pages; 2002–2006 partial."
    tabOptions(tableFontSize = "12px", dataRowPadding = "2px", columnLabelsFontSize = "11px",
               columnLabelsPaddingHorizontal = "2px", dataRowPaddingHorizontal = "2px")
  nbTable t

nbNote("""
The last column is a *nanoplot*, a bar chart as small as a word: `fmtNanoplot` draws a cell that
holds numbers, "12 15 0 ...", one bar per edition. The numbers are the devroom's events in each year
under any of its names, counted from `tracks.csv` (`talksPerYear`, at the top of the page); point
at a bar, or tap it, to read it. `colsMergeRange` again, for the first and the last year. The
longest run of consecutive editions comes from nanuq: the year minus the year's rank in its
devroom is the same number for the whole run (`col.year - col.year.rank.over("family")`), and a
group by counts it.
""", nkCode)

nbText: """
The bars show what the numbers alone did not: Mozilla's room grew to its largest in the years
of Firefox OS and then faded, Free Java was busiest in the years after Java became free, and
the rooms that still run (Embedded, Distributions, Legal and Policy) are as full as ever, or
fuller. Many changed their name on the way: FOSS Office had ten, from OpenOffice.org to
LibreOffice Technology. Some are languages (Java, Python, Go, Perl, Ada), some
communities of projects (BSD, Distributions), some topics that kept their room as the projects
in them changed (Legal and Policy, Virtualization, Containers).

How is a devroom matched across years, when its name changes? In two steps. First every name is
folded to a key: lower case, no accents or punctuation, without a leading "the" or a trailing
"devroom" or "track", so "Mozilla devroom" and "mozilla" are one. That is enough for most. Then
49 rules typed by hand join keys that are the same room under another name, such as Jabber,
XMPP and Real Time Communications. These are the devrooms the rules joined, with every name
they had:
"""

nbShowCode:
  let t = tabella(story("devroom_renames.csv"), rownameCol = "devroom"):
    optCssTheme()
    tabHeader "One devroom, many names", "the devrooms joined by hand, with every name and its years"
    colsHide "keys"
    colsLabel:
      first: "since"
      names: ""
    colsWidth:
      devroom: "34%"
      first: "44px"
    tabStyle style.text(size = "11.5px"), loc.body(cols("names"))
    tabStyle style.text(weight = "bold"), loc.stub()
    tabSourceNote "FOSDEM's schedules and devroom pages; the rules are in src/insights.nim."
    tabOptions(tableFontSize = "12px", dataRowPadding = "3px")
  nbTable t

nbNote("""
The table is made in nanuq: each devroom's names are grouped by their key, written as "name
(first–last)" with `format`, and joined in order with `str.join("; ")`. A name can overlap the
next one: Free Java and Java were both used in 2014 and 2015. `colsWidth` is a block too.
""", nkCode)
nbText: """

### How many are new each year?

Every year, some devrooms are new, most continue, a few come back, and some run for the last
time. The decades add up:
"""

nbShowCode:
  let t = tabella(story("devroom_flow.csv"), rownameCol = "year", groupnameCol = "decade"):
    optCssTheme()
    tabHeader "Coming and going", "devrooms of every edition, by where they come from"
    tabSpanner "of which", ["new", "continuing", "back"]
    colsLabel:
      continuing: "from the year before"
      last_time: "last time"
    summaryRows:
      total: agg.sum
      columns = ["new", "back", "last_time"]
      missingText = ""
    subZero "last_time", rows = where(it.year == 2027), zeroText = ""
    tabStyle style.fill(tint("--success-soft")), loc.body(cols("new"), rows = where(13 <= it.new))
    tabFootnote "Not held again up to 2027.", loc.columnLabels(cols("last_time"))
    tabFootnote "Partial: the old sites list some devrooms without their pages.",
      loc.stub(rows = where(it.year <= 2006))
    tabSourceNote "FOSDEM's schedules and devroom pages; 2002–2006 partial."
    tabOptions(tableFontSize = "13px", dataRowPadding = "2px", summaryRowPadding = "2px")
  nbTable t

nbNote("""
Summary rows per decade again, on three columns of five. The statuses come from a window in
nanuq: the year before a devroom's year is `col.year.shift(1).over("family")`, and the next one
`shift(-1)`. `subZero` empties the "last time" of 2027, which nothing can say yet.
""", nkCode)

nbText: """
The years of change are the last three: 13 new devrooms in 2025, 14 in 2026, 21 in 2027, and 20
of 2025's and 19 of 2026's not held again. FOSDEM is not only bigger than ten years ago; its
devrooms turn over faster.
"""

nbText: """
## C · The people

### Who gives the keynotes?

The first talk on Saturday morning, in Janson, the biggest hall of the ULB, after the
welcome, opens FOSDEM. Richard Stallman gave the first, on software patents, and two
more; then came the founders of O'Reilly, Wikipedia, the Software Freedom Law Center, Jenkins,
systemd. It is not the only keynote: from 2007, when the schedule starts to mark them, to
2025, Janson has one or two more on Saturday and usually one at the end of Sunday, before the
closing. Here is every one, the opening keynote of each year shaded; a title opens the talk's
page at FOSDEM, ▶ its recording:
"""

nbTabs(python = "", r = gtCell("keynotes <-")):
  nbCode:
    var lastYear = 0
    let keynotes = story("keynotes.csv")
      .withColumn("title", proc (it: Row): Value = link($it.title, $it.url))   # a link to the talk
      .withColumn("day", proc (it: Row): Value = toValue(($it.day)[0 .. 2]))
      .withColumn("edition", proc (it: Row): Value =        # the year, on its first keynote only
        let y = it.year.toFloat.int
        result = toValue(if y == lastYear: "" else: $y)
        lastYear = y)
    let opening = where(it.opening == true)
    let t = tabella(keynotes, rownameCol = "edition"):
      optCssTheme()
      tabHeader "The keynotes", "every edition; shaded, the one that opened it"
      colsHide ["year", "opening", "start", "room", "url"]
      subMissing "by", missingText = "Richard Stallman"
      fmtMarkdown "title"
      colsMerge ["title", "by"], pattern = "{1}<br>{2}"
      fmtUrl "video", label = "▶"
      subMissing "video", missingText = ""
      colsLabel:
        day: ""
        title: ""
        video: ""
      tabStyle style.fill(tint("--primary-soft")), loc.body(rows = opening), loc.stub(rows = opening)
      tabStyle style.text(size = "12px", color = tint("--muted")), loc.body(cols("day"))
      tabFootnote "The schedule says only \"RMS\".", loc.body(cols("title"), rows = where(it.year == 2002))
      tabFootnote "Online: no keynotes; the first talk of the day, in the community track.",
        loc.body(cols("title"), rows = where(it.year == 2021 or it.year == 2022))
      tabSourceNote md("FOSDEM's schedules ([archive.fosdem.org](https://archive.fosdem.org/)): talks of type keynote, 2007–2025, without the welcome, the closing and the quiz; before 2007 and in 2026, the opening talk only.")
      tabOptions(tableFontSize = "13px", dataRowPadding = "3px")
  nbTable t

nbNote("""
This is the one table of the story shown in two languages, the Nim that makes it now and the R
with gt it was first written in: it is the one that needed the most of 0.2. A title becomes a
Markdown link (`link`, this story's own, then `fmtMarkdown`), and `colsMerge` puts the speakers
under it in the same cell, with the pattern `{1}<br>{2}`. `fmtUrl` turns each recording into a
▶. The year is shown once, on the first keynote of each year: gt changes the stub's text with
`text_transform`, the Nim makes the column so. nanuq picks the opening talk and joins it to the
keynotes.
""", nkCode, "Two languages, once")

nbText: """
The early openings were about freedom, patents and licences. From 2012 they are about how
projects are made and kept (communities, money, the kernel), and in 2025 about how one learns
to program. Among the others: Greg Kroah-Hartman on a first kernel patch in 2010, Chris Lattner
on LLVM in 2011, Poul-Henning Kamp on the NSA in 2014. 2025 had ten.

### Who keeps coming back?

About 7,500 people spoke at FOSDEM at least once. Michael Meeks, of LibreOffice, spoke at 22 editions,
from 2002 to 2026; these fifteen spoke at the most, with their talks in each edition from 2001
to 2026:
"""

nbShowCode:
  let top = story("speakers_top.csv")
  let perEdition = talksPerEdition(top["person"].values.mapIt($it))
  let t = tabella(top, rownameCol = "person"):
    optCssTheme()
    tabHeader "Coming back", "the people who spoke at the most editions"
    colsAdd "per_edition", proc (r: Row): Value = toValue(perEdition[$r.person])
    colsHide ["first_year", "last_year"]
    tabSpanner "talks", ["talks", "keynotes", "main_track_talks", "devroom_talks"]
    colsLabel:
      talks: "all"
      keynotes: "keynote"
      main_track_talks: "main"
      devroom_talks: "devroom"
      per_edition: "by year"
    subZero ["keynotes", "main_track_talks"], zeroText = ""
    fmtNanoplot "per_edition", plotType = "bar", plotHeight = "1em", options = bars
    colsAlign alRight, ["talks", "keynotes", "main_track_talks", "devroom_talks"]
    tabFootnote "Talks in each edition, 2001 to 2026.", loc.columnLabels(cols("per_edition"))
    tabStyle style.text(weight = "bold"), loc.body(cols("editions"))
    tabSourceNote "FOSDEM's schedules; a person is a name matched across years (case, accents and nicknames folded)."
    tabOptions(tableFontSize = "12px", dataRowPadding = "2px", columnLabelsFontSize = "11px",
               columnLabelsPaddingHorizontal = "2px", dataRowPaddingHorizontal = "2px")
  nbTable t

nbNote("""
`subZero` leaves the cells empty where there are no keynotes or main-track talks, so the
table shows where each one spoke. The nanoplot is new in the port: each person's talks in each
edition, counted from `event_speakers.csv` (`talksPerEdition`, at the top of the page). It
takes the place of the first and the last year, which the R version merged into one column: the
bars show them, and the gaps between. The
names are matched in nanuq with a folded key: "Richard \"RichiH\" Hartmann" and "Richard
Hartmann" are one person.
""", nkCode)

nbText: """
Almost all of them speak in a devroom: the people who come back are the people who run a
community's room, or speak in one, every year. Michael Meeks and Thorsten Behrens in the office
suites' room, Tom Marble in Legal and Policy, Mark Reinhold and Roman Kennke in Free Java,
Robert Kaiser in Mozilla's, Frédéric Descamps in MySQL's. The bars show the two ways of coming
back: a talk or two every year, for twenty years, or many talks in a few years, in a room one
runs.

### How many speak for the first time?

Yet FOSDEM is mostly new faces: every year since 2007, more than half of the speakers had
never spoken there before. And the devrooms' calls, posted to the FOSDEM mailing list, often
come from someone who will speak too:
"""

nbShowCode:
  let t = tabella(story("newcomers.csv"), rownameCol = "year", groupnameCol = "decade"):
    optCssTheme()
    tabHeader "New faces", "speakers of every edition, and the devrooms' calls"
    tabSpanner "speakers", ["speakers", "first_time_speakers", "returning", "first_time_share"]
    tabSpanner "devroom calls", ["cfp_posts", "cfp_by_speaker"]
    fmtPercent "first_time_share", decimals = 0
    colsMergeNPct "first_time_speakers", "first_time_share"
    tabStyle style.text(whitespace = "nowrap"), loc.body(cols("first_time_speakers"))
    fmtInteger ["speakers", "first_time_speakers", "returning"]
    colsLabel:
      speakers: "all"
      first_time_speakers: "first time"
      returning: "again"
      cfp_posts: "posted"
      cfp_by_speaker: "by a speaker"
    summaryRows:
      total: agg.sum
      columns = ["cfp_posts", "cfp_by_speaker"]
      missingText = ""
    subZero ["cfp_posts", "cfp_by_speaker"], zeroText = ""
    tabFootnote "Calls posted to fosdem@lists.fosdem.org; before 2011 devrooms announced on their own lists.",
      loc.spanners("devroom calls")
    tabSourceNote "FOSDEM's schedules and the fosdem@ mailing list archive."
    tabOptions(tableFontSize = "13px", dataRowPadding = "2px", summaryRowPadding = "2px")
  nbTable t

nbNote("""
`colsMergeNPct` writes the share beside the count, "719 (59%)", and hides the share's own
column. A call is "by a speaker" when its sender spoke at the same edition: FOSDEM publishes no
list of who runs a devroom, so the sender is the closest trace.
""", nkCode)

nbText: """
Six speakers in ten are new every year, and the share hardly moves: 59% in 2009, and again in 2026.
FOSDEM grew from 176 speakers to 1,216 without becoming a club. Four calls in ten come from
someone who also speaks, the devroom's organisers giving a talk in their own room.
"""

nbText: """
## A coda · Nim at FOSDEM

tabelline is written in Nim, so one last table: every FOSDEM talk about Nim, or about a project
built with it. Before 2019 there is none. Then Nim found a home in the devroom of minimalistic
and emerging languages, had a devroom of its own in 2022, online (its call went out on
[nim-lang.org](https://nim-lang.org/blog.html), and the author of tabelline was among its
organisers), and turned up in other rooms: Nimbus, an Ethereum client, in 2019; Chalk, the
supply-chain tool written in Nim by John Viega's Crash Override, in the testing devroom in 2024;
Nim for Pythonistas in the Python devroom in 2025. In 2018 Nim had a stand.
"""

nbShowCode:
  let nim = story("nim.csv")
    .withColumn("title", proc (it: Row): Value =
      link(if it["kind"] == "stand": "The Nim stand" else: $it.title, $it.url))
    .withColumn("track", proc (it: Row): Value =
      if it["kind"] == "stand":       # "K (level 2)" is "building K, level 2"
        toValue("building " & ($it.track).replace(" (level ", ", level ").strip(chars = {')'}))
      else: toValue(($it.track).replace(" devroom", "")))
    .withColumn("how", proc (it: Row): Value =       # said only when the talk is not about Nim
      if it.how == "about Nim" or it.how == "stand": null() else: toValue("*" & $it.how & "*"))
  let t = tabella(nim, groupnameCol = "year"):
    optCssTheme()
    tabHeader "Nim at FOSDEM", "the talks about Nim, or about projects built with it"
    colsHide ["kind", "url"]
    colsMoveToStart "title"
    fmtMarkdown "title"
    colsMerge ["title", "by"], pattern = "{1}<<<br>{2}>>"
    fmtMarkdown "how"
    colsMerge ["track", "how"], pattern = "{1}<<<br>{2}>>"
    fmtUrl "video", label = "▶"
    subMissing "video", missingText = ""
    colsLabel:
      title: "talk"
      track: "devroom"
      video: ""
    tabStyle style.text(size = "12px"), loc.body(cols("track"))
    tabStyle style.fill(tint("--primary-soft")), loc.body(rows = where(it.track == "Nim Programming Language"))
    tabFootnote "Online, with a devroom of its own.", loc.rowGroups("2022")
    tabSourceNote md("FOSDEM's schedules: titles with \"Nim\", the 2022 Nim devroom, and abstracts read by hand (talks that only mention Nim are left out); the stand from [archive.fosdem.org/2018/stands](https://archive.fosdem.org/2018/stands/).")
    tabOptions(tableFontSize = "13px", dataRowPadding = "3px")
  nbTable t

nbNote("""
The pattern `{1}<<<br>{2}>>` of `colsMerge` writes the second value only when there is one
(the stand has no speaker). The devroom gets a second line, in italics, only for the talks
that are not about Nim itself: the same pattern, on another pair of columns, with the
second one written as Markdown emphasis (`*built with Nim*`) and shown by `fmtMarkdown`. The list is made in
nanuq: a regex on the titles, the 2022 devroom, four talks added by hand after reading the
abstracts, and the stand from `stands.csv`.
""", nkCode)

nbText: """
Nineteen talks in seven years, by fifteen speakers; Peter Munch-Ellingsen gave five of them, and
Andreas Rumpf, who made Nim, two. Every one was recorded.
"""

nbPart 2, "", prSecondary   # the closing sections: how it is built
nbText: """
## How this story is built

From zero, in four layers. How the data was made, its schema and the checks it passes are told
in a story of their own: [FOSDEM's data, made with nanuq](../fosdem-data/).

**1. The raw data** is FOSDEM's own: the schedule of every edition from archive.fosdem.org (an
XML export from 2012, the web pages before), the history of the devrooms' calls in the source
of FOSDEM's website on GitHub, the fosdem@ mailing list archive (only senders, dates and
subjects), and fosdem.org's news of 2027. `src/fetch.sh` downloads them, about 200 MB, which
are not committed.

**2. The tables** are made in two steps. Short Nim scripts (standard library only) flatten
each raw format into staging CSV files; then `src/process.nim`, written with nanuq (Polars for
Nim), cleans, joins and counts them into the ten tables of `docs/stories/data/fosdem/`. Its
README says what is complete for each year. Two runs give the same files, byte for byte.

**3. The story's small tables** come from those ten with nanuq again, in `src/insights.nim`:
the dates, the sizes, the online years, the devroom families (a folded name plus 49 renames
typed by hand), the opening talks, the speakers. Each is a CSV in `story/`, with a `#` line
saying what it is made from. The two series of the nanoplots are counted on the page itself,
with Nim's standard library, from `tracks.csv` and `event_speakers.csv`.

**4. The tables on this page** are tabelline 0.2: `nbShowCode` (in `docs/blocks.nim`) runs a
cell of Nim and shows the table it makes, with the code folded under it. Before 0.2 was built,
every table was written in R with gt, which already had what they needed, in cells that ran in
one R session; their R code and their HTML are kept in `story/fosdem-gt.json`, with the gt
version. The port is a table-by-table translation, verb by verb.

## From gt to tabelline

The gt functions the R version used, and what each became in the port:
"""

nbShowCode:
  let port = tableData:
    gt: ["summary_rows, grand_summary_rows", "cols_merge_range", "cols_merge_n_pct",
         "cols_merge", "cols_units", "text_case_match", "fmt_url, fmt_markdown, sub_missing, sub_zero",
         "text_transform on the stub", "data.frame, cut, order", "$col <-, filtering rows",
         "emoji", ""]
    tabelline: ["summaryRows, grandSummaryRows", "colsMergeRange", "colsMergeNPct",
                "colsMerge", "colsUnits", "textCaseMatch", "fmtUrl, fmtMarkdown, subMissing, subZero",
                "a stub column made in Nim", "tableData, withColumn, sortedBy", "colsAdd, rowsHide",
                "fmtIcon", "fmtNanoplot"]
    where: ["How big, the devrooms of 2027, coming and going, new faces",
            "One row, every FOSDEM, the stands, the longest-running, coming back", "New faces",
            "The keynotes, Nim at FOSDEM", "Online and back", "Every FOSDEM",
            "Most tables", "The keynotes", "Most tables", "One row, the longest-running, coming back",
            "Three parts of three", "The longest-running, coming back (new in the port)"]
    since: ["0.2", "0.2", "0.2", "0.2", "0.2", "0.2", "0.1", "0.1", "0.1", "0.2", "0.2", "0.2"]
  let t = tabella(port, rownameCol = "gt", groupnameCol = "since"):
    optCssTheme()
    tabHeader "From gt to tabelline", "the R functions of the first version, and the Nim of the port"
    rowGroupOrder ["0.2", "0.1"]
    textCaseMatch:
      "0.2": "new in tabelline 0.2"
      "0.1": "already in tabelline 0.1"
      locations = loc.rowGroups()
    colsLabel:
      tabelline: ""
      where: ""
    tabStyle style.text(font = "var(--mono)", size = "11px"), loc.stub(), loc.body(cols("tabelline"))
    tabStyle style.text(size = "11.5px"), loc.body(cols("where"))
    colsWidth:
      where: "34%"
  nbTable t

nbNote("""
Everything the R version needed is in tabelline 0.2, and the port adds two things gt also has
but the R did not use: icons and nanoplots. What stays different is how the data is shaped
before the table: R changes columns of a data frame in place (`keynotes$title <- ...`), and
tabelline's data is read only, so a column is added with `colsAdd` inside the table (new in
0.2), or, when the table is grouped or labelled by it, made before with this story's
`withColumn`; rows are left out with `rowsHide`. One bug came out of the port: `subZero` with an
empty text, `zeroText = ""`, left the zero there, because an empty substitution was read as
none; it is fixed, with a test, in the same change. gt's
`text_transform` on the stub sees only the text, not the row, so showing a year once is a
column made in Nim.
""", nkCode)

nbSave
