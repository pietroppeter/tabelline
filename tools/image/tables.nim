## The four tables every image-output proof of concept draws (tabelline 0.3, research post
## "A table as a picture"), from the simplest to the hardest, so the pictures of the SVG, pixie
## and Chrome proofs can be put side by side. `import tables` and call `imageTables()`.
##
## 1. planets: the inner planets, a title, a subtitle, a stub, numbers;
## 2. cars: a part of gt's gtcars, with spanners, row groups, summary rows, footnotes, source notes;
## 3. styles: `tabStyle`, `dataColor`, row striping, `md()` with bold and italic;
## 4. plots: nanoplots (a line and bars) and pictures (`fmtImage`, PNG and SVG).

import std/os
import tabelline, tabelline/datasets

const here = currentSourcePath().parentDir

proc planetsTable*(): Tabella =
  tabella(planets(), rownameCol = "planet"):
    rowsHide where(it["type"].s != "Terrestrial")
    colsHide ["type", "density", "gravity", "day_length", "orbital_period", "rings"]
    tabHeader "The inner planets", "the four rocky worlds closest to the Sun"
    fmtNumber "mass", decimals = 3
    fmtInteger ["diameter", "mean_temp"]
    fmtNumber "distance", decimals = 1
    colsLabel:
      mass: "mass, 10²⁴ kg"
      diameter: "diameter, km"
      distance: "from the Sun, 10⁶ km"
      mean_temp: "mean temperature, °C"
      moons: "moons"

proc carsTable*(): Tabella =
  tabella(gtcars(), rownameCol = "model", groupnameCol = "ctry_origin"):
    rowsHide where($it.mfr notin ["Ferrari", "Lamborghini", "Maserati", "Porsche", "BMW"] or it.year.toFloat < 2016)
    colsHide ["mfr", "year", "trim", "bdy_style", "hp_rpm", "trq_rpm", "drivetrain", "trsmn"]
    tabHeader md("**Deluxe cars** of 2016 and 2017"), "a part of gt's gtcars"
    tabSpanner "performance", ["hp", "trq"]
    tabSpanner "miles per gallon", ["mpg_c", "mpg_h"]
    fmtCurrency "msrp", currency = "USD", decimals = 0
    colsLabel:
      hp: "horsepower"
      trq: "torque, lb-ft"
      mpg_c: "city"
      mpg_h: "highway"
      msrp: "price"
    summaryRows:
      mean: agg.mean
      columns = ["hp", "msrp"]
      missingText = ""
    grandSummaryRows:
      largest: agg.max
      columns = ["hp", "trq", "msrp"]
      missingText = ""
    tabFootnote "The price of the base model, before options.", loc.columnLabels("msrp")
    tabFootnote "Germany's cars here are all made by Porsche and BMW.", loc.rowGroups("Germany")
    tabSourceNote "Source: gt's gtcars dataset (MIT), from Edmunds.com."
    tabSourceNote md("Read *mpg* as the EPA's estimate: your mileage may vary.")

proc stylesTable*(): Tabella =
  tabella(planets(), rownameCol = "planet"):
    colsHide ["type", "mass", "density", "day_length", "orbital_period", "rings", "distance"]
    tabHeader md("Hot and **cold** worlds"), md("temperature *and* gravity, coloured by value")
    fmtInteger ["diameter", "mean_temp"]
    fmtNumber "gravity", decimals = 1
    dataColor "mean_temp", palette = palette("rdbu"), domain = (200.0, -200.0)
    dataColor "gravity", palette = @["#FFFFFF", "#2C7FB8"]
    tabStyle style.fill("#FFF3C4") & style.text(weight = "bold"),
             loc.stub(rows = where(it.planet == "Earth"))
    tabStyle style.text(style = "italic", color = "#8A4B08"), loc.body(cols = "moons", rows = where(it.moons.toFloat > 50))
    tabStyle style.borders(sides = {sBottom}, color = "#333333", weight = "2px"), loc.columnLabels()
    colsLabel:
      diameter: md("*diameter*, km")
      gravity: md("**gravity**, m/s²")
      mean_temp: md("mean temperature, **°C**")
      moons: "moons"
    optRowStriping()
    tabSourceNote md("The *gas giants* have **no surface**: their temperature is taken at 1 bar.")

proc plotsTable*(): Tabella =
  let worlds = tableData:
    planet: ["Mercury", "Venus", "Earth", "Mars"]
    picture: ["mercury", "venus", "earth", "mars"]
    temperatures: ["-173 -50 100 300 427 300 100 -50", "462 464 465 464 462 463 464 465",
                   "-10 0 12 22 28 22 12 0", "-120 -90 -60 -20 20 -20 -60 -90"]
    moons: [0, 0, 1, 2]
  tabella(worlds, rownameCol = "planet"):
    tabHeader "Pictures in cells", "a picture, a line through the day, bars"
    fmtImage "picture", path = here / "pictures", filePattern = "{x}.png", height = "2em"
    fmtNanoplot "temperatures", plotType = "line"
    colsAdd "bar", proc (r: Row): Value = r.moons
    fmtNanoplot "bar", plotType = "bar"
    colsLabel:
      picture: ""
      temperatures: "°C through a day"
      bar: ""
    tabSourceNote "The temperatures are made up, for the picture; the moons are not."

proc imageTables*(): seq[(string, Tabella)] =
  ## The four tables, with a short name for their files.
  @[("planets", planetsTable()), ("cars", carsTable()), ("styles", stylesTable()), ("plots", plotsTable())]

when isMainModule:
  # writes the four tables as standalone HTML pages, for a browser screenshot
  let dir = if paramCount() > 0: paramStr(1) else: "build/image"
  createDir dir
  for (name, t) in imageTables():
    t.save(dir / name & ".html")
    echo dir / name & ".html"
