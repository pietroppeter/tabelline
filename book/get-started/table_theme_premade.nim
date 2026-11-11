import tabbook
bookInit()

nbText: "# Premade Themes"

attribution gtGuide("Premade Themes", "table-theme-premade",
  "The six styles side by side are made in a Python cell that returns their HTML (the " &
  "original prints it into the Quarto page). tabelline has three styles of `optStylize`, not " &
  "six.")

nbText: """
Great Tables provides convenience methods starting with `opt_` (e.g. `GT.opt_row_striping()`), as a shortcut for various styles that can be set via `GT.tab_options()`.

There are two important kinds of `GT.opt_*()` methods:

* `GT.opt_stylize()`: allows setting one of six premade table themes.
* The remaining `opt_*()` methods: shortcuts for common uses of `GT.tab_options()`.

We'll use the basic GT object below for most examples, since it marks some of the table parts.
"""

tabs """
from great_tables import GT, exibble, md

lil_exibble = exibble.head(5)[["num", "char", "row", "group"]]

gt_ex = (
    GT(lil_exibble, rowname_col="row", groupname_col="group")
    .tab_header(
        title=md("Data listing from exibble"),
        subtitle=md("This is a **Great Tables** dataset."),
    )
    .tab_stubhead(label="row")
    .fmt_number(columns="num")
    .fmt_currency(columns="currency")
    .tab_source_note(source_note="This is only a portion of the dataset.")
    .opt_vertical_padding(scale=0.5)
)

gt_ex
""", """
library(gt)
library(dplyr)

lil_exibble <- exibble |> slice_head(n = 5) |> select(num, char, row, group)

# no fmt_currency(columns = currency): the table has no such column, and gt stops on it
gt_ex <- gt(lil_exibble, rowname_col = "row", groupname_col = "group") |>
  tab_header(
    title = md("Data listing from exibble"),
    subtitle = md("This is a **Great Tables** dataset.")
  ) |>
  tab_stubhead(label = "row") |>
  fmt_number(columns = num) |>
  tab_source_note(source_note = "This is only a portion of the dataset.") |>
  opt_vertical_padding(scale = 0.5)

gt_ex
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    let lilExibble = exibble().head(5).select(["num", "char", "row", "group"])

    let gtEx = tabella(lilExibble, rownameCol = "row", groupnameCol = "group"):
      tabHeader md"Data listing from exibble", md"This is a **Great Tables** dataset."
      tabStubhead "row"
      fmtNumber "num"
      # fmtCurrency "currency": there is no currency column (Great Tables lets it pass)
      tabSourceNote "This is only a portion of the dataset."
      optVerticalPadding(scale = 0.5)

    nbTable gtEx

tabelline """
The original formats a `currency` column that `lil_exibble` does not have, and Great Tables
lets it pass. tabelline stops with an error that names the column and the columns there are,
so the line is left out.
"""

nbText: """
## `opt_stylize()`: premade themes

Below are the first two premade styles. The first uses `color="blue"`, and the second uses `color="red"`.
"""

sideBySide()

tabs """
gt_ex.opt_stylize(style=1, color="blue")
""", """
gt_ex |> opt_stylize(style = 1, color = "blue")
""":
  nbCode:
    nbTable gtEx.optStylize(style = 1, color = "blue")

tabs """
gt_ex.opt_stylize(style=2, color="red")
""", """
gt_ex |> opt_stylize(style = 2, color = "red")
""":
  nbCode:
    nbTable gtEx.optStylize(style = 2, color = "red")

endSideBySide()

nbText: """
Notice that first table (blue) emphasizes the row labels with a solid background color. The second table (red) emphasizes the column labels, and uses solid lines to separate the body cell values. See `GT.opt_stylize()` for all available color options.
"""

tabelline """
tabelline's styles are its own, after gt's: style 1 stripes the rows, style 2 fills the header
and the column labels, style 3 tints the column labels and stripes the rows. Making them match
gt's six is a gap.
"""

nbText: """
There are six styles available, each emphasizing different table parts. The `style=` values are numbered from `1` to `6`:
"""

tabs """
class Styles:
    # the six styles side by side, as the original lays them out in its page
    def _repr_html_(self):
        cells = "".join(
            f"<div><div style='text-align:center;'>{ii}</div>{gt_ex.opt_stylize(style=ii).as_raw_html()}</div>"
            for ii in range(1, 7)
        )
        return f"<div class='tb-styles'>{cells}</div>"

Styles()
""", """
# the six styles side by side, as the original lays them out in its page
cells <- vapply(1:6, function(ii) {
  paste0("<div><div style='text-align:center;'>", ii, "</div>",
         as_raw_html(opt_stylize(gt_ex, style = ii), inline_css = FALSE), "</div>")
}, "")

htmltools::HTML(paste0("<div class='tb-styles'>", paste(cells, collapse = ""), "</div>"))
""":
  nbCode:
    var cells = ""
    for ii in 1 .. 3:
      cells.add "<div><div style='text-align:center;'>" & $ii & "</div>" &
                nb.tableHtml(gtEx.optStylize(style = ii)) & "</div>"
    nbRawHtml "<div class='tb-styles'>" & cells & "</div>"

nbText: """
## `opt_*()` convenience methods

This section shows the different `opt_*()` methods available. They serve as convenience methods for common `GT.tab_options()` tasks.

### Align table header
"""

tabs """
gt_ex.opt_align_table_header(align="left")
""", """
gt_ex |> opt_align_table_header(align = "left")
""":
  nbCode:
    nbTable gtEx.optAlignTableHeader(align = "left")

nbText: """
### Make text ALL CAPS
"""

tabs """
gt_ex.opt_all_caps()
""", """
gt_ex |> opt_all_caps()
""":
  nbCode:
    nbTable gtEx.optAllCaps()

tabelline """
gt's `opt_all_caps()` puts the column labels, the stub and the row group labels in capitals;
tabelline's, the column labels only, for now.
"""

nbText: """
### Reduce or expand padding
"""

sideBySide()

tabs """
gt_ex.opt_vertical_padding(scale=0.3)
""", """
gt_ex |> opt_vertical_padding(scale = 0.3)
""":
  nbCode:
    nbTable gtEx.optVerticalPadding(scale = 0.3)

tabs """
gt_ex.opt_horizontal_padding(scale=3)
""", """
gt_ex |> opt_horizontal_padding(scale = 3)
""":
  nbCode:
    nbTable gtEx.optHorizontalPadding(scale = 3)

endSideBySide()

nbText: """
### Set table outline
"""

tabs """
gt_ex.opt_table_outline()
""", """
gt_ex |> opt_table_outline()
""":
  nbCode:
    nbTable gtEx.optTableOutline()

bookSave()
