import tabbook
bookInit()

nbText: "# Great Tables `v0.4.0`: Nanoplots and More"

attribution gtBlog("Great Tables v0.4.0: Nanoplots and More", "introduction-0.4.0/", "Rich Iannone",
  "19 Mar 2024", "The code of the first table is shown, not folded. The link of `save()` points " &
  "to its reference page today, `gtsave()`; the one to Polars' list columns, to their page " &
  "today; the one to the *Get Started* guide on nanoplots, to " &
  "the book's port of it.")

nbText: """
The recent `v0.4.0` release of **Great Tables** contains nanoplots as a major new feature. So, in this post I'll concentrate on showing you all the things you can do with nanoplots. What are nanoplots? Well, with nanoplots you can do this:
"""

tabs """
from great_tables import GT, md
from great_tables.data import illness
import polars as pl

illness_mini = (
    pl.from_pandas(illness)
    .head(10)
    .select(
        "test", values=pl.concat_str(pl.exclude("test", "units"), separator=" ", ignore_nulls=True)
    )
    .slice(1, 9)
)

(
    GT(illness_mini, rowname_col="test")
    .fmt_nanoplot(columns="values")
    .tab_header(md("Partial summary of daily tests<br>performed on YF patient"))
    .tab_stubhead(label=md("**Test**"))
    .cols_label(values=md("*Progression*"))
    .cols_align(align="center", columns="values")
    .tab_source_note(source_note="Measurements from Day 3 through to Day 8.")
)
""", """
library(gt)
library(dplyr)

illness |>
  head(10) |>
  slice(2:10) |>
  select(-units) |>
  gt(rowname_col = "test") |>
  cols_nanoplot(
    columns = c(starts_with("day"), norm_l, norm_u),
    new_col_name = "values",
    new_col_label = md("*Progression*"),
    missing_vals = "remove"
  ) |>
  tab_header(md("Partial summary of daily tests<br>performed on YF patient")) |>
  tab_stubhead(label = md("**Test**")) |>
  cols_align(align = "center", columns = values) |>
  tab_source_note(source_note = "Measurements from Day 3 through to Day 8.")
""":
  nbCode:
    import std/[sequtils, strutils]
    import tabelline, gtdata

    let illness = illness().head(10)
    var tests, values: seq[Value]
    for i in 1 ..< illness.nrows:   # .slice(1, 9): all rows but the first
      tests.add illness["test", i]
      let cells = illness.names.filterIt(it notin ["test", "units"]).mapIt(illness[it, i])
      values.add toValue(cells.filterIt(not it.isNull).mapIt($it).join(" "))
    let illnessMini = toTableData({"test": tests, "values": values})

    let progression = tabella(illnessMini, rownameCol = "test"):
      fmtNanoplot "values"
      tabHeader md"Partial summary of daily tests<br>performed on YF patient"
      tabStubhead md"**Test**"
      colsLabel:
        values: md"*Progression*"
      colsAlign alCenter, "values"
      tabSourceNote "Measurements from Day 3 through to Day 8."
    nbTable progression

tabelline """
The Polars chain is a loop here: for each test but the first, the values of every column but
`test` and `units`, missing ones left out, joined by spaces. Polars' `exclude` takes the normal
range (`norm_l` and `norm_u`) too, so the last two points of a plot are its bounds, in the
original as here. `colsNanoplot` would make the plots straight from the columns (gt's
`cols_nanoplot()`, the R tab).
"""

nbText: """
While the emphasis here will be on the aforementioned nanoplots feature, the last two releases (`v0.3.1` and `v0.4.0`) overall gave us a nice collection of improvements which includes:

- the [`fmt_nanoplot()`](https://posit-dev.github.io/great-tables/reference/GT.fmt_nanoplot.html) method for adding nanoplots to your table
- improved HTML table representations in different code environments
- integration of Polars selectors in the `columns=` arg of all formatting (`fmt_*()`) methods
- the [`save()`](https://posit-dev.github.io/great-tables/reference/GT.gtsave.html) method for saving a **GT** table as an image file
- rendering a **GT** table as an HTML string though [`as_raw_html()`](https://posit-dev.github.io/great-tables/reference/GT.as_raw_html.html)

Now let's dive into the wonderful world of nanoplots!
"""

tabelline """
tabelline has `toHtml` for the HTML string; it has no `save` to an image.
"""

nbText: """
### Nanoplots, small interactive plots in your table

Nanoplots are small yet information-laden plots that fit nicely into table cells. They are interactive, allowing for more information to be shown on hovering (or through touch when that interaction is available). Nanoplots try to show individual data points with reasonably good visibility (space is limited, this is going in a table after all!) and the plot representations change depending on the data fed into them.

We can generate nanoplots via the [`fmt_nanoplot()`](https://posit-dev.github.io/great-tables/reference/GT.fmt_nanoplot.html) method. Let's make two nanoplots of the two different available plot types: `"line"` and `"bar"`:
"""

tabs """
random_numbers_df = pl.DataFrame(
    {
        "i": range(1, 5),
        "lines": [
            "20 23 6 7 37 23 21 4 7 16",
            "2.3 6.8 9.2 2.42 3.5 12.1 5.3 3.6 7.2 3.74",
            "-12 -5 6 3.7 0 8 -7.4",
            "2 0 15 7 8 10 1 24 17 13 6",
        ],
    }
).with_columns(bars=pl.col("lines"))

(
    GT(random_numbers_df, rowname_col="i")
    .fmt_nanoplot(columns="lines", plot_type="line")
    .fmt_nanoplot(columns="bars", plot_type="bar")
)
""", """
random_numbers_df <-
  tibble(
    i = 1:4,
    lines = c(
      "20 23 6 7 37 23 21 4 7 16",
      "2.3 6.8 9.2 2.42 3.5 12.1 5.3 3.6 7.2 3.74",
      "-12 -5 6 3.7 0 8 -7.4",
      "2 0 15 7 8 10 1 24 17 13 6"
    )
  ) |>
  mutate(bars = lines)

random_numbers_df |>
  gt(rowname_col = "i") |>
  cols_nanoplot(columns = lines, new_col_name = "lines_plot", new_col_label = "lines", plot_type = "line") |>
  cols_nanoplot(columns = bars, new_col_name = "bars_plot", new_col_label = "bars", plot_type = "bar")
""":
  nbCode:
    let numbers = @["20 23 6 7 37 23 21 4 7 16",
                    "2.3 6.8 9.2 2.42 3.5 12.1 5.3 3.6 7.2 3.74",
                    "-12 -5 6 3.7 0 8 -7.4",
                    "2 0 15 7 8 10 1 24 17 13 6"]
    let randomNumbersDf = tableData:
      i: [1, 2, 3, 4]
      lines: numbers
      bars: numbers

    let linesAndBars = tabella(randomNumbersDf, rownameCol = "i"):
      fmtNanoplot "lines", plotType = "line"
      fmtNanoplot "bars", plotType = "bar"
    nbTable linesAndBars

nbText: """
As can be seen, the method accepts bundles of values per cell that are formatted as strings (with spaces between each of the values). You can also use [Polars list columns](https://docs.pola.rs/user-guide/expressions/lists-and-arrays/) as acceptable input.
"""

tabelline """
tabelline takes the same strings, and a cell can also hold a list, as Polars' list columns do:
`@[20.0, 23, 6, 7]` is a nanoplot of four values.
"""

nbText: """
### Adding reference lines and highlighted areas

It's possible to add in a reference line and a reference area to individual plots. These may be useful to highlight a particular statistic (e.g., median or minimum value) or a bounded region of interest (e.g., the area between the first and third quartiles). Here is an example of how to use these options via the `reference_line=` and `reference_area=` arguments:
"""

tabs """
(
    GT(random_numbers_df, rowname_col="i")
    .fmt_nanoplot(
        columns="lines",
        reference_line="mean",
        reference_area=["min", "q1"]
    )
    .fmt_nanoplot(
        columns="bars",
        plot_type="bar",
        reference_line="max",
        reference_area=["max", "median"])
)
""", """
random_numbers_df |>
  gt(rowname_col = "i") |>
  cols_nanoplot(
    columns = lines,
    new_col_name = "lines_plot",
    new_col_label = "lines",
    reference_line = "mean",
    reference_area = c("min", "q1")
  ) |>
  cols_nanoplot(
    columns = bars,
    new_col_name = "bars_plot",
    new_col_label = "bars",
    plot_type = "bar",
    reference_line = "max",
    reference_area = c("max", "median")
  )
""":
  nbCode:
    let references = tabella(randomNumbersDf, rownameCol = "i"):
      fmtNanoplot "lines",
        referenceLine = "mean",
        referenceArea = ("min", "q1")
      fmtNanoplot "bars",
        plotType = "bar",
        referenceLine = "max",
        referenceArea = ("max", "median")
    nbTable references

nbText: """
Having a reference line and/or area can be valuable in different situations. We make it easy by allowing you to mix-and-match numeric values and a set of keywords (these are: `"mean"`, `"median"`, `"min"`, `"max"`, `"q1"`, `"q3"`, `"first"`, or `"last"`).

### Simple bars

We can also have single-value bar plots and line plots. These will run in the horizontal direction and such plots are meant for easy value comparisons (which works great in tables). To make this work, give [`fmt_nanoplot()`](https://posit-dev.github.io/great-tables/reference/GT.fmt_nanoplot.html) a column of numeric values. The following example shows how [`fmt_nanoplot()`](https://posit-dev.github.io/great-tables/reference/GT.fmt_nanoplot.html) can be used to create single-value bar and line plots.
"""

tabs """
single_vals_df = pl.DataFrame(
    {
        "i": range(1, 6),
        "bars": [4.1, 1.3, -5.3, 0, 8.2],
        "lines": [12.44, 6.34, 5.2, -8.2, 9.23]
    }
)

(
    GT(single_vals_df, rowname_col="i")
    .fmt_nanoplot(columns="bars", plot_type="bar")
    .fmt_nanoplot(columns="lines", plot_type="line")
)
""", """
single_vals_df <-
  tibble(
    i = 1:5,
    bars = c(4.1, 1.3, -5.3, 0, 8.2),
    lines = c(12.44, 6.34, 5.2, -8.2, 9.23)
  )

single_vals_df |>
  gt(rowname_col = "i") |>
  cols_nanoplot(columns = bars, new_col_name = "bars_plot", new_col_label = "bars", plot_type = "bar") |>
  cols_nanoplot(columns = lines, new_col_name = "lines_plot", new_col_label = "lines", plot_type = "line")
""":
  nbCode:
    let singleValsDf = tableData:
      i: [1, 2, 3, 4, 5]
      bars: [4.1, 1.3, -5.3, 0.0, 8.2]
      lines: [12.44, 6.34, 5.2, -8.2, 9.23]

    let simpleBars = tabella(singleValsDf, rownameCol = "i"):
      fmtNanoplot "bars", plotType = "bar"
      fmtNanoplot "lines", plotType = "line"
    nbTable simpleBars

nbText: """
Notice that there is some light interactivity available here as well! When hovering over a plotted bar or line the data value will appear.

### Customizing with `nanoplot_options()`

We provide a lot of options for customizing your nanoplots. With the [`nanoplot_options()`](https://posit-dev.github.io/great-tables/reference/nanoplot_options.html) helper function, it's possible to change the look and feel for a set of nanoplots. The `options=` argument of [`fmt_nanoplot()`](https://posit-dev.github.io/great-tables/reference/GT.fmt_nanoplot.html) is where you'd need to invoke that helper function. Some possibilities for customization include determining which nanoplot elements are present, changing the sizes and colors of different elements, and a whole lot more! Here's an example where both line- and bar-based nanoplots retain their basic compositional elements, but their appearance is quite different.
"""

tabs """
from great_tables import nanoplot_options

(
    GT(random_numbers_df)
    .fmt_nanoplot(
        columns="lines",
        options=nanoplot_options(
            data_point_radius=8,
            data_point_stroke_color="black",
            data_point_stroke_width=3,
            data_point_fill_color="white",
            data_line_type="straight",
            data_line_stroke_color="green",
            data_line_stroke_width=5,
            data_area_fill_color="green",
            show_data_area=False,
        ),
    )
    .fmt_nanoplot(
        columns="bars",
        plot_type="bar",
        options=nanoplot_options(
            data_bar_stroke_color="brown",
            data_bar_fill_color="yellow",
            data_bar_negative_stroke_color="black",
            data_bar_negative_fill_color="blue",
        ),
    )
)
""", """
random_numbers_df |>
  gt() |>
  cols_nanoplot(
    columns = lines,
    new_col_name = "lines_plot",
    new_col_label = "lines",
    options = nanoplot_options(
      data_point_radius = 8,
      data_point_stroke_color = "black",
      data_point_stroke_width = 3,
      data_point_fill_color = "white",
      data_line_type = "straight",
      data_line_stroke_color = "green",
      data_line_stroke_width = 5,
      data_area_fill_color = "green",
      show_data_area = FALSE
    )
  ) |>
  cols_nanoplot(
    columns = bars,
    new_col_name = "bars_plot",
    new_col_label = "bars",
    plot_type = "bar",
    options = nanoplot_options(
      data_bar_stroke_color = "brown",
      data_bar_fill_color = "yellow",
      data_bar_negative_stroke_color = "black",
      data_bar_negative_fill_color = "blue"
    )
  )
""":
  nbCode:
    let customized = tabella(randomNumbersDf):
      fmtNanoplot "lines",
        options = nanoplotOptions(
          dataPointRadius = 8,
          dataPointStrokeColor = "black",
          dataPointStrokeWidth = 3,
          dataPointFillColor = "white",
          dataLineType = "straight",
          dataLineStrokeColor = "green",
          dataLineStrokeWidth = 5,
          dataAreaFillColor = "green",
          showDataArea = false)
      fmtNanoplot "bars",
        plotType = "bar",
        options = nanoplotOptions(
          dataBarStrokeColor = "brown",
          dataBarFillColor = "yellow",
          dataBarNegativeStrokeColor = "black",
          dataBarNegativeFillColor = "blue")
    nbTable customized

nbText: """
We want you to have a lot of creative control for how these tiny plots are displayed. So, when you need it, [`nanoplot_options()`](https://posit-dev.github.io/great-tables/reference/nanoplot_options.html) is there for you!

### Wrapping up

We're always excited to offer new and exciting features that make summary tables fun and useful. The new nanoplots functionality is something we will continue to iterate on since there is definitely room for plotting innovation in tables for display. And there's a lot more to nanoplots than these examples can show. For much more information on this, check out the [*Get Started* guide on nanoplots](../get-started/nanoplots.html). Please let us know through [GitHub Issues](https://github.com/posit-dev/great-tables/issues) whether you ran into problems with this (or any other) feature, or, if you have suggestions for improvement!
"""

bookSave()
