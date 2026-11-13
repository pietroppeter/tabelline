import tabbook
bookInit()

nbText: "# Sports earnings"

attribution gtExample("Sports earnings",
  "https://github.com/posit-dev/great-tables/blob/main/docs/examples/sports-earnings/index.ipynb",
  "The notebook's two cells are one example here, and its files are read from the book's " &
  "folder. The table recreates one by Lisa Hornung; the sports icons are by Firza Alamsyah " &
  "(the Noun Project), and the data by Forbes.")

nbText: """
The highest paid athletes of 2023, with the share of their earnings made off the field drawn as
a bar.
"""

tabs """
import polars as pl
import polars.selectors as cs
from great_tables import GT, md


def create_bar(prop_fill: float, max_width: int, height: int) -> str:
    "Create divs to represent prop_fill as a bar."
    width = round(max_width * prop_fill, 2)
    px_width = f"{width}px"
    return f'''\
    <div style="width: {max_width}px; background-color: lightgrey;">\
        <div style="height:{height}px;width:{px_width};background-color:green;"></div>\
    </div>\
    '''


df = pl.read_csv("../data/great-tables/examples/sports_earnings.csv")

res = (
    df.with_columns(
        (pl.col("Off-the-Field Earnings") / pl.col("Total Earnings")).alias("raw_perc"),
        (pl.col("Sport").str.to_lowercase() + ".png").alias("icon"),
    )
    .head(9)
    .with_columns(
        pl.col("raw_perc")
          .map_elements(lambda x: create_bar(x, max_width=75, height=20))
          .alias("Off-the-Field Earnings Perc")
    )
    .select("Rank", "Name", "icon", "Sport", "Total Earnings", "Off-the-Field Earnings", "Off-the-Field Earnings Perc")
)

(
    GT(res, rowname_col="Rank")
    .tab_header("Highest Paid Athletes in 2023")
    .tab_spanner("Earnings", cs.contains("Earnings"))
    #.fmt_number(cs.starts_with("Total"), scale_by = 1/1_000_000, decimals=1)
    .cols_label(**{
        "Total Earnings": "Total $M",
        "Off-the-Field Earnings": "Off field $M",
        "Off-the-Field Earnings Perc": "Off field %"
    })
    .fmt_number(["Total Earnings", "Off-the-Field Earnings"], scale_by = 1/1_000_000, decimals=1)
    .fmt_image("icon", path="../data/great-tables/examples/sports-icons/")
    .tab_source_note(
        md(
            '<br><div style="text-align: center;">'
            "Original table: [@LisaHornung_](https://twitter.com/LisaHornung_/status/1752981867769266231)"
            " | Sports icons: [Firza Alamsyah](https://thenounproject.com/browse/collection-icon/sports-96427)"
            " | Data: Forbes"
            "</div>"
            "<br>"
        )
    )
)
""", """
library(gt)
library(dplyr)

create_bar <- function(prop_fill, max_width, height) {
  # Create divs to represent prop_fill as a bar
  width <- round(max_width * prop_fill, 2)
  sprintf(
    '<div style="width: %spx; background-color: lightgrey;"><div style="height:%spx;width:%spx;background-color:green;"></div></div>',
    max_width, height, width
  )
}

res <-
  read.csv("../data/great-tables/examples/sports_earnings.csv", check.names = FALSE) |>
  mutate(
    `Off-the-Field Earnings Perc` = `Off-the-Field Earnings` / `Total Earnings`,
    icon = paste0(tolower(Sport), ".png")
  ) |>
  slice_head(n = 9) |>
  select(Rank, Name, icon, Sport, `Total Earnings`, `Off-the-Field Earnings`, `Off-the-Field Earnings Perc`)

res |>
  gt(rowname_col = "Rank") |>
  tab_header("Highest Paid Athletes in 2023") |>
  tab_spanner("Earnings", contains("Earnings")) |>
  cols_label(
    `Total Earnings` = "Total $M",
    `Off-the-Field Earnings` = "Off field $M",
    `Off-the-Field Earnings Perc` = "Off field %"
  ) |>
  fmt_number(c(`Total Earnings`, `Off-the-Field Earnings`), scale_by = 1 / 1e6, decimals = 1) |>
  fmt(
    columns = `Off-the-Field Earnings Perc`,
    fns = function(x) create_bar(x, max_width = 75, height = 20)
  ) |>
  fmt_image(icon, path = "../data/great-tables/examples/sports-icons/") |>
  tab_source_note(
    md(paste0(
      "Original table: [@LisaHornung_](https://twitter.com/LisaHornung_/status/1752981867769266231)",
      " | Sports icons: [Firza Alamsyah](https://thenounproject.com/browse/collection-icon/sports-96427)",
      " | Data: Forbes"
    ))
  ) |>
  tab_style(cell_text(align = "center"), cells_source_notes())
""":
  nbCode:
    import std/[math, streams, strutils]
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    proc createBar(propFill: float, maxWidth, height: int): string =
      ## Create divs to represent propFill as a bar.
      let width = round(maxWidth.float * propFill, 2)
      "<div style=\"width: $1px; background-color: lightgrey;\">" % $maxWidth &
        "<div style=\"height:$1px;width:$2px;background-color:green;\"></div></div>" % [$height, $width]

    let res = readCsv(newStringStream(sportsEarningsCsv))
      .withColumns(
        (col("Off-the-Field Earnings") / col("Total Earnings")).alias("Off-the-Field Earnings Perc"),
        concatStr([col("Sport").str.toLowercase, lit(".png")]).alias("icon"))
      .head(9)
      .select("Rank", "Name", "icon", "Sport", "Total Earnings", "Off-the-Field Earnings",
              "Off-the-Field Earnings Perc")

    let sportsTbl = tabella(res, rownameCol = "Rank"):
      tabHeader "Highest Paid Athletes in 2023"
      tabSpanner "Earnings", containing("Earnings")
      colsLabel:
        "Total Earnings": "Total $M"
        "Off-the-Field Earnings": "Off field $M"
        "Off-the-Field Earnings Perc": "Off field %"
      fmtNumber ["Total Earnings", "Off-the-Field Earnings"], scaleBy = 1 / 1_000_000, decimals = 1
      fmt "Off-the-Field Earnings Perc", proc (v: Value): string =
        createBar(v.toFloat, maxWidth = 75, height = 20)
      fmtImage "icon", path = sportsIcons
      tabSourceNote md("Original table: [@LisaHornung_](https://twitter.com/LisaHornung_/status/1752981867769266231)" &
        " | Sports icons: [Firza Alamsyah](https://thenounproject.com/browse/collection-icon/sports-96427)" &
        " | Data: Forbes")
      tabStyle style.text(align = "center"), loc.sourceNotes()
    nbTable sportsTbl

tabelline """
The bar is HTML written by a proc, as in the notebook, but in tabelline (and gt) it is a format
of the share, so the data keep the number: `fmt` turns it into the bar when the table is drawn.
The source note is centred with a style, as gt does it, where the notebook writes a `div` in its
Markdown.
"""

bookSave()
