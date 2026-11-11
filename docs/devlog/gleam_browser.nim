## devlog: 11 Nov 2026 H | tabelline in the browser, from Gleam | Pietro asked whether tabelline could run in a web page with Gleam. It can: tabelline compiled by `nim js`, called from Gleam on its JavaScript target, inside a Lustre app that builds the table again at every change, with the same HTML as Nim. How it works from zero, the two things that broke, what it weighs, the other ways we looked at, and the plan.
## A dated post: the research for running tabelline from Gleam in a browser, and is not updated afterwards.
import std/os
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
let shots = docs / "devlog" / "data" / "gleam-browser"
nbInit
nb.doc.filename = docs / "devlog" / "gleam-browser" / "index.html"
nb.useTabelline(title = "tabelline in the browser, from Gleam", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026", "tabelline in the browser, from Gleam", """
Pietro: "Can we do something which uses the JS backend and runs in a web page? Can we bind Nim JS
to Gleam JS?" Yes. tabelline compiled by `nim js`, called from Gleam on its JavaScript target,
inside a Lustre app that builds the table again at every change, with the same HTML as Nim, byte
for byte. How it works from zero, the two things that broke, what it weighs, the other ways we
looked at, and the plan.
"""

nbToc()

nbText: """
## Try it

[tabelline, in your browser](https://claude.ai/artifact/15qsuyTtVujSYgdkZYzN3h) is one HTML
file. Change the title, the locale, the decimals of the mass, the palette of the moons or the
line above which a number of moons is bold, and the table is built again, in the page, by
tabelline. Nothing goes to a server.
"""

nbBeside:
  nbScreenshot shots / "start.jpg", shots / "start.json", "The page as it opens: the controls (1), the time tabelline took (2), the table (3)"
  nbScreenshot shots / "changed.jpg", shots / "changed.json", "In Italian, with no decimals, viridis, bold above 10 moons: 6.7 ms"

nbText: """
## Three pieces

Three languages meet in the page, each doing what it is good at.

1. **Gleam** describes the table. A table is a plain Gleam value, built with `|>`; nothing runs
   until `render`, which writes it as JSON. This is the binding of
   [tabelline-polyglot](https://github.com/pietroppeter/tabelline-polyglot) (the one that runs
   on the BEAM through a NIF), unchanged.
2. **tabelline**, compiled from Nim to JavaScript, reads that JSON (the same spec the C ABI
   reads, `capi/spec.nim`) and writes the HTML.
3. **[Lustre](https://hexdocs.pm/lustre/)**, Gleam's framework for web apps, puts it in the
   page. A Lustre app is three functions: `init` makes the first model, `update` makes a new
   model from a message ("the user moved the slider"), `view` turns a model into elements. Our
   `view` calls tabelline.

The next three sections build the page in that order, from the bottom: Nim to JavaScript, Gleam
to tabelline, Lustre to the page.

## Nim to JavaScript

`nim js` compiles a Nim program to one JavaScript file. A procedure marked `exportc` keeps its
name there, so other code can call it; a `cstring` is a JavaScript string. Here is all of
`js/tabelline_js.nim`, the JavaScript twin of the C ABI's `tbl_render_spec`:

```nim
import std/[json, jsffi]
import ../capi/spec
import tabelline

proc tabellineRender(spec, format: cstring): JsObject {.exportc: "tabelline_render".} =
  result = newJsObject()
  try:
    let t = tabellaFromSpec(parseJson($spec))
    let output = case $format
      of "", "html": t.toHtml
      of "page": t.toHtml(makePage = true)
      of "text": t.toText
      of "markdown", "md": t.toMarkdown
      else: raise newException(ValueError, "unknown format " & $format)
    result.ok = true
    result.value = cstring(output)
  except CatchableError as e:
    result.ok = false
    result.value = cstring(e.msg)
```

It answers `{ok: true, value: html}` or `{ok: false, value: why}`, so an error comes back as a
value, not as an exception thrown across languages. `nim js` writes a script, not an ES module:
the build appends one line, `export { tabelline_render };`, and the file can be imported.

## What broke under `nim js`

tabelline needs only Nim's standard library, so it compiled almost at once. Two things broke.

**Reading a file.** `fmtImage` reads a local picture to inline it, with `fileExists` and
`readFile`, which a browser does not have. The fix is a branch for JavaScript that says so: a
file name raises an error there, an address (`https://...`) works as before.

**Big strings in a loop.** The first table hung: no output after two minutes. The cause is how
`nim js` writes a `const` string: not once, but again at every place it is used, as a call that
rebuilds it (`makeNimstrLit("...")`). The locales' CLDR values are one const string of 117 KB, used
inside the loop that finds where each value starts: the whole string was built again at every
step of the loop, 117,000 times. The icons are another const string, 1.5 MB, used in five places,
so the file weighed 18 MB. The fix is one line each: bind the string once to a `let`, and use
that.

```nim
when defined(js):
  # The JS backend writes a const string out again wherever it is used.
  let localeText = localeValues
else:
  template localeText: string = localeValues
```

With both fixes the planets table renders in Node in about 7 ms (the first time about 45 ms,
while the engine warms up), and its HTML is the HTML of `nim/planets.nim`, byte for byte.

## Gleam to tabelline

Gleam compiles to Erlang or to JavaScript. A function written in another language is declared
with `@external`, once per target, with the module and the function to call. The binding already
had the Erlang one; the JavaScript one goes beside it, and nothing else changes:

```gleam
@external(erlang, "tabelline_ffi", "render")
@external(javascript, "./tabelline_ffi.mjs", "render")
fn render_spec(spec: String, format: String) -> Result(String, String)
```

`tabelline_ffi.mjs` turns tabelline's answer into a Gleam `Result`, with the `Ok` and `Error`
classes of Gleam's own runtime:

```javascript
import { Ok, Error } from "./gleam.mjs";
import { tabelline_render } from "./tabelline_nim.mjs";

export function render(spec, format) {
  const r = tabelline_render(spec, format);
  return r.ok ? new Ok(r.value) : new Error(r.value);
}
```

One difference between the targets showed up. On the BEAM a `Float` and an `Int` are different
things, and Erlang writes `1898.0` as `1898.0`. In JavaScript both are a number, and
`JSON.stringify(1898.0)` is `1898`: tabelline would read Jupiter's mass as an integer. The
JavaScript side writes a whole float with its `.0`, as Erlang does. Then `gleam run -m planets`,
on the JavaScript target, prints the same HTML as the other eight languages.

## Lustre to the page

The model holds what the controls can change; each control sends a message; `update` puts the
new value in the model. `view` builds the table from the model, renders it, and puts the HTML in
a `div`:

```gleam
fn view(model: Model) -> Element(Msg) {
  let rendered = tabelline.render(planets(model), model.format)
  html.main([], [
    controls(model),
    case rendered {
      Ok(table) -> element.unsafe_raw_html("", "div", [class("output")], table)
      Error(why) -> html.p([class("error")], [text(why)])
    },
  ])
}
```

`planets(model)` is the planets table of the other languages, with the model's values in five
places: `tabelline.locale(model.locale)`, `tabelline.header(model.title, ...)`,
`fmt_number(columns: ["mass"], decimals: model.decimals)`, `data_color(..., palette:
model.palette)` and the `Where("moons", ">", json.int(model.many_moons))` of the bold style.
`unsafe_raw_html` is Lustre's way to put HTML it did not build in the page; its name is a
warning about HTML from users, and tabelline escapes every value it writes.

## What it weighs
"""

block:
  type Weight = object
    build: string
    minified, gzipped: float
  let rows = @[
    Weight(build: "tabelline, everything", minified: 3761, gzipped: 863),
    Weight(build: "without the icons", minified: 2277, gzipped: 372),
    Weight(build: "without the icons and the datasets", minified: 1836, gzipped: 261),
    Weight(build: "Gleam's runtime, the binding, Lustre and the app", minified: 59, gzipped: 20)]
  let t = tabella(rows, rownameCol = "build"):
    tabHeader "What the page downloads", "in KB, minified by esbuild"
    colsLabel:
      minified: "minified"
      gzipped: "gzipped"
    fmtNumber ["minified", "gzipped"], decimals = 0
    tabSourceNote "Measured on 11 November with Nim 2.2.4, Gleam 1.19, Lustre 5.7.1, esbuild 0.25. The two smaller builds turned the icons and the datasets off by hand, to measure them."
    optCssTheme()
  nbTable t

nbText: """
Almost all of it is tabelline, and most of that is data, not code: the 2,000 Font Awesome icons
(1.5 MB), the CLDR locales and the datasets. A program compiled by Nim keeps only what it uses,
but a binding that can call every verb from JSON uses everything. The icons and the datasets can
become choices of the JavaScript build, off unless asked for; the locales stay, since every number
needs them. Gleam and Lustre add 20 KB.

## Other ways we looked at

Before building, four ways to run tabelline for a Gleam web page.
"""

block:
  type Way = object
    way, runs, size, state: string
  let rows = @[
    Way(way: "**`nim js`** (this post)", runs: "in the browser, as JavaScript",
        size: "1.8 to 3.8 MB (260 to 860 KB gzipped)", state: "works: same HTML, 7 ms"),
    Way(way: "**WebAssembly**, Nim through Emscripten", runs: "in the browser, as wasm",
        size: "likely smaller code, the same data", state: "not tried: needs Emscripten; every string is copied in and out of the wasm memory, and tabelline is all strings"),
    Way(way: "**Lustre server components**, with the NIF", runs: "on the BEAM; the browser gets the changes",
        size: "a 14 KB client script", state: "possible today with the Erlang binding; needs a server, so not a page that stands alone"),
    Way(way: "**A tabelline written in Gleam**", runs: "anywhere Gleam runs",
        size: "only Gleam", state: "the long way: the JSON spec and the same-HTML test would be its contract")]
  let t = tabella(rows, rownameCol = "way"):
    tabHeader "Four ways", "to run tabelline for a Gleam web page"
    colsLabel:
      runs: "where it runs"
      size: "what it weighs"
      state: "state"
    tabStubhead "way"
    fmtMarkdown ["way"]
    optCssTheme()
  nbTable t

nbText: """
`nim js` wins for now: it works today, it needs nothing outside Nim and Gleam, it gives the same
HTML as every other language by construction, and the page stands alone, so it can be shown off
anywhere. WebAssembly would not make the data smaller, which is most of the weight. Server
components are the right tool for an app with a server, and come almost free from the NIF
binding: a later step, not this one.

## Thinking like a Gleam programmer

Pietro asked for the Gleam binding to be written thinking like Giacomo Cavalieri, who writes
much of Gleam's tooling and some of its best loved packages. The
[polyglot thread](https://github.com/pietroppeter/tabelline-polyglot) is reworking it that way:
types instead of strings where a value has a few choices, labelled arguments, a table that
cannot be built wrong. For the browser that rework needs only one thing: `render` stays behind
one `@external`, so the JavaScript target is the two lines above. What the browser adds is
small:

- a module `tabelline/lustre` with `view(table) -> Element(msg)`, so an app writes
  `tabelline_lustre.view(table)` and never sees `unsafe_raw_html`;
- errors as a type, not a string, the same on both targets;
- the JavaScript build of tabelline shipped inside the Gleam package, so `gleam add tabelline`
  is all a user does, on either target.

## The plan

Five steps, for the thread that builds it:

1. **tabelline**: the two fixes of this post, and a CI job that compiles the
   tests with `nim js` and runs them in Node, so the JavaScript backend stays working.
2. **tabelline**: the icons and the datasets as choices of the JavaScript build (`-d:` defines),
   off in the browser build unless asked for.
3. **tabelline-polyglot**: `js/` (the export) and a Gleam package with both targets, from the
   reworked binding, with `tabelline/lustre`; `tools/polyglot.nim` checks the JavaScript target
   too (nine ports, same HTML).
4. **The demo**: the Lustre app, built in CI and published on GitHub Pages, with a second table
   from a dataset the reader picks.
5. **A devlog post** with what was built, and the demo inside it.

## How it is built

The proof of concept is in tabelline-polyglot, `js/` and `lustre/` (branch
`claude/project-thread-iukcmv`). `nim r lustre/build.nim` does four things:

1. `nim js -d:release js/tabelline_js.nim` writes `build/tabelline_nim.js`, and the build
   appends the `export` line, as `lustre/src/tabelline_nim.mjs`.
2. `gleam build` compiles the app, the binding, Lustre and Gleam's standard library to
   JavaScript modules in `lustre/build/dev/javascript/`. Gleam copies the `.mjs` files of
   `src/` beside them, so `./tabelline_ffi.mjs` and `./gleam.mjs` are found.
3. esbuild follows the imports from `main` and writes one minified script.
4. The script goes inside `page.html`, which holds the style: one file, `dist/index.html`.

The sandbox it was written in could not reach Hex, Gleam's package registry. The Gleam binary
came from GitHub's releases, and Lustre and its six dependencies were cloned with git and given
to `gleam.toml` as paths. The committed `gleam.toml` names them as Hex packages.
"""

nbSave
