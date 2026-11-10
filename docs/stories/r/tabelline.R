# What the R cells of a story take for granted: the few things tabelline has and gt has not.
# A story written in R first (to be ported to Nim when the release is built) reads this before
# its first cell (docs/stories/r/run.R).

# tint("--success-soft"): a colour of the page, as tabelline's `tint`. gt takes only named or
# hex colours, so each token is a placeholder hex here, and the page puts `var(--token)` back
# when it is built (blocks.nim, `runR`). The list is `tokenColours` of docs/theme.nim.
tokens <- c("--paper", "--shade", "--line", "--muted", "--ink", "--surface",
            "--primary", "--primary-soft", "--primary-text", "--secondary", "--secondary-soft",
            "--secondary-text", "--warning", "--warning-soft", "--success", "--success-soft",
            "--success-text")
tint <- function(token) {
  i <- match(token, tokens)
  if (is.na(i)) stop("not a token: ", token)
  sprintf("#F0E0%02X", i)
}

# opt_css_theme(): tabelline's `optCssTheme()`, every colour of the table and its font from the
# page, so the table follows the page's look (Munari or quaderno).
opt_css_theme <- function(data) {
  gt::tab_options(data,
    table.font.names = "var(--font)",
    table.font.color = tint("--ink"),
    table.background.color = tint("--paper"),
    table.border.top.color = tint("--ink"), table.border.top.width = gt::px(3),
    table.border.bottom.color = tint("--ink"), table.border.bottom.width = gt::px(3),
    heading.border.bottom.color = tint("--primary"),
    column_labels.border.bottom.color = tint("--ink"),
    column_labels.border.top.color = tint("--ink"),
    column_labels.font.weight = "bold",
    table_body.hlines.color = tint("--line"),
    table_body.border.bottom.color = tint("--ink"),
    row_group.background.color = tint("--shade"),
    row_group.border.top.color = tint("--ink"),
    row_group.border.bottom.color = tint("--line"),
    summary_row.background.color = tint("--shade"),
    grand_summary_row.background.color = tint("--shade"),
    stub.border.color = tint("--line"),
    footnotes.border.bottom.color = tint("--ink"),
    source_notes.border.bottom.color = tint("--ink"),
    heading.title.font.size = "17px", heading.subtitle.font.size = "13px",
    source_notes.font.size = "12px", footnotes.font.size = "12px",
    table.font.size = "14px")
}
