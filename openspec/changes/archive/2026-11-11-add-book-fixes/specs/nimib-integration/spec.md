## MODIFIED Requirements

### Requirement: A table block
`import tabelline/nimib` SHALL add `nbTable t`, a block that keeps the HTML and the Markdown of
the table, so the table renders with nimib's HTML backend (`nbInit`) and Markdown backend
(`nbInitMd`). `nbTable` SHALL also take the data and a body, `nbTable data: body`, and add
`tabella(data): body` in one step, with any other argument of `tabella` (`rownameCol`, ...);
`nbTable data` without a body SHALL add a table of the data as it is, and `nbTable t: body` a
table `t` changed by the body. The core of tabelline SHALL NOT depend on nimib.

#### Scenario: A README from a notebook
- **WHEN** a notebook made with `nbInitMd` calls `nbTable t`
- **THEN** the Markdown file holds `t.toMarkdown`

#### Scenario: md in a notebook
- **WHEN** a notebook does `import nimib` and imports tabelline, and calls `md("...")`
- **THEN** the call is tabelline's `md`: nimib 0.5 has no `md` of its own, so nothing is excluded from the import

#### Scenario: A table in one step
- **WHEN** a notebook calls `nbTable planets(), rownameCol = "planet":` with `tabHeader "Planets"` in the body
- **THEN** the page shows the planets with their names as the stub and the heading "Planets", and no table needs a name
