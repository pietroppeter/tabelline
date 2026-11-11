## ADDED Requirements

### Requirement: Data frames of nanuq
`import tabelline/nanuq` SHALL make `toTableData(df)` and `tabella(df)` (so `tabella(df): body`)
work for a nanuq DataFrame, copying every column in order: integers as ints, floats as floats,
booleans as bools, strings as text, any other type as the text Polars writes for it, and a null
as a missing value. It SHALL be the only module of tabelline that imports nanuq; nanuq SHALL be
part of the `docs` feature, so the core keeps needing only Nim's standard library.

#### Scenario: A summary made in nanuq
- **WHEN** a DataFrame is grouped and summarised in nanuq and given to `tabella(df): body`
- **THEN** the table has the frame's columns in order, numbers aligned right, and the body's verbs apply as for any data

#### Scenario: Nulls
- **WHEN** a column of the DataFrame holds a null
- **THEN** that cell is missing (`isNull`), and `subMissing` shows it as for any data
