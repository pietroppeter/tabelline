## The roadmap, docs/roadmap/index.html: the releases from 0.1 to 0.5, and for each the three
## threads that make it (build it, use it, port the references), with their status. Kept up
## to date: the data is docs/piano.nim, updated when a thread starts, ships or changes its plan.
import std/[os, strutils, strformat]
import nimib except md
import tabelline, tabelline/nimib
import blocchi, piano

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "roadmap" / "index.html"
nb.useTabelline(nome = "tabelline", materia = "Roadmap", classe = "kept up to date",
               title = "tabelline roadmap", homeHref = "../",
               description = "The releases of tabelline, and the three threads that make each one.")

nbTitolo "Roadmap · kept up to date", "The roadmap", """
Five releases to cover most of gt, and three threads for each: one builds it, one uses it, one ports the code that already exists.
"""
nbText: """
What goes in each release comes from the [feature map](../coverage/); why the work is split in
three is told in the devlog post [Three threads for every release](../devlog/three-threads/).
This page says where each thread stands.
"""
nbIndice

nbText: "## The three threads"

block:
  type Kind = object
    thread, does: string
  var rows: seq[Kind]
  for (key, icon, name, does) in threadKinds:
    rows.add Kind(thread: icon & " " & name, does: does)
  let t = tabella(rows, rownameCol = "thread"):
    tabHeader "Three threads for every release"
    colsLabel {"does": ""}
    optCssTheme()
  nbTable t

nbText: "## Releases"

block:
  type Row = object
    release, thread, what, output, status: string
  var rows: seq[Row]
  for r in releases:
    for th in r.threads:
      var icon = ""
      for (key, i, name, does) in threadKinds:
        if key == th.kind: icon = i
      rows.add Row(release: &"{r.version} · {r.theme}", thread: &"{icon} **{th.title}**<br>{th.what}",
                   output: (if th.href.len > 0: &"[{th.output}](../{th.href})" else: th.output), status: th.status)
  var t = tabella(rows, groupnameCol = "release"):
    tabHeader "Releases and their threads", "0.1 to 0.5"
    colsLabel {"thread": "thread, and what it does", "output": "makes"}
    fmtMarkdown ["thread", "output"]
    colsWidth {"output": "24%", "status": "5em"}
    optCssTheme()
  t = t.tabStyle(style.text(color = "var(--muted)"), loc.body(cols = "status", rows = where(it["status"] == "planned")))
  nbTable t

nbText: """
## The references

The port threads take code from these sources. Each port names its source and keeps its
licence; a source whose licence does not allow it is not copied.
"""

block:
  type Source = object
    source, who, licence, release: string
  let rows = @[
    Source(source: "[Great Tables user guide](https://posit-dev.github.io/great-tables/get-started/)", who: "Posit (Rich Iannone, Michael Chow)", licence: "MIT", release: "0.1, 0.2, 0.4"),
    Source(source: "[gt articles](https://gt.rstudio.com/articles/)", who: "Posit (Rich Iannone)", licence: "MIT", release: "0.1, 0.2"),
    Source(source: "[Great Tables examples](https://posit-dev.github.io/great-tables/examples/)", who: "Posit", licence: "MIT", release: "0.2"),
    Source(source: "gt reference examples", who: "Posit", licence: "MIT", release: "0.3, 0.5"),
    Source(source: "[Great Tables blog](https://posit-dev.github.io/great-tables/blog/)", who: "Posit", licence: "MIT", release: "0.4"),
    Source(source: "[Posit Table Contest](https://posit.co/blog/announcing-the-2024-table-contest-winners/)", who: "the entrants", licence: "each entry its own", release: "0.3"),
    Source(source: "[pharmaverse examples](https://pharmaverse.github.io/examples/)", who: "pharmaverse", licence: "to check", release: "0.5"),
  ]
  let t = tabella(rows, rownameCol = "source"):
    tabHeader "Reference code to port"
    colsLabel {"who": "by", "release": "for"}
    fmtMarkdown "source"
    tabSourceNote "The ports go in the tabelline book, a nimibook kept in this repository (in the Edo palette, made like the Nanuq Book), with the original Python or R next to the Nim."
    optCssTheme()
  nbTable t

nbText: "## Left aside"

block:
  type Aside = object
    what, why: string
  var rows: seq[Aside]
  for (what, why) in leftAside: rows.add Aside(what: what, why: why)
  let t = tabella(rows, rownameCol = "what"):
    tabHeader "Not planned, for now"
    colsLabel {"why": ""}
    optCssTheme()
  nbTable t

nbSave
