import polars as pl
from great_tables import GT, loc, md, style
import gt_extras as gte

nfl_df = pl.read_json("nfl_2011_stats.json")

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
