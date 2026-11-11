# tabelline

> *Le tabelline*: the times tables of Italian primary school. Here: great tables for Nim.

**tabelline** makes display tables in Nim: tables meant to be read by people, with a header, a
stub, row groups, spanners over columns, formatted numbers, colours and notes. It follows R's
[gt](https://gt.rstudio.com) and Python's [Great Tables](https://posit-dev.github.io/great-tables/),
with their parts and their verbs (in camelCase), written in plain Nim, and fits in
[nimib](https://github.com/pietroppeter/nimib) notebooks.

**Site:** [pietroppeter.github.io/tabelline](https://pietroppeter.github.io/tabelline/), with
the [Guide](https://pietroppeter.github.io/tabelline/explainer/), the
[stories](https://pietroppeter.github.io/tabelline/stories/), the
[book](https://pietroppeter.github.io/tabelline/book/), the
[roadmap](https://pietroppeter.github.io/tabelline/roadmap/), the
[devlog](https://pietroppeter.github.io/tabelline/devlog/) and the
[specs](https://pietroppeter.github.io/tabelline/specs/).

```nim
import tabelline, tabelline/datasets

let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  tabHeader md("The **planets**"), "of the Solar System"
  colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
  tabSpanner "Size", ["mass", "diameter"]
  fmtNumber "mass", decimals = 3, dropTrailingZeros = true
  fmtInteger "diameter"
  tabFootnote "As of 2024.", loc.columnLabels("moons")
  tabSourceNote "NASA Planetary Fact Sheet"
echo t                 # a text table, below
t.save "planets.html"  # the HTML table, standalone
```

```
              The planets
          of the Solar System
┌─────────┬───────┬──────────┬─────────┐
│         │       Size       │         │
│         │  mass │ diameter │ moons^1 │
╞═════════╪═══════╪══════════╪═════════╡
│ Terrestrial                          │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┤
│ Mercury │  0.33 │    4,879 │       0 │
│ Venus   │  4.87 │   12,104 │       0 │
│ Earth   │  5.97 │   12,756 │       1 │
│ Mars    │ 0.642 │    6,792 │       2 │
├─────────┼───────┼──────────┼─────────┤
│ Gas giant                            │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┤
│ Jupiter │ 1,898 │  142,984 │      95 │
│ Saturn  │   568 │  120,536 │     146 │
├─────────┼───────┼──────────┼─────────┤
│ Ice giant                            │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┄┄┤
│ Uranus  │  86.8 │   51,118 │      28 │
│ Neptune │   102 │   49,528 │      16 │
└─────────┴───────┴──────────┴─────────┘
1 As of 2024.
NASA Planetary Fact Sheet
```

The same verbs chain, too: `tabella(planets()).tabHeader("The planets").fmtNumber("mass")`.
In a nimib notebook, `import tabelline/nimib` and `nbTable t`.

## Stories

Real subjects told in tables made with tabelline, at least one for every release, kept up to date
([all the stories](https://pietroppeter.github.io/tabelline/stories/), sources in `docs/stories/`);
the home page shows them as a gallery:

- [Milano Cortina 2026, in small numbers](https://pietroppeter.github.io/tabelline/stories/milano-cortina/)
  (tabelline 0.1): the 2026 Winter Olympics and Paralympics in three parts of three (the Games,
  the money, what stays), learning from Il Post's coverage, on data from Wikipedia, Il Post and NOAA.
- [FOSDEM's data, made with nanuq](https://pietroppeter.github.io/tabelline/stories/fosdem-data/)
  (tabelline 0.1): how the data of the FOSDEM story was made, from five kinds of web page to ten
  tidy tables with nanuq (Polars for Nim): the nanuq code, what nanuq did well and where it
  pinched, the schema of every table, and checks that run when the page is built.
- [FOSDEM, twenty-six times](https://pietroppeter.github.io/tabelline/stories/fosdem/)
  (tabelline 0.2, written in R with gt until 0.2 and 0.3 are built): the editions, the devrooms
  and the people of FOSDEM from 2001 to 2027, on FOSDEM's own schedules, read with nanuq.

## The site

The home page groups the pages by the question a reader brings. They are kept up to date as
tabelline changes; dated posts are in the devlog.

**Learn tabelline**

1. [Guide](https://pietroppeter.github.io/tabelline/explainer/) (*The Great Explainer*): what gt
   and Great Tables are, how they work inside, who uses them (the Posit Table Contest and more),
   and tabelline step by step.
2. [Book](https://pietroppeter.github.io/tabelline/book/): guides and examples of gt and Great
   Tables redone in Nim, with the original code and its table next to every example, [what
   the book will port](https://pietroppeter.github.io/tabelline/book/next.html), [an example for
   every feature](https://pietroppeter.github.io/tabelline/book/features.html), [the Table Contest
   entries](https://pietroppeter.github.io/tabelline/book/contest.html) and [what the port
   found](https://pietroppeter.github.io/tabelline/book/gaps.html) missing. Its sources are in
   `book/` (see [The book](#the-book) below).
3. [Reference](https://pietroppeter.github.io/tabelline/api/): every name tabelline exports, from
   the source: its signature, doc comment, gt and Great Tables names, and an example that ran,
   with a table of the modules and what they import. Each name has a link of its own
   (`api/#verbs-tabHeader`, or `api/#tabHeader`).

**Where it's going**

4. [Roadmap](https://pietroppeter.github.io/tabelline/roadmap/): what each release from 0.1 to 0.5
   adds and the real tables it is tried on, with the three threads of each (build it, use it,
   port the references), from `docs/piano.nim`.
5. [Feature map](https://pietroppeter.github.io/tabelline/coverage/): every feature group of gt
   and Great Tables, whether tabelline has it, and the release that plans the rest (data in
   `docs/coverage/gt.json`).

**How it's made**

6. [Devlog](https://pietroppeter.github.io/tabelline/devlog/): dated posts, newest first.
7. [Specs](https://pietroppeter.github.io/tabelline/specs/): how tabelline behaves today, written
   down with [OpenSpec](https://github.com/Fission-AI/OpenSpec) in `openspec/`, with examples that
   run against the code while the page is built.
8. [Design guide](https://pietroppeter.github.io/tabelline/design/): the two looks, the shapes, the
   colours, the type and every component, with when to use each.
9. [For coding agents](https://pietroppeter.github.io/tabelline/agents/): setup, commands, where
   things are, and the rules from AGENTS.md; also [llms.txt](https://pietroppeter.github.io/tabelline/llms.txt).

Posts, dated, and not rewritten afterwards, though they take edits (posts of the same day take a letter, A, B, C, ...):

- [Designing tabelline 0.2](https://pietroppeter.github.io/tabelline/devlog/designing-0-2/)
  (10 Nov 2026 A): 0.2 takes in 0.3 and 0.4, in five groups, each from zero with its choices;
  written while 0.2 is built.
- [Review mode](https://pietroppeter.github.io/tabelline/devlog/review-mode/)
  (9 Nov 2026 A): select text on a page, comment on it, go through the comments with a bar at the
  bottom, and export them as Markdown with a YAML block for an agent. Every page of the site has
  it now, with its version from git; the post is reviewed with itself, round by round.
- [Rethinking tabelline's datasets](https://pietroppeter.github.io/tabelline/devlog/datasets/)
  (8 Nov 2026 E): the three ways to make a dataset, the datasets tabelline uses and where they come
  from, the ones gt and Great Tables show first, and a brainstorm of three domains in three sizes
  (a twin for gt's best known datasets, the islands of the Mediterranean, World Heritage per person); a
  draft to decide from.
- [Blocks, not HTML](https://pietroppeter.github.io/tabelline/devlog/blocks-review/)
  (8 Nov 2026 D): how much HTML, CSS and colour the pages write by hand (measured at build), the
  custom blocks that would replace it (a gallery block works already, `docs/blocks.nim`), where
  styles and colours should live, and what a nimib skill should teach against the drift.
- [Reviewing the design: a palette by roles](https://pietroppeter.github.io/tabelline/devlog/design-review/)
  (8 Nov 2026 C): what the pages' six colours do today, shape apart from colour, a palette by roles (neutral, primary,
  secondary, status, data) for both looks, every component mapped to it, and six choices to make
  before it becomes the new Design Ref.
- [What the book found for 0.1](https://pietroppeter.github.io/tabelline/devlog/book-found/)
  (8 Nov 2026 B): what porting the Great Tables guide into the book found, and 0.1 fixed.
- [Designing tabelline 0.1](https://pietroppeter.github.io/tabelline/devlog/designing-0-1/)
  (7 Nov 2026 F): the 24 small groups of gt in 0.1, how each became an OpenSpec change, R vs
  Python vs Nim, and the Nim sugar.
- [Three threads for every release](https://pietroppeter.github.io/tabelline/devlog/three-threads/)
  (7 Nov 2026 E): how tabelline will grow from 0.1 to 0.5, after nanuq: build it, use it on real
  data, port reference code, with Nim, Python and R in tabs.
- [Munari meets Japan: palettes for the second look](https://pietroppeter.github.io/tabelline/devlog/palettes/)
  (7 Nov 2026 D): softer colours for the Munari look, from Japan's traditional colour names: what
  each of its six colours does, six palettes to swipe through, the page part by part, and the
  stories behind the names.
- [Two looks: the quaderno and Munari](https://pietroppeter.github.io/tabelline/devlog/two-looks/)
  (7 Nov 2026 C): a second look for the pages, after Bruno Munari, one switch away in every header.
- [Tabellone: when a table becomes a grid](https://pietroppeter.github.io/tabelline/devlog/tabellone/)
  (7 Nov 2026 B): what a data grid is (AG Grid and friends), why gt and Great Tables are not
  grids, whether tabelline should have a big brother, and a small working sketch.
- [Day one: from gt to tabelline](https://pietroppeter.github.io/tabelline/devlog/day-one/) (7 Nov 2026 A):
  reading gt and Great Tables, deciding to write rather than wrap, and a first tabelline.

## Files

- `src/tabelline.nim`: the module to import, with two of the three macros (`tabella(data): body`, `tableData:`; `tabOptions` is in `verbs.nim`).
- `src/tabelline/core.nim`: the data model (`Value`, `TableData`, `Text`, selectors, styles, `Tabella`).
- `src/tabelline/formats.nim`: value formatting and the `fmt*` / `sub*` verbs.
- `src/tabelline/units.nim`: units and chemical formulas in gt's notation (`fmtUnits`, `fmtChem`, `colsUnits`).
- `src/tabelline/countries.nim`, `locales.nim`, `currencies.nim`: country names, the conventions of 657 locales and 305 currencies, from Unicode CLDR 49, written once by `tools/cldr.nim` (licence in `licenses/`). `src/tabelline/localize.nim` reads them (`getLocale`, `currencyInfo`, `formatPattern`).
- `src/tabelline/pictures.nim`: icons (`fmtIcon`, every Font Awesome Free icon, from `data/fontawesome.tsv`, written by `tools/fontawesome.nim`; licence in `licenses/`) and images (`fmtImage`, inlined as data URLs).
- `src/tabelline/nanoplots.nim`: nanoplots (`fmtNanoplot`, `colsNanoplot`), a port of Great Tables' SVG, and sparklines in text.
- `src/tabelline/verbs.nim`: `tab*`, `cols*`, locations, `dataColor`, options and `opt*` presets.
- `src/tabelline/colors.nim`: palettes, interpolation, text contrast.
- `src/tabelline/build.nim`: the build step all renderers share. `src/tabelline/extract.nim`: the built table as data (`extractCells`, `extractBody`, `extractSummary`).
- `src/tabelline/render_html.nim`, `render_text.nim`: HTML (scoped CSS), text and Markdown.
- `src/tabelline/nimib.nim`: the `nbTable` block. `src/tabelline/datasets.nim`: `planets`, `exibble`, `tavolaPitagorica`, `isole`, `citta` (the last two from `src/tabelline/data/`).
- `tests/`: `nim r tests/all.nim`. `tools/specexamples.nim`: runs the examples of the specs.
- `docs/`: the pages, as nimib notebooks (`docs/all.nim` builds them all; `docs/theme.nim` is the style of both looks, from the tokens, and `docs/blocks.nim` the blocks every page is made of; `docs/review.nim` is the review mode, blocks and styles in one module that can move to nimib).
- `book/`: the tabelline book, a [nimibook](https://github.com/pietroppeter/nimibook) (see below).
- `openspec/`: specs and open changes; `openspec/config.yaml` has the rules. `BACKLOG.md`, `CHANGELOG.md`, `AGENTS.md`.

## Building

```sh
sh tools/setup.sh                # once: what is missing (Nim, atlas, libpcre3) + deps from atlas.lock
nim r tests/all.nim              # tests
nim r tools/specexamples.nim     # the examples of the specs
nim r -d:release docs/all.nim    # every page, into docs/
nim r book/bookbuild.nim         # the book, into docs/book/ (only the chapters that changed)
```

With Nim and atlas already installed, `atlas rep --feature=docs` is all the setup does on a
laptop. Dependencies are managed with [atlas](https://github.com/nim-lang/atlas): nimib is the
`docs` feature of `tabelline.nimble`, pinned in `atlas.lock`, cloned into `deps/`, and `nim.cfg`
puts it on the path. AGENTS.md has how to change a dependency.

The library itself needs only Nim (2.2 or later) and its standard library. CI
(`.github/workflows/pages.yml`) runs the tests and the examples, builds the pages and deploys them
to GitHub Pages from `main`.

## The book

`book/` is a [nimibook](https://github.com/pietroppeter/nimibook): `book/nbook.nim` has the
table of contents, a chapter is `book/<section>/<page>.nim` (Markdown pages are `.md`), and
`book/tabbook.nim` has the helpers: `attribution` (the box that names the source, its licence
and what the port changed), `tabs` (an example in 👑 Nim next to the original 🐍 Python
and the same in 🏴‍☠️ R with gt), `python` (Python and R with no Nim yet), `sideBySide` (small examples next to each other) and `tabelline` (the book's own remarks). The look is in
`book/theme/` (the Munari look with the Edo palette), the data of the sources in `book/data/`,
their licences in `licenses/`.

`nim r book/bookbuild.nim` builds it into `docs/book/`, the way the Nanuq book does: a chapter
reruns only when a file it depends on changed (the record is in `docs/book/<chapter>.json`), the
stale chapters run as one program, and every page is then rendered from the JSON, so a theme
change reruns nothing. `--force` reruns them all. CI starts from the JSON of the live book.

The Python side runs with Great Tables (the uv project `book/gt/`, `book/gt/run.py`) only when a
chapter's Python changed, and its outputs are committed in `book/gt/outputs/`: building the book
needs [uv](https://docs.astral.sh/uv/) only then. The R side is the same with gt
(`book/gt/run.R`, outputs in `book/gt/outputs-r/`): it needs R with gt, dplyr, tidyr, jsonlite
and knitr only when a chapter's R changed. CI sets `BOOK_NO_PYTHON=1` and `BOOK_NO_R=1`, so a
chapter whose outputs are out of date fails there.

To add a chapter: check the source's licence, write the page with `bookInit()`, `attribution`,
`tabs` and `bookSave()` (see any chapter), add it to `book/nbook.nim` and the source to
`book/licences.md`, and note what tabelline lacks in `book/gaps.md`.

## License

MIT. The datasets: `planets` from NASA's Planetary Fact Sheet (public domain), `exibble` from gt
(MIT). The fonts in `docs/assets/fonts` are under the SIL Open Font License. The book's ported
pages keep the licence of their source (Great Tables: MIT, `licenses/great-tables-MIT.txt`).
