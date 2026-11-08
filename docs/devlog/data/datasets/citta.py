"""The largest cities of the European Union, the twin of gt's `towny`: writes citta.tsv.
Run: python3 citta.py

From Wikipedia's "List of cities in the European Union by population within city limits", read
as wikitext (action=raw): city, member state (Wikipedia's three-letter flag template), official
population and the date it was counted (each country counts on its own day).
"""
import re, urllib.request, pathlib

URL = ("https://en.wikipedia.org/w/index.php?title="
       "List_of_cities_in_the_European_Union_by_population_within_city_limits&action=raw")
req = urllib.request.Request(URL, headers={"User-Agent": "tabelline-docs/0.1"})
text = urllib.request.urlopen(req, timeout=30).read().decode()
months = {m: i + 1 for i, m in enumerate(["January", "February", "March", "April", "May", "June", "July",
                                          "August", "September", "October", "November", "December"])}
out = ["# EU cities by population within city limits: Wikipedia, read 8 Nov 2026 by citta.py",
       "city\tstate\tpopulation\tcounted"]
for chunk in text.split("\n|-")[1:]:
    city = re.search(r"\[\[(?:[^|\]]*\|)?([^\]]*)\]\]", chunk)
    state = re.search(r"\{\{([A-Z]{3})\}\}", chunk)
    pop = re.search(r"\{\{nts\|(\d+)\}\}", chunk)
    day = re.search(r"\{\{dts\|format=dmy\|(\d{4})\|(\w+)\|(\d+)", chunk)
    if city and state and pop:
        counted = f"{day.group(1)}-{months[day.group(2)]:02d}-{int(day.group(3)):02d}" if day else ""
        out.append(f"{city.group(1)}\t{state.group(1)}\t{pop.group(1)}\t{counted}")
pathlib.Path(__file__).with_name("citta.tsv").write_text("\n".join(out) + "\n")
print(len(out) - 2); print("\n".join(out[:14]))
