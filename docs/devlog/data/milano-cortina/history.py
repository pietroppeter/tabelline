"""Write history.tsv: every Winter Games held, from Wikipedia's list.

    python3 docs/devlog/data/milano-cortina/history.py
    FETCH_CACHE=/tmp/wp python3 docs/devlog/data/milano-cortina/history.py   # reuses a page read before

Reads the article "Winter Olympic Games" through the REST API (CC BY-SA 4.0) and keeps the Games
that were held: edition, year, host, nations, athletes and events. The cancelled Games of 1940 and
1944 and the future ones are left out. Needs pandas and lxml. Run it by hand: the page build
fetches nothing.
"""
import io, os, re, sys, time, urllib.request
from pathlib import Path
import pandas as pd

TITLE = "Winter_Olympic_Games"
URL = "https://en.wikipedia.org/api/rest_v1/page/html/" + TITLE
UA = "tabelline-docs/0.1 (https://github.com/pietroppeter/tabelline)"
HERE = Path(__file__).parent

CACHE = Path(os.environ["FETCH_CACHE"]) if os.environ.get("FETCH_CACHE") else None

def fetch():
    for attempt in range(8):
        try:
            req = urllib.request.Request(URL, headers={"User-Agent": UA})
            return urllib.request.urlopen(req, timeout=60).read().decode("utf-8")
        except Exception as e:  # 429 from the rate limit, mostly
            print(f"retry {attempt}: {e}", file=sys.stderr)
            time.sleep(20 * (attempt + 1))
    raise SystemExit("could not read " + TITLE)

cached = CACHE / (TITLE + ".html") if CACHE else None
if cached and cached.exists():
    html = cached.read_text(encoding="utf-8")
else:
    html = fetch()
    if cached:
        CACHE.mkdir(parents=True, exist_ok=True)
        cached.write_text(html, encoding="utf-8")
rev = html.split("Redirect/revision/", 1)[1].split('"', 1)[0]
table = next(t for t in pd.read_html(io.StringIO(html))
             if isinstance(t.columns, pd.MultiIndex) and ("Host city", "Host city") in t.columns)
table.columns = [b for a, b in table.columns]

def num(s):
    """The leading number of a cell: "78[g]" is 78, "92+1[h]" is 92."""
    m = re.match(r"[\d,]+", str(s))
    return int(m.group(0).replace(",", "")) if m else None

rows = []
for _, r in table.iterrows():
    year = num(r["Year"])
    athletes, events, nations = num(r["Total"]), num(r["Events"]), num(r["Nations"])
    if None in (athletes, events, nations) or year > 2026:
        continue          # cancelled (1940, 1944) or still to come
    host = str(r["Host city"]).split("[")[0]
    rows.append({"year": year, "host": host, "country": str(r["Host country"]).split("[")[0],
                 "nations": nations, "athletes": athletes, "events": events})
with open(HERE / "history.tsv", "w", encoding="utf-8") as f:
    f.write(f"# from https://en.wikipedia.org/wiki/{TITLE} (revision {rev}), CC BY-SA 4.0\n")
    pd.DataFrame(rows).to_csv(f, sep="\t", index=False, lineterminator="\n")
print("wrote history.tsv", len(rows), "rows")
