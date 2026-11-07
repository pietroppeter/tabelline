## The parts of a table, each in its own colour: the six parts of gt (and the row groups and
## spanners), drawn on any tabelline table. Used by the explainer and the home page.
##
## The colours are light tints of Haru, the default palette of the Munari look, and of its
## neighbours among the Japanese traditional colours (nipponcolors.com), so that they read
## in both looks: 菜の花 nanohana, 勿忘草 wasurenagusa, 紅梅 kōbai, 洒落柿 sharegaki, 藤 fuji,
## 苗 nae and 瓶覗 kamenozoki, each mixed with the paper (白練 shironeri) at about 40%.
import tabelline

type Part* = tuple[name, what, colour, kanji, colourName: string]

const parts*: seq[Part] = @[
  ("table header", "a title and a subtitle", "#FAECAC", "菜の花", "nanohana"),
  ("column labels", "one per column, with spanner labels over groups of columns", "#C7DFEA", "勿忘草", "wasurenagusa"),
  ("stub head", "the top-left corner, a label for the stub", "#F1BEC7", "紅梅", "kōbai"),
  ("stub", "the row labels", "#FDDFC4", "洒落柿", "sharegaki"),
  ("row groups", "labels that split the rows", "#CDC7DE", "藤", "fuji"),
  ("table body", "the cells, where the data lives", "#CAE2B7", "苗", "nae"),
  ("table footer", "footnotes, marked in the table, and source notes", "#D7EEEC", "瓶覗", "kamenozoki"),
]

proc showParts*(t: sink Tabella): Tabella =
  ## Colours every part of `t`; later styles win, so this goes last.
  t.tabStyle(style.fill(parts[0].colour), loc.title(), loc.subtitle())
   .tabStyle(style.fill(parts[1].colour), loc.columnLabels(), loc.spanners())
   .tabStyle(style.fill(parts[2].colour), loc.stubhead())
   .tabStyle(style.fill(parts[3].colour), loc.stub())
   .tabStyle(style.fill(parts[4].colour), loc.rowGroups())
   .tabStyle(style.fill(parts[5].colour) & style.text(color = "#1C1C1C"), loc.body())   # over data colours too
   .tabStyle(style.fill(parts[6].colour), loc.sourceNotes(), loc.footnotes())

func partsLegend*(): string =
  ## The parts as a list, each with a swatch of its colour.
  result = "<ul class=\"parti\">"
  for p in parts:
    result.add "<li><span class=\"tinta-parte\" style=\"background:" & p.colour & "\"></span><strong>" & p.name &
      "</strong>: " & p.what & " <span class=\"colore\">(<span lang=\"ja\">" & p.kanji & "</span> " & p.colourName & ")</span></li>"
  result.add "</ul>"

const partsCss* = """<style>
.parti { list-style: none; padding: 0; margin: .8rem 0; }
.parti li { margin: .35rem 0; padding-left: 2rem; position: relative; line-height: 1.45; }
.tinta-parte { position: absolute; left: 0; top: .25em; width: 1.3rem; height: 1rem; outline: 1px solid rgba(0,0,0,.15); }
.parti .colore { color: var(--muted); font-size: .88em; }
.vista-parti[hidden] { display: none !important; }
.mostra-parti { font: 700 .72rem/1.6 var(--text); letter-spacing: .14em; text-transform: uppercase; cursor: pointer;
  border: 2px solid var(--pencil); background: transparent; color: var(--pencil); padding: .3rem .8rem; margin: .2rem 0 0; }
.mostra-parti[aria-pressed="true"] { background: var(--pencil); color: var(--paper); }
</style>"""
