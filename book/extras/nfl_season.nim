import tabbook
bookInit()

nbText: "# An NFL season"

attribution Source(title: "“NFL 2011 Season”, an example of gt-extras",
  url: "https://posit-dev.github.io/gt-extras/examples/with-code.html#nfl_table",
  authors: "the gt-extras contributors (Posit Software, PBC)", license: "MIT",
  licenseUrl: "https://github.com/posit-dev/gt-extras/blob/main/LICENSE",
  changes: "The table is the example of the page Examples With Code, made from the data that " &
    "the notebook An NFL season prepares (book/data/gt-extras/); the notebook's data steps " &
    "are told, not repeated. The R tab is written for the book with gtExtras, gt-extras' R " &
    "original.")

nbText: """
[gt-extras](https://posit-dev.github.io/gt-extras/) adds plots, icons and themes to Great
Tables, each a function that takes a table and gives it back (`GT.pipe`), after
[gtExtras](https://jthomasmock.github.io/gtExtras/) by Tom Mock for gt. Its example of an NFL
season puts most of them in one table: a strip of wins and losses for each team, an arrow for
its streak, a dumbbell from the points it scored to the points it allowed, a coloured box for
the difference, two rows highlighted (the two teams of the Super Bowl), and the
[FiveThirtyEight](https://fivethirtyeight.com) look, in two tables side by side.

The notebook [An NFL season](https://github.com/posit-dev/gt-extras/blob/main/docs/examples/nfl-season/index.ipynb)
makes the data from [nflverse's games](https://github.com/nflverse/nfldata), as the Super Bowl
Squares post does: the regular season's games, a row for each team with its record, its average
points for and against, its sixteen results (1 a win, 0 a loss, ½ a tie) and its streak, joined
with the teams' divisions, names and logos, sorted by division and wins.
"""

tabs """
import polars as pl
from great_tables import GT, loc, md, style
import gt_extras as gte

nfl_df = pl.read_json("../data/gt-extras/nfl_2011_stats.json")

def make_gt(df) -> GT:
    return (
        GT(df, rowname_col="Team", groupname_col="team_division")
        .tab_header(
            title="2011 NFL Season at a Glance",
            subtitle="Super Bowl XLVI: New York Giants def. New England Patriots",
        )
        .tab_source_note(
            md(
                '<span style="float: right;">Source: [Lee Sharpe, nflverse](https://github.com/nflverse/nfldata)</span>'
            )
        )
        .tab_stubhead(label="Team")
        .tab_spanner(label="Scoring", columns=["Avg PF", "Avg PA", "Point Diff"])
        .tab_spanner(label="Season Trends", columns=["Games", "Streak"])
        .fmt_number(columns="Point Diff", decimals=1)
        .fmt_image("team_logo_espn")
        .cols_hide(["Wins", "team_conf", "team_name"])
        .cols_align(align="center", columns=["Avg PF", "Avg PA", "Games"])
        # Great Tables 1.1 moves no column after the stub: the logo goes first
        .cols_move_to_start("team_logo_espn")
        .cols_label({"team_logo_espn": ""})
        .pipe(
            gte.gt_plt_winloss,
            column="Games",
            win_color="blue",
            loss_color="orange",
            tie_color="gray",
            height=40,
            width=120,
        )
        .pipe(
            gte.gt_fa_rank_change,
            column="Streak",
            icon_type="turn",
            color_up="blue",
            color_down="orange",
            size=14,
        )
        .pipe(
            gte.gt_plt_dumbbell,
            col1="Avg PF",
            col2="Avg PA",
            col1_color="green",
            col2_color="red",
            width=300,
            height=40,
            num_decimals=0,
            label="Points For vs Points Against",
            font_size=12,
        )
        .pipe(
            gte.gt_color_box,
            columns="Point Diff",
            palette=["green", "yellow", "red"],
            domain=[14, -14]
        )
        # Great Tables 1.1 styles the stub only through loc.stub(), not as a column
        .tab_style(style.fill(color="lightgray"), loc.stub())
        .pipe(gte.gt_highlight_rows, rows="NYG", fill="gold", alpha=0.3)
        .pipe(gte.gt_highlight_rows, rows="NE", fill="silver", alpha=0.3)
        .pipe(gte.gt_add_divider, columns="Point Diff", color="darkblue", weight=3)
        .pipe(gte.gt_theme_538)
    )


gt1 = make_gt(nfl_df.head(16))
gt2 = make_gt(nfl_df.slice(16, 16))

gte.gt_two_column_layout(gt1, gt2, table_header_from=1)
""", """
library(gt)
library(gtExtras)
library(dplyr)

nfl_df <- jsonlite::fromJSON("../data/gt-extras/nfl_2011_stats.json")

make_gt <- function(df) {
  df |>
    gt(rowname_col = "Team", groupname_col = "team_division") |>
    tab_header(
      title = "2011 NFL Season at a Glance",
      subtitle = "Super Bowl XLVI: New York Giants def. New England Patriots"
    ) |>
    tab_source_note(
      md("Source: [Lee Sharpe, nflverse](https://github.com/nflverse/nfldata)")
    ) |>
    tab_stubhead(label = "Team") |>
    tab_spanner(label = "Scoring", columns = c(`Avg PF`, `Avg PA`, `Point Diff`)) |>
    tab_spanner(label = "Season Trends", columns = c(Games, Streak)) |>
    fmt_number(columns = `Point Diff`, decimals = 1) |>
    gt_img_rows(columns = team_logo_espn, height = 25) |>
    cols_hide(c(Wins, team_conf, team_name)) |>
    cols_align(align = "center", columns = c(`Avg PF`, `Avg PA`, Games)) |>
    cols_move_to_start(team_logo_espn) |>
    cols_label(team_logo_espn = "") |>
    gt_plt_winloss(Games, max_wins = 16, palette = c("blue", "orange", "gray")) |>
    gt_fa_rank_change(Streak, fa_type = "turn", palette = c("blue", "grey", "orange")) |>
    gt_plt_dumbbell(
      `Avg PF`, `Avg PA`,
      label = "Points For vs Points Against",
      palette = c("green", "red", "lightgrey")
    ) |>
    gt_color_box(columns = `Point Diff`, palette = c("red", "yellow", "green"), domain = c(-14, 14)) |>
    gt_highlight_cols(columns = Team, fill = "lightgray") |>
    gt_highlight_rows(rows = Team == "NYG", fill = "gold", alpha = 0.3, font_weight = "normal") |>
    gt_highlight_rows(rows = Team == "NE", fill = "silver", alpha = 0.3, font_weight = "normal") |>
    gt_add_divider(columns = `Point Diff`, color = "darkblue", weight = px(3)) |>
    gt_theme_538(quiet = TRUE)
}

gt1 <- make_gt(nfl_df[1:16, ])
gt2 <- make_gt(nfl_df[17:32, ])

htmltools::HTML(as.character(gt_two_column_layout(list(gt1, gt2), output = "viewer")))
""":
  nbCode:
    import std/[math, sequtils, streams, strformat, strutils]
    import nanuq
    import tabelline, tabelline/nanuq, tabelline/colors, gtdata

    let nflDf = readJson(newStringStream(nflStatsJson))
      .withColumns(
        # the sixteen results as a text of numbers ("1.0 0.0 0.5 ...")
        col("Games").list.eval(element().`cast`(String)).list.join(" "),
        # points for and against in one cell, for the dumbbell
        concatStr([col("Avg PF").`cast`(String), col("Avg PA").`cast`(String)], " ").alias("Avg PF"))

    proc winloss(games: string, width = 120.0, height = 40.0): string =
      ## A strip of results: a win a bar up, a loss a bar down, a tie a short bar in the middle.
      let results = games.splitWhitespace.mapIt(parseFloat(it))
      let w = width / 16
      result = &"<svg width=\"{width}\" height=\"{height}\" role=\"img\" aria-label=\"{games}\">"
      for i, r in results:
        let (y, h, colour) =
          if r == 1: (height * 0.1, height * 0.4, "blue")
          elif r == 0: (height * 0.5, height * 0.4, "orange")
          else: (height * 0.4, height * 0.2, "gray")
        result.add &"<rect x=\"{i.float * w + 1:.1f}\" y=\"{y:.1f}\" width=\"{w - 2:.1f}\" " &
          &"height=\"{h:.1f}\" rx=\"2\" fill=\"{colour}\"/>"
      result.add "</svg>"

    proc rankChange(streak: Value): string =
      ## The streak with an arrow: up and blue for wins, down and orange for losses.
      let n = streak.toFloat.int
      if n > 0: iconSvg("turn-up", height = "14px", fill = "blue") & &" {n}"
      elif n < 0: iconSvg("turn-down", height = "14px", fill = "orange") & &" {-n}"
      else: "0"

    const lo = 10.0  # the points of the dumbbells, along a scale shared by the rows
    const hi = 35.0
    proc dumbbell(points: string, width = 300.0, height = 40.0): string =
      ## Points for (green) and against (red) as two dots joined by a line, with their values.
      let p = points.splitWhitespace.mapIt(parseFloat(it))
      let x = p.mapIt(20 + (it - lo) / (hi - lo) * (width - 40))
      &"<svg width=\"{width}\" height=\"{height}\" role=\"img\" aria-label=\"{points}\">" &
        &"<line x1=\"{x[0]:.1f}\" x2=\"{x[1]:.1f}\" y1=\"26\" y2=\"26\" stroke=\"lightgrey\" stroke-width=\"3\"/>" &
        &"<circle cx=\"{x[0]:.1f}\" cy=\"26\" r=\"5\" fill=\"green\"/>" &
        &"<circle cx=\"{x[1]:.1f}\" cy=\"26\" r=\"5\" fill=\"red\"/>" &
        &"<text x=\"{x[0]:.1f}\" y=\"14\" font-size=\"12\" text-anchor=\"middle\" fill=\"green\">{p[0].round.int}</text>" &
        &"<text x=\"{x[1]:.1f}\" y=\"14\" font-size=\"12\" text-anchor=\"middle\" fill=\"red\">{p[1].round.int}</text></svg>"

    proc colorBox(diff: Value): string =
      ## The difference in a box coloured from red (-14) through yellow to green (14).
      let x = diff.toFloat
      let fill = interpolate(["red", "yellow", "green"], clamp((x + 14) / 28, 0.0, 1.0))
      &"<span style=\"display:inline-block;width:3.5em;padding:2px 4px;border-radius:4px;" &
        &"background:{fill};color:{idealTextColor(fill)};font-weight:bold\">{formatNumber(x, 1)}</span>"

    proc theme538(t: sink Tabella): Tabella =
      ## FiveThirtyEight's look, as `gt_theme_538` gives it, with the reader's fonts for Cairo
      ## and Chivo.
      tabella(t):
        optTableFont "Cairo, " & systemFonts("system-ui")
        tabStyle style.text(weight = "bold"), loc.title()
        tabStyle style.text(transform = "uppercase", size = "14px") & style.css("vertical-align: bottom"),
          loc.columnLabels(), loc.stubhead()
        tabOptions(columnLabelsBackgroundColor = "white", dataRowPadding = "3px",
                   headingBorderBottomStyle = "none", tableBorderTopStyle = "none",
                   tableBorderBottomStyle = "none", columnLabelsFontWeight = "normal",
                   columnLabelsBorderTopStyle = "none", columnLabelsBorderBottomWidth = "2px",
                   columnLabelsBorderBottomColor = "black", rowGroupBorderTopStyle = "none",
                   rowGroupBorderBottomWidth = "1px", rowGroupBorderBottomColor = "black",
                   stubBorderColor = "white", stubBorderWidth = "0px",
                   sourceNotesFontSize = "12px", tableFontSize = "16px", headingAlign = "left")

    proc makeTable(df: DataFrame): Tabella =
      tabella(df, rownameCol = "Team", groupnameCol = "team_division"):
        tabHeader "2011 NFL Season at a Glance",
          "Super Bowl XLVI: New York Giants def. New England Patriots"
        tabSourceNote md"Source: [Lee Sharpe, nflverse](https://github.com/nflverse/nfldata)"
        tabStubhead "Team"
        tabSpanner "Scoring", ["Avg PF", "Point Diff"]
        tabSpanner "Season Trends", ["Games", "Streak"]
        fmtImage "team_logo_espn", height = "25px", alt = "logo"
        colsHide ["Wins", "team_conf", "team_name", "Avg PA"]
        colsAlign alCenter, ["Avg PF", "Games"]
        colsMoveToStart "team_logo_espn"
        colsLabel:
          team_logo_espn: ""
          "Avg PF": "Points For vs Points Against"
        fmt "Games", proc (v: Value, ctx: RenderContext): string = winloss($v)
        fmt "Streak", proc (v: Value, ctx: RenderContext): string = rankChange(v)
        fmt "Avg PF", proc (v: Value, ctx: RenderContext): string = dumbbell($v)
        fmt "Point Diff", proc (v: Value, ctx: RenderContext): string = colorBox(v)
        tabStyle style.fill("lightgray"), loc.stub()
        tabStyle style.fill("rgb(255 215 0 / 0.3)"), loc.body(rows = where(it["Team"] == "NYG"))
        tabStyle style.fill("rgb(192 192 192 / 0.3)"), loc.body(rows = where(it["Team"] == "NE"))
        tabStyle style.borders({sRight}, color = "darkblue", weight = "3px"),
          loc.body(cols = "Point Diff"), loc.columnLabels(cols = "Point Diff")
        theme538()

    nbTable makeTable(nflDf.head(16))
    nbTable makeTable(nflDf.slice(16, 16))

tabelline """
tabelline has none of gt-extras' functions, so the Nim tab draws them with what it has: each
plot is a small proc that writes SVG (the strip of results, the dumbbell) or HTML (the box), and
`fmt` puts it in the cells (a proc that takes the `RenderContext` too gives HTML, which
tabelline does not escape); the streak's arrows are Font Awesome's, from `iconSvg`; the
highlights are fills and the divider a border, and the FiveThirtyEight look is a proc of
`tabOptions` and styles, as `gt_theme_538` is in Python. The two tables come one after the
other, as they would on a phone. The logos are ESPN's, linked as in the original, not copied.

The table says 2011, the season of Super Bowl XLVI; the notebook takes the games of 2016 (the
Patriots' 14 and 2), so the numbers are those of the 2016 season.
"""

bookSave()
