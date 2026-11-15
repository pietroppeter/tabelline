# way-of-working Specification

## Purpose
How tabelline is made: specs with examples that run, pages kept up to date, stories and a devlog built as
nimib notebooks, previews before merges.

## Requirements

### Requirement: Behaviour lives in the specs
Every agreed behaviour SHALL be a requirement with scenarios in `openspec/specs/`. New work SHALL
start as an OpenSpec change in `openspec/changes/` (proposal, spec deltas, tasks), be built in one
PR, and be archived when it ships. Ideas not yet picked up SHALL live in `BACKLOG.md`.

#### Scenario: An idea becomes work
- **WHEN** a backlog idea is picked up
- **THEN** it becomes a change, its backlog entry is marked in progress, and when the change is archived the entry is removed and CHANGELOG.md gets a line

### Requirement: Examples that run
A requirement that describes Nim API SHALL have an example: a ```nim block followed by a ```text
block with what it prints. `nim r tools/specexamples.nim` SHALL run every example of the specs in
one program and fail when an output differs; `--update` SHALL write the actual outputs back. CI
SHALL run them on every push and pull request.

#### Scenario: A change breaks an example
- **WHEN** a change to the code makes an example print something else
- **THEN** `tools/specexamples.nim` exits with an error showing the expected and the actual output

### Requirement: Pages are notebooks
Every page SHALL be a nimib notebook in `docs/` that writes an HTML file, in the theme of the docs
(`useTabelline`), with the code that made each table shown next to it. The pages SHALL share their
style, fonts and scripts as files in `docs/assets/`, linked relatively, nothing loaded from
another site; `-d:singleFile` SHALL build each page as one file with everything inlined. CI SHALL
build all pages (`docs/all.nim`) and deploy them to GitHub Pages from `main`; the HTML SHALL NOT
be committed.

#### Scenario: Reading two pages
- **WHEN** a reader opens the home page, then the Guide
- **THEN** the style and the fonts are downloaded once

#### Scenario: A one-page preview
- **WHEN** a page is built with `-d:singleFile`
- **THEN** its HTML file works alone, with no other file beside it

### Requirement: Pages kept up to date, and a devlog
The site SHALL have pages kept up to date as tabelline changes (the Guide, the specs page and
the others on the home page), and a devlog of dated posts, each telling one step as it happened.
A post SHALL NOT be rewritten afterwards, but it SHALL take edits: typos, links and small
corrections. The home page SHALL list the pages in groups, by the question a reader brings, with
names a newcomer can read. The devlog index SHALL list only the posts, newest first, read from
the posts' sources. The specs page SHALL show every spec with its examples, their output and the
HTML table each example makes.

#### Scenario: A new post
- **WHEN** a post `docs/devlog/<slug>.nim` is added
- **THEN** it appears on the devlog index at the next build with nothing else to edit, and gets a line in the README

#### Scenario: A typo in an old post
- **WHEN** a reader finds a typo in a dated post
- **THEN** it is fixed in the post, and the post keeps its date

### Requirement: Every page can be reviewed
Every page of the docs SHALL have the review mode (the spec `review-mode`), turned on by the
theme: `useTabelline` SHALL call `nbReview()`, and `useTabelline(review = false)` SHALL leave it
out. The pages SHALL share one copy of the script (`docs/assets/review.js`), as they share their
style (the change `share-site-assets`).

#### Scenario: A new page
- **WHEN** a new page is added to `docs/`
- **THEN** it has a version line and **✎ Review** with nothing to add to the page

### Requirement: Stories
The site SHALL have a Stories section: every release's *use it* thread SHALL tell a real subject in
tables made with tabelline, as a story in `docs/stories/<slug>.nim` whose first line is
`## story: <release> | <title> | <lede>`. A release MAY have more stories than its *use it* thread's
(such as one on how a story's data was made). The home page and the stories page SHALL show every story
in a gallery, in release order (the first release first; in a release, the *use it* thread's story
first), read from the stories' sources. Stories SHALL be kept up to date, and the roadmap SHALL link
each *use it* thread to its story. A story that was published at another address SHALL keep it,
forwarding to the story.

#### Scenario: A new story
- **WHEN** a story `docs/stories/<slug>.nim` is added
- **THEN** it appears in the gallery of the home page and of the stories page at the next build with nothing else to edit, and gets a line in the README

### Requirement: English, preview first
Specs, code, commits, PRs and the devlog SHALL be in English (Italian words are welcome as names).
A change SHALL be shown to Pietro as a published preview before it is merged, and nothing SHALL
go to `main` without his go.

### Requirement: Docs for agents in plain text
The site SHALL publish, next to the Reference, `api.md` (every exported name with its
signatures, doc comment, gt's and Great Tables' names and an example of the specs with its
output, after an index of one line per name) and `api.json` (the same as data), built from the
source with the pages. `llms.txt` SHALL list these plain-text docs first, with the feature map's
`gt.json` and the specs' Markdown at the release's tag, and the README SHALL say how to install
tabelline.

#### Scenario: An agent looks up a gt name
- **WHEN** an agent greps `api.md` for `fmt_number`
- **THEN** it finds the entry of `fmtNumber`, with its signature and an example that ran

### Requirement: Skills for agents, tested
The repository SHALL hold, in `skills/`, the skills for agents that use tabelline: `tabelline`
(what the docs do not say: how to work, the traps agents met, recipes for hard tables) and
`table-building` (true of any table with any library: what to decide first, in what order to
build, and to look at the page before saying it is done), installable as a Claude Code plugin
from the repository. A skill SHALL NOT copy the API or the book. Every Nim example of a skill
SHALL run against the code and print the text shown after it (`tools/skillexamples.nim`, in CI).
Every rule of a skill SHALL come from an agent's run, with an eval case in the skill's `evals/`
that `tools/skillevals.nim` grades.

#### Scenario: A skill's example goes out of date
- **WHEN** a change to tabelline alters what an example of `skills/tabelline/SKILL.md` prints
- **THEN** `nim r tools/skillexamples.nim` fails in CI until the skill is updated in the same PR

#### Scenario: An agent's table is graded
- **WHEN** an agent has ported a table in a folder and `nim r tools/skillevals.nim skills/tabelline/evals/port-gt-extras <folder>` runs
- **THEN** each grader of the case is printed as passed or failed, and the exit code is 1 if one failed
