## Why

nimib's old `md` template, a marker for nimiBoost's Markdown highlighting, clashed with
tabelline's `md()`: every notebook that imported both needed `import nimib except md`. Pietro
asked to remove it from nimib (review of the review mode post, round 7, comment 19), and nimib
removed `md` and `fmd` in pietroppeter/nimib#268, released in nimib 0.5.0. This is the BACKLOG
entry "Remove nimib's deprecated `md`". Built in the PR that adds this change.

## What Changes

- Notebooks, the book and the docs import nimib with `import nimib`; `book/tabbook.nim` exports
  it whole.
- nimib is pinned to a commit with nimib#268 (then to the 0.5.0 tag) in `atlas.lock`.
- The scenario "nimib's old md template" says that `md("...")` is tabelline's.

```nim
import nimib
import tabelline, tabelline/nimib
```

## Differences from gt and Great Tables

None: gt and Great Tables have `md()` too, and no nimib.
