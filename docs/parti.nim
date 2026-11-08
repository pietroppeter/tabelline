## The parts of a table, each in its own colour: the six parts of gt (and the row groups and
## spanners), drawn on any tabelline table. Used by the explainer and the home page (`nbParti`).
##
## The colours are `partTints` in `stile.nim`: light tints of Haru, the default palette of the
## Munari look, and of its neighbours among the Japanese traditional colours (nipponcolors.com).
import tabelline
import stile

type Part* = tuple[name, what, kanji, colourName: string]

const parts*: seq[Part] = @[
  ("table header", "a title and a subtitle", "菜の花", "nanohana"),
  ("column labels", "one per column, with spanner labels over groups of columns", "勿忘草", "wasurenagusa"),
  ("stub head", "the top-left corner, a label for the stub", "紅梅", "kōbai"),
  ("stub", "the row labels", "洒落柿", "sharegaki"),
  ("row groups", "labels that split the rows", "藤", "fuji"),
  ("table body", "the cells, where the data lives", "苗", "nae"),
  ("table footer", "footnotes, marked in the table, and source notes", "瓶覗", "kamenozoki"),
]

proc showParts*(t: sink Tabella): Tabella =
  ## Colours every part of `t`; later styles win, so this goes last.
  t.tabStyle(style.fill(partTints[0]), loc.title(), loc.subtitle())
   .tabStyle(style.fill(partTints[1]), loc.columnLabels(), loc.spanners())
   .tabStyle(style.fill(partTints[2]), loc.stubhead())
   .tabStyle(style.fill(partTints[3]), loc.stub())
   .tabStyle(style.fill(partTints[4]), loc.rowGroups())
   .tabStyle(style.fill(partTints[5]) & style.text(color = tinta("--n-9")), loc.body())   # over data colours too
   .tabStyle(style.fill(partTints[6]), loc.sourceNotes(), loc.footnotes())
