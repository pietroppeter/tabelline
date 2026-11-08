"""The islands of the Mediterranean, the twin of gt's `islands`: writes isole.tsv.
Run: python3 isole.py

From Wikipedia's "List of islands in the Mediterranean", table "By area", read as wikitext
(action=raw). Each row: name, country, area in km², population, main city. Cyprus's area is a
template there, so it is written in here (9,251 km², Wikipedia's Cyprus).
"""
import re, urllib.request, pathlib

URL = "https://en.wikipedia.org/w/index.php?title=List_of_islands_in_the_Mediterranean&action=raw"
req = urllib.request.Request(URL, headers={"User-Agent": "tabelline-docs/0.1"})
text = urllib.request.urlopen(req, timeout=30).read().decode()
table = text[text.index("== By area =="):text.index("==By population")]

def link(s):
    s = re.sub(r"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", r"\1", s)
    s = re.sub(r"<br\s*/?>.*", "", s)
    return re.sub(r"<[^>]+>|'''?", "", s).strip()

def number(s):
    m = re.search(r"[\d,]+(?:\.\d+)?", re.sub(r"\{\{[^}]*\}\}", "", s))
    return m.group(0).replace(",", "") if m else ""

rows = []
for chunk in table.split("\n|-")[1:]:
    cells = [c.strip() for c in re.split(r"\n\||\|\|", chunk) if c.strip()]
    if not cells or cells[0].startswith("!"): continue
    name = link(cells[0])
    countries = re.findall(r"\{\{flag\|([^}|]+)", chunk)
    area = re.search(r"\{\{convert\|([\d,.]+)\|km2", chunk)
    area = area.group(1).replace(",", "") if area else ("9251" if name == "Cyprus" else "")
    rest = [c for c in cells if not c.startswith(("[[File", "{{flag", "{{convert"))]
    pop = number(rest[1]) if len(rest) > 1 else ""
    city = link(rest[2]) if len(rest) > 2 else ""
    if name and area and not name.startswith("class="):
        rows.append((name, countries[0] if countries else "", area, pop, city))

out = ["# Islands of the Mediterranean by area: Wikipedia, List of islands in the Mediterranean, read 8 Nov 2026 by isole.py",
       "island\tcountry\tarea\tpopulation\tcity"]
out += ["\t".join(r) for r in rows]
pathlib.Path(__file__).with_name("isole.tsv").write_text("\n".join(out) + "\n")
print(len(rows)); print("\n".join(out[:16]))
