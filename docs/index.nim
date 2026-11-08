## The home page, docs/index.html: what tabelline is, the simplest table that shows it, and the
## living documents, in reading order. Dated posts are not listed here: they are in the devlog.
## When a release adds features, the table may grow a little, but it stays simple.
import std/[os, strformat]
import nimib except md
import tabelline, tabelline/[datasets, nimib]
import quaderno, parti

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
nbRawHtml: partsCss & """<button type="button" class="mostra-parti" aria-pressed="false">Show the parts</button><div class="vista-dati">"""
nbTable t
nbRawHtml: """</div><div class="vista-parti" hidden>"""
nbTable showParts(t)
nbRawHtml: partsLegend() & """<p>The six parts of every gt table, explained in <a href="explainer/#the-parts-of-a-table">The Great Explainer</a>.</p></div>
<script>
(function () {
  var b = document.querySelector('.mostra-parti'), d = document.querySelector('.vista-dati'), p = document.querySelector('.vista-parti');
  b.addEventListener('click', function () {
    var on = b.getAttribute('aria-pressed') !== 'true';
    b.setAttribute('aria-pressed', on ? 'true' : 'false');
    b.textContent = on ? 'Show the data' : 'Show the parts';
    d.hidden = on; p.hidden = !on;
  });
})();
</script>"""

# The living documents, in the order to read them; each is kept up to date. Posts are in the devlog.
# The book appears once its sources (book/) are in the repository.
type Living = tuple[href, title, what: string]
var living: seq[Living] = @[
  ("explainer/", "The Great Explainer", "gt and Great Tables from zero: what they are, how they work inside, who uses them; and tabelline, step by step."),
  ("devlog/", "Devlog", "How tabelline is made: the roadmap and the coverage map, then every post, newest first. Bigger changes are tracked and explained here."),
  ("book/", "Book", "The Great Tables and gt guides ported to tabelline, page by page, with the original next to it."),
  ("design/", "Design Ref", "The two looks, the shapes, the palette, the type and every component, with when to use each: the reference for writing a page."),
  ("agents/", "Agents", "For coding agents: setup, commands, the working rules and where things are."),
  ("specs/", "Specs", "How tabelline behaves today: requirements with examples that ran when the page was built."),
]
if not dirExists(docs.parentDir / "book"):
  living.delete(2)
var cards = ""
for i, d in living:
  cards.add &"""<div class="nota azzurra"><small>{i + 1}</small><span class="titolo"><a href="{d.href}">{d.title}</a></span>{d.what}</div>"""

nbRawHtml: &"""<h2 id="living-documents">Living documents</h2>
<p>Kept up to date as tabelline changes, in the order to read them.</p>
<div class="cards">{cards}</div>
<p>Status: a first version. The API will change.</p>"""
nbSave
