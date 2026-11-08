## MODIFIED Requirements

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
