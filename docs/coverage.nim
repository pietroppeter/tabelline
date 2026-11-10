## The feature map (gt coverage), docs/coverage/index.html: every feature group of gt (R) and Great Tables
## (Python), where tabelline stands, and the release that plans the rest. Kept up to date, not a
## dated post: the data is docs/coverage/gt.json, updated in the PR that changes a status (and
## in each release PR). The tables on the page are tabelline tables.
import std/[os, json, strutils, strformat, sequtils, tables]
import nimib except md
import tabelline, tabelline/nimib
import blocks

let docs = currentSourcePath().parentDir
let data = parseFile(docs / "coverage" / "gt.json")
nbInit
nb.doc.filename = docs / "coverage" / "index.html"
nb.useTabelline(section = "Feature map", cadence = "kept up to date",
               title = "tabelline and gt: feature map", homeHref = "../",
               description = "Every feature group of gt and Great Tables, what tabelline has, and the plan for the rest.")

const labels = {"done": "has it", "partial": "partly", "missing": "missing", "no": "not planned"}.toTable
const colours = {"done": "var(--success-text)", "partial": "var(--secondary-text)", "missing": "var(--primary-text)", "no": "var(--muted)"}.toTable

type Item = object
  area, feature, gt, status, plan, size, note, where: string
var items: seq[Item]
for a in data["areas"]:
  for r in a["rows"]:
    items.add Item(area: a["title"].getStr, feature: r["feature"].getStr, gt: r["gt"].getStr,
                   status: r["status"].getStr, plan: r{"plan"}.getStr, size: r{"size"}.getStr,
                   note: r["note"].getStr, where: r{"where"}.getStr("both"))
let total = items.len
func count(xs: seq[Item], s: string): int = xs.countIt(it.status == s)

nbTitle &"""Feature map · updated {data["updated"].getStr}""", "tabelline and gt: the feature map", &"""
Every feature group of gt and Great Tables, whether tabelline has it, and the release that plans the rest.
"""
nbText: &"""
gt (R) and Great Tables (Python) have about 200 functions between them. This page groups them
into {total} feature groups and says whether tabelline **has it**, has it **partly** (fewer options
than gt), is **missing** it, or does **not plan** it (machinery of R or Python, or something a Nim
string already does). Today tabelline has **{items.count("done")}** of {total} groups,
**{items.count("partial")}** partly, and {items.count("missing")} are missing. Names are gt's;
tabelline uses the same names in camelCase (`fmt_number` is `fmtNumber`).

The data is [docs/coverage/gt.json](https://github.com/pietroppeter/tabelline/blob/main/docs/coverage/gt.json),
compared with {data["gt"].getStr}.
"""
nbToc

nbText: "## By area"

block:
  type AreaRow = object
    area: string
    has, partly, missing: int
    share: float
  var rows: seq[AreaRow]
  for a in data["areas"]:
    let xs = items.filterIt(it.area == a["title"].getStr)
    rows.add AreaRow(area: &"{a[\"title\"].getStr} ({xs.len})", has: xs.count("done"), partly: xs.count("partial"),
                     missing: xs.count("missing"),
                     share: 100 * (xs.count("done").float + 0.5 * xs.count("partial").float) / xs.len.float)
  let t = tabella(rows, rownameCol = "area"):
    tabHeader "Coverage by area", &"tabelline {data[\"release\"][\"version\"].getStr} against gt and Great Tables"
    tabStubhead "area (groups)"
    colsLabel {"has": "has it", "share": "covered"}
    fmtNumber "share", decimals = 0, pattern = "{x}%"
    dataColor "share", palette = palette("greens"), domain = (0.0, 100.0)
    tabSourceNote "Covered: groups that tabelline has, plus half of those it has partly. Not counted: the groups it does not plan."
    optCssTheme()
  nbTable t

nbText: """
## The plan

Five releases to cover most of gt. Each one is a theme; inside it, every group becomes an
OpenSpec change before it is built. Sizes are rough: S is hours, M a day or two, L more.
"""

block:
  type PlanRow = object
    release, theme, what: string
    groups, s, m, l: int
  var rows: seq[PlanRow]
  for p in data["plans"]:
    let v = p["version"].getStr
    let xs = items.filterIt(it.plan == v)
    rows.add PlanRow(release: v, theme: p["title"].getStr, what: p["plan"].getStr, groups: xs.len,
                     s: xs.countIt(it.size == "S"), m: xs.countIt(it.size == "M"), l: xs.countIt(it.size == "L"))
  let t = tabella(rows, rownameCol = "release"):
    tabHeader "Releases", "what each one adds"
    colsLabel {"what": "", "s": "S", "m": "M", "l": "L"}
    tabSpanner "sizes", ["s", "m", "l"]
    subZero ["s", "m", "l"], zeroText = ""
    tabStyle style.text(weight = "bold"), loc.body(cols = "theme")
    optCssTheme()
  nbTable t

nbText: """
### A bigger 0.1: the basics, while they are cheap

Before 0.1.0 was tagged, it grew by these groups that took hours each, most
of them a verb over machinery that was already there (formats, substitutions, options, locations),
each one an OpenSpec change. With them, 0.1 has every basic of gt except the ones that need real
work: summary rows and merged columns, which open 0.2. How they were built is in the devlog post
[Designing tabelline 0.1](../devlog/designing-0-1/).
"""

block:
  type Basic = object
    area, feature: string
  let rows = items.filterIt(it.plan == "0.1").mapIt(Basic(area: it.area,
    feature: &"**{it.feature}**<br>`" & it.gt.replace(", ", "` `") & "`<br>" & it.note))
  let t = tabella(rows, groupnameCol = "area"):
    tabHeader "Built for 0.1", &"{rows.len} small groups, each a few hours"
    colsLabel {"feature": "group, gt names, what it is"}
    fmtMarkdown "feature"
    optCssTheme()
  nbTable t

nbText: """
## Catalogue

Every group, by area. The release column says where an open group is planned.
"""

block:
  type Row = object
    area, feature, now, plan: string
  var rows: seq[Row]
  for x in items:
    let only = if x.where == "both": "" else: &" ({x.where} only)"
    var feat = &"**{x.feature}**<br>`" & x.gt.replace(", ", "` `") & "`" & only
    if x.note.len > 0: feat.add "<br>" & x.note
    rows.add Row(area: x.area, feature: feat, now: labels[x.status],
                 plan: (if x.plan.len > 0 and x.status != "done": x.plan & " · " & x.size
                        elif x.plan.len > 0: "in " & x.plan else: ""))
  var t = tabella(rows, groupnameCol = "area"):
    tabHeader "gt and Great Tables, group by group", "and where tabelline stands"
    colsLabel {"feature": "feature group, gt names, notes", "now": "today", "plan": "planned"}
    fmtMarkdown "feature"
    colsWidth {"now": "5.5em", "plan": "4.5em"}
    optCssTheme()
  for s, label in labels:
    let c = colours[s]
    t = t.tabStyle(style.text(color = c, weight = "bold"), loc.body(cols = "now", rows = where(it["now"] == label)))
  nbTable t

nbText: """
## Not from gt

tabelline follows gt and Great Tables. What it has that neither of them has is listed here, with
why it is there and the closest thing in gt or Great Tables. Anything new that is not from gt
gets a line in this table.
"""

block:
  type N = object
    what, why, closest: string
  let rows = @[
    N(what: "`tableData:`", why: "data written as columns in Nim code, names like `size.mass` included", closest: "a data frame (R) or a Polars or pandas DataFrame (Python)"),
    N(what: "a table from a seq of objects or tuples", why: "Nim data as it is, one column per field", closest: "a data frame"),
    N(what: "`parseCsv`, `readCsv`, `addColumn`, `toTableData`", why: "the core uses only Nim's standard library, so it reads its own data", closest: "readr, Polars or pandas, before `gt()` / `GT()`"),
    N(what: "`rowOrder`", why: "sorts the rows shown and leaves the data as it is; Nim has no dplyr", closest: "`dplyr::arrange()` or `df.sort()` before the table"),
    N(what: "`colsReorder`", why: "puts some columns in a new order in the places they hold, so two can swap", closest: "`cols_move()`, `cols_move_to_start()`"),
    N(what: "the text and Markdown renderers (`echo t`, `toMarkdown`)", why: "tables in the terminal, in tests and in the specs' examples", closest: "none; gt and Great Tables write HTML (and LaTeX, RTF, Word in gt)"),
    N(what: "`optCssTheme()`", why: "every colour and the font of the table come from the page's CSS variables, so the table follows the page's look", closest: "`opt_stylize()` / `tab_options()`, with fixed colours"),
    N(what: "`nbTable` (nimib)", why: "a table in a nimib notebook, with its Markdown for the notebook's text output", closest: "a table printed in Quarto, R Markdown or Jupyter"),
    N(what: "the datasets `planets` and `tavolaPitagorica`", why: "small examples for the docs (`exibble` is gt's)", closest: "gt's and Great Tables' datasets"),
  ]
  let t = tabella(rows):
    tabHeader "Not from gt", "what tabelline has that gt and Great Tables do not"
    colsLabel {"what": "in tabelline", "why": "why", "closest": "closest in gt or Great Tables"}
    fmtMarkdown everything()
    tabOptions(tableWidth = "100%", tableFontSize = "14px")
    optCssTheme()
  nbTable t

nbSave
