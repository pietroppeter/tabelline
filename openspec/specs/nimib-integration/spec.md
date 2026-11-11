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

#### Scenario: md in a notebook
- **WHEN** a notebook does `import nimib` and imports tabelline, and calls `md("...")`
- **THEN** the call is tabelline's `md`: nimib 0.5 has no `md` of its own, so nothing is excluded from the import

### Requirement: One stylesheet per page
`nbTable` SHALL write `tabellaCss` once per page, with the first table of the page; the next
tables SHALL not repeat it. `nb.tableHtml(t)` SHALL give the HTML of `t` with the same rule, for
a block that puts a table inside its own HTML. A new page (`nbInit`) SHALL start without it.

#### Scenario: A page of many tables
- **WHEN** a page calls `nbTable` for 100 tables, with any options
- **THEN** the page holds `tabellaCss` once, in the first table's block

#### Scenario: A table in another block
- **WHEN** a custom block renders `nb.tableHtml(t)` after an `nbTable`
- **THEN** its HTML has no `tabellaCss`, and the table looks as it does alone
