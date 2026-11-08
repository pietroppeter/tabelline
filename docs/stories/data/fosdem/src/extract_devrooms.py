"""Parse FOSDEM 2007-2010 devroom pages (schedule/devroom(s)/<x>.html) and the devroom index pages.

Usage: python3 -I extract_devrooms.py <pages dir> <stage dir>
Writes html_devroom_events.csv (one row per talk) and html_devrooms.csv (devroom, rooms, capacity).
"""
import csv, html, os, re, sys

src, out = sys.argv[1], sys.argv[2]
DAYS = {"Sat": "Saturday", "Sun": "Sunday", "Fri": "Friday"}

def text(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", s))).strip()

rows, persons, rooms = [], [], []
for fn in sorted(os.listdir(os.path.join(src, "devrooms"))):
    y, key = int(fn[:4]), fn[5:-5]
    s = open(os.path.join(src, "devrooms", fn), encoding="utf-8", errors="replace").read()
    h1 = re.search(r'<h1[^>]*class="title"[^>]*>(.*?)</h1>', s, re.S) or re.search(r"<h1[^>]*>(.*?)</h1>", s, re.S)
    name = text(h1.group(1)) if h1 else key
    room = re.search(r"Room:\s*(?:<[^>]+>\s*)*([^<]+)", s)
    bc = re.findall(r'<a href="\.\./devrooms?/[^"]+\.html">([^<]+)</a>', s)
    name = bc[-1].strip() if bc else name
    tbl = re.search(r'<table class="track-index">(.*?)</table>', s, re.S)
    if not tbl:
        continue
    for tr in re.split(r"<tr[ >]", tbl.group(1))[1:]:
        when = re.search(r"(Sat|Sun|Fri)\s*(?:</a>)?\s*(?:&nbsp;)?\s*(\d\d?:\d\d)\s*-\s*(\d\d?:\d\d)", tr.replace("&nbsp;", " "))
        ev = re.search(r'<td class="event">\s*<a href="\.\./events/([^"]+)\.html">(.*?)</a>', tr, re.S)
        if not ev:
            ev2 = re.search(r'<td class="event">(.*?)</td>', tr, re.S)
            if not ev2 or not text(ev2.group(1)):
                continue
            slug, title = "", text(ev2.group(1))
        else:
            slug, title = ev.group(1), text(ev.group(2))
        sp = re.search(r'<td class="speaker[^"]*">(.*?)</td>', tr, re.S)
        names = [text(n) for n in re.findall(r"<a [^>]*>(.*?)</a>", sp.group(1), re.S)] if sp else []
        if sp and not names and text(sp.group(1)):
            names = [n.strip() for n in re.split(r",| and ", text(sp.group(1))) if n.strip()]
        eid = f"{y}-{slug or key + '-' + str(len(rows))}"
        rows.append([y, eid, key, name, DAYS.get(when.group(1), "") if when else "",
                     when.group(2) if when else "", when.group(3) if when else "",
                     text(room.group(1)) if room else "", slug, title])
        for i, n in enumerate(names):
            persons.append([y, eid, n, i + 1])

for y in range(2007, 2011):
    fn = os.path.join(src, f"devrooms{y}.html")
    if not os.path.exists(fn):
        continue
    s = open(fn, encoding="utf-8", errors="replace").read()
    s = s[s.find("<thead>", s.find("Developer Rooms")):]
    s = s[:s.find("</table>")]
    for m in re.finditer(r'href="devrooms?/([^"]+)\.html">([^<]+)</a>(.*?)(?=href="devrooms?/|$)', s, re.S):
        rs = [text(r) for r in re.findall(r"<a [^>]*rooms/[^>]*>(.*?)</a>", m.group(3), re.S)]
        caps = re.findall(r"\((\d+)\)", " ".join(rs))
        if not caps:  # 2008 layout: separate room and capacity cells
            tds = [text(t) for t in re.findall(r"<td[^>]*>(.*?)</td>", m.group(3), re.S)]
            rs = [t for t in tds if t and not t.isdigit()]
            caps = [t for t in tds if t.isdigit()]
        rooms.append([y, m.group(1), text(m.group(2)), "; ".join(re.sub(r"\s*\(\d+\)", "", r) for r in rs), "; ".join(caps)])

def w(name, header, data):
    with open(os.path.join(out, name), "w", newline="") as f:
        cw = csv.writer(f); cw.writerow(header); cw.writerows(data)

w("html_devroom_events.csv", ["year", "event_id", "devroom_key", "devroom_page_title", "day", "start", "end", "room", "slug", "title"], rows)
w("html_devroom_persons.csv", ["year", "event_id", "name", "position"], persons)
w("html_devrooms.csv", ["year", "devroom_key", "devroom", "rooms", "capacity"], rooms)
import collections
print(collections.Counter(r[0] for r in rows), len(rooms), "devroom index rows")
