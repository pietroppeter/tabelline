## *Stile*: every styling decision of tabelline's pages, in one place.
##
## The palette by roles of the design review (devlog, 8 November 2026): each look gives six values,
## paper, ink, primary, secondary, warning and success, and every other colour is mixed from them
## in the browser (`color-mix(in oklab, ...)`), so a palette is six values and a reader can try
## another one on the page:
##
## - a neutral scale `--n-0` (the paper) to `--n-9` (the ink), and `--surface`, a whiter sheet;
## - for each colour role, the colour (`--primary`, for shapes and edges), a soft version for
##   backgrounds (`--primary-soft`) and a text version (`--primary-text`); warning has no text
##   version: the warning colour is never text.
##
## Shape says what kind of thing it is (the circle a place, the triangle a warning, the square a
## sheet set apart, drawn as its straight top edge); colour says the role.
##
## Two looks are in every page: Munari (the default, scoped by `html[data-tema="munari"]`) and the
## quaderno (an Italian school exercise book). Fonts are inlined, so a page is one standalone file.
## No other module of the docs writes CSS or a colour: pages use the blocks of `blocchi.nim`, and
## tables take tabelline's `optTokens()`, whose colours are these tokens.

import std/[os, strformat, strutils, base64]

const fontDir = currentSourcePath().parentDir / "assets" / "fonts"

func face(family, file, weight, style: string): string =
  &"@font-face{{font-family:'{family}';src:url(data:font/woff2;base64,{encode(staticRead(fontDir / file))}) format('woff2');" &
    &"font-weight:{weight};font-style:{style};font-display:swap}}\n"

const fonts = face("Patrick Hand", "patrick-hand.woff2", "400", "normal") &
              face("Atkinson Hyperlegible", "atkinson-regular.woff2", "400", "normal") &
              face("Atkinson Hyperlegible", "atkinson-bold.woff2", "700", "normal") &
              face("Atkinson Hyperlegible", "atkinson-italic.woff2", "400", "italic") &
              face("Jost", "jost-400-normal.woff2", "400", "normal") &
              face("Jost", "jost-400-italic.woff2", "400", "italic") &
              face("Jost", "jost-700-normal.woff2", "700", "normal")

# ------------------------------------------------------------------------------------ the palette

type Look* = object
  ## The six values a look gives; every token is mixed from them.
  paper*, ink*, primary*, secondary*, warning*, success*: string

const
  quadernoLook* = Look(paper: "#FDFDF9", ink: "#2B2D38",
                       primary: "#1F4E99",     # blue pen: headings, links
                       secondary: "#5B9BD5",   # sky blue: notes and cards to go to, bars
                       warning: "#FFD84D", success: "#3FA34D")
    ## The quaderno's values. Its red pen stays a motif of the look (`--red-pen`), not a role.
  haru* = Look(paper: "#FCFAF2",       # 白練 shironeri, white silk
               ink: "#1C1C1C",         # 墨 sumi, ink
               primary: "#E16B8C",     # 紅梅 kōbai, red plum blossom: the circle
               secondary: "#7DB9DE",   # 勿忘草 wasurenagusa, forget-me-not: the square
               warning: "#F7D94C",     # 菜の花 nanohana, rapeseed flower: the triangle
               success: "#86C166")     # 苗 nae, seedling: the fourth
    ## Munari's default palette, Haru (spring): Japanese traditional colours (nipponcolors.com).

  neutralSteps* = [0, 4, 8, 14, 25, 40, 55, 65, 80, 100]  ## ink in paper, % per step `--n-0`..`--n-9`
  softShare* = 22   ## % of a colour in paper, for `--x-soft`
  textShare* = 50   ## % of a colour in ink, for `--x-text`

  partTints* = ["#FAECAC", "#C7DFEA", "#F1BEC7", "#FDDFC4", "#CDC7DE", "#CAE2B7", "#D7EEEC"]
    ## The categorical palette of the parts of a table (`parti.nim`): Haru and its neighbours
    ## (菜の花, 勿忘草, 紅梅, 洒落柿, 藤, 苗, 瓶覗), about 40% in the paper, readable in both looks.

func tokensCss(): string =
  ## The derived tokens, declared once on `html` for both looks.
  for i, s in neutralSteps:
    result.add &"--n-{i}: color-mix(in oklab, var(--ink) {s}%, var(--paper));\n"
  result.add "--surface: color-mix(in oklab, #FFFFFF 60%, var(--paper));\n"
  for role in ["primary", "secondary", "warning", "success"]:
    result.add &"--{role}-soft: color-mix(in oklab, var(--{role}) {softShare}%, var(--paper));\n"
    if role != "warning":
      result.add &"--{role}-text: color-mix(in oklab, var(--{role}) {textShare}%, var(--ink));\n"

func lookCss(l: Look): string =
  &"--paper: {l.paper}; --ink: {l.ink}; --primary: {l.primary}; --secondary: {l.secondary}; " &
    &"--warning: {l.warning}; --success: {l.success};"

const tokens = "html {\n" & lookCss(quadernoLook) & "\n" & tokensCss() & "}\n" &
  # Munari names its six values after where they go; the palettes post swaps them on the page.
  &"""html[data-tema="munari"] {{
  --m-carta: {haru.paper}; --m-inchiostro: {haru.ink}; --m-cerchio: {haru.primary};
  --m-quadrato: {haru.secondary}; --m-triangolo: {haru.warning}; --m-quarto: {haru.success};
  --paper: var(--m-carta); --ink: var(--m-inchiostro); --primary: var(--m-cerchio);
  --secondary: var(--m-quadrato); --warning: var(--m-triangolo); --success: var(--m-quarto);
}}
"""

# ------------------------------------------------------------------------------------ the quaderno
# Shared rules first, written in the quaderno; the Munari rules below change what differs.

const quadernoCss = """
html {
  /* the quaderno's own motifs, beside the tokens */
  --grid: #D9E7F5;          /* the squares */
  --margin: #E9585B;        /* the red margin rule */
  --postit: #FFF6B8;        /* sticky notes */
  --highlight: rgba(255, 230, 90, .55);
  --tape: rgba(255, 214, 165, .75);
  --edge: #C9D9EC;          /* pale blue rules */
  --red-pen: #C62828;       /* corrections, subheadings, stamps */
  --hand: "Patrick Hand", "Segoe Print", "Comic Sans MS", cursive;
  --text: "Atkinson Hyperlegible", system-ui, -apple-system, "Segoe UI", sans-serif;
  --mono: ui-monospace, "SF Mono", Menlo, Consolas, "DejaVu Sans Mono", monospace;
  --sq: 20px;               /* one square, about 5 mm */
  /* names from before the tokens, for the dated posts' own CSS */
  --pencil: var(--n-9); --pen: var(--primary); --pen-red: var(--red-pen); --muted: var(--n-7);
  --card: var(--surface); --rule: var(--n-3); --carta: var(--n-1);
  --giallo: var(--warning); --blu: var(--secondary);
}
* { box-sizing: border-box; }
[hidden] { display: none !important; }
html { -webkit-text-size-adjust: 100%; }
body {
  margin: 0; color: var(--n-9); font: 17px/1.6 var(--text);
  background-color: var(--paper);
  background-image:
    linear-gradient(var(--grid) 1px, transparent 1px),
    linear-gradient(90deg, var(--grid) 1px, transparent 1px);
  background-size: var(--sq) var(--sq);
  padding: 0 max(14px, env(safe-area-inset-right, 0px)) 0 max(14px, env(safe-area-inset-left, 0px));
}
body > header, body > main, body > footer { max-width: 50rem; margin: 0 auto; position: relative; }
main { padding-left: 2.2rem; border-left: 3px double var(--margin); padding-bottom: 2rem; }
@media (max-width: 640px) { main { padding-left: .9rem; } }

/* the cover label */
.etichetta { margin: 2.2rem auto 1.6rem; max-width: 30rem; background: var(--surface);
  border: 2px solid var(--primary); border-radius: 18px; padding: 1rem 1.4rem 1.1rem;
  box-shadow: 4px 5px 0 color-mix(in srgb, var(--primary) 15%, transparent); position: relative; }
.etichetta::before { content: ""; position: absolute; inset: 6px; border: 1px solid var(--edge); border-radius: 13px; pointer-events: none; }
.etichetta .riga { display: flex; gap: .6rem; align-items: baseline; border-bottom: 1.5px dotted var(--edge); padding: .15rem 0; }
.etichetta .riga span:first-child { font: 600 .72rem/1 var(--text); letter-spacing: .12em; text-transform: uppercase; color: var(--n-7); min-width: 5.2rem; }
.etichetta .riga span:last-child { font: 1.55rem/1.25 var(--hand); color: var(--primary); }
.etichetta .nome span:last-child { font-size: 2.3rem; }
.etichetta .nome a { color: inherit; text-decoration: none; }
.crumbs { display: flex; justify-content: space-between; gap: 1rem; flex-wrap: wrap; font: 1.05rem var(--hand); padding-top: .8rem; }
.crumbs a { color: var(--primary); }
.lede { font-size: 1.15rem; color: var(--n-9); margin: 0 0 1.2rem; }
.kicker { font: 600 .74rem/1 var(--text); letter-spacing: .14em; text-transform: uppercase; color: var(--red-pen); margin: 0; }

/* headings in blue pen, with a highlighter stroke */
h1, h2, h3, h4 { font-family: var(--hand); font-weight: 400; color: var(--primary); line-height: 1.15; }
h1 { font-size: 2.6rem; margin: 1.5rem 0 .4rem; }
h2 { font-size: 2.05rem; margin: 2.6rem 0 .8rem; display: inline-block;
  background: linear-gradient(transparent 55%, var(--highlight) 55%, var(--highlight) 92%, transparent 92%);
  padding: 0 .3rem; margin-left: -.3rem; scroll-margin-top: 1rem; }
h3 { font-size: 1.55rem; margin: 1.8rem 0 .5rem; color: var(--red-pen); scroll-margin-top: 1rem; }
h2 .num { color: var(--red-pen); margin-right: .35rem; }
a { color: var(--primary); text-decoration-thickness: 1.5px; text-underline-offset: 2px; }
strong { font-weight: 700; }
p, li { max-width: 46rem; }
blockquote { margin: 1.2rem 0; padding: .7rem 1rem; background: var(--postit); border-radius: 2px 2px 14px 2px;
  box-shadow: 2px 3px 6px rgba(0,0,0,.08); transform: rotate(-.4deg); }
blockquote p { margin: .3rem 0; }
hr { border: 0; border-top: 2px dashed var(--edge); margin: 2rem 0; }
mark { background: var(--highlight); padding: 0 .15em; }
img { max-width: 100%; }

/* code on index cards, outputs on sticky notes */
pre { margin: 1rem 0; }
pre > code, pre.nb-output { display: block; overflow-x: auto; font: 13px/1.55 var(--mono); padding: .8rem 1rem;
  border-radius: 6px; }
body pre > code { font-size: 13px; }
pre > code { background: var(--surface); border: 1px solid var(--edge); border-left: 5px solid var(--primary);
  box-shadow: 2px 3px 0 color-mix(in srgb, var(--primary) 8%, transparent); }
pre.nb-output { background: var(--postit); border: 0; box-shadow: 2px 3px 6px rgba(0,0,0,.07); white-space: pre; color: var(--n-9); }
pre.nb-output::before { content: "output"; display: block; font: .95rem var(--hand); color: var(--n-7); margin-bottom: .1rem; }
:not(pre) > code { font: .88em var(--mono); background: color-mix(in srgb, var(--primary) 7%, transparent); padding: .05em .3em; border-radius: 4px; }
.hljs-keyword { color: var(--primary-text); font-weight: 700; } .hljs-string { color: var(--success-text); }
.hljs-number, .hljs-literal { color: var(--secondary-text); }
.hljs-comment { color: var(--n-7); font-style: italic; } .hljs-type { color: var(--primary); } .hljs-built_in { color: var(--secondary-text); }
.hljs-meta { color: var(--n-7); }

/* tables pasted in, with a strip of tape, on squared paper */
.tabella { position: relative; margin: 1.6rem 0 1.8rem; padding: 18px 14px 12px; background: var(--surface);
  box-shadow: 0 1px 2px rgba(0,0,0,.08), 3px 5px 14px rgba(0,0,0,.07); border-radius: 2px; }
.tabella::before { content: ""; position: absolute; top: -11px; left: 50%; width: 110px; height: 24px;
  margin-left: -55px; background: var(--tape); transform: rotate(-2deg); box-shadow: 0 1px 2px rgba(0,0,0,.08); }
.tabella .tb_table { background-image: linear-gradient(var(--grid) 1px, transparent 1px),
  linear-gradient(90deg, var(--grid) 1px, transparent 1px); background-size: 12px 12px; }
.tabella .tb_title { font-family: var(--hand); font-size: 150%; }
main table:not(.tb_table) { border-collapse: collapse; margin: 1rem 0; background: var(--surface); }
main table:not(.tb_table) th, main table:not(.tb_table) td { border: 1px solid var(--edge); padding: .35rem .6rem; text-align: left; vertical-align: top; }

/* the indice: a sticky note with the headings */
.indice { background: var(--postit); padding: 1rem 1.3rem 1.1rem; margin: 1.4rem 0 2rem; max-width: 34rem;
  box-shadow: 2px 4px 10px rgba(0,0,0,.1); transform: rotate(.5deg); border-radius: 2px 2px 18px 2px; }
.indice h2.indice-title { font-size: 1.7rem; background: none; margin: 0 0 .4rem; padding: 0; display: block; color: var(--red-pen); }
.indice ol { margin: 0; padding-left: 1.5rem; font: 1.2rem/1.45 var(--hand); }
.indice ol ol { font-size: 1.05rem; padding-left: 1.1rem; list-style: none; }
.indice ol ol li::before { content: "– "; color: var(--n-7); }
.indice a { text-decoration: none; color: var(--primary); }
.indice a:hover { text-decoration: underline; }

/* notes (nbNota): a sticky note, coloured by its kind; a warning carries the triangle */
.nota { background: var(--postit); padding: .8rem 1.1rem; margin: 1.3rem 0; border-radius: 2px 2px 14px 2px;
  box-shadow: 2px 3px 8px rgba(0,0,0,.09); transform: rotate(-.3deg); }
.nota.info { background: var(--secondary-soft); } .nota.done { background: var(--success-soft); }
.nota.missing { background: var(--primary-soft); } .nota.warning { background: var(--warning-soft); }
.nota > :first-child { margin-top: 0; } .nota > :last-child { margin-bottom: 0; }
.nota .titolo { font: 1.3rem var(--hand); color: var(--red-pen); display: block; }
.nota .numero { font: 700 .72rem/1.2 var(--text); letter-spacing: .14em; color: var(--n-7); display: block; }
.nota.warning { position: relative; padding-left: 3rem; }
.nota.warning::before, .nota.warning::after { content: ""; position: absolute; left: .9rem; top: .9rem; width: 1.4rem; height: 1.25rem;
  clip-path: polygon(50% 0, 100% 100%, 0 100%); }
.nota.warning::before { background: var(--n-9); }
.nota.warning::after { background: var(--warning); transform: scale(.7); transform-origin: 50% 68%; }
.timbro { display: inline-block; font: 1.05rem var(--hand); color: var(--red-pen); border: 2px solid var(--red-pen);
  border-radius: 8px; padding: 0 .5rem; transform: rotate(-4deg); }
.timbro.ok { color: var(--success-text); border-color: var(--success-text); }
.timbro.ko { background: var(--primary-soft); }

/* cards (nbCards, nbCard): a grid of notes */
.cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(14rem, 1fr)); gap: 1rem; margin: 1.2rem 0; }
.cards .nota { margin: 0; }
.cards .nota .titolo + p { margin-top: .3rem; }

/* a gallery (nbGalleria, nbScheda): cards to swipe sideways, numbered */
.nb-galleria { display: flex; align-items: flex-start; gap: .8rem; overflow-x: auto; scroll-snap-type: x mandatory;
  padding: .2rem 0 .8rem; counter-reset: nb-scheda; -webkit-overflow-scrolling: touch; }
.nb-galleria::after { content: ""; flex: 0 0 .2rem; }
.nb-galleria > .nb-scheda { flex: 0 0 min(84%, 24rem); scroll-snap-align: start; overflow-x: auto; padding: .7rem .9rem .8rem;
  background: var(--surface); border: 1px solid var(--n-3); counter-increment: nb-scheda; }
.nb-galleria > .nb-scheda::before { content: counter(nb-scheda); display: block; font: 700 .72rem/1.2 var(--text); letter-spacing: .14em; color: var(--n-7); }
.nb-galleria > .nb-scheda > h3 { margin: .15rem 0 .4rem; font-size: 1.15rem; }
.nb-galleria > .nb-scheda[data-label]::before { content: attr(data-label) " · " counter(nb-scheda); text-transform: uppercase; }
.nb-galleria > .nb-scheda p { font-size: .94rem; line-height: 1.45; margin: 0 0 .5rem; }
.nb-scheda pre { margin: .4rem 0; }
body .nb-scheda pre > code { font-size: 12.5px; white-space: pre-wrap; overflow-wrap: anywhere; }
.nb-scheda .tabella { margin: .4rem 0 0; }
.nb-scheda .tabella table { font-size: 14px !important; }
.accanto { display: flex; flex-wrap: wrap; gap: 0 .6rem; justify-content: center; align-items: flex-start; }
.accanto .tabella { padding-left: 6px; padding-right: 6px; }

/* tabs (nbTabs): the same example in Nim, Python and R; the choice holds for the whole page */
.lingue { margin: 1.2rem 0; }
.lingue-tab { display: flex; gap: 0; flex-wrap: wrap; }
.lingue-tab button { font: 1rem var(--hand); color: var(--primary); background: var(--surface); border: 1.5px solid var(--primary);
  border-bottom: 0; padding: .15rem .8rem; cursor: pointer; margin-right: -1.5px; }
.lingue-tab button[aria-selected="true"] { background: var(--primary); color: var(--n-0); }
.lingue-pannello { border-top: 1.5px solid var(--primary); padding-top: .2rem; }
.lingue-pannello > pre:first-child { margin-top: .6rem; }

/* the code of a table, folded under it (nbShowCode) */
details.codice { margin: -1rem 0 1.6rem; }
details.codice > summary { list-style: none; cursor: pointer; display: inline-block; font: 1rem var(--hand); color: var(--primary); }
details.codice > summary::-webkit-details-marker { display: none; }
details.codice > summary::before { content: "+ show code"; }
details.codice[open] > summary::before { content: "− hide code"; }
details.codice pre { margin: .4rem 0 0; }
body details.codice pre > code { font-size: 12.5px; }

/* the parts of a table (nbParti): a switch between the data and its parts, and their legend */
.parti { list-style: none; padding: 0; margin: .8rem 0; }
.parti li { margin: .35rem 0; padding-left: 2rem; position: relative; line-height: 1.45; }
.tinta-parte { position: absolute; left: 0; top: .25em; width: 1.3rem; height: 1rem; outline: 1px solid var(--n-3); }
.parti .colore { color: var(--n-7); font-size: .88em; }
.mostra-parti { font: 700 .72rem/1.6 var(--text); letter-spacing: .14em; text-transform: uppercase; cursor: pointer;
  border: 2px solid var(--n-9); background: transparent; color: var(--n-9); padding: .3rem .8rem; margin: .2rem 0 0; }
.mostra-parti[aria-pressed="true"] { background: var(--n-9); color: var(--n-0); }

/* swatches (nbTinte): a colour beside its name */
.tinte { display: grid; grid-template-columns: repeat(auto-fill, minmax(9.5rem, 1fr)); gap: .8rem; margin: 1rem 0; }
.tinte .tinta { font-size: .86rem; line-height: 1.35; }
.tinte .tinta span { display: block; height: 2.4rem; margin-bottom: .3rem; outline: 1px solid var(--n-2); }
.tinte .tinta strong { display: block; font-size: .95rem; }

/* parts of a long page (nbParte): a label, then the sections' circles take the part's colour */
.parte { font: 700 .74rem/1 var(--text); letter-spacing: .2em; text-transform: uppercase; margin: 3.4rem 0 -1.2rem; color: var(--n-7); }
.parte-secondary ~ h2 { --part: var(--secondary); } .parte-success ~ h2 { --part: var(--success); }

/* the specs page (nbSpecs): each capability folds open; examples carry a pass stamp */
details.spec { background: var(--surface); border: 1.5px solid var(--n-3); border-radius: 10px; margin: .8rem 0; padding: .5rem 1rem; }
details.spec > summary { cursor: pointer; font-size: 1.1rem; }
details.spec > summary b { font: 1.45rem var(--hand); color: var(--primary); margin-right: .4rem; }
details.spec .counts { color: var(--n-7); font-size: .85rem; }
details.spec .purpose { display: block; color: var(--n-9); font-size: .95rem; margin: .2rem 0 .3rem; }
.req { border-top: 2px dashed var(--n-3); padding: .4rem 0 .6rem; }
.req h4 { font: 1.3rem var(--hand); color: var(--red-pen); margin: .6rem 0 .2rem; }
.example { margin: .6rem 0 1rem; }
.example .ex-head { display: flex; gap: .6rem; align-items: center; font-size: .8rem; color: var(--n-7); }
.ex-out summary { cursor: pointer; font: 1.05rem var(--hand); color: var(--n-7); }
.scen { background: var(--n-1); border-radius: 8px; padding: .4rem .8rem; margin: .5rem 0; }
.scen-name { font: 1.1rem var(--hand); color: var(--primary); }
.scen ul { margin: .2rem 0; padding-left: 1.2rem; }
.kw { font: 600 .75rem var(--text); letter-spacing: .08em; padding: 0 .3rem; border-radius: 4px; }
.kw.when { background: var(--secondary-soft); } .kw.then { background: var(--success-soft); } .kw.and, .kw.given { background: var(--n-2); }
.src { font-size: .8rem; color: var(--n-7); }
details.links summary { cursor: pointer; }

/* the look switch */
.tema { display: flex; justify-content: flex-end; gap: 0; margin: .6rem 0 0; }
.tema button { font: 1rem var(--hand); color: var(--primary); background: var(--surface); border: 1.5px solid var(--primary);
  padding: .1rem .7rem; cursor: pointer; }
.tema button:first-child { border-radius: 10px 0 0 10px; } .tema button:last-child { border-radius: 0 10px 10px 0; border-left: 0; }
.tema button[aria-pressed="true"] { background: var(--primary); color: var(--n-0); }
.forme, .motto { display: none; }

footer { font: 1.05rem var(--hand); color: var(--n-7); padding: 1rem 0 3rem; text-align: center; }
footer a { color: var(--primary); }
details.source { margin-top: 1rem; text-align: left; }
details.source summary { cursor: pointer; }
details.source pre { max-height: 32rem; overflow: auto; }
"""

# ---------------------------------------------------------------------------------------- Munari
# After Bruno Munari: flat paper, one geometric sans (Jost), and the three shapes of his books,
# each with a meaning. Nothing that only decorates may look like something to press or drag.

const munariCss = """
html[data-tema="munari"] {
  --hand: "Jost", "Futura", "Century Gothic", system-ui, sans-serif;
  --text: "Jost", "Futura", "Century Gothic", system-ui, sans-serif;
  --pen: var(--n-9); --pen-red: var(--primary-text);
}
html[data-tema="munari"] body { background: var(--paper); font: 18px/1.6 var(--text); }
html[data-tema="munari"] main { border-left: 0; padding-left: 0; }
html[data-tema="munari"] header { padding-top: .4rem; }

/* the cover: the three shapes over each other, like sheets of coloured acetate */
html[data-tema="munari"] .forme { display: block; position: absolute; top: 6.3rem; right: 0; width: 9.5rem; height: 8.5rem; pointer-events: none; }
html[data-tema="munari"] .forme i { position: absolute; display: block; mix-blend-mode: multiply; }
html[data-tema="munari"] .forme .cerchio { width: 6.2rem; height: 6.2rem; border-radius: 50%; background: var(--primary); right: 0; top: 0; }
html[data-tema="munari"] .forme .quadrato { width: 4.6rem; height: 4.6rem; background: var(--secondary); right: 3.6rem; top: 2.6rem; }
html[data-tema="munari"] .forme .triangolo { width: 5.6rem; height: 4.9rem; background: var(--warning); right: 1.2rem; top: 3.6rem;
  clip-path: polygon(50% 0, 100% 100%, 0 100%); }
html[data-tema="munari"] .etichetta { margin: 2.4rem 0 1.4rem; max-width: none; background: none; border: 0; border-radius: 0;
  box-shadow: none; padding: 0 10.5rem 0 0; min-height: 8.5rem; }
html[data-tema="munari"] .etichetta::before { display: none; }
html[data-tema="munari"] .etichetta .riga { display: block; border: 0; padding: 0; }
html[data-tema="munari"] .etichetta .riga span:first-child { display: none; }
html[data-tema="munari"] .etichetta .riga span:last-child { font: 400 1.25rem/1.3 var(--text); color: var(--n-9); }
html[data-tema="munari"] .etichetta .nome span:last-child { font: 700 3.4rem/1 var(--text); letter-spacing: -.03em; }
html[data-tema="munari"] .etichetta .riga:last-child:not(.nome) span:last-child { font-size: .8rem; letter-spacing: .18em; text-transform: uppercase; color: var(--n-7); }
@media (max-width: 560px) {
  html[data-tema="munari"] .forme { transform: scale(.62); transform-origin: top right; top: 6rem; }
  html[data-tema="munari"] .etichetta { padding-right: 6.4rem; min-height: 6rem; }
  html[data-tema="munari"] .etichetta .nome span:last-child { font-size: 2.5rem; }
}
html[data-tema="munari"] .crumbs { font: 700 .74rem/1 var(--text); letter-spacing: .16em; text-transform: uppercase; padding-top: 1rem; }
html[data-tema="munari"] .crumbs a { color: var(--n-9); text-decoration: none; }
html[data-tema="munari"] .tema button { font: 700 .72rem/1.6 var(--text); letter-spacing: .14em; text-transform: uppercase;
  border: 2px solid var(--n-9); border-radius: 0; background: transparent; color: var(--n-9); padding: .2rem .7rem; }
html[data-tema="munari"] .tema button:last-child { border-left: 0; }
html[data-tema="munari"] .tema button[aria-pressed="true"] { background: var(--n-9); color: var(--n-0); }

/* type: one sans, big and plain; sections marked by the circle */
html[data-tema="munari"] h1, html[data-tema="munari"] h2, html[data-tema="munari"] h3, html[data-tema="munari"] h4 {
  font-family: var(--text); font-weight: 700; color: var(--n-9); letter-spacing: -.015em; }
html[data-tema="munari"] h1 { font-size: 2.9rem; line-height: 1.05; }
html[data-tema="munari"] h2 { font-size: 1.85rem; display: block; background: none; padding: 0 0 0 2.4rem; margin: 3rem 0 .9rem; position: relative; }
html[data-tema="munari"] h2::before { content: ""; position: absolute; left: 0; top: .2em; width: 1.5rem; height: 1.5rem;
  background: var(--part, var(--primary)); border-radius: 50%; }
html[data-tema="munari"] h3 { font-size: 1.25rem; color: var(--primary-text); margin-top: 2rem; }
html[data-tema="munari"] h2 .num { color: var(--n-7); }
html[data-tema="munari"] .kicker { font: 700 .74rem/1 var(--text); letter-spacing: .2em; color: var(--primary-text); }
html[data-tema="munari"] .lede { font-size: 1.3rem; line-height: 1.45; }
html[data-tema="munari"] a { color: var(--n-9); text-decoration-color: var(--primary); text-decoration-thickness: 2px; }
html[data-tema="munari"] a:hover { background: var(--primary-soft); }
html[data-tema="munari"] blockquote { transform: none; box-shadow: none; border-radius: 0; background: none; border-left: 6px solid var(--n-4); }
html[data-tema="munari"] hr { border-top: 2px solid var(--n-9); }
html[data-tema="munari"] mark { background: var(--warning-soft); }

/* code: a white sheet with a black edge; outputs on grey paper */
html[data-tema="munari"] pre > code { border: 2px solid var(--n-9); border-radius: 0; box-shadow: none; }
html[data-tema="munari"] pre.nb-output { background: var(--n-1); border-radius: 0; box-shadow: none; color: var(--n-9); }
html[data-tema="munari"] pre.nb-output::before { font: 700 .66rem/1.4 var(--text); letter-spacing: .2em; text-transform: uppercase; color: var(--primary-text); }
html[data-tema="munari"] :not(pre) > code { background: var(--n-1); border-radius: 0; }
html[data-tema="munari"] .hljs-keyword { color: var(--primary-text); font-weight: 700; }
html[data-tema="munari"] .hljs-string { color: var(--secondary-text); }
html[data-tema="munari"] .hljs-number, html[data-tema="munari"] .hljs-literal { color: var(--success-text); }
html[data-tema="munari"] .hljs-type { color: var(--n-9); font-weight: 700; }
html[data-tema="munari"] .hljs-built_in { color: var(--primary-text); }

/* tables: no tape, no squares; the rules come from optTokens(), from the tokens */
html[data-tema="munari"] .tabella { box-shadow: none; border-radius: 0; padding: 16px 0 10px; background: transparent; }
html[data-tema="munari"] .tabella::before { content: none; display: none; }
html[data-tema="munari"] .tabella .tb_table { background-image: none; }
html[data-tema="munari"] .tabella .tb_title { font-size: 125%; letter-spacing: -.01em; }
html[data-tema="munari"] main table:not(.tb_table) th, html[data-tema="munari"] main table:not(.tb_table) td { border-color: var(--n-3); }

/* the indice: numbers on circles, as the section headings */
html[data-tema="munari"] .indice { background: none; box-shadow: none; transform: none; border-radius: 0; padding: 1rem 0;
  border-top: 3px solid var(--n-9); border-bottom: 3px solid var(--n-9); max-width: 36rem; }
html[data-tema="munari"] .indice h2.indice-title { font: 700 .78rem/1 var(--text); letter-spacing: .2em; text-transform: uppercase;
  color: var(--n-9); padding: 0; margin: 0 0 .9rem; }
html[data-tema="munari"] .indice h2.indice-title::before { display: none; }
html[data-tema="munari"] .indice > ol { list-style: none; padding: 0; counter-reset: voce; font: 500 1.08rem/1.5 var(--text); }
html[data-tema="munari"] .indice > ol > li { counter-increment: voce; position: relative; padding-left: 2.3rem; margin: .35rem 0; }
html[data-tema="munari"] .indice > ol > li::before { content: counter(voce); position: absolute; left: 0; top: .1rem; width: 1.5rem; height: 1.5rem;
  border-radius: 50%; background: var(--primary); color: #fff; font: 700 .78rem/1.5rem var(--text); text-align: center; }
html[data-tema="munari"] .indice > ol > li.parte-secondary::before { background: var(--secondary); color: var(--n-9); }
html[data-tema="munari"] .indice > ol > li.parte-success::before { background: var(--success); color: var(--n-9); }
html[data-tema="munari"] .indice ol ol { font: 400 .95rem/1.45 var(--text); padding-left: 0; margin: .15rem 0 .3rem; }
html[data-tema="munari"] .indice ol ol li::before { content: "— "; color: var(--n-7); }
html[data-tema="munari"] .indice a { color: var(--n-9); }

/* sheets set apart (notes, cards, gallery cards): flat paper with the square's straight top edge,
   in the colour of their kind; nothing on them to press */
html[data-tema="munari"] .nota { border-radius: 0; box-shadow: none; transform: none; padding: 1rem 1.2rem;
  background: var(--n-1); border-top: 5px solid var(--n-9); }
html[data-tema="munari"] .nota.info { background: var(--secondary-soft); border-top-color: var(--secondary); }
html[data-tema="munari"] .nota.done { background: var(--success-soft); border-top-color: var(--success); }
html[data-tema="munari"] .nota.missing { background: var(--primary-soft); border-top-color: var(--primary); }
html[data-tema="munari"] .nota.warning { background: var(--warning-soft); border-top-color: var(--warning); padding-left: 3.1rem; }
html[data-tema="munari"] .nota.warning::before, html[data-tema="munari"] .nota.warning::after { left: 1.1rem; top: 1.1rem; }
html[data-tema="munari"] .nota .titolo { font: 700 1.1rem var(--text); color: var(--n-9); }
html[data-tema="munari"] .nb-galleria > .nb-scheda { border: 0; border-top: 5px solid var(--secondary); background: var(--n-1); }
html[data-tema="munari"] .timbro { font: 700 .8rem/1.6 var(--text); letter-spacing: .12em; text-transform: uppercase; border-radius: 0; transform: none;
  color: var(--n-9); border-color: var(--n-9); }
html[data-tema="munari"] .timbro.ok { color: var(--success-text); border-color: var(--success); }

/* tabs and switches: ink, the selected one filled */
html[data-tema="munari"] .lingue-tab button { font: 700 .72rem/1.6 var(--text); letter-spacing: .1em; text-transform: uppercase;
  border: 2px solid var(--n-9); border-bottom: 0; border-radius: 0; background: transparent; color: var(--n-9); margin-right: -2px; }
html[data-tema="munari"] .lingue-tab button[aria-selected="true"] { background: var(--n-9); color: var(--n-0); }
html[data-tema="munari"] .lingue-pannello { border-top: 2px solid var(--n-9); }
html[data-tema="munari"] details.codice { margin-top: -.8rem; }
html[data-tema="munari"] details.codice > summary { font: 700 .68rem/1.6 var(--text); letter-spacing: .12em;
  text-transform: uppercase; color: var(--n-9); border-bottom: 2px solid var(--secondary); }

/* specs */
html[data-tema="munari"] details.spec { border-radius: 0; border: 0; border-top: 5px solid var(--secondary); background: var(--n-1); }
html[data-tema="munari"] details.spec > summary b { font: 700 1.2rem var(--text); color: var(--n-9); }
html[data-tema="munari"] .req h4, html[data-tema="munari"] .scen-name, html[data-tema="munari"] .ex-out summary { font-family: var(--text); font-weight: 700; font-size: 1rem; }
html[data-tema="munari"] .req h4 { color: var(--primary-text); }
html[data-tema="munari"] .scen-name { color: var(--n-9); }
html[data-tema="munari"] .scen { background: var(--n-0); border-radius: 0; }

/* footer, with Munari's motto */
html[data-tema="munari"] footer { font: 400 .9rem/1.5 var(--text); color: var(--n-7); border-top: 2px solid var(--n-9); margin-top: 2rem; }
html[data-tema="munari"] footer a { color: var(--n-9); }
html[data-tema="munari"] .motto { display: block; font: 700 1.35rem/1.3 var(--text); color: var(--n-9); margin: .2rem 0 1rem; }
html[data-tema="munari"] .motto span { display: block; font: 400 .74rem/2 var(--text); letter-spacing: .2em; text-transform: uppercase; color: var(--primary-text); }
"""

const css* = fonts & tokens & quadernoCss & munariCss
  ## All the CSS of a page: both looks, every block.

# ----------------------------------------------------------------------------------------- tables

const tokenColours* = ["--n-0", "--n-1", "--n-3", "--n-7", "--n-9", "--surface",
  "--primary", "--primary-soft", "--primary-text", "--secondary", "--secondary-soft", "--secondary-text",
  "--warning", "--warning-soft", "--success", "--success-soft", "--success-text"]
  ## The tokens a page may name in a table colour, as `tinta("--secondary")`.

func tinta*(token: string): string =
  ## A token as a CSS colour, for tabelline's colour arguments: `fmtBar(color = tinta("--secondary"))`.
  doAssert token in tokenColours, "not a token: " & token
  "var(" & token & ")"

func tintaMix*(token: string, share: int, other = "--n-0"): string =
  ## `share`% of a token in another (the paper by default), for a scale drawn from the palette.
  doAssert token in tokenColours and other in tokenColours
  &"color-mix(in oklab, var({token}) {share}%, var({other}))"
