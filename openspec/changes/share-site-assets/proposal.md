## Why

Every page of the docs inlines its whole style, fonts included: the home page is 250 KB, 220 KB of
it style and fonts, the same on every page. The rule comes from tabelline's first commit
("standalone HTML file, fonts inlined, nothing remote"), from the habit of one-shot nimib pages
and one-page previews. Pietro, 10 Nov 2026 (thread "Build a review mode for nimib pages"): that
is right for a one-shot page, but a page in a collection should share everything it needs. The
review mode, on every page (change `review-mode-api`), would add 27 KB more per page. The PR
that builds it is still to be opened.

## What Changes

- The pages of the docs share their style, their fonts and the review script as files in
  `docs/assets/` (`site.css`, `fonts/*.woff2`, `review.js`), linked relatively: local to the
  site, nothing remote. A reader downloads them once.
- `-d:standalone` builds every page as one file again, everything inlined, for a one-page preview.
- The full-site preview copies `docs/assets/` with the pages, as it does for the book; the
  tool becomes `tools/preview.nim`, like the other tools (it is the last Python one in `tools/`).
- The rule is rewritten in AGENTS.md, the way-of-working spec and the design guide: a page in a
  collection shares; a one-shot page is one file.

## Differences from gt and Great Tables

None: this is about the docs, not tables.

## Capabilities

### Modified Capabilities
- `way-of-working`: pages share their assets.

## Impact

`docs/stile.nim` (the CSS written to a file, fonts as files), `docs/blocchi.nim`
(`useTabelline` links them), `docs/all.nim`, `tools/preview.py` (to `preview.nim`), `tools/drift.nim` (counts are
unchanged), AGENTS.md, the design guide, the deployed `docs/assets/`.
