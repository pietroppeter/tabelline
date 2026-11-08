"""Write co2.tsv: CO2 in the air in February of each Italian Winter Games we can measure.

    python3 docs/devlog/data/milano-cortina/co2.py

Reads NOAA's monthly means at Mauna Loa (Scripps before 1974), public data, and keeps February
of 1959 (the first February measured: Cortina 1956 was before the record began), 2006 (Turin)
and 2026 (Milano Cortina). The share is written as a fraction of the air (parts per one), so the
page formats it with fmtPartsper. Run it by hand: the page build fetches nothing.
"""
import urllib.request
from pathlib import Path

URL = "https://gml.noaa.gov/webdata/ccgg/trends/co2/co2_mm_mlo.txt"
HERE = Path(__file__).parent
GAMES = {1959: "first February measured", 2006: "Turin 2006", 2026: "Milano Cortina 2026"}

text = urllib.request.urlopen(URL, timeout=60).read().decode()
created = next(l for l in text.splitlines() if "File Creation" in l).split(":", 1)[1].strip()
rows = []
for line in text.splitlines():
    if line.startswith("#"):
        continue
    year, month, _, average, *_ = line.split()
    if int(month) == 2 and int(year) in GAMES:
        rows.append((year, GAMES[int(year)], float(average) / 1e6))
with open(HERE / "co2.tsv", "w") as f:
    f.write(f"# from {URL} (NOAA GML and Scripps, file of {created}), monthly mean, February\n")
    f.write("year\tgames\tco2\n")
    for year, games, co2 in rows:
        f.write(f"{year}\t{games}\t{co2:.8f}\n")
print("wrote co2.tsv", len(rows), "rows")
