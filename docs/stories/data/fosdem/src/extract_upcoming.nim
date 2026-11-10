## Read the announced next edition from fosdem.org/<year>/news/: its dates and accepted devrooms.
##
## Usage: extract_upcoming <raw/upcoming dir> <stage dir> <year>
## Expects accepted-developer-rooms.html and fosdem-<year>-dates.html (from fetch.sh). Writes
## upcoming_devrooms.csv (year, devroom, cfp link) and upcoming_edition.csv (year, start, end).

import std/tables
import common

let src = paramStr(1)
let stage = paramStr(2)
let year = parseInt(paramStr(3))

let s = readText(src / "accepted-developer-rooms.html")
let art = s.sl(s.pyFind("<article"), s.pyFind("</article>"))
let ul = art.sl(art.pyFind("<ul>"), art.pyFind("</ul>"))
var rows: seq[seq[string]]
for li in ul.findall(rx"(?s)<li>(.*?)</li>", 1):
  let link = li.search(rx"""href="([^"]+)"""")
  rows.add @[$year, text(li), link.group(1)]
let announced = art.search(rx"""<p class="date-small">([^<]+)</p>""")

let d = text(readText(src / "fosdem-" & $year & "-dates.html"))
let m = d.search(rx("Saturday (\\d+) and Sunday (\\d+) (\\w+) " & $year))
let months = {"January": 1, "February": 2}.toTable
let start = if m.ok: $year & "-" & align($months[m.group(3)], 2, '0') & "-" & align($parseInt(m.group(1)), 2, '0') else: ""
let stop = if m.ok: $year & "-" & align($months[m.group(3)], 2, '0') & "-" & align($parseInt(m.group(2)), 2, '0') else: ""

writeCsv(stage, "upcoming_devrooms.csv", ["year", "devroom", "cfp_link"], rows)
writeCsv(stage, "upcoming_edition.csv", ["year", "start", "end", "devrooms_announced"],
         @[@[$year, start, stop, (if announced.ok: text(announced.group(1)) else: "")]])
echo rows.len, " devrooms announced for ", year, " ", start, " ", stop
