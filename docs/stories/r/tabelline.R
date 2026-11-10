# What the R cells of a story take for granted: the few things tabelline has and gt has not.
# A story written in R first (to be ported to Nim when the release is built) reads this before
# its first cell (docs/stories/r/run.R).

# tinta("--success-soft"): a colour of the page, as tabelline's `tinta`. gt takes only named or
# hex colours, so each token is a placeholder hex here, and the page puts `var(--token)` back
# when it is built (blocchi.nim, `runR`). The list is `tokenColours` of docs/stile.nim.
tokens <- c("--paper", "--shade", "--line", "--muted", "--ink", "--surface",
            "--primary", "--primary-soft", "--primary-text", "--secondary", "--secondary-soft",
            "--secondary-text", "--warning", "--warning-soft", "--success", "--success-soft",
            "--success-text")
tinta <- function(token) {
  i <- match(token, tokens)
  if (is.na(i)) stop("not a token: ", token)
  sprintf("#F0E0%02X", i)
}

# opt_css_theme(): tabelline's `optCssTheme()`, every colour of the table and its font from the
# page, so the table follows the page's look (Munari or quaderno).
opt_css_theme <- function(data) {
  gt::tab_options(data,
    table.font.names = "var(--font)",
    table.font.color = tinta("--ink"),
    table.background.color = tinta("--paper"),
    table.border.top.color = tinta("--ink"), table.border.top.width = gt::px(3),
    table.border.bottom.color = tinta("--ink"), table.border.bottom.width = gt::px(3),
    heading.border.bottom.color = tinta("--primary"),
    column_labels.border.bottom.color = tinta("--ink"),
    column_labels.border.top.color = tinta("--ink"),
    column_labels.font.weight = "bold",
    table_body.hlines.color = tinta("--line"),
    table_body.border.bottom.color = tinta("--ink"),
    row_group.background.color = tinta("--shade"),
    row_group.border.top.color = tinta("--ink"),
    row_group.border.bottom.color = tinta("--line"),
    summary_row.background.color = tinta("--shade"),
    grand_summary_row.background.color = tinta("--shade"),
    stub.border.color = tinta("--line"),
    footnotes.border.bottom.color = tinta("--ink"),
    source_notes.border.bottom.color = tinta("--ink"),
    heading.title.font.size = "17px", heading.subtitle.font.size = "13px",
    source_notes.font.size = "12px", footnotes.font.size = "12px",
    table.font.size = "14px")
}
