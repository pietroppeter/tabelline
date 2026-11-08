## The Agents page, docs/agents/index.html: what a coding agent (or a person new to the repository)
## needs to work on tabelline: setup, the commands, where things are, and the working rules, read
## from AGENTS.md when the page builds so the two never disagree. A living document. It also
## writes docs/llms.txt, a short map of the site for language models (llmstxt.org).
import std/[os, strformat, strutils]
import nimib except md
import tabelline, tabelline/nimib
import quaderno

let docs = currentSourcePath().parentDir
let repo = docs.parentDir
nbInit
nb.doc.filename = docs / "agents" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Agents", classe = "living document",
               title = "tabelline for agents", homeHref = "../",
               description = "For coding agents working on tabelline: setup, commands, where things are, and the working rules.")

nbText: """
<p class="kicker">Agents · living document · started 8 November 2026</p>

# Working on tabelline, for agents

<p class="lede">What a coding agent needs to change tabelline: how to set up, the five commands
it will run, where things are, and the rules of the repository. People new to the code can read
it too.</p>

The rules below are read from [AGENTS.md](https://github.com/pietroppeter/tabelline/blob/main/AGENTS.md)
when this page is built, so they are always the ones in the repository. A short map of the site
for language models is at [llms.txt](../llms.txt). Skills for tabelline will be listed here when
there are some.
"""
nbIndice

nbText: """
## Start here

In a fresh checkout or sandbox, run the setup first. It installs what is missing (Nim, atlas,
libpcre3) and the pinned dependencies, and it is safe to run again:

```sh
sh tools/setup.sh
```

Then these are the commands an agent runs, in the order a change needs them:
"""

block:
  let cmds = tableData:
    command: ["nim r tests/all.nim", "nim r tools/specexamples.nim", "nim r tools/specexamples.nim --update",
              "nim r -d:release docs/all.nim", "python3 tools/preview.py"]
    does: ["runs the tests", "runs every example in the specs and checks its output",
           "rewrites the outputs after a change is built (`--changes` adds open changes)",
           "builds every page into docs/ (the HTML is not committed)",
           "copies the built pages to ../tabelline-preview, for an artifact to show Pietro"]
  let t = tabella(cmds, rownameCol = "command"):
    tabHeader "The commands"
    colsLabel {"does": "what it does"}
    fmtMarkdown "does"
    optQuaderno()
  nbTable t

nbText: """
## Where things are

- `src/tabelline/`: the library. The core needs only Nim's standard library; nimib is used only
  by `src/tabelline/nimib.nim`.
- `openspec/specs/`: how tabelline behaves, requirement by requirement, each with an example.
  New work starts as a change in `openspec/changes/`. Rendered on the [specs page](../specs/),
  which can show part of them: `specs/?spec=<names>` or `specs/?change=<names>`.
- `docs/`: every page, a nimib notebook. The look is `docs/quaderno.nim` and `docs/munari.nim`,
  explained in the [Design Ref](../design/). Posts are in `docs/devlog/`.
- `BACKLOG.md` (ideas), `CHANGELOG.md` (what shipped), `docs/coverage/gt.json` (what of gt is
  covered), `docs/piano.nim` (the roadmap's data).

## The rules, from AGENTS.md
"""

# AGENTS.md, one level of heading down so that its sections sit under this one.
var rules = readFile(repo / "AGENTS.md")
rules = rules.split('\n', 1)[1]   # drop its own title
rules = rules.replace("\n## ", "\n### ")
nbText: rules

nbText: """
## How it is built

`docs/agents.nim` reads `AGENTS.md` from the repository when the pages are built, drops its
title and turns its `##` sections into `###`, so the rules on this page are the file's. It also
writes `docs/llms.txt` from the list of living documents below it in the same file; CI publishes
it at the root of the site.
"""
nbSave

# llms.txt (llmstxt.org): a title, a summary, then links to what a model should read.
let pages = [
  ("The Great Explainer", "explainer/", "gt and Great Tables from zero, and tabelline step by step"),
  ("Devlog", "devlog/", "the roadmap, the coverage map and every post"),
  ("Design Ref", "design/", "the look of the pages and every component"),
  ("Agents", "agents/", "setup, commands and the working rules"),
  ("Specs", "specs/", "every requirement, with examples that ran when the page was built"),
]
var llms = """# tabelline

> Display tables for Nim, after R's gt and Python's Great Tables: a header, a stub, groups,
> spanners, formatted numbers, colours and notes, rendered to HTML, text and Markdown.

Source: https://github.com/pietroppeter/tabelline . Verbs are gt's in camelCase (`tab_header` is
`tabHeader`); a table is a `Tabella` value and every verb returns a new one.

## Docs

"""
for (title, path, what) in pages:
  llms.add &"- [{title}]({siteUrl}{path}): {what}\n"
llms.add &"\n## Optional\n\n- [Coverage map]({siteUrl}coverage/): what of gt tabelline has\n" &
  &"- [Roadmap]({siteUrl}roadmap/): the releases from 0.1 to 0.5\n"
writeFile(docs / "llms.txt", llms)
