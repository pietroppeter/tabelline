"""Parse the "event index" pages of FOSDEM 2007-2011 (archive.fosdem.org/<year>/schedule/events.html).

Usage: python3 -I extract_eventindex.py <pages dir> <stage dir>
Writes html_events.csv and html_event_persons.csv in the same shape as the XML staging files.
"""
import csv, html, os, re, sys

src, out = sys.argv[1], sys.argv[2]
DAYS = {"Sat": "Saturday", "Sun": "Sunday", "Fri": "Friday"}

def text(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", s))).strip()

events, persons = [], []
for y in range(2007, 2012):
    fn = os.path.join(src, f"events{y}.html")
    if not os.path.exists(fn):
        continue
    s = open(fn, encoding="utf-8", errors="replace").read()
    track = ""
    for tr in re.findall(r"<tr[^>]*>.*?</tr>", s, re.S):
        if "track-title" in tr:
            track = text(tr)
            continue
        m = re.search(r'<p class="(?:event-)?title">\s*<a href="events?/([^"]+)\.html">(.*?)</a>', tr, re.S)
        if not m:
            continue
        st = re.search(r'start-time">\s*(\d\d?:\d\d)', tr)
        en = re.search(r'end-time">\s*(\d\d?:\d\d)', tr)
        slug, title = m.group(1), text(m.group(2))
        sub = re.search(r'<p class="subtitle">(.*?)</p>', tr, re.S)
        sp = re.search(r'<td class="speakers">(.*?)</td>', tr, re.S)
        names = [text(n) for n in re.findall(r"<a [^>]*>(.*?)</a>", sp.group(1), re.S)] if sp else []
        room = re.search(r'<td class="event room">(.*?)</td>', tr, re.S)
        when = re.search(r'(?:event-timespec|event day start-time)">(.*?)</td>', tr, re.S)
        if "track-title" in tr: continue
        w = text(when.group(1)) if when else ""
        wm = re.match(r"(\w+)\s+(\d\d?:\d\d)\s*→\s*(\d\d?:\d\d)", w)
        day, start, end = (DAYS.get(wm.group(1), wm.group(1)), wm.group(2), wm.group(3)) if wm else ("", "", "")
        if not wm and st:
            dd = re.search(r'event day">(.*?)</td>', tr, re.S)
            day, start, end = DAYS.get(text(dd.group(1)) if dd else "", ""), st.group(1), en.group(1) if en else ""
        media = re.search(r'<td class="event-media">(.*?)</td>', tr, re.S)
        videos = len(re.findall(r'href="https?://video\.fosdem\.org', media.group(1))) if media else 0
        eid = f"{y}-{slug}"
        events.append([y, eid, day, start, end, text(room.group(1)) if room else "", slug, title,
                       text(sub.group(1)) if sub else "", track, videos])
        for i, n in enumerate(names):
            persons.append([y, eid, n, i + 1])

with open(os.path.join(out, "html_events.csv"), "w", newline="") as f:
    cw = csv.writer(f)
    cw.writerow(["year", "event_id", "day", "start", "end", "room", "slug", "title", "subtitle", "track", "videos"])
    cw.writerows(events)
with open(os.path.join(out, "html_event_persons.csv"), "w", newline="") as f:
    cw = csv.writer(f)
    cw.writerow(["year", "event_id", "name", "position"])
    cw.writerows(persons)
import collections
print(collections.Counter(e[0] for e in events))
