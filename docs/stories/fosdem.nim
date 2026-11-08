## story: 0.2 | FOSDEM, twenty-six times | Brussels' free software weekend from OSDEM 2001 to FOSDEM 2027, in three parts of three: the editions, the devrooms, the people. The data from FOSDEM's own schedules, read with nanuq; the tables written in R with gt for now, to be ported to tabelline 0.2.
## A story, kept up to date (first written on 8 November 2026). It is written ahead of tabelline
## 0.2 and 0.3: every table is R with gt (`nbShowR`), run by docs/stories/r/run.R, and its output
## is kept in docs/stories/data/fosdem/story/fosdem-gt.json, to compare with the tabelline port.
## The data is in docs/stories/data/fosdem/ (see its README); the small tables of this story are
## in story/, written by src/insights.nim (nanuq).
import std/os
import nimib except md
import tabelline, tabelline/nimib
import ../blocchi

let docs = currentSourcePath().parentDir.parentDir
let story = "docs/stories/data/fosdem/story"   # from the repository's root, for R
nbInit
nb.doc.filename = docs / "stories" / "fosdem" / "index.html"
nb.useTabelline(nome = "tabelline",
                title = "FOSDEM, twenty-six times", homeHref = "../", backLabel = "Stories", nameHref = "../../")

nbTitolo "A story · tabelline 0.2", "FOSDEM, twenty-six times", """
Every year, on a weekend at the start of February, a few thousand people who make free software
fill the campus of the Université Libre de Bruxelles. There is no ticket and no registration.
This is FOSDEM in tables, from OSDEM in 2001 to the edition of 2027, in three parts of three:
the editions, the devrooms, the people.
"""

nbNota("""
Green cards like this one are about how the tables are made. This story is written ahead of
tabelline 0.2, which brings summary rows and merged columns, and 0.3 (units, dates in other
languages, data from nanuq): so for now every table is **R with gt**, and the story will be
ported to Nim when the release is built. The numbers are computed in Nim with
[nanuq](https://github.com/pietroppeter/nanuq) and saved as small CSV files; R only reads them
and draws the table. *Show code* under a table opens the R that made it.
""", nkCode, "Reading the code")

nbIndice()

nbText: """
## One row to start

The least one can say about FOSDEM: when the next one is, how many devrooms it will have, and
how many came before it.
"""

nbShowR """
editions <- read.csv("dates.csv", comment.char = "#")
next_one <- editions[editions$year == 2027, c("name", "start", "end", "venue")]
next_one$devrooms <- 78
next_one$before <- 26
next_one$venue <- sub(" \\(.*", "", next_one$venue)   # "ULB", without the full name
gt(next_one, rowname_col = "name") |>
  opt_css_theme() |>
  tab_header("FOSDEM 2027", "the 27th edition, as announced") |>
  fmt_date(c(start, end), date_style = "day_m") |>
  cols_merge_range(start, end, sep = "–") |>
  cols_label(start = "when", venue = "where", devrooms = "devrooms", before = "editions before") |>
  tab_source_note("fosdem.org, news of 2027: the dates and the accepted developer rooms.")
"""

nbNota("""
`cols_merge_range` puts the two dates in one column, as "30 Jan–31 Jan": merged columns are
tabelline 0.2. `opt_css_theme()` is tabelline's `optCssTheme()`, written in R for this story
(in `docs/stories/r/tabelline.R`): the table takes the page's colours and font.
""", nkCode)

nbText: """
FOSDEM 2027 will be the earliest one yet, on 30 January as in 2016, and the 27th: OSDEM, the first, was in
2001, and the F (for *Free*) came the year after.

## Three parts of three

Twenty-six editions are too many for one table, so the story splits them in three, and every
part in three again: three questions each, nine tables, simplest first.
"""

nbShowR """
parts <- data.frame(
  part = c("📅 The editions", "🚪 The devrooms", "🎤 The people"),
  questions = c("When is it? How big is it? What did the online years change?",
                "Which devrooms come in 2027? Which ran the longest? How many are new each year?",
                "Who opens FOSDEM? Who keeps coming back? How many speak for the first time?"))
gt(parts) |>
  opt_css_theme() |>
  cols_label(part = "part", questions = "three questions") |>
  tab_style(cell_text(weight = "bold"), cells_body(part))
"""

nbText: """
## Where the numbers come from

FOSDEM publishes its schedule, and keeps every past one at archive.fosdem.org: since 2012 as an
XML file of every event, before that as web pages. Its website's source keeps the calls for
participation of each devroom, and its mailing list has been archived since 2006. From these,
nine tables, in `docs/stories/data/fosdem/`:
"""

nbShowR """
files <- c("editions", "events", "event_speakers", "people", "tracks", "rooms",
           "cfp_listings", "cfp_posts", "mailing_list_years")
tables <- do.call(rbind, lapply(files, function(f) {
  path <- file.path("..", paste0(f, ".csv"))
  data.frame(table = paste0(f, ".csv"), rows = nrow(read.csv(path, comment.char = "#")),
             about = sub("\\..*", "", sub("^# ", "", readLines(path, n = 1))))
}))
gt(tables, rowname_col = "table") |>
  opt_css_theme() |>
  tab_header("The data", "nine tables, one row per ...") |>
  fmt_integer(rows) |>
  cols_label(rows = "rows", about = "") |>
  tab_style(cell_text(size = "12px"), cells_body(about)) |>
  tab_source_note(md("archive.fosdem.org, FOSDEM's website on GitHub, lists.fosdem.org; see the folder's README."))
"""

nbNota("""
Every file starts with a line naming its sources, so `read.csv(comment.char = "#")` skips it,
as tabelline's `readCsv(path, comment = "#")` does. The story's own small tables are in
`story/`, made from these by `src/insights.nim`.
""", nkCode)

nbText: """
The schedules are complete from 2011. Before that the old sites show the main tracks and, for
most years, the devroom pages; the first three editions only have their printed main grid. The
tables below say where a year is partial.
"""

nbParte 1, "", prSuccess   # no label: the headings name the parts, the circles take its colour
nbText: """
## A · The editions

### When is it?

FOSDEM is a weekend in winter, but which one has changed. The first editions moved around
February; from 2004 to 2008 they were at the end of the month. Since 2011 the Saturday has always
fallen between 30 January and 5 February, the first weekend of February or the last of
January, except in 2021, online. In green, the years in that week:
"""

nbShowR """
dates <- read.csv("dates.csv", comment.char = "#")
dates$in_window <- dates$in_window == "true"   # Polars writes true and false
dates$era <- cut(dates$year, c(2000, 2003, 2008, 2010, 2030),
                 labels = c("the first ones", "late February", "moving", "the week of 1 February"))
gt(dates, rowname_col = "year", groupname_col = "era") |>
  opt_css_theme() |>
  tab_header("Every FOSDEM", "Saturday and Sunday, 2001 to 2027") |>
  cols_hide(c(edition, venue, day_of_year, in_window)) |>
  fmt_date(c(start, end), date_style = "day_month") |>
  cols_merge_range(start, end, sep = " – ") |>
  text_case_match("in person" ~ "", .locations = cells_body(format)) |>
  text_case_match("FOSDEM" ~ "", .locations = cells_body(name)) |>
  cols_label(name = "", start = "weekend", format = "") |>
  tab_style(cell_fill(tinta("--success-soft")), cells_body(rows = in_window)) |>
  tab_style(cell_fill(tinta("--success-soft")), cells_stub(rows = in_window)) |>
  tab_source_note("FOSDEM's archived sites; 2027 from fosdem.org.") |>
  tab_options(table.font.size = "13px", data_row.padding = px(2))
"""

nbNota("""
The row groups come from a column made with `cut`, and `cols_merge_range` puts Saturday and
Sunday in one cell (tabelline 0.2). `text_case_match` empties "in person", so only "online"
stands out.
""", nkCode)

nbText: """
Nothing in the data states the rule; the dates show it, and 2027 keeps it.

### How big is it?

Thirty-one talks in three rooms in 2001; over a thousand in 2025 and 2026. The growth is in the
devrooms: rooms that a community runs for a day, with its own call for talks. In 2001 there were
none; in 2026, 65 of them held 926 of the 1,079 events.
"""

nbShowR """
sizes <- read.csv("sizes.csv", comment.char = "#")
gt(sizes, rowname_col = "year", groupname_col = "decade") |>
  opt_css_theme() |>
  tab_header("How big", "events, devrooms and speakers of every edition") |>
  cols_hide(c(coverage, lightning_talks)) |>
  tab_spanner("talks", c(devroom_talks, main_track_talks)) |>
  cols_label(events = "events", devrooms = "devrooms", devroom_talks = "devroom",
             main_track_talks = "main", lightning_talks = "lightning", speakers = "speakers") |>
  fmt_integer(-c(year, decade, coverage)) |>
  summary_rows(groups = everything(), columns = c(events, devroom_talks, main_track_talks),
               fns = list(total = ~ sum(.)), fmt = ~ fmt_integer(.)) |>
  grand_summary_rows(columns = c(events, devroom_talks, main_track_talks),
                     fns = list(`all 26` = ~ sum(.)), fmt = ~ fmt_integer(.)) |>
  tab_style(cell_text(color = tinta("--muted")), cells_body(rows = year <= 2006)) |>
  tab_style(cell_text(color = tinta("--muted")), cells_stub(rows = year <= 2006)) |>
  tab_footnote("Until 2006 the devroom talks are known only where a devroom page is archived.",
               cells_stub(rows = year == 2006)) |>
  tab_source_note("FOSDEM's schedules; an event is anything on them, with stands and BOFs.") |>
  tab_options(table.font.size = "12px", data_row.padding = px(2), column_labels.padding.horizontal = px(3), data_row.padding.horizontal = px(3))
"""

nbNota("""
`summary_rows` adds a total under each decade, and `grand_summary_rows` one for all the years:
summary rows are the first feature of tabelline 0.2. The speakers have no total on purpose: the
same person speaks in many years, so they do not add up.
""", nkCode)

nbText: """
The main tracks stayed small: 18 talks a year from 2007 to 2011, never more than 45. What grew,
grew in the devrooms: a third of the events in 2004, more than eight in ten since 2010.

### What did the online years change?

In 2021 and 2022 FOSDEM was online, because of the pandemic. It did not shrink much: about as
many talks as in 2019, recorded in advance and streamed in about a hundred virtual rooms, one
for every devroom and track. A talk was 30 minutes, as in 2019, against 25 in the other
years.
"""

nbShowR """
online <- read.csv("online.csv", comment.char = "#")
gt(online, rowname_col = "year") |>
  opt_css_theme() |>
  tab_header("Online and back", "the editions of 2018 to 2026") |>
  cols_hide(c(devrooms, format)) |>
  fmt_integer(c(events, devrooms, rooms, speakers)) |>
  fmt_number(median_minutes, decimals = 0) |>
  cols_units(median_minutes = "min") |>
  fmt_percent(with_video, decimals = 0) |>
  cols_label(format = "", events = "events", devrooms = "devrooms", rooms = "rooms",
             speakers = "speakers", median_minutes = "a talk", with_video = "on video") |>
  tab_style(cell_fill(tinta("--secondary-soft")), cells_body(rows = format == "online")) |>
  tab_style(cell_fill(tinta("--secondary-soft")), cells_stub(rows = format == "online")) |>
  tab_footnote("The median length of a talk: keynotes, main tracks, devrooms, lightning talks.",
               cells_column_labels(median_minutes)) |>
  tab_footnote("Online.", cells_stub(rows = format == "online")) |>
  tab_source_note("FOSDEM's schedules.") |>
  tab_options(table.font.size = "13px")
"""

nbNota("""
`cols_units` writes the unit beside the column's label, "a talk, min" (units are tabelline
0.3), and `fmt_percent` the share of events with a video. The online years are shaded, with a
footnote instead of a column.
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

nbShowR """
rooms27 <- read.csv("devrooms_2027.csv", comment.char = "#")
order <- c("since before 2013", "since 2013–2022", "since 2023 or later",
           "back after a pause", "new in 2027")
rooms27 <- rooms27[order(match(rooms27$group, order), rooms27$first, rooms27$devroom), ]
gt(rooms27, rowname_col = "devroom", groupname_col = "group") |>
  opt_css_theme() |>
  tab_header("The devrooms of 2027", "and the year each first ran") |>
  row_group_order(order) |>
  cols_label(first = "since", editions = "editions", was = "in 2026") |>
  sub_missing(was, missing_text = "") |>
  summary_rows(groups = everything(), columns = editions,
               fns = list(devrooms = ~ length(.)), fmt = ~ fmt_integer(.)) |>
  tab_style(cell_fill(tinta("--success-soft")), cells_row_groups("new in 2027")) |>
  tab_style(cell_text(size = "12px"), cells_body(was)) |>
  tab_source_note("fosdem.org, accepted developer rooms of 2027; earlier years from the schedules.") |>
  tab_options(table.font.size = "13px", data_row.padding = px(2))
"""

nbNota("""
The summary row of each group counts its devrooms (`length`), under the editions column. The
groups are computed in nanuq (`src/insights.nim`): a devroom's *family* is its name folded to a
key, plus 49 renames matched by hand, and its status is new, back (missing the year before) or
continuing.
""", nkCode)

nbText: """
Twenty-one are new. Eleven return after a pause, and among them are some of the oldest: Free
Java, PostgreSQL, PHP, Perl, Ruby and the office suites (LibreOffice's devroom, now *FOSS
Office*) all had no room in 2026. Of the devrooms of the first years, 2002 to 2005, only
Embedded comes to 2027 without a pause.

### Which ran the longest?

Twenty-four editions, almost all of them, for two devrooms: Mozilla's, which ran every year from
2002 to 2025, and Embedded's. Here are those held ten times or more:
"""

nbShowR """
longest <- read.csv("devrooms_longest.csv", comment.char = "#")
longest$in_2027 <- longest$in_2027 == "true"
gt(longest, rowname_col = "devroom") |>
  opt_css_theme() |>
  tab_header("The longest-running devrooms", "held in ten editions or more") |>
  cols_hide(c(names, in_2027)) |>
  cols_merge_range(first, last, sep = "–") |>
  fmt_integer(talks) |>
  cols_label(first = "years", editions = "editions", longest_run = "in a row",
             talks = "talks", n_names = "names") |>
  tab_style(cell_text(whitespace = "nowrap"), cells_body(first)) |>
  tab_style(cell_text(color = tinta("--muted")), cells_body(rows = !in_2027)) |>
  tab_style(cell_text(color = tinta("--muted")), cells_stub(rows = !in_2027)) |>
  tab_style(cell_text(weight = "bold"), cells_body(editions)) |>
  tab_footnote("Grey: not among the devrooms of 2027.", cells_column_labels(first)) |>
  tab_source_note("FOSDEM's schedules and devroom pages; 2002–2006 partial.") |>
  tab_options(table.font.size = "12px", data_row.padding = px(2), column_labels.padding.horizontal = px(3), data_row.padding.horizontal = px(3))
"""

nbNota("""
`cols_merge_range` again, for the first and the last year. The longest run of consecutive
editions comes from nanuq: the year minus the year's rank in its devroom is the same number
for the whole run (`col.year - col.year.rank.over("family")`), and a group by counts it.
""", nkCode)

nbText: """
The names column is the number of names a devroom had: FOSS Office had ten, from
OpenOffice.org to LibreOffice Technology. Some are languages (Java, Python, Go, Perl, Ada), some
communities of projects (BSD, Distributions), some topics that kept their room as the projects
in them changed (Legal and Policy, Virtualization, Containers).

### How many are new each year?

Every year, some devrooms are new, most continue, a few come back, and some run for the last
time. The decades add up:
"""

nbShowR """
flow <- read.csv("devroom_flow.csv", comment.char = "#")
gt(flow, rowname_col = "year", groupname_col = "decade") |>
  opt_css_theme() |>
  tab_header("Coming and going", "devrooms of every edition, by where they come from") |>
  tab_spanner("of which", c(new, continuing, back)) |>
  cols_label(devrooms = "devrooms", new = "new", continuing = "from the year before",
             back = "back", last_time = "last time") |>
  summary_rows(groups = everything(), columns = c(new, back, last_time),
               fns = list(total = ~ sum(.)), fmt = ~ fmt_integer(.)) |>
  sub_zero(last_time, zero_text = "", rows = year == 2027) |>
  tab_style(cell_fill(tinta("--success-soft")), cells_body(new, rows = new >= 13)) |>
  tab_style(cell_text(color = tinta("--muted")), cells_body(rows = year <= 2006)) |>
  tab_style(cell_text(color = tinta("--muted")), cells_stub(rows = year <= 2006)) |>
  tab_footnote("Not held again up to 2027.", cells_column_labels(last_time)) |>
  tab_source_note("FOSDEM's schedules and devroom pages; 2002–2006 partial.") |>
  tab_options(table.font.size = "13px", data_row.padding = px(2))
"""

nbNota("""
Summary rows per decade again, on three columns of five. The statuses come from a window in
nanuq: the year before a devroom's year is `col.year.shift(1).over("family")`, and the next one
`shift(-1)`.
""", nkCode)

nbText: """
The years of change are the last three: 13 new devrooms in 2025, 14 in 2026, 21 in 2027, and 20
of 2025's and 19 of 2026's not held again. FOSDEM is not only bigger than ten years ago; its
devrooms turn over faster.
"""

nbText: """
## C · The people

### Who opens FOSDEM?

The first talk on Saturday morning, in Janson, the biggest hall of the ULB, after the
welcome, is FOSDEM's keynote. Richard Stallman gave the first, on software patents, and two
more; then came the founders of O'Reilly, Wikipedia, the Software Freedom Law Center, Jenkins,
systemd:
"""

nbShowR """
openers <- read.csv("openers.csv", comment.char = "#")
openers$by[openers$by == ""] <- NA   # an empty name is a missing one
gt(openers, rowname_col = "year") |>
  opt_css_theme() |>
  tab_header("Opening FOSDEM", "the first talk on Saturday, in the main room") |>
  cols_hide(c(start, room)) |>
  cols_label(title = "", by = "") |>
  sub_missing(by, missing_text = "Richard Stallman") |>
  tab_style(cell_text(weight = "bold"), cells_body(by)) |>
  tab_style(cell_text(size = "12px"), cells_body(title)) |>
  tab_style(cell_fill(tinta("--secondary-soft")), cells_body(rows = year %in% c(2021, 2022))) |>
  tab_style(cell_fill(tinta("--secondary-soft")), cells_stub(rows = year %in% c(2021, 2022))) |>
  tab_footnote("Online: the first talk of the day, in the community track.",
               cells_stub(rows = year %in% c(2021, 2022))) |>
  tab_footnote("The schedule says only \"RMS\".", cells_stub(rows = year == 2002)) |>
  tab_source_note("FOSDEM's schedules: room A in 2001, Conference Room 1 in 2003, Janson otherwise.") |>
  tab_options(table.font.size = "13px", data_row.padding = px(2))
"""

nbNota("""
`sub_missing` fills the one speaker the schedule of 2002 does not name; with `missing_text` it
is a substitution, not a change to the data. The rule (first room of Saturday, first talk
after the welcome) is in nanuq.
""", nkCode)

nbText: """
The early keynotes were about freedom, patents and licences. From 2012 they are about how
projects are made and kept (communities, money, the kernel), and in 2025 about how one learns
to program.

### Who keeps coming back?

About 7,500 people spoke at FOSDEM at least once. Michael Meeks, of LibreOffice, spoke at 22 editions,
from 2002 to 2026; these fifteen spoke at the most:
"""

nbShowR """
top <- read.csv("speakers_top.csv", comment.char = "#")
gt(top, rowname_col = "person") |>
  opt_css_theme() |>
  tab_header("Coming back", "the people who spoke at the most editions") |>
  cols_merge_range(first_year, last_year, sep = "–") |>
  tab_spanner("talks", c(talks, keynotes, main_track_talks, devroom_talks), id = "kinds") |>
  cols_label(first_year = "years", editions = "editions", talks = "all",
             keynotes = "keynote", main_track_talks = "main", devroom_talks = "devroom") |>
  sub_zero(c(keynotes, main_track_talks), zero_text = "") |>
  cols_align("right", c(talks, keynotes, main_track_talks, devroom_talks)) |>
  tab_style(cell_text(whitespace = "nowrap"), cells_body(first_year)) |>
  tab_style(cell_text(weight = "bold"), cells_body(editions)) |>
  tab_source_note("FOSDEM's schedules; a person is a name matched across years (case, accents and nicknames folded).") |>
  tab_options(table.font.size = "12px", data_row.padding = px(2), column_labels.padding.horizontal = px(3), data_row.padding.horizontal = px(3))
"""

nbNota("""
`sub_zero` leaves the cells empty where there are no keynotes or main-track talks, so the
table shows where each one spoke. The names are matched in nanuq with a folded key: "Richard
\"RichiH\" Hartmann" and "Richard Hartmann" are one person.
""", nkCode)

nbText: """
Almost all of them speak in a devroom: the people who come back are the people who run a
community's room, or speak in one, every year. Michael Meeks and Thorsten Behrens in the office
suites' room, Tom Marble in Legal and Policy, Mark Reinhold and Roman Kennke in Free Java,
Robert Kaiser in Mozilla's, Frédéric Descamps in MySQL's.

### How many speak for the first time?

Yet FOSDEM is mostly new faces: every year since 2007, more than half of the speakers had
never spoken there before. And the devrooms' calls, posted to the FOSDEM mailing list, often
come from someone who will speak too:
"""

nbShowR """
newcomers <- read.csv("newcomers.csv", comment.char = "#")
gt(newcomers, rowname_col = "year", groupname_col = "decade") |>
  opt_css_theme() |>
  tab_header("New faces", "speakers of every edition, and the devrooms' calls") |>
  tab_spanner("speakers", c(speakers, first_time_speakers, returning, first_time_share), id = "who") |>
  tab_spanner("devroom calls", c(cfp_posts, cfp_by_speaker)) |>
  fmt_percent(first_time_share, decimals = 0) |>
  cols_merge_n_pct(first_time_speakers, first_time_share) |>
  tab_style(cell_text(whitespace = "nowrap"), cells_body(first_time_speakers)) |>
  fmt_integer(c(speakers, first_time_speakers, returning)) |>
  cols_label(speakers = "all", first_time_speakers = "first time", returning = "again",
             cfp_posts = "posted", cfp_by_speaker = "by a speaker") |>
  summary_rows(groups = everything(), columns = c(cfp_posts, cfp_by_speaker),
               fns = list(total = ~ sum(.)), fmt = ~ fmt_integer(.)) |>
  sub_zero(c(cfp_posts, cfp_by_speaker), zero_text = "") |>
  tab_footnote("Calls posted to fosdem@lists.fosdem.org; before 2011 devrooms announced on their own lists.",
               cells_column_spanners("devroom calls")) |>
  tab_source_note("FOSDEM's schedules and the fosdem@ mailing list archive.") |>
  tab_options(table.font.size = "13px", data_row.padding = px(2))
"""

nbNota("""
`cols_merge_n_pct` writes the share beside the count, "720 (59%)": merged columns, tabelline
0.2. A call is "by a speaker" when its sender spoke at the same edition: FOSDEM publishes no
list of who runs a devroom, so the sender is the closest trace.
""", nkCode)

nbText: """
Six speakers in ten are new every year, and the share hardly moves: 60% in 2009, 59% in 2026.
FOSDEM grew from 176 speakers to 1,216 without becoming a club. Four calls in ten come from
someone who also speaks, the devroom's organisers giving a talk in their own room.
"""

nbParte 2, "", prSecondary   # the closing sections: how it is built
nbText: """
## How this story is built

From zero, in four layers.

**1. The raw data** is FOSDEM's own: the schedule of every edition from archive.fosdem.org (an
XML export from 2012, the web pages before), the history of the devrooms' calls in the source
of FOSDEM's website on GitHub, the fosdem@ mailing list archive (only senders, dates and
subjects), and fosdem.org's news of 2027. `src/fetch.sh` downloads them, about 200 MB, which
are not committed.

**2. The tables** are made in two steps. Short Python scripts (standard library only) flatten
each raw format into staging CSV files; then `src/process.nim`, written with nanuq (Polars for
Nim), cleans, joins and counts them into the nine tables of `docs/stories/data/fosdem/`. Its
README says what is complete for each year. Two runs give the same files, byte for byte.

**3. The story's small tables** come from those nine with nanuq again, in `src/insights.nim`:
the dates, the sizes, the online years, the devroom families (a folded name plus 49 renames
typed by hand), the opening talks, the speakers. Each is a CSV in `story/`, with a `#` line
saying what it is made from.

**4. The tables on this page** are R with gt, because tabelline does not yet have what they
need. `nbShowR` (in `docs/blocchi.nim`) takes a cell of R and shows what it makes, with the code
folded under it. The cells run in one R session, in order, through `docs/stories/r/run.R`, which
first reads `docs/stories/r/tabelline.R`: `opt_css_theme()` and `tinta()`, the two things the
pages have and gt has not. gt takes only named or hex colours, so `tinta` gives each token a
placeholder hex and the page puts the token back. Their HTML is kept in `story/fosdem-gt.json`, with the
gt version, so the site builds without R, and so the tabelline port can be compared with it,
table by table.

## What tabelline will need

The gt functions this story uses that tabelline 0.1 does not have, and the release that plans
them:
"""

nbShowR """
needed <- data.frame(
  release = c("0.2", "0.2", "0.2", "0.3"),
  gt = c("summary_rows, grand_summary_rows", "cols_merge_range", "cols_merge_n_pct",
         "cols_units"),
  where = c("How big, the devrooms of 2027, coming and going, new faces",
            "One row, every FOSDEM, the longest-running, coming back", "New faces",
            "Online and back"))
gt(needed, rowname_col = "gt", groupname_col = "release") |>
  opt_css_theme() |>
  tab_header("What the port needs") |>
  row_group_order(c("0.2", "0.3")) |>
  cols_label(where = "") |>
  tab_style(cell_text(font = "var(--mono)", size = "12px"), cells_stub()) |>
  tab_style(cell_text(size = "12px"), cells_body(where))
"""

nb.runR(docs / "stories" / "data" / "fosdem" / "story" / "fosdem-gt.json", story)
nbSave
