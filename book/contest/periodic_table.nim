# SPDX-License-Identifier: GPL-3.0
# This chapter ports a GPL-3 entry, so its code (all three tabs) is GPL-3 too:
# https://github.com/etiennebacher/periodic-table/blob/main/LICENSE
import tabbook
bookInit()

nbText: "# Periodic table of elements"

attribution contestEntry("Reproducing the Periodic Table of Elements",
  "https://github.com/etiennebacher/periodic-table/blob/main/main.R",
  "Etienne Bacher (2020)", "GPL-3.0",
  "https://github.com/etiennebacher/periodic-table/blob/main/LICENSE",
  "The entry is one R script, `main.R`, kept in the R tab with three changes: it shows the " &
    "table instead of saving it as a PNG, it writes `fmt_markdown(columns = everything())` " &
    "(`columns = TRUE` is deprecated in gt 1.4), and thallium is Tl, not Ti. Its README is the " &
    "text. The entry is licensed under the GPL 3, so the code of this chapter, in all three " &
    "tabs, is GPL 3 too ([a copy](https://github.com/pietroppeter/tabelline/blob/main/licenses/periodic-table-GPL-3.txt)); " &
    "tabelline itself, and the rest of the book, stay MIT.")

nbText: """
## Context

This is my participation to the [Table Contest 2020](https://blog.rstudio.com/2020/09/15/announcing-the-2020-rstudio-table-contest/), organized by RStudio. I tried to reproduce [this periodic table of elements](https://en.wikipedia.org/wiki/File:Taxonomic_PT_with_colour_categories.jpg) with the package `{gt}`.
"""

tabs """
import polars as pl
from great_tables import GT, loc, style

# the entry's table: a column for each group, "number symbol" in each cell, "" where
# there is no element
elements = pl.DataFrame({
    "rowname": ["1", "2", "3", "4", "5", "6", "7", "", "", ""],
    "1": ["1 H", "3 Li", "11 Na", "19 K", "37 Rb", "55 Cs", "87 Fr", "", "", ""],
    "2": ["", "4 Be", "12 Mg", "20 Ca", "38 Sr", "56 Ba", "88 Ra", "", "", ""],
    "3": ["", "", "", "21 Sc", "39 Y", "57 La", "89 Ac", "", "", ""],
    " ": ["", "", "", "", "", "58-71", "90-103", "", "", ""],
    "4": ["", "", "", "22 Ti", "40 Zr", "72 Hf", "104 Rf", "", "58 Ce", "90 Th"],
    "5": ["", "", "", "23 V", "41 Nb", "73 Ta", "105 Db", "", "59 Pr", "91 Pa"],
    "6": ["", "", "", "24 Cr", "42 Mo", "74 W", "106 Sg", "", "60 Nd", "92 U"],
    "7": ["", "", "", "25 Mn", "43 Tc", "75 Re", "107 Bh", "", "61 Pm", "93 Np"],
    "8": ["", "", "", "26 Fe", "44 Ru", "76 Os", "108 Hs", "", "62 Sm", "94 Pu"],
    "9": ["", "", "", "27 Co", "45 Rh", "77 Ir", "109 Mt", "", "63 Eu", "95 Am"],
    "10": ["", "", "", "28 Ni", "46 Pd", "78 Pt", "110 Ds", "", "64 Gd", "96 Cm"],
    "11": ["", "", "", "29 Cu", "47 Ag", "79 Au", "111 Rg", "", "65 Tb", "97 Bk"],
    "12": ["", "", "", "30 Zn", "48 Cd", "80 Hg", "112 Cn", "", "66 Dy", "98 Cf"],
    "13": ["", "5 B", "13 Al", "31 Ga", "49 In", "81 Tl", "113 Nh", "", "67 Ho", "99 Es"],
    "14": ["", "6 C", "14 Si", "32 Ge", "50 Sn", "82 Pb", "114 Fl", "", "68 Er", "100 Fm"],
    "15": ["", "7 N", "15 P", "33 As", "51 Sb", "83 Bi", "115 Mc", "", "69 Tm", "101 Md"],
    "16": ["", "8 O", "16 S", "34 Se", "52 Te", "84 Po", "116 Lv", "", "70 Yb", "102 No"],
    "17": ["", "9 F", "17 Cl", "35 Br", "53 I", "85 At", "117 Ts", "", "71 Lu", "103 Lr"],
    "18": ["2 He", "10 Ne", "18 Ar", "36 Kr", "54 Xe", "86 Rn", "118 Og", "", "", ""],
})

# the colour of each kind of element, by atomic number; the rest are transition metals
kinds = {
    "#FFD700": [1, 6, 7, 8, 9, 15, 16, 17, 34, 35, 53],                # reactive non-metals
    "#7FFFD4": [2, 10, 18, 36, 54, 86],                                 # noble gases
    "#F08080": [3, 11, 19, 37, 55, 87],                                 # alkali metals
    "#F0E68C": [4, 12, 20, 38, 56, 88],                                 # alkaline earth metals
    "#ffccff": list(range(57, 72)),                                     # lanthanides
    "#ff99cc": list(range(89, 104)),                                    # actinides
    "#D8BFD8": list(range(109, 119)),                                   # not yet determined
    "#B0C4DE": [13, 30, 31, 48, 49, 50, 80, 81, 82, 83, 84, 85],        # post-transition metals
    "#BDB76B": [5, 14, 32, 33, 51, 52],                                 # metalloids
}

def colour(cell):
    z = int(cell.replace("-", " ").split()[0])
    return next((c for c, zs in kinds.items() if z in zs), "#FFB6C1")

periodic = (
    GT(elements, rowname_col="rowname")
    .cols_align("center")
    .fmt(lambda x: x.replace(" ", "<br>"))
    .tab_header(title="Periodic table of elements")
    .tab_options(
        table_border_top_style="hidden", table_border_bottom_style="hidden",
        heading_border_bottom_style="hidden", column_labels_border_bottom_style="hidden",
        table_body_border_bottom_style="hidden", table_body_hlines_style="hidden",
        stub_border_style="hidden",
    )
)
# a fill and a border on every cell with an element
for name in elements.columns[1:]:
    for i, cell in enumerate(elements[name]):
        if cell:
            periodic = periodic.tab_style([style.fill(colour(cell)), style.borders()],
                                          loc.body(columns=name, rows=[i]))
# Great Tables 1.1 has no footnotes
periodic
""", """
library(dplyr)
library(stringr)
library(gt)


#####################################################################
## Create data for periodic table ##
#####################################################################

elements <- tibble(
  rowname = c("1", "2", "3", "4", "5", "6", "7", "", "", ""),
  "1" = c("1 H", "3 Li", "11 Na", "19 K", "37 Rb", "55 Cs", "87 Fr", "", "", ""),
  "2" = c("", "4 Be", "12 Mg", "20 Ca", "38 Sr", "56 Ba", "88 Ra", "", "", ""),
  "3" = c("", "", "", "21 Sc", "39 Y", "57 La", "89 Ac", "", "", ""),
  " " = c(rep("", times = 5), "58-71", "90-103", "", "", ""),
  "4" = c("", "", "", "22 Ti", "40 Zr", "72 Hf", "104 Rf", "", "58 Ce", "90 Th"),
  "5" = c("", "", "", "23 V", "41 Nb", "73 Ta", "105 Db", "", "59 Pr", "91 Pa"),
  "6" = c("", "", "", "24 Cr", "42 Mo", "74 W", "106 Sg", "", "60 Nd", "92 U"),
  "7" = c("", "", "", "25 Mn", "43 Tc", "75 Re", "107 Bh", "", "61 Pm", "93 Np"),
  "8" = c("", "", "", "26 Fe", "44 Ru", "76 Os", "108 Hs", "", "62 Sm", "94 Pu"),
  "9" = c("", "", "", "27 Co", "45 Rh", "77 Ir", "109 Mt", "", "63 Eu", "95 Am"),
  "10" = c("", "", "", "28 Ni", "46 Pd", "78 Pt", "110 Ds", "", "64 Gd", "96 Cm"),
  "11" = c("", "", "", "29 Cu", "47 Ag", "79 Au", "111 Rg", "", "65 Tb", "97 Bk"),
  "12" = c("", "", "", "30 Zn", "48 Cd", "80 Hg", "112 Cn", "", "66 Dy", "98 Cf"),
  "13" = c("", "5 B", "13 Al", "31 Ga", "49 In", "81 Tl", "113 Nh", "", "67 Ho", "99 Es"),
  "14" = c("", "6 C", "14 Si", "32 Ge", "50 Sn", "82 Pb", "114 Fl", "", "68 Er", "100 Fm"),
  "15" = c("", "7 N", "15 P", "33 As", "51 Sb", "83 Bi", "115 Mc", "", "69 Tm", "101 Md"),
  "16" = c("", "8 O", "16 S", "34 Se", "52 Te", "84 Po", "116 Lv", "", "70 Yb", "102 No"),
  "17" = c("", "9 F", "17 Cl", "35 Br", "53 I", "85 At", "117 Ts", "", "71 Lu", "103 Lr"),
  "18" = c("2 He", "10 Ne", "18 Ar", "36 Kr", "54 Xe", "86 Rn", "118 Og", "", "", "")
)


#####################################################################
## Create the table from the data ##
#####################################################################

gt_colored <- elements %>%
  
  # create markdown instruction to make numbers and abbreviations on separate lines
  mutate(
    across(
      .cols = everything(), 
      .fns = ~ str_replace_all(string = .," ","<br>")
    )
  ) %>%
  
  
  ## numbers as rownames
  gt(rowname_col = "rowname") %>% 
  
  
  ## alignment in cells
  cols_align(align = "center") %>%
  
  ## put numbers and abbreviations on separate lines
  fmt_markdown(columns = everything()) %>%
  
  
  # Non metals reactive
  tab_style(
    style = cell_fill(color = "#FFD700"),
    locations = list(
      cells_body(
        columns = "1",
        rows = "1"
      ),
      cells_body(
        columns = c("14", "15", "16", "17"),
        rows = "2"
      ),
      cells_body(
        columns = c("15", "16", "17"),
        rows = "3"
      ),
      cells_body(
        columns = "17",
        rows = "5"
      ),
      cells_body(
        columns = c("16", "17"),
        rows = "4"
      )
    )
  ) %>%

  
  # non metal noble gas
  tab_style(
    style = cell_fill(color = "#7FFFD4"),
    locations = cells_body(
      columns = "18",
      rows = c(1:6)
    )
  ) %>%
  
  
  # metals alkali
  tab_style(
    style = cell_fill(color = "#F08080"),
    locations = cells_body(
      columns = "1",
      rows = c(2:7)
    )
  ) %>%
  
  
  # metals alkaline earth
  tab_style(
    style = cell_fill(color = "#F0E68C"),
    locations = cells_body(
      columns = "2",
      rows = c(2:7)
    )
  ) %>%
  
  
  # metals transition
  tab_style(
    style = cell_fill(color = "#FFB6C1"),
    locations = list(
      cells_body(
        columns = c("4", "5", "6", "7", "8", "9", "10", "11"),
        rows = c(4:6)
      ),
      cells_body(
        columns = "3",
        rows = c(4:5)
      ),
      cells_body(
        columns = c("4", "5", "6", "7", "8"),
        rows = 7
      )
    )
  ) %>%
  
  
  # metals actinide
  tab_style(
    style = cell_fill(color = "#ff99cc"),
    locations = list(
      cells_body(
        columns = c("3", " "),
        rows = 7
      ),
      cells_body(
        columns = c("4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"),
        rows = 10
      )
    )
  ) %>%
  
  
  # metals lanthanide
  tab_style(
    style = cell_fill(color = "#ffccff"),
    locations = list(
      cells_body(
        columns = c("3", " "),
        rows = 6
      ),
      cells_body(
        columns = c("4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"),
        rows = 9
      )
    )
  ) %>%
  
  
  # properties not yet determined
  tab_style(
    style = cell_fill(color = "#D8BFD8"),
    locations = cells_body(
      columns = c("9", "10", "11", "12", "13", "14", "15", "16", "17", "18"),
      rows = 7
    )
  ) %>%
  
  
  # metals post transition
  tab_style(
    style = cell_fill(color = "#B0C4DE"),
    locations = list(
      cells_body(
        columns = "13",
        rows = 3
      ),
      cells_body(
        columns = c("12", "13"),
        rows = 4
      ),
      cells_body(
        columns = c("12", "13", "14"),
        rows = 5
      ),
      cells_body(
        columns = c("12", "13", "14", "15", "16", "17"),
        rows = 6
      )
    )
  ) %>%
  
  
  # metalloids
  tab_style(
    style = list(
      cell_fill(color = "#BDB76B")
    ),
    locations = list(
      cells_body(
        columns = "13",
        rows = 2
      ),
      cells_body(
        columns = "14",
        rows = c(3:4)
      ),
      cells_body(
        columns = "15",
        rows = c(4:5)
      ),
      cells_body(
        columns = "16",
        rows = 5
      )
    )
  ) 
  



gt_final <- gt_colored %>%
  
  ## remove borders for empty cells
  tab_header(
    title = "Periodic table of elements"
  ) %>%
  tab_style(
    style = list(
      cell_borders(
        sides = "all",
        weight = NULL
      )
    ),
    locations = list(
      cells_stub(rows = c(1:10)),
      cells_body(
        columns = c("2", "3", " ", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"),
        rows = 1
      ),
      cells_body(
        columns = c("3", " ", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
        rows = c(2:3)
      ),
      cells_body(
        columns = c(" "),
        rows = c(4:5)
      ),
      cells_body(
        columns = c("1", "2", "3", " "),
        rows = c(8:10)
      ),
      cells_body(
        columns = "18",
        rows = c(8:10)
      )
    )
  ) %>%
  
  ## add borders on every side for full cells
  tab_style(
    style = cell_borders(),
    locations = list(
      cells_body(
        columns = c("1", "18"),
        rows = 1:7
      ),
      cells_body(
        columns = c("2", "13", "14", "15", "16", "17"),
        rows = 2:7
      ),
      cells_body(
        columns = c("3", "4", "5", "6", "7", "8", "9", "10", "11", "12"),
        rows = 4:7
      ),
      cells_body(
        columns = " ",
        rows = 6:7
      ),
      cells_body(
        columns = c("4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"),
        rows = 9:10
      )
    )
  ) %>%
  
  
  ## remove borders for non-cells places by putting them in white as "style = NULL" doesn't work
  tab_options(
    table.border.top.color = "#FFFFFF",
    table.border.bottom.color = "#FFFFFF",
    table_body.border.bottom.color = "#FFFFFF",
    table.border.left.color = "#FFFFFF",
    table.border.right.color = "#FFFFFF",
    heading.border.bottom.color = "#FFFFFF",
    column_labels.border.bottom.color = "#FFFFFF"
  ) %>%
  
  ## add footnotes
  tab_footnote(
    footnote = "(a) Whether group 3 is composed of -La-Ac or -Lu-Lr is under review by the IUPAC. (b) The last two members of the group are known as transition metals.",
    locations = cells_column_labels(columns = "3")
  ) %>%
  tab_footnote(
    footnote = "Some authors treat Zn, Cd and Hg as transition metals.",
    locations = cells_column_labels(columns = "12")
  ) %>%
  
  ## change footnote symbol (can't choose specifically those used on Wikipedia)
  opt_footnote_marks(marks = "standard")

gt_final
""":
  nbCode:
    import std/[sequtils, strutils]
    import tabelline

    # the entry's table: a column for each group, "number symbol" in each cell, "" where
    # there is no element
    let elements = tableData:
      rowname: ["1", "2", "3", "4", "5", "6", "7", "", "", ""]
      "1": ["1 H", "3 Li", "11 Na", "19 K", "37 Rb", "55 Cs", "87 Fr", "", "", ""]
      "2": ["", "4 Be", "12 Mg", "20 Ca", "38 Sr", "56 Ba", "88 Ra", "", "", ""]
      "3": ["", "", "", "21 Sc", "39 Y", "57 La", "89 Ac", "", "", ""]
      " ": ["", "", "", "", "", "58-71", "90-103", "", "", ""]
      "4": ["", "", "", "22 Ti", "40 Zr", "72 Hf", "104 Rf", "", "58 Ce", "90 Th"]
      "5": ["", "", "", "23 V", "41 Nb", "73 Ta", "105 Db", "", "59 Pr", "91 Pa"]
      "6": ["", "", "", "24 Cr", "42 Mo", "74 W", "106 Sg", "", "60 Nd", "92 U"]
      "7": ["", "", "", "25 Mn", "43 Tc", "75 Re", "107 Bh", "", "61 Pm", "93 Np"]
      "8": ["", "", "", "26 Fe", "44 Ru", "76 Os", "108 Hs", "", "62 Sm", "94 Pu"]
      "9": ["", "", "", "27 Co", "45 Rh", "77 Ir", "109 Mt", "", "63 Eu", "95 Am"]
      "10": ["", "", "", "28 Ni", "46 Pd", "78 Pt", "110 Ds", "", "64 Gd", "96 Cm"]
      "11": ["", "", "", "29 Cu", "47 Ag", "79 Au", "111 Rg", "", "65 Tb", "97 Bk"]
      "12": ["", "", "", "30 Zn", "48 Cd", "80 Hg", "112 Cn", "", "66 Dy", "98 Cf"]
      "13": ["", "5 B", "13 Al", "31 Ga", "49 In", "81 Tl", "113 Nh", "", "67 Ho", "99 Es"]
      "14": ["", "6 C", "14 Si", "32 Ge", "50 Sn", "82 Pb", "114 Fl", "", "68 Er", "100 Fm"]
      "15": ["", "7 N", "15 P", "33 As", "51 Sb", "83 Bi", "115 Mc", "", "69 Tm", "101 Md"]
      "16": ["", "8 O", "16 S", "34 Se", "52 Te", "84 Po", "116 Lv", "", "70 Yb", "102 No"]
      "17": ["", "9 F", "17 Cl", "35 Br", "53 I", "85 At", "117 Ts", "", "71 Lu", "103 Lr"]
      "18": ["2 He", "10 Ne", "18 Ar", "36 Kr", "54 Xe", "86 Rn", "118 Og", "", "", ""]

    # the colour of each kind of element, by atomic number; the rest are transition metals
    let kinds = [
      ("#FFD700", @[1, 6, 7, 8, 9, 15, 16, 17, 34, 35, 53]),          # reactive non-metals
      ("#7FFFD4", @[2, 10, 18, 36, 54, 86]),                           # noble gases
      ("#F08080", @[3, 11, 19, 37, 55, 87]),                           # alkali metals
      ("#F0E68C", @[4, 12, 20, 38, 56, 88]),                           # alkaline earth metals
      ("#ffccff", toSeq(57 .. 71)),                                    # lanthanides
      ("#ff99cc", toSeq(89 .. 103)),                                   # actinides
      ("#D8BFD8", toSeq(109 .. 118)),                                  # not yet determined
      ("#B0C4DE", @[13, 30, 31, 48, 49, 50, 80, 81, 82, 83, 84, 85]),  # post-transition metals
      ("#BDB76B", @[5, 14, 32, 33, 51, 52])]                           # metalloids

    proc colour(cell: string): string =
      let z = parseInt(cell.split({' ', '-'})[0])
      for (c, zs) in kinds:
        if z in zs: return c
      "#FFB6C1"

    var periodic = tabella(elements, rownameCol = "rowname"):
      colsAlign alCenter
      fmt everything(), proc (v: Value, ctx: RenderContext): string =
        ($v).replace(" ", "<br>")
      tabHeader "Periodic table of elements"
      tabOptions(tableBorderTopStyle = "hidden", tableBorderBottomStyle = "hidden",
                 headingBorderBottomStyle = "hidden", columnLabelsBorderBottomStyle = "hidden",
                 tableBodyBorderBottomStyle = "hidden", tableBodyHlinesStyle = "hidden",
                 stubBorderStyle = "hidden")
      tabFootnote "(a) Whether group 3 is composed of -La-Ac or -Lu-Lr is under review by the IUPAC. (b) The last two members of the group are known as transition metals.",
        loc.columnLabels(cols = "3")
      tabFootnote "Some authors treat Zn, Cd and Hg as transition metals.",
        loc.columnLabels(cols = "12")
      optFootnoteMarks "standard"
    # a fill and a border on every cell with an element
    for c in elements.columns[1 .. ^1]:
      for i, v in c.values:
        if ($v).len > 0:
          periodic = periodic.tabStyle(style.fill(colour($v)) & style.borders(),
                                       loc.body(cols = c.name, rows = i))
    nbTable periodic

tabelline """
The R places each colour with lists of cells, by column and row; the 👑 and 🐍 tabs give each
kind of element its atomic numbers instead, and colour every cell from its number, in a loop
after the table is made. The entry hides the borders of the empty cells and draws those of the
others; here the table has no lines of its own (`tabOptions`, hidden) and every element gets
`style.borders()`. Its comment *can't choose specifically those used on Wikipedia* is about
the marks of the footnotes: tabelline takes marks of your own,
`optFootnoteMarks(["(a)", "(b)"])`.
"""

bookSave()

