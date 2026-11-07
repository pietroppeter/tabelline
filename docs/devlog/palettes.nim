## devlog: 07 Nov 2026 D | Munari meets Japan: palettes for the second look | The Munari look gets softer colours, taken from Japan's traditional colour names, and loses the dots and holes that looked like buttons. Six palettes to compare, and a button on each to try it on this page.
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

type
  Colour = object
    kanji, name, gloss, hex: string
  Palette = object
    key, title, mood: string
    carta, inchiostro, rosso, blu, giallo, verde: Colour

func c(kanji, name, gloss, hex: string): Colour = Colour(kanji: kanji, name: name, gloss: gloss, hex: hex)

# Every Japanese colour below is from NIPPON COLORS (nipponcolors.com), as listed in the npm
# package nippon-colors 1.0.0 (MIT): kanji, romanized name and value. The glosses are ours.
let palettes = @[
  Palette(key: "primari", title: "0 · Primari, the first Munari",
          mood: "The look as it was until this morning: printer's primaries. Bold, and the yellow shouts.",
          carta: c("", "warm white", "paper", "#FBF9F4"), inchiostro: c("", "black", "ink", "#141414"),
          rosso: c("", "red", "Munari red", "#E2231A"), blu: c("", "blue", "", "#1F5FBF"),
          giallo: c("", "yellow", "", "#FFCC00"), verde: c("", "green", "", "#5FAF55")),
  Palette(key: "shojohi", title: "1 · Shōjōhi, ruri, kuchinashi",
          mood: "Munari's primaries again, in Japanese pigments: almost the same red and blue, and a gardenia yellow that stays quiet. The new default.",
          carta: c("白練", "shironeri", "white silk", "#FCFAF2"), inchiostro: c("墨", "sumi", "ink stick", "#1C1C1C"),
          rosso: c("猩猩緋", "shōjōhi", "scarlet", "#E83015"), blu: c("瑠璃", "ruri", "lapis lazuli", "#005CAF"),
          giallo: c("梔子", "kuchinashi", "gardenia", "#F6C555"), verde: c("若竹", "wakatake", "young bamboo", "#5DAC81")),
  Palette(key: "haru", title: "2 · Haru, spring",
          mood: "Plum blossom, forget-me-not and rapeseed flowers: lighter and gentler, closer to a children's book.",
          carta: c("白練", "shironeri", "white silk", "#FCFAF2"), inchiostro: c("墨", "sumi", "ink stick", "#1C1C1C"),
          rosso: c("紅梅", "kōbai", "red plum blossom", "#E16B8C"), blu: c("勿忘草", "wasurenagusa", "forget-me-not", "#7DB9DE"),
          giallo: c("菜の花", "nanohana", "rapeseed flower", "#F7D94C"), verde: c("苗", "nae", "seedling", "#86C166")),
  Palette(key: "wabi", title: "3 · Wabi, earth",
          mood: "Red earth, indigo grey and mustard, with charcoal for ink: muted, like a print on handmade paper.",
          carta: c("白練", "shironeri", "white silk", "#FCFAF2"), inchiostro: c("消炭", "keshizumi", "spent charcoal", "#434343"),
          rosso: c("弁柄", "bengara", "red iron oxide", "#9A5034"), blu: c("藍鼠", "ainezumi", "indigo grey", "#566C73"),
          giallo: c("芥子", "karashi", "mustard", "#CAAD5F"), verde: c("青丹", "aoni", "green earth", "#516E41")),
  Palette(key: "aizome", title: "4 · Aizome, indigo dyeing",
          mood: "Blues from one dye vat, from deep to the palest, with one vermilion circle and dark blue for ink.",
          carta: c("胡粉", "gofun", "shell white", "#FFFFFB"), inchiostro: c("紺", "kon", "navy", "#0F2540"),
          rosso: c("緋", "ake", "scarlet", "#CC543A"), blu: c("縹", "hanada", "light indigo", "#006284"),
          giallo: c("瓶覗", "kamenozoki", "a peek into the vat", "#A5DEE4"), verde: c("青磁", "seiji", "celadon", "#69B0AC")),
  Palette(key: "edo", title: "5 · Edo, the city",
          mood: "Edo purple, Shinbashi blue and kerria gold: the fashionable colours of old Tokyo. The loudest of the Japanese ones.",
          carta: c("白練", "shironeri", "white silk", "#FCFAF2"), inchiostro: c("墨", "sumi", "ink stick", "#1C1C1C"),
          rosso: c("江戸紫", "edomurasaki", "Edo purple", "#77428D"), blu: c("新橋", "shinbashi", "Shinbashi blue", "#0089A7"),
          giallo: c("山吹", "yamabuki", "kerria flower", "#FFB11B"), verde: c("萌黄", "moegi", "fresh sprouts", "#7BA23F")),
]

func roles(p: Palette): seq[(string, Colour)] =
  @[("paper", p.carta), ("ink", p.inchiostro), ("circle", p.rosso), ("square", p.blu),
    ("triangle", p.giallo), ("green", p.verde)]

func vars(p: Palette): string =
  &"--m-carta:{p.carta.hex};--m-inchiostro:{p.inchiostro.hex};--m-rosso:{p.rosso.hex};" &
    &"--m-blu:{p.blu.hex};--m-giallo:{p.giallo.hex};--m-verde:{p.verde.hex}"

func label(x: Colour): string =
  if x.kanji == "": x.name else: &"<span lang=\"ja\">{x.kanji}</span> {x.name}"

proc specimen(p: Palette): string =
  var swatches = ""
  for (role, x) in p.roles:
    swatches.add &"""<li><span class="tinta" style="background:{x.hex}"></span><span class="ruolo">{role}</span> {x.label} <code>{x.hex}</code></li>"""
  result = &"""<figure class="campione" style="{p.vars}">
<div class="foglio">
  <div class="mini-forme" aria-hidden="true"><i class="c"></i><i class="q"></i><i class="t"></i></div>
  <p class="mini-titolo">tabelline</p>
  <div class="mini-note"><i class="n g"></i><i class="n b"></i><i class="n r"></i><i class="n v"></i></div>
</div>
<figcaption><strong>{p.title}</strong><br>{p.mood}</figcaption>
<ul class="tinte">{swatches}</ul>
<button type="button" class="prova" data-vars="{p.vars}">Try it on this page</button>
</figure>"""

nbRawHtml: """<style>
.campione { margin: 1.6rem 0 2.2rem; }
.campione .foglio { position: relative; isolation: isolate; height: 9rem; background: var(--m-carta);
  border: 1px solid color-mix(in srgb, var(--m-inchiostro) 18%, var(--m-carta)); overflow: hidden; }
.campione .mini-forme { position: absolute; right: .8rem; top: .7rem; width: 7rem; height: 6.5rem; }
.campione .mini-forme i { position: absolute; display: block; mix-blend-mode: multiply; }
.campione .mini-forme .c { width: 4.6rem; height: 4.6rem; border-radius: 50%; background: var(--m-rosso); right: 0; top: 0; }
.campione .mini-forme .q { width: 3.4rem; height: 3.4rem; background: var(--m-blu); right: 2.7rem; top: 2rem; }
.campione .mini-forme .t { width: 4.2rem; height: 3.7rem; background: var(--m-giallo); right: .9rem; top: 2.7rem;
  clip-path: polygon(50% 0, 100% 100%, 0 100%); }
.campione .mini-titolo { position: absolute; left: 1rem; top: .6rem; margin: 0; font: 700 2rem/1 "Jost", system-ui, sans-serif;
  letter-spacing: -.03em; color: var(--m-inchiostro); }
.campione .mini-note { position: absolute; left: 1rem; bottom: .9rem; display: flex; gap: .4rem; }
.campione .mini-note .n { display: block; width: 3.4rem; height: 2.2rem; border-top: 4px solid; }
.campione .n.g { background: color-mix(in srgb, var(--m-giallo) 38%, var(--m-carta)); border-color: var(--m-giallo); }
.campione .n.b { background: color-mix(in srgb, var(--m-blu) 20%, var(--m-carta)); border-color: var(--m-blu); }
.campione .n.r { background: color-mix(in srgb, var(--m-rosso) 20%, var(--m-carta)); border-color: var(--m-rosso); }
.campione .n.v { background: color-mix(in srgb, var(--m-verde) 26%, var(--m-carta)); border-color: var(--m-verde); }
.campione figcaption { margin: .7rem 0 .4rem; }
.campione .tinte { list-style: none; padding: 0; margin: 0 0 .7rem; columns: 2 15rem; font-size: .9rem; }
.campione .tinte li { break-inside: avoid; margin: .15rem 0; }
.campione .tinta { display: inline-block; width: 1.6rem; height: .8rem; vertical-align: -.05rem; margin-right: .4rem;
  outline: 1px solid rgba(0,0,0,.12); }
.campione .ruolo { display: inline-block; width: 4.4rem; color: var(--muted); }
.campione code { font-size: .8rem; }
.prova, .ripristina { font: 700 .72rem/1.6 var(--text); letter-spacing: .14em; text-transform: uppercase; cursor: pointer;
  border: 2px solid var(--pencil); background: transparent; color: var(--pencil); padding: .3rem .8rem; }
.prova[aria-pressed="true"] { background: var(--pencil); color: var(--paper); }
.ripristina { display: block; margin: 1rem 0; }
</style>"""

nbText: """
<p class="kicker">Devlog · 7 November 2026</p>

# Munari meets Japan: palettes for the second look

<p class="lede">The Munari look gets softer colours, taken from Japan's traditional colour names,
and loses the dots and holes that looked like buttons. Here are six palettes side by side, with a
button on each to try it on this page.</p>

The [Munari look](../two-looks/) came out this morning with printer's primaries: a red, a blue and
a yellow at full strength. On a phone, the yellow was too strong: a whole card of it shouts. And
the first reader of the look found something else: every note had a round hole cut in its top
corner, after Munari's *Nella notte buia*, and on a screen a white circle in the corner of a card
looks like a radio button: something to press, that does nothing.

## Two rules, fixed today

- **Softer colours.** The yellow is now *kuchinashi*, the yellow of gardenia, and the coloured
  paper of the notes is mixed from the palette at about a third of its strength, with the full
  colour only along the top edge.
- **Nothing that only decorates may look like something to press or drag.** So the hole is gone
  from the notes, and the red dot that pinned each table, which could pass for a notification, is
  now the first stretch of the table's top rule, drawn in red. What is left that looks like a
  button is a button: the look switch at the top, and the buttons on this page. The three big
  shapes of the cover stay: they are too large to read as controls, and they do not take clicks.

## Why Japanese colours

Japan has a long tradition of named colours: hundreds of them, each named after a plant, a dye,
a mineral or an animal, many of them centuries old. They are
colours that people chose and used for a long time, so they sit well together, and they are
gentler than the colours of a printer's ink. A curated list of 250, with kanji, names and values,
is [NIPPON COLORS](https://nipponcolors.com/); every Japanese colour on this page is from that
list.

The names are a pleasure in themselves: *kamenozoki*, "a peek into the vat", is the palest
blue, of cloth dipped in indigo only briefly. It feels like a name Munari could have given.

The idea is to keep everything of Munari but the inks: the three shapes over each other, the
flat paper, one typeface. Only the six colours change: paper, ink, and the circle, the square,
the triangle and a green for the notes. Everything else (the tints of the notes, the lines of the
tables, the grey of small text) is mixed from those six in the CSS, so a palette is six values.

## Six palettes

Each has a specimen and its six colours. **Try it on this page** paints this page with it (the
look switches to Munari if you are in the quaderno); nothing is remembered, and the next page
opens with the default.
"""

nbRawHtml: palettes.mapIt(specimen(it)).join("\n") &
  """<button type="button" class="ripristina">Back to the default</button>"""

nbText: """
## All the colours, in one table

The same colours as a tabelline table, with a column for how each reads as text on its paper
(the contrast ratio of WCAG: 4.5 is enough for small text, 3 for large). The circle colour is
also used for small red text in the Munari look (the kicker above a title, the third-level
headings), so it needs the most contrast of the three shapes.
"""

block:  # the table only, not its code
  type Row = object
    palette, role, colour, swatch, hex: string
    contrast: float
  var rows: seq[Row]
  for p in palettes:
    for (role, x) in p.roles:
      if role == "paper": continue
      let name = if x.kanji == "": x.name else: x.kanji & " " & x.name & (if x.gloss != "": ", " & x.gloss else: "")
      rows.add Row(palette: p.title.split(" · ")[1].split(",")[0], role: role, colour: name, swatch: "",
                   hex: x.hex, contrast: contrast(parseColor(x.hex), parseColor(p.carta.hex)))
  var t = tabella(rows, groupnameCol = "palette"):
    tabHeader "Six palettes for the Munari look", "each colour on the paper of its palette"
    colsLabel {"role": "", "colour": "colour", "swatch": "", "hex": "value", "contrast": "contrast on paper"}
    fmtNumber "contrast", decimals = 1
    colsWidth {"swatch": "3em"}
    tabSourceNote md("Japanese colours from [NIPPON COLORS](https://nipponcolors.com/), as in the npm package *nippon-colors* 1.0.0. Glosses are ours. Contrast ratio after WCAG 2.")
    optQuaderno()
  for i, r in rows:
    t = t.tabStyle(style.fill(r.hex), loc.body(cols = "swatch", rows = [i]))
  nbTable t

nbText: """
## Which one

Palette 1 is the default from today: it is the closest to Munari, with the yellow brought down.
Palette 2 is the friendliest, and the one a children's book would pick. Palette 3 is the calmest
to read for a long time; palette 4 is the most Japanese, and palette 5 the most fun. Any of them
can be the default by changing six lines of `docs/munari.nim`; the others could become a choice
in the header one day, but two looks are enough for now.
"""

nbRawHtml: """<script>
(function () {
  var root = document.documentElement, base = root.getAttribute('style') || '';
  var buttons = document.querySelectorAll('.prova');
  function press(b) { buttons.forEach(function (x) { x.setAttribute('aria-pressed', x === b ? 'true' : 'false'); }); }
  buttons.forEach(function (b) {
    b.setAttribute('aria-pressed', 'false');
    b.addEventListener('click', function () {
      root.setAttribute('style', base + ';' + b.dataset.vars);
      root.dataset.tema = 'munari';
      document.querySelectorAll('.tema button').forEach(function (x) {
        x.setAttribute('aria-pressed', x.dataset.tema === 'munari' ? 'true' : 'false'); });
      press(b);
    });
  });
  document.querySelector('.ripristina').addEventListener('click', function () {
    root.setAttribute('style', base); press(null);
  });
})();
</script>"""

nbSave
