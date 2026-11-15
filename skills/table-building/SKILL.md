---
name: table-building
description: Use when building, porting or reviewing a display table that people will read (in a report, a page, a README or a slide), with any library (tabelline, gt, Great Tables, HTML by hand), to build it in order and check it by looking at it, even if the user only says "make a table".
metadata:
  status: draft
---

# Building a table

How to get from data and an intent to a table worth printing, whatever draws it. The library's
own skill says which verbs to call (for tabelline, the skill `tabelline`); this one says in what
order to work and when the table is done.

It exists because of what agents did on six hard tables: every one compiled, every agent grepped
the HTML for its styles, none looked at the page. Two of the pages had a title shown twice, a
column cut off at the edge and rows 170px tall around a small drawing.

## 1. Say what the table is for

One sentence before any code: who reads it, and what they compare. "The owner sees which pizza
type earns most, and how sizes split." That sentence picks the rows (what is compared), the
order (by the measure that matters, not by the alphabet), and what can go.

When porting a table, the original has decided this already. List every thing it shows (each
column, group, total, note, colour, drawing) before you write, and tick the list at the end.

## 2. Shape the data first

One row for each thing compared, columns in the order they are read, sorted, already summed.
Print the data and check two or three numbers by hand against the source. A wrong join gives a
handsome table of wrong numbers.

## 3. Build in the order of the parts

Run the program after each step and read the text output.

1. **Stub and groups**: the names of the rows on the left, rows gathered under group labels.
2. **Column labels and spanners**: words a reader knows, not names from the data; the unit in
   the label (`Price, EUR`), not repeated in every cell; a spanner over columns that belong
   together.
3. **Formats**: numbers of a column with the same decimals, thousands separated, as few digits
   as the comparison needs; dates as a reader writes them; a dash for what is missing.
4. **Totals**: a summary row or column only if the reader would add them up.
5. **Title and notes**: a title that says what is in the table, a subtitle for the period or
   the unit, the source in a note.
6. **Emphasis, last and little**: colour for one thing only (the size of a number, or the row
   to notice). Text on the left, numbers on the right, thin rules, no grid. These are Jon
   Schwabish's [ten guidelines](https://doi.org/10.1017/bca.2020.11): space and light rules
   over boxes, and nothing that does not carry data.

## 4. Look at it

A table is not done when it compiles. Write the HTML, then run `scripts/look.js` from this
skill's folder (here `$SKILL`):

```sh
node "$SKILL/scripts/look.js" table.html
```

It writes `table-wide.png` (1100px) and `table-phone.png` (390px) and lists what it can measure:
a page that scrolls sideways, cut cells, rows far taller than the rest, pictures that did not
load. Then **read both pictures** and look for what it cannot measure:

- a title or a label shown twice, or a column that should be hidden and is not;
- a drawing too big, too small, off its line, or not on the same scale from row to row;
- labels that wrap into three lines, numbers that do not line up, a column far too wide;
- colours you cannot read text on;
- on the phone, a table that is only its first two columns.

Fix, run again, look again, until a look finds nothing. If nothing here can take a screenshot,
say so in your reply: do not write that the table looks right.

## 5. Say what you checked

In the reply: what the table shows, which numbers you checked by hand, that you looked at it
wide and on a phone (or could not), and, for a port, each thing of the original that is missing
or different and what you did instead.
