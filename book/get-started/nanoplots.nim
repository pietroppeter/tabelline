import tabbook
bookInit()

nbText: "# Nanoplots"

attribution gtGuide("Nanoplots", "nanoplots",
  "The second way to write the lists of values, with Polars structs, is kept as code that " &
  "does not run, as in the original.")

nbText: """
Nanoplots are tiny plots you can use in your table. They are simple by design, mainly because there isn't a lot of space to work with. With that simplicity, however, you do get a set of very succinct data visualizations that adapt nicely to the amount of data you feed into them. Here's some of the main features:

- interactivity: you can hover over data and other elements to show values
- choice of line and bar charting
- you can annotate plots with a reference line and/or area
- plenty of easy-to-use options for composing your plots

## A simple line-based nanoplot

Let's make some simple plots with a Polars DataFrame. Here we are using lists to define data values for each cell in the `numbers` column. The `GT.fmt_nanoplot()` method understands that these are input values for a line plot (the default type of nanoplot).
"""

tabs """
from great_tables import GT
import polars as pl

random_numbers_df = pl.DataFrame(
    {
        "example": ["Row " + str(x) for x in range(1, 5)],
        "numbers": [
            "20 23 6 7 37 23 21 4 7 16",
            "2.3 6.8 9.2 2.42 3.5 12.1 5.3 3.6 7.2 3.74",
            "-12 -5 6 3.7 0 8 -7.4",
            "2 0 15 7 8 10 1 24 17 13 6",
        ],
    }
)

GT(random_numbers_df).fmt_nanoplot(columns="numbers")
""", """
library(gt)
library(dplyr)

random_numbers_df <- tibble(
  example = paste("Row", 1:4),
  numbers = c(
    "20 23 6 7 37 23 21 4 7 16",
    "2.3 6.8 9.2 2.42 3.5 12.1 5.3 3.6 7.2 3.74",
    "-12 -5 6 3.7 0 8 -7.4",
    "2 0 15 7 8 10 1 24 17 13 6"
  )
)

# gt has no fmt_nanoplot(): cols_nanoplot() draws a new column from the values
gt(random_numbers_df) |> cols_nanoplot(columns = numbers, new_col_name = "plots")
""":
  nbCode:
    import tabelline

    let randomNumbersDf = tableData:
      example: ["Row 1", "Row 2", "Row 3", "Row 4"]
      numbers: ["20 23 6 7 37 23 21 4 7 16",
                "2.3 6.8 9.2 2.42 3.5 12.1 5.3 3.6 7.2 3.74",
                "-12 -5 6 3.7 0 8 -7.4",
                "2 0 15 7 8 10 1 24 17 13 6"]

    let plots = tabella(randomNumbersDf):
      fmtNanoplot "numbers"
    nbTable plots

tabelline """
`fmtNanoplot` is a port of Great Tables' own: the same SVG, with the same options and
defaults, drawn when the table is rendered. `echo plots` prints it as text, where each nanoplot
is a sparkline (▁▃▅█) with its lowest and highest value.
"""

nbText: """
This looks a lot like the familiar sparklines you might see in tables where space for plots is limited. The input values, strings of space-separated values, can be considered here as *y* values and they are evenly spaced along the imaginary *x* axis.

Hovering over (or touching) the values is something of a treat! You might notice that:

- data values are automatically formatted for you in a compact fashion
- the plot elements also display pertinent values

This sort of interactively is baked into the rendered SVG graphics that `GT.fmt_nanoplot()` generates from your data and selection of options.

Polars lets us express 'lists-of-values-per-cell' in different ways and **Great Tables** is pretty good at understanding different column *dtypes*. So, you can alternatively create the same table as above with the following code.

```python
random_numbers_df = pl.DataFrame(
    {
        "example": ["Row " + str(x) for x in range(1, 5)],
        "numbers": [
            { "val": [20, 23, 6, 7, 37, 23, 21, 4, 7, 16] },
            { "val": [2.3, 6.8, 9.2, 2.42, 3.5, 12.1, 5.3, 3.6, 7.2, 3.74] },
            { "val": [-12, -5, 6, 3.7, 0, 8, -7.4] },
            { "val": [2, 0, 15, 7, 8, 10, 1, 24, 17, 13, 6] },
        ],
    }
)

GT(random_numbers_df).fmt_nanoplot(columns="numbers")
```

Both forms of the `numbers` column in the two DataFrames look the same to `GT.fmt_nanoplot()`. The key for the list of values (here, `"val"`) can be anything as long as it's repeated down the column. So the choice is yours on how you want to prepare those column values.
"""

tabelline """
A cell holds a list of values (`@[20.0, 23, 6]`), or a text of numbers separated by spaces,
commas or semicolons, maybe in brackets (`"[1, 2, NA]"`), where `NA` is a missing value. To plot several columns of numbers, one plot per row, `colsNanoplot` joins them
into a new column, as gt's `cols_nanoplot()` does.
"""

nbText: """
## The reference line and the reference area

You can insert two additional things which may be useful: a reference line and a reference area. You can define them either through literal values or via keywords (these are: `"mean"`, `"median"`, `"min"`, `"max"`, `"q1"`, `"q3"`, `"first"`, or `"last"`). Here's a reference line that corresponds to the mean data value of each nanoplot:
"""

tabs """
GT(random_numbers_df).fmt_nanoplot(columns="numbers", reference_line="mean")
""", """
gt(random_numbers_df) |>
  cols_nanoplot(columns = numbers, new_col_name = "plots", reference_line = "mean")
""":
  nbCode:
    let meanLine = tabella(randomNumbersDf):
      fmtNanoplot "numbers", referenceLine = "mean"
    nbTable meanLine

nbText: """
This example uses a reference area that bounds the minimum value to the median value:
"""

tabs """
GT(random_numbers_df).fmt_nanoplot(columns="numbers", reference_area=["min", "median"])
""", """
gt(random_numbers_df) |>
  cols_nanoplot(columns = numbers, new_col_name = "plots", reference_area = c("min", "median"))
""":
  nbCode:
    let minMedian = tabella(randomNumbersDf):
      fmtNanoplot "numbers", referenceArea = ("min", "median")
    nbTable minMedian

nbText: """
As an added touch, you don't need to worry about the order of the keywords provided to `reference_area=` (which could be potentially problematic if providing a literal value and a keyword).
"""

tabelline """
`referenceArea` is a pair, its two ends; a literal value is written as text, `("0", "max")`.
"""

nbText: """
## Using `autoscale=` to have a common *y*-axis scale across plots

There are lots of options. Like, if you want to ensure that the scale is shared across all of the nanoplots (so you can better get a sense of overall magnitude), you can set `autoscale=` to `True`:
"""

tabs """
GT(random_numbers_df).fmt_nanoplot(columns="numbers", autoscale=True)
""", """
gt(random_numbers_df) |>
  cols_nanoplot(columns = numbers, new_col_name = "plots", autoscale = TRUE)
""":
  nbCode:
    let autoscaled = tabella(randomNumbersDf):
      fmtNanoplot "numbers", autoscale = true
    nbTable autoscaled

nbText: """
If you hover along or touch the left side of any of the plots above, you'll see that each *y* scale runs from `-12.0` to `37.0`. Using `autoscale=True` is very useful if you want to compare the magnitudes of values across rows in addition to their trends. It won't, however, make much sense if the overall magnitudes of values vary wildly across rows (e.g., comparing changing currency values or stock prices over time).

## Using the `nanoplot_options()` helper function

There are many options for customization. You can radically change the look of a collection of nanoplots with the `nanoplot_options()` helper function. With that function, you invoke it in the `options=` argument of `GT.fmt_nanoplot()`. You can modify the sizes and colors of different elements, decide which elements are even present, and much more! Here's an example where a line-based nanoplot retains all of its elements, but the overall appearance is greatly altered.
"""

tabs """
from great_tables import nanoplot_options

(
    GT(random_numbers_df)
    .fmt_nanoplot(
        columns="numbers",
        options=nanoplot_options(
            data_point_radius=8,
            data_point_stroke_color="black",
            data_point_stroke_width=2,
            data_point_fill_color="white",
            data_line_type="straight",
            data_line_stroke_color="brown",
            data_line_stroke_width=2,
            data_area_fill_color="orange",
            vertical_guide_stroke_color="green",
        ),
    )
)
""", """
gt(random_numbers_df) |>
  cols_nanoplot(
    columns = numbers,
    new_col_name = "plots",
    options = nanoplot_options(
      data_point_radius = 8,
      data_point_stroke_color = "black",
      data_point_stroke_width = 2,
      data_point_fill_color = "white",
      data_line_type = "straight",
      data_line_stroke_color = "brown",
      data_line_stroke_width = 2,
      data_area_fill_color = "orange",
      vertical_guide_stroke_color = "green"
    )
  )
""":
  nbCode:
    let restyled = tabella(randomNumbersDf):
      fmtNanoplot "numbers",
        options = nanoplotOptions(
          dataPointRadius = 8,
          dataPointStrokeColor = "black",
          dataPointStrokeWidth = 2,
          dataPointFillColor = "white",
          dataLineType = "straight",
          dataLineStrokeColor = "brown",
          dataLineStrokeWidth = 2,
          dataAreaFillColor = "orange",
          verticalGuideStrokeColor = "green")
    nbTable restyled

nbText: """
As can be seen, you have a lot of fine-grained control over the look of a nanoplot.

## Making nanoplots with bars using `plot_type="bar"`

We don't just support line plots in `GT.fmt_nanoplot()`, we also have the option to show bar plots. The only thing you need to change is the value of `plot_type=` argument to `"bar"`:
"""

tabs """
GT(random_numbers_df).fmt_nanoplot(columns="numbers", plot_type="bar")
""", """
gt(random_numbers_df) |>
  cols_nanoplot(columns = numbers, new_col_name = "plots", plot_type = "bar")
""":
  nbCode:
    let bars = tabella(randomNumbersDf):
      fmtNanoplot "numbers", plotType = "bar"
    nbTable bars

nbText: """
An important difference between line plots and bar plots is that the bars project from a zero line. Notice that some negative values in the bar-based nanoplot appear red and radiate downward from the gray zero line.

Using `plot_type="bar"` still allows us to supply a reference line and a reference area with `reference_line=` and `reference_area=`. The `autoscale=` option works here as well. We also have a set of options just for bar plots available inside `nanoplot_options()`. Here's an example where we use all of the aforementioned customization possibilities:
"""

tabs """
(
    GT(random_numbers_df)
    .fmt_nanoplot(
        columns="numbers",
        plot_type="bar",
        autoscale=True,
        reference_line="min",
        reference_area=[0, "max"],
        options=nanoplot_options(
            data_bar_stroke_color="gray",
            data_bar_stroke_width=2,
            data_bar_fill_color="orange",
            data_bar_negative_stroke_color="blue",
            data_bar_negative_stroke_width=1,
            data_bar_negative_fill_color="lightblue",
            reference_line_color="pink",
            reference_area_fill_color="bisque",
            vertical_guide_stroke_color="blue",
        ),
    )
)
""", """
gt(random_numbers_df) |>
  cols_nanoplot(
    columns = numbers,
    new_col_name = "plots",
    plot_type = "bar",
    autoscale = TRUE,
    reference_line = "min",
    reference_area = list(0, "max"),
    options = nanoplot_options(
      data_bar_stroke_color = "gray",
      data_bar_stroke_width = 2,
      data_bar_fill_color = "orange",
      data_bar_negative_stroke_color = "blue",
      data_bar_negative_stroke_width = 1,
      data_bar_negative_fill_color = "lightblue",
      reference_line_color = "pink",
      reference_area_fill_color = "bisque",
      vertical_guide_stroke_color = "blue"
    )
  )
""":
  nbCode:
    let allOptions = tabella(randomNumbersDf):
      fmtNanoplot "numbers",
        plotType = "bar",
        autoscale = true,
        referenceLine = "min",
        referenceArea = ("0", "max"),
        options = nanoplotOptions(
          dataBarStrokeColor = "gray",
          dataBarStrokeWidth = 2,
          dataBarFillColor = "orange",
          dataBarNegativeStrokeColor = "blue",
          dataBarNegativeStrokeWidth = 1,
          dataBarNegativeFillColor = "lightblue",
          referenceLineColor = "pink",
          referenceAreaFillColor = "bisque",
          verticalGuideStrokeColor = "blue")
    nbTable allOptions

tabelline """
The colours of a nanoplot go into its SVG as they are, so any CSS colour works here, `bisque`
too, as it does in `dataColor` (see [Colorizing with Data](colorizing_with_data.html)).
"""

nbText: """
## Horizontal bar and line plots

Single-value bar plots, running in the horizontal direction, can be made by simply invoking `GT.fmt_nanoplot()` on a column of numeric values. These plots are meant for comparison across rows so the method automatically scales the horizontal bars to facilitate this type of display. Here's a simple example that uses `plot_type="bar"` on the `numbers` column that contains a single numeric value in every cell.
"""

tabs """
single_vals_df = pl.DataFrame(
    {
        "example": ["Row " + str(x) for x in range(1, 5)],
        "numbers": [2.75, 0, -3.2, 8]
    }
)

GT(single_vals_df).fmt_nanoplot(columns="numbers", plot_type="bar")
""", """
single_vals_df <- tibble(
  example = paste("Row", 1:4),
  numbers = c(2.75, 0, -3.2, 8)
)

gt(single_vals_df) |>
  cols_nanoplot(columns = numbers, new_col_name = "plots", plot_type = "bar")
""":
  nbCode:
    let singleValsDf = tableData:
      example: ["Row 1", "Row 2", "Row 3", "Row 4"]
      numbers: [2.75, 0, -3.2, 8]

    let horizontal = tabella(singleValsDf):
      fmtNanoplot "numbers", plotType = "bar"
    nbTable horizontal

nbText: """
This, interestingly enough, works with the `"line"` type of nanoplot. The result is akin to a lollipop plot:
"""

tabs """
GT(single_vals_df).fmt_nanoplot(columns="numbers")
""", """
gt(single_vals_df) |> cols_nanoplot(columns = numbers, new_col_name = "plots")
""":
  nbCode:
    let lollipops = tabella(singleValsDf):
      fmtNanoplot "numbers"
    nbTable lollipops

nbText: """
You get to customize the line and the data point marker with the latter display of single values, and that's a plus. Nonetheless, it is more common to see horizontal bar plots in tables and the extra customization of negative values makes that form of presentation more advantageous.

## Line plots with paired *x* and *y* values

Aside from a single stream of *y* values, we can plot pairs of *x* and *y* values. This works only for the `"line"` type of plot. We can set up a column of Polars `struct` values in a DataFrame to have this input data prepared for `GT.fmt_nanoplot()`. Notice that the dictionary values in the enclosed list must have the `"x"` and `"y"` keys. Further to this, the list lengths for each of `"x"` and `"y"` must match (i.e., to make valid pairs of *x* and *y*).
"""

tabs """
weather_2 = pl.DataFrame(
    {
        "station": ["Station " + str(x) for x in range(1, 4)],
        "temperatures": [
            {
                "x": [6.1, 8.0, 10.1, 10.5, 11.2, 12.4, 13.1, 15.3],
                "y": [24.2, 28.2, 30.2, 30.5, 30.5, 33.1, 33.5, 32.7],
            },
            {
                "x": [7.1, 8.2, 10.3, 10.75, 11.25, 12.5, 13.5, 14.2],
                "y": [18.2, 18.1, 20.3, 20.5, 21.4, 21.9, 23.1, 23.3],
            },
            {
                "x": [6.3, 7.1, 10.3, 11.0, 12.07, 13.1, 15.12, 16.42],
                "y": [15.2, 17.77, 21.42, 21.63, 25.23, 26.84, 27.2, 27.44],
            },
        ]
    }
)

(
    GT(weather_2)
    .fmt_nanoplot(
        columns="temperatures",
        plot_type="line",
        expand_x=[5, 16],
        expand_y=[10, 40],
        options=nanoplot_options(
            show_data_area=False,
            show_data_line=False
        )
    )
)
""", """
# gt reads the x values from columns of their own
weather_2 <- tibble(
  station = paste("Station", 1:3),
  x = c(
    "6.1 8.0 10.1 10.5 11.2 12.4 13.1 15.3",
    "7.1 8.2 10.3 10.75 11.25 12.5 13.5 14.2",
    "6.3 7.1 10.3 11.0 12.07 13.1 15.12 16.42"
  ),
  y = c(
    "24.2 28.2 30.2 30.5 30.5 33.1 33.5 32.7",
    "18.2 18.1 20.3 20.5 21.4 21.9 23.1 23.3",
    "15.2 17.77 21.42 21.63 25.23 26.84 27.2 27.44"
  )
)

gt(weather_2) |>
  cols_nanoplot(
    columns = y,
    columns_x_vals = x,
    new_col_name = "temperatures",
    plot_type = "line",
    expand_x = c(5, 16),
    expand_y = c(10, 40),
    options = nanoplot_options(
      show_data_area = FALSE,
      show_data_line = FALSE
    )
  )
""":
  nbCode:
    let weather2 = tableData:
      station: ["Station 1", "Station 2", "Station 3"]
      temperatures: [
        (x: @[6.1, 8.0, 10.1, 10.5, 11.2, 12.4, 13.1, 15.3],
         y: @[24.2, 28.2, 30.2, 30.5, 30.5, 33.1, 33.5, 32.7]),
        (x: @[7.1, 8.2, 10.3, 10.75, 11.25, 12.5, 13.5, 14.2],
         y: @[18.2, 18.1, 20.3, 20.5, 21.4, 21.9, 23.1, 23.3]),
        (x: @[6.3, 7.1, 10.3, 11.0, 12.07, 13.1, 15.12, 16.42],
         y: @[15.2, 17.77, 21.42, 21.63, 25.23, 26.84, 27.2, 27.44])]

    let scatter = tabella(weather2):
      fmtNanoplot "temperatures",
        plotType = "line",
        expandX = @[5.0, 16.0],
        expandY = @[10.0, 40.0],
        options = nanoplotOptions(
          showDataArea = false,
          showDataLine = false)
    nbTable scatter

tabelline """
A cell can hold a record: a Nim tuple with the fields `x` and `y` is the dictionary of
Polars' `struct`, and `fmtNanoplot` places each *y* at its *x*. A list (`@[1.0, 4, 2]`) is a
cell of *y* values too, as Polars' list columns are.
"""

nbText: """
The options for removing the *data area* and the *data line* (though the corresponding `show_*` arguments of `nanoplot_options()`) make the finalized nanoplots look somewhat like scatter plots.
"""

bookSave()
