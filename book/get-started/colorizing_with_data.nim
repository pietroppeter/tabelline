import tabbook
bookInit()

nbText: "# Colorizing with Data"

attribution gtGuide("Colorizing with Data", "colorizing-with-data",
  "The reshaping of `sza` with Polars is done in plain Nim.")

nbText: """
You sometimes come across heat maps in data visualization, and they're used to represent data values with color gradients. This technique is great for identifying patterns, trends, outliers, and missing data when there's lots of data. Tables can have this sort of treatment as well! Typically, formatted numeric values are shown along with some color treatment coinciding with the underlying data values.

We can make this possible in **Great Tables** by using the `GT.data_color()` method. Let's start with a simple example, using a Polars DataFrame with three columns of values. We can introduce that data to `GT` and use `GT.data_color()` without any arguments.
"""

tabs """
from great_tables import GT
import polars as pl

simple_df = pl.DataFrame(
    {
        "integer": [1, 2, 3, 4, 5],
        "float": [2.3, 1.3, 5.1, None, 4.4],
        "category": ["one", "two", "three", "one", "three"],
    }
)

GT(simple_df).data_color()
""", """
library(gt)
library(dplyr)

simple_df <- tibble(
  integer = c(1L, 2L, 3L, 4L, 5L),
  float = c(2.3, 1.3, 5.1, NA, 4.4),
  category = c("one", "two", "three", "one", "three")
)

gt(simple_df) |> data_color()
""":
  nbCode:
    import tabelline, gtdata

    let simpleDf = tableData:
      integer: [1, 2, 3, 4, 5]
      float: [2.3, 1.3, 5.1, nil, 4.4]
      category: ["one", "two", "three", "one", "three"]

    nbTable tabella(simpleDf).dataColor(everything())

tabelline """
`dataColor()` with no arguments colours the numeric columns only, where Great Tables colours
them all: `dataColor(everything())` does what Great Tables does by default, each column on its
own, numbers along the palette and text by category. Missing values are a light grey in
tabelline, a darker one in Great Tables, which also writes them as `None`. The default palettes
differ: Great Tables' is a red-to-green ramp, tabelline's is `palette("blues")`.
"""

nbText: """
This works but doesn't look all too appealing. However, we can take note of a few things straight away. The first thing is that `GT.data_color()` doesn't format the values but rather it applies color fill values to the cells. The second thing is that you don't have to intervene and modify the text color so that there's enough contrast, **Great Tables** will do that for you (this behavior *can* be deactivated with the `autocolor_text=` argument though).

## Setting palette colors

While this first example illustrated some basic things, the common thing to do in practices to provide a list of colors to the `palette=` argument. Let's choose two colors `"green"` and `"red"` and place them in that order.
"""

tabs """
GT(simple_df).data_color(palette=["blue", "red"])
""", """
gt(simple_df) |> data_color(palette = c("blue", "red"))
""":
  nbCode:
    nbTable tabella(simpleDf).dataColor(everything(), palette = @["blue", "red"])

tabelline """
`dataColor` takes `autoColorText`, as `autocolor_text=`. Colours are CSS names or hex codes in
both.
"""

nbText: """
Now that we've moved away from the default palette and specified colors, we can see that lower numerical values are closer to blue and higher values are closer to red (those in the middle have colors that are a blend of the two; in this case, more in the purple range). Categorical values behave similarly, they take on ordinal values based on their first appearance (from top to bottom) and those values are used to generate the background colors.

## Coloring missing values with `na_color`

There is a lone `"None"` value in the `float` column, and it has a gray background. Throughout the **Great Tables** package, missing values are treated in different ways and, in this case, it's given a default color value. We can change that with the `na_color=` argument. Let's try it now:
"""

tabs """
GT(simple_df).data_color(palette=["blue", "red"], na_color="#FFE4C4")
""", """
gt(simple_df) |> data_color(palette = c("blue", "red"), na_color = "#FFE4C4")
""":
  nbCode:
    nbTable tabella(simpleDf).dataColor(everything(), palette = @["blue", "red"], naColor = "#FFE4C4")

nbText: """
Now, the gray color has been changed to Bisque. Note that when it comes to colors, you can use any combination of CSS/X11 color names and hexadecimal color codes.

## Using `domain=` to color values across columns

The previous usages of the `GT.data_color()` method were such that the color ranges encompassed the boundaries of the data values. That can be changed with the `domain=` argument, which expects a list of two values (a lower and an upper value). Let's use the range `[0, 10]` on the first two columns, `integer` and `float`, and not the third (since a numerical domain is incompatible with string-based values). Here's the table code for that:
"""

tabs """
(
    GT(simple_df)
    .data_color(
        columns=["integer", "float"],
        palette=["blue", "red"],
        domain=[0, 10],
        na_color="white"
    )
)
""", """
gt(simple_df) |>
  data_color(
    columns = c(integer, float),
    palette = c("blue", "red"),
    domain = c(0, 10),
    na_color = "white"
  )
""":
  nbCode:
    nbTable tabella(simpleDf).dataColor(
      columns = ["integer", "float"],
      palette = @["blue", "red"],
      domain = (0.0, 10.0),
      naColor = "white")

tabelline """
`domain` is a pair of floats, `(from, to)`.
"""

nbText: """
Nice! We can clearly see that the color ramp in the first column (`integer`) only proceeds from blue (value: `1`) to purple (value: `5`) and there isn't a reddish color in sight (would need a value close to 10).

## Bringing it all together

For a more advanced treatment of data colorization in the table, let's take the `sza` dataset (available in the `great_tables.data` submodule) and vigorously reshape it with **Polars** so that solar zenith angles are arranged as rows by month, and the half-hourly clock times are the columns (from early morning to solar noon).

Once the `pivot()`ing is done, we can introduce that that table to the `GT` class, placing the names of the months in the table stub. We will use `GT.data_color()` with a domain that runs from `90` to `0` (here, 90&deg; is sunrise, and 0&deg; is represents the sun angle that's directly overhead). There are months where the sun rises later in the morning, before the sunrise times we'll see missing values in the dataset, and `na_color="white"` will handle those cases. Okay, that's the plan, and now here's the code:
"""

tabs """
from great_tables import html
from great_tables.data import sza
import polars.selectors as cs

sza_pivot = (
    pl.from_pandas(sza)
    .filter((pl.col("latitude") == "20") & (pl.col("tst") <= "1200"))
    .select(pl.col("*").exclude("latitude"))
    .drop_nulls()
    .pivot(values="sza", index="month", on="tst", sort_columns=True)
)

(
    GT(sza_pivot, rowname_col="month")
    .data_color(
        domain=[90, 0],
        palette=["rebeccapurple", "white", "orange"],
        na_color="white",
    )
    .tab_header(
        title="Solar Zenith Angles from 05:30 to 12:00",
        subtitle=html("Average monthly values at latitude of 20&deg;N."),
    )
)
""", """
library(tidyr)

sza_pivot <- sza |>
  filter(latitude == 20, tst <= "1200") |>
  select(-latitude) |>
  filter(!is.na(sza)) |>
  pivot_wider(names_from = tst, values_from = sza, names_sort = TRUE)

# gt wants the domain from low to high, so the palette goes the other way;
# R does not know the colour name "rebeccapurple"
gt(sza_pivot, rowname_col = "month") |>
  data_color(
    domain = c(0, 90),
    palette = c("orange", "white", "#663399"),
    na_color = "white"
  ) |>
  tab_header(
    title = "Solar Zenith Angles from 05:30 to 12:00",
    subtitle = html("Average monthly values at latitude of 20&deg;N.")
  )
""":
  nbCode:
    import std/[tables, algorithm, strutils]

    # the pivot, by hand: a row per month, a column per time (hhmm) up to noon
    let s = sza()
    var months: seq[string]
    var times: seq[int]
    var angle: Table[(string, int), Value]
    for i in 0 ..< s.nrows:
      let (lat, month, tst, a) = (s["latitude", i], $s["month", i], s["tst", i].i, s["sza", i])
      if lat == 20 and tst <= 1200 and not a.isNull:
        if month notin months: months.add month
        if tst notin times: times.add tst
        angle[(month, tst)] = a
    times.sort()

    let szaPivot = TableData()
    szaPivot.addColumn("month", toValues(months))
    for t in times:
      var col: seq[Value]
      for m in months: col.add angle.getOrDefault((m, t), null())
      szaPivot.addColumn(align($t, 4, '0'), col)

    nbTable tabella(szaPivot, rownameCol = "month")
      .dataColor(
        domain = (90.0, 0.0),
        palette = @["#663399", "white", "orange"],  # rebeccapurple
        naColor = "white")
      .tabHeader(
        title = "Solar Zenith Angles from 05:30 to 12:00",
        subtitle = html"Average monthly values at latitude of 20&deg;N.")

tabelline """
Two differences. tabelline knows only 17 colour names (`rebeccapurple` is not one of them,
so it is given in hex, as in the R tab: R does not know it either); all the CSS names are a gap. tabelline's CSV reader reads `tst` (`"0400"`) and `latitude` as numbers,
where pandas keeps them as text, so the filter compares numbers. A `domain` from high to
low, `(90.0, 0.0)`, runs the palette the other way, as in Great Tables.
"""

nbText: """
Because this is a table for presentation, we can't neglect using `GT.tab_header()`. A *title* and *subtitle* can provide just enough information to guide the reader out through your table visualization.
"""

bookSave()
