## devlog: 07 Nov 2026 D | Munari meets Japan: palettes for the second look | The Munari look gets softer colours, taken from Japan's traditional colour names, and loses the dots and holes that looked like buttons. What each colour does on a page, six palettes to swipe through, and the stories behind the names.
## A dated post: it tells how the palettes were chosen, and is not updated afterwards.
import std/[os, strutils, strformat, sequtils]
import nimib except md
import tabelline, tabelline/nimib
import ../quaderno

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "palettes" / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Devlog", classe = "post · 7 November 2026",
               title = "Munari meets Japan: palettes for the second look", homeHref = "../")

# ------------------------------------------------------------------------------------ palettes
type
  Colour = object
    kanji, name, gloss, hex, story: string
  Palette = object
    key, title, mood: string
    colours: array[6, Colour]   # in the order of `roles`

const roles = ["carta", "inchiostro", "cerchio", "quadrato", "triangolo", "quarto"]
const roleNames = ["paper", "ink", "circle", "square", "triangle", "fourth"]

func c(kanji, name, gloss, hex: string, story = ""): Colour =
  Colour(kanji: kanji, name: name, gloss: gloss, hex: hex, story: story)

# Every Japanese colour is from NIPPON COLORS (nipponcolors.com), as listed in the npm package
# nippon-colors 1.0.0 (MIT): kanji, romanized name and value. Glosses and stories are ours.
let shironeri = c("白練", "shironeri", "white silk", "#FCFAF2",
  "silk that has been boiled to take the gum out of it: soft, with a quiet shine. A white that is not quite white.")
let sumi = c("墨", "sumi", "ink stick", "#1C1C1C",
  "the ink of calligraphy: a stick of soot and glue, ground with water on a stone. Its black is never flat.")
let palettes = @[
  Palette(key: "haru", title: "Haru, spring",
    mood: "Plum blossom, forget-me-not and rapeseed: lighter and gentler, closer to a children's book. The default: Pietro's pick.",
    colours: [shironeri, sumi,
      c("紅梅", "kōbai", "red plum blossom", "#E16B8C",
        "plum trees flower in late winter, weeks before the cherries; at the old court it was a colour worn at the end of winter."),
      c("勿忘草", "wasurenagusa", "forget-me-not", "#7DB9DE",
        "\"the grass of do-not-forget\": a word-for-word translation of the European name, so one of the younger names in the list."),
      c("菜の花", "nanohana", "rapeseed flower", "#F7D94C",
        "the yellow of whole fields in spring; the buds are eaten too, briefly boiled."),
      c("苗", "nae", "seedling", "#86C166",
        "the green of rice seedlings, just before they are planted out in the flooded fields.")]),
  Palette(key: "shojohi", title: "Shōjōhi, ruri, kuchinashi",
    mood: "Munari's primaries in Japanese pigments: nearly the same red and blue, and a yellow that stays quiet. The first default, for a few hours.",
    colours: [shironeri, sumi,
      c("猩猩緋", "shōjōhi", "scarlet", "#E83015",
        "named after the shōjō, a red-haired spirit of the Noh stage who loves sake. It was the colour of the imported woollen cloth that warlords of the 1500s wore over their armour."),
      c("瑠璃", "ruri", "lapis lazuli", "#005CAF",
        "the blue stone, one of the seven treasures of the Buddhist sutras."),
      c("梔子", "kuchinashi", "gardenia", "#F6C555",
        "the gardenia, whose fruit gives a yellow dye (it still colours sweet chestnuts at New Year). The name can be read as \"no mouth\", because the ripe fruit never opens."),
      c("若竹", "wakatake", "young bamboo", "#5DAC81",
        "the green of bamboo in its first year, before it darkens.")]),
  Palette(key: "wabi", title: "Wabi, earth",
    mood: "Red earth, indigo grey and mustard, with charcoal for ink: muted, like a print on handmade paper.",
    colours: [shironeri,
      c("消炭", "keshizumi", "spent charcoal", "#434343",
        "charcoal put out before it burns through: light, and quick to light again. A soft black for ink."),
      c("弁柄", "bengara", "red iron oxide", "#9A5034",
        "named after Bengal, where it was first imported from. It paints the wooden lattices of the old town houses of Kyoto."),
      c("藍鼠", "ainezumi", "indigo grey", "#566C73",
        "nezumi, mouse, means grey. When Edo-period laws forbade bright colours to merchants, dyers answered with so many subtle shades that people spoke of \"48 browns and 100 greys\"."),
      c("芥子", "karashi", "mustard", "#CAAD5F",
        "mustard, the hot yellow paste served with oden and nattō."),
      c("青丹", "aoni", "green earth", "#516E41",
        "a green-blue earth used as a pigment; \"aoni yoshi\", fine with green earth, is the old poetic epithet of Nara.")]),
  Palette(key: "aizome", title: "Aizome, indigo dyeing",
    mood: "Blues from one dye vat, from deep to the palest, with one scarlet circle and navy for ink.",
    colours: [
      c("胡粉", "gofun", "shell white", "#FFFFFB",
        "white from oyster shells, weathered for years and ground fine: the white of doll faces and of Japanese painting."),
      c("紺", "kon", "navy", "#0F2540",
        "the deepest indigo, from cloth dipped again and again; workers' clothes were kon, and dyers' shops are still called kon'ya."),
      c("緋", "ake", "scarlet", "#CC543A",
        "an old word for bright red, dyed with madder root."),
      c("縹", "hanada", "light indigo", "#006284",
        "the old name of the plain blue of indigo-dyed cloth, between the palest and the deepest."),
      c("瓶覗", "kamenozoki", "a peek into the vat", "#A5DEE4",
        "the palest indigo, from cloth dipped only once, as if it had just peeked into the vat. A name Munari could have given."),
      c("青磁", "seiji", "celadon", "#69B0AC",
        "the grey-green glaze of celadon porcelain, from China and Korea, treasured in Japan for centuries.")]),
  Palette(key: "edo", title: "Edo, the city",
    mood: "Edo purple, Shinbashi blue and kerria gold: the fashion colours of old Tokyo. The loudest of the Japanese ones.",
    colours: [shironeri, sumi,
      c("江戸紫", "edomurasaki", "Edo purple", "#77428D",
        "the bluish purple of Edo (Tokyo), against the reddish purple of Kyoto; the headband of Sukeroku, a dashing hero of kabuki."),
      c("新橋", "shinbashi", "Shinbashi blue", "#0089A7",
        "a bright blue of the new chemical dyes, loved around 1900 by the geisha of Shinbashi, in Tokyo, who made it the fashion."),
      c("山吹", "yamabuki", "kerria flower", "#FFB11B",
        "the golden yellow of the kerria flower, and in Edo slang the colour of gold coins: in period dramas a bribe is \"sweets the colour of yamabuki\"."),
      c("萌黄", "moegi", "fresh sprouts", "#7BA23F",
        "the green of new shoots in spring.")]),
  Palette(key: "primari", title: "Primari, before today",
    mood: "The first Munari look, until this morning: printer's primaries, bold, and the yellow shouts.",
    colours: [c("", "warm white", "", "#FBF9F4"), c("", "black", "", "#141414"),
      c("", "red", "", "#E2231A"), c("", "blue", "", "#1F5FBF"),
      c("", "yellow", "", "#FFCC00"), c("", "green", "", "#5FAF55")]),
]

func vars(p: Palette): string =
  for i, r in roles: result.add &"--m-{r}:{p.colours[i].hex};"

func label(x: Colour): string =
  if x.kanji == "": x.name else: &"<span lang=\"ja\">{x.kanji}</span> {x.name}"

proc card(p: Palette, i: int): string =
  var swatches = ""
  for k, x in p.colours:
    swatches.add &"""<li><span class="tinta" style="background:{x.hex}"></span><span class="ruolo">{roleNames[k]}</span>{x.label}</li>"""
  let nomi = p.colours.mapIt(it.label & " <code>" & it.hex & "</code>").join("|").replace("\"", "&quot;")
  &"""<section class="scheda" style="{p.vars}" data-vars="{p.vars}" data-nomi="{nomi}" data-titolo="{i + 1} · {p.title}" aria-label="palette {i + 1}: {p.title}">
<div class="foglio" aria-hidden="true"><i class="c"></i><i class="q"></i><i class="t"></i><b>{i + 1}</b></div>
<h3>{p.title}</h3>
<p>{p.mood}</p>
<ul class="tinte">{swatches}</ul>
</section>"""

nbRawHtml: """<style>
/* the summary: what each of the six colours does */
.sei { list-style: none; padding: 0; margin: 1rem 0 .4rem; }
.sei li { display: grid; grid-template-columns: 2.2rem 1fr; gap: 0 .7rem; padding: .45rem 0; border-top: 1px solid var(--rule, #ddd); }
.sei li:last-child { border-bottom: 1px solid var(--rule, #ddd); }
.sei .tinta { grid-row: span 2; width: 2.2rem; height: 2.2rem; outline: 1px solid rgba(0,0,0,.12); }
.sei .cerchio-t { border-radius: 50%; } .sei .triangolo-t { clip-path: polygon(50% 0, 100% 100%, 0 100%); outline: 0; }
.sei strong { font-weight: 700; } .sei .nome { color: var(--muted); font-size: .9rem; }
.sei .usi { font-size: .92rem; line-height: 1.4; }
.ora { font-size: .9rem; color: var(--muted); margin: .2rem 0 1rem; }
/* the gallery: swipe to pick */
.galleria { display: flex; gap: .8rem; overflow-x: auto; scroll-snap-type: x mandatory; padding: .2rem 0 .8rem;
  margin: 0 -1rem; padding-left: 1rem; scroll-padding-left: 1rem; -webkit-overflow-scrolling: touch; }
.galleria::after { content: ""; flex: 0 0 .2rem; }
.scheda { flex: 0 0 min(84%, 24rem); scroll-snap-align: start; background: var(--m-carta); color: var(--m-inchiostro);
  border: 1px solid color-mix(in srgb, var(--m-inchiostro) 18%, var(--m-carta)); padding: 0 1rem .8rem; }
.scheda .foglio { position: relative; isolation: isolate; height: 6.5rem; margin: 0 -1rem .6rem; overflow: hidden;
  border-bottom: 1px solid color-mix(in srgb, var(--m-inchiostro) 12%, var(--m-carta)); }
.scheda .foglio i { position: absolute; display: block; mix-blend-mode: multiply; }
.scheda .foglio .c { width: 3.8rem; height: 3.8rem; border-radius: 50%; background: var(--m-cerchio); right: 1rem; top: .5rem; }
.scheda .foglio .q { width: 2.9rem; height: 2.9rem; background: var(--m-quadrato); right: 3.3rem; top: 2rem; }
.scheda .foglio .t { width: 3.5rem; height: 3.1rem; background: var(--m-triangolo); right: 1.7rem; top: 2.6rem; clip-path: polygon(50% 0, 100% 100%, 0 100%); }
.scheda .foglio b { position: absolute; left: 1rem; top: .4rem; font: 700 3rem/1 "Jost", system-ui, sans-serif; color: var(--m-inchiostro); }
.scheda h3 { margin: 0 0 .2rem !important; font: 700 1.15rem/1.25 "Jost", system-ui, sans-serif !important; color: var(--m-inchiostro) !important; }
.scheda p { margin: 0 0 .6rem; font-size: .92rem; line-height: 1.45; }
.scheda .tinte { list-style: none; padding: 0; margin: 0; font-size: .86rem; }
.scheda .tinte li { margin: .12rem 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.scheda .tinta, .tinte-tab .tinta { display: inline-block; width: 1.5rem; height: .75rem; margin-right: .45rem; vertical-align: -.03rem;
  outline: 1px solid rgba(0,0,0,.12); }
.scheda .ruolo { display: inline-block; width: 3.9rem; opacity: .65; }
/* the anatomy */
.parte { font: 700 .7rem/1.3 var(--text); letter-spacing: .16em; text-transform: uppercase; color: var(--muted); margin: 1.6rem 0 -.6rem; }
</style>"""

nbText: """
<p class="kicker">Devlog · 7 November 2026</p>

# Munari meets Japan: palettes for the second look

<p class="lede">The Munari look gets softer colours, from Japan's traditional colour names, and
loses the dots and holes that looked like buttons. Here is what each colour does, six palettes
to swipe through, and the stories behind their names.</p>

## The page in six colours

A Munari page is drawn with six colours, named after where they go rather than their hue: the
same role can be scarlet in one palette and purple in another. Everything else (the tints of the
notes, the lines of the tables, the greys, the colours used as text, with a little ink mixed in
so that they stay readable) is mixed from these six.
"""

nbRawHtml: """<ul class="sei">
<li><span class="tinta" style="background:var(--m-carta)"></span><span><strong>paper</strong> <span class="nome" data-ruolo="0"></span></span><span class="usi">the page; mixed into every tint</span></li>
<li><span class="tinta" style="background:var(--m-inchiostro)"></span><span><strong>ink</strong> <span class="nome" data-ruolo="1"></span></span><span class="usi">text, headings, links, rules, code edges, the look switch</span></li>
<li><span class="tinta cerchio-t" style="background:var(--m-cerchio)"></span><span><strong>circle</strong> <span class="nome" data-ruolo="2"></span></span><span class="usi">the big circle; kickers, third-level headings and link underlines; code keywords and built-ins; the red start of a table; the rosa note</span></li>
<li><span class="tinta" style="background:var(--m-quadrato)"></span><span><strong>square</strong> <span class="nome" data-ruolo="3"></span></span><span class="usi">the big square; code strings; the azzurra note</span></li>
<li><span class="tinta triangolo-t" style="background:var(--m-triangolo)"></span><span><strong>triangle</strong> <span class="nome" data-ruolo="4"></span></span><span class="usi">the big triangle (never text: too light); the plain note, table group headings, quotes, link hover</span></li>
<li><span class="tinta" style="background:var(--m-quarto)"></span><span><strong>fourth</strong> <span class="nome" data-ruolo="5"></span></span><span class="usi">the fourth note (verde); numbers and literals in code</span></li>
</ul>
<p class="ora">Showing: <strong class="titolo-ora">1 · Haru, spring</strong>. In the quaderno look the page keeps its own colours; switch to Munari at the top to see a palette on the whole page.</p>"""

nbText: """
## Six palettes: swipe to choose

Swipe the cards: the one in front paints this page, from the shapes at the top to the code below.
Nothing is remembered, and the next page opens with the default, palette 1.
"""

nbRawHtml: "<div class=\"galleria\" tabindex=\"0\" aria-label=\"palettes: swipe or scroll sideways to choose\">" &
  toSeq(0 ..< palettes.len).mapIt(card(palettes[it], it)).join("\n") & "</div>"

nbText: """
Two rules came with the new colours. **Nothing that only decorates may look like something to
press or drag**: the round hole that every note had (after Munari's *Nella notte buia*) looked like
a radio button, so it is gone, and so is the red dot that pinned each table, now the first stretch
of its top rule. And **the yellow is never text**: too light to read, it only fills.

## Anatomy of a page

Everything in this section is the real thing, in the palette in front above.

<p class="parte">Text</p>

Body text is Jost at 18 pixels, ink on paper. A [link](../) is ink with an underline in the circle
colour, filled with the triangle colour when touched; *emphasis* is the italic of the same font,
and `inline code` sits on paper with a little ink in it.

> A quote has a bar in the triangle colour, and nothing else.

### A third-level heading, in the circle colour

Second-level headings, like those of this page, take one of the three shapes in turn: circle,
square, triangle.

<p class="parte">Notes</p>
"""

nbNota("**The plain note** is paper with a third of the triangle in it, and the full triangle along its top edge.")
nbNota("**The azzurra note** does the same with the square.", "azzurra")
nbNota("**The rosa note** with the circle.", "rosa")
nbNota("**The verde note** with the fourth colour, which is green in most palettes, but need not be.", "verde")

nbText: """<p class="parte">Code and its output</p>

Keywords take the circle in bold, and built-ins like `echo` and `string` the circle without;
strings take the square, numbers and literals the fourth colour; types are bold ink; comments and
pragmas are grey. Nothing in code is underlined, so nothing looks like a link."""

nbCode:
  {.push warnings: off.}     # a pragma
  type Iro = object          # a comment
    name: string
  proc show(c: Iro, n = 250): string =
    c.name & ", one of " & $n
  echo show(Iro(name: "梔子")), " ", true
  echo len("kuchinashi")

nbText: """<p class="parte">A table</p>"""

block:
  type Book = object
    shape, book: string
    year, sides: int
    decade: string
  let books = @[
    Book(shape: "square", book: "La scoperta del quadrato", year: 1960, sides: 4, decade: "the 1960s"),
    Book(shape: "circle", book: "La scoperta del cerchio", year: 1964, sides: 0, decade: "the 1960s"),
    Book(shape: "triangle", book: "La scoperta del triangolo", year: 1976, sides: 3, decade: "the 1970s"),
  ]
  let t = tabella(books, rownameCol = "shape", groupnameCol = "decade"):
    tabHeader "Munari's three shapes", "a small book for each"
    fmtMarkdown "book"
    tabSourceNote "Black rules above and below, the top one starting in the circle colour; group headings in a tint of the triangle."
    optQuaderno()
  nbTable t

nbText: """
## The styles in detail

Every part of the page, its type and the colours it takes. The colour column follows the palette
in front.
"""

block:  # the table only, not its code
  type Part = object
    part, element, typeface, colour, swatch: string
  func p(part, element, typeface, colour: string): Part =
    Part(part: part, element: element, typeface: typeface, colour: colour)
  let parts = @[
    p("cover", "name", "Jost 700, 3.4rem, tight", "ink"),
    p("cover", "three shapes", "", "circle, square, triangle, multiplied where they overlap"),
    p("header", "crumbs, look switch", "Jost 700, small, spaced capitals", "ink; the switch is the only button"),
    p("text", "kicker", "Jost 700, small, spaced capitals", "circle, as text"),
    p("text", "title, headings", "Jost 700, 2.9 / 1.85rem", "ink; heading marks in the three shapes"),
    p("text", "third-level headings", "Jost 700, 1.25rem", "circle, as text"),
    p("text", "body", "Jost 400, 18px, line 1.6", "ink on paper"),
    p("text", "links", "", "ink, underline in circle, triangle on touch"),
    p("notes", "plain, azzurra, rosa, verde", "Jost 400; titles 700", "a third of triangle, square, circle, fourth; the full colour on top"),
    p("code", "block", "monospace, on white", "a 2px ink edge"),
    p("code", "keywords", "bold", "circle, as text"),
    p("code", "strings", "", "square, as text"),
    p("code", "numbers, literals", "", "fourth, as text"),
    p("code", "built-ins", "", "circle, as text"),
    p("code", "types", "bold", "ink"),
    p("code", "comments, pragmas", "italic; plain", "grey (ink in paper)"),
    p("code", "output", "monospace", "ink on grey paper, label in circle"),
    p("tables", "rules", "Jost, the page's", "ink, 3px; the top starts in circle"),
    p("tables", "group headings", "", "a tint of triangle"),
    p("index", "numbers", "Jost 700", "on a circle, a square, a triangle in turn"),
    p("footer", "motto", "Jost 700, 1.35rem", "ink; the name in circle"),
  ]
  const swatchOf = {"circle": "var(--m-cerchio)", "square": "var(--m-quadrato)", "triangle": "var(--m-triangolo)",
                    "fourth": "var(--m-quarto)", "ink": "var(--m-inchiostro)"}
  var t = tabella(parts, groupnameCol = "part", rownameCol = "element"):
    tabHeader "One page, part by part", "the Munari look"
    colsLabel {"typeface": "type", "colour": "colour", "swatch": ""}
    colsWidth {"swatch": "1.6em", "typeface": "30%"}
    optQuaderno()
  for i, x in parts:   # the swatch is the first colour the row names
    var first = (x.colour.len, "")
    for (k, v) in swatchOf:
      let at = x.colour.find(k)
      if at >= 0 and at < first[0]: first = (at, v)
    if first[1] != "": t = t.tabStyle(style.fill(first[1]), loc.body(cols = "swatch", rows = [i]))
  nbTable t

nbText: """
## The names, and their stories

Japan has hundreds of named colours, each after a plant, a dye, a mineral or a creature, many of
them centuries old. Every Japanese colour here is from
[NIPPON COLORS](https://nipponcolors.com/), a list of 250 with their kanji. The stories are the
ones told about these names; one or two are legends.
"""

block:
  var html = ""
  var seen: seq[string]
  for i, p in palettes:
    if p.key == "primari": continue
    var items = ""
    for k, x in p.colours:
      if x.story == "" or x.name in seen: continue
      seen.add x.name
      items.add &"""<li><span class="tinta" style="background:{x.hex}"></span><strong>{x.label}</strong>, {x.gloss} ({roleNames[k]}): {x.story}</li>"""
    html.add &"""<p class="parte">{i + 1} · {p.title}</p><ul class="nomi">{items}</ul>"""
  nbRawHtml: """<style>.nomi { list-style: none; padding: 0; } .nomi li { margin: .7rem 0; line-height: 1.5; }
.nomi .tinta { display: inline-block; width: 1.5rem; height: .75rem; margin-right: .45rem; outline: 1px solid rgba(0,0,0,.12); }</style>""" & html

nbRawHtml: """<details class="tutti"><summary>All the colours, with their contrast on paper</summary>"""

block:  # the table only, not its code
  type Row = object
    palette, role, colour, swatch, hex: string
    contrast: float
  var rows: seq[Row]
  for i, p in palettes:
    for k, x in p.colours:
      if k == 0: continue
      rows.add Row(palette: &"{i + 1} · " & p.title.split(",")[0], role: roleNames[k],
                   colour: (if x.kanji == "": x.name else: x.kanji & " " & x.name), swatch: "", hex: x.hex,
                   contrast: contrast(parseColor(x.hex), parseColor(p.colours[0].hex)))
  var t = tabella(rows, groupnameCol = "palette"):
    tabHeader "Six palettes", "each colour on the paper of its palette"
    colsLabel {"role": "", "swatch": "", "hex": "value", "contrast": "contrast"}
    fmtNumber "contrast", decimals = 1
    colsWidth {"swatch": "1.6em"}
    tabSourceNote md("Contrast ratio after WCAG 2: 4.5 is enough for small text, 3 for large. As text, the page mixes a little ink into the circle, square and fourth colours, so they read better than these numbers say.")
    optQuaderno()
  for i, r in rows:
    t = t.tabStyle(style.fill(r.hex), loc.body(cols = "swatch", rows = [i]))
  nbTable t

nbRawHtml: "</details>"

nbText: """
Palette 1, Haru, is the default: the gentlest, and the one a children's book would pick. Any of the others can take its place by changing six lines of
`docs/munari.nim`.
"""

nbRawHtml: """<script>
(function () {
  var root = document.documentElement, base = root.getAttribute('style') || '';
  var cards = Array.prototype.slice.call(document.querySelectorAll('.scheda'));
  var current = null;
  function apply(card) {
    if (card === current) return;
    current = card;
    root.setAttribute('style', base + ';' + card.dataset.vars);
    var nomi = card.dataset.nomi.split('|');
    document.querySelectorAll('.sei .nome').forEach(function (s) { s.innerHTML = nomi[+s.dataset.ruolo]; });
    document.querySelector('.titolo-ora').textContent = card.dataset.titolo;
  }
  apply(cards[0]);
  var gallery = document.querySelector('.galleria');
  function pick() {
    var left = gallery.getBoundingClientRect().left, best = cards[0], d = Infinity;
    cards.forEach(function (c) {
      var x = Math.abs(c.getBoundingClientRect().left - left - 16);
      if (x < d) { d = x; best = c; }
    });
    apply(best);
  }
  var timer;
  gallery.addEventListener('scroll', function () { clearTimeout(timer); timer = setTimeout(pick, 60); }, { passive: true });
})();
</script>"""

nbSave
