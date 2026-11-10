## The home page, docs/index.html: what tabelline is, the simplest table that shows it, and the
## pages of the site in three groups, by the question a reader brings: learn tabelline, where it is
## going, how it is made. Dated posts are not listed here: they are in the devlog.
## When a release adds features, the table may grow a little, but it stays simple.
import std/os
import nimib
import tabelline, tabelline/[datasets, nimib]
import blocchi, stories/storie

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
    tabSourceNote "NASA Planetary Fact Sheet"
    optCssTheme()  # the page's colours
nbParti t
nbText: """
The six parts of every gt table are explained in the [Guide](explainer/#the-parts-of-a-table).
The last line, `optCssTheme()`, is tabelline's own: the table takes its colours and font from the
page, so it changes with the look you pick at the top ([how it works](explainer/#tables-that-follow-the-page)).
"""

nbText: """
## Stories

Real subjects told in tables made with tabelline, one for every release. [All the stories](stories/).
"""
nbStorie "stories/"

# The pages of the site, in three groups by the question a reader brings, each in reading order.
# They are kept up to date as tabelline changes; dated posts are in the devlog.
type
  Page = tuple[href, title, what: string]
  Group = tuple[heading, lede: string, pages: seq[Page]]
let groups: seq[Group] = @[
  ("Learn tabelline", "Start here.", @[
    ("explainer/", "Guide", "gt and Great Tables from zero: what they are, how they work inside, who uses them; then tabelline, step by step."),
    ("book/", "Book", "The gt and Great Tables guides, redone in Nim page by page, with the original next to every example."),
    ("zen/", "The Zen of tabelline", "import tabelline/this: nineteen aphorisms about tables, after Francesco Bruzzesi's Zen of Great Tables."),
  ]),
  ("Where it's going", "What tabelline has today and what comes next.", @[
    ("roadmap/", "Roadmap", "What each release from 0.1 to 0.5 adds, and the real tables it is tried on."),
    ("coverage/", "Feature map", "Every feature of gt and Great Tables, and whether tabelline has it yet."),
  ]),
  ("How it's made", "For anyone who wants to look inside or help.", @[
    ("devlog/", "Devlog", "Dated posts on how tabelline is made, newest first. The other pages are kept up to date; posts stay as they were written."),
    ("specs/", "Specs", "How tabelline behaves, requirement by requirement, written with OpenSpec for agents and people: each with an example that ran when the page was built."),
    ("design/", "Design guide", "How these pages look and why: the two looks, the shapes, the palette, the type and every component."),
    ("agents/", "For coding agents", "Setup, commands, where things are and the working rules, for a coding agent or a person new to the code."),
  ]),
]

for g in groups:
  nbText "## " & g.heading & "\n\n" & g.lede
  nbCards g.heading:
    for d in g.pages:
      nbCard(d.title, d.href, ""):
        nbText d.what
nbSave
