import tabbook
bookInit()

nbText: "# Great Tables `v0.18.0`: Easy Column Spanners and More!"

attribution gtBlog("Great Tables v0.18.0: Easy Column Spanners and More!", "introduction-0.18.0/",
  "Rich Iannone", "18 Jul 2025",
  "The links to Great Tables' reference pages are written as plain names, as the post's " &
  "own cross-references (`~~.GT.tab_spanner_delim()`) show in the book.")

nbText: """
The development of Great Tables continues! We're excited to announce the release of `v0.18.0`, which brings several powerful new features. These features make it even easier to create beautiful, informative tables. The key additions in this release include new methods (and a tweak to an existing one):

- `GT.tab_spanner_delim()`: quick spanner creation
- `GT.fmt_tf()`: easy boolean value formatting
- `GT.cols_label_rotate()`: enables column label rotation
- `GT.fmt_datetime()`: added `format_str=` parameter for extra customization

Let's explore each of these interesting new features!

### Quick spanner creation with `tab_spanner_delim()`

Working with data that has hierarchical column names can be tedious when manually creating spanners. The new `GT.tab_spanner_delim()` method automates this process by intelligently splitting column names based on a delimiter and creating the appropriate spanner structure.

Here's a practical example using the `towny` dataset, which contains population data for a collection of municipalities across multiple census years. Let's start by looking at the most populated cities and examining their column structure:
"""

tabs """
from great_tables import GT
from great_tables.data import towny
import polars as pl
import polars.selectors as cs

# Create a smaller version of the `towny` dataset
towny_mini = (
    pl.from_pandas(towny)
    .filter(pl.col("csd_type") == "city")
    .sort("population_2021", descending=True)
    .select(
        "name",
        cs.starts_with("population_"),
        cs.starts_with("density_")
    )
    .head(5)
)

# Let's look at the column names
print(towny_mini.columns)
""", """
library(gt)
library(dplyr)

# Create a smaller version of the `towny` dataset
towny_mini <-
  towny |>
  filter(csd_type == "city") |>
  arrange(desc(population_2021)) |>
  select(name, starts_with("population_"), starts_with("density_")) |>
  head(5)

# Let's look at the column names
print(colnames(towny_mini))
""":
  nbCode:
    import std/[streams, times]
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    # Create a smaller version of the `towny` dataset
    let towny = readCsv(newStringStream(townyCsv), inferSchemaLength = 10_000)
    let townyMini = towny
      .filter(col("csd_type") == "city")
      .sort("population_2021", descending = true)
      .select(col("name"), col("^population_.*$"), col("^density_.*$"))
      .head(5)

    # Let's look at the column names
    echo townyMini.columns

nbText: """
Notice how the column names have a clear hierarchical structure with underscores as delimiters. Let's now create a table that takes advantage of this structure:
"""

tabs """
(
    GT(towny_mini, rowname_col="name")
    .tab_spanner_delim(delim="_")
    .fmt_integer(columns=cs.contains("population"))
    .fmt_number(columns=cs.contains("density"), decimals=1)
    .tab_header(title="Population and Density Trends from Census Data")
    .opt_align_table_header(align="left")
)
""", """
towny_mini |>
  gt(rowname_col = "name") |>
  tab_spanner_delim(delim = "_") |>
  fmt_integer(columns = contains("population")) |>
  fmt_number(columns = contains("density"), decimals = 1) |>
  tab_header(title = "Population and Density Trends from Census Data") |>
  opt_align_table_header(align = "left")
""":
  nbCode:
    let census = tabella(townyMini, rownameCol = "name"):
      tabSpannerDelim delim = "_"
      fmtInteger containing("population")
      fmtNumber containing("density"), decimals = 1
      tabHeader "Population and Density Trends from Census Data"
      optAlignTableHeader "left"
    nbTable census

tabelline """
The data steps are written with [nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim
(a name between `^` and `$` is a regular expression, as in Polars, for `cs.starts_with`); `import tabelline/nanuq` makes `tabella(df)` take its
data frames. tabelline's own selector for `cs.contains` is `containing`: `contains` is already
taken in Nim, by the `in` operator.
"""

nbText: """
The `GT.tab_spanner_delim()` method recognizes the underscore delimiter and creates a hierarchical structure: `"population"` and `"density"` become top-level spanners, with the years (`1996`, `2001`, `2021`) as the final column labels. This creates a clean, organized appearance that clearly groups related metrics together. And, this one method can be used instead of a combination of `GT.cols_label()` and `GT.tab_spanner()` (which requires a separate invocation per spanner added).

### Beautiful boolean formatting with `fmt_tf()`

Boolean data is common in analytical tables, but raw `True`/`False` values can look unprofessional. The new `GT.fmt_tf()` method provides elegant ways to display boolean data using symbols, words, or custom formatting.

Here's a simple example showing different `tf_style=` options:
"""

tabs """
from great_tables import GT
import polars as pl

# Create a simple DF with boolean data
bool_df = pl.DataFrame({
    "feature": ["Premium Sound", "Leather Seats", "Sunroof", "Navigation"],
    "model_a": [True, False, True, True],
    "model_b": [True, True, False, True],
    "model_c": [False, True, True, False]
})

(
    GT(bool_df, rowname_col="feature")
    .fmt_tf(tf_style="check-mark", colors=["green", "red"])
    .tab_header(title="Car Features Comparison", subtitle="Using check-mark style")
)
""", """
# Create a simple tibble with boolean data
bool_df <-
  dplyr::tibble(
    feature = c("Premium Sound", "Leather Seats", "Sunroof", "Navigation"),
    model_a = c(TRUE, FALSE, TRUE, TRUE),
    model_b = c(TRUE, TRUE, FALSE, TRUE),
    model_c = c(FALSE, TRUE, TRUE, FALSE)
  )

bool_df |>
  gt(rowname_col = "feature") |>
  fmt_tf(tf_style = "check-mark", colors = c("green", "red")) |>
  tab_header(title = "Car Features Comparison", subtitle = "Using check-mark style")
""":
  nbCode:
    # Create a simple data frame with boolean data
    let boolDf = newDataFrame:
      feature: ["Premium Sound", "Leather Seats", "Sunroof", "Navigation"]
      model_a: [true, false, true, true]
      model_b: [true, true, false, true]
      model_c: [false, true, true, false]

    let checks = tabella(boolDf, rownameCol = "feature"):
      fmtTf everything(), tfStyle = "check-mark", colors = ["green", "red"]
      tabHeader title = "Car Features Comparison", subtitle = "Using check-mark style"
    nbTable checks

tabelline """
`fmtTf` takes its columns first, as every format of tabelline does: `everything()` is all of
them, where Great Tables' `columns=` defaults to every column.
"""

nbText: """
You can also use different symbols and colors for a more distinctive look:
"""

tabs """
(
    GT(bool_df, rowname_col="feature")
    .fmt_tf(tf_style="circles", colors=["#4CAF50", "#F44336"])
    .tab_header(title="Car Features Comparison", subtitle="Using circles style")
)
""", """
bool_df |>
  gt(rowname_col = "feature") |>
  fmt_tf(tf_style = "circles", colors = c("#4CAF50", "#F44336")) |>
  tab_header(title = "Car Features Comparison", subtitle = "Using circles style")
""":
  nbCode:
    let circles = tabella(boolDf, rownameCol = "feature"):
      fmtTf everything(), tfStyle = "circles", colors = ["#4CAF50", "#F44336"]
      tabHeader title = "Car Features Comparison", subtitle = "Using circles style"
    nbTable circles

nbText: """
The `GT.fmt_tf()` method transforms boolean values into visually appealing symbols that make it easy to quickly scan and compare data across rows and columns.

### Rotating column labels with `cols_label_rotate()`

When dealing with many columns or long column names, horizontal space becomes precious. The `GT.cols_label_rotate()` method solves this by rotating column labels vertically, allowing for more compact table layouts.

Here's an example where we use the `gtcars` dataset to create a table which communicates a feature matrix:
"""

tabs """
from great_tables import GT, style, loc
from great_tables.data import gtcars
import polars as pl
import polars.selectors as cs

# Manipulate dataset to create a feature comparison table
gtcars_mini = (
    pl.from_pandas(gtcars)
    .filter(pl.col("year") == 2017)
    .filter(pl.col("ctry_origin").is_in(["Germany", "Italy", "United Kingdom"]))
    .with_columns([
        (pl.col("hp") > 500).alias("High Power"),
        (pl.col("mpg_h") > 25).alias("Fuel Efficient"),
        (pl.col("drivetrain") == "awd").alias("All Wheel Drive"),
        (pl.col("msrp") > 100000).alias("Premium Price"),
        (pl.col("trsmn").str.contains("manual")).alias("Manual Transmission")
    ])
    .select([
        "mfr", "model", "trim",
        "High Power",
        "Fuel Efficient",
        "All Wheel Drive",
        "Premium Price",
        "Manual Transmission"
    ])
    .head(10)
)

(
    GT(gtcars_mini)
    .fmt_tf(
        columns=cs.by_dtype(pl.Boolean),
        tf_style="check-mark",
        colors=["#2E8B57", "#DC143C"]
    )
    .cols_label_rotate(
        columns=cs.by_dtype(pl.Boolean),
        dir="sideways-lr"
    )
    .tab_header(
        title="European Luxury Cars Feature Matrix",
        subtitle="2017 Models with Performance & Luxury Features"
    )
    .opt_stylize(style=1)
    .tab_style(
        style=style.text(size="11px"),
        locations=loc.body()
    )
)
""", """
# Manipulate dataset to create a feature comparison table
gtcars_mini <-
  gtcars |>
  filter(year == 2017) |>
  filter(ctry_origin %in% c("Germany", "Italy", "United Kingdom")) |>
  mutate(
    `High Power` = hp > 500,
    `Fuel Efficient` = mpg_h > 25,
    `All Wheel Drive` = drivetrain == "awd",
    `Premium Price` = msrp > 100000,
    `Manual Transmission` = grepl("manual", trsmn)
  ) |>
  select(
    mfr, model, trim,
    `High Power`, `Fuel Efficient`, `All Wheel Drive`, `Premium Price`, `Manual Transmission`
  ) |>
  head(10)

gtcars_mini |>
  gt() |>
  fmt_tf(
    columns = where(is.logical),
    tf_style = "check-mark",
    colors = c("#2E8B57", "#DC143C")
  ) |>
  # gt has no cols_label_rotate(), which is Great Tables' own: a CSS style turns the labels
  tab_style(
    style = "writing-mode: sideways-lr; vertical-align: bottom;",
    locations = cells_column_labels(columns = where(is.logical))
  ) |>
  tab_header(
    title = "European Luxury Cars Feature Matrix",
    subtitle = "2017 Models with Performance & Luxury Features"
  ) |>
  opt_stylize(style = 1) |>
  tab_style(style = cell_text(size = px(11)), locations = cells_body())
""":
  nbCode:
    # Manipulate dataset to create a feature comparison table
    let gtcarsDf = readCsv(newStringStream(gtcarsCsv), inferSchemaLength = 10_000)
    let gtcarsMini = gtcarsDf
      .filter(col("year") == 2017)
      .filter(col("ctry_origin").isIn(["Germany", "Italy", "United Kingdom"]))
      .withColumns(
        (col("hp") > 500).alias("High Power"),
        (col("mpg_h") > 25).alias("Fuel Efficient"),
        (col("drivetrain") == "awd").alias("All Wheel Drive"),
        (col("msrp") > 100000).alias("Premium Price"),
        col("trsmn").str.contains("manual").alias("Manual Transmission"))
      .select("mfr", "model", "trim",
              "High Power",
              "Fuel Efficient",
              "All Wheel Drive",
              "Premium Price",
              "Manual Transmission")
      .head(10)

    let features = ["High Power", "Fuel Efficient", "All Wheel Drive", "Premium Price",
                    "Manual Transmission"]
    let matrix = tabella(gtcarsMini):
      fmtTf features, tfStyle = "check-mark", colors = ["#2E8B57", "#DC143C"]
      colsLabelRotate features, dir = "sideways-lr"
      tabHeader title = "European Luxury Cars Feature Matrix",
        subtitle = "2017 Models with Performance & Luxury Features"
      optStylize style = 1
      tabStyle style.text(size = "11px"), loc.body()
    nbTable matrix

tabelline """
tabelline has no selector by the type of a column, as `cs.by_dtype(pl.Boolean)`: the table names
the five columns. `gtcarsCsv` is the CSV of `gtcars` in `tabelline/datasets`, for nanuq's
`readCsv`.
"""

nbText: """
This example demonstrates how both the `GT.fmt_tf()` and `GT.cols_label_rotate()` methods can work well together. The boolean columns use checkmarks (✓/✗) with custom `colors=`, while the rotated labels save horizontal space in this dense feature matrix. The combination allows you to put more information into a compact and still readable format.

### Enhanced datetime formatting with `fmt_datetime()`

The `GT.fmt_datetime()` method now supports custom format strings through the new `format_str=` parameter, giving you complete control over how datetime values appear in your tables.

Here's an example using the included `gibraltar` weather dataset:
"""

tabs """
from great_tables import GT
from great_tables.data import gibraltar
import polars as pl

# Prepare the meteorological data
gibraltar_mini = (
    pl.from_pandas(gibraltar)
    .with_columns(
        [
            pl.concat_str([pl.col("date"), pl.lit(" "), pl.col("time")])
            .str.strptime(pl.Datetime, format="%Y-%m-%d %H:%M")
            .alias("datetime")
        ]
    )
    .filter(pl.col("datetime").dt.hour().is_in([6, 12, 18]))
    .select(["datetime", "temp", "humidity", "condition"])
    .sort("datetime")
    .head(10)
)

(
    GT(gibraltar_mini)
    .fmt_datetime(
        columns="datetime",
        format_str="%b %d %Y (%a) - %I:%M %p",
    )
    .fmt_number(columns="temp", decimals=1, pattern="{x}°C")
    .fmt_percent(columns="humidity", scale_values=False, decimals=0)
    .cols_label(
        datetime="Time",
        temp="Temperature",
        humidity="Humidity",
        condition="Conditions",
    )
    .tab_header(
        title="Gibraltar Temperature and Humidity Conditions",
        subtitle="Morning, Noon, and Evening Readings"
    )
    .opt_stylize(style=1, color="cyan")
)
""", """
# Prepare the meteorological data
gibraltar_mini <-
  gibraltar |>
  mutate(datetime = as.POSIXct(paste(date, time), format = "%Y-%m-%d %H:%M", tz = "UTC")) |>
  filter(as.integer(format(datetime, "%H")) %in% c(6, 12, 18)) |>
  select(datetime, temp, humidity, condition) |>
  arrange(datetime) |>
  head(10)

gibraltar_mini |>
  gt() |>
  fmt_datetime(columns = datetime, format = "%b %d %Y (%a) - %I:%M %p") |>
  fmt_number(columns = temp, decimals = 1, pattern = "{x}°C") |>
  fmt_percent(columns = humidity, scale_values = FALSE, decimals = 0) |>
  cols_label(
    datetime = "Time",
    temp = "Temperature",
    humidity = "Humidity",
    condition = "Conditions"
  ) |>
  tab_header(
    title = "Gibraltar Temperature and Humidity Conditions",
    subtitle = "Morning, Noon, and Evening Readings"
  ) |>
  opt_stylize(style = 1, color = "cyan")
""":
  nbCode:
    # Prepare the meteorological data
    let gibraltar = readCsv(newStringStream(gibraltarCsv), inferSchemaLength = 10_000)
    let gibraltarMini = gibraltar
      .withColumns(concatStr([col("date"), lit(" "), col("time")])
                     .str.strptime(Datetime, format = "%Y-%m-%d %H:%M")
                     .alias("datetime"))
      .filter(col("datetime").dt.hour.isIn([6, 12, 18]))
      .select("datetime", "temp", "humidity", "condition")
      .sort("datetime")
      .head(10)

    let weather = tabella(gibraltarMini):
      fmt "datetime", proc (v: Value): string =
        parse($v, "yyyy-MM-dd HH:mm:ss'.'ffffff").format("MMM dd yyyy (ddd) - hh:mm tt")
      fmtNumber "temp", decimals = 1, pattern = "{x}°C"
      fmtPercent "humidity", scaleValues = false, decimals = 0
      colsLabel:
        datetime: "Time"
        temp: "Temperature"
        humidity: "Humidity"
        condition: "Conditions"
      tabHeader title = "Gibraltar Temperature and Humidity Conditions",
        subtitle = "Morning, Noon, and Evening Readings"
      optStylize style = 1, color = "cyan"
    nbTable weather

tabelline """
`fmtDatetime` takes gt's named date and time styles but no format string, as `format_str=`
(strftime's `%b %d %Y`): the table gives `fmt` a small format with Nim's own `std/times`, whose
patterns are written `MMM dd yyyy (ddd) - hh:mm tt`. Polars gives a datetime to tabelline as its
text, `2023-05-01 06:20:00.000000`, which `parse` reads back.
"""

nbText: """
The custom datetime formatting string in `format_str="%b %d %Y (%a) - %I:%M %p"` creates a readable datetime format that's perfect for weather reporting, showing the day of week, month, day, year, and the time in 12-hour format.

### Acknowledgements and what's next

We're grateful to all the contributors who made this release possible. These new features represent significant improvements for creating space-efficient tables while also maximizing visual appeal.

The combination of these features lets you now create complex, professional tables with hierarchical column structures, boolean indicators, space-saving labels, and nicely formatted datetime displays.

We're always happy to get feedback and hear about how you're using Great Tables:

1. [GitHub Issues](https://github.com/posit-dev/great-tables/issues)
2. [GitHub Discussions](https://github.com/posit-dev/great-tables/discussions)
3. [Discord](https://discord.com/invite/Ux7nrcXHVV)

Keep building those beautiful tables!
"""

bookSave()
