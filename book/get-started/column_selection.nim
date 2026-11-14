import tabbook
bookInit()

nbText: "# Column Selection"

attribution gtGuide("Column Selection", "column-selection",
  "tabelline selects columns by name or by rule; where the original selects by position, " &
  "with a function, or with Polars selectors, the Nim tab names the columns or uses the rule " &
  "that comes closest.")

nbText: """
The `columns=` argument for methods like `GT.tab_spanner()`, `GT.cols_move()`, and `GT.tab_style` allows a range of options for selecting columns.

The simplest approach is just a list of strings with the exact column names. However, we can specify columns using any of the following:

* a single string column name.
* an integer for the column's position.
* a list of strings or integers.
* a **Polars** selector.
* a function that takes a string and returns `True` or `False`.
"""

tabelline """
A `ColSel` in tabelline is a column name, an array or seq of names, or a rule: `everything()`,
`startsWith(...)`, `endsWith(...)`, `containing(...)`, `numeric()`, `textual()`,
`ofKind(vkBool)` (Polars' `cs.by_dtype`), `positions(...)` from 0, and `named(cond)`, any test
of the name `it` (Great Tables' function; `matches(proc)` takes a proc). Rules join: `a + b`
(Polars' `|`), `a - b` (`exclude`), `a & b` (the columns of both). gt's `matches()` takes a
regular expression; tabelline has none, and `named` does the same with a test.
"""

tabs """
from great_tables import GT
from great_tables.data import exibble

lil_exibble = exibble[["num", "char", "fctr", "date", "time"]].head(4)
gt_ex = GT(lil_exibble)

gt_ex
""", """
library(gt)
library(dplyr)

lil_exibble <- exibble |> select(num, char, fctr, date, time) |> slice_head(n = 4)
gt_ex <- gt(lil_exibble)

gt_ex
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    let lilExibble = exibble().select(["num", "char", "fctr", "date", "time"]).head(4)
    let gtEx = tabella(lilExibble)

    nbTable gtEx

nbText: """
## Using integers

We can use a list of strings or integers to select columns by name or position, respectively.
"""

tabs """
gt_ex.cols_move_to_start(columns=["date", 1, -1])
""", """
# R counts from 1: column 2 is char, last_col() the last one
gt_ex |> cols_move_to_start(columns = c(date, 2, last_col()))
""":
  nbCode:
    # a Nim list holds one kind of value: "date" is position 3
    nbTable gtEx.colsMoveToStart(positions(3, 1, -1))

nbText: """
Note the code above moved the following columns:

* The string `"date"` matched the column of the same name.
* The integer `1` matched the second column (this is similar to list indexing).
* The integer `-1` matched the last column.

Moreover, the order of the list defines the order of selected columns. In this case, `"data"` was the first entry, so it's the very first column in the new table.

## Using **Polars** selectors

When using a **Polars** DataFrame, you can select columns using [**Polars** selectors](https://pola-rs.github.io/polars/py-polars/html/reference/selectors.html). The example below uses **Polars** selectors to move all columns that start with `"c"` or `"f"` to the start of the table.
"""

tabs """
import polars as pl
import polars.selectors as cs

pl_df = pl.from_pandas(lil_exibble)

GT(pl_df).cols_move_to_start(columns=cs.starts_with("c") | cs.starts_with("f"))
""", """
gt_ex |> cols_move_to_start(columns = starts_with("c") | starts_with("f"))
""":
  nbCode:
    nbTable gtEx.colsMoveToStart(startsWith("c") + startsWith("f"))

tabelline """
`+` is Polars' `|`: the columns of either rule, in the order of the data (`char, fctr`), as in
Polars. A rule resolves to the names it selects with `resolve(data)`.
"""

nbText: """
In general, selection should match the behaviors of the **Polars** `DataFrame.select()` method.
"""

python """
pl_df.select(cs.starts_with("c") | cs.starts_with("f")).columns
""", """
names(tidyselect::eval_select(quote(starts_with("c") | starts_with("f")), lil_exibble))
"""

nbText: """
See the [Selectors page in the polars docs](https://pola-rs.github.io/polars/py-polars/html/reference/selectors.html) for more information on this.


## Using functions

A function can be used to select columns. It should take a column name as a string and return `True` or `False`.
"""

tabs """
gt_ex.cols_move_to_start(columns=lambda x: "c" in x)
""", """
gt_ex |> cols_move_to_start(columns = contains("c"))
""":
  nbCode:
    import std/strutils   # `in` for texts
    nbTable gtEx.colsMoveToStart(named("c" in it))

bookSave()
