## The datasets of Great Tables that the book's pages use and tabelline does not ship
## (`tabelline/datasets` has `exibble`, `gtcars`, `countrypops`, `illness` and `metro`, exported
## here): `islands`, `airquality` and `sza`, and the images of the metro lines, as files in
## book/data/great-tables/, copied from the `great_tables` package (MIT). They are read when the
## chapter is compiled (`staticRead`), so a chapter reruns when its data changes.
##
## `head`, `take` and `select` are here too: Great Tables takes a data frame, and the guide cuts its
## data with pandas and Polars; tabelline's `TableData` has no verbs of its own (data frames come later).
import std/os
import tabelline, tabelline/datasets
export datasets

const dataDir = currentSourcePath().parentDir & "/data/great-tables/"
const
  islandsCsv = staticRead(dataDir & "islands.csv")
  airqualityCsv = staticRead(dataDir & "airquality.csv")
  szaCsv = staticRead(dataDir & "sza.csv")

const metroImages* = dataDir & "metro_images"
  ## The folder of the metro lines' images (`metro_1.svg`, ...), for `fmtImage(path = ...)`.

proc islands*(): TableData = parseCsv(islandsCsv)
  ## The 48 largest landmasses of the world, area in thousands of square miles (R's `islands`).
proc airquality*(): TableData = parseCsv(airqualityCsv)
  ## Daily air quality in New York, May to September 1973 (R's `airquality`).
proc sza*(): TableData = parseCsv(szaCsv)
  ## Solar zenith angles by latitude, month and half hour of true solar time.

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
