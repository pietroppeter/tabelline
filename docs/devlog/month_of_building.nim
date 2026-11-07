## devlog: 07 Nov 2026 F | A month of building, as an operetta | Seven weeks of open source made with Claude, told in seven acts: what happened, one moment from each, and the parts of a way of working that grew along the way. The first use of tabelline on real data.
## A dated post: it tells the month as it was on 7 November 2026, and is not updated afterwards.
## The data and the selection are in docs/mese.nim; the raw pull requests in devlog/data/.
import std/[os, strutils, strformat, tables]
import nimib except md
import tabelline, tabelline/nimib
import ../quaderno, ../mese

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "month-of-building" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Devlog", classe = "post · 7 November 2026",
               title = "A month of building, as an operetta", homeHref = "../")

const bar = "var(--blu, var(--pen))"   # the square's blue in Munari, the pen in the quaderno
let d = monthData()
var repos: CountTable[string]
for i in 0 ..< d.nrows: repos.inc $d["repo", i]
let byAct = prsByAct()

nbText: &"""
<p class="kicker">Devlog · 7 November 2026</p>

# A month of building, as an operetta

<p class="lede">Seven weeks of open source made with Claude, told in seven acts: what happened,
one moment from each, and the parts of a way of working that grew along the way.</p>

Since Opus 5.5 came out, Pietro has been writing open source with Claude, mostly from his phone.
From 20 September to 7 November that made **{d.nrows} pull requests and issues** in
**{repos.len} public repositories**, his own and a few of others. That is too much to show, and
this post does not try: no dashboard, no grid, no chart of every day. It picks.

It picks three things: the acts the month falls into, one moment from each act, and the parts
of a way of working that each act added. The last are the point. They are what the next post
puts together and names: [Operetta](../operetta/).

This is also the first time tabelline is used on real data, by its own *use it* thread for 0.1
(see the [roadmap](../../roadmap/)): every table below is a tabelline table, and what it was
missing is at the end.

## Seven acts

An operetta is a light opera: an overture, a few acts, an interlude, a finale, songs between
spoken parts. The month had that shape.
"""

block:
  type ActRow = object
    act, story: string
    prs: int
  var rows: seq[ActRow]
  for a in acts:
    rows.add ActRow(act: &"**{a.name}**<br>{a.english}<br>{a.dates}",
                    story: &"{a.story}<br>**One moment:** {a.moment}", prs: byAct[a.key])
  let t = tabella(rows, rownameCol = "act"):
    tabHeader "The month in seven acts", "20 September to 7 November 2026"
    colsLabel {"story": "what happened", "prs": "PRs"}
    fmtMarkdown ["act", "story"]
    fmtBar "prs", color = bar, width = "2.5em", showValue = true
    colsWidth {"act": "24%"}
    tabFootnote "Pull requests and issues opened in the act, public repositories only.", loc.columnLabels("prs")
    tabSourceNote md("From GitHub's search API; the selection of acts and moments is by hand.")
  nbTable t

nbText: """
Two things stand out. The busiest act is nanuq, Polars for Nim, which went from a first proof
of concept to 0.6 in six days. And the acts overlap: the talk ran under everything, and the
workshop and the games shared the same week. A thread for each piece of work, in a project for
each subject, is what made that possible: Claude carries one task while Pietro reads another.

Where the work went, repository by repository, is the one count worth showing. Here it is in
the three languages of tabelline's explainers: Nim with tabelline, Python with Great Tables, R
with gt.
"""

nbTabs(python = """
import polars as pl
from great_tables import GT

prs = pl.read_csv("docs/devlog/data/month-prs.tsv", separator="\t", quote_char=None)
top = (prs.with_columns(pl.col("repo").str.replace("pietroppeter/", ""))
          .group_by("repo").len("prs")
          .sort("prs", descending=True).head(7))
(GT(top, rowname_col="repo")
    .tab_header("Where the work went", "the seven busiest of 30 repositories")
    .cols_label(prs="PRs and issues")
    .fmt_nanoplot("prs", plot_type="bar"))
""", r = """
library(gt)
library(dplyr)

prs <- read.delim("docs/devlog/data/month-prs.tsv", quote = "")
top <- prs |>
  mutate(repo = sub("pietroppeter/", "", repo)) |>
  count(repo, name = "prs", sort = TRUE) |>
  head(7)
gt(top, rowname_col = "repo") |>
  tab_header("Where the work went", "the seven busiest of 30 repositories") |>
  cols_label(prs = "PRs and issues") |>
  fmt_nanoplot(prs, plot_type = "bar")
"""):
  nbCode:
    let prs = readCsv("docs/devlog/data/month-prs.tsv", sep = '\t')
    var counts: CountTable[string]
    for i in 0 ..< prs.nrows:
      counts.inc ($prs["repo", i]).replace("pietroppeter/", "")
    counts.sort()
    var top: seq[tuple[repo: string, prs: int]]
    for repo, n in counts:
      if top.len < 7: top.add (repo, n)
    let t = tabella(top, rownameCol = "repo"):
      tabHeader "Where the work went", "the seven busiest of 30 repositories"
      colsLabel {"prs": "PRs and issues"}
      fmtBar "prs", color = "var(--blu, var(--pen))", width = "9em"
  nbTable t

nbText: """
Six of the seven were started in these seven weeks. The talk is the exception: started in
August, it is the one piece of work that runs through the whole month.

## What grew

The month's real output is not in the counts. In every act a problem came up, a part of the way
of working was made to solve it, and the next project copied it. Here is each part where it
first shows up, in a pull request title:
"""

block:
  type PartRow = object
    act, part, what, born: string
  var rows: seq[PartRow]
  for p in parts:
    var label = ""
    for a in acts:
      if a.key == p.act: label = &"{a.name} · {a.english}"
    rows.add PartRow(act: label, part: &"**{p.name}**", what: p.plain,
                     born: &"[{p.born.replace(\"talk-sailing-seas-scientific-nim\", \"talk\")}#{p.pr}]({prUrl(p.born, p.pr)})<br>{p.date}")
  let t = tabella(rows, rownameCol = "part", groupnameCol = "act"):
    tabHeader "The parts of a way of working", "where each first appears"
    colsLabel {"what": "what it is", "born": "first in"}
    fmtMarkdown ["part", "born"]
    colsWidth {"part": "26%", "born": "24%"}
    tabFootnote "Tried for nimib (closed, kept for later), and the subject of the third post.", loc.stub(rows = where(it["part"] == "**Skills**"))
    tabSourceNote md("Some parts existed earlier in a smaller form; this is where they first get a pull request of their own.")
  nbTable t

nbText: """
Read top to bottom, the table tells how the way of working was built: first what any repo needs
when it is made in throwaway cloud sessions (a setup script, pages built by CI, a line saying
AI was used), then places to think in (explainers, artifacts), then ways to agree with Claude
before building (specs, a backlog, proposals in their own PRs), and last the parts that only a
library growing toward a reference needs (a coverage map, a book of ports, design posts, three
threads per release).

## How the work went

Behind the tables there is one loop, and it is the same in every act:

1. **An idea becomes a page.** An explainer, often a claude-artifacts page made on the phone:
   the affinity propagation animation, the diagrams history, declarative dragging. Reading a
   page is how Pietro thinks with Claude.
2. **The page becomes a repo** when the idea holds. zogyn and diagrammari started as
   artifacts; parloku as a notebook.
3. **The repo grows living documents**: an explainer, the specs, a coverage map, a roadmap.
   They say how things are *now*, and are rebuilt on every push.
4. **The devlog keeps the story**: dated posts, written while the decisions are fresh.
5. **Previews close the loop**: a published page, read on the phone, with a link to the exact
   part that changed. Nothing reaches `main` without a "go".

## What it leaves

Two questions, each with a post of its own:

- **Can the parts be picked, rather than all copied?** nanuq used almost every one; cadero, a
  furniture plan, needed few; a talk needs different ones. The next post,
  [Operetta, a first sketch](../operetta/), lists the parts as modules and says which to pick
  for what.
- **What are skills, and where do they go?** They were tried once and set aside. The third post,
  [Skills, from the beginning](../skills/), starts from the simplest idea and ends with what
  Operetta could do with them.

## What tabelline was missing

This post used tabelline as a user would, and sent what it found to the thread that builds 0.1:
"""

block:
  type Gap = object
    what, how: string
  let rows = @[
    Gap(what: "No TSV reader that leaves quotes alone",
        how: "`readCsv(sep = '\\t')` works, but a `\"` in the middle of a title starts a quoted field and the quotes vanish (`next to \"live\"` reads `next to live`). Python needs `quote_char=None`, R `quote = \"\"`."),
    Gap(what: "No count or group-by",
        how: "Expected: tabelline is not a data frame library. A `CountTable` did the job; with nanuq it would be one line."),
    Gap(what: "Small Markdown, no HTML",
        how: "`fmtMarkdown` knows `<br>` but escapes any other tag (a `<small>` showed as text), and turns `~` and `^` into sub- and superscripts, so `~50 PRs` would surprise. An `html()` cell format would help."),
    Gap(what: "Markdown in a group label",
        how: "Row group labels come from the data as plain text; `fmtMarkdown` reaches cells, not groups, so act names stay plain."),
    Gap(what: "No nanoplot for single values",
        how: "`fmtBar` covers it here. Great Tables and gt draw a single value as a bar with `fmt_nanoplot(plot_type=\"bar\")`, planned for 0.4."),
    Gap(what: "A colour from the page",
        how: "`fmtBar(color = \"var(--blu, var(--pen))\")` works because the colour goes into a style attribute, so a page's CSS variables reach it. Worth saying so in the docs."),
  ]
  let t = tabella(rows, rownameCol = "what"):
    tabHeader "Gaps found by this post"
    colsLabel {"how": ""}
    fmtMarkdown "how"
    colsWidth {"what": "30%"}
  nbTable t

nbSave
