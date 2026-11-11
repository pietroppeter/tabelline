import tabbook
bookInit()

nbText: "# Row Selection"

attribution gtGuide("Row Selection", "row-selection",
  "The Polars and pandas examples are the same in Nim: `where`.")

nbText: """
Location and formatter functions (e.g. `loc.body()` and `GT.fmt_number()`) can be applied to specific rows, using the `rows=` argument.

Rows may be specified using any of the following:

* None (the default), to select everything.
* an integer for the row's position.
* a list of or integers.
* a **Polars** selector for filtering.
* a function that takes a DataFrame and returns a boolean Series.

The following sections will use a subset of the `exibble` data, to demonstrate these options.
"""

tabelline """
A `RowSel` in tabelline is `allRows()` (the default), an index, an array or seq of indices, a
range (`0..2`), or `where(cond)`, a condition on each row `it`.
"""

tabs """
from great_tables import GT, exibble, loc, style

lil_exibble = exibble[["num", "char", "currency"]].head(3)
gt_ex = GT(lil_exibble)
""", """
library(gt)
library(dplyr)

lil_exibble <- exibble |> select(num, char, currency) |> slice_head(n = 3)
gt_ex <- gt(lil_exibble)
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    let lilExibble = exibble().select(["num", "char", "currency"]).head(3)
    let gtEx = tabella(lilExibble)

nbText: """
## Using integers

Use a single integer, or a list of integers, to select rows by position.
"""

tabs """
gt_ex.fmt_currency("currency", rows=0, decimals=1)
""", """
gt_ex |> fmt_currency(currency, rows = 1, decimals = 1)
""":
  nbCode:
    nbTable gtEx.fmtCurrency("currency", rows = 0, decimals = 1)

nbText: """
Notice that a dollar sign (`$`) was only added to the first row (index `0` in python).

Indexing works the same as selecting items from a python list. This  negative integers select relative to the final row.
"""

tabs """
gt_ex.fmt_currency("currency", rows=[0, -1], decimals=1)
""", """
# R counts from 1 and has no negative positions for the last row
gt_ex |> fmt_currency(currency, rows = c(1, nrow(lil_exibble)), decimals = 1)
""":
  nbCode:
    # no negative indices yet: -1 is the last row, lilExibble.nrows - 1
    nbTable gtEx.fmtCurrency("currency", rows = [0, lilExibble.nrows - 1], decimals = 1)

tabelline """
Indices start from 0 in tabelline too. Negative ones are a gap (Nim writes the last as `^1`,
which would be the way to say it).
"""

nbText: """
## Using polars expressions

The `rows=` argument accepts polars expressions, which return a boolean Series, indicating which rows to operate on.

For example, the code below only formats the `num` column, but only when currency is less than 40.
"""

tabs """
import polars as pl

gt_polars = GT(pl.from_pandas(lil_exibble))

gt_polars.fmt_integer("num", rows=pl.col("currency") < 40)
""", """
gt_ex |> fmt_integer(num, rows = currency < 40)
""":
  nbCode:
    nbTable gtEx.fmtInteger("num", rows = where(it.currency < 40))

nbText: """
Here's a more realistic example, which highlights the row with the highest value for currency.
"""

tabs """
import polars.selectors as cs

gt_polars.tab_style(
    style.fill("yellow"),
    loc.body(
        columns=cs.all(),
        rows=pl.col("currency") == pl.col("currency").max()
    )
)
""", """
gt_ex |>
  tab_style(
    cell_fill("yellow"),
    cells_body(
      columns = everything(),
      rows = currency == max(currency)
    )
  )
""":
  nbCode:
    import std/sequtils
    let top = lilExibble["currency"].values.mapIt(it.toFloat).max

    nbTable gtEx.tabStyle(
      style.fill("yellow"),
      loc.body(cols = everything(), rows = where(it.currency == top)))

tabelline """
`where` sees one row at a time, so a condition on the whole column (its maximum) is computed
first, in plain Nim (`mapIt` is from `std/sequtils`).
"""

nbText: """
## Using a function

Since libraries like `pandas` don't have lazy expressions, the `rows=` argument also accepts a function for selecting rows. The function should take a DataFrame and return a boolean series. A missing value in that series leaves its row unselected, as it does with a polars expression.

Here's the same example as the previous polars section, but with pandas data, and a lambda for selecting rows.
"""

tabs """
gt_ex.fmt_integer("num", rows=lambda D: D["currency"] < 40)
""", """
# without data masking: a plain vector of TRUE/FALSE
gt_ex |> fmt_integer(num, rows = lil_exibble$currency < 40)
""":
  nbCode:
    nbTable gtEx.fmtInteger("num", rows = where(it.currency < 40))

nbText: """
Here's the styling example from the previous polars section.
"""

tabs """
import polars.selectors as cs

gt_ex.tab_style(
    style.fill("yellow"),
    loc.body(
        columns=lambda colname: True,
        rows=lambda D: D["currency"] == D["currency"].max()
    )
)
""", """
gt_ex |>
  tab_style(
    cell_fill("yellow"),
    cells_body(
      columns = everything(),
      rows = lil_exibble$currency == max(lil_exibble$currency)
    )
  )
""":
  nbCode:
    nbTable gtEx.tabStyle(
      style.fill("yellow"),
      loc.body(cols = everything(), rows = where(it.currency == top)))

bookSave()
