## Why

Pietro, 11 Nov 2026 (thread "Build tabelline for Gleam in the browser", from the research post
*tabelline in the browser, from Gleam*, PR #97): tabelline runs in a web page, compiled by
`nim js` and called from Gleam. That needs tabelline to work under the JavaScript backend, to
stay working, and to be small enough to download. Steps 1 and 2 of the post's plan; built in
the PR of this change.

## What Changes

- **tabelline works under `nim js`.** Five things broke, and are fixed:
  - `imageDataUrl` (so `fmtImage` and `localImage` with a file) raises under JavaScript, which
    has no files; an address works as before.
  - The big const strings (CLDR values, Font Awesome) are bound once with `let`: `nim js` writes
    a const string out at every use, so the locale lookup hung and a build weighed 18 MB.
  - A tie rounds to the even digit under JavaScript as in C (`formatNumber(2.25, 1)` is "2.2"):
    `toFixed` rounds a tie up, so `fixed(x, decimals)` finds ties from the number's exact digits.
  - `colsAlignDecimal` pads cells through an iterator, not a list of `ptr string` (a change
    through such a pointer was lost under JavaScript).
- **Tests under JavaScript.** `tests/js.nim` is `tests/all.nim` but the nimib tests; CI runs it
  with `nim js -d:nodejs -r`. A test that needs a file has a JavaScript branch.
- **A lean build.** `-d:tabellineIcons=false` leaves the icons out (1.5 MB) and
  `-d:tabellineDatasets=false` the bigger datasets (450 KB: all but `planets`, `exibble` and
  `tavolaPitagorica`). What is left out raises `ValueError` and names the define. Both are on by
  default, on every backend: a program compiled by Nim keeps only what it uses anyway; the
  defines are for a build that can call every verb from JSON, as the browser one does.
  `tests/lean.nim` checks it, in C and JavaScript.

## Differences from gt and Great Tables

None in names or behaviour: gt and Great Tables run in R and Python, not in a browser. Running
in a page, and a lean build, are new: a line in *Not from gt*.

## Capabilities

### New requirement in `rendering`
- Under JavaScript

## Impact

`src/tabelline/{localize,pictures,formats,build,datasets,nanoplots,verbs}.nim`, `tests/js.nim`,
`tests/lean.nim`, `tests/test_{pictures,formats,finish_0_2}.nim`, CI, the coverage map, README,
CHANGELOG.
