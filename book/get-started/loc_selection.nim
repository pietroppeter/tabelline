import tabbook
bookInit()

nbText: "# Location selection"

attribution gtGuide("Location selection", "loc-selection",
  "The table of locations has a column for tabelline. The Polars data is made in Nim with " &
  "the book's `take` and `select`.")

nbText: """
Great Tables uses the `loc` module to specify locations for styling in `GT.tab_style()`. Some location specifiers also allow selecting specific columns and rows of data.

For example, you might style a particular row name, group, column, or spanner label.

The table below shows the different location specifiers, along with the types of column or row selection they allow.
"""

tabs """
import polars as pl
from great_tables import GT

data = [
    ["header", "loc.header()", "composite"],
    ["", "loc.title()", ""],
    ["", "loc.subtitle()", ""],
    ["boxhead", "loc.column_header()", "composite"],
    ["", "loc.spanner_labels()", "columns"],
    ["", "loc.column_labels()", "columns"],
    ["row stub", "loc.stub()", "rows"],
    ["", "loc.row_groups()", "rows"],
    # ["", "loc.summary_stub()", "rows"],
    ["", "loc.grand_summary_stub()", "rows"],
    ["table body", "loc.body()", "columns and rows"],
    # ["", "loc.summary_rows()", "columns and rows"],
    ["", "loc.grand_summary_rows()", "columns and rows"],
    ["footer", "loc.footer()", "composite"],
    ["", "loc.source_notes()", ""],
]

df = pl.DataFrame(data, schema=["table part", "name", "selection"], orient="row")

GT(df)
""", """
library(gt)
library(dplyr)

# gt's cells_*() helpers: there are no composite ones (the whole header, column header or footer)
data <- tribble(
  ~`table part`, ~name,                         ~selection,
  "header",      "cells_title()",               "groups",
  "",            "cells_title(\"title\")",      "",
  "",            "cells_title(\"subtitle\")",   "",
  "boxhead",     "cells_column_spanners()",     "spanners",
  "",            "cells_column_labels()",       "columns",
  "row stub",    "cells_stub()",                "rows",
  "",            "cells_row_groups()",          "groups",
  "",            "cells_stub_grand_summary()",  "rows",
  "",            "cells_stubhead()",            "",
  "table body",  "cells_body()",                "columns and rows",
  "",            "cells_grand_summary()",       "columns and rows",
  "footer",      "cells_footnotes()",           "",
  "",            "cells_source_notes()",        ""
)

gt(data)
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    type Location = tuple[part, name, selection, tabelline: string]
    let data: seq[Location] = @[
      ("header", "loc.header()", "composite", "loc.header()"),
      ("", "loc.title()", "", "loc.title()"),
      ("", "loc.subtitle()", "", "loc.subtitle()"),
      ("boxhead", "loc.column_header()", "composite", "loc.columnHeader()"),
      ("", "loc.spanner_labels()", "columns", "loc.spannerLabels(labels)"),
      ("", "loc.column_labels()", "columns", "loc.columnLabels(cols)"),
      ("row stub", "loc.stub()", "rows", "loc.stub(rows)"),
      ("", "loc.row_groups()", "rows", "loc.rowGroups(names)"),
      ("", "", "", "loc.summaryStub(groups, rows)"),
      ("", "loc.grand_summary_stub()", "rows", "loc.grandSummaryStub(rows)"),
      ("table body", "loc.body()", "columns and rows", "loc.body(cols, rows)"),
      ("", "", "", "loc.summary(groups, columns, rows)"),
      ("", "loc.grand_summary_rows()", "columns and rows", "loc.grandSummary(columns, rows)"),
      ("footer", "loc.footer()", "composite", "loc.footer()"),
      ("", "loc.source_notes()", "", "loc.sourceNotes()"),
      ("", "", "", "loc.footnotes()"),
      ("", "loc.stubhead()", "", "loc.stubhead()")]

    let locations = tabella(data):
      colsLabel:
        part: "table part"
    nbTable locations

tabelline """
A table straight from a seq of named tuples, one field per column: `tabella(data)`. Four rows
are not in the original's list: the summary rows of each group, `loc.summaryStub()` and
`loc.summary()`, which Great Tables leaves out (it has no summary rows of groups yet, only
grand ones), tabelline's `loc.footnotes()`, and `loc.stubhead()`, which Great Tables has but
leaves out here.
"""

nbText: """
Note that composite specifiers are ones that target multiple locations. For example, `loc.header()` specifies both `loc.title()` and `loc.subtitle()`.

## Setting up data

The examples below will use this small dataset to show selecting different locations, as well as specific rows and columns within a location (where supported).
"""

tabs """
import polars as pl
import polars.selectors as cs

from great_tables import GT, loc, style, exibble

pl_exibble = pl.from_pandas(exibble)[[0, 1, 4], ["num", "char", "group"]]

pl_exibble
""", """
small_exibble <- exibble |> slice(c(1, 2, 5)) |> select(num, char, group)

small_exibble
""":
  nbCode:
    let plExibble = exibble().take([0, 1, 4]).select(["num", "char", "group"])

    echo tabella(plExibble)

nbText: """
## Simple locations

Simple locations don't take any arguments.

For example, styling the title uses `loc.title()`.
"""

tabs """
(
    GT(pl_exibble)
    .tab_header("A title", "A subtitle")
    .tab_style(
        style.fill("yellow"),
        loc.title(),
    )
)
""", """
gt(small_exibble) |>
  tab_header("A title", "A subtitle") |>
  tab_style(
    cell_fill("yellow"),
    cells_title("title")
  )
""":
  nbCode:
    let titled = tabella(plExibble):
      tabHeader "A title", "A subtitle"
      tabStyle style.fill("yellow"), loc.title()
    nbTable titled

nbText: """
## Composite locations

Composite locations target multiple simple locations.

For example, `loc.header()` includes both `loc.title()` and `loc.subtitle()`.
"""

tabs """
(
    GT(pl_exibble)
    .tab_header("A title", "A subtitle")
    .tab_style(
        style.fill("yellow"),
        loc.header(),
    )
)
""", """
gt(small_exibble) |>
  tab_header("A title", "A subtitle") |>
  tab_style(
    cell_fill("yellow"),
    cells_title()
  )
""":
  nbCode:
    let header = tabella(plExibble):
      tabHeader "A title", "A subtitle"
      tabStyle style.fill("yellow"), loc.header()
    nbTable header

nbText: """
## Body columns, rows and mask

Use `columns=` and `rows=` in `loc.body()` to style specific cells in the table body.
"""

tabs """
(
    GT(pl_exibble).tab_style(
        style.fill("yellow"),
        loc.body(
            columns=cs.starts_with("cha"),
            rows=pl.col("char").str.contains("a"),
        ),
    )
)
""", """
gt(small_exibble) |>
  tab_style(
    cell_fill("yellow"),
    cells_body(
      columns = starts_with("cha"),
      rows = grepl("a", char)
    )
  )
""":
  nbCode:
    import std/strutils

    let cells = tabella(plExibble):
      tabStyle style.fill("yellow"),
               loc.body(cols = startsWith("cha"), rows = where("a" in $it["char"]))
    nbTable cells

nbText: """
Alternatively, use `mask=` in `loc.body()` to apply conditional styling to rows on a per-column basis.
"""

tabs """
(
    GT(pl_exibble).tab_style(
        style.fill("yellow"),
        loc.body(mask=cs.string().str.contains("p")),
    )
)
""", """
# gt has no mask: one tab_style() for each text column does the same
Reduce(
  function(tbl, col) {
    tab_style(tbl,
      cell_fill("yellow"),
      cells_body(columns = all_of(col), rows = grepl("p", small_exibble[[col]]))
    )
  },
  names(small_exibble)[sapply(small_exibble, is.character)],
  gt(small_exibble)
)
""":
  nbCode:
    # no mask yet: a style for each text column, on the rows where it contains "p"
    var t = tabella(plExibble)
    for name in textual().resolve(plExibble):
      t = t.tabStyle(style.fill("yellow"), loc.body(cols = name, rows = where("p" in $it[name])))
    nbTable t

nbText: """
This is discussed in detail in [Styling the Table Body](basic_styling.html).

## Column labels

Locations like `loc.spanner_labels()` and `loc.column_labels()` can select specific column and spanner labels.

You can use name strings, index position, or polars selectors.
"""

tabs """
GT(pl_exibble).tab_style(
    style.fill("yellow"),
    loc.column_labels(
        cs.starts_with("cha"),
    ),
)
""", """
gt(small_exibble) |>
  tab_style(
    cell_fill("yellow"),
    cells_column_labels(
      starts_with("cha")
    )
  )
""":
  nbCode:
    let labels = tabella(plExibble):
      tabStyle style.fill("yellow"), loc.columnLabels(startsWith("cha"))
    nbTable labels

nbText: """
However, note that `loc.spanner_labels()` currently only accepts list of string names.

## Row and group names

Row and group names in `loc.stub()` and `loc.row_groups()` may be specified three ways:

* by name
* by index
* by polars expression
"""

tabelline """
tabelline's `loc.stub` takes rows (an index, indices, `where`), and `loc.rowGroups` takes group
names. A row by its name, and a group by one of its rows, are gaps: `where` stands in for the
first.
"""

sideBySide()

tabs """
gt = GT(pl_exibble).tab_stub(
    rowname_col="char",
    groupname_col="group",
)

gt.tab_style(style.fill("yellow"), loc.stub())
""", """
gt_tbl <- gt(small_exibble, rowname_col = "char", groupname_col = "group")

gt_tbl |> tab_style(cell_fill("yellow"), cells_stub())
""":
  nbCode:
    let gt = tabella(plExibble, rownameCol = "char", groupnameCol = "group")

    nbTable gt.tabStyle(style.fill("yellow"), loc.stub())

tabs """
gt.tab_style(style.fill("yellow"), loc.stub("banana"))
""", """
gt_tbl |> tab_style(cell_fill("yellow"), cells_stub("banana"))
""":
  nbCode:
    nbTable gt.tabStyle(style.fill("yellow"), loc.stub(where(it["char"] == "banana")))

tabs """
gt.tab_style(style.fill("yellow"), loc.stub(["apricot", 2]))
""", """
# gt takes the rows by name or by number, not both: apricot is row 1
gt_tbl |> tab_style(cell_fill("yellow"), cells_stub(c(1, 3)))
""":
  nbCode:
    nbTable gt.tabStyle(style.fill("yellow"), loc.stub(where(it["char"] == "apricot")), loc.stub(2))

endSideBySide()

nbText: """
### Groups by name and position

Note that for specifying row groups, the group corresponding to the group name or row number in the original data is used.

For example, the code below styles the group corresponding to the row at index 1 (i.e. the second row) in the data.
"""

tabs """
gt.tab_style(
    style.fill("yellow"),
    loc.row_groups(1),
)
""", """
gt_tbl |>
  tab_style(
    cell_fill("yellow"),
    cells_row_groups(2)
  )
""":
  nbCode:
    nbTable gt.tabStyle(style.fill("yellow"), loc.rowGroups($plExibble["group", 1]))

nbText: """
Since the second row (starting with "banana") is in "grp_a", that is the group that gets styled.

This means you can use a polars expression to select groups:
"""

tabs """
gt.tab_style(
    style.fill("yellow"),
    loc.row_groups(pl.col("group") == "grp_b"),
)
""", "":
  nbCode:
    nbTable gt.tabStyle(style.fill("yellow"), loc.rowGroups("grp_b"))  # no conditions on groups yet

nbText: """
You can also specify group names using a string (or list of strings).
"""

tabs """
gt.tab_style(
    style.fill("yellow"),
    loc.row_groups("grp_b"),
)
""", """
gt_tbl |>
  tab_style(
    cell_fill("yellow"),
    cells_row_groups("grp_b")
  )
""":
  nbCode:
    nbTable gt.tabStyle(style.fill("yellow"), loc.rowGroups("grp_b"))

bookSave()
