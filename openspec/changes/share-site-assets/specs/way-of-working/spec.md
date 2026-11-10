## MODIFIED Requirements

### Requirement: Pages are notebooks
Every page SHALL be a nimib notebook in `docs/` that writes an HTML file, in the theme of the docs
(`useTabelline`), with the code that made each table shown next to it. The pages SHALL share their
style, fonts and scripts as files in `docs/assets/`, linked relatively, nothing loaded from
another site; `-d:standalone` SHALL build each page as one file with everything inlined. CI SHALL
build all pages (`docs/all.nim`) and deploy them to GitHub Pages from `main`; the HTML SHALL NOT
be committed.

#### Scenario: Reading two pages
- **WHEN** a reader opens the home page, then the Guide
- **THEN** the style and the fonts are downloaded once

#### Scenario: A one-page preview
- **WHEN** a page is built with `-d:standalone`
- **THEN** its HTML file works alone, with no other file beside it
