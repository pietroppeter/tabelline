import tabbook
bookInit()

nbText: "# Case Study: Clinical Tables"

attribution gtVignette("Case Study: Clinical Tables", "case-study-clinical-tables",
  "The R chunks are the article's own; the Python tab writes them with Polars. The datasets " &
  "rx_adsl and rx_addv are written from gt as CSV files, with their labels in a JSON file.")

nbText: """
The **gt** package contains the `rx_adsl` dataset, which resembles the structure of a common ADSL ADaM dataset for clinical trial data. Each record refers to demographic information for a single subject in the fictional trial. Every column is equipped with a label attribute allowing the users to get familiar with the data.
"""

tabs """
import json
from math import exp, lgamma, log, sqrt

import polars as pl
import polars.selectors as cs
from great_tables import GT, loc, md, style

# gt's `rx_adsl`, and the labels, units and levels R keeps with its columns
rx_meta = json.load(open("../data/gt/rx_meta.json"))
rx_adsl = pl.read_csv("../data/gt/rx_adsl.csv")

rx_adsl.glimpse()
""", """
library(gt)
library(dplyr)
library(tidyr)
library(rlang)
library(purrr)

rx_adsl |> str()
""":
  nbCode:
    import std/[json, math, sequtils, streams, strutils]
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    # gt's `rx_adsl`; `rxMeta()` has the labels, units and levels R keeps with its columns
    let rxAdsl = readCsv(newStringStream(rxAdslCsv))
    echo rxAdsl.glimpse

tabelline """
gt's datasets `rx_adsl` and `rx_addv` come with the book as CSV files, with what R keeps with
their columns (labels, units, the order of the levels) in a JSON file: Great Tables does not have
them, and a CSV file has no labels.
"""

nbText: """
### Demographic Summary Tables

Let's start with an example of a basic demographic summary table. In a first step, we use **dplyr** and **tidyr** to create a tibble with the shape of our desired table and then use **gt** functions to create the output table:
"""

tabs """
arms = rx_meta["rx_adsl"]["TRTA"]["levels"]

def custom_summary(df, group_var, sum_var):
    info = rx_meta["rx_adsl"][sum_var]

    if "levels" in info:
        category_lbl = f"{info['label']}, n (%)"

        df_out = (
            df.group_by(group_var, sum_var)
            .agg(val=pl.len())
            .with_columns(pct=pl.col("val") / pl.col("val").sum().over(group_var))
            .pivot(on=group_var, index=sum_var, values=["val", "pct"])
            .fill_null(0)
            .sort(pl.col(sum_var).cast(pl.Enum(info["levels"])))
            .rename({sum_var: "label"})
            .with_columns(category=pl.lit(category_lbl))
        )
    else:
        category_lbl = f"{info['label']} ({info['units']})"

        rows = {"n": {}, "Mean (SD)": {}, "Median": {}, "Min - Max": {}}
        for arm in arms:
            x = df.filter(pl.col(group_var) == arm)[sum_var].drop_nulls().cast(pl.Float64)
            rows["n"][f"val_{arm}"] = float(x.len())
            rows["Mean (SD)"] |= {f"val_{arm}": x.mean(), f"sd_{arm}": x.std()}
            rows["Median"][f"val_{arm}"] = x.median()
            rows["Min - Max"] |= {f"min_{arm}": x.min(), f"max_{arm}": x.max()}

        df_out = pl.DataFrame(
            [{"label": label, **values} for label, values in rows.items()],
            infer_schema_length=None,
        ).with_columns(category=pl.lit(category_lbl))

    return df_out

adsl_summary = pl.concat(
    [
        custom_summary(rx_adsl.filter(pl.col("ITTFL") == "Y"), "TRTA", sum_var)
        for sum_var in ["AGE", "AAGEGR1", "SEX", "ETHNIC", "BLBMI"]
    ],
    how="diagonal_relaxed",
)
""", """
custom_summary <- function(df, group_var, sum_var) {
  group_var <- rlang::ensym(group_var)
  sum_var <- rlang::ensym(sum_var)

  is_categorical <-
    is.character(eval(expr(`$`(df, !!sum_var)))) |
      is.factor(eval(expr(`$`(df, !!sum_var))))

  if (is_categorical) {
    category_lbl <-
      sprintf("%s, n (%%)", attr(eval(expr(`$`(df, !!sum_var))), "label"))

    df_out <-
      df |>
      dplyr::group_by(!!group_var) |>
      dplyr::mutate(N = dplyr::n()) |>
      dplyr::ungroup() |>
      dplyr::group_by(!!group_var, !!sum_var) |>
      dplyr::summarize(
        val = dplyr::n(),
        pct = dplyr::n() / mean(N),
        .groups = "drop"
      ) |>
      tidyr::pivot_wider(
        id_cols = !!sum_var, names_from = !!group_var,
        values_from = c(val, pct)
      ) |>
      dplyr::rename(label = !!sum_var) |>
      dplyr::mutate(
        across(where(is.numeric), ~ ifelse(is.na(.), 0, .)),
        category = category_lbl
      )
  } else {
    category_lbl <-
      sprintf(
        "%s (%s)",
        attr(eval(expr(`$`(df, !!sum_var))), "label"),
        attr(eval(expr(`$`(df, !!sum_var))), "units")
      )

    df_out <-
      df |>
      dplyr::group_by(!!group_var) |>
      dplyr::summarize(
        n = sum(!is.na(!!sum_var)),
        mean = mean(!!sum_var, na.rm = TRUE),
        sd = sd(!!sum_var, na.rm = TRUE),
        median = median(!!sum_var, na.rm = TRUE),
        min = min(!!sum_var, na.rm = TRUE),
        max = max(!!sum_var, na.rm = TRUE),
        min_max = NA,
        .groups = "drop"
      ) |>
      tidyr::pivot_longer(
        cols = c(n, mean, median, min_max),
        names_to = "label",
        values_to = "val"
      ) |>
      dplyr::mutate(
        sd = ifelse(label == "mean", sd, NA),
        max = ifelse(label == "min_max", max, NA),
        min = ifelse(label == "min_max", min, NA),
        label = dplyr::recode(
          label,
          "mean" = "Mean (SD)",
          "min_max" = "Min - Max",
          "median" = "Median"
        )
      ) |>
      tidyr::pivot_wider(
        id_cols = label,
        names_from = !!group_var,
        values_from = c(val, sd, min, max)
      ) |>
      dplyr::mutate(category = category_lbl)
  }

  return(df_out)
}

adsl_summary <-
  dplyr::filter(rx_adsl, ITTFL == "Y") |>
  (\(data) purrr::map_df(
    .x = dplyr::vars(AGE, AAGEGR1, SEX, ETHNIC, BLBMI),
    .f = \(x) custom_summary(df = data, group_var = TRTA, sum_var = !!x)
  ))()
""":
  nbCode:
    let meta = rxMeta()["rx_adsl"]
    let arms = meta["TRTA"]["levels"].to(seq[string])

    proc customSummary(df: DataFrame, groupVar, sumVar: string): DataFrame =
      let info = meta[sumVar]

      if info.hasKey("levels"):
        let categoryLbl = info["label"].getStr & ", n (%)"

        df.groupBy(groupVar, sumVar)
          .agg(len().alias("val"))
          .withColumns((col("val") / col("val").sum.over(groupVar)).alias("pct"))
          .pivot(groupVar, index = sumVar, values = ["val", "pct"])
          .fillNull(0)
          .sort([col(sumVar).cast(Enum(info["levels"].to(seq[string])))])
          .rename({sumVar: "label"})
          .withColumns(lit(categoryLbl).alias("category"))
      else:
        let categoryLbl = info["label"].getStr & " (" & info["units"].getStr & ")"
        let x = col(sumVar).cast(float)

        df.groupBy(groupVar)
          .agg(
            x.isNotNull.sum.cast(float).alias("n"),
            x.mean.alias("mean"),
            x.std.alias("sd"),
            x.median.alias("median"),
            x.min.alias("min"),
            x.max.alias("max"),
            lit(nil).cast(float).alias("min_max"))
          .unpivot(["n", "mean", "median", "min_max"], index = [groupVar, "sd", "min", "max"],
                   variableName = "label", valueName = "val")
          .withColumns(
            `when`(col("label") == "mean").then(col("sd")).otherwise(nil).alias("sd"),
            `when`(col("label") == "min_max").then(col("max")).otherwise(nil).alias("max"),
            `when`(col("label") == "min_max").then(col("min")).otherwise(nil).alias("min"),
            col("label").replace({"mean": "Mean (SD)", "min_max": "Min - Max", "median": "Median"}))
          .pivot(groupVar, index = "label", values = ["val", "sd", "min", "max"])
          .withColumns(lit(categoryLbl).alias("category"))

    let adslItt = rxAdsl.filter(col("ITTFL") == "Y")
    let adslSummary = concat(
      ["AGE", "AAGEGR1", "SEX", "ETHNIC", "BLBMI"].mapIt(customSummary(adslItt, "TRTA", it)),
      how = ConcatMethod.DiagonalRelaxed)

tabelline """
tabelline makes tables, not data: the data steps are written with
[nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim, as R writes them with dplyr and
tidyr (`unpivot` is `pivot_longer`, `pivot` is `pivot_wider`), and `import tabelline/nanuq`
makes `tabella(df)` work for its data frames. `` `when` `` takes backticks: `when` is a word of
Nim. `rxMeta()` gives the labels and the order of the levels, as R's attributes do.
"""

nbText: """
We can now start to expose our tibble with the summary of adsl variables to **gt** using `gt()`. Values should be grouped by category, with labels as rownames. In addition, we can give our table a nice title and subtitle.
"""

tabs """
rx_adsl_tbl = GT(
    adsl_summary, rowname_col="label", groupname_col="category"
).tab_header(
    title="x.x: Demographic Characteristics",
    subtitle="x.x.x: Demographic Characteristics - ITT Analysis Set",
)

rx_adsl_tbl
""", """
rx_adsl_tbl <-
  adsl_summary |>
  gt(
    rowname_col = "label",
    groupname_col = "category"
  ) |>
  tab_header(
    title = "x.x: Demographic Characteristics",
    subtitle = "x.x.x: Demographic Characteristics - ITT Analysis Set"
  )

rx_adsl_tbl
""":
  nbCode:
    let rxAdslTbl = tabella(adslSummary, rownameCol = "label", groupnameCol = "category"):
      tabHeader "x.x: Demographic Characteristics",
        "x.x.x: Demographic Characteristics - ITT Analysis Set"

    nbTable rxAdslTbl

nbText: """
As a first step, let's try to format the columns, formatting counts, min, max and medians with `fmt_integer()`, percentages with `fmt_percent()`, and mean and sd values with `fmt_number()` using `1` and `2` decimals, respectively. We are intentionally keeping the `NA` values for now, as these will be needed in the `cols_merge()` pattern in the next step.
"""

tabs """
rx_adsl_tbl = (
    rx_adsl_tbl
    .fmt_integer(
        columns=cs.starts_with("val_", "min_", "max_"),
        # (and the counts, which R shows as 36 unformatted, Polars as 36.0)
        rows=pl.col("label").is_in(["n", "Median", "Min - Max"])
        | pl.col("category").str.ends_with(", n (%)"),
    )
    .fmt_percent(columns=cs.starts_with("pct_"), decimals=1)
    .fmt_number(
        columns=cs.starts_with("val_"), rows=pl.col("label") == "Mean (SD)", decimals=1
    )
    .fmt_number(
        columns=cs.starts_with("sd_"), rows=pl.col("label") == "Mean (SD)", decimals=2
    )
)

rx_adsl_tbl
""", """
rx_adsl_tbl <-
  rx_adsl_tbl |>
  fmt_integer(
    columns = starts_with(c("val_", "min_", "max_")),
    rows = label %in% c("n", "Median", "Min - Max")
  ) |>
  fmt_percent(
    columns = starts_with("pct_"),
    decimals = 1
  ) |>
  fmt_number(
    columns = starts_with("val_"),
    rows = label == "Mean (SD)",
    decimals = 1
  ) |>
  fmt_number(
    columns = starts_with("sd_"),
    rows = label == "Mean (SD)",
    decimals = 2
  )

rx_adsl_tbl
""":
  nbCode:
    let rxAdslFmt = tabella(rxAdslTbl):
      fmtInteger startsWith(["val_", "min_", "max_"]),
        rows = where($it.label in ["n", "Median", "Min - Max"] or ($it.category).endsWith(", n (%)"))
      fmtPercent startsWith("pct_"), decimals = 1
      fmtNumber startsWith("val_"), rows = where(it.label == "Mean (SD)"), decimals = 1
      fmtNumber startsWith("sd_"), rows = where(it.label == "Mean (SD)"), decimals = 2

    nbTable rxAdslFmt

tabelline """
`startsWith` takes several prefixes, as gt's `starts_with()` does, in brackets:
`startsWith("val_", "min_")` with two texts would be Nim's own `startsWith` of strutils.
"""

nbText: """
This looks way better but our table still has a rather wide style. To collapse the columns appropriately, we will use `cols_merge()`, combining mean and SD, min and max, as well as n and percentages, respectively. We will use the `pattern` argument to specify our custom merging pattern.
"""

tabs """
rx_adsl_tbl = rx_adsl_tbl.cols_merge(
    columns=["val_Placebo", "pct_Placebo", "sd_Placebo", "min_Placebo", "max_Placebo"],
    pattern="<<{0}>><< ({1})>><< ({2})>><<{3} - {4}>>",
).cols_merge(
    columns=["val_Drug 1", "pct_Drug 1", "sd_Drug 1", "min_Drug 1", "max_Drug 1"],
    pattern="<<{0}>><< ({1})>><< ({2})>><<{3} - {4}>>",
)

rx_adsl_tbl
""", """
rx_adsl_tbl <-
  rx_adsl_tbl |>
  cols_merge(
    columns = c("val_Placebo", "pct_Placebo", "sd_Placebo", "min_Placebo", "max_Placebo"),
    pattern = "<<{1}>><< ({2})>><< ({3})>><<{4} - {5}>>"
  ) |>
  cols_merge(
    columns = c("val_Drug 1", "pct_Drug 1", "sd_Drug 1", "min_Drug 1", "max_Drug 1"),
    pattern = "<<{1}>><< ({2})>><< ({3})>><<{4} - {5}>>"
  )

rx_adsl_tbl
""":
  nbCode:
    let rxAdslMerged = tabella(rxAdslFmt):
      for arm in arms:
        colsMerge ["val_", "pct_", "sd_", "min_", "max_"].mapIt(it & arm),
          pattern = "<<{1}>><< ({2})>><< ({3})>><<{4} - {5}>>"

    nbTable rxAdslMerged

tabelline """
A `for` in a `tabella` body repeats its verbs: one merge for each arm. Great Tables numbers the
columns of a pattern from `{0}`, gt and tabelline from `{1}`.
"""

nbText: """
Now that looks more like a demographic table. But let's take a step back and understand the merging pattern. `{ }` are used to arrange the single column values in a row-wise fashion. The number in curly braces corresponds to the order specified in the `columns = ` argument. We use `<< >>` to surround spans of text that will be omitted if any of the values within contain missing values. Our first column in the call to `cols_merge()` contains values for n's, means and medians and is printed if the values are not missing (meaning for the cells for numeric and categorical n's, means and medians but not for min and max). The SD and percentages for categorical grouping variables are then appended to the cells for mean and categorical n's, because these are the only rows that contain non-missing values. All of the previous aspects are ignored for the min and max row, as n's, percentages, SD's and medians are missing. Here, only min and max are arranged.

We can now start to look in to style features. Let us indent the values in the stub using `tab_stub_indent()` and left-align the title with `opt_align_table_header()`.
"""

tabs """
rx_adsl_tbl = rx_adsl_tbl.tab_stub_indent(
    rows=list(range(len(adsl_summary))), indent=5
).opt_align_table_header(align="left")

rx_adsl_tbl
""", """
rx_adsl_tbl <-
  rx_adsl_tbl |>
  tab_stub_indent(
    rows = everything(),
    indent = 5
  ) |>
  opt_align_table_header(align = "left")

rx_adsl_tbl
""":
  nbCode:
    let rxAdslIndented = tabella(rxAdslMerged):
      tabStubIndent allRows(), 5
      optAlignTableHeader "left"

    nbTable rxAdslIndented

nbText: """
Let's now change the column width of our Placebo and Drug 1 columns and align all values to the center, making use of `cols_width()` and `cols_align()`.
"""

tabs """
rx_adsl_tbl = rx_adsl_tbl.cols_width(
    {"label": "250px"} | {f"val_{arm}": "200px" for arm in arms}
).cols_align(align="center", columns=cs.starts_with("val_"))

rx_adsl_tbl
""", """
rx_adsl_tbl <-
  rx_adsl_tbl |>
  cols_width(
    starts_with("val_") ~ px(200),
    1 ~ px(250)
  ) |>
  cols_align(
    align = "center",
    columns = starts_with("val_")
  )

rx_adsl_tbl
""":
  nbCode:
    let rxAdslAligned = tabella(rxAdslIndented):
      colsWidth @[("label", "250px")] & arms.mapIt(("val_" & it, "200px"))
      colsAlign alCenter, startsWith("val_")

    nbTable rxAdslAligned

nbText: """
In a final step we can now take care of the column names and assign something more meaningful. Out column header should be the name of the study intervention together with the respective subject count. To make use of `cols_label()`'s ability to handle lists, we summarize our new column labels in a named list.
"""

tabs """
# Count subjects per arm and make the labels of the columns
arm_n = (
    rx_adsl.filter(pl.col("ITTFL") == "Y")
    .group_by("TRTA")
    .len()
    .sort(pl.col("TRTA").cast(pl.Enum(arms)))
)

collbl_list = {
    f"val_{arm}": f"{arm} N={n} (100%)" for arm, n in arm_n.iter_rows()
}

rx_adsl_tbl = rx_adsl_tbl.cols_label(collbl_list)

rx_adsl_tbl
""", """
### Count subjects per arm and summarize values in a list
arm_n <-
  rx_adsl |>
  dplyr::filter(ITTFL == "Y") |>
  dplyr::group_by(TRTA) |>
  dplyr::summarize(
    lbl = sprintf("%s N=%i (100%%)", unique(TRTA), dplyr::n()),
    .groups = "drop"
  ) |>
  dplyr::arrange(TRTA)

collbl_list <- as.list(arm_n$lbl)
names(collbl_list) <- paste0("val_", arm_n$TRTA)

rx_adsl_tbl <-
  rx_adsl_tbl |>
  cols_label(.list = collbl_list)

rx_adsl_tbl
""":
  nbCode:
    # Count subjects per arm and make the labels of the columns
    var collblList: seq[(string, string)]
    for arm in arms:
      let n = adslItt.filter(col("TRTA") == arm).height
      collblList.add ("val_" & arm, arm & " N=" & $n & " (100%)")

    let rxAdslLabelled = tabella(rxAdslAligned):
      colsLabel collblList

    nbTable rxAdslLabelled

nbText: """
### Response / Event Rate Analysis Tables

In another table, we can summarize the number of subjects with an event per intervention in the subgroup defined by the age groups. Within each intervention group we are counting the number and percentage of participants with an event (`EVNTFL == "Y"`) as well as the total number of participants. The number of participants with an event divided by the number without an event are the odds of experiencing the event per study intervention. The odds ratio is then computed as the odds under Drug 1 divided by the odds under Placebo.

The below code performs the calculation outlined above within the subgroup defined by `AAGEGR1`, where confidence intervals around the event rates are computed using the Clopper Pearson method.
"""

tabs """
# The probability of at most `k` events in `n`, each with probability `p`
def binom_cdf(k, n, p):
    return sum(
        exp(lgamma(n + 1) - lgamma(i + 1) - lgamma(n - i + 1) + i * log(p) + (n - i) * log(1 - p))
        for i in range(k + 1)
    )

# The `p` in (0, 1) where `f`, increasing, is zero
def bisect(f):
    lo, hi = 0.0, 1.0
    for _ in range(60):
        mid = (lo + hi) / 2
        lo, hi = (mid, hi) if f(mid) < 0 else (lo, mid)
    return (lo + hi) / 2

# The Clopper-Pearson interval of `x` events in `n` (R's `qf()` gives the same)
def clopper_pearson(x, n, level=0.95):
    a = (1 - level) / 2
    low = 0.0 if x == 0 else bisect(lambda p: 1 - binom_cdf(x - 1, n, p) - a)
    up = 1.0 if x == n else bisect(lambda p: a - binom_cdf(x, n, p))
    return low, up

z = 1.959963984540054  # R's qnorm(0.975)

rows = []
for age in rx_meta["rx_adsl"]["AAGEGR1"]["levels"]:
    row = {"AAGEGR1": age}
    for arm in arms:
        subjects = rx_adsl.filter(
            (pl.col("ITTFL") == "Y") & (pl.col("TRTA") == arm) & (pl.col("AAGEGR1") == age)
        )
        x = (subjects["EVNTFL"] == "Y").sum()
        n = len(subjects)
        low, up = clopper_pearson(x, n)
        row |= {
            f"n_resp_{arm}": x, f"n_total_{arm}": n, f"pct_{arm}": 100 * x / n,
            f"ci_up_{arm}": 100 * up, f"ci_low_{arm}": 100 * low, f"odds_{arm}": x / (n - x),
        }
    rows.append(row)

rx_responders = pl.DataFrame(rows)
rx_responders = (
    rx_responders.with_columns(
        **{
            "or": pl.when(pl.col("odds_Placebo") == 0)
            .then(None)
            .otherwise(pl.col("odds_Drug 1") / pl.col("odds_Placebo"))
        }
    )
    .with_columns(
        se=(
            1 / pl.col("n_resp_Placebo")
            + 1 / pl.col("n_resp_Drug 1")
            + 1 / (pl.col("n_total_Placebo") - pl.col("n_resp_Placebo"))
            + 1 / (pl.col("n_total_Drug 1") - pl.col("n_resp_Drug 1"))
        ).sqrt()
    )
    .with_columns(
        or_ci_low=(pl.col("or").log() - z * pl.col("se")).exp(),
        or_ci_up=(pl.col("or").log() + z * pl.col("se")).exp(),
    )
    .select(
        "AAGEGR1",
        *[f"{v}_{arm}" for v in ["n_resp", "n_total", "pct", "ci_up", "ci_low"] for arm in arms],
        "or", "or_ci_low", "or_ci_up",
    )
)
""", """
rx_responders <-
  rx_adsl |>
  dplyr::filter(ITTFL == "Y") |>
  dplyr::group_by(TRTA, AAGEGR1) |>
  dplyr::summarize(
    n_resp = sum(EVNTFL == "Y"),
    n_total = dplyr::n(),
    pct = 100 * sum(EVNTFL == "Y") / dplyr::n(),
    ci_up = 100 * (
      1 + (dplyr::n() - sum(EVNTFL == "Y")) / (
        (sum(EVNTFL == "Y") + 1) * qf(
          0.975,
          2 * (sum(EVNTFL == "Y") + 1),
          2 * (dplyr::n() - sum(EVNTFL == "Y"))
        )
      )
    )^(-1),
    ci_low = ifelse(
      sum(EVNTFL == "Y") == 0,
      0,
      100 * (
        1 + (dplyr::n() - sum(EVNTFL == "Y") + 1) /
          (sum(EVNTFL == "Y") * qf(
            0.025,
            2 * sum(EVNTFL == "Y"),
            2 * (dplyr::n() - sum(EVNTFL == "Y") + 1)
          )
          )
      )^(-1)
    ),
    odds = sum(EVNTFL == "Y") / (dplyr::n() - sum(EVNTFL == "Y")),
    .groups = "drop"
  ) |>
  tidyr::pivot_wider(
    id_cols = AAGEGR1,
    names_from = TRTA,
    values_from = c(n_resp, n_total, pct, ci_up, ci_low, odds)
  ) |>
  dplyr::mutate(
    or = ifelse(
      odds_Placebo == 0,
      NA_real_,
      !!sym("odds_Drug 1") / odds_Placebo
    ),
    or_ci_low = exp(
      log(or) - qnorm(0.975) * sqrt(
        1 / n_resp_Placebo +
          1 / !!sym("n_resp_Drug 1") +
            1 / (n_total_Placebo - n_resp_Placebo) +
            1 / (!!sym("n_total_Drug 1") - !!sym("n_resp_Drug 1"))
      )
    ),
    or_ci_up = exp(
      log(or) + qnorm(0.975) * sqrt(
        1 / n_resp_Placebo +
          1 / !!sym("n_resp_Drug 1") +
            1 / (n_total_Placebo - n_resp_Placebo) +
            1 / (!!sym("n_total_Drug 1") - !!sym("n_resp_Drug 1"))
      )
    )
  ) |>
  dplyr::select(-tidyselect::starts_with("odds_"))
""":
  nbCode:
    # The probability of at most `k` events in `n`, each with probability `p`
    proc binomCdf(k, n: int, p: float): float =
      for i in 0 .. k:
        result += exp(lgamma(float(n + 1)) - lgamma(float(i + 1)) - lgamma(float(n - i + 1)) +
                      float(i) * ln(p) + float(n - i) * ln(1 - p))

    # The `p` in (0, 1) where `f`, increasing, is zero
    proc bisect(f: proc (p: float): float): float =
      var (lo, hi) = (0.0, 1.0)
      for _ in 1 .. 60:
        let mid = (lo + hi) / 2
        if f(mid) < 0: lo = mid else: hi = mid
      (lo + hi) / 2

    # The Clopper-Pearson interval of `x` events in `n` (R's `qf()` gives the same)
    proc clopperPearson(x, n: int, level = 0.95): (float, float) =
      let a = (1 - level) / 2
      let low = if x == 0: 0.0 else: bisect(proc (p: float): float = 1 - binomCdf(x - 1, n, p) - a)
      let up = if x == n: 1.0 else: bisect(proc (p: float): float = a - binomCdf(x, n, p))
      (low, up)

    const z = 1.959963984540054  # R's qnorm(0.975)

    let counts = adslItt
      .groupBy("TRTA", "AAGEGR1")
      .agg((col("EVNTFL") == "Y").sum.alias("n_resp"), len().alias("n_total"))
      .sort([col("TRTA").cast(Enum(arms)),
             col("AAGEGR1").cast(Enum(meta["AAGEGR1"]["levels"].to(seq[string])))])

    # the intervals in Nim, one for each row: nanuq has no quantiles of the F distribution
    let intervals = zip(counts.toList("n_resp", int), counts.toList("n_total", int))
      .mapIt(clopperPearson(it[0], it[1]))

    let (resp, total) = (col("n_resp"), col("n_total"))
    proc byArm(name, arm: string): Expr = col(name & "_" & arm)

    let rxResponders = counts
      .withColumns(
        series("ci_up", intervals.mapIt(100 * it[1])),
        series("ci_low", intervals.mapIt(100 * it[0])))
      .withColumns((100 * resp / total).alias("pct"), (resp / (total - resp)).alias("odds"))
      .pivot("TRTA", index = "AAGEGR1",
             values = ["n_resp", "n_total", "pct", "ci_up", "ci_low", "odds"])
      .withColumns(
        `when`(byArm("odds", "Placebo") == 0).then(nil)
          .otherwise(byArm("odds", "Drug 1") / byArm("odds", "Placebo")).alias("or"),
        sqrt(1 / byArm("n_resp", "Placebo") + 1 / byArm("n_resp", "Drug 1") +
             1 / (byArm("n_total", "Placebo") - byArm("n_resp", "Placebo")) +
             1 / (byArm("n_total", "Drug 1") - byArm("n_resp", "Drug 1"))).alias("se"))
      .withColumns(
        exp(log(col("or")) - z * col("se")).alias("or_ci_low"),
        exp(log(col("or")) + z * col("se")).alias("or_ci_up"))
      .drop(["odds_Placebo", "odds_Drug 1", "se"])

tabelline """
Nim's standard library has no quantiles of the F distribution (R's `qf()`): the book finds the
Clopper-Pearson interval from the binomial probabilities, by bisection, which gives the same
numbers. Neither has `qnorm()`, so its value at 0.975 is written out.
"""

nbText: """
Let's first create a basic **gt** table with a left-aligned table title and subtitle. Here we are using `tab_header()` and `opt_align_table_header()` again.
"""

tabs """
rx_resp_tbl = GT(rx_responders).tab_header(
    title="x.x: Efficacy Data",
    subtitle="x.x.x: Occurence of Event per Subgroup - {gt} Analysis Set",
).opt_align_table_header(align="left")

rx_resp_tbl
""", """
rx_resp_tbl <- rx_responders |>
  gt() |>
  tab_header(
    title = "x.x: Efficacy Data",
    subtitle = "x.x.x: Occurence of Event per Subgroup - {gt} Analysis Set"
  ) |>
  opt_align_table_header(align = "left")

rx_resp_tbl
""":
  nbCode:
    let rxRespTbl = tabella(rxResponders):
      tabHeader "x.x: Efficacy Data",
        "x.x.x: Occurence of Event per Subgroup - {gt} Analysis Set"
      optAlignTableHeader "left"

    nbTable rxRespTbl

nbText: """
Next, we are formatting the columns for counts to integers with `fmt_integer()`, percentages and CI's around percentages as numbers with one decimal and odds ratio and the CI around the odds ratio as numbers with two decimals, in both cases using `fmt_number()`.
"""

tabs """
rx_resp_tbl = (
    rx_resp_tbl
    .fmt_integer(columns=cs.starts_with("n_"))
    .fmt_number(columns=cs.starts_with("pct_", "ci_"), decimals=1)
    .fmt_number(columns=cs.starts_with("or"), decimals=2)
)

rx_resp_tbl
""", """
rx_resp_tbl <-
  rx_resp_tbl |>
  fmt_integer(columns = starts_with("n_")) |>
  fmt_number(columns = starts_with(c("pct_", "ci_")), decimals = 1) |>
  fmt_number(columns = starts_with("or"), decimals = 2)

rx_resp_tbl
""":
  nbCode:
    let rxRespFmt = tabella(rxRespTbl):
      fmtInteger startsWith("n_")
      fmtNumber startsWith(["pct_", "ci_"]), decimals = 1
      fmtNumber startsWith("or"), decimals = 2

    nbTable rxRespFmt

nbText: """
We can now merge the columns for participants with events, total number of participants and percentage of participants with events, as well as the 95% CI's around the event rate using `cols_merge()`. To indicate the intervention group we are adding tab spanners with `tab_spanner()`.
"""

tabs """
rx_resp_tbl = (
    rx_resp_tbl
    .cols_merge(
        columns=["n_resp_Placebo", "n_total_Placebo", "pct_Placebo"], pattern="{0}/{1} ({2})"
    )
    .cols_merge(
        columns=["n_resp_Drug 1", "n_total_Drug 1", "pct_Drug 1"], pattern="{0}/{1} ({2})"
    )
    .cols_merge(columns=["ci_low_Placebo", "ci_up_Placebo"], pattern="[{0}, {1}]")
    .cols_merge(columns=["ci_low_Drug 1", "ci_up_Drug 1"], pattern="[{0}, {1}]")
    .cols_merge(columns=["or_ci_low", "or_ci_up"], pattern="[{0}, {1}]")
    .tab_spanner(label="Drug 1", columns=["n_resp_Drug 1", "ci_low_Drug 1"])
    .tab_spanner(label="Placebo", columns=["n_resp_Placebo", "ci_low_Placebo"])
)

rx_resp_tbl
""", """
rx_resp_tbl <-
  rx_resp_tbl |>
  cols_merge(
    columns = c("n_resp_Placebo", "n_total_Placebo", "pct_Placebo"),
    pattern = "{1}/{2} ({3})"
  ) |>
  cols_merge(
    columns = c("n_resp_Drug 1", "n_total_Drug 1", "pct_Drug 1"),
    pattern = "{1}/{2} ({3})"
  ) |>
  cols_merge(
    columns = c("ci_low_Placebo", "ci_up_Placebo"),
    pattern = "[{1}, {2}]"
  ) |>
  cols_merge(
    columns = c("ci_low_Drug 1", "ci_up_Drug 1"),
    pattern = "[{1}, {2}]"
  ) |>
  cols_merge(
    columns = c("or_ci_low", "or_ci_up"),
    pattern = "[{1}, {2}]"
  ) |>
  tab_spanner(
    label = "Drug 1",
    columns = c("n_resp_Drug 1", "ci_low_Drug 1")
  ) |>
  tab_spanner(
    label = "Placebo",
    columns = c("n_resp_Placebo", "ci_low_Placebo")
  )

rx_resp_tbl
""":
  nbCode:
    let rxRespMerged = tabella(rxRespFmt):
      for arm in arms:
        colsMerge ["n_resp_" & arm, "n_total_" & arm, "pct_" & arm], pattern = "{1}/{2} ({3})"
        colsMerge ["ci_low_" & arm, "ci_up_" & arm], pattern = "[{1}, {2}]"
      colsMerge ["or_ci_low", "or_ci_up"], pattern = "[{1}, {2}]"
      tabSpanner "Drug 1", cols("n_resp_Drug 1", "ci_low_Drug 1")
      tabSpanner "Placebo", cols("n_resp_Placebo", "ci_low_Placebo")

    nbTable rxRespMerged

tabelline """
A spanner gathers its columns next to the first one, as gt's `tab_spanner()` does
(`gather = false` leaves them where they are).
"""

nbText: """
The table is looking way better now. Let's now group the two categories and highlight the fact that these are actually age subgroups. We are using `tab_row_group()` to manually add a row group label *Age*.
"""

tabs """

""", """
rx_resp_tbl <-
  rx_resp_tbl |>
  tab_row_group(
    label = "Age",
    rows = everything()
  )

rx_resp_tbl
""":
  nbCode:
    let rxRespGrouped = tabella(rxRespMerged):
      tabRowGroup "Age", allRows()

    nbTable rxRespGrouped

tabelline """
Great Tables has no `tab_row_group()`: its groups come from a column of the data. Its tab here
goes on without the group *Age*.
"""

nbText: """
Next, we'll take care of the column labels. As we now have the `tab_row_group()` label in place, we no longer need the label for the first column and can assign an empty string. Also, because of the two tab spanners, we can assign equal column labels for event rates and 95% CI's in both intervention groups.

Using `cols_width()` and `cols_align()` we can apply a more convenient column width and left-align the first column.
"""

tabs """
rx_resp_tbl = (
    rx_resp_tbl
    .cols_align(align="center", columns=cs.starts_with("n_", "ci", "or"))
    .cols_label(
        {
            "AAGEGR1": "",
            "n_resp_Placebo": "Event Rate (%)",
            "ci_low_Placebo": "[95% CI]",
            "n_resp_Drug 1": "Event Rate (%)",
            "ci_low_Drug 1": "[95% CI]",
            "or": "Odds ratio",
            "or_ci_low": "[95% CI]",
        }
    )
    .cols_width({"AAGEGR1": "80px"} | {c: "120px" for c in rx_responders.columns[1:]})
    .cols_align(align="left", columns="AAGEGR1")
)

rx_resp_tbl
""", """
rx_resp_tbl <-
  rx_resp_tbl |>
  cols_align(
    align = "center",
    columns = starts_with(c("n_", "ci", "or"))
  ) |>
  cols_label(
    .list = c(
      "AAGEGR1" = "",
      "n_resp_Placebo" = "Event Rate (%)",
      "ci_low_Placebo" = "[95% CI]",
      "n_resp_Drug 1" = "Event Rate (%)",
      "ci_low_Drug 1" = "[95% CI]",
      "or" = "Odds ratio",
      "or_ci_low" = "[95% CI]"
    )
  ) |>
  cols_width(
    1 ~ px(80),
    everything() ~ px(120)
  ) |>
  cols_align(align = "left", columns = 1)

rx_resp_tbl
""":
  nbCode:
    let rxRespLabelled = tabella(rxRespGrouped):
      colsAlign alCenter, startsWith(["n_", "ci", "or"])
      colsLabel:
        AAGEGR1: ""
        n_resp_Placebo: "Event Rate (%)"
        ci_low_Placebo: "[95% CI]"
        "n_resp_Drug 1": "Event Rate (%)"
        "ci_low_Drug 1": "[95% CI]"
        "or": "Odds ratio"
        or_ci_low: "[95% CI]"
      colsWidth rxResponders.columns.mapIt((it, if it == "AAGEGR1": "80px" else: "120px"))
      colsAlign alLeft, positions(0)

    nbTable rxRespLabelled

tabelline """
In a block of pairs a name that is not a Nim name is written as a string: `"n_resp_Drug 1"`,
and `"or"`, a keyword of Nim. Columns by position count from 0 in tabelline, as in Python:
gt's `columns = 1` is `positions(0)`.
"""

nbText: """
Finally, we make use of `tab_footnote()` and can add a footnote to the columns with the 95% CI's around event rates, indicating that these were derived from the Clopper-Pearson method. To change the default symbol choice of `tab_footnote()` from numbers to letters, we add `tab_options(footnote.marks = letters)`.
"""

tabs """
rx_resp_tbl = rx_resp_tbl.tab_footnote(
    footnote="Event rate 95% exact confidence interval uses the Clopper−Pearson method.",
    locations=loc.column_labels(columns=["ci_low_Placebo", "ci_low_Drug 1"]),
    placement="right",
).tab_options(footnotes_marks="letters")

rx_resp_tbl
""", """
rx_resp_tbl <-
  rx_resp_tbl |>
  tab_footnote(
    footnote = "Event rate 95% exact confidence interval uses the Clopper−Pearson method.",
    locations = cells_column_labels(
      columns = c("ci_low_Placebo", "ci_low_Drug 1")
    ),
    placement = "right"
  ) |>
  tab_options(footnotes.marks = letters)

rx_resp_tbl
""":
  nbCode:
    let rxRespFinal = tabella(rxRespLabelled):
      tabFootnote "Event rate 95% exact confidence interval uses the Clopper−Pearson method.",
        loc.columnLabels(cols("ci_low_Placebo", "ci_low_Drug 1"))
      tabOptions:
        footnotesMarks = fmLetters

    nbTable rxRespFinal

tabelline """
tabelline puts a mark after the label always, so it needs no `placement`.
"""

nbText: """
### Protocol Deviation Table

For the summary table for protocol deviations (PDs) we will use a second CDISC-flavored dataset, namely `rx_addv`. This dataset contains a summary row, indicating whether a subject in the ITT population in `rx_adsl` experienced at least one major PD or not. In addition to the subject level summary, individual PDs are summarized.
"""

tabs """
rx_addv = pl.read_csv("../data/gt/rx_addv.csv")

rx_addv.glimpse()
""", """
rx_addv |> str()
""":
  nbCode:
    echo glimpse(rxAddv())

nbText: """
We would now like to build a table to summarize overall and counts of individual PDs by treatment arm and furthermore indicate, whether the PD was related to COVID-19 or not. In order to build this table, we first need to apply some data wrangling with functions from **dplyr** and **tidyr**.
"""

tabs """
params = rx_meta["rx_addv"]["PARAM"]["levels"]

addv_sum = (
    rx_addv.with_columns(NTOT=pl.col("USUBJID").n_unique().over("TRTA"))
    .group_by("TRTA", "PARCAT1", "PARAM", "CRIT1FL")
    .agg(
        n=pl.col("AVAL").sum(),
        pct=100 * pl.col("AVAL").sum() / pl.col("NTOT").mean(),
    )
    .sort(
        pl.col("TRTA").cast(pl.Enum(arms)), "PARCAT1",
        pl.col("PARAM").cast(pl.Enum(params)), "CRIT1FL",
    )
    .with_columns(arm_flag=pl.concat_str("TRTA", "CRIT1FL", separator="_"))
    .pivot(on="arm_flag", index=["PARCAT1", "PARAM"], values=["n", "pct"])
    .with_columns(cs.numeric().fill_null(0))
)
addv_sum = pl.concat(
    [pl.DataFrame({"PARAM": ["Subjects with at least:"]}), addv_sum],
    how="diagonal_relaxed",
)

addv_sum
""", """
addv_sum <-
  rx_addv |>
  dplyr::group_by(TRTA) |>
  dplyr::mutate(
    NTOT = n_distinct(USUBJID),
    .groups = "drop"
  ) |>
  dplyr::group_by(TRTA, PARCAT1, PARAM, CRIT1FL) |>
  dplyr::summarize(
    n = sum(AVAL, na.rm = TRUE),
    pct = 100 * sum(AVAL, na.rm = TRUE) / mean(NTOT),
    .groups = "drop"
  ) |>
  tidyr::pivot_wider(
    id_cols = c(PARCAT1, PARAM),
    names_from = c(TRTA, CRIT1FL),
    values_from = c(n, pct)
  ) |>
  dplyr::mutate(across(where(is.numeric), ~ ifelse(is.na(.), 0, .))) |>
  dplyr::add_row(PARAM = "Subjects with at least:", .before = 1)

addv_sum
""":
  nbCode:
    let rxAddv = readCsv(newStringStream(rxAddvCsv))
    let params = rxMeta()["rx_addv"]["PARAM"]["levels"].to(seq[string])

    let firstRow = newDataFrame:
      PARAM: ["Subjects with at least:"]

    let addvSum = concat([firstRow,
      rxAddv
        .withColumns(col("USUBJID").nUnique.over("TRTA").alias("NTOT"))
        .groupBy("TRTA", "PARCAT1", "PARAM", "CRIT1FL")
        .agg(
          col("AVAL").sum.alias("n"),
          (100 * col("AVAL").sum / col("NTOT").mean).alias("pct"))
        .sort([col("TRTA").cast(Enum(arms)), col("PARCAT1"),
               col("PARAM").cast(Enum(params)), col("CRIT1FL")])
        .withColumns(concatStr([col("TRTA"), col("CRIT1FL")], separator = "_").alias("arm_flag"))
        .pivot("arm_flag", index = ["PARCAT1", "PARAM"], values = ["n", "pct"])
        .fillNull(0)],
      how = ConcatMethod.DiagonalRelaxed)

    echo tabella(addvSum)

nbText: """
This is the dataset that serves as a starting point for `gt`. We will start by exposing the dataset to `gt` and add our usual left-aligned headers.
"""

tabs """
addv_tbl = GT(addv_sum, rowname_col="PARAM").tab_header(
    title="xx.x: Demographic and Baseline Data",
    subtitle="xx.x.x: Major Protocol Deviations and Relationship to COVID-19 - ITT Set",
).opt_align_table_header(align="left")

addv_tbl
""", """
addv_tbl <-
  addv_sum |>
  gt(rowname_col = "PARAM") |>
  tab_header(
    title = "xx.x: Demographic and Baseline Data",
    subtitle = "xx.x.x: Major Protocol Deviations and Relationship to COVID-19 - ITT Set"
  ) |>
  opt_align_table_header(align = "left")

addv_tbl
""":
  nbCode:
    let addvTbl = tabella(addvSum, rownameCol = "PARAM"):
      tabHeader "xx.x: Demographic and Baseline Data",
        "xx.x.x: Major Protocol Deviations and Relationship to COVID-19 - ITT Set"
      optAlignTableHeader "left"

    nbTable addvTbl

nbText: """
In a next step, we would like to create a summary row for all individual PDs to get the overall number of individual PDs, as well as the corresponding percentage. For this, we will first create a row group for individual PDs using `tab_row_group()` applied to all rows where `PARCAT1` is equal to `PROTOCOL DEVIATIONS`. Then, we'll arrange the order of the row groups to list individual PDs after the overall summary. Finally, we can create a summary row, using `summary_rows()` and `gt` sums up all columns with n's and percentages for us (other summary functions are possible, but `fn = 'sum'` does the job for us).
"""

tabs """
# Great Tables has no tab_row_group(): the row groups come from a column of
# the data, so the table is made again with a column `group` (the first rows
# go in a group with an empty label: they cannot be in no group, as gt's NA)
addv_tbl = (
    GT(
        addv_sum.with_columns(
            group=pl.when(pl.col("PARCAT1") == "PROTOCOL DEVIATION")
            .then(pl.lit(" "))
            .otherwise(pl.lit(""))
        ),
        rowname_col="PARAM",
        groupname_col="group",
    )
    .tab_header(
        title="xx.x: Demographic and Baseline Data",
        subtitle="xx.x.x: Major Protocol Deviations and Relationship to COVID-19 - ITT Set",
    )
    .opt_align_table_header(align="left")
    .summary_rows(
        fns={"Study Procedure Deviations": cs.numeric().sum()},
        groups=[" "],
        side="top",
    )
)

addv_tbl
""", """
addv_tbl <-
  addv_tbl |>
  tab_row_group(
    label = " ",
    rows = PARCAT1 == "PROTOCOL DEVIATION"
  ) |>
  row_group_order(groups = c(NA, " ")) |>
  summary_rows(
    groups = " ",
    columns = where(is.numeric),
    fns = list(label = "Study Procedure Deviations", fn = "sum"),
    side = "top"
  )

addv_tbl
""":
  nbCode:
    let addvGrouped = tabella(addvTbl):
      tabRowGroup " ", where(it.PARCAT1 == "PROTOCOL DEVIATION")
      summaryRows:
        "Study Procedure Deviations": agg.sum
        groups = [" "]
        side = sTop

    nbTable addvGrouped

tabelline """
Rows in no group come first in tabelline, so it needs no `rowGroupOrder` here (gt's
`row_group_order(groups = c(NA, " "))`).
"""

nbText: """
We only kept the column `PARCAT1` to facilitate the generation of the row group. We can hide this column now using `cols_hide()`:
"""

tabs """
addv_tbl = addv_tbl.cols_hide(columns="PARCAT1")

addv_tbl
""", """
addv_tbl <-
  addv_tbl |>
  cols_hide(columns = "PARCAT1")

addv_tbl
""":
  nbCode:
    let addvHidden = tabella(addvGrouped):
      colsHide "PARCAT1"

    nbTable addvHidden

nbText: """
Now that the table has roughly the right shape, we can start to format all numeric columns and merge columns for n's and percentages by intervention group and COVID-19 relationship flag.
"""

tabs """
addv_tbl = (
    addv_tbl
    .sub_missing(rows=[0], missing_text="")
    .fmt_number(columns=cs.starts_with("pct"), decimals=1)
    .cols_merge_n_pct(col_n="n_Placebo_Y", col_pct="pct_Placebo_Y")
    .cols_merge_n_pct(col_n="n_Placebo_N", col_pct="pct_Placebo_N")
    .cols_merge_n_pct(col_n="n_Drug 1_Y", col_pct="pct_Drug 1_Y")
    .cols_merge_n_pct(col_n="n_Drug 1_N", col_pct="pct_Drug 1_N")
)

addv_tbl
""", """
addv_tbl <-
  addv_tbl |>
  sub_missing(
    rows = 1,
    missing_text = ""
  ) |>
  fmt_number(
    columns = starts_with("pct"),
    decimals = 1
  ) |>
  cols_merge_n_pct(
    col_n = "n_Placebo_Y",
    col_pct = "pct_Placebo_Y"
  ) |>
  cols_merge_n_pct(
    col_n = "n_Placebo_N",
    col_pct = "pct_Placebo_N"
  ) |>
  cols_merge_n_pct(
    col_n = "n_Drug 1_Y",
    col_pct = "pct_Drug 1_Y"
  ) |>
  cols_merge_n_pct(
    col_n = "n_Drug 1_N",
    col_pct = "pct_Drug 1_N"
  )

addv_tbl
""":
  nbCode:
    let addvMerged = tabella(addvHidden):
      subMissing(rows = 0, missingText = "")
      fmtNumber startsWith("pct"), decimals = 1
      for arm in arms:
        for flag in ["Y", "N"]:
          colsMergeNPct "n_" & arm & "_" & flag, "pct_" & arm & "_" & flag

    nbTable addvMerged

nbText: """
This looks more like a PD table! We can now modify the column names and create a cascade of column spanners.
"""

tabs """
addv_tbl = (
    addv_tbl
    .tab_spanner(
        label=md("COVID-19 Related"), columns=["n_Placebo_Y", "n_Placebo_N"], id="cov_pla"
    )
    .tab_spanner(
        label=md("COVID-19 Related"), columns=["n_Drug 1_Y", "n_Drug 1_N"], id="cov_dru"
    )
    .tab_spanner(
        label=md("Placebo  \n  N=90 (100%)  \n   n (%)"),
        columns=["n_Placebo_Y", "n_Placebo_N"],
        id="pla",
    )
    .tab_spanner(
        label=md("Drug 1  \n  N=90 (100%)  \n   n (%)"),
        columns=["n_Drug 1_Y", "n_Drug 1_N"],
        id="dru",
    )
    .cols_label(
        {"n_Placebo_Y": "Yes", "n_Placebo_N": "No", "n_Drug 1_Y": "Yes", "n_Drug 1_N": "No"}
    )
    .tab_style(
        style=style.text(align="center"),
        locations=loc.spanner_labels(ids=["cov_pla", "cov_dru", "pla", "dru"]),
    )
)

addv_tbl
""", """
addv_tbl <-
  addv_tbl |>
  tab_spanner(
    label = md("COVID-19 Related"),
    columns = c("n_Placebo_Y", "n_Placebo_N"),
    id = "cov_pla"
  ) |>
  tab_spanner(
    label = md("COVID-19 Related"),
    columns = c("n_Drug 1_Y", "n_Drug 1_N"),
    id = "cov_dru"
  ) |>
  tab_spanner(
    label = md("Placebo  \n  N=90 (100%)  \n   n (%)"),
    columns = c("n_Placebo_Y", "n_Placebo_N")
  ) |>
  tab_spanner(
    label = md("Drug 1  \n  N=90 (100%)  \n   n (%)"),
    columns = c("n_Drug 1_Y", "n_Drug 1_N")
  ) |>
  cols_label(
    .list = list(
      "n_Placebo_Y" = "Yes",
      "n_Placebo_N" = "No",
      "n_Drug 1_Y" = "Yes",
      "n_Drug 1_N" = "No"
    )
  ) |>
  tab_style(
    style = cell_text(align = "center"),
    locations = cells_column_spanners(spanners = everything())
  )

addv_tbl
""":
  nbCode:
    let addvSpanned = tabella(addvMerged):
      tabSpanner md"COVID-19 Related", cols("n_Placebo_Y", "n_Placebo_N")
      tabSpanner md"COVID-19 Related", cols("n_Drug 1_Y", "n_Drug 1_N")
      tabSpanner md("Placebo  \n  N=90 (100%)  \n   n (%)"), cols("n_Placebo_Y", "n_Placebo_N"), level = 2
      tabSpanner md("Drug 1  \n  N=90 (100%)  \n   n (%)"), cols("n_Drug 1_Y", "n_Drug 1_N"), level = 2
      colsLabel:
        n_Placebo_Y: "Yes"
        n_Placebo_N: "No"
        "n_Drug 1_Y": "Yes"
        "n_Drug 1_N": "No"
      tabStyle style.text(align = "center"), loc.spanners("COVID-19 Related", "Placebo  \n  N=90 (100%)  \n   n (%)", "Drug 1  \n  N=90 (100%)  \n   n (%)")

    nbTable addvSpanned

tabelline """
Two spanners with the same label are told apart by their columns, so tabelline needs no `id`;
a spanner over another one takes `level = 2`, where gt finds the level itself. A spanner gathers
its columns in the order given, Yes before No, as gt's does, and `md` breaks a line at two spaces
and a newline, as Markdown does.
"""

nbText: """
We can now add a footnote, indicating that subjects can have more than one PD during the course of the study. The footnote is added with `tab_footnote()` to the row `At least one major Protocol Deviation`.
"""

tabs """
addv_tbl = addv_tbl.tab_footnote(
    footnote="Subjects can have more than one Protocol Deviation throughout the study.",
    locations=loc.stub(rows=["At least one major Protocol Deviation"]),
    placement="right",
)

addv_tbl
""", """
addv_tbl <-
  addv_tbl |>
  tab_footnote(
    footnote = "Subjects can have more than one Protocol Deviation throughout the study.",
    locations = cells_stub(rows = c("At least one major Protocol Deviation")),
    placement = "right"
  )

addv_tbl
""":
  nbCode:
    let addvFootnoted = tabella(addvSpanned):
      tabFootnote "Subjects can have more than one Protocol Deviation throughout the study.",
        loc.stub(rows = where(it.PARAM == "At least one major Protocol Deviation"))

    nbTable addvFootnoted

nbText: """
Finally, we can style the table, indenting the individual PDs under `Study Procedure Deviations`, left-aligning the first column and centering all other columns. Note that for the indentation, we can still use the hidden column `PARCAT1` to identify individual PDs.
"""

tabs """
addv_tbl.cols_align(align="center", columns=cs.starts_with("n_")).cols_align(
    align="left", columns=["PARCAT1", "PARAM"]
).tab_stub_indent(rows=pl.col("PARCAT1") == "PROTOCOL DEVIATION", indent=5)
""", """
addv_tbl |>
  cols_align(
    align = "center",
    columns = 3:6
  ) |>
  cols_align(
    align = "left",
    columns = 1:2
  ) |>
  tab_stub_indent(
    rows = PARCAT1 == "PROTOCOL DEVIATION",
    indent = 5
  )
""":
  nbCode:
    let addvFinal = tabella(addvFootnoted):
      colsAlign alCenter, startsWith("n_")
      colsAlign alLeft, cols("PARCAT1", "PARAM")
      tabStubIndent where(it.PARCAT1 == "PROTOCOL DEVIATION"), 5

    nbTable addvFinal

bookSave()
