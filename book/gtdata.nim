## The datasets of Great Tables that the book's pages use and tabelline does not ship
## (`tabelline/datasets` has `exibble`, `gtcars`, `countrypops`, `illness` and `metro`, exported
## here): `islands`, `airquality` and `sza`, and `peeps`, `films`, `towny`, `nuclides`,
## `gibraltar` and `reactions` (as CSV text, for nanuq's `readCsv`), and the images of the metro lines, as files in
## book/data/great-tables/, copied from the `great_tables` package (MIT), and gt's `rx_adsl` and
## `rx_addv` in book/data/gt/, written from the `gt` R package (MIT) with their labels. They are read when the
## chapter is compiled (`staticRead`), so a chapter reruns when its data changes.
##
## `head`, `take` and `select` are here too: Great Tables takes a data frame, and the guide cuts its
## data with pandas and Polars; tabelline's `TableData` has no verbs of its own (data frames come later).
import std/[json, os, strutils]
import tabelline, tabelline/datasets
export datasets

const dataDir = currentSourcePath().parentDir & "/data/great-tables/"
const
  islandsCsv = staticRead(dataDir & "islands.csv")
  airqualityCsv = staticRead(dataDir & "airquality.csv")
  szaCsv = staticRead(dataDir & "sza.csv")
const
  peepsCsv* = staticRead(dataDir & "peeps.csv")
    ## Great Tables' `peeps`: 100 made-up people with an address in North America.
  filmsCsv* = staticRead(dataDir & "films.csv")
    ## Great Tables' `films`: the feature films in competition at the Cannes festival, 1946-2024.
  townyCsv* = staticRead(dataDir & "towny.csv")
    ## Great Tables' `towny`: the municipalities of Ontario and their census populations.
  nuclidesCsv* = staticRead(dataDir & "nuclides.csv")
    ## Great Tables' `nuclides`: every known nuclide, its mass, half-life and decay modes.
  gibraltarCsv* = staticRead(dataDir & "gibraltar.csv")
    ## Great Tables' `gibraltar`: the weather at Gibraltar's airport, May 2023, every half hour.
  gamesCsv* = staticRead(dataDir & "games.csv")
    ## The NFL games of 1999-2023 (nflverse, by Lee Sharpe), as the Super Bowl Squares post
    ## reads them, cut to the columns it uses.
  septaStopsCsv* = staticRead(dataDir & "septa/chw-stops.csv")
    ## The stations of SEPTA's Chestnut Hill West line, as the SEPTA timetables post has them.
  septaTimesCsv* = staticRead(dataDir & "septa/times.csv")
    ## The weekend trains of the same line: a row for each station, a column for each train.
  reactionsCsv* = staticRead(dataDir & "reactions.csv")
    ## Great Tables' `reactions`: rate constants of gas-phase reactions of 1,683 organic compounds.

const
  gtDir = currentSourcePath().parentDir & "/data/gt/"
  rxAdslCsv* = staticRead(gtDir & "rx_adsl.csv")
  rxAddvCsv* = staticRead(gtDir & "rx_addv.csv")
  rxMetaJson = staticRead(gtDir & "rx_meta.json")

const
  tabDataDir = currentSourcePath().parentDir.parentDir & "/src/tabelline/data/"
  metroCsv* = staticRead(tabDataDir & "metro.csv")
    ## `metro` (in `tabelline/datasets`) as CSV text, for nanuq's `readCsv`.
  illnessCsv* = staticRead(tabDataDir & "illness.csv")
    ## `illness` (in `tabelline/datasets`) as CSV text, for nanuq's `readCsv`.
  gtcarsCsv* = staticRead(tabDataDir & "gtcars.csv")
    ## `gtcars` (in `tabelline/datasets`) as CSV text, for nanuq's `readCsv`.

const metroImages* = dataDir & "metro_images"
  ## The folder of the metro lines' images (`metro_1.svg`, ...), for `fmtImage(path = ...)`.

proc islands*(): TableData = parseCsv(islandsCsv)
  ## The 48 largest landmasses of the world, area in thousands of square miles (R's `islands`).
proc airquality*(): TableData = parseCsv(airqualityCsv)
  ## Daily air quality in New York, May to September 1973 (R's `airquality`).
proc sza*(): TableData = parseCsv(szaCsv)
  ## Solar zenith angles by latitude, month and half hour of true solar time.

proc rxAdsl*(): TableData = parseCsv(rxAdslCsv)
  ## gt's `rx_adsl`: the subjects of a fictional clinical trial, one row each (an ADSL dataset).
proc rxAddv*(): TableData = parseCsv(rxAddvCsv)
  ## gt's `rx_addv`: the protocol deviations of the same trial (an ADDV dataset).
proc rxMeta*(): JsonNode = parseJson(rxMetaJson)
  ## What R keeps with the columns of `rx_adsl` and `rx_addv`: `label`, `units` and, for a
  ## factor, its `levels` in order (`rxMeta()["rx_adsl"]["SEX"]["levels"]`).

proc tail*(d: TableData, n = 5): TableData =
  ## The last `n` rows.
  result = TableData()
  for c in d.columns:
    result.addColumn(c.name, c.values[max(0, c.values.len - n) .. ^1])

proc head*(d: TableData, n = 5): TableData =
  ## The first `n` rows.
  result = TableData()
  for c in d.columns:
    result.addColumn(c.name, c.values[0 ..< min(n, c.values.len)])

proc take*(d: TableData, rows: openArray[int]): TableData =
  ## The rows at `rows`, in that order (pandas' `.loc[[...]]`, Polars' `[[...]]`).
  result = TableData()
  for c in d.columns:
    var vs: seq[Value]
    for i in rows: vs.add c.values[i]
    result.addColumn(c.name, vs)

proc select*(d: TableData, names: openArray[string]): TableData =
  ## The columns `names`, in that order (pandas' `df[[...]]`).
  result = TableData()
  for n in names: result.addColumn(n, d[n].values)

proc glimpse*(d: TableData, width = 72): string =
  ## A glance at `d`, as dplyr's `glimpse()` and Polars' `glimpse()`: the number of rows and
  ## columns, then a line for each column with its kind and its first values.
  result = "Rows: " & $d.nrows & "\nColumns: " & $d.ncols & "\n"
  var w = 0
  for c in d.columns: w = max(w, c.name.len)
  for c in d.columns:
    var line = "$ " & c.name & spaces(w - c.name.len) & " <" & ($c.kindOf)[2 .. ^1].toLowerAscii & "> "
    for k, v in c.values:
      let s = (if k > 0: ", " else: "") & (if v.isNull: "NA" else: $v)
      if line.len + s.len > width: (line.add ", …"; break)
      line.add s
    result.add line & "\n"
