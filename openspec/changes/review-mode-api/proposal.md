## Why

The review mode was built round by round inside the devlog post *Review mode* (PRs #40 to #47),
outside the OpenSpec flow: it has no spec, and its API grew with the post. After round 7 Pietro
said it is close to working for him and asked for two things (thread "Build a review mode for
nimib pages", 10 Nov 2026):

- a simpler API, where the version is the latest one by itself, not an argument that defaults to 1;
- a way to turn it on for every page of the docs, maybe hidden in the theme.

Keeping a notebook per version (`review_mode/v1.nim` … `v8.nim`) was part of the experiment, and
it costs: about 3,000 lines rebuilt by every CI run, a copy and a record line per round, and old
versions that are rebuilt with today's blocks, so not exactly what was read. Git already keeps
every version, exactly. This change writes down what the review mode is, and changes three
things: the version comes from git, versions are no longer kept as pages, and the docs turn it
on in the theme. The BACKLOG entries "Review mode: one notebook, not one per version" and
"Review-mode rounds made site-wide changes outside a change" are where it comes from. The PR
that builds it is still to be opened.

## What Changes

- A new spec, `review-mode`: the review mode as it is after round 7 (reading by default, the
  bar, the comment box, the export, History), and the changes below.
- **The version comes from git.** `nbReview()` reads the number of commits that touched the
  page's source and the last one's short hash and date (`12`, `a1b2c3d`, `10 Nov 2026`). Outside
  git, a hash of the source. The `version` argument goes.
- **The export carries the commit**: `nimib-review/4` adds `commit:` to the YAML block, so the
  agent can see what changed since the review (`git diff a1b2c3d -- <source>`).
- **Versions are not kept as pages.** `nbVersions`, `versionHref`, `versionsJson` and the
  `versions` argument go. History lists only the comments this browser keeps, by version, with
  Clear.
- **`nbVersion()` takes no arguments**: it writes *Version 12 · updated 10 Nov 2026* from git.
- **Every page of the docs** gets the review mode from the theme: `useTabelline` calls
  `nbReview`, and **✎ Review** sits in the site's header, beside the switch of the looks, so no
  page needs a line of its own. `useTabelline(review = false)` leaves it out.
- **The post *Review mode* becomes one notebook.** v1 to v8 stop being rebuilt; the post's
  versions section links each version to its commit and its round's export.
- CI fetches the whole history (`fetch-depth: 0`), so the commit count is right.

## Differences from gt and Great Tables

None: the review mode is part of the docs, not of tables. It is not from gt or Great Tables; the
closest thing is a page's "suggest an edit" link (gt's pkgdown site links each page to GitHub).

## Capabilities

### New Capabilities
- `review-mode`: commenting on a page and exporting the comments for an agent.

### Modified Capabilities
- `way-of-working`: every page of the docs has the review mode.

## Impact

`docs/review.nim` (API, version from git), `docs/assets/review.js` (header button, History,
format /4), `docs/blocchi.nim` (`useTabelline`, the header), `docs/stile.nim` (the header
button), the post `docs/devlog/review_mode*` (one notebook), `.claude/skills/nimib-review/`
(format /4, the diff), `.github/workflows/` (`fetch-depth: 0`), AGENTS.md, the design guide.
