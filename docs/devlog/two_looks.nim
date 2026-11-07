## devlog: 07 Nov 2026 | Two looks: the quaderno and Munari | The pages get a second look, after Bruno Munari, one switch away in every header; the quaderno stays the default and your choice is remembered.
## A dated post: it tells how the second look was made, and is not updated afterwards.
import std/os
import nimib except md
import tabelline, tabelline/nimib
import ../quaderno

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "two-looks" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Devlog", classe = "post · 7 November 2026",
               title = "Two looks: the quaderno and Munari", homeHref = "../")

nbText: """
<p class="kicker">Devlog · 7 November 2026</p>

# Two looks: the quaderno and Munari

<p class="lede">The pages get a second look, after Bruno Munari, one switch away in every
header; the quaderno stays the default and your choice is remembered.</p>

The quaderno look (squared paper, a red margin, handwriting, tape and sticky notes) is fun, and
not for everybody: a reader found it too much. So instead of replacing it, every page now has
two looks, and a switch at the top right, **quaderno | Munari**. Try it now: the page changes in
place, and the next page you open keeps the look you picked.

## Why Munari

[Bruno Munari](https://it.wikipedia.org/wiki/Bruno_Munari) (Milan, 1907-1998) was a painter,
designer, writer and teacher who never kept those apart. He made *macchine inutili*, useless
machines that hang and turn (from the 1930s); *libri illeggibili*, books with no words, only
paper, colour and cuts (from 1949); children's books with holes and coloured pages, like
*Nella notte buia* (1956); three small books on the three basic shapes, *La scoperta del
quadrato* (1960), *del cerchio* (1964) and *del triangolo* (1976); and books on how design
works, *Design e comunicazione visiva* (1968), *Fantasia* (1977), *Da cosa nasce cosa* (1981).
He won the Compasso d'Oro in 1954, 1955 and 1979, and in 1977 opened the first workshop for
children in a museum, at Brera.

The quaderno is the school notebook; Munari is the other side of an Italian school: the
workshop where children learn by cutting paper and laying shapes on each other. For a library
named after the times tables, he is the right second teacher.

## What the Munari look takes from him

Everything in it is a rule of the quaderno look, done again with less:
"""

nbCode:
  type Look = object
    part, quaderno, munari: string
  let looks = @[
    Look(part: "paper", quaderno: "squares, a red margin rule", munari: "plain warm white, nothing on it"),
    Look(part: "type", quaderno: "handwriting (Patrick Hand) and Atkinson Hyperlegible", munari: "one geometric sans, Jost, in two weights"),
    Look(part: "cover", quaderno: "the label of an exercise book: nome, materia, classe", munari: "the name, big; a circle, a square and a triangle laid over each other like coloured acetate"),
    Look(part: "headings", quaderno: "blue pen with a highlighter stroke", munari: "black, each after one of the three shapes, in turn"),
    Look(part: "notes", quaderno: "sticky notes, slightly crooked", munari: "flat coloured paper with a round hole cut through, as in Nella notte buia"),
    Look(part: "index", quaderno: "a sticky note in handwriting", munari: "numbers on a red circle, a blue square, a yellow triangle"),
    Look(part: "tables", quaderno: "pasted in with a strip of tape, on squared paper", munari: "a black rule above and below, pinned by a red dot"),
    Look(part: "code", quaderno: "an index card with a blue edge", munari: "a white sheet with a black edge"),
    Look(part: "footer", quaderno: "a line in pencil", munari: "his motto: complicare è facile, semplificare è difficile"),
  ]
  let lookTable = tabella(looks, rownameCol = "part"):
    tabHeader "One page, two looks", "what each part of a page becomes"
    colsLabel {"quaderno": "quaderno (default)", "munari": "Munari"}
    colsWidth {"quaderno": "40%", "munari": "45%"}
    optQuaderno()
nbTable lookTable

nbNota("""
**The motto.** *Complicare è facile, semplificare è difficile*: to complicate is easy, to
simplify is hard. It is the line of Munari's that is quoted most, from his
[*Verbale scritto*](https://it.wikiquote.org/wiki/Bruno_Munari) (1992). The Munari look puts it
at the foot of every page, as a reminder for whoever writes the next one.
""", "azzurra")

nbText: """
## How it works

- **Both looks are in every page.** The Munari rules live in `docs/munari.nim`, all under
  `html[data-tema="munari"]`, so they change nothing until the switch is on. The fonts are inlined
  as before (Jost adds about 40 kB), so a page is still one standalone file that loads nothing.
- **The choice is remembered** in the browser (`localStorage`, key `tabelline-tema`), and read by
  a few lines in the `<head>` before anything is drawn, so there is no flash of the other look.
- **A link can pick the look:** `?tema=munari` or `?tema=quaderno` at the end of any page's
  address, for example to share a page in the Munari look. It is remembered as well.
- **The quaderno is the default**: with nothing remembered, a page opens as a quaderno.
- **Tables made with `optQuaderno()`** are dressed again by the Munari look: no squares, black
  rules, the same font as the page. Today this overrides the table's own scoped CSS, which is a
  shortcut; the clean way is a table preset `optMunari()` in the library, with its spec, if the
  look stays. Tables with styles of their own (colours, bold cells) keep them in both looks.

The three shapes are drawn with CSS only: a `border-radius` for the circle, a `clip-path` for the
triangle, and `mix-blend-mode: multiply` so that where they overlap the colours mix as they would
on a light table: red over blue goes almost black, yellow over blue goes green.
"""

nbSave
