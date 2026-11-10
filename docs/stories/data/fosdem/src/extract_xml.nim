## Flatten FOSDEM Pentabarf/pretalx schedule XML (2012-2026) into staging CSVs.
##
## Usage: extract_xml <raw/xml dir> <stage dir>
## Only parses and flattens; cleaning and aggregation happen in nanuq (process.nim).

import std/[xmlparser, xmltree, algorithm]
import common

proc ownText(x: XmlNode): string =
  ## The text of an element before its first child element (Python's ElementTree `.text`).
  for c in x:
    case c.kind
    of xnText, xnCData: result.add c.text
    of xnEntity: result.add htmlUnescape("&" & c.text & ";")
    of xnElement: break
    else: discard

proc kids(x: XmlNode, tag: string): seq[XmlNode] =
  if x == nil: return
  for c in x:
    if c.kind == xnElement and c.tag == tag: result.add c

proc kid(x: XmlNode, tag: string): XmlNode =
  let k = x.kids(tag)
  if k.len > 0: k[0] else: nil

proc t(x: XmlNode, tag: string): string =
  let c = x.kid(tag)
  if c == nil: "" else: c.ownText.pyStrip

proc keepTrailingSpaces(xml: string): string =
  ## Nim's XML parser trims the spaces at the end of an attribute value, and Python keeps
  ## them (a few links end with one): write them as character references, which it keeps.
  var at = 0
  for m in xml.finditer(rx"""(=\s*"[^"<]*?)([ \t\r\n]+)"|(=\s*'[^'<]*?)([ \t\r\n]+)'"""):
    let q = if m.has(1): '"' else: '\''
    result.add xml[at ..< m.start]
    result.add (if m.has(1): m.group(1) else: m.group(3)) & "&#32;".repeat((if m.has(1): m.group(2) else: m.group(4)).len) & q
    at = m.stop
  result.add xml[at .. ^1]

proc path(x: XmlNode, a, b: string): seq[XmlNode] =
  for c in x.kids(a): result.add c.kids(b)

let src = paramStr(1)
let stage = paramStr(2)
var conf, events, eperson, links, tracks: seq[seq[string]]
var files: seq[string]
for kind, f in walkDir(src, relative = true):
  if f.endsWith(".xml"): files.add f
files.sort
for fn in files:
  let year = $parseInt(fn[0 ..< 4])
  let root = parseXml(keepTrailingSpaces(readFile(src / fn)))
  let c = root.kid("conference")
  conf.add @[year, c.t("title"), c.t("subtitle"), c.t("venue"), c.t("city"), c.t("start"),
             c.t("end"), c.t("days")]
  for tr in root.path("tracks", "track"):
    tracks.add @[year, tr.attr("slug"), tr.ownText.pyStrip, tr.attr("online_qa")]
  for day in root.kids("day"):
    let date = day.attr("date")
    for room in day.kids("room"):
      for ev in room.kids("event"):
        let eid = ev.attr("id")
        let tr = ev.kid("track")
        var video, slides, attachments, nlinks = 0
        for a in ev.path("attachments", "attachment"):
          inc attachments
          if a.attr("type") == "slides" or "slides" in a.ownText.toLowerAscii: inc slides
        for l in ev.path("links", "link"):
          let href = l.attr("href")
          inc nlinks
          if (href.startsWith("https://video.fosdem.org") or href.startsWith("http://video.fosdem.org")) and
             (href.endsWith(".webm") or href.endsWith(".mp4")): inc video
          links.add @[year, eid, href, l.ownText.pyStrip]
        events.add @[year, eid, ev.attr("guid"), date, ev.t("start"), ev.t("duration"),
                     room.attr("name"), ev.t("slug"), ev.t("title"), ev.t("subtitle"),
                     (if tr == nil: "" else: tr.ownText.pyStrip), (if tr == nil: "" else: tr.attr("slug")),
                     ev.t("type"), ev.t("language"), $ev.t("abstract").chars, $ev.t("description").chars,
                     $video, $slides, $attachments, $nlinks]
        for i, p in ev.path("persons", "person"):
          eperson.add @[year, eid, p.attr("id"), p.ownText.pyStrip, $(i + 1)]

writeCsv(stage, "conference.csv", ["year", "title", "subtitle", "venue", "city", "start", "end", "days"], conf)
writeCsv(stage, "xml_tracks.csv", ["year", "track_slug", "track", "online_qa"], tracks)
writeCsv(stage, "xml_events.csv", ["year", "event_id", "guid", "date", "start", "duration", "room", "slug",
                                   "title", "subtitle", "track", "track_slug", "type", "language",
                                   "abstract_chars", "description_chars", "videos", "slides",
                                   "attachments", "links"], events)
writeCsv(stage, "xml_event_persons.csv", ["year", "event_id", "person_id", "name", "position"], eperson)
writeCsv(stage, "xml_links.csv", ["year", "event_id", "href", "text"], links)
echo conf.len, " editions, ", events.len, " events, ", eperson.len, " speaker slots"
