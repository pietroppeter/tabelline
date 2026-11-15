## The page For coding agents, docs/agents/index.html: what a coding agent (or a person new to the repository)
## needs to work on tabelline: setup, the commands, where things are, and the working rules, read
## from AGENTS.md when the page builds so the two never disagree. Kept up to date. It also
## writes docs/llms.txt, a short map of the site for language models (llmstxt.org).
import std/[os, strformat, strutils, algorithm]
import nimib
import tabelline, tabelline/nimib
import blocks

let docs = currentSourcePath().parentDir
let repo = docs.parentDir
nbInit
nb.doc.filename = docs / "agents" / "index.html"
nb.useTabelline(section = "For coding agents", cadence = "kept up to date",
               title = "tabelline for agents", homeHref = "../",
               description = "For coding agents working on tabelline: setup, commands, where things are, and the working rules.")

nbTitle "For coding agents · kept up to date · started 8 November 2026", "Working on tabelline, for agents", """
What a coding agent needs to change tabelline: how to set up, the commands it will run, where things are, and the rules of the repository. People new to the code can read it too.
"""
nbText: """
The rules below are read from [AGENTS.md](https://github.com/pietroppeter/tabelline/blob/main/AGENTS.md)
when this page is built, so they are always the ones in the repository. A short map of the site
for language models is at [llms.txt](../llms.txt). An agent *using* tabelline (not changing it)
reads the whole API in one Markdown file, [api.md](../api.md), or as data, [api.json](../api.json):
the Reference, as plain text. Two [skills](#skills-for-agents-that-use-tabelline) come with the repository.
"""
nbToc

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
              "nim r tools/drift.nim", "nim r -d:release docs/all.nim", "nim r book/bookbuild.nim",
              "nim r tools/preview.nim"]
    does: ["runs the tests", "runs every example in the specs and checks its output",
           "rewrites the outputs after a change is built (`--changes` adds open changes)",
           "checks that no page adds HTML, styles or colours (`--update` lowers the baseline)",
           "builds every page into docs/ (the HTML is not committed)",
           "builds the book into docs/book/ (only the chapters that changed)",
           "copies the built pages to ../tabelline-preview, for an artifact to show Pietro"]
  let t = tabella(cmds, rownameCol = "command"):
    tabHeader "The commands"
    colsLabel {"does": "what it does"}
    fmtMarkdown "does"
    optCssTheme()
  nbTable t

nbText: """
## Where things are

- `src/tabelline/`: the library. The core needs only Nim's standard library; nimib is used only
  by `src/tabelline/nimib.nim`, and nanuq only by `src/tabelline/nanuq.nim`.
- `openspec/specs/`: how tabelline behaves, requirement by requirement, each with an example.
  New work starts as a change in `openspec/changes/`. Rendered on the [specs page](../specs/),
  which can show part of them: `specs/?spec=<names>` or `specs/?change=<names>`.
- `docs/`: every page, a nimib notebook made of the blocks in `docs/blocks.nim` (the review mode's are in `docs/review.nim`); the look is `docs/theme.nim`,
  explained in the [Design guide](../design/). Posts are in `docs/devlog/`, stories (one for
  every release, told with tabelline) in `docs/stories/`.
- `book/`: the [book](../book/), a nimibook (`nim r book/bookbuild.nim`); its planned sources are
  in `book/plan/`.
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
## Skills, for agents that use tabelline

A skill is a short Markdown file an agent reads before a task. Two are in the repository, in
`skills/`, and the post [Skills for tabelline](../devlog/skills/) tells how they were made and
tested.

- [tabelline](https://github.com/pietroppeter/tabelline/blob/main/skills/tabelline/SKILL.md):
  what tabelline's docs do not say. Where the plain-text docs are and how to search them, how to
  work (a recipe, `echo t`, then the page), the traps agents met, and two pages for hard tables:
  data made in code, and drawings in cells.
- [table-building](https://github.com/pietroppeter/tabelline/blob/main/skills/table-building/SKILL.md):
  for any table, with any library. What to decide first, in what order to build, and to look at
  the page, wide and on a phone, before saying it is done. It comes with a script that takes the
  two screenshots.

In Claude Code they install as a plugin:

```
/plugin install tabelline --marketplace pietroppeter/tabelline
```

Any other agent can be pointed at the two files. Their Nim examples run against the code
(`nim r tools/skillexamples.nim`, in CI), and each skill has eval cases in `evals/`, graded by
`nim r tools/skillevals.nim <case> <run folder>`.

## How it is built

`docs/agents.nim` reads `AGENTS.md` from the repository when the pages are built, drops its
title and turns its `##` sections into `###`, so the rules on this page are the file's. It also
writes `docs/llms.txt` from the list of pages below it in the same file; CI publishes
it at the root of the site.
"""
nbSave

# llms.txt (llmstxt.org): a title, a summary, then links to what a model should read.
let pages = [
  ("Guide", "explainer/", "gt and Great Tables from zero, and tabelline step by step"),
  ("Stories", "stories/", "real subjects told in tables made with tabelline, one for every release"),
  ("Book", "book/", "the Great Tables and gt guides ported to tabelline, with what the book will port and what the port found"),
  ("Reference", "api/", "every name tabelline exports: signatures, doc comments, gt and Great Tables names, examples (as Markdown: api.md, as JSON: api.json)"),
  ("Feature map", "coverage/", "what of gt and Great Tables tabelline has"),
  ("Roadmap", "roadmap/", "the releases, from 0.1 to 0.3"),
  ("Devlog", "devlog/", "dated posts on how tabelline is made, newest first"),
  ("Specs", "specs/", "every requirement, written with OpenSpec, with examples that ran when the page was built"),
  ("Design guide", "design/", "the look of the pages and every component"),
  ("For coding agents", "agents/", "setup, commands and the working rules"),
]
let tag = block:
  var v = ""
  for l in readFile(repo / "tabelline.nimble").splitLines:
    if l.startsWith("version"): v = "v" & l.split('"')[1]
  v
let raw = "https://raw.githubusercontent.com/pietroppeter/tabelline/" & tag & "/"
var llms = &"""# tabelline

> Display tables for Nim, after R's gt and Python's Great Tables: a header, a stub, groups,
> spanners, formatted numbers, colours and notes, rendered to HTML, text and Markdown.

Source: https://github.com/pietroppeter/tabelline ({tag}). Verbs are gt's in camelCase
(`tab_header` is `tabHeader`); a table is a `Tabella` value and every verb returns a new one.
Install (not in nimble's package list): `nimble install "https://github.com/pietroppeter/tabelline@#{tag}"`,
run outside a nimble project; it needs only Nim 2.2 and its standard library.

## For a model: plain text first

- [API reference, Markdown]({siteUrl}api.md): every exported name with its signatures, doc
  comment, gt's and Great Tables' names and a spec example with what it prints; an index of one
  line per name at the top. Grep it for a gt name (`fmt_number`) to find tabelline's.
- [API reference, JSON]({siteUrl}api.json): the same as data.
- [Feature map, JSON]({siteUrl}coverage/gt.json): every feature of gt and Great Tables, done,
  partial, missing (with the release planned) or not planned.
- Specs, Markdown: every behaviour as a requirement with an example and its output:
"""
var specDirs: seq[string]
for f in walkDirs(repo / "openspec" / "specs" / "*"): specDirs.add f
specDirs.sort()
for f in specDirs:
  if f.lastPathPart != "way-of-working" and f.lastPathPart != "review-mode":
    llms.add &"  - [{f.lastPathPart}]({raw}openspec/specs/{f.lastPathPart}/spec.md)\n"
llms.add &"- [README]({raw}README.md): the simplest example, and where everything is.\n"
# the skills are read from main: they are newer than the release's tag
let skillsRaw = "https://raw.githubusercontent.com/pietroppeter/tabelline/main/skills/"
llms.add &"""
## Skills

Short instructions for an agent that makes a table, tested with agents. Read them before a task.

- [tabelline]({skillsRaw}tabelline/SKILL.md): how to work with tabelline, the traps agents met,
  and where to read for hard tables (data made in code, drawings in cells).
- [table-building]({skillsRaw}table-building/SKILL.md): for any table with any library: what to
  decide first, in what order to build, and how to look at the page before saying it is done.
"""
llms.add "\n## Pages\n\n"
for (title, path, what) in pages:
  llms.add &"- [{title}]({siteUrl}{path}): {what}\n"
writeFile(docs / "llms.txt", llms)
