"""Parse FOSDEM track pages (archive.fosdem.org/<year>/schedule/track/<slug>/), 2013-2026.

Usage: python3 -I extract_trackpages.py <raw/archive/tracks dir> <stage dir>
Writes track_pages.csv: year, track_slug, track, group (the breadcrumb level above the
track, such as "Developer rooms", when the site shows one), rooms, CfP link.
"""
import csv, html, os, re, sys

src, out = sys.argv[1], sys.argv[2]

def text(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", s))).strip()

rows = []
for y in sorted(os.listdir(src)):
    d = os.path.join(src, y)
    if not y.isdigit() or not os.path.isdir(d):
        continue
    idx = os.path.join(d, "index.html")
    groups = {}
    if os.path.exists(idx):  # the tracks index groups tracks under headings (Main tracks, Developer rooms, ...)
        s = open(idx, encoding="utf-8", errors="replace").read()
        heading = ""
        for m in re.finditer(r"<h[34][^>]*>(.*?)</h[34]>|href=\"/%s/schedule/track/([^/\"]+)/\"" % y, s, re.S):
            if m.group(1) is not None:
                heading = text(m.group(1))
            elif m.group(2):
                groups.setdefault(m.group(2), heading)
    for fn in sorted(os.listdir(d)):
        if fn == "index.html":
            continue
        slug = fn[:-5]
        s = open(os.path.join(d, fn), encoding="utf-8", errors="replace").read()
        h1 = re.search(r'<div id="pagetitles">\s*<h1>(.*?)</h1>', s, re.S)
        crumbs = [text(c) for c in re.findall(r"<li(?: class=\"active\")?>(.*?)</li>", s[s.find('class="breadcrumbs"'):s.find("</ul>", s.find('class="breadcrumbs"'))], re.S)]
        crumbs = [c for c in crumbs if c and c != "/"]
        group = crumbs[-2] if len(crumbs) >= 5 else groups.get(slug, "")
        side = re.search(r'<p class="side-box">(.*?)</p>', s, re.S)
        rooms = re.findall(r'/schedule/room/[^"]+/">([^<]+)</a>', side.group(1)) if side else []
        box = re.search(r'class="[^"]*track-cfp[^"]*">(.*?)</div>', s, re.S)
        cfp = re.search(r'href="([^"]+)"|(https?://[^\s<]+)', box.group(1)) if box else None
        rows.append([int(y), slug, text(h1.group(1)) if h1 else slug, group, "; ".join(dict.fromkeys(rooms)),
                     (cfp.group(1) or cfp.group(2)) if cfp else ""])

with open(os.path.join(out, "track_pages.csv"), "w", newline="") as f:
    cw = csv.writer(f)
    cw.writerow(["year", "track_slug", "track", "group", "rooms", "cfp_link"])
    cw.writerows(rows)
import collections
print(collections.Counter(r[0] for r in rows), sum(1 for r in rows if r[5]), "with CfP link")
