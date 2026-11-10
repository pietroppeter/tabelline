## Parse FOSDEM 2007-2010 devroom pages (schedule/devroom(s)/<x>.html) and the devroom index pages.
##
## Usage: extract_devrooms <pages dir> <stage dir>
## Writes html_devroom_events.csv (one row per talk) and html_devrooms.csv (devroom, rooms, capacity).

import std/[tables, algorithm]
import common

let src = paramStr(1)
let stage = paramStr(2)
let days = {"Sat": "Saturday", "Sun": "Sunday", "Fri": "Friday"}.toTable

var rows, persons, rooms: seq[seq[string]]
var years: seq[int]
var files: seq[string]
for kind, f in walkDir(src / "devrooms", relative = true): files.add f
files.sort
for fn in files:
  let y = parseInt(fn[0 ..< 4])
  let key = fn.sl(5, -5)
  let s = readText(src / "devrooms" / fn)
  var h1 = s.search(rx"""(?s)<h1[^>]*class="title"[^>]*>(.*?)</h1>""")
  if not h1.ok: h1 = s.search(rx"(?s)<h1[^>]*>(.*?)</h1>")
  var name = if h1.ok: text(h1.group(1)) else: key
  let room = s.search(rx"Room:\s*(?:<[^>]+>\s*)*([^<]+)")
  let bc = s.findall(rx"""<a href="\.\./devrooms?/[^"]+\.html">([^<]+)</a>""", 1)
  if bc.len > 0: name = bc[^1].pyStrip
  let tbl = s.search(rx"""(?s)<table class="track-index">(.*?)</table>""")
  if not tbl.ok: continue
  for tr in tbl.group(1).resplit(rx"<tr[ >]")[1 .. ^1]:
    let whenM = tr.replace("&nbsp;", " ").search(rx"(Sat|Sun|Fri)\s*(?:</a>)?\s*(?:&nbsp;)?\s*(\d\d?:\d\d)\s*-\s*(\d\d?:\d\d)")
    let ev = tr.search(rx"""(?s)<td class="event">\s*<a href="\.\./events/([^"]+)\.html">(.*?)</a>""")
    var slug, title: string
    if not ev.ok:
      let ev2 = tr.search(rx"""(?s)<td class="event">(.*?)</td>""")
      if not ev2.ok or text(ev2.group(1)).len == 0: continue
      slug = ""; title = text(ev2.group(1))
    else:
      slug = ev.group(1); title = text(ev.group(2))
    let sp = tr.search(rx"""(?s)<td class="speaker[^"]*">(.*?)</td>""")
    var names = if sp.ok: sp.group(1).findall(rx"(?s)<a [^>]*>(.*?)</a>", 1).mapIt(text(it)) else: @[]
    if sp.ok and names.len == 0 and text(sp.group(1)).len > 0:
      names = text(sp.group(1)).resplit(rx",| and ").mapIt(it.pyStrip).filterIt(it.len > 0)
    let eid = $y & "-" & (if slug.len > 0: slug else: key & "-" & $rows.len)
    rows.add @[$y, eid, key, name, (if whenM.ok: days.getOrDefault(whenM.group(1), "") else: ""),
               whenM.group(2), whenM.group(3), (if room.ok: text(room.group(1)) else: ""), slug, title]
    years.add y
    for i, n in names:
      persons.add @[$y, eid, n, $(i + 1)]

for y in 2007 .. 2010:
  let fn = src / "devrooms" & $y & ".html"
  if not fileExists(fn): continue
  var s = readText(fn)
  s = s.sl(s.pyFind("<thead>", s.pyFind("Developer Rooms")))
  s = s.sl(0, s.pyFind("</table>"))
  for m in s.finditer(rx"""(?s)href="devrooms?/([^"]+)\.html">([^<]+)</a>(.*?)(?=href="devrooms?/|$)"""):
    var rs = m.group(3).findall(rx"(?s)<a [^>]*rooms/[^>]*>(.*?)</a>", 1).mapIt(text(it))
    var caps = rs.join(" ").findall(rx"\((\d+)\)", 1)
    if caps.len == 0:  # 2008 layout: separate room and capacity cells
      let tds = m.group(3).findall(rx"(?s)<td[^>]*>(.*?)</td>", 1).mapIt(text(it))
      rs = tds.filterIt(it.len > 0 and not it.fullmatch(rx"\d+"))
      caps = tds.filterIt(it.fullmatch(rx"\d+"))
    rooms.add @[$y, m.group(1), text(m.group(2)), rs.mapIt(it.sub(rx"\s*\(\d+\)", "")).join("; "), caps.join("; ")]

writeCsv(stage, "html_devroom_events.csv", ["year", "event_id", "devroom_key", "devroom_page_title", "day",
                                            "start", "end", "room", "slug", "title"], rows)
writeCsv(stage, "html_devroom_persons.csv", ["year", "event_id", "name", "position"], persons)
writeCsv(stage, "html_devrooms.csv", ["year", "devroom_key", "devroom", "rooms", "capacity"], rooms)
echo counts(years), rooms.len, " devroom index rows"
