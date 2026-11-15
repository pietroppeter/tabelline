import std/[tables, sequtils, algorithm, strutils]
import tabelline

let sales = readCsv("pizzaplace.csv")
let sizes = ["S", "M", "L", "XL", "XXL"]
var count: CountTable[(string, string)]
var revenue: Table[string, float]
var total = 0.0
for i in 0 ..< sales.nrows:
  let ty = $sales["type", i]
  let p = sales["price", i].toFloat
  count.inc((ty, $sales["size", i]))
  revenue.mgetOrPut(ty, 0.0) += p
  total += p
let types = toSeq(revenue.keys).sortedByIt(-revenue[it])

var columns = @[("type", toValues(types.mapIt(it.capitalizeAscii())))]
for s in sizes:
  columns.add (s, toValues(types.mapIt(count.getOrDefault((it, s), 0))))
columns.add ("pizzas", toValues(types.mapIt(sizes.foldl(a + count.getOrDefault((it, b), 0), 0))))
columns.add ("revenue", toValues(types.mapIt(revenue[it])))
columns.add ("share", toValues(types.mapIt(revenue[it] / total)))

let t = tabella(toTableData(columns), rownameCol = "type"):
  tabHeader md("**Pizza sales in 2015, by type and size**"), md("Number of pizzas sold; types ordered by revenue")
  tabSpanner "Pizzas sold by size", sizes
  colsLabel:
    pizzas: "All sizes"
    revenue: "Revenue, $"
    share: "Share of revenue"
  fmtNumber sizes, decimals = 0
  fmtNumber "pizzas", decimals = 0
  fmtNumber "revenue", decimals = 0
  fmtPercent "share", decimals = 1
  subZero sizes, zeroText = "–"
  grandSummaryRows:
    "All types": agg.sum
  tabSourceNote "Source: pizzaplace.csv, one row per pizza sold (5,000 pizzas). Revenue assumes prices in US dollars."
echo t
t.save "report.html"
