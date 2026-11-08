## devlog: 07 Nov 2026 C | Two looks: the quaderno and Munari | The pages get a second look, after Bruno Munari, the new default; the quaderno is one switch away in every header, and your choice is remembered.
## A dated post: it tells how the second look was made, and is not updated afterwards.
import std/[os, sequtils]
import nimib except md
import tabelline, tabelline/nimib
import ../blocchi

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "two-looks" / "index.html"
nb.useTabelline(nome = "tabelline",
               title = "Two looks: the quaderno and Munari", homeHref = "../", backLabel = "Devlog", nameHref = "../../")

nbTitolo "7 November 2026", "Two looks: the quaderno and Munari", """
The pages get a second look, after Bruno Munari, one switch away in every header: Munari is the new default, and your choice is remembered.
"""
nbText: """
The quaderno look (squared paper, a red margin, handwriting, tape and sticky notes) is fun, and
not for everybody: a reader found it too much. So every page now has two looks, and a switch at
the top right, **Munari | quaderno**. Munari is the default from 0.1; the quaderno is one tap
away. Try it now: the page changes in place, and the next page you open keeps the look you
picked.

## Who was Bruno Munari?

For readers outside Italy: [Bruno Munari](https://en.wikipedia.org/wiki/Bruno_Munari) (born in
Milan in 1907, died there in 1998) is one of the people who made Italian design what it is, and
one of the few who worked on everything at once. He started as a young painter among the
Futurists, and went on to be a designer of objects, lamps and furniture, a graphic designer, an
artist, a writer of books about design and seeing, a maker of children's books, and a teacher
who cared most about how children learn by doing. He did not keep those apart: for him art,
design and play were the same activity, aimed at different people.

Some of what he made, to give the range:
"""

block:  # the table only, not its code
  type Work = object
    year: int
    title, english, what: string
  let works = @[
    Work(year: 1930, title: "Macchine inutili", english: "Useless machines", what: "light mobiles of card and wood that hang and turn in the air"),
    Work(year: 1949, title: "Libri illeggibili", english: "Unreadable books", what: "books with no words: only paper, colour, cuts and holes, to be read with the eyes and hands"),
    Work(year: 1956, title: "Nella notte buia", english: "In the Dark of the Night", what: "a children's book on black, translucent and rough papers, with holes to look through"),
    Work(year: 1960, title: "La scoperta del quadrato", english: "The Discovery of the Square", what: "the first of three small books on the basic shapes; the circle followed in 1964, the triangle in 1976"),
    Work(year: 1968, title: "Design e comunicazione visiva", english: "Design and Visual Communication", what: "his lessons on how images and objects say things"),
    Work(year: 1971, title: "Abitacolo", english: "Habitacle", what: "a child's room in one steel grid: bed, shelves and desk that the child arranges"),
    Work(year: 1977, title: "Laboratorio per bambini", english: "Workshop for children", what: "the first art workshop for children in a museum, at Brera in Milan"),
    Work(year: 1981, title: "Da cosa nasce cosa", english: "One Thing Leads to Another", what: "his book on the method of design, from the problem to the simplest answer"),
  ]
  type Shown = object
    year: int
    work, what: string
  let shown = works.mapIt(Shown(year: it.year, work: "*" & it.title & "*<br>" & it.english, what: it.what))
  let worksTable = tabella(shown):
    tabHeader "Bruno Munari in eight works", "1930 to 1981: art, books, objects, teaching"
    colsLabel {"year": "", "work": "work (and in English)", "what": "what it is"}
    fmtMarkdown "work"
    colsWidth {"work": "36%"}
    tabStyle style.text(weight = "bold"), loc.body(cols = "year")
    tabSourceNote md("Dates from [Wikipedia](https://it.wikipedia.org/wiki/Bruno_Munari) (Italian and English). The useless machines date from the early 1930s. Munari won the Compasso d'Oro, Italy's design prize, in 1954, 1955 and 1979, and for his whole career in 1995.")
    optCssTheme()
  nbTable worksTable

nbText: """
Many of his books are still printed by [Corraini](https://www.corraini.com/), in Mantua, and
his way of running art workshops for children is still taught.

## Why Munari, for tabelline

The quaderno is the school notebook. Munari is the other side of an Italian school: the workshop
where children learn by cutting paper and laying shapes over each other. For a library named
after the times tables, he is the right second teacher. And he is a good teacher for anyone who
makes tables: his whole method was to remove what is not needed until what is left can be read
at a glance, which is also what gt and Great Tables ask of a good table.

## What the Munari look takes from him

Everything in it is a rule of the quaderno look, done again with less:
"""

block:  # the table only, not its code
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
    colsLabel {"quaderno": "quaderno", "munari": "Munari (default)"}
    colsWidth {"quaderno": "40%", "munari": "45%"}
    optCssTheme()
  nbTable lookTable

nbNota("""
**The motto.** *Complicare è facile, semplificare è difficile*: to complicate is easy, to
simplify is hard. It is the line of Munari's that is quoted most, from his
[*Verbale scritto*](https://it.wikiquote.org/wiki/Bruno_Munari) (1992). The Munari look puts it
at the foot of every page, as a reminder for whoever writes the next one.
""", nkInfo)

nbText: """
## How it works

- **Both looks are in every page.** The Munari rules live in `docs/munari.nim`, all under
  `html[data-tema="munari"]`, laid over the quaderno rules. The fonts are inlined
  as before (Jost adds about 40 kB), so a page is still one standalone file that loads nothing.
- **The choice is remembered** in the browser (`localStorage`, key `tabelline-tema`), and read by
  a few lines in the `<head>` before anything is drawn, so there is no flash of the other look.
- **A link can pick the look:** `?tema=munari` or `?tema=quaderno` at the end of any page's
  address, for example to share a page in the Munari look. It is remembered as well.
- **Munari is the default**: with nothing remembered, a page opens in the Munari look. Without
  JavaScript, it opens as a quaderno, the look the Munari rules are laid over.
- **Tables made with `optQuaderno()`** are dressed again by the Munari look: no squares, black
  rules, the same font as the page. Today this overrides the table's own scoped CSS, which is a
  shortcut; the clean way is a table preset `optMunari()` in the library, with its spec, if the
  look stays. Tables with styles of their own (colours, bold cells) keep them in both looks.

The three shapes are drawn with CSS only: a `border-radius` for the circle, a `clip-path` for the
triangle, and `mix-blend-mode: multiply` so that where they overlap the colours mix as they would
on a light table: red over blue goes almost black, yellow over blue goes green.
"""

nbSave
