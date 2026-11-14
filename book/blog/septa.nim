import tabbook
bookInit()

nbText: "# Recreating Septa Transit Timetables in Python"

attribution gtBlog("Recreating Septa Transit Timetables in Python", "septa-timetables/",
  "Michael Chow and Rich Iannone", "12 Mar 2026",
  "The post's four pictures of timetables (SEPTA's, MetroTransit's, the MTA's and SEPTA's " &
  "trip planner) are linked, not copied: they are pictures of the agencies' own pages. The " &
  "data are read from a copy of the post's files (`book/data/great-tables/septa/`).")

nbText: """
Recently, Rich and I were poking around transit data, and we were struck by the amount of structuring that goes into transit timetables.

For example, consider this weekend rail schedule table from SEPTA, Philadelphia's transit agency ([the picture is in the original post](https://posit-dev.github.io/great-tables/blog/septa-timetables/)).

Notice these big pieces:

* The vertical text on the left indicating trains are traveling "TO CENTER CITY".
* The blue header, and spanner columns ("Services" and "Train Number") grouping related columns.
* The striped background for easier reading. Also the black background indicating stations in Center City (the urban core).

Tables like this often have to be created in tools like Illustrator, and updated by hand. At the same time, when agencies automate table creation, they often sacrifice a lot of the assistive features and helpful affordances of the table.

We set out to recreate this table in Great Tables (and by we I mean 99% Rich). In this post, I'll walk quickly through how we recreated it, and share some other examples of transit timetables in the wild. For the theory behind why tables like this are useful, see [The Design Philosophy of Great Tables](https://posit-dev.github.io/great-tables/blog/design-philosophy/).

## Reading in stops and times

For this example, I simplified SEPTA's transit data down to two pieces:

* `chw-stops.csv` - detailed information about each stop location.
* `times.csv` - when a train arrives at a stop on the Chesnut Hill West line. Each row is a stop location, and each column is a trip (e.g. the 6:51am train).

To make the final table we joined these two together, to get the trips and stop information together.
"""

tabelline """
The post opens with the finished table and shows its code twice, folded at the top and with
comments further down. Here the table comes once, at the end of “Creating the table”, after the
data it is made from.
"""

tabs """
import polars as pl

stops = pl.read_csv("../data/great-tables/septa/chw-stops.csv")
times = pl.read_csv("../data/great-tables/septa/times.csv")
""", """
library(gt)
library(dplyr)

stops <- read.csv("../data/great-tables/septa/chw-stops.csv")
times <- read.csv("../data/great-tables/septa/times.csv", check.names = FALSE)
""":
  nbCode:
    import std/[sequtils, streams, strutils, strformat]
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    let stops = readCsv(newStringStream(septaStopsCsv))
    let times = readCsv(newStringStream(septaTimesCsv))

nbText: """
Here's a quick preview of stops.
"""

tabs """
stops.select("stop_name", "service_access", "service_cash").head()
""", """
stops |> select(stop_name, service_access, service_cash) |> head()
""":
  nbCode:
    echo stops.select("stop_name", "service_access", "service_cash").head()

nbText: """
Notice that the table above has the name of each stop, and a 1 or 0 in the `service_access` column to indicate whether the stop is wheelchair accessible. Note that a big challenge for this specific route is that sometimes boarding the train requires using steps, and sometimes the station requires using steps. For example, Chelton Ave (not shown) does not require steps to board the train, but the station itself is not wheelchair accessible because of steps to get to the platform.

Here's a quick preview of the times.
"""

tabs """
times.head(3)
""", """
times |> head(3)
""":
  nbCode:
    echo times.head(3)

nbText: """
Notice that each trip is a column (i.e. a train leaving from Chesnut Hill West at a specific time), and each row is a stop. For example, the 8210 train is the 6:51am train. (Note that schedules and train numbers can change, so this data may be out of date).

Joining these together gives us `stop_times`, with trips and stop information on the columns.
"""

tabs """
stop_times = times.join(other=stops, on="stop_name", maintain_order="left").select(
    pl.lit("To Center City").alias("direction"), pl.col("*")
)

stop_times.head(3)
""", """
stop_times <-
  times |>
  left_join(stops, by = "stop_name") |>
  mutate(direction = "To Center City", .before = 1)

stop_times |> head(3)
""":
  nbCode:
    let stopTimes = times.join(stops, ["stop_name"], how = JoinType.Left)
      .select(lit("To Center City").alias("direction"), col("*"))

    echo stopTimes.head(3)

nbText: """
Notice that in the table above, the first row tells us when each train leaves Chesnut Hill West, and information about the Chesnut Hill West stop.

## Creating the table

Below is the code for the table, with 5 key activities marked with comments. For example, the first is creating high level structure, like the header and the left-hand "To Center City" stub. Others include formatting in checkmarks, customizing columns (e.g. their width), and styling (e.g. setting background colors and fonts).

It's a lot to take in, but worth it!:
"""

tabs """
from great_tables import GT, html, style, loc, google_font
import polars as pl
import polars.selectors as cs


def h_m_p(s):
    h, m, _ = [int(part) for part in s.split(":")]
    ap = "a"

    if h > 12:
        h -= 12
        ap = "p"
    return f"{h}:{m:02d}{ap}"


def tick(b):
    return "&check;" if b else ""


transit_table = (
    GT(stop_times)

    # Create left-hand stub, top header, and hide extra cols --------
    .tab_stub(groupname_col="direction")
    .tab_header("Saturdays, Sundays, and Major Holidays")
    .cols_hide(
        columns=["stop_url", "zone_id", "stop_desc", "stop_lat", "stop_lon", "stop_id"]
    )

    # custom functions for checkmarks and time formatting -----------
    .fmt(h_m_p, columns=cs.matches(r"^[0-9]{4}$"))
    .fmt(tick, columns=cs.starts_with("service_"))

    # relabel columns and add spanners (labels over columns) --------
    .cols_label(
        stop_name="Stations",
        service_access="A",
        service_cash="C",
        service_park="P",
        fare_zone=html("Fare<br>Zone"),
    )
    .tab_spanner(label="Services", columns=cs.starts_with("service_"))
    .tab_spanner(label="Train Number", columns=cs.matches(r"^[0-9]{4}$"))

    # move columns around and setting their width and alignment -----
    .cols_move_to_start("fare_zone")
    .cols_move_to_start(cs.starts_with("service_"))
    .cols_width(
        cases={c: "18px" for c in stop_times.columns if c.startswith("service_")}
    )
    .cols_width(cases={c: "60px" for c in stop_times.columns if c.startswith("8")})
    .cols_align(align="center", columns="fare_zone")
    .cols_align(align="right", columns=cs.matches(r"^[0-9]{4}$"))

    # styles: striping, vertical text, background colors, fonts -----
    # style header
    .tab_style(
        locations=loc.header(),
        style=style.css(
            "background-color: rgb(66, 99, 128) !important; color: white !important; font-size: 24px !important; font-weight: bold !important; border-width: 0px !important;",
        ),
    )
    # style vertical text on left
    .tab_style(
        locations=loc.row_groups(),
        style=style.css(
            "writing-mode: sideways-lr; padding-bottom: 25% !important; font-size: 24px !important; font-weight: bold !important; text-transform: uppercase !important;"
        ),
    )
    .tab_style(
        style=style.css(
            "background-color: black !important; color: white !important; border-top: none !important; border-bottom: none !important;"
        ),
        locations=loc.body(columns=None, rows=list(range(-4, -1))),
    )
    .tab_style(
        style=style.css(
            '''
                border-top: none !important;
                border-bottom: none !important;
                border-right: solid white 2px !important;
                color: white !important;
            '''
        ),
        locations=loc.body(
            columns=~cs.matches(r"^[0-9]{4}$"), rows=list(range(-4, -1))
        ),
    )
    .tab_style(
        style=style.css("border-right: solid black 2px !important;"),
        locations=loc.body(
            columns=~cs.matches(r"^[0-9]{4}$"), rows=list(range(0, 10)) + [13]
        ),
    )
    .tab_options(
        row_striping_background_color="#A9A9A9",
        row_group_as_column=True,
    )
    .opt_row_striping(row_striping=True)
    .opt_table_outline()
    .opt_table_font(font=google_font("IBM Plex Sans"))
)

transit_table
""", """
h_m_p <- function(s) {
  parts <- as.integer(strsplit(s, ":")[[1]])
  h <- parts[1]
  ap <- "a"
  if (h > 12) {
    h <- h - 12
    ap <- "p"
  }
  sprintf("%d:%02d%s", h, parts[2], ap)
}

tick <- function(b) ifelse(b == 1, "&check;", "")

trains <- grep("^[0-9]{4}$", names(stop_times), value = TRUE)

transit_table <-
  stop_times |>

  # Create left-hand stub, top header, and hide extra cols --------
  gt(groupname_col = "direction", row_group_as_column = TRUE) |>
  tab_header("Saturdays, Sundays, and Major Holidays") |>
  cols_hide(columns = c(stop_url, zone_id, stop_desc, stop_lat, stop_lon, stop_id)) |>

  # custom functions for checkmarks and time formatting -----------
  fmt(columns = matches("^[0-9]{4}$"), fns = function(x) vapply(x, h_m_p, "")) |>
  fmt(columns = starts_with("service_"), fns = tick) |>

  # relabel columns and add spanners (labels over columns) --------
  cols_label(
    stop_name = "Stations",
    service_access = "A",
    service_cash = "C",
    service_park = "P",
    fare_zone = html("Fare<br>Zone")
  ) |>
  tab_spanner(label = "Services", columns = starts_with("service_")) |>
  tab_spanner(label = "Train Number", columns = matches("^[0-9]{4}$")) |>

  # move columns around and setting their width and alignment -----
  cols_move_to_start(fare_zone) |>
  cols_move_to_start(starts_with("service_")) |>
  cols_width(starts_with("service_") ~ px(18), starts_with("8") ~ px(60)) |>
  cols_align(align = "center", columns = fare_zone) |>
  cols_align(align = "right", columns = matches("^[0-9]{4}$")) |>

  # styles: striping, vertical text, background colors, fonts -----
  tab_style(
    locations = cells_title(),
    style = "background-color: rgb(66, 99, 128) !important; color: white !important; font-size: 24px !important; font-weight: bold !important; border-width: 0px !important;"
  ) |>
  tab_style(
    locations = cells_row_groups(),
    style = "writing-mode: sideways-lr; padding-bottom: 25% !important; font-size: 24px !important; font-weight: bold !important; text-transform: uppercase !important;"
  ) |>
  tab_style(
    style = "background-color: black !important; color: white !important; border-top: none !important; border-bottom: none !important;",
    locations = cells_body(rows = 11:13)
  ) |>
  tab_style(
    style = "border-top: none !important; border-bottom: none !important; border-right: solid white 2px !important; color: white !important;",
    locations = cells_body(columns = !matches("^[0-9]{4}$"), rows = 11:13)
  ) |>
  tab_style(
    style = "border-right: solid black 2px !important;",
    locations = cells_body(columns = !matches("^[0-9]{4}$"), rows = c(1:10, 14))
  ) |>
  tab_options(row.striping.background_color = "#A9A9A9") |>
  opt_row_striping(row_striping = TRUE) |>
  opt_table_outline() |>
  opt_table_font(font = google_font("IBM Plex Sans"))

transit_table
""":
  nbCode:
    proc hMP(v: Value): string =
      let parts = ($v).split(":").mapIt(parseInt(it))
      var h = parts[0]
      var ap = "a"
      if h > 12:
        h -= 12
        ap = "p"
      &"{h}:{parts[1]:02}{ap}"

    proc tick(v: Value): string =
      if v == 1: "✓" else: ""

    # the columns of the trains: four digits, as `cs.matches(r"^[0-9]{4}$")`
    let trains = stopTimes.columns.filterIt(it.len == 4 and it.allCharsInSet(Digits))
    let center = [10, 11, 12]   # the stations of Center City, as rows -4 to -2

    let transitTable = tabella(stopTimes, groupnameCol = "direction"):

      # Create left-hand stub, top header, and hide extra cols --------
      tabHeader "Saturdays, Sundays, and Major Holidays"
      colsHide ["stop_url", "zone_id", "stop_desc", "stop_lat", "stop_lon", "stop_id"]

      # custom functions for checkmarks and time formatting -----------
      fmt trains, hMP
      fmt startsWith("service_"), tick

      # relabel columns and add spanners (labels over columns) --------
      colsLabel:
        stop_name: "Stations"
        service_access: "A"
        service_cash: "C"
        service_park: "P"
      colsLabel "fare_zone", html"Fare<br>Zone"
      tabSpanner "Services", startsWith("service_")
      tabSpanner "Train Number", trains

      # move columns around and setting their width and alignment -----
      colsMoveToStart "fare_zone"
      colsMoveToStart startsWith("service_")
      colsWidth stopTimes.columns.filterIt(it.startsWith("service_")).mapIt((it, "18px"))
      colsWidth stopTimes.columns.filterIt(it.startsWith("8")).mapIt((it, "60px"))
      colsAlign alCenter, "fare_zone"
      colsAlign alRight, trains

      # styles: striping, vertical text, background colors, fonts -----
      # style header
      tabStyle style.css("background-color: rgb(66, 99, 128) !important; color: white !important; font-size: 24px !important; font-weight: bold !important; border-width: 0px !important;"),
        loc.header()
      # style vertical text on left
      tabStyle style.css("writing-mode: sideways-lr; padding-bottom: 25% !important; font-size: 24px !important; font-weight: bold !important; text-transform: uppercase !important;"),
        loc.rowGroups()
      tabStyle style.css("background-color: black !important; color: white !important; border-top: none !important; border-bottom: none !important;"),
        loc.body(rows = center)
      tabStyle style.css("""
                border-top: none !important;
                border-bottom: none !important;
                border-right: solid white 2px !important;
                color: white !important;
            """),
        loc.body(cols = everything() - trains, rows = center)
      tabStyle style.css("border-right: solid black 2px !important;"),
        loc.body(cols = everything() - trains, rows = toSeq(0 ..< 10) & @[13])
      tabOptions(rowStripingBackgroundColor = "#A9A9A9", rowGroupAsColumn = true)
      optRowStriping()
      optTableOutline()
      optTableFont "\"IBM Plex Sans\", " & systemFonts("neo-grotesque")
    nbTable transitTable

tabelline """
tabelline has no `tab_stub()` (nor has gt): the group column is chosen in
`tabella(groupnameCol = ...)`, and `rowGroupAsColumn` puts its label in a column of its own on
the left. The columns of the trains are found by their names (four digits) in Nim, as tabelline
has no selector by a regular expression, and the rows of Center City are counted from the top
(10 to 12), as tabelline takes no negative rows. `everything() - trains` is `~cs.matches(...)`.
A block of `colsLabel` takes plain texts, or only `md`/`html` ones: the HTML label of
`fare_zone` gets a `colsLabel` of its own. The ticks are the character ✓, where the post writes the HTML entity `&check;`. The R tab
writes the gt way: gt has no `tab_stub()` and takes `row_group_as_column` in `gt()`.

On a phone the table is wider than the screen and scrolls inside its box, and the stations go
with it: tabelline cannot yet keep the first columns in place while the rest scrolls, as a
timetable on a phone would want.
"""

nbText: """
## Other schedules in the wild

MetroTransit in Minneapolis uses a transposed format, with stops as columns and trips as rows. Here's an example from their [Route 2 bus timetable](https://www.metrotransit.org/route/2) (its picture is in [the original post](https://posit-dev.github.io/great-tables/blog/septa-timetables/#other-schedules-in-the-wild)).

This is useful when there a lot of trips, because with trips on the rows readers can scroll down (versus needing to scroll sideways).

The MTA in New York City is similar. Here's an example of their [bx1 bus route timetable](https://www.mta.info/schedules/bus/bx1) (also pictured in the original post).

What I like about all these tables is they highlight the structure behind bus and train routes. Sometimes they skip certain stops. But realistically, what makes them a route is that trips tend to make the same stops over and over.

A common alternative to using these tables is to do routing from a set start to end point. For example, a form for selecting a start and end point on SEPTA's website gives a resulting table of departure and arrival times (pictured in the original post).

Notice that the table has removed a lot of information about intermediate stops people might not care about.

## In conclusion

Transit tables are richly structured displays of information.
They take advantage often of the fact that a train route like Chesnut Hill West is a fixed set of stops--so that stops can be on the rows, and arrival times for trips throughout the day can be on the columns.

This is intuitive to people reading transit timetables, but can get tricky to display on the web. Timetables are a core part of navigating transit networks, so it was a fun experiment to try replicating one of Septa's timetables in Great Tables!
"""

bookSave()
