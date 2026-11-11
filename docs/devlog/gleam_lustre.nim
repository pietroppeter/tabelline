## devlog: 11 Nov 2026 I | tabelline in a Lustre app | The plan of *tabelline in the browser, from Gleam*, built: tabelline passes its tests under `nim js`, a build can leave out the icons and the datasets, Gleam's binding runs on both its targets with the same HTML, a table is a Lustre element, and a demo with two tables that build again at every change. What was built, the three bugs the tests found, what it weighs, and how it is built.
## A dated post: what the thread "Build tabelline for Gleam in the browser" built, and is not updated afterwards.
import std/os
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
let shots = docs / "devlog" / "data" / "gleam-lustre"
nbInit
nb.doc.filename = docs / "devlog" / "gleam-lustre" / "index.html"
nb.useTabelline(title = "tabelline in a Lustre app", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026", "tabelline in a Lustre app", """
The research post *tabelline in the browser, from Gleam* ended with a plan of five steps. This
is the plan, built: tabelline passes its tests under `nim js`, a build can leave out the icons and
the datasets, Gleam's binding runs on both its targets with the same HTML, a table is a Lustre
element, and a demo with two tables that build again at every change. What was built, the three
bugs the tests found, what it weighs, and how it is built.
"""

nbToc()

nbText: """
## Try it

[The demo](https://claude.ai/artifact/DXJQBmhiJBnUpoo8Vi29UN) is one HTML file (on
[GitHub Pages](https://pietroppeter.github.io/tabelline-polyglot/) once it is merged). Two
tables, built again by tabelline, in the page, at every change:

- **the planets**, the table every port of tabelline draws: change its title, its locale, the
  decimals of the mass, the palette of the moons and the line above which they are bold, and
  draw it as HTML, text or Markdown;
- **a dataset**: pick one of the eight that come with tabelline (`gtcars`, `countrypops`,
  `isole`...) and how many of its first and last rows to show, as gt's `gt_preview()` does.
"""

nbScreenshot shots / "planets.jpg", shots / "none.json", "The planets in Italian, one decimal, viridis: 7.7 ms"
nbScreenshot shots / "dataset.jpg", shots / "none.json", "The first four and the last of the 194 islands"

nbText: """
## The plan, step by step

The research post planned five steps. Here is where each one is.
"""

block:
  type Step = object
    step, where, what: string
  let rows = @[
    Step(step: "1. Tests under `nim js`", where: "tabelline",
         what: "`tests/js.nim`, every test but nimib's, compiled by `nim js` and run in Node, in CI. Five fixes."),
    Step(step: "2. A lean build", where: "tabelline",
         what: "two defines that leave the icons and the datasets out of a build; what is left out says so. `tests/lean.nim`, in C and in JavaScript."),
    Step(step: "3. Gleam on both targets", where: "tabelline-polyglot",
         what: "`js/` (the export) and the Gleam package of the typed API, with JavaScript beside Erlang; `tabelline_lustre`; the port `gleam-js` prints the same HTML as Nim."),
    Step(step: "4. The demo", where: "tabelline-polyglot",
         what: "`lustre/demo/`: the planets and a dataset the reader picks, built into one file by CI and published on Pages."),
    Step(step: "5. A post", where: "tabelline", what: "this one.")]
  let t = tabella(rows, rownameCol = "step"):
    tabHeader "Five steps", "from the research post's plan"
    colsLabel:
      where: "where"
      what: "what was built"
    tabStubhead "step"
    fmtMarkdown ["step", "what"]
    optCssTheme()
  nbTable t

nbText: """
## What the tests found

The research post fixed two things and drew one table, the planets, with the same HTML as Nim.
Running all of tabelline's tests under `nim js` found three more: every test passed in C, and
three of them failed in Node.
"""

block:
  type Fix = object
    what, why, fix: string
  let rows = @[
    Fix(what: "a file name for an image", why: "a browser has no files: `fileExists` and `readFile` do not compile",
        fix: "under JavaScript a file name raises a `ValueError`; an address works (research post)"),
    Fix(what: "a big `const` string", why: "`nim js` writes it out again at every use: the locales' lookup hung, and the icons made 18 MB",
        fix: "bound once with `let` (research post)"),
    Fix(what: "`formatNumber(2.25, 1)` was 2.3", why: "JavaScript's `toFixed` rounds a tie up; C's `printf` rounds it to the even digit, 2.2",
        fix: "`fixed(x, decimals)` finds a tie from the number's exact digits, and rounds it to even"),
    Fix(what: "`colsAlignDecimal` padded nothing", why: "it changed each cell through a `ptr string`, and under JavaScript the change was lost",
        fix: "an iterator that yields each cell as a `var string`"),
    Fix(what: "two tests that write a file", why: "no files under JavaScript",
        fix: "a branch `when defined(js)` that checks what JavaScript can do instead")]
  type Row = object
    what, why: string
  var told: seq[Row]
  for r in rows: told.add Row(what: r.what, why: r.why & ". **Fix:** " & r.fix & ".")
  let t = tabella(told, rownameCol = "what"):
    tabHeader "Five things", "that broke under nim js, and their fixes"
    colsLabel:
      why: "why, and the fix"
    colsWidth:
      what: "34%"
    tabStubhead "what broke"
    fmtMarkdown everything()
    optCssTheme()
  nbTable t

nbText: """
The tie is the one that matters most: tabelline's promise is the same output on every backend,
byte for byte, and 2.25 to one decimal is the kind of number a table shows. The fix, in
`formats.nim`:

```nim
func fixed*(x: float, decimals: int): string =
  when defined(js):
    result = $toFixedJs(x, decimals)
    let exact = $toFixedJs(x, decimals + 30)   # the double's exact digits
    let cut = exact.len - 30
    if exact[cut] != '5' or exact[cut + 1 .. ^1].anyIt(it != '0'): return   # not a tie
    # a tie after an even digit: keep the digit (toFixed rounded it up)
    ...
  else:
    formatFloat(x, ffDecimal, decimals)
```

A double is a binary fraction, so it has a finite decimal expansion, and `toFixed` writes it
exactly when asked for enough digits: 2.25 is `2.250000...`, a tie; 2.35 is
`2.350000000000000088...`, not one, and rounds up on both backends.

## What it weighs

A program compiled by Nim keeps only what it uses. A binding that can call every verb from JSON
uses everything, so the icons and the datasets are in it unless the build leaves them out: two
defines, both on by default, on every backend.
"""

block:
  type Weight = object
    build: string
    minified, gzipped: float
  let rows = @[
    Weight(build: "everything", minified: 3695, gzipped: 850),
    Weight(build: "with the datasets, without the icons (the demo)", minified: 2247, gzipped: 370),
    Weight(build: "without either (`js/build.nim`, the default)", minified: 1807, gzipped: 258)]
  let t = tabella(rows, rownameCol = "build"):
    tabHeader "tabelline for JavaScript", "in KB, minified by esbuild"
    fmtMarkdown ["build"]
    colsLabel:
      minified: "minified"
      gzipped: "gzipped"
    fmtNumber ["minified", "gzipped"], decimals = 0
    tabSourceNote "Nim 2.2.4, esbuild 0.25, gzip -9. The demo page, with Gleam's runtime, Lustre and the app, weighs 2.3 MB, 392 KB gzipped."
    optCssTheme()
  nbTable t

nbText: """
```nim
const tabellineIcons* {.booldefine.} = true
const fontawesomeTsv = when tabellineIcons: staticRead("data/fontawesome.tsv") else: ""
```

What is left out says so: `fmtIcon` raises *no icons in this build (-d:tabellineIcons=false)*,
and `gtcars()` *the dataset gtcars is not in this build (-d:tabellineDatasets=false)*. The rest,
locales included, is the same.

## Gleam, on both targets

The Gleam package is the typed API of the polyglot repository: a table of your own records,
columns read from them, formats, styles and errors as Gleam types. It had one function written
in Erlang that the JavaScript target needed: `render`, and the three that write JSON numbers
and strings. Each now has a JavaScript twin beside it:

```gleam
@external(erlang, "tabelline_ffi", "render")
@external(javascript, "./tabelline_ffi.mjs", "render")
fn render_spec(spec: String, format: String) -> Result(String, String)
```

On the JavaScript side a Gleam `Float` is a JavaScript number, and `JSON.stringify(2.0)` is
`2`: tabelline would read an integer. `json_float` writes a whole float with its `.0`, as Erlang
does, and a test says so. Then the same `planets.gleam` prints the same HTML on both targets,
and `tools/polyglot.nim` checks it as a fourteenth port, `gleam-js`.

The demo needed two things the API did not have: a table from a dataset, and a preview.

```gleam
tabelline.from_dataset(Gtcars)
|> tabelline.preview(top: 5, bottom: 1)
|> tabelline.to_html
```

`from_dataset` gives a `Table(Nil)`: its columns are the dataset's. In the spec it is
`{"dataset": "gtcars"}`, and the spec reads all eight datasets now, each once: `countrypops`
takes 200 ms to parse in JavaScript, too long to wait at every change of a slider.

## A table is a Lustre element

`tabelline_lustre` is a package of its own, so that `tabelline` keeps no dependencies. It has
four functions:

```gleam
pub fn view(table: Table(row)) -> Element(msg) {
  view_with(table, [])
}

pub fn view_with(table: Table(row), attributes: List(Attribute(msg))) -> Element(msg) {
  case tabelline.to_html(table) {
    Ok(drawn) ->
      element.unsafe_raw_html("", "div", [attribute.class("tabelline"), ..attributes], drawn)
    Error(error) -> problem(error)
  }
}
```

and `view_text`, `view_markdown`, which put the table in a `pre`. A table that cannot be drawn is
a paragraph that says why. An app never sees `unsafe_raw_html`: tabelline escapes every value it
writes, so its HTML can go in the page as it is.

The demo's `view` is then two calls, one for each table, and the model is the controls: a
title, a locale, a number of decimals, a `Palette`, a number of moons, an `Output`, a `Dataset`
and two numbers of rows. Every choice is a Gleam type, so a drop-down is a list of typed values
and their names.

```gleam
fn view(model: Model) -> Element(Msg) {
  html.main([class("page")], [
    section("The planets", planet_controls(model), draw(planets_table(model), model)),
    section("A dataset", dataset_controls(model), draw(dataset_table(model), model)),
  ])
}
```

(Simplified: the demo also times each table.)

## How it is built

`nim r lustre/demo/build.nim`, in tabelline-polyglot, does four things:

1. `nim r js/build.nim --datasets` compiles `js/tabelline_js.nim` with `nim js -d:release
   -d:tabellineIcons=false -d:tabellineDatasets=true`, and writes it as an ES module into the Gleam
   package, `gleam/src/tabelline_nim.mjs` (not committed).
2. `gleam build` in `lustre/demo/` compiles the app, `tabelline`, `tabelline_lustre`, Lustre and
   Gleam's standard library to JavaScript modules.
3. esbuild follows the imports from `entry.mjs` and writes one minified script.
4. The script goes in `page.html`, which holds the style: one file, `dist/index.html`.

CI runs the same build (`.github/workflows/demo.yml`), tests the Gleam package in Node first
(`gleam test --target javascript`), and on `main` publishes the page on GitHub Pages. In
tabelline, CI runs the tests under JavaScript and the lean build at every push, so the
JavaScript backend stays working.

## What is next

Lustre's server components, with the NIF on the BEAM: the same `tabelline_lustre.view`, drawn
on a server. And the Gleam package on Hex, with the JavaScript build of tabelline inside it,
so `gleam add tabelline` is all a user does, on either target.
"""

nbSave
