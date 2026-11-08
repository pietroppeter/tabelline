## The home page, docs/index.html: what tabelline is, the simplest table that shows it, and the
## living documents, in reading order. Dated posts are not listed here: they are in the devlog.
## When a release adds features, the table may grow a little, but it stays simple.
import std/os
import nimib except md
import tabelline, tabelline/[datasets, nimib]
import blocchi

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "index.html"
nb.useTabelline(nome = "tabelline", materia = "great tables for Nim", classe = "1ª · since November 2026",
               title = "tabelline: great tables for Nim",
               description = "tabelline: display tables for Nim, after R's gt and Python's Great Tables.")

nbText: """
**tabelline** makes display tables in Nim: a header, a stub, groups, spanners, formatted numbers,
colours and notes, rendered to HTML, text and Markdown. It follows R's [gt](https://gt.rstudio.com)
and Python's [Great Tables](https://posit-dev.github.io/great-tables/), in plain Nim, and fits in
[nimib](https://github.com/pietroppeter/nimib) notebooks.
"""

nbCode:
  let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    tabHeader md("The **planets**"), "of the Solar System"
    colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "rings"]
    colsLabel {"mass": md("mass<br>10^24^ kg"), "diameter": md("diameter<br>km"),
               "mean_temp": md("mean<br>°C"), "moons": md("moons")}
    fmtNumber "mass", decimals = 3, dropTrailingZeros = true
    fmtInteger "diameter"
    dataColor "mean_temp", palette = palette("rdbu"), domain = (-200.0, 200.0)
    fmtBar "moons", color = "var(--secondary)", width = "4em"
    tabSourceNote "NASA Planetary Fact Sheet"
    optPageTheme()  # the page's colours
nbParti t
nbText: """
The six parts of every gt table are explained in [The Great Explainer](explainer/#the-parts-of-a-table).
The last line, `optPageTheme()`, is tabelline's own: the table takes its colours and font from the
page, so it changes with the look you pick at the top ([how it works](explainer/#tables-that-follow-the-page)).
"""

# The living documents, in the order to read them; each is kept up to date. Posts are in the devlog.
# Until the book's sources (book/) are in the repository, its card says it is coming, with no link.
type Living = tuple[href, title, what: string]
var living: seq[Living] = @[
  ("explainer/", "The Great Explainer", "gt and Great Tables from zero: what they are, how they work inside, who uses them; and tabelline, step by step."),
  ("devlog/", "Devlog", "How tabelline is made: every post, newest first. Bigger changes are tracked and explained here."),
  ("book/", "Book", "The Great Tables and gt guides ported to tabelline, page by page, with the original next to it."),
  ("roadmap/", "Roadmap", "The releases from 0.1 to 0.5, and the three threads that make each one: build it, use it, port the references."),
  ("coverage/", "Coverage map", "Every feature group of gt and Great Tables, what tabelline has, and the releases that plan the rest."),
  ("design/", "Design Ref", "The two looks, the shapes, the palette, the type and every component, with when to use each: the reference for writing a page."),
  ("agents/", "Agents", "For coding agents: setup, commands, the working rules and where things are."),
  ("specs/", "Specs", "How tabelline behaves today: requirements with examples that ran when the page was built."),
]
let bookReady = dirExists(docs.parentDir / "book")

nbText: """
## Living documents

Kept up to date as tabelline changes, in the order to read them.
"""
nbCards "the living documents":
  for i, d in living:
    let ready = d.href != "book/" or bookReady
    nbCard(d.title & (if ready: "" else: " (coming soon)"), (if ready: d.href else: ""), $(i + 1)):
      nbText d.what
nbNota "Status: a first version. The API will change.", nkWarning
nbSave
