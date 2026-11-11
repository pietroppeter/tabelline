import tabbook
bookInit()

nbText: "# Great Tables `v0.3.0`: So Many Style Options!"

attribution gtBlog("Great Tables v0.3.0: So Many Style Options!", "introduction-0.3.0/", "Rich Iannone",
  "16 Feb 2024", "The links to Great Tables' reference pages are kept; `warnings.filterwarnings` " &
  "is left out of the R and Nim tabs.")

nbText: """
As our work on **Great Tables** continues, we want you to be able to produce increasingly sophisticated tables. The look of an HTML table really matters and we believe aesthetics can elevate the presentation of tabular data. In the `v0.3.0` release, we've implemented features that are concerned with modifying the visual aspects of a table. Let's get down to what's new in this version.

### Modifying the widths of columns

Before `v0.3.0`, you could not alter the widths of individual columns. This meant that to great extent your content decided the width of individual columns. Even though browsers do an adequate job in sizing the widths of table columns, it doesn't always result in a pleasing-to-look-at table. What if you want more space? Maybe you want consistently-sized columns? There's many reasons to want to have a choice in the matter and the new [`cols_width()`](https://posit-dev.github.io/great-tables/reference/GT.cols_width.html) method now makes this possible.

Here's an example where the widths of all columns are set with our preferred length values (in `px`).
"""

tabs """
import warnings
from great_tables import GT, exibble

warnings.filterwarnings("ignore")
exibble_mini = exibble[["num", "char", "date", "datetime", "row"]].head(5)

(
    GT(exibble_mini).cols_width(
        cases={
            "num": "30px",
            "char": "100px",
            "date": "150px",
            "datetime": "200px",
            "row": "50px"
        }
    )
)
""", """
library(gt)
library(dplyr)

exibble_mini <- exibble |> select(num, char, date, datetime, row) |> head(5)

gt(exibble_mini) |>
  cols_width(
    num ~ px(30),
    char ~ px(100),
    date ~ px(150),
    datetime ~ px(200),
    row ~ px(50)
  )
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    let exibbleMini = exibble().select(["num", "char", "date", "datetime", "row"]).head(5)

    let widths = tabella(exibbleMini):
      colsWidth:
        num: "30px"
        char: "100px"
        date: "150px"
        datetime: "200px"
        row: "50px"
    nbTable widths

tabelline """
`colsWidth` takes its pairs as a block, one column per line, as `colsLabel` does. On a phone
the table is wider than the screen and scrolls sideways inside its box.
"""

nbText: """
You don't have to define widths for all columns with [`cols_width()`](https://posit-dev.github.io/great-tables/reference/GT.cols_width.html), and you're free to use either `px` or `%` values when defining widths. See the [reference page](https://posit-dev.github.io/great-tables/reference/GT.cols_width.html) for more information and relevant examples.

### Setting options across the entire table with `tab_options()`

The new [`tab_options()`](https://posit-dev.github.io/great-tables/reference/GT.tab_options.html) method gives you the freedom to specify any of dozens of global style and layout options for the table. Want a font that's used across all cells? Use the `table_font_names=` option. Do you need to make the text smaller, but only in the stub? Use `stub_font_size=` for that. The number of options is perhaps overwhelming at first but we think you'll enjoy having them around nonetheless. It makes styling the table (and developing your own table themes) a relatively simple task.

Here's an example that creates a table with a few common components and then uses [`tab_options()`](https://posit-dev.github.io/great-tables/reference/GT.tab_options.html) to set up a collection of fonts for the table with the (also new) [`system_fonts()`](https://posit-dev.github.io/great-tables/reference/system_fonts.html) function:
"""

tabs """
from great_tables import md, system_fonts

gt_tbl = (
    GT(
        exibble[["num", "char", "currency", "row", "group"]],
        rowname_col="row",
        groupname_col="group",
    )
    .tab_header(
        title=md("Data listing from **exibble**"),
        subtitle=md("`exibble` is a **Great Tables** dataset."),
    )
    .fmt_number(columns="num")
    .fmt_currency(columns="currency")
    .tab_source_note(source_note="This is only a subset of the dataset.")
)

gt_tbl.tab_options(table_font_names=system_fonts(name="industrial"))
""", """
gt_tbl <-
  exibble |>
  select(num, char, currency, row, group) |>
  gt(rowname_col = "row", groupname_col = "group") |>
  tab_header(
    title = md("Data listing from **exibble**"),
    subtitle = md("`exibble` is a **gt** dataset.")
  ) |>
  fmt_number(columns = num) |>
  fmt_currency(columns = currency) |>
  tab_source_note(source_note = "This is only a subset of the dataset.")

gt_tbl |> opt_table_font(stack = "industrial")
""":
  nbCode:
    let gtTbl = tabella(exibble().select(["num", "char", "currency", "row", "group"]),
                        rownameCol = "row", groupnameCol = "group"):
      tabHeader title = md"Data listing from **exibble**",
        subtitle = md"`exibble` is a **Great Tables** dataset."
      fmtNumber "num"
      fmtCurrency "currency"
      tabSourceNote "This is only a subset of the dataset."

    let industrialTbl = tabella(gtTbl):
      tabOptions tableFontNames = systemFonts("industrial")
    nbTable industrialTbl

tabelline """
`systemFonts("industrial")` is Great Tables' *industrial* stack, as `system_fonts()` gives it. A table already made takes more verbs with `tabella(gtTbl): body`, and `gtTbl`
itself stays as it was, so each example below starts from it again.
"""

nbText: """
Note that `table_font_names=` accepts a list of fonts that operate as fallbacks for users across different systems (i.e., they may not have the font you have). And the [`system_fonts()`](https://posit-dev.github.io/great-tables/reference/system_fonts.html) helper function in **Great Tables** makes this easy by providing you with themed, local font stacks that are meant to work across different computing platforms.

Here's another example where we set the width of the table to span across the entire page (or containing element).
"""

tabs """
gt_tbl.tab_options(table_width="100%")
""", """
gt_tbl |> tab_options(table.width = pct(100))
""":
  nbCode:
    let fullWidth = tabella(gtTbl):
      tabOptions tableWidth = "100%"
    nbTable fullWidth

nbText: """
One more where the background color of the table is set to `"lightcyan"`:
"""

tabs """
gt_tbl.tab_options(table_background_color="lightcyan")
""", """
gt_tbl |> tab_options(table.background.color = "lightcyan")
""":
  nbCode:
    let lightcyan = tabella(gtTbl):
      tabOptions tableBackgroundColor = "lightcyan"
    nbTable lightcyan

nbText: """
There are many more options available in [`tab_options()`](https://posit-dev.github.io/great-tables/reference/GT.tab_options.html), so have a look at its [reference page](https://posit-dev.github.io/great-tables/reference/GT.tab_options.html) for more information and useful examples.

### Using the new `opt_*()` methods to do more complex tasks with table options

While [`tab_options()`](https://posit-dev.github.io/great-tables/reference/GT.tab_options.html) is a great method for setting global table options, sometimes you want to set a number of them at once for a combined effect. For that type of operation, we have the `opt_*()` series of methods. A common thing you might do is align the content in the table header, we can make that an easy thing with [`opt_align_table_header()`](https://posit-dev.github.io/great-tables/reference/GT.opt_align_table_header.html):
"""

tabs """
gt_tbl.opt_align_table_header(align="left")
""", """
gt_tbl |> opt_align_table_header(align = "left")
""":
  nbCode:
    let leftHeader = tabella(gtTbl):
      optAlignTableHeader "left"
    nbTable leftHeader

nbText: """
With that, you don't have to hunt through the myriad options within [`tab_options()`](https://posit-dev.github.io/great-tables/reference/GT.tab_options.html) to find the two args you need to get the job done.

The [`opt_all_caps()`](https://posit-dev.github.io/great-tables/reference/GT.opt_all_caps.html) method transforms the text within the column labels, the stub, and in all row groups so that we get an all-capitalized (yet somewhat sized down) look that better differentiates the labels from the data. It's rather easy to use, just do this:
"""

tabs """
gt_tbl.opt_all_caps()
""", """
gt_tbl |> opt_all_caps()
""":
  nbCode:
    let allCaps = tabella(gtTbl):
      optAllCaps()
    nbTable allCaps

tabelline """
tabelline's `optAllCaps` sets only the column labels: the stub and the row group labels keep
their case (a gap, in the book's [list](../gaps.html)).
"""

nbText: """
This sets nine options you'd otherwise set in [`tab_options()`](https://posit-dev.github.io/great-tables/reference/GT.tab_options.html) all at once, making life generally easier.

Here's one last example, this time using [`opt_vertical_padding()`](https://posit-dev.github.io/great-tables/reference/GT.opt_vertical_padding.html). You'd use that if you're dissatisfied with the level of top/bottom padding within cells of all locations (e.g., in the table body, in the column labels, etc.). You can either make a table taller or more 'compressed' with a single argument: `scale=`. Here's an example where the amount of vertical padding is reduced, resulting in a table taking up less vertical space.
"""

tabs """
gt_tbl.opt_vertical_padding(scale=0.5)
""", """
gt_tbl |> opt_vertical_padding(scale = 0.5)
""":
  nbCode:
    let compressed = tabella(gtTbl):
      optVerticalPadding 0.5
    nbTable compressed

nbText: """
We have the following methods available in the `opt_*()` family

- [`opt_align_table_header()`](https://posit-dev.github.io/great-tables/reference/GT.opt_align_table_header.html)
- [`opt_all_caps()`](https://posit-dev.github.io/great-tables/reference/GT.opt_all_caps.html)
- [`opt_vertical_padding()`](https://posit-dev.github.io/great-tables/reference/GT.opt_vertical_padding.html)
- [`opt_horizontal_padding()`](https://posit-dev.github.io/great-tables/reference/GT.opt_horizontal_padding.html)

and we plan to add more `opt_*()` methods in future releases.
"""

tabelline """
tabelline has all four, as `optAlignTableHeader`, `optAllCaps`, `optVerticalPadding` and
`optHorizontalPadding`, and the ones Great Tables added later (`optStylize`, `optTableFont`,
`optTableOutline`, `optRowStriping`, ...): see [Premade Themes](../get-started/table_theme_premade.html).
"""

nbText: """
### A new formatting method: `fmt_image()`

Wouldn't it be great to add graphics to your table? The [`fmt_image()`](https://posit-dev.github.io/great-tables/reference/GT.fmt_image.html) method provides an easy way to add image files on disk into table body cells. The cells need to contain some reference to an image file. The `path=` and `file_pattern=` arguments give you some flexibility in defining exactly where the image files live.

Here's an example using the `metro` dataset that's included within **Great Tables**.
"""

tabs """
from great_tables.data import metro
from importlib_resources import files

img_paths = files("great_tables") / "data/metro_images"
metro_mini = metro[["name", "lines", "passengers"]].head(5)

(
    GT(metro_mini)
    .fmt_image(columns="lines", path=img_paths, file_pattern="metro_{}.svg")
    .fmt_integer(columns="passengers")
    .cols_label(
        name="Station",
        lines="Metro Lines",
        passengers="Passengers per Year (2021)"
    )
    .tab_options(table_width="700px")
)
""", """
img_paths <- system.file("metro_svg", package = "gt")

metro |>
  select(name, lines, passengers) |>
  head(5) |>
  gt() |>
  fmt_image(columns = lines, path = img_paths, file_pattern = "metro_{x}.svg") |>
  fmt_integer(columns = passengers) |>
  cols_label(
    name = "Station",
    lines = "Metro Lines",
    passengers = "Passengers per Year (2021)"
  ) |>
  tab_options(table.width = px(700))
""":
  nbCode:
    let metroMini = metro().select(["name", "lines", "passengers"]).head(5)

    let stations = tabella(metroMini):
      fmtImage "lines", path = metroImages, filePattern = "metro_{x}.svg"
      fmtInteger "passengers"
      colsLabel:
        name: "Station"
        lines: "Metro Lines"
        passengers: "Passengers per Year (2021)"
      tabOptions tableWidth = "700px"
    nbTable stations

tabelline """
`metroImages` is the folder of the images, copied into the book with the `metro` data
(`gtdata`). `filePattern` writes the value as `{x}`, as gt does (Great Tables writes `{}`), and
each image is read when the verb is called and put in the page, so the page needs no other file.
"""

nbText: """
Notice that `path=img_paths` specified the folder the images live in, and `file_pattern="metro_{}.svg"` provided a template for converting each value in the `lines` column to an SVG file name.

The [`fmt_image()`](https://posit-dev.github.io/great-tables/reference/GT.fmt_image.html) method supports three kinds of files as inputs, either: (1) complete http/https or local paths to the files; (2) the file names, where a common path can be provided via the `path=` arg; or (3) a fragment of the file name, as shown in the example above.

The package has some graphics stored in the `data/metro_images` directory. They are SVGs and they look *very* nice in the example table!

See the [`fmt_image()`](https://posit-dev.github.io/great-tables/reference/GT.fmt_image.html) reference page for more information on this new method.

### Wrapping up

This `v0.3.0` release has some great new methods that add value to most any table-making endeavor. We also fixed a few bugs along the way so that you'll have a overall smoother experience when building beautiful tables. As ever, we'll work toward more and more improvements to give you more creative possibilities!
"""

bookSave()
