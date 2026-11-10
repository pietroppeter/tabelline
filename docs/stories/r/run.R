# Runs the R cells of a story, written in R with gt before tabelline has the features it needs.
#
#     Rscript docs/stories/r/run.R < cells.json > outputs.json
#
# Reads `{"page": <name>, "dir": <data dir, from the repository's root>, "cells": [<R code>, ...]}`,
# sources tabelline.R (beside this file), moves to `dir` and runs the cells in order, in one
# environment, like a notebook's. For each cell it writes what it printed and the HTML of its
# last value, if visible (a gt table as `as_raw_html(inline_css = FALSE)`). The page's build
# (`runR` in docs/blocks.nim) calls it only when a cell changed, and keeps the outputs in a
# committed JSON file, so building the site needs no R. gt's random table ids are seeded from
# the page's name, so a second run gives the same HTML.
suppressPackageStartupMessages({
  library(jsonlite)
  library(gt)
})

args <- commandArgs(trailingOnly = FALSE)
here <- dirname(normalizePath(sub("^--file=", "", args[grep("^--file=", args)])))
root <- normalizePath(file.path(here, "..", "..", ".."))

shown <- function(value) {
  if (inherits(value, "gt_tbl")) {
    h <- as.character(gt::as_raw_html(value, inline_css = FALSE))
    return(gsub("@import url\\([^)]*\\);?", "", h))  # nothing remote in the pages
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
      if (k < length(exprs) && visible && !inherits(value, "gt_tbl")) print(value)
    }
  }, type = "output")
  list(printed = paste(printed, collapse = "\n"),
       html = if (length(exprs) > 0 && visible) shown(value) else "")
}

main <- function() {
  invisible(Sys.setlocale("LC_ALL", "C.UTF-8"))  # the data has accents and dashes
  req <- fromJSON(paste(readLines(file("stdin"), warn = FALSE), collapse = "\n"),
                  simplifyVector = FALSE)
  set.seed(sum(utf8ToInt(req$page) * seq_along(utf8ToInt(req$page))) %% .Machine$integer.max)
  env <- new.env(parent = globalenv())
  sys.source(file.path(here, "tabelline.R"), envir = env)
  setwd(file.path(root, req$dir))
  outputs <- lapply(req$cells, function(code) {
    tryCatch(run(code, env), error = function(e)
      list(printed = "", html = "", error = conditionMessage(e)))
  })
  cat(toJSON(list(gt = as.character(packageVersion("gt")),
                  r = paste(R.version$major, R.version$minor, sep = "."),
                  outputs = outputs), auto_unbox = TRUE, null = "null"))
}

main()
