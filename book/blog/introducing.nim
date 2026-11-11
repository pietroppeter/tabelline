import tabbook
bookInit()

nbText: "# Introducing Great Tables"

attribution gtBlog("Introducing Great Tables", "introduction_great_tables.html", "Rich Iannone",
  "4 Jan 2024", "Left out: installing with pip (see the book's [Intro](../get-started/intro.html)).")

nbText: """
We are really excited about developing the **Great Tables** package because we believe it'll make great-looking display tables possible in Python. Though it's still early days for the project/package, you can do good things with it today!

In this short post, we'll take a look at a few examples that focus on the more common table-making use cases. We'll show you how to:

- configure the structure of the table
- format table-cell values
- integrate source notes
- add styling to targeted table cells
- use features from **Polars** to make it all better/nicer

Alright! Let's get right into it.

## A Basic Table

Let's get right to making a display table with **Great Tables**. The package has quite a few datasets and so we'll start by making use of the very small, but useful, `exibble` dataset. After importing the `GT` class and that dataset, we'll introduce that Pandas table to `GT()`.
"""

tabs """
from great_tables import GT, exibble

# Create a display table with the `exibble` dataset
gt_tbl = GT(exibble)

# Now, show the gt table
gt_tbl
""", """
library(gt)
library(dplyr)

# Create a display table with the `exibble` dataset
gt_tbl <- gt(exibble)

# Now, show the gt table
gt_tbl
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    # Create a display table with the `exibble` dataset
    let gtTbl = tabella(exibble())

    # Now, show the gt table
    nbTable gtTbl

nbText: """
That looks pretty good! Indeed, it is a basic table but we really didn't really ask for much either. What we did get was an HTML table containing column labels and all of the body cells. You'll probably be wanting a bit more, so, let's look at how we can incorporate more table components and perform cell data formatting in the upcoming examples.

## More Complex Tables

Let's take things a bit further and create a table with the included `gtcars` dataset. **Great Tables** provides a large selection of methods and they let you refine the table display. They were designed so that you can easily create a really presentable and *beautiful* table visualization.

For this next table, we'll incorporate a *Stub* component and this provides a place for the row labels. Groupings of rows will be generated through categorical values in a particular column (we just have to cite the column name for that to work). We'll add a table title and subtitle with `tab_header()`. The numerical values will be formatted with the `fmt_integer()` and `fmt_currency()` methods. Column labels will be enhanced via `cols_label()` and a source note will be included through use of the `tab_source_note()` method. Here is the table code, followed by the table itself.
"""

tabs """
from great_tables import GT, md, html
from great_tables.data import gtcars

gtcars_mini = gtcars[["mfr", "model", "year", "hp", "trq", "msrp"]].tail(10)

(
    GT(gtcars_mini, rowname_col="model", groupname_col="mfr")
    .tab_spanner(label=md("*Performance*"), columns=["hp", "trq"])
    .tab_header(
        title=html("Data listing from <strong>gtcars</strong>"),
        subtitle=html("A <span style='font-size:12px;'>small selection</span> of great cars."),
    )
    .cols_label(year="Year Produced", hp="HP", trq="Torque", msrp="Price (USD)")
    .fmt_integer(columns=["year", "hp", "trq"], use_seps=False)
    .fmt_currency(columns="msrp")
    .tab_source_note(source_note="Source: the gtcars dataset within the Great Tables package.")
)
""", """
gtcars_mini <- gtcars |> select(mfr, model, year, hp, trq, msrp) |> slice_tail(n = 10)

gt(gtcars_mini, rowname_col = "model", groupname_col = "mfr") |>
  tab_spanner(label = md("*Performance*"), columns = c(hp, trq)) |>
  tab_header(
    title = html("Data listing from <strong>gtcars</strong>"),
    subtitle = html("A <span style='font-size:12px;'>small selection</span> of great cars.")
  ) |>
  cols_label(year = "Year Produced", hp = "HP", trq = "Torque", msrp = "Price (USD)") |>
  fmt_integer(columns = c(year, hp, trq), use_seps = FALSE) |>
  fmt_currency(columns = msrp) |>
  tab_source_note(source_note = "Source: the gtcars dataset within the Great Tables package.")
""":
  nbCode:
    let gtcarsMini = gtcars().select(["mfr", "model", "year", "hp", "trq", "msrp"]).tail(10)

    let cars = tabella(gtcarsMini, rownameCol = "model", groupnameCol = "mfr"):
      tabSpanner md"*Performance*", ["hp", "trq"]
      tabHeader title = html"Data listing from <strong>gtcars</strong>",
                subtitle = html"A <span style='font-size:12px;'>small selection</span> of great cars."
      colsLabel:
        year: "Year Produced"
        hp: "HP"
        trq: "Torque"
        msrp: "Price (USD)"
      fmtInteger ["year", "hp", "trq"], useSeps = false
      fmtCurrency "msrp"
      tabSourceNote "Source: the gtcars dataset within the Great Tables package."
    nbTable cars

tabelline """
`gtcars` is read from a copy of Great Tables' CSV file (`gtdata`, with `tail`, the last rows).
The title and subtitle are the original's HTML, kept as it is.
"""

nbText: """
With the six different methods applied, the table looks highly presentable! The rendering you're seeing here has been done through [**Quarto**](https://quarto.org) (this entire site has been generated with [**quartodoc**](https://machow.github.io/quartodoc/get-started/overview.html)). If you haven't yet tried out **Quarto**, we highly recommend it!

For this next example we'll use the `airquality` dataset (also included in the package; it's inside the `data` submodule). With this table, two spanners will be added with the `tab_spanner()` method. This method is meant to be easy to use, you only need to provide the text for the spanner label and the columns associated with the spanner. We also make it easy to move columns around. You can use `cols_move_to_start()` (example of that below) and there are also the `cols_move_to_end()` and `cols_move()` methods.
"""

tabs """
from great_tables.data import airquality

airquality_mini = airquality.head(10).assign(Year=1973)

(
    GT(airquality_mini)
    .tab_header(
        title="New York Air Quality Measurements",
        subtitle="Daily measurements in New York City (May 1-10, 1973)",
    )
    .cols_label(
        Ozone=html("Ozone,<br>ppbV"),
        Solar_R=html("Solar R.,<br>cal/m<sup>2</sup>"),
        Wind=html("Wind,<br>mph"),
        Temp=html("Temp,<br>&deg;F"),
    )
    .tab_spanner(label="Date", columns=["Year", "Month", "Day"])
    .tab_spanner(label="Measurement", columns=["Ozone", "Solar.R", "Wind", "Temp"])
    .cols_move_to_start(columns=["Year", "Month", "Day"])
)
""", """
airquality_mini <- airquality |> slice_head(n = 10) |> mutate(Year = 1973L)

gt(airquality_mini) |>
  tab_header(
    title = "New York Air Quality Measurements",
    subtitle = "Daily measurements in New York City (May 1-10, 1973)"
  ) |>
  cols_label(
    Ozone = html("Ozone,<br>ppbV"),
    Solar.R = html("Solar R.,<br>cal/m<sup>2</sup>"),
    Wind = html("Wind,<br>mph"),
    Temp = html("Temp,<br>&deg;F")
  ) |>
  tab_spanner(label = "Date", columns = c(Year, Month, Day)) |>
  tab_spanner(label = "Measurement", columns = c(Ozone, Solar.R, Wind, Temp)) |>
  cols_move_to_start(columns = c(Year, Month, Day))
""":
  nbCode:
    import std/sequtils

    let airqualityMini = airquality().head(10)

    let air = tabella(airqualityMini):
      colsAdd "Year", newSeqWith(10, 1973)
      tabHeader title = "New York Air Quality Measurements",
                subtitle = "Daily measurements in New York City (May 1-10, 1973)"
      colsLabel:
        Ozone: html"Ozone,<br>ppbV"
        Solar_R: html"Solar R.,<br>cal/m<sup>2</sup>"
        Wind: html"Wind,<br>mph"
        Temp: html"Temp,<br>&deg;F"
      tabSpanner "Date", ["Year", "Month", "Day"]
      tabSpanner "Measurement", ["Ozone", "Solar_R", "Wind", "Temp"]
      colsMoveToStart ["Year", "Month", "Day"]
    nbTable air

tabelline """
The original names the column `Solar.R`, its name in R, in the second spanner; in Great Tables'
`airquality` it is `Solar_R`, so the spanner leaves it out. tabelline stops on a column that
does not exist, so the Nim tab names `Solar_R`, and its spanner covers all four measurements.
"""

nbText: """
That table looks really good, and the nice thing about all these methods is that they can be used in virtually any order.

## Formatting Table Cells

We didn't want to skimp on formatting methods for table cells with this early release. There are 12 `fmt_*()` methods available right now:

- `fmt_number()`: format numeric values
- `fmt_integer()`: format values as integers
- `fmt_percent()`: format values as percentages
- `fmt_scientific()`: format values to scientific notation
- `fmt_currency()`: format values as currencies
- `fmt_bytes()`: format values as bytes
- `fmt_roman()`: format values as Roman numerals
- `fmt_date()`: format values as dates
- `fmt_time()`: format values as times
- `fmt_datetime()`: format values as datetimes
- `fmt_markdown()`: format Markdown text
- `fmt()`: set a column format with a formatting function

We strive to make formatting a simple task but we also want to provide the user a lot of power through advanced options and we ensure that varied combinations of options works well. For example, most of the formatting methods have a `locale=` argument. We want as many users as possible to be able to format numbers, dates, and times in ways that are familiar to them and are adapted to their own regional specifications. Now let's take a look at an example of this with a smaller version of the `exibble` dataset:
"""

tabelline """
tabelline has all twelve, with the same names in camelCase (`fmtNumber`, ..., `fmtMarkdown`,
`fmt`), and the formats Great Tables added later.
"""

tabs """
exibble_smaller = exibble[["date", "time"]].head(4)

(
    GT(exibble_smaller)
    .fmt_date(columns="date", date_style="wday_month_day_year")
    .fmt_date(columns="date", rows=[2, 3], date_style="day_month_year", locale="de-CH")
    .fmt_time(columns="time", time_style="h_m_s_p")
)
""", """
exibble_smaller <- exibble |> select(date, time) |> slice_head(n = 4)

gt(exibble_smaller) |>
  fmt_date(columns = date, date_style = "wday_month_day_year") |>
  fmt_date(columns = date, rows = 3:4, date_style = "day_month_year", locale = "de-CH") |>
  fmt_time(columns = time, time_style = "h_m_s_p")
""":
  nbCode:
    let exibbleSmaller = exibble().select(["date", "time"]).head(4)

    let dates = tabella(exibbleSmaller):
      fmtDate "date", dateStyle = "wday_month_day_year"
      fmtDate "date", rows = [2, 3], dateStyle = "day_month_year", locale = "de-CH"
      fmtTime "time", timeStyle = "h_m_s_p"
    nbTable dates

nbText: """
We support hundreds of locales, from `af` to `zu`! While there are more formatting methods yet to be added, the ones that are available all work exceedingly well.
"""

tabelline """
So does tabelline, from CLDR: the same locales, from `af` to `zu`.
"""

nbText: """
## Using Styles within a Table

We can use the `tab_style()` method in combination with `loc.body()` and various `style.*()` functions to set styles on cells of data within the table body. For example, the table-making code below applies a yellow background color to the targeted cells.
"""

tabs """
from great_tables import GT, style, loc
from great_tables.data import airquality

airquality_mini = airquality.head()

(
    GT(airquality_mini)
    .tab_style(
        style=style.fill(color="yellow"),
        locations=loc.body(columns="Temp", rows=[1, 2])
    )
)
""", """
airquality_mini <- airquality |> slice_head(n = 5)

gt(airquality_mini) |>
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = cells_body(columns = Temp, rows = 2:3)
  )
""":
  nbCode:
    let airMini = airquality().head()

    let yellow = tabella(airMini):
      tabStyle style = style.fill(color = "yellow"),
               locations = loc.body(cols = "Temp", rows = [1, 2])
    nbTable yellow

nbText: """
Aside from `style.fill()` we can also use `style.text()` and `style.borders()` to focus the styling on cell text and borders. Here's an example where we perform several types of styling on targeted cells (the key is to put the `style.*()` calls in a list).
"""

tabs """
from great_tables import GT, style, exibble

(
    GT(exibble[["num", "currency"]])
    .fmt_number(columns = "num", decimals=1)
    .fmt_currency(columns = "currency")
    .tab_style(
        style=[
            style.fill(color="lightcyan"),
            style.text(weight="bold")
        ],
        locations=loc.body(columns="num")
    )
    .tab_style(
        style=[
            style.fill(color = "#F9E3D6"),
            style.text(style = "italic")
        ],
        locations=loc.body(columns="currency")
    )
)
""", """
exibble |>
  select(num, currency) |>
  gt() |>
  fmt_number(columns = num, decimals = 1) |>
  fmt_currency(columns = currency) |>
  tab_style(
    style = list(
      cell_fill(color = "lightcyan"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(columns = num)
  ) |>
  tab_style(
    style = list(
      cell_fill(color = "#F9E3D6"),
      cell_text(style = "italic")
    ),
    locations = cells_body(columns = currency)
  )
""":
  nbCode:
    let styled = tabella(exibble().select(["num", "currency"])):
      fmtNumber "num", decimals = 1
      fmtCurrency "currency"
      tabStyle style = style.fill(color = "lightcyan") & style.text(weight = "bold"),
               locations = loc.body(cols = "num")
      tabStyle style = style.fill(color = "#F9E3D6") & style.text(style = "italic"),
               locations = loc.body(cols = "currency")
    nbTable styled

tabelline """
Styles join with `&`, where Great Tables puts them in a list.
"""

nbText: """
## Column Selection with Polars (and How It Helps with Styling)

Styles can also be specified using **Polars** expressions. For example, the code below uses the `Temp` column to set color to `"lightyellow"` or `"lightblue"`.
"""

tabs """
import polars as pl

from great_tables import GT, from_column, style, loc
from great_tables.data import airquality

airquality_mini = pl.from_pandas(airquality.head())

# A Polars expression defines color based on values in `Temp`
fill_color_temp = (
    pl.when(pl.col("Temp") > 70)
    .then(pl.lit("lightyellow"))
    .otherwise(pl.lit("lightblue"))
)

# Pass `fill_color_temp` to the `color=` arg of `style.fill()`
(
    GT(airquality_mini)
    .tab_style(
        style=style.fill(color=fill_color_temp),
        locations=loc.body("Temp")
    )
)
""", """
# from_column() with a function defines color based on values in `Temp`
fill_color_temp <- from_column(
  column = "Temp",
  fn = function(x) ifelse(x > 70, "lightyellow", "lightblue")
)

gt(airquality_mini) |>
  tab_style(
    style = cell_fill(color = fill_color_temp),
    locations = cells_body(Temp)
  )
""":
  nbCode:
    # a style for the rows where Temp > 70, another for the others
    let byTemp = tabella(airMini):
      tabStyle style.fill("lightyellow"), loc.body("Temp", where(it["Temp"] > 70))
      tabStyle style.fill("lightblue"), loc.body("Temp", where(not (it["Temp"] > 70)))
    nbTable byTemp

tabelline """
`where(cond)` selects the rows where `cond` holds, with `it` the row: tabelline's version of a
Polars expression. A style takes one colour, so two colours take two styles; a colour computed
for each row is a column of the data, read with `fromColumn`.
"""

nbText: """
We can deftly mix and match **Polars** column selectors and expressions. This gives us great flexibility in selecting specific columns and rows. Here's an example of doing that again with `tab_style()`:
"""

tabs """
import polars.selectors as cs

(
    GT(airquality_mini)
    .tab_style(
        style=style.fill(color="yellow"),
        locations=loc.body(
            columns=cs.starts_with("Te"),
            rows=pl.col("Temp") > 70
        )
    )
)
""", """
gt(airquality_mini) |>
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = cells_body(
      columns = starts_with("Te"),
      rows = Temp > 70
    )
  )
""":
  nbCode:
    let mixed = tabella(airMini):
      tabStyle style = style.fill(color = "yellow"),
               locations = loc.body(cols = startsWith("Te"), rows = where(it["Temp"] > 70))
    nbTable mixed

nbText: """
It feels great to use the conveniences offered by **Polars** and we're excited about how far we can take this!

## Where We're Going with **Great Tables**

We're obviously pretty encouraged about how **Great Tables** is turning out and so we'll continue to get useful table-making niceties into the package. We welcome any and all feedback, so get in touch with us:

- you can file a GitHub [issue](https://github.com/posit-dev/great-tables/issues) or get a discussion going in [GitHub Discussions](https://github.com/posit-dev/great-tables/discussions)
- there's an [X/Twitter account at @gt_package](https://twitter.com/gt_package), so check it out for package news and announcements
- there's a fun [Discord server](https://discord.gg/Ux7nrcXHVV) that lets you more casually ask questions and generally just talk about table things

Stay tuned for more on **Great Tables** in this blog or elsewhere in the Internet!
"""

bookSave()
