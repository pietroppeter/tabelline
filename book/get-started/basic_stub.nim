import tabbook
bookInit()

nbText: "# Stub (Row Labels)"

attribution gtGuide("Stub (Row Labels)", "basic-stub",
  "The row groups are added to the data in Nim with `addColumn`.")

nbText: """
The **Stub** component of a table is the area to the left that typically contains *row labels* and may also contain *row group labels*. Those subparts can be grouped in a sequence of *row groups*. The **Stub Head** provides a location for a label that describes the **Stub** (and could also be used to describe the column labels). The **Stub** is optional since there are cases where a **Stub** wouldn't be useful (the display tables presented in the previous section looked just fine without a **Stub**).

## Row names

An easy way to generate a **Stub** part is by specifying a stub column in the `GT()` class with the `rowname_col=` argument. This will signal to **Great Tables** that the named column should be used as the stub, using the contents of that column to make *row labels*. Let's add a stub with our `islands` dataset by using `rowname_col=` in the call to `GT`:
"""

tabs """
from great_tables import GT, md, html
from great_tables.data import islands

islands_mini = islands.head(10)

GT(islands_mini).tab_stub(rowname_col="name")
""", """
library(gt)
library(dplyr)

islands_tbl <- tibble(name = names(islands), size = islands)
islands_mini <- islands_tbl |> slice_head(n = 10)

# gt has no tab_stub(): the stub is chosen when the table is made
gt(islands_mini, rowname_col = "name")
""":
  nbCode:
    import tabelline, gtdata
    import std/sequtils

    let islandsMini = islands().head(10)

    nbTable tabella(islandsMini, rownameCol = "name")

tabelline """
tabelline has no `tabStub` verb yet: the stub is chosen when the table is made, with
`tabella(data, rownameCol = ...)`, Great Tables' convenience arguments at the end of this
page. A `tabStub` verb is a gap.
"""

nbText: """
Notice that the landmass names are now placed to the left? That's the **Stub**. Notably, there is a prominent border to the right of it but there's no label above the **Stub**. We can change this and apply what's known as a *stubhead label* through use of the `GT.tab_stubhead()` method:
"""

tabs """
(
    GT(islands_mini)
    .tab_stub(rowname_col="name")
    .tab_stubhead(label="landmass")
)
""", """
gt(islands_mini, rowname_col = "name") |>
  tab_stubhead(label = "landmass")
""":
  nbCode:
    let withStubhead = tabella(islandsMini, rownameCol = "name"):
      tabStubhead "landmass"
    nbTable withStubhead

nbText: """
A very important thing to note here is that the table now has one column. Before, when there was no **Stub**, two columns were present (with the **Column Labels** of `"name"` and `"size"`) but now column number `1` (the only column remaining) is `size`.

## Row groups

Let's incorporate row groups into the display table. This divides rows into groups, creating *row groups*, and results in a display of a *row group labels* right above the each group. This can be easily done with a table containing row labels and the key is to use the `groupname_col=` argument of the `GT` class. Here we will create three row groups (with row group labels `"continent"`, `"country"`, and `"subregion"`) to have a grouping of rows.
"""

tabs """
island_groups = islands.head(10).assign(group = ["subregion"] * 2 + ["country"] * 2 + ["continent"] * 6)

(
    GT(island_groups)
    .tab_stub(rowname_col="name", groupname_col="group")
    .tab_stubhead(label="landmass")
)
""", """
island_groups <- islands_mini |>
  mutate(group = c(rep("subregion", 2), rep("country", 2), rep("continent", 6)))

gt(island_groups, rowname_col = "name", groupname_col = "group") |>
  tab_stubhead(label = "landmass")
""":
  nbCode:
    let islandGroups = islands().head(10)
    islandGroups.addColumn("group", toValues(
      @["subregion", "subregion", "country", "country"] & newSeqWith(6, "continent")))

    let grouped = tabella(islandGroups, rownameCol = "name", groupnameCol = "group"):
      tabStubhead "landmass"
    nbTable grouped

nbText: """
## GT convenience arguments

Rather than using the `GT.tab_stub()` method, the `GT(rowname_col=..., groupname_col=...)` arguments
provide a quick way to specify row names and groups.
"""

tabs """
GT(island_groups, rowname_col="name", groupname_col="group")
""", """
gt(island_groups, rowname_col = "name", groupname_col = "group")
""":
  nbCode:
    nbTable tabella(islandGroups, rownameCol = "name", groupnameCol = "group")

bookSave()
