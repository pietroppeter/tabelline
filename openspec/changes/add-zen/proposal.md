## Why

Great Tables has an easter egg after Python's `import this`: `import great_tables.this` prints
*The Zen of Great Tables*, and in a notebook shows it as a great table. Francesco Bruzzesi wrote
it (posit-dev/great-tables#1079, November 2026); he is the friend who got tabelline started.
Pietro asked to port it to tabelline (project thread "Port the Zen of Great Tables"). Built in
the PR that adds this change.

## What Changes

- `import tabelline/this` prints *The Zen of tabelline* when the program starts.
- `import tabelline/zen` gives it without printing: `pep20` and `aphorisms` (each with the part
  of tabelline that embodies it), `zenText`, `faithfulness`, `zenData()` and `zenTable()`.
- Eleven aphorisms are Francesco's as they are; eight are retold about tabelline.
- A page, The Zen of tabelline (`docs/zen.nim`), shows the text, the table, what changed from
  Great Tables and how it is built. A row "The Zen" in the feature map.

```nim
import tabelline/this
```

## Differences from gt and Great Tables

- gt (R) has no Zen.
- Great Tables' module is `great_tables.this` and its table is `great_tables.this.table()`;
  tabelline's are `tabelline/this` and `zenTable()` in `tabelline/zen`, so the table can be had
  without the print (Nim cannot tell a notebook from a console when a module is imported).
- Eight aphorisms differ (1, 4, 6, 7, 8, 9, 14, 19), and the methods are tabelline's.
- The 20th aphorism is left to Francesco, not to Rich Iannone.
- Faithfulness is one minus the edit distance over the longer length (`std/editdistance`), not
  `difflib`'s ratio, and is coloured with `dataColor`, not drawn with `fmt_nanoplot` (not in
  tabelline yet).
- The aphorism and its original share one column, laid out by a formatter, as tabelline has no
  `colsMerge` yet.
