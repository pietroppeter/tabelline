## ADDED Requirements

### Requirement: Stories
The site SHALL have a Stories section: every release's *use it* thread SHALL tell a real subject in
tables made with tabelline, as a story in `docs/stories/<slug>.nim` whose first line is
`## story: <release> | <title> | <lede>`. The stories page SHALL list every story, newest release
first, read from the stories' sources. Stories SHALL be kept up to date, and the roadmap SHALL link
each *use it* thread to its story. A story that was published at another address SHALL keep it,
forwarding to the story.

#### Scenario: A new story
- **WHEN** a story `docs/stories/<slug>.nim` is added
- **THEN** it appears on the stories page at the next build with nothing else to edit, and gets a line in the README
