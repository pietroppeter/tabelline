"""Flatten FOSDEM Pentabarf/pretalx schedule XML (2012-2026) into staging CSVs.

Usage: python3 -I extract_xml.py <raw/xml dir> <stage dir>
Only parses and flattens; cleaning and aggregation happen in nanuq (process.nim).
"""
import csv, os, sys, xml.etree.ElementTree as ET

src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)

def t(el, tag):
    x = el.find(tag)
    return (x.text or "").strip() if x is not None and x.text else ""

def w(name, header, rows):
    with open(os.path.join(out, name), "w", newline="") as f:
        cw = csv.writer(f)
        cw.writerow(header)
        cw.writerows(rows)

conf, events, eperson, links, tracks = [], [], [], [], []
for fn in sorted(os.listdir(src)):
    if not fn.endswith(".xml"):
        continue
    year = int(fn[:4])
    root = ET.parse(os.path.join(src, fn)).getroot()
    c = root.find("conference")
    conf.append([year, t(c, "title"), t(c, "subtitle"), t(c, "venue"), t(c, "city"),
                 t(c, "start"), t(c, "end"), t(c, "days")])
    for tr in root.findall("tracks/track"):
        tracks.append([year, tr.get("slug", ""), (tr.text or "").strip(), tr.get("online_qa", "")])
    for day in root.findall("day"):
        date = day.get("date", "")
        for room in day.findall("room"):
            for ev in room.findall("event"):
                eid = ev.get("id", "")
                tr = ev.find("track")
                kinds = {"video": 0, "slides": 0, "attachment": 0, "link": 0}
                for a in ev.findall("attachments/attachment"):
                    kinds["attachment"] += 1
                    if a.get("type") == "slides" or "slides" in (a.text or "").lower():
                        kinds["slides"] += 1
                for l in ev.findall("links/link"):
                    href = l.get("href", "")
                    kinds["link"] += 1
                    if href.startswith(("https://video.fosdem.org", "http://video.fosdem.org")) and href.endswith((".webm", ".mp4")):
                        kinds["video"] += 1
                    links.append([year, eid, href, (l.text or "").strip()])
                events.append([
                    year, eid, ev.get("guid", ""), date, t(ev, "start"), t(ev, "duration"),
                    room.get("name", ""), t(ev, "slug"), t(ev, "title"), t(ev, "subtitle"),
                    (tr.text or "").strip() if tr is not None else "",
                    tr.get("slug", "") if tr is not None else "",
                    t(ev, "type"), t(ev, "language"),
                    len(t(ev, "abstract")), len(t(ev, "description")),
                    kinds["video"], kinds["slides"], kinds["attachment"], kinds["link"],
                ])
                for i, p in enumerate(ev.findall("persons/person")):
                    eperson.append([year, eid, p.get("id", ""), (p.text or "").strip(), i + 1])

w("conference.csv", ["year", "title", "subtitle", "venue", "city", "start", "end", "days"], conf)
w("xml_tracks.csv", ["year", "track_slug", "track", "online_qa"], tracks)
w("xml_events.csv", ["year", "event_id", "guid", "date", "start", "duration", "room", "slug",
                     "title", "subtitle", "track", "track_slug", "type", "language",
                     "abstract_chars", "description_chars", "videos", "slides",
                     "attachments", "links"], events)
w("xml_event_persons.csv", ["year", "event_id", "person_id", "name", "position"], eperson)
w("xml_links.csv", ["year", "event_id", "href", "text"], links)
print(len(conf), "editions,", len(events), "events,", len(eperson), "speaker slots")
