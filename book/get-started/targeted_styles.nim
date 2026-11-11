import tabbook
bookInit()

nbText: "# Styling the whole table"

attribution gtGuide("Styling the whole table", "targeted-styles", "")

nbText: """
In [Styling the Table Body](basic_styling.html), we discussed styling table data with `GT.tab_style()`.
In this article we'll cover how the same method can be used to style many other parts of the table, like the header, specific spanner labels, the footer, and more.

## Kitchen sink

Below is a big example that shows all possible `loc` specifiers being used.
"""

tabs """
from great_tables import GT, exibble, loc, style

# https://colorbrewer2.org/#type=qualitative&scheme=Paired&n=12 and grey
brewer_colors = [
    "#a6cee3",
    "#1f78b4",
    "#b2df8a",
    "#33a02c",
    "#fb9a99",
    "#e31a1c",
    "#fdbf6f",
    "#ff7f00",
    "#cab2d6",
    "#6a3d9a",
    "#ffff99",
    "#b15928",
    "#808080",
]

c = iter(brewer_colors)

gt = (
    GT(exibble.loc[[0, 1, 4], ["num", "char", "fctr", "row", "group"]])
    .tab_header("title", "subtitle")
    .tab_stub(rowname_col="row", groupname_col="group")
    .tab_source_note("yo")
    .tab_spanner("spanner", ["char", "fctr"])
    .tab_stubhead("stubhead")
    .grand_summary_rows(fns={"Total": lambda x: x.sum(numeric_only=True)})
)

(
    gt.tab_style(style.fill(next(c)), loc.body())
    # Columns -----------
    # TODO: appears in browser, but not vs code
    .tab_style(style.fill(next(c)), loc.column_labels(columns="num"))
    .tab_style(style.fill(next(c)), loc.column_header())
    .tab_style(style.fill(next(c)), loc.spanner_labels(ids=["spanner"]))
    # Header -----------
    .tab_style(style.fill(next(c)), loc.header())
    .tab_style(style.fill(next(c)), loc.subtitle())
    .tab_style(style.fill(next(c)), loc.title())
    # Footer -----------
    .tab_style(style.borders(weight="3px"), loc.source_notes())
    .tab_style(style.fill(next(c)), loc.footer())
    # Stub --------------
    .tab_style(style.fill(next(c)), loc.row_groups())
    .tab_style(style.borders(weight="3px"), loc.stub(rows=1))
    .tab_style(style.fill(next(c)), loc.stub())
    .tab_style(style.fill(next(c)), loc.stubhead())
    # Summary Rows --------------
    .tab_style(style.fill(next(c)), loc.grand_summary())
    .tab_style(style.fill(next(c)), loc.grand_summary_stub())
)
""", """
library(gt)
library(dplyr)

# https://colorbrewer2.org/#type=qualitative&scheme=Paired&n=12 and grey
brewer_colors <- c(
  "#a6cee3",
  "#1f78b4",
  "#b2df8a",
  "#33a02c",
  "#fb9a99",
  "#e31a1c",
  "#fdbf6f",
  "#ff7f00",
  "#cab2d6",
  "#6a3d9a",
  "#ffff99",
  "#b15928",
  "#808080"
)

gt_tbl <- exibble |>
  slice(c(1, 2, 5)) |>
  select(num, char, fctr, row, group) |>
  gt(rowname_col = "row", groupname_col = "group") |>
  tab_header("title", "subtitle") |>
  tab_source_note("yo") |>
  tab_spanner("spanner", c(char, fctr)) |>
  tab_stubhead("stubhead") |>
  grand_summary_rows(columns = num, fns = list(label = "Total", fn = "sum"))

# the same colour for each location as in the Python tab; gt has no cells for the whole
# column header, header or footer, so their parts take their colour first
gt_tbl |>
  tab_style(cell_fill(brewer_colors[1]), cells_body()) |>
  # Columns -----------
  tab_style(cell_fill(brewer_colors[3]), list(cells_column_labels(), cells_column_spanners())) |>
  tab_style(cell_fill(brewer_colors[2]), cells_column_labels(columns = num)) |>
  tab_style(cell_fill(brewer_colors[4]), cells_column_spanners(spanners = "spanner")) |>
  # Header -----------
  tab_style(cell_fill(brewer_colors[5]), cells_title()) |>
  tab_style(cell_fill(brewer_colors[6]), cells_title("subtitle")) |>
  tab_style(cell_fill(brewer_colors[7]), cells_title("title")) |>
  # Footer -----------
  tab_style(cell_borders(weight = px(3)), cells_source_notes()) |>
  tab_style(cell_fill(brewer_colors[8]), cells_source_notes()) |>
  # Stub --------------
  tab_style(cell_fill(brewer_colors[9]), cells_row_groups()) |>
  tab_style(cell_borders(weight = px(3)), cells_stub(rows = 2)) |>
  tab_style(cell_fill(brewer_colors[10]), cells_stub()) |>
  tab_style(cell_fill(brewer_colors[11]), cells_stubhead()) |>
  # Summary Rows --------------
  tab_style(cell_fill(brewer_colors[12]), cells_grand_summary()) |>
  tab_style(cell_fill(brewer_colors[13]), cells_stub_grand_summary())
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    # https://colorbrewer2.org/#type=qualitative&scheme=Paired&n=12 and grey
    let brewerColors = ["#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", "#e31a1c",
                        "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a", "#ffff99", "#b15928", "#808080"]
    var k = -1
    proc next(): string = (inc k; brewerColors[k])

    let data = exibble().take([0, 1, 4]).select(["num", "char", "fctr", "row", "group"])
    let gt = tabella(data, rownameCol = "row", groupnameCol = "group"):
      tabHeader "title", "subtitle"
      tabSourceNote "yo"
      tabSpanner "spanner", ["char", "fctr"]
      tabStubhead "stubhead"
      grandSummaryRows:
        Total: agg.sum

    let kitchenSink = tabella(gt):
      tabStyle style.fill(next()), loc.body()
      # Columns -----------
      tabStyle style.fill(next()), loc.columnLabels(cols = "num")
      tabStyle style.fill(next()), loc.columnHeader()
      tabStyle style.fill(next()), loc.spannerLabels("spanner")
      # Header -----------
      tabStyle style.fill(next()), loc.header()
      tabStyle style.fill(next()), loc.subtitle()
      tabStyle style.fill(next()), loc.title()
      # Footer -----------
      tabStyle style.borders(weight = "3px"), loc.sourceNotes()
      tabStyle style.fill(next()), loc.footer()
      # Stub --------------
      tabStyle style.fill(next()), loc.rowGroups()
      tabStyle style.borders(weight = "3px"), loc.stub(rows = 1)
      tabStyle style.fill(next()), loc.stub()
      tabStyle style.fill(next()), loc.stubhead()
      # Summary Rows --------------
      tabStyle style.fill(next()), loc.grandSummary()
      tabStyle style.fill(next()), loc.grandSummaryStub()
    nbTable kitchenSink

tabelline """
tabelline has every location of Great Tables, the composite ones included: `loc.header()`,
`loc.columnHeader()` and `loc.footer()`. `grandSummaryRows` takes its aggregates as a block,
one per line, a label and an aggregate of the `agg` namespace (`Total: agg.sum`): by default
it sums up the numeric columns, as `numeric_only=True` does in pandas. A column with no
format of its own shows its sum with two decimals (5,552.33), where Great Tables shows the
sum as Python prints it (5552.3331); `missingText` (a dash, `—`, by default; Great Tables
writes `---`) fills the cells of the other columns.
A composite location sits *under* its parts, as in Great Tables: the fill of
`loc.columnHeader()` does not cover the blue of `loc.columnLabels(cols = "num")` given before
it. `loc.spannerLabels` takes the labels of the spanners (`loc.spanners` is the same), as
tabelline's spanners have no ids.

Compare the Nim and Python tabs: the same colours in the same places, but for two differences.
A fill on a spanner colours the whole cell in Great Tables, only the label in tabelline; and the
missing value of `char` shows as `None` in Great Tables, blank in tabelline (`subMissing`
shows it as a dash).
"""

nbText: """
## Body
"""

tabs """
gt.tab_style(style.fill("yellow"), loc.body())
""", """
gt_tbl |> tab_style(cell_fill("yellow"), cells_body())
""":
  nbCode:
    let bodyStyled = tabella(gt):
      tabStyle style.fill("yellow"), loc.body()
    nbTable bodyStyled

nbText: """
## Column labels
"""

tabs """
(
    gt
    .tab_style(style.fill("yellow"), loc.column_header())
    .tab_style(style.fill("blue"), loc.column_labels(columns="num"))
    .tab_style(style.fill("red"), loc.spanner_labels(ids=["spanner"]))
)
""", """
# no cells for the whole column header: its parts
gt_tbl |>
  tab_style(cell_fill("yellow"), list(cells_column_labels(), cells_column_spanners())) |>
  tab_style(cell_fill("blue"), cells_column_labels(columns = num)) |>
  tab_style(cell_fill("red"), cells_column_spanners(spanners = "spanner"))
""":
  nbCode:
    let labelsStyled = tabella(gt):
      tabStyle style.fill("yellow"), loc.columnHeader()
      tabStyle style.fill("blue"), loc.columnLabels(cols = "num")
      tabStyle style.fill("red"), loc.spannerLabels("spanner")
    nbTable labelsStyled

nbText: """
## Header
"""

tabs """
(
    gt.tab_style(style.fill("yellow"), loc.header())
    .tab_style(style.fill("blue"), loc.title())
    .tab_style(style.fill("red"), loc.subtitle())
)
""", """
gt_tbl |>
  tab_style(cell_fill("yellow"), cells_title()) |>
  tab_style(cell_fill("blue"), cells_title("title")) |>
  tab_style(cell_fill("red"), cells_title("subtitle"))
""":
  nbCode:
    let headerStyled = tabella(gt):
      tabStyle style.fill("yellow"), loc.header()
      tabStyle style.fill("blue"), loc.title()
      tabStyle style.fill("red"), loc.subtitle()
    nbTable headerStyled

nbText: """
## Footer
"""

tabs """
(
    gt.tab_style(
        style.fill("yellow"),
        loc.source_notes(),
    ).tab_style(
        style.borders(weight="3px"),
        loc.footer(),
    )
)
""", """
# no cells for the whole footer: its source notes
gt_tbl |>
  tab_style(
    cell_fill("yellow"),
    cells_source_notes()
  ) |>
  tab_style(
    cell_borders(weight = px(3)),
    cells_source_notes()
  )
""":
  nbCode:
    let footerStyled = tabella(gt):
      tabStyle style.fill("yellow"), loc.sourceNotes()
      tabStyle style.borders(weight = "3px"), loc.footer()
    nbTable footerStyled

nbText: """
## Stub
"""

tabs """
(
    gt.tab_style(style.fill("yellow"), loc.stub())
    .tab_style(style.fill("blue"), loc.row_groups())
    .tab_style(
        style.borders(style="dashed", weight="3px", color="red"),
        loc.stub(rows=[1]),
    )
)
""", """
gt_tbl |>
  tab_style(cell_fill("yellow"), cells_stub()) |>
  tab_style(cell_fill("blue"), cells_row_groups()) |>
  tab_style(
    cell_borders(style = "dashed", weight = px(3), color = "red"),
    cells_stub(rows = 2)
  )
""":
  nbCode:
    let stubStyled = tabella(gt):
      tabStyle style.fill("yellow"), loc.stub()
      tabStyle style.fill("blue"), loc.rowGroups()
      tabStyle style.borders(style = "dashed", weight = "3px", color = "red"), loc.stub(rows = [1])
    nbTable stubStyled

nbText: """
## Stubhead
"""

tabs """
gt.tab_style(style.fill("yellow"), loc.stubhead())
""", """
gt_tbl |> tab_style(cell_fill("yellow"), cells_stubhead())
""":
  nbCode:
    let stubheadStyled = tabella(gt):
      tabStyle style.fill("yellow"), loc.stubhead()
    nbTable stubheadStyled

nbText: """
## Grand Summary Rows
"""

tabs """
(
    gt.tab_style(
        style.fill("yellow"),
        loc.grand_summary_stub(),
    ).tab_style(
        style.fill("lightblue"),
        loc.grand_summary(),
    )
)
""", """
gt_tbl |>
  tab_style(
    cell_fill("yellow"),
    cells_stub_grand_summary()
  ) |>
  tab_style(
    cell_fill("lightblue"),
    cells_grand_summary()
  )
""":
  nbCode:
    let summaryStyled = tabella(gt):
      tabStyle style.fill("yellow"), loc.grandSummaryStub()
      tabStyle style.fill("lightblue"), loc.grandSummary()
    nbTable summaryStyled

bookSave()
