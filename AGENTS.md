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
- Anything new that is not from gt or Great Tables gets a line in the table *Not from gt* of the
  coverage map (`docs/coverage.nim`): what it is, why, and the closest thing in gt or Great Tables.
- Name verbs after gt in camelCase (`tab_header` is `tabHeader`), and list differences from gt and
  Great Tables in every proposal.

## Code

- The core (`src/tabelline/`) needs only Nim's standard library. nimib is used only by
  `src/tabelline/nimib.nim` and the docs. Optional interop goes in its own module
  (`src/tabelline/nanuq.nim`, for nanuq's data frames).
- Verbs take a `Tabella` (`sink`) and return the new one; formats and styles resolve columns and
  rows when the verb is called and run when the table is rendered (`build.nim`), so every renderer
  agrees. Macros only where a proc cannot do the job (today: `tabella(data): body`, `tableData:`,
  `tabOptions`).
- Examples in the docs and the specs write a table as `tabella(data): body`, one verb per line,
  not as a chain of dots, and a verb that takes a list of pairs (`colsLabel`, `colsWidth`,
  `colsUnits`, `textCaseMatch`, `summaryRows`, `grandSummaryRows`, `summaryColumns`) as an
  indented block, one pair per line (`summaryRows:` then `total: agg.sum`). A new verb whose first
  argument is a list of pairs goes in `pairVerbs` (`src/tabelline.nim`).
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
  and writes an HTML file that shares its style, fonts and scripts with the other pages
  (`docs/assets/`: `site.css`, written by `theme.nim`, the fonts, `review.js`; local, nothing
  remote), so a reader downloads them once; `-d:singleFile` inlines them, for a page that must
  work alone, such as a one-page artifact. It has two looks: Munari, the
  default (plain rules, so a page without JavaScript is Munari), and the quaderno (rules under
  `html[data-tema="quaderno"]`); the header switches between them and the choice is remembered.
  The pages of the islands of the Mediterranean offer the Minoan look instead of the quaderno
  (`useTabelline(looks = ["munari", "minoan"], firstLook = "minoan")`).
  Check new page elements at 390px in Munari; in the quaderno only what might affect it (a
  broken quaderno is a minor issue for now). The HTML is not committed: CI builds every
  page (`nim r -d:release docs/all.nim`) and deploys `docs/` to GitHub Pages from `main`.
- **Blocks, not HTML.** A page is Markdown in `nbText`, nimib's blocks, `nbTable`, and the blocks
  of `docs/blocks.nim` (`nbTitle`, `nbToc`, `nbNote(text, kind)`, `nbCards`/`nbCard`,
  `nbGallery`/`nbGalleryCard`, `nbTabs`, `nbShowCode`, `nbFoldCode`, `nbParts`, `nbBeside`, `nbSwatches`,
  `nbPart`, `nbDrawing`). In a page that tells a story with tables (an explainer, a use-it post), what is
  about the code goes in `nbNote(text, nkCode)`, the green card, under the table it explains,
  with a first card that says so; the text tells the story. No HTML in `nbText`, no CSS and no colours in a page. What is needed a second time
  becomes a block in `docs/blocks.nim`; its CSS goes in `docs/theme.nim`, from the tokens.
  `nbRawHtml` is a last resort, for a one-off, with a comment saying why. Tables take
  `optCssTheme()`; a colour in a page is a token (`"var(--secondary)"`), never a hex value.
  `nim r tools/drift.nim` (in CI) fails when a page has more HTML, styles, scripts or colours than
  its line in `tools/drift.tsv`; when a page loses some, lower its line with `--update`.
- Every explainer, story and devlog post has a table of contents: `nbToc` right after `nbTitle`,
  which also gives every heading its ↑ back to it (Pietro's review of the Mediterranean post).
- Every link leads somewhere. After building the pages and the book, `nim r tools/links.nim` checks
  the links inside the site (files and `#anchors`, and links to this repository's files on main,
  the PR's branch or a commit, in the checkout), and `nim r -d:ssl tools/links.nim --external` the
  links to other sites too (404 and 410 fail). CI runs the first on every run and the second once a
  week (and by hand), so a page that moves upstream (Great Tables' Get Started became its User
  Guide) is caught without slowing every PR.
- The home page shows the simplest example, then the gallery of the stories, and links the pages in three groups, by the question
  a reader brings: Learn tabelline (Guide, Book, Reference), Where it's going (Feature map, Roadmap), How
  it's made (Devlog, Specs, Design guide, For coding agents). Name pages in plain words a newcomer
  reads without knowing how tabelline is made. The devlog lists only posts. A new page gets a card
  there (`docs/index.nim`), a line in the README, and in `docs/agents.nim`'s llms.txt list.
- The Design guide (`docs/design.nim`) is updated in the PR that changes the look; a big design
  change starts as a devlog post. The page For coding agents reads this file when it builds.
- Stories are the *use it* threads' output, one for every release, and a release may have
  others (FOSDEM's data, for 0.1): a real subject told in tables, as a user would. A story is `docs/stories/<slug>.nim` (first line `## story: <release> |
  title | lede`, data in `docs/stories/data/<slug>/`); the gallery of the home page and of the
  stories page finds it and shows a small table from it (`preview` in `docs/stories/storie.nim`), and the roadmap's thread links it (`href`
  in `docs/piano.nim`). A story is kept up to date, like the other pages: when a release makes
  one of its tables better, change the story.
- The pages of the site are kept up to date. A devlog post
  (`docs/devlog/<slug>.nim`, first line `## devlog: dd Mon yyyy X | title | lede`) is dated and not
  rewritten afterwards, but takes edits (typos, links, small corrections); the devlog index finds
  it, and it gets a line in the README. `X` is a letter
  for posts of the same day, in the order they were written (A, B, C, ...), so the index can
  show the newest first.
- Shape for kind, colour for role. The circle is a place (sections, the indice), the triangle a
  warning (`nkWarning`, drawn as a road sign), the square a sheet set apart (notes, cards, gallery
  cards: their straight top edge). Each shape has a default colour, another only with a reason.
  Nothing that only decorates may look like something to press or drag (no dots, holes or knobs
  on cards). Colours are the tokens of `docs/theme.nim`: six values per look (paper, ink,
  primary, secondary, warning, success), and every other colour mixed from them (the neutrals
  `--shade`, `--line`, `--muted` and the scale `--neutral-0` … `--neutral-9`, `--surface`,
  `--x-soft`, `--x-text`); the warning colour is never text. The old names `--n-0` … `--n-9` and
  `--text` (now `--font`) are kept only for the dated posts' own CSS.
- The feature map (`docs/coverage.nim`) reads `docs/coverage/gt.json`. A PR that adds or
  completes a gt feature updates its row there (status, and `plan` while it is open), and a
  release PR checks the whole file.
- Review mode: every page has it, turned on by `useTabelline` (`review = false` leaves it out),
  from `docs/review.nim` (a module of its own in English that can move to nimib, with its
  styles; a plain nimib page calls `nbReview()`). The page shows *Version N · updated D*
  under its lede, with **✎ Review** beside it (`nbVersion()` moves the line); the version is
  the number of commits that changed the page's source, so CI checks out the whole history. In
  the review mode a reader selects text, comments, and exports the comments as Markdown with a
  block of YAML (`format: nimib-review/6`, in rounds: **Copy** sends the comments, which keep their
  numbers, and the next export holds only new or changed ones; `/5` said where a comment kept from an
  older version is from, `/4` added the `commit`, `/3` had no commit, `/2` had kinds,
  `/1` a front matter). When such an export is pasted in the chat, follow the skill
  `.claude/skills/nimib-review/`. The devlog post `review_mode` records its rounds in
  `docs/devlog/review_mode/storia.nim`.
- A link can show part of the specs page: `specs/?spec=<names>` or `specs/?change=<names>`
  (comma-separated, `name*` for a prefix, `all`, or the same after `#`).

## The book

- The book is `book/`, a nimibook built by `nim r book/bookbuild.nim` into `docs/book/` (see
  README.md). One theme, the Munari look with the Edo palette: the tokens of `docs/theme.nim` in
  the values `edo`, written by the build before `book/theme/edo.css`, which names no colour of
  its own. Its own tables (the sources) take `optCssTheme()`; the ported examples keep the colours
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
- The sources the book plans to port are in `book/plan/sources.json`: each says where its pages
  are (`find`: a repository and paths), and lists by hand only the pages it has something to say
  about. `nim r book/plan/plan.nim` searches the repositories (git, no API), maps each page to
  the features it uses and writes `book/plan/pages.json` (committed); it reports pages found and
  not listed (`port: "triage"` until read: list them) and pages listed and gone. Rerun it when
  `docs/coverage/gt.json` changes or a source is added; findings of a port go to `found`.
  `nim r book/plan/plan.nim fmt_currency` (or words of a feature) lists the pages that show a
  feature, the help pages of gt and Great Tables first: start there when porting or building it.
  The Table Contest entries are collected by `nim r book/plan/contest.nim` (forum and winners
  posts, cached; `--offline`) into the source `table-contest`; run it, then `plan.nim`.

## Previews and PRs

- Show Pietro a published preview of the pages before asking to merge; he reviews on his phone.
- `nim r tools/preview.nim` copies the built pages to `../tabelline-preview` for an artifact
  (folder links point to index.html), with `docs/assets/` and the book: publish the whole folder. A link to the artifact ending in `#<page>`
  opens that page: the folder with `/` as `-`, such as `#devlog-three-threads` or `#roadmap`,
  and for the book `#book-` and the page's path without `.html`, such as
  `#book-get-started-intro`. Give Pietro the deep link to what changed.
- When a change is visual, put before and after screenshots (phone width, Munari; the quaderno
  only when the change might affect it) in the reply
  to Pietro, and only the after shots of what changed in the PR description. To show them in the
  PR without adding them to `main`, commit them, link them by that commit's sha, and remove them
  in the next commit.
- Nothing goes to `main` without his go. One clean PR per change; keep the PR description in sync
  with the branch.
