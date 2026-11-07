## devlog: 07 Nov 2026 | Day one: from gt to tabelline | Reading gt and Great Tables, deciding to write rather than wrap, and a first tabelline with its specs, its explainer and a notebook look.
## A dated post: it tells the first day as it happened, and is not updated afterwards.
import std/os
import nimib except md
import tabelline, tabelline/[datasets, nimib]
import ../quaderno

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "day-one" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Devlog", classe = "post · 7 November 2026",
               title = "Day one: from gt to tabelline", homeHref = "../")

nbText: """
<p class="kicker">Devlog · 7 November 2026</p>

# Day one: from gt to tabelline

<p class="lede">Reading gt and Great Tables, deciding to write rather than wrap, and a first
tabelline with its specs, its explainer and a notebook look.</p>

The request was short: *let's make great tables for Nim*. The name was already picked,
**tabelline**, the times tables of Italian primary school, and the repository already made.
The rest of this post tells the first day.

## Reading first

The first step was not code but reading. Both [gt](https://github.com/rstudio/gt) and
[Great Tables](https://github.com/posit-dev/great-tables) are open source, so we cloned them and
read how they are built rather than how they are documented. Three things stood out:

1. A table is **two layers**: the data, and a spec of how to show it, split into one small
   structure per concern (boxhead, heading, spanners, stub, formats, styles, options...).
2. **Nothing is computed until the end.** Verbs record; `build_data()` formats, orders and
   numbers the footnotes when the table is printed.
3. The **HTML** is one `<div>` per table with its own `<style>`, every rule prefixed by the
   table's id, from one stylesheet template where every option is a variable.

We also read about how people use them, mostly through the Posit
**Table Contest** (2020-2025): editable Shiny tables, Spotify dashboards, airline fleets, pixel
art, and a great deal of pharma. The explainer has the details.

## Write, don't wrap

Wrapping R or Python would bring an interpreter into every Nim program, and there is no hard
kernel to reuse: the value of gt is its design and its catalogue of use cases. So tabelline is
written in plain Nim, with no dependencies in the core, and it borrows gt's design and names
(in camelCase: `tab_header` is `tabHeader`), so that gt's documentation can be read as ours.

The choices of the day, in one table:
"""

nbCode:
  let choices = tableData:
    topic: ["data", "spec", "verbs", "labels", "selectors", "locations", "options", "recipes"]
    choice: ["columns of a Value variant, in a ref (never copied)",
             "a plain Tabella value: boxhead, parts, formats, styles, options",
             "procs that take a Tabella and return one, with sink, so chains move",
             "Text: plain, md() or html(), with a converter from string",
             "ColSel and RowSel, with where(it[\"col\"] > 1) for rows",
             "loc.body(...) and style.fill(...), namespaces as in Great Tables",
             "TabOptions with Nim 2 default fields, set by the tabOptions macro",
             "tabella(data): body, a macro that applies one verb per line"]
    instead: ["a generic typed column per type", "R's list of data frames, Python's frozen dataclass",
              "R's pipe, Python's method chain", "gt's md() and html()", "tidyselect, Polars selectors",
              "gt's cells_body()", "tab_options() with ~200 arguments", "none: R and Python have no macros"]
  let choicesTable = tabella(choices, rownameCol = "topic"):
    tabHeader "Design choices of day one", "and what gt and Great Tables do instead"
    colsLabel {"choice": "tabelline", "instead": "gt / Great Tables"}
    tabStyle style.text(color = "#5E6475", size = "90%"), loc.body(cols = "instead")
    optQuaderno()
  nbTable choicesTable

nbText: """
## What got built

By the end of the day, the library (about 1,800 lines of Nim in `src/`) had the six parts of a
table, eleven formatters and a small bar, styles at locations, colours by value, forty options
and four presets, and three renderers sharing one build step: HTML, text (so `echo t` draws the
table) and Markdown (so nimib's Markdown backend works). And a block for nimib, `nbTable`.

The first table it drew is the one every Italian pupil knows:
"""

nbCode:
  echo tabella(tavolaPitagorica(5), rownameCol = "×").tabHeader("La tavola pitagorica")

nbText: """
## Specs that run

The repository follows the setup of a few of Pietro's other projects:
[OpenSpec](https://github.com/Fission-AI/OpenSpec) specs in `openspec/`, a backlog, a changelog,
living documents and this devlog, all built by CI as nimib notebooks.

The twist here is that every requirement about the API has an example: Nim code followed by what
it prints. Since `echo` draws a table, an example shows its table in plain text, and
`tools/specexamples.nim` runs all of them in one program and fails if an output changes. The
[specs page](../../specs/) runs them again while it is built and shows, next to each example,
the HTML table it makes. On day one: 8 specs, 28 requirements, 22 examples, all passing.

## A notebook look

The pages are dressed as an Italian exercise book: squared paper with a red margin, the label on
the cover (*nome*, *materia*, *classe*), headings in blue pen over a highlighter stroke, code on
index cards, output on sticky notes, and tables pasted in with a strip of tape. The fonts (Patrick
Hand and Atkinson Hyperlegible) are inlined, so each page is one file that works offline.

## Next

Summary rows are the first open change (`openspec/changes/add-summary-rows`). After that, from the
backlog: nanoplots, more formats, column merges, interop with nanuq and datamancer, LaTeX output,
and a gallery.
"""
nbSave
