import tabbook
bookInit()

nbText: "# Great Tables `v0.13.0`: Applying styles to all table locations"

attribution gtBlog("Great Tables v0.13.0: Applying styles to all table locations",
  "introduction-0.13.0/", "Rich Iannone and Michael Chow", "10 Oct 2024",
  "The first table shows its code, which the post folds away; the map of the locations is " &
  "the post's own figure.")

nbText: """
We did something in Great Tables (`0.13.0`) that'll make your tables that much more customizable: super *fine-grained* ways of setting styles throughout the table. Before you were largely constrained to styling through the following strategies:

1. use a limited set of styles (e.g., background color, font weight, etc.) to different table locations like the stub, the column labels, etc., through `tab_options()`
2. use `tab_style()` with a larger set of styling options for the table body cells (specified by `loc.body()`)

In `v0.13.0`, we can target much more than just the table body! Here is the expanded set of `loc.*()` methods along with the locations that they can target.

![The locations of a table and the loc methods that target them](../images/GT-locations-map.png)

This augmentation of the `loc` module to include all locations in the table means that there won't be a spot in the table to which you can't add styling. This is terrific because it gives you free rein to fully customize the look of your table.

Let's make a table and see how this new feature could be used.

### Starting things off with a big GT table

The table we'll make uses the `nuclides` dataset (available in the `great_tables.data` module). Through use of the `tab_*()` methods, quite a few table components (hence *locations*) will be added. We have hidden the code here because it is quite lengthy but you're encouraged to check it out to glean some interesting GT tricks.
"""

tabs """
from great_tables import GT, md, style, loc, google_font
from great_tables.data import nuclides
import polars as pl
import polars.selectors as cs

nuclides_mini = (
    pl.from_pandas(nuclides)
    .filter(pl.col("element") == "C")
    .with_columns(pl.col("nuclide").str.replace(r"[0-9]+$", ""))
    .with_columns(mass_number=pl.col("z") + pl.col("n"))
    .with_columns(
        isotope=pl.concat_str(pl.col("element") + "-" + pl.col("mass_number").cast(pl.String))
    )
    .select(["isotope", "atomic_mass", "half_life", "isospin", "decay_1", "decay_2", "decay_3"])
)

gt_tbl = (
    GT(nuclides_mini, rowname_col="isotope")
    .tab_header(
        title="Isotopes of Carbon",
        subtitle="There are two stable isotopes of carbon and twelve that are unstable.",
    )
    .tab_spanner(label="Decay Mode", columns=cs.starts_with("decay"))
    .tab_source_note(md("Data obtained from the *nuclides* dataset."))
    .tab_stubhead(label="Isotope")
    .fmt_scientific(columns="half_life")
    .fmt_number(
        columns="atomic_mass",
        decimals=4,
        scale_by=1 / 1e6,
    )
    .sub_missing(columns="half_life", missing_text=md("**STABLE**"))
    .sub_missing(columns=cs.starts_with("decay"))
    .cols_label(
        atomic_mass="Atomic Mass",
        half_life="Half Life, s",
        isospin="Isospin",
        decay_1="1",
        decay_2="2",
        decay_3="3",
    )
    .cols_align(align="center", columns=[cs.starts_with("decay"), "isospin"])
    .opt_align_table_header(align="left")
    .opt_table_font(font=google_font(name="IBM Plex Sans"))
    .opt_vertical_padding(scale=0.5)
    .opt_horizontal_padding(scale=2)
)

gt_tbl
""", """
library(gt)
library(dplyr)

nuclides_mini <-
  nuclides |>
  filter(element == "C") |>
  mutate(mass_number = z + n) |>
  mutate(isotope = paste0(element, "-", mass_number)) |>
  select(isotope, atomic_mass, half_life, isospin, decay_1, decay_2, decay_3)

gt_tbl <-
  nuclides_mini |>
  gt(rowname_col = "isotope") |>
  tab_header(
    title = "Isotopes of Carbon",
    subtitle = "There are two stable isotopes of carbon and twelve that are unstable."
  ) |>
  tab_spanner(label = "Decay Mode", columns = starts_with("decay")) |>
  tab_source_note(md("Data obtained from the *nuclides* dataset.")) |>
  tab_stubhead(label = "Isotope") |>
  fmt_scientific(columns = half_life) |>
  fmt_number(columns = atomic_mass, decimals = 4, scale_by = 1 / 1e6) |>
  sub_missing(columns = half_life, missing_text = md("**STABLE**")) |>
  sub_missing(columns = starts_with("decay")) |>
  cols_label(
    atomic_mass = "Atomic Mass",
    half_life = "Half Life, s",
    isospin = "Isospin",
    decay_1 = "1",
    decay_2 = "2",
    decay_3 = "3"
  ) |>
  cols_align(align = "center", columns = c(starts_with("decay"), isospin)) |>
  opt_align_table_header(align = "left") |>
  opt_table_font(font = google_font(name = "IBM Plex Sans")) |>
  opt_vertical_padding(scale = 0.5) |>
  opt_horizontal_padding(scale = 2)

gt_tbl
""":
  nbCode:
    import std/streams
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    let nuclides = readCsv(newStringStream(nuclidesCsv), inferSchemaLength = 10_000)
    let nuclidesMini = nuclides
      .filter(col("element") == "C")
      .withColumns(col("nuclide").str.replace(r"[0-9]+$", ""))
      .withColumns((col("z") + col("n")).alias("mass_number"))
      .withColumns(concatStr([col("element"), lit("-"), col("mass_number").`cast`(String)])
                     .alias("isotope"))
      .select("isotope", "atomic_mass", "half_life", "isospin", "decay_1", "decay_2", "decay_3")

    let stable = where(it["half_life"].isNull)  # the rows of the stable isotopes

    var gtTbl = tabella(nuclidesMini, rownameCol = "isotope"):
      tabHeader title = "Isotopes of Carbon",
        subtitle = "There are two stable isotopes of carbon and twelve that are unstable."
      tabSpanner "Decay Mode", startsWith("decay")
      tabSourceNote md"Data obtained from the *nuclides* dataset."
      tabStubhead "Isotope"
      fmtScientific "half_life"
      fmtNumber "atomic_mass", decimals = 4, scaleBy = 1 / 1e6
      subMissing "half_life", missingText = "STABLE"
      tabStyle style.text(weight = "bold"), loc.body(cols = "half_life", rows = stable)
      subMissing startsWith("decay")
      colsLabel:
        atomic_mass: "Atomic Mass"
        half_life: "Half Life, s"
        isospin: "Isospin"
        decay_1: "1"
        decay_2: "2"
        decay_3: "3"
      colsAlign alCenter, startsWith("decay") + "isospin"
      optAlignTableHeader "left"
      optTableFont "\"IBM Plex Sans\", " & systemFonts("neo-grotesque")
      optVerticalPadding 0.5
      optHorizontalPadding 2
    nbTable gtTbl

tabelline """
`subMissing` takes plain text, not Markdown as `md("**STABLE**")`: the table writes STABLE and
makes it bold with a style on the same cells. `where(it["half_life"].isNull)` picks the rows of
the stable isotopes, the condition the post writes later as `pl.col("half_life").is_null()`;
`startsWith("decay") + "isospin"` adds a column to a selector, as the list does in Python. A font
from Google Fonts is asked for by name, with a stack of the reader's own fonts after it: the book
loads nothing from other sites (see [v0.12.0](v0_12.html)). The data steps are written with
[nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim. The R tab leaves out the
`str.replace` of `nuclide`, a column the table does not show.
"""

nbText: """
This table will serve as a great starting point for demonstrating all the things you can now do with `tab_style()`. And the following checklist will serve as a rough plan for how we will style the table:

- use `loc.body()` to emphasize isotope half-life values
- employ `loc.stub()` to draw attention to isotope names (and also point out the 'STABLE' rows)
- use `style.css()` for creating custom CSS styles (e.g., to indent row labels for stable isotopes)
- work with composite locations and style the whole header and footer quite simply
- set the default table body fill with `tab_options()`

Really this'll be `tab_style()` like you've never seen it before, so let's get on with it.

### Styling the body

First, we'll use `loc.body()` to emphasize half life values in two ways:

* Make the values in the `atomic_mass` and `half_life` use a monospace font.
* fill the background of isotopes with STABLE half lives to be PaleTurquoise.
"""

tabs """
gt_tbl = (
    gt_tbl
    .tab_style(
        style=style.text(font=google_font(name="IBM Plex Mono")),
        locations=loc.body(columns=["atomic_mass", "half_life"])
    )
    .tab_style(
        style=[style.text(color="Navy"), style.fill(color="PaleTurquoise")],
        locations=loc.body(columns="half_life", rows=pl.col("half_life").is_not_null())
    )
)

gt_tbl
""", """
gt_tbl <-
  gt_tbl |>
  tab_style(
    style = cell_text(font = google_font(name = "IBM Plex Mono")),
    locations = cells_body(columns = c(atomic_mass, half_life))
  ) |>
  tab_style(
    style = list(cell_text(color = "Navy"), cell_fill(color = "PaleTurquoise")),
    locations = cells_body(columns = half_life, rows = !is.na(half_life))
  )

gt_tbl
""":
  nbCode:
    let unstable = where(not it["half_life"].isNull)
    gtTbl = gtTbl
      .tabStyle(style.text(font = "\"IBM Plex Mono\", " & systemFonts("monospace-code")),
                loc.body(cols = ["atomic_mass", "half_life"]))
      .tabStyle(style.text(color = "Navy") & style.fill("PaleTurquoise"),
                loc.body(cols = "half_life", rows = unstable))
    nbTable gtTbl

tabelline """
Styles join with `&` (a list in Great Tables). A table can be changed after it is made, verb by
verb, as `gt_tbl` is here: `tabella(data): body` is only the way to write the first steps.
"""

nbText: """
Note these important pieces in the code:

* setting monospace font: we used [`google_font()`](https://posit-dev.github.io/great-tables/reference/google_font.html) (added in the previous release) to apply the monospaced font IBM Plex Mono.
* filling unstable half lives to turquoise: because the half life cells with the value STABLE are actually missing in the underlying data, and filled in using `GT.sub_missing()`, we used the polars expression `pl.col("half_life").is_not_null()` to target everything that isn't STABLE.

This is mainly a reminder that Polars expressions are quite something. And targeting cells in the body with `loc.body(rows=...)` can be powerful by extension.

### Don't forget the stub!

We mustn't forget the stub. It's a totally separate location, being off to the side and having the important responsibility of holding the row labels. Here, we are going to do two things:

1. Change the fill color (to 'Linen') and make the text bold for the *entire stub*
2. Highlight the rows where we have stable isotopes (the extent is both for the stub and the body cells)
"""

tabs """
gt_tbl = (
    gt_tbl
    .tab_style(
        style=[style.fill(color="Linen"), style.text(weight="bold")],
        locations=loc.stub()
    )
    .tab_style(
        style=style.fill(color="LightCyan"),
        locations=[
            loc.body(rows=pl.col("half_life").is_null()),
            loc.stub(rows=pl.col("half_life").is_null())
        ]
    )
 )

gt_tbl
""", """
gt_tbl <-
  gt_tbl |>
  tab_style(
    style = list(cell_fill(color = "Linen"), cell_text(weight = "bold")),
    locations = cells_stub()
  ) |>
  tab_style(
    style = cell_fill(color = "LightCyan"),
    locations = list(
      cells_body(rows = is.na(half_life)),
      cells_stub(rows = is.na(half_life))
    )
  )

gt_tbl
""":
  nbCode:
    gtTbl = gtTbl
      .tabStyle(style.fill("Linen") & style.text(weight = "bold"), loc.stub())
      .tabStyle(style.fill("LightCyan"), loc.body(rows = stable), loc.stub(rows = stable))
    nbTable gtTbl

nbText: """
For task #1, a simple `.tab_style(..., locations=loc.stub())` targeted the entire stub.

Task #2 is more interesting. Like `loc.body()`, `loc.stub()` has a `rows=` argument that can  target specific rows with Polars expressions. We used the same Polars expression as in the previous section to target those rows that belong to the stable isotopes.

We've dressed up the stub so that it is that much more prominent. And that linen-colored stub goes so well with the light-cyan rows, representative of carbon-12 and carbon-13!

### Using custom style rules with the new `style.css()`

Aside from decking out the `loc` module with all manner of location methods, we've added a little something to the `style` module: `style.css()`! What's it for? It lets you supply style declarations to its single `rule=` argument.

As an example, I might want to indent some text in one or more table cells. You can't really do that with the `style.text()` method since it doesn't have an `indent=` argument. So, in Great Tables `0.13.0` you can manually indent the row label text for the 'STABLE' rows using a CSS style rule:
"""

tabs """
gt_tbl = (
    gt_tbl
    .tab_style(
        style=style.css(rule="text-indent: 4px;"),
        locations=loc.stub(rows=pl.col("half_life").is_null())
    )
)

gt_tbl
""", """
gt_tbl <-
  gt_tbl |>
  tab_style(
    style = "text-indent: 4px;",
    locations = cells_stub(rows = is.na(half_life))
  )

gt_tbl
""":
  nbCode:
    gtTbl = gtTbl.tabStyle(style.css("text-indent: 4px;"), loc.stub(rows = stable))
    nbTable gtTbl

nbText: """
We targeted the cells in the stub that corresponded to the stable isotopes (carbon-12 and -13) with a Polars expression (same one as in the previous code cell) and now we have a 4px indentation of the 'C-12' and 'C-13' text! This new bonus functionality really allows almost any type of styling possible, provided you have those CSS skillz.

### The *combined* location helpers: `loc.column_header()` and `loc.footer()`

Look, I know we brought up the expression *fine-grained* before---right in the first paragraph---but sometimes you need just the opposite. There are lots of little locations in a GT table and some make for logical groupings. To that end, we have the concept of *combined* location helpers.

Let's set a grey background fill on the stubhead, column header, and footer:
"""

tabs """
gt_tbl = (
    gt_tbl
    .tab_style(
        style=[style.text(v_align="middle"), style.fill(color="#EEEEEE")],
        locations=[loc.stubhead(), loc.column_header(), loc.footer()]
    )
)

gt_tbl
""", """
gt_tbl <-
  gt_tbl |>
  tab_style(
    style = list(cell_text(v_align = "middle"), cell_fill(color = "#EEEEEE")),
    locations = list(cells_stubhead(), cells_column_spanners(), cells_column_labels(),
                     cells_footnotes(), cells_source_notes())
  )

gt_tbl
""":
  nbCode:
    gtTbl = gtTbl.tabStyle(style.css("vertical-align: middle") & style.fill("#EEEEEE"),
                           loc.stubhead(), loc.columnHeader(), loc.footer())
    nbTable gtTbl

tabelline """
`style.text` has no `vAlign`: `style.css("vertical-align: middle")` says the same. gt has no
combined locations, so the R tab lists the parts.
"""

nbText: """
The [`loc.column_header()`](https://posit-dev.github.io/great-tables/reference/loc.column_header.html) location always targets both `loc.column_labels()` and `loc.spanner_labels()`.

A good strategy for your tables would be to style with combined location helpers first and then drill into the specific cells of those super locations with more fine-grained styles in a later `tab_style()` call.

### Styling the title and the subtitle

Although it really doesn't appear to have separate locations, the table header (produced by way of `tab_header()`) can have two of them: the title and the subtitle (the latter is optional). These can be targeted via `loc.title()` and `loc.subtitle()`. Let's focus in on the title location and set an aliceblue background fill on the title, along with some font and border adjustments.
"""

tabs """
gt_tbl = (
    gt_tbl
    .tab_style(
        style=[
            style.text(size="24px"),
            style.fill(color="aliceblue"),
            style.borders(sides="bottom", color="#BFDFF6", weight="2px")
        ],
        locations=loc.title()
    )
)

gt_tbl
""", """
gt_tbl <-
  gt_tbl |>
  tab_style(
    style = list(
      cell_text(size = px(24)),
      cell_fill(color = "aliceblue"),
      cell_borders(sides = "bottom", color = "#BFDFF6", weight = px(2))
    ),
    locations = cells_title(groups = "title")
  )

gt_tbl
""":
  nbCode:
    gtTbl = gtTbl.tabStyle(
      style.text(size = "24px") & style.fill("aliceblue") &
        style.borders(sides = {sBottom}, color = "#BFDFF6", weight = "2px"),
      loc.title())
    nbTable gtTbl

nbText: """
Looks good. Notice that the title location is separate from the subtitle one, the background fill reveals the extent of its area.

A subtitle is an optional part of the header. We do have one in our table example, so let's style that as well. The `style.css()` method will be used to give the subtitle text some additional top and bottom padding, and, we'll put in a fancy background involving a linear gradient.
"""

tabs """
gt_tbl = (
    gt_tbl
    .tab_style(
        style=style.css(rule="padding-top: 5px;"
            "padding-bottom: 5px;"
            "background-image: linear-gradient(120deg, #d4fc79 0%, #96f6a1 100%);"
        ),
        locations=loc.subtitle()
    )
)

gt_tbl
""", """
gt_tbl <-
  gt_tbl |>
  tab_style(
    style = paste0(
      "padding-top: 5px;",
      "padding-bottom: 5px;",
      "background-image: linear-gradient(120deg, #d4fc79 0%, #96f6a1 100%);"
    ),
    locations = cells_title(groups = "subtitle")
  )

gt_tbl
""":
  nbCode:
    gtTbl = gtTbl.tabStyle(
      style.css("padding-top: 5px;" &
        "padding-bottom: 5px;" &
        "background-image: linear-gradient(120deg, #d4fc79 0%, #96f6a1 100%);"),
      loc.subtitle())
    nbTable gtTbl

nbText: """
None of what was done above could be done prior to `v0.13.0`. The `style.css()` method makes this all possible.

The combined location helper for the title and the subtitle locations is `loc.header()`. As mentioned before, it can be used as a shorthand for `locations=[loc.title(), loc_subtitle()]` and it's useful here where we want to change the font for the title and subtitle text.
"""

tabs """
gt_tbl = (
    gt_tbl
    .tab_style(
        style=style.text(font=google_font("IBM Plex Serif")),
        locations=loc.header()
    )
)

gt_tbl
""", """
gt_tbl <-
  gt_tbl |>
  tab_style(
    style = cell_text(font = google_font("IBM Plex Serif")),
    locations = cells_title()
  )

gt_tbl
""":
  nbCode:
    gtTbl = gtTbl.tabStyle(style.text(font = "\"IBM Plex Serif\", " & systemFonts("transitional")),
                           loc.header())
    nbTable gtTbl

nbText: """
Though the order of things matters when setting styles via `tab_style()`, it's not a problem here to set a style for the combined 'header' location after doing so for the 'title' and 'subtitle' locations because the 'font' attribute *wasn't* set by `tab_style()` for those smaller locations.

### How `tab_style()` fits in with `tab_options()`

When it comes to styling, you can use `tab_options()` for some of the basics and use `tab_style()` for the more demanding styling tasks. And you could combine the usage of both in your table. Let's set a default honeydew background fill on the body values:
"""

tabs """
gt_tbl = gt_tbl.tab_options(table_background_color="HoneyDew")

gt_tbl
""", """
gt_tbl <- gt_tbl |> tab_options(table.background.color = "HoneyDew")

gt_tbl
""":
  nbCode:
    gtTbl = gtTbl.tabOptions(tableBackgroundColor = "HoneyDew")
    nbTable gtTbl

nbText: """
In the example, we asked for the HoneyDew background fill on the entire table with `tab_options()`. However, even though `tab_options()` was used after those `tab_style()` invocations, the 'HoneyDew' background color was only applied to the locations that didn't have a background color set through `tab_style(). The important takeaway here is that the precedence (or priority) is *always* given to `tab_style()`, regardless of the order of invocation.

### Wrapping up

We'd like to thank [Tim Paine](https://github.com/timkpaine) for getting the expanded `loc` work off the ground. Additionally, we are grateful to [Jerry Wu](https://github.com/jrycw) for his contributions to the `v0.13.0` release of the package.

We'd be very pleased to receive comments or suggestions on the new functionality. [GitHub Issues](https://github.com/posit-dev/great-tables/issues) or [GitHub Discussions](https://github.com/posit-dev/great-tables/discussions) are both fine venues for getting in touch with us. Finally, if ever you want to talk about tables with us, you're always welcome to jump into our [Discord Server](https://discord.com/invite/Ux7nrcXHVV).
"""

bookSave()
