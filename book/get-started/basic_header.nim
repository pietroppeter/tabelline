import tabbook
bookInit()

nbText: "# Header and Footer"

attribution gtGuide("Header and Footer", "basic-header", "")

nbText: """
The way that we add components like the **Table Header** and *source notes* in the **Table Footer** is to use the `tab_*()` family of methods. A **Table Header** is easy to add so let's see how the previous table looks with a *title* and a *subtitle*. We can add this component using the `GT.tab_header()` method:
"""

tabs """
from great_tables import GT, md, html
from great_tables.data import islands

islands_mini = islands.head(10)

# Make a display table with the `islands_tbl` table;
# put a heading just above the column labels
(
    GT(islands_mini)
    .tab_header(
        title = "Large Landmasses of the World",
        subtitle = "The top ten largest are presented"
    )
)
""", """
library(gt)
library(dplyr)

islands_tbl <- tibble(name = names(islands), size = islands)
islands_mini <- islands_tbl |> slice_head(n = 10)

# Make a display table with the `islands_tbl` table;
# put a heading just above the column labels
gt(islands_mini) |>
  tab_header(
    title = "Large Landmasses of the World",
    subtitle = "The top ten largest are presented"
  )
""":
  nbCode:
    import tabelline, gtdata

    let islandsMini = islands().head(10)

    # Make a display table with the `islands_tbl` table;
    # put a heading just above the column labels
    nbTable tabella(islandsMini).tabHeader(
      title = "Large Landmasses of the World",
      subtitle = "The top ten largest are presented")

nbText: """
The **Header** table component provides an opportunity to describe the data that's presented. Using `subtitle=` allows us to insert a subtitle, which is an optional part of the **Header**. We may also style the `title=` and `subtitle=` using Markdown! We do this by wrapping the values passed to `title=` or `subtitle=` with the `md()` helper function (we may also use `html()` in a similar fashion). Here is an example with the table data truncated for brevity:
"""

tabs """
# Make a display table with the `islands_tbl` table;
# put a heading just above the column labels
gt_tbl = (
    GT(islands.head(2))
    .tab_header(
        title = md("Large Landmasses of the *World* &#x1F310;"),
        subtitle = md("The top **ten** largest are presented")
    )
)

gt_tbl
""", """
# Make a display table with the `islands_tbl` table;
# put a heading just above the column labels
gt_tbl <- gt(islands_tbl |> slice_head(n = 2)) |>
  tab_header(
    title = md("Large Landmasses of the *World* &#x1F310;"),
    subtitle = md("The top **ten** largest are presented")
  )

gt_tbl
""":
  nbCode:
    # Make a display table with the `islands_tbl` table;
    # put a heading just above the column labels
    let gtTbl = tabella(islands().head(2)).tabHeader(
      title = md("Large Landmasses of the *World* 🌐"),
      subtitle = md("The top **ten** largest are presented"))

    nbTable gtTbl

tabelline """
tabelline's `md()` is a small inline Markdown (emphasis, code, links, `~sub~`, `^sup^`), with
no HTML entities: Nim strings are UTF-8, so the globe goes in as it is. The full Markdown of
gt (lists, entities, and the rest of CommonMark) is a gap.
"""

nbText: """
A *source note* can be added to the table's **Footer** through use of the `GT.tab_source_note()` method. It works in the same way as `GT.tab_header()` (it also allows for Markdown inputs) except it can be called multiple times---each invocation results in the addition of a source note.
"""

tabs """
# Display the `islands_tbl` data with a heading and two source notes
(
    gt_tbl
    .tab_source_note(
        source_note = "Source: The World Almanac and Book of Facts, 1975, page 406."
    )
    .tab_source_note(
        source_note = md("Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley.")
    )
)
""", """
# Display the `islands_tbl` data with a heading and two source notes
gt_tbl |>
  tab_source_note(
    source_note = "Source: The World Almanac and Book of Facts, 1975, page 406."
  ) |>
  tab_source_note(
    source_note = md("Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley.")
  )
""":
  nbCode:
    # Display the `islands_tbl` data with a heading and two source notes
    nbTable gtTbl
      .tabSourceNote("Source: The World Almanac and Book of Facts, 1975, page 406.")
      .tabSourceNote(md("Reference: McNeil, D. R. (1977) *Interactive Data Analysis*. Wiley."))

bookSave()
