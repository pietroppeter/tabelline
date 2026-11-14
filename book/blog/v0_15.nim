import tabbook
bookInit()

nbText: "# Great Tables `v0.15.0`: Flags, Icons, and Other Formatting Goodies"

attribution gtBlog("Great Tables v0.15.0: Flags, Icons, and Other Formatting Goodies",
  "introduction-0.15.0/", "Rich Iannone", "19 Dec 2024",
  "The table of accounting notation shows its code, which the post folds away.")

nbText: """
The development of Great Tables is really moving along these days. We just released version `0.15.0` and it adds quite a few nice things to the package. The features we'll highlight in this post are:

- adding flag icons with the new `fmt_flag()` method
- peppering your table cells with Font Awesome icons via `fmt_icon()`
- support for displaying accounting notation with four number-based formatting methods

Let's look at each of these in turn!

### Using `fmt_flag()` to incorporate country flag icons

When tables contain country-level data, having a more visual representation for a country can help the reader more quickly parse the table contents. The new `fmt_flag()` method makes this easy to accomplish. You just need to have either [two-letter country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) or [three-letter country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) in a column.

Here's an example where country flags, shown as simplified circular icons, can be added to a table with `fmt_flag()`:
"""

tabs """
from great_tables import GT
from great_tables.data import peeps
import polars as pl

peeps_mini = (
    pl.from_pandas(peeps)
    .filter(pl.col("dob").str.slice(offset=0, length=4) == "1988")
    .with_columns(name=pl.col("name_given") + " " + pl.col("name_family"))
    .fill_null(value="")
    .select(["country", "name", "address", "city", "state_prov", "postcode"])
)

(
    GT(peeps_mini)
    .tab_header(title="Our Contacts (Born in 1988)")
    .fmt_flag(columns="country")
    .opt_vertical_padding(scale=0.5)
    .cols_label(
        country="",
        name="Name",
        address="Address",
        city="City",
        state_prov="State/Prov.",
        postcode="Zip/Postcode",
    )
)
""", """
library(gt)
library(dplyr)

peeps_mini <-
  peeps |>
  filter(substr(as.character(dob), 1, 4) == "1988") |>
  mutate(name = paste(name_given, name_family)) |>
  mutate(across(where(is.character), ~ coalesce(.x, ""))) |>
  select(country, name, address, city, state_prov, postcode)

peeps_mini |>
  gt() |>
  tab_header(title = "Our Contacts (Born in 1988)") |>
  fmt_flag(columns = country) |>
  opt_vertical_padding(scale = 0.5) |>
  cols_label(
    country = "",
    name = "Name",
    address = "Address",
    city = "City",
    state_prov = "State/Prov.",
    postcode = "Zip/Postcode"
  )
""":
  nbCode:
    import std/streams
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    let peeps = readCsv(newStringStream(peepsCsv), inferSchemaLength = 0)  # every column as text
    let peepsMini = peeps
      .filter(col("dob").str.slice(0, 4) == "1988")
      .withColumns(concatStr([col("name_given"), col("name_family")], " ").alias("name"))
      .withColumns(all().fillNull(""))
      .select("country", "name", "address", "city", "state_prov", "postcode")

    let contacts = tabella(peepsMini):
      tabHeader "Our Contacts (Born in 1988)"
      fmtFlag "country"
      optVerticalPadding 0.5
      colsLabel:
        country: ""
        name: "Name"
        address: "Address"
        city: "City"
        state_prov: "State/Prov."
        postcode: "Zip/Postcode"
    nbTable contacts

tabelline """
The data steps are written with [nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim,
as the post writes them with Polars; `import tabelline/nanuq` makes `tabella(df)` take its data
frames. The CSV is read with every column as text (`inferSchemaLength = 0`), as the `peeps` of
Great Tables has them, so the postcodes keep their leading zeros.

`fmtFlag` takes two-letter and three-letter codes, as `fmt_flag()` does, but shows each flag as
its emoji, not as Great Tables' round picture: nothing is added to the page, and the flag looks
as the reader's system draws it (Windows draws the two letters instead). Hovering a flag shows its
code, where Great Tables shows the name of the country.
"""

nbText: """
This slice of the `peeps` dataset has country codes in their 3-letter form (i.e., `"USA"`, `"SVN"`, and `"CAN"`) within the `country` column. So long as they are correct, `fmt_flag()` will perform the conversion to flag icons. Also, there's a little bit of interactivity here: when hovering over a flag, the country name will appear as a tooltip!

We have the power to display multiple flag icons within a single cell. To make this happen, the country codes need to be combined in a single string where each code is separated by a comma (e.g., `"US,DE,GB"`). Here's an example that uses a portion of the `films` dataset:
"""

tabs """
from great_tables import GT, google_font
from great_tables.data import films
import polars as pl

films_mini = (
    pl.from_pandas(films)
    .filter(pl.col("director") == "Michael Haneke")
    .with_columns(title=pl.col("title") + " (" + pl.col("year").cast(pl.String) + ")")
    .select(["title", "run_time", "countries_of_origin"])
)

(
    GT(films_mini)
    .fmt_flag(columns="countries_of_origin")
    .tab_header(title="In Competition Films by Michael Haneke")
    .opt_stylize()
    .tab_options(column_labels_hidden=True)
    .opt_table_font(font=google_font("PT Sans"))
)
""", """
films_mini <-
  films |>
  filter(director == "Michael Haneke") |>
  mutate(title = paste0(title, " (", year, ")")) |>
  select(title, run_time, countries_of_origin)

films_mini |>
  gt() |>
  fmt_flag(columns = countries_of_origin) |>
  tab_header(title = "In Competition Films by Michael Haneke") |>
  opt_stylize() |>
  tab_options(column_labels.hidden = TRUE) |>
  opt_table_font(font = google_font("PT Sans"))
""":
  nbCode:
    let films = readCsv(newStringStream(filmsCsv), inferSchemaLength = 10_000)
    let filmsMini = films
      .filter(col("director") == "Michael Haneke")
      .withColumns(concatStr([col("title"), lit(" ("), col("year").`cast`(String), lit(")")])
                     .alias("title"))
      .select("title", "run_time", "countries_of_origin")

    let haneke = tabella(filmsMini):
      fmtFlag "countries_of_origin"
      tabHeader "In Competition Films by Michael Haneke"
      optStylize()
      tabOptions(columnLabelsHidden = true)
      optTableFont "\"PT Sans\", " & systemFonts("humanist")
    nbTable haneke

tabelline """
tabelline has no `google_font()`: a page of the book loads nothing from other sites, so the table
asks for PT Sans by name and falls back to a humanist stack of the reader's own fonts
(`systemFonts("humanist")`). The Python and R tabs show the same fallback, as the book takes
their `@import` of Google Fonts out.
"""

nbText: """
The column `countries_of_origin` has these combined strings for each of the co-production films, where countries are arranged by decreasing level of contribution (e.g., `"FR,AT,RO,DE"` in the second row). The `fmt_flag()` method parses these strings into a sequence of flag icons that are displayed in the order provided. Each of the flags is separated by a space character but you can always change that default separator with the `sep=` argument.

### Using `fmt_icon()` to include Font Awesome icons

The new `fmt_icon()` method gives you the ability to easily include Font Awesome icons in a table. It uses a similar input/output scheme as with `fmt_flag()`: provide the *short* icon name (e.g., `"table"`, `"music"`, `"globe"`, etc.) or a comma-separated list of them, and `fmt_icon()` will provide the Font Awesome icon in place. Let's see it in action with an example that uses the `metro` dataset:
"""

tabs """
from great_tables import GT
from great_tables.data import metro
import polars as pl

metro_mini = (
    pl.from_pandas(metro).tail(10)
    .with_columns(
        services = (
            pl.when(pl.col("connect_tramway").is_not_null())
            .then(pl.lit("train, train-tram"))
            .otherwise(pl.lit("train"))
        )
    )
    .select(["name", "services", "location"])
)

(
    GT(metro_mini)
    .tab_header("Services Available at Select Stations")
    .fmt_icon(columns="services", sep=" / ")
    .tab_options(column_labels_hidden=True)
    .opt_stylize(color="green")
    .opt_horizontal_padding(scale=3)
    .opt_align_table_header(align="left")
)
""", """
metro_mini <-
  metro |>
  tail(10) |>
  mutate(
    services = ifelse(!is.na(connect_tramway), "train, train-tram", "train")
  ) |>
  select(name, services, location)

metro_mini |>
  gt() |>
  tab_header("Services Available at Select Stations") |>
  fmt_icon(columns = services, sep = " / ") |>
  tab_options(column_labels.hidden = TRUE) |>
  opt_stylize(color = "green") |>
  opt_horizontal_padding(scale = 3) |>
  opt_align_table_header(align = "left")
""":
  nbCode:
    let metroDf = readCsv(newStringStream(metroCsv), inferSchemaLength = 10_000)
    let metroMini = metroDf.tail(10)
      .withColumns(`when`(col("connect_tramway").isNotNull)
                     .then(lit("train, train-tram"))
                     .otherwise(lit("train"))
                     .alias("services"))
      .select("name", "services", "location")

    let services = tabella(metroMini):
      tabHeader "Services Available at Select Stations"
      fmtIcon "services", sep = " / "
      tabOptions(columnLabelsHidden = true)
      optStylize color = "green"
      optHorizontalPadding 3
      optAlignTableHeader "left"
    nbTable services

tabelline """
`fmtIcon` draws the icons of Font Awesome Free from the SVG files tabelline ships, offline too, as
Great Tables does with faicons. `` `when` `` takes backticks in nanuq: `when` is a word of Nim.
"""

nbText: """
In the code, we added in the icon names `"train"` and `"train-tram"` to the `services` column, and there could either be just the train icon or the pair that includes the tramway service. We wanted a little separation between the icons in the latter case, so `sep=" / "` was used to place a slash with spacing between any pair of icons. The icons appear here with a black fill color, but that can be changed with the `fill_color=` argument (and there are several other arguments for controlling style attributes).

For a list of available icons, their names, and what they look like, check out [this listing on the Font Awesome website](https://fontawesome.com/search?m=free&o=r). The icons draw from the Font Awesome 'free' set (2000+ icons in total) but are not obtained via the web. Rather, we use the [faicons library](https://pypi.org/project/faicons/) so that this can be done entirely offline (directly using the SVG icons stored within faicons).

### Accounting notation in select numeric formatting methods

For certain types of tables, it may be preferable to use accounting notation for numerical figures. This type of notation renders negative values in parentheses while omitting the minus sign. This is often seen for monetary and percentage figures but it's also sensible for plain numbers in the right context. We've added support for accounting notation in four formatting methods:

- `fmt_number()`
- `fmt_integer()`
- `fmt_currency()`
- `fmt_percent()`

Here's a comprehensive example table that demonstrates how this type of formatting looks.
"""

tabs """
from great_tables import GT
import polars as pl

df = pl.DataFrame({
    "number_type": ["negative", "positive"],
    "number": [-1.2, 23.6],
    "integer": [-2323, 23213],
    "currency": [-24334.23, 7323.253],
    "percent": [-0.0523, 0.363]
    }
).with_columns(
    number_acc = pl.col("number"),
    integer_acc = pl.col("integer"),
    currency_acc = pl.col("currency"),
    percent_acc = pl.col("percent")
)

(
    GT(df, rowname_col="number_type")
    .fmt_number(columns="number")
    .fmt_percent(columns="percent")
    .fmt_integer(columns="integer")
    .fmt_currency(columns="currency")
    .fmt_number(columns="number_acc", accounting=True)
    .fmt_percent(columns="percent_acc", accounting=True)
    .fmt_integer(columns="integer_acc", accounting=True)
    .fmt_currency(columns="currency_acc", accounting=True)
    .tab_spanner(label="default formatting", columns=[1, 2, 3, 4])
    .tab_spanner(label="with accounting notation", columns=[5, 6, 7, 8])
    .cols_label(
        number_acc="number",
        integer_acc="integer",
        currency_acc="currency",
        percent_acc="percent"
    )
)
""", """
df <-
  dplyr::tibble(
    number_type = c("negative", "positive"),
    number = c(-1.2, 23.6),
    integer = c(-2323, 23213),
    currency = c(-24334.23, 7323.253),
    percent = c(-0.0523, 0.363)
  ) |>
  mutate(
    number_acc = number,
    integer_acc = integer,
    currency_acc = currency,
    percent_acc = percent
  )

df |>
  gt(rowname_col = "number_type") |>
  fmt_number(columns = number) |>
  fmt_percent(columns = percent) |>
  fmt_integer(columns = integer) |>
  fmt_currency(columns = currency) |>
  fmt_number(columns = number_acc, accounting = TRUE) |>
  fmt_percent(columns = percent_acc, accounting = TRUE) |>
  fmt_integer(columns = integer_acc, accounting = TRUE) |>
  fmt_currency(columns = currency_acc, accounting = TRUE) |>
  tab_spanner(label = "default formatting", columns = c(number, integer, currency, percent)) |>
  tab_spanner(
    label = "with accounting notation",
    columns = c(number_acc, integer_acc, currency_acc, percent_acc)
  ) |>
  cols_label(
    number_acc = "number",
    integer_acc = "integer",
    currency_acc = "currency",
    percent_acc = "percent"
  )
""":
  nbCode:
    let df = newDataFrame:
      number_type: ["negative", "positive"]
      number: [-1.2, 23.6]
      integer: [-2323, 23213]
      currency: [-24334.23, 7323.253]
      percent: [-0.0523, 0.363]
    let accounts = df.withColumns(
      col("number").alias("number_acc"), col("integer").alias("integer_acc"),
      col("currency").alias("currency_acc"), col("percent").alias("percent_acc"))

    proc accounting(f: proc (x: float): string): proc (v: Value): string =
      ## A format in accounting notation: a negative value in parentheses, with no minus sign.
      result = proc (v: Value): string =
        let x = v.toFloat
        if x < 0: "(" & f(-x) & ")" else: f(x)

    let acc = tabella(accounts, rownameCol = "number_type"):
      fmtNumber "number"
      fmtPercent "percent"
      fmtInteger "integer"
      fmtCurrency "currency"
      fmt "number_acc", accounting(proc (x: float): string = formatNumber(x))
      fmt "percent_acc", accounting(proc (x: float): string = formatPercent(x))
      fmt "integer_acc", accounting(proc (x: float): string = formatInteger(x))
      fmtCurrency "currency_acc", accounting = true
      tabSpanner "default formatting", positions(1, 2, 3, 4)
      tabSpanner "with accounting notation", positions(5, 6, 7, 8)
      colsLabel:
        number_acc: "number"
        integer_acc: "integer"
        currency_acc: "currency"
        percent_acc: "percent"
    nbTable acc

tabelline """
Only `fmtCurrency` has `accounting` in tabelline. For the other three, the table writes a small
format that puts a negative value in parentheses and gives it `fmt`, with tabelline's
`formatNumber`, `formatPercent` and `formatInteger`. `positions` counts the columns of the data
from 0, the stub included, as `columns=[1, 2, 3, 4]` does.
"""

nbText: """
For the formatting in the final four columns, we use `accounting=True` to get the values into accounting notation. This is only apparent for the negative values (first row) as the positive values won't change their appearance, looking the same as they do when `accounting=False` (the default).

### Acknowledgements and how to contact us

We are *very* grateful for the work that [Jerry Wu](https://github.com/jrycw) has done during this release, some of which includes:

- enhancing the `fmt_image()` to support `http`/`https` schema in the `columns=` parameter, and writing an [incredible blog post](https://posit-dev.github.io/great-tables/blog/rendering-images/) about incorporating images in your tables
- improving the `save()` method, giving it the ability to perform intermediate saves (since the method returns itself)
- adding the `pipe()` method, which operates similarly to that of the Pandas and Polars APIs
- all sorts of little QoL fixes

We extend our gratitude also to [Alessandro Molina](https://github.com/amol-) for adding experimental support for `pyarrow.Table` inputs in this release.

Finally, we thank [Luke Manley](https://github.com/lukemanley) and [Guillaume Lemaitre](https://github.com/glemaitre) for their first contributions to the project!

We're always happy to get feedback. There are three good ways to talk to us:

1. [GitHub Issues](https://github.com/posit-dev/great-tables/issues)
2. [GitHub Discussions](https://github.com/posit-dev/great-tables/discussions)
3. [Discord](https://discord.com/invite/Ux7nrcXHVV)

Don't be shy. We love talking tables (and how we can make them better)!
"""

bookSave()
