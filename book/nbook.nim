## The table of contents of the tabelline book. `nim r book/bookbuild.nim` builds it (see
## book/README.md).
import nimibook

var book = initBookWithToc:
  entry("Introduction", "index", numbered = false)
  section("Great Tables: Get Started", "get-started/index.md"):
    entry("Intro", "intro")
    entry("Overview", "overview")
    entry("Header and Footer", "basic_header")
    entry("Stub (Row Labels)", "basic_stub")
    entry("Column Labels", "basic_column_labels")
    entry("Formatting Values", "basic_formatting")
    entry("Nanoplots", "nanoplots")
    entry("Styling the Table Body", "basic_styling")
    entry("Styling the whole table", "targeted_styles")
    entry("Colorizing with Data", "colorizing_with_data")
    entry("Table Theme Options", "table_theme_options")
    entry("Premade Themes", "table_theme_premade")
    entry("Column Selection", "column_selection")
    entry("Row Selection", "row_selection")
    entry("Location selection", "loc_selection")
  section("Great Tables: the blog", "blog/index.md"):
    entry("Introducing Great Tables", "introducing")
    entry("v0.2.0: Easy Data Coloring", "v0_2")
    entry("Using Polars to Win at Super Bowl Squares", "superbowl")
    entry("v0.3.0: So Many Style Options!", "v0_3")
    entry("v0.4.0: Nanoplots and More", "v0_4")
    entry("The Design Philosophy of Great Tables", "design")
    entry("Great Tables for Scientific Publishing", "scientific")
    entry("v0.12.0: Google Fonts and zebra stripes", "v0_12")
    entry("v0.13.0: Applying styles to all table locations", "v0_13")
    entry("v0.15.0: Flags, Icons, and Other Formatting Goodies", "v0_15")
    entry("v0.18.0: Easy Column Spanners and More!", "v0_18")
    entry("Recreating Septa Transit Timetables in Python", "septa")
  section("gt: articles", "vignettes/index.md"):
    entry("Creating Summary Lines", "summary_lines")
    entry("Case Study: gtcars", "case_study_gtcars")
    entry("Case Study: Clinical Tables", "case_study_clinical")
  entry("What the book will port", "next", numbered = false)
  section("The Table Contest", "contest.nim"):
    entry("Guide to table making, with table.glue", "contest/table_glue")
  entry("Find an example by feature", "features", numbered = false)
  entry("What the port found", "gaps.md", numbered = false)
  entry("Sources and licences", "licences.md", numbered = false)

nimibookCli(book)
