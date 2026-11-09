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
    entry("Styling the Table Body", "basic_styling")
    entry("Styling the whole table", "targeted_styles")
    entry("Colorizing with Data", "colorizing_with_data")
    entry("Table Theme Options", "table_theme_options")
    entry("Premade Themes", "table_theme_premade")
    entry("Column Selection", "column_selection")
    entry("Row Selection", "row_selection")
    entry("Location selection", "loc_selection")
  entry("What the book will port", "next", numbered = false)
  section("The Table Contest", "contest.nim"):
    entry("Guide to table making, with table.glue", "contest/table_glue")
  entry("Find an example by feature", "features", numbered = false)
  entry("What the port found", "gaps.md", numbered = false)
  entry("Sources and licences", "licences.md", numbered = false)

nimibookCli(book)
