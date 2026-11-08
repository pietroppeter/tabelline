# FOSDEM, 2001–2026: the data

Data for tabelline's story about FOSDEM, [FOSDEM, twenty-six times](../../fosdem.nim) (the 0.2
story: devrooms, talks and the people who give them). Twenty-six editions, from OSDEM in February 2001 to FOSDEM 2026, plus 2027 as announced so far
(dates, the 78 accepted devrooms and their calls for participation). Only the data is here; the story comes later.

Every table is a CSV whose first line is a `#` comment naming its sources, so it reads with
`readCsv(path, comment = "#")`. Text fields are on one line (no line breaks inside quotes).

## Tables

| file | rows | one row per |
|---|---:|---|
| `editions.csv` | 27 | edition (2027 as announced): dates, format (2021 and 2022 were online), counts of events, keynotes, main-track, devroom and lightning talks, devrooms, rooms, speakers, first-time speakers, events with video, and how complete the year is (`coverage`) |
| `events.csv` | 12,686 | scheduled event: `kind` (keynote, main track, devroom, lightning talk, BOF, stand, junior, workshop, certification, other), track, title, subtitle, day, start, end, minutes, room, number of speakers, language, videos and slides linked, the schedule's own type and the source |
| `event_speakers.csv` | 14,566 | speaker of an event (year, event_id as in `events.csv`, position, name as printed, `person_key`) |
| `people.csv` | 7,561 | person (by `person_key`): name as last printed, `is_person` (false for "FOSDEM Staff", "LPI Team" and the like), first and last year, editions, talks, keynotes, main-track and devroom talks, the years |
| `tracks.csv` | 1,210 | track or devroom in an edition (2027: the accepted devrooms): kind, the site's group (Main tracks, Developer rooms, ...), events, speaker slots, events with video, rooms, room capacity (2007–2010), days, CfP link and deadline, and where an otherwise empty devroom is listed |
| `rooms.csv` | 692 | room in an edition: events, tracks, scheduled minutes |
| `cfp_listings.csv` | 669 | devroom CfP as FOSDEM listed it: the website's `devrooms-cfp.yaml` (editions 2013–2020: day, link, deadline, when it was first listed) and the CfP link of each track page (2021–2026) |
| `cfp_posts.csv` | 734 | call for participation posted to the fosdem@ mailing list (2007–2027): edition, date, kind (devroom cfp, fosdem call, other cfp), devroom name read from the subject, subject, sender, `sender_key` and whether the sender also spoke that year |
| `mailing_list_years.csv` | 21 | year of the fosdem@ list: messages, threads, senders, CfP posts |

`person_key` folds case, accents, punctuation and nicknames in quotes ("Richard "RichiH" Hartmann"
is `richard hartmann`), so the same person matches across years. It does not know that "RMS",
"Richard Stallman" and "Richard M Stallman" are one person; early years have more of these.

Organizers: FOSDEM never published devroom organizers as data. The closest structured trace is the
sender of each devroom's CfP post (`cfp_posts.csv`), usually one of the devroom's managers; 43% of
them also spoke at that edition. The FOSDEM staff itself is only in prose (team pages of 2003–2006).

The story's own small tables are in `story/`, made from these by `src/insights.nim` (nanuq): the
dates, sizes, online years, devroom families (renames matched by hand), the devrooms of 2027,
opening talks, recurring speakers and newcomers. `story/fosdem-gt.json` keeps the HTML of the
story's gt tables (it is written in R with gt until tabelline 0.2 and 0.3 are built), to compare
with the tabelline port.

## Coverage by year

| year | events | speakers | devrooms | with talks | with CfP link | CfP posts | with video | coverage |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| 2001 | 31 | 25 | 0 | 0 | 0 | 0 | 0 | main grid only |
| 2002 | 39 | 30 | 5 | 0 | 0 | 0 | 0 | main grid only |
| 2003 | 37 | 19 | 6 | 0 | 0 | 0 | 0 | main grid only |
| 2004 | 45 | 36 | 8 | 2 | 0 | 0 | 0 | main grid + most devroom pages |
| 2005 | 105 | 83 | 18 | 11 | 0 | 0 | 0 | main grid + most devroom pages |
| 2006 | 139 | 119 | 16 | 14 | 0 | 0 | 0 | main grid + most devroom pages |
| 2007 | 207 | 176 | 15 | 15 | 0 | 1 | 23 | main tracks + devroom pages |
| 2008 | 228 | 231 | 16 | 16 | 0 | 2 | 22 | main tracks + devroom pages |
| 2009 | 276 | 239 | 19 | 19 | 0 | 1 | 0 | main tracks + devroom pages |
| 2010 | 293 | 233 | 22 | 22 | 0 | 0 | 22 | main tracks + devroom pages |
| 2011 | 331 | 294 | 20 | 20 | 0 | 8 | 0 | full schedule (event index) |
| 2012 | 441 | 410 | 27 | 27 | 0 | 11 | 71 | full schedule |
| 2013 | 487 | 476 | 30 | 30 | 23 | 16 | 102 | full schedule |
| 2014 | 513 | 487 | 33 | 33 | 32 | 24 | 294 | full schedule |
| 2015 | 552 | 531 | 36 | 36 | 33 | 33 | 340 | full schedule |
| 2016 | 617 | 569 | 38 | 38 | 36 | 33 | 479 | full schedule |
| 2017 | 668 | 610 | 41 | 41 | 39 | 32 | 617 | full schedule |
| 2018 | 689 | 651 | 42 | 42 | 41 | 41 | 645 | full schedule |
| 2019 | 775 | 730 | 47 | 47 | 42 | 47 | 715 | full schedule |
| 2020 | 872 | 841 | 56 | 56 | 56 | 52 | 818 | full schedule |
| 2021 | 773 | 684 | 49 | 49 | 48 | 32 | 652 | full schedule |
| 2022 | 730 | 655 | 52 | 52 | 52 | 37 | 663 | full schedule |
| 2023 | 780 | 787 | 55 | 55 | 53 | 49 | 733 | full schedule |
| 2024 | 874 | 945 | 59 | 59 | 57 | 56 | 842 | full schedule |
| 2025 | 1105 | 1193 | 70 | 70 | 70 | 65 | 955 | full schedule |
| 2026 | 1079 | 1216 | 65 | 65 | 64 | 56 | 989 | full schedule |
| 2027 |  |  | 78 | 0 | 70 | 66 |  | announced: dates, devrooms and CfPs |

The gaps, by year:

- **2001–2003**: only the printed main schedule (talk, speaker, slot, room); devrooms (2002–2003)
  are known by name only, with no talks. Some cells name a topic with no speaker (2003's "Open
  Sessions"). 2001's rooms are A, B and C.
- **2004–2006**: main schedule plus each devroom's schedule page where it has one (2 of 8 devrooms
  in 2004, 11 of 18 in 2005, 14 of 16 in 2006). These pages are free-form, so about one devroom talk
  in ten has no speaker and some times have no end. No rooms for devroom talks.
- **2007–2010**: main tracks from the event index, devrooms from their pages (devroom list with
  rooms and capacities). No subtitles, abstracts or languages. Video links only where the page
  listed them (none in 2009).
- **2011**: the whole schedule from the event index, without video links.
- **2012–2026**: the schedule export (Pentabarf, pretalx from 2026): everything, with abstract and
  description lengths in the raw data. Main-track and devroom categories come from the schedule's
  own `type` (2012 has none, so its tracks were classified by name).
- **CfPs**: the website's list of devroom CfPs covers editions 2013–2020 and the track pages link a
  CfP from 2021 on, so 2013–2026 have a CfP link for almost every devroom; 2012 and before have none. The mailing list carries few CfPs before 2011: devrooms
  then announced on their own lists. The list's old pipermail links (`lists.fosdem.org/pipermail/...`)
  now 404; the same messages are in the HyperKitty archive.
- **Online years**: 2021 and 2022 have about 100 virtual "rooms" (one per devroom).
- **Not here**: abstracts and descriptions (kept out to keep the files small; they are in the
  raw XML), attendance, speaker affiliations, and staff/devroom manager lists, which FOSDEM does
  not publish as data.

## Sources

- `archive.fosdem.org/<year>/schedule/xml` (2012–2026), the event index, devroom and speaker pages
  of 2007–2011, the archived sites of 2001–2006, and the track pages of 2013–2026.
- `github.com/FOSDEM/website` (archived site source, 2013–2025): every version of
  `content/devrooms-cfp.yaml`.
- `fosdem.org/2027/news/`: the dates and the accepted developer rooms of the next edition.
- `lists.fosdem.org` HyperKitty export of fosdem@lists.fosdem.org (September 2006 to now). Only
  sender names, dates and subjects are kept; no e-mail addresses and no message bodies.

FOSDEM's schedule content is published by FOSDEM; check its terms before republishing the tables
beyond a story that quotes them.

## Rebuilding

```
sh src/fetch.sh raw                    # ~200 MB of raw downloads, not committed
sh src/build.sh raw <nanuq checkout>   # staging CSVs in raw/stage, tables here
```

`src/extract_*.py` (Python standard library) only flatten each raw format into staging CSVs; all
the cleaning, joining and counting is in `src/process.nim`, written with
[nanuq](https://github.com/pietroppeter/nanuq) 0.6.1. Two runs give byte-identical files.
