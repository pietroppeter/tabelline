## Step 2 of the islands' data: cleans, joins and counts the staging CSVs of extract.nim with
## nanuq (Polars for Nim), and writes the tables of the story (docs/stories/isole.nim).
##
##   nim r -d:release --path:<nanuq>/src process.nim <stage dir> <out dir>
##
## Every output is a CSV whose first line is a `#` comment naming what it is made from, read by
## the story with `readCsv(path, comment = "#")`. The hand-written tables (regions.csv,
## history.csv, highlights.csv) are read from <out dir>.

import std/os
import nanuq

let stage = paramStr(1)
let outDir = paramStr(2)
let tabelline = currentSourcePath().parentDir.parentDir.parentDir.parentDir.parentDir.parentDir

proc rd(path: string): LazyFrame =
  ## A CSV with its `#` line, every column read as text first: types are chosen here.
  readCsv(path, inferSchemaLength = some(0), commentPrefix = "#").lazy

proc save(df: DataFrame, name, comment: string) =
  ## nanuq's writeCsv has no comment option, so the `#` line is put in front afterwards.
  let path = outDir / name
  df.writeCsv(path)
  writeFile(path, "# " & comment & "\n" & readFile(path))
  echo name, ": ", df.height, " rows x ", df.width, " columns"

proc num(e: Expr): Expr = e.cast(Float64, strict = false)
proc int64(e: Expr): Expr = e.cast(Float64, strict = false).cast(Int64)

# ---------------------------------------------------------------- 1. the islands

# tabelline's own isole dataset has each island's country and population; the staging list has
# its page, Wikidata item, place and main town. They meet on the name the list shows.
let isole = rd(tabelline / "src" / "tabelline" / "data" / "isole.csv")
  .select(col.island.alias("label"), col.country, col.population.int64)
  .unique(["label"], keep = UniqueKeepStrategy.First, maintainOrder = true)

# Each heritage property once: its parts share the number before the dash (1733-001 is Knossos,
# part of 1733, the Minoan Palatial Centres), and a letter after it marks an extension (132ter).
# The name and year are the property's own.
let propertyNames = rd(stage / "heritage_properties.csv")
  .select(col.whs_id.str.replace(r"(bis|ter|rev)$", "").alias("property"), col.name, col.listed)
  .unique(["property"], keep = UniqueKeepStrategy.First, maintainOrder = true)
let properties = rd(stage / "heritage.csv")
  .withColumns(col.whs_id.str.replace(r"-.*", "").str.replace(r"(bis|ter|rev)$", "").alias("property"))
  .groupBy(col.title, col.property, maintainOrder = true)
  .agg(col.site.sort.first.alias("part"), len().alias("parts"))
  .join(propertyNames, on = ["property"], how = JoinType.Left)
  .withColumns(col.name.fillNull(col.part).alias("site"))

let airports = rd(stage / "airports.csv")

# Wikipedia's list gives Cyprus no population: the island has been divided since 1974. Its
# estimate is the sum of the two counts on Wikipedia (read 13 Nov 2026): 918,100 in the areas the
# Republic of Cyprus controls (census 2021, page Cyprus) and 382,836 in the north (estimate 2021,
# page Northern Cyprus).
const cyprusPeople = 918_100 + 382_836

# The ISO code of each of the list's countries, for its flag and to add up every island by country.
const codeOf = [("Italy", "IT"), ("Greece", "GR"), ("Cyprus", "CY"), ("France", "FR"), ("Spain", "ES"),
                ("Croatia", "HR"), ("Tunisia", "TN"), ("Turkey", "TR"), ("Malta", "MT"), ("Albania", "AL")]
var listCode = `when`(col.country == codeOf[0][0]).then(codeOf[0][1])
for (name, code) in codeOf[1 .. ^1]: listCode = listCode.`when`(col.country == name).then(code)
let islands = rd(stage / "islands.csv")
  .join(isole, on = ["label"], how = JoinType.Left)
  .join(rd(stage / "shapes.csv").select(col.title, col.outline_km2.num, col.coast_km.num,
                                        col.points.int64, col.matched, col.x, col.y),
        on = ["title"], how = JoinType.Left)
  .join(properties.groupBy(col.title).agg(len().alias("heritage")), on = ["title"], how = JoinType.Left)
  .join(airports.groupBy(col.title).agg(len().alias("airports")), on = ["title"], how = JoinType.Left)
  .join(rd(stage / "every_island.csv").filter(col.title.isNotNull).select(col.title, col.iho_sea, col.clon.num, col.clat.num),
        on = ["title"], how = JoinType.Left)
  .select(col.rank.int64, col.label.alias("island"), col.title,
          # two islands tabelline's isole has no country for
          `when`(col.label == "La Galite").then("Tunisia").`when`(col.label == "Île du Levant").then("France")
            .otherwise(col.country).alias("country"),
          listCode.`when`(col.label == "La Galite").then("TN").`when`(col.label == "Île du Levant").then("FR")
            .otherwise("").alias("code"),
          col.list_km2.num.alias("km2"),
          `when`(col.title == "Geography of Cyprus").then(cyprusPeople).otherwise(col.population).alias("population"),
          col.town, col.wikidata, col.lat.num, col.lon.num, col.elevation.num,
          col.archipelago, col.native, col.italian, (col.main == "true").alias("main"), col.sea, col.sea_how,
          col.outline_km2, col.coast_km, col.points, col.matched,
          col.heritage.fillNull(0), col.airports.fillNull(0), col.iho_sea, col.clon, col.clat, col.x, col.y)
  .sort("rank").collect
islands.save("islands.csv", "The 195 islands of Wikipedia's List of islands in the Mediterranean (by area, its rank), with tabelline's isole (country, population), Wikidata (item, place, highest point, archipelago, native name, Italian name, sea), the country's ISO code, the sea as the IHO draws them (Marine Regions, CC BY 4.0), the OpenStreetMap outline (© OpenStreetMap contributors, ODbL) that holds each (km², coast km, points, its centroid clon and clat, x and y in km) and the counts of World Heritage properties and airports on it.")

# ---------------------------------------------------------------- 2. what is on them

properties.join(islands.lazy.select(col.title, col.island), on = ["title"])
  .select(col.island, col.title, col.property, col.site, col.listed.int64, col.parts)
  .sort(["title", "listed", "property"]).collect
  .save("heritage.csv", "World Heritage properties on the islands, one row each (parts of a serial property counted in parts): Wikidata, placed by the islands' outlines.")

# Passengers: Wikidata has counts by year and by month, sometimes several for the same year from
# different sources. A year counts once, with its largest yearly count (a smaller one is often
# part of the year). An island's airports then add up: its small airports (never a million
# passengers in a year, when another one has) are left out, as they are often counted for a
# few years only, and a year counts when every one of the others has a count.
let yearly = rd(stage / "passengers.csv")
  .filter(col.precision == "9")
  .withColumns(col.date.str.slice(0, 4).cast(Int64).alias("year"), col.passengers.int64)
  .groupBy(col.iata, col.year).agg(col.passengers.max)
  .join(airports.select(col.iata, col.title, col.airport), on = ["iata"])

yearly.select(col.title, col.iata, col.airport, col.year, col.passengers)
  .sort(["title", "iata", "year"]).collect
  .save("airports.csv", "Passengers of each airport on the islands, by year: Wikidata P3872 (yearly counts; the largest when there are several).")
let active = yearly
  .groupBy(col.title, col.iata).agg(col.passengers.max.alias("most"))
  .filter(col.most >= 1_000_000 or col.most.max.over(col.title) < 1_000_000)
  .select(col.title, col.iata)

let counted = active.groupBy(col.title).agg(len().alias("counted"))
yearly.join(active, on = ["title", "iata"])
  .groupBy(col.title, col.year)
  .agg(col.passengers.sum, len().alias("airports"), col.iata.sort.str.join(" ").alias("iata"))
  .join(counted, on = ["title"])
  .filter(col.airports == col.counted and col.year >= 2000)
  .join(islands.lazy.select(col.title, col.island), on = ["title"])
  .select(col.island, col.title, col.year, col.passengers, col.iata)
  .sort(["title", "year"]).collect
  .save("passengers.csv", "Passengers of the islands' airports by year, 2000 on: the sum of the island's airports (those with a million passengers in some year, or all when none has), in the years every one of them has a count (airports.csv).")

# ---------------------------------------------------------------- 3. the main islands

# Climate: long to wide, a column per month.
rd(stage / "climate.csv")
  .withColumns(col.value.num, format("m{}", col.month.str.zfill(2)).alias("m"))
  .collect
  .pivot(on = "m", index = ["title", "measure"], values = "value", aggregateFunction = PivotAgg.First, sortColumns = true)
  .lazy.join(islands.lazy.select(col.title, col.island), on = ["title"])
  .select(col.island, col.title, col.measure, col("^m\\d\\d$"))
  .sort(["title", "measure"]).collect
  .save("climate.csv", "Monthly normals of the main islands (m01 January ... m12 December): high_c, mean_c and low_c (°C), rain_mm, rain_days, sun_hours, sea_c (sea temperature, where a page has it). From the weather boxes of Wikipedia (stations.csv says which).")

rd(stage / "stations.csv").collect.save("stations.csv", "Where each main island's climate comes from: the Wikipedia page and the weather box's own description of its station.")

# Unemployment: the regions of the main islands, and the median of every region of the list.
let jobs = rd(stage / "unemployment.csv").withColumns(col.year.int64, col.rate.num)
let regions = rd(outDir / "regions.csv")
let islandRegions = regions.select(col.region).filter(col.region.isNotNull).unique(maintainOrder = true)
concat([
    jobs.join(islandRegions, on = ["region"]).select(col.region, col.year, col.rate),
    jobs.groupBy(col.year).agg(col.rate.median).select(lit("All regions (median)").alias("region"), col.year, col.rate)])
  .withColumns(format("y{}", col.year).alias("y"))
  .collect
  .pivot(on = "y", index = "region", values = "rate", aggregateFunction = PivotAgg.First, sortColumns = true)
  .sort("region")
  .save("unemployment.csv", "Unemployment rate (%) of the main islands' regions, 2006-2025 (y2006 ... y2025), and the median of the 300 or so regions listed: Wikipedia, List of European regions by unemployment rate (Eurostat).")

# Every island of the sea, by country: extract.nim's rings of OpenStreetMap, each with its country
# from Natural Earth and its people on Wikidata; the list's islands take the list's country and
# area and people (Natural Earth's closest country for Agathonisi and Kastellorizo is Turkey).
let listed = islands.lazy
  .select(col.title, col.code.alias("list_code"), col.km2.alias("list_km2"), col.population.cast(Float64).alias("list_people"), col.main)
rd(stage / "every_island.csv")
  .select(col.title, col.code, col.km2.num, col.wd_people.num)
  .join(listed, on = ["title"], how = JoinType.Left)
  .withColumns(col.list_code.fillNull(col.code).alias("code"), col.list_km2.fillNull(col.km2).alias("km2"),
               col.list_people.fillNull(col.wd_people).alias("people"))
  .groupBy(col.code)
  .agg(len().alias("islands"), col.km2.filter(col.km2 >= 0.01).len.alias("hectare"),
       col.title.count.alias("listed"), col.main.filter(col.main).len.alias("main"),
       col.km2.sum.round(1).alias("km2"), col.people.sum.cast(Int64).alias("people"),
       col.people.count.alias("peopled"))
  .sort("km2", descending = true).collect
  .save("countries.csv", "Every island of the Mediterranean, by country: OpenStreetMap's land polygons in the sea (© OpenStreetMap contributors, ODbL; not the Peloponnese and Kassandra, cut off by canals, nor islands in lakes), the country from Natural Earth (public domain), the area and people from Wikipedia's list for its 195 islands, and for the others the polygon's area and the people on Wikidata (P1082). islands: every polygon; hectare: those of 0.01 km² or more; listed and main: of the 195 and the 35; peopled: those with a count.")

# Every island of the sea, by the IHO's sea: the other islands, not the list's, of a hectare or
# more (smaller ones are mostly rocks, and some piers and breakwaters drawn as land).
rd(stage / "every_island.csv")
  .select(col.title, col.km2.num, col.iho_sea)
  .filter(col.title.isNull and col.km2 >= 0.01)
  .groupBy(col.iho_sea)
  .agg(len().alias("others"), col.km2.sum.round(1).alias("others_km2"))
  .sort("iho_sea").collect
  .save("seas.csv", "The other islands of each sea, as the IHO draws them (Marine Regions, CC BY 4.0): OpenStreetMap's land polygons in the sea (© OpenStreetMap contributors, ODbL) that are not one of the list's 195, of 0.01 km² or more; how many (others) and their km² (others_km2).")

# The other islands themselves, for the map of every island: each with its centroid, country,
# sea and area, of a hectare or more.
rd(stage / "every_island.csv")
  .select(col.title, col.code, col.km2.num, col.iho_sea, col.clon.num, col.clat.num)
  .filter(col.title.isNull and col.km2 >= 0.01)
  .select(col.clon.round(3).alias("lon"), col.clat.round(3).alias("lat"), col.code, col.km2.round(3).alias("km2"), col.iho_sea)
  .sort(["lon", "lat"]).collect
  .save("others.csv", "The islands of the Mediterranean that are not one of the list's 195, of 0.01 km² or more: OpenStreetMap's land polygons in the sea (© OpenStreetMap contributors, ODbL), each with the centroid of its outline (lon, lat), its country from Natural Earth (public domain), its km² and its sea as the IHO draws them (Marine Regions, CC BY 4.0).")

let gdp = rd(stage / "gdp.csv")
  .select(col.region, col.pps_per_person.num, col.pps_index.num, col.population_m.num)

# One row per main island: its place, size, people, region and what the other tables say.
let lastPax = rd(outDir / "passengers.csv").withColumns(col.year.int64, col.passengers.int64)
  .sort(["title", "year"]).groupBy(col.title).agg(col.year.last.alias("pax_year"), col.passengers.last.alias("pax"))
let climate = rd(outDir / "climate.csv")
let sea = climate.filter(col.measure == "sea_c").select(col.title, col.m08.num.alias("sea_aug"))
let high = climate.filter(col.measure == "high_c").select(col.title, col.m08.num.alias("high_aug"), col.m01.num.alias("high_jan"))
islands.lazy.filter(col.main)
  .join(regions.select(col.title, col.locale, col.region), on = ["title"], how = JoinType.Left)
  .join(gdp, on = ["region"], how = JoinType.Left)
  .join(jobs.filter(col.year == 2025).select(col.region, col.rate.alias("jobless_2025")), on = ["region"], how = JoinType.Left)
  .join(lastPax, on = ["title"], how = JoinType.Left)
  .join(sea, on = ["title"], how = JoinType.Left)
  .join(high, on = ["title"], how = JoinType.Left)
  .select(col.rank, col.island, col.italian, col.title, col.country, col.code, col.locale, col.km2, col.population,
          (col.population / col.km2).round(0).alias("per_km2"), col.coast_km, col.elevation, col.archipelago,
          col.town, col.sea.alias("seas"), col.heritage, col.airports, col.region, col.pps_per_person, col.pps_index,
          col.jobless_2025, col.pax_year, col.pax, col.high_jan, col.high_aug, col.sea_aug)
  .sort("rank").collect
  .save("main.csv", "The 35 main islands (the largest, down to Elba, 224 km²), one row each: islands.csv with their region (regions.csv), its GDP per person in PPS and as % of the EU (2024) and unemployment (2025), the last year of passengers (passengers.csv), and the January and August highs and the August sea (climate.csv).")
