# Working on tabelline

Notes for coding agents (and people) changing this repository. How tabelline behaves is in
`openspec/specs/` (rendered at `specs/`); how it is laid out is in README.md. This file holds the
working rules that are easy to miss.

## Behaviour lives in the specs

- Every agreed behaviour is a requirement with scenarios in `openspec/specs/`. New work starts as
  an OpenSpec change in `openspec/changes/` (`/opsx:propose`), is built in a PR (`/opsx:apply`),
  and is archived when it ships (`/opsx:archive`). `openspec/config.yaml` has the rules.
- Ideas go in BACKLOG.md, not straight into work. When a change is archived, remove its BACKLOG
  entry and add a CHANGELOG.md line under Unreleased with the PR number.
- Every requirement about the API has an example: a ```nim block followed by a ```text block with
  what it prints (`echo t` prints a table as text). `nim r tools/specexamples.nim` runs them all;
  `--update` rewrites the outputs after a change is built; `--changes` includes open changes.
- Name verbs after gt in camelCase (`tab_header` is `tabHeader`), and list differences from gt and
  Great Tables in every proposal.

## Code

- The core (`src/tabelline/`) needs only Nim's standard library. nimib is used only by
  `src/tabelline/nimib.nim` and the docs. Optional interop goes in its own module.
- Verbs take a `Tabella` (`sink`) and return the new one; formats and styles resolve columns and
  rows when the verb is called and run when the table is rendered (`build.nim`), so every renderer
  agrees. Macros only where a proc cannot do the job (today: `tabella(data): body`, `tableData:`,
  `tabOptions`).
- `nim r tests/all.nim` runs the tests. Dependencies are managed with atlas: nimib is the `docs`
  feature of `tabelline.nimble`, pinned in `atlas.lock`, cloned into `deps/` (not committed) and
  put on the path by `nim.cfg` (committed, written by atlas).

## Setup

- In a fresh checkout or sandbox, run `sh tools/setup.sh` before anything else. It installs what is
  missing (Nim from GitHub nightlies, atlas, libpcre3) and the pinned dependencies, and is safe to
  rerun. It prints the `export PATH=...` line to use when it installed Nim or atlas.
- To change a dependency: `atlas use <pkg>` or edit the `docs` feature, `atlas install
  --feature=docs`, run the tests and the pages, then `atlas pin --feature=docs` and commit
  `atlas.lock` and `nim.cfg`. Without `--feature=docs`, atlas leaves nimib out.
- `atlas.lock` keeps a copy of `tabelline.nimble`, and `atlas rep` (so `tools/setup.sh`) writes that
  copy back: after editing `tabelline.nimble`, run `atlas pin --feature=docs` before the setup.

## Pages

- Every page is a nimib notebook in `docs/` that calls `nb.useTabelline(...)` after `nbInit`
  and writes a standalone HTML file (fonts inlined, nothing remote) with two looks: Munari, the
  default (plain rules, so a page without JavaScript is Munari), and the quaderno (rules under
  `html[data-tema="quaderno"]`); the header switches between them and the choice is remembered.
  Check new page elements in both looks, at 390px. The HTML is not committed: CI builds every
  page (`nim r -d:release docs/all.nim`) and deploys `docs/` to GitHub Pages from `main`.
  Notebooks that import nimib and tabelline use `import nimib except md`.
- **Blocks, not HTML.** A page is Markdown in `nbText`, nimib's blocks, `nbTable`, and the blocks
  of `docs/blocchi.nim` (`nbTitolo`, `nbIndice`, `nbNota(text, kind)`, `nbCards`/`nbCard`,
  `nbGalleria`/`nbScheda`, `nbTabs`, `nbShowCode`, `nbParti`, `nbAccanto`, `nbTinte`,
  `nbParte`). In a page that tells a story with tables (an explainer, a use-it post), what is
  about the code goes in `nbNota(text, nkCode)`, the green card, under the table it explains,
  with a first card that says so; the text tells the story. No HTML in `nbText`, no CSS and no colours in a page. What is needed a second time
  becomes a block in `docs/blocchi.nim`; its CSS goes in `docs/stile.nim`, from the tokens.
  `nbRawHtml` is a last resort, for a one-off, with a comment saying why. Tables take
  `optPageTheme()`; a colour in a page is a token (`"var(--secondary)"`), never a hex value.
  `nim r tools/drift.nim` (in CI) fails when a page has more HTML, styles, scripts or colours than
  its line in `tools/drift.tsv`; when a page loses some, lower its line with `--update`.
- The home page shows the simplest example, the gallery of the stories, and links the living
  documents in this order: The Great Explainer, Devlog, Book, Roadmap, Coverage map, Design Ref, Agents, Specs. The devlog
  lists only posts. A new living document gets a card there
  (`docs/index.nim`), a line in the README, and in `docs/agents.nim`'s llms.txt list.
- The Design Ref (`docs/design.nim`) is updated in the PR that changes the look; a big design
  change starts as a devlog post. The Agents page reads this file when it builds.
- Stories are the *use it* threads' output, one for every release: a real subject told in
  tables, as a user would. A story is `docs/stories/<slug>.nim` (first line `## story: <release> |
  title | lede`, data in `docs/stories/data/<slug>/`); the gallery of the home page and of the
  stories page finds it and shows a small table from it (`preview` in `docs/stories/storie.nim`), and the roadmap's thread links it (`href`
  in `docs/piano.nim`). A story is kept up to date, like a living document: when a release makes
  one of its tables better, change the story.
- Living documents are kept up to date. A devlog post
  (`docs/devlog/<slug>.nim`, first line `## devlog: dd Mon yyyy X | title | lede`) is dated and not
  updated afterwards; the devlog index finds it, and it gets a line in the README. `X` is a letter
  for posts of the same day, in the order they were written (A, B, C, ...), so the index can
  show the newest first.
- Shape for kind, colour for role. The circle is a place (sections, the indice), the triangle a
  warning (`nkWarning`, drawn as a road sign), the square a sheet set apart (notes, cards, gallery
  cards: their straight top edge). Each shape has a default colour, another only with a reason.
  Nothing that only decorates may look like something to press or drag (no dots, holes or knobs
  on cards). Colours are the tokens of `docs/stile.nim`: six values per look (paper, ink,
  primary, secondary, warning, success), and every other colour mixed from them (`--n-0` …
  `--n-9`, `--surface`, `--x-soft`, `--x-text`); the warning colour is never text.
- The coverage map (`docs/coverage.nim`) reads `docs/coverage/gt.json`. A PR that adds or
  completes a gt feature updates its row there (status, and `plan` while it is open), and a
  release PR checks the whole file.
- A link can show part of the specs page: `specs/?spec=<names>` or `specs/?change=<names>`
  (comma-separated, `name*` for a prefix, `all`, or the same after `#`).

## The book

- The book is `book/`, a nimibook built by `nim r book/bookbuild.nim` into `docs/book/` (see
  README.md). One theme, the Munari look with the Edo palette: the tokens of `docs/stile.nim` in
  the values `edo`, written by the build before `book/theme/edo.css`, which names no colour of
  its own. Its own tables (the sources) take `optPageTheme()`; the ported examples keep the colours
  of the guide. Chapters are written with `book/tabbook.nim`'s blocks (`tabs`, `tabelline`,
  `sideBySide`), not with HTML.
- A ported page keeps the text of the original as it is; everything the book says about
  tabelline goes in `tabelline "..."` boxes, and every gap found goes to `book/gaps.md` (and to
  the build thread, or BACKLOG.md).
- A change to a chapter's Python needs uv (`book/gt/`), and a change to its R needs R with gt:
  rebuild, then commit `book/gt/outputs/` and `book/gt/outputs-r/`. CI never runs Python or R.
  The R tab is written for the book (the gt way to make the same table); where gt has no way,
  pass `""` and the tab says so.
- When tabelline gains a feature a chapter works around, update the chapter and `book/gaps.md`.
- The sources the book plans to port are in `book/plan/sources.json`; `python3 book/plan/plan.py`
  maps each page to the features it calls and writes `book/plan/pages.json` (committed). Rerun it
  when `docs/coverage/gt.json` changes or a source is added; findings of a port go to `found`.

## Previews and PRs

- Show Pietro a published preview of the pages before asking to merge; he reviews on his phone.
- `python3 tools/preview.py` copies the built pages to `../tabelline-preview` for an artifact
  (folder links point to index.html), with the book. A link to the artifact ending in `#<page>`
  opens that page: the folder with `/` as `-`, such as `#devlog-three-threads` or `#roadmap`,
  and for the book `#book-` and the page's path without `.html`, such as
  `#book-get-started-intro`. Give Pietro the deep link to what changed.
- When a change is visual, put before and after screenshots (phone width, both looks) in the reply
  to Pietro, and only the after shots of what changed in the PR description. To show them in the
  PR without adding them to `main`, commit them, link them by that commit's sha, and remove them
  in the next commit.
- Nothing goes to `main` without his go. One clean PR per change; keep the PR description in sync
  with the branch.
