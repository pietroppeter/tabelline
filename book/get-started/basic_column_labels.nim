import tabbook
bookInit()

nbText: "# Column Labels"

attribution gtGuide("Column Labels", "basic-column-labels",
  "The `Year` column is added to the data in Nim with `addColumn`.")

nbText: """
The table's **Column Labels** part contains, at a minimum, columns and their *column labels*. The last example had a single column: `size`. Just as in the **Stub**, we can create groupings called *spanner labels* that encompass one or more columns.

To better demonstrate how **Column Labels** work and are displayed, let's use an input data table with more columns. In this case, that input table will be `airquality`. It has the following columns:

- `Ozone`: mean ground-level ozone in parts per billion by volume (ppbV), measured between 13:00 and 15:00
- `Solar_R`: solar radiation in Langley units (cal/m<sup>2</sup>), measured between 08:00 and noon
- `Wind`: mean wind speed in miles per hour (mph)
- `Temp`: maximum daily air temperature in degrees Fahrenheit (&deg;F)
- `Month`, `Day`: the numeric month and day of month for the record

We know that all measurements took place in 1973, so a `year` column will be added to the dataset before it is passed to the `GT` class.
"""

tabs """
from great_tables import GT, html
from great_tables.data import airquality

airquality_mini = airquality.head(10).assign(Year = 1973)

airquality_mini
""", """
library(gt)
library(dplyr)

airquality_mini <- airquality |> slice_head(n = 10) |> mutate(Year = 1973L)

airquality_mini
""":
  nbCode:
    import tabelline, gtdata
    import std/sequtils

    let airqualityMini = airquality().head(10)
    airqualityMini.addColumn("Year", toValues(newSeqWith(10, 1973)))

    echo airqualityMini.tabella

tabelline """
Great Tables shows the pandas DataFrame itself here. tabelline's `TableData` has no display of
its own: the closest is a bare table, `tabella(data)`, printed as text with `echo`.
"""

nbText: """
## Adding Column Spanners

Let's organize the time information under a `Time` *spanner label*, and put the other columns under a `Measurement` *spanner label*. We can do this with the `GT.tab_spanner()` method.
"""

tabs """
gt_airquality = (
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
)

gt_airquality
""", """
gt_airquality <- gt(airquality_mini) |>
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
  )

gt_airquality
""":
  nbCode:
    let gtAirquality = tabella(airqualityMini):
      tabHeader "New York Air Quality Measurements",
                "Daily measurements in New York City (May 1-10, 1973)"
      tabSpanner "Time", ["Year", "Month", "Day"]
      tabSpanner "Measurement", ["Ozone", "Solar_R", "Wind", "Temp"]

    nbTable gtAirquality

tabelline """
The columns under `Time` are the same, in a different order: Great Tables puts the columns of a
spanner in the order they are given (`Year`, `Month`, `Day`), tabelline leaves them in the
order of the data (`Month`, `Day`, `Year`), which works here because they are already next to
each other. Gathering the columns of a spanner, as Great Tables does, is a gap.
"""

nbText: """
## Moving and Relabeling Columns

We can do two more things to make this presentable:

- move the `Time` columns to the beginning of the series (using `GT.cols_move_to_start()`)
- customize the column labels so that they are more descriptive (using `GT.cols_label()`)

Let's do both of these things in the next example:
"""

tabs """
(
    gt_airquality
    .cols_move_to_start(columns=["Year", "Month", "Day"])
    .cols_label(
        Ozone=html("Ozone,<br>ppbV"),
        Solar_R=html("Solar R.,<br>cal/m<sup>2</sup>"),
        Wind=html("Wind,<br>mph"),
        Temp=html("Temp,<br>&deg;F")
    )
)
""", """
gt_airquality |>
  cols_move_to_start(columns = c(Year, Month, Day)) |>
  cols_label(
    Ozone = html("Ozone,<br>ppbV"),
    Solar.R = html("Solar R.,<br>cal/m<sup>2</sup>"),
    Wind = html("Wind,<br>mph"),
    Temp = html("Temp,<br>&deg;F")
  )
""":
  nbCode:
    let relabeled = tabella(gtAirquality):
      colsMoveToStart ["Year", "Month", "Day"]
      colsLabel:
        Ozone: html"Ozone,<br>ppbV"
        Solar_R: html"Solar R.,<br>cal/m<sup>2</sup>"
        Wind: html"Wind,<br>mph"
        Temp: html"Temp,<br>&deg;F"
    nbTable relabeled

nbText: """
Note that even though columns were moved using `GT.cols_move_to_start()`, the *spanner column labels* still spanned above the correct *column labels*. There are a number of methods on `GT` to move columns, including `GT.cols_move()`, `GT.cols_move_to_end()`; there's even a method to hide columns: `GT.cols_hide()`.

Multiple columns can be renamed in a single use of `GT.cols_label()`. Further to this, the helper functions `md()` and `html()` can be used to create column labels with additional styling. In the above example, we provided column labels as HTML so that we can insert linebreaks with `<br>`, insert a superscripted `2` (with `<sup>2</sup>`), and insert a degree symbol as an HTML entity (`&deg;`).
"""

tabelline """
tabelline has `colsMove`, `colsMoveToStart`, `colsMoveToEnd`, `colsReorder`, `colsHide` and
`colsUnhide`. Inside `tabella(data): body`, `colsLabel` takes its pairs as a block, one
`column: label` per line, where a label is a string, `md"..."` or `html"..."` (outside a body,
the same pairs go in a table constructor, `colsLabel({"Ozone": ...})`). With `md`, the same
labels need no HTML: `md"Solar R.,<br>cal/m^2^"`; and `colsUnits` writes units in gt's
notation, so `Solar_R: "cal/m^2"` in a `colsUnits:` block shows "Solar_R, cal/m²".
"""

nbText: """
## Targeting Columns for `columns=`

In the above examples, we selected columns to span or move using a list of column names (as strings). However, **Great Tables** supports a wide range of ways to select columns.

For example, you can use a lambda function:
"""

tabs """
(
    GT(airquality_mini)
    .cols_move_to_start(columns=lambda colname: colname.endswith("R"))
)
""", """
gt(airquality_mini) |>
  cols_move_to_start(columns = ends_with("R"))
""":
  nbCode:
    let moved = tabella(airqualityMini):
      colsMoveToStart endsWith("R")
    nbTable moved

nbText: """
Inputs like strings, integers, and polars selectors are also supported. For more information, see [Column Selection](column_selection.html).
"""

tabelline """
tabelline selects columns with rules instead of functions: `everything()`, `startsWith`,
`endsWith`, `containing`, `numeric()` and `textual()`, or names. Selecting by position, and
with any function of the name, are gaps (see [Column Selection](column_selection.html)).
"""

bookSave()
