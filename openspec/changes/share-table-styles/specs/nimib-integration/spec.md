## ADDED Requirements

### Requirement: One style per page
`nbTable` SHALL write each style class's `<style>` once per page: the first table of the page
with a class carries it, the next ones with the same class do not. `nb.tableHtml(t)` SHALL give
the HTML of `t` with the same rule, for a block that puts a table inside its own HTML. A new page
(`nbInit`) SHALL start with no style written.

#### Scenario: A page of many tables
- **WHEN** a page calls `nbTable` for 100 tables with the same options
- **THEN** the page holds one `<style>` for them, in the first table's block

#### Scenario: Two styles on a page
- **WHEN** a page shows tables with two different sets of options
- **THEN** the page holds two `<style>` elements, one per class

#### Scenario: A table in another block
- **WHEN** a custom block renders `nb.tableHtml(t)` after an `nbTable` with the same style class
- **THEN** its HTML has no `<style>`, and the table looks as it does alone
