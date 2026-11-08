"""A first taste of a `paesi` dataset: the countries with the most World Heritage Sites, with their
population. Writes unesco.tsv. Run: python3 unesco.py

- Sites: the bar chart of the countries with the most sites in Wikipedia's "World Heritage Site"
  (read as wikitext, action=raw, which the REST API's rate limits don't block as often).
- Population: Great Tables' `countrypops` (World Bank, via the great_tables package, MIT), year 2022,
  its last year. Countries are joined on their ISO code, since the names differ
  (Russia / Russian Federation, Turkey / Türkiye, Iran / Iran (Islamic Republic)).
"""
import csv, io, re, urllib.request, pathlib

def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": "tabelline-docs/0.1"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read().decode()

wiki = get("https://en.wikipedia.org/w/index.php?title=World_Heritage_Site&action=raw")
asof = re.search(r"\{\{As of\|(\d{4})\|(\w+)\}\}", wiki)
sites = [(re.sub(r"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", r"\1", name), int(n))
         for name, n in re.findall(r'text:"([^"]*)" \((\d+)\)', wiki)]
iso = {"Italy": "IT", "China": "CN", "France": "FR", "Germany": "DE", "Spain": "ES", "India": "IN",
       "Mexico": "MX", "United Kingdom": "GB", "Russia": "RU", "Iran": "IR", "Japan": "JP",
       "United States": "US", "Brazil": "BR", "Canada": "CA", "Turkey": "TR", "Australia": "AU",
       "Greece": "GR", "Poland": "PL", "Czech Republic": "CZ", "Portugal": "PT", "South Korea": "KR",
       "Belgium": "BE", "Sweden": "SE"}
pops = get("https://raw.githubusercontent.com/posit-dev/great-tables/main/great_tables/data/01-countrypops.csv")
population = {r["country_code_2"]: int(r["population"]) for r in csv.DictReader(io.StringIO(pops))
              if r["year"] == "2022" and r["population"]}
out = [f"# World Heritage Sites: Wikipedia, World Heritage Site, as of {asof.group(2)} {asof.group(1)}; "
       "population: Great Tables' countrypops (World Bank), 2022. Written by unesco.py on 8 Nov 2026",
       "country\tcode\tsites\tpopulation"]
for name, n in sites:
    code = iso[name]
    out.append(f"{name}\t{code}\t{n}\t{population[code]}")
pathlib.Path(__file__).with_name("unesco.tsv").write_text("\n".join(out) + "\n")
print("\n".join(out))
