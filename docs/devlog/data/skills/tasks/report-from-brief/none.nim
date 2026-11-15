import std/[tables, strutils, algorithm, sequtils]
import tabelline

const sizes = ["S", "M", "L", "XL", "XXL"]

# count pizzas and revenue by (type, size)
var cnt: Table[(string, string), int]
var rev: Table[string, float]
var types: seq[string]
let raw = readCsv("pizzaplace.csv")
for i in 0 ..< raw.nrows:
  let ty = $raw["type", i]
  let sz = $raw["size", i]
  if ty notin types: types.add ty
  cnt.mgetOrPut((ty, sz), 0) += 1
  rev.mgetOrPut(ty, 0.0) += raw["price", i].toFloat

# best-selling type first
proc total(ty: string): int = sizes.mapIt(cnt.getOrDefault((ty, it))).foldl(a + b)
types.sort(proc (a, b: string): int = cmp(total(b), total(a)))

var d = TableData()
d.addColumn("type", types.mapIt(toValue(it.capitalizeAscii)))
for s in sizes:
  d.addColumn(s, types.mapIt(if cnt.hasKey((it, s)): toValue(cnt[(it, s)]) else: toValue(nil)))

d.addColumn("Revenue", types.mapIt(toValue(rev[it])))

let t = tabella(d, rownameCol = "type"):
  tabHeader "Pizzas sold in 2015", "by type and size, with revenue"
  tabStubhead "Type"
  tabSpanner "Size", ["S", "M", "L", "XL", "XXL"]
  summaryColumns:
    Total: agg.sum
    columns = cols("S", "M", "L", "XL", "XXL")
  fmtInteger cols("S", "M", "L", "XL", "XXL", "Total")
  fmtCurrency cols("Revenue"), currency = "USD", decimals = 0
  dataColor cols("S", "M", "L", "XL", "XXL"), palette = palette("pastelli")
  colsMove cols("Total"), after = "XXL"
  colsAlign alRight
  subMissing everything(), missingText = "–"
  grandSummaryRows:
    "All types": agg.sum
    columns = cols("S", "M", "L", "XL", "XXL", "Total", "Revenue")
  tabSourceNote "Source: pizzaplace.csv, 5,000 pizzas sold in 2015. – means none sold."

echo t
t.save "report.html"
