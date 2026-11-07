# tabelline

> *Le tabelline*: the times tables of Italian primary school. Here: great tables for Nim.

**tabelline** makes display tables in Nim: tables meant to be read by people, with a header, a
stub, row groups, spanners over columns, formatted numbers, colours and notes. It follows R's
[gt](https://gt.rstudio.com) and Python's [Great Tables](https://posit-dev.github.io/great-tables/),
with their parts and their verbs (in camelCase), written in plain Nim, and fits in
[nimib](https://github.com/pietroppeter/nimib) notebooks.

**Site:** [pietroppeter.github.io/tabelline](https://pietroppeter.github.io/tabelline/), with the
[explainer](https://pietroppeter.github.io/tabelline/explainer/), the
[specs](https://pietroppeter.github.io/tabelline/specs/) and the
[devlog](https://pietroppeter.github.io/tabelline/devlog/).

> **Status: 0.1, a proof of concept.** It already makes tables worth showing; most of gt is still
> ahead, and the API will change.

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

## Living documents

Kept up to date as tabelline changes:

- [Explainer](https://pietroppeter.github.io/tabelline/explainer/): what gt and Great Tables are,
  how they work inside, who uses them (the Posit Table Contest and more), and tabelline step by step.
- [Specs](https://pietroppeter.github.io/tabelline/specs/): how tabelline behaves today, written
  down with [OpenSpec](https://github.com/Fission-AI/OpenSpec) in `openspec/`, with examples that
  run against the code while the page is built.
- [Coverage map](https://pietroppeter.github.io/tabelline/coverage/): every feature group of gt
  and Great Tables, what tabelline has, and the releases that plan the rest (data in
  `docs/coverage/gt.json`).
- [Devlog](https://pietroppeter.github.io/tabelline/devlog/): the living documents, then the posts.

Posts, dated and not updated afterwards (posts of the same day take a letter, A, B, C, ...):

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

- `src/tabelline.nim`: the module to import, with the two macros (`tabella(data): body`, `tableData:`).
- `src/tabelline/core.nim`: the data model (`Value`, `TableData`, `Text`, selectors, styles, `Tabella`).
- `src/tabelline/formats.nim`: value formatting and the `fmt*` / `sub*` verbs.
- `src/tabelline/verbs.nim`: `tab*`, `cols*`, locations, `dataColor`, options and `opt*` presets.
- `src/tabelline/colors.nim`: palettes, interpolation, text contrast.
- `src/tabelline/build.nim`: the build step all renderers share.
- `src/tabelline/render_html.nim`, `render_text.nim`: HTML (scoped CSS), text and Markdown.
- `src/tabelline/nimib.nim`: the `nbTable` block. `src/tabelline/datasets.nim`: `planets`, `exibble`, `tavolaPitagorica`.
- `tests/`: `nim r tests/all.nim`. `tools/specexamples.nim`: runs the examples of the specs.
- `docs/`: the pages, as nimib notebooks (`docs/all.nim` builds them all; `docs/quaderno.nim` is the theme, `docs/munari.nim` the Munari look laid over it, the default).
- `openspec/`: specs and open changes; `openspec/config.yaml` has the rules. `BACKLOG.md`, `CHANGELOG.md`, `AGENTS.md`.

## Building

```sh
sh tools/setup.sh                # once: what is missing (Nim, atlas, libpcre3) + deps from atlas.lock
nim r tests/all.nim              # tests
nim r tools/specexamples.nim     # the examples of the specs
nim r -d:release docs/all.nim    # every page, into docs/
```

With Nim and atlas already installed, `atlas rep --feature=docs` is all the setup does on a
laptop. Dependencies are managed with [atlas](https://github.com/nim-lang/atlas): nimib is the
`docs` feature of `tabelline.nimble`, pinned in `atlas.lock`, cloned into `deps/`, and `nim.cfg`
puts it on the path. AGENTS.md has how to change a dependency.

The library itself needs only Nim (2.2 or later) and its standard library. CI
(`.github/workflows/pages.yml`) runs the tests and the examples, builds the pages and deploys them
to GitHub Pages from `main`.

## License

MIT. The datasets: `planets` from NASA's Planetary Fact Sheet (public domain), `exibble` from gt
(MIT). The fonts in `docs/assets/fonts` are under the SIL Open Font License.
