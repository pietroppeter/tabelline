# gt's datasets

`rx_adsl` and `rx_addv`, fictional clinical trial data from the R package
[gt](https://gt.rstudio.com) (MIT, a copy of its licence is in `licenses/gt-MIT.txt`), written
with gt 1.4.0 as CSV files (missing values are empty). R keeps a label with each column, units
with some, and the order of the levels of a factor: they are in `rx_meta.json`. To write them again:

```r
library(gt); library(jsonlite)
meta <- function(d) lapply(d, function(c) {
  m <- list(label = attr(c, "label"))
  if (!is.null(attr(c, "units"))) m$units <- attr(c, "units")
  if (is.factor(c)) m$levels <- levels(c)
  m
})
write.csv(rx_adsl, "rx_adsl.csv", row.names = FALSE, na = "")
write.csv(rx_addv, "rx_addv.csv", row.names = FALSE, na = "")
writeLines(toJSON(list(rx_adsl = meta(rx_adsl), rx_addv = meta(rx_addv)),
                  auto_unbox = TRUE, pretty = TRUE), "rx_meta.json")
```
