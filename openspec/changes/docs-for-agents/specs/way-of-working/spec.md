## ADDED Requirements

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
