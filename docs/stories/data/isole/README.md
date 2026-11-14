# The islands' data

The tables of the story *Islands of the Mediterranean* (`docs/stories/isole.nim`), and how they
are made (told in `docs/stories/isole_data.nim`). Each CSV starts with a `#` line saying what it
is made from.

```
cd src
nim r -d:ssl fetch.nim <raw dir>                    # Wikipedia pages, Wikidata queries, OpenStreetMap's land (needs unzip)
nim r -d:release extract.nim <raw dir> <stage dir>  # staging CSVs: outlines, lists, weather boxes
cd .. && nim r -d:release --path:<nanuq>/src src/process.nim <stage dir> .   # the tables, with nanuq
nim r -d:release src/map.nim <raw dir> .            # the maps, map-west.svg and map-east.svg (and -it)
```

`regions.csv`, `history.csv` and `highlights.csv` are written by Claude (from Wikipedia); the rest is generated.

## Sources and licences

- Wikipedia (text and tables: List of islands in the Mediterranean, the islands' and towns'
  weather boxes, the EU regions' GDP and unemployment lists), CC BY-SA 4.0.
- Wikidata (items, places, heritage sites, airports, passengers), CC0.
- OpenStreetMap's land polygons from osmdata.openstreetmap.de (outlines), © OpenStreetMap
  contributors, under the Open Database License (ODbL 1.0). The outline columns of `islands.csv`
  (`outline_km2`, `coast_km`, `points`, `matched`, `x`, `y`), and the island each heritage site
  and airport is placed on, are derived from it and are under the ODbL too, and so are the
  coasts of `map-west.svg` and `map-east.svg`.
- tabelline's own `isole` dataset (country and population).
