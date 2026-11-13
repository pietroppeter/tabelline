## Why

Pietro's review of the islands story (version 22, 13 Nov 2026), on the table of the islands
ordered by people per km²: the text talks about Malta, Sicily, Cres and Krk, and the preview showed
only its two ends. "Can we add to the table preview an option where, besides the top rows and the
bottom rows, we can have ranges in the middle too?" Built in PR #101.

## What Changes

- `tabellaPreview(data, topN, bottomN, moreRows = ...)`: the rows of `moreRows` are shown too,
  between the first and the last, in their order. `moreRows` is a row selector, as in every verb:
  an index (from 0), a range, a set of both (`{12, 40..42}`, as nimiSlides' `animateCode`), or
  `where(it.island in ["Sicily", "Krk", "Cres"])`.
- Each run of rows left out gets its own shaded row ("4..11"), and a run of a single row is shown
  rather than left out (the rule that already showed a table of `topN + bottomN + 1` rows whole).
- A converter from a set to a row selector, so `{0, 5..7}` works wherever rows are chosen.

The name: Pietro proposed `otherRows` or `moreRows`; `moreRows` reads "and these rows too", and
`otherRows` could read as "all the others". `middleRows` was left out, since a chosen row can sit
next to the ends.

## Differences from gt and Great Tables

- gt's `gt_preview()` and Great Tables have only `top_n` and `bottom_n` (and `incl_rownums`);
  `moreRows` is new, and gets a line in *Not from gt*. Indices are from 0, as in every tabelline
  verb, while the stub numbers rows from 1, as gt does.
