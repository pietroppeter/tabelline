## Why

Before the tag of 0.2, Pietro asked why the book still had gaps (14 Nov 2026): "That is indeed
why we update the book before release." The book's `gaps.md` listed 31 things its chapters
worked around, marked **new**. He chose to close all but three in 0.2 (image export, small
charts from other data, which `fmt` with a proc already draws, and moving the book's helpers to
nanuq). Built in PR #87, the release PR.

## What Changes

- Data: a CSV column with a value written with a zero in front (`"0400"`) stays text; a list
  column of a nanuq data frame becomes a list.
- Parts: `tabStub(rownameCol, groupnameCol)` on a table already made; `tabRowGroup(label, id =
  ...)` relabels a group, Markdown included.
- Columns and rows: `ofKind(vkBool)`, `named(cond)` and `matches(proc)`, `a & b`; a block of
  `colsLabel` mixes plain and `html`/`md` labels; negative row indices and `^1`.
- Formats: `nSigfig`; `accounting` in `fmtNumber`, `fmtInteger`, `fmtPercent`; `expStyle`;
  `fmtDatetime(formatStr = ...)`; Markdown in `subMissing`; `fmtFlag` with the country's name
  on hover and `round = true`; the format functions take `pattern`, `locale` and `expStyle`.
- Text: `md()` with HTML entities, `_` and `__`, `~~struck~~`, `<https://...>`, paragraphs
  and lists.
- Options: `optStylize` with gt's six styles in its six colours (`addRowStriping`);
  `optAllCaps(locations)`; light text on a dark stub, row group or summary row; `stubSticky`.
- Styles: `style.text(vAlign, indent)`, `style.fill(alpha)`; `loc.stub(labels)`,
  `loc.rowGroups(rows)`, `loc.body(mask)`; a fill on a spanner fills its cell; `dataColor`
  leaves the stub alone; R's colour names; `palette("great-tables")`.
- Look: formatted numbers do not break inside a cell.

## Differences from gt and Great Tables

- `named(cond)` and `matches(proc)` test a column's name with Nim code; gt's `matches()` takes a
  regular expression, Great Tables a function or a Polars selector. tabelline has no regular
  expressions (the core needs only the standard library).
- Rows from the end are `-1` (as Python) or `^1` (Nim); gt has none.
- `loc.stub(rows, labels)` takes indices and labels in two arguments: Great Tables' list mixes
  them (`["apricot", 2]`), and a Nim list holds one kind of value.
- `loc.body(mask)` is a proc of the cell's value (and of its column), Great Tables' a Polars
  expression; gt has no mask.
- `fmtDatetime(formatStr)` is gt's `format`, Great Tables' `format_str`.
- `stubSticky` is not in gt or Great Tables (a line in *Not from gt*).
- `dataColor`'s default palette stays tabelline's `blues`; Great Tables' is `palette("great-tables")`.
