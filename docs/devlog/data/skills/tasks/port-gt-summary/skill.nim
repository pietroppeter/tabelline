import std/[sequtils]
import tabelline, tabelline/datasets

# filter(ctry_origin %in% c("Germany","Italy")) |> select(...)
let src = gtcars()
let keep = toSeq(0 ..< src.nrows).filterIt($src["ctry_origin", it] in ["Germany", "Italy"])
var cols: seq[(string, seq[Value])]
for c in ["model", "ctry_origin", "hp", "mpg_c", "mpg_h", "msrp"]:
  cols.add (c, keep.mapIt(src[c, it]))

let t = tabella(toTableData(cols.mapIt((it[0], toValues(it[1])))),
                rownameCol = "model", groupnameCol = "ctry_origin"):
  tabHeader md("**German and Italian** cars")
  colsMergeRange "mpg_c", "mpg_h"
  colsLabel:
    mpg_c: "MPG (city–hwy)"
    hp: "HP"
    msrp: "Price"
  fmtCurrency(columns = "msrp", decimals = 0)
  summaryRows:
    Average: agg.mean
    columns = ["hp", "msrp"]
    fmtNumber(decimals = 0)
  grandSummaryRows:
    Max: agg.max
    columns = "msrp"
    fmtCurrency(decimals = 0)
  dataColor(columns = "hp", palette = palette("viridis"))

echo t
t.save "port.html"
