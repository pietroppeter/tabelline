# Runs the gt (R) side of a chapter of the tabelline book.
#
#     Rscript book/gt/run.R < cells.json > outputs.json
#
# The R twin of run.py. Reads `{"chapter": <name>, "cells": [<R code>, ...]}` and runs the
# cells in order, in one environment, like the cells of a notebook. For each cell it writes
# what the cell printed and the HTML of its last value, if visible: a gt table as
# `as_raw_html(inline_css = FALSE)`, HTML as it is, anything else as printed text. The book's build
# (book/tabbook.nim) calls this only when a chapter's R changed, and keeps the outputs in
# book/gt/outputs-r/<chapter>.json, which is committed: building the book needs no R otherwise.
#
# gt gives every table a random id; the random generator is seeded from the chapter's name, so
# running a chapter again gives the same HTML.
#
# Needs R with the packages gt (the book records its version), dplyr, tidyr and jsonlite:
# install.packages(c("gt", "dplyr", "tidyr", "jsonlite", "knitr")).
suppressPackageStartupMessages({
  library(jsonlite)
})

args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("^--file=", "", args[grep("^--file=", args)])))
setwd(here)  # cells read data relative to book/gt

shown <- function(value) {
  if (inherits(value, "gt_tbl")) {
    h <- as.character(gt::as_raw_html(value, inline_css = FALSE))
    return(gsub("@import url\\([^)]*\\);?", "", h))  # nothing remote in the book's pages
  }
  if (inherits(value, "html")) {  # HTML made by the cell (htmltools::HTML)
    return(gsub("@import url\\([^)]*\\);?", "", as.character(value)))
  }
  text <- paste(utils::capture.output(print(value)), collapse = "\n")
  paste0("<pre class=\"nb-output\">", htmltools::htmlEscape(text), "</pre>")
}

run <- function(code, env) {
  exprs <- parse(text = code, keep.source = FALSE)
  value <- NULL
  visible <- FALSE
  printed <- utils::capture.output({
    for (k in seq_along(exprs)) {
      r <- withVisible(eval(exprs[[k]], env))
      value <- r$value
      visible <- r$visible
      # a visible value before the last one prints, as at the console
      if (k < length(exprs) && visible && !inherits(value, "gt_tbl")) print(value)
    }
  }, type = "output")
  list(printed = paste(printed, collapse = "\n"),
       html = if (length(exprs) > 0 && visible) shown(value) else "")
}

main <- function() {
  req <- fromJSON(paste(readLines(file("stdin"), warn = FALSE), collapse = "\n"),
                  simplifyVector = FALSE)
  # a seed from the chapter's name
  set.seed(sum(utf8ToInt(req$chapter) * seq_along(utf8ToInt(req$chapter))) %% .Machine$integer.max)
  env <- new.env(parent = globalenv())
  outputs <- lapply(req$cells, function(code) {
    tryCatch(run(code, env), error = function(e)
      list(printed = "", html = "", error = conditionMessage(e)))
  })
  cat(toJSON(list(gt = as.character(packageVersion("gt")), r = paste(R.version$major, R.version$minor, sep = "."),
                  outputs = outputs), auto_unbox = TRUE, null = "null"))
}

main()
