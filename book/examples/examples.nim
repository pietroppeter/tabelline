import tabbook
bookInit()

nbText: "# Examples"

attribution gtExample("Examples", "https://posit-dev.github.io/great-tables/examples/",
  "The examples are shown one after the other, with their code, where the original sets them " &
  "in a grid with the code folded; the data files are read from the book's folder; the Sports " &
  "earnings example has a page of its own, next, and the gt-extras example comes with the other " &
  "gt-extras pages.")

nbText: """
These are the tables of the Great Tables Examples page, from a small table of the largest
landmasses to a year of sales of coffee equipment with icons and bar plots.
"""

tabs """
import polars as pl
from great_tables import GT, md, html
from great_tables.data import islands

islands_mini = (
    pl.from_pandas(islands).sort("size", descending=True)
    .head(10)
)

(
    GT(islands_mini)
    .tab_header(
        title="Large Landmasses of the World",
        subtitle="The top ten largest are presented"
    )
    .tab_stub(rowname_col="name")
    .tab_source_note(source_note="Source: The World Almanac and Book of Facts, 1975, page 406.")
    .tab_source_note(
        source_note=md("Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley.")
    )
    .tab_stubhead(label="landmass")
    .fmt_integer(columns="size")
)
""", """
library(gt)
library(dplyr)
library(tidyr)

islands_mini <-
  tibble(name = names(islands), size = islands) |>
  arrange(desc(size)) |>
  slice_head(n = 10)

islands_mini |>
  gt(rowname_col = "name") |>
  tab_header(
    title = "Large Landmasses of the World",
    subtitle = "The top ten largest are presented"
  ) |>
  tab_source_note(source_note = "Source: The World Almanac and Book of Facts, 1975, page 406.") |>
  tab_source_note(
    source_note = md("Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley.")
  ) |>
  tab_stubhead(label = "landmass") |>
  fmt_integer(columns = size)
""":
  nbCode:
    import std/streams
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    let islandsMini = readCsv(newStringStream(islandsCsv))
      .sort("size", descending = true)
      .head(10)

    let islandsTbl = tabella(islandsMini, rownameCol = "name"):
      tabHeader "Large Landmasses of the World", "The top ten largest are presented"
      tabSourceNote "Source: The World Almanac and Book of Facts, 1975, page 406."
      tabSourceNote md"Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley."
      tabStubhead "landmass"
      fmtInteger "size"
    nbTable islandsTbl

tabelline """
The data steps are written with [nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim,
as the examples write them with Polars; `import tabelline/nanuq` lets `tabella` take its data
frames. tabelline has no `tabStub`: the stub is named when the table is made, with `rownameCol`
(and `groupnameCol`), as in gt.
"""

tabs """
from great_tables import GT, html
from great_tables.data import airquality

airquality_mini = airquality.head(10).assign(Year = 1973)

(
    GT(airquality_mini)
    .tab_header(
        title="New York Air Quality Measurements",
        subtitle="Daily measurements in New York City (May 1-10, 1973)"
    )
    .tab_spanner(
        label="Time",
        columns=["Year", "Month", "Day"]
    )
    .tab_spanner(
        label="Measurement",
        columns=["Ozone", "Solar_R", "Wind", "Temp"]
    )
    .cols_move_to_start(columns=["Year", "Month", "Day"])
    .cols_label(
        Ozone = html("Ozone,<br>ppbV"),
        Solar_R = html("Solar R.,<br>cal/m<sup>2</sup>"),
        Wind = html("Wind,<br>mph"),
        Temp = html("Temp,<br>&deg;F")
    )
)
""", """
airquality_mini <- airquality |> head(10) |> mutate(Year = 1973L)

airquality_mini |>
  gt() |>
  tab_header(
    title = "New York Air Quality Measurements",
    subtitle = "Daily measurements in New York City (May 1-10, 1973)"
  ) |>
  tab_spanner(
    label = "Time",
    columns = c(Year, Month, Day)
  ) |>
  tab_spanner(
    label = "Measurement",
    columns = c(Ozone, Solar.R, Wind, Temp)
  ) |>
  cols_move_to_start(columns = c(Year, Month, Day)) |>
  cols_label(
    Ozone = html("Ozone,<br>ppbV"),
    Solar.R = html("Solar R.,<br>cal/m<sup>2</sup>"),
    Wind = html("Wind,<br>mph"),
    Temp = html("Temp,<br>&deg;F")
  )
""":
  nbCode:
    let airqualityMini = readCsv(newStringStream(airqualityCsv), inferSchemaLength = 10_000)
      .head(10)
      .withColumns(lit(1973).alias("Year"))

    let airqualityTbl = tabella(airqualityMini):
      tabHeader "New York Air Quality Measurements",
        "Daily measurements in New York City (May 1-10, 1973)"
      tabSpanner "Time", ["Year", "Month", "Day"]
      tabSpanner "Measurement", ["Ozone", "Solar_R", "Wind", "Temp"]
      colsMoveToStart ["Year", "Month", "Day"]
      colsLabel:
        Ozone: html"Ozone,<br>ppbV"
        Solar_R: html"Solar R.,<br>cal/m<sup>2</sup>"
        Wind: html"Wind,<br>mph"
        Temp: html"Temp,<br>&deg;F"
    nbTable airqualityTbl

tabs """
from great_tables import GT
from great_tables.data import countrypops
import polars as pl
import polars.selectors as cs

# Get vectors of 2-letter country codes for each region of Oceania
oceania = {
    "Australasia": ["AU", "NZ"],
    "Melanesia": ["NC", "PG", "SB", "VU"],
    "Micronesia": ["FM", "GU", "KI", "MH", "MP", "NR", "PW"],
    "Polynesia": ["PF", "WS", "TO", "TV"],
}

# Create a dictionary mapping country to region (e.g. AU -> Australasia)
country_to_region = {
    country: region for region, countries in oceania.items() for country in countries
}

wide_pops = (
    pl.from_pandas(countrypops)
    .filter(
        pl.col("country_code_2").is_in(list(country_to_region))
        & pl.col("year").is_in([2000, 2010, 2020])
    )
    .with_columns(pl.col("country_code_2").replace(country_to_region).alias("region"))
    .pivot(index=["country_name", "region"], on="year", values="population")
    .sort("2020", descending=True)
)

(
    GT(wide_pops)
    .tab_header(title="Populations of Oceania's Countries in 2000, 2010, and 2020")
    .tab_spanner(label="Total Population", columns=cs.all())
    .tab_stub(rowname_col="country_name", groupname_col="region")
    .fmt_integer()
)
""", """
# Get vectors of 2-letter country codes for each region of Oceania
oceania <- list(
  Australasia = c("AU", "NZ"),
  Melanesia = c("NC", "PG", "SB", "VU"),
  Micronesia = c("FM", "GU", "KI", "MH", "MP", "NR", "PW"),
  Polynesia = c("PF", "WS", "TO", "TV")
)

# A named vector mapping country to region (e.g. AU -> Australasia)
country_to_region <- setNames(rep(names(oceania), lengths(oceania)), unlist(oceania))

wide_pops <-
  countrypops |>
  filter(country_code_2 %in% names(country_to_region), year %in% c(2000, 2010, 2020)) |>
  mutate(region = country_to_region[country_code_2]) |>
  select(country_name, region, year, population) |>
  pivot_wider(names_from = year, values_from = population) |>
  arrange(desc(`2020`))

wide_pops |>
  gt(rowname_col = "country_name", groupname_col = "region") |>
  tab_header(title = "Populations of Oceania's Countries in 2000, 2010, and 2020") |>
  tab_spanner(label = "Total Population", columns = everything()) |>
  fmt_integer()
""":
  nbCode:
    import std/[sequtils, tables]

    # Get lists of 2-letter country codes for each region of Oceania
    let oceania = {
      "Australasia": @["AU", "NZ"],
      "Melanesia": @["NC", "PG", "SB", "VU"],
      "Micronesia": @["FM", "GU", "KI", "MH", "MP", "NR", "PW"],
      "Polynesia": @["PF", "WS", "TO", "TV"]}.toOrderedTable

    # Create a table mapping country to region (e.g. AU -> Australasia)
    var countryToRegion = initOrderedTable[string, string]()
    for region, countries in oceania:
      for country in countries: countryToRegion[country] = region

    var codes: seq[string]
    for country in countryToRegion.keys: codes.add country

    let widePops = readCsv(newStringStream(countrypopsCsv), inferSchemaLength = 10_000)
      .filter(col("country_code_2").isIn(codes) and col("year").isIn([2000, 2010, 2020]))
      .withColumns(col("country_code_2").replace(countryToRegion.pairs.toSeq).alias("region"))
      .pivot(index = ["country_name", "region"], on = "year", values = "population")
      .sort("2020", descending = true)

    let widePopsTbl = tabella(widePops, rownameCol = "country_name", groupnameCol = "region"):
      tabHeader "Populations of Oceania's Countries in 2000, 2010, and 2020"
      tabSpanner "Total Population", everything()
      fmtInteger()
    nbTable widePopsTbl

tabs """
from great_tables import GT, html
from great_tables.data import towny

towny_mini = (
    towny[["name", "website", "density_2021", "land_area_km2", "latitude", "longitude"]]
    .sort_values("density_2021", ascending=False)
    .head(10)
)

towny_mini["url_name"] = "[" + towny_mini["name"] + "](" + towny_mini["website"] + ")"

towny_mini["location"] = (
    "[map](http://maps.google.com/?ie=UTF8&hq=&ll="
    + towny_mini["latitude"].astype(str)
    + ","
    + towny_mini["longitude"].astype(str)
    + "&z=13)"
)

(
    GT(
        towny_mini[["url_name", "location", "land_area_km2", "density_2021"]],
        rowname_col="url_name",
    )
    .tab_header(
        title="The Municipalities of Ontario",
        subtitle="The top 10 highest population density in 2021",
    )
    .tab_stubhead(label="Municipality")
    .fmt_markdown(columns=["url_name", "location"])
    .fmt_number(columns=["land_area_km2", "density_2021"], decimals=1)
    .cols_label(
        land_area_km2=html("land area, <br>km<sup>2</sup>"),
        density_2021=html("density, <br>people/km<sup>2</sup>"),
    )
)
""", """
towny_mini <-
  towny |>
  select(name, website, density_2021, land_area_km2, latitude, longitude) |>
  arrange(desc(density_2021)) |>
  slice_head(n = 10) |>
  mutate(
    url_name = paste0("[", name, "](", website, ")"),
    location = paste0(
      "[map](http://maps.google.com/?ie=UTF8&hq=&ll=",
      latitude, ",", longitude, "&z=13)"
    )
  )

towny_mini |>
  select(url_name, location, land_area_km2, density_2021) |>
  gt(rowname_col = "url_name") |>
  tab_header(
    title = "The Municipalities of Ontario",
    subtitle = "The top 10 highest population density in 2021"
  ) |>
  tab_stubhead(label = "Municipality") |>
  fmt_markdown(columns = c(url_name, location)) |>
  fmt_number(columns = c(land_area_km2, density_2021), decimals = 1) |>
  cols_label(
    land_area_km2 = html("land area, <br>km<sup>2</sup>"),
    density_2021 = html("density, <br>people/km<sup>2</sup>")
  )
""":
  nbCode:
    let townyMini = readCsv(newStringStream(townyCsv), inferSchemaLength = 10_000)
      .select("name", "website", "density_2021", "land_area_km2", "latitude", "longitude")
      .sort("density_2021", descending = true)
      .head(10)
      .withColumns(
        concatStr([lit("["), col("name"), lit("]("), col("website"), lit(")")]).alias("url_name"),
        concatStr([lit("[map](http://maps.google.com/?ie=UTF8&hq=&ll="),
                   col("latitude").`cast`(String), lit(","), col("longitude").`cast`(String),
                   lit("&z=13)")]).alias("location"))
      .select("url_name", "location", "land_area_km2", "density_2021")

    let townyTbl = tabella(townyMini, rownameCol = "url_name"):
      tabHeader "The Municipalities of Ontario", "The top 10 highest population density in 2021"
      tabStubhead "Municipality"
      fmtMarkdown ["url_name", "location"]
      fmtNumber ["land_area_km2", "density_2021"], decimals = 1
      colsLabel:
        land_area_km2: html"land area, <br>km<sup>2</sup>"
        density_2021: html"density, <br>people/km<sup>2</sup>"
    nbTable townyTbl

tabs """
from great_tables import GT, html
from great_tables.data import sza
import polars as pl
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
    .sub_missing(missing_text="")
)
""", """
sza_pivot <-
  sza |>
  filter(latitude == 20, tst <= "1200") |>
  select(-latitude) |>
  drop_na() |>
  pivot_wider(names_from = tst, values_from = sza, names_sort = TRUE)

sza_pivot |>
  gt(rowname_col = "month") |>
  data_color(
    domain = c(0, 90),
    palette = c("orange", "white", "#663399"),  # R has no rebeccapurple
    na_color = "white"
  ) |>
  tab_header(
    title = "Solar Zenith Angles from 05:30 to 12:00",
    subtitle = html("Average monthly values at latitude of 20&deg;N.")
  ) |>
  sub_missing(missing_text = "")
""":
  nbCode:
    let szaPivot = readCsv(newStringStream(szaCsv), inferSchemaLength = 0)  # every column as text
      .filter(col("latitude") == "20" and col("tst") <= lit("1200"))
      .drop("latitude")
      .dropNulls()
      .withColumns(col("sza").`cast`(Float64))
      .pivot(values = "sza", index = "month", on = "tst", sortColumns = true)

    let szaTbl = tabella(szaPivot, rownameCol = "month"):
      dataColor domain = (90.0, 0.0), palette = @["rebeccapurple", "white", "orange"],
        naColor = "white"
      tabHeader "Solar Zenith Angles from 05:30 to 12:00",
        html"Average monthly values at latitude of 20&deg;N."
      subMissing(missingText = "")
    nbTable szaTbl

tabelline """
gt's `data_color()` wants its domain from low to high, so the R tab turns the palette around
instead: 0° (the sun overhead) is orange, 90° (the sun on the horizon) purple, as in Python and
Nim, where the domain may run from high to low. R's colour names are not CSS's, and
`rebeccapurple` is CSS only: the R tab writes it as `#663399`.
"""

nbText: """
The Sports earnings example, the highest paid athletes of 2023, has [a page of its
own](sports_earnings.html).

The next example is the carbon intensity of electricity consumption, by Grant Chalmers
([source](https://gist.github.com/chalg/93ca29e202ab86e7d4caad44726372e4/d17c1b4ba608ae1c3df6ac7fc377065ae5708ba7),
[blog post with the R code](https://chalg.quarto.pub/carbon-intensity-of-electricity-consumption/)).
"""

tabs """
import warnings
from great_tables import GT, md, html, system_fonts
import pandas as pd

warnings.filterwarnings("ignore")
power_cie_prepared_tbl = pd.read_csv("../data/great-tables/examples/power_cie_prepared_tbl.csv")


# Create a Great Tables object
ciep_gt_tbl = GT(data=power_cie_prepared_tbl)

# Apply wider color ranges & formatting

gt_tbl = (
    ciep_gt_tbl.fmt_percent(
        columns=[
            "Hydro",
            "Nuclear",
            "Wind",
            "Solar",
            "Geothermal",
            "Biomass",
            "Gas",
            "Coal",
            "Oil",
            "Unknown",
            "Hydro Discharge",
            "Battery Discharge",
        ],
        decimals=1,
    )
    .fmt_number(columns=["CO2 Intensity"], decimals=0)
    .data_color(
        columns=["CO2 Intensity"],
        palette=[
            "#00A600",
            "#E6E600",
            "#E8C32E",
            "#D69C4E",
            "#Dc863B",
            "sienna",
            "sienna4",
            "tomato4",
            "brown",
        ],
        domain=[0, 900],
    )
    .data_color(
        columns=["Hydro", "Nuclear", "Wind", "Solar", "Geothermal"],
        palette=["#00A600", "chartreuse3", "chartreuse4", "snow"][::-1],
        domain=[0, 1],
    )
    .data_color(
        columns=["Hydro", "Geothermal"],
        palette=["#00A600", "chartreuse3", "chartreuse4", "snow"][::-1],
        domain=[0, 1],
    )
    .data_color(
        columns=["Biomass"], palette=["snow", "#EEC900", "#E8C32E", "#D69C4E"], domain=[0, 0.3]
    )
    .data_color(
        columns=["Gas", "Coal", "Oil"],
        palette=["tomato4", "sienna4", "#D69C4E", "#Dc863B", "snow"][::-1],
        domain=[0, 1],
    )
    .data_color(
        columns=["Zone", "Unknown", "Hydro Discharge", "Battery Discharge"],
        palette=["snow", "snow", "snow", "snow"],
    )
    .cols_width(
        {
            "CO2 Intensity": "58px",
            "Hydro": "58px",
            "Nuclear": "58px",
            "Wind": "58px",
            "Solar": "58px",
            "Geothermal": "58px",
            "Biomass": "58px",
            "Gas": "58px",
            "Coal": "58px",
            "Oil": "58px",
            "Unknown": "58px",
            "Hydro Discharge": "58px",
            "Battery Discharge": "58px",
        }
    )
    .tab_header(
        title=md(
            "2023 Mean **Carbon Intensity** (gCO2eq/kWh) and **Power Consumption** Breakdown (%)"
        )
    )
    .tab_source_note(
        md(
            '<br><div style="text-align: left;">'
            "**Source**: api.electricitymap.org"
            " | **Methodology**: https://www.electricitymaps.com/methodology."
            " Some emissions factors are based on IPCC 2014 defaults, while some are based on more accurate regional factors."
            " <br>All zones are publicly available on the *Carbon intensity and emission factors* tab via Google docs link<br>"
            "</div>"
            "<br>"
        )
    )
    .tab_options(
        source_notes_font_size="x-small",
        source_notes_padding=3,
        table_font_names=system_fonts("humanist"),
        data_row_padding="1px",
        heading_background_color="antiquewhite",
        source_notes_background_color="antiquewhite",
        column_labels_background_color="antiquewhite",
        table_background_color="snow",
        data_row_padding_horizontal=3,
        column_labels_padding_horizontal=58,
    )
    .cols_align(align="center")
    .cols_align(align="left", columns=["Zone"])
    .opt_table_outline()
)

gt_tbl
""", """
power_cie_prepared_tbl <- read.csv(
  "../data/great-tables/examples/power_cie_prepared_tbl.csv",
  check.names = FALSE
)

shares <- c(
  "Hydro", "Nuclear", "Wind", "Solar", "Geothermal", "Biomass", "Gas", "Coal",
  "Oil", "Unknown", "Hydro Discharge", "Battery Discharge"
)

power_cie_prepared_tbl |>
  gt() |>
  fmt_percent(columns = all_of(shares), decimals = 1) |>
  fmt_number(columns = "CO2 Intensity", decimals = 0) |>
  data_color(
    columns = "CO2 Intensity",
    palette = c(
      "#00A600", "#E6E600", "#E8C32E", "#D69C4E", "#Dc863B",
      "sienna", "sienna4", "tomato4", "brown"
    ),
    domain = c(0, 900)
  ) |>
  data_color(
    columns = c(Hydro, Nuclear, Wind, Solar, Geothermal),
    palette = rev(c("#00A600", "chartreuse3", "chartreuse4", "snow")),
    domain = c(0, 1)
  ) |>
  data_color(
    columns = Biomass,
    palette = c("snow", "#EEC900", "#E8C32E", "#D69C4E"),
    domain = c(0, 0.3)
  ) |>
  data_color(
    columns = c(Gas, Coal, Oil),
    palette = rev(c("tomato4", "sienna4", "#D69C4E", "#Dc863B", "snow")),
    domain = c(0, 1)
  ) |>
  data_color(
    columns = c(Zone, Unknown, `Hydro Discharge`, `Battery Discharge`),
    palette = c("snow", "snow", "snow", "snow")
  ) |>
  cols_width(-Zone ~ px(58)) |>
  tab_header(
    title = md("2023 Mean **Carbon Intensity** (gCO2eq/kWh) and **Power Consumption** Breakdown (%)")
  ) |>
  tab_source_note(
    md(paste0(
      '<br><div style="text-align: left;">',
      "**Source**: api.electricitymap.org",
      " | **Methodology**: https://www.electricitymaps.com/methodology.",
      " Some emissions factors are based on IPCC 2014 defaults, while some are based on more accurate regional factors.",
      " <br>All zones are publicly available on the *Carbon intensity and emission factors* tab via Google docs link<br>",
      "</div>",
      "<br>"
    ))
  ) |>
  opt_table_font(stack = "humanist") |>
  tab_options(
    source_notes.font.size = "x-small",
    source_notes.padding = px(3),
    data_row.padding = px(1),
    heading.background.color = "antiquewhite",
    source_notes.background.color = "antiquewhite",
    column_labels.background.color = "antiquewhite",
    table.background.color = "snow",
    data_row.padding.horizontal = px(3),
    column_labels.padding.horizontal = px(58)
  ) |>
  cols_align(align = "center") |>
  cols_align(align = "left", columns = Zone) |>
  opt_table_outline()
""":
  nbCode:
    let powerCie = readCsv(newStringStream(powerCieCsv), inferSchemaLength = 10_000)

    let widths = powerCie.columns[1 .. ^1].mapIt((it, "58px"))  # every column but Zone
    let shares = ["Hydro", "Nuclear", "Wind", "Solar", "Geothermal", "Biomass", "Gas", "Coal",
                  "Oil", "Unknown", "Hydro Discharge", "Battery Discharge"]

    # R's numbered colour names, which CSS does not have
    const
      sienna4 = "#8B4726"
      tomato4 = "#8B3626"
      chartreuse3 = "#66CD00"
      chartreuse4 = "#458B00"

    let powerTbl = tabella(powerCie):
      fmtPercent shares, decimals = 1
      fmtNumber "CO2 Intensity", decimals = 0
      dataColor "CO2 Intensity", domain = (0.0, 900.0), palette = @["#00A600", "#E6E600",
        "#E8C32E", "#D69C4E", "#Dc863B", "sienna", sienna4, tomato4, "brown"]
      dataColor ["Hydro", "Nuclear", "Wind", "Solar", "Geothermal"], domain = (0.0, 1.0),
        palette = @["snow", chartreuse4, chartreuse3, "#00A600"]
      dataColor "Biomass", domain = (0.0, 0.3), palette = @["snow", "#EEC900", "#E8C32E", "#D69C4E"]
      dataColor ["Gas", "Coal", "Oil"], domain = (0.0, 1.0),
        palette = @["snow", "#Dc863B", "#D69C4E", sienna4, tomato4]
      dataColor ["Zone", "Unknown", "Hydro Discharge", "Battery Discharge"],
        palette = @["snow", "snow", "snow", "snow"]
      colsWidth widths
      tabHeader md"2023 Mean **Carbon Intensity** (gCO2eq/kWh) and **Power Consumption** Breakdown (%)"
      tabSourceNote md("**Source**: api.electricitymap.org" &
        " | **Methodology**: https://www.electricitymaps.com/methodology." &
        " Some emissions factors are based on IPCC 2014 defaults, while some are based on more accurate regional factors." &
        "<br>All zones are publicly available on the *Carbon intensity and emission factors* tab via Google docs link")
      optTableFont systemFonts("humanist")
      tabOptions(sourceNotesFontSize = "x-small", sourceNotesPadding = "3px",
                 dataRowPadding = "1px", headingBackgroundColor = "antiquewhite",
                 sourceNotesBackgroundColor = "antiquewhite",
                 columnLabelsBackgroundColor = "antiquewhite", tableBackgroundColor = "snow",
                 dataRowPaddingHorizontal = "3px", columnLabelsPaddingHorizontal = "58px")
      colsAlign alCenter
      colsAlign alLeft, "Zone"
      optTableOutline()
    nbTable powerTbl

tabelline """
CSS names 148 colours, R 657: tabelline knows the CSS ones, so R's numbered shades (`sienna4`,
`chartreuse3`) are written as hex values here. The source note is Markdown with its line breaks
and left alignment left out: the notes of a tabelline table are already aligned to the left.
"""

nbText: """
The last example is a year of sales of coffee equipment, by Michael Chow
([source](https://github.com/machow/coffee-sales-data/),
[notebook](https://github.com/machow/coffee-sales-data/blob/main/example_notebook.ipynb)).
"""

tabs """
import polars as pl
import polars.selectors as cs
from great_tables import GT, loc, style

coffee_sales = pl.read_ndjson("../data/great-tables/examples/coffee-sales.ndjson")

sel_rev = cs.starts_with("revenue")
sel_prof = cs.starts_with("profit")

# yo

coffee_table = (
    GT(coffee_sales)
    .tab_header("Sales of Coffee Equipment")
    .tab_spanner(label="Revenue", columns=sel_rev)
    .tab_spanner(label="Profit", columns=sel_prof)
    .cols_label(
        revenue_dollars="Amount",
        profit_dollars="Amount",
        revenue_pct="Percent",
        profit_pct="Percent",
        monthly_sales="Monthly Sales",
        icon="",
        product="Product",
    )
    # formatting ----
    .fmt_number(
        columns=cs.ends_with("dollars"),
        compact=True,
        pattern="${x}",
        n_sigfig=3,
    )
    .fmt_percent(columns=cs.ends_with("pct"), decimals=0)
    # style ----
    .tab_style(
        style=style.fill(color="aliceblue"),
        locations=loc.body(columns=sel_rev),
    )
    .tab_style(
        style=style.fill(color="papayawhip"),
        locations=loc.body(columns=sel_prof),
    )
    .tab_style(
        style=style.text(weight="bold"),
        locations=loc.body(rows=pl.col("product") == "Total"),
    )
    .fmt_nanoplot("monthly_sales", plot_type="bar")
    .fmt_image("icon", path="../data/great-tables/examples/coffee-table-icons/")
    .sub_missing(missing_text="")
)

coffee_table
""", """
coffee_sales <-
  jsonlite::stream_in(
    file("../data/great-tables/examples/coffee-sales.ndjson"),
    verbose = FALSE
  ) |>
  as_tibble() |>
  unnest_wider(monthly_sales, names_sep = "_")

coffee_sales |>
  gt() |>
  tab_header("Sales of Coffee Equipment") |>
  tab_spanner(label = "Revenue", columns = starts_with("revenue")) |>
  tab_spanner(label = "Profit", columns = starts_with("profit")) |>
  cols_label(
    revenue_dollars = "Amount",
    profit_dollars = "Amount",
    revenue_pct = "Percent",
    profit_pct = "Percent",
    icon = "",
    product = "Product"
  ) |>
  # formatting ----
  fmt_number(
    columns = ends_with("dollars"),
    suffixing = TRUE,
    pattern = "${x}",
    n_sigfig = 3
  ) |>
  fmt_percent(columns = ends_with("pct"), decimals = 0) |>
  # style ----
  tab_style(
    style = cell_fill(color = "aliceblue"),
    locations = cells_body(columns = starts_with("revenue"))
  ) |>
  tab_style(
    style = cell_fill(color = "papayawhip"),
    locations = cells_body(columns = starts_with("profit"))
  ) |>
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_body(rows = product == "Total")
  ) |>
  cols_nanoplot(
    columns = starts_with("monthly_sales_"),
    plot_type = "bar",
    new_col_name = "monthly_sales",
    new_col_label = "Monthly Sales"
  ) |>
  fmt_image(columns = icon, path = "../data/great-tables/examples/coffee-table-icons/") |>
  sub_missing(missing_text = "")
""":
  nbCode:
    let coffeeSales = readNdjson(newStringStream(coffeeSalesNdjson))
      # a list column as a text of numbers, which a tabelline table takes
      .withColumns(col("monthly_sales").list.eval(element().`cast`(String)).list.join(" "))

    let selRev = startsWith("revenue")
    let selProf = startsWith("profit")

    let coffeeTable = tabella(coffeeSales):
      tabHeader "Sales of Coffee Equipment"
      tabSpanner "Revenue", selRev
      tabSpanner "Profit", selProf
      colsLabel:
        revenue_dollars: "Amount"
        profit_dollars: "Amount"
        revenue_pct: "Percent"
        profit_pct: "Percent"
        monthly_sales: "Monthly Sales"
        icon: ""
        product: "Product"
      # formatting ----
      fmtNumber endsWith("dollars"), compact = true, pattern = "${x}", decimals = 1
      fmtPercent endsWith("pct"), decimals = 0
      # style ----
      tabStyle style.fill("aliceblue"), loc.body(cols = selRev)
      tabStyle style.fill("papayawhip"), loc.body(cols = selProf)
      tabStyle style.text(weight = "bold"), loc.body(rows = where(it["product"] == "Total"))
      fmtNanoplot "monthly_sales", plotType = "bar"
      fmtImage "icon", path = coffeeIcons
      subMissing(missingText = "")
    nbTable coffeeTable

tabelline """
tabelline's `fmtNumber` has no significant figures (`n_sigfig`): `decimals = 1` with
`compact = true` gives $904.5K where Great Tables gives $904K and $2.05M where tabelline gives
$2.0M. The monthly sales are a list in each row; `tabella` cannot take a list column from a nanuq data
frame yet, so they become a text of numbers first, which a nanoplot reads as well. gt's nanoplots take their values from
columns, so the R tab spreads the twelve months over twelve columns first.
"""

bookSave()
