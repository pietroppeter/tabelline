## devlog: 11 Nov 2026 F | Great tables in every language | R has gt and Python has Great Tables. What do the other languages have? A survey of 28 languages, from C to Gleam, from Zig to the JVM: what makes a display table, the three kinds of table libraries we found, the few that speak gt's grammar (two of them born this year), and why tabelline, being Nim, could reach all the others.
## A dated post: the survey behind tabelline's ports to other languages, and is not updated afterwards.
import std/[os, strutils]
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "polyglot-survey" / "index.html"
nb.useTabelline(title = "Great tables in every language", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026", "Great tables in every language", """
R has gt and Python has Great Tables. What do the other languages have? A survey of 28 languages,
from C to Gleam and from Zig to the JVM: what makes a display table, the three kinds of table
libraries we found, the few that speak gt's grammar, and why tabelline could reach all the others.
"""

nbText: """
Pietro, this morning: "It's so good, the tables, that every language should have a Great
Tables-like library, and at least having a port might mean that others will create it." This
post is the first half of the answer: what the other languages have today. The second half,
[tabelline in eight languages](../polyglot/), is the proofs of concept: tabelline itself, called
from C, Zig, Rust, Julia, Java, Erlang, Gleam and Elixir.

It goes from the simplest to the most complex: what we were looking for, how we looked, the
answer in one table, the languages one by one, the two newcomers that taught us the most, and
what it means for tabelline.
"""

nbNote """
Green cards like the next one are about the code of the tables on this page: how tabelline makes
them. The text tells the story.
""", nkCode

nbText: """
## What we were looking for

Three kinds of library show data in rows and columns, and they are easy to confuse.

- **A printer** lays values out in a grid of characters: borders, padding, alignment, maybe
  colours in a terminal. You give it rows of strings; it gives you text.
- **A grid** is a table to explore, in a browser or a notebook: sort, filter, scroll, edit. AG
  Grid is the best known ([Tabellone](../tabellone/) is about them).
- **A display table** is a table to read, the kind printed in a report or a paper. gt calls the
  idea a grammar: a table is built from named parts (a header, a stub with row groups, spanners
  over the column labels, the body, summary rows, a footer with footnotes and source notes),
  values are *formatted* (numbers, currencies, dates, in a locale), cells are *styled* by where
  they are or by what they hold, and the same table goes to HTML, LaTeX or Word.

The question of this post is the third kind. A library counts if it has gt's parts; it speaks
gt's grammar if it also builds a table the gt way, one verb at a time on named parts.
"""

let kinds = tableData:
  kind: ["printer", "grid", "display table"]
  input: ["rows of strings", "a data frame or rows", "a data frame and verbs"]
  makes: ["text", "a widget to explore", "a table to read"]
  parts: ["borders, a header row", "columns, a header row", "header, stub, row groups, spanners, footnotes, source notes"]
  example: ["libfort, tabled, terminal-table", "AG Grid, TanStack Table", "gt, Great Tables, tabelline"]

block:
  let t = tabella(kinds, rownameCol = "kind"):
    colsLabel:
      input: "Takes"
      makes: "Makes"
      parts: "Its parts"
      example: "For example"
    optCssTheme()
  nbTable t

nbText: """
## How we looked

On 11 November 2026, for 28 languages, we searched GitHub for table libraries (by name,
description and README, the most starred first) and read the READMEs of the ones that looked
closest to gt. We searched for "Great Tables", "inspired by gt", "display tables" and "grammar of
tables" in every language too.

Two limits, said plainly. The sandbox this was written in could not open Julia's Discourse, CRAN
or the package registries' web pages, so what a library does comes from its README, and its
stars from GitHub. And a search finds what is named the way you search: a library that never says
"table" in its description can be missed. If you know one, the review mode of this page (✎ Review)
is the place to say so.

## The answer in one table

Grouped by how close each one is to gt: **gt's grammar** (parts and verbs), **gt's parts** (the
parts, with an API of its own), **printers** and **grids**. Stars are GitHub's, on 11 November;
what each one makes (text, HTML, LaTeX, ...) is in the survey's file.
"""

let survey = readCsv(docs / "devlog" / "data" / "polyglot-survey.tsv", sep = '\t')

block:
  var links: seq[Value]
  for i in 0 ..< survey.nrows:
    links.add toValue("[" & survey["library", i].s & "](" & survey["url", i].s & ")")
  survey.addColumn("lib", links)
  let t = tabella(survey, groupnameCol = "kind"):
    colsHide ["library", "url", "outputs"]
    colsMoveToStart "lib"
    colsLabel:
      lib: "Library"
      language: "Language"
      stars: "Stars"
      note: "Note"
    fmtMarkdown "lib"
    fmtInteger "stars"
    optCssTheme()
  nbTable t

nbNote """
The survey is a TSV file (`docs/devlog/data/polyglot-survey.tsv`) read with `readCsv(sep = '\t')`;
the library's name becomes a Markdown link (a new column, then `fmtMarkdown`), and `kind`
groups the rows (`groupnameCol`), in the order the groups first appear.
""", nkCode

nbText: """
Five libraries speak gt's grammar, and three of them are R and Python's gt and Great Tables and
this site's tabelline. Outside them, gt's grammar lives in two places, both born in 2026: a Typst
package and a JavaScript runtime. Every other language has printers, grids, or a data frame that
can print itself.

## Language by language

**C and C++.** [libfort](https://github.com/seleznevae/libfort) (two files to copy into a project)
and [tabulate](https://github.com/p-ranav/tabulate) for C++ draw text tables with borders,
alignment and cell styles. No formats, no parts beyond a header row.

**Zig.** [prettytable-zig](https://github.com/dying-will-bullet/prettytable-zig), a port of Rust's
prettytable, and the pretty-table module of zigcli: text, with Unicode widths done right.

**Rust.** Does Rust have anything like gt? No. [tabled](https://github.com/zhiburt/tabled) (2,372
stars) prints structs and enums as tables with a derive macro, and a companion crate turns its
tables into plain HTML; [comfy-table](https://github.com/Nukesor/comfy-table) wraps terminal tables
to the screen and is now in a feature freeze while it looks for a maintainer. Both are excellent
printers. There is no crate with a header and a stub, spanners, `fmt_currency` or footnotes, and
the crate name `gt` belongs to an unrelated database helper.

**Go.** [tablewriter](https://github.com/olekukonko/tablewriter) and
[go-pretty](https://github.com/jedib0t/go-pretty) are the most starred printers of the survey, and
both write HTML and Markdown too. They merge cells and sort rows; they don't format or style by
location.

**Gleam.** Four small libraries: [tobble](https://github.com/ollien/tobble) ("does not aim to be a
full layout library"), trellis, gtabler and fabulous. All text, all young, all with Gleam's
builder pipes, which is what a display table in Gleam would look like too.

**Elixir and Erlang.** [table_rex](https://github.com/djm/table_rex) and scribe print text
tables; Livebook shows data frames as an interactive table (`Kino.DataTable`), a grid. Nothing
in Erlang itself.

**Ruby.** [terminal-table](https://github.com/tj/terminal-table) and
[tabulo](https://github.com/matt-harvey/tabulo): text tables, column spans, many options.

**Julia.** The closest of all. [PrettyTables.jl](https://github.com/ronisbr/PrettyTables.jl)
draws a table with gt's sections (title, subtitle, row group labels, column labels with merged
spanners, summary rows, footnotes, source notes) to text, HTML, LaTeX, Markdown and Typst, and
says its design "is heavily inspired by the R package gt, but the API is quite different".
[SummaryTables.jl](https://github.com/PumasAI/SummaryTables.jl) makes the tables of clinical
reports (table one, listings) in HTML, docx, LaTeX and Typst. What Julia lacks is the grammar: a
table built one verb at a time, `fmt_*` on chosen columns, styles on named locations.

**The JVM.** [Tablesaw](https://github.com/jtablesaw/tablesaw) and
[Kotlin DataFrame](https://github.com/Kotlin/dataframe) print and render data frames, Kotlin's to
HTML with formats; [picnic](https://github.com/JakeWharton/picnic) builds HTML-like tables in a
Kotlin DSL and draws them as text. Nothing like gt on the JVM.

**And the rest.** C# has [Spectre.Console](https://github.com/spectreconsole/spectre.console)'s
table widget; Swift, Crystal, V and Lua have text printers; Haskell has tabular and colonnade,
OCaml [printbox](https://github.com/c-cube/printbox) (text and HTML); Clojure's Clerk has a table
viewer; JavaScript and TypeScript have the grids (AG Grid, TanStack Table), and many components
for one framework or another, but no display-table grammar of their own.

## Two newcomers

Two libraries are new this year, and both chose a shape worth learning from.

**[keisen](https://github.com/mcanouil/keisen)** (Typst, August 2026) "implements the
display-table grammar in a declarative API for Typst documents, inspired by gt and great_tables".
A table is one call, `display-table(data, ...)`, and every part or format is an argument:
`table-header`, `table-stub`, `columns-label`, `table-spanner`, `format-currency`,
`summary-rows`, `table-style` at `cells-body(columns: ..., rows: row => ...)`, `data-colour`,
`table-footnote`. In a language with no pipes and no mutation, gt's verbs became a list of values.
It even ships an `llms.txt` for coding agents, as tabelline does.

**[lt](https://github.com/yihui/lt)** (R, May 2026), by Yihui Xie, is "lightweight tables for R,
inspired by gt and DT". The R side writes a JSON spec ("titles, column spanners, row groups,
footnotes, and number formatting"), and one small vanilla JavaScript file builds the table from
it in the browser. The table is data; the renderer is one tiny runtime that any language could
feed.

Both say the same thing from two sides: gt's grammar does not need R. It needs a way to say the
parts and the verbs (keisen: arguments; lt: JSON) and one renderer.

## What it means for tabelline

tabelline is written in Nim, and Nim compiles to C. A Nim library can be a C library: a `.so`,
a `.dylib` or a `.dll` with a C header, the one thing every language on this list can call. So
the shortest way to a display table in Rust, Zig, Gleam or Java is not a port of gt to each of
them: it is tabelline, once, behind a C ABI, and a thin binding in each language, written in
that language's own style.

A binding is not the end. A Gleam programmer will want a table library written in Gleam, with
Gleam's types; a Rust programmer one with Rust's. But a binding that works shows the grammar in
that language, today, with real tables, and that is how ports start: someone sees it, likes it,
and writes it properly. As lt shows, the shape of the C ABI is almost given: a table as JSON in,
the table out. [tabelline in eight languages](../polyglot/) builds it, and calls it from eight
languages.
"""

nbSave
