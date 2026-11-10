## The Zen of tabelline, a remix of Francesco Bruzzesi's *Zen of Great Tables*
## (`import great_tables.this`, posit-dev/great-tables#1079), itself a remix of Tim Peters's
## *Zen of Python* (`import this`, PEP 20).
##
## `import tabelline/zen` gives the aphorisms, the text and the table, quietly;
## `import tabelline/this` prints the text when the program starts, as `import this` does.

import std/[editdistance, strutils, unicode]
import core, formats, verbs, colors

const pep20* = [
  "Beautiful is better than ugly.",
  "Explicit is better than implicit.",
  "Simple is better than complex.",
  "Complex is better than complicated.",
  "Flat is better than nested.",
  "Sparse is better than dense.",
  "Readability counts.",
  "Special cases aren't special enough to break the rules.",
  "Although practicality beats purity.",
  "Errors should never pass silently.",
  "Unless explicitly silenced.",
  "In the face of ambiguity, refuse the temptation to guess.",
  "There should be one-- and preferably only one --obvious way to do it.",
  "Although that way may not be obvious at first unless you're Dutch.",
  "Now is better than never.",
  "Although never is often better than *right* now.",
  "If the implementation is hard to explain, it's a bad idea.",
  "If the implementation is easy to explain, it may be a good idea.",
  "Namespaces are one honking great idea -- let's do more of those!",
]
  ## *The Zen of Python*: 20 aphorisms, "only 19 of which have been written down".

const aphorisms* = [
  ("Beautiful is better than ugly, even at the console.", "echo t"),
  ("A data table is input. A display table is output.", "save()"),
  ("Simple is better than complex.", "colsHide()"),
  ("Complex is better than copying it into a spreadsheet.", "tabStyle()"),
  ("Flat is better than nested, unless it's under a spanner.", "tabSpanner()"),
  ("Sparse is better than dense, except for the *tavola pitagorica*.", "tavolaPitagorica()"),
  ("Readability counts, with a comma in Italy and a dot in England.", "fmtNumber()"),
  ("Special cases aren't special enough to break the six parts.", "rownameCol"),
  ("Although practicality beats purity, so a table may wear the page's CSS.", "optCssTheme()"),
  ("Missing values should never pass silently.", "dataColor()"),
  ("Unless explicitly `subMissing()`.", "subMissing()"),
  ("In the face of ambiguity, label your columns.", "colsLabel()"),
  ("There should be one (and preferably only one) obvious way to make a table.", "tabella()"),
  ("Although that way may not be obvious at first unless you're Italian.", "Tabella"),
  ("Now is better than never.", "fmtDatetime()"),
  ("Although the 1949 Census Manual is often better than *right* now.", "fmtRoman()"),
  ("If the table is hard to explain, add a footnote.", "tabFootnote()"),
  ("If the table is easy to explain, it may be a great table.", "tabHeader()"),
  ("Namespaces are one honking great idea: `loc` and `style` are two of those!", "loc.body()"),
]
  ## Each aphorism of the Zen of tabelline, with the part of tabelline that embodies it.
  ## Most are Francesco's, from the Zen of Great Tables; 1, 4, 6-9, 13, 14 and 19 are tabelline's.

func zenLines(): string =
  for i, (a, _) in aphorisms:
    if i > 0: result.add "\n"
    result.add a

const zenText* = "The Zen of tabelline, after the Zen of Great Tables by Francesco Bruzzesi\n\n" & zenLines()
  ## What `import tabelline/this` prints.

func faithfulness*(aphorism, original: string): float =
  ## How close an aphorism stays to its PEP 20 original, from 0 to 1: one minus the edit distance
  ## of the two (lower case, without Markdown's `` ` `` and `*`), over the length of the longer.
  let a = aphorism.multiReplace(("`", ""), ("*", "")).toLower
  let o = original.multiReplace(("`", ""), ("*", "")).toLower
  1.0 - editDistance(a, o) / max(a.runeLen, o.runeLen)

proc zenData*(): TableData =
  ## One row per aphorism, and a 20th row left empty: `n`, `aphorism` (the aphorism, a line break
  ## and its original), `method` and `faithful`.
  result = TableData()
  var n, aphorism, meth, faithful: seq[Value]
  for i, (a, m) in aphorisms:
    n.add toValue(i + 1)
    aphorism.add toValue(a & "\n" & pep20[i])
    meth.add toValue(m)
    faithful.add toValue(faithfulness(a, pep20[i]))
  n.add toValue(20)
  for col in [addr aphorism, addr meth, addr faithful]: col[].add null()
  result.addColumn("n", n)
  result.addColumn("aphorism", aphorism)
  result.addColumn("method", meth)
  result.addColumn("faithful", faithful)

proc stacked(v: Value, ctx: RenderContext): string =
  # gt would join two columns with cols_merge(); tabelline has no colsMerge yet, so the cell holds
  # both lines and this formatter lays them out: the aphorism, and its original under it.
  let parts = ($v).split('\n', 1)
  if ctx == rcHtml: inlineMarkdown(parts[0]) & "<br><small><em>" & inlineMarkdown(parts[1]) & "</em></small>"
  else: (parts[0] & " (" & parts[1] & ")").multiReplace(("`", ""), ("*", ""))

proc zenTable*(): Tabella =
  ## The Zen of tabelline, as a table.
  initTabella(zenData(), rownameCol = "n")
    .tabHeader("The Zen of tabelline",
               md("after Francesco Bruzzesi's *Zen of Great Tables*, after Tim Peters's `import this`"))
    .colsLabel({"aphorism": "Aphorism", "method": "Embodied by", "faithful": "Faithful"})
    .fmtRoman("n")
    .fmt("aphorism", stacked)
    .fmt("method", proc (v: Value, ctx: RenderContext): string =
      if ctx == rcHtml: "<code>" & escapeHtml($v) & "</code>" else: $v)
    .fmtPercent("faithful", decimals = 0)
    .dataColor("faithful", palette = palette("blues"), domain = (0.0, 1.0),
               rows = where(it["n"] < 20))
    .subMissing("aphorism", missingText = "Left for Francesco to write.")
    .subMissing(cols("method", "faithful"), missingText = "")
    .tabStyle(style.text(weight = "bold"), loc.stub())
    .tabStyle(style.text(whitespace = "nowrap"), loc.body(cols = "method"))
    .tabStyle(style.text(style = "italic"), loc.body(cols = "aphorism", rows = where(it["n"] == 20)))
    .colsAlign(alCenter, cols("method", "faithful"))
    .optRowStriping()
    # wide enough to read on a phone, where it scrolls sideways in its box
    .tabOptions(tableWidth = "max(100%, 560px)", headingAlign = "left")
    .tabFootnote("See?", loc.body(cols = "method", rows = where(it["n"] == 17)))
    .tabSourceNote("Faithful: how close an aphorism stays to its PEP 20 original, one minus the " &
                   "edit distance of the two over the length of the longer one.")
    .tabSourceNote(md("Originals: PEP 20, *The Zen of Python*, by Tim Peters. Remixed by Francesco " &
                      "Bruzzesi in *The Zen of Great Tables*, and remixed again here."))
