import tabbook
bookInit()

nbText: "# Intro"

attribution gtGuide("Intro", "index",
  "Left out: installing with pip (tabelline installs with nimble or atlas, see below) and the " &
  "notes on Pandas and Polars, which tabelline does not take yet.")

nbText: """
The **Great Tables** package is all about making it simple to produce nice-looking display tables. Display tables? Well yes, we are trying to distinguish between data tables (i.e., DataFrames) and those tables you’d find in a web page, a journal article, or in a magazine. Such tables can likewise be called presentation tables, summary tables, or just tables really. Here are some examples, ripped straight from the web:

![](../images/tables_from_the_web.png)

We can think of display tables as output only, where we’d not want to use them as input ever again. Other features include annotations, table element styling, and text transformations that serve to communicate the subject matter more clearly.

## Let's Install
"""

tabelline """
tabelline is a Nim package with no dependencies but Nim's standard library:

```sh
nimble install https://github.com/pietroppeter/tabelline
```

or, with [atlas](https://github.com/nim-lang/atlas), `atlas use https://github.com/pietroppeter/tabelline`.
Then `import tabelline`. In a [nimib](https://github.com/pietroppeter/nimib) notebook, as in
this book, `import tabelline/nimib` adds `nbTable t`, which shows the table `t` as a block of
the page.
"""

nbText: """
## A Basic Table using **Great Tables**

Let’s use a subset of the `islands` dataset available within `great_tables.data`:
"""

tabs """
from great_tables import GT, md, html
from great_tables.data import islands

islands_mini = islands.head(10)
""", """
library(gt)
library(dplyr)

islands_tbl <- tibble(name = names(islands), size = islands)
islands_mini <- islands_tbl |> slice_head(n = 10)
""":
  nbCode:
    import tabelline, gtdata
    import std/sequtils

    let islandsMini = islands().head(10)

tabelline """
`tabelline/datasets` does not have `islands` yet (it has `exibble` and `planets`), so the book
reads it from a copy of Great Tables' CSV file (`gtdata`, in the book's sources), which also
has `head`: tabelline's `TableData` is not a data frame, and has no verbs of its own.
"""

nbText: """
The `islands` data is a simple **Pandas** DataFrame with 2 columns and that'll serve as a great start. Speaking of which, the main entry point into the **Great Tables** API is the `GT` class. Let's use that to make a presentable table:
"""

tabs """
# Create a display table showing ten of the largest islands in the world
gt_tbl = GT(islands_mini)

# Show the output table
gt_tbl
""", """
# Create a display table showing ten of the largest islands in the world
gt_tbl <- gt(islands_mini)

# Show the output table
gt_tbl
""":
  nbCode:
    # Create a display table showing ten of the largest islands in the world
    let gtTbl = tabella(islandsMini)

    # Show the output table
    nbTable gtTbl

nbText: """
That doesn't look too bad! Sure, it's basic but we really didn't really ask for much. We did receive a proper table with column labels and the data. Oftentimes however, you'll want a bit more: a **Table header**, a **Stub**, and sometimes *source notes* in the **Table Footer** component.
"""

tabelline """
The main entry point of tabelline is `tabella`, *a table* in Italian, the `GT` of Great Tables.
A `Tabella` is a plain value: every verb takes one and gives back a new one. `echo gtTbl`
prints it as text, in a terminal, and `gtTbl.save "islands.html"` writes it as a standalone
HTML page.
"""

nbText: """
## Some Beautiful Examples

In the following pages we'll use **Great Tables** to turn DataFrames into beautiful tables, like the ones below.
"""

tabs """
from great_tables import GT, md, html
from great_tables.data import islands

islands_mini = islands.head(10)

(
    GT(islands_mini, rowname_col = "name")
    .tab_header(
        title="Large Landmasses of the World",
        subtitle="The top ten largest are presented"
    )
    .tab_source_note(
        source_note="Source: The World Almanac and Book of Facts, 1975, page 406."
    )
    .tab_source_note(
        source_note=md("Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley.")
    )
    .tab_stubhead(label="landmass")
)
""", """
gt(islands_mini, rowname_col = "name") |>
  tab_header(
    title = "Large Landmasses of the World",
    subtitle = "The top ten largest are presented"
  ) |>
  tab_source_note(
    source_note = "Source: The World Almanac and Book of Facts, 1975, page 406."
  ) |>
  tab_source_note(
    source_note = md("Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley.")
  ) |>
  tab_stubhead(label = "landmass")
""":
  nbCode:
    let landmasses = tabella(islandsMini, rownameCol = "name"):
      tabHeader "Large Landmasses of the World", "The top ten largest are presented"
      tabSourceNote "Source: The World Almanac and Book of Facts, 1975, page 406."
      tabSourceNote md("Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley.")
      tabStubhead "landmass"
    nbTable landmasses

tabelline """
`tabella(data): body` is a macro, one of tabelline's three (with `tableData:` and
`tabOptions`): it reads each line of `body` as a verb applied to the table, so the chain of
methods becomes a list of lines. Everything else is plain Nim procs:
`tabHeader "Large Landmasses of the World"` in the body stands for
`t = t.tabHeader("Large Landmasses of the World")`.
"""

tabs """
from great_tables import GT, html
from great_tables.data import airquality

airquality_m = airquality.head(10).assign(Year=1973)

gt_airquality = (
    GT(airquality_m)
    .tab_header(
        title="New York Air Quality Measurements",
        subtitle="Daily measurements in New York City (May 1-10, 1973)",
    )
    .tab_spanner(label="Time", columns=["Year", "Month", "Day"])
    .tab_spanner(label="Measurement", columns=["Ozone", "Solar_R", "Wind", "Temp"])
    .cols_move_to_start(columns=["Year", "Month", "Day"])
    .cols_label(
        Ozone=html("Ozone,<br>ppbV"),
        Solar_R=html("Solar R.,<br>cal/m<sup>2</sup>"),
        Wind=html("Wind,<br>mph"),
        Temp=html("Temp,<br>&deg;F"),
    )
)

gt_airquality
""", """
airquality_m <- airquality |> slice_head(n = 10) |> mutate(Year = 1973L)

gt_airquality <- gt(airquality_m) |>
  tab_header(
    title = "New York Air Quality Measurements",
    subtitle = "Daily measurements in New York City (May 1-10, 1973)"
  ) |>
  tab_spanner(label = "Time", columns = c(Year, Month, Day)) |>
  tab_spanner(label = "Measurement", columns = c(Ozone, Solar.R, Wind, Temp)) |>
  cols_move_to_start(columns = c(Year, Month, Day)) |>
  cols_label(
    Ozone = html("Ozone,<br>ppbV"),
    Solar.R = html("Solar R.,<br>cal/m<sup>2</sup>"),
    Wind = html("Wind,<br>mph"),
    Temp = html("Temp,<br>&deg;F")
  )

gt_airquality
""":
  nbCode:
    let airqualityM = airquality().head(10)

    let gtAirquality = tabella(airqualityM):
      colsAdd "Year", newSeqWith(10, 1973)
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

    nbTable gtAirquality

tabelline """
`colsAdd` adds a column to the table, as gt's `cols_add()`, where Great Tables adds it to the
data frame (`assign`); `newSeqWith` is from `std/sequtils`. `colsLabel` takes its pairs as a
block, one column per line.
"""

bookSave()
