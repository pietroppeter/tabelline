## devlog: 07 Nov 2026 E | Three threads for every release | How tabelline will grow from 0.1 to 0.5: for every release one thread builds it, one uses it on real data, one ports reference code from gt and Great Tables. The way nanuq was made, with Nim, Python and R side by side.
## A dated post: it tells how the work was planned, and is not updated afterwards.
import std/[os, strutils, strformat]
import nimib except md
import tabelline, tabelline/nimib
import ../quaderno, ../piano

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "three-threads" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Devlog", classe = "post · 7 November 2026",
               title = "Three threads for every release", homeHref = "../")

nbText: """
<p class="kicker">Devlog · 7 November 2026</p>

# Three threads for every release

<p class="lede">How tabelline will grow from 0.1 to 0.5: for every release, one thread builds it,
one uses it on real data, and one ports reference code from gt and Great Tables, with Nim,
Python and R side by side.</p>

The [coverage map](../../coverage/) says what is missing; this post says how it gets done. The
plan is the one that made [nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim, from
0.3 to 0.6: every release is three pieces of work running at the same time, each in its own
thread, each with its own output.

## How it went in nanuq

Each nanuq release had an *API design* post (Designing Nanuq 0.x), an *explainer* that used the
release on a subject with real data, and ports of public Polars tutorials to the
[Nanuq Book](https://github.com/pietroppeter/nanuq-book). From 0.4 the explainer was written in
Python first, while the release was being built, and then in Nim; from 0.6 every step of it
showed both, in tabs, and the build checked that they gave the same output.
"""

block:
  type Nanuq = object
    release, design, explainer: string
  let rows = @[
    Nanuq(release: "0.3", design: "temporal types, the str and dt namespaces, Parquet, errors, categoricals; written before the code",
          explainer: "*Aged 19*: a young rider's 2026 season and cycling's records of age and speed"),
    Nanuq(release: "0.4", design: "math, rolling windows, pivot, time windows, Series, Arraymancer; and what the explainer and the book ports changed",
          explainer: "*Counting El Niños*: NOAA's index, rain in Peru, the temperature of the planet; written in Python first"),
    Nanuq(release: "0.5", design: "nested types, JSON, SQL, Nim callbacks; and the smaller functions the book asked for",
          explainer: "*Above 4000*: the Alpine four-thousanders, the hut-to-hut treks around them, the 8000-metre peaks"),
    Nanuq(release: "0.6", design: "streaming, serialization, Decimal, Arrow, Excel, SQLite; thirty functions from the coverage map",
          explainer: "*Move 37*: 98,000 professional go games and 2.8 million amateur ones, Nim and Python in tabs, checked equal"),
  ]
  let t = tabella(rows, rownameCol = "release"):
    tabHeader "nanuq, release by release", "the design post and the explainer of each"
    colsLabel {"design": "🔨 Designing Nanuq 0.x", "explainer": "🧭 the explainer"}
    fmtMarkdown "explainer"
    tabSourceNote md("Alongside, the 📚 Nanuq Book ported the Polars user guide, *Polars: The Definitive Guide*, *Modern Polars*, a Polars cookbook, Real Python tutorials and three benchmarks (1BRC, PDS-H, db-benchmark), each chapter with its source and licence.")
    optQuaderno()
  nbTable t

nbText: """
What made it work: the explainer and the book did not care how a function was built, only
whether it was there and read well. So they found what the coverage map could not: calls that
users write all the time and were missing, names that read badly, a bug in a corner. Each
Designing post ends with a section on what they changed.

## The three threads

For tabelline, every release starts three threads:
"""

block:
  type Kind = object
    thread, does: string
  var rows: seq[Kind]
  for (key, icon, name, does) in threadKinds:
    rows.add Kind(thread: icon & " " & name, does: does)
  let t = tabella(rows, rownameCol = "thread"):
    tabHeader "Three threads for every release"
    colsLabel {"does": ""}
    optQuaderno()
  nbTable t

nbText: """
The build thread owns the code; the other two own a document each, and send it what they
find (an OpenSpec change for the release, or a line in the backlog). A release ships when the
build thread is done and both documents build against it.

## Nim, Python and R, side by side

The use-it explainers and the book show every example three times, in tabs: 👑 Nim with
tabelline, 🐍 Python with Great Tables, 🏴‍☠️ R with gt. The choice holds for the whole page.
Here is the first one:
"""

nbTabs(python = """
import polars as pl
from great_tables import GT

rocky = pl.DataFrame({
    "planet": ["Mercury", "Venus", "Earth", "Mars"],
    "moons": [0, 0, 1, 2],
    "mass": [0.330, 4.87, 5.97, 0.642],
})
(GT(rocky, rowname_col="planet")
    .tab_header("Rocky planets", "mass in 10^24 kg")
    .fmt_number("mass", decimals=2))
""", r = """
library(gt)

rocky <- data.frame(
  planet = c("Mercury", "Venus", "Earth", "Mars"),
  moons = c(0, 0, 1, 2),
  mass = c(0.330, 4.87, 5.97, 0.642)
)
gt(rocky, rowname_col = "planet") |>
  tab_header("Rocky planets", "mass in 10^24 kg") |>
  fmt_number(mass, decimals = 2)
"""):
  nbCode:
    let rocky = tableData:
      planet: ["Mercury", "Venus", "Earth", "Mars"]
      moons: [0, 0, 1, 2]
      mass: [0.330, 4.87, 5.97, 0.642]
    let t = tabella(rocky, rownameCol = "planet"):
      tabHeader "Rocky planets", "mass in 10^24 kg"
      fmtNumber "mass", decimals = 2
  nbTable t

nbText: """
Today the Python and R tabs show the code only. In the explainers they will also show the
table each one makes, built from the same data, so the three can be compared by eye.

## The releases

Five releases, each with a theme from the coverage map, and fifteen threads:
"""

block:
  type Row = object
    release, build, use, port: string
  var rows: seq[Row]
  for r in releases:
    var row = Row(release: &"**{r.version}**<br>{r.theme}")
    for th in r.threads:
      case th.kind
      of "build": row.build = th.what
      of "use": row.use = th.title.replace("Use it: ", "")
      of "port": row.port = th.title.replace("Port ", "").capitalizeAscii
    rows.add row
  let t = tabella(rows, rownameCol = "release"):
    tabHeader "From 0.1 to 0.5", "what each thread of each release does"
    colsLabel {"build": "🔨 build", "use": "🧭 use it on", "port": "📚 port"}
    fmtMarkdown "release"
    colsWidth {"build": "40%"}
    optQuaderno()
  nbTable t

nbText: """
The subjects of the use-it threads are a first guess, each chosen for what its release adds:
flags and times for the basics, stages and totals for summary rows, units and months for
locales, pictures for images and nanoplots, and the clinical tables that gt was first loved
for. Each thread will check its data and its licence before it starts, and can change subject.

Left aside, for now: interactive tables (the parked [Tabellone](../tabellone/)), the machinery of
Shiny and R graphics, and fonts loaded from the web.

## Where it is kept

- The [roadmap](../../roadmap/), a living document, lists every thread with its status and the
  reference code each port will take, with its licence.
- The [coverage map](../../coverage/) says what each release adds, group by group, and is
  updated with the code.
- The ports go in a tabelline book, a new repository made like the Nanuq Book.
"""

nbSave
