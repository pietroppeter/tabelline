"""Write by-sport.tsv: who won each of the 16 sports of Milano Cortina 2026.

    python3 docs/stories/data/milano-cortina/sports.py
    FETCH_CACHE=/tmp/wp python3 docs/stories/data/milano-cortina/sports.py   # keeps the pages read

Reads "<sport> at the 2026 Winter Olympics" on English Wikipedia (REST API, CC BY-SA 4.0, slowly:
Wikipedia limits fast clients) and keeps every row of each sport's medal table: sport, team, flag
code, gold, silver, bronze, total. Needs pandas and lxml. Run it by hand: the page build fetches
nothing.
"""
import io, os, sys, time, urllib.parse, urllib.request
from pathlib import Path
import pandas as pd
from iso import ISO

HERE = Path(__file__).parent
UA = "tabelline-docs/0.1 (https://github.com/pietroppeter/tabelline)"
CACHE = Path(os.environ["FETCH_CACHE"]) if os.environ.get("FETCH_CACHE") else None
SPORTS = ["Alpine skiing", "Biathlon", "Bobsleigh", "Cross-country skiing", "Curling", "Figure skating",
          "Freestyle skiing", "Ice hockey", "Luge", "Nordic combined", "Short-track speed skating",
          "Skeleton", "Ski jumping", "Ski mountaineering", "Snowboarding", "Speed skating"]

def page(title):
    """The article's HTML and revision id; with FETCH_CACHE set, pages read before are reused."""
    cached = CACHE / (title + ".html") if CACHE else None
    if cached and cached.exists():
        html = cached.read_text(encoding="utf-8")
    else:
        url = "https://en.wikipedia.org/api/rest_v1/page/html/" + urllib.parse.quote(title, safe="")
        for attempt in range(8):
            try:
                req = urllib.request.Request(url, headers={"User-Agent": UA})
                html = urllib.request.urlopen(req, timeout=60).read().decode("utf-8")
                break
            except Exception as e:  # 429 from the rate limit, mostly
                print(f"retry {attempt} {title}: {e}", file=sys.stderr)
                time.sleep(20 * (attempt + 1))
        else:
            raise SystemExit("could not read " + title)
        time.sleep(4)
        if cached:
            CACHE.mkdir(parents=True, exist_ok=True)
            cached.write_text(html, encoding="utf-8")
    return html, html.split("Redirect/revision/", 1)[1].split('"', 1)[0]

def clean(s):
    return str(s).split("[")[0].replace("*", "").strip()

rows, sources = [], []
for sport in SPORTS:
    title = f"{sport} at the 2026 Winter Olympics".replace(" ", "_")
    html, rev = page(title)
    sources.append(f"# from https://en.wikipedia.org/wiki/{title} (revision {rev})")
    table = next(t for t in pd.read_html(io.StringIO(html))
                 if {"Rank", "Gold", "Silver", "Bronze", "Total"} <= set(map(str, t.columns)))
    who = [c for c in table.columns if c not in ("Rank", "Gold", "Silver", "Bronze", "Total")][0]
    for _, r in table.iterrows():
        team = clean(r[who])
        if str(r["Rank"]).startswith("Total") or team.startswith("Total"):
            continue
        rows.append({"sport": sport, "team": team, "code": ISO.get(team, ""),
                     "gold": int(r["Gold"]), "silver": int(r["Silver"]), "bronze": int(r["Bronze"]),
                     "total": int(r["Total"])})
missing = sorted({r["team"] for r in rows if r["team"] not in ISO})
if missing:
    print("no flag code for:", ", ".join(missing), file=sys.stderr)
with open(HERE / "by-sport.tsv", "w", encoding="utf-8") as f:
    f.write("\n".join(sources) + "\n# CC BY-SA 4.0\n")
    pd.DataFrame(rows).to_csv(f, sep="\t", index=False, lineterminator="\n")
print("wrote by-sport.tsv", len(rows), "rows")
