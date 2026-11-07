# nimib-integration Specification

## Purpose
tabelline in nimib notebooks.

## Requirements

### Requirement: A table block
`import tabelline/nimib` SHALL add `nbTable t`, a block that keeps the HTML and the Markdown of
the table, so the table renders with nimib's HTML backend (`nbInit`) and Markdown backend
(`nbInitMd`). The core of tabelline SHALL NOT depend on nimib.

#### Scenario: A README from a notebook
- **WHEN** a notebook made with `nbInitMd` calls `nbTable t`
- **THEN** the Markdown file holds `t.toMarkdown`

#### Scenario: nimib's old md template
- **WHEN** a notebook imports nimib and tabelline and calls `md("...")`
- **THEN** the call is ambiguous with nimib's deprecated `md`, so the notebook imports `nimib except md`
