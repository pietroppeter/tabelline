## Turns the staging CSVs (flattened from FOSDEM's raw sources by the extract_*.py
## scripts) into the tidy tables of docs/stories/data/fosdem/.
##
##   nim r -d:release --path:<nanuq>/src process.nim <stage dir> <out dir>
##
## Every table is built with nanuq (Polars for Nim). Each output CSV starts with a
## `#` comment line that names its sources, as tabelline's readCsv expects.

import std/os
import nanuq

let stage = paramStr(1)
let outDir = paramStr(2)
createDir(outDir)

proc rd(name: string): LazyFrame =
  readCsv(stage / name, inferSchemaLength = none(int)).lazy

proc save(df: DataFrame, name, comment: string) =
  ## nanuq's writeCsv has no comment option, so the `#` line is put in front afterwards.
  let path = outDir / name
  df.writeCsv(path)
  let body = readFile(path)
  writeFile(path, "# " & comment & "\n" & body)
  echo name, ": ", df.height, " rows x ", df.width, " columns"

# ---------------------------------------------------------------- helpers

proc nameKey(e: Expr): Expr =
  ## A key to match the same person across years: accents and case folded (ø, ł, ß and
  ## friends too), punctuation and nicknames in quotes dropped, spaces collapsed. The key keeps
  ## Latin letters only, so "Bogomil Shopov - Бого" is `bogomil shopov`; a name with no Latin
  ## letter at all (a name in Chinese) keeps its own letters.
  let folded = e.str.normalize(UnicodeForm.NFKD)
   .str.replaceAll(r"\p{Mn}", "")
   .str.replaceAll("\"[^\"]*\"", " ")
   .str.toLowercase
   # letters that NFKD does not split into a base letter and a mark
   .str.replaceMany({"ø": "o", "ł": "l", "ß": "ss", "æ": "ae", "œ": "oe", "ı": "i", "þ": "th", "ð": "d", "đ": "d"})
  let latin = folded.str.replaceAll(r"[^a-z0-9]+", " ").str.stripChars
  choose(if latin == "": folded.str.replaceAll(r"[^\p{L}\p{N}]+", " ").str.stripChars else: latin)

proc minutesOf(e: Expr): Expr =
  ## "HH:MM" to minutes after midnight.
  e.str.splitExact(":", 1).struct.field("field_0").cast(Int64) * 60 +
    e.str.splitExact(":", 1).struct.field("field_1").cast(Int64)

proc hhmm(e: Expr): Expr =
  ## minutes after midnight to "HH:MM".
  format("{}:{}", (e div 60).cast(String).str.zfill(2), (e mod 60).cast(String).str.zfill(2))

# ---------------------------------------------------------------- events

# 2012-2026: the schedule XML (Pentabarf until 2025, pretalx from 2026).
let xmlEvents = rd("xml_events.csv").withColumns(
  lit("schedule xml").alias("source"),
  col.date.str.strptime(Date, "%Y-%m-%d").dt.weekday.alias("wd"),
  minutesOf(col.start).alias("start_min"),
  minutesOf(col.duration).alias("duration_min"),
).withColumns(
  choose(if col.wd == 5: "Friday" elif col.wd == 6: "Saturday" elif col.wd == 7: "Sunday" else: "Other").alias("day"),
  hhmm(col.start_min + col.duration_min).alias("end"),
  col.event_id.cast(String),
).select(col.year, col.event_id, col.source, col.day, col.start, col.end, col.duration_min,
         col.room, col.track, col("type"), col.title, col.subtitle, col.language, col.videos, col.slides,
         # the archive of 2012 keeps its pages as event/<slug>.html, later years as event/<slug>/
         choose(if col.year == 2012: format("https://archive.fosdem.org/{}/schedule/event/{}.html", col.year, col.slug)
                else: format("https://archive.fosdem.org/{}/schedule/event/{}/", col.year, col.slug)).alias("url"))
  # the first recording of each event: the MP4 when there is one
  .join(rd("xml_links.csv").filter(col.href.str.contains(r"^https?://video\.fosdem\.org/.*\.(mp4|webm)$"))
          .withColumns(col.event_id.cast(String), col.href.str.endsWith(".mp4").not.alias("not_mp4"))
          .sort(["year", "event_id", "not_mp4", "href"])
          .groupBy(col.year, col.event_id).agg(col.href.first.alias("video")),
        on = ["year", "event_id"], how = JoinType.Left)

# 2007-2011: the event index of the old site (main tracks only until 2010, all of 2011).
let idxEvents = rd("html_events.csv").withColumns(
  lit("event index html").alias("source"),
  (minutesOf(col("end")) - minutesOf(col.start)).alias("duration_min"),
  choose(if col.year == 2011: "" else: "maintrack").alias("type"),
  lit("").alias("language"), lit(0).alias("slides"),
  choose(if col.year == 2011: format("https://archive.fosdem.org/{}/schedule/event/{}.html", col.year, col.slug)
         else: format("https://archive.fosdem.org/{}/schedule/events/{}.html", col.year, col.slug)).alias("url"),
)
# 2007-2010: devroom pages (named after the devroom index of the same year).
let devroomNames = rd("html_devrooms.csv").select(col.year, col.devroom_key, col.devroom)
let devEvents = rd("html_devroom_events.csv")
  .join(devroomNames, on = ["year", "devroom_key"], how = JoinType.Left)
  .withColumns(
    lit("devroom page html").alias("source"),
    choose(if col.devroom_key == "lightningtalks": "Lightning Talks" else: col.devroom).fillNull(col.devroom_key).alias("track"),
    choose(if col.devroom_key == "lightningtalks": "lightningtalk" else: "devroom").alias("type"),
    (minutesOf(col("end")) - minutesOf(col.start)).alias("duration_min"),
    lit("").alias("subtitle"), lit("").alias("language"), lit(0).alias("videos"), lit(0).alias("slides"),
    # these talks have no page of their own: the devroom's page
    choose(if col.devroom_key == "lightningtalks": format("https://archive.fosdem.org/{}/schedule/tracks/lightningtalks.html", col.year)
           elif col.year <= 2008: format("https://archive.fosdem.org/{}/schedule/devroom/{}.html", col.year, col.devroom_key)
           else: format("https://archive.fosdem.org/{}/schedule/devrooms/{}.html", col.year, col.devroom_key)).alias("url"),
    lit("").alias("video"),
  )
# 2001-2006: the printed main schedule grid, and the devroom pages of 2004-2006.
let earlyMain = rd("early_events.csv").withColumns(
  format("{}-main-{}", col.year, intRange(1, len() + 1, dtype = Int64).over(col.year)).alias("event_id"),
  lit("schedule grid html").alias("source"),
  col.room.str.replace(r"^(?:Talk|Tutorials) \((\w+)(?: room)?\)$", "$1")
          .str.replace(r"^(\w)", "$1").alias("room"),
  choose(if col.room.str.startsWith("Tutorials"): "tutorial" else: "maintrack").alias("type"),
  lit("").alias("track"),
  (minutesOf(col("end")) - minutesOf(col.start)).alias("duration_min"),
  lit("").alias("subtitle"), lit("").alias("language"), lit(0).alias("videos"), lit(0).alias("slides"),
  lit("").alias("url"), lit("").alias("video"),
)
let earlyDevNames = rd("early_devrooms.csv")
let earlyDev = rd("early_devroom_events.csv")
  # ids first: a join does not keep the row order unless asked (maintainOrder)
  .withColumns(format("{}-{}-{}", col.year, col.devroom_key, intRange(0, len(), dtype = Int64)).alias("event_id"))
  .join(earlyDevNames, on = ["year", "devroom_key"], how = JoinType.Left)
  .withColumns(
    lit("devroom page html").alias("source"),
    col.devroom.alias("track"), lit("devroom").alias("type"), lit("").alias("room"),
    (minutesOf(col("end")) - minutesOf(col.start)).alias("duration_min"),
    lit("").alias("subtitle"), lit("").alias("language"), lit(0).alias("videos"), lit(0).alias("slides"),
    lit("").alias("url"), lit("").alias("video"),
  )

let cols = @["year", "event_id", "source", "day", "start", "end", "duration_min", "room", "track",
             "type", "title", "subtitle", "language", "videos", "slides", "url", "video"]
proc pick(lf: LazyFrame): LazyFrame =
  var es: seq[Expr]
  for c in cols:
    es.add(if c in ["year", "duration_min", "videos", "slides"]: col(c).cast(Int64) else: col(c).cast(String))
  lf.select(es)

let allEvents = concat([xmlEvents.pick, idxEvents.pick, devEvents.pick, earlyMain.pick, earlyDev.pick])

# What kind of slot a talk is: one vocabulary for 25 years of type and track names.
let mainTrackWords = r"(?i)keynote|opening|closing|welcome"
let events = allEvents.withColumns(
  col.title.str.replaceAll(r"\s+", " ").str.stripChars, col.subtitle.str.replaceAll(r"\s+", " ").str.stripChars,
  col.room.str.stripChars, col.track.str.stripChars,
  choose(
    if col("type") == "keynote" or (col("type") == "maintrack" and col.track.str.contains(mainTrackWords)): "keynote"
    elif col("type").isIn(["maintrack", "lecture"]): "main track"
    elif col("type") == "devroom" or col.track.str.contains(r"(?i)devroom|developer room"): "devroom"
    elif col("type").isIn(["lightning", "lightningtalk"]) or col.track.str.contains(r"(?i)lightning"): "lightning talk"
    elif col("type") == "bof": "BOF"
    elif col("type") == "standtrack": "stand"
    elif col("type") == "junior": "junior"
    elif col("type").isIn(["workshop", "tutorial"]): "workshop"
    elif col("type") == "certification" or col.track.str.contains(r"(?i)certification"): "certification"
    elif col("type").isIn(["keysigning", "infodesk"]) or col.track.str.contains(r"(?i)keysigning"): "other"
    elif col.year == 2012 and col.track.str.contains(r"(?i)keynote"): "keynote"
    elif col.year == 2012 and col.track.str.contains(r"(?i) track$"): "main track"
    elif col.year == 2012 and col("type") == "" and col.track == "CAcert": "other"
    elif col.year == 2012 and col("type") == "": "devroom"
    elif col.year == 2011 and col.track.str.contains(r"(?i)keynote"): "keynote"
    elif col.year == 2011 and col.track.str.contains(r"(?i)track"): "main track"
    elif col.year == 2011: "devroom"
    else: "other"
  ).alias("kind"),
).sort(["year", "day", "start", "room", "title", "event_id"]).collect

# ---------------------------------------------------------------- speakers

let xmlP = rd("xml_event_persons.csv").select(col.year, col.event_id.cast(String), col.name, col.position)
let idxP = rd("html_event_persons.csv").select(col.year, col.event_id, col.name, col.position)
let devP = rd("html_devroom_persons.csv").select(col.year, col.event_id, col.name, col.position)
# Early years have the speakers as text in the event row: split on "&", "," and " and ".
let earlyP = events.lazy.filter(col.source.isIn(["schedule grid html"]) or
                                (col.source == "devroom page html" and col.year <= 2006))
  .select(col.year, col.event_id, col.title)
  .join(concat([earlyMain.select(col.event_id, col.speakers), earlyDev.select(col.event_id, col.speakers)]),
        on = ["event_id"], how = JoinType.Inner)
  .filter(col.speakers != "")
  .withColumns(col.speakers.str.replaceAll(r"\s*(?:&|,| and )\s*", "|").str.split("|").alias("name"))
  .explode("name")
  .withColumns(col.name.str.stripChars, intRange(1, len() + 1, dtype = Int64).over(col.event_id).alias("position"))
  .select(col.year, col.event_id, col.name, col.position)

let speakers = concat([xmlP, idxP, devP, earlyP], how = ConcatMethod.VerticalRelaxed)
  .filter(col.name.isNotNull and col.name != "")
  .withColumns(nameKey(col.name).alias("person_key"))
  .unique(["year", "event_id", "person_key"], keep = UniqueKeepStrategy.First, maintainOrder = true)
  .select(col.year.cast(Int64), col.event_id, col.position.cast(Int64), col.name.alias("person"), col.person_key)
  .sort(["year", "event_id", "position", "person"])
  .collect

let nSpeakers = speakers.lazy.groupBy(col.year, col.event_id).agg(len().alias("speakers"))
let eventsOut = events.lazy.join(nSpeakers, on = ["year", "event_id"], how = JoinType.Left)
  .withColumns(col.speakers.fillNull(0))
  .select(col.year, col.event_id, col.kind, col.track, col.title, col.subtitle, col.day, col.start,
          col("end"), col.duration_min, col.room, col.speakers, col.language, col.videos, col.slides,
          col("type").alias("source_type"), col.source, col.url.fillNull(""), col.video.fillNull(""))
  .sort(["year", "day", "start", "room", "title", "event_id"])
  .collect

# People: one row per person key, with the name as last written.
let people = speakers.lazy.join(eventsOut.lazy.select(col.year, col.event_id, col.kind), on = ["year", "event_id"])
  .sort(["year", "event_id", "person"])
  .groupBy(col.person_key, maintainOrder = true)
  .agg(col.person.last.alias("person"),
       col.year.min.alias("first_year"), col.year.max.alias("last_year"),
       col.year.nUnique.alias("editions"), len().alias("talks"),
       (col.kind == "keynote").sum.alias("keynotes"),
       (col.kind == "main track").sum.alias("main_track_talks"),
       (col.kind == "devroom").sum.alias("devroom_talks"),
       col.year.unique.sort.cast(String).str.join(" ").alias("years"))
  .sort(["talks", "person_key"], descending = [true, false])
  .withColumns(col.person_key.str.contains(r"\b(staff|team|panel|volunteers|organi[sz]ers|everyone|various|tbd|tba|speakers|committee|crew|community|board|developers)\b").not.alias("is_person"))
  .select(col.person, col.person_key, col.is_person, col.first_year, col.last_year, col.editions, col.talks,
          col.keynotes, col.main_track_talks, col.devroom_talks, col.years)
  .collect

eventsOut.save("events.csv", "FOSDEM talks 2001-2026, one row per scheduled event. Sources: archive.fosdem.org schedule XML (2012-2026), event index and devroom pages (2007-2011), printed schedule grids and devroom pages (2001-2006). See README.md.")
speakers.save("event_speakers.csv", "Who spoke in which FOSDEM event (year, event_id as in events.csv). person_key folds case, accents and nicknames to match people across years. Sources as events.csv.")
people.save("people.csv", "FOSDEM speakers 2001-2026, one row per person_key (see event_speakers.csv): first and last year, editions, talks by kind. Derived from events.csv and event_speakers.csv.")

# ---------------------------------------------------------------- tracks

let trackPages = rd("track_pages.csv")
let cfpYaml = rd("cfp_yaml.csv").withColumns(nameKey(col.devroom).alias("tkey"), col.edition.alias("year"))
  .unique(["year", "tkey"], keep = UniqueKeepStrategy.Last)
  .select(col.year, col.tkey, col.announcement.alias("cfp_yaml"), col.deadline.alias("cfp_deadline"))
proc trackKey(e: Expr): Expr =
  nameKey(e).str.replace(r"^the ", "").str.replace(r" (devroom|dev room|developer room|developers room|track)s?$", "")

# Devrooms the old sites list, also those whose talks are not online (2002-2010).
let listed = concat([
  rd("early_grid_devrooms.csv").select(col.year, col.devroom, col.room.alias("listed_rooms"),
                                       lit("").alias("capacity"), lit("schedule grid").alias("list_source")),
  rd("early_devrooms.csv").select(col.year, col.devroom, lit("").alias("listed_rooms"),
                                  lit("").alias("capacity"), lit("devroom page").alias("list_source")),
  rd("html_devrooms.csv").select(col.year, col.devroom, col.rooms.alias("listed_rooms"),
                                 col.capacity.cast(String), lit("devroom index").alias("list_source")),
  rd("upcoming_devrooms.csv").select(col.year, col.devroom, lit("").alias("listed_rooms"),
                                     lit("").alias("capacity"), lit("accepted devrooms news").alias("list_source"),
                                     col.cfp_link.alias("upcoming_cfp")),
], how = ConcatMethod.DiagonalRelaxed)
  .withColumns(trackKey(col.devroom).alias("tkey"), col.year.cast(Int64))
  .unique(["year", "tkey"], keep = UniqueKeepStrategy.First, maintainOrder = true)

let fromEvents = eventsOut.lazy.filter(col.track != "")
  .groupBy(col.year, col.track)
  .agg(col.kind.mode.first.alias("kind"), len().alias("events"),
       col.speakers.sum.alias("speaker_slots"),
       col.room.filter(col.room != "").unique.sort.str.join("; ").alias("rooms"),
       col.day.filter(col.day != "").unique.sort.str.join("; ").alias("days"),
       (col.videos > 0).sum.alias("events_with_video"))
  .withColumns(trackKey(col.track).alias("tkey"))

let tracks = fromEvents
  .join(listed, on = ["year", "tkey"], how = JoinType.Full, coalesce = some(true))
  .withColumns(
    col.track.fillNull(col.devroom),
    col.kind.fillNull("devroom"),
    col.events.fillNull(0), col.speaker_slots.fillNull(0), col.events_with_video.fillNull(0),
    choose(if col.rooms.isNull or col.rooms == "": col.listed_rooms else: col.rooms).alias("rooms"),
  )
  .join(trackPages.withColumns(trackKey(col.track).alias("tkey"))
          .unique(["year", "tkey"], keep = UniqueKeepStrategy.First, maintainOrder = true)
          .select(col.year, col.tkey, col.group, col.cfp_link),
        on = ["year", "tkey"], how = JoinType.Left)
  .join(cfpYaml, on = ["year", "tkey"], how = JoinType.Left)
  .withColumns(choose(
      if col.cfp_link.isNotNull and col.cfp_link != "": col.cfp_link
      elif col.upcoming_cfp.isNotNull and col.upcoming_cfp != "": col.upcoming_cfp
      else: col.cfp_yaml).alias("cfp"))
  .sort(["year", "kind", "track", "list_source"])
  .select(col.year, col.track, col.kind, col.group.alias("site_group"), col.events, col.speaker_slots,
          col.events_with_video, col.rooms, col.capacity, col.days, col.cfp, col.cfp_deadline,
          col.list_source.alias("listed_on"))
  .collect
tracks.save("tracks.csv", "FOSDEM tracks and devrooms per edition 2001-2027 (2027: the accepted devrooms as announced) (events grouped by track; 2001-2006 main talks had no track). CfP links: devrooms-cfp.yaml in github.com/FOSDEM/website (2013-2020), track pages on archive.fosdem.org (2021-2026).")

# ---------------------------------------------------------------- rooms

let rooms = eventsOut.lazy.filter(col.room != "")
  .groupBy(col.year, col.room)
  .agg(len().alias("events"), col.track.filter(col.track != "").nUnique.alias("tracks"),
       col.duration_min.sum.alias("scheduled_minutes"))
  .sort(["year", "events", "room"], descending = [false, true, false])
  .collect
rooms.save("rooms.csv", "Rooms used per FOSDEM edition and how many events they held. Derived from events.csv.")

# ---------------------------------------------------------------- calls for participation

let cfpListings = concat([
  rd("cfp_yaml.csv").select(col.edition.alias("year"), col.devroom, col.day, col.announcement,
                            col.deadline, col.first_listed, lit("website devrooms-cfp.yaml").alias("source")),
  trackPages.filter(col.cfp_link.isNotNull and col.cfp_link != "")
    .select(col.year, col.track.alias("devroom"), lit("").alias("day"), col.cfp_link.alias("announcement"),
            lit("").alias("deadline"), lit("").alias("first_listed"), lit("track page").alias("source")),
], how = ConcatMethod.VerticalRelaxed).sort(["year", "devroom", "source", "announcement", "day", "deadline", "first_listed"]).collect
cfpListings.save("cfp_listings.csv", "Devroom calls for participation as FOSDEM listed them: devrooms-cfp.yaml in github.com/FOSDEM/website (editions 2013-2020) and the CfP link of each track page on archive.fosdem.org (2021-2026).")

# Mailing list: every message of fosdem@lists.fosdem.org (2006-), CfPs flagged.
let msgs = rd("list_messages.csv").withColumns(
  col.subject.str.replace(r"(?i)^(\s*\[FOSDEM\]\s*)+", "").str.stripChars.alias("subject"),
)
let cfpRe = r"(?i)\bcall for (papers|participation|proposals|presentations|talks|speakers|submissions|content)|\bc[f4]p\b|\bcfp\b"
let msgsD = msgs.withColumns(
  intRange(0, len(), dtype = Int64).alias("msg"),
  col.subject.str.contains(cfpRe).alias("is_cfp"),
  col.subject.str.contains(r"(?i)volunteer").alias("is_volunteers"),
  col.date.str.strptime(Date, "%Y-%m-%d").alias("d"),
).withColumns(
  # The next edition after the message's date (FOSDEM is in late January or February).
  choose(if col.d.dt.month >= 3: col.d.dt.year + 1 else: col.d.dt.year).cast(Int64).alias("next_edition"),
)
# The edition a message is about: the FOSDEM year it names (near its date), else the next edition.
let named = msgsD.select(col.msg, col.next_edition,
                         col.years_mentioned.cast(String).str.split(" ").alias("y"))
  .explode("y")
  .withColumns(col.y.cast(Int64, strict = false))
  .filter(col.y >= col.next_edition - 1 and col.y <= col.next_edition + 1)
  .groupBy(col.msg).agg(col.y.min.alias("named"))
let messages = msgsD.join(named, on = ["msg"], how = JoinType.Left)
  .withColumns(col.named.fillNull(col.next_edition).alias("edition"))
  .sort("msg")
  .select(col.date, col.edition, col.sender, col.subject, col.is_reply.cast(Boolean), col.is_cfp,
          col.is_volunteers, col.pretalx_link)
  .collect
let cfpPosts = messages.lazy
  .filter(col.is_cfp and not col.is_reply and not col.is_volunteers)
  .withColumns(
    choose(
      if col.subject.str.contains(r"(?i)call for (developer rooms|devrooms)|call for participation: main tracks|lightning talks and stands|call for stands|stands cfp"): "fosdem call"
      elif col.subject.str.contains(r"(?i)dev ?room|developer room|track|room"): "devroom cfp"
      else: "other cfp"
    ).alias("kind"),
    col.subject
      .str.replaceAll(r"(?i)\[?\bc[f4]p\b\]?|call for (papers|participation|proposals|presentations|talks|speakers|submissions|content)|fosdem\s*'?\d{2,4}|\bfosdem\b|[@:\[\]\-–|]|\b(at|the|for|in|a|an)\b|\b20\d\d\b", " ")
      .str.extract(r"(?i)^\s*(.+?)\s+(?:dev(?:eloper)?\s*rooms?|devroom|track|room)\b", 1)
      .str.replaceAll(r"\s+", " ").str.stripChars.alias("devroom_from_subject"),
  )
  .withColumns(nameKey(col.sender).alias("sender_key"))
  # Did the sender also speak at that edition? (organizers often give a talk in their devroom)
  .join(speakers.lazy.select(col.year.alias("edition"), col.person_key.alias("sender_key"), lit(true).alias("sender_spoke"))
          .unique(["edition", "sender_key"]),
        on = ["edition", "sender_key"], how = JoinType.Left)
  .withColumns(col.sender_spoke.fillNull(false))
  .select(col.edition, col.date, col.kind, col.devroom_from_subject, col.subject, col.sender, col.sender_key,
          col.sender_spoke, col.pretalx_link)
  .sort(["edition", "date", "subject", "sender"])
  .collect
let listYears = messages.lazy.groupBy(col.date.str.head(4).cast(Int64).alias("year"))
  .agg(len().alias("messages"), col.is_reply.not.sum.alias("threads"),
       col.sender.nUnique.alias("senders"),
       (col.is_cfp and not col.is_reply and not col.is_volunteers).sum.alias("cfp_posts"))
  .sort("year").collect

cfpPosts.save("cfp_posts.csv", "Calls for participation posted to fosdem@lists.fosdem.org (2006-2026, HyperKitty mbox export), one row per first post; sender names only. edition is the FOSDEM year the post names, else the next edition after its date.")
listYears.save("mailing_list_years.csv", "Messages per year on fosdem@lists.fosdem.org (HyperKitty mbox export, Sep 2006 - Nov 2026).")

# ---------------------------------------------------------------- editions

let conf = rd("conference.csv").select(col.year, col.start, col("end"), col.venue, col.city)
let early = newDataFrame:
  year: [2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011]
  start: ["2001-02-03", "2002-02-16", "2003-02-08", "2004-02-21", "2005-02-26", "2006-02-25",
          "2007-02-24", "2008-02-23", "2009-02-07", "2010-02-06", "2011-02-05"]
  "end": ["2001-02-04", "2002-02-17", "2003-02-09", "2004-02-22", "2005-02-27", "2006-02-26",
          "2007-02-25", "2008-02-24", "2009-02-08", "2010-02-07", "2011-02-06"]
  venue: ["ULB (Université Libre de Bruxelles)", "ULB (Université Libre de Bruxelles)", "ULB (Université Libre de Bruxelles)",
          "ULB (Université Libre de Bruxelles)", "ULB (Université Libre de Bruxelles)", "ULB (Université Libre de Bruxelles)",
          "ULB (Université Libre de Bruxelles)", "ULB (Université Libre de Bruxelles)", "ULB (Université Libre de Bruxelles)",
          "ULB (Université Libre de Bruxelles)", "ULB (Université Libre de Bruxelles)"]
  city: ["Brussels", "Brussels", "Brussels", "Brussels", "Brussels", "Brussels", "Brussels", "Brussels",
         "Brussels", "Brussels", "Brussels"]
let perYear = eventsOut.lazy.groupBy(col.year).agg(
  len().alias("events"),
  (col.kind == "keynote").sum.alias("keynotes"),
  (col.kind == "main track").sum.alias("main_track_talks"),
  (col.kind == "devroom").sum.alias("devroom_talks"),
  (col.kind == "lightning talk").sum.alias("lightning_talks"),
    col.room.filter(col.room != "").nUnique.alias("rooms"),
  (col.videos > 0).sum.alias("events_with_video"),
  col.source.unique.sort.str.join("; ").alias("sources"),
)
let devroomsYear = tracks.lazy.filter(col.kind == "devroom").groupBy(col.year).agg(len().alias("devrooms"))
let peopleYear = speakers.lazy.groupBy(col.year).agg(col.person_key.nUnique.alias("speakers"))
let newPeople = people.lazy.groupBy(col.first_year.alias("year")).agg(len().alias("first_time_speakers"))
let upcoming = rd("upcoming_edition.csv").select(col.year.cast(Int64), col.start, col("end"),
  lit("ULB (Université Libre de Bruxelles)").alias("venue"), lit("Brussels").alias("city"))
let editions = concat([early.lazy.withColumns(col.year.cast(Int64)), conf.withColumns(col.year.cast(Int64)), upcoming],
                      how = ConcatMethod.VerticalRelaxed)
  .withColumns(
    (col.year - 2000).alias("edition"),
    choose(if col.year == 2001: "OSDEM" else: "FOSDEM").alias("name"),
    choose(if col.year.isIn([2021, 2022]): "online" else: "in person").alias("format"),
  )
  .join(perYear, on = ["year"], how = JoinType.Left)
  .join(peopleYear, on = ["year"], how = JoinType.Left)
  .join(devroomsYear, on = ["year"], how = JoinType.Left)
  .withColumns(
    col.devrooms.fillNull(0),
    # 2022 was online too, though its schedule export still names the ULB.
    choose(if col.format == "online": "Online" else: col.venue).alias("venue"),
    choose(if col.format == "online": "" else: col.city).alias("city"),
  )
  .join(newPeople, on = ["year"], how = JoinType.Left)
  .withColumns(
    choose(
      if col.events.isNull: "announced: dates, devrooms and CfPs"
      elif col.year >= 2012: "full schedule"
      elif col.year == 2011: "full schedule (event index)"
      elif col.year >= 2007: "main tracks + devroom pages"
      elif col.year >= 2004: "main grid + most devroom pages"
      else: "main grid only"
    ).alias("coverage"))
  .select(col.year, col.edition, col.name, col.start, col("end"), col.format, col.venue, col.city,
          col.events, col.keynotes, col.main_track_talks, col.devroom_talks, col.lightning_talks,
          col.devrooms, col.rooms, col.speakers, col.first_time_speakers, col.events_with_video,
          col.coverage, col.sources)
  .sort("year").collect
editions.save("editions.csv", "FOSDEM editions 2001-2027 (OSDEM in 2001; 2027 as announced on fosdem.org): dates, venue and counts derived from events.csv. 2021 and 2022 were online. coverage says how complete the schedule is for that year; see README.md.")

# ---------------------------------------------------------------- stands

# 2008-2026: the stands pages (a list until 2012, tables by building after, cards online).
rd("stands.csv")
  .withColumns(col.stand.str.replaceAll(r"\s+", " ").str.stripChars, nameKey(col.stand).alias("stand_key"),
               col.building.fillNull(""), col.theme.fillNull(""))
  .select(col.year, col.stand, col.stand_key, col.building, col.theme)
  .sort(["year", "stand_key", "stand"]).collect
  .save("stands.csv", "Stands at FOSDEM 2008-2026, one row per stand as the archived stands page lists it (archive.fosdem.org/<year>/stands.html until 2012, /<year>/stands/ after; online in 2021 and 2022). stand_key folds case and punctuation; a stand shared by projects is one row.")
