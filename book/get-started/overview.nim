import tabbook
bookInit()

nbText: "# Overview"

attribution gtGuide("Overview", "overview", "The figure is the original's.")

nbText: """
## Adding Parts to this Simple Table

The **Great Tables** package makes it relatively easy to add components so that the resulting output table better conveys the information you want to present. These table components work well together and the possible variations in arrangement can handle even the most demanding table presentation needs. The previous output table we showed had only two components: the **Column Labels** and the **Table Body**. The next few examples will show all of the other table parts that are available.

This is the way the main parts of a table (and their subparts) fit together:

![The parts of a table](../images/gt_parts_of_a_table.svg)

The components (roughly from top to bottom) are:

- the **Table Header** (optional; with a **title** and possibly a **subtitle**)
- the **Stub** and the **Stub Head** (optional; contains *row labels*, optionally within *row groups* having *row group labels*)
- the **Column Labels** (contains *column labels*, optionally under *spanner labels*)
- the **Table Body** (contains *columns* and *rows* of *cells*)
- the **Table Footer** (optional; possibly with one or more **source notes**)
"""

tabelline """
tabelline has the same parts, with the same names, and the same verbs to add them, in
camelCase: `tabHeader`, `tabStubhead`, `tabSpanner`, `tabSourceNote`, `tabFootnote`. Its
[explainer](https://pietroppeter.github.io/tabelline/explainer/) draws every part of a table in
its own colour. Two small differences: the footer has *footnotes* too, marked in the table
(`tabFootnote`, in gt and Great Tables as well), and a table can also be printed as text, where
the same parts are drawn with box characters.
"""

nbCode:
  import tabelline, tabelline/datasets
  let parts = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    tabHeader "The planets", "of the Solar System"
    tabStubhead "planet"
    colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
    tabSpanner "Size", ["mass", "diameter"]
    tabFootnote "As of 2024.", loc.columnLabels("moons")
    tabSourceNote "NASA Planetary Fact Sheet"
  echo parts

bookSave()
