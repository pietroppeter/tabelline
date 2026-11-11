import tabbook
bookInit()

nbText: "# Case Study: gtcars"

attribution gtVignette("Case Study: gtcars", "case-study-gtcars",
  "The R chunks are the article's own; the Python tab writes them with Polars. The article's " &
  "logo of gtcars is left out.")

nbText: """
Let's make a display table using the `gtcars` dataset. We all know `mtcars`... what is `gtcars`? It's basically a modernized `mtcars` for the **gt** age. It's part of the **gt** package, and here is a preview of the tibble using `dplyr::glimpse()`:
"""

tabs """
import polars as pl
from great_tables import GT, loc, md, style
from great_tables.data import gtcars

# This is `gtcars`
pl.from_pandas(gtcars).glimpse()
""", """
library(gt)
library(dplyr)

# This is `gtcars`
glimpse(gtcars)
""":
  nbCode:
    import std/[algorithm, sequtils, strutils]
    import tabelline, gtdata

    # This is `gtcars`
    echo glimpse(gtcars())

tabelline """
`gtcars` is one of tabelline's datasets (`tabelline/datasets`, which `gtdata` brings). `glimpse`
is the book's, as `head` and `select` are: tabelline makes tables, not data, so the book writes
them in a few lines of Nim. For real data steps, the clinical case study uses nanuq's data frames.
"""

nbText: """
For the purpose of simply learning more about **gt**, let's reduce this 47-row tibble to one that has only 8 rows with a little **dplyr**ing:
"""

tabs """
# Get a subset of 8 cars from the `gtcars` dataset: two
# from each manufacturer country of origin except the UK
gtcars_8 = (
    pl.from_pandas(gtcars)
    .filter(pl.int_range(pl.len()).over("ctry_origin") < 2)
    .sort("ctry_origin", maintain_order=True)
    .filter(pl.col("ctry_origin") != "United Kingdom")
)

# Show the `gtcars_8` table
gtcars_8.glimpse()
""", """
# Get a subset of 8 cars from the `gtcars` dataset: two
# from each manufacturer country of origin except the UK
gtcars_8 <-
  gtcars |>
  group_by(ctry_origin) |>
  slice_head(n = 2) |>
  ungroup() |>
  filter(ctry_origin != "United Kingdom")

# Show the `gtcars_8` tibble
glimpse(gtcars_8)
""":
  nbCode:
    # Get a subset of 8 cars from the `gtcars` dataset: two
    # from each manufacturer country of origin except the UK
    let cars = gtcars()
    let rowsOf = proc (d: TableData): seq[int] = toSeq(0 ..< d.nrows)
    var picked: seq[int]
    for country in cars["ctry_origin"].values.mapIt($it).deduplicate.sorted:
      if country != "United Kingdom":
        picked.add rowsOf(cars).filterIt($cars["ctry_origin", it] == country)[0 .. 1]
    let gtcars8 = cars.take(picked)

    # Show the `gtcars8` table
    echo glimpse(gtcars8)

nbText: """
Let's make a display table from this dataset. In doing so we'll fulfill the following 10 requirements:

1. putting the cars into characteristic groups (by the car manufacturer's country of origin)
2. removing some of the columns that we don't want to present
3. incorporating some columns into a column group
4. formatting the currency data and using a monospaced font for easier reading of that data
5. giving the table a title and a subtitle
6. adding footnotes to draw attention to some of the more interesting data points and to explain some of the more unusual aspects of the data
7. placing a citation for the dataset at the bottom of the table
8. transforming the transmission (`trsmn`) codes so that they are readable and understandable
9. styling some cells according to basic criteria
10. highlighting the cars that are considered to be *grand tourers*

### Row Groups

Let's again use **dplyr** to help make groupings by the `ctry_origin` column, which provides the country of origin for the vehicle manufacturer of the car. We can simply use `dplyr::group_by()` on the `gtcars` dataset and pass that to `gt()`. What you get is a display table that arranges the cars into row groups, with the name of the group displayed prominently above.
"""

tabs """
# Use `groupname_col` on `gtcars_8` to make row groups
GT(gtcars_8, groupname_col="ctry_origin")
""", """
# Use `group_by()` on `gtcars` and pass that to `gt()`
gtcars_8 |>
  group_by(ctry_origin) |>
  gt()
""":
  nbCode:
    # Use `groupnameCol` on `gtcars8` to make row groups
    let byCountry = tabella(gtcars8, groupnameCol = "ctry_origin")
    nbTable byCountry

nbText: """
Getting the row groups in the preferred order can be done easily with `dplyr::arrange()`. For example, we can have groups that are arranged alphabetically by manufacturer (`mfr`) and then sorted by highest sticker price (`msrp`) to lowest.
"""

tabs """
GT(
    gtcars_8.sort(["mfr", "msrp"], descending=[False, True]),
    groupname_col="ctry_origin",
)
""", """
gtcars_8 |>
  group_by(ctry_origin) |>
  arrange(mfr, desc(msrp)) |>
  gt()
""":
  nbCode:
    # The rows in order of `mfr`, then of `msrp`, from the highest
    let byMfr = gtcars8.take(rowsOf(gtcars8).sortedByIt(
      ($gtcars8["mfr", it], -gtcars8["msrp", it].toFloat)))
    let byMfrTable = tabella(byMfr, groupnameCol = "ctry_origin")
    nbTable byMfrTable

tabelline """
The groups come in the order of their first row, in tabelline as in gt and Great Tables: sorting
the rows sorts the groups.
"""

nbText: """
We could also use factor levels to get a more particular ordering within `arrange()`. For example, we can first arrange the groups themselves (the country of origin--`ctry_origin`) by our own preferred ordering and then arrange by `mfr` and descending `msrp` as before. Then, `group_by(ctry_origin)` can be used on the sorted tibble before passing this to `gt()`.
"""

tabs """
# Define our preferred order for `ctry_origin`
order_countries = ["Germany", "Italy", "United States", "Japan"]
# (a country not in the list comes last, as R's `factor()` does)
country_rank = pl.col("ctry_origin").replace_strict(
    order_countries, list(range(len(order_countries))), default=len(order_countries)
)

# Reorder the table rows by our specific ordering of groups
GT(
    gtcars_8.sort(
        country_rank, "mfr", "msrp",
        descending=[False, False, True],
    ),
    groupname_col="ctry_origin",
)
""", """
# Define our preferred order for `ctry_origin`
order_countries <- c("Germany", "Italy", "United States", "Japan")

# Reorder the table rows by our specific ordering of groups
gtcars_8 |>
  arrange(
    factor(ctry_origin, levels = order_countries), mfr, desc(msrp)
  ) |>
  group_by(ctry_origin) |>
  gt()
""":
  nbCode:
    # Define our preferred order for `ctry_origin`
    let orderCountries = ["Germany", "Italy", "United States", "Japan"]

    # Reorder the table rows by our specific ordering of groups
    # (a country not in the list comes last, as R's `factor()` does)
    proc arranged(d: TableData): TableData =
      proc rank(country: Value): int =
        result = orderCountries.find($country)
        if result < 0: result = orderCountries.len
      d.take(rowsOf(d).sortedByIt(
        (rank(d["ctry_origin", it]), $d["mfr", it], -d["msrp", it].toFloat)))
    let byOrder = tabella(arranged(gtcars8), groupnameCol = "ctry_origin")
    nbTable byOrder

nbText: """
The last variation is to combine the manufacturer name with the model name, using those combined strings as row labels for the table. This is just a little more **dplyr** where we can use `dplyr::mutate()` to make a new `car` column followed by `dplyr::select()` where we remove the `mfr` and `model` columns. When introducing the tibble to the `gt()` function, we can now use the `rowname_col` argument to specify a column that will serve as row labels (which is the newly made `car` column).
"""

tabs """
# Reorder the table rows by our specific ordering of groups
tab = GT(
    gtcars_8.sort(
        country_rank, "mfr", "msrp",
        descending=[False, False, True],
    )
    .with_columns(car=pl.concat_str("mfr", "model", separator=" "))
    .drop("mfr", "model"),
    rowname_col="car",
    groupname_col="ctry_origin",
)

# Show the table
tab
""", """
# Reorder the table rows by our specific ordering of groups
tab <-
  gtcars_8 |>
  arrange(
    factor(ctry_origin, levels = order_countries),
    mfr, desc(msrp)
  ) |>
  mutate(car = paste(mfr, model)) |>
  select(-mfr, -model) |>
  group_by(ctry_origin) |>
  gt(rowname_col = "car")

# Show the table
tab
""":
  nbCode:
    # A column `car`, the manufacturer and the model, in place of both
    proc withCar(d: TableData): TableData =
      d.addColumn("car", rowsOf(d).mapIt(toValue($d["mfr", it] & " " & $d["model", it])))
      d.select(d.names.filterIt(it notin ["mfr", "model"]))

    # Reorder the table rows by our specific ordering of groups
    let tab = tabella(withCar(arranged(gtcars8)), rownameCol = "car", groupnameCol = "ctry_origin")

    # Show the table
    nbTable tab

nbText: """
### Hiding and Moving Some Columns

Let's hide two columns that we don't need to the final table: `drivetrain` and `bdy_style`. We can use `cols_hide()` to hide columns. The same end result might also have been achieved by using `gtcars |> dplyr::select(-c(drivetrain, bdy_style))`, before introducing the table to `gt()`. Why this function then? Sometimes you'll need variables for conditional statements within **gt** but won't want to display them in the end.

Aside from hiding columns, let's *move* some of them. Again, this could be done with `dplyr::select()` but there are options here in **gt** via `cols_move_to_start()`, `cols_move()`, and `cols_move_to_end()`.
"""

tabs """
# Use a few `cols_*()` methods to hide and move columns
tab = (
    tab
    .cols_hide(columns=["drivetrain", "bdy_style"])
    .cols_move(columns=["trsmn", "mpg_c", "mpg_h"], after="trim")
)

# Show the table
tab
""", """
# Use a few `cols_*()` functions to hide and move columns
tab <-
  tab |>
  cols_hide(columns = c(drivetrain, bdy_style)) |>
  cols_move(
    columns = c(trsmn, mpg_c, mpg_h),
    after = trim
  )

# Show the table
tab
""":
  nbCode:
    # Use a few `cols*` verbs to hide and move columns
    let tabMoved = tabella(tab):
      colsHide ["drivetrain", "bdy_style"]
      colsMove cols("trsmn", "mpg_c", "mpg_h"), after = "trim"

    # Show the table
    nbTable tabMoved

nbText: """
### Putting Columns Into Groups

It's sometimes useful to arrange variables/columns into groups by using spanner column labels. This can be done in **gt** with `tab_spanner()`. It takes the `label` and `columns` arguments; `label` is the spanner column label and the `columns` are those columns that belong in this group.

Here, we'll put the `mpg_c`, `mpg_h`, `hp`, `hp_rpm`, `trq`, `trq_rpm` columns under the `Performance` spanner column, and the remaining columns won't be grouped together. This single spanner column label is styled with Markdown by using the `md()` helper.
"""

tabs """
# Put the first three columns under a spanner
# column with the label 'Performance'
tab = tab.tab_spanner(
    label="Performance",
    columns=["mpg_c", "mpg_h", "hp", "hp_rpm", "trq", "trq_rpm"],
)

# Show the table
tab
""", """
# Put the first three columns under a spanner
# column with the label 'Performance'
tab <-
  tab |>
  tab_spanner(
    label = "Performance",
    columns = c(mpg_c, mpg_h, hp, hp_rpm, trq, trq_rpm)
  )

# Show the table
tab
""":
  nbCode:
    # Put the first three columns under a spanner
    # column with the label 'Performance'
    let tabSpanned = tabella(tabMoved):
      tabSpanner "Performance", cols("mpg_c", "mpg_h", "hp", "hp_rpm", "trq", "trq_rpm")

    # Show the table
    nbTable tabSpanned

nbText: """
### Merging Columns Together and Labeling Them

Sometimes we'd like to combine the data from two columns into a single column. `cols_merge()` allows us to do this, we just need to describe how the data should be combined. For our table, let's merge together the following pairs of columns:

- `mpg_c` and `mpg_h` (miles per gallon in city and highway driving modes)
- `hp` and `hp_rpm` (horsepower and associated RPM)
- `trq` and `trq_rpm` (torque and associated RPM)

`cols_merge()` uses a `col_1` column and a `col_2` column. Once combined, the `col_1` column will be retained and the `col_2` column will be dropped. The pattern argument uses `{1}` and `{2}` to represent the content of `col_1` and `col_2`. Here, we can use string literals to add text like `rpm` or the `@` sign. Furthermore, because we are targeting an HTML table, we can use the `<br>` tag to insert a linebreak.

We are going to do something a little special with the `pattern` for the `mpg_c` and `mpg_h` columns and wrap it all with `<<`/`>>`. This is special pattern syntax that tells **gt** to remove anything inside those double braces when there is an `NA` value. We find that is a single row that has `NA` in both columns (for the 'Tesla Model S') and rather than seeing `"NA"` appear in the table, it's better to remove that entry entirely with this specialized pattern syntax.  

Labeling columns essentially means that we are choosing display-friendly labels that are no longer simply the column names (the default label). `cols_label()` makes this relabeling possible. It accepts a series of named arguments in the form of `<column_name> = <column_label>, ...`.
"""

tabs """
# Perform three column merges to better present
# MPG, HP, and torque; relabel all the remaining
# columns for a nicer-looking presentation
tab = (
    tab
    .cols_merge(columns=["mpg_c", "mpg_h"], pattern="<<{0}c<br>{1}h>>")
    .cols_merge(columns=["hp", "hp_rpm"], pattern="{0}<br>@{1}rpm")
    .cols_merge(columns=["trq", "trq_rpm"], pattern="{0}<br>@{1}rpm")
    .cols_label(
        mpg_c="MPG",
        hp="HP",
        trq="Torque",
        year="Year",
        trim="Trim",
        trsmn="Transmission",
        msrp="MSRP",
    )
)

# Show the table
tab
""", """
# Perform three column merges to better present
# MPG, HP, and torque; relabel all the remaining
# columns for a nicer-looking presentation
tab <-
  tab |>
  cols_merge(
    columns = c(mpg_c, mpg_h),
    pattern = "<<{1}c<br>{2}h>>"
  ) |>
  cols_merge(
    columns = c(hp, hp_rpm),
    pattern = "{1}<br>@{2}rpm"
  ) |>
  cols_merge(
    columns = c(trq, trq_rpm),
    pattern = "{1}<br>@{2}rpm"
  ) |>
  cols_label(
    mpg_c = "MPG",
    hp = "HP",
    trq = "Torque",
    year = "Year",
    trim = "Trim",
    trsmn = "Transmission",
    msrp = "MSRP"
  )

# Show the table
tab
""":
  nbCode:
    # Perform three column merges to better present
    # MPG, HP, and torque; relabel all the remaining
    # columns for a nicer-looking presentation
    let tabMerged = tabella(tabSpanned):
      colsMerge ["mpg_c", "mpg_h"], pattern = "<<{1}c<br>{2}h>>"
      colsMerge ["hp", "hp_rpm"], pattern = "{1}<br>@{2}rpm"
      colsMerge ["trq", "trq_rpm"], pattern = "{1}<br>@{2}rpm"
      colsLabel:
        mpg_c: "MPG"
        hp: "HP"
        trq: "Torque"
        year: "Year"
        trim: "Trim"
        trsmn: "Transmission"
        msrp: "MSRP"

    # Show the table
    nbTable tabMerged

nbText: """
### Using Formatter Functions

There are a number of formatter functions, all with the general naming convention `fmt*()`. The various formatters are convenient for applying formats to numeric or character values in the table's field. Here, we will simply use `fmt_currency()` on the `msrp` column (we still refer to columns by their original names) to get USD currency will no decimal places. We're not supplying anything for the `rows` argument and this means we want to apply the formatting to the entire column of data.
"""

tabs """
# Format the `msrp` column to USD currency
# with no display of the currency subunits
tab = tab.fmt_currency(columns="msrp", decimals=0)

# Show the table
tab
""", """
# Format the `msrp` column to USD currency
# with no display of the currency subunits
tab <-
  tab |>
  fmt_currency(columns = msrp, decimals = 0)

# Show the table
tab
""":
  nbCode:
    # Format the `msrp` column to USD currency
    # with no display of the currency subunits
    let tabPriced = tabella(tabMerged):
      fmtCurrency "msrp", decimals = 0

    # Show the table
    nbTable tabPriced

nbText: """
### Column Alignment and Style Changes

We can change the alignment of data in columns with `cols_align()`. For our table, let's center-align the `mpg_c`, `hp`, and `trq` columns. All other columns will maintain their default alignments.

It's sometimes useful to modify the default styles of table cells. We can do this in a targeted way with `tab_style()`. That function require two key pieces of information: a `style` definition, and one or more `locations` (which cells should the styles be applied to?). The `style` argument commonly uses the `cell_*()` helper functions. There are three of these (`cell_text()`, `cell_fill()` and `cell_borders()`) and each contains different arguments for the different styles that are supported.

Here we will use `cell_text()` and specify a text `size` of `"12px"` for our targeted cells---both `px(12)` and `"12px"` work equally well here. We also use helper functions with the `locations` argument and these are the `cells_*()` functions. We would like to target the data cells in all columns except `year` and `msrp` so we need to use `cells_body` and then supply our target columns to its own `columns` argument.
"""

tabs """
# Center-align three columns in the table and
# modify the text size of a few columns of data
tab = (
    tab
    .cols_align(align="center", columns=["mpg_c", "hp", "trq"])
    .tab_style(
        style=style.text(size="12px"),
        locations=loc.body(columns=["trim", "trsmn", "mpg_c", "hp", "trq"]),
    )
)

# Show the table
tab
""", """
# Center-align three columns in the gt table and
# modify the text size of a few columns of data
tab <-
  tab |>
  cols_align(
    align = "center",
    columns = c(mpg_c, hp, trq)
  ) |>
  tab_style(
    style = cell_text(size = px(12)),
    locations = cells_body(
      columns = c(trim, trsmn, mpg_c, hp, trq)
    )
  )

# Show the table
tab
""":
  nbCode:
    # Center-align three columns in the table and
    # modify the text size of a few columns of data
    let tabAligned = tabella(tabPriced):
      colsAlign alCenter, cols("mpg_c", "hp", "trq")
      tabStyle style.text(size = "12px"), loc.body(cols = cols("trim", "trsmn", "mpg_c", "hp", "trq"))

    # Show the table
    nbTable tabAligned

nbText: """
### Text Transforms

Transforming text with `text_transform()` is a great way to further manipulate text in data cells (even after they've been formatted with the `fmt*()` function). After targeting data cells with the `cells_body()` location helper function, we supply a function to the `fn` argument that processes a vector of text (the vector `x` will be the formatted text in each of the targeted cells). If we intend to render an HTML table, we can directly apply HTML tags in the transformation function. The function we provide here is a bit complicated but it will build strings in the `trsmn` column that read better in a display table.
"""

tabs """
# Transform the text in `trsmn` with a function
# given to `text_transform()`; here `x` is the
# formatted text of one cell
def transmission(x):
    # The first character of `x` always
    # indicates the number of transmission speeds
    speed = x[0]

    # Which transmission type we have in `x`
    if x[1:3] == "am":
        type = "Automatic/Manual"
    elif x[1] == "m":
        type = "Manual"
    elif x[1] == "a":
        type = "Automatic"
    elif x[1:3] == "dd":
        type = "Direct Drive"

    # The speed and the type, as HTML text replacing `x`
    return f"{speed} Speed<br><em>{type}</em>"

tab = tab.text_transform(locations=loc.body(columns="trsmn"), fn=transmission)

# Show the table
tab
""", """
# Transform the column of text in `trsmn` using
# a custom function within `text_transform()`;
# here `x` represents a character vector defined
# in the `cells_body()` function
tab <-
  tab |>
  text_transform(
    locations = cells_body(columns = trsmn),
    fn = function(x) {
      # The first character of `x` always
      # indicates the number of transmission speeds
      speed <- substr(x, 1, 1)

      # We can carefully determine which transmission
      # type we have in `x` with a `dplyr::case_when()`
      # statement
      type <-
        dplyr::case_when(
          substr(x, 2, 3) == "am" ~ "Automatic/Manual",
          substr(x, 2, 2) == "m" ~ "Manual",
          substr(x, 2, 2) == "a" ~ "Automatic",
          substr(x, 2, 3) == "dd" ~ "Direct Drive"
        )

      # Let's paste together the `speed` and `type`
      # vectors to create HTML text replacing `x`
      paste(speed, " Speed<br><em>", type, "</em>")
    }
  )

# Show the table
tab
""":
  nbCode:
    # Transform the text in `trsmn` with a proc
    # given to `textTransform`; here `x` is the
    # formatted text of one cell
    proc transmission(x: string): string =
      # The first character of `x` always
      # indicates the number of transmission speeds
      let speed = x[0 .. 0]

      # Which transmission type we have in `x`
      let kind =
        if x.continuesWith("am", 1): "Automatic/Manual"
        elif x[1] == 'm': "Manual"
        elif x[1] == 'a': "Automatic"
        elif x.continuesWith("dd", 1): "Direct Drive"
        else: ""

      # The speed and the type, as HTML text replacing `x`
      speed & " Speed<br><em>" & kind & "</em>"

    let tabTransformed = tabella(tabAligned):
      textTransform transmission, loc.body(cols = "trsmn")

    # Show the table
    nbTable tabTransformed

tabelline """
A pattern of `colsMerge` and the text of `textTransform` may hold HTML (`<br>`, `<em>`): the
HTML table shows it as HTML, as gt and Great Tables do. The text of `echo` would show the tags.
"""

nbText: """
### Table Header: Title and Subtitle 

`tab_header()` allows us to place a table title and, optionally, a subtitle at the top of the display table. It's generally a good idea to have both in a table, where the subtitle provides additional information (though that isn't quite the case in our example below).
"""

tabs """
# Add a table title and subtitle; we can use
# Markdown with the `md()` helper function
tab = tab.tab_header(
    title=md("The Cars of **gtcars**"),
    subtitle="These are some fine automobiles",
)

# Show the table
tab
""", """
# Add a table title and subtitle; we can use
# markdown with the `md()` helper function
tab <-
  tab |>
  tab_header(
    title = md("The Cars of **gtcars**"),
    subtitle = "These are some fine automobiles"
  )

# Show the table
tab
""":
  nbCode:
    # Add a table title and subtitle; we can use
    # Markdown with the `md` helper
    let tabTitled = tabella(tabTransformed):
      tabHeader md"The Cars of **gtcars**", "These are some fine automobiles"

    # Show the table
    nbTable tabTitled

nbText: """
### Adding a Source Citation

A *source note* can be added below the display table with `tab_source_note()`. We can even add multiple source notes with multiple calls of that function. Here, we supply a web URL and by using Markdown (with `md()`) it's easy to create a link to the source of the data.
"""

tabs """
# Add a source note to the bottom of the table; this
# appears below the footnotes
tab = tab.tab_source_note(
    source_note=md("Source: Various pages within the Edmonds website.")
)

# Show the table
tab
""", """
# Add a source note to the bottom of the table; this
# appears below the footnotes
tab <-
  tab |>
  tab_source_note(
    source_note = md(
      "Source: Various pages within the Edmonds website."
    )
  )

# Show the table
tab
""":
  nbCode:
    # Add a source note to the bottom of the table; this
    # appears below the footnotes
    let tabSourced = tabella(tabTitled):
      tabSourceNote md"Source: Various pages within the Edmonds website."

    # Show the table
    nbTable tabSourced

nbText: """
### Using the Complete `gtcars` table and Adding Footnotes

Let's bring it all together by putting together all the statements we developed for `gtcars_8`, and applying that to the complete `gtcars` dataset. At the same time, we'll add a few interesting footnotes and our specific requirements for footnoting are:

    a. identifying the car with the best gas mileage (city)
    b. identifying the car with the highest horsepower
    c. stating the currency of the MSRP

`tab_footnote()` expects note text for the `footnote` argument, and locations for where the footnote mark should be attached. It will handle the placement of the footnote mark and also place the footnote in the footnotes area. Here, we'll use the `cells_body()` *location helper* function. There are several location helper functions for targeting all parts of the table (e.g,. `cells_body()`, `cells_stub()`, etc.). Each *location helper* has its own interface for targeting cells so refer to the documentation for examples of how they work in practice (e.g., use `?cells_body`).

What `cells_body()` expects is `columns` (column names, which can be conveniently provided in `c()`) and `rows` (which can be a vector of row names or row indices). The `cells_stub()` location helper only expects a vector of `rows`. For `cells_column_labels()`, we provide column labels in its `columns` argument. Here, we are targeting a footnote to the `msrp` column label so we will use `columns = msrp`.

In terms of structuring the code, we're taking all the previous statements and putting those in first. It should be noted that the order of the statements does not matter to the end result, we could also put in all of the `tab_footnote()` statements first (again, any in order) and expect the same output table.
"""

tabs """
# The car with the best city gas mileage, and the one with the
# highest horsepower: they will be used to target the correct
# cells for footnotes
cars_named = pl.from_pandas(gtcars).with_columns(
    car=pl.concat_str("mfr", "model", separator=" ")
)
best_gas_mileage_city = cars_named.top_k(1, by="mpg_c")["car"].to_list()
highest_horsepower = cars_named.top_k(1, by="hp")["car"].to_list()

# Define our preferred order for `ctry_origin`
order_countries = ["Germany", "Italy", "United States", "Japan"]

# Create a display table with `gtcars`, using all of the previous
# methods chained together + additional `tab_footnote()` calls
tab = (
    GT(
        pl.from_pandas(gtcars)
        .sort(
            country_rank, "mfr", "msrp",
            descending=[False, False, True],
        )
        .with_columns(car=pl.concat_str("mfr", "model", separator=" "))
        .drop("mfr", "model"),
        rowname_col="car",
        groupname_col="ctry_origin",
    )
    .cols_hide(columns=["drivetrain", "bdy_style"])
    .cols_move(columns=["trsmn", "mpg_c", "mpg_h"], after="trim")
    .tab_spanner(
        label="Performance",
        columns=["mpg_c", "mpg_h", "hp", "hp_rpm", "trq", "trq_rpm"],
    )
    .cols_merge(columns=["mpg_c", "mpg_h"], pattern="<<{0}c<br>{1}h>>")
    .cols_merge(columns=["hp", "hp_rpm"], pattern="{0}<br>@{1}rpm")
    .cols_merge(columns=["trq", "trq_rpm"], pattern="{0}<br>@{1}rpm")
    .cols_label(
        mpg_c="MPG",
        hp="HP",
        trq="Torque",
        year="Year",
        trim="Trim",
        trsmn="Transmission",
        msrp="MSRP",
    )
    .fmt_currency(columns="msrp", decimals=0)
    .cols_align(align="center", columns=["mpg_c", "hp", "trq"])
    .tab_style(
        style=style.text(size="12px"),
        locations=loc.body(columns=["trim", "trsmn", "mpg_c", "hp", "trq"]),
    )
    .text_transform(locations=loc.body(columns="trsmn"), fn=transmission)
    .tab_header(
        title=md("The Cars of **gtcars**"),
        subtitle="These are some fine automobiles",
    )
    .tab_source_note(
        source_note=md("Source: Various pages within the Edmonds website.")
    )
    .tab_footnote(
        footnote=md("Best gas mileage (city) of all the **gtcars**."),
        locations=loc.body(
            columns="mpg_c", rows=pl.col("car").is_in(best_gas_mileage_city)
        ),
    )
    .tab_footnote(
        footnote=md("The highest horsepower of all the **gtcars**."),
        locations=loc.body(
            columns="hp", rows=pl.col("car").is_in(highest_horsepower)
        ),
    )
    .tab_footnote(
        footnote="All prices in U.S. dollars (USD).",
        locations=loc.column_labels(columns="msrp"),
    )
)

# Show the table
tab
""", """
# Use dplyr functions to get the car with the best city gas mileage;
# this will be used to target the correct cell for a footnote
best_gas_mileage_city <-
  gtcars |>
  slice_max(mpg_c, n = 1) |>
  mutate(car = paste(mfr, model)) |>
  pull(car)

# Use dplyr functions to get the car with the highest horsepower
# this will be used to target the correct cell for a footnote
highest_horsepower <-
  gtcars |>
  slice_max(hp, n = 1) |>
  mutate(car = paste(mfr, model)) |>
  pull(car)

# Define our preferred order for `ctry_origin`
order_countries <- c("Germany", "Italy", "United States", "Japan")

# Create a display table with `gtcars`, using all of the previous
# statements piped together + additional `tab_footnote()` stmts
tab <-
  gtcars |>
  arrange(
    factor(ctry_origin, levels = order_countries),
    mfr, desc(msrp)
  ) |>
  mutate(car = paste(mfr, model)) |>
  select(-mfr, -model) |>
  group_by(ctry_origin) |>
  gt(rowname_col = "car") |>
  cols_hide(columns = c(drivetrain, bdy_style)) |>
  cols_move(
    columns = c(trsmn, mpg_c, mpg_h),
    after = trim
  ) |>
  tab_spanner(
    label = "Performance",
    columns = c(mpg_c, mpg_h, hp, hp_rpm, trq, trq_rpm)
  ) |>
  cols_merge(
    columns = c(mpg_c, mpg_h),
    pattern = "<<{1}c<br>{2}h>>"
  ) |>
  cols_merge(
    columns = c(hp, hp_rpm),
    pattern = "{1}<br>@{2}rpm"
  ) |>
  cols_merge(
    columns = c(trq, trq_rpm),
    pattern = "{1}<br>@{2}rpm"
  ) |>
  cols_label(
    mpg_c = "MPG",
    hp = "HP",
    trq = "Torque",
    year = "Year",
    trim = "Trim",
    trsmn = "Transmission",
    msrp = "MSRP"
  ) |>
  fmt_currency(columns = msrp, decimals = 0) |>
  cols_align(
    align = "center",
    columns = c(mpg_c, hp, trq)
  ) |>
  tab_style(
    style = cell_text(size = px(12)),
    locations = cells_body(
      columns = c(trim, trsmn, mpg_c, hp, trq)
    )
  ) |>
  text_transform(
    locations = cells_body(columns = trsmn),
    fn = function(x) {
      speed <- substr(x, 1, 1)

      type <-
        dplyr::case_when(
          substr(x, 2, 3) == "am" ~ "Automatic/Manual",
          substr(x, 2, 2) == "m" ~ "Manual",
          substr(x, 2, 2) == "a" ~ "Automatic",
          substr(x, 2, 3) == "dd" ~ "Direct Drive"
        )

      paste(speed, " Speed<br><em>", type, "</em>")
    }
  ) |>
  tab_header(
    title = md("The Cars of **gtcars**"),
    subtitle = "These are some fine automobiles"
  ) |>
  tab_source_note(
    source_note = md(
      "Source: Various pages within the Edmonds website."
    )
  ) |>
  tab_footnote(
    footnote = md("Best gas mileage (city) of all the **gtcars**."),
    locations = cells_body(
      columns = mpg_c,
      rows = best_gas_mileage_city
    )
  ) |>
  tab_footnote(
    footnote = md("The highest horsepower of all the **gtcars**."),
    locations = cells_body(
      columns = hp,
      rows = highest_horsepower
    )
  ) |>
  tab_footnote(
    footnote = "All prices in U.S. dollars (USD).",
    locations = cells_column_labels(columns = msrp)
  )

# Show the table
tab
""":
  nbCode:
    # The car with the most of `col`: it will be used
    # to target the correct cells for footnotes
    proc carWithMost(d: TableData, col: string): string =
      let best = rowsOf(d).filterIt(not d[col, it].isNull).sortedByIt(-d[col, it].toFloat)[0]
      $d["mfr", best] & " " & $d["model", best]
    let bestGasMileageCity = carWithMost(gtcars(), "mpg_c")
    let highestHorsepower = carWithMost(gtcars(), "hp")

    # Create a display table with `gtcars`, using all of the previous
    # verbs, one per line + additional `tabFootnote` verbs
    let tabFull = tabella(withCar(arranged(gtcars())), rownameCol = "car", groupnameCol = "ctry_origin"):
      colsHide ["drivetrain", "bdy_style"]
      colsMove cols("trsmn", "mpg_c", "mpg_h"), after = "trim"
      tabSpanner "Performance", cols("mpg_c", "mpg_h", "hp", "hp_rpm", "trq", "trq_rpm")
      colsMerge ["mpg_c", "mpg_h"], pattern = "<<{1}c<br>{2}h>>"
      colsMerge ["hp", "hp_rpm"], pattern = "{1}<br>@{2}rpm"
      colsMerge ["trq", "trq_rpm"], pattern = "{1}<br>@{2}rpm"
      colsLabel:
        mpg_c: "MPG"
        hp: "HP"
        trq: "Torque"
        year: "Year"
        trim: "Trim"
        trsmn: "Transmission"
        msrp: "MSRP"
      fmtCurrency "msrp", decimals = 0
      colsAlign alCenter, cols("mpg_c", "hp", "trq")
      tabStyle style.text(size = "12px"), loc.body(cols = cols("trim", "trsmn", "mpg_c", "hp", "trq"))
      textTransform transmission, loc.body(cols = "trsmn")
      tabHeader md"The Cars of **gtcars**", "These are some fine automobiles"
      tabSourceNote md"Source: Various pages within the Edmonds website."
      tabFootnote md"Best gas mileage (city) of all the **gtcars**.",
        loc.body(cols = "mpg_c", rows = where(it.car == bestGasMileageCity))
      tabFootnote md"The highest horsepower of all the **gtcars**.",
        loc.body(cols = "hp", rows = where(it.car == highestHorsepower))
      tabFootnote "All prices in U.S. dollars (USD).", loc.columnLabels("msrp")

    # Show the table
    nbTable tabFull

tabelline """
The data is made by the procs of the steps before (`arranged`, `withCar`), and the verbs are
the same, one per line: a `tabella` body is a list of what the table has. `where(it.car == ...)`
picks the row of a car by its label: `car` is the stub, and still a column of the data.
"""

nbText: """
And that is it. The final table looks pretty good and conveys the additional information we planned for. That table can be used in a lot of different places like R Markdown, Shiny, email messages... wherever HTML is accepted.
"""

bookSave()
