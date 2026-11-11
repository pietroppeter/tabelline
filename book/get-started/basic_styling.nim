import tabbook
bookInit()

nbText: "# Styling the Table Body"

attribution gtGuide("Styling the Table Body", "basic-styling",
  "Left out: the note on VS Code. The Polars examples have no Nim of their own (tabelline " &
  "takes no data frames yet): their Nim tab shows the same table made with `where`.")

nbText: """
**Great Tables** can add styles---like color, text properties, and borders---on many different parts of
the displayed table. The following set of examples shows how to set styles on the body of table, where the data cells are located.

For the examples on this page, we'll use the included airquality dataset to set up `GT` objects for both **Pandas** and **Polars** DataFrames.
"""

tabs """
import polars as pl

from great_tables import GT, from_column, style, loc
from great_tables.data import airquality

air_head = airquality.head()

gt_air = GT(air_head)
gt_pl_air = GT(pl.from_pandas(air_head))
""", """
library(gt)
library(dplyr)

air_head <- airquality |> slice_head(n = 5)

gt_air <- gt(air_head)
""":
  nbCode:
    import tabelline, gtdata

    let airHead = airquality().head()

    let gtAir = tabella(airHead)

nbText: """
## Style basics

We use the `GT.tab_style()` method in combination with `loc.body()` to set styles on cells of data in the table body. For example, the table-making code below applies a yellow background color to specific cells.
"""

tabs """
gt_air.tab_style(
    style=style.fill(color="yellow"),
    locations=loc.body(columns="Temp", rows=[1, 2])
)
""", """
gt_air |>
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = cells_body(columns = Temp, rows = 2:3)
  )
""":
  nbCode:
    nbTable gtAir.tabStyle(
      style = style.fill(color = "yellow"),
      locations = loc.body(cols = "Temp", rows = [1, 2]))

nbText: """
There are two important arguments to `GT.tab_style()`: `style=` and `locations=`. We are calling a specific function for each of these:

* `style.fill()`: the type of style to apply. In this case the *fill* (or background color).
* `loc.body()`: the area we want to style. In this case, it's the table body with specific columns and rows specified.

In addition to `style.fill()`, several other styling functions exist. We'll look at styling borders and text in the following sections.
"""

tabelline """
The same two arguments, and the same `style` and `loc` namespaces. One name differs:
`loc.body` takes `cols =` where Great Tables takes `columns=`.
"""

nbText: """
### Customizing Borders

Let's use `style.borders()` to place borders around targeted cells. In this next example, the table has a red dashed border above two rows.
"""

tabs """
gt_air.tab_style(
    style=style.borders(sides="top", color="red", style="dashed", weight="3px"),
    locations=loc.body(rows=[1, 2])
)
""", """
gt_air |>
  tab_style(
    style = cell_borders(sides = "top", color = "red", style = "dashed", weight = px(3)),
    locations = cells_body(rows = 2:3)
  )
""":
  nbCode:
    nbTable gtAir.tabStyle(
      style = style.borders(sides = {sTop}, color = "red", style = "dashed", weight = "3px"),
      locations = loc.body(rows = [1, 2]))

tabelline """
`sides` is a Nim set of `sTop`, `sRight`, `sBottom` and `sLeft` (all four by default), where
Great Tables takes a string or a list of strings.
"""

nbText: """
### Customizing Text

We can style text with by using the `style.text()` function. This gives us many customization possibilities for any text we target. For example, the `Solar_R` column below has green, bolded text in a custom font.
"""

tabs """
gt_air.tab_style(
    style=style.text(color="green", font="Times New Roman", weight="bold"),
    locations=loc.body(columns="Solar_R")
)
""", """
gt_air |>
  tab_style(
    style = cell_text(color = "green", font = "Times New Roman", weight = "bold"),
    locations = cells_body(columns = Solar.R)
  )
""":
  nbCode:
    nbTable gtAir.tabStyle(
      style = style.text(color = "green", font = "Times New Roman", weight = "bold"),
      locations = loc.body(cols = "Solar_R"))

nbText: """
## Column-based Styles

In addition to setting styles to specific values (e.g., a `"yellow"` background fill), you can also use parameter values from table columns to specify styles. The way to do this is to use the `from_column()` helper function to access those values.
"""

tabs """
df = pl.DataFrame({"x": [1, 2], "background": ["lightyellow", "lightblue"]})

(
    GT(df)
    .tab_style(
        style=style.fill(color=from_column(column="background")),
        locations=loc.body(columns="x")
    )
)
""", """
df <- tibble(x = c(1, 2), background = c("lightyellow", "lightblue"))

gt(df) |>
  tab_style(
    style = cell_fill(color = from_column(column = "background")),
    locations = cells_body(columns = x)
  )
""":
  nbCode:
    let df = tableData:
      x: [1, 2]
      background: ["lightyellow", "lightblue"]

    let t = tabella(df):
      tabStyle style = style.fill(color = fromColumn("background")),
               locations = loc.body(cols = "x")
    nbTable t

tabelline """
`fromColumn("background")` stands for the value of that column in each row of the location,
as in Great Tables. `tableData:`, a macro, makes a `TableData` from columns, one per line, as
Polars' dictionary does.
"""

nbText: """
Notice that in the code above, we used values from the `background` column to specify the fill color for each styled row.

In the next few sections, we'll first show how this combines nicely with the `GT.cols_hide()` method, then, we'll demonstrate how to use **Polars** expressions to do everything much more simply.

### Combining Styling with `cols_hide()`

One common approach is to specify a style from a column, and then hide that column in the final output. For example, we can add a background column to our `airquality` data:
"""

tabs """
color_map = {
    True: "lightyellow",
    False: "lightblue"
}

with_color = air_head.assign(
    background=(air_head["Temp"] > 70).replace(color_map)
)

with_color
""", """
with_color <- air_head |>
  mutate(background = if_else(Temp > 70, "lightyellow", "lightblue"))

with_color
""":
  nbCode:
    let withColor = airquality().head()
    var background: seq[Value]
    for v in withColor["Temp"].values:
      background.add toValue(if v > 70: "lightyellow" else: "lightblue")
    withColor.addColumn("background", background)

    echo tabella(withColor)

nbText: """
Notice that the dataset now has a `background` column set to either `"lightyellow"` or `"lightblue"`, depending on whether `Temp` is above `70`.

We can then use this `background` column to set the fill color of certain body cells, and then hide the `background` column since we don't need that in our finalized display table:
"""

tabs """
(
    GT(with_color)
    .tab_style(
        style=style.fill(color=from_column(column="background")),
        locations=loc.body(columns="Temp")
    )
    .cols_hide(columns="background")
)
""", """
gt(with_color) |>
  tab_style(
    style = cell_fill(color = from_column(column = "background")),
    locations = cells_body(columns = Temp)
  ) |>
  cols_hide(columns = background)
""":
  nbCode:
    let tc = tabella(withColor):
      tabStyle style = style.fill(color = fromColumn("background")),
               locations = loc.body(cols = "Temp")
      colsHide "background"
    nbTable tc

nbText: """
Note the two methods used above:

* `GT.tab_style()`: uses `from_column()` to set the color using the values of the `background` column.
* `GT.cols_hide()`: prevents the `background` column from being displayed in the output.

### Using **Polars** expressions

Styles can also be specified using **Polars** expressions. For example, the code below uses the `Temp` column to set color to `"lightyellow"` or `"lightblue"`.
"""

tabs """
# A Polars expression defines color based on `Temp`
temp_color = (
    pl.when(pl.col("Temp") > 70)
    .then(pl.lit("lightyellow"))
    .otherwise(pl.lit("lightblue"))
)

gt_pl_air.tab_style(
    style=style.fill(color=temp_color),
    locations=loc.body("Temp")
)
""", """
# from_column() with a function of the column defines color based on `Temp`
temp_color <- from_column(
  column = "Temp",
  fn = function(x) if_else(x > 70, "lightyellow", "lightblue")
)

gt_air |>
  tab_style(
    style = cell_fill(color = temp_color),
    locations = cells_body(Temp)
  )
""":
  nbCode:
    # a style for the rows where Temp > 70, another for the others
    let byTemp = tabella(gtAir):
      tabStyle style.fill("lightyellow"), loc.body("Temp", where(it["Temp"] > 70))
      tabStyle style.fill("lightblue"), loc.body("Temp", where(not (it["Temp"] > 70)))
    nbTable byTemp

tabelline """
`where(cond)` selects the rows where `cond` holds, with `it` the row: tabelline's version of a
Polars expression, or of a function of the DataFrame. Each style takes one colour, so the two
colours take two styles.
"""

nbText: """
### Using functions

You can also use a function, that takes the DataFrame and returns a Series with a style value for each row.

This is shown below on a pandas DataFrame.
"""

tabs """
def map_color(df):
    return (df["Temp"] > 70).map(
        {True: "lightyellow", False: "lightblue"}
    )

gt_air.tab_style(
    style=style.fill(
        color=map_color),
    locations=loc.body("Temp")
)
""", """
map_color <- function(temp) {
  ifelse(temp > 70, "lightyellow", "lightblue")
}

gt_air |>
  tab_style(
    style = cell_fill(color = from_column("Temp", fn = map_color)),
    locations = cells_body(Temp)
  )
""":
  nbCode:
    proc mapColor(d: TableData, i: int): string =
      if d["Temp", i] > 70: "lightyellow" else: "lightblue"

    var tf = gtAir
    for i in 0 ..< airHead.nrows:
      tf = tf.tabStyle(style.fill(mapColor(airHead, i)), loc.body("Temp", i))
    nbTable tf

nbText: """
## Specifying columns and rows

### Using polars selectors

If you are using **Polars**, you can use column selectors and expressions for selecting specific columns and rows:
"""

tabs """
import polars.selectors as cs

gt_pl_air.tab_style(
    style=style.fill(color="yellow"),
    locations=loc.body(
        columns=cs.starts_with("Te"),
        rows=pl.col("Temp") > 70
    )
)
""", """
gt_air |>
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = cells_body(
      columns = starts_with("Te"),
      rows = Temp > 70
    )
  )
""":
  nbCode:
    nbTable gtAir.tabStyle(
      style = style.fill(color = "yellow"),
      locations = loc.body(cols = startsWith("Te"), rows = where(it["Temp"] > 70)))

nbText: """
See [Column Selection](column_selection.html) for details on selecting columns.

### Using a function

For tools like **pandas**, you can use a function (or lambda) to select rows. The function should take a DataFrame, and output a boolean Series.
"""

tabs """
gt_air.tab_style(
    style=style.fill(color="yellow"),
    locations=loc.body(
        columns=lambda col_name: col_name.startswith("Te"),
        rows=lambda D: D["Temp"] > 70,
    )
)
""", """
# without tidyselect: plain vectors of names and of TRUE/FALSE
gt_air |>
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = cells_body(
      columns = names(air_head)[startsWith(names(air_head), "Te")],
      rows = air_head$Temp > 70
    )
  )
""":
  nbCode:
    nbTable gtAir.tabStyle(
      style = style.fill(color = "yellow"),
      locations = loc.body(cols = startsWith("Te"), rows = where(it["Temp"] > 70)))

nbText: """
## Multiple styles and locations

We can use a list within `style=` to apply multiple styles at once. For example, the code below sets fill and border styles on the same set of body cells.
"""

tabs """
gt_air.tab_style(
    style=[style.fill(color="yellow"), style.borders(sides="all")],
    locations=loc.body(columns="Temp", rows=[1, 2]),
)
""", """
gt_air |>
  tab_style(
    style = list(cell_fill(color = "yellow"), cell_borders(sides = "all")),
    locations = cells_body(columns = Temp, rows = 2:3)
  )
""":
  nbCode:
    nbTable gtAir.tabStyle(
      style = style.fill(color = "yellow") & style.borders(),
      locations = loc.body(cols = "Temp", rows = [1, 2]))

tabelline """
Styles join with `&` instead of going in a list.
"""

nbText: """
Note that you can also pass a list to `locations=`!
"""

tabs """
gt_air.tab_style(
    style=style.fill(color="yellow"),
    locations=[
        loc.body(columns="Temp", rows=[1, 2]),
        loc.body(columns="Ozone", rows=[0])
    ]
)
""", """
gt_air |>
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = list(
      cells_body(columns = Temp, rows = 2:3),
      cells_body(columns = Ozone, rows = 1)
    )
  )
""":
  nbCode:
    nbTable gtAir.tabStyle(style.fill(color = "yellow"),
      loc.body(cols = "Temp", rows = [1, 2]),
      loc.body(cols = "Ozone", rows = [0]))

nbText: """
You can also combine **Polars** selectors with a row filtering expression, in order to select a combination of columns and rows.
"""

tabs """
import polars.selectors as cs

gt_pl_air.tab_style(
    style=style.fill(color="yellow"),
    locations=loc.body(
        columns=cs.exclude(["Month", "Day"]),
        rows=pl.col("Temp") == pl.col("Temp").max()
    )
)
""", """
gt_air |>
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = cells_body(
      columns = -c(Month, Day),
      rows = Temp == max(Temp)
    )
  )
""":
  nbCode:
    var maxTemp = 0
    for v in airHead["Temp"].values: maxTemp = max(maxTemp, v.i)

    nbTable gtAir.tabStyle(
      style = style.fill(color = "yellow"),
      locations = loc.body(cols = ["Ozone", "Solar_R", "Wind", "Temp"],
                           rows = where(it["Temp"] == maxTemp)))

tabelline """
tabelline has no `exclude` selector, nor a way to combine selectors (gaps): the columns are
named. The maximum is computed first, in plain Nim.
"""

nbText: """
Lastly, you can use **Polars** selectors or expressions to conditionally select rows on a per-column basis.
"""

tabs """
import polars.selectors as cs

gt_pl_air.tab_style(
    style=style.fill(color="yellow"),
    locations=loc.body(mask=cs.all().eq(cs.all().max())),
)
""", """
# gt has no mask: one tab_style() for each column does the same
Reduce(
  function(tbl, col) {
    tab_style(tbl,
      style = cell_fill(color = "yellow"),
      locations = cells_body(
        columns = all_of(col),
        rows = which(air_head[[col]] == max(air_head[[col]], na.rm = TRUE))
      )
    )
  },
  names(air_head),
  gt_air
)
""":
  nbCode:
    # no mask yet: the cells with the maximum of their column, one column at a time
    var tm = gtAir
    for c in airHead.columns:
      var top = -Inf
      for v in c.values:
        if v.isNumber: top = max(top, v.toFloat)
      for i, v in c.values:
        if v.isNumber and v.toFloat == top:
          tm = tm.tabStyle(style.fill("yellow"), loc.body(cols = c.name, rows = i))
    nbTable tm

tabelline """
`loc.body(mask = ...)`, a condition for each cell, is a gap. The loop above does by hand what
a mask would do.
"""

nbText: """
## Learning more

* API Docs:
  - `GT.tab_style()`
  - [`style.*` and `loc.*` functions](https://posit-dev.github.io/great-tables/reference/#location-targeting-and-styling-classes)
  - `from_column()`
"""

bookSave()
