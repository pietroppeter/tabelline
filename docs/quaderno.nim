## *Quaderno*: the look of tabelline's pages, an Italian school exercise book.
##
## Squared paper (*quaderno a quadretti*, 5 mm squares) with a red margin rule, the label on the
## cover (*nome*, *materia*, *classe*), headings in blue pen with a highlighter stroke, code on
## index cards, outputs on sticky notes, tables pasted in with a strip of tape, and an *indice*
## (table of contents) built when the page is.
##
## Nothing loads from elsewhere: the fonts (Patrick Hand for the handwriting, Atkinson
## Hyperlegible for the text, both OFL) are inlined from `docs/assets/fonts`, and Nim code is
## highlighted at build time by nimib. So a page is one standalone HTML file.
##
## A second look, *Munari* (`docs/munari.nim`), is the default since 0.1; the quaderno is one click
## away in the header of every page, and the reader's choice is remembered.
##
## Usage, right after `nbInit`:
##   nb.useQuaderno(nome = "tabelline", materia = "...", classe = "...", lede = "...")
##   nbIndice          # the table of contents of the `##` and `###` headings, where you put it

import std/[json, os, strutils, strformat, base64, sequtils]
import nimib
import munari
export munari

const
  repoUrl* = "https://github.com/pietroppeter/tabelline"
  siteUrl* = "https://pietroppeter.github.io/tabelline/"
  fontDir = currentSourcePath().parentDir / "assets" / "fonts"

func fontFace(family, file, weight, style: string, data: string): string =
  &"@font-face{{font-family:'{family}';src:url(data:font/woff2;base64,{data}) format('woff2');" &
    &"font-weight:{weight};font-style:{style};font-display:swap}}\n"

const fonts = fontFace("Patrick Hand", "patrick-hand", "400", "normal",
                       encode(staticRead(fontDir / "patrick-hand.woff2"))) &
              fontFace("Atkinson Hyperlegible", "atkinson-regular", "400", "normal",
                       encode(staticRead(fontDir / "atkinson-regular.woff2"))) &
              fontFace("Atkinson Hyperlegible", "atkinson-bold", "700", "normal",
                       encode(staticRead(fontDir / "atkinson-bold.woff2"))) &
              fontFace("Atkinson Hyperlegible", "atkinson-italic", "400", "italic",
                       encode(staticRead(fontDir / "atkinson-italic.woff2")))

const tabsScript = """<script>
(function () {
  function choose(lang) {
    document.querySelectorAll('.lingue').forEach(function (box) {
      if (!box.querySelector('[data-lingua="' + lang + '"]')) return;
      box.querySelectorAll('.lingue-tab button').forEach(function (b) { b.setAttribute('aria-selected', b.dataset.lingua === lang ? 'true' : 'false'); });
      box.querySelectorAll('.lingue-pannello').forEach(function (p) { p.hidden = p.dataset.lingua !== lang; });
    });
  }
  document.querySelectorAll('.lingue-tab button').forEach(function (b) {
    b.addEventListener('click', function () { choose(b.dataset.lingua); });
  });
})();
</script>"""

const quadernoCss* = """
:root {
  --paper: #FDFDF9;
  --grid: #D9E7F5;          /* the squares */
  --margin: #E9585B;        /* the red margin rule */
  --pencil: #2B2D38;        /* text */
  --pen: #1F4E99;           /* blue pen: headings, links */
  --pen-red: #C62828;       /* red pen: corrections, accents */
  --muted: #5E6475;
  --card: #FFFFFF;
  --postit: #FFF6B8;        /* sticky notes */
  --highlight: rgba(255, 230, 90, .55);
  --hl-green: rgba(140, 230, 150, .5);
  --hl-pink: rgba(255, 170, 200, .5);
  --tape: rgba(255, 214, 165, .75);
  --hand: "Patrick Hand", "Segoe Print", "Comic Sans MS", cursive;
  --text: "Atkinson Hyperlegible", system-ui, -apple-system, "Segoe UI", sans-serif;
  --mono: ui-monospace, "SF Mono", Menlo, Consolas, "DejaVu Sans Mono", monospace;
  --sq: 20px;               /* one square, about 5 mm */
}
* { box-sizing: border-box; }
[hidden] { display: none !important; }
html { -webkit-text-size-adjust: 100%; }
body {
  margin: 0; color: var(--pencil); font: 17px/1.6 var(--text);
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
.etichetta { margin: 2.2rem auto 1.6rem; max-width: 30rem; background: var(--card);
  border: 2px solid var(--pen); border-radius: 18px; padding: 1rem 1.4rem 1.1rem;
  box-shadow: 4px 5px 0 rgba(31, 78, 153, .15); position: relative; }
.etichetta::before { content: ""; position: absolute; inset: 6px; border: 1px solid #9DB8E0; border-radius: 13px; pointer-events: none; }
.etichetta .riga { display: flex; gap: .6rem; align-items: baseline; border-bottom: 1.5px dotted #9DB8E0; padding: .15rem 0; }
.etichetta .riga span:first-child { font: 600 .72rem/1 var(--text); letter-spacing: .12em; text-transform: uppercase; color: var(--muted); min-width: 5.2rem; }
.etichetta .riga span:last-child { font: 1.55rem/1.25 var(--hand); color: var(--pen); }
.etichetta .nome span:last-child { font-size: 2.3rem; }
.etichetta .nome a { color: inherit; text-decoration: none; }
.crumbs { display: flex; justify-content: space-between; gap: 1rem; flex-wrap: wrap; font: 1.05rem var(--hand); padding-top: .8rem; }
.crumbs a { color: var(--pen); }
.lede { font-size: 1.15rem; color: var(--pencil); margin: 0 0 1.2rem; }
.kicker { font: 600 .74rem/1 var(--text); letter-spacing: .14em; text-transform: uppercase; color: var(--pen-red); margin: 0; }

/* headings in blue pen, with a highlighter stroke */
h1, h2, h3, h4 { font-family: var(--hand); font-weight: 400; color: var(--pen); line-height: 1.15; }
h1 { font-size: 2.6rem; margin: 1.5rem 0 .4rem; }
h2 { font-size: 2.05rem; margin: 2.6rem 0 .8rem; display: inline-block;
  background: linear-gradient(transparent 55%, var(--highlight) 55%, var(--highlight) 92%, transparent 92%);
  padding: 0 .3rem; margin-left: -.3rem; scroll-margin-top: 1rem; }
h3 { font-size: 1.55rem; margin: 1.8rem 0 .5rem; color: var(--pen-red); scroll-margin-top: 1rem; }
h2 .num { color: var(--pen-red); margin-right: .35rem; }
a { color: var(--pen); text-decoration-thickness: 1.5px; text-underline-offset: 2px; }
strong { font-weight: 700; }
p, li { max-width: 46rem; }
blockquote { margin: 1.2rem 0; padding: .7rem 1rem; background: var(--postit); border-radius: 2px 2px 14px 2px;
  box-shadow: 2px 3px 6px rgba(0,0,0,.08); transform: rotate(-.4deg); }
blockquote p { margin: .3rem 0; }
hr { border: 0; border-top: 2px dashed #9DB8E0; margin: 2rem 0; }
mark { background: var(--highlight); padding: 0 .15em; }
img { max-width: 100%; }

/* code on index cards, outputs on sticky notes */
pre { margin: 1rem 0; }
pre > code, pre.nb-output { display: block; overflow-x: auto; font: 13.5px/1.55 var(--mono); padding: .8rem 1rem;
  border-radius: 6px; }
pre > code { background: var(--card); border: 1px solid #C9D9EC; border-left: 5px solid var(--pen);
  box-shadow: 2px 3px 0 rgba(31, 78, 153, .08); }
pre.nb-output { background: var(--postit); border: 0; box-shadow: 2px 3px 6px rgba(0,0,0,.07); white-space: pre; color: #3D3A2A; }
pre.nb-output::before { content: "output"; display: block; font: .95rem var(--hand); color: #A08A2A; margin-bottom: .1rem; }
:not(pre) > code { font: .88em var(--mono); background: rgba(31, 78, 153, .07); padding: .05em .3em; border-radius: 4px; }
.hljs-keyword { color: #8E2C8F; font-weight: 600; } .hljs-string { color: #1C7A4E; } .hljs-number { color: #B5520D; }
.hljs-comment { color: #7A8394; font-style: italic; } .hljs-type { color: #1F4E99; } .hljs-built_in { color: #A3361F; }
.hljs-literal { color: #B5520D; } .hljs-meta { color: #6B5BA8; }

/* tables pasted in, with a strip of tape */
.tabella { position: relative; margin: 1.6rem 0 1.8rem; padding: 18px 14px 12px; background: var(--card);
  box-shadow: 0 1px 2px rgba(0,0,0,.08), 3px 5px 14px rgba(0,0,0,.07); border-radius: 2px; }
.tabella::before { content: ""; position: absolute; top: -11px; left: 50%; width: 110px; height: 24px;
  margin-left: -55px; background: var(--tape); transform: rotate(-2deg); box-shadow: 0 1px 2px rgba(0,0,0,.08); }
main table:not(.tb_table) { border-collapse: collapse; margin: 1rem 0; background: var(--card); }
main table:not(.tb_table) th, main table:not(.tb_table) td { border: 1px solid #C9D9EC; padding: .35rem .6rem; text-align: left; vertical-align: top; }

/* the indice: a sticky note with the headings */
.indice { background: var(--postit); padding: 1rem 1.3rem 1.1rem; margin: 1.4rem 0 2rem; max-width: 34rem;
  box-shadow: 2px 4px 10px rgba(0,0,0,.1); transform: rotate(.5deg); border-radius: 2px 2px 18px 2px; }
.indice h2.indice-title { font-size: 1.7rem; background: none; margin: 0 0 .4rem; padding: 0; display: block; color: var(--pen-red); }
.indice ol { margin: 0; padding-left: 1.5rem; font: 1.2rem/1.45 var(--hand); }
.indice ol ol { font-size: 1.05rem; padding-left: 1.1rem; list-style: none; }
.indice ol ol li::before { content: "– "; color: var(--muted); }
.indice a { text-decoration: none; color: var(--pen); }
.indice a:hover { text-decoration: underline; }

/* sticky notes and stamps */
.nota { background: var(--postit); padding: .8rem 1.1rem; margin: 1.3rem 0; border-radius: 2px 2px 14px 2px;
  box-shadow: 2px 3px 8px rgba(0,0,0,.09); transform: rotate(-.3deg); }
.nota.verde { background: #DDF7DA; } .nota.rosa { background: #FDE0EA; } .nota.azzurra { background: #DDEEFF; }
.nota > :first-child { margin-top: 0; } .nota > :last-child { margin-bottom: 0; }
.nota .titolo { font: 1.3rem var(--hand); color: var(--pen-red); display: block; }
.timbro { display: inline-block; font: 1.05rem var(--hand); color: var(--pen-red); border: 2px solid var(--pen-red);
  border-radius: 8px; padding: 0 .5rem; transform: rotate(-4deg); }
.voto { display: inline-block; font: 1.6rem/1 var(--hand); color: var(--pen-red); border: 2px solid var(--pen-red);
  border-radius: 50%; width: 2.6rem; height: 2.6rem; text-align: center; line-height: 2.5rem; transform: rotate(-8deg); }
.cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(14rem, 1fr)); gap: 1rem; margin: 1.2rem 0; }
.cards .nota { margin: 0; }
/* tabs: the same example in Nim, Python and R; the choice holds for the whole page */
.lingue { margin: 1.2rem 0; }
.lingue-tab { display: flex; gap: 0; flex-wrap: wrap; }
.lingue-tab button { font: 1rem var(--hand); color: var(--pen); background: var(--card); border: 1.5px solid var(--pen);
  border-bottom: 0; padding: .15rem .8rem; cursor: pointer; margin-right: -1.5px; }
.lingue-tab button[aria-selected="true"] { background: var(--pen); color: #fff; }
.lingue-pannello { border-top: 1.5px solid var(--pen); padding-top: .2rem; }
.lingue-pannello > pre:first-child { margin-top: .6rem; }
html[data-tema="munari"] .lingue-tab button { font: 700 .72rem/1.6 var(--text); letter-spacing: .1em; text-transform: uppercase;
  border: 2px solid var(--pencil); border-bottom: 0; border-radius: 0; background: transparent; color: var(--pencil); margin-right: -2px; }
html[data-tema="munari"] .lingue-tab button[aria-selected="true"] { background: var(--pencil); color: var(--paper); }
html[data-tema="munari"] .lingue-pannello { border-top: 2px solid var(--pencil); }
footer { font: 1.05rem var(--hand); color: var(--muted); padding: 1rem 0 3rem; text-align: center; }
footer a { color: var(--pen); }
details.source { margin-top: 1rem; text-align: left; }
details.source summary { cursor: pointer; }
details.source pre { max-height: 32rem; overflow: auto; }
/* the code of a table, folded under it */
details.codice { margin: -1rem 0 1.6rem; }
details.codice > summary { list-style: none; cursor: pointer; display: inline-block; font: 1rem var(--hand); color: var(--pen); }
details.codice > summary::-webkit-details-marker { display: none; }
details.codice > summary::before { content: "+ show code"; }
details.codice[open] > summary::before { content: "− hide code"; }
details.codice pre { margin: .4rem 0 0; }
body details.codice pre > code { font-size: 12.5px; }
html[data-tema="munari"] details.codice { margin-top: -.8rem; }
html[data-tema="munari"] details.codice > summary { font: 700 .68rem/1.6 var(--text); letter-spacing: .12em;
  text-transform: uppercase; color: var(--pencil); border-bottom: 2px solid var(--m-quadrato); }
"""

# ----------------------------------------------------------------------------- headings and TOC

func slugify*(s: string): string =
  ## The anchor of a heading: lowercase words joined by `-`.
  var last = '-'
  for c in s.toLowerAscii:
    if c in {'a'..'z', '0'..'9'}:
      result.add c
      last = c
    elif last != '-':
      result.add '-'
      last = '-'
  result = result.strip(chars = {'-'})

func stripInline(s: string): string =
  ## Heading text without Markdown marks or tags, for anchors and the indice.
  var inTag = false
  for c in s:
    if c == '<': inTag = true
    elif c == '>': inTag = false
    elif not inTag and c notin {'*', '`', '_'}: result.add c

func headingsOf*(markdownText: string): seq[(int, string)] =
  ## The `##` and `###` headings of a Markdown text, with their level (outside code fences).
  var fence = false
  for line in markdownText.splitLines:
    if line.strip.startsWith("```"): fence = not fence
    if fence: continue
    if line.startsWith("## "): result.add (2, line[3 .. ^1].strip.stripInline)
    elif line.startsWith("### "): result.add (3, line[4 .. ^1].strip.stripInline)

func addHeadingIds(html: string): string =
  ## `<h2>Text</h2>` becomes `<h2 id="text">Text</h2>`, matching `slugify` of the indice.
  result = html
  for tag in ["h2", "h3"]:
    var res = ""
    var i = 0
    let open = "<" & tag & ">"
    let close = "</" & tag & ">"
    while true:
      let a = result.find(open, i)
      if a < 0: break
      let b = result.find(close, a)
      if b < 0: break
      let inner = result[a + open.len ..< b]
      res.add result[i ..< a] & "<" & tag & " id=\"" & slugify(stripInline(inner).replace("&amp;", "&")) & "\">" & inner & close
      i = b + close.len
    res.add result[i .. ^1]
    result = res

func unescapeHtml(s: string): string =
  s.multiReplace(("&lt;", "<"), ("&gt;", ">"), ("&quot;", "\""), ("&#39;", "'"), ("&amp;", "&"))

func highlightNimFences(html: string): string =
  ## ```nim fences in Markdown, highlighted like the code that ran.
  const openTag = """<pre><code class="language-nim">"""
  const close = "</code></pre>"
  var i = 0
  while true:
    let a = html.find(openTag, i)
    if a < 0: break
    let b = html.find(close, a + openTag.len)
    if b < 0: break
    result.add html[i ..< a]
    result.add """<pre><code class="nohighlight nim">""" &
      highlightNim(unescapeHtml(html[a + openTag.len ..< b]).strip(leading = false, chars = {'\n'})) & close
    i = b + close.len
  result.add html[i .. ^1]


const
  pythonKeywords = ["and", "as", "assert", "break", "class", "continue", "def", "del", "elif", "else",
    "except", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "not", "or",
    "pass", "raise", "return", "try", "while", "with", "yield"]
  rKeywords = ["if", "else", "for", "while", "repeat", "function", "return", "next", "break", "in",
    "library", "require"]
  otherLiterals = ["True", "False", "None", "TRUE", "FALSE", "NULL", "NA", "Inf", "NaN"]

func highlightOther*(code, lang: string): string =
  ## A small highlighter for the R and Python code that pages show but do not run: keywords,
  ## strings, numbers, comments and function calls, with the same classes as the Nim code.
  let keywords = if lang == "r": @rKeywords else: @pythonKeywords
  func esc(s: string): string = s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"))
  func span(cls, s: string): string = "<span class=\"hljs-" & cls & "\">" & esc(s) & "</span>"
  var i = 0
  while i < code.len:
    let c = code[i]
    if c == '#':
      var j = i
      while j < code.len and code[j] != '\n': inc j
      result.add span("comment", code[i ..< j]); i = j
    elif c in {'"', '\''}:
      var j = i + 1
      while j < code.len and code[j] != c and code[j] != '\n':
        if code[j] == '\\': inc j
        inc j
      j = min(j + 1, code.len)
      result.add span("string", code[i ..< j]); i = j
    elif c in {'0'..'9'} and (i == 0 or code[i - 1] notin {'a'..'z', 'A'..'Z', '_', '.'}):
      var j = i
      while j < code.len and code[j] in {'0'..'9', '.', '_', 'e', 'E', 'x', 'L'}: inc j
      result.add span("number", code[i ..< j]); i = j
    elif c in {'a'..'z', 'A'..'Z', '_', '.'}:
      var j = i
      while j < code.len and code[j] in {'a'..'z', 'A'..'Z', '0'..'9', '_', '.'}: inc j
      let w = code[i ..< j]
      if w in keywords: result.add span("keyword", w)
      elif w in otherLiterals: result.add span("literal", w)
      elif j < code.len and code[j] == '(' and w.strip(chars = {'.'}).len > 0:
        let lead = w.len - w.strip(leading = true, trailing = false, chars = {'.'}).len
        result.add esc(w[0 ..< lead]) & span("built_in", w[lead .. ^1])
      else: result.add esc(w)
      i = j
    elif c == '|' and i + 1 < code.len and code[i + 1] == '>':
      result.add span("meta", "|>"); i += 2
    else:
      result.add esc($c); inc i

func highlightOtherFences(html: string): string =
  ## ```r and ```python fences in Markdown, highlighted with `highlightOther`.
  result = html
  for lang in ["r", "python"]:
    let openTag = "<pre><code class=\"language-" & lang & "\">"
    const close = "</code></pre>"
    var res = ""
    var i = 0
    while true:
      let a = result.find(openTag, i)
      if a < 0: break
      let b = result.find(close, a + openTag.len)
      if b < 0: break
      res.add result[i ..< a]
      res.add "<pre><code class=\"nohighlight " & lang & "\">" &
        highlightOther(unescapeHtml(result[a + openTag.len ..< b]).strip(leading = false, chars = {'\n'}), lang) & close
      i = b + close.len
    res.add result[i .. ^1]
    result = res

newNbBlock(NbIndice):
  title: string
  toHtml:
    var items = ""
    var openSub = false
    for b in nb.doc.blocksFlattened:
      if not (b of NbText): continue
      for (level, text) in headingsOf(b.NbText.text):
        let link = &"""<a href="#{slugify(text)}">{text}</a>"""
        if level == 2:
          if openSub: (items.add "</ol>"; openSub = false)
          if items.len > 0: items.add "</li>"
          items.add "<li>" & link
        else:
          if not openSub: (items.add "<ol>"; openSub = true)
          items.add "<li>" & link & "</li>"
    if openSub: items.add "</ol>"
    if items.len > 0: items.add "</li>"
    &"""<nav class="indice" aria-label="{blk.title}"><h2 class="indice-title">{blk.title}</h2><ol>{items}</ol></nav>"""

proc indice*(nb: var Nb, title = "Indice") =
  nb.add newNbIndice(title = title)

template nbIndice*(ttitle = "Indice") =
  ## The table of contents of the page's `##` and `###` headings, built when the page is saved.
  nb.indice(ttitle)

const lingue* = [("nim", "👑 Nim"), ("python", "🐍 Python"), ("r", "🏴‍☠️ R")]

func tabsHtml*(panels: openArray[string]): string =
  ## Tabs over `panels` (HTML), in the order of `lingue`; an empty panel has no tab.
  result = """<div class="lingue"><div class="lingue-tab" role="tablist">"""
  var first = true
  for i, (key, label) in lingue:
    if panels[i].len == 0: continue
    result.add &"""<button type="button" role="tab" data-lingua="{key}" aria-selected="{first}">{label}</button>"""
    first = false
  result.add "</div>"
  first = true
  for i, (key, label) in lingue:
    if panels[i].len == 0: continue
    result.add &"""<div class="lingue-pannello" role="tabpanel" data-lingua="{key}"{(if first: "" else: " hidden")}>{panels[i]}</div>"""
    first = false
  result.add "</div>"

func codeHtml*(code, lang: string): string =
  ## Code that is shown, not run (Python and R examples).
  "<pre><code class=\"nohighlight " & lang & "\">" & highlightOther(code.strip(chars = {'\n'}), lang) & "</code></pre>"

template nbTabs*(python, r: string, body: untyped) =
  ## The Nim blocks `body` adds (code that runs, and its output), in a 👑 Nim tab next to the
  ## same example in 🐍 Python (Great Tables) and 🏴‍☠️ R (gt), shown and not run.
  let first = nb.blocks.len
  body
  var nimSide = ""
  for i in first ..< nb.blocks.len:
    nimSide.add nb.render(nb.blocks[i])
  nb.blocks.setLen(first)
  nbRawHtml: tabsHtml([nimSide, (if python.len > 0: codeHtml(python, "python") else: ""),
                       (if r.len > 0: codeHtml(r, "r") else: "")])

template nbShowCode*(body: untyped) =
  ## Runs `body` and shows the blocks it adds (its tables), with `body`'s own code folded below
  ## them: "show code" opens it. For pages that show off the code behind each table.
  let code = getCode(body)
  let first = nb.blocks.len
  block:
    body
  var shown = ""
  for i in first ..< nb.blocks.len:
    shown.add nb.render(nb.blocks[i])
  nb.blocks.setLen(first)
  nbRawHtml: shown & "<details class=\"codice\"><summary></summary><pre><code class=\"nohighlight nim hljs\">" &
    highlightNim(code) & "</code></pre></details>"

template nbNota*(text: string, color = "") =
  ## A sticky note; `color` is "", "verde", "rosa" or "azzurra".
  nbRawHtml: "<div class=\"nota " & color & "\">" & markdownToHtml(text) & "</div>"

# ----------------------------------------------------------------------------------------- theme

func quadernoText(blk: JsonNode, nb: Nb): string =
  highlightOtherFences(highlightNimFences(addHeadingIds(markdownToHtml(blk{"text"}.getStr))))

func quadernoHeader(blk: JsonNode, nb: Nb): string =
  let c = nb.doc.context
  let home = c{"home_href"}.getStr
  let backLabel = c{"back_label"}.getStr("tabelline")
  let back = if home.len > 0: &"""<a href="{home}">← {backLabel}</a>""" else: "<span></span>"
  var rows = ""
  for (key, label, cls) in [("nome", "Nome", "nome"), ("materia", "Materia", ""), ("classe", "Classe", "")]:
    let v = c{key}.getStr
    if v.len > 0:
      let nameHref = c{"name_href"}.getStr
      let shown = if key == "nome" and nameHref.len > 0: &"""<a href="{nameHref}">{v}</a>""" else: v
      rows.add &"""<div class="riga {cls}"><span>{label}</span><span>{shown}</span></div>"""
  &"""<header>
<nav class="crumbs">{back}<a href="{repoUrl}">tabelline on GitHub ↗</a></nav>
{temaSwitch}{forme}
<div class="etichetta">{rows}</div>
</header>"""

func quadernoFooter(blk: JsonNode, nb: Nb): string =
  let source = nb.doc.context{"source_highlighted"}.getStr
  "<footer>" & motto & "Written in Nim with <a href=\"https://github.com/pietroppeter/nimib\">nimib</a> 🐳 · tables by " &
    &"""<a href="{repoUrl}">tabelline</a> · the code on this page ran when it was built""" &
    (if source.len == 0: "" else:
      """<details class="source"><summary>show the source of this page</summary><pre><code class="nohighlight nim">""" &
      source & "</code></pre></details>") & "</footer>" & temaBodyScript & tabsScript

func emptyPartial(blk: JsonNode, nb: Nb): string = ""

proc useQuaderno*(nb: var Nb, nome, materia = "", classe = "", title = "", description = "",
                  homeHref = "", backLabel = "tabelline", nameHref = "") =
  ## The quaderno look. `nome`, `materia` and `classe` fill the cover label; `homeHref` links back,
  ## with `backLabel` as its text (a devlog post links back to the devlog); `nameHref` makes the
  ## name a link (a devlog post's name links to the home page).
  let desc = if description.len > 0: "<meta name=\"description\" content=\"" &
               description.replace("\"", "&quot;") & "\">\n" else: ""
  nb.doc.context["title"] = %(if title.len > 0: title else: nome)
  nb.doc.context["stylesheet"] = %(desc &
    """<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2280%22>✏️</text></svg>">""" &
    "\n" & temaHeadScript & "\n<style>\n" & fonts & munariFonts & quadernoCss & munariCss & "</style>")
  nb.doc.context["highlight"] = %""
  nb.doc.context["nb_style"] = %""
  nb.doc.context["disableHighlightJs"] = %true
  nb.doc.context["nome"] = %nome
  nb.doc.context["materia"] = %materia
  nb.doc.context["classe"] = %classe
  nb.doc.context["home_href"] = %homeHref
  nb.doc.context["back_label"] = %backLabel
  nb.doc.context["name_href"] = %nameHref
  nb.backend.partials["header"] = quadernoHeader
  nb.backend.partials["footer"] = quadernoFooter
  nb.backend.partials["nbText"] = quadernoText
  nb.backend.partials["left"] = emptyPartial
  nb.backend.partials["right"] = emptyPartial
