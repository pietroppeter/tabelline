import tabbook
bookInit()

nbText: "# Basic gt Styling Reference"

attribution contestEntry("Basic gt Styling Reference",
  "https://github.com/a-drumm/table-contest-2022/blob/main/gt_styling.qmd",
  "Abigail (a-drumm, 2022), honourable mention", "MIT",
  "https://github.com/a-drumm/table-contest-2022/blob/main/LICENSE",
  "The entry is a reference of gt's styling, made of gt tables: its text and its R code are " &
    "kept (the code was folded away in the original; the book reads its list of options, " &
    "`opts.csv`, from `book/data/contest/gt_styling_opts.csv`). The 👑 tabs are a reference " &
    "of tabelline's styling made the same way: the same tables, with tabelline's names in " &
    "their cells (`style.text(...)`, `tableBodyHlinesColor`), and where tabelline has no " &
    "such argument, the CSS that does it. The 🐍 tabs make the same tables with Great " &
    "Tables, as far as it goes: it has no footnotes yet. Two changes to the R, for gt 1.4: " &
    "`summary_rows(groups = everything())` where the entry had `groups = TRUE`, and the " &
    "label of a summary row is now escaped, so the borders table's coloured label is a " &
    "plain one coloured with `tab_style`.")
nbText: """
`gt` allows for extensive and precise table styling. This is a non-comprehensive quick reference to aid users in easily knowing the basic, common functions and arguments and what they do.

There are two basic styling functions: `tab_style` allows for custom styling of one or more cells and `tab_options` modifies the (150+ provided) options of a table. `gt` continues adding more specific stand-alone styling functions with `opt_*()`, which can be found in its [documentation](https://gt.rstudio.com/index.html).

# `tab_style(gt, style, locations)`

## style =

### `cell_text()`
"""

nbText: """
> **Tip**
>
> Give your hex codes names for easier coding: `peach <- "#f9bc9c"` & `cell_border(color = peach)`
"""

tabs """
import polars as pl
from great_tables import GT, google_font, html, loc, style

peach, yellow, green, purple = "#f9bc9c", "#feef8f", "#9fd28d", "#786895"

c_text = pl.DataFrame(
    [
        ["color =", '"wheat"', '"#9fd28d"', "peach", ""],
        ["font =", 'google_font(name="Merriweather")', '"Garamond"', '"sans-serif"', ""],
        ["size =", "px(8)", '"14px"', '"xx-small"', '"x-large"'],
        ["align =", '"center"', '"left"', '"right"', '"justify"'],
        ["v_align =", '"middle"', '"top"', '"bottom"', ""],
        ["style =", '"normal"', '"italic"', '"oblique"', ""],
        ["weight =", '"bold"', '"lighter"', '"bolder"', "800"],
        ["decorate =", '"line-through"', '"underline"', '"overline"', '"underline overline"'],
        ["transform =", '"uppercase"', '"lowercase"', '"capitalize"', ""],
        ['style.css("text-indent: ...")', '"15px"', '"25px"', '"10%"', ""],
    ],
    schema=["a", "b", "c", "d", "e"],
    orient="row",
)

# each cell styled as it says: (row, column, style)
c_text_styles = [
    (0, "b", style.text(color="wheat", weight="bold")),
    (0, "c", style.text(color="#9fd28d", weight="bold")),
    (1, "b", style.text(font=google_font("Merriweather"), size="8px")),
    (1, "c", style.text(font="Garamond")),
    (1, "d", style.text(font="sans-serif")),
    (2, "b", style.text(size="8px")),
    (2, "c", style.text(size="14px")),
    (2, "d", style.text(size="xx-small")),
    (2, "e", style.text(size="x-large")),
    (3, "b", style.text(align="center")),
    (3, "c", style.text(align="left")),
    (3, "d", style.text(align="right")),
    (3, "e", style.text(align="justify")),
    (4, "b", style.text(v_align="middle")),
    (4, "c", style.text(v_align="top")),
    (4, "d", style.text(v_align="bottom")),
    (5, "b", style.text(style="normal")),
    (5, "c", style.text(style="italic")),
    (5, "d", style.text(style="oblique")),
    (6, "b", style.text(weight="bold")),
    (6, "c", style.text(weight="lighter")),
    (6, "d", style.text(weight="bolder")),
    (6, "e", style.text(weight=800, align="left")),
    (7, "b", style.text(decorate="line-through")),
    (7, "c", style.text(decorate="underline")),
    (7, "d", style.text(decorate="overline")),
    (7, "e", style.text(decorate="underline overline")),
    (8, "b", style.text(transform="uppercase")),
    (8, "c", style.text(transform="lowercase")),
    (8, "d", style.text(transform="capitalize")),
    (9, "b", style.css("text-indent: 15px")),
    (9, "c", style.css("text-indent: 25px")),
    (9, "d", style.css("text-indent: 10%")),
]

c_text_table = (
    GT(c_text, rowname_col="a", id="ctext")
    .tab_options(
        column_labels_hidden=True,
        table_body_hlines_color=peach,
        table_body_hlines_width="1px",
        stub_border_color=green,
        table_body_border_top_color=purple,
        table_body_border_bottom_color=purple,
        table_border_bottom_color=purple,
        data_row_padding="2px",
    )
    .opt_table_font(font=google_font("Roboto"))
    .cols_width({c: "150px" for c in ["a", "b", "c", "d", "e"]})
    # Great Tables 1.1 has no footnotes
    .tab_style(style.text(align="right"), loc.stub())
    .opt_css("#ctext .gt_row { height: 50px; border-bottom-style: none; }")
)
for row, column, s in c_text_styles:
    c_text_table = c_text_table.tab_style(s, loc.body(columns=column, rows=[row]))
c_text_table
""", """
library(tidyverse)
library(gt)


peach <- "#f9bc9c"
yellow <- "#feef8f"
green <- "#9fd28d"
purple <- "#786895"

c <- c(a = "color =", b = "\"wheat\"", c = "\"#9fd28d\"", d = "peach")
f <- c(a = "font =", b = "google_fonts(name = \"Merriweather\")", c = "\"Garamond\"", d = "\"sans-serif\"", e = "default_fonts()")
si <- c(a = "size =", b = "px(8)", c = "\"14px\"", d = "\"xx-small\"", e = "\"x-large\"")
a <- c(a = "align =", b = "\"center\"", c = "\"left\"", d = "\"right\"", e = "\"justify\"") 
v <- c(a = "valign =", b = "\"middle\"", c = "\"top\"", d = "\"bottom\"")
st <- c(a = "style =", b = "\"normal\"", c = "\"italic\"", d = "\"oblique\"")
w <- c(a = "weight =", b = "\"bold\"", c = "\"lighter\"", d = "\"bolder\"", e = "800")
d <- c(a = "decorate =", b = "\"line-through\"", c = "\"underline\"", d = "\"overline\"", e = "\"underline overline\"")
t <- c(a = "transform =", b = "\"uppercase\"", c = "\"lowercase\"", d = "\"capitalize\"")
i <- c(a = "indent =", b = "px(15)", c = "\"25px\"", d = "pct(10)")


c_text <- bind_rows(c,f,si,a,v,st,w,d,t,i) %>% 
  mutate(across(everything(), ~ replace_na(., "")))

c_text %>% 
  gt(rowname_col = "a", id = "ctext") %>% 
  tab_options(
    column_labels.hidden = TRUE,
    table_body.hlines.color = peach,
    table_body.hlines.width = "1px",
    stub.border.color = green,
    table_body.border.top.color = purple,
    table_body.border.bottom.color = purple,
    table.border.bottom.color = purple,
    data_row.padding = "2px"
  ) %>%
  opt_table_font(font = google_font(name = "Roboto")) %>% 
  cols_width(everything() ~ "150px") %>% 
  tab_footnote(
    footnote = "See above callout tip.",
    locations = cells_body(columns = 4, rows = 1)
  ) %>% 
  tab_footnote(
    footnote = "Number from 1-1000 - only with variable fonts.",
    locations = cells_body(columns = 5, rows = 7)
  ) %>% 
  tab_footnote(
    footnote = "Code must be written in lowercase - example here shows the output.",
    locations = list(cells_body(columns = 2, rows = 9),
                     cells_body(columns = 4, rows = 9))
  ) %>% 
  tab_style(
    locations = cells_stub(),
    style = cell_text(align = "right")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 1),
    style = cell_text(color = "wheat", weight = "bold")
  ) %>%
  tab_style(
    locations = cells_body(columns = 3, rows = 1),
    style = cell_text(color = "#9fd28d", weight = "bold")
  ) %>%
  tab_style(
    locations = cells_body(columns = 2, rows = 2),
    style = cell_text(font = google_font(name = "Merriweather"), size = "8px")
  ) %>%
  tab_style(
    locations = cells_body(columns = 3, rows = 2),
    style = cell_text(font = "Garamond")
  ) %>%
  tab_style(
    locations = cells_body(columns = 4, rows = 2),
    style = cell_text(font = "sans-serif")
  ) %>%
  tab_style(
    locations = cells_body(columns = 4, rows = 2),
    style = cell_text(font = default_fonts())
  ) %>%
  tab_style(
    locations = cells_body(columns = 2, rows = 3),
    style = cell_text(size = px(8))
  ) %>%
  tab_style(
    locations = cells_body(columns = 3, rows = 3),
    style = cell_text(size = "14px")
  ) %>%
  tab_style(
    locations = cells_body(columns = 4, rows = 3),
    style = cell_text(size = "xx-small")
  ) %>%
  tab_style(
    locations = cells_body(columns = 5, rows = 3),
    style = cell_text(size = "x-large")
  ) %>%
  tab_style(
    locations = cells_body(columns = 2, rows = 4),
    style = cell_text(align = "center")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 4),
    style = cell_text(align = "left")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 4),
    style = cell_text(align = "right")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 5, rows = 4),
    style = cell_text(align = "justify")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 5),
    style = cell_text(v_align = "middle")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 5),
    style = cell_text(v_align = "top")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 5),
    style = cell_text(v_align = "bottom")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 6),
    style = cell_text(style = "normal")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 6),
    style = cell_text(style = "italic")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 6),
    style = cell_text(style = "oblique")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 7),
    style = cell_text(weight = "bold")
  ) %>%
  tab_style(
    locations = cells_body(columns = 3, rows = 7),
    style = cell_text(weight = "lighter")
  ) %>%
  tab_style(
    locations = cells_body(columns = 4, rows = 7),
    style = cell_text(weight = "bolder")
  ) %>%
  tab_style(
    locations = cells_body(columns = 5, rows = 7),
    style = cell_text(weight = 800, align = "left")
  ) %>%
  tab_style(
    locations = cells_body(columns = 2, rows = 8),
    style = cell_text(decorate = "line-through")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 8),
    style = cell_text(decorate = "underline")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 8),
    style = cell_text(decorate = "overline")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 5, rows = 8),
    style = cell_text(decorate = "underline overline")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 9),
    style = cell_text(transform = "uppercase")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 9),
    style = cell_text(transform = "lowercase")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 9),
    style = cell_text(transform = "capitalize")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 10),
    style = cell_text(indent = px(15))
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 10),
    style = cell_text(indent = "25px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 10),
    style = cell_text(indent = pct(10))
  ) %>% 
  opt_css(
    css = "
    #ctext .gt_row {
     height: 50px; 
     border-bottom-style: none;
    }") 
""":
  nbCode:
    import tabelline

    const
      peach = "#f9bc9c"
      yellow = "#feef8f"
      green = "#9fd28d"
      purple = "#786895"
      roboto = "Roboto, " & systemFonts("system-ui")

    # tabelline's arguments of style.text, and the CSS of what it has no argument for
    let cText = tableData:
      a: ["color =", "font =", "size =", "align =", "style.css(\"vertical-align: ...\")",
          "style =", "weight =", "decorate =", "transform =", "style.css(\"text-indent: ...\")"]
      b: ["\"wheat\"", "\"Merriweather\"", "\"8px\"", "\"center\"", "middle", "\"normal\"",
          "\"bold\"", "\"line-through\"", "\"uppercase\"", "15px"]
      c: ["\"#9fd28d\"", "\"Garamond\"", "\"14px\"", "\"left\"", "top", "\"italic\"",
          "\"lighter\"", "\"underline\"", "\"lowercase\"", "25px"]
      d: ["peach", "\"sans-serif\"", "\"xx-small\"", "\"right\"", "bottom", "\"oblique\"",
          "\"bolder\"", "\"overline\"", "\"capitalize\"", "10%"]
      e: ["", "systemFonts(\"system-ui\")", "\"x-large\"", "\"justify\"", "", "", "\"800\"",
          "\"underline overline\"", "", ""]

    # each cell styled as it says: (row, column, style)
    let cTextStyles = @[
      (0, "b", style.text(color = "wheat", weight = "bold")),
      (0, "c", style.text(color = "#9fd28d", weight = "bold")),
      (1, "b", style.text(font = "Merriweather, serif", size = "8px")),
      (1, "c", style.text(font = "Garamond, serif")),
      (1, "d", style.text(font = "sans-serif")),
      (1, "e", style.text(font = systemFonts("system-ui"))),
      (2, "b", style.text(size = "8px")),
      (2, "c", style.text(size = "14px")),
      (2, "d", style.text(size = "xx-small")),
      (2, "e", style.text(size = "x-large")),
      (3, "b", style.text(align = "center")),
      (3, "c", style.text(align = "left")),
      (3, "d", style.text(align = "right")),
      (3, "e", style.text(align = "justify")),
      (4, "b", style.css("vertical-align: middle")),
      (4, "c", style.css("vertical-align: top")),
      (4, "d", style.css("vertical-align: bottom")),
      (5, "b", style.text(style = "normal")),
      (5, "c", style.text(style = "italic")),
      (5, "d", style.text(style = "oblique")),
      (6, "b", style.text(weight = "bold")),
      (6, "c", style.text(weight = "lighter")),
      (6, "d", style.text(weight = "bolder")),
      (6, "e", style.text(weight = "800", align = "left")),
      (7, "b", style.text(decorate = "line-through")),
      (7, "c", style.text(decorate = "underline")),
      (7, "d", style.text(decorate = "overline")),
      (7, "e", style.text(decorate = "underline overline")),
      (8, "b", style.text(transform = "uppercase")),
      (8, "c", style.text(transform = "lowercase")),
      (8, "d", style.text(transform = "capitalize")),
      (9, "b", style.css("text-indent: 15px")),
      (9, "c", style.css("text-indent: 25px")),
      (9, "d", style.css("text-indent: 10%"))]

    let cTextTable = tabella(cText, rownameCol = "a"):
      tabOptions(columnLabelsHidden = true, tableBodyHlinesColor = peach,
                 tableBodyHlinesWidth = "1px", stubBorderColor = green,
                 tableBodyBorderTopColor = purple, tableBodyBorderBottomColor = purple,
                 tableBorderBottomColor = purple, dataRowPadding = "2px")
      optTableFont roboto
      colsWidth:
        a: "150px"
        b: "150px"
        c: "150px"
        d: "150px"
        e: "150px"
      tabFootnote "See above callout tip.", loc.body(cols = "d", rows = 0)
      tabFootnote "Number from 1-1000 - only with variable fonts.", loc.body(cols = "e", rows = 6)
      tabFootnote "Code must be written in lowercase - example here shows the output.",
        loc.body(cols = "b", rows = 8), loc.body(cols = "d", rows = 8)
      tabStyle style.text(align = "right"), loc.stub()
      for (row, column, s) in cTextStyles:
        tabStyle s, loc.body(cols = column, rows = row)
      optCss "tbody td, tbody th { height: 50px; border-bottom-style: none; }"
    nbTable cTextTable

tabelline """
The 👑 table is the same reference for tabelline: its cells name the arguments of tabelline's
`style.text`, and each cell is styled as it says, by a loop over a list of (row, column,
style). `style.text` has no `vAlign` and no `indent`: `style.css("vertical-align: top")` and
`style.css("text-indent: 15px")` do it, and `font` takes a CSS font stack, with
`systemFonts(...)` for gt's `default_fonts()`. Fonts are not loaded from Google Fonts, so
Merriweather and Roboto show only where the reader has them. Great Tables has `v_align` but no
`indent`, and no footnotes yet.
"""
nbText: """
### `cell_borders()`
"""

tabs """
c_borders = pl.DataFrame(
    [
        ["sides =", '"left"', '"right"', '"top"', '["top", "bottom"]', '"all"'],
        ["color =", '"wheat"', '"#9fd28d"', "", "", ""],
        ["style =", '"solid"', '"dashed"', '"dotted"', '"hidden"', ""],
        ["weight =", "1", "px(2)", '"3px"', "px(4)", '"5px"'],
    ],
    schema=["n", "a", "b", "c", "d", "e"],
    orient="row",
)

c_border_styles = [
    (0, "a", style.borders(sides="left", color=purple, weight="4px")),
    (0, "b", style.borders(sides="right", color=purple, weight="4px")),
    (0, "c", style.borders(sides="top", color=purple, weight="4px")),
    (0, "d", style.borders(sides=["top", "bottom"], color=purple, weight="4px")),
    (0, "e", style.borders(sides="all", color=purple, weight="4px")),
    (1, "a", style.borders(sides="all", color="wheat", weight="4px")),
    (1, "b", style.borders(sides="all", color="#9fd28d", weight="4px")),
    (2, "a", style.borders(sides="bottom", color=purple, weight="5px", style="solid")),
    (2, "b", style.borders(sides="bottom", color=purple, weight="5px", style="dashed")),
    (2, "c", style.borders(sides="bottom", color=purple, weight="5px", style="dotted")),
    (2, "d", style.borders(sides="bottom", color=purple, weight="5px", style="hidden")),
    (3, "a", style.borders(sides="bottom", color=purple, weight="1px")),
    (3, "b", style.borders(sides="bottom", color=purple, weight="2px")),
    (3, "c", style.borders(sides="bottom", color=purple, weight="3px")),
    (3, "d", style.borders(sides="bottom", color=purple, weight="4px")),
    (3, "e", style.borders(sides="bottom", color=purple, weight="5px")),
]

c_border_table = (
    GT(c_borders, rowname_col="n", id="cborder")
    .tab_options(column_labels_hidden=True, stub_border_width="0px")
    .opt_table_font(font=google_font("Roboto"))
    .tab_style(style.text(align="center"), loc.body())
    .tab_style(style.text(align="right"), loc.stub())
    .opt_css(
        "#cborder .gt_table { border-collapse: separate; border-top-style: none; border-bottom-style: none; }"
        " #cborder .gt_row { border-top-style: none; border-bottom-style: none; }"
    )
)
for row, column, s in c_border_styles:
    c_border_table = c_border_table.tab_style(s, loc.body(columns=column, rows=[row]))
c_border_table
""", """
bsi <- c(n = "sides =", a = "\"left\"", b = "\"right\"", c = "\"top\"", d = "c(\"top\", \"bottom\")", e = "\"all\"")
bc <- c(n = "color =", a = "\"wheat\"", b = "\"#9fd28d\"")
bst <- c(n = "style =", a = "\"solid\"", b = "\"dashed\"", c = "\"dotted\"", d = "\"hidden\"")
bw <- c(n = "weight =", a = "1", b = "px(2)", c = "\"3px\"", d = "px(4)", e = "\"5px\"")

c_borders <- bind_rows(bsi, bc, bst, bw) %>%
  mutate(across(everything(), ~ replace_na(., "")))

c_borders %>% 
  gt(id = "cborder", rowname_col = "n") %>% 
  tab_options(
    column_labels.hidden = TRUE,
    stub.border.width = "0px"
  ) %>% 
  opt_table_font(font = google_font(name = "Roboto")) %>% 
  tab_style(
    locations = cells_body(),
    style = cell_text(align = "center")
  ) %>% 
  tab_style(
    locations = cells_stub(),
    style = cell_text(align = "right")
  ) %>% 
  opt_css(
    css = "
    #cborder .gt_table {
    border-collapse: separate;
    border-top-style: none;
    border-bottom-style: none;
    }
    
    #cborder .gt_row {
    border-top-style: none;
    border-bottom-style: none;
    }"
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 1),
    style = cell_borders(sides = "left",
                         color = purple,
                         weight = "4px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 1),
    style = cell_borders(sides = "right",
                         color = purple,
                         weight = "4px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 1),
    style = cell_borders(sides = "top",
                         color = purple,
                         weight = "4px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 5, rows = 1),
    style = cell_borders(sides = c("top", "bottom"),
                         color = purple,
                         weight = "4px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 6, rows = 1),
    style = cell_borders(sides = "all",
                         color = purple,
                         weight = "4px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 2),
    style = cell_borders(sides = "all",
                         color = "wheat",
                         weight = "4px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 2),
    style = cell_borders(sides = "all",
                         color = "#9fd28d",
                         weight = "4px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 3),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "5px",
                         style = "solid")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 3),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "5px",
                         style = "dashed")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 3),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "5px",
                         style = "dotted")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 5, rows = 3),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "5px",
                         style = NULL)
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 4),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "1px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 4),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "2px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 4, rows = 4),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "3px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 5, rows = 4),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "4px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 6, rows = 4),
    style = cell_borders(sides = "bottom",
                         color = purple,
                         weight = "5px")
  ) 
""":
  nbCode:
    # tabelline's arguments of style.borders
    let cBorders = tableData:
      n: ["sides =", "color =", "style =", "weight ="]
      a: ["{sLeft}", "\"wheat\"", "\"solid\"", "\"1px\""]
      b: ["{sRight}", "\"#9fd28d\"", "\"dashed\"", "\"2px\""]
      c: ["{sTop}", "", "\"dotted\"", "\"3px\""]
      d: ["{sTop, sBottom}", "", "\"hidden\"", "\"4px\""]
      e: ["all (the default)", "", "", "\"5px\""]

    let cBorderStyles = @[
      (0, "a", style.borders({sLeft}, color = purple, weight = "4px")),
      (0, "b", style.borders({sRight}, color = purple, weight = "4px")),
      (0, "c", style.borders({sTop}, color = purple, weight = "4px")),
      (0, "d", style.borders({sTop, sBottom}, color = purple, weight = "4px")),
      (0, "e", style.borders(color = purple, weight = "4px")),
      (1, "a", style.borders(color = "wheat", weight = "4px")),
      (1, "b", style.borders(color = "#9fd28d", weight = "4px")),
      (2, "a", style.borders({sBottom}, color = purple, weight = "5px", style = "solid")),
      (2, "b", style.borders({sBottom}, color = purple, weight = "5px", style = "dashed")),
      (2, "c", style.borders({sBottom}, color = purple, weight = "5px", style = "dotted")),
      (2, "d", style.borders({sBottom}, color = purple, weight = "5px", style = "hidden")),
      (3, "a", style.borders({sBottom}, color = purple, weight = "1px")),
      (3, "b", style.borders({sBottom}, color = purple, weight = "2px")),
      (3, "c", style.borders({sBottom}, color = purple, weight = "3px")),
      (3, "d", style.borders({sBottom}, color = purple, weight = "4px")),
      (3, "e", style.borders({sBottom}, color = purple, weight = "5px"))]

    let cBorderTable = tabella(cBorders, rownameCol = "n"):
      tabOptions(columnLabelsHidden = true, stubBorderWidth = "0px")
      optTableFont roboto
      tabStyle style.text(align = "center"), loc.body()
      tabStyle style.text(align = "right"), loc.stub()
      optCss "table { border-collapse: separate; border-top-style: none; border-bottom-style: none; }" &
        " tbody td, tbody th { border-top-style: none; border-bottom-style: none; }"
      for (row, column, s) in cBorderStyles:
        tabStyle s, loc.body(cols = column, rows = row)
    nbTable cBorderTable
nbText: """
### `cell_fill()`
"""

tabs """
c_fill = pl.DataFrame(
    [["color =", '"wheat"', '"#9fd28d"'], ["with an alpha", '"rgb(254 239 143 / 0.5)"', '"#feef8fcc"']],
    schema=["a", "b", "c"],
    orient="row",
)

(
    GT(c_fill, rowname_col="a")
    .tab_options(
        column_labels_hidden=True,
        table_body_hlines_color=peach,
        stub_border_color=green,
        table_body_border_top_color=purple,
        table_body_border_top_width="2px",
        table_body_border_bottom_color=purple,
        table_border_bottom_color=purple,
        table_width="300px",
    )
    .tab_style(style.text(align="right"), loc.stub())
    # Great Tables' style.fill has no alpha: a colour with one is CSS
    .tab_style(style.fill("wheat"), loc.body(columns="b", rows=[0]))
    .tab_style(style.fill("#9fd28d"), loc.body(columns="c", rows=[0]))
    .tab_style(style.fill("rgb(254 239 143 / 0.5)"), loc.body(columns="b", rows=[1]))
    .tab_style(style.fill(yellow + "cc"), loc.body(columns="c", rows=[1]))
    .tab_style(style.text(align="center"), loc.body())
)
""", """
co <- c(a = "color =", b = "\"wheat\"", c = "\"#9fd28d\"")
al <- c(a = "alpha =", b = ".5", c = ".8")

cfill <- bind_rows(co, al)

cfill %>% 
  gt(rowname_col = "a") %>% 
  tab_options(column_labels.hidden = TRUE,
              table_body.hlines.color = peach,
              stub.border.color = green,
              table_body.border.top.color = purple,
              table_body.border.top.width = "2px",
              table_body.border.bottom.color = purple,
              table.border.bottom.color = purple,
              table.width = "300px") %>% 
  tab_style(
    locations = cells_stub(),
    style = cell_text(align = "right")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 1),
    style = cell_fill(color = "wheat")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 1),
    style = cell_fill(color = "#9fd28d")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 2, rows = 2),
    style = cell_fill(color = yellow, alpha = .5)
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3, rows = 2),
    style = cell_fill(color = yellow, alpha = .8)
  ) %>% 
  tab_style(
    locations = cells_body(),
    style = cell_text(align = "center")
  ) %>% 
  as_raw_html()
""":
  nbCode:
    # tabelline's style.fill has a colour only: a colour with an alpha is CSS
    let cFill = tableData:
      a: ["color =", "with an alpha"]
      b: ["\"wheat\"", "\"rgb(254 239 143 / 0.5)\""]
      c: ["\"#9fd28d\"", "\"#feef8fcc\""]

    let cFillTable = tabella(cFill, rownameCol = "a"):
      tabOptions(columnLabelsHidden = true, tableBodyHlinesColor = peach, stubBorderColor = green,
                 tableBodyBorderTopColor = purple, tableBodyBorderTopWidth = "2px",
                 tableBodyBorderBottomColor = purple, tableBorderBottomColor = purple,
                 tableWidth = "300px")
      tabStyle style.text(align = "right"), loc.stub()
      tabStyle style.fill("wheat"), loc.body(cols = "b", rows = 0)
      tabStyle style.fill("#9fd28d"), loc.body(cols = "c", rows = 0)
      tabStyle style.fill("rgb(254 239 143 / 0.5)"), loc.body(cols = "b", rows = 1)
      tabStyle style.fill(yellow & "cc"), loc.body(cols = "c", rows = 1)
      tabStyle style.text(align = "center"), loc.body()
    nbTable cFillTable
nbText: """
## locations =
"""

nbText: """
Use one - or more with `list()` - of these to target cells.
"""

tabs """
c_locations = pl.DataFrame({
    "ccl1": ["loc.stub(rows=[0])"] + ["loc.stub()"] * 9,
    "ccl2": ['loc.body(columns="ccl2", rows=[0])'] + ["loc.body()"] * 9,
    "ccl3": ["loc.body()"] * 10,
    "ccl4": ["loc.body()"] * 10,
    "ccl5": ['loc.row_groups(rows=["grp1"])'] * 5 + ['loc.row_groups(rows=["grp2"])'] * 5,
})

(
    GT(c_locations, rowname_col="ccl1", groupname_col="ccl5", id="cells")
    .opt_table_font(font=google_font("Roboto"))
    .tab_options(
        table_font_size="15px",
        table_border_bottom_color=purple,
        table_border_top_color=purple,
        table_body_border_bottom_color=purple,
        table_body_border_bottom_style="double",
        grand_summary_row_border_color=purple,
        summary_row_border_color=green,
        table_body_hlines_color=peach,
        stub_border_color=peach,
        row_group_border_bottom_color=green,
        row_group_border_top_color=green,
        heading_border_bottom_color=purple,
        source_notes_padding="5px",
    )
    .tab_header(title="loc.title()", subtitle="loc.subtitle()")
    .tab_spanner("loc.spanner_labels(ids=)", columns=["ccl3", "ccl4"], id="spanner")
    .tab_style(style.borders(sides="bottom", color=green), loc.spanner_labels(ids=["spanner"]))
    .tab_stubhead("loc.stubhead()")
    # Great Tables 1.1 has no footnotes
    .tab_source_note("loc.source_notes()")
    # Great Tables 1.1 sums up every column: the summaries fill the three
    # Great Tables 1.1 sums up every column (summary_rows takes no columns yet)
    .summary_rows(fns={"loc.summary_stub()": pl.lit("loc.summary()")}, missing_text="")
    .grand_summary_rows(fns={"loc.grand_summary_stub()": pl.lit("loc.grand_summary()")}, missing_text="")
    .cols_width({"ccl2": "160px", "ccl3": "140px", "ccl4": "140px"})
    .cols_label(ccl2="loc.column_labels(columns=)", ccl3="", ccl4="")
    .tab_style(style.text(size="10px"), loc.body())
    .tab_style(style.text(align="center"), loc.body(columns=["ccl3", "ccl4"]))
    .tab_style(style.text(size="11px", align="right"), loc.stub())
    .tab_style(style.text(v_align="top"), [loc.summary_stub(), loc.grand_summary_stub()])
    .tab_style(
        style.text(whitespace="nowrap"),
        [loc.grand_summary(), loc.grand_summary_stub(), loc.summary(), loc.summary_stub(), loc.column_labels()],
    )
    .opt_css("#cells .gt_row { border-bottom-style: none; }")
)
""", """
cl1 <- c("cells_stub(rows = 1)", rep("cells_stub()", length.out = 9))
cl2 <- c("cells_body(column = 2, row = 1)", rep("cells_body()", length.out = 9))
cl3 <- rep("cells_body()", length.out = 10)
cl4 <- rep("cells_body()", length.out = 10)
cl5 <- c(rep("cells_row_groups(groups = \"grp1\")", length.out = 5),
         rep("cells_row_groups(groups = \"grp2\")", length.out = 5))

c_locations <- tibble(cl1, cl2, cl3, cl4, cl5) %>%
  rename(ccl1 = cl1,
         ccl2 = cl2,
         ccl3 = cl3,
         ccl4 = cl4,
         ccl5 = cl5) %>% 
  group_by(ccl5)

c_locations %>% 
  gt(rowname_col = "ccl1", id = "cells") %>% 
  opt_table_font(font = google_font("Roboto")) %>% 
  tab_options(
    table.font.size = "15px",
    table.border.bottom.color = purple,
    table.border.top.color = purple,
    table_body.border.bottom.color = purple,
    table_body.border.bottom.style = "double",
    grand_summary_row.border.color = purple,
    summary_row.border.color = green,
    table_body.hlines.color = peach,
    stub.border.color = peach,
    row_group.border.bottom.color = green,
    row_group.border.top.color = green,
    heading.border.bottom.color = purple,
    source_notes.padding = "5px",
    footnotes.padding = "5px"
  ) %>% 
  tab_style(
    locations = cells_column_spanners(),
    style = cell_borders(sides = "bottom", color = green)
  ) %>% 
  tab_header(
    title = "cells_title(groups = \"title\")",
    subtitle = "cells_title(groups = \"subtitle\")"
  ) %>% 
  tab_spanner("cells_column_spanners(spanners = )", columns = 3:4) %>% 
  tab_stubhead("cells_stubhead()") %>% 
  tab_footnote(footnote = "cells_footnotes()") %>% 
  tab_source_note(source_note = "cells_source_notes()") %>% 
  summary_rows(columns = 2,
               fns = list("cells_stub_summary(groups = , rows = )" = ~html("<div style=\"height: 22px;\"></div><div>cells_summary(groups = , columns = , rows = )</div>")),
               formatter = fmt_markdown,
               groups = everything(),
               missing_text = "") %>% 
  grand_summary_rows(columns = 2,
                     fns = list("cells_stub_grand_summary(rows = )" = ~html("<div style=\"height: 22px;\"></div><div>cells_grand_summary(columns = , rows = )</div>")),
                     formatter = fmt_markdown,
                     missing_text = "") %>%
  cols_width(
    ccl2 ~ "160px",
    everything() ~ "140px"
  ) %>% 
  cols_label(
    ccl2 = "cells_column_labels(columns = )",
    ccl3 = html("<div style=\"height: 20px;\"></div>"),
    ccl4 = ""
  ) %>% 
  tab_style(
    locations = cells_body(),
    style = cell_text(size = "10px")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 3:4),
    style = cell_text(align = "center")
  ) %>% 
  tab_style(
    locations = cells_stub(),
    style = cell_text(size = "11px", align = "right")
  ) %>% 
  tab_style(
    locations = list(cells_stub_summary(),
                     cells_stub_grand_summary()),
    style = cell_text(v_align = "top")
  ) %>% 
  tab_style(
    locations = list(cells_grand_summary(),
                     cells_stub_grand_summary(),
                     cells_summary(),
                     cells_stub_summary(),
                     cells_column_labels()),
    style = cell_text(whitespace = "nowrap")
  ) %>% 
  opt_css(
    css = "
    #cells .gt_grand_summary_row {
     overflow-x: visible; 
    }
    
    #cells .gt_summary_row {
     overflow-x: visible; 
    }
    
    #cells .gt_col_heading {
     overflow-x: visible; 
    }
    
    #cells .gt_column_spanner {
     border-bottom-style: solid;
     border-bottom-width: 2px;
     border-bottom-color: #9fd28d;
    }
    
    #cells .gt_row{
     border-bottom-style: none;
    }")
""":
  nbCode:
    # each part of a table says which `loc` finds it
    let cLocations = tableData:
      ccl1: ["loc.stub(rows = 0)", "loc.stub()", "loc.stub()", "loc.stub()", "loc.stub()",
             "loc.stub()", "loc.stub()", "loc.stub()", "loc.stub()", "loc.stub()"]
      ccl2: ["loc.body(cols = \"ccl2\", rows = 0)", "loc.body()", "loc.body()", "loc.body()",
             "loc.body()", "loc.body()", "loc.body()", "loc.body()", "loc.body()", "loc.body()"]
      ccl3: ["loc.body()", "loc.body()", "loc.body()", "loc.body()", "loc.body()",
             "loc.body()", "loc.body()", "loc.body()", "loc.body()", "loc.body()"]
      ccl4: ["loc.body()", "loc.body()", "loc.body()", "loc.body()", "loc.body()",
             "loc.body()", "loc.body()", "loc.body()", "loc.body()", "loc.body()"]
      ccl5: ["loc.rowGroups(\"grp1\")", "loc.rowGroups(\"grp1\")", "loc.rowGroups(\"grp1\")",
             "loc.rowGroups(\"grp1\")", "loc.rowGroups(\"grp1\")", "loc.rowGroups(\"grp2\")",
             "loc.rowGroups(\"grp2\")", "loc.rowGroups(\"grp2\")", "loc.rowGroups(\"grp2\")",
             "loc.rowGroups(\"grp2\")"]

    proc says(text: string): Aggregate =
      ## A summary that writes its own location.
      aggregate(proc (values: seq[Value]): Value = toValue(text))

    let cLocationsTable = tabella(cLocations, rownameCol = "ccl1", groupnameCol = "ccl5"):
      optTableFont roboto
      tabOptions(tableFontSize = "15px", tableBorderBottomColor = purple,
                 tableBorderTopColor = purple, tableBodyBorderBottomColor = purple,
                 tableBodyBorderBottomStyle = "double", grandSummaryRowBorderColor = purple,
                 summaryRowBorderColor = green, tableBodyHlinesColor = peach,
                 stubBorderColor = peach, rowGroupBorderBottomColor = green,
                 rowGroupBorderTopColor = green, headingBorderBottomColor = purple,
                 sourceNotesPadding = "5px", footnotesPadding = "5px")
      tabHeader "loc.title()", "loc.subtitle()"
      tabSpanner "loc.spanners(\"...\")", ["ccl3", "ccl4"]
      tabStyle style.borders({sBottom}, color = green, weight = "2px"), loc.spanners("loc.spanners(\"...\")")
      tabStubhead "loc.stubhead()"
      tabFootnote "loc.footnotes()"
      tabSourceNote "loc.sourceNotes()"
      summaryRows(fns = {"loc.summaryStub(groups = , rows = )": says("loc.summary(groups = , columns = , rows = )")},
                  columns = "ccl2", missingText = "")
      grandSummaryRows(fns = {"loc.grandSummaryStub(rows = )": says("loc.grandSummary(columns = , rows = )")},
                       columns = "ccl2", missingText = "")
      colsWidth:
        ccl2: "160px"
        ccl3: "140px"
        ccl4: "140px"
      colsLabel:
        ccl2: "loc.columnLabels(cols = )"
        ccl3: ""
        ccl4: ""
      tabStyle style.text(size = "10px"), loc.body()
      tabStyle style.text(align = "center"), loc.body(cols = ["ccl3", "ccl4"])
      tabStyle style.text(size = "11px", align = "right"), loc.stub()
      tabStyle style.css("vertical-align: top"), loc.summaryStub(), loc.grandSummaryStub()
      tabStyle style.text(whitespace = "nowrap"), loc.grandSummary(), loc.grandSummaryStub(),
        loc.summary(), loc.summaryStub(), loc.columnLabels()
      optCss "tbody td, tbody th { border-bottom-style: none; }"
    nbTable cLocationsTable

tabelline """
tabelline's locations are `loc.title()`, `loc.subtitle()`, `loc.stubhead()`,
`loc.columnLabels(cols = ...)`, `loc.spanners(...)`, `loc.rowGroups(...)`, `loc.stub(rows =
...)`, `loc.body(cols = ..., rows = ...)`, `loc.summary()`, `loc.summaryStub()`,
`loc.grandSummary()`, `loc.grandSummaryStub()`, `loc.footnotes()` and `loc.sourceNotes()`.
The summary rows write text with an aggregate of their own (`aggregate(proc ...)`), as gt's
summary functions return HTML here.
"""
nbText: """
# `tab_options(gt, options)`

## Borders

All borders have three associated arguments: `.color`, `.width`, and `.style`. These are (almost) all the borders you can target.
"""

tabs """

""", """
tb_a1 <- c("", "table_body.vlines", "", "", "table_body.hlines", "")
tb_a2 <- c("", "", "", "", "", "")
tb_a3 <- c("", "", "", "", "", "")
tb_a4 <- c("", "", "", "", "", "")

tb_a <- tibble(tb_a1, tb_a2, tb_a3, tb_a4)

tb_a %>% 
  gt(id = "two", rowname_col = "tb_a4") %>% 
  tab_header(title = html("<div style=\"text-align: right;color: #f764de;\">heading.border.lr</div> <div style=\"text-align: left;color: #30766a;\">heading.border.bottom</div>")) %>%
  tab_row_group(label = html("<div style=\"text-align: right; color: #ff8a8a; font-weight: bold;\">row_group.border.right</div><span style=\"color: #b349c5; font-weight: bold;\">row_group.border.bottom</span>"),
                rows = 1:3) %>% 
  tab_row_group(label = html("<div style=\"color: #b349c5; text-align: right; color: #79c1ef; font-weight: bold;\">row_group.border.top</div><span style=\"text-align: right;color: #bfcd8e;font-weight: bold;\">row_group.border.left</span>"),
                rows = 4:6) %>% 
  tab_footnote(footnote = html("<div style=\" text-align: right; color: #90ea66;font-weight: bold;\">footnotes.border.lr</div><span style=\"color: #fc99d5;\">footnotes.bottom.border</span>")) %>% 
  tab_source_note(source_note = html("<div style=\"text-align: right; color: #57ecc0; font-weight: bold; vertical-align: top;\">source_notes.border.lr</div><span style=\"color: #8033cb;\">source_note.bottom.border</span>")) %>% 
  summary_rows(columns = tb_a1,
               fns = list("stub_border.color" = ~ html("<span style=\"color: #a6cfc6;\">summary_row.border.color</span>")),
               formatter = fmt_markdown,
               groups = everything(),
               missing_text = "") %>% 
  tab_style(cell_text(color = "#737fc9", weight = "bold"), cells_stub_summary()) %>% 
  tab_style(
    locations = cells_body(columns = 1, rows = 2),
    style = cell_text(color = "#fb5471", align = "right")
  ) %>% 
  tab_style(
    locations = cells_body(columns = 1, rows = 5),
    style = cell_text(color = "#f79302")
  ) %>% 
  tab_style(
    locations = cells_column_labels(columns = 1),
    style = cell_text(color = "#af1680", weight = "bold")
  ) %>% 
  tab_style(
    locations = cells_title(),
    style = cell_text(weight = "bold")
  ) %>% 
  cols_label(
    tb_a1 = "column_labels.border.vline",
    tb_a2 = "",
    tb_a3 = ""
  ) %>% 
  tab_options(
    data_row.padding = "10px",
    data_row.padding.horizontal = "10px",
    table.font.weight = "bold",
    table.font.size = "14px",
    heading.title.font.size = "16px",
    source_notes.border.lr.color = "#57ecc0",
    source_notes.border.lr.style = "solid",
    source_notes.border.lr.width = "3px",
    source_notes.border.bottom.color = "#8033cb",
    source_notes.border.bottom.style = "solid",
    source_notes.border.bottom.width = "3px",
    summary_row.border.color = "#a6cfc6",
    summary_row.border.style = "solid",
    summary_row.border.width = "3px",
    footnotes.border.lr.color = "#90ea66",
    footnotes.border.lr.style = "solid",
    footnotes.border.lr.width = "3px",
    row_group.border.top.color = "#79c1ef",
    row_group.border.top.style = "solid",
    row_group.border.top.width = "3px",
    row_group.border.bottom.color = "#b349c5",
    row_group.border.bottom.style = "solid",
    row_group.border.bottom.width = "3px",
    row_group.border.left.color = "#bfcd8e",
    row_group.border.left.style = "solid",
    row_group.border.left.width = "3px",
    row_group.border.right.color = "#ff8a8a",
    row_group.border.right.style = "solid",
    row_group.border.right.width = "3px",
    table_body.hlines.color = "#f79302",
    table_body.hlines.style = "solid",
    table_body.hlines.width = "3px",
    table_body.vlines.color = "#fb5471",
    table_body.vlines.style = "solid",
    table_body.vlines.width = "3px",
    stub.border.color = "#737fc9",
    stub.border.style = "solid",
    stub.border.width = "3px",
    heading.border.bottom.color = "#30766a",
    heading.border.bottom.style = "solid",
    heading.border.bottom.width = "3px",
    heading.border.lr.color = "#f764de",
    heading.border.lr.style = "solid",
    heading.border.lr.width = "3px",
    column_labels.vlines.color = "#af1680",
    column_labels.vlines.style = "solid",
    column_labels.vlines.width = "3px",
    footnotes.border.bottom.color = "#fc99d5",
    footnotes.border.bottom.style = "solid",
    footnotes.border.bottom.width = "3px"
  ) %>% as_raw_html()
""":
  nbCode:
    # every border has the options ...Style, ...Width and ...Color: their names in tabelline
    proc coloured(text, colour: string, align = "left", bold = true): string =
      "<div style=\"text-align: " & align & "; color: " & colour &
        (if bold: "; font-weight: bold" else: "") & "\">" & text & "</div>"

    let tbA = tableData:
      tbA1: ["", "tableBodyVlines", "", "", "tableBodyHlines", ""]
      tbA2: ["", "", "", "", "", ""]
      tbA3: ["", "", "", "", "", ""]
      tbA4: ["", "", "", "", "", ""]

    let tbATable = tabella(tbA, rownameCol = "tbA4"):
      tabHeader html(coloured("headingBorderLr", "#f764de", "right", false) &
                     coloured("headingBorderBottom", "#30766a", bold = false))
      tabRowGroup html(coloured("rowGroupBorderRight", "#ff8a8a", "right") &
                       coloured("rowGroupBorderBottom", "#b349c5")), rows = 0..2
      tabRowGroup html(coloured("rowGroupBorderTop", "#79c1ef", "right") &
                       coloured("rowGroupBorderLeft", "#bfcd8e")), rows = 3..5
      tabFootnote html(coloured("footnotesBorderLr", "#90ea66", "right") &
                       coloured("footnotesBorderBottom", "#fc99d5", bold = false))
      tabSourceNote html(coloured("sourceNotesBorderLr", "#57ecc0", "right") &
                         coloured("sourceNotesBorderBottom", "#8033cb", bold = false))
      summaryRows(fns = {"stubBorder": says("summaryRowBorder")}, columns = "tbA1", missingText = "")
      tabStyle style.text(color = "#737fc9", weight = "bold"), loc.summaryStub()
      tabStyle style.text(color = "#a6cfc6"), loc.summary()
      tabStyle style.text(color = "#fb5471", align = "right"), loc.body(cols = "tbA1", rows = 1)
      tabStyle style.text(color = "#f79302"), loc.body(cols = "tbA1", rows = 4)
      tabStyle style.text(color = "#af1680", weight = "bold"), loc.columnLabels(cols = "tbA1")
      tabStyle style.text(weight = "bold"), loc.title()
      colsLabel:
        tbA1: "columnLabelsVlines"
        tbA2: ""
        tbA3: ""
      tabOptions(
        dataRowPadding = "10px", dataRowPaddingHorizontal = "10px",
        tableFontWeight = "bold", tableFontSize = "14px", headingTitleFontSize = "16px",
        sourceNotesBorderLrColor = "#57ecc0", sourceNotesBorderLrStyle = "solid",
        sourceNotesBorderLrWidth = "3px",
        sourceNotesBorderBottomColor = "#8033cb", sourceNotesBorderBottomStyle = "solid",
        sourceNotesBorderBottomWidth = "3px",
        summaryRowBorderColor = "#a6cfc6", summaryRowBorderStyle = "solid",
        summaryRowBorderWidth = "3px",
        footnotesBorderLrColor = "#90ea66", footnotesBorderLrStyle = "solid",
        footnotesBorderLrWidth = "3px",
        rowGroupBorderTopColor = "#79c1ef", rowGroupBorderTopStyle = "solid",
        rowGroupBorderTopWidth = "3px",
        rowGroupBorderBottomColor = "#b349c5", rowGroupBorderBottomStyle = "solid",
        rowGroupBorderBottomWidth = "3px",
        rowGroupBorderLeftColor = "#bfcd8e", rowGroupBorderLeftStyle = "solid",
        rowGroupBorderLeftWidth = "3px",
        rowGroupBorderRightColor = "#ff8a8a", rowGroupBorderRightStyle = "solid",
        rowGroupBorderRightWidth = "3px",
        tableBodyHlinesColor = "#f79302", tableBodyHlinesStyle = "solid",
        tableBodyHlinesWidth = "3px",
        tableBodyVlinesColor = "#fb5471", tableBodyVlinesStyle = "solid",
        tableBodyVlinesWidth = "3px",
        stubBorderColor = "#737fc9", stubBorderStyle = "solid", stubBorderWidth = "3px",
        headingBorderBottomColor = "#30766a", headingBorderBottomStyle = "solid",
        headingBorderBottomWidth = "3px",
        headingBorderLrColor = "#f764de", headingBorderLrStyle = "solid",
        headingBorderLrWidth = "3px",
        columnLabelsVlinesColor = "#af1680", columnLabelsVlinesStyle = "solid",
        columnLabelsVlinesWidth = "3px",
        footnotesBorderBottomColor = "#fc99d5", footnotesBorderBottomStyle = "solid",
        footnotesBorderBottomWidth = "3px")
    nbTable tbATable
tabs """

""", """
tb_b1 <- c("", "", "", "", "table.border.right", "")
tb_b2 <- c("", "table.border.left", "", "", "", "")

tb_b <- tibble(tb_b1, tb_b2) 

tb_b %>% 
  gt(id = "two", rowname_col = "tb_b2") %>% 
  tab_style(
    locations = cells_body(),
    style = cell_text(align = "right", color = "#5ac7dc", weight = "bold") 
  ) %>% 
  tab_style(
    locations = cells_stub(),
    style = cell_text(color = "#fc7086", weight = "bold")
  ) %>% 
  tab_stubhead(
    label = html("<div style=\"color: #d16dbe; font-weight: bold;\">column_labels.border.bottom</div>")
  ) %>% 
  cols_label(
    tb_b1 = html("<div style=\"color: #74de58; text-align: right; height: 30px; font-weight: bold;\">column_labels.border.lr</div>")
  ) %>% 
  tab_header(
    title = html("<div style=\"text-align: left;color: #f79302; font-weight: bold;\">table.border.top</div><div style=\"text-align: right;color: #f1d438; font-weight: bold;\">column_labels.border.top</div>")
  ) %>%
  grand_summary_rows(
    columns = 1,
    fns = list(" " = ~html("<div style=\"vertical-align: top; color: #4e66b6; height: 30px; align: center;\">grand_summary_row.border</div>")),
    formatter = fmt_markdown,
    missing_text = ""
  ) %>%
  tab_footnote(
    footnote = html("<div style=\"text-align: right; color: #54a32f; font-weight: bold;\">table_body.border.bottom</div><span style=\"color: #6c135a; font-weight: bold;\">table.border.bottom</span>")
  ) %>% 
  tab_options(
    data_row.padding = "8px",
    grand_summary_row.padding = "0px",
    table.font.weight = "bold",
    table.font.size = "14px",
    source_notes.border.lr.color = "#57ecc0",
    source_notes.border.lr.width = "3px",
    source_notes.border.lr.style = "solid",
    source_notes.border.bottom.style = "solid",
    source_notes.border.bottom.color = "#4e66b6",
    source_notes.border.bottom.width = "3px",
    grand_summary_row.border.color = "#4e66b6",
    table_body.border.bottom.color = "#54a32f",
    table_body.border.bottom.style = "solid",
    table_body.border.bottom.width = "3px",
    table_body.hlines.color = "#f79302",
    table_body.hlines.style = "none",
    table_body.hlines.width = "3px",
    table_body.border.top.color = "#1d866d",
    table_body.border.top.style = "solid",
    table_body.border.top.width = "3px",
    stub.border.color = "#737fc9",
    stub.border.style = "none",
    stub.border.width = "3px",
    table.border.top.color = "#f79302",
    table.border.top.style = "solid",
    table.border.top.width = "3px",
    table.border.bottom.color = "#6c135a",
    table.border.bottom.style = "solid",
    table.border.bottom.width = "3px",
    table.border.right.color = "#5ac7dc",
    table.border.right.style = "solid",
    table.border.right.width = "3px",
    table.border.left.color = "#fc7086",
    table.border.left.style = "solid",
    table.border.left.width = "3px",
    column_labels.border.top.color = "#f1d438",
    column_labels.border.top.style = "solid",
    column_labels.border.top.width = "3px",
    column_labels.border.bottom.color = "#d16dbe",
    column_labels.border.bottom.style = "solid",
    column_labels.border.bottom.width = "3px",
    column_labels.border.lr.color = "#74de58",
    column_labels.border.lr.style = "solid",
    column_labels.border.lr.width = "3px"
  ) %>% as_raw_html()
""":
  nbCode:
    let tbB = tableData:
      tbB1: ["", "", "", "", "tableBorderRight", ""]
      tbB2: ["", "tableBorderLeft", "", "", "", ""]

    let tbBTable = tabella(tbB, rownameCol = "tbB2"):
      tabStyle style.text(align = "right", color = "#5ac7dc", weight = "bold"), loc.body()
      tabStyle style.text(color = "#fc7086", weight = "bold"), loc.stub()
      tabStubhead html(coloured("columnLabelsBorderBottom", "#d16dbe"))
      colsLabel "tbB1", html(coloured("columnLabelsBorderLr", "#74de58", "right"))
      tabHeader html(coloured("tableBorderTop", "#f79302") &
                     coloured("columnLabelsBorderTop", "#f1d438", "right"))
      grandSummaryRows(fns = {" ": says("grandSummaryRowBorder")}, columns = "tbB1", missingText = "")
      tabStyle style.text(color = "#4e66b6") & style.css("vertical-align: top"), loc.grandSummary()
      tabFootnote html(coloured("tableBodyBorderBottom", "#54a32f", "right") &
                       coloured("tableBorderBottom", "#6c135a"))
      tabOptions(
        dataRowPadding = "8px", grandSummaryRowPadding = "0px",
        tableFontWeight = "bold", tableFontSize = "14px",
        sourceNotesBorderLrColor = "#57ecc0", sourceNotesBorderLrWidth = "3px",
        sourceNotesBorderLrStyle = "solid",
        sourceNotesBorderBottomStyle = "solid", sourceNotesBorderBottomColor = "#4e66b6",
        sourceNotesBorderBottomWidth = "3px",
        grandSummaryRowBorderColor = "#4e66b6",
        tableBodyBorderBottomColor = "#54a32f", tableBodyBorderBottomStyle = "solid",
        tableBodyBorderBottomWidth = "3px",
        tableBodyHlinesColor = "#f79302", tableBodyHlinesStyle = "none",
        tableBodyHlinesWidth = "3px",
        tableBodyBorderTopColor = "#1d866d", tableBodyBorderTopStyle = "solid",
        tableBodyBorderTopWidth = "3px",
        stubBorderColor = "#737fc9", stubBorderStyle = "none", stubBorderWidth = "3px",
        tableBorderTopColor = "#f79302", tableBorderTopStyle = "solid",
        tableBorderTopWidth = "3px",
        tableBorderBottomColor = "#6c135a", tableBorderBottomStyle = "solid",
        tableBorderBottomWidth = "3px",
        tableBorderRightColor = "#5ac7dc", tableBorderRightStyle = "solid",
        tableBorderRightWidth = "3px",
        tableBorderLeftColor = "#fc7086", tableBorderLeftStyle = "solid",
        tableBorderLeftWidth = "3px",
        columnLabelsBorderTopColor = "#f1d438", columnLabelsBorderTopStyle = "solid",
        columnLabelsBorderTopWidth = "3px",
        columnLabelsBorderBottomColor = "#d16dbe", columnLabelsBorderBottomStyle = "solid",
        columnLabelsBorderBottomWidth = "3px",
        columnLabelsBorderLrColor = "#74de58", columnLabelsBorderLrStyle = "solid",
        columnLabelsBorderLrWidth = "3px")
    nbTable tbBTable

tabelline """
Every border option of gt is in tabelline, with the same three parts (`...Style`, `...Width`,
`...Color`) in camelCase. The 🐍 tabs are empty for these two tables, which need a footnote
for the borders around the footer: Great Tables 1.1 has no footnotes.
"""
nbText: """
There's one missing: `table_body.border.top`. It shares space with `row_group.border.top` in the first table and `column_lables.border.bottom` in the second table. You'll only need to use it when you don't have column labels or row groups.

### Which Border Wins?

Scenario: You set the color for `table.border.bottom.color`, but it's still gray. But you find if you set `table.border.bottom.width` at 3px, suddenly it _is_ the color you set.

There is logic to this - the rules for how CSS handles border conflict. Every cell actually has 4 borders. They're almost always collapsed because separate borders are ugly. When they collapse, CSS decides which one matters the most. 
"""

nbText: """
`column_labels.border.bottom` and `table_body.border.top` share the same border space so they can be an example here. 

If we set a color for each of them, only one of them will show. Both of those options were rendered by `gt` in HTML file, but CSS prioritizes one of them.
"""

tabs """
from great_tables.data import gtcars

border_fight = (
    GT(gtcars.iloc[:4, :3], id="borders")
    .tab_options(
        column_labels_border_top_style="hidden",
        table_body_border_bottom_style="hidden",
        table_body_hlines_style="none",
    )
)

border_fight.tab_options(
    column_labels_border_bottom_color=green,
    table_body_border_top_color=peach,
)
""", """
border_fight <- gtcars %>% 
  select(1:3) %>% 
  slice(1:4) %>% 
  gt(id = "borders") %>% 
  tab_options(column_labels.border.top.style = "hidden",
              table_body.border.bottom.style = "hidden",
              table_body.hlines.style = "none")

border_fight %>% 
  tab_options(
    column_labels.border.bottom.color = green,
    table_body.border.top.color = peach
  ) %>% 
  as_raw_html()
""":
  nbCode:
    import std/streams
    import nanuq
    import tabelline/nanuq, gtdata

    let gtcarsTop = readCsv(newStringStream(gtcarsCsv), inferSchemaLength = 10_000)
      .select("mfr", "model", "year").head(4)

    let borderFight = tabella(gtcarsTop):
      tabOptions(columnLabelsBorderTopStyle = "hidden", tableBodyBorderBottomStyle = "hidden",
                 tableBodyHlinesStyle = "none")

    nbTable tabella(borderFight):
      tabOptions(columnLabelsBorderBottomColor = green,
                 tableBodyBorderTopColor = peach)
nbText: """
Here are the rules, tailored for `gt` table-making:

The style "hidden" beats everything - if any of the borders are "hidden", none of the borders will show.
"""

tabs """
border_fight.tab_options(
    column_labels_border_bottom_color=green,
    column_labels_border_bottom_style="hidden",
    column_labels_border_bottom_width="2px",
    table_body_border_top_color=peach,
    table_body_border_top_style="solid",
    table_body_border_top_width="2px",
)
""", """
border_fight %>% 
  tab_options(
    column_labels.border.bottom.color = green,
    column_labels.border.bottom.style = "hidden",
    column_labels.border.bottom.width = "2px",
    table_body.border.top.color = peach,
    table_body.border.top.style = "solid",
    table_body.border.top.width = "2px"
  ) %>% 
  as_raw_html()
""":
  nbCode:
    nbTable tabella(borderFight):
      tabOptions(columnLabelsBorderBottomColor = green,
                 columnLabelsBorderBottomStyle = "hidden",
                 columnLabelsBorderBottomWidth = "2px",
                 tableBodyBorderTopColor = peach,
                 tableBodyBorderTopStyle = "solid",
                 tableBodyBorderTopWidth = "2px")
nbText: """
The "none" style hides a border but _doesn't_ affect any others.
"""

tabs """
border_fight.tab_options(
    column_labels_border_bottom_color=green,
    column_labels_border_bottom_style="none",
    column_labels_border_bottom_width="2px",
    table_body_border_top_color=peach,
    table_body_border_top_style="solid",
    table_body_border_top_width="2px",
)
""", """
border_fight %>% 
  tab_options(
    column_labels.border.bottom.color = green,
    column_labels.border.bottom.style = "none",
    column_labels.border.bottom.width = "2px",
    table_body.border.top.color = peach,
    table_body.border.top.style = "solid",
    table_body.border.top.width = "2px"
  ) %>% 
  as_raw_html()
""":
  nbCode:
    nbTable tabella(borderFight):
      tabOptions(columnLabelsBorderBottomColor = green,
                 columnLabelsBorderBottomStyle = "none",
                 columnLabelsBorderBottomWidth = "2px",
                 tableBodyBorderTopColor = peach,
                 tableBodyBorderTopStyle = "solid",
                 tableBodyBorderTopWidth = "2px")
nbText: """
Wider borders win.
"""

tabs """
border_fight.tab_options(
    column_labels_border_bottom_color=green,
    column_labels_border_bottom_style="solid",
    column_labels_border_bottom_width="2px",
    table_body_border_top_color=peach,
    table_body_border_top_style="solid",
    table_body_border_top_width="3px",
)
""", """
border_fight %>% 
  tab_options(
    column_labels.border.bottom.color = green,
    column_labels.border.bottom.style = "solid",
    column_labels.border.bottom.width = "2px",
    table_body.border.top.color = peach,
    table_body.border.top.style = "solid",
    table_body.border.top.width = "3px"
  ) %>% 
  as_raw_html()
""":
  nbCode:
    nbTable tabella(borderFight):
      tabOptions(columnLabelsBorderBottomColor = green,
                 columnLabelsBorderBottomStyle = "solid",
                 columnLabelsBorderBottomWidth = "2px",
                 tableBodyBorderTopColor = peach,
                 tableBodyBorderTopStyle = "solid",
                 tableBodyBorderTopWidth = "3px")
nbText: """
Then it goes to style in the order: "double", "solid", "dashed", "dotted".
"""

tabs """
border_fight.tab_options(
    column_labels_border_bottom_color=green,
    column_labels_border_bottom_style="solid",
    column_labels_border_bottom_width="2px",
    table_body_border_top_color=peach,
    table_body_border_top_style="double",
    table_body_border_top_width="2px",
)
""", """
border_fight %>% 
  tab_options(
    column_labels.border.bottom.color = green,
    column_labels.border.bottom.style = "solid",
    column_labels.border.bottom.width = "2px",
    table_body.border.top.color = peach,
    table_body.border.top.style = "double",
    table_body.border.top.width = "2px"
  ) %>% 
  as_raw_html()
""":
  nbCode:
    nbTable tabella(borderFight):
      tabOptions(columnLabelsBorderBottomColor = green,
                 columnLabelsBorderBottomStyle = "solid",
                 columnLabelsBorderBottomWidth = "2px",
                 tableBodyBorderTopColor = peach,
                 tableBodyBorderTopStyle = "double",
                 tableBodyBorderTopWidth = "2px")
nbText: """
If the only difference is color, then border that will show is the one associated with, in order of priority: cell, row, table part (header, body, or footer), then table. 
"""

tabs """
border_fight.tab_options(
    column_labels_border_bottom_color=green,
    column_labels_border_bottom_style="solid",
    column_labels_border_bottom_width="2px",
    table_body_border_top_color=peach,
    table_body_border_top_style="solid",
    table_body_border_top_width="2px",
)
""", """
border_fight %>% 
  tab_options(
    column_labels.border.bottom.color = green,
    column_labels.border.bottom.style = "solid",
    column_labels.border.bottom.width = "2px",
    table_body.border.top.color = peach,
    table_body.border.top.style = "solid",
    table_body.border.top.width = "2px"
  ) %>% 
  as_raw_html()
""":
  nbCode:
    nbTable tabella(borderFight):
      tabOptions(columnLabelsBorderBottomColor = green,
                 columnLabelsBorderBottomStyle = "solid",
                 columnLabelsBorderBottomWidth = "2px",
                 tableBodyBorderTopColor = peach,
                 tableBodyBorderTopStyle = "solid",
                 tableBodyBorderTopWidth = "2px")
nbText: """
If you were writing the CSS for an HTML table from scratch, this wouldn't matter as much. But `gt` makes things easier by building in reasonable defaults, which means that occasionally things might not show up as you think they will. There is one surefire way to avoid any of this though, which is to set all your borders at >2px.

## More options for `tab_options`
"""

tabs """
import re

# Great Tables' options are the arguments of tab_options
import inspect
names = [n for n in inspect.signature(GT.tab_options).parameters if n != "self"]
suffixes = ["_padding_horizontal", "_padding", "_background_color", "_font_size", "_font_weight", "_text_transform"]
rows = []
for name in names:
    for suffix in suffixes:
        if name.endswith(suffix) and name != suffix[1:]:
            rows.append({"opts": name[: -len(suffix)], "x": "", "cat": suffix})
            break
opts = pl.DataFrame(rows).sort(["cat", "opts"])

def gt_map(cats):
    return (
        GT(opts.filter(pl.col("cat").is_in(cats)), groupname_col="cat")
        .opt_table_font(font=google_font("Roboto"))
        .cols_width({"opts": "180px", "x": "100px"})
        .tab_style(style.text(align="right"), loc.row_groups())
        .tab_style(style.borders(sides="bottom", style="hidden"), loc.body(columns="x"))
        .tab_options(
            table_font_size="14px",
            data_row_padding="5px",
            row_group_padding_horizontal="15px",
            column_labels_border_top_color=purple,
            table_border_top_color=purple,
            row_group_border_bottom_color=green,
            row_group_border_top_color=green,
            table_body_border_bottom_color=purple,
            table_body_hlines_color=peach,
        )
        .cols_label(opts="Table Part", x="Attribute")
    )

[gt_map(["_background_color", "_text_transform"]), gt_map(["_font_size", "_font_weight"]),
 gt_map(["_padding", "_padding_horizontal"])]
""", """
opts <- read_csv("../data/contest/gt_styling_opts.csv", col_names = c("opts"))

opts <- opts %>% 
  mutate(opts = str_remove(opts, " = NULL,")) %>% 
  mutate(cat = case_when(str_detect(opts, "horizontal") ~ ".padding.horizontal",
                         str_detect(opts, "padding") ~ ".padding",
                         str_detect(opts, "background") ~ ".background.color",
                         str_detect(opts, "size") ~ ".font.size",
                         str_detect(opts, "font\\.weight") ~ ".font.weight",
                         str_detect(opts, "transform") ~ ".text_transform")) %>% 
  mutate(opts = case_when(str_detect(opts, "horizontal") ~ str_remove(opts, ".padding.horizontal"),
                          str_detect(opts, "padding") ~ str_remove(opts, ".padding"),
                          str_detect(opts, "background") ~ str_remove(opts, ".background.color"),
                          str_detect(opts, "size") ~ str_remove(opts, ".font.size"),
                          str_detect(opts, "font\\.weight") ~ str_remove(opts, ".font.weight"),
                          str_detect(opts, "transform") ~ str_remove(opts, ".text_transform"))) %>% 
  filter(!is.na(cat)) %>% 
  add_column(x = "") %>% 
  arrange(cat) %>% 
  mutate(grp = case_when(str_detect(cat, "back|text") ~ 1,
                         str_detect(cat, "font") ~ 2,
                         TRUE ~ 3))

opts_list <- opts %>% 
  group_by(grp) %>% 
  group_split() 

gt_map <- function(x) {
  x %>% 
    select(-grp) %>% 
    group_by(cat) %>% 
    gt(id = "options") %>% 
    opt_table_font(
      font = google_font("Roboto")
    ) %>% 
    cols_width(
      opts ~ "180px",
      x ~ "100px"
    ) %>% 
    tab_style(
      locations = cells_row_groups(),
      style = cell_text(align = "right")
    ) %>% 
    tab_style(
      locations = cells_body(columns = x),
      style = cell_borders(sides = "bottom", style = "hidden")
    ) %>% 
    tab_options(
      table.font.size = "14px",
      data_row.padding = "5px",
      row_group.padding.horizontal = "15px"
    ) %>% 
    cols_label(
      opts = "Table Part",
      x = "Attribute"
    ) %>% 
    tab_options(
      column_labels.border.top.color = purple,
      table.border.top.color = purple,
      row_group.border.bottom.color = green,
      row_group.border.top.color = green,
      table_body.border.bottom.color = purple,
      table_body.hlines.color = peach
    ) %>% 
    opt_css(
    css = "
    #options .gt_row {
    border-bottom-style: none;
    }"
  )
}

opts_gts <- opts_list %>% 
  map(~gt_map(.))

# the book shows the three tables of the list
opts_gts
""":
  nbCode:
    import std/[algorithm, strutils]

    # tabelline's options are the fields of TabOptions: the parts of a table that have each
    # of six attributes
    const attributes = ["PaddingHorizontal", "Padding", "BackgroundColor", "FontSize",
                        "FontWeight", "TextTransform"]
    var opts: seq[tuple[cat, part: string]]
    for name, _ in TabOptions().fieldPairs:
      for attribute in attributes:
        if name.endsWith(attribute) and name.len > attribute.len:
          opts.add (attribute, name[0 ..< name.len - attribute.len])
          break
    opts.sort()

    proc optionsTable(cats: openArray[string]): Tabella =
      var part, x, cat: seq[string]
      for o in opts:
        if o.cat in cats:
          part.add o.part
          x.add ""
          cat.add "..." & o.cat
      let data = tableData:
        opts: part
        x: x
        cat: cat
      tabella(data, groupnameCol = "cat"):
        optTableFont roboto
        colsWidth:
          opts: "180px"
          x: "100px"
        tabStyle style.text(align = "right"), loc.rowGroups()
        tabStyle style.borders({sBottom}, style = "hidden"), loc.body(cols = "x")
        tabOptions(tableFontSize = "14px", dataRowPadding = "5px",
                   rowGroupPaddingHorizontal = "15px",
                   columnLabelsBorderTopColor = purple, tableBorderTopColor = purple,
                   rowGroupBorderBottomColor = green, rowGroupBorderTopColor = green,
                   tableBodyBorderBottomColor = purple, tableBodyHlinesColor = peach)
        colsLabel:
          opts: "Table Part"
          x: "Attribute"
        optCss "tbody td { border-bottom-style: none; }"

    nbTable optionsTable(["BackgroundColor", "TextTransform"])
    nbTable optionsTable(["FontSize", "FontWeight"])
    nbTable optionsTable(["Padding", "PaddingHorizontal"])

tabelline """
The 👑 tables list tabelline's own options: they are the fields of `TabOptions`, read with
`fieldPairs` when the page is built, so the list cannot fall behind; the 🐍 ones read Great
Tables' from the arguments of `tab_options`. Where gt has an option that tabelline lacks, it is
missing from the 👑 list: compare it with the 🏴‍☠️ one.
"""
bookSave()

