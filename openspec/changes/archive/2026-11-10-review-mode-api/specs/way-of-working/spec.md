## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Every page can be reviewed
Every page of the docs SHALL have the review mode (the spec `review-mode`), turned on by the
theme: `useTabelline` SHALL call `nbReview()`, and `useTabelline(review = false)` SHALL leave it
out. The pages SHALL share one copy of the script (`docs/assets/review.js`), as they share their
style (the change `share-site-assets`).

#### Scenario: A new page
- **WHEN** a new page is added to `docs/`
- **THEN** it has a version line and **✎ Review** with nothing to add to the page
