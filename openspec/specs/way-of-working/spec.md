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
the others on the home page), and a devlog of dated posts, each telling one step as it happened
and not updated afterwards. The home page SHALL list the pages in groups, by the question a reader
brings, with names a newcomer can read. The devlog index SHALL list only the posts, newest first,
read from the posts' sources. The specs page SHALL show every spec with its examples, their
output and the HTML table each example makes.

#### Scenario: A new post
- **WHEN** a post `docs/devlog/<slug>.nim` is added
- **THEN** it appears on the devlog index at the next build with nothing else to edit, and gets a line in the README

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
