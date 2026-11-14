import tabbook
bookInit()

# The data of the chapter (book/data/contest/latam/), read when it is compiled; here and not in
# gtdata.nim, which every chapter imports.
const
  latamDir = currentSourcePath().parentDir & "/../data/contest/latam/"
  cngAtcCsv = staticRead(latamDir & "commonnamegroup_atc.csv")
  atcClassCsv = staticRead(latamDir & "atcclass.csv")

nbText: """
# Mapping the Latin American Pharmaceutical Landscape

*An Analysis of Drug Preparations by ATC Classification*, by Lukman Aliyu
"""

attribution contestEntry("Mapping the Latin American Pharmaceutical Landscape",
  "https://github.com/lukmanaj/latam-pharma-atc-analysis/blob/main/atc_analysis.qmd",
  "Lukman Aliyu Jibril (2025), honourable mention", "MIT",
  "https://github.com/lukmanaj/latam-pharma-atc-analysis/blob/main/LICENSE",
  "The entry is one Quarto document: its text is kept, and its R code is in the 🏴‍☠️ R " &
  "tabs, with the three tables. The data are the two CSV files the entry downloads from " &
  "[sydmizar/drugs-datasets](https://github.com/sydmizar/drugs-datasets) (CC0), copied to " &
  "`book/data/contest/latam/`, so the R tab reads them from there. The numbers the document " &
  "computes inside its text (`r ...`) are written in, as its page shows them; its last " &
  "section, the R session's information, is left out.")

nbText: """
## Introduction

The Anatomical Therapeutic Chemical (ATC) classification system, established by the World Health Organization, provides a standardized framework for categorizing pharmaceutical substances. This analysis explores the diversity of drug preparations available across Latin America, revealing patterns in therapeutic focus and pharmaceutical availability.

Using open-source data from the [`drugs-datasets`](https://github.com/sydmizar/drugs-datasets) repository, I examine drug-to-ATC mappings spanning **14 major therapeutic categories**. This work demonstrates advanced table design techniques using the `gt` package while providing meaningful insights into regional pharmaceutical distribution.

## Data Acquisition & Preparation

> **Data Overview**
>
> -   **Total unique preparations:** 12,171
> -   **Total ATC classes represented:** 2,749
> -   **Data source:** [sydmizar/drugs-datasets](https://github.com/sydmizar/drugs-datasets)

## ATC Classification System

The WHO ATC system organizes drugs hierarchically:

1.  **First level (1 letter)**: Anatomical/therapeutic main group
2.  **Second level (2 digits)**: Therapeutic subgroup
3.  **Third level (1 letter)**: Pharmacological subgroup
4.  **Fourth level (1 letter)**: Chemical subgroup
5.  **Fifth level (2 digits)**: Chemical substance

This analysis focuses on the **first level** to understand broad therapeutic patterns.

## Main Results Table
"""

tabs """
import polars as pl
from great_tables import GT, html, loc, md, style

cng_atc = pl.read_csv("../data/contest/latam/commonnamegroup_atc.csv")
atc = pl.read_csv("../data/contest/latam/atcclass.csv")

# join the two tables; the first letter of the ATC code is the main group
merged = (
    cng_atc.join(atc.select("atcclassid", "code", "name"), on="atcclassid", how="left")
    .filter(pl.col("code").is_not_null())
    .with_columns(pl.col("code").str.slice(0, 1).alias("first_level"))
)
total_preparations = merged["commonnamegroupid"].n_unique()

atc_first_level_names = {
    "A": "Alimentary tract and metabolism",
    "B": "Blood and blood forming organs",
    "C": "Cardiovascular system",
    "D": "Dermatologicals",
    "G": "Genito-urinary system and sex hormones",
    "H": "Systemic hormonal preparations (excluding sex hormones and insulins)",
    "J": "Antiinfectives for systemic use",
    "L": "Antineoplastic and immunomodulating agents",
    "M": "Musculo-skeletal system",
    "N": "Nervous system",
    "P": "Antiparasitic products, insecticides and repellents",
    "R": "Respiratory system",
    "S": "Sensory organs",
    "V": "Various",
}

category_summary = (
    merged.group_by("first_level")
    .agg(
        pl.col("commonnamegroupid").n_unique().alias("n_drugs"),
        pl.col("atcclassid").n_unique().alias("n_atc_classes"),
    )
    .with_columns(
        pl.col("first_level").replace_strict(atc_first_level_names).alias("category_name"),
        (pl.col("n_drugs") / total_preparations * 100).alias("percentage"),
        (pl.col("n_drugs") / pl.col("n_atc_classes")).alias("avg_preps_per_class"),
    )
    .sort("n_drugs", descending=True)
)

main_table = (
    GT(category_summary.select(
        pl.col("first_level").alias("ATC Code"),
        pl.col("category_name").alias("Category"),
        pl.col("n_drugs").alias("Unique Preparations"),
        pl.col("n_atc_classes").alias("ATC Classes"),
        pl.col("percentage").alias("Share (%)"),
        pl.col("avg_preps_per_class").alias("Avg Preps/Class"),
    ))
    .tab_header(
        title=md("**Latin American Drug Preparations by ATC Category**"),
        subtitle=f"Analysis of {total_preparations:,} unique preparations across 14 therapeutic areas",
    )
    .cols_align(align="center", columns="ATC Code")
    .cols_align(align="left", columns="Category")
    .cols_align(align="right", columns=["Unique Preparations", "ATC Classes", "Share (%)", "Avg Preps/Class"])
    .fmt_number(columns=["Unique Preparations", "ATC Classes"], decimals=0)
    .fmt_number(columns=["Share (%)", "Avg Preps/Class"], decimals=1)
    .data_color(
        columns="Share (%)",
        palette=["black", "#2d7bb6"],
        domain=[0, category_summary["percentage"].max()],
    )
    # Great Tables' fill has no alpha: the colour is given with one
    .tab_style(style=style.fill(color="rgb(187 175 218 / 0.1)"), locations=loc.body(rows=[0, 1, 2]))
    .tab_spanner(label="Volume Metrics", columns=["Unique Preparations", "ATC Classes"])
    .tab_spanner(label="Distribution Metrics", columns=["Share (%)", "Avg Preps/Class"])
    .cols_label({"Avg Preps/Class": html("Avg Preps<br>per Class")})
    .tab_source_note(md("**Data:** sydmizar/drugs-datasets (latam_csv) | **Classification:** WHO ATC System"))
    # Great Tables 1.1 has no footnotes yet: they are written as source notes
    .tab_source_note("Category: Categories ranked by total unique preparations")
    .tab_source_note("Avg Preps per Class: Average number of unique preparations per ATC class within category")
    .tab_options(
        table_font_size="14px",
        heading_title_font_size="20px",
        heading_subtitle_font_size="14px",
        heading_align="left",
        column_labels_font_weight="bold",
        row_group_font_weight="bold",
        data_row_padding="6px",
        source_notes_font_size="11px",
    )
)
main_table
""", """
# Core data manipulation and table creation
library(dplyr)
library(tidyr)
library(gt)

# Additional packages for enhanced visualizations
library(scales)
library(glue)
library(stringr)

# the book reads the two files the entry downloads from sydmizar/drugs-datasets
local_cng_atc <- "../data/contest/latam/commonnamegroup_atc.csv"
local_atc <- "../data/contest/latam/atcclass.csv"

# Load CSV files
# commonnamegroup_atc: maps drug preparations to ATC classes
# atcclass: provides ATC classification hierarchy and codes
cng_atc <- read.csv(local_cng_atc, stringsAsFactors = FALSE)
atc <- read.csv(local_atc, stringsAsFactors = FALSE)

# Join datasets and extract first-level ATC category
# The first character of the ATC code indicates the main anatomical/therapeutic group
merged <- cng_atc |>
  left_join(atc |> select(atcclassid, code, name), by = "atcclassid") |>
  filter(!is.na(code)) |>
  mutate(first_level = substr(code, 1, 1))

# Calculate summary statistics
total_preparations <- n_distinct(merged$commonnamegroupid)
total_atc_classes <- n_distinct(merged$atcclassid)

# WHO ATC first-level anatomical/therapeutic categories
atc_first_level_names <- c(
  A = "Alimentary tract and metabolism",
  B = "Blood and blood forming organs",
  C = "Cardiovascular system",
  D = "Dermatologicals",
  G = "Genito-urinary system and sex hormones",
  H = "Systemic hormonal preparations (excluding sex hormones and insulins)",
  J = "Antiinfectives for systemic use",
  L = "Antineoplastic and immunomodulating agents",
  M = "Musculo-skeletal system",
  N = "Nervous system",
  P = "Antiparasitic products, insecticides and repellents",
  R = "Respiratory system",
  S = "Sensory organs",
  V = "Various"
)

# Aggregate data by first-level ATC category
category_summary <- merged |>
  group_by(first_level) |>
  summarise(
    n_drugs = n_distinct(commonnamegroupid),
    n_atc_classes = n_distinct(atcclassid),
    .groups = "drop"
  ) |>
  mutate(
    category_name = atc_first_level_names[first_level],
    percentage = n_drugs / total_preparations * 100,
    # Calculate average preparations per ATC class as a complexity metric
    avg_preps_per_class = n_drugs / n_atc_classes
  ) |>
  arrange(desc(n_drugs))

# Create the main comparison table
main_table <- category_summary |>
  select(
    `ATC Code` = first_level,
    Category = category_name,
    `Unique Preparations` = n_drugs,
    `ATC Classes` = n_atc_classes,
    `Share (%)` = percentage,
    `Avg Preps/Class` = avg_preps_per_class
  ) |>
  gt() |>
  # Header and subtitle
  tab_header(
    title = md("**Latin American Drug Preparations by ATC Category**"),
    subtitle = glue("Analysis of {comma(total_preparations)} unique preparations across 14 therapeutic areas")
  ) |>
  # Column alignment
  cols_align(align = "center", columns = `ATC Code`) |>
  cols_align(align = "left", columns = Category) |>
  cols_align(align = "right", columns = c(`Unique Preparations`, `ATC Classes`, `Share (%)`, `Avg Preps/Class`)) |>
  # Format numbers
  fmt_number(
    columns = `Unique Preparations`,
    decimals = 0,
    sep_mark = ","
  ) |>
  fmt_number(
    columns = `ATC Classes`,
    decimals = 0,
    sep_mark = ","
  ) |>
  fmt_number(
    columns = `Share (%)`,
    decimals = 1
  ) |>
  fmt_number(
    columns = `Avg Preps/Class`,
    decimals = 1
  ) |>
  # Add sparkline-style bar chart in the percentage column
  data_color(
    columns = `Share (%)`,
    method = "numeric",
    palette = c("black", "#2d7bb6"),
    domain = c(0, max(category_summary$percentage))
  ) |>
  # Highlight top categories
  tab_style(
    style = cell_fill(color = "#bbafda", alpha = 0.1),
    locations = cells_body(rows = 1:3)
  ) |>
  # Add column spanners for logical grouping
  tab_spanner(
    label = "Volume Metrics",
    columns = c(`Unique Preparations`, `ATC Classes`)
  ) |>
  tab_spanner(
    label = "Distribution Metrics",
    columns = c(`Share (%)`, `Avg Preps/Class`)
  ) |>
  # Column labels with additional context
  cols_label(
    `Avg Preps/Class` = html("Avg Preps<br>per Class")
  ) |>
  # Source notes and footnotes
  tab_source_note(
    source_note = md("**Data:** sydmizar/drugs-datasets (latam_csv) | **Classification:** WHO ATC System")
  ) |>
  tab_footnote(
    footnote = "Categories ranked by total unique preparations",
    locations = cells_column_labels(columns = Category)
  ) |>
  tab_footnote(
    footnote = "Average number of unique preparations per ATC class within category",
    locations = cells_column_labels(columns = `Avg Preps/Class`)
  ) |>
  # Table styling options
  tab_options(
    table.font.size = px(14),
    heading.title.font.size = px(20),
    heading.subtitle.font.size = px(14),
    heading.align = "left",
    column_labels.font.weight = "bold",
    row_group.font.weight = "bold",
    data_row.padding = px(6),
    source_notes.font.size = px(11),
    footnotes.font.size = px(11)
  )

main_table
""":
  nbCode:
    import std/[streams, strutils, tables]
    import nanuq
    import tabelline, tabelline/nanuq

    let cngAtc = readCsv(newStringStream(cngAtcCsv))
    let atc = readCsv(newStringStream(atcClassCsv))

    # join the two tables; the first letter of the ATC code is the main group
    let merged = cngAtc.join(atc.select("atcclassid", "code", "name"), on = ["atcclassid"],
                             how = JoinType.Left)
      .filter(col("code").isNotNull)
      .withColumns(col("code").str.slice(0, 1).alias("first_level"))
    let totalPreparations = merged.select(col("commonnamegroupid").nUnique).toList("commonnamegroupid", int)[0]

    let atcFirstLevelNames = {
      "A": "Alimentary tract and metabolism",
      "B": "Blood and blood forming organs",
      "C": "Cardiovascular system",
      "D": "Dermatologicals",
      "G": "Genito-urinary system and sex hormones",
      "H": "Systemic hormonal preparations (excluding sex hormones and insulins)",
      "J": "Antiinfectives for systemic use",
      "L": "Antineoplastic and immunomodulating agents",
      "M": "Musculo-skeletal system",
      "N": "Nervous system",
      "P": "Antiparasitic products, insecticides and repellents",
      "R": "Respiratory system",
      "S": "Sensory organs",
      "V": "Various"}

    let categorySummary = merged.groupBy("first_level")
      .agg(col("commonnamegroupid").nUnique.alias("n_drugs"),
           col("atcclassid").nUnique.alias("n_atc_classes"))
      .withColumns(
        col("first_level").replace(atcFirstLevelNames).alias("category_name"),
        (col("n_drugs") / lit(totalPreparations.float) * lit(100.0)).alias("percentage"),
        (col("n_drugs") / col("n_atc_classes")).alias("avg_preps_per_class"))
      .sort("n_drugs", descending = true)
    let maxShare = categorySummary.toList("percentage", float).max

    let mainTable = tabella(categorySummary.select(
        col("first_level").alias("ATC Code"), col("category_name").alias("Category"),
        col("n_drugs").alias("Unique Preparations"), col("n_atc_classes").alias("ATC Classes"),
        col("percentage").alias("Share (%)"), col("avg_preps_per_class").alias("Avg Preps/Class"))):
      tabHeader md"**Latin American Drug Preparations by ATC Category**",
        "Analysis of " & insertSep($totalPreparations, ',') & " unique preparations across 14 therapeutic areas"
      colsAlign alCenter, "ATC Code"
      colsAlign alLeft, "Category"
      colsAlign alRight, ["Unique Preparations", "ATC Classes", "Share (%)", "Avg Preps/Class"]
      fmtNumber ["Unique Preparations", "ATC Classes"], decimals = 0
      fmtNumber ["Share (%)", "Avg Preps/Class"], decimals = 1
      dataColor "Share (%)", palette = @["black", "#2d7bb6"], domain = (0.0, maxShare)
      tabStyle style.fill("rgb(187 175 218 / 0.1)"), loc.body(rows = 0..2)
      tabSpanner "Volume Metrics", ["Unique Preparations", "ATC Classes"]
      tabSpanner "Distribution Metrics", ["Share (%)", "Avg Preps/Class"]
      colsLabel "Avg Preps/Class", html"Avg Preps<br>per Class"
      tabSourceNote md"**Data:** sydmizar/drugs-datasets (latam_csv) | **Classification:** WHO ATC System"
      tabFootnote "Categories ranked by total unique preparations", loc.columnLabels(cols = "Category")
      tabFootnote "Average number of unique preparations per ATC class within category",
        loc.columnLabels(cols = "Avg Preps/Class")
      tabOptions(tableFontSize = "14px", headingTitleFontSize = "20px",
                 headingSubtitleFontSize = "14px", headingAlign = "left",
                 columnLabelsFontWeight = "bold", rowGroupFontWeight = "bold",
                 dataRowPadding = "6px", sourceNotesFontSize = "11px", footnotesFontSize = "11px")
    nbTable mainTable

tabelline """
The data steps are nanuq's, one for each of dplyr's: `join`, `filter`, `str.slice` for
`substr`, `groupBy(...).agg(...)` with `nUnique` for `n_distinct`, and `replace` with the
table of names for the lookup `atc_first_level_names[first_level]`. A fill with transparency is
a CSS colour with an alpha (`rgb(187 175 218 / 0.1)`), as `style.fill` has no `alpha`, nor
has Great Tables'. Great Tables 1.1 has no footnotes, so its tab writes them as source notes.
"""

nbText: """
## Detailed Category Breakdown

*Deep dive into the five most represented therapeutic categories*
"""

tabs """
top_5_codes = category_summary.head(5)["first_level"].to_list()

top_detail = (
    merged.filter(pl.col("first_level").is_in(top_5_codes))
    .group_by("first_level", "atcclassid", "name")
    .agg(pl.col("commonnamegroupid").n_unique().alias("n_preps"))
    .join(category_summary.select("first_level", "category_name", "n_drugs"), on="first_level", how="left")
    .with_columns(
        (pl.col("n_preps") / pl.col("n_drugs") * 100).alias("pct_of_category"),
        pl.concat_str("first_level", pl.lit(" - "), "category_name").alias("category_label"),
    )
    # the eight largest classes of each category, ties by the order of the classes
    .sort(["category_label", "n_preps", "atcclassid"], descending=[False, True, False])
    .group_by("category_label", maintain_order=True)
    .head(8)
    .select(
        pl.col("category_label").alias("Category"),
        pl.col("name").alias("ATC Class Name"),
        pl.col("n_preps").alias("Preparations"),
        pl.col("pct_of_category").alias("% of Category"),
    )
)

(
    GT(top_detail, groupname_col="Category")
    .tab_header(
        title=md("**Most Common ATC Classes Within Top 5 Categories**"),
        subtitle="Showing up to 8 most prevalent classes per category",
    )
    .fmt_number(columns="Preparations", decimals=0)
    .fmt_number(columns="% of Category", decimals=1)
    .data_color(columns="Preparations", palette=["#f7f7f7", "#d73027"])
    .cols_align(align="left", columns="ATC Class Name")
    .cols_align(align="right", columns=["Preparations", "% of Category"])
    .tab_options(
        table_font_size="13px",
        row_group_font_weight="bold",
        row_group_background_color="#f0f0f0",
        data_row_padding="5px",
    )
    .tab_source_note("Classes ordered by number of unique preparations within each category")
)
""", """
# Get top 5 categories
top_5_codes <- category_summary |>
  slice_head(n = 5) |>
  pull(first_level)

# Create detailed breakdown for top categories
top_detail <- merged |>
  filter(first_level %in% top_5_codes) |>
  group_by(first_level, atcclassid, name) |>
  summarise(n_preps = n_distinct(commonnamegroupid), .groups = "drop") |>
  left_join(
    category_summary |> select(first_level, category_name, n_drugs),
    by = "first_level"
  ) |>
  mutate(
    pct_of_category = n_preps / n_drugs * 100,
    category_label = paste0(first_level, " - ", category_name)
  ) |>
  group_by(category_label) |>
  slice_max(order_by = n_preps, n = 8, with_ties = FALSE) |>
  ungroup() |>
  select(
    Category = category_label,
    `ATC Class Name` = name,
    `Preparations` = n_preps,
    `% of Category` = pct_of_category
  )

# Create grouped table
detail_table <- top_detail |>
  gt(groupname_col = "Category") |>
  tab_header(
    title = md("**Most Common ATC Classes Within Top 5 Categories**"),
    subtitle = "Showing up to 8 most prevalent classes per category"
  ) |>
  fmt_number(
    columns = Preparations,
    decimals = 0,
    sep_mark = ","
  ) |>
  fmt_number(
    columns = `% of Category`,
    decimals = 1
  ) |>
  data_color(
    columns = Preparations,
    method = "numeric",
    palette = c("#f7f7f7", "#d73027"),
    domain = NULL
  ) |>
  cols_align(align = "left", columns = `ATC Class Name`) |>
  cols_align(align = "right", columns = c(Preparations, `% of Category`)) |>
  tab_options(
    table.font.size = px(13),
    row_group.font.weight = "bold",
    row_group.background.color = "#f0f0f0",
    data_row.padding = px(5)
  ) |>
  tab_source_note(
    source_note = "Classes ordered by number of unique preparations within each category"
  )

detail_table
""":
  nbCode:
    let top5Codes = categorySummary.head(5).toList("first_level", string)

    let topDetail = merged.filter(col("first_level").isIn(top5Codes))
      .groupBy("first_level", "atcclassid", "name")
      .agg(col("commonnamegroupid").nUnique.alias("n_preps"))
      .join(categorySummary.select("first_level", "category_name", "n_drugs"), on = ["first_level"],
            how = JoinType.Left)
      .withColumns(
        (col("n_preps") / col("n_drugs") * lit(100.0)).alias("pct_of_category"),
        concatStr([col("first_level"), lit(" - "), col("category_name")]).alias("category_label"))
      # the eight largest classes of each category, ties by the order of the classes
      .sort(@["category_label", "n_preps", "atcclassid"], descending = [false, true, false])
      .filter(intRange(0, len()).over("category_label") < lit(8))
      .select(col("category_label").alias("Category"), col("name").alias("ATC Class Name"),
              col("n_preps").alias("Preparations"), col("pct_of_category").alias("% of Category"))

    let detailTable = tabella(topDetail, groupnameCol = "Category"):
      tabHeader md"**Most Common ATC Classes Within Top 5 Categories**",
        "Showing up to 8 most prevalent classes per category"
      fmtNumber "Preparations", decimals = 0
      fmtNumber "% of Category", decimals = 1
      dataColor "Preparations", palette = @["#f7f7f7", "#d73027"]
      colsAlign alLeft, "ATC Class Name"
      colsAlign alRight, ["Preparations", "% of Category"]
      tabOptions(tableFontSize = "13px", rowGroupFontWeight = "bold",
                 rowGroupBackgroundColor = "#f0f0f0", dataRowPadding = "5px")
      tabSourceNote "Classes ordered by number of unique preparations within each category"
    nbTable detailTable

tabelline """
gt's `slice_max(n = 8)` by group is a sort and a filter on the rank of each row in its group
(`intRange(0, len()).over("category_label") < 8`, as Polars writes `int_range(pl.len())`);
the sort breaks ties by the class's id, the order in which `slice_max` keeps them. The class
names are in Spanish, as the data are.
"""

nbText: """
## Key Insights

> **Major Findings**
>
> 1.  **Nervous system** (N) dominates with **2,129 preparations** (17.5% of total)
>
> 2.  The **top 3 categories** account for **41.9%** of all preparations, indicating concentration in key therapeutic areas
>
> 3.  **Systemic hormonal preparations (excluding sex hormones and insulins)** shows the highest diversity with **6.3 preparations per ATC class** on average
>
> 4.  Category **V** has the lowest preparation-to-class ratio (**2.6**), suggesting more specialized formulations

## Visual Summary
"""

tabs """
max_drugs = category_summary["n_drugs"].max()

def count_bar(x):
    # the count in white on a bar as long as its share of the largest count
    bar_pct = x / max_drugs * 100
    return (
        "<div style='display: flex; align-items: center; justify-content: space-between;'>"
        f"<div style='flex-grow: 1; background: linear-gradient(90deg, #3182bd {bar_pct}%, transparent {bar_pct}%); "
        "padding: 4px 8px; border-radius: 3px; margin-right: 8px;'>"
        f"<span style='color: white; font-weight: bold; text-shadow: 1px 1px 2px rgba(0,0,0,0.5);'>{x:,}</span>"
        "</div></div>"
    )

(
    GT(category_summary.with_row_index("Rank", offset=1).select(
        "Rank",
        pl.col("first_level").alias("Code"),
        pl.col("category_name").alias("Category"),
        pl.col("n_drugs").alias("Count"),
        pl.col("percentage").alias("Percentage"),
    ))
    .tab_header(
        title=md("**Therapeutic Category Rankings**"),
        subtitle="Visual comparison of preparation volumes",
    )
    .fmt_number(columns="Percentage", decimals=1, pattern="{x}%")
    .fmt(count_bar, columns="Count")
    .cols_align(align="center", columns=["Rank", "Code"])
    .cols_align(align="left", columns="Category")
    .cols_align(align="right", columns="Percentage")
    .cols_width(Rank="60px", Code="80px", Category="350px", Count="200px", Percentage="100px")
    .tab_style(
        style=style.text(weight="bold", color="#d73027"),
        locations=loc.body(rows=pl.col("Rank") <= 3),
    )
    .tab_options(table_font_size="13px", data_row_padding="8px", heading_align="left")
)
""", """
# Create a visual-focused summary using gt with enhanced styling
visual_table <- category_summary |>
  mutate(
    rank = row_number(),
    bar_length = n_drugs / max(n_drugs) * 100
  ) |>
  select(
    Rank = rank,
    Code = first_level,
    Category = category_name,
    Count = n_drugs,
    Percentage = percentage
  ) |>
  gt() |>
  tab_header(
    title = md("**Therapeutic Category Rankings**"),
    subtitle = "Visual comparison of preparation volumes"
  ) |>
  fmt_number(
    columns = Count,
    decimals = 0,
    sep_mark = ","
  ) |>
  fmt_number(
    columns = Percentage,
    decimals = 1,
    pattern = "{x}%"
  ) |>
  # Create visual bars for count
  text_transform(
    locations = cells_body(columns = Count),
    fn = function(x) {
      val <- as.numeric(gsub(",", "", x))
      max_val <- max(as.numeric(gsub(",", "", category_summary$n_drugs)))
      bar_pct <- val / max_val * 100

      glue(
        "<div style='display: flex; align-items: center; justify-content: space-between;'>
          <div style='flex-grow: 1; background: linear-gradient(90deg, #3182bd {bar_pct}%, transparent {bar_pct}%);
                      padding: 4px 8px; border-radius: 3px; margin-right: 8px;'>
            <span style='color: white; font-weight: bold; text-shadow: 1px 1px 2px rgba(0,0,0,0.5);'>{scales::comma(val)}</span>
          </div>
        </div>"
      )
    }
  ) |>
  cols_align(align = "center", columns = c(Rank, Code)) |>
  cols_align(align = "left", columns = Category) |>
  cols_align(align = "right", columns = Percentage) |>
  cols_width(
    Rank ~ px(60),
    Code ~ px(80),
    Category ~ px(350),
    Count ~ px(200),
    Percentage ~ px(100)
  ) |>
  tab_style(
    style = cell_text(weight = "bold", color = "#d73027"),
    locations = cells_body(rows = Rank <= 3)
  ) |>
  tab_options(
    table.font.size = px(13),
    data_row.padding = px(8),
    heading.align = "left"
  )

visual_table
""":
  nbCode:
    let maxDrugs = categorySummary.toList("n_drugs", float).max

    proc countBar(x: float): string =
      ## The count in white on a bar as long as its share of the largest count.
      let barPct = x / maxDrugs * 100
      "<div style='display: flex; align-items: center; justify-content: space-between;'>" &
        "<div style='flex-grow: 1; background: linear-gradient(90deg, #3182bd " & $barPct &
        "%, transparent " & $barPct & "%); padding: 4px 8px; border-radius: 3px; margin-right: 8px;'>" &
        "<span style='color: white; font-weight: bold; text-shadow: 1px 1px 2px rgba(0,0,0,0.5);'>" &
        formatNumber(x, 0) & "</span></div></div>"

    let visualTable = tabella(categorySummary.withRowIndex("Rank", offset = 1).select(
        col("Rank"), col("first_level").alias("Code"), col("category_name").alias("Category"),
        col("n_drugs").alias("Count"), col("percentage").alias("Percentage"))):
      tabHeader md"**Therapeutic Category Rankings**", "Visual comparison of preparation volumes"
      fmtNumber "Percentage", decimals = 1, pattern = "{x}%"
      fmt "Count", proc (v: Value, ctx: RenderContext): string = countBar(v.toFloat)
      colsAlign alCenter, ["Rank", "Code"]
      colsAlign alLeft, "Category"
      colsAlign alRight, "Percentage"
      colsWidth:
        Rank: "60px"
        Code: "80px"
        Category: "350px"
        Count: "200px"
        Percentage: "100px"
      tabStyle style.text(weight = "bold", color = "#d73027"), loc.body(rows = where(it["Rank"] <= 3))
      tabOptions(tableFontSize = "13px", dataRowPadding = "8px", headingAlign = "left")
    nbTable visualTable

tabelline """
gt's `text_transform()` gets the formatted text and reads the number back from it
(`gsub(",", "", x)`); tabelline's `fmt` gets the value, so `countBar` takes the number and
formats it itself (`formatNumber(x, 0)` puts in the commas). The bar is the entry's HTML, a
gradient that stops at the count's share of the largest one.
"""

nbText: """
## Methodology Notes

This analysis demonstrates several key table design principles:

-   **Data storytelling**: Progressive disclosure from overview to detail
-   **Visual hierarchy**: Strategic use of color, grouping, and typography
-   **Contextual information**: Inline calculations and explanatory footnotes
-   **Reproducibility**: Complete code with caching for offline work
-   **Accessibility**: Clear labels and logical structure

All code and data are open source and fully reproducible. The analysis can be regenerated with updated data by simply re-running this Quarto document.

------------------------------------------------------------------------

**Contest submission**: 2025 Table Contest \| **Created with**: Quarto + gt + R
"""

bookSave()
