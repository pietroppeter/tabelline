## The home page, docs/index.html: what tabelline is, one table, and the way to the living
## documents and the devlog.
import std/os
import nimib except md
import tabelline, tabelline/[datasets, nimib]
import quaderno

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "great tables for Nim", classe = "1ª · since November 2026",
               title = "tabelline: great tables for Nim",
               description = "tabelline: display tables for Nim, after R's gt and Python's Great Tables.")

nbText: """
<p class="lede"><strong>tabelline</strong> makes display tables in Nim: a header, a stub, groups,
spanners, formatted numbers, colours and notes, rendered to HTML, text and Markdown. It follows
R's <a href="https://gt.rstudio.com">gt</a> and Python's
<a href="https://posit-dev.github.io/great-tables/">Great Tables</a>, in plain Nim, and fits in
<a href="https://github.com/pietroppeter/nimib">nimib</a> notebooks.</p>
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
    fmtBar "moons", color = "#A0C4FF", width = "4em"
    tabSourceNote "NASA Planetary Fact Sheet"
    optQuaderno()
nbTable t

nbText: """
<div class="cards">
<div class="nota"><span class="titolo"><a href="explainer/">Explainer</a></span>gt and Great Tables: what they are, how they work inside, who uses them; and tabelline, step by step.</div>
<div class="nota azzurra"><span class="titolo"><a href="specs/">Specs</a></span>How tabelline behaves today, with examples that ran when the page was built.</div>
<div class="nota verde"><span class="titolo"><a href="devlog/">Devlog</a></span>Living documents first, then dated posts on how tabelline is made.</div>
</div>

Status: a first version, a proof of concept. The API will change.
"""
nbSave
