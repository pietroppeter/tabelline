# Data made in code

tabelline shows data; it does not group, join, pivot or sort the rows that make it (gt leaves
that to dplyr, Great Tables to Polars). Do those steps in plain Nim with `std/tables`, then hand
tabelline columns. This is most of the work of porting a table whose Python or R starts with a
data frame, so write it first and print the result before any styling.

What to use:

- **Read**: `readCsv(path)` or `parseCsv(text)` give a `TableData`. For JSON, read it with
  `std/json` and build the columns as below.
- **A cell is a `Value`**: `$v` is its text, `v.toFloat` its number, `v.isNull` says it is
  missing. `data["column", i]` is the cell of row `i`; `data.nrows` the number of rows. Do not
  read `v.f` or `v.i` directly: the wrong one fails when the program runs.
  `data.names` lists the columns. `readCsv` leaves times (`06:51:00`) and codes with a zero in
  front as text.
- **Group, count, sum**: a `Table` or a `CountTable` keyed by the group (a tuple for two keys).
- **Join**: a `Table` from the key to what you look up.
- **Sort**: sort the keys in Nim before you make the columns. (`rowOrder` only changes the
  order shown.)
- **Build**: a `seq` of `(name, toValues(seq))` pairs, then `toTableData(columns)`. Column
  names can be computed. `null()` is a missing value (a hole in a pivot); `subMissing` shows it
  as a dash. `tableData:` is for values written out by
  hand.
- **Dataframes**: if the project already uses [nanuq](https://github.com/pietroppeter/nanuq)
  (Polars for Nim), `import tabelline/nanuq` and `tabella(df)`. Do not add it for one table.

```nim
import std/[tables, sequtils, algorithm]
import tabelline

# rows as they come: one sale per row (here from text; `readCsv("sales.csv")` reads a file)
let sales = parseCsv("""shop,size,price
Trento,S,8.5
Trento,L,12
Bari,S,8
Trento,S,8.5
Bari,L,11.5
Bari,L,11.5
""")
let regions = {"Trento": "North", "Bari": "South"}.toTable   # a join is a lookup in a Table

# group and count: a cell is a `Value`: `$v` its text, `v.toFloat` its number
var count: CountTable[(string, string)]
var revenue: Table[string, float]
for i in 0 ..< sales.nrows:
  let shop = $sales["shop", i]
  count.inc((shop, $sales["size", i]))
  revenue.mgetOrPut(shop, 0.0) += sales["price", i].toFloat

# pivot: one row per shop, one column per size; sort before making the table
let sizes = ["S", "L"]
let shops = toSeq(revenue.keys).sortedByIt(-revenue[it])
var columns = @[("shop", toValues(shops)), ("region", toValues(shops.mapIt(regions[it])))]
for size in sizes:
  columns.add (size, toValues(shops.mapIt(count[(it, size)])))
columns.add ("revenue", toValues(shops.mapIt(revenue[it])))

let t = tabella(toTableData(columns), rownameCol = "shop"):
  tabSpanner "Pizzas sold", sizes
  fmtCurrency "revenue", currency = "EUR"
echo t
```

```text
┌────────┬────────┬───┬─────────┬─────────┐
│        │        │ Pizzas sold │         │
│        │ region │ S │       L │ revenue │
╞════════╪════════╪═══╪═════════╪═════════╡
│ Bari   │ South  │ 1 │       2 │  €31.00 │
│ Trento │ North  │ 2 │       1 │  €29.00 │
└────────┴────────┴───┴─────────┴─────────┘
```
