## The Zen of tabelline, docs/zen/index.html: Python's `import this`, Francesco Bruzzesi's Zen of
## Great Tables, and tabelline's remix of it, as text and as a table, then how it is built.
## Kept up to date: the aphorisms and the table are in src/tabelline/zen.nim.
import std/os
import nimib
import tabelline, tabelline/[nimib, zen]
import blocchi

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "zen" / "index.html"
nb.useTabelline(nome = "tabelline", materia = "The Zen", classe = "kept up to date",
               title = "The Zen of tabelline", homeHref = "../",
               description = "import tabelline/this: the Zen of tabelline, after the Zen of Great Tables.")

nbTitolo "The Zen · kept up to date", "The Zen of tabelline", """
Nineteen aphorisms about tables, after Francesco Bruzzesi's *Zen of Great Tables*, after Tim Peters's *Zen of Python*.
"""
nbIndice

nbText: """
## import this

Python has a well-known easter egg: `import this` prints *The Zen of Python*, nineteen aphorisms
by Tim Peters ([PEP 20](https://peps.python.org/pep-0020/)). The first is *Beautiful is better
than ugly*.

In November 2026 [Francesco Bruzzesi](https://github.com/FBruzzesi) gave Great Tables a Zen of
its own: `import great_tables.this` prints *The Zen of Great Tables*, each aphorism of PEP 20
retold about tables, and in a notebook it shows them as a great table
([great-tables#1079](https://github.com/posit-dev/great-tables/pull/1079)). Francesco is also the
friend who got tabelline started.

tabelline follows Great Tables, so it has a Zen too. In Nim, a module's top-level code runs when
the program starts, so importing the module is enough:

```nim
import tabelline/this
```

prints the same text as this cell, from `tabelline/zen`, which only defines it:
"""
nbCode:
  echo zenText

nbText: """
## As a table

`zenTable()` makes the Zen into a table: the aphorism with its PEP 20 original under it, the
part of tabelline that embodies it, and how faithful it stays to Tim Peters's words. The
twentieth aphorism of PEP 20 was never written, and here it is left to Francesco.
"""
nbCode:
  let t = zenTable().optCssTheme()
nbTable t
nbNota("""
The green cards are about the code. `zenTable()` is a table like any other: it comes back as a
`Tabella`, so a page can add verbs to it, as this one adds `optCssTheme()` to take the page's
colours.
""", nkCode)

nbText: """
## What changed from Great Tables

Most aphorisms are Francesco's, word for word. Eight are retold about tabelline: the console,
where a tabella prints as text; the Italian times table that gave tabelline its name; the
locales it knows; the six parts of a table; the page's colours; Italian instead of Rich (the
author of gt); and the `loc` and `style` namespaces.
"""

block:
  type Changed = object
    n: int
    greatTables, tabelline: string
  # The aphorisms of the Zen of Great Tables (great_tables/this.py) that tabelline retells.
  let greatTables = {
    1: "Beautiful is better than printed at the console.",
    4: "Complex is better than copying it into Excel.",
    6: "Sparse is better than dense, but a nanoplot can be both.",
    7: "Readability counts, in every locale from `af` to `zu`.",
    8: "Special cases aren't special enough to break the six components.",
    9: "Although `opt_css()` beats purity, provided you have those CSS skillz.",
    14: "Although that way may not be obvious at first unless you're Rich.",
    19: "Bringing your own DataFrame is one honking great idea: let's do more of those!",
  }
  var rows: seq[Changed]
  for (n, gt) in greatTables:
    rows.add Changed(n: n, greatTables: gt, tabelline: aphorisms[n - 1][0])
  let changed = tabella(rows, rownameCol = "n"):
    tabHeader "Retold for tabelline", "the other eleven are the same as in Great Tables"
    colsLabel {"greatTables": "Great Tables", "tabelline": "tabelline"}
    fmtRoman "n"
    fmtMarkdown ["greatTables", "tabelline"]
    optCssTheme()
  nbTable changed

nbText: """
## How it is built

The Zen is two small modules of the core, `src/tabelline/zen.nim` and `src/tabelline/this.nim`,
with nothing but Nim's standard library.

`zen.nim` starts from the words: `pep20`, the nineteen aphorisms of PEP 20, and `aphorisms`, the
nineteen of tabelline, each with the part of tabelline that embodies it. `zenText` joins them
under a first line, at compile time.
"""
nbFoldCode "src/tabelline/zen.nim", start = "func zenLines", stop = "func faithfulness",
           title = "`zenText`"

nbText: """
How faithful an aphorism is to its original is a number from 0 to 1: one minus the
[edit distance](https://en.wikipedia.org/wiki/Levenshtein_distance) of the two, the number of
letters to add, remove or change to turn one into the other, over the length of the longer.
"""
nbFoldCode "src/tabelline/zen.nim", start = "func faithfulness", stop = "proc zenData",
           title = "`faithfulness`"
nbNota("""
Great Tables measures the same thing with Python's `difflib.SequenceMatcher.ratio()`, which
counts matching blocks instead of edits, so its percentages are close to these but not the same.
`editDistance` is in Nim's `std/editdistance`.
""", nkCode)

nbText: """
`zenData()` makes the data: one row for each aphorism and a twentieth row with only its number,
so the missing aphorism is a missing value. The aphorism column holds two lines, the aphorism
and its original.
"""
nbFoldCode "src/tabelline/zen.nim", start = "proc zenData", stop = "proc stacked",
           title = "`zenData`"

nbText: """
`zenTable()` makes the table, verb after verb: the number is the stub, written in Roman numerals;
the two lines of an aphorism are laid out one under the other; the faithfulness is a percentage
coloured from light to dark blue; the missing aphorism gets its text; a footnote says *See?* where
the Zen says to add a footnote.
"""
nbFoldCode "src/tabelline/zen.nim", start = "proc stacked", title = "`zenTable`"
nbNota("""
Great Tables puts the aphorism and its original in two columns and joins them with `cols_merge()`.
tabelline has no `colsMerge` yet (see the [feature map](../coverage/)), so the column holds both
lines and a formatter, `stacked`, lays them out. It writes a line break in HTML and brackets in
text, so `echo zenTable()` prints a table too.
""", nkCode)

nbText: """
`this.nim` is three lines: it imports `zen`, exports it, and prints `zenText` at the top level,
which Nim runs when the program starts. Import `tabelline/zen` instead to use the Zen without
printing it.
"""
nbFoldCode "src/tabelline/this.nim", title = "`this.nim`"
nbSave
