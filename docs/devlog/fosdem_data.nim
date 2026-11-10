## devlog: 10 Nov 2026 A | FOSDEM's data, made with nanuq | Twenty-six years of FOSDEM schedules, from five kinds of web page to ten tidy tables, cleaned, joined and counted with nanuq, Polars for Nim, in under a second. The nanuq code that makes them, what nanuq did well and where it pinched, the schema of every table, and the checks that say the tables hold together.
## A dated post about how the data of the FOSDEM story (docs/stories/data/fosdem/) was made. It
## does not need nanuq: it reads the committed CSVs with the standard library, and quotes the
## nanuq code from src/process.nim as text. The checks run on the data every time the page is
## built. The meaning of each column is written by hand in devlog/data/fosdem_data/columns.csv.
import std/[os, strutils, sequtils, tables, sets, parsecsv, streams, times, algorithm]
import nimib except md
import tabelline, tabelline/nimib
import ../blocchi

let docs = currentSourcePath().parentDir.parentDir
let fosdem = docs / "stories" / "data" / "fosdem"
let process = readFile(fosdem / "src" / "process.nim")
nbInit
nb.doc.filename = docs / "devlog" / "fosdem-data" / "index.html"
nb.useTabelline(nome = "tabelline",
                title = "FOSDEM's data, made with nanuq", homeHref = "../", backLabel = "Devlog", nameHref = "../../")

type Row = Table[string, string]

proc load(path: string): seq[Row] =
  ## A CSV as rows of strings, skipping the `#` line that names its sources.
  var p: CsvParser
  p.open(newStringStream(readFile(path).splitLines.filterIt(not it.startsWith("#")).join("\n")), path)
  p.readHeaderRow()
  while p.readRow():
    var r: Row
    for c in p.headers: r[c] = p.rowEntry(c)
    result.add r

proc excerpt(start: string): string =
  ## The code of src/process.nim from the line that starts with `start` to the next blank line.
  var lines = process.splitLines
  var i = 0
  while not lines[i].startsWith(start): inc i
  var j = i
  while j < lines.len and lines[j].strip.len > 0: inc j
  "```nim\n" & lines[i ..< j].join("\n") & "\n```"

let names = ["editions", "tracks", "rooms", "events", "event_speakers", "people",
             "cfp_listings", "cfp_posts", "mailing_list_years", "stands"]
var data: Table[string, seq[Row]]
for n in names: data[n] = load(fosdem / n & ".csv")
let ev = data["events"]

nbTitolo "10 November 2026", "FOSDEM's data, made with nanuq", """
Twenty-six years of FOSDEM schedules, from five kinds of web page to ten tidy tables, cleaned,
joined and counted with nanuq, Polars for Nim, in under a second.
"""

nbText: """
tabelline makes display tables from data that is already processed. For the FOSDEM story the
processing is done by [nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim: the
data frame library of Rust and Python, written with Nim's syntax. This is the first time nanuq
made a whole dataset from raw files, end to end, and it is worth showing how: every table of
the story comes out of about 750 lines of nanuq, which run in less than a second and give the
same files, byte for byte, every time.
"""

nbNota("""
Green cards like this one are about how the page is made. This post does not use nanuq: it
reads the CSV files nanuq wrote with Nim's standard library, and quotes the nanuq code from
`src/process.nim` as it is.
""", nkCode, "Reading the code")

nbIndice()

nbText: """
## One expression to start

The smallest piece of the work is a name. FOSDEM prints a speaker's name as the speaker typed
it, so the same person comes back with accents or without, with a nickname, in other cases.
To count who keeps coming back, every name gets a key. In nanuq that is one expression, built
from string operations as in Polars, and kept in a proc so it can be used on any column:
""" & excerpt("proc nameKey") & """

Six people, each showing one thing the key folds:
"""

nbShowCode:
  type Spellings = object
    key, folds, spellings: string
  var seen: Table[string, OrderedSet[string]]
  for s in data["event_speakers"]:
    seen.mgetOrPut(s["person_key"], initOrderedSet[string]()).incl s["person"]
  let picked = [("richard hartmann", "a nickname"), ("jon maddog hall", "quotes, case"),
                ("kris nova", "accents, case"), ("adrien beraud", "an accent"),
                ("helge hess", "ß is ss"), ("aeva black", "Æ is ae")]
  var rows: seq[Spellings]
  for (k, why) in picked:
    rows.add Spellings(key: k, folds: why, spellings: seen[k].toSeq.join(" · "))
  let t = tabella(rows, rownameCol = "key"):
    optCssTheme()
    tabHeader "One person, many spellings", "the key, what it folds, and the names as printed"
    colsLabel {"key": "", "folds": "folds", "spellings": "as printed"}
  nbTable t

nbText: """
The key is not clever on purpose: it does not know that "RMS" is Richard Stallman. It is
cheap, it is the same on every run, and the story says where it fails.

## Three steps, one of them nanuq

The data goes from FOSDEM's websites to ten tables in three steps, each in the tool that suits it:
"""

nbShowCode:
  type Step = object
    step, tool, does: string
    files: int
  let src = fosdem / "src"
  var py = 0
  for f in walkFiles(src / "extract_*.py"): inc py
  let rows = @[
    Step(step: "1. fetch", tool: "shell: curl, wget, git", files: 1,
         does: "download the archive's pages, XML, mailing list and website history, about 200 MB"),
    Step(step: "2. flatten", tool: "Python, standard library", files: py,
         does: "read HTML, XML, YAML and mbox, write one staging CSV per format"),
    Step(step: "3. process", tool: "Nim with nanuq", files: 2,
         does: "clean, join and count: the ten tables, then the story's small ones")]
  let t = tabella(rows, rownameCol = "step"):
    optCssTheme()
    tabHeader "From the web to ten tables", "the scripts in src/, in the order build.sh runs them"
    colsLabel {"step": "", "files": "scripts", "does": "what it does"}
    colsMoveToEnd ["does"]
  nbTable t

nbText: """
The first two steps only move bytes around: the old FOSDEM sites are HTML written by hand, one
layout a year, and Python's parsers read them in a few lines each. Everything that needs a
decision (what a talk is, who a person is, which devroom is which) happens in the third step,
in nanuq. The raw files are not committed; the ten tables are.

## Five sources, one table of events

Twenty-six years of schedules come in five shapes: the XML export (2012 on), the event index
of the old site (2007–2011), the devroom pages (2007–2010), the printed grid (2001–2006) and the
early devroom pages (2004–2006). Each becomes a lazy frame with the same columns, and nanuq
stacks them:
""" & excerpt("let cols = ") & """

A lazy frame is a plan, not data: nanuq (Polars underneath) reads the CSV, filters, joins and
groups only when `collect` is called, and in the best order it finds. Here is what each shape
gave:
"""

nbShowCode:
  type Source = object
    source, years: string
    events: int
  var bySource: OrderedTable[string, (int, int, int)]   # events, first year, last year
  for e in ev:
    let y = e["year"].parseInt
    let (n, lo, hi) = bySource.getOrDefault(e["source"], (0, 9999, 0))
    bySource[e["source"]] = (n + 1, min(lo, y), max(hi, y))
  var rows: seq[Source]
  for s, (n, lo, hi) in bySource:
    rows.add Source(source: s, events: n, years: $lo & "–" & $hi)
  rows.sort(proc (a, b: Source): int = cmp(b.events, a.events))
  let t = tabella(rows, rownameCol = "source"):
    optCssTheme()
    tabHeader "Where the events come from", "the source column of events.csv"
    colsLabel {"source": ""}
    fmtInteger "events"
  nbTable t

nbText: """
## One vocabulary for twenty-five years

Each source names its slots in its own way: `maintrack`, `lecture`, `devroom`, `lightningtalk`,
or nothing at all, with the kind hidden in the track's name. nanuq's `choose` reads like an
`if`/`elif` chain and becomes one Polars `when/then/otherwise` expression, so the whole
vocabulary is in one place:

```nim
choose(
  if col("type") == "keynote" or (col("type") == "maintrack" and col.track.str.contains(mainTrackWords)): "keynote"
  elif col("type").isIn(["maintrack", "lecture"]): "main track"
  elif col("type") == "devroom" or col.track.str.contains(r"(?i)devroom|developer room"): "devroom"
  elif col("type").isIn(["lightning", "lightningtalk"]) or col.track.str.contains(r"(?i)lightning"): "lightning talk"
  # ... eleven more cases, for BOFs, stands, workshops and the years 2011 and 2012
  else: "other"
).alias("kind")
```

What it made of FOSDEM's own words:
"""

nbShowCode:
  type Kind = object
    kind, fromTypes: string
    events: int
  var count: CountTable[string]
  var types: Table[string, CountTable[string]]
  for e in ev:
    count.inc e["kind"]
    let st = if e["source_type"] == "": "(none)" else: e["source_type"]
    types.mgetOrPut(e["kind"], initCountTable[string]()).inc st
  var rows: seq[Kind]
  for k, n in count:
    var ts = types[k]
    ts.sort()
    rows.add Kind(kind: k, events: n, fromTypes: ts.keys.toSeq[0 ..< min(3, ts.len)].join(", "))
  rows.sort(proc (a, b: Kind): int = cmp(b.events, a.events))
  let t = tabella(rows, rownameCol = "kind"):
    optCssTheme()
    tabHeader "The kinds of event", "the kind column of events.csv, and the schedule types it comes from most"
    colsLabel {"kind": "", "fromTypes": "mostly from"}
    fmtInteger "events"
  nbTable t

nbText: """
## Joined, grouped, counted

The rest is what data frames are for. People are the speakers grouped by their key, with a
handful of aggregations in one `agg`; `over` would do the same per group without grouping:
""" & excerpt("let people = ") & """

The devrooms are a full join: the tracks that have talks, and the devrooms the old sites only
list by name, matched on a folded name, with `coalesce` so the key columns meet in one:

```nim
let tracks = fromEvents
  .join(listed, on = ["year", "tkey"], how = JoinType.Full, coalesce = some(true))
```

## What nanuq did well, and where it pinched

This was nanuq's first long job, and it went well: about 420 lines make the ten tables, 330
more the story's small ones, and both run in a fraction of a second. Writing it also found a
few rough edges, which are nanuq's to-do list now:
"""

nbShowCode:
  type Note = object
    what, how: string
  let good = @[
    Note(what: "lazy frames", how: "read, join and group, collect once; fast enough to rerun on every change"),
    Note(what: "choose", how: "an if/elif chain that is one expression: 25 years of vocabulary in one place"),
    Note(what: "expressions in procs", how: "nameKey, minutesOf, hhmm: written once, used on any column"),
    Note(what: "str and regex", how: "Unicode NFKD, replaceAll, extract: the Polars string namespace, all there"),
    Note(what: "concat", how: "vertical relaxed and diagonal relaxed: five sources with different columns stack"),
    Note(what: "same output", how: "with explicit sorts, two runs write the same files, byte for byte")]
  let pinch = @[
    Note(what: "col.type", how: "type is a Nim keyword: a long type-mismatch error; col(\"type\") works"),
    Note(what: "col[\"end\"]", how: "not supported; col(\"end\") works, and newDataFrame wants \"end\" quoted"),
    Note(what: "coalesce", how: "the join wants some(true), not true"),
    Note(what: "writeCsv", how: "no comment option: the # line is added after"),
    Note(what: "errors", how: "ColumnNotFoundError comes with an empty message"),
    Note(what: "row order", how: "joins reorder rows: ids made after a join changed between runs")]
  type Line = object
    side, what, how: string
  var rows: seq[Line]
  for n in good: rows.add Line(side: "did well", what: n.what, how: n.how)
  for n in pinch: rows.add Line(side: "pinched", what: n.what, how: n.how)
  let t = tabella(rows, rownameCol = "what", groupnameCol = "side"):
    optCssTheme()
    tabHeader "nanuq, after its first long job", "what made the work easy, and what got in the way"
    colsLabel {"what": "", "how": ""}
  nbTable t

nbNota("""
None of the pinches stopped the work, and each has a workaround in `process.nim`. The last one
is the only one that could have gone unnoticed: Polars does not keep the row order of a join
unless asked, so numbering rows after a join gave different ids on different runs. Numbering
before the join, and sorting before every write, fixed it.
""", nkWarning)

nbText: """
## The ten tables

What nanuq writes: ten CSV files in `docs/stories/data/fosdem/`, each with a first `#` line
naming its sources, so tabelline's `readCsv(path, comment = "#")` reads it as it is.
"""

nbShowCode:
  type FileRow = object
    group, file, years: string
    rows, columns: int
  let groups = {"editions": "the schedule", "tracks": "the schedule", "rooms": "the schedule",
                "events": "the schedule", "event_speakers": "the schedule", "people": "the schedule",
                "cfp_listings": "the calls", "cfp_posts": "the calls", "mailing_list_years": "the calls",
                "stands": "the floor"}.toTable
  var rows: seq[FileRow]
  for n in names:
    let rs = data[n]
    var years = ""
    for key in ["year", "edition", "first_year"]:
      if key in rs[0]:
        let ys = rs.mapIt(it[key]).filterIt(it.len >= 4).mapIt(it[0..3].parseInt)
        years = $ys.min & "–" & $ys.max
        break
    rows.add FileRow(group: groups[n], file: n, years: years, rows: rs.len, columns: rs[0].len)
  let t = tabella(rows, rownameCol = "file", groupnameCol = "group"):
    optCssTheme()
    tabHeader "Ten tables", "the files nanuq writes"
    colsLabel {"file": ""}
    fmtInteger ["rows", "columns"]
  nbTable t

nbText: """
And every column, with what it means and how often it is filled:
"""

nbShowCode:
  type Col = object
    table, column, meaning, filled: string
  var rows: seq[Col]
  for c in load(docs / "devlog" / "data" / "fosdem_data" / "columns.csv"):
    let rs = data[c["table"]]
    let full = rs.countIt(it[c["column"]] != "")
    rows.add Col(table: c["table"], column: c["column"], meaning: c["meaning"],
                 filled: $(full * 100 div rs.len) & "%")
  let t = tabella(rows, rownameCol = "column", groupnameCol = "table"):
    optCssTheme()
    tabHeader "Every column", "what it means, and how often it is filled"
    tabOptions(tableFontSize = "13px")
    colsLabel {"column": ""}
    colsAlign alRight, ["filled"]
  nbTable t

nbText: """
## How they join

The tables are tidy: one row per thing, a key per table, and the other tables point to it.
The checks below found two things while this post was written. The first: the key of an event
is its year *and* its id, because the XML export numbers events per year, so id 2411 is a talk
in 2014 and another in 2025. The second: one speaker of 2026, whose name is written in Chinese,
had an empty key, because the first `nameKey` kept only the letters a to z. It also turned ø, ł
and ß into spaces, so Helge Heß and Helge Hess were two people. The key above is the fixed one,
and the data was made again: 7,559 people instead of 7,561, and one first-time speaker fewer in
2009 and in 2026.
"""

nbShowCode:
  type Check = object
    group, check: string
    rows, wrong: int
  var rows: seq[Check]
  proc add(group, check: string, total, bad: int) =
    rows.add Check(group: group, check: check, rows: total, wrong: bad)
  proc keyOf(r: Row, cols: openArray[string]): string = cols.mapIt(r[it]).join("|")
  proc dupes(t: string, cols: openArray[string]) =
    var seen: HashSet[string]
    var bad = 0
    for r in data[t]:
      let k = r.keyOf(cols)
      if k in seen: inc bad else: seen.incl k
    add("each key is unique", t & ": " & cols.join(", "), data[t].len, bad)
  dupes("editions", ["year"])
  dupes("tracks", ["year", "track"])
  dupes("rooms", ["year", "room"])
  dupes("events", ["year", "event_id"])
  dupes("event_speakers", ["year", "event_id", "position"])
  dupes("people", ["person_key"])
  dupes("stands", ["year", "stand"])
  proc points(t, to: string, cols: openArray[string], toCols: openArray[string] = []) =
    let tc = if toCols.len > 0: @toCols else: @cols
    let keys = data[to].mapIt(it.keyOf(tc)).toHashSet
    var rs: seq[Row]
    for r in data[t]:
      if cols.allIt(r[it] != ""): rs.add r
    add("every pointer finds its row", t & " → " & to, rs.len, rs.countIt(it.keyOf(cols) notin keys))
  points("event_speakers", "events", ["year", "event_id"])
  points("event_speakers", "people", ["person_key"])
  points("events", "tracks", ["year", "track"])
  points("events", "rooms", ["year", "room"])
  points("events", "editions", ["year"])
  points("cfp_posts", "editions", ["edition"], ["year"])
  points("stands", "editions", ["year"])
  proc agrees(t, col, what: string, counted: CountTable[string], cols: openArray[string]) =
    let rs = data[t].filterIt(it[col] != "")
    add("every count agrees", what, rs.len, rs.countIt(it[col].parseInt != counted[it.keyOf(cols)]))
  var perYear, perEvent, perTrack, perRoom, perPostYear: CountTable[string]
  for e in ev:
    perYear.inc e["year"]
    if e["track"] != "": perTrack.inc e.keyOf(["year", "track"])
    if e["room"] != "": perRoom.inc e.keyOf(["year", "room"])
  for s in data["event_speakers"]: perEvent.inc s.keyOf(["year", "event_id"])
  for p in data["cfp_posts"]: perPostYear.inc p["date"][0..3]
  agrees("editions", "events", "editions.events = its events", perYear, ["year"])
  agrees("events", "speakers", "events.speakers = its speakers", perEvent, ["year", "event_id"])
  agrees("tracks", "events", "tracks.events = its events", perTrack, ["year", "track"])
  agrees("rooms", "events", "rooms.events = its events", perRoom, ["year", "room"])
  agrees("mailing_list_years", "cfp_posts", "mailing_list_years.cfp_posts = the posts", perPostYear, ["year"])
  let eds = data["editions"]
  add("every value makes sense", "editions start on a Saturday", eds.len,
      eds.countIt(it["start"].parse("yyyy-MM-dd").weekday != dSat))
  let timed = ev.filterIt(it["start"] != "" and it["end"] != "")
  add("every value makes sense", "events end after they start", timed.len,
      timed.countIt(it["start"] >= it["end"]))
  add("every value makes sense", "people: first year ≤ last year", data["people"].len,
      data["people"].countIt(it["first_year"] > it["last_year"]))
  let t = tabella(rows, rownameCol = "check", groupnameCol = "group"):
    optCssTheme()
    tabHeader "Checked", "run on the ten tables every time this page is built"
    tabOptions(tableFontSize = "14px")
    colsLabel {"check": "", "rows": "rows", "wrong": "wrong"}
    fmtInteger ["rows", "wrong"]
  nbTable t

nbText: """
Zero everywhere: the tables hold together. They also agree with themselves across files that
nanuq wrote separately, which is the best sign that nothing was lost between the steps. What the
checks cannot see is what FOSDEM's old sites never had: the schedules are complete from 2011,
partial before (the story marks those years), and there is no list of who organised a devroom.

## How this post is built

The post reads the ten CSV files with Nim's `parsecsv`, as rows of strings, and makes every
table and check from them with tabelline: no nanuq is needed to build the site. The nanuq code
above is read from `src/process.nim` when the page is built, so it is the code that made the
data. To make the data again, from the raw files:

```sh
sh src/fetch.sh raw                   # about 200 MB from archive.fosdem.org and friends
sh src/build.sh raw <nanuq checkout>  # Python flattens, nanuq makes the tables
```
"""

nbSave
