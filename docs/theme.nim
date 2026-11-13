## *Stile*: every styling decision of tabelline's pages, in one place.
##
## The palette by roles of the design review (devlog, 8 November 2026): each look gives six values,
## paper, ink, primary, secondary, warning and success, and every other colour is mixed from them
## in the browser (`color-mix(in oklab, ...)`), so a palette is six values and a reader can try
## another one on the page:
##
## - the neutrals, ink mixed into paper: `--shade` (outputs, plain notes, row groups), `--line`
##   (rules), `--muted` (grey text), the whole scale `--neutral-0` (the paper) to `--neutral-9`
##   (the ink) for the steps in between, and `--surface`, a whiter sheet;
## - for each colour role, the colour (`--primary`, for shapes and edges), a soft version for
##   backgrounds (`--primary-soft`) and a text version (`--primary-text`); warning has no text
##   version: the warning colour is never text.
##
## Shape says what kind of thing it is (the circle a place, the triangle a warning, the square a
## sheet set apart, drawn as its straight top edge); colour says the role.
##
## Two looks are in every page: Munari, the default, whose rules are the page itself (so a page
## without JavaScript is Munari), and the quaderno (an Italian school exercise book), every rule of
## which is scoped by `html[data-tema="quaderno"]`. The pages share it: `css` is written once to
## `docs/assets/site.css`, and its fonts are the files beside it, in `docs/assets/fonts/`. Built
## with `-d:singleFile`, a page inlines all of it instead (fonts as data URLs), so it is one file
## that works alone, for a one-page preview. No other module of the docs writes CSS or a colour: pages use the blocks of `blocks.nim`, and
## tables take tabelline's `optCssTheme()`, which reads these tokens by name (`--ink`, `--paper`,
## `--line`, `--shade`, `--primary`, `--secondary`, `--font`).

import std/[os, strformat, strutils, base64]

const
  singleFile* = defined(singleFile)
    ## `-d:singleFile`: every page is one file, its style and fonts inlined
  assetsDir* = currentSourcePath().parentDir / "assets"
    ## `docs/assets/`: the files the pages share (deployed with them)
  fontDir = assetsDir / "fonts"

func face(family, file, weight, style: string): string =
  # shared: the font file, beside site.css; singleFile: the font itself, as a data URL
  let src = when singleFile: "data:font/woff2;base64," & encode(staticRead(fontDir / file)) else: "fonts/" & file
  &"@font-face{{font-family:'{family}';src:url({src}) format('woff2');" &
    &"font-weight:{weight};font-style:{style};font-display:swap}}\n"

const fonts = face("Patrick Hand", "patrick-hand.woff2", "400", "normal") &
              face("Atkinson Hyperlegible", "atkinson-regular.woff2", "400", "normal") &
              face("Atkinson Hyperlegible", "atkinson-bold.woff2", "700", "normal") &
              face("Atkinson Hyperlegible", "atkinson-italic.woff2", "400", "italic") &
              face("Jost", "jost-400-normal.woff2", "400", "normal") &
              face("Jost", "jost-400-italic.woff2", "400", "italic") &
              face("Jost", "jost-700-normal.woff2", "700", "normal") &
              face("Gentium Book Plus", "gentium-regular.woff2", "400", "normal") &
              face("Gentium Book Plus", "gentium-italic.woff2", "400", "italic") &
              face("Gentium Book Plus", "gentium-bold.woff2", "700", "normal")

# ------------------------------------------------------------------------------------ the palette

type Look* = object
  ## The six values a look gives; every token is mixed from them. A dark look (`dark`) has a dark
  ## paper and a light ink: its `--surface`, the sheet set above the paper, is a little lighter
  ## than the paper instead of whiter (devlog "Toward a dark tabelline").
  paper*, ink*, primary*, secondary*, warning*, success*: string
  dark*: bool

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

  minoanLook* = Look(paper: "#EFE6D2",     # lime plaster, the ground of the frescoes
                     ink: "#1E1A17",       # black glaze, the black of the vases
                     primary: "#C3693C",   # terracotta: the clay of red-figure, the circle, links
                     secondary: "#3F7FA6", # dolphin blue, from the Knossos fresco: the square, bars
                     warning: "#D9A441",   # yellow ochre: the triangle
                     success: "#6E8B5A")   # olive, from the place: what works, code notes
    ## The Minoan look's values (devlog "Designing a Mediterranean look", the tournament's winner),
    ## the same six as `mediterraneanSources`' "minoan", checked there by the colour rules.

  edo* = Look(paper: "#FCFAF2",        # 白練 shironeri, white silk
              ink: "#1C1C1C",          # 墨 sumi, ink
              primary: "#77428D",      # 江戸紫 edomurasaki, Edo purple: the circle, links, the book's notes
              secondary: "#0089A7",    # 新橋 shinbashi, Shinbashi blue: the square, the Python tab
              warning: "#FFB11B",      # 山吹 yamabuki, kerria flower: the triangle, the source box
              success: "#7BA23F")      # 萌黄 moegi, fresh sprouts: numbers in code
    ## The book's palette, Edo (the fashion colours of old Tokyo): the book has one look,
    ## Munari, in these six values (`book/theme/edo.css`, `paletteCss(edo)`).

  neutralSteps* = [0, 4, 8, 14, 25, 40, 55, 65, 80, 100]  ## ink in paper, % per step `--neutral-0`..`--neutral-9`
  softShare* = 22   ## % of a colour in paper, for `--x-soft`
  textShare* = 50   ## % of a colour in ink, for `--x-text`

  partTints* = ["#FAECAC", "#C7DFEA", "#F1BEC7", "#FDDFC4", "#CDC7DE", "#CAE2B7", "#D7EEEC"]
    ## The categorical palette of the parts of a table (`table_parts.nim`): Haru and its neighbours
    ## (菜の花, 勿忘草, 紅梅, 洒落柿, 藤, 苗, 瓶覗), about 40% in the paper, readable in both looks.

func tokensCss(dark = false): string =
  ## The derived tokens, declared once on `html` for both looks. On a dark paper the surface is
  ## the paper with a little ink in it, a sheet lifted towards the light, never white.
  for i, s in neutralSteps:
    result.add &"--neutral-{i}: color-mix(in oklab, var(--ink) {s}%, var(--paper));\n"
  result.add "--shade: var(--neutral-1); --line: var(--neutral-3); --muted: var(--neutral-7);\n"
  result.add(if dark: "--surface: color-mix(in oklab, var(--ink) 7%, var(--paper));\n"
             else: "--surface: color-mix(in oklab, #FFFFFF 60%, var(--paper));\n")
  for role in ["primary", "secondary", "warning", "success"]:
    result.add &"--{role}-soft: color-mix(in oklab, var(--{role}) {softShare}%, var(--paper));\n"
    if role != "warning":
      result.add &"--{role}-text: color-mix(in oklab, var(--{role}) {textShare}%, var(--ink));\n"

func lookCss(l: Look): string =
  &"--paper: {l.paper}; --ink: {l.ink}; --primary: {l.primary}; --secondary: {l.secondary}; " &
    &"--warning: {l.warning}; --success: {l.success};"

func paletteCss*(l: Look, selector = "html"): string =
  ## The six values of a look and every token mixed from them, on one selector: for a page with
  ## one look, such as the book (`book/bookbuild.nim` puts `paletteCss(edo)` before its theme).
  selector & " {\n" & lookCss(l) & "\n" & tokensCss(l.dark) &
    (if l.dark: "color-scheme: dark;\n" else: "") & "}\n"

const tokens =
  # Munari names its six values after where they go; the palettes post swaps them on the page.
  &"""html {{
  --m-carta: {haru.paper}; --m-inchiostro: {haru.ink}; --m-cerchio: {haru.primary};
  --m-quadrato: {haru.secondary}; --m-triangolo: {haru.warning}; --m-quarto: {haru.success};
  --paper: var(--m-carta); --ink: var(--m-inchiostro); --primary: var(--m-cerchio);
  --secondary: var(--m-quadrato); --warning: var(--m-triangolo); --success: var(--m-quarto);
""" & tokensCss() & "}\n" &
  "html[data-tema=\"quaderno\"] {\n" & lookCss(quadernoLook) & "\n}\n" &
  "html[data-tema=\"minoan\"] {\n" & lookCss(minoanLook) & "\n}\n"

# ---------------------------------------------------------------------------------------- Munari
# After Bruno Munari: flat paper, one geometric sans (Jost), and the three shapes of his books,
# each with a meaning. Nothing that only decorates may look like something to press or drag.
# These rules are the page: they need no script, so a page without JavaScript is Munari.

const munariCss = """
html {
  --hand: "Jost", "Futura", "Century Gothic", system-ui, sans-serif;
  --font: "Jost", "Futura", "Century Gothic", system-ui, sans-serif;
  --mono: ui-monospace, "SF Mono", Menlo, Consolas, "DejaVu Sans Mono", monospace;
  /* the quaderno's own motifs, kept here for the dated posts' own CSS */
  --grid: #D9E7F5;          /* the squares */
  --margin: #E9585B;        /* the red margin rule */
  --postit: #FFF6B8;        /* sticky notes */
  --highlight: rgba(255, 230, 90, .55);
  --tape: rgba(255, 214, 165, .75);
  --edge: #C9D9EC;          /* pale blue rules */
  --red-pen: #C62828;       /* corrections, subheadings, stamps */
  --sq: 20px;               /* one square, about 5 mm */
  /* names from before the tokens, for the dated posts' own CSS */
  --pencil: var(--ink); --pen: var(--ink); --pen-red: var(--primary-text);
  --card: var(--surface); --rule: var(--line); --carta: var(--shade);
  --text: var(--font); --n-0: var(--neutral-0); --n-1: var(--neutral-1); --n-2: var(--neutral-2); --n-3: var(--neutral-3); --n-4: var(--neutral-4);
  --n-5: var(--neutral-5); --n-6: var(--neutral-6); --n-7: var(--neutral-7); --n-8: var(--neutral-8); --n-9: var(--neutral-9);
  --giallo: var(--warning); --blu: var(--secondary);
}
* { box-sizing: border-box; }
[hidden] { display: none !important; }
html { -webkit-text-size-adjust: 100%; }
body {
  margin: 0; color: var(--ink); font: 18px/1.6 var(--font); background-color: var(--paper);
  padding: 0 max(14px, env(safe-area-inset-right, 0px)) 0 max(14px, env(safe-area-inset-left, 0px));
}
body > header, body > main, body > footer { max-width: 50rem; margin: 0 auto; position: relative; }
main { padding-bottom: 2rem; }
header { padding-top: .4rem; }

/* the cover: the three shapes over each other, like sheets of coloured acetate */
.forme { display: block; position: absolute; top: 6.3rem; right: 0; width: 9.5rem; height: 8.5rem; pointer-events: none; }
.forme i { position: absolute; display: block; mix-blend-mode: multiply; }
.forme .cerchio { width: 6.2rem; height: 6.2rem; border-radius: 50%; background: var(--primary); right: 0; top: 0; }
.forme .quadrato { width: 4.6rem; height: 4.6rem; background: var(--secondary); right: 3.6rem; top: 2.6rem; }
.forme .triangolo { width: 5.6rem; height: 4.9rem; background: var(--warning); right: 1.2rem; top: 3.6rem;
  clip-path: polygon(50% 0, 100% 100%, 0 100%); }
.etichetta { margin: 2.4rem 0 1.4rem; position: relative; padding: 0 10.5rem 0 0; min-height: 8.5rem; }
.etichetta .riga span:first-child { display: none; }
.etichetta .riga span:last-child { font: 400 1.25rem/1.3 var(--font); color: var(--ink); }
.etichetta .nome span:last-child { font: 700 3.4rem/1 var(--font); letter-spacing: -.03em; }
.etichetta .riga:last-child:not(.nome) span:last-child { font-size: .8rem; letter-spacing: .18em; text-transform: uppercase; color: var(--muted); }
.etichetta .nome a { color: inherit; text-decoration: none; }
@media (max-width: 560px) {
  .forme { transform: scale(.62); transform-origin: top right; top: 6rem; }
  .etichetta { padding-right: 6.4rem; min-height: 6rem; }
  .etichetta .nome span:last-child { font-size: 2.5rem; }
}
.crumbs { display: flex; justify-content: space-between; gap: 1rem; flex-wrap: wrap; padding-top: 1rem;
  font: 700 .74rem/1 var(--font); letter-spacing: .16em; text-transform: uppercase; }
.crumbs a { color: var(--ink); text-decoration: none; }
.crumbs .lingua b { border-bottom: 2px solid currentColor; }   /* the page's language, the others links */
.lede { font-size: 1.3rem; line-height: 1.45; color: var(--ink); margin: 0 0 1.2rem; }
.kicker { font: 700 .74rem/1 var(--font); letter-spacing: .2em; text-transform: uppercase; color: var(--primary-text); margin: 0; }

/* type: one sans, big and plain; sections marked by the circle */
h1, h2, h3, h4 { font-family: var(--font); font-weight: 700; color: var(--ink); letter-spacing: -.015em; line-height: 1.15; }
h1 { font-size: 2.9rem; line-height: 1.05; margin: 1.5rem 0 .4rem; }
h2 { font-size: 1.85rem; display: block; padding: 0 0 0 2.4rem; margin: 3rem 0 .9rem; position: relative; scroll-margin-top: 1rem; }
h2::before { content: ""; position: absolute; left: 0; top: .2em; width: 1.5rem; height: 1.5rem;
  background: var(--part, var(--primary)); border-radius: 50%; }
h3 { font-size: 1.25rem; color: var(--primary-text); margin: 2rem 0 .5rem; scroll-margin-top: 1rem; }
h2 .num { color: var(--muted); margin-right: .35rem; }
a { color: var(--ink); text-decoration-color: var(--primary); text-decoration-thickness: 2px; text-underline-offset: 2px; }
a:hover { background: var(--primary-soft); }
strong { font-weight: 700; }
p, li { max-width: 46rem; }
blockquote { margin: 1.2rem 0; padding: .7rem 1rem; border-left: 6px solid var(--neutral-4); }
blockquote p { margin: .3rem 0; }
hr { border: 0; border-top: 2px solid var(--ink); margin: 2rem 0; }
mark { background: var(--warning-soft); padding: 0 .15em; }
img { max-width: 100%; }

/* code: a white sheet with a black edge; outputs on grey paper */
pre { margin: 1rem 0; }
pre > code, pre.nb-output { display: block; overflow-x: auto; font: 13px/1.55 var(--mono); padding: .8rem 1rem; }
body pre > code { font-size: 13px; }
pre > code { background: var(--surface); border: 2px solid var(--ink); }
pre.nb-output { background: var(--shade); border: 0; white-space: pre; color: var(--ink); }
pre.nb-output::before { content: "output"; display: block; margin-bottom: .1rem;
  font: 700 .66rem/1.4 var(--font); letter-spacing: .2em; text-transform: uppercase; color: var(--primary-text); }
:not(pre) > code { font: .88em var(--mono); background: var(--shade); padding: .05em .3em; }
.hljs-keyword { color: var(--primary-text); font-weight: 700; } .hljs-string { color: var(--secondary-text); }
.hljs-number, .hljs-literal { color: var(--success-text); }
.hljs-comment { color: var(--muted); font-style: italic; } .hljs-type { color: var(--ink); font-weight: 700; }
.hljs-built_in { color: var(--primary-text); } .hljs-meta { color: var(--muted); }

/* tables: no tape, no squares; the rules come from optCssTheme(), from the tokens */
.tabella { position: relative; margin: 1.6rem 0 1.8rem; padding: 16px 0 10px; }
.tabella .tb_title { font-family: var(--hand); font-size: 125%; letter-spacing: -.01em; }
.tabella td code { overflow-wrap: anywhere; }  /* long names in a cell wrap on a phone */
main table:not(.tb_table) { border-collapse: collapse; margin: 1rem 0; background: var(--surface); }
main table:not(.tb_table) th, main table:not(.tb_table) td { border: 1px solid var(--line); padding: .35rem .6rem; text-align: left; vertical-align: top; }

/* the indice: numbers on circles, as the section headings */
.indice { padding: 1rem 0; margin: 1.4rem 0 2rem; max-width: 36rem;
  border-top: 3px solid var(--ink); border-bottom: 3px solid var(--ink); }
.indice h2.indice-title { font: 700 .78rem/1 var(--font); letter-spacing: .2em; text-transform: uppercase;
  color: var(--ink); padding: 0; margin: 0 0 .9rem; display: block; }
.indice h2.indice-title::before { display: none; }
.indice ol { margin: 0; }
.indice > ol { list-style: none; padding: 0; counter-reset: voce; font: 500 1.08rem/1.5 var(--font); }
.indice > ol > li { counter-increment: voce; position: relative; padding-left: 2.3rem; margin: .35rem 0; }
.indice > ol > li::before { content: counter(voce); position: absolute; left: 0; top: .1rem; width: 1.5rem; height: 1.5rem;
  border-radius: 50%; background: var(--primary); color: #fff; font: 700 .78rem/1.5rem var(--font); text-align: center; }
.indice > ol > li.parte-secondary::before { background: var(--secondary); color: var(--ink); }
.indice > ol > li.parte-success::before { background: var(--success); color: var(--ink); }
.indice ol ol { font: 400 .95rem/1.45 var(--font); padding-left: 0; margin: .15rem 0 .3rem; list-style: none; }
/* back to the indice: an arrow at the end of every heading, on the pages that have an indice */
.su { display: none; margin-left: .45rem; padding: .2em .45em; font-size: .55em; vertical-align: .25em;
  color: var(--muted); text-decoration: none; border: 1px solid var(--line); line-height: 1; }
.su::before { content: "↑"; }
.su:hover, .su:focus-visible { color: var(--ink); border-color: var(--ink); }
body:has(#indice) .su { display: inline-block; }
.indice ol ol li::before { content: "— "; color: var(--muted); }
.indice a { text-decoration-line: none; color: var(--ink); }
.indice a:hover { text-decoration-line: underline; }

/* sheets set apart (notes, cards, gallery cards): flat paper with the square's straight top edge,
   in the colour of their kind; nothing on them to press. A warning carries the triangle. */
.nota { padding: 1rem 1.2rem; margin: 1.3rem 0; background: var(--shade); border-top: 5px solid var(--ink); }
.nota.info { background: var(--secondary-soft); border-top-color: var(--secondary); }
.nota.done, .nota.code { background: var(--success-soft); border-top-color: var(--success); }
.nota.missing { background: var(--primary-soft); border-top-color: var(--primary); }
.nota.warning { background: var(--warning-soft); border-top-color: var(--warning); }
.nota > :first-child { margin-top: 0; } .nota > :last-child { margin-bottom: 0; }
.nota .titolo { font: 700 1.1rem var(--font); color: var(--ink); display: block; }
.nota .numero { font: 700 .72rem/1.2 var(--font); letter-spacing: .14em; color: var(--muted); display: block; }
.nota.warning { position: relative; padding-left: 3.1rem; }
.nota.warning::before, .nota.warning::after { content: ""; position: absolute; left: 1.1rem; top: 1.1rem; width: 1.4rem; height: 1.25rem;
  clip-path: polygon(50% 0, 100% 100%, 0 100%); }
.nota.warning::before { background: var(--ink); }
.nota.warning::after { background: var(--warning); transform: scale(.7); transform-origin: 50% 68%; }
.timbro { display: inline-block; font: 700 .8rem/1.6 var(--font); letter-spacing: .12em; text-transform: uppercase;
  color: var(--ink); border: 2px solid var(--ink); padding: 0 .5rem; }
.timbro.ok { color: var(--success-text); border-color: var(--success); }
.timbro.ko { background: var(--primary-soft); }

/* cards (nbCards, nbCard): a grid of notes */
.cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(14rem, 1fr)); gap: 1rem; margin: 1.2rem 0; }
.cards .nota { margin: 0; }
.cards .nota .titolo + p { margin-top: .3rem; }

/* a gallery (nbGallery, nbGalleryCard): cards to swipe sideways, numbered */
.nb-galleria { display: flex; align-items: flex-start; gap: .8rem; overflow-x: auto; scroll-snap-type: x mandatory;
  padding: .2rem 0 .8rem; counter-reset: nb-scheda; -webkit-overflow-scrolling: touch; }
.nb-galleria::after { content: ""; flex: 0 0 .2rem; }
.nb-galleria > .nb-scheda { flex: 0 0 min(84%, 24rem); scroll-snap-align: start; overflow-x: auto; padding: .7rem .9rem .8rem;
  background: var(--shade); border: 0; border-top: 5px solid var(--secondary); counter-increment: nb-scheda; }
.nb-galleria > .nb-scheda::before { content: counter(nb-scheda); display: block; font: 700 .72rem/1.2 var(--font); letter-spacing: .14em; color: var(--muted); }
.nb-galleria > .nb-scheda > h3 { margin: .15rem 0 .4rem; font-size: 1.15rem; }
.nb-galleria > .nb-scheda[data-label]::before { content: attr(data-label) " · " counter(nb-scheda); text-transform: uppercase; }
.nb-galleria > .nb-scheda p { font-size: .94rem; line-height: 1.45; margin: 0 0 .5rem; }
.nb-scheda pre { margin: .4rem 0; }
body .nb-scheda pre > code { font-size: 12.5px; white-space: pre-wrap; overflow-wrap: anywhere; }
.nb-scheda .tabella { margin: .4rem 0 0; }
.nb-scheda .tabella table { font-size: 14px !important; }
.accanto { display: flex; flex-wrap: wrap; gap: 0 .6rem; justify-content: center; align-items: flex-start; }

/* tabs (nbTabs): the same example in Nim, Python and R; the choice holds for the whole page */
.lingue { margin: 1.2rem 0; }
.lingue-tab { display: flex; gap: 0; flex-wrap: wrap; }
.lingue-tab button { font: 700 .72rem/1.6 var(--font); letter-spacing: .1em; text-transform: uppercase; color: var(--ink);
  background: transparent; border: 2px solid var(--ink); border-bottom: 0; padding: .15rem .8rem; cursor: pointer; margin-right: -2px; }
.lingue-tab button[aria-selected="true"] { background: var(--ink); color: var(--paper); }
.lingue-pannello { border-top: 2px solid var(--ink); padding-top: .2rem; }
.lingue-pannello > pre:first-child { margin-top: .6rem; }

/* the code of a table, folded under it (nbShowCode) */
details.codice { margin: -.8rem 0 1.6rem; }
details.codice > summary { list-style: none; cursor: pointer; display: inline-block; font: 700 .68rem/1.6 var(--font);
  letter-spacing: .12em; text-transform: uppercase; color: var(--ink); border-bottom: 2px solid var(--secondary); }
details.codice > summary::-webkit-details-marker { display: none; }
details.codice > summary::before { content: "+ show code"; }
details.codice[open] > summary::before { content: "− hide code"; }
details.codice pre { margin: .4rem 0 0; }
body /* a drawing (nbDrawing): a Pele diagram in the page's colours */
.disegno { margin: 1.4rem 0; }
.disegno svg { display: block; max-width: 100%; height: auto; margin: 0 auto; --pele-bg: var(--paper); --pele-fg: var(--ink);
  --pele-muted: var(--muted); --pele-line: var(--ink); --pele-border: var(--ink); --pele-surface: var(--surface);
  --pele-surface-alt: var(--neutral-1); --pele-accent: var(--secondary); }
/* a map (an SVG with class map, from a story's data): its parts in the page's colours */
.disegno svg.map .sea { fill: var(--surface); }
.disegno svg.map .land { fill: var(--neutral-2); stroke: var(--neutral-4); stroke-width: 1; }
.disegno svg.map .main { fill: var(--secondary); }
.disegno svg.map .dot { fill: var(--primary); stroke: var(--surface); stroke-width: 1.5; }
.disegno svg.map text { font-family: inherit; }
.disegno svg.map .sea-name { fill: var(--muted); font-style: italic; letter-spacing: 1.5px; }
.disegno svg.map .name { fill: var(--ink); font-weight: 600; paint-order: stroke; stroke: var(--surface);
  stroke-width: 5px; stroke-linejoin: round; }
.disegno figcaption { margin-top: .5rem; font-size: .9rem; color: var(--muted); }
body details.codice pre > code { font-size: 12.5px; }

/* code, folded under its name and its length (nbFoldCode) */
details.foldcode { margin: 0; border-top: 1px solid var(--line); border-bottom: 1px solid var(--line); }
details.foldcode + details.foldcode { border-top: 0; }
details.foldcode:not(:has(+ details.foldcode)) { margin-bottom: 1.6rem; }
details.foldcode > summary { list-style: none; cursor: pointer; padding: .45rem 0; display: flex; gap: .6rem;
  align-items: baseline; }
details.foldcode > summary::-webkit-details-marker { display: none; }
details.foldcode > summary::before { content: "+"; font-weight: 700; width: .8rem; color: var(--secondary); }
details.foldcode[open] > summary::before { content: "−"; }
details.foldcode > summary > span { margin-left: auto; font-size: .8rem; white-space: nowrap; }
details.foldcode pre { margin: .2rem 0 .8rem; }
body details.foldcode pre > code { font-size: 12.5px; }

/* the parts of a table (nbParts): a switch between the data and its parts, and their legend */
.parti { list-style: none; padding: 0; margin: .8rem 0; }
.parti li { margin: .35rem 0; padding-left: 2rem; position: relative; line-height: 1.45; }
.tinta-parte { position: absolute; left: 0; top: .25em; width: 1.3rem; height: 1rem; outline: 1px solid var(--line); }
.parti .colore { color: var(--muted); font-size: .88em; }
.mostra-parti { font: 700 .72rem/1.6 var(--font); letter-spacing: .14em; text-transform: uppercase; cursor: pointer;
  border: 2px solid var(--ink); background: transparent; color: var(--ink); padding: .3rem .8rem; margin: .2rem 0 0; }
.mostra-parti[aria-pressed="true"] { background: var(--ink); color: var(--paper); }

/* a palette sample (nbInPalette): blocks on another look's paper, with its tokens */
.in-palette { background: var(--paper); color: var(--ink); padding: .9rem .7rem; margin: .8rem 0;
  border: 1px solid var(--line); }
.in-palette > p:first-child { margin-top: 0; font-size: .8rem; letter-spacing: .12em; text-transform: uppercase; color: var(--muted); }

/* a palette tried on the page (nbTryPalette): the button, pressed while the palette is on */
.prova-palette { font: 700 .72rem/1.6 var(--font); letter-spacing: .12em; text-transform: uppercase; cursor: pointer;
  border: 2px solid var(--ink); background: transparent; color: var(--ink); padding: .35rem .8rem; }
.prova-palette[aria-pressed="true"] { background: var(--ink); color: var(--paper); }

/* swatches (nbSwatches): a colour beside its name */
.tinte { display: grid; grid-template-columns: repeat(auto-fill, minmax(9.5rem, 1fr)); gap: .8rem; margin: 1rem 0; }
.tinte .tinta { font-size: .86rem; line-height: 1.35; }
.tinte .tinta span { display: block; height: 2.4rem; margin-bottom: .3rem; outline: 1px solid var(--neutral-2); }
.tinte .tinta strong { display: block; font-size: .95rem; }
/* in a gallery card the swatches are small, three to a row */
.nb-scheda .tinte { grid-template-columns: repeat(3, 1fr); gap: .5rem; }
.nb-scheda .tinte .tinta { font-size: .78rem; line-height: 1.25; }
.nb-scheda .tinte .tinta span { height: 1.4rem; margin-bottom: .2rem; }
.nb-scheda .tinte .tinta strong { font-size: .82rem; }

/* a tournament (nbTournament): rounds of matches, two buttons each, and the result to copy */
.torneo { margin: 1rem 0 1.4rem; }
.torneo-turno { margin: 1.2rem 0 .45rem; font: 700 .76rem/1.2 var(--font); letter-spacing: .14em; text-transform: uppercase; color: var(--muted); }
.torneo-partite { display: grid; gap: .8rem; }
.torneo-partita { display: grid; grid-template-columns: 1fr 1fr; gap: .4rem; }
.torneo-num { grid-column: 1 / -1; font-size: .74rem; color: var(--muted); display: flex; justify-content: space-between; align-items: baseline; }
.torneo-undo { font: inherit; font-size: .74rem; color: var(--ink); background: none; border: 0; padding: .1rem 0 .1rem .6rem;
  text-decoration: underline; text-decoration-color: var(--primary); cursor: pointer; }
.torneo-player { display: flex; flex-direction: column; border: 1px solid var(--line); background: var(--paper); min-height: 3.4rem; }
.torneo-open { flex: 1; display: flex; flex-direction: column; align-items: stretch; gap: .3rem; text-align: left; font: inherit;
  color: var(--ink); background: none; border: 0; border-radius: 0; padding: .45rem .55rem .45rem; cursor: pointer;
  -webkit-tap-highlight-color: transparent; }
.torneo-open strong { font-size: .88rem; line-height: 1.25; }
.torneo-what { font-size: .74rem; color: var(--muted); }
.torneo-keep { font: inherit; font-size: .78rem; color: var(--ink); background: var(--shade); border: 0; border-top: 1px solid var(--line);
  border-radius: 0; padding: .35rem .55rem; text-align: left; cursor: pointer; }
.torneo-player.torneo-in { border-color: var(--primary); box-shadow: inset 0 0 0 1px var(--primary); }
.torneo-player.torneo-in .torneo-keep { background: var(--primary-soft); font-weight: 700; }
.torneo-player.torneo-out .torneo-open { opacity: .45; }
.torneo-player.torneo-unknown { border-style: dashed; padding: .45rem .55rem; justify-content: center; }
.torneo-dialog { width: min(34rem, calc(100% - 1.4rem)); max-height: 86vh; padding: 0; border: 1px solid var(--line);
  background: var(--paper); color: var(--ink); display: none; flex-direction: column; }
.torneo-dialog[open] { display: flex; }
.torneo-dialog::backdrop { background: color-mix(in oklab, var(--ink) 45%, transparent); }
.torneo-dialog-card { overflow-y: auto; padding: .4rem .4rem 0; }
.torneo-dialog .nb-galleria { display: block; overflow: visible; padding: 0; margin: 0; }
.torneo-dialog .nb-galleria > .nb-scheda { flex: none; overflow: visible; }
.torneo-dialog .nb-galleria > .nb-scheda::before { display: none; }
.torneo-dialog-bar { display: flex; gap: .5rem; padding: .6rem; border-top: 1px solid var(--line); background: var(--paper); }
.torneo-dialog-bar button { font: inherit; font-size: .92rem; padding: .45rem .9rem; border: 1px solid var(--line); background: var(--shade);
  color: var(--ink); border-radius: 0; cursor: pointer; }
.torneo-dialog-bar .torneo-dialog-keep { flex: 1; border-color: var(--primary); box-shadow: inset 0 0 0 1px var(--primary); font-weight: 700; }
.torneo-tinte { display: flex; height: .5rem; }
.torneo-tinte i { flex: 1; }
.torneo-bye { margin: 0; font-size: .85rem; color: var(--muted); }
.torneo-fine { margin-top: 1.2rem; display: flex; flex-wrap: wrap; gap: .5rem; align-items: center; }
.torneo-esito { flex: 1 1 100%; margin: 0; font-weight: 700; }
.torneo-fine button { font: inherit; font-size: .9rem; padding: .4rem .8rem; background: var(--shade); color: var(--ink);
  border: 1px solid var(--line); border-radius: 0; cursor: pointer; }
.torneo-fine textarea { flex: 1 1 100%; min-height: 10rem; font: 12.5px/1.4 ui-monospace, Menlo, monospace; color: var(--ink);
  background: var(--surface); border: 1px solid var(--line); }

/* parts of a long page (nbPart): a label, then the sections' circles take the part's colour */
.parte { font: 700 .74rem/1 var(--font); letter-spacing: .2em; text-transform: uppercase; margin: 3.4rem 0 -1.2rem; color: var(--muted); }
.parte-secondary ~ :is(h2, .titolo-foto) { --part: var(--secondary); } .parte-success ~ :is(h2, .titolo-foto) { --part: var(--success); }
/* a later part wins over an earlier one, whatever its colour: one more class for the second part on */
.parte ~ .parte-primary ~ :is(h2, .titolo-foto) { --part: var(--primary); }
.parte ~ .parte-secondary ~ :is(h2, .titolo-foto) { --part: var(--secondary); }
.parte ~ .parte-success ~ :is(h2, .titolo-foto) { --part: var(--success); }

/* a section's heading over a photo (nbPhotoHeading): the photo as wide as the text and low, the
   heading over its lower edge in the paper's colour, on a band of ink dark enough for any photo
   (a pale sky too), and in every look (one more class than a look's own heading colour); while
   the photo loads, the band is the shade; the credit small, under it */
.titolo-foto { margin: 3rem 0 1rem; }
.titolo-foto-img { position: relative; background: var(--shade); aspect-ratio: 2 / 1; max-height: 11rem; width: 100%; }
.titolo-foto-3 .titolo-foto-img { max-height: 8.5rem; }
.titolo-foto img { display: block; width: 100%; height: 100%; object-fit: cover; }
.titolo-foto .titolo-foto-img :is(h2, h3) { position: absolute; left: 0; right: 0; bottom: 0; margin: 0; color: var(--paper);
  padding: 2.6rem .8rem .7rem 3.2rem; text-shadow: 0 1px 3px color-mix(in oklab, var(--ink) 70%, transparent);
  background: linear-gradient(transparent, color-mix(in oklab, var(--ink) 70%, transparent) 45%, color-mix(in oklab, var(--ink) 88%, transparent)); }
.titolo-foto h2::before { left: .8rem; top: auto; bottom: .85rem; box-shadow: 0 0 0 2px var(--paper); }
.titolo-foto .titolo-foto-img h3 { padding-left: .8rem; font-style: normal; font-weight: 700; }
.titolo-foto .su { color: var(--paper); border-color: color-mix(in oklab, var(--paper) 60%, transparent); text-shadow: none; }
.titolo-foto figcaption { margin-top: .35rem; font-size: .78rem; line-height: 1.35; color: var(--muted); }
.titolo-foto figcaption a { color: var(--muted); }

/* the specs page (nbSpecs): each capability folds open; examples carry a pass stamp */
details.spec { background: var(--shade); border: 0; border-top: 5px solid var(--secondary); margin: .8rem 0; padding: .5rem 1rem; }
details.spec > summary { cursor: pointer; font-size: 1.1rem; }
details.spec > summary b { font: 700 1.2rem var(--font); color: var(--ink); margin-right: .4rem; }
details.spec .counts { color: var(--muted); font-size: .85rem; }
details.spec .purpose { display: block; color: var(--ink); font-size: .95rem; margin: .2rem 0 .3rem; }
.req { border-top: 2px dashed var(--line); padding: .4rem 0 .6rem; }
.req h4 { font: 700 1rem var(--font); color: var(--primary-text); margin: .6rem 0 .2rem; }
.example { margin: .6rem 0 1rem; }
.example .ex-head { display: flex; gap: .6rem; align-items: center; font-size: .8rem; color: var(--muted); }
.ex-out summary { cursor: pointer; font: 700 1rem var(--font); color: var(--muted); }
.scen { background: var(--paper); padding: .4rem .8rem; margin: .5rem 0; }
.scen-name { font: 700 1rem var(--font); color: var(--ink); }
.scen ul { margin: .2rem 0; padding-left: 1.2rem; }
.kw { font: 600 .75rem var(--font); letter-spacing: .08em; padding: 0 .3rem; border-radius: 4px; }
.kw.when { background: var(--secondary-soft); } .kw.then { background: var(--success-soft); } .kw.and, .kw.given { background: var(--neutral-2); }
.src { font-size: .8rem; color: var(--muted); }
details.links summary { cursor: pointer; }

/* a part of a page folded under a line (nbFold): closed at first */
details.fold { border-top: 2px solid var(--ink); border-bottom: 2px solid var(--ink); margin: 1rem 0 1.6rem; }
details.fold > summary { list-style: none; cursor: pointer; padding: .55rem 0; display: flex; gap: .6rem; font: 700 1rem var(--font); }
details.fold > summary::-webkit-details-marker { display: none; }
details.fold > summary::before { content: "+"; width: .8rem; color: var(--secondary); }
details.fold[open] > summary::before { content: "−"; }
details.fold[open] > summary { border-bottom: 1px solid var(--line); }

/* the API reference (nbApi): one sheet per name, its straight top edge in ink */
.api { border-top: 2px solid var(--ink); margin: 1.6rem 0 0; padding: .3rem 0 .2rem; scroll-margin-top: 1rem; }
.api h4 { display: flex; align-items: baseline; gap: .6rem; flex-wrap: wrap; margin: .2rem 0 .4rem; }
.api h4 code { font: 700 1.05rem var(--mono); color: var(--ink); background: none; padding: 0; overflow-wrap: anywhere; }
.api .api-anchor { margin-left: auto; font: 700 1rem var(--font); color: var(--muted); text-decoration: none; padding: 0 .3rem; }
.api .api-anchor:hover, .api:target .api-anchor { color: var(--primary-text); }
.api .api-kind { font: 700 .7rem/1 var(--font); letter-spacing: .16em; text-transform: uppercase; color: var(--muted); }
.api pre.api-sig { margin: .3rem 0; }
.api > p { margin: .4rem 0; }
.api > p code, .api li code { overflow-wrap: anywhere; }
.api .api-none { color: var(--muted); font-style: italic; }
.api .api-links { font-size: .82rem; color: var(--muted); }
.api .api-links a { color: var(--ink); }
.api details.api-ex { margin: .5rem 0; }
.api details.api-ex > summary { cursor: pointer; font: 700 .9rem var(--font); color: var(--muted); }

/* the look switch: ink, the selected one filled */
.switches { display: flex; justify-content: flex-end; flex-wrap: wrap; gap: .5rem; margin: .6rem 0 0; }
@media (max-width: 560px) { .switches:has(.ora) + .forme { top: 8.4rem; } .switches:has(.ora) ~ .etichetta { margin-top: 3.6rem; } }
.tema, .ora { display: flex; gap: 0; }
.tema button, .ora button { font: 700 .72rem/1.6 var(--font); letter-spacing: .14em; text-transform: uppercase; cursor: pointer;
  border: 2px solid var(--ink); background: transparent; color: var(--ink); padding: .2rem .7rem; }
.tema button:last-child, .ora button:last-child { border-left: 0; }
.tema button[aria-pressed="true"], .ora button[aria-pressed="true"] { background: var(--ink); color: var(--paper); }

/* footer, with Munari's motto */
footer { font: 400 .9rem/1.5 var(--font); color: var(--muted); padding: 1rem 0 3rem; text-align: center;
  border-top: 2px solid var(--ink); }
body > footer { margin-top: 2rem; }
footer a { color: var(--ink); }
.motto { display: block; font: 700 1.35rem/1.3 var(--font); color: var(--ink); margin: .2rem 0 1rem; }
.motto span { display: block; font: 400 .74rem/2 var(--font); letter-spacing: .2em; text-transform: uppercase; color: var(--primary-text); }
details.source { margin-top: 1rem; text-align: left; }
details.source summary { cursor: pointer; }
details.source pre { overflow-x: auto; }   /* the whole source, top to bottom: it is opened on purpose */
/* a screenshot with numbered circles (nbScreenshot): the circle is a place */
.schermata { margin: 1rem 0; width: min(47%, 15rem); }
.schermata > div { position: relative; }
.schermata img { display: block; width: 100%; height: auto; border: 1px solid var(--line); }
.schermata .punto { position: absolute; transform: translate(-50%, -50%); width: 1.25rem; height: 1.25rem; border-radius: 50%;
  display: flex; align-items: center; justify-content: center; font: 700 .72rem/1 var(--font);
  background: var(--primary); color: var(--paper); box-shadow: 0 0 0 2px var(--paper); }
.schermata figcaption { font-size: .8rem; line-height: 1.35; color: var(--muted); margin-top: .3rem; }
"""

# ------------------------------------------------------------------------------------ the quaderno
# An Italian school exercise book, the other look: squared paper, a red margin, headings in blue
# pen with a highlighter stroke, code on index cards, outputs on sticky notes, tables taped in.
# Every rule is scoped by `html[data-tema="quaderno"]` and changes only what differs from Munari.

const quadernoRules = """
html {
  --hand: "Patrick Hand", "Segoe Print", "Comic Sans MS", cursive;
  --font: "Atkinson Hyperlegible", system-ui, -apple-system, "Segoe UI", sans-serif;
  --pen: var(--primary); --pen-red: var(--red-pen);
}
body { font: 17px/1.6 var(--font);
  background-image:
    linear-gradient(var(--grid) 1px, transparent 1px),
    linear-gradient(90deg, var(--grid) 1px, transparent 1px);
  background-size: var(--sq) var(--sq); }
main { padding-left: 2.2rem; border-left: 3px double var(--margin); }
@media (max-width: 640px) { main { padding-left: .9rem; } }
header { padding-top: 0; }

/* the cover label */
.etichetta { margin: 2.2rem auto 1.6rem; max-width: 30rem; background: var(--surface); min-height: auto;
  border: 2px solid var(--primary); border-radius: 18px; padding: 1rem 1.4rem 1.1rem;
  box-shadow: 4px 5px 0 color-mix(in srgb, var(--primary) 15%, transparent); }
.etichetta::before { content: ""; position: absolute; inset: 6px; border: 1px solid var(--edge); border-radius: 13px; pointer-events: none; }
.etichetta .riga { display: flex; gap: .6rem; align-items: baseline; border-bottom: 1.5px dotted var(--edge); padding: .15rem 0; }
.etichetta .riga span:first-child { display: inline; font: 600 .72rem/1 var(--font); letter-spacing: .12em; text-transform: uppercase; color: var(--muted); min-width: 5.2rem; }
.etichetta .riga span:last-child { font: 1.55rem/1.25 var(--hand); color: var(--primary); }
.etichetta .nome span:last-child { font: 2.3rem/1.25 var(--hand); letter-spacing: normal; }
.etichetta .riga:last-child:not(.nome) span:last-child { font-size: 1.55rem; letter-spacing: normal; text-transform: none; color: var(--primary); }
.crumbs { font: 1.05rem var(--hand); letter-spacing: normal; text-transform: none; padding-top: .8rem; }
.crumbs a { color: var(--primary); text-decoration-line: underline; }
.lede { font-size: 1.15rem; line-height: inherit; }
.kicker { font-weight: 600; letter-spacing: .14em; color: var(--red-pen); }

/* headings in blue pen, with a highlighter stroke */
h1, h2, h3, h4 { font-family: var(--hand); font-weight: 400; color: var(--primary); letter-spacing: normal; }
h1 { font-size: 2.6rem; line-height: 1.15; }
h2 { font-size: 2.05rem; margin: 2.6rem 0 .8rem -.3rem; display: inline-block; position: static; padding: 0 .3rem;
  background: linear-gradient(transparent 55%, var(--highlight) 55%, var(--highlight) 92%, transparent 92%); }
h2::before { content: none; }
h3 { font-size: 1.55rem; margin-top: 1.8rem; color: var(--red-pen); }
h2 .num { color: var(--red-pen); }
a { color: var(--primary); text-decoration-color: currentcolor; text-decoration-thickness: 1.5px; }
a:hover { background: none; }
blockquote { background: var(--postit); border-radius: 2px 2px 14px 2px; border-left: 0;
  box-shadow: 2px 3px 6px rgba(0,0,0,.08); transform: rotate(-.4deg); }
hr { border-top: 2px dashed var(--edge); }
mark { background: var(--highlight); }

/* code on index cards, outputs on sticky notes */
pre > code, pre.nb-output { border-radius: 6px; }
pre > code { border: 1px solid var(--edge); border-left: 5px solid var(--primary);
  box-shadow: 2px 3px 0 color-mix(in srgb, var(--primary) 8%, transparent); }
pre.nb-output { background: var(--postit); box-shadow: 2px 3px 6px rgba(0,0,0,.07); }
pre.nb-output::before { font: .95rem var(--hand); letter-spacing: normal; text-transform: none; color: var(--muted); }
:not(pre) > code { background: color-mix(in srgb, var(--primary) 7%, transparent); border-radius: 4px; }
.hljs-string { color: var(--success-text); }
.hljs-number, .hljs-literal { color: var(--secondary-text); }
.hljs-type { color: var(--primary); font-weight: inherit; } .hljs-built_in { color: var(--secondary-text); }

/* tables pasted in, with a strip of tape, on squared paper */
.tabella { padding: 18px 14px 12px; background: var(--surface);
  box-shadow: 0 1px 2px rgba(0,0,0,.08), 3px 5px 14px rgba(0,0,0,.07); border-radius: 2px; }
.tabella::before { content: ""; position: absolute; top: -11px; left: 50%; width: 110px; height: 24px;
  margin-left: -55px; background: var(--tape); transform: rotate(-2deg); box-shadow: 0 1px 2px rgba(0,0,0,.08); }
.tabella .tb_table { background-image: linear-gradient(var(--grid) 1px, transparent 1px),
  linear-gradient(90deg, var(--grid) 1px, transparent 1px); background-size: 12px 12px; }
.tabella .tb_title { font-size: 150%; letter-spacing: normal; }
main table:not(.tb_table) th, main table:not(.tb_table) td { border-color: var(--edge); }

/* the indice: a sticky note with the headings */
.indice { background: var(--postit); padding: 1rem 1.3rem 1.1rem; max-width: 34rem; border: 0;
  box-shadow: 2px 4px 10px rgba(0,0,0,.1); transform: rotate(.5deg); border-radius: 2px 2px 18px 2px; }
.indice h2.indice-title { font: 400 1.7rem/1.15 var(--hand); letter-spacing: normal; text-transform: none; background: none;
  color: var(--red-pen); margin: 0 0 .4rem; }
.indice > ol { list-style: decimal; padding-left: 1.5rem; counter-reset: none; font: 1.2rem/1.45 var(--hand); }
.indice > ol > li { counter-increment: none; position: static; padding-left: 0; margin: 0; }
.indice > ol > li::before { content: none; }
.indice ol ol { font: 1.05rem/1.45 var(--hand); padding-left: 1.1rem; margin: 0; }
.indice ol ol li::before { content: "– "; }
.indice a { color: var(--primary); }

/* notes (nbNote): a sticky note, coloured by its kind; a warning carries the triangle */
.nota { background: var(--postit); padding: .8rem 1.1rem; border-top: 0; border-radius: 2px 2px 14px 2px;
  box-shadow: 2px 3px 8px rgba(0,0,0,.09); transform: rotate(-.3deg); }
.nota.info { background: var(--secondary-soft); } .nota.done, .nota.code { background: var(--success-soft); }
.nota.missing { background: var(--primary-soft); } .nota.warning { background: var(--warning-soft); }
.nota .titolo { font: 1.3rem var(--hand); color: var(--red-pen); }
.nota.warning { padding-left: 3rem; }
.nota.warning::before, .nota.warning::after { left: .9rem; top: .9rem; }
.timbro { font: 1.05rem var(--hand); letter-spacing: normal; text-transform: none; color: var(--red-pen); border-color: var(--red-pen);
  border-radius: 8px; transform: rotate(-4deg); }
.timbro.ok { color: var(--success-text); border-color: var(--success-text); }
.nb-galleria > .nb-scheda { background: var(--surface); border: 1px solid var(--line); }
.accanto .tabella { padding-left: 6px; padding-right: 6px; }

/* tabs and switches in blue pen */
.lingue-tab button { font: 1rem var(--hand); letter-spacing: normal; text-transform: none; color: var(--primary);
  background: var(--surface); border: 1.5px solid var(--primary); border-bottom: 0; margin-right: -1.5px; }
.lingue-tab button[aria-selected="true"] { background: var(--primary); color: var(--paper); }
.lingue-pannello { border-top: 1.5px solid var(--primary); }
details.codice { margin-top: -1rem; }
details.codice > summary { font: 1rem var(--hand); letter-spacing: normal; text-transform: none; color: var(--primary); border-bottom: 0; }

/* specs */
details.spec { background: var(--surface); border: 1.5px solid var(--line); border-radius: 10px; }
details.spec > summary b { font: 1.45rem var(--hand); color: var(--primary); }
.req h4 { font: 1.3rem var(--hand); color: var(--red-pen); }
.ex-out summary { font: 1.05rem var(--hand); }
.scen { background: var(--shade); border-radius: 8px; }
.scen-name { font: 1.1rem var(--hand); color: var(--primary); }

/* the look switch */
.tema button, .ora button { font: 1rem var(--hand); letter-spacing: normal; text-transform: none; color: var(--primary);
  background: var(--surface); border: 1.5px solid var(--primary); padding: .1rem .7rem; }
.tema button:first-child, .ora button:first-child { border-radius: 10px 0 0 10px; } .tema button:last-child, .ora button:last-child { border-radius: 0 10px 10px 0; border-left: 0; }
.tema button[aria-pressed="true"], .ora button[aria-pressed="true"] { background: var(--primary); color: var(--paper); }
.forme, .motto { display: none; }

footer { font: 1.05rem var(--hand); border-top: 0; }
body > footer { margin-top: 0; }
footer a { color: var(--primary); }
"""

func scoped*(rules, scope: string): string =
  ## Puts `scope` before every selector of `rules`; `html` itself becomes `scope`. Rules inside
  ## `@media` are scoped too; comments are kept.
  var i = 0
  while i < rules.len:
    if rules.continuesWith("/*", i):
      let e = rules.find("*/", i) + 2
      result.add rules[i ..< e]; i = e
    elif rules[i] in {'}', '\n', ' '}:
      result.add rules[i]; inc i
    elif rules.continuesWith("@media", i):
      let e = rules.find('{', i) + 1
      result.add rules[i ..< e]; i = e
    else:
      let e = rules.find('{', i)
      var sels: seq[string]
      for s in rules[i ..< e].split(','):
        let s = s.strip
        sels.add(if s == "html": scope else: scope & " " & s)
      let close = rules.find('}', e)
      result.add sels.join(", ") & " " & rules[e .. close]; i = close + 1

const quadernoCss = scoped(quadernoRules, "html[data-tema=\"quaderno\"]")


# ---------------------------------------------------------------------------------------- Minoan
# After the frescoes of Knossos and Thera and the vases of Athens (devlog "Designing a Mediterranean
# look"): lime plaster for paper, the black glaze for ink, terracotta and dolphin blue; one serif
# made for Greek and Latin scholarship, Gentium Book Plus, which has every letter of the islands'
# names (ć č š ž ğ ş ı ħ ġ, and Sicilian ḍ); the running wave as the rule over every table and
# under the masthead, the meander over the footer (swapped in Pietro's review of version 8). Drawn as masks, so their colour is a token.

func svgUrl(svg: string): string =
  "url(\"data:image/svg+xml," & svg.multiReplace(("<", "%3C"), (">", "%3E"), ("\"", "'"), ("#", "%23")) & "\")"

const
  meander* = svgUrl("""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path d="M0 1.5H24M0 22.5H24M2 19V5H18V15H8V10H13" fill="none" stroke="black" stroke-width="2.4"/></svg>""")
    ## The Greek key between two rules, one unit, to repeat sideways.
  runningWave* = svgUrl("""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 14" width="20" height="14"><path d="M0 12C4 12 3 2 10 2C16 2 16 9 12 9C9 9 9 6 11 6M10 12H20" fill="none" stroke="black" stroke-width="1.8"/></svg>""")
    ## The running wave (the "running dog" of Greek borders), one unit, to repeat sideways.

const minoanRules = """
html {
  --font: "Gentium Book Plus", "Gentium Plus", Georgia, "Times New Roman", serif;
  --hand: var(--font);
  --meander: """ & meander & """;
  --wave: """ & runningWave & """;
}
body { font: 19px/1.6 var(--font); font-variant-numeric: oldstyle-nums proportional-nums; }

/* the masthead: the wordmark in spaced capitals, then a running wave in dolphin blue instead of Munari's shapes */
.forme { display: none; }
.etichetta { padding-right: 0; min-height: 0; margin: 2rem 0 1.6rem; padding-bottom: 1.6rem; }
.etichetta::after { content: ""; position: absolute; left: 0; right: 0; bottom: 0; height: 14px; background: var(--secondary);
  -webkit-mask: var(--wave) repeat-x left center / auto 14px; mask: var(--wave) repeat-x left center / auto 14px; }
.etichetta .nome span:last-child { font: 700 2.7rem/1 var(--font); letter-spacing: .14em; text-transform: uppercase; color: var(--ink); }
.etichetta .riga:last-child:not(.nome) span:last-child { font-variant: small-caps; text-transform: lowercase; letter-spacing: .12em; color: var(--primary-text); }
.kicker { font: 400 .95rem/1.2 var(--font); font-variant: small-caps; text-transform: lowercase; letter-spacing: .14em; color: var(--primary-text); }
.lede { font-style: italic; font-size: 1.25rem; }

/* headings: the serif, bold, a little open; the section circle is a terracotta disc ringed in black glaze */
h1, h2, h3, h4 { font-family: var(--font); letter-spacing: .005em; }
h1 { font-size: 2.6rem; line-height: 1.08; }
h2 { font-size: 1.75rem; }
h2::before { box-shadow: inset 0 0 0 2.5px var(--ink); }
h3 { font-style: italic; font-weight: 400; font-size: 1.35rem; color: var(--primary-text); }
a { text-decoration-color: var(--primary); text-decoration-thickness: 1.5px; text-underline-offset: .15em; }
blockquote { border-left: 3px solid var(--primary); font-style: italic; }

/* tables: a running wave in dolphin blue as the rule above, lining figures that line up */
.tabella:not(#_) { padding-top: 26px; }  /* :not(#_) to win over the table's own stylesheet */
.tabella::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 12px; background: var(--secondary);
  -webkit-mask: var(--wave) repeat-x left center / auto 12px; mask: var(--wave) repeat-x left center / auto 12px; }
.tabella table { font-variant-numeric: lining-nums tabular-nums; }
.tabella .tb_title { font-family: var(--font); font-size: 135%; letter-spacing: .01em; }
.tabella .tb_subtitle { font-style: italic; }

/* the indice: numbers in terracotta discs, the headings in the serif */
.indice h2.indice-title { font: 400 1rem/1 var(--font); font-variant: small-caps; text-transform: lowercase; letter-spacing: .16em; }
.indice > ol > li::before { box-shadow: inset 0 0 0 2px var(--ink); font-variant-numeric: lining-nums; }

/* notes and cards: plaster panels, their straight top edge in the role's colour */
.nota { background: color-mix(in oklab, var(--surface) 60%, var(--paper)); }
.nota .titolo { font-variant: small-caps; text-transform: lowercase; letter-spacing: .08em; }
.nb-galleria > .nb-scheda { background: color-mix(in oklab, var(--surface) 60%, var(--paper)); }

/* code stays in the monospace, smaller; outputs on plaster */
pre > code, pre.nb-output { font-variant-numeric: normal; }

/* the look switch, in small capitals */
.tema button, .ora button { font-family: var(--font); font-variant: small-caps; text-transform: lowercase; letter-spacing: .1em; font-weight: 700; }

/* the footer: a meander above it, in black glaze */
body > footer { padding-top: 2.4rem; }
body > footer::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 14px; background: var(--ink);
  -webkit-mask: var(--meander) repeat-x left center / auto 14px; mask: var(--meander) repeat-x left center / auto 14px; }
.motto { font-style: italic; }
"""

const minoanCss = scoped(minoanRules, "html[data-tema=\"minoan\"]")

# ------------------------------------------------------------------------------- the night looks
# A page with night looks (`useTabelline(nights = ...)`, devlog "Toward a dark tabelline") has a
# giorno / notte switch: at night Munari becomes Munari notte, the same rules on a night palette,
# and the quaderno, the playful look of the day, becomes the terminal: a retro screen after the
# Matrix and Blade Runner, in a monospace, where every table is shown as text (`toText`).

const
  munariNotte* = Look(paper: "#0F2540",     # 濃藍 koai, deep indigo
                      ink: "#FCFAF2",       # 白練 shironeri, white silk
                      primary: "#E16B8C", secondary: "#7DB9DE", warning: "#F7D94C", success: "#86C166",
                      dark: true)
    ## Munari at night: Haru's four colours (紅梅, 勿忘草, 菜の花, 苗) on deep indigo ("Yoru").
  terminale* = Look(paper: "#0A0F0D",       # dark glass of a monitor
                    ink: "#9CF2B0",         # green phosphor, softened for reading
                    primary: "#FF8A3D",     # sodium orange of Blade Runner's city: the circle, links
                    secondary: "#38D3DB",   # neon cyan: the square, bars
                    warning: "#FFD24A",     # amber: the triangle
                    success: "#3DFF7A",     # code-rain green of the Matrix
                    dark: true)
    ## The terminal, the quaderno's night look.

const terminaleRules = """
html { --font: var(--mono); --hand: var(--mono); }
body { font-size: 16px; }
body::after { content: ""; position: fixed; inset: 0; pointer-events: none; z-index: 50;
  background: repeating-linear-gradient(to bottom, transparent 0 2px, rgba(0,0,0,.2) 2px 3px); }
h1, h2, h3, .etichetta .nome span:last-child { text-transform: uppercase; letter-spacing: .02em;
  text-shadow: 0 0 .4em color-mix(in oklab, var(--ink) 50%, transparent); }
h1 { font-size: 2rem; }
h2 { font-size: 1.45rem; }
h3 { font-size: 1.1rem; }
.lede { font-size: 1.1rem; }
.etichetta .nome span:last-child { font: 700 2.2rem/1 var(--mono); }
.etichetta .nome span:last-child::after { content: "▋"; color: var(--primary); text-shadow: none; }
.forme i { mix-blend-mode: screen; }
.switches:has(.ora) + .forme { top: 6rem; }
.switches:has(.ora) ~ .etichetta { margin-top: 2.4rem; }
a { text-decoration-color: var(--primary); }
pre > code { border: 1px solid var(--line); }
.tabella-html { display: none; }
.in-palette .tabella-html { display: block; }
.in-palette pre.tabella-text { display: none; }
pre.tabella-text { display: block; color: var(--ink); background: var(--surface); border: 1px solid var(--line);
  text-shadow: 0 0 .3em color-mix(in oklab, var(--ink) 35%, transparent); }
"""

const nightCss =
  "/* tables as text: shown only by a look that wants them (the terminal) */\n" &
  ".tabella-text { display: none; }\n" &
  "pre.tabella-text { overflow-x: auto; white-space: pre; font: 12.5px/1.2 var(--mono); padding: .8rem .9rem; margin: 1.4rem 0; }\n" &
  paletteCss(munariNotte, "html[data-tema=\"munari-notte\"]") &
  "html[data-tema=\"munari-notte\"] .forme i { mix-blend-mode: screen; }\n" &
  paletteCss(terminale, "html[data-tema=\"terminale\"]") &
  scoped(terminaleRules, "html[data-tema=\"terminale\"]")

const css* = fonts & tokens & munariCss & quadernoCss & minoanCss & nightCss
  ## All the CSS of a page: Munari, the default, then the quaderno and the Minoan look, scoped.

proc assetHref*(name, pageFile: string): string =
  ## The link from a page (its HTML file) to a file the pages share, `docs/assets/<name>`.
  relativePath(assetsDir / name, absolutePath(pageFile).parentDir).replace('\\', '/')

proc siteCss*(pageFile: string, extra = ""): string =
  ## What a page puts in its head for its style: a link to `docs/assets/site.css` (written when
  ## it changed), relative to the page; with `-d:singleFile`, the CSS itself. `extra` is CSS of
  ## other modules every page has (the review mode's).
  when singleFile:
    "<style>\n" & css & extra & "</style>"
  else:
    let file = assetsDir / "site.css"
    if not fileExists(file) or readFile(file) != css & extra: writeFile(file, css & extra)
    &"""<link rel="stylesheet" href="{assetHref("site.css", pageFile)}">"""

# ----------------------------------------------------------------------------------------- tables

const tokenColours* = ["--paper", "--shade", "--line", "--muted", "--ink", "--surface",
  "--primary", "--primary-soft", "--primary-text", "--secondary", "--secondary-soft", "--secondary-text",
  "--warning", "--warning-soft", "--success", "--success-soft", "--success-text"]
  ## The tokens a page may name in a table colour, as `tint("--secondary")`.

func tint*(token: string): string =
  ## A token as a CSS colour, for tabelline's colour arguments: `style.fill(tint("--secondary"))`.
  doAssert token in tokenColours, "not a token: " & token
  "var(" & token & ")"

func tintMix*(token: string, share: int, other = "--paper"): string =
  ## `share`% of a token in another (the paper by default), for a scale drawn from the palette.
  doAssert token in tokenColours and other in tokenColours
  &"color-mix(in oklab, var({token}) {share}%, var({other}))"

# ----------------------------------------------------------------------------------- review mode


# ------------------------------------------------------------------------- Mediterranean sources
# The colours of the post "Designing a Mediterranean look": for each source of the look, six
# colours in the roles of a look, picked by the rules of the post (devlog/mediterranean.nim, "From
# a source to six colours"): each named after a material of the source, or of the place it shows
# when the source has no such colour (`fromPlace`). Picked by eye, not sampled from a picture.
# They are candidates; the look that wins becomes a `Look` above.

type MediColour* = tuple[hex, name, role: string, fromPlace: bool]

const mediterraneanSources*: seq[(string, array[6, MediColour])] = @[
  ("minoan", [("#EFE6D2", "lime plaster", "paper", false), ("#1E1A17", "black glaze", "ink", false),
              ("#C3693C", "terracotta", "primary", false), ("#3F7FA6", "dolphin blue", "secondary", false),
              ("#D9A441", "yellow ochre", "warning", false), ("#6E8B5A", "olive", "success", true)]),
  ("isolari", [("#F3E9D2", "vellum", "paper", false), ("#3A2E26", "iron-gall ink", "ink", false),
               ("#B8382B", "cinnabar", "primary", false), ("#3D6A9E", "azurite", "secondary", false),
               ("#C9A347", "gold leaf", "warning", false), ("#4F8A6E", "verdigris", "success", false)]),
  ("matisse", [("#FBF8F1", "white paper", "paper", false), ("#1B2238", "night blue", "ink", false),
               ("#2643A6", "ultramarine", "primary", false), ("#D9577A", "Dufy pink", "secondary", false),
               ("#F2C230", "lemon", "warning", false), ("#3E9E6B", "palm green", "success", false)]),
  ("miro", [("#F7F4EC", "whitewashed wall", "paper", false), ("#111111", "black sign", "ink", false),
            ("#D7261E", "red", "primary", false), ("#1D4F9C", "blue", "secondary", false),
            ("#F6C700", "yellow", "warning", false), ("#2E8B57", "green", "success", false)]),
  ("list", [("#F7F6F2", "whitewash", "paper", false), ("#141414", "shadow", "ink", false),
            ("#2C5D8F", "a blue door", "primary", true), ("#B23A73", "bougainvillea", "secondary", true),
            ("#E3B83B", "broom flower", "warning", true), ("#55704A", "caper leaf", "success", true)]),
  ("maiolica", [("#FAF8F2", "tin glaze", "paper", false), ("#1A2340", "manganese blue-black", "ink", false),
                ("#1E4FA1", "cobalt", "primary", false), ("#A0522D", "terracotta", "secondary", false),
                ("#F2B632", "antimony yellow", "warning", false), ("#3C8C5A", "copper green", "success", false)]),
  ("scianna", [("#F2F0EB", "print white", "paper", false), ("#0E0E0E", "silver black", "ink", false),
               ("#9E1B13", "feast red", "primary", false), ("#2F5D9E", "cart blue", "secondary", true),
               ("#E9C33A", "lemon", "warning", true), ("#4E7A3A", "lemon leaf", "success", true)]),
  ("vitali", [("#F8F6F0", "bleached sand", "paper", false), ("#2E3134", "shade", "ink", false),
              ("#23898E", "shallow sea", "primary", false), ("#E04E39", "umbrella red", "secondary", false),
              ("#F3C64B", "umbrella yellow", "warning", false), ("#4F7B4A", "stone pine", "success", true)]),
  ("luzzu", [("#F1EADB", "limestone", "paper", true), ("#1C1F26", "tar", "ink", false),
             ("#1F5AA6", "hull blue", "primary", false), ("#7A2630", "waterline maroon", "secondary", false),
             ("#F2CF2E", "lemon mustaċċ", "warning", false), ("#2E8B4E", "green", "success", false)]),
  ("lionni", [("#FAF7EF", "white page", "paper", false), ("#1C1C1E", "Swimmy black", "ink", false),
              ("#C8352B", "red fish", "primary", false), ("#2F6F9F", "watercolour sea", "secondary", false),
              ("#E8B63A", "sun yellow", "warning", false), ("#4B8B4F", "seaweed green", "success", false)]),
  ("luzzati", [("#F6F0E2", "stage paper", "paper", false), ("#201A1A", "black outline", "ink", false),
               ("#B5266F", "magenta", "primary", false), ("#2A5C9A", "Ligurian blue", "secondary", false),
               ("#E0B030", "gold", "warning", false), ("#3E8E53", "green", "success", false)]),
  ("lai", [("#EFE7D6", "unbleached linen", "paper", false), ("#2A2522", "black thread", "ink", false),
           ("#3F6EA6", "ribbon blue", "primary", false), ("#A8653A", "bread crust", "secondary", false),
           ("#D9A84A", "saffron", "warning", true), ("#5E7F4E", "lentisk", "success", true)]),
  ("casale", [("#F2EBDD", "limestone tessera", "paper", false), ("#22201E", "black tessera", "ink", false),
              ("#A4432C", "red ochre", "primary", false), ("#3E5F7A", "slate-blue glass", "secondary", false),
              ("#D9A441", "yellow ochre", "warning", false), ("#4F7A55", "green serpentine", "success", false)]),
  ("bauer", [("#F7F3E8", "rag paper", "paper", false), ("#2B2620", "iron-gall ink", "ink", false),
             ("#A63A6E", "cyclamen", "primary", false), ("#3B5BA5", "borage blue", "secondary", false),
             ("#E2B443", "rockrose yellow", "warning", false), ("#4E7D3A", "sage leaf", "success", false)]),
  ("procida", [("#F6F2EA", "whitewash", "paper", false), ("#1E2228", "boat tar", "ink", false),
               ("#B4475E", "Corricella pink", "primary", false), ("#2F6F9E", "fishermen's blue", "secondary", false),
               ("#EBC23F", "lemon plaster", "warning", false), ("#3F7F5C", "shutter green", "success", false)]),
  ("mediterraneo", [("#F5F1E8", "whitewashed lane", "paper", false), ("#1F1D1C", "priest's cassock", "ink", false),
                    ("#1E6A9A", "harbour water", "primary", false), ("#A84B32", "red plaster", "secondary", false),
                    ("#D6A23E", "ochre plaster", "warning", false), ("#4E7A3F", "caper bush", "success", true)]),
  ("djerba", [("#F7F5EF", "plaster of a dome", "paper", false), ("#1F2230", "loom black", "ink", false),
              ("#7A2E6A", "murex purple", "primary", false), ("#A65A35", "clay of the pots", "secondary", false),
              ("#D4AE3E", "olive oil", "warning", false), ("#3F7A4A", "date palm", "success", false)]),
  ("ghirri", [("#F6F3EA", "faded print", "paper", false), ("#3B3F45", "soft black", "ink", false),
              ("#8FB3C7", "pale sky", "primary", false), ("#E8B4B0", "faded pink", "secondary", false),
              ("#EAD9A0", "pale yellow", "warning", false), ("#9DBFB0", "sea green", "success", false)]),
]

func sourceColours*(key: string): array[6, MediColour] =
  ## The six colours of a Mediterranean source, in the order of the roles.
  for (k, colours) in mediterraneanSources:
    if k == key: return colours
  doAssert false, "no Mediterranean source: " & key

func sourceSwatches*(key: string): seq[(string, string, string)] =
  ## The six colours of a Mediterranean source, for `nbSwatches`: colour, name, role.
  for c in sourceColours(key):
    result.add (c.hex, c.name, c.role & (if c.fromPlace: ", from the place" else: ""))

# ---------------------------------------------------------------------------------- dark sources
# The colours of the post "Toward a dark tabelline": for each source of a dark look, six colours
# in the roles of a look, on a dark paper. Picked by eye from the source (or, for a design system,
# taken from its published values); `added` marks a role the source has no colour for, filled
# from outside it. Candidates only: none is a look yet.

type DarkColour* = tuple[hex, name, role: string, added: bool]

const darkSources*: seq[(string, array[6, DarkColour])] = @[
  ("yoru", [("#0F2540", "濃藍 koai, deep indigo", "paper", false), ("#FCFAF2", "白練 shironeri, white silk", "ink", false),
            ("#E16B8C", "紅梅 kōbai, red plum", "primary", false), ("#7DB9DE", "勿忘草 wasurenagusa, forget-me-not", "secondary", false),
            ("#F7D94C", "菜の花 nanohana, rapeseed", "warning", false), ("#86C166", "苗 nae, seedling", "success", false)]),
  ("matrix", [("#0D0208", "the screen's black", "paper", false), ("#C9F7CF", "the bright head of a falling string", "ink", false),
              ("#00FF41", "code-rain green", "primary", false), ("#3C6FE0", "the blue pill", "secondary", false),
              ("#E8C547", "amber", "warning", true), ("#2FBF4F", "the trail behind", "success", false)]),
  ("androids", [("#0B1317", "wet night", "paper", false), ("#EFE4D0", "fog under sodium light", "ink", false),
                ("#FF7A2F", "sodium orange", "primary", false), ("#2BC4C9", "neon cyan", "secondary", false),
                ("#F2C14E", "a lit window", "warning", false), ("#6FBF73", "green", "success", true)]),
  ("phosphor", [("#0C0C0C", "dark glass", "paper", false), ("#FFB000", "P3 amber phosphor", "ink", false),
                ("#FF5555", "bright red", "primary", false), ("#55FFFF", "bright cyan", "secondary", false),
                ("#FFFF55", "bright yellow", "warning", false), ("#55FF55", "bright green", "success", false)]),
  ("lcars", [("#000000", "space", "paper", false), ("#FFCC99", "peach", "ink", false),
             ("#FF9900", "orange", "primary", false), ("#9999FF", "periwinkle", "secondary", false),
             ("#FFCC00", "gold", "warning", false), ("#99CC66", "green", "success", true)]),
  ("bloomberg", [("#000000", "black", "paper", false), ("#E8E8E8", "white figures", "ink", false),
                 ("#FB8B1E", "terminal amber", "primary", false), ("#4FA8FF", "header blue", "secondary", false),
                 ("#FFD400", "alert yellow", "warning", false), ("#4CD964", "up green", "success", false)]),
  ("solarized", [("#002B36", "base03", "paper", false), ("#93A1A1", "base1", "ink", false),
                 ("#D33682", "magenta", "primary", false), ("#268BD2", "blue", "secondary", false),
                 ("#B58900", "yellow", "warning", false), ("#859900", "green", "success", false)]),
  ("primer", [("#0D1117", "canvas", "paper", false), ("#E6EDF3", "foreground", "ink", false),
              ("#DB61A2", "sponsors pink", "primary", false), ("#58A6FF", "accent blue", "secondary", false),
              ("#D29922", "attention", "warning", false), ("#3FB950", "success", "success", false)]),
  ("material", [("#121212", "dark surface", "paper", false), ("#E0E0E0", "white at 87%", "ink", false),
                ("#BB86FC", "purple 200", "primary", false), ("#03DAC6", "teal 200", "secondary", false),
                ("#FFD54F", "amber 300", "warning", true), ("#81C784", "green 300", "success", true)]),
]

func darkColours*(key: string): array[6, DarkColour] =
  ## The six colours of a dark source, in the order of the roles.
  for (k, colours) in darkSources:
    if k == key: return colours
  doAssert false, "no dark source: " & key

func darkLook*(key: string): Look =
  ## A dark source as a look, for `nbInPalette`.
  let c = darkColours(key)
  Look(paper: c[0].hex, ink: c[1].hex, primary: c[2].hex, secondary: c[3].hex, warning: c[4].hex,
       success: c[5].hex, dark: true)

func darkSwatches*(key: string): seq[(string, string, string)] =
  ## The six colours of a dark source, for `nbSwatches`: colour, name, role.
  for c in darkColours(key):
    result.add (c.hex, c.name, c.role & (if c.added: ", added" else: ""))
