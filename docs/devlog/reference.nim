## devlog: 11 Nov 2026 A | A reference in our own style | Every name tabelline exports, on one page that looks like the rest of the site and that people and agents can link to. What Nim's doc tools give, why the page reads both them and the source, the choices behind it (each set against gt and Great Tables), the four rounds of review that shaped it, and how it is built.
## A dated post: it tells how the Reference page (docs/api.nim) was made, and is not updated
## afterwards. The page itself is kept up to date; the counts here are those of 11 November 2026.
import std/[os, strutils]
import nimib
import tabelline, tabelline/nimib
import ../blocks
import ../../tools/apidoc

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "reference" / "index.html"
nb.useTabelline(title = "A reference in our own style", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026", "A reference in our own style", """
Every name tabelline exports, on one page that looks like the rest of the site and that people and agents can link to. What Nim's doc tools give, why the page reads both them and the source, the choices behind it, the four rounds of review that shaped it, and how it is built.
"""

nbText: """
tabelline had a guide, a book, specs and a feature map, and each of them tells a story: how
to make a table, how a gt example looks in Nim, what a verb must do. None of them answers the
plainest question a reader brings: *what is `fmtNumber`, exactly, and what does it take?* That is
the job of a reference: one place with every name, its signature and its doc comment. The
[Reference](../../api/) is that place. This post tells how it was made.
"""

nbToc()

nbText: """
## What a reference is for

Two readers come to a reference. A person comes with a name: they saw `colsLabel` in an example
and want its arguments. An agent comes with a task: it needs the list of names, to find the one
that does the job, and a link it can give back. Both want the same things:

- every name, none missing, so the page can be trusted;
- the name's signature as the compiler sees it, and the doc comment as its author wrote it;
- a link that leads to the name and keeps working when the API grows;
- a way from tabelline's name to gt's and Great Tables', since most readers know one of them.

gt has a [reference](https://gt.rstudio.com/reference/) made by pkgdown, Great Tables
[one](https://posit-dev.github.io/great-tables/reference/) made by quartodoc: an index of every
function, grouped by family, and a page for each. Nim has its own tools for this.

## What Nim offers

Nim can write the documentation of a module in four ways, and the source is a fifth place to
read. Each gives part of what a reference needs:
"""

block:
  type Tool = object
    tool, gives, misses: string
  let rows = @[
    Tool(tool: "`nim doc`",
         gives: "an HTML page per module, every exported name with its signature and doc comment",
         misses: "its own look, nimdoc's, not the site's; no links to gt"),
    Tool(tool: "`nim jsondoc`",
         gives: "the same as JSON: name, kind, signature, line",
         misses: "doc comments rendered as reStructuredText, where `*`, backticks and `|` mean something else; two of ours fail"),
    Tool(tool: "`nim book`",
         gives: "new in Nim 2.4 ([#26139](https://github.com/nim-lang/Nim/pull/26139)): a book from Markdown and a SUMMARY.md, in nimdoc's look",
         misses: "no module documentation of its own: it links to the pages of `nim doc`"),
    Tool(tool: "`--project`",
         gives: "`nim doc --project`: every module at once, with an index",
         misses: "Nim 2.2.4 stops with a RangeDefect on `locales.nim`, a constant of 150 000 characters (Nim 2.4.1 does not)"),
    Tool(tool: "the source",
         gives: "doc comments as written (Markdown), the `# ----` lines that cut a module in sections, imports and exports",
         misses: "the kinds and signatures as Nim prints them, after macros and templates"),
  ]
  let t = tabella(rows, rownameCol = "tool"):
    tabHeader "Five places to read an API"
    colsLabel:
      gives: "what it gives"
      misses: "what it misses"
    fmtMarkdown columns = ["tool", "gives", "misses"]
    tabStyle style.css("white-space: nowrap"), loc.stub()
    optCssTheme()
  nbTable t

nbText: """
So the page reads two of them. `nim jsondoc`, one module at a time, says which names a module
exports, of what kind, with what signature, on which line. The source, at that line, gives the
doc comment in the Markdown it was written in, and the section the name sits in. `nim book`
was the reason to look, and it is a good fit for a book of Markdown chapters, but a reference in
our own look needs the data, not someone else's HTML.

## One page, from the simplest up

The page goes from the whole to the parts, the way this site explains things: the modules
first, then each module, then each name. Every choice below is set against what gt and Great
Tables do.

### The modules

- **One page.** Every name is on [one page](../../api/), so a reader searches it with the
  browser and an agent reads one file. *gt:* an index and a page per function. *Great Tables:*
  the same.
- **The modules come first, in one table.** For each module: what it is, how many names it
  exports and of what kinds, the modules it [exports again](../../api/#modules) (`tabelline`
  exports all of them, `core` exports `std/options`), what it imports, which modules import it,
  what it uses from Nim. Each module's name in the table links to its section. *gt:* one
  package, no modules. *Great Tables:* modules exist but the reference groups by family.
- **Dependency order.** A module comes after every module it imports, so `core` is first and
  `tabelline`, which brings them all, is last. The table of contents has the same order, coloured
  by part. *gt* and *Great Tables:* by family, starting from the table itself (`gt()`, `GT`).

### The names of a module

- **A table of names, by section.** Under each module's heading and first sentence, a table lists
  every name with its kind (`func ×9` when it has nine overloads), grouped by the module's
  sections; each group links to its section. *gt* and *Great Tables:* the index lists names by
  family, with a one-line description.
- **The entries are folded.** The names' entries sit in a fold that starts closed, so the page
  can be read as a map of modules. A link to a name inside a closed fold opens it.

### One name

- **A link that lasts.** `api/#verbs-tabHeader` is the module and the name, and does not change
  when another module adds a name of the same spelling. The short `api/#tabHeader` works too, for
  the first name with that spelling. Operators are spelled by their character codes:
  `#core-op26` is `&`. The **#** beside a name is its link. *gt:*
  `reference/tab_header.html`. *Great Tables:* `reference/GT.tab_header.html`.
- **Signatures that fit a phone.** Nim prints a signature wrapped at 80 columns; the page puts
  one argument per line instead, as the guide writes a long call. The effects Nim inferred
  (`raises`, `tags`, `gcsafe`) are left out: they are in the source.
- **The doc comment as written.** Read from the source, so its Markdown stays Markdown, and the
  names it mentions become links.
- **Its counterparts, checked.** A link to gt's and Great Tables' page for the same thing, only
  when that page exists: their reference indexes are read from their repositories, so no link
  leads to a 404. A name that is tabelline's own says *Not from gt*, as the
  [feature map](../../coverage/) does.
- **An example that runs.** The shortest example in the specs that uses the name, folded, run
  while the page builds, with the table it makes. *gt* and *Great Tables:* examples run when
  their site is built, too.

### The look

The page is written with blocks, not HTML, like every page of the site: two new blocks,
`nbApi` for a name's entry and `nbFold` for a fold, with their CSS in `theme.nim`. The page has
no HTML of its own, and the drift check passes.
"""

nbNote """
On 11 November 2026 the page lists 356 names in 15 modules, and 232 have a doc comment.
`tabHeader` and `tabStubhead` are among those without one: the page says *No doc comment yet*,
which is a list of what to write.
""", nkInfo, "The counts"

nbText: """
## Four rounds of review

The page was made on 10 November and reviewed four times on 11 November, on a phone, with
the review mode. Each round asked for something a reference needs, and each answer is now on
the page:
"""

block:
  type Round = object
    round, asked, made: string
  let rows = @[
    Round(round: "ask", asked: "a reference from Nim's own tools, in our style",
          made: "`apidoc.nim` (jsondoc and the source), the page, the block `nbApi`"),
    Round(round: "1", asked: "every name linkable from outside; a table of the modules and their dependencies; Great Tables next to gt; a page in Learn tabelline; modules folded",
          made: "anchors and the **#**, the modules table, `references.nim`, the Reference card, `nbFold`"),
    Round(round: "2", asked: "a table of every name before each fold, grouped by section; what each module exports; the modules table grouped by module",
          made: "the names tables, the *exports* row, the table turned so that it reads on a phone"),
    Round(round: "3", asked: "the table of contents coloured by part; `core` first",
          made: "pink, blue and green parts; the modules in dependency order"),
    Round(round: "4", asked: "each module and each section linked from its table; the modules a module exports again",
          made: "linked groups in both tables, the *exports again* row"),
  ]
  let t = tabella(rows, rownameCol = "round"):
    tabHeader "From the request to the page"
    colsLabel:
      asked: "asked for"
      made: "what it made"
    fmtMarkdown columns = ["asked", "made"]
    optCssTheme()
  nbTable t

nbText: """
## What is still open

- **Verbs as they are written.** A verb's signature starts with `t: sink Tabella`, which a
  reader never writes inside `tabella(data): body`. The page could show the verb as it is
  called there.
- **The weight of the page.** Every example table carries its own CSS, so the page is heavy. A
  change of its own, one table style per page, takes that away.
- **Doc comments.** A third of the names have none yet.

## How it is built

The page reads four places, each with a small tool, and then is written like any other page.

**1. `nim jsondoc`, one module at a time.** `tools/apidoc.nim` runs it on each module a user
imports (the three modules that hold only CLDR data are left out), and keeps the JSON in
`nimcache/apidoc/` under a hash of all of `src/`, so a build runs it only after a change. Each
entry gives a name, a kind, a signature and a line. Two fixes: jsondoc calls a `func` a proc, so
the kind is the signature's first word; and an operator's name comes quoted and HTML-escaped.
"""

nbFoldCode "tools/apidoc.nim", "proc jsondoc(", "func docBlock", "`jsondoc`: run once per change, cached"
nbFoldCode "tools/apidoc.nim", "func cleanSignature", "proc apiModule", "`cleanSignature`: the arguments, not the effects"

nbText: """
**2. The source.** At the line jsondoc gives, the doc comment is the `##` lines that follow the
declaration (a signature can take several lines first). The section is the last `# ----` line
above it. The imports and the re-exports are the `import`, `from` and `export` lines, written in
full: `import core` in `tabelline/verbs` is `tabelline/core`.
"""

nbFoldCode "tools/apidoc.nim", "func docBlock", "func moduleDoc", "`docBlock`: the doc comment of a declaration"
nbFoldCode "tools/apidoc.nim", "func sectionAt", "func cleanSignature", "`sectionAt`: the section of a line"
nbFoldCode "tools/apidoc.nim", "func importsOf", "proc kindName", "`importsOf` and `reexportsOf`"

nbText: """
All of it is an `ApiModule` for each module, with an `ApiSymbol` for each name (its overloads
together). `nim r tools/apidoc.nim` prints it as JSON, for agents. Here is the smallest module:
"""

nbCode:
  let m = apiModule("tabelline/units")
  echo m.name, ": ", m.symbols.len, " names; imports ", m.imports.join(", ")
  for s in m.symbols:
    echo "  ", s.kind, " ", s.name, " (", s.section, ")"

nbText: """
**3. The specs.** Every requirement about the API has an example with what it prints. The page
collects them with `tools/specexamples.nim`, runs them once, and gives each name the shortest
example that uses it.

**4. gt's and Great Tables' indexes.** `tools/references.nim` reads gt's pkgdown configuration
and Great Tables' quartodoc configuration from their repositories, and writes the names they
document to `docs/coverage/references.json` (committed). Two names in Great Tables' index have no
page on its site, and are left out. Rerun it when the feature map is checked for a release.
"""

nbFoldCode "tools/references.nim", "proc names(", "when isMainModule", "`names`: the names of a reference index"

nbText: """
**The page.** `docs/api.nim` puts the modules in dependency order (a module goes when all it
imports is placed), gives each name its anchor, avoiding the ids of the headings, and writes
the tables with tabelline and the entries with `nbApi`. A long signature is cut at its
arguments, at the top-level `;`, one per line.
"""

nbFoldCode "docs/api.nim", "proc dependencyOrder", "let order", "`dependencyOrder`: each module after its imports"
nbFoldCode "docs/api.nim", "proc anchorOf", "var anchors", "`anchorOf`: a link that lasts"
nbFoldCode "docs/api.nim", "func phoneSignature", "proc linked", "`phoneSignature`: one argument per line"

nbText: """
**The fold that opens.** A link to a name inside a closed fold would lead nowhere, so a few lines
of JavaScript, shared by every page, open the folds around the target of the link, when the page
loads and when the link changes.
"""

nbFoldCode "docs/blocks.nim", "function reveal()", "window.addEventListener('hashchange', reveal)", "`reveal`: open the folds around a link's target", "js"

nbSave
