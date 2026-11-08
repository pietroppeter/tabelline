"""Parse FOSDEM 2003-2006 devroom pages: the devroom list and each devroom's schedule page.

Usage: python3 -I extract_early_devrooms.py <raw/archive/html dir> <stage dir>
Writes early_devrooms.csv (year, key, devroom) and early_devroom_events.csv
(year, key, day, start, end, title, speakers). The pages are free-form, so this is a
best effort: two layouts are recognised (time before the title, or time before the speaker).
"""
import csv, glob, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from grid import tables

root, out = sys.argv[1], sys.argv[2]
T = r"(\d\d?)[.:h](\d\d)"
devrooms, events = [], []

def heading(path):
    s = open(path, encoding="utf-8", errors="replace").read()
    s = re.sub(r"<[^>]+>", "|", s)
    m = re.search(r"\|\s*(?:Welcome to the )?([^|]{2,60}?) [Dd]evelopers?'?s?'? ?room", s)
    return re.sub(r"\s+", " ", m.group(1)).strip() if m else ""

def looks_like_name(s):
    w = s.split()
    return 0 < len(w) <= 6 and not s.endswith((".", "!", "?", ":")) and s[:1].isupper()

for y in range(2003, 2007):
    base = os.path.join(root, str(y), str(y), "index") if y > 2003 else os.path.join(root, "2003", "index")
    pages = sorted(glob.glob(os.path.join(base, "dev_room_*.html")))
    if y == 2003:
        s = open(os.path.join(base, "dev_room.html"), encoding="utf-8", errors="replace").read()
        names = re.findall(r"([A-Z][\w.+/ -]{1,40}?) (?:developers|softwares) room", re.sub(r"<[^>]+>", " ", s))
        for n in dict.fromkeys(x.strip() for x in names):
            devrooms.append([y, n.lower().replace(" ", ""), n])
        continue
    for p in pages:
        key = os.path.basename(p)[len("dev_room_"):-5]
        name = heading(p) or key
        devrooms.append([y, key, name])
        sched = os.path.join(base, f"dev_room_{key}", "schedule.html")
        if not os.path.exists(sched):
            continue
        day = ""
        for g in tables(sched):
            for r in g:
                r = [c for c in r if c.strip()]
                if len(r) < 2:
                    continue
                dm = re.search(r"(Saturday|Sunday|Friday)", r[0])
                if dm and r[0] == r[1]:
                    day = dm.group(1); continue
                if not day:
                    continue
                a, b = r[0], r[1]
                m = re.match(T + r"(?:\s*(?:-+>?|–|→|\ufffd|to)\s*" + T + r")?[\s:/.-]*(.*)", a)
                if m:
                    start = f"{int(m.group(1)):02d}:{m.group(2)}"
                    end = f"{int(m.group(3)):02d}:{m.group(4)}" if m.group(3) else ""
                    title = m.group(5).strip()
                    parts = [x.strip() for x in b.split(" / ")]
                    if not title:
                        title = parts[0]
                        parts = parts[1:] if len(parts) > 1 else []
                    spk = parts[-1] if parts and looks_like_name(parts[-1]) and parts[-1] != title else ""
                    events.append([y, key, day, start, end, title, spk])
                    continue
                m = re.match(T + r"\s*\S*\s*" + T + r"\s*(?:/\s*(.*))?", b)
                if m:
                    events.append([y, key, day, f"{int(m.group(1)):02d}:{m.group(2)}",
                                   f"{int(m.group(3)):02d}:{m.group(4)}", a.strip(), (m.group(5) or "").strip()])

def w(name, header, data):
    with open(os.path.join(out, name), "w", newline="") as f:
        cw = csv.writer(f); cw.writerow(header); cw.writerows(data)

w("early_devrooms.csv", ["year", "devroom_key", "devroom"], devrooms)
w("early_devroom_events.csv", ["year", "devroom_key", "day", "start", "end", "title", "speakers"], events)
import collections
print(collections.Counter(d[0] for d in devrooms), collections.Counter(e[0] for e in events))
