## The datasets of Great Tables that the Get Started guide uses and tabelline does not ship yet
## (`tabelline/datasets` has `exibble`): `islands`, `airquality` and `sza`, as CSV files in
## book/data/great-tables/, copied from the `great_tables` package (MIT). They are read when the
## chapter is compiled (`staticRead`), so a chapter reruns when its data changes.
##
## `head`, `take` and `select` are here too: Great Tables takes a data frame, and the guide cuts its
## data with pandas and Polars; tabelline's `TableData` has no verbs of its own (data frames come in 0.3).
import std/os
import tabelline

const dataDir = currentSourcePath().parentDir & "/data/great-tables/"
const
  islandsCsv = staticRead(dataDir & "islands.csv")
  airqualityCsv = staticRead(dataDir & "airquality.csv")
  szaCsv = staticRead(dataDir & "sza.csv")

proc islands*(): TableData = parseCsv(islandsCsv)
  ## The 48 largest landmasses of the world, area in thousands of square miles (R's `islands`).
proc airquality*(): TableData = parseCsv(airqualityCsv)
  ## Daily air quality in New York, May to September 1973 (R's `airquality`).
proc sza*(): TableData = parseCsv(szaCsv)
  ## Solar zenith angles by latitude, month and half hour of true solar time.

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
