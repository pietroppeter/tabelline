## The small tables of the FOSDEM story (docs/stories/fosdem.nim), computed with nanuq from the
## tidy tables of docs/stories/data/fosdem/.
##
##   nim r -d:release --hints:off --path:<nanuq>/src insights.nim <data dir> <out dir>
##
## Every output is a CSV with a `#` line naming what it is made from, read by the story with
## `readCsv(path, comment = "#")`. The devroom families (renames) are written here by hand.

import std/[os, sequtils]
import nanuq

let data = paramStr(1)
let outDir = paramStr(2)
createDir(outDir)

proc rd(name: string): LazyFrame =
  readCsv(data / name, inferSchemaLength = none(int), commentPrefix = "#").lazy

proc save(df: DataFrame, name, comment: string) =
  let path = outDir / name
  df.writeCsv(path)
  writeFile(path, "# " & comment & "\n" & readFile(path))
  echo name, ": ", df.height, " rows x ", df.width, " columns"

proc trackKey(e: Expr): Expr =
  ## As in process.nim: the name of a track folded to match it across years.
  e.str.normalize(UnicodeForm.NFKD).str.replaceAll(r"\p{Mn}", "")
   .str.toLowercase.str.replaceAll(r"[^a-z0-9]+", " ").str.stripChars
   .str.replace(r"^the ", "")
   .str.replace(r"( (devroom|dev room|developer room|developers room|track)s?)+$", "")

const lastYear = 2027      # the edition announced so far
const lastHeld = 2026      # the last edition with a schedule

# ---------------------------------------------------------------- A. the editions

let editions = rd("editions.csv")

# A1: the dates. Which weekend of the year: FOSDEM is the weekend after the end of January.
editions.withColumns(
    col.start.str.strptime(Date, "%Y-%m-%d").alias("d"),
  ).withColumns(
    col.d.dt.ordinalDay.alias("day_of_year"),
    col.d.dt.weekday.alias("wd"),
    # since 2011 the Saturday falls between 30 January (day 30) and 5 February (day 36)
    (col.d.dt.ordinalDay >= 30 and col.d.dt.ordinalDay <= 36).alias("in_window"),
  ).select(col.year, col.edition, col.name, col.start, col("end"), col.format, col.venue,
           col.day_of_year, col.in_window,
           # the edition's site: archived, or fosdem.org for the next one
           choose(if col.year > lastHeld: format("https://fosdem.org/{}/", col.year)
                  else: format("https://archive.fosdem.org/{}/", col.year)).alias("url"))
  .sort("year").collect
  .save("dates.csv", "The dates of every FOSDEM edition, from editions.csv; day_of_year is the day of the year of the Saturday; in_window: it falls between 30 January and 5 February.")

# A2: how big, by decade.
editions.filter(col.year <= lastHeld).withColumns(
    choose(if col.year < 2010: "2001–2009" elif col.year < 2020: "2010–2019" else: "2020–2026").alias("decade"),
  ).select(col.decade, col.year, col.events, col.devrooms, col.devroom_talks, col.main_track_talks,
           col.lightning_talks, col.speakers, col.coverage)
  .sort("year").collect
  .save("sizes.csv", "Events, devrooms and speakers of every edition held, from editions.csv.")

# A3: the online years, and the years around them.
let events = rd("events.csv")
let talkKinds = ["keynote", "main track", "devroom", "lightning talk"]
let lengths = events.filter(col.kind.isIn(talkKinds) and col.duration_min > 0)
  .groupBy(col.year).agg(col.duration_min.median.alias("median_minutes"))
editions.filter(col.year >= 2018 and col.year <= lastHeld)
  .join(lengths, on = ["year"], how = JoinType.Left)
  .withColumns((col.events_with_video / col.events).alias("with_video"))
  .select(col.year, col.format, col.events, col.devrooms, col.rooms, col.speakers,
          col.median_minutes, col.with_video)
  .sort("year").collect
  .save("online.csv", "The editions of 2018-2026 (2021 and 2022 online), from editions.csv and events.csv; median_minutes of talks (keynotes, main track, devrooms, lightning).")

# ---------------------------------------------------------------- B. the devrooms

# A family is the same devroom under its names. Most renames only drop or add words, and the
# folded key already matches them; these are the ones that need a hand. First match wins.
const families = [
  (r"^mysql|mariadb", "mysql"),
  (r"^micro ?kernel", "microkernels"),
  (r"virtuali[sz]ation|^infrastructure as a service", "virtualization"),
  (r"^llvm", "llvm"),
  (r"^hpc", "hpc"),
  (r"^jabber|^xmpp|^real time communications|^telephony|^open source telephony", "rtc"),
  (r"java$|openjdk|classpath", "free java"),
  (r"openoffice|libreoffice|open document editors|^foss office", "office"),
  (r"^bsd$|^bsd illumos", "bsd"),
  (r"crossdesktop|^cross desktop|^desktops$", "crossdesktop"),
  (r"game development", "games"),
  (r"^config(uration)? (and |systems )*management|^infra management", "config"),
  (r"^testing and|^continuous integration|^test$", "testing"),
  (r"^collaborati", "collaboration"),
  (r"^open research", "open research"),
  (r"trusted computing|^confidential computing", "confidential"),
  (r"^erlang", "erlang"),
  (r"^amateur radio$", "amateur radio"),
  (r"radio", "radio"),
  (r"^monitoring", "monitoring"),
  (r"cad|open hardware", "hardware"),
  (r"^legal", "legal"),
  (r"^embedded$|^embedded and mobile|^embedded mobile", "embedded"),
  (r"^crossdistro|^cross ?distr", "distributions"),
  (r"^perl|^raku", "perl"),
  (r"^ruby", "ruby"),
  (r"^decentrali[sz]ed internet", "decentralized internet"),
  (r"^python", "python"),
  (r"^php", "php"),
  (r"^gnustep|^world of gnustep", "gnustep"),
  (r"^x org|^xorg", "x org"),
  (r"^gcc", "gcc"),
  (r"^matrix", "matrix"),
  (r"^energy", "energy"),
  (r"^emulator", "emulator"),
  (r"^foss on mobile", "foss on mobile"),
  (r"^image based linux", "image based linux"),
  (r"^software bill|^sboms", "sbom"),
  (r"^open source in the european|^open source eu policy", "eu policy"),
  (r"^apis", "apis"),
  (r"^educational|foss educational", "educational"),
  (r"^risc ?v", "risc v"),
  (r"^libre soc|vlsi", "fpga"),
  (r"^graph( |$)", "graph"),
  (r"^containers|^linux containers", "containers"),
  (r"^electronic design|^eda$", "eda"),
  (r"^wine", "wine"),
  (r"^open source search|^search$", "search"),
  (r"^backup", "backup"),
]

proc familyOf(key: Expr): Expr =
  var t = `when`(key.str.contains(families[0][0])).then(families[0][1])
  for (pat, fam) in families[1 .. ^1]:
    t = t.`when`(key.str.contains(pat)).then(fam)
  t.otherwise(key)

let rooms = rd("tracks.csv").filter(col.kind == "devroom")
  .withColumns(trackKey(col.track).alias("key"))
  .withColumns(familyOf(col.key).alias("family"))
  # one row per family and year: the busiest name of that year
  .sort(["family", "year", "events", "track"], descending = [false, false, true, false])
  .groupBy(col.family, col.year)
  .agg(col.track.first.alias("name"), col.events.sum.alias("events"),
       col.track.nUnique.alias("rooms_that_year"))
  .sort(["family", "year"])
  .withColumns(
    col.year.shift(1).over("family").alias("prev"),
    col.year.shift(-1).over("family").alias("next"),
    (col.year - col.year.rank(RankMethod.Ordinal).over("family").cast(Int64)).alias("run"),
  )
  .withColumns(choose(
      if col.prev.isNull: "new"
      elif col.prev == col.year - 1: "continuing"
      else: "back").alias("status"))
  .collect

# B1: the devrooms of 2027 and where they come from.
let byFamily = rooms.lazy.groupBy(col.family).agg(
    col.year.min.alias("first"), col.year.count.alias("editions"),
    col.name.filter(col.year == lastYear - 1).first.alias("name_last_year"),
    col.name.sortBy(col.year).last.alias("name"),
    col.name.unique.len.alias("names"),
  )
rooms.lazy.filter(col.year == lastYear)
  .join(byFamily, on = ["family"], how = JoinType.Left)
  .withColumns(choose(
      if col.status == "new": "new in 2027"
      elif col.status == "back": "back after a pause"
      elif col.first >= 2023: "since 2023 or later"
      elif col.first >= 2013: "since 2013–2022"
      else: "since before 2013").alias("group"),
    choose(if col.name_last_year.isNotNull and trackKey(col.name_last_year) != trackKey(col.name): col.name_last_year
           else: "").alias("was"))
  .join(rd("tracks.csv").filter(col.year == lastYear).select(col.track.alias("name"), col.cfp.fillNull("")),
        on = ["name"], how = JoinType.Left)
  .select(col.group, col.name.alias("devroom"), col.first, col.editions, col.was, col.cfp.fillNull(""))
  .sort(["first", "devroom"]).collect
  .save("devrooms_2027.csv", "The 78 devrooms accepted for FOSDEM 2027 and their history, from tracks.csv; a family is a devroom under its names (the renames matched in insights.nim).")

# B2: the devrooms that ran the most editions.
let streaks = rooms.lazy.groupBy(col.family, col.run).agg(len().alias("streak"))
  .groupBy(col.family).agg(col.streak.max.alias("longest_run"))
rooms.lazy.groupBy(col.family).agg(
    col.year.min.alias("first"), col.year.max.alias("last"), col.year.count.alias("editions"),
    col.events.sum.alias("talks"),
    col.name.sortBy(col.year).last.alias("devroom"),
    col.name.unique.sort.str.join("; ").alias("names"),
    col.name.nUnique.alias("n_names"),
  )
  .join(streaks, on = ["family"], how = JoinType.Left)
  .filter(col.editions >= 10)
  .withColumns((col.last == lastYear).alias("in_2027"))
  .sort(["editions", "first", "devroom"], descending = [true, false, false])
  .select(col.devroom, col.first, col.last, col.editions, col.longest_run, col.talks,
          col.n_names, col.names, col.in_2027)
  .collect
  .save("devrooms_longest.csv", "Devrooms held in ten editions or more, from tracks.csv: years, longest run of consecutive editions, talks, names.")

# B2b: the renames. A name folded to a key matches "Mozilla devroom" and "mozilla"; the families
# above join keys that differ. One row per family with more than one key: its names in order.
let raw = rd("tracks.csv").filter(col.kind == "devroom")
  .withColumns(trackKey(col.track).alias("key"))
  .withColumns(familyOf(col.key).alias("family"))
raw.sort(["family", "key", "year", "events", "track"], descending = [false, false, false, true, false])
  .groupBy(col.family, col.key)
  .agg(col.year.min.alias("from"), col.year.max.alias("to"), col.year.nUnique.alias("years"),
       col.track.last.str.replace(r"(?i)( dev ?room)+$", "").alias("name"))
  .withColumns(choose(
      if col("from") == col.to: format("{} ({})", col.name, col("from"))
      else: format("{} ({}–{})", col.name, col("from"), col.to)).alias("label"))
  .sort(["family", "from", "to", "key"])
  .groupBy(col.family)
  .agg(col.key.count.alias("keys"), col("from").min.alias("first"),
       col.label.str.join("; ").alias("names"),
       col.name.sortBy(col.to).last.alias("devroom"))
  .filter(col.keys > 1)
  .sort(["first", "devroom"])
  .select(col.devroom, col.first, col.keys, col.names)
  .collect
  .save("devroom_renames.csv", "Devrooms that ran under names that differ by more than case, punctuation or the word devroom, matched by the families of insights.nim: their names in order, with years, from tracks.csv.")

# B3: every year, how many devrooms were new, continued, came back, and did not come back.
rooms.lazy.withColumns(
    (col.next.isNull and col.year < lastYear).alias("last_time"))
  .groupBy(col.year).agg(
    len().alias("devrooms"),
    (col.status == "new").sum.alias("new"),
    (col.status == "continuing").sum.alias("continuing"),
    (col.status == "back").sum.alias("back"),
    col.last_time.sum.alias("last_time"))
  .withColumns(choose(if col.year < 2010: "2002–2009" elif col.year < 2020: "2010–2019" else: "2020–2027").alias("decade"))
  .select(col.decade, col.year, col.devrooms, col.new, col.continuing, col.back, col.last_time)
  .sort("year").collect
  .save("devroom_flow.csv", "Devrooms of each edition by where they come from (new, continuing from the year before, back after a pause) and how many never came back (last_time), from tracks.csv; 2002-2006 are partial, see README.md.")

# ---------------------------------------------------------------- C. the people

let speakers = rd("event_speakers.csv")
let people = rd("people.csv")

# C1: the keynotes. The opening talk of every edition is the first talk on Saturday in the main
# room (the room of the first talk of the day: A in 2001, Janson from 2002) that is not the
# welcome; online (2021, 2022), where the main room had only the welcome, the first talk of
# Saturday. From 2007 to 2025 the schedule marks the other keynotes too.
let saturday = events.filter(col.day == "Saturday" and col.kind.isIn(["keynote", "main track"]))
let mainRoom = saturday.sort(["year", "start", "room"]).groupBy(col.year)
  .agg(col.room.first.alias("main_room"))
let welcome = r"(?i)^(welcome|opening|introduction)( (talk|to fosdem( 20\d\d)?|and opening))?$|^(?i)welcome to fosdem"
let names = speakers.sort(["year", "event_id", "position"]).groupBy(col.year, col.event_id)
  .agg(col.person.str.join(", ").alias("by"))
let opening = saturday.join(mainRoom, on = ["year"]).filter(col.title.str.contains(welcome).not)
  .withColumns((col.room != col.main_room).alias("elsewhere"))
  .sort(["year", "elsewhere", "start", "room", "event_id"])
  .groupBy(col.year).agg(col.event_id.first)
  .withColumns(lit(true).alias("opening"))
let notKeynote = r"(?i)^(welcome|closing|donators return|the endgame)|highlights|quiz"
let others = events.filter(col.kind == "keynote" and col.title.str.contains(notKeynote).not)
  .join(names, on = ["year", "event_id"], how = JoinType.Left)
  .filter(col.by.isNotNull and col.by != "FOSDEM" and col.by != "FOSDEM Staff")
  .select(col.year, col.event_id)
concat([opening.select(col.year, col.event_id), others])
  .unique(["year", "event_id"], keep = UniqueKeepStrategy.First, maintainOrder = true)
  .join(events, on = ["year", "event_id"])
  .join(names, on = ["year", "event_id"], how = JoinType.Left)
  .join(opening, on = ["year", "event_id"], how = JoinType.Left)
  .withColumns(col.opening.fillNull(false), col.by.fillNull(""),
               choose(if col.day == "Saturday": 1 else: 2).alias("d"))
  .sort(["year", "opening", "d", "start", "event_id"], descending = [false, true, false, false, false])
  .withColumns(choose(if col.url == "": format("https://archive.fosdem.org/{}/", col.year) else: col.url).alias("url"))
  .select(col.year, col.opening, col.day, col.start, col.title, col.by, col.room, col.url, col.video)
  .collect
  .save("keynotes.csv", "The keynotes of every edition: the opening talk (first talk on Saturday in the main room after the welcome) of every year, and the other keynotes the schedule marks (2007-2025), without the welcome, closing and quiz; with links to each talk's page and video, from events.csv and event_speakers.csv.")

# C2: the people who spoke at the most editions.
people.filter(col.is_person)
  .sort(["editions", "talks", "person"], descending = [true, true, false]).head(15)
  .select(col.person, col.first_year, col.last_year, col.editions, col.talks, col.keynotes,
          col.main_track_talks, col.devroom_talks)
  .collect
  .save("speakers_top.csv", "The 15 people who spoke at the most FOSDEM editions, from people.csv.")

# C3: new faces, every year; and how many devroom calls came from someone who also spoke.
let cfp = rd("cfp_posts.csv").filter(col.kind == "devroom cfp")
  .groupBy(col.edition.alias("year")).agg(len().alias("cfp_posts"), col.sender_spoke.sum.alias("cfp_by_speaker"))
editions.filter(col.year >= 2007 and col.year <= lastHeld)
  .join(cfp, on = ["year"], how = JoinType.Left)
  .withColumns(
    (col.first_time_speakers / col.speakers).alias("first_time_share"),
    (col.speakers - col.first_time_speakers).alias("returning"),
    col.cfp_posts.fillNull(0), col.cfp_by_speaker.fillNull(0))
  .withColumns(choose(if col.year < 2010: "2007–2009" elif col.year < 2020: "2010–2019" else: "2020–2026").alias("decade"))
  .select(col.decade, col.year, col.speakers, col.first_time_speakers, col.returning,
          col.first_time_share, col.cfp_posts, col.cfp_by_speaker)
  .sort("year").collect
  .save("newcomers.csv", "Speakers of every edition from 2007 (the first with full main tracks and devroom pages), how many spoke for the first time, and the devroom calls posted to the fosdem@ list, from editions.csv, people.csv and cfp_posts.csv.")

# ---------------------------------------------------------------- D. Nim at FOSDEM

# Talks about Nim: the title says so, or the Nim devroom of 2022. Talks found in the abstracts
# of the schedule (2012-2026) are read and sorted by hand: about Nim, or about a project built
# with Nim. Talks that only name Nim in a list of languages are left out.
const nimByHand = [
  (2021, "11334", "about Nim"),          # Optimising for humans: Nim on micro-controllers
  (2019, "8698", "built with Nim"),      # Nimbus, Status' Ethereum client
  (2024, "2877", "built with Nim"),      # Chalk, by Crash Override
  (2025, "5848", "uses Nim"),            # transpiling to C with Nim and prescheme
]
let byHand = newDataFrame(series("year", nimByHand.mapIt(it[0])), series("event_id", nimByHand.mapIt(it[1])),
                         series("how", nimByHand.mapIt(it[2]))).lazy
let nimTalks = events
  .join(byHand, on = ["year", "event_id"], how = JoinType.Left)
  .filter(col.how.isNotNull or col.title.str.contains(r"\bNim\b") or col.track == "Nim Programming Language")
  .withColumns(col.how.fillNull("about Nim"))
  .join(names, on = ["year", "event_id"], how = JoinType.Left)
  .select(col.year, col.kind, col.track, col.title, col.by.fillNull(""), col.how, col.url, col.video)
let nimStand = rd("stands.csv").filter(col.stand_key == "nim")
  .select(col.year, lit("stand").alias("kind"), col.building.alias("track"), lit("Nim").alias("title"),
          lit("").alias("by"), lit("stand").alias("how"),
          format("https://archive.fosdem.org/{}/stands/", col.year).alias("url"), lit("").alias("video"))
concat([nimTalks, nimStand], how = ConcatMethod.VerticalRelaxed)
  .sort(["year", "kind", "track", "title"]).collect
  .save("nim.csv", "Nim at FOSDEM: talks about Nim or about projects built with it (titles, the 2022 Nim devroom, and abstracts read by hand), and the Nim stand, from events.csv, event_speakers.csv and stands.csv.")

# A. the stands: how many every year, and the projects with a stand in the most editions.
let stands = rd("stands.csv")
stands.groupBy(col.year).agg(len().alias("stands")).sort("year").collect
  .save("stands_by_year.csv", "Stands of every edition from 2008, from stands.csv.")
stands.sort(["stand_key", "year"]).groupBy(col.stand_key)
  .agg(col.stand.last.alias("stand"), col.year.nUnique.alias("editions"),
       col.year.min.alias("first"), col.year.max.alias("last"))
  .sort(["editions", "first", "stand"], descending = [true, false, false]).head(12)
  .select(col.stand, col.first, col.last, col.editions).collect
  .save("stands_top.csv", "The stands present at the most editions (2008-2026), by name folded to a key, from stands.csv.")
