library(gt)
library(dplyr)

gtcars |>
  filter(ctry_origin %in% c("Germany", "Italy")) |>
  select(model, ctry_origin, hp, mpg_c, mpg_h, msrp) |>
  gt(rowname_col = "model", groupname_col = "ctry_origin") |>
  tab_header(title = md("**German and Italian** cars")) |>
  cols_merge_range(col_begin = mpg_c, col_end = mpg_h) |>
  cols_label(mpg_c = "MPG (city–hwy)", hp = "HP", msrp = "Price") |>
  fmt_currency(columns = msrp, decimals = 0) |>
  summary_rows(
    columns = c(hp, msrp),
    fns = list(Average = ~ mean(.)),
    fmt = ~ fmt_number(., decimals = 0)
  ) |>
  grand_summary_rows(
    columns = msrp,
    fns = list(Max = ~ max(.)),
    fmt = ~ fmt_currency(., decimals = 0)
  ) |>
  data_color(columns = hp, palette = "viridis")
