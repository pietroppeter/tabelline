"""Read the stands of every edition from FOSDEM's archived stands pages (2008-2026).

Usage: python3 -I extract_stands.py <raw/stands dir> <stage dir>
Expects <year>.html from fetch.sh: stands.html for 2008-2012, stands/ from 2013. Writes
stands.csv (year, stand, building, theme, position): one row per stand as the page lists it
(a stand shared by two projects is one row, "OpenBSD + OpenSSH").
"""
import csv, html, os, re, sys

src, out = sys.argv[1], sys.argv[2]

def text(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", s))).strip()

rows = []
for name in sorted(os.listdir(src)):
    m = re.match(r"(\d{4})\.html$", name)
    if not m:
        continue
    year = int(m.group(1))
    s = open(os.path.join(src, name), encoding="utf-8", errors="replace").read()
    found = []
    if year <= 2012:
        # an announcement: <h2> buildings (2012) and <li> stands, in the content node
        a = s.find('<div class="content">', s.find('id="node-'))
        b = s.find('<div class="clearfix">', a)
        body = s[a:b]
        building = ""
        for tag, inner in re.findall(r"<(h2|li)[^>]*>(.*?)</\1>", body, re.S):
            if tag == "h2":
                building = text(inner).replace(" building", "").strip()
            else:
                found.append((text(inner), building, ""))
    elif year in (2021, 2022):
        # online: one card per stand, "<h4>Box86 stand <small>Stand</small></h4>"
        for inner in re.findall(r"<h4>(.*?)<small>", s, re.S):
            found.append((re.sub(r"\s+stand$", "", text(inner), flags=re.I), "online", ""))
    else:
        # tables: a building heading per table, rows of stands (2026: themes as <h5> rows)
        for table in re.findall(r"<table.*?</table>", s, re.S):
            h = re.search(r"<h4>(.*?)</h4>", table, re.S)
            building = text(h.group(1)) if h else ""
            theme = ""
            for tr in re.findall(r"<tr>(.*?)</tr>", table, re.S):
                h5 = re.search(r"<h5>(.*?)</h5>", tr, re.S)
                if h5:
                    theme = text(h5.group(1))
                    continue
                p = re.search(r'class="stands-table-project"[^>]*>(.*?)</td>', tr, re.S)
                if p:
                    found.append((text(p.group(1)), building, theme))
                    continue
                tds = re.findall(r"<td[^>]*>(.*?)</td>", tr, re.S)
                if len(tds) == 2 and re.fullmatch(r"\d+", text(tds[0])):
                    found.append((text(tds[1]), building, theme))
    for i, (stand, building, theme) in enumerate(found):
        if stand:
            rows.append([year, stand, building, theme, i + 1])

with open(os.path.join(out, "stands.csv"), "w", newline="") as f:
    cw = csv.writer(f)
    cw.writerow(["year", "stand", "building", "theme", "position"])
    cw.writerows(rows)
print(len(rows), "stands")
