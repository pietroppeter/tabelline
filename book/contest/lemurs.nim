import tabbook
bookInit()

# The data of the chapter (book/data/contest/lemurs/), read when it is compiled. They are here and
# not in gtdata.nim, which every chapter imports, so that only this chapter reads them.
const
  lemurDir = currentSourcePath().parentDir & "/../data/contest/lemurs/"
  lemursCsv = staticRead(lemurDir & "lemurs.csv")
  weightsCsv = staticRead(lemurDir & "weights.csv")
  taxonCsv = staticRead(lemurDir & "taxon.csv")

nbText: "# Lemurs at Duke Lemur Center"

attribution contestEntry("Lemurs at Duke Lemur Center",
  "https://github.com/nrennie/2022-table-contest/blob/main/lemurs.qmd",
  "Nicola Rennie (2022), honourable mention", "CC BY 4.0",
  "https://github.com/nrennie/2022-table-contest/blob/main/LICENSE.md",
  "The entry is one Quarto document; its R code is in the 🏴‍☠️ R tab, with three changes. " &
  "It reads the data from `book/data/contest/lemurs/`: TidyTuesday's `lemur_data.csv` cut to " &
  "one row per lemur and the weights (`cut.nim` there does it), with the entry's `taxon.csv`, " &
  "and it counts the lemurs by their id, not their name. The line charts average the weights: " &
  "the original averages the ages (`mean(age_at_wt_mo)`), so its lines climbed straight " &
  "whatever the lemur. And the current residents are the darker part of each bar, as the " &
  "column's note says (the original drew them lighter). The pictures of the lemurs are linked " &
  "from the entry's repository, not copied: they come under several Creative Commons licences " &
  "(the entry's `data/image_credits.csv`).")

nbText: """
The [Duke Lemur Center](https://lemur.duke.edu/) has kept a record of every lemur it has
housed since 1966, with each weighing:
[TidyTuesday](https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24)
shared it in 2021. Nicola Rennie's table has a row for each of the 27 kinds of lemur, the most
numerous first: a picture, the name and a few words about it, a bar chart of the males and
females the centre has housed, and a line chart of how they grow. The charts are ggplot2
plots, drawn as pictures by gt's `ggplot_image()`.
"""

tabs """
import polars as pl
from great_tables import GT, html, loc, style

lemurs = pl.read_csv("../data/contest/lemurs/lemurs.csv", schema_overrides={"dlc_id": pl.Utf8}, null_values="NA")
weights = pl.read_csv("../data/contest/lemurs/weights.csv", schema_overrides={"weight_g": pl.Float64})
taxons = pl.read_csv("../data/contest/lemurs/taxon.csv")

# one row for each kind of lemur, the most numerous first, with its name and description
lemur_nums = (
    lemurs.group_by("taxon").len("n")
    .join(taxons, on="taxon", how="left")
    .sort(["n", "taxon"], descending=[True, False])
    .with_columns(
        pl.format(
            "<p align='left'><b>{}</b><br><i>{}</i><br><small>{}</small><p>",
            "common", "latin", "description",
        ).alias("species")
    )
)

# how many male and female lemurs of each kind, and how many live at the centre now
lemur_count = (
    lemurs.filter(pl.col("sex").is_in(["F", "M"]))
    .group_by("taxon", "sex")
    .agg(pl.len().alias("n_tot"), pl.col("dod").is_null().sum().alias("n_current"))
)

# the average weight of male and female lemurs of each kind, by age in two-year groups
lemur_weights = (
    weights.filter(pl.col("age_at_wt_mo") > 0)
    .with_columns((pl.col("age_at_wt_mo") / 24).ceil().cast(pl.Int64).alias("age_group"))
    .group_by("taxon", "sex", "age_group")
    .agg(pl.col("weight_g").mean().alias("avg_wt"))
)

colours = {"F": "#a1b70d", "M": "#8a8d8f"}
max_count = -(-lemur_count["n_tot"].max() // 50) * 50  # the same scale for every kind
max_weight = -(-int(lemur_weights["avg_wt"].max()) // 50) * 50

def taxon_bar(taxon, width=260, height=70):
    # a bar for the males and one for the females: the current residents darker, at its end
    rows = {r["sex"]: r for r in lemur_count.filter(pl.col("taxon") == taxon).iter_rows(named=True)}
    scale = (width - 40) / max_count
    svg = f'<svg width="{width}" height="{height}" role="img" aria-label="lemurs of {taxon}">'
    for i, sex in enumerate(["M", "F"]):
        if sex not in rows:
            continue
        r, y = rows[sex], 3 + i * 32
        svg += (
            f'<rect x="0" y="{y}" width="{r["n_tot"] * scale:.1f}" height="32" fill="{colours[sex]}" fill-opacity="0.5"/>'
            f'<rect x="{(r["n_tot"] - r["n_current"]) * scale:.1f}" y="{y}" width="{r["n_current"] * scale:.1f}" height="32" fill="{colours[sex]}"/>'
            f'<text x="{r["n_tot"] * scale + 5:.1f}" y="{y + 21}" font-size="13" font-weight="bold">{r["n_tot"]}</text>'
        )
    return svg + "</svg>"

def taxon_line(taxon, width=240, height=80):
    # the average weight by age, a line and its points for the males and for the females
    left, right, top, bottom = 48, width - 6, 6, height - 16
    x = lambda group: left + (group - 0.5) / 20 * (right - left)
    y = lambda wt: bottom - wt / max_weight * (bottom - top)
    svg = f'<svg width="{width}" height="{height}" role="img" aria-label="weights of {taxon}" font-size="10" fill="#555">'
    svg += f'<text transform="translate(9 {(top + bottom) / 2}) rotate(-90)" text-anchor="middle">Weight (g)</text>'
    for wt in (0, 2000, 4000):
        svg += (
            f'<line x1="{left}" x2="{right}" y1="{y(wt):.1f}" y2="{y(wt):.1f}" stroke="#8a8d8f" stroke-width="0.5"/>'
            f'<text x="{left - 3}" y="{y(wt) + 3:.1f}" text-anchor="end">{wt}</text>'
        )
    for group, label in ((5, "10 years"), (10, "20 years"), (15, "30 years")):
        svg += f'<text x="{x(group):.1f}" y="{height - 3}" text-anchor="middle">{label}</text>'
    data = lemur_weights.filter(pl.col("taxon") == taxon).sort("age_group")
    for sex in ["F", "M"]:
        points = [(x(g), y(w)) for g, w in data.filter(pl.col("sex") == sex).select("age_group", "avg_wt").iter_rows()]
        line = " ".join(f"{px:.1f},{py:.1f}" for px, py in points)
        svg += f'<polyline points="{line}" fill="none" stroke="{colours[sex]}" stroke-width="2" stroke-opacity="0.5"/>'
        svg += "".join(f'<circle cx="{px:.1f}" cy="{py:.1f}" r="2.5" fill="{colours[sex]}"/>' for px, py in points)
    return svg + "</svg>"

st1 = "Lemurs are a unique group of primates native to Madagascar, an island off the coast of east Africa. Although they are related to monkeys and apes, lemurs make up a separate branch of the primate family tree and are classified as a superfamily, made up of five individual lemur families and more than 100 different species. Founded in 1966 on the campus of Duke University in Durham, NC, the Duke Lemur Center is a world leader in the study, care, and protection of lemurs—Earth’s most threatened group of mammals. The Duke Lemur Center houses the world’s largest and most diverse population of lemurs outside their native Madagascar."
cap1 = "* Table created by N. Rennie for the 2022 Posit Table Contest in November 2022."
cap2 = '** Images used are licensed under Creative Commons licences. See <a style="color:#a1b70d" href="https://github.com/nrennie/2022-table-contest">github.com/nrennie/2022-table-contest</a> for details.'
cap3 = '*** Data originally from <a style="color:#a1b70d" href="https://lemur.duke.edu/">lemur.duke.edu</a> and can be accessed on GitHub at <a style="color:#a1b70d" href="https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24">github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24</a>.'

lemur_table = lemur_nums.select(
    pl.col("taxon").alias("img_html"), "species",
    pl.col("taxon").alias("bars"), pl.col("taxon").alias("lines"),
)
oswald = "Oswald, Bahnschrift, 'DIN Alternate', 'Franklin Gothic Medium', sans-serif-condensed, sans-serif"

(
    GT(lemur_table)
    .fmt_image("img_html", path="https://raw.githubusercontent.com/nrennie/2022-table-contest/main/images/",
               file_pattern="{}.png", height="100px")
    .fmt(lambda x: x, columns="species")
    .fmt(taxon_bar, columns="bars")
    .fmt(taxon_line, columns="lines")
    .cols_label(
        img_html="",
        species="",
        bars=html("How many <span style='color:#8a8d8f'>male</span> and <span style='color:#a1b70d'>female</span> lemurs are housed at Duke Lemur Center?<br><small><i>NB: Darker shade indicates number of current residents.</i></small>"),
        lines=html("How do <span style='color:#8a8d8f'>male</span> and <span style='color:#a1b70d'>female</span> lemurs grow as they age?<br><small><i>NB: Average across all male and female lemurs recorded.</i></small>"),
    )
    .cols_width(img_html="125px", species="400px", bars="275px", lines="325px")
    .tab_options(table_width="1125px", container_width="1125px", heading_padding="20px")
    .tab_header(title="LEMURS AT DUKE LEMUR CENTER", subtitle=html(st1))
    .tab_style(style.text(font="Bangers, " + oswald, size="xx-large", align="left"), loc.title())
    .tab_style(style.text(font=oswald, size="medium", color="#8a8d8f", align="left"), loc.subtitle())
    .tab_style(style.text(font=oswald, v_align="middle"), loc.column_labels(columns=["bars", "lines"]))
    .tab_style(style.text(font=oswald), loc.body(columns="species"))
    .tab_source_note(html(f"{cap1}<br>{cap2}<br>{cap3}"))
    .tab_style(style.text(font=oswald, size="small"), loc.source_notes())
    .tab_style(style.fill("#d8dde0"), loc.body(rows=list(range(0, 27, 2))))
)
""", """
library(tidyverse)
library(gt)

# the book reads TidyTuesday's lemur_data.csv cut to one row per lemur and the weights
lemurs <- readr::read_csv("../data/contest/lemurs/lemurs.csv", col_types = cols(dlc_id = "c"))
weights <- readr::read_csv("../data/contest/lemurs/weights.csv")
taxons <- readr::read_csv("../data/contest/lemurs/taxon.csv")

# create description column of table
lemur_nums <- lemurs %>%
  # count number of each species and sort taxonomy as a factor
  count(taxon) %>%
  # join taxonomy description data to lemur data
  left_join(taxons, by = "taxon") %>%
  arrange(desc(n), taxon) %>%
  mutate(taxon = factor(taxon, levels = taxon)) %>%
  # join species name, latin name, and description together with HTML formatting
  mutate(species = glue::glue("<p align='left'><b>{common}</b><br><i>{latin}</i><br><small>{description}</small><p>")) %>%
  select(taxon, n, species)

# count number of male and female lemurs for each species, and whether they are still living or not
lemur_count <- lemurs %>%
  mutate(current = if_else(is.na(dod), "CURRENT", "DEAD"),
         current = factor(current, levels = c("CURRENT", "DEAD"))) %>%
  filter(sex %in% c("F", "M")) %>%
  group_by(taxon, sex) %>%
  # include total number of male and female lemurs
  mutate(n_tot = n()) %>%
  group_by(current, taxon, sex, n_tot) %>%
  summarise(n = n(), .groups = "drop")

# create a function that produces a bar chart of number of male and
# female lemurs for a given taxonomy code
taxon_bar <- function(select_taxon, df){
  # filter to only include selected species
  plot_data <- df %>%
    filter(taxon == select_taxon)
  ggplot() +
    # bar chart coloured by sex and whether lemurs are currently at DLC
    geom_col(data = plot_data,
             mapping = aes(x = sex,
                           y = n,
                           fill = sex,
                           alpha = current),
             width = 1) +
    # add label with total number of males and females
    geom_text(data = plot_data,
              mapping = aes(x = sex,
                            y = n_tot,
                            label = n_tot),
              hjust = -0.3,
              colour = "black",
              size = 20,
              fontface = "bold") +
    # remove labels and set colour choices
    labs(x = "", y = "") +
    scale_fill_manual(values = c("#a1b70d", "#8a8d8f")) +
    # the book: current residents darker, as the column's note says
    scale_alpha_manual(values = c(1, 0.5)) +
    # fix limits to be the same for all plots (across all species)
    scale_y_continuous(limits = c(0, plyr::round_any(max(df$n_tot), 50, ceiling))) +
    coord_flip() +
    theme_minimal() +
    theme(legend.position = "none",
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.text = element_blank(),
          plot.margin = margin(5.5, 15, 5.5, 5.5))
}

# call the barchart function on all taxonomy codes
barcharts <- purrr::map(.x = lemur_nums$taxon, .f = ~taxon_bar(.x, df = lemur_count))

# create a table of the average lemur weights with age for each species
lemur_weights <- weights %>%
  filter(sex %in% c("F", "M")) %>%
  drop_na() %>%
  # break down into 2 year age groups and calculate avg weight
  mutate(age_group = cut(age_at_wt_mo,
                         breaks = seq(0, 500, 24))) %>%
  # the book: the original averaged age_at_wt_mo
  group_by(taxon, sex, age_group) %>%
  summarise(avg_wt = mean(weight_g), .groups = "drop") %>%
  # the weighings at birth (age 0) fall in no group
  filter(!is.na(age_group))

# create a function that produces a line chart of weight of male and
# female lemurs for a given taxonomy code as they age
taxon_line <- function(select_taxon, df){
  # filter to only chosen taxonomy code
  plot_data <- df %>%
    filter(taxon == select_taxon)
  ggplot(data = plot_data,
         mapping = aes(x = age_group,
                       y = avg_wt,
                       colour = sex,
                       group = sex)) +
    # draw semi-transparent line with points on top
    geom_line(linewidth = 4, alpha = 0.5) +
    geom_point(size = 8) +
    labs(x = "", y = "Weight (g)") +
    # set colours and axis break points
    scale_colour_manual(values = c("#a1b70d", "#8a8d8f")) +
    scale_x_discrete(breaks = c("(96,120]", "(216,240]", "(336,360]"),
                     labels = c("10 years", "20 years", "30 years"),
                     drop = FALSE) +
    # the book: breaks for weights, not ages
    scale_y_continuous(limits = c(0, plyr::round_any(max(df$avg_wt), 50, ceiling)),
                       breaks = c(0, 2000, 4000)) +
    coord_cartesian(expand = FALSE) +
    theme_minimal() +
    theme(legend.position = "none",
          panel.grid.minor = element_blank(),
          axis.title.y = element_text(margin = margin(r = 30), size = 60),
          axis.text = element_text(size = 50),
          panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_line(colour = "#8a8d8f"),
          plot.margin = margin(40, 40, 5, 5))
}

# call function to make linechart for each species
linecharts <- purrr::map(.x = lemur_nums$taxon, .f = ~taxon_line(.x, df = lemur_weights))

# write subtitle and caption for table
st1 <- "Lemurs are a unique group of primates native to Madagascar, an island off the coast of east Africa. Although they are related to monkeys and apes, lemurs make up a separate branch of the primate family tree and are classified as a superfamily, made up of five individual lemur families and more than 100 different species. Founded in 1966 on the campus of Duke University in Durham, NC, the Duke Lemur Center is a world leader in the study, care, and protection of lemurs—Earth’s most threatened group of mammals. The Duke Lemur Center houses the world’s largest and most diverse population of lemurs outside their native Madagascar."

# add html styling to the links to set colours to match plots
cap1 <- "* Table created by N. Rennie for the 2022 Posit Table Contest in November 2022."
cap2 <- '** Images used are licensed under Creative Commons licences. See <a style="color:#a1b70d" href="https://github.com/nrennie/2022-table-contest">github.com/nrennie/2022-table-contest</a> for details.'
cap3 <- '*** Data originally from <a style="color:#a1b70d" href="https://lemur.duke.edu/">lemur.duke.edu</a> and can be accessed on GitHub at <a style="color:#a1b70d" href="https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24">github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24</a>.'

# read in images from GitHub repo and set height
all_images <- tibble::tibble(taxon = lemur_nums$taxon) %>%
  mutate(img_html = glue::glue("<img src='https://raw.githubusercontent.com/nrennie/2022-table-contest/main/images/{taxon}.png' style='height:100px;'>"))

# select columns to go into final table
lemur_table <- lemur_nums %>%
  left_join(all_images, by = "taxon") %>%
  mutate(bars = NA,
         lines = NA) %>%
  select(c(img_html, species, bars, lines))

# create table using gt
lemur_table %>%
  gt() %>%
  # images
  text_transform(
    locations = cells_body(columns = img_html),
    fn = function(x){
      purrr::map(
        lemur_table$img_html, gt::html
      )
    }
  ) %>%
  # names
  text_transform(
    locations = cells_body(columns = species),
    fn = function(x){
      purrr::map(
        lemur_table$species, gt::html
      )
    }
  ) %>%
  # barcharts
  text_transform(
    locations = cells_body(columns = bars),
    fn = function(x){
      purrr::map(
        barcharts, ggplot_image, height = px(80), aspect_ratio = 4
      )
    }
  ) %>%
  # linecharts
  text_transform(
    locations = cells_body(columns = lines),
    fn = function(x){
      purrr::map(
        linecharts, ggplot_image, height = px(80), aspect_ratio = 3
      )
    }
  ) %>%
  # change column labels
  cols_label(
    img_html = "",
    species = "",
    # add html code to change text colour inside column label
    bars = gt::html(
      "How many <span style='color:#8a8d8f'>male</span> and <span style='color:#a1b70d'>female</span> lemurs are housed at Duke Lemur Center?<br><small><i>NB: Darker shade indicates number of current residents.</i></small>"
    ),
    lines = gt::html(
      "How do <span style='color:#8a8d8f'>male</span> and <span style='color:#a1b70d'>female</span> lemurs grow as they age?<br><small><i>NB: Average across all male and female lemurs recorded.</i></small>"
    )
  ) %>%
  # column width
  cols_width(
    img_html ~ px(125),
    species ~ px(400),
    bars ~ px(275),
    lines ~ px(325)
  ) %>%
  # table width and header padding
  tab_options(table.width = 1125,
              container.width = 1125,
              heading.padding = 20
              ) %>%
  # header
  tab_header(
    title = "LEMURS AT DUKE LEMUR CENTER",
    subtitle = gt::html(
      glue::glue("{st1}")
    )
  ) %>%
  # title styling
  tab_style(
    locations = cells_title(groups = "title"),
    style = list(
      cell_text(font = google_font(
        name = "Bangers"
      ),
      size = "xx-large",
      align = "left"))
  ) %>%
  # subtitle styling
  tab_style(
    locations = cells_title(groups = "subtitle"),
    style = list(
      cell_text(font = google_font(
        name = "Oswald"
      ),
      size = "medium",
      color = "#8a8d8f",
      align = "left"))
  ) %>%
  # column header styling
  tab_style(
    style = list(
      cell_text(
        font = google_font(name = "Oswald"),
        v_align = "middle")
      ),
    locations = cells_column_labels(c(bars, lines))
  ) %>%
  # Column styling
  tab_style(
    style = list(
      cell_text(font = google_font(name = "Oswald"),
      )),
    locations = cells_body(columns = c(species))
  ) %>%
  # source note uing captions written previously
  tab_source_note(
    source_note = gt::html(
      glue::glue("{cap1}<br>{cap2}<br>{cap3}")
    )
  ) %>%
  # source note styling
  tab_style(
    style = list(
      cell_text(font = google_font(
        name = "Oswald"
      ),
      size = "small")),
    locations = cells_source_notes()
  ) %>%
  # colour alternating rows
  tab_style(
    style = list(cell_fill(color = "#d8dde0")),
    locations = cells_body(rows = seq(1,27,2))
  )
""":
  nbCode:
    import std/[math, sequtils, streams, strformat, strutils, tables]
    import nanuq
    import tabelline, tabelline/nanuq

    let lemurs = readCsv(newStringStream(lemursCsv), schemaOverrides = {"dlc_id": String}, nullValues = ["NA"])
    let weights = readCsv(newStringStream(weightsCsv), schemaOverrides = {"weight_g": Float64})
    let taxons = readCsv(newStringStream(taxonCsv))

    # one row for each kind of lemur, the most numerous first, with its name and description
    let lemurNums = lemurs.groupBy("taxon").agg(len().alias("n"))
      .join(taxons, on = ["taxon"], how = JoinType.Left)
      .sort(@["n", "taxon"], descending = [true, false])

    # how many male and female lemurs of each kind, and how many live at the centre now
    let lemurCount = lemurs.filter(col("sex").isIn(["F", "M"]))
      .groupBy("taxon", "sex")
      .agg(len().alias("n_tot"), col("dod").isNull.sum.alias("n_current"))

    # the average weight of male and female lemurs of each kind, by age in two-year groups
    let lemurWeights = weights.filter(col("age_at_wt_mo") > lit(0.0))
      .withColumns((col("age_at_wt_mo") / lit(24.0)).ceil.`cast`(Int64).alias("age_group"))
      .groupBy("taxon", "sex", "age_group")
      .agg(col("weight_g").mean.alias("avg_wt"))
      .sort(@["taxon", "sex", "age_group"])

    const colours = {"F": "#a1b70d", "M": "#8a8d8f"}.toTable
    proc roundUp(x: float, to = 50.0): float = ceil(x / to) * to
    let maxCount = lemurCount.toList("n_tot", float).max.roundUp  # one scale for all
    let maxWeight = lemurWeights.toList("avg_wt", float).max.roundUp

    proc taxonBar(taxon: string, width = 260.0, height = 70.0): string =
      ## A bar for the males and one for the females: the current residents darker, at its end.
      let scale = (width - 40) / maxCount
      result = &"<svg width=\"{width}\" height=\"{height}\" role=\"img\" aria-label=\"lemurs of {taxon}\">"
      for r in lemurCount.filter(col("taxon") == lit(taxon)).rows(tuple[sex: string, n_tot, n_current: float]):
        let (sex, total, current) = r
        let y = if sex == "M": 3.0 else: 35.0
        result.add &"<rect x=\"0\" y=\"{y}\" width=\"{total * scale:.1f}\" height=\"32\" fill=\"{colours[sex]}\" fill-opacity=\"0.5\"/>" &
          &"<rect x=\"{(total - current) * scale:.1f}\" y=\"{y}\" width=\"{current * scale:.1f}\" height=\"32\" fill=\"{colours[sex]}\"/>" &
          &"<text x=\"{total * scale + 5:.1f}\" y=\"{y + 21}\" font-size=\"13\" font-weight=\"bold\">{total.int}</text>"
      result.add "</svg>"

    proc taxonLine(taxon: string, width = 240.0, height = 80.0): string =
      ## The average weight by age: a line and its points for the males and for the females.
      let (left, right, top, bottom) = (48.0, width - 6, 6.0, height - 16)
      proc x(group: float): float = left + (group - 0.5) / 20 * (right - left)
      proc y(wt: float): float = bottom - wt / maxWeight * (bottom - top)
      result = &"<svg width=\"{width}\" height=\"{height}\" role=\"img\" aria-label=\"weights of {taxon}\" font-size=\"10\" fill=\"#555\">" &
        &"<text transform=\"translate(9 {(top + bottom) / 2}) rotate(-90)\" text-anchor=\"middle\">Weight (g)</text>"
      for wt in [0.0, 2000, 4000]:
        result.add &"<line x1=\"{left}\" x2=\"{right}\" y1=\"{y(wt):.1f}\" y2=\"{y(wt):.1f}\" stroke=\"#8a8d8f\" stroke-width=\"0.5\"/>" &
          &"<text x=\"{left - 3}\" y=\"{y(wt) + 3:.1f}\" text-anchor=\"end\">{wt.int}</text>"
      for (group, label) in [(5.0, "10 years"), (10.0, "20 years"), (15.0, "30 years")]:
        result.add &"<text x=\"{x(group):.1f}\" y=\"{height - 3}\" text-anchor=\"middle\">{label}</text>"
      let data = lemurWeights.filter(col("taxon") == lit(taxon))
      for sex in ["F", "M"]:
        let points = data.filter(col("sex") == lit(sex)).rows(tuple[age_group, avg_wt: float])
          .mapIt((x(it.age_group), y(it.avg_wt)))
        let line = points.mapIt(&"{it[0]:.1f},{it[1]:.1f}").join(" ")
        result.add &"<polyline points=\"{line}\" fill=\"none\" stroke=\"{colours[sex]}\" stroke-width=\"2\" stroke-opacity=\"0.5\"/>"
        for (px, py) in points:
          result.add &"<circle cx=\"{px:.1f}\" cy=\"{py:.1f}\" r=\"2.5\" fill=\"{colours[sex]}\"/>"
      result.add "</svg>"

    const
      st1 = "Lemurs are a unique group of primates native to Madagascar, an island off the coast of east Africa. Although they are related to monkeys and apes, lemurs make up a separate branch of the primate family tree and are classified as a superfamily, made up of five individual lemur families and more than 100 different species. Founded in 1966 on the campus of Duke University in Durham, NC, the Duke Lemur Center is a world leader in the study, care, and protection of lemurs—Earth’s most threatened group of mammals. The Duke Lemur Center houses the world’s largest and most diverse population of lemurs outside their native Madagascar."
      cap1 = "* Table created by N. Rennie for the 2022 Posit Table Contest in November 2022."
      cap2 = "** Images used are licensed under Creative Commons licences. See <a style=\"color:#a1b70d\" href=\"https://github.com/nrennie/2022-table-contest\">github.com/nrennie/2022-table-contest</a> for details."
      cap3 = "*** Data originally from <a style=\"color:#a1b70d\" href=\"https://lemur.duke.edu/\">lemur.duke.edu</a> and can be accessed on GitHub at <a style=\"color:#a1b70d\" href=\"https://github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24\">github.com/rfordatascience/tidytuesday/blob/master/data/2021/2021-08-24</a>."
      oswald = "Oswald, " & systemFonts("industrial")

    let lemurTable = lemurNums.select(
      col("taxon").alias("img_html"),
      concatStr([lit("<p align='left'><b>"), col("common"), lit("</b><br><i>"), col("latin"),
                 lit("</i><br><small>"), col("description"), lit("</small><p>")]).alias("species"),
      col("taxon").alias("bars"), col("taxon").alias("lines"))

    let lemurGt = tabella(lemurTable):
      fmtImage "img_html", path = "https://raw.githubusercontent.com/nrennie/2022-table-contest/main/images/",
        filePattern = "{x}.png", height = "100px", alt = "a picture of the lemur"
      fmt "species", proc (v: Value, ctx: RenderContext): string = $v
      fmt "bars", proc (v: Value, ctx: RenderContext): string = taxonBar($v)
      fmt "lines", proc (v: Value, ctx: RenderContext): string = taxonLine($v)
      colsLabel:
        img_html: html""
        species: html""
        bars: html"How many <span style='color:#8a8d8f'>male</span> and <span style='color:#a1b70d'>female</span> lemurs are housed at Duke Lemur Center?<br><small><i>NB: Darker shade indicates number of current residents.</i></small>"
        lines: html"How do <span style='color:#8a8d8f'>male</span> and <span style='color:#a1b70d'>female</span> lemurs grow as they age?<br><small><i>NB: Average across all male and female lemurs recorded.</i></small>"
      colsWidth:
        img_html: "125px"
        species: "400px"
        bars: "275px"
        lines: "325px"
      tabOptions(tableWidth = "1125px", containerWidth = "1125px", headingPadding = "20px")
      tabHeader "LEMURS AT DUKE LEMUR CENTER", html(st1)
      tabStyle style.text(font = "Bangers, " & oswald, size = "xx-large", align = "left"), loc.title()
      tabStyle style.text(font = oswald, size = "medium", color = "#8a8d8f", align = "left"), loc.subtitle()
      tabStyle style.text(font = oswald) & style.css("vertical-align: middle"),
        loc.columnLabels(cols = ["bars", "lines"])
      tabStyle style.text(font = oswald), loc.body(cols = "species")
      tabSourceNote html(cap1 & "<br>" & cap2 & "<br>" & cap3)
      tabStyle style.text(font = oswald, size = "small"), loc.sourceNotes()
      tabStyle style.fill("#d8dde0"), loc.body(rows = countup(0, 26, 2).toSeq)
    nbTable lemurGt

tabelline """
The 🏴‍☠️ R tab draws its charts with ggplot2 and puts them in the table as pictures, with
`ggplot_image()`; tabelline and Great Tables have no plots of that kind, so the 👑 and 🐍 tabs
draw the two charts as SVG, each with a small function of the kind (the bars from the counts,
the line from the weights by age), which `fmt` puts in the cells of the columns `bars` and
`lines`. Those columns hold the kind of lemur, which the function looks up, where gt's columns
are empty and its `text_transform()` takes the charts in order. The pictures are
`fmtImage`'s, with a pattern for their file names, and the HTML of the name and description is
given back by `fmt` as it is. The fonts are asked for by name, with the reader's own condensed
fonts (`systemFonts("industrial")`) after them, as the book loads nothing from Google Fonts.
"""

bookSave()
