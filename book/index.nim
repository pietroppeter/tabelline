import tabbook, sources
bookInit()

nbText: """
# The tabelline book

[tabelline](https://github.com/pietroppeter/tabelline) makes display tables in Nim: tables meant
to be read by people, with a header, a stub, row groups, spanners over columns, formatted
numbers, colours and notes. It follows R's [gt](https://gt.rstudio.com) and Python's
[Great Tables](https://posit-dev.github.io/great-tables/). This book takes their guides and
examples and ports them to tabelline, one page at a time, with the original next to the port.

Every example comes in three tabs: **👑 Nim**, the tabelline version, run when the book is
built, **🐍 Python**, the original Great Tables code with the table it makes, and **🏴‍☠️ R**, the
same table made with gt, written for this book. Pick a tab once and every example follows. The text of the original is kept as it is; what the book has to say
about tabelline (how it differs, what it lacks yet) is in boxes marked **× tabelline**.

## Hello, tables

The times table, *la tavola pitagorica*, the first table every Italian pupil learns:
"""

tabs """
import polars as pl
from great_tables import GT

tavola = pl.DataFrame(
    {"×": list(range(1, 6))} | {str(j): [i * j for i in range(1, 6)] for j in range(1, 6)}
)
GT(tavola, rowname_col="×").tab_header("Le tabelline").tab_stubhead("×")
""", """
library(gt)

tavola <- data.frame(`×` = 1:5, outer(1:5, 1:5), check.names = FALSE)
names(tavola)[-1] <- 1:5

gt(tavola, rowname_col = "×") |> tab_header("Le tabelline") |> tab_stubhead("×")
""":
  nbCode:
    import tabelline, tabelline/datasets

    nbTable tabella(tavolaPitagorica(5), rownameCol = "×")
      .tabHeader("Le tabelline")
      .tabStubhead("×")

tabelline """
`tavolaPitagorica(n)` is one of tabelline's datasets, with `planets` and gt's `exibble`.
"""

nbText: """
## What is here

- **Great Tables: Get Started**: the first section of the
  [Great Tables user guide](https://posit-dev.github.io/great-tables/get-started/), page by
  page, from the parts of a table to styles, themes and selections. *Nanoplots* is left for
  tabelline 0.4, when it gets them.
- **What the book will port**: every source planned, page by page, with what each page needs
  and the release of tabelline that can port it.
- **What the port found**: everything tabelline lacks to do what the guide does, in one list,
  for the next releases. What 0.1 gained from it is told in the devlog,
  [What the book found for 0.1](https://pietroppeter.github.io/tabelline/devlog/book-found/).

## What the book will port

The Get Started guide is the first source; these are the others, from the simplest to the most
complex. For each, how many of its pages tabelline can port now and how many wait for a
release, by the gt functions their code calls; [What the book will port](next.html) has every
page and what it waits for.
"""

nbTable sourcesTable()

nbText: """
Sources still to be mapped, once their pages are listed:
"""

nbTable candidatesTable()

nbText: """
## Sources and licences

Each ported page starts with a box that names its source, its authors and its licence, and says
what the port changed. The sources and their licences are listed in
[Sources and licences](licences.html). The book's own text and code are MIT licensed, as
tabelline.

## How the book is built

From the simplest piece to the whole book.

**A page.** Every page is a [nimib](https://github.com/pietroppeter/nimib) notebook, a Nim
program in `book/`: `bookInit()` starts it, `nbText` writes text, `nbCode` runs Nim and shows
the code with what it prints, `nbTable` (from `tabelline/nimib`) shows a table, and
`bookSave()` writes the page. [nimibook](https://github.com/pietroppeter/nimibook) adds what
makes pages a book: the table of contents (`book/nbook.nim`), the sidebar, the previous and
next buttons, the search.

**A box.** `tabelline "..."` puts the book's own remarks in a box of their own, so the text of
the original stays as it was; `attribution` is the box at the top of a ported page.

**Tabs.** `tabs py, r: body` runs the Nim blocks of `body` and puts them, rendered, in the 👑 Nim
tab, next to two empty tabs for the Python and the R. A small script (`book/theme/book.js`)
shows the tab you pick, in every example, and remembers it. `sideBySide` puts a few small
examples next to each other.

**Python and R.** When a page is saved, its Python cells, all of them in order, go to
`book/gt/run.py`, which runs them with Great Tables in one namespace, like the cells of a
notebook, and gives back what each printed and the HTML of its last value; the R cells go to
`book/gt/run.R`, which does the same with gt. The answers are kept with the cells in
`book/gt/outputs/` and `book/gt/outputs-r/`, which are committed: when the cells have not
changed, they are read from there, and neither Python nor R runs. The tables' random ids are
seeded with the page's name, so the same cells give the same HTML. The code of the three
languages is highlighted when the page is built, so a page loads no highlighter.

**A page as data.** `bookSave()` also writes the page as JSON (`docs/book/<page>.json`): its
blocks, already rendered, and its source.

**Only what changed.** `nim r book/bookbuild.nim` adds to each page's JSON a record of every
file the page depended on, with its hash: what Nim compiled for it (its own list, with
`-d:nimBetterRun`: the page, the helpers, tabelline, nimib, nimibook and the data it reads
while compiling), its Python and R outputs, and the Nim version. A page whose record still
matches is not run again. The pages that changed are compiled as one program, so tabelline and
nimib are compiled once; if that fails, they are built one by one, and a failing page gets its
own log.

**Then every page.** One last pass renders every page from its JSON with the current theme and
table of contents: adding a page or changing the look runs no page again. The look is
nimibook's, with `book/theme/edo.css` (the Munari look in the Edo palette) added to it.

**In CI.** The workflow that publishes tabelline's pages starts from the JSON of the published
book (`BOOK_FROM`), so a pull request runs only the pages it changed; it never runs Python or R
(`BOOK_NO_PYTHON`, `BOOK_NO_R`: a page whose outputs are out of date fails, and says how to
update them). Every change to tabelline reruns every page, so a page that no longer works shows
up in the pull request that broke it. The Great Tables side ran with the version pinned in
`book/gt/uv.lock` (Great Tables 1.1.0), the R side with gt 1.4.0 (R 4.3).
"""

bookSave()
