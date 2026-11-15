import std/[sequtils, sugar]
import tabelline, tabelline/datasets

# filter(ctry_origin %in% c("Germany", "Italy")) |> select(model, ctry_origin, hp, mpg_c, mpg_h, msrp)
let cars = gtcars()
let keep = toSeq(0 ..< cars.nrows).filterIt(cars["ctry_origin", it] in [toValue("Germany"), toValue("Italy")])
let data = TableData()
for name in ["model", "ctry_origin", "hp", "mpg_c", "mpg_h", "msrp"]:
  data.addColumn(name, keep.mapIt(cars[name, it]))

let t = tabella(data, rownameCol = "model", groupnameCol = "ctry_origin"):
  tabHeader md("**German and Italian** cars")
  colsMergeRange "mpg_c", "mpg_h"
  colsLabel [("mpg_c", "MPG (city–hwy)"), ("hp", "HP"), ("msrp", "Price")]
  fmtCurrency "msrp", decimals = 0
  summaryRows(fns = {"Average": agg.mean}, columns = cols("hp", "msrp"), missingText = "",
              fmt = (x: float) => formatNumber(x, decimals = 0))
  grandSummaryRows(fns = {"Max": agg.max}, columns = cols("msrp"), missingText = "",
                   fmt = (x: float) => formatCurrency(x, decimals = 0))
  dataColor "hp", palette = palette("viridis")

echo t
t.save "port.html"
