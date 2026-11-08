"""Read the announced next edition from fosdem.org/<year>/news/: its dates and accepted devrooms.

Usage: python3 -I extract_upcoming.py <raw/upcoming dir> <stage dir> <year>
Expects accepted-developer-rooms.html and fosdem-<year>-dates.html (from fetch.sh). Writes
upcoming_devrooms.csv (year, devroom, cfp link) and upcoming_edition.csv (year, start, end).
"""
import csv, html, os, re, sys

src, out, year = sys.argv[1], sys.argv[2], int(sys.argv[3])

def text(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", s))).strip()

s = open(os.path.join(src, "accepted-developer-rooms.html"), encoding="utf-8").read()
art = s[s.find("<article"):s.find("</article>")]
ul = art[art.find("<ul>"):art.find("</ul>")]
rows = []
for li in re.findall(r"<li>(.*?)</li>", ul, re.S):
    link = re.search(r'href="([^"]+)"', li)
    rows.append([year, text(li), link.group(1) if link else ""])
announced = re.search(r'<p class="date-small">([^<]+)</p>', art)

d = text(open(os.path.join(src, f"fosdem-{year}-dates.html"), encoding="utf-8").read())
m = re.search(r"Saturday (\d+) and Sunday (\d+) (\w+) " + str(year), d)
months = {"January": 1, "February": 2}
start = f"{year}-{months[m.group(3)]:02d}-{int(m.group(1)):02d}" if m else ""
end = f"{year}-{months[m.group(3)]:02d}-{int(m.group(2)):02d}" if m else ""

with open(os.path.join(out, "upcoming_devrooms.csv"), "w", newline="") as f:
    cw = csv.writer(f); cw.writerow(["year", "devroom", "cfp_link"]); cw.writerows(rows)
with open(os.path.join(out, "upcoming_edition.csv"), "w", newline="") as f:
    cw = csv.writer(f); cw.writerow(["year", "start", "end", "devrooms_announced"])
    cw.writerow([year, start, end, text(announced.group(1)) if announced else ""])
print(len(rows), "devrooms announced for", year, start, end)
