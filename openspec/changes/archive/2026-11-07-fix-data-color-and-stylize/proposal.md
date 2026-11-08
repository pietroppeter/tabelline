## Why

The tabelline book (port thread, PR #11) checked its chapters against 0.1 and found that
`dataColor` does not colour like Great Tables when a call covers several columns, and that
`optStylize(2, "red")` writes dark text on its dark red header. Reported to the thread "Build
tabelline 0.1" on 7 Nov 2026; fixed before the 0.1.0 release.

## What Changes

- `dataColor` colours each column on its own: its own range, numbers as numbers even when a text
  column is in the same call. A domain from high to low runs the palette the other way (it gave
  every cell the middle colour).
- The heading and column labels get white text on any background that white reads better on,
  judged by contrast (it looked only at the red channel).

## Differences from gt and Great Tables

- None left: gt and Great Tables both colour each column on its own range.

## Capabilities

### Modified requirements in `styling`
- Colour by value
- Options and presets

## Impact

`src/tabelline/verbs.nim` (`dataColor`), `src/tabelline/render_html.nim` (heading text colour),
the spec `styling`, tests.
