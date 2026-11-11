## Why

The book's port for 0.2 (gt's articles and the Great Tables blog) left three findings open, and
Pietro asked for all three in 0.2 (11 Nov 2026, book thread: "Do all the three fixes"):

- `dataColor` knew 17 CSS colour names, so `palette = @["lightblue", "darkgreen"]` raised
  `ValueError`: the book wrote `"#006400"` instead. gt and Great Tables take every CSS name.
- A table in a notebook takes two steps, `let t = tabella(data): body` then `nbTable t`:
  `nbTable tabella(data): body` does not compile, because Nim gives the body to the outer call.
- The case studies start from raw data, one row per subject of a trial; R and Python shape it
  with dplyr and Polars before gt sees it, and the book wrote those steps in plain Nim.

## What Changes

- `parseColor` (so `dataColor`, `interpolate`, `idealTextColor`) knows the 148 colour names of
  CSS, in any case; anything else that is not `#rgb` or `#rrggbb` raises `ValueError`. The white
  text on a dark heading or column labels background (`tabOptions`) works for a name too.
- `nbTable data: body` adds `tabella(data): body` in one step, with `tabella`'s other arguments
  (`nbTable planets(), rownameCol = "planet": body`); `nbTable data` without a body is a table of
  the data as it is; `nbTable t` and `nbTable t: body` take a table.
- A new optional module, `tabelline/nanuq`: `toTableData(df)` and `tabella(df)` for a DataFrame
  of nanuq (Polars for Nim). nanuq joins the `docs` feature (pinned in atlas.lock); the core still
  needs only the standard library. The clinical case study shapes its data with nanuq.

## Differences from gt and Great Tables

- Colour names: the same 148 names as Great Tables (R's gt also knows R's own colour names, such
  as `"gray50"`, which tabelline does not).
- `nbTable data: body` has no counterpart: R and Python notebooks show a cell's last value.
- `tabella(df)` is gt's `gt(df)` and Great Tables' `GT(df)`, for nanuq's data frames; the data is
  copied, and dates and other types become text, as Polars writes them.

## Impact

- `src/tabelline/colors.nim`, `render_html.nim`, `nimib.nim`, new `src/tabelline/nanuq.nim`;
  `tabelline.nimble`, `atlas.lock`, `nim.cfg`; CI runs `tests/test_nanuq.nim`.
- Docs: the guide (Data, In nimib, the colours of step 4), the Reference (a module more), the
  feature map's *Not from gt*, the book (v0.2.0 chapter, clinical case study, gaps), README.
