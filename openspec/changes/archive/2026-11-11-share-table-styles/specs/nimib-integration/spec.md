## ADDED Requirements

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
