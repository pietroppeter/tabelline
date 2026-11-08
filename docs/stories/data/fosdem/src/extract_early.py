"""Parse the main schedule grids of FOSDEM 2001-2006 (OSDEM 2001, FOSDEM 2002-2006).

Usage: python3 -I extract_early.py <raw/archive/html dir> <stage dir>
Writes early_events.csv: year, day, start, end, room, cell (as printed), title, speakers.
Each year printed its grid a bit differently, so the split of a cell into title and
speakers follows the year's convention (see SPLIT). Cells that span all rooms are
plenary talks in the first room.
"""
import csv, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from grid import tables

root, out = sys.argv[1], sys.argv[2]
FILES = {
    2001: "2001/program/index.html",
    2002: "2002/schedule/index.html",
    2003: "2003/index/schedule.html",
    2004: "2004/2004/index/schedule.html",
    2005: "2005/2005/index/schedule.html",
    2006: "2006/2006/index/schedule.html",
}
TIME = re.compile(r"^(\d\d?)[:h](\d\d)\s*(?:-|->|→)\s*(\d\d?)[:h](\d\d)")
SKIP = re.compile(r"^(-|/|lunch.*|party|)$", re.I)
DEVROOM = re.compile(r"developers?'? ?room", re.I)

def split(year, cell):
    """Return (title, speakers) for a schedule cell."""
    c = cell
    room = ""
    m = re.search(r"\((Jan?s?son)\)", c)
    if m:
        room = "Janson"; c = (c[:m.start()] + c[m.end():]).strip(" /")
    if year == 2001:
        m = re.match(r"(.+?):\s*(.+)", c)
        if m and len(m.group(1).split()) <= 3 and not re.search(r"round table|strategies", c, re.I):
            return m.group(2).strip(), m.group(1).strip(), room
        m = re.match(r"(.+?) by (.+)", c)
        if m:
            return m.group(1).strip(), m.group(2).strip(), room
        return c, "", room
    if year == 2002:
        m = re.match(r"(.+?):\s*(.+)", c)
        if m:
            return m.group(1).strip(), re.sub(r"\s*[-(]\s*(USA|UK)\)?$", "", m.group(2)).strip(" ."), room
        return c, "", room
    parts = [p.strip() for p in c.split(" / ") if p.strip()]
    if len(parts) >= 2:
        return " ".join(parts[:-1]), parts[-1], room
    return c, "", room

def norm_room(r):
    m = re.search(r"\((\w+?)(?: room)?$", r)
    if m:
        r = m.group(1)
    r = re.sub(r"\s*\(\d+\)|:\s*\d+ places", "", r).replace(" / ", " ").strip()
    r = {"Jansson": "Janson"}.get(r, r)
    return r[:1].upper() + r[1:]

rows, devrooms = [], set()
for year, fn in FILES.items():
    for g in tables(os.path.join(root, fn)):
        header, day = None, ""
        for r in g:
            if not r:
                continue
            first = r[0]
            dm = re.search(r"(Saturday|Sunday)", " ".join(r[:3]))
            if dm and not TIME.match(first):
                day = dm.group(1)
                if any(re.search(r"room|places|\(\d+\)|chavanne|janson|lameere", x, re.I) for x in r[1:]):
                    header = r
                continue
            if header is None and any(re.search(r"\(\d+\)|chavanne|lameere", x, re.I) for x in r[1:]):
                header = r
                continue
            m = TIME.match(first)
            if not m or not day:
                continue
            start = f"{int(m.group(1)):02d}:{m.group(2)}"
            end = f"{int(m.group(3)):02d}:{m.group(4)}"
            cells = r[1:]
            filled = [x for x in cells if not SKIP.match(x.strip())]
            seen = set()
            for i, cell in enumerate(cells):
                cell = cell.strip()
                if DEVROOM.search(cell) and cell not in seen:
                    devrooms.add((year, re.sub(r"\s*developers?'? ?room", "", cell, flags=re.I).strip(),
                                  norm_room(header[i + 1]) if header and i + 1 < len(header) else ""))
                if SKIP.match(cell) or DEVROOM.search(cell) or cell in seen:
                    continue
                seen.add(cell)
                plenary = len(filled) > 1 and all(x == cell for x in filled)
                room = header[i + 1] if header and i + 1 < len(header) else ""
                title, speakers, room2 = split(year, cell)
                if plenary or room2:
                    room = room2 or (header[1] if header else "")
                room = norm_room(room)
                if year == 2006 and title.startswith("Welcome of visitors"):
                    title, speakers = "Welcome of visitors followed by Richard M Stallman's keynote", "Richard M Stallman"
                if title.startswith("FOSDEM Return Operation"):
                    title, speakers = cell.replace(" / ", " "), ""
                rows.append([year, day, start, end, room, cell, title, speakers])

with open(os.path.join(out, "early_events.csv"), "w", newline="") as f:
    cw = csv.writer(f)
    cw.writerow(["year", "day", "start", "end", "room", "cell", "title", "speakers"])
    cw.writerows(rows)
with open(os.path.join(out, "early_grid_devrooms.csv"), "w", newline="") as f:
    cw = csv.writer(f)
    cw.writerow(["year", "devroom", "room"])
    cw.writerows(sorted(devrooms))
import collections
print(sorted(devrooms))
print(collections.Counter(r[0] for r in rows))
