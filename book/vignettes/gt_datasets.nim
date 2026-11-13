import tabbook
import tabelline, gtdata
bookInit()

nbText: "# gt Datasets"

attribution gtVignette("gt Datasets", "gt-datasets",
  "The R chunks are the article's own; the Python tab writes them with Polars, for the datasets " &
  "that Great Tables ships too. The article's six pictures of the datasets are left out, and its " &
  "data dictionaries are shown as tables, without their code.")

proc dictionary(rows: openArray[(string, string, string)]): Tabella =
  ## A data dictionary as the article draws it: the names and types in Courier, the table smaller.
  var column, kind, description: seq[Value]
  for (c, k, d) in rows:
    column.add toValue(c)
    kind.add toValue(k)
    description.add toValue(d)
  let data = TableData()
  data.addColumn("Column", column)
  data.addColumn("Type", kind)
  data.addColumn("Description", description)
  tabella(data):
    tabStyle style.text(font = "Courier"), loc.body(cols = ["Column", "Type"])
    tabOptions(tableWidth = "80%", tableFontSize = "smaller", columnLabelsFontSize = "small")

nbText: """
The **gt** package comes with six built-in datasets for experimenting with the **gt** API: `countrypops`, `sza`, `gtcars`, `sp500`, `pizzaplace`, and `exibble`. While each dataset has different subject matter, all of them will be used to develop **gt** examples with consistent syntax.

Each dataset is stored as a tibble, ranging from very small (like `exibble`, an example tibble of 8 rows) to quite large in size (e.g., at nearly 50,000 rows: `pizzaplace`). Larger datasets are typically impractical as **gt output tables** but they provide opportunities for demonstrating preprocessing using tidyverse tools like **dplyr** and **tidyr** (upstream of **gt**'s `gt()` entry point).

In many **gt** workflows, there will often be prep work like this where the creation of the input table and any salient information (e.g., metadata for footnotes) will be done alongside the preparation of the display table.

In the next few examples, we'll show how tables can be created with each of these datasets. Each example will be preceded with a set of requirements that serve as a design brief. This planning stage can be very useful in your own work for the purpose of organization. The hope is that this collection of simple examples will inspire the creation of much more interesting display tables with **gt**.
"""

tabelline """
The six datasets are in tabelline too: `countrypops`, `gtcars` and `exibble` in
`tabelline/datasets`, `sza` in the book's `gtdata`, and `sp500` (only 2010, the year the
example uses) and `pizzaplace` (only the columns it uses) as CSV text in `gtdata`. The data steps
are written with [nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim, as the Python
tab writes them with Polars; `import tabelline/nanuq` lets `tabella` take its data frames.
"""

nbText: """
### `countrypops`

This dataset provides the total populations of 215 countries on a yearly basis, from 1960 to 2021. The source data comes from the [World Bank](https://data.worldbank.org/indicator/SP.POP.TOTL), where it has been cleaned and tidied up for inclusion into this package. Each row contains a population value for a country in a given year, where `NA` values for `population` indicate that the country did not exist in that particular year.

The `countrypops` dataset is a tibble with 13,330 rows and 5 variables. Here are explanations for each of the variables:
"""

nbTable dictionary([
  ("country_name", "chr", "Name of the country"),
  ("country_code_2", "chr", "The 2-letter ISO 3166-1 country code"),
  ("country_code_3", "chr", "The 3-letter ISO 3166-1 country code"),
  ("year", "int", "The year for the population estimate"),
  ("population", "int", "The population estimate, midway through the year")])

nbText: """
#### A `countrypops` Example

The table that we'll create from `countrypops` will meet these requirements:

1. use countries from Oceania
2. countries in different regions of Oceania will be grouped together
3. provide populations for the 2000, 2010, and 2020 years only; they should appear as separate columns with a spanner group column stating that these columns refer to population values
4. format population figures to contain commas
5. provide a descriptive title
"""

tabs """
import polars as pl
from great_tables import GT, html, loc, md, style, vals
from great_tables.data import countrypops, exibble, gtcars, pizzaplace, sp500, sza

# Get lists of 2-letter country codes for each region of Oceania
Australasia = ["AU", "NZ"]
Melanesia = ["NC", "PG", "SB", "VU"]
Micronesia = ["FM", "GU", "KI", "MH", "MP", "NR", "PW"]
Polynesia = ["PF", "WS", "TO", "TV"]

region = (
    pl.when(pl.col("country_code_2").is_in(Australasia)).then(pl.lit("Australasia"))
    .when(pl.col("country_code_2").is_in(Melanesia)).then(pl.lit("Melanesia"))
    .when(pl.col("country_code_2").is_in(Micronesia)).then(pl.lit("Micronesia"))
    .when(pl.col("country_code_2").is_in(Polynesia)).then(pl.lit("Polynesia"))
)

# Create a GT table based on a preprocessed `countrypops`
oceania = (
    pl.from_pandas(countrypops)
    .filter(pl.col("country_code_2").is_in(Australasia + Melanesia + Micronesia + Polynesia))
    .filter(pl.col("year").is_in([2000, 2010, 2020]))
    .with_columns(region=region)
    .drop("country_code_2", "country_code_3")
    .pivot(on="year", index=["country_name", "region"], values="population")
    .sort(["region", "2020"], descending=[False, True])
)

(
    GT(oceania, rowname_col="country_name", groupname_col="region")
    .tab_header(title="Populations of Oceania's Countries in 2000, 2010, and 2020")
    .tab_spanner(label="Total Population", columns=["2000", "2010", "2020"])
    .fmt_integer()
)
""", """
library(gt)
library(dplyr)
library(tidyr)

# Get vectors of 2-letter country codes for each region of Oceania
Australasia <- c("AU", "NZ")
Melanesia <- c("NC", "PG", "SB", "VU")
Micronesia <- c("FM", "GU", "KI", "MH", "MP", "NR", "PW")
Polynesia <- c("PF", "WS", "TO", "TV")

# Create a gt table based on a preprocessed `countrypops`
countrypops |>
  filter(country_code_2 %in% c(
    Australasia, Melanesia, Micronesia, Polynesia)
  ) |>
  filter(year %in% c(2000, 2010, 2020)) |>
  mutate(region = case_when(
    country_code_2 %in% Australasia ~ "Australasia",
    country_code_2 %in% Melanesia ~ "Melanesia",
    country_code_2 %in% Micronesia ~ "Micronesia",
    country_code_2 %in% Polynesia ~ "Polynesia",
  )) |>
  pivot_wider(names_from = year, values_from = population) |>
  arrange(region, desc(`2020`)) |>
  select(-starts_with("country_code")) |>
  gt(
    rowname_col = "country_name",
    groupname_col = "region"
  ) |>
  tab_header(title = "Populations of Oceania's Countries in 2000, 2010, and 2020") |>
  tab_spanner(
    label = "Total Population",
    columns = everything()
  ) |>
  fmt_integer()
""":
  nbCode:
    import std/streams
    import nanuq
    import tabelline/nanuq

    # Get lists of 2-letter country codes for each region of Oceania
    let
      Australasia = ["AU", "NZ"]
      Melanesia = ["NC", "PG", "SB", "VU"]
      Micronesia = ["FM", "GU", "KI", "MH", "MP", "NR", "PW"]
      Polynesia = ["PF", "WS", "TO", "TV"]

    let code = col("country_code_2")
    let region = `when`(code.isIn(Australasia)).then("Australasia")
      .`when`(code.isIn(Melanesia)).then("Melanesia")
      .`when`(code.isIn(Micronesia)).then("Micronesia")
      .`when`(code.isIn(Polynesia)).then("Polynesia")

    # Create a table based on a preprocessed `countrypops`
    let oceania = readCsv(newStringStream(countrypopsCsv), inferSchemaLength = 10_000)
      .filter(code.isIn(@Australasia & @Melanesia & @Micronesia & @Polynesia))
      .filter(col("year").isIn([2000, 2010, 2020]))
      .withColumns(Expr(region).alias("region"))
      .drop(["country_code_2", "country_code_3"])
      .pivot(on = "year", index = ["country_name", "region"], values = "population")
      .sort(["region", "2020"], descending = [false, true])

    let oceaniaTbl = tabella(oceania, rownameCol = "country_name", groupnameCol = "region"):
      tabHeader "Populations of Oceania's Countries in 2000, 2010, and 2020"
      tabSpanner "Total Population", everything()
      fmtInteger()
    nbTable oceaniaTbl

tabelline """
The numbers in the R tab differ a little from the other two: gt 1.4 has the World Bank's newer
estimates, and tabelline's `countrypops` is the one Great Tables ships.
"""

nbText: """
### `sza`

The solar zenith angle is one measure of the solar position. It can be thought of as 'height' of the sun in relation to an observer. A solar zenith angle of 0&deg; indicates that the sun is directly overhead (a different solar angle, the *solar altitude angle*, is 90&deg; in this instance). With the sun at the horizontal (e.g., during sunrise/sunset) we observe the solar zenith angle to be around 90&deg; (there is the matter of atmospheric refraction). During nighttime, solar zenith angles in the range of 90&ndash;180 are possible (again, depending on the location of the observer).

The `sza` dataset has calculated values for the solar zenith angles every 30 minutes from 04:00 to 12:00 (true solar time). Temporally, these calculations are for the 1st of every month of the year. Spatially, the observer is located at somewhere along latitudes 20&deg;N, 30&deg;N, 40&deg;N, and 50&deg;N (because we are using true solar time, the longitude is unimportant). This is quite an extensive topic, and more information can be found by using `?sza` in the R console or by visiting [this page](https://en.wikipedia.org/wiki/Solar_zenith_angle).

The `sza` dataset is a tibble with 816 rows and 4 variables. Here are explanations for each of the variables:
"""

nbTable dictionary([
  ("latitude", "dbl", "The latitude in decimal degrees for the observations"),
  ("month", "fct", "The measurement month; all calculations where conducted for the first day of each month"),
  ("tst", "chr", "The true solar time at the given latitude and date (first of month) for which the solar zenith angle is calculated"),
  ("sza", "dbl", "The solar zenith angle in degrees, where NAs indicate that sunrise hadn't yet occurred by the tst value")])

nbText: """
#### An `sza` Example

The table that we'll create from `sza` will meet these requirements:

1. filter the data to just use the 20&deg;N data and remove the `latitude` column
2. `NA` values from `sza` column are to be removed
3. reshape the table so that columns of `tst` (true solar time) contain angles in degrees (from the `sza` column)
4. the **gt output table** will have the `month`s as row labels in the stub
5. missing values will be replaced with an empty string (so that those cells are blank)
6. a stubhead label will state what's inside the stubs (months, at 20&deg;N)
7. the table will have a heading decorated with the HTML *Black Sun with Rays* (`&#x2600;`) symbol
8. to fit the large amount of data in a small area, use some table options to reduce text size and row padding
"""

tabs """
# Create a GT table based on a preprocessed `sza`
sza_20 = (
    pl.from_pandas(sza)
    .filter(pl.col("latitude") == "20")
    .drop("latitude")
    .drop_nulls("sza")
    .pivot(on="tst", index="month", values="sza")
)

(
    GT(sza_20, rowname_col="month")
    .sub_missing(missing_text="")
    .tab_stubhead(label=md("month<br>(20&deg;N)"))
    .tab_header(title=md("&#x2600; Solar Zenith Angles &#x2600;"))
    .tab_options(
        column_labels_font_size="smaller",
        table_font_size="smaller",
        data_row_padding="3px",
    )
)
""", """
# Create a gt table based on a preprocessed `sza`
sza |>
  filter(latitude == 20) |>
  select(-latitude) |>
  filter(!is.na(sza)) |>
  pivot_wider(names_from = "tst", values_from = sza) |>
  gt(rowname_col = "month") |>
  sub_missing(missing_text = "") |>
  tab_stubhead(label = md("month<br>(20&deg;N)")) |>
  tab_header(title = md("&#x2600; Solar Zenith Angles &#x2600;")) |>
  tab_options(
    column_labels.font.size = "smaller",
    table.font.size = "smaller",
    data_row.padding = px(3)
  )
""":
  nbCode:
    # Create a table based on a preprocessed `sza`
    let sza20 = readCsv(newStringStream(szaCsv), inferSchemaLength = 0)  # every column as text
      .filter(col("latitude") == "20")
      .drop("latitude")
      .dropNulls("sza")
      .withColumns(col("sza").`cast`(Float64))
      .pivot(on = "tst", index = "month", values = "sza")

    let szaTbl = tabella(sza20, rownameCol = "month"):
      subMissing(missingText = "")
      tabStubhead html"month<br>(20°N)"
      tabHeader "☀ Solar Zenith Angles ☀"
      tabOptions(columnLabelsFontSize = "smaller", tableFontSize = "smaller",
                 dataRowPadding = "3px")
    nbTable szaTbl

tabelline """
The degree sign and the sun are written as they are: Nim's strings are UTF-8, so the title needs
no Markdown to turn `&#x2600;` into ☀, and the stubhead takes `html` only for its line break.
`sza` is read with every column as text, so the times keep their leading zero (`0530`), and the
angles are then cast to numbers.
"""

nbText: """
### `gtcars`

The `gtcars` dataset takes off where `mtcars` left off. It contains 47 cars from the 2014-2017 model years. Many of the `gtcars` vehicles are grand tourers. Indeed, many of these provide the ability to cross an entire continent at speed and in comfort yet, when it's called for, they will allow you to experience driving thrills. The chassis and suspension are in most cases top-notch and supply superb handling and roadholding on all routes one would conceivably encounter during the grand touring experience. The two plus two (2 + 2) seating configuration is smartly designed to deliver comfort for a driver and passenger, adequate space for luggage, and have room to spare.

The `gtcars` dataset is a tibble with 47 rows and 15 variables. Here are explanations for each of the variables:
"""

nbTable dictionary([
  ("mfr", "chr", "The name of the car manufacturer"),
  ("model", "chr", "The car's model name"),
  ("year", "int", "The car's model year"),
  ("trim", "chr", "A short description of the car model's trim"),
  ("bdy_style", "chr", "An identifier of the car's body style, which is either coupe, convertible,     sedan, or hatchback"),
  ("hp, hp_rpm", "int", "The car's horsepower and the associated RPM level"),
  ("trq, trq_rpm", "int", "The car's torque and the associated RPM level"),
  ("mpg_c, mpg_h", "int", "The miles per gallon fuel efficiency rating for city and highway driving"),
  ("drivetrain", "chr", "The car's drivetrain which, for this dataset is either rwd (Rear Wheel Drive)     or awd (All Wheel Drive)"),
  ("trsmn", "chr", "The codified transmission type, where the number part is the number of gears; the car could have automatic transmission (a), manual transmission (m), an option to switch between both types (am), or, direct drive (dd)"),
  ("ctry_origin", "chr", "The country name for where the vehicle manufacturer is headquartered")])

nbText: """
#### A `gtcars` Example

The table that we'll create from `gtcars` will meet these requirements:

1. only include German cars
2. limit the dataset to the top two most expensive offerings from each German manufacturer
3. the information included will be the manufacturer (`mfr`), the car model (`model`), the `drivetrain`, and the price (`msrp`)
4. add a table title
5. combine the car make and model into a single column
6. capitalize the `drivetrain` text
7. format the prices as USD currency with commas and no decimal places shown
8. relabel the column headings to provide nicer labels
9. add two footnotes to explain the `drivetrain` abbreviations and to specify the currency of the `msrp` prices; ensure that the footnote marks are lowercase letters
"""

tabs """
# Create a GT table based on a preprocessed `gtcars`
german = (
    pl.from_pandas(gtcars)
    .filter(pl.col("ctry_origin") == "Germany")
    .sort(["mfr", "msrp"], descending=[False, True])
    .filter(pl.int_range(pl.len()).over("mfr") < 2)
    .select("mfr", "model", "drivetrain", "msrp")
)

(
    GT(german)
    .tab_header(title="Select German Automobiles")
    .cols_merge(columns=["mfr", "model"])
    .text_transform(locations=loc.body(columns="drivetrain"), fn=lambda x: x.upper())
    .fmt_currency(columns="msrp", decimals=0)
    .cols_label(mfr="Car", drivetrain="Drivetrain", msrp="MSRP")
    .tab_footnote(footnote="Prices in USD.", locations=loc.column_labels(columns="msrp"))
    .tab_footnote(
        footnote="AWD = All Wheel Drive, RWD = Rear Wheel Drive.",
        locations=loc.column_labels(columns="drivetrain"),
    )
    .opt_footnote_marks(marks="letters")
)
""", """
# Create a gt table based on a preprocessed `gtcars`
gtcars |>
  filter(ctry_origin == "Germany") |>
  slice_max(n = 2, msrp, by = mfr) |>
  select(mfr, model, drivetrain, msrp) |>
  gt() |>
  tab_header(title = "Select German Automobiles") |>
  cols_merge(columns = c(mfr, model)) |>
  text_transform(
    locations = cells_body(columns = drivetrain),
    fn = function(x) toupper(x)
  ) |>
  fmt_currency(decimals = 0) |>
  cols_label(
    mfr = "Car",
    drivetrain = "Drivetrain",
    msrp = "MSRP"
  ) |>
  tab_footnote(
    footnote = "Prices in USD.",
    locations = cells_column_labels(columns = msrp)
  ) |>
  tab_footnote(
    footnote = "AWD = All Wheel Drive, RWD = Rear Wheel Drive.",
    locations = cells_column_labels(columns = drivetrain)
  ) |>
  opt_footnote_marks(marks = "letters")
""":
  nbCode:
    import std/strutils

    # Create a table based on a preprocessed `gtcars`
    let german = readCsv(newStringStream(gtcarsCsv), inferSchemaLength = 10_000)
      .filter(col("ctry_origin") == "Germany")
      .sort(["mfr", "msrp"], descending = [false, true])
      .filter(intRange(0, len()).over("mfr") < 2)
      .select("mfr", "model", "drivetrain", "msrp")

    let germanTbl = tabella(german):
      tabHeader "Select German Automobiles"
      colsMerge ["mfr", "model"]
      textTransform proc (x: string): string = x.toUpperAscii, loc.body(cols = "drivetrain")
      fmtCurrency "msrp", decimals = 0
      colsLabel:
        mfr: "Car"
        drivetrain: "Drivetrain"
        msrp: "MSRP"
      tabFootnote "Prices in USD.", loc.columnLabels(cols = "msrp")
      tabFootnote "AWD = All Wheel Drive, RWD = Rear Wheel Drive.",
        loc.columnLabels(cols = "drivetrain")
      optFootnoteMarks "letters"
    nbTable germanTbl

tabelline """
dplyr's `slice_max(by = mfr)` keeps the makers in the order they first come in `gtcars` (BMW
first); the Python and Nim tabs sort them by name, so Audi comes first.
"""

nbText: """
### `sp500`

The S&P 500 is a capitalization-weighted index of about 500 leading companies (where bigger companies have more influence within the index) that have common stock listed in either the NYSE or NASDAQ markets. The companies chosen are intended to provide representation of the U.S. economy. This index is a managed list (managed by S&P Dow Jones Indices LLC) with occasional changes of the constituent companies based on their performance and changes in the economy.

There is daily S&P 500 data available in the `sp500` dataset, with daily indicators (price statistics, `volume`, etc.) from 1950 to 2015, inclusive. There are 16,607 rows in the dataset, and 7 variables:
"""

nbTable dictionary([
  ("date", "date", "The date expressed as `Date` values"),
  ("open, high, low, close", "dbl", "The day's opening, high, low, and closing prices in USD; the close price is adjusted for splits"),
  ("volume", "dbl", "The number of trades for the given `date`"),
  ("adj_close", "dbl", "The close price adjusted for both dividends and splits")])

nbText: """
#### An `sp500` Example

The table that we'll create from `sp500` will meet these requirements:

1. use only data from the period `2010-06-02` to `2010-06-15`
2. the adjusted close `adj_close` column won't be included
3. a title and subtitle will be added to describe the contents of the table
4. put the column labels in title case
5. format the `date` column to appear as '2 Jun 2010'
6. have the price columns (`open`, `high`, `low`, `close`) appear in USD
7. the large numbers in `volume` should be shown as billions (with the `B` suffix)
8. up- and down-pointing triangles (in green and red) will be added alongside the `close` price as appropriate
"""

tabs """
# Define the start and end dates for the data range
start_date = "2010-06-02"
end_date = "2010-06-15"

# The HTML decimal references for the black
# up- and down-pointing triangles are: #9650 and #9660;
# use an in-line style to apply color
up_arrow = '<span style="color:green">&#9650;</span>'
down_arrow = '<span style="color:red">&#9660;</span>'

# Create a GT table based on a preprocessed `sp500`
sp500_june = (
    pl.from_pandas(sp500)
    .filter(pl.col("date").is_between(pl.lit(start_date), pl.lit(end_date)))
    .drop("adj_close")
)

(
    GT(sp500_june)
    .tab_header(title="S&P 500", subtitle=f"{start_date} to {end_date}")
    .fmt_date(columns="date", date_style="day_m_year")
    .fmt_currency(columns=["open", "high", "low", "close"])
    .fmt_number(columns="volume", compact=True)
    .text_transform(
        locations=loc.body(columns="close", rows=pl.col("close") > pl.col("open")),
        fn=lambda x: f"{x} {up_arrow}",
    )
    .text_transform(
        locations=loc.body(columns="close", rows=pl.col("close") < pl.col("open")),
        fn=lambda x: f"{x} {down_arrow}",
    )
    .cols_label_with(fn=lambda x: x[0].upper() + x[1:])
)
""", """
# Define the start and end dates for the data range
start_date <- "2010-06-02"
end_date <- "2010-06-15"

# The HTML decimal references for the black
# up- and down-pointing triangles are: #9650 and #9660;
# use an in-line style to apply color
up_arrow <- "<span style=\"color:green\">&#9650;</span>"
down_arrow <- "<span style=\"color:red\">&#9660;</span>"

# Create a gt table based on a preprocessed `sp500`
sp500 |>
  filter(date >= start_date, date <= end_date) |>
  select(-adj_close) |>
  gt() |>
  tab_header(
    title = "S&P 500",
    subtitle = glue::glue("{start_date} to {end_date}")
  ) |>
  fmt_date(
    columns = date,
    date_style = "day_m_year"
  ) |>
  fmt_currency(columns = c(open, high, low, close)) |>
  fmt_number(columns = volume, suffixing = TRUE) |>
  text_transform(
    locations = cells_body(
      columns = close,
      rows = close > open
    ),
    fn = function(x) paste(x, up_arrow)
  ) |>
  text_transform(
    locations = cells_body(
      columns = close,
      rows = close < open
    ),
    fn = function(x) paste(x, down_arrow)
  ) |>
  cols_label_with(
    columns = everything(),
    fn = ~ paste0(toupper(substr(., 1, 1)), substr(., 2, nchar(.)))
  )
""":
  nbCode:
    # Define the start and end dates for the data range
    let
      startDate = "2010-06-02"
      endDate = "2010-06-15"

    # The HTML decimal references for the black
    # up- and down-pointing triangles are: #9650 and #9660;
    # use an in-line style to apply color
    let
      upArrow = "<span style=\"color:green\">&#9650;</span>"
      downArrow = "<span style=\"color:red\">&#9660;</span>"

    # Create a table based on a preprocessed `sp500`
    let sp500June = readCsv(newStringStream(sp500Csv), inferSchemaLength = 10_000)
      .filter(col("date") >= lit(startDate) and col("date") <= lit(endDate))
      .drop("adj_close")

    let sp500Tbl = tabella(sp500June):
      tabHeader "S&P 500", startDate & " to " & endDate
      fmtDate "date", dateStyle = "day_m_year"
      fmtCurrency ["open", "high", "low", "close"]
      fmtNumber "volume", compact = true
      textTransform proc (x: string): string = x & " " & upArrow,
        loc.body(cols = "close", rows = where(it["close"] > it["open"]))
      textTransform proc (x: string): string = x & " " & downArrow,
        loc.body(cols = "close", rows = where(it["close"] < it["open"]))
      colsLabelWith capitalizeAscii
    nbTable sp500Tbl

tabelline """
`compact = true` is gt's `suffixing = TRUE` and Great Tables' `compact=True`: 4.04B for
4,040,000,000. The text that `textTransform` returns is HTML, as in gt, so the triangles keep
the article's inline colours.
"""

nbText: """
### `pizzaplace`

The `pizzaplace` dataset is unusual to say the least. It brings up more questions than answers. Why is it that the 'The Greek' pizza (`the_greek`) comes in `XL` and `XXL` sizes whilst (almost) all the other pizzas adhere to the `S`-`M`-`L` paradigm? Why is the 'Brie Carre' pizza (`brie_carre`) only small? Also, is any of this real (?), and, what is the nature of reality? (All of these questions are quite complicated... however, while I can doubt the existence of the material world, I cannot doubt the existence of myself as someone thinking about all the delicious pizzas on offer at `pizzaplace`.)

We have somehow obtained the 2015 sales from the pizzaplace, where each row is a pizza sold. There are 32 different types of pizza in 4 different categories: `classic`, `chicken`, `supreme`, and `veggie`. It was a great year of sales, personal problems notwithstanding. A kitchen fire in late September did not help with the morale situation. Nevertheless, $817,860 in sales for the year! That was indeed something to be cheerful about.

Let's learn more about how this fascinating dataset is structured:
"""

nbTable dictionary([
  ("id", "chr", "The ID for the order, which consists of one or more pizzas at a given `date` and `time`"),
  ("date", "chr", "A character representation of the order `date`, expressed in the ISO 8601 date format (YYYY-MM-DD)"),
  ("time", "chr", "A character representation of the order time, expressed as a 24-hour time the ISO 8601 extended time format (hh:mm:ss)"),
  ("name", "chr", "The short name for the pizza"),
  ("size", "chr", "The size of the pizza, which can either be S, M, L, XL (rare!), or XXL (even rarer!); most pizzas are available in the S, M, and L sizes but exceptions apply"),
  ("type", "chr", "The category or type of pizza, which can either be `classic`, `chicken`, `supreme`, or `veggie`"),
  ("price", "dbl", "The price of the pizza and the amount that it sold for (in USD)")])

nbText: """
#### A `pizzaplace` Example

Let's make a reporting table from the `pizzaplace` dataset with these requirements:

1. obtain the total sale numbers and revenue from each `size` of pizza from each category (`type`)
2. create a gt table where each row represents a combination of `size`-`type` (`size` provides the row labels and `type` forms the row groups)
3. add a title to explain the contents of the table
4. format the numeric `sold` column to use commas and no decimal places
5. format the currency values (`income`) to be in `USD` currency
5. add a summary for each grouping that provides total sell counts and revenue amounts
6. color the row groups and summary cells to add a little pizzazz
"""

tabs """
# Create a GT table based on a preprocessed `pizzaplace`
pizza_sales = (
    pl.from_pandas(pizzaplace)
    .group_by("type", "size")
    .agg(sold=pl.len(), income=pl.col("price").sum())
    .sort("type", "size")
)

(
    GT(pizza_sales, rowname_col="size", groupname_col="type")
    .tab_header(title="Pizzas Sold in 2015")
    .fmt_integer(columns="sold")
    .fmt_currency(columns="income")
    # one summary row for both columns: the count is an integer, the income a float
    .summary_rows(
        fns={"TOTAL": pl.col("sold", "income").sum()},
        fmt=lambda x: vals.fmt_integer(x) if isinstance(x[0], int) else vals.fmt_currency(x),
    )
    .tab_options(
        summary_row_background_color="#ACEACE",
        row_group_background_color="#FFEFDB",
    )
)
""", """
# Create a gt table based on a preprocessed `pizzaplace`
pizzaplace |>
  dplyr::group_by(type, size) |>
  dplyr::summarize(
    sold = n(),
    income = sum(price),
    .groups = "drop_last"
  ) |>
  gt(rowname_col = "size") |>
  tab_header(title = "Pizzas Sold in 2015") |>
  fmt_integer(columns = sold) |>
  fmt_currency(columns = income) |>
  summary_rows(
    columns = sold,
    fns = list(TOTAL = "sum"),
    fmt = list(~ fmt_integer(.))
  ) |>
  summary_rows(
    columns = income,
    fns = list(TOTAL = "sum"),
    fmt = list(~ fmt_currency(.))
  ) |>
  tab_options(
    summary_row.background.color = "#ACEACE",
    row_group.background.color = "#FFEFDB"
  )
""":
  nbCode:
    # Create a table based on a preprocessed `pizzaplace`
    let pizzaSales = readCsv(newStringStream(pizzaplaceCsv), inferSchemaLength = 10_000)
      .groupBy("type", "size")
      .agg(len().alias("sold"), col("price").sum.alias("income"))
      .sort(["type", "size"])

    let pizzaTbl = tabella(pizzaSales, rownameCol = "size", groupnameCol = "type"):
      tabHeader "Pizzas Sold in 2015"
      fmtInteger "sold"
      fmtCurrency "income"
      summaryRows:
        TOTAL: agg.sum
        columns = "sold"
        fmtInteger()
      summaryRows:
        TOTAL: agg.sum
        columns = "income"
        fmtCurrency()
      tabOptions(summaryRowBackgroundColor = "#ACEACE", rowGroupBackgroundColor = "#FFEFDB")
    nbTable pizzaTbl

tabelline """
Two `summaryRows` with the same label make one row in tabelline, as in the article, each
filling its own columns. In Great Tables a second call with the label `TOTAL` replaces the
first, so the Python tab makes the row in one call and tells the count from the income by its
type; gt 1.4 labels the row `sum`, where the article shows `TOTAL`.
"""

nbText: """
### `exibble`

The example tibble that's useful for **gt** is called `exibble`. It's 8 rows, has clear ordering of data, and the columns contain data that can be tested with the various **gt** formatter functions (`fmt*()`). Here is a table describing the columns of `exibble`:
"""

nbTable dictionary([
  ("num", "dbl", "A numeric column ordered with increasingly larger values"),
  ("char", "chr", "A character column composed of names of fruits from a to h"),
  ("fctr", "fct", "A factor column with numbers from 1 to 8, written out"),
  ("date, time, datetime", "chr", "Character columns with dates, times, and datetimes"),
  ("currency", "dbl", "A numeric column that is useful for testing currency-based formatting"),
  ("row", "chr", "A character column in the format `row_X` which can be useful for testing with row label in a table stub"),
  ("group", "chr", "A character column with four `grp_a` values and four `grp_b` values which can be useful for testing tables that contain row groups")])

nbText: """
#### An `exibble` Example

Let's test as many formatter functions as possible with `exibble` while also using row labels and row groups (furnished by the `row` and `group` columns). We'll format `num` to display numbers with 2 decimal places. The dates in `date` will be formatted with `date_style` `6` (the `m_day_year` style, use `info_date_style()` to learn about all of them). The 24-h time values in `time` will use `time_style` `4` (`hm_p`, more info at `info_time_style()`). Datetimes as in `datetime` column can be formatted with the `fmt_datetime()` function (which uses the `date_style` and `time_style` arguments). The column `currency` will be formatted as a currency with `fmt_currency` and we'll consider these values to be euros (`currency = "EUR"`).
"""

tabs """
# Create a GT table based on `exibble`
(
    GT(exibble, rowname_col="row", groupname_col="group")
    .fmt_number(columns="num", decimals=2)
    .fmt_date(columns="date", date_style="m_day_year")
    .fmt_time(columns="time", time_style="h_m_p")
    .fmt_datetime(columns="datetime", date_style="m_day_year", time_style="h_m_p")
    .fmt_currency(columns="currency", currency="EUR")
    .tab_options(
        column_labels_font_size="small",
        table_font_size="small",
        row_group_font_size="small",
        data_row_padding="3px",
    )
)
""", """
# Create a gt table based on `exibble`
exibble |>
  gt(
    rowname_col = "row",
    groupname_col = "group"
  ) |>
  fmt_number(
    columns = num,
    decimals = 2
  ) |>
  fmt_date(
    columns = date,
    date_style = "m_day_year"
  ) |>
  fmt_time(
    columns = time,
    time_style = "h_m_p"
  ) |>
  fmt_datetime(
    columns = datetime,
    date_style = "m_day_year",
    time_style = "h_m_p"
  ) |>
  fmt_currency(
    columns = currency,
    currency = "EUR"
  ) |>
  tab_options(
    column_labels.font.size = "small",
    table.font.size = "small",
    row_group.font.size = "small",
    data_row.padding = px(3)
  )
""":
  nbCode:
    # Create a table based on `exibble`
    let exibbleTbl = tabella(exibble(), rownameCol = "row", groupnameCol = "group"):
      fmtNumber "num", decimals = 2
      fmtDate "date", dateStyle = "m_day_year"
      fmtTime "time", timeStyle = "h_m_p"
      fmtDatetime "datetime", dateStyle = "m_day_year", timeStyle = "h_m_p"
      fmtCurrency "currency", currency = "EUR"
      tabOptions(columnLabelsFontSize = "small", tableFontSize = "small",
                 rowGroupFontSize = "small", dataRowPadding = "3px")
    nbTable exibbleTbl

bookSave()
