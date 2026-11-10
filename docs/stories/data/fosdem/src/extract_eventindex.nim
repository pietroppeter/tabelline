## Parse the "event index" pages of FOSDEM 2007-2011 (archive.fosdem.org/<year>/schedule/events.html).
##
## Usage: extract_eventindex <pages dir> <stage dir>
## Writes html_events.csv and html_event_persons.csv in the same shape as the XML staging files.

import std/tables
import common

let src = paramStr(1)
let stage = paramStr(2)
let days = {"Sat": "Saturday", "Sun": "Sunday", "Fri": "Friday"}.toTable

let row = rx"(?s)<tr[^>]*>.*?</tr>"
let titleRe = rx"""(?s)<p class="(?:event-)?title">\s*<a href="events?/([^"]+)\.html">(.*?)</a>"""
let startRe = rx"""start-time">\s*(\d\d?:\d\d)"""
let endRe = rx"""end-time">\s*(\d\d?:\d\d)"""
let subRe = rx"""(?s)<p class="subtitle">(.*?)</p>"""
let speakersRe = rx"""(?s)<td class="speakers">(.*?)</td>"""
let anchor = rx"(?s)<a [^>]*>(.*?)</a>"
let roomRe = rx"""(?s)<td class="event room">(.*?)</td>"""
let whenRe = rx"""(?s)(?:event-timespec|event day start-time)">(.*?)</td>"""
let spanRe = rx"(\w+)\s+(\d\d?:\d\d)\s*→\s*(\d\d?:\d\d)"
let dayRe = rx"""(?s)event day">(.*?)</td>"""
let mediaRe = rx"""(?s)<td class="event-media">(.*?)</td>"""
let videoRe = rx"""href="(https?://video\.fosdem\.org[^"]*)""""

var events, persons: seq[seq[string]]
var years: seq[int]
for y in 2007 .. 2011:
  let fn = src / "events" & $y & ".html"
  if not fileExists(fn): continue
  let s = readText(fn)
  var track = ""
  for tr in s.findall(row):
    if "track-title" in tr:
      track = text(tr)
      continue
    let m = tr.search(titleRe)
    if not m.ok: continue
    let st = tr.search(startRe)
    let en = tr.search(endRe)
    let slug = m.group(1)
    let title = text(m.group(2))
    let sub = tr.search(subRe)
    let sp = tr.search(speakersRe)
    let names = if sp.ok: sp.group(1).findall(anchor, 1).mapIt(text(it)) else: @[]
    let room = tr.search(roomRe)
    let whenM = tr.search(whenRe)
    let w = if whenM.ok: text(whenM.group(1)) else: ""
    let wm = w.match(spanRe)
    var day, start, stop = ""
    if wm.ok:
      day = days.getOrDefault(wm.group(1), wm.group(1)); start = wm.group(2); stop = wm.group(3)
    if not wm.ok and st.ok:
      let dd = tr.search(dayRe)
      day = days.getOrDefault(if dd.ok: text(dd.group(1)) else: "", "")
      start = st.group(1)
      stop = if en.ok: en.group(1) else: ""
    let media = tr.search(mediaRe)
    let hrefs = if media.ok: media.group(1).findall(videoRe, 1) else: @[]
    let eid = $y & "-" & slug
    events.add @[$y, eid, day, start, stop, (if room.ok: text(room.group(1)) else: ""), slug, title,
                 (if sub.ok: text(sub.group(1)) else: ""), track, $hrefs.len, (if hrefs.len > 0: hrefs[0] else: "")]
    years.add y
    for i, n in names:
      persons.add @[$y, eid, n, $(i + 1)]

writeCsv(stage, "html_events.csv", ["year", "event_id", "day", "start", "end", "room", "slug", "title",
                                    "subtitle", "track", "videos", "video"], events)
writeCsv(stage, "html_event_persons.csv", ["year", "event_id", "name", "position"], persons)
echo counts(years)
