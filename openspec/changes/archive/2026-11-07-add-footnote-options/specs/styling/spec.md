## ADDED Requirements

### Requirement: Footnote marks, look and order
`optFootnoteMarks(marks)` SHALL set the marks: `"numbers"`, `"letters"`, `"LETTERS"`, `"standard"`
(\*, †, ‡, §), `"extended"` (with ‖, ¶) or a list of your own, repeated (\*\*) when they run out.
`optFootnoteSpec(specRef, specFtr)` SHALL set how marks look in the table and in the footer (`^`
raised, `i` italic, `b` bold, `(` or `[` around). `optFootnoteOrder(order)` SHALL put marked notes
first (`"marks_first"`, the default), last (`"marks_last"`), or keep the order notes were added in
(`"preserve_order"`, which numbers the marks in that order too).

```nim
echo tabella(tavolaPitagorica(2), rownameCol = "×")
  .tabFootnote("A note with no mark.")
  .tabFootnote("Two twos.", loc.body(cols = "2", rows = [1]))
  .tabFootnote("The first row.", loc.stub(rows = [0]))
  .optFootnoteMarks("standard").optFootnoteSpec("^", "(").optFootnoteOrder("marks_last")
```

```text
┌─────┬───┬─────┐
│     │ 1 │   2 │
╞═════╪═══╪═════╡
│ 1^* │ 1 │   2 │
│ 2   │ 2 │ 4^† │
└─────┴───┴─────┘
A note with no mark.
(*) The first row.
(†) Two twos.
```

#### Scenario: More notes than marks
- **WHEN** a table has five notes and the standard marks
- **THEN** the fifth is marked \*\*
