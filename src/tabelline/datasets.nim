## Small datasets for examples and tests, built into the module (no files to find at run time).
##
## - `planets`: the eight planets, from NASA's Planetary Fact Sheet (public domain).
## - `exibble`: gt's tiny "example tibble", a column of each type (MIT, from gt / Great Tables).
## - `tavolaPitagorica(n)`: the times table, *la tavola pitagorica*, as every Italian pupil knows it.
## - `isole`: the 194 islands of the Mediterranean, by area (Wikipedia), the twin of gt's `islands`.
## - `citta`: the 95 largest cities of the European Union (Wikipedia), the twin of gt's `towny`.
## - `gtcars`, `countrypops`, `illness`, `metro`: four of gt's datasets, as Great Tables ships
##   them (MIT, `licenses/great-tables-MIT.txt`), the ones the book's pages use.
##
## The data of `isole` and `citta` is in `data/` (CSV, with its source in a `#` line), read when
## compiling; `docs/devlog/data/datasets/` has the programs that wrote it.
##
## `-d:tabellineDatasets=false` leaves out all but `planets`, `exibble` and `tavolaPitagorica`
## (450 KB, most of it `countrypops`), for a JavaScript build that names datasets at run time:
## the others then raise `ValueError` and say so.

import core

const tabellineDatasets* {.booldefine.} = true
  ## Whether the bigger datasets are in the build (see above).

template dataFile(name: string): string =
  when tabellineDatasets: staticRead(name) else: ""

proc leftOut(name: string) =
  when not tabellineDatasets:
    raise newException(ValueError, "the dataset " & name & " is not in this build (-d:tabellineDatasets=false)")

const planetsCsv* = """planet,type,mass,diameter,density,gravity,day_length,distance,orbital_period,mean_temp,moons,rings
Mercury,Terrestrial,0.330,4879,5429,3.7,4222.6,57.9,88.0,167,0,false
Venus,Terrestrial,4.87,12104,5243,8.9,2802.0,108.2,224.7,464,0,false
Earth,Terrestrial,5.97,12756,5514,9.8,24.0,149.6,365.2,15,1,false
Mars,Terrestrial,0.642,6792,3934,3.7,24.7,228.0,687.0,-65,2,false
Jupiter,Gas giant,1898,142984,1326,23.1,9.9,778.5,4331,-110,95,true
Saturn,Gas giant,568,120536,687,9.0,10.7,1432.0,10747,-140,146,true
Uranus,Ice giant,86.8,51118,1270,8.7,17.2,2867.0,30589,-195,28,true
Neptune,Ice giant,102,49528,1638,11.0,16.1,4515.0,59800,-200,16,true
"""
  ## Units: mass 10^24 kg, diameter km, density kg/m³, gravity m/s², day length hours,
  ## distance from the Sun 10^6 km, orbital period days, mean temperature °C. Known moons as
  ## of the 2024 fact sheet (the counts keep growing).

const exibbleCsv* = """num,char,fctr,date,time,datetime,currency,row,group
0.1111,apricot,one,2015-01-15,13:35,2018-01-01 02:22,49.95,row_1,grp_a
2.222,banana,two,2015-02-15,14:40,2018-02-02 14:33,17.95,row_2,grp_a
33.33,coconut,three,2015-03-15,15:45,2018-03-03 03:44,1.39,row_3,grp_a
444.4,durian,four,2015-04-15,16:50,2018-04-04 15:55,65100,row_4,grp_a
5550,,five,2015-05-15,17:55,2018-05-05 04:00,1325.81,row_5,grp_b
,fig,six,2015-06-15,,2018-06-06 16:11,13.255,row_6,grp_b
777000,grapefruit,seven,,19:10,2018-07-07 05:22,,row_7,grp_b
8880000,honeydew,eight,2015-08-15,20:20,,0.44,row_8,grp_b
"""

const isoleCsv* = dataFile("data/isole.csv")
  ## island, country, area (km²), population, city (the largest). Wikipedia, "List of islands in
  ## the Mediterranean", read 8 Nov 2026.
const cittaCsv* = dataFile("data/citta.csv")
  ## city, state (three-letter code), population within city limits, counted (the date of the
  ## count). Wikipedia, "List of cities in the European Union by population within city limits",
  ## read 8 Nov 2026.

const
  gtcarsCsv = dataFile("data/gtcars.csv")
  countrypopsCsv = dataFile("data/countrypops.csv")
  illnessCsv = dataFile("data/illness.csv")
  metroCsv = dataFile("data/metro.csv")

proc gtcars*(): TableData = (leftOut "gtcars"; parseCsv(gtcarsCsv))
  ## 47 deluxe automobiles from the 2014-2017 model years, with their performance and price
  ## (gt's `gtcars`).
proc countrypops*(): TableData = (leftOut "countrypops"; parseCsv(countrypopsCsv))
  ## The population of every country, every year from 1960 to 2022 (World Bank; gt's
  ## `countrypops`).
proc illness*(): TableData = (leftOut "illness"; parseCsv(illnessCsv))
  ## Daily tests of a patient with yellow fever, days 3 to 9, with their normal ranges (gt's
  ## `illness`).
proc metro*(): TableData = (leftOut "metro"; parseCsv(metroCsv))
  ## The stations of the Paris Metro, with their lines and passengers in 2021 (gt's `metro`).

proc planets*(): TableData = parseCsv(planetsCsv)
proc exibble*(): TableData = parseCsv(exibbleCsv)
proc isole*(): TableData = (leftOut "isole"; parseCsv(isoleCsv, comment = "#"))
proc citta*(): TableData = (leftOut "citta"; parseCsv(cittaCsv, comment = "#"))

proc tavolaPitagorica*(n = 10): TableData =
  ## An n×n times table: a column `×` with 1..n, then one column per factor ("1" .. "n").
  result = TableData()
  var first: seq[Value]
  for i in 1 .. n: first.add toValue(i)
  result.addColumn("×", first)
  for j in 1 .. n:
    var col: seq[Value]
    for i in 1 .. n: col.add toValue(i * j)
    result.addColumn($j, col)
