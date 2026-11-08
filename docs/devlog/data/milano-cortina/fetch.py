"""Regenerate the Wikipedia tables of the Milano Cortina post.

    python3 docs/devlog/data/milano-cortina/fetch.py
    FETCH_CACHE=/tmp/wp python3 docs/devlog/data/milano-cortina/fetch.py   # keeps the pages read

Reads five English Wikipedia articles through the REST API (one page every few seconds,
with retries: Wikipedia limits fast clients), and writes one TSV per table next to this file.
Each TSV starts with comment lines naming the article and the revision it was read from.
Wikipedia's text is CC BY-SA 4.0; the facts in these tables come from its articles.
Needs pandas and lxml. Run it by hand: the page build reads the TSVs and fetches nothing.
"""
import io, os, sys, time, urllib.parse, urllib.request
from pathlib import Path
import pandas as pd

HERE = Path(__file__).parent
UA = "tabelline-docs/0.1 (https://github.com/pietroppeter/tabelline)"

CACHE = Path(os.environ["FETCH_CACHE"]) if os.environ.get("FETCH_CACHE") else None

def page(title):
    """The article's HTML and revision id; with FETCH_CACHE set, pages read before are reused."""
    if CACHE and (CACHE / (title + ".html")).exists():
        html = (CACHE / (title + ".html")).read_text(encoding="utf-8")
        return html, (CACHE / (title + ".rev")).read_text().strip()
    html, rev = fetch(title)
    if CACHE:
        CACHE.mkdir(parents=True, exist_ok=True)
        (CACHE / (title + ".html")).write_text(html, encoding="utf-8")
        (CACHE / (title + ".rev")).write_text(rev)
    return html, rev

def fetch(title):
    url = "https://en.wikipedia.org/api/rest_v1/page/html/" + urllib.parse.quote(title, safe="")
    for attempt in range(8):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=60) as r:
                html = r.read().decode("utf-8")
            rev = html.split("Redirect/revision/", 1)[1].split('"', 1)[0]
            time.sleep(3)
            return html, rev
        except Exception as e:  # 429 from the rate limit, mostly
            print(f"retry {attempt} {title}: {e}", file=sys.stderr)
            time.sleep(20 * (attempt + 1))
    raise SystemExit("could not read " + title)

def tables(html):
    return pd.read_html(io.StringIO(html))

def write(name, df, title, rev):
    with open(HERE / name, "w", encoding="utf-8") as f:
        f.write(f"# from https://en.wikipedia.org/wiki/{title} (revision {rev}), CC BY-SA 4.0\n")
        df.to_csv(f, sep="\t", index=False, lineterminator="\n")
    print("wrote", name, len(df), "rows")

def clean(s):
    return str(s).split("[")[0].replace("*", "").strip()

from iso import ISO   # country codes for the flags (ISO 3166-1 alpha-2)

def medal_table(df, who):
    df = df[~df["Rank"].astype(str).str.startswith(("Totals", "11–"))].copy()
    df[who] = df[who].map(clean)
    df.insert(2, "code", df[who].map(lambda n: ISO.get(n, "")))
    df = df.rename(columns={who: "team", "Rank": "rank", "Gold": "gold", "Silver": "silver",
                            "Bronze": "bronze", "Total": "total"})
    df["rank"] = df["rank"].astype(str).str.replace("–", "")
    return df

# 1. The Olympic medal table, every team that won a medal.
t, rev = "2026_Winter_Olympics_medal_table", None
html, rev = page(t)
df = [x for x in tables(html) if list(x.columns)[:2] == ["Rank", "NOC"]][0]
write("medals.tsv", medal_table(df, "NOC"), t, rev)

# 2. The Paralympic medal table (the article lists the first ten).
t = "2026_Winter_Paralympics"
html, rev = page(t)
df = [x for x in tables(html) if list(x.columns)[:2] == ["Rank", "NPC"]][0]
write("paralympics.tsv", medal_table(df, "NPC"), t, rev)

# 3. Italy at every Winter Olympics.
t = "Italy_at_the_Winter_Olympics"
html, rev = page(t)
df = tables(html)[1]
df.columns = df.iloc[0]
df = df[1:]
df = df[df["Games"].str.match(r"^\d{4}") & df["Gold"].notna()].copy()
df.insert(0, "year", df["Games"].str[:4].astype(int))
df["Games"] = df["Games"].str[5:]
df = df.rename(columns={"Games": "host", "Athletes": "athletes", "Gold": "gold", "Silver": "silver",
                        "Bronze": "bronze", "Total": "total", "Rank": "rank"})
write("italy-history.tsv", df, t, rev)

# 4. Italy's medals in 2026, one row per medal.
t = "Italy_at_the_2026_Winter_Olympics"
html, rev = page(t)
from lxml import html as LH
rows = []
for tb in LH.fromstring(html).xpath("//table[not(.//table)]"):
    head = [" ".join(c.text_content().split()) for c in tb.xpath(".//tr[1]/th")]
    if head[:5] != ["Medal", "Name", "Sport", "Event", "Date"]: continue
    for tr in tb.xpath(".//tr")[1:]:
        cells = tr.xpath("./td|./th")
        if len(cells) < 5 or cells[0].text_content().strip() == "Medal": continue
        names = [" ".join(a.text_content().split()) for a in cells[1].xpath(".//a")] or \
                [" ".join(cells[1].text_content().split())]
        day = int(" ".join(cells[4].text_content().split()).split()[0])
        rows.append({"medal": " ".join(cells[0].text_content().split()).lower(),
                     "date": f"2026-02-{day:02d}",
                     "sport": " ".join(cells[2].text_content().split()),
                     "event": " ".join(cells[3].text_content().split()).replace("’", "'"),
                     "athletes": ", ".join(names)})
    break
write("italy-medals.tsv", pd.DataFrame(rows), t, rev)

# 5. The venues, by cluster, and the events of each sport.
t = "2026_Winter_Olympics"
html, rev = page(t)
ts = tables(html)
clusters = ["Milan", "Cortina d'Ampezzo", "Valtellina", "Val di Fiemme", "Verona"]
venues = [x for x in ts if list(x.columns) == ["Venue", "Events", "Capacity", "Status"]]
out = []
for cluster, v in zip(clusters, venues):
    for _, r in v.iterrows():
        out.append({"cluster": cluster, "venue": clean(r["Venue"]), "events": clean(r["Events"]),
                    "capacity": int(str(r["Capacity"]).replace(",", "").split("[")[0]),
                    "status": clean(r["Status"])})
write("venues.tsv", pd.DataFrame(out), t, rev)
cal = [x for x in ts if "Events" in x.columns and x.shape[0] > 15][0]
cal = cal[[cal.columns[0], "Events"]]
cal.columns = ["sport", "events"]
cal = cal[cal["events"].astype(str).str.fullmatch(r"\d+")]
cal = cal[~cal["sport"].str.contains("medal|total|Daily|Cumulative", case=False)]
write("sports.tsv", cal, t, rev)
ath = [x for x in ts if list(x.columns) == ["Ranking", "NOC", "Athletes"]][0]
ath = ath[ath["Ranking"] != "Total"].rename(columns={"Ranking": "rank", "NOC": "team", "Athletes": "athletes"})
ath["team"] = ath["team"].map(clean)
ath["athletes"] = ath["athletes"].map(clean)
ath.insert(2, "code", ath["team"].map(lambda n: ISO.get(n, "")))
write("athletes.tsv", ath, t, rev)
