import tabbook
bookInit()

nbText: "# Great Tables `v0.2.0`: Easy Data Coloring"

attribution gtBlog("Great Tables v0.2.0: Easy Data Coloring", "introduction-0.2.0/", "Rich Iannone",
  "24 Jan 2024", "The links to the *Get Started* guide point to the book's ports of its pages.")

nbText: """
We enjoy working on **Great Tables** because we want everybody to easily make beautiful tables. Tables don't have to be boring, they really could be captivating and insightful. With every release we get closer and closer to realizing our mission and, as such, we're happy to announce the `v0.2.0` release that's now on PyPI.

The really big feature that's available with this release is the `data_color()` method. It gives you several options for colorizing data cells based on the underlying data. The method automatically scales color values according to the data in order to emphasize differences or reveal trends. The example below emphasizes large currency values with a `"darkgreen"` fill color.
"""

tabs """
from great_tables import GT, exibble

(
    GT(exibble[["currency", "date", "row"]].head(4), rowname_col="row")
    .data_color(
        columns="currency",
        palette=["lightblue", "darkgreen"]
    )
)
""", """
library(gt)
library(dplyr)

exibble |>
  select(currency, date, row) |>
  head(4) |>
  gt(rowname_col = "row") |>
  data_color(
    columns = currency,
    palette = c("lightblue", "darkgreen")
  )
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    let exibbleMini = exibble().select(["currency", "date", "row"]).head(4)

    let colored = tabella(exibbleMini, rownameCol = "row"):
      dataColor cols("currency"), palette = @["lightblue", "darkgreen"]
    nbTable colored

nbText: """
Note that we use `columns=` to specify which columns get the colorizing treatment (just `currency` here) and the `palette=` is given as a list of color values. From this we can see that the `65100.0` value polarizes the data coloring process; it is `"darkgreen"` while all other values are `"lightblue"` (with no interpolated colors in between). Also, isn't it nice that the text adapts to the background color?

The above example is suitable for emphasizing large values, but, maybe you consider the extreme value to be something that's out of bounds? For that, we can use the `domain=` and `na_value=` arguments to gray-out the extreme values. We'll also nicely format the `currency` column in this next example.
"""

tabs """
(
    GT(exibble[["currency", "date", "row"]].head(4), rowname_col="row")
    .data_color(
        columns="currency",
        palette=["lightblue", "darkgreen"],
        domain=[0, 50],
        na_color="lightgray"
    )
    .fmt_currency(
        columns="currency",
        currency="GBP",
        use_subunits=False
    )
)
""", """
exibble |>
  select(currency, date, row) |>
  head(4) |>
  gt(rowname_col = "row") |>
  data_color(
    columns = currency,
    palette = c("lightblue", "darkgreen"),
    domain = c(0, 50),
    na_color = "lightgray"
  ) |>
  fmt_currency(
    columns = currency,
    currency = "GBP",
    use_subunits = FALSE
  )
""":
  nbCode:
    let grayedOut = tabella(exibbleMini, rownameCol = "row"):
      dataColor cols("currency"),
        palette = @["lightblue", "darkgreen"],
        domain = (0.0, 50.0),
        naColor = "lightgray"
      fmtCurrency "currency",
        currency = "GBP",
        useSubunits = false
    nbTable grayedOut

tabelline """
`domain` is a pair of floats, its low and its high end. A value outside it takes `naColor`, as
in Great Tables.
"""

nbText: """
Now the very large value is in `"lightgray"`, making all other values easier to compare. We did setting `domain=[0, 50]` and specifying `na_color="lightgray"`. This caused the out-of-bounds value of `65100` to have a light gray background. Notice that the values are also formatted as currencies, and this is thanks to `fmt_currency()` which never interferes with styling.

Here's a more inspirational example that uses a heavily-manipulated version of the `countrypops` dataset (thanks again, **Polars**!) along with a color treatment that's mediated by `data_color()`. Here, the population values can be easily compared by the amount of `"purple"` within them.
"""

tabs """
from great_tables.data import countrypops
import polars as pl
import polars.selectors as cs

wide_pops = (
    pl.from_pandas(countrypops)
    .filter(
        pl.col("country_code_2").is_in(["FM", "GU", "KI", "MH", "MP", "NR", "PW"])
        & pl.col("year").is_in([2000, 2010, 2020])
    )
    .pivot(index="country_name", on="year", values="population")
    .sort("2020", descending=True)
)

(
    GT(wide_pops, rowname_col="country_name")
    .tab_header(
        title="Populations of Select Countries in Oceania",
        subtitle="Population values are from 2000, 2010, and 2020.",
    )
    .tab_spanner(label="Total Population", columns=cs.all())
    .fmt_integer(columns=["2000", "2010", "2020"])
    .data_color(palette=["white", "purple"], domain=[0, 1.7e5])
)
""", """
library(tidyr)

wide_pops <-
  countrypops |>
  filter(
    country_code_2 %in% c("FM", "GU", "KI", "MH", "MP", "NR", "PW"),
    year %in% c(2000, 2010, 2020)
  ) |>
  select(country_name, year, population) |>
  pivot_wider(names_from = year, values_from = population) |>
  arrange(desc(`2020`))

wide_pops |>
  gt(rowname_col = "country_name") |>
  tab_header(
    title = "Populations of Select Countries in Oceania",
    subtitle = "Population values are from 2000, 2010, and 2020."
  ) |>
  tab_spanner(label = "Total Population", columns = everything()) |>
  fmt_integer(columns = c(`2000`, `2010`, `2020`)) |>
  data_color(palette = c("white", "purple"), domain = c(0, 1.7e5))
""":
  nbCode:
    import std/[algorithm, sequtils, tables]

    let pops = countrypops()
    let codes = ["FM", "GU", "KI", "MH", "MP", "NR", "PW"]
    var byCountry: OrderedTable[string, seq[Value]]
    for i in 0 ..< pops.nrows:
      let year = int(pops["year", i].toFloat)
      if $pops["country_code_2", i] in codes and year in [2000, 2010, 2020]:
        byCountry.mgetOrPut($pops["country_name", i], newSeq[Value](3))[(year - 2000) div 10] =
          pops["population", i]
    var rows = toSeq(byCountry.pairs)
    rows.sort(proc (a, b: (string, seq[Value])): int = cmp(b[1][2].toFloat, a[1][2].toFloat))

    let widePops = toTableData({
      "country_name": rows.mapIt(toValue(it[0])),
      "2000": rows.mapIt(it[1][0]),
      "2010": rows.mapIt(it[1][1]),
      "2020": rows.mapIt(it[1][2])})

    let oceania = tabella(widePops, rownameCol = "country_name"):
      tabHeader "Populations of Select Countries in Oceania",
        "Population values are from 2000, 2010, and 2020."
      tabSpanner "Total Population", everything()
      fmtInteger cols("2000", "2010", "2020")
      dataColor palette = @["white", "purple"], domain = (0.0, 1.7e5)
    nbTable oceania

tabelline """
tabelline has no data frames yet (they are planned for a later release), so the filter and the pivot
that Polars does in one chain are a loop over the rows here: each country gets its three
populations, and the rows are sorted by the last one.
"""

nbText: """
This was just a sampler of what you can do with the all-new `data_color()` method. Take a look at these pages for more information:

- The [*Colorizing with Data*](../get-started/colorizing_with_data.html) page in the *Get Started* Guide, which provides more details on how to use `data_color()`
- The guide on [Basic Styling](../get-started/basic_styling.html) covers general styling (e.g., bold text, underlines, etc.) with `tab_style()`
- The reference pages for [`data_color()`](https://posit-dev.github.io/great-tables/reference/GT.data_color.html) and [`tab_style()`](https://posit-dev.github.io/great-tables/reference/GT.tab_style.html)

To conclude, we're happy that this new functionality is now in the **Great Tables** package! We hope you find it useful for your table-generation work. And we'll keep improving upon it so that you'll have more possibilities to make beautiful, and colorful, tables for presentation.
"""

bookSave()
