## devlog: 08 Nov 2026 E | Rethinking tabelline's datasets | A table is for people, and people recognise the data before they read a number. Which datasets tabelline uses today and where they come from, which ones a reader of gt and Great Tables meets first, and a brainstorm of what tabelline could use instead: familiar from gt, with an Italian twist, in three domains and three sizes, with the islands of the Mediterranean as the first table. A first draft, to decide from.
## A dated post: the survey as it was on 8 November 2026, not updated afterwards. The counts of
## tabelline's own datasets are taken from the sources when the page is first built and kept in
## devlog/data/datasets/uses.csv; the data from outside was fetched by four Nim scripts there
## (survey, unesco, isole, citta), each with its Python twin, from public sources.
import std/[os, strutils, strformat, sequtils, algorithm, tables]
import nimib except md
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
let root = docs.parentDir
let data = docs / "devlog" / "data" / "datasets"
nbInit
nb.doc.filename = docs / "devlog" / "datasets" / "index.html"
nb.useTabelline(title = "Rethinking tabelline's datasets", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

proc readData(name: string): TableData =
  ## One of this post's CSV files: its `#` lines name the source.
  readCsv(data / name, comment = "#")

nbTitle "8 November 2026", "Rethinking tabelline's datasets", """
A table is for people, and people recognise the data before they read a number. What tabelline
uses today, what gt and Great Tables show first, and what tabelline could use instead.
"""

nbText: """
tabelline takes data that is already processed and makes a display table from it: a table crafted
for people to read. gt and Great Tables open their guides with the same distinction. They set
*display tables* apart from *data tables* (data frames): display tables are the ones
"you'd find in a web page, a journal article, or in a magazine", and they are "output only, where
we'd not want to use them as input ever again" ([Great Tables, Get
Started](https://posit-dev.github.io/great-tables/user-guide/introduction.html); gt's
[introduction](https://gt.rstudio.com/articles/gt.html) says the same).

If the table is for a reader, the data in it is half of what the reader gets. A reader who sees
Mercury, or Italy, or a carbonara, knows what the row is before reading its numbers, and can look
at what the table does with them. When the same few datasets come back from page to page, they
become landmarks: whoever has read gt's guide knows `islands` and `exibble` by sight. tabelline's
pages so far took whatever data was at hand. This post surveys it, in three parts:

1. **What we have**: how a dataset is made in tabelline, the three it ships, and the many small
   ones written inside the pages.
2. **What gt and Great Tables show first**: the datasets of their READMEs, of their first guide,
   and of their reference.
3. **What we could have**: three domains in three sizes, a tabelline twin for gt's best known
   datasets, and a first taste of three of them.

It ends with recommendations, the choices to make, and how this page is built.
"""

nbToc()

# ======================================================================================== Part 1
nbPart 1, "What we have", prPrimary

nbText: """
## Three ways to make a dataset

A dataset in tabelline is a `TableData`: named columns of values (numbers, text, true or false,
dates as text, missing). There are three ways to make one, from the simplest to write to the
most useful in a program. Here is the same small table, three Italian dishes, made the three ways.
"""

nbGallery "three ways to make the same table: swipe or scroll sideways":
  nbGalleryCard "Load it":
    block:
      nbText "From a file, with `readCsv` (or from a string, with `parseCsv`). Each value's type is guessed."
      nbCode:
        let ricette = readCsv(data / "ricette.csv")
      nbTable tabella(ricette, rownameCol = "dish").optCssTheme()
  nbGalleryCard "Write the columns":
    block:
      nbText "In the code, one line per column, with the `tableData:` macro."
      nbCode:
        let ricette = tableData:
          dish: ["Carbonara", "Pesto alla genovese", "Risotto alla milanese"]
          region: ["Lazio", "Liguria", "Lombardia"]
          vegetarian: [false, true, false]
      nbTable tabella(ricette, rownameCol = "dish").optCssTheme()
  nbGalleryCard "From objects":
    block:
      nbText "From Nim objects or named tuples, one field per column: `tabella` takes them as they are."
      nbCode:
        type Ricetta = object
          dish, region: string
          vegetarian: bool
        let ricette = @[
          Ricetta(dish: "Carbonara", region: "Lazio", vegetarian: false),
          Ricetta(dish: "Pesto alla genovese", region: "Liguria", vegetarian: true),
          Ricetta(dish: "Risotto alla milanese", region: "Lombardia", vegetarian: false)]
      nbTable tabella(ricette, rownameCol = "dish").optCssTheme()

nbNote """
**1 · Load it.** `readCsv(path)` reads a file; `parseCsv(text)` reads a string. Both take a
`sep` (`'\t'` for TSV) and a `comment` (`comment = "#"` skips the lines naming a source).
With `parseCsv` a page can read its file when it is compiled with `staticRead` and carry it inside (the book
does this for Great Tables' data). The built-in datasets are of this kind too: `planets()`
parses a CSV string kept in `tabelline/datasets`.

**2 · Write the columns.** `tableData:` is a macro: each line is `name: [values]`, a name may
have dots (`size.mass`, for spanners) or be quoted, and `nil` is a missing value. For columns
computed in a loop, the proc behind it takes pairs: `toTableData({"n": ns.toValues})`.

**3 · From objects.** `toTableData(rows)` reads the fields of each object with `fieldPairs`,
in their order; `tabella(rows)` calls it for you. This is the way for data that a program
already has: rows parsed from somewhere else, or built with types of its own.
""", nkCode, "Code"

nbNote """
**Missing.** There is no reader for JSON, and no verbs on the data
(filter, sort, head, join): the book writes its own `head`, `take` and `select`. Data frames
are planned for 0.3.
""", nkMissing

# -------------------------------------------------------------------------- counted uses
let snapshot = data / "uses.csv"
const builtins = ["planets()", "exibble()", "tavolaPitagorica(", "islands()", "airquality()", "sza()",
                  "tableData:", "readCsv(", "readTsv("]

proc area(rel: string): string =
  if rel.startsWith("book/"): "book"
  elif rel.startsWith("openspec/"): "specs"
  elif rel.startsWith("tests/"): "tests"
  elif rel.startsWith("docs/devlog/"): "posts"
  elif rel.startsWith("docs/"): "living documents"
  elif rel.startsWith("src/"): "library"
  else: "README"

# A dated snapshot: counted once, when the page was first built (8 November 2026), so the post
# keeps its numbers as pages change. Delete the file to count again.
if not fileExists(snapshot):
  var counts = initOrderedTable[(string, string), int]()
  for dir in ["docs", "book", "openspec/specs", "tests", "src"]:
    for path in walkDirRec(root / dir):
      if not (path.endsWith(".nim") or path.endsWith(".md")) or path.endsWith("datasets.nim") and "devlog" in path:
        continue
      let s = readFile(path)
      let rel = path.relativePath(root)
      for b in builtins:
        let n = s.count(b)
        if n > 0: counts.mgetOrPut((area(rel), b), 0) += n
  for b in builtins:
    let n = readFile(root / "README.md").count(b)
    if n > 0: counts.mgetOrPut(("README", b), 0) += n
  var lines = @["# Uses of each way to get a dataset, counted in tabelline's sources on 8 Nov 2026",
                "area,dataset,uses"]
  for k, v in counts: lines.add &"{k[0]},{k[1]},{v}"
  writeFile(snapshot, lines.join("\n") & "\n")

let uses = readData("uses.csv")
proc used(a, b: string): int =
  for i in 0 ..< uses.nrows:
    if $uses["area", i] == a and $uses["dataset", i] == b: return int(uses["uses", i].toFloat)

nbText: """
## The three it ships

`tabelline/datasets` has three datasets, built into the module so that no file has to be found
when a program runs. They are where every page and spec starts.
"""

nbShowCode:
  type Shipped = object
    dataset, what: string
    docs, book, checks: int
  proc row(name, call, what: string): Shipped =
    Shipped(dataset: name, what: what,
            docs: used("README", call) + used("living documents", call) + used("posts", call),
            book: used("book", call), checks: used("specs", call) + used("tests", call))
  let rows = @[
    row("`planets`", "planets()", "8 planets × 12 facts, from NASA (public domain)"),
    row("`tavolaPitagorica`", "tavolaPitagorica(", "the times table, made by the code"),
    row("`exibble`", "exibble()", "gt's toy table, a column per type (MIT)")]
  let t = tabella(rows, rownameCol = "dataset"):
    optCssTheme()
    tabHeader "The datasets tabelline ships", "and how many times the sources call them"
    tabSpanner "calls in", ["docs", "book", "checks"]
    colsLabel {"checks": "specs, tests"}
    fmtMarkdown "dataset"
    subZero zeroText = "·"
    tabSourceNote md("Counted in the sources on 8 November 2026 (`devlog/data/datasets/uses.csv`); *docs* are the README, the pages and the posts.")
  nbTable t

nbText: &"""
The planets are the landmark today: the README and the home page start from them, and the Solar
System is also where most small examples come from (below). In the specs and the tests the tavola
pitagorica is called as often, as the simplest grid of numbers there is. `exibble` is there for the book, whose ported
chapters must keep gt's data, and for the parts of the docs that compare with gt.

## The ones written in the pages

Most tables in the pages are not made from the datasets above: the sources write
**{used("posts", "tableData:") + used("living documents", "tableData:")}** `tableData:` blocks in
the docs and posts, **{used("book", "tableData:")}** in the book, **{used("specs", "tableData:")}**
in the specs and **{used("tests", "tableData:")}** in the tests, and a few more tables come from
objects. Grouped by what they are about, they fall in three families:
"""

nbShowCode:
  type Small = object
    family, theme, examples, where: string
  let rows = @[
    Small(family: "Made up for an example", theme: "🪐 the Solar System",
          examples: "planets and moons, rocky and giant, mass and radius, distance and water",
          where: "Designing 0.1 (ten), Three threads, explainer, specs"),
    Small(family: "Made up for an example", theme: "🧮 school",
          examples: "tabelline 2 × 3, 4 × 5, 6 × 7; a pagella with *materia* and *voto*",
          where: "Design Ref, Blocks review, explainer"),
    Small(family: "Made up for an example", theme: "🔧 one of each unit",
          examples: "telescopes sold, file sizes, a kettle and a wind turbine, race times, Apollo 11, CO₂ in 1850 and 2025, three cities and their flags",
          where: "Designing 0.1, specs"),
    Small(family: "Taken from gt", theme: "🧪 gt's own",
          examples: "`exibble`, the colorizing guide's small frame, four cars from `gtcars`, a palette frame",
          where: "book, Designing 0.1, Book found"),
    Small(family: "Taken from gt", theme: "🏝️ R's classics",
          examples: "`islands`, `airquality`, `sza` (CSV files copied from Great Tables)",
          where: "book"),
    Small(family: "Read from real data", theme: "⛷️ a story",
          examples: "Milano Cortina 2026: medals, venues, sports, athletes, history (Wikipedia), CO₂ (NOAA)",
          where: "Milano Cortina post"),
    Small(family: "Read from real data", theme: "📏 the docs themselves",
          examples: "the commands of the repo, the choices of day one, the colours of the design, the audit of the pages, the Table Contest's winners",
          where: "Agents, Day one, Design review, Blocks review, explainer")]
  let t = tabella(rows, rownameCol = "theme", groupnameCol = "family"):
    optCssTheme()
    tabHeader "The small datasets, by what they are about", "written in the pages, 8 November 2026"
    colsLabel {"examples": "for example", "where": "in"}
    fmtMarkdown "examples"
  nbTable t

nbText: """
Three things stand out. **The Solar System is already a theme**, the only one: it began with
`planets()` and the small examples followed it. **The rest is ad hoc**: telescopes, kettles and a
Ford GT were the first thing that fit the format to show, and none of them comes back. **Real data
lives only in stories** (Milano Cortina) and in the book's copies of gt's data, in files next to
the page that reads them.
"""

# ======================================================================================== Part 2
nbPart 2, "What gt and Great Tables show first", prSecondary

let survey = readData("survey.csv")

nbText: """
## The first table

A reader meets gt or Great Tables in one of two places, and each shows a different first table.
The **README** of both makes one table from **`sp500`**, a week of the S&P 500 index in June 2010,
with a title, dates and currency: it shows off formats. The **first guide** (gt's introduction,
Great Tables' *Get Started*) starts from **`islands`**, the ten largest landmasses of the world,
two columns: it shows the parts of a table, one at a time, and moves on to **`airquality`**
(New York, 1973) for column labels.
"""

nbShowCode:
  type First = object
    library, page, datasets: string
  var rows: seq[First]
  for i in 0 ..< survey.nrows:
    let page = $survey["page", i]
    if page == "reference examples" or page.startsWith("Get Started: ") and page != "Get Started: index": continue
    rows.add First(library: $survey["library", i], page: page.replace("Get Started: index", "Get Started"),
                   datasets: ($survey["datasets", i]).split(' ').mapIt("`" & it & "`").join(", "))
  let t = tabella(rows, groupnameCol = "library"):
    optCssTheme()
    tabHeader "The first pages", "and the datasets their code uses, in order of appearance in the list of datasets"
    fmtMarkdown "datasets"
    colsLabel {"page": "page", "datasets": "datasets"}
    tabSourceNote md("Counted in the sources on raw.githubusercontent.com on 8 November 2026 by `survey.nim`.")
  nbTable t

nbText: """
## The guide and the reference

After the first page, Great Tables' guide settles on **`exibble`**: eight rows of one column per
type, made to show what each format and selector does. It is the guide's dataset for formats,
styles, themes and selections; `islands`, `airquality` and `sza` come back once or twice, and three
pages build a small frame of their own. The reference is different: each function's examples pick
a real dataset that fits, and a few come back again and again.
"""

nbShowCode:
  type Page = object
    page, datasets: string
    frames: int
  var guide: seq[Page]
  var reference: seq[(string, int)]
  for i in 0 ..< survey.nrows:
    let page = $survey["page", i]
    if page.startsWith("Get Started: ") and page != "Get Started: index":
      guide.add Page(page: page["Get Started: ".len .. ^1],
                     datasets: ($survey["datasets", i]).split(' ').filterIt(it.len > 0).mapIt("`" & it & "`").join(", "),
                     frames: int(survey["inline", i].toFloat))
    elif page == "reference examples":
      reference.add ($survey["datasets", i], int(survey["inline", i].toFloat))
  let g = tabella(guide, rownameCol = "page"):
    optCssTheme()
    tabHeader "Great Tables, Get Started", "after the first page"
    colsLabel {"frames": "own frames"}
    fmtMarkdown "datasets"
    subZero zeroText = ""
  let refData = tableData:
    dataset: reference.mapIt("`" & it[0] & "`")
    examples: reference.mapIt(it[1])
  let r = tabella(refData, rownameCol = "dataset"):
    optCssTheme()
    tabHeader "gt's reference", "examples that start from each dataset"
    fmtMarkdown "dataset"
    tabSourceNote md("In four of gt's R files: `format_data`, `tab_create_modify`, `data_color`, `utils_render_html`.")
  nbBeside:
    nbTable g
    nbTable r

nbText: """
## Sixteen datasets, eighteen in R

Both READMEs end with the datasets the package ships, as a row of badges: sixteen in Great
Tables, eighteen in gt (two of them clinical, for pharma tables). `islands` and `airquality` are
not among them: they are R's own datasets, from the 1970s, which Great Tables copies for its guide.
"""

nbShowCode:
  type Ds = object
    dataset, what: string
    rows: int
  let rows = @[
    Ds(dataset: "countrypops", what: "yearly populations of countries, 1960 to 2024 (World Bank)", rows: 13975),
    Ds(dataset: "sza", what: "solar zenith angles by month and latitude, twice an hour", rows: 816),
    Ds(dataset: "gtcars", what: "deluxe cars of 2014 to 2017 (with Ferrari, Lamborghini, Maserati)", rows: 47),
    Ds(dataset: "sp500", what: "the S&P 500 index, daily, 1950 to 2015", rows: 16607),
    Ds(dataset: "pizzaplace", what: "a year of sales of a pizza place", rows: 49574),
    Ds(dataset: "exibble", what: "a toy table, one column of each type", rows: 8),
    Ds(dataset: "towny", what: "the municipalities of Ontario, 1996 to 2021", rows: 414),
    Ds(dataset: "peeps", what: "people from all over the world, with addresses", rows: 100),
    Ds(dataset: "films", what: "the films in competition at Cannes", rows: 1873),
    Ds(dataset: "metro", what: "the stations of the Paris Métro", rows: 321),
    Ds(dataset: "gibraltar", what: "the weather in Gibraltar, May 2023", rows: 1431),
    Ds(dataset: "constants", what: "the fundamental physical constants", rows: 354),
    Ds(dataset: "illness", what: "lab tests of one patient", rows: 39),
    Ds(dataset: "reactions", what: "rates of gas-phase reactions of organic compounds", rows: 1683),
    Ds(dataset: "photolysis", what: "photolysis rates of organic compounds", rows: 34),
    Ds(dataset: "nuclides", what: "the nuclides", rows: 3383),
    Ds(dataset: "rx_adsl", what: "a clinical trial's subjects (gt only)", rows: 182),
    Ds(dataset: "rx_addv", what: "a clinical trial's protocol deviations (gt only)", rows: 291)]
  let t = tabella(rows, rownameCol = "dataset"):
    optCssTheme()
    tabHeader "The datasets of gt and Great Tables", "in the order of their READMEs"
    fmtInteger "rows"
    tabSourceNote md("From gt's `R/datasets.R` and the READMEs, 8 November 2026.")
  nbTable t

nbNote """
**Do gt and Great Tables start from the population of countries?** Not quite, but it is the
dataset they put first. `countrypops` opens the list of datasets in both READMEs, its badge comes
first, and it ties with `gtcars` as the dataset gt's reference uses most (14 examples each, in the
four files counted). But the first table a reader sees is `sp500` in the README and `islands` in
the guide, and Great Tables' guide uses `countrypops` only in its Examples page (the populations of
Oceania).
""", nkInfo

nbText: """
What gt does, in three: **familiar data with history** (R's own `islands` and `airquality`, the
S&P 500, Cannes, the Paris Métro), **one toy table for every type** (`exibble`), and **a few rich
datasets reused everywhere** (`countrypops`, `gtcars`, `towny`), so that the reader of the
reference has seen the data before.
"""

# ======================================================================================== Part 3
nbPart 3, "What we could have", prSuccess

nbText: """
## Three domains, three sizes

The idea: take what is familiar from gt and Great Tables, and give it a twist that is tabelline's
own: Italian, recognisable to anyone, and about things that are made to be looked at. The datasets
fall in three domains, each in three sizes:

- **tiny**: three to six rows, written in the example with `tableData:`, so the reader sees all of it;
- **built in**: tens of rows, in `tabelline/datasets`, a landmark that comes back in every page;
- **big**: hundreds of rows or more, read from files, for stories and the book.

Three by three is a tavola pitagorica, so here it is as one.
"""

nbShowCode:
  let grid = tableData:
    domain: ["🍝 Casa: the kitchen and the school", "📐 Bottega: design", "🏔️ Mondo: geography and the sky"]
    tiny: ["three dishes and their region; *tabelline* 2 × 3; a *pagella*",
           "the steps of Munari's method, for a *risotto verde*",
           "four planets and their moons"]
    builtIn: ["`tavolaPitagorica`, the times tables",
              "`compasso`: the Compasso d'Oro of 1954, its designers, objects and makers",
              "`planets`; `isole`: the islands of the Mediterranean; `alpi`: the highest peaks of the Alps"]
    big: ["`pizza`: the price of a margherita, by city and year (inflation and regional differences)",
          "every Compasso d'Oro, 1954 to 2024",
          "`paesi`: countries, their population and their World Heritage Sites; `citta`: the cities of the EU"]
  let t = tabella(grid, rownameCol = "domain"):
    optCssTheme()
    tabHeader "Nine datasets", "three domains × three sizes"
    colsLabel {"builtIn": "built in"}
    fmtMarkdown ["tiny", "builtIn", "big"]
  nbTable t

nbText: """
**Casa** is what everyone knows: Italian food for the small examples, which need no explaining
(everyone knows a carbonara, and has an opinion on it), and school, where *tabelline* come from:
the tavola pitagorica, a timetable, a report card. **Bottega** is design, where tabelline's looks
come from: Bruno Munari, and the Compasso d'Oro, Italy's design award since 1954 (Munari won it
that first year, with the toy monkey Zizì). It also bridges back to the kitchen: Munari explains
his design method, in *Da cosa nasce cosa*, by designing a *risotto verde*. **Mondo** is the world
seen from Italy: the planets stay, the islands of the Mediterranean (the sea Italy sits in), the
Alps, which cross eight countries (their highest peaks stand between Italy, France and
Switzerland), and the countries of the world, with a twist.

The big Casa dataset is a real one: **the price of a pizza margherita in Italy**, by city and by
year, so that one table shows both inflation (the same city, year after year) and the differences
between regions (the same year, north to south). It is also the dataset that is hardest to get:
Il Post [wrote in 2023](https://www.ilpost.it/2023/02/24/pizza-prezzo-aumento/) that there is little
data on what pizzerias charge, beyond the restaurant federation's estimates (+7.7% in a year, in
January 2023) and ISTAT's indices for the ingredients and for ready-made pizza.

A first piece arrived in January 2026: an observatory of Neapolitan pizza (the University of Naples
Parthenope, the CNR, the Verace Pizza Napoletana association and FIPE Campania) surveyed 101
pizzerias that follow the same rules, so the same pizza, and published the price of a margherita
by area, with an index that sets Naples at 100.
"""

nbShowCode:
  let pizza = readData("pizza.csv")
  let t = tabella(pizza, rownameCol = "area"):
    optCssTheme()
    tabHeader "What a margherita costs", "a Neapolitan margherita in 101 pizzerias, presented in January 2026"
    fmtCurrency "price", currency = "EUR", decimals = 2
    fmtNumber "index", decimals = 1
    subMissing missingText = ""
    colsLabel {"price": "price", "index": "Naples = 100"}
    tabStyle style.text(weight = "bold"), loc.body(rows = where(it["area"] == "Italia"))
    tabSourceNote md("Osservatorio Socio-Economico della Pizza Napoletana, *Indice Pizza Napoletana Margherita*, as reported by [FIPE](https://www.fipe.it/2026/01/16/comunicazione/notizie-dal-mondo-fipe/losservatorio-socio-economico-della-pizza-napoletana-presenta-lindice-pizza-napoletana-margherita-e-offre-un-quadro-del-comparto/), 16 January 2026.")
  nbTable t

nbText: """
Fourteen percent more in the North than in Naples, and the South slightly cheaper than Naples.
It is one year and four areas: the regional half of the dataset, not yet the inflation half. For
that, ISTAT's consumer price indices have restaurants and pizzerias by city (indices, not euros;
its data service was too slow to answer today), and FIPE's monthly notes on prices give the yearly
change; the ministry's price observatory, with average prices by provincial capital, did not answer
either. The observatory's index will come back every year, which is what a `pizza` dataset needs.

## A twin for gt's best known datasets

A reader who comes from gt should find a dataset that plays the same part, in the same place.
"""

nbShowCode:
  type Twin = object
    gt, twin, source: string
  let rows = @[
    Twin(gt: "`islands`", twin: "`isole`: the islands of the Mediterranean, their area, people and main town",
         source: "✅ Wikipedia, 194 islands"),
    Twin(gt: "`sp500`", twin: "`paesi`: World Heritage Sites and population, flags, ratios",
         source: "✅ Wikipedia and `countrypops`"),
    Twin(gt: "`exibble`", twin: "none for now: `exibble` stays as it is",
         source: "—"),
    Twin(gt: "`countrypops`", twin: "`paesi` in full: every country, every year, with CO₂ and GDP", source: "✅ Our World in Data, on GitHub"),
    Twin(gt: "`sza`", twin: "`tavolaPitagorica`, coloured by value", source: "✅ the code"),
    Twin(gt: "`airquality`", twin: "the air or the weather of an Italian city", source: "🟡 ARPA Lombardia"),
    Twin(gt: "`gtcars`", twin: "the Compasso d'Oro: designer, object, maker, year", source: "✅ Italian Wikipedia"),
    Twin(gt: "`pizzaplace`", twin: "`pizza`: what a margherita costs, by city and year", source: "🟡 ISTAT, the ministry's price observatory"),
    Twin(gt: "`towny`", twin: "`citta`: the largest cities of the EU, and the day each was counted", source: "✅ Wikipedia, 95 cities"),
    Twin(gt: "`films`, `metro`", twin: "Venice's Golden Lions, Milan's metro", source: "🟡 Wikipedia, Comune di Milano")]
  let t = tabella(rows, rownameCol = "gt"):
    optCssTheme()
    tabHeader "Twins", "a tabelline dataset for the part each gt dataset plays"
    colsLabel {"twin": "tabelline's twin", "source": "from"}
    fmtMarkdown ["gt", "twin", "source"]
    tabSourceNote md("✅ read from this sandbox on 8 November 2026, or nothing to download; 🟡 a source exists, blocked here or not tried yet.")
  nbTable t

nbText: """
The parts: `islands` is the guide's first table, a short list; `sp500` the README's showcase,
with dates and formats; `exibble` the toy with one column of each type; `countrypops`, `gtcars`
and `towny` the rich datasets of the reference; `sza` a grid to colour; `airquality` daily
measures with gaps; `pizzaplace` a big table of sales.
"""

nbText: """
## Three first tastes

### The islands of the Mediterranean

gt's guide opens with the largest landmasses of the world. tabelline can open with the islands
of the sea it sits in: Wikipedia lists 194 of them by area, with their country, people and main
town. The two largest are Italian, and the first ten are shared by five countries.
"""

nbShowCode:
  let raw = readData("isole.csv")
  const iso = {"Italy": "IT", "Cyprus": "CY", "France": "FR", "Greece": "GR", "Spain": "ES", "Croatia": "HR",
               "Turkey": "TR", "Tunisia": "TN", "Malta": "MT", "Albania": "AL"}.toTable
  type Isola = object
    island, flag: string
    area: float
    population: Value
    city: string
  var rows: seq[Isola]
  for i in 0 ..< 10:
    rows.add Isola(island: $raw["island", i], flag: iso.getOrDefault($raw["country", i]),
                   area: raw["area", i].toFloat, population: raw["population", i], city: $raw["city", i])
  let t = tabella(rows, rownameCol = "island"):
    optCssTheme()
    tabHeader "Islands of the Mediterranean", "the ten largest"
    fmtFlag "flag"
    fmtInteger ["area", "population"]
    subMissing missingText = "–"
    colsLabel {"flag": toText(""), "area": md("km^2^"), "city": toText("main town")}
    tabSourceNote md("Wikipedia, *List of islands in the Mediterranean*, 8 November 2026, by `isole.nim`. Cyprus's population is a template there, not a number.")
  nbTable t

nbText: """
Like `islands`, it is a list anyone can read, and it grows: area and people give a density, the
countries give row groups (Greece has 101 of the 194, Croatia 41, Italy 27), and the flags come
for free with `fmtFlag`.

### The cities of the European Union

gt's `towny` lists places and how many people live there. Wikipedia lists the 95 cities of the
European Union with more than about 300,000 people inside their city limits, each with the day
its country counted them: Rome is third, after Berlin and Madrid, and the dates show that every
country counts on a day of its own.
"""

nbShowCode:
  let raw = readData("citta.csv")
  const iso = {"GER": "DE", "ESP": "ES", "ITA": "IT", "FRA": "FR", "AUT": "AT", "POL": "PL", "ROU": "RO",
               "HUN": "HU", "CZE": "CZ", "BUL": "BG", "NLD": "NL", "SWE": "SE", "POR": "PT", "GRC": "GR",
               "DEN": "DK", "FIN": "FI", "LTU": "LT", "IRL": "IE", "BEL": "BE", "CRO": "HR", "LVA": "LV",
               "EST": "EE", "SVN": "SI", "SVK": "SK"}.toTable
  type Citta = object
    city, flag: string
    population: int
    counted: string
  var rows: seq[Citta]
  for i in 0 ..< 10:
    rows.add Citta(city: $raw["city", i], flag: iso.getOrDefault($raw["state", i]),
                   population: int(raw["population", i].toFloat), counted: $raw["counted", i])
  let t = tabella(rows, rownameCol = "city"):
    optCssTheme()
    tabHeader "Cities of the European Union", "the ten largest, within their city limits"
    fmtFlag "flag"
    fmtInteger "population"
    fmtDate "counted", dateStyle = "d MMM yyyy"
    colsLabel {"flag": "", "counted": "counted on"}
    tabStyle style.text(weight = "bold"), loc.body(rows = where(it["city"] == "Rome"))
    tabSourceNote md("Wikipedia, *List of cities in the European Union by population within city limits*, 8 November 2026, by `citta.nim`.")
  nbTable t

nbText: """
Milan is 13th (1.36 million), Naples 18th and Turin 20th; of the 95 cities, 23 are German, 13
Spanish, 9 Polish and 9 Italian. Dates like these are what `fmtDate` is for, and the country codes
give flags again.

### The countries of the World Heritage

The idea that started this post: gt starts from the population of countries; tabelline can too,
and add the World Heritage Sites that UNESCO has recognised. By population Italy is not in the
top ten (it is 25th in `countrypops` for 2022); by sites it is first. Here are the countries with the most sites, with
the population from Great Tables' own `countrypops`, and the sites per ten million people.
"""

nbShowCode:
  let raw = readData("unesco.csv")
  type Paese = object
    country, code: string
    sites, population: int
    perTenMillion: float
  var rows: seq[Paese]
  for i in 0 ..< raw.nrows:
    let sites = int(raw["sites", i].toFloat)
    let pop = int(raw["population", i].toFloat)
    rows.add Paese(country: $raw["country", i], code: $raw["code", i], sites: sites, population: pop,
                   perTenMillion: sites / pop * 1e7)
  rows.sort(proc (a, b: Paese): int = cmp(b.perTenMillion, a.perTenMillion))
  let t = tabella(rows[0 ..< 10], rownameCol = "country"):
    optCssTheme()
    tabHeader md("Where the **World Heritage** is dense"), "the countries with 15 sites or more, by sites per 10 million people"
    fmtFlag "code"
    fmtInteger ["sites", "population"]
    fmtNumber "perTenMillion", decimals = 1
    colsLabel {"code": "", "perTenMillion": "per 10 M people"}
    tabStyle style.text(weight = "bold"), loc.body(rows = where(it["country"] == "Italy"))
    tabSourceNote md("Sites: Wikipedia, *World Heritage Site*, as of July 2026. Population: Great Tables' `countrypops` (World Bank), 2022. By `unesco.nim`.")
  nbTable t

nbText: """
Italy is first by sites (62, with China at 61) but sixth here: per person, Greece, Portugal and
the Czech Republic have more. That is a finding of its own, and a warning for the dataset: a ratio
favours small countries, and among all of them the microstates win (the Holy See is a site of its
own). So `paesi` should carry both numbers, and its examples should say which they rank by.

Two things the twist needs that tabelline does not have: **a join** (the names differ, *Russia*
here, *Russian Federation* in `countrypops`, so the script joins on ISO codes), and **the data
itself**: UNESCO's own list, the World Bank's API and the Our World in Data site are blocked from
this sandbox, Wikipedia answers slowly (it rate-limits) but answers, and Our World in Data's
datasets on GitHub can be read: `owid/co2-data` has every country's population, GDP and CO₂ by
year up to 2024 (CC BY), a richer `countrypops`.
"""

# ================================================================================== closing
nbText: """
## Recommendations

Three, to discuss, each with its choices.

### 1 · One first table, one landmark, one toy

- **First table: `isole`**, the twin of `islands`: the ten largest islands of the Mediterranean,
  in the README's first lines, the home page and the explainer's opening. It is short, Italian at
  the top and shared by five countries, and grows naturally into groups (by country), a density
  and flags. `alpi` follows it as the second geography dataset.
- **Landmark: `paesi`**, the twin of `countrypops` and the README's showcase in the place of
  `sp500`: flags, integers, ratios, a title, a bold row.
- **Toy: `exibble` as it is.** A value in tabelline is missing, a bool, an integer, a float or
  a string: dates, times and factors are strings, formatted when the table is rendered. A twin
  with a column for each type can wait until there are more types; a pantry (`dispensa`) would
  be a good one, with a reason for every missing value.

### 2 · Small examples come from the kitchen and the school

Every tiny example is food or school, or the planets when the example is about science: no more
telescopes and kettles. A dish has a region, a price, a cooking time, a date of harvest, a
vegetarian flag: every format has a dish to show it on. Ported chapters keep gt's data, since
the book keeps its sources as they are, and a `tabelline` box can show the twin beside them.

### 3 · Three steps, in three PRs

1. **Decide** the names and the nine cells (this post, with its review).
2. **Build** (an OpenSpec change): `isole`, `alpi` and `paesi` in `tabelline/datasets`, each
   with its source, licence and date in the module, and the scripts that made them.
3. **Migrate**: the README, the home page, the explainer and the specs' examples move to the new
   datasets; the dated posts keep what they had.

## Choices to make

- **The first table**: `isole` (recommended), `alpi`, `paesi`, the planets as today, or a small food table?
- **Names**: Italian (`isole`, `citta`, `alpi`, `paesi`, `compasso`), as `tavolaPitagorica` is, or
  English, as `planets` is? An Italian name is part of the twist; mixing both is what we have now.
- **Bottega**: is Munari's *risotto verde* the right tiny example for design, and the Compasso
  d'Oro the right bigger one? A dataset from Munari's own books needs care with what we take from
  them (facts and names, in our own words).
- **Sizes**: do built-in datasets stay small (tens of rows, inside the module), and the big ones
  live as files in the docs, or should `paesi` ship whole?

## How this page is built

**1. The page** is a nimib notebook, `docs/devlog/datasets.nim`, written with the docs' blocks
(`docs/blocchi.nim`): `nbGalleria` for the three ways, `nbShowCode` under every table, `nbAccanto`
for the two tables side by side, `nbNota` for the notes, `nbParte` for the three parts. Every
table takes `optCssTheme()`, so it follows the look you picked in the header.

**2. The counts of tabelline** were taken from the sources the first time the page was built:
every `.nim` and `.md` file in `docs/`, `book/`, `openspec/specs/`, `tests/` and `src/`, and the
README, counting the calls of each dataset and the `tableData:` blocks. They are kept in
`devlog/data/datasets/uses.csv`, because a dated post keeps the numbers it had.

**3. The data from outside** was fetched by four scripts beside it, run once: `survey.nim` reads
the READMEs, guides and reference files of gt and Great Tables from raw.githubusercontent.com and
writes `survey.csv`; `unesco.nim` reads Wikipedia's *World Heritage Site* page as wikitext and Great
Tables' `countrypops` CSV, joins them on ISO codes and writes `unesco.csv`; `isole.nim` reads
Wikipedia's list of the islands of the Mediterranean and writes `isole.csv`; `citta.nim` reads its
list of the cities of the European Union and writes `citta.csv`. Each file starts with a `#` line naming its source, and the page reads it
with `readCsv(path, comment = "#")`, which skips those lines.

The scripts were first written in Python, then in Nim, and both are kept beside the data: each
pair writes the same file, row for row. Nim needs nothing beyond its standard library:
`std/httpclient` (compiled with `-d:ssl`) to read a page, `std/re` for the patterns, `std/parsecsv`
for a CSV. Here is the shortest pair, the cities.
"""

nbTabs readFile(data / "citta.py"), "":
  nbText "```nim\n" & readFile(data / "citta.nim").strip & "\n```"

nbShowCode:
  type Pair = object
    script: string
    nim, python: int
    same: string
  proc lines(f: string): int = readFile(data / f).strip.splitLines.len
  var rows: seq[Pair]
  for s in ["survey", "unesco", "isole", "citta"]:
    rows.add Pair(script: s, nim: lines(s & ".nim"), python: lines(s & ".py"), same: "✅")
  let t = tabella(rows, rownameCol = "script"):
    optCssTheme()
    tabHeader "Four scripts, twice", "lines of each, and whether they write the same file"
    tabSpanner "lines", ["nim", "python"]
    colsLabel {"nim": "👑 Nim", "python": "🐍 Python", "same": "same file"}
  nbTable t

nbText: """
The Nim versions are a few lines longer: a `get` proc that goes through the proxy (Python's
`urllib` reads `HTTPS_PROXY` by itself) and explicit capture arrays for `re`. Otherwise they read
line for line like the Python, and they run where the docs are built, with no Python needed. The
next datasets can be fetched in Nim from the start.
"""

nbSave
