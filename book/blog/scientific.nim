import tabbook
bookInit()

nbText: "# Great Tables for Scientific Publishing"

attribution gtBlog("Great Tables for Scientific Publishing", "tables-for-scientific-publishing/",
  "Rich Iannone", "8 Jul 2024",
  "The post's callout on the SciPy 2024 talk is a quoted paragraph.")

nbText: """
**Great Tables** version `0.10.0` has be released today and it contains a host of new features to support tables meant for scientific publishing.

In this post, we'll review the big pieces that scientific tables need:

* **Unit notation**: rendering units and chemical formulas (e.g., °C or C<sub>6</sub>H<sub>6</sub>).
* **Scientific notation**: formatting for very large and small numbers (e.g., 3.50 × 10<sup>−11</sup>)
* **Nanoplots**: compact visualizations for revealing trends.

We've added **six new datasets**, to help quickly show off scientific publishing! We'll use the new `reactions` and `gibraltar` datasets to create examples in the fields of Atmospheric Chemistry and Meteorology, respectively.

> **Rich presented on this topic at SciPy 2024!**
>
> At SciPy 2024 (on July 11, 2024), Rich delivered a talk called *Great Tables for Everyone* and it presented some of the tables shown in this post. If you weren't in attendance that's okay, you can [watch the recorded talk](https://youtu.be/uvH-Z39ZUj0?si=3NVipMteXaeO3vb1) and the materials are available [in GitHub](https://github.com/rich-iannone/presentations/tree/main/2024-07-11-SciPy-talk-GT).

## Unit and scientific notation

We added the `reactions` dataset to serve as the basis for examples in the discipline of Atmospheric Chemistry. The dataset contains reaction rate constants for gas-phase reactions of 1,683 organic compounds. Each of these compounds can potentially undergo reaction with hydroxyl radicals (OH), nitrate radicals (NO<sub>3</sub>), or chlorine atoms (Cl). These reaction rate constants are typically very small values in units of cm<sup>3</sup> molecules<sup>–1</sup> s<sup>–1</sup>. In the upcoming example, we'll pare down this massive dataset to only 11 rows representing the class of organic compounds known as mercaptans.

To make this table work well in a scientific reporting context, we need three pieces:

* way to represent units, like cm<sup>3</sup>
* method for typesetting chemical formulae, as in CH<sub>4</sub>
* formatting for very small numbers in scientific notation.

**Great Tables** provides the necessary functionality for all three requirements. Here is a summary table that tabulates rate constants for mercaptan compounds undergoing reaction with OH, O<sub>3</sub>, and Cl:
"""

tabs """
from great_tables import GT
from great_tables.data import reactions
import polars as pl
import polars.selectors as ps

reactions_mini = (
    pl.from_pandas(reactions)
    .filter(pl.col("cmpd_type") == "mercaptan")
    .select([
        "cmpd_name",
        "cmpd_formula",
        ps.ends_with("k298")
    ])
    .with_columns(
        cmpd_formula=pl.concat_str(
            "%" + pl.col("cmpd_formula") + "%"
        )
    )
)

(
    GT(reactions_mini, rowname_col="cmpd_name")
    .tab_header(title="Gas-phase reactions of selected mercaptan compounds")
    .tab_spanner(
        columns=ps.ends_with("k298"),
        label="Reaction Rate Constant (298 K),<br>{{cm^3 molecules^–1 s^–1}}"
    )
    .fmt_units(columns="cmpd_formula")
    .fmt_scientific(columns=ps.ends_with("k298"))
    .sub_missing()
    .cols_hide(columns="O3_k298")
    .cols_label(
        cmpd_formula="",
        OH_k298="OH",
        NO3_k298="{{%NO3%}}",
        Cl_k298="Cl",
    )
    .opt_stylize(style=1, color="blue")
    .opt_horizontal_padding(scale=3)
    .opt_table_font(stack="humanist")
)
""", """
library(gt)
library(dplyr)

reactions_mini <-
  reactions |>
  filter(cmpd_type == "mercaptan") |>
  select(cmpd_name, cmpd_formula, ends_with("k298")) |>
  mutate(cmpd_formula = paste0("%", cmpd_formula, "%"))

reactions_mini |>
  gt(rowname_col = "cmpd_name") |>
  tab_header(title = "Gas-phase reactions of selected mercaptan compounds") |>
  tab_spanner(
    columns = ends_with("k298"),
    label = md("Reaction Rate Constant (298 K),<br>{{cm^3 molecules^–1 s^–1}}")
  ) |>
  fmt_units(columns = cmpd_formula) |>
  fmt_scientific(columns = ends_with("k298")) |>
  sub_missing() |>
  cols_hide(columns = O3_k298) |>
  cols_label(
    cmpd_formula = "",
    OH_k298 = "OH",
    NO3_k298 = "{{%NO3%}}",
    Cl_k298 = "Cl"
  ) |>
  opt_stylize(style = 1, color = "blue") |>
  opt_horizontal_padding(scale = 3) |>
  opt_table_font(stack = "humanist")
""":
  nbCode:
    import std/streams
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    let reactions = readCsv(newStringStream(reactionsCsv), inferSchemaLength = 10_000)
    let reactionsMini = reactions
      .filter(col("cmpd_type") == "mercaptan")
      .select(col("cmpd_name"), col("cmpd_formula"), col("^.*k298$"))
      .withColumns(concatStr([lit("%"), col("cmpd_formula"), lit("%")]).alias("cmpd_formula"))

    let mercaptans = tabella(reactionsMini, rownameCol = "cmpd_name"):
      tabHeader title = "Gas-phase reactions of selected mercaptan compounds"
      tabSpanner md("Reaction Rate Constant (298 K),\\\n{{cm^3 molecules^–1 s^–1}}"),
        endsWith("k298")
      fmtUnits "cmpd_formula"
      fmtScientific endsWith("k298")
      subMissing()
      colsHide "O3_k298"
      colsLabel:
        cmpd_formula: ""
        OH_k298: "OH"
        NO3_k298: "{{%NO3%}}"
        Cl_k298: "Cl"
      optStylize style = 1, color = "blue"
      optHorizontalPadding 3
      optTableFont systemFonts("humanist")
    nbTable mercaptans

tabelline """
The line break in the spanner is Markdown's (a backslash at the end of the line), where Great
Tables takes `<br>`; units between `{{` and `}}` work in a Markdown label too. A column whose name
ends in `k298` is `col("^.*k298$")` for nanuq, a regular expression as in Polars, and
`endsWith("k298")` for tabelline. `optTableFont` takes the stack itself:
`systemFonts("humanist")` is `stack="humanist"`.
"""

nbText: """
This is a nice-looking table! And note these pieces:

* The `label=` argument to functions like `.tab_spanner()` supports the use of curly braces (`{{`/`}}`) for the specialized units notation. So using `"{{cm^3 molecules^–1 s^–1}}"` in the input will become cm<sup>3</sup> molecules<sup>–1</sup> s<sup>–1</sup> in the output
* The `.fmt_units()` method converts values that are already in units notation in the table body. For example, a cell with text `"%CH4S%"` becomes CH<sub>4</sub>S (the surrounding `%` indicates that the text should be interpreted as chemistry notation).
* The `.fmt_scientific()` method formats values (in this case, very small values) to scientific notation (e.g., 3.50 × 10<sup>–11</sup>). Not doing so would make the table look very strange to a researcher that is familiar with this sort of data.

The combination of units notation (and chemistry notation, which is a part of that) really makes the presentation of this table complete and understandable to a practitioner of the field. **Great Tables** supports the use of units notation in spanner labels (with `.tab_spanner()`) and also in column labels (with `.cols_labels()`). The column label 'NO<sub>3</sub>' was created with the latter method by supplying the text `"{{%NO3%}}"` as the column label for the `NO3_k298` column.

## Nanoplots

We added the nanoplots feature to **Great Tables** in v0.4.0 (check out the [intro blog post](v0_4.html) for a quick explainer) so that tables can contain small, info-packed plots that fit reasonably well into a table context. They are interactive in that hovering over the data points provides additional plot information. This approach brings together the advantages of plots (elucidation of trends in data) and tables (access to numerical values representing the data points) in a single summary visualization.

Version `0.10.0` of **Great Tables** adds the `gibraltar` dataset, which provides meteorological data (temeperature, humidity, wind speed, etc.) for the entire month of May 2024 at Gibraltar Airport Station.

Nanoplots, as mentioned, are great for condensing a lot of information into a small area. Our example here with the `gibraltar` dataset takes all of the temperature and humidity data for the first 10 days of May 2023 and displays them in easy-to-explore nanoplots across two columns:
"""

tabs """
from great_tables import GT, nanoplot_options
from great_tables.data import gibraltar
import polars as pl

nano_opts = nanoplot_options(
    data_point_radius=4,
    data_point_stroke_width=4,
    data_point_stroke_color="black",
    data_point_fill_color="white",
    data_line_stroke_width=4,
    data_line_stroke_color="gray",
    show_data_line=True,
    show_data_points=True,
    show_data_area=False,
  )

gibraltar_mini = (
    pl.from_pandas(gibraltar)
    .filter(pl.col("date") <= "2023-05-10")
    .with_columns(pl.col("humidity") * 100)
    .select(["date", "temp", "humidity"])
    .group_by("date")
    .agg(pl.col("temp"), pl.col("humidity"))
    .sort("date")
)

(
  GT(gibraltar_mini)
  .tab_header(
    title="Meteorological Summary of Gibraltar Station",
    subtitle="Data taken from May 1-10, 2023."
  )
  .fmt_nanoplot(
    columns="temp", autoscale=True, options=nano_opts
  )
  .fmt_nanoplot(
    columns="humidity", autoscale=True, options=nano_opts
  )
  .fmt_date(
    columns="date",
    date_style="wd_m_day_year"
  )
  .cols_label(
    date="Date",
    temp="Temperature, {{:degree:C}}",
    humidity="Humidity, % (RH)",
  )
  .cols_align(
    align="left",
    columns=["temp", "humidity"]
  )
)
""", """
nano_opts <-
  nanoplot_options(
    data_point_radius = 4,
    data_point_stroke_width = 4,
    data_point_stroke_color = "black",
    data_point_fill_color = "white",
    data_line_stroke_width = 4,
    data_line_stroke_color = "gray",
    show_data_line = TRUE,
    show_data_points = TRUE,
    show_data_area = FALSE
  )

# gt has no fmt_nanoplot(): cols_nanoplot() makes a plot from columns, one value in each
gibraltar_mini <-
  gibraltar |>
  filter(date <= "2023-05-10") |>
  mutate(humidity = humidity * 100) |>
  group_by(date) |>
  mutate(i = row_number()) |>
  ungroup() |>
  select(date, i, temp, humidity) |>
  tidyr::pivot_wider(names_from = i, values_from = c(temp, humidity)) |>
  arrange(date)

gibraltar_mini |>
  gt() |>
  tab_header(
    title = "Meteorological Summary of Gibraltar Station",
    subtitle = "Data taken from May 1-10, 2023."
  ) |>
  cols_nanoplot(
    columns = starts_with("temp_"), new_col_name = "temp", autoscale = TRUE,
    options = nano_opts
  ) |>
  cols_nanoplot(
    columns = starts_with("humidity_"), new_col_name = "humidity", autoscale = TRUE,
    options = nano_opts
  ) |>
  fmt_date(columns = date, date_style = "wd_m_day_year") |>
  cols_label(
    date = "Date",
    temp = "Temperature, {{:degree:C}}",
    humidity = "Humidity, % (RH)"
  ) |>
  cols_align(align = "left", columns = c(temp, humidity))
""":
  nbCode:
    let nanoOpts = nanoplotOptions(
      dataPointRadius = 4,
      dataPointStrokeWidth = 4,
      dataPointStrokeColor = "black",
      dataPointFillColor = "white",
      dataLineStrokeWidth = 4,
      dataLineStrokeColor = "gray",
      showDataLine = true,
      showDataPoints = true,
      showDataArea = false)

    let gibraltar = readCsv(newStringStream(gibraltarCsv), inferSchemaLength = 10_000)
    let gibraltarMini = gibraltar
      .filter(col("date") <= "2023-05-10")
      .withColumns(col("humidity") * 100)
      .select("date", "temp", "humidity")
      .groupBy("date", maintainOrder = true)
      .agg(col("temp").`cast`(String).str.join(" "),
           col("humidity").`cast`(String).str.join(" "))
      .sort("date")

    let station = tabella(gibraltarMini):
      tabHeader title = "Meteorological Summary of Gibraltar Station",
        subtitle = "Data taken from May 1-10, 2023."
      fmtNanoplot "temp", autoscale = true, options = nanoOpts
      fmtNanoplot "humidity", autoscale = true, options = nanoOpts
      fmtDate "date", dateStyle = "wd_m_day_year"
      colsLabel:
        date: "Date"
        temp: "Temperature, {{:degree:C}}"
        humidity: "Humidity, % (RH)"
      colsAlign alLeft, ["temp", "humidity"]
    nbTable station

tabelline """
A nanoplot takes its values as a list or as numbers in a text, separated by spaces: the day's
temperatures are joined in a text (`str.join(" ")`), where Polars keeps them as a list column,
which nanuq gives tabelline as the text Polars writes for it. gt has no `fmt_nanoplot()`: the R
tab spreads each day's values over columns and gives them to `cols_nanoplot()`.
"""

nbText: """
Once we have the data aggregated in the form of list columns, the `.fmt_nanoplot()` method shows us the trends of temperature and relative humidity values throughout the day (from `00:00` to `24:00`). One interesting observation that can be made from the table is that on May 9, 2023 there was a late-day temperature increase that coincided with a corresponding decrease in relative humidity. Making such an observation without nanoplots would be quite a bit more difficult and would require some serious determination, necessitating a careful scanning of numbers across a row cells.

Units notation is ever useful and it is applied in one of the column labels of this table. It could potentially be difficult to format even simple things like the units of temperature. In this case we wanted to add in the temperature units of °C for the `temperature` column. Units notation has a collection of symbols available, including `":degree:"` (colons encapsulate the collection of symbol keywords), for insertion within units notation text. The example takes advantage of the available symbols and so having °C as part of a label is not too hard to express.

## Hope all your (science-y) tables are great!

We did scientific work pretty heavily in the past and so we understand that great tables in the realm of science publication is something that could and should be possible. We'll keep doing more to make this even better in upcoming releases.
"""

bookSave()
