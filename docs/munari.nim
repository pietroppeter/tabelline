## *Munari*: the second look of tabelline's pages, after Bruno Munari (1907-1998).
##
## Munari is the default look; the quaderno is a switch away, in the header of every page, and the
## choice is remembered (`localStorage`, key `tabelline-tema`); `?tema=munari` or `?tema=quaderno`
## in a link picks one too. Both looks are in every page, so a page is still one standalone file.
##
## What it takes from Munari: the three shapes of his books *La scoperta del quadrato* (1960),
## *del cerchio* (1964) and *del triangolo* (1976), in red, blue and yellow, laid over each other
## as transparent sheets; flat paper with nothing on it that is not needed ("complicare è facile,
## semplificare è difficile"); one geometric sans (Jost, OFL, after the 1920s geometric types);
## notes in flat coloured paper; and a page that a child could take apart. Nothing that only
## decorates may look like something to press or drag (no dots, holes or knobs on cards).
##
## The colours are six variables, named by where they go, not by their hue: `--m-carta` (paper),
## `--m-inchiostro` (ink), `--m-cerchio`, `--m-quadrato` and `--m-triangolo` (the three shapes, and
## what each colours on the page) and `--m-quarto` (a fourth, for the fourth note and the numbers
## in code). Everything else is mixed from them (tints, rules, greys, and darker versions of the
## colours used as text), so a palette is six values. The default is Haru, spring: Japanese
## traditional colours, gentler than Munari's primaries; the devlog post *Munari meets Japan* lists what each colour does
## and lets a reader try the other palettes on the page.
##
## Everything here is scoped by `html[data-tema="munari"]`, which a few lines in the `<head>` set
## before the page is drawn unless the reader picked the quaderno; the quaderno rules are untouched
## (without JavaScript a page shows as a quaderno).

import std/[os, strformat, base64]

const fontDir = currentSourcePath().parentDir / "assets" / "fonts"

func face(file, weight, style: string): string =
  &"@font-face{{font-family:'Jost';src:url(data:font/woff2;base64,{encode(staticRead(fontDir / file))}) format('woff2');" &
    &"font-weight:{weight};font-style:{style};font-display:swap}}\n"

const munariFonts* = face("jost-400-normal.woff2", "400", "normal") &
                     face("jost-400-italic.woff2", "400", "italic") &
                     face("jost-700-normal.woff2", "700", "normal")

const temaHeadScript* = """<script>
(function () {
  try {
    var q = new URLSearchParams(location.search).get('tema');
    if (q === 'munari' || q === 'quaderno') localStorage.setItem('tabelline-tema', q);
    var t = q || localStorage.getItem('tabelline-tema');
    document.documentElement.dataset.tema = (t === 'quaderno') ? 'quaderno' : 'munari';
  } catch (e) { document.documentElement.dataset.tema = 'munari'; }
})();
</script>"""

const temaSwitch* = """<div class="tema" role="group" aria-label="Look of the page">
<button type="button" data-tema="munari" title="after Bruno Munari">Munari</button><button type="button" data-tema="quaderno" title="an Italian school exercise book">quaderno</button>
</div>"""

const forme* = """<div class="forme" aria-hidden="true"><i class="cerchio"></i><i class="quadrato"></i><i class="triangolo"></i></div>"""

const motto* = """<p class="motto">“Complicare è facile, semplificare è difficile.” <span>Bruno Munari</span></p>"""

const temaBodyScript* = """<script>
(function () {
  var root = document.documentElement;
  function show() {
    var t = root.dataset.tema === 'munari' ? 'munari' : 'quaderno';
    document.querySelectorAll('.tema button').forEach(function (b) {
      b.setAttribute('aria-pressed', b.dataset.tema === t ? 'true' : 'false');
    });
  }
  document.querySelectorAll('.tema button').forEach(function (b) {
    b.addEventListener('click', function () {
      root.dataset.tema = b.dataset.tema;
      try { localStorage.setItem('tabelline-tema', b.dataset.tema); } catch (e) {}
      show();
    });
  });
  // one of the three shapes for each section heading, in turn: circle, square, triangle
  document.querySelectorAll('main h2:not(.indice-title)').forEach(function (h, k) {
    h.classList.add('forma-' + (k % 3));
  });
  show();
})();
</script>"""

const munariCss* = """
/* the switch, in both looks */
.tema { display: flex; justify-content: flex-end; gap: 0; margin: .6rem 0 0; }
.tema button { font: 1rem var(--hand); color: var(--pen); background: var(--card); border: 1.5px solid var(--pen);
  padding: .1rem .7rem; cursor: pointer; }
.tema button:first-child { border-radius: 10px 0 0 10px; } .tema button:last-child { border-radius: 0 10px 10px 0; border-left: 0; }
.tema button[aria-pressed="true"] { background: var(--pen); color: #fff; }
.forme, .motto { display: none; }

/* ------------------------------------------------------------------------------- Munari */
html[data-tema="munari"] {
  /* the palette, Haru (spring): Japanese traditional colours (nipponcolors.com) */
  --m-carta: #FCFAF2;      /* 白練 shironeri, white silk */
  --m-inchiostro: #1C1C1C; /* 墨 sumi, ink */
  --m-cerchio: #E16B8C;    /* 紅梅 kōbai, red plum blossom */
  --m-quadrato: #7DB9DE;   /* 勿忘草 wasurenagusa, forget-me-not */
  --m-triangolo: #F7D94C;  /* 菜の花 nanohana, rapeseed flower */
  --m-quarto: #86C166;     /* 苗 nae, seedling */
  /* the colours as text: a little ink in them, so that light ones stay readable */
  --m-cerchio-testo: color-mix(in oklab, var(--m-cerchio) 75%, var(--m-inchiostro));
  --m-quadrato-testo: color-mix(in oklab, var(--m-quadrato) 60%, var(--m-inchiostro));
  --m-quarto-testo: color-mix(in oklab, var(--m-quarto) 62%, var(--m-inchiostro));
  --paper: var(--m-carta);
  --pencil: var(--m-inchiostro);
  --pen: var(--m-inchiostro);
  --pen-red: var(--m-cerchio-testo);
  --blu: var(--m-quadrato);
  --giallo: var(--m-triangolo);
  --muted: color-mix(in srgb, var(--m-inchiostro) 62%, var(--m-carta));
  --card: color-mix(in srgb, #FFFFFF 60%, var(--m-carta));
  --postit: color-mix(in srgb, var(--m-triangolo) 38%, var(--m-carta));
  --highlight: color-mix(in srgb, var(--m-triangolo) 55%, transparent);
  --rule: color-mix(in srgb, var(--m-inchiostro) 12%, var(--m-carta));
  --hand: "Jost", "Futura", "Century Gothic", system-ui, sans-serif;
  --text: "Jost", "Futura", "Century Gothic", system-ui, sans-serif;
  --carta: color-mix(in srgb, var(--m-inchiostro) 6%, var(--m-carta));
}
html[data-tema="munari"] body { background: var(--paper); font: 18px/1.6 var(--text); }
html[data-tema="munari"] main { border-left: 0; padding-left: 0; }
html[data-tema="munari"] header { padding-top: .4rem; }

/* the cover: the three shapes over each other, like sheets of coloured acetate */
html[data-tema="munari"] .forme { display: block; position: absolute; top: 6.3rem; right: 0; width: 9.5rem; height: 8.5rem; pointer-events: none; }
html[data-tema="munari"] .forme i { position: absolute; display: block; mix-blend-mode: multiply; }
html[data-tema="munari"] .forme .cerchio { width: 6.2rem; height: 6.2rem; border-radius: 50%; background: var(--m-cerchio); right: 0; top: 0; }
html[data-tema="munari"] .forme .quadrato { width: 4.6rem; height: 4.6rem; background: var(--blu); right: 3.6rem; top: 2.6rem; }
html[data-tema="munari"] .forme .triangolo { width: 5.6rem; height: 4.9rem; background: var(--giallo); right: 1.2rem; top: 3.6rem;
  clip-path: polygon(50% 0, 100% 100%, 0 100%); }
html[data-tema="munari"] .etichetta { margin: 2.4rem 0 1.4rem; max-width: none; background: none; border: 0; border-radius: 0;
  box-shadow: none; padding: 0 10.5rem 0 0; min-height: 8.5rem; }
html[data-tema="munari"] .etichetta::before { display: none; }
html[data-tema="munari"] .etichetta .riga { display: block; border: 0; padding: 0; }
html[data-tema="munari"] .etichetta .riga span:first-child { display: none; }
html[data-tema="munari"] .etichetta .riga span:last-child { font: 400 1.25rem/1.3 var(--text); color: var(--pencil); }
html[data-tema="munari"] .etichetta .nome span:last-child { font: 700 3.4rem/1 var(--text); letter-spacing: -.03em; }
html[data-tema="munari"] .etichetta .riga:last-child span:last-child { font-size: .8rem; letter-spacing: .18em; text-transform: uppercase; color: var(--muted); }
@media (max-width: 560px) {
  html[data-tema="munari"] .forme { transform: scale(.62); transform-origin: top right; top: 6rem; }
  html[data-tema="munari"] .etichetta { padding-right: 6.4rem; min-height: 6rem; }
  html[data-tema="munari"] .etichetta .nome span:last-child { font-size: 2.5rem; }
}
html[data-tema="munari"] .crumbs { font: 700 .74rem/1 var(--text); letter-spacing: .16em; text-transform: uppercase; padding-top: 1rem; }
html[data-tema="munari"] .crumbs a { color: var(--pencil); text-decoration: none; }
html[data-tema="munari"] .tema button { font: 700 .72rem/1.6 var(--text); letter-spacing: .14em; text-transform: uppercase;
  border: 2px solid var(--pencil); border-radius: 0; background: transparent; color: var(--pencil); padding: .2rem .7rem; }
html[data-tema="munari"] .tema button:last-child { border-left: 0; }
html[data-tema="munari"] .tema button[aria-pressed="true"] { background: var(--pencil); color: var(--paper); }

/* type: one sans, big and plain */
html[data-tema="munari"] h1, html[data-tema="munari"] h2, html[data-tema="munari"] h3, html[data-tema="munari"] h4 {
  font-family: var(--text); font-weight: 700; color: var(--pencil); letter-spacing: -.015em; }
html[data-tema="munari"] h1 { font-size: 2.9rem; line-height: 1.05; }
html[data-tema="munari"] h2 { font-size: 1.85rem; display: block; background: none; padding: 0 0 0 2.4rem; margin: 3rem 0 .9rem; position: relative; }
html[data-tema="munari"] h2::before { content: ""; position: absolute; left: 0; top: .2em; width: 1.5rem; height: 1.5rem;
  background: var(--m-cerchio); border-radius: 50%; }
html[data-tema="munari"] h2.forma-1::before { background: var(--blu); border-radius: 0; }
html[data-tema="munari"] h2.forma-2::before { background: var(--giallo); border-radius: 0; clip-path: polygon(50% 0, 100% 100%, 0 100%); }
html[data-tema="munari"] h3 { font-size: 1.25rem; color: var(--pen-red); margin-top: 2rem; }
html[data-tema="munari"] h2 .num { color: var(--muted); }
html[data-tema="munari"] .kicker { font: 700 .74rem/1 var(--text); letter-spacing: .2em; color: var(--pen-red); }
html[data-tema="munari"] .lede { font-size: 1.3rem; line-height: 1.45; }
html[data-tema="munari"] a { color: var(--pencil); text-decoration-color: var(--pen-red); text-decoration-thickness: 2px; }
html[data-tema="munari"] a:hover { background: var(--giallo); }
html[data-tema="munari"] blockquote { transform: none; box-shadow: none; border-radius: 0; background: none; border-left: 6px solid var(--giallo); }
html[data-tema="munari"] hr { border-top: 2px solid var(--pencil); }

/* code: a white sheet with a black edge; outputs on grey paper */
html[data-tema="munari"] pre > code { border: 2px solid var(--pencil); border-radius: 0; box-shadow: none; }
html[data-tema="munari"] pre.nb-output { background: var(--carta); border-radius: 0; box-shadow: none; color: var(--pencil); }
html[data-tema="munari"] pre.nb-output::before { font: 700 .66rem/1.4 var(--text); letter-spacing: .2em; text-transform: uppercase; color: var(--pen-red); }
html[data-tema="munari"] :not(pre) > code { background: var(--carta); border-radius: 0; }
/* code colours: keywords after the circle, strings after the square, numbers after the fourth */
html[data-tema="munari"] .hljs-keyword { color: var(--m-cerchio-testo); font-weight: 700; }
html[data-tema="munari"] .hljs-string { color: var(--m-quadrato-testo); }
html[data-tema="munari"] .hljs-number, html[data-tema="munari"] .hljs-literal { color: var(--m-quarto-testo); }
html[data-tema="munari"] .hljs-type { color: var(--pencil); font-weight: 700; }
html[data-tema="munari"] .hljs-built_in { color: var(--m-cerchio-testo); }
html[data-tema="munari"] .hljs-comment { color: var(--muted); font-style: italic; }
html[data-tema="munari"] .hljs-meta { color: var(--muted); }

/* tables: no tape, no squares; a black rule top and bottom, the top one starting in red */
html[data-tema="munari"] .tabella { box-shadow: none; border-radius: 0; padding: 16px 0 10px; background: transparent; }
html[data-tema="munari"] .tabella::before { width: 3rem; height: 3px; border-radius: 0; background: var(--m-cerchio);
  top: 16px; left: 0; margin: 0; transform: none; box-shadow: none; z-index: 1; }
html[data-tema="munari"] .tabella .tb_table { background-image: none !important; background-color: var(--card) !important;
  font-family: var(--text) !important; color: var(--pencil) !important;
  border-top: 3px solid var(--pencil) !important; border-bottom: 3px solid var(--pencil) !important; }
html[data-tema="munari"] .tabella .tb_title { font-family: var(--text) !important; font-weight: 700 !important; color: var(--pencil) !important; letter-spacing: -.01em; }
html[data-tema="munari"] .tabella .tb_heading_last { border-bottom-color: var(--m-cerchio) !important; }
html[data-tema="munari"] .tabella .tb_col_heading, html[data-tema="munari"] .tabella .tb_spanner { color: var(--pencil) !important; }
html[data-tema="munari"] .tabella .tb_col_headings_last th, html[data-tema="munari"] .tabella .tb_spanner { border-bottom-color: var(--pencil) !important; }
html[data-tema="munari"] .tabella .tb_row { border-top-color: var(--rule) !important; }
html[data-tema="munari"] .tabella .tb_stub { border-right-color: var(--rule) !important; }
html[data-tema="munari"] .tabella .tb_group_heading { border-color: var(--pencil) !important;
  background-color: color-mix(in srgb, var(--m-triangolo) 22%, var(--m-carta)) !important; }
html[data-tema="munari"] main table:not(.tb_table) th, html[data-tema="munari"] main table:not(.tb_table) td { border-color: var(--rule); }

/* the indice: numbers on coloured shapes */
html[data-tema="munari"] .indice { background: none; box-shadow: none; transform: none; border-radius: 0; padding: 1rem 0;
  border-top: 3px solid var(--pencil); border-bottom: 3px solid var(--pencil); max-width: 36rem; }
html[data-tema="munari"] .indice h2.indice-title { font: 700 .78rem/1 var(--text); letter-spacing: .2em; text-transform: uppercase;
  color: var(--pencil); padding: 0; margin: 0 0 .9rem; }
html[data-tema="munari"] .indice h2.indice-title::before { display: none; }
html[data-tema="munari"] .indice > ol { list-style: none; padding: 0; counter-reset: voce; font: 500 1.08rem/1.5 var(--text); }
html[data-tema="munari"] .indice > ol > li { counter-increment: voce; position: relative; padding-left: 2.3rem; margin: .35rem 0; }
html[data-tema="munari"] .indice > ol > li::before { content: counter(voce); position: absolute; left: 0; top: .1rem; width: 1.5rem; height: 1.5rem;
  border-radius: 50%; background: var(--m-cerchio); color: #fff; font: 700 .78rem/1.5rem var(--text); text-align: center; }
html[data-tema="munari"] .indice > ol > li:nth-child(3n+2)::before { background: var(--blu); border-radius: 0; }
html[data-tema="munari"] .indice > ol > li:nth-child(3n)::before { background: var(--giallo); color: var(--pencil); border-radius: 0;
  width: 1.7rem; left: -.1rem; top: -.05rem; height: 1.6rem; line-height: 2.05rem; font-size: .7rem; clip-path: polygon(50% 0, 100% 100%, 0 100%); }
html[data-tema="munari"] .indice ol ol { font: 400 .95rem/1.45 var(--text); padding-left: 0; margin: .15rem 0 .3rem; }
html[data-tema="munari"] .indice ol ol li::before { content: "— "; color: var(--muted); }
html[data-tema="munari"] .indice a { color: var(--pencil); }

/* notes: flat coloured paper, its colour in full along the top edge; nothing on it to press */
html[data-tema="munari"] .nota { border-radius: 0; box-shadow: none; transform: none; padding: 1rem 1.2rem;
  border-top: 5px solid var(--m-triangolo); }
html[data-tema="munari"] .nota.verde { background: color-mix(in srgb, var(--m-quarto) 26%, var(--m-carta)); border-top-color: var(--m-quarto); }
html[data-tema="munari"] .nota.rosa { background: color-mix(in srgb, var(--m-cerchio) 20%, var(--m-carta)); border-top-color: var(--m-cerchio); }
html[data-tema="munari"] .nota.azzurra { background: color-mix(in srgb, var(--m-quadrato) 20%, var(--m-carta)); border-top-color: var(--m-quadrato); }
html[data-tema="munari"] .nota .titolo { font: 700 1.1rem var(--text); color: var(--pencil); }
html[data-tema="munari"] .timbro { font: 700 .8rem/1.6 var(--text); letter-spacing: .12em; text-transform: uppercase; border-radius: 0; transform: none; }
html[data-tema="munari"] .voto { font: 700 1.2rem/2.5rem var(--text); transform: none; }

/* footer, with Munari's motto */
html[data-tema="munari"] footer { font: 400 .9rem/1.5 var(--text); color: var(--muted); border-top: 2px solid var(--pencil); margin-top: 2rem; }
html[data-tema="munari"] footer a { color: var(--pencil); }
html[data-tema="munari"] .motto { display: block; font: 700 1.35rem/1.3 var(--text); color: var(--pencil); margin: .2rem 0 1rem; }
html[data-tema="munari"] .motto span { display: block; font: 400 .74rem/2 var(--text); letter-spacing: .2em; text-transform: uppercase; color: var(--pen-red); }
"""
