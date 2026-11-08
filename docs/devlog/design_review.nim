## devlog: 08 Nov 2026 C | Reviewing the design: a palette by roles | The pages grew faster than their palette: six colours named after shapes, a yellow that does five jobs while it should only warn, galleries copied from post to post. What we have, shape apart from colour, a palette by roles (neutral, primary, secondary, status, data) for both looks, every component mapped to it, and the choices to make before it becomes the new Design Ref.
## A dated post: the design review as it was proposed on 8 November 2026, not updated afterwards.
## What is decided goes to the Design Ref (docs/design.nim). The colour maths (OKLab mixes and
## WCAG contrast) runs when the page is built.
import std/[os, strutils, strformat, sequtils, math, algorithm]
import nimib except md
import tabelline, tabelline/nimib
import ../quaderno

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "design-review" / "index.html"
nb.useQuaderno(nome = "tabelline",
               title = "Reviewing the design: a palette by roles", homeHref = "../", backLabel = "Devlog", nameHref = "../../")

# ---------------------------------------------------------------------------------- colour maths
# sRGB <-> OKLab (Björn Ottosson's matrices), the space CSS `color-mix(in oklab, ...)` mixes in,
# and WCAG 2 contrast. Enough to know what a mix looks like and whether text on it can be read.
type Rgb = array[3, float]

func hexToRgb(h: string): Rgb =
  for i in 0 .. 2: result[i] = parseHexInt(h[1 + 2*i .. 2 + 2*i]) / 255
func toHex(c: Rgb): string =
  "#" & c.mapIt(toHex(int(round(clamp(it, 0.0, 1.0) * 255)), 2)).join
func lin(c: float): float = (if c <= 0.04045: c / 12.92 else: pow((c + 0.055) / 1.055, 2.4))
func delin(c: float): float = (if c <= 0.0031308: 12.92 * c else: 1.055 * pow(c, 1 / 2.4) - 0.055)
func toOklab(c: Rgb): Rgb =
  let (r, g, b) = (lin(c[0]), lin(c[1]), lin(c[2]))
  let l = cbrt(0.4122214708*r + 0.5363325363*g + 0.0514459929*b)
  let m = cbrt(0.2119034982*r + 0.6806995451*g + 0.1073969566*b)
  let s = cbrt(0.0883024619*r + 0.2817188376*g + 0.6299787005*b)
  [0.2104542553*l + 0.7936177850*m - 0.0040720468*s,
   1.9779984951*l - 2.4285922050*m + 0.4505937099*s,
   0.0259040371*l + 0.7827717662*m - 0.8086757660*s]
func fromOklab(o: Rgb): Rgb =
  let l = pow(o[0] + 0.3963377774*o[1] + 0.2158037573*o[2], 3)
  let m = pow(o[0] - 0.1055613458*o[1] - 0.0638541728*o[2], 3)
  let s = pow(o[0] - 0.0894841775*o[1] - 1.2914855480*o[2], 3)
  [delin(4.0767416621*l - 3.3077115913*m + 0.2309699292*s),
   delin(-1.2684380046*l + 2.6097574011*m - 0.3413193965*s),
   delin(-0.0041960863*l - 0.7034186147*m + 1.7076147010*s)]
func mix(a, b: string, p: float): string =
  ## `color-mix(in oklab, a p, b)`, as a hex value.
  let (x, y) = (toOklab(hexToRgb(a)), toOklab(hexToRgb(b)))
  toHex(fromOklab([x[0]*p + y[0]*(1-p), x[1]*p + y[1]*(1-p), x[2]*p + y[2]*(1-p)]))
func luminance(h: string): float =
  let c = hexToRgb(h)
  0.2126*lin(c[0]) + 0.7152*lin(c[1]) + 0.0722*lin(c[2])
func contrast(a, b: string): float =
  let (x, y) = (luminance(a), luminance(b))
  (max(x, y) + 0.05) / (min(x, y) + 0.05)

# ------------------------------------------------------------------------------ the proposed roles
# Each look gives seven values; every token is mixed from them.
type Look = object
  name: string
  paper, ink, primary, secondary, warning, success: string

let munari = Look(name: "Munari (Haru)", paper: "#FCFAF2", ink: "#1C1C1C", primary: "#E16B8C",
                  secondary: "#7DB9DE", warning: "#F7D94C", success: "#86C166")
let quadernoLook = Look(name: "Quaderno", paper: "#FDFDF9", ink: "#2B2D38", primary: "#1F4E99",
                        secondary: "#C62828", warning: "#FFD84D", success: "#3FA34D")

const steps = [0, 4, 8, 14, 25, 40, 55, 65, 80, 100]   # ink in paper, per neutral step 0..9
const softShare = 0.22    # a colour in paper, for the background of a note
const textShare = 0.50    # a colour in ink, for text in that colour

type Token = tuple[name, value, role: string]

func tokens(l: Look): seq[Token] =
  for i, s in steps:
    result.add (&"--n-{i}", mix(l.ink, l.paper, s / 100), "neutral")
  result.add ("--surface", mix("#FFFFFF", l.paper, 0.6), "neutral")
  for (role, c) in [("primary", l.primary), ("secondary", l.secondary), ("warning", l.warning), ("success", l.success)]:
    result.add (&"--{role}", c, role)
    result.add (&"--{role}-soft", mix(c, l.paper, softShare), role)
    result.add (&"--{role}-text", mix(c, l.ink, textShare), role)

func css(ts: seq[Token]): string =
  ts.mapIt(&"{it.name}: {it.value};").join(" ")

let munariTokens = tokens(munari)
let quadernoTokens = tokens(quadernoLook)
func value(ts: seq[Token], name: string): string =
  for t in ts:
    if t.name == name: return t.value

nbRawHtml: &"""<style>
html {{ {css(quadernoTokens)} }}
html[data-tema="munari"] {{ {css(munariTokens)} }}
.scala {{ display: grid; grid-template-columns: repeat(10, 1fr); gap: 2px; margin: .6rem 0 .2rem; }}
.scala span {{ height: 2.2rem; outline: 1px solid rgba(0,0,0,.06); }}
.scala-num {{ display: grid; grid-template-columns: repeat(10, 1fr); font-size: .72rem; color: var(--n-7); text-align: center; }}
.ruoli {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(9.5rem, 1fr)); gap: .8rem; margin: 1rem 0; }}
.ruolo-c {{ font-size: .86rem; line-height: 1.35; }}
.ruolo-c .tre {{ display: grid; grid-template-columns: 2fr 1fr 1fr; height: 2.4rem; margin-bottom: .3rem; }}
.ruolo-c strong {{ display: block; font-size: .95rem; }}
.galleria {{ display: flex; align-items: flex-start; gap: .8rem; overflow-x: auto; scroll-snap-type: x mandatory;
  padding: .2rem 0 .8rem; -webkit-overflow-scrolling: touch; }}
.galleria::after {{ content: ""; flex: 0 0 .2rem; }}
.scheda {{ flex: 0 0 min(84%, 22rem); scroll-snap-align: start; padding: .7rem .9rem .9rem;
  background: var(--n-0); color: var(--n-9); border: 1px solid var(--n-3); }}
.scheda .numero {{ font: 700 .7rem/1.2 var(--text); letter-spacing: .14em; text-transform: uppercase; color: var(--n-7); }}
.scheda h3 {{ margin: .15rem 0 .5rem !important; font-size: 1.1rem !important; color: var(--n-9) !important; }}
.scheda p {{ margin: .4rem 0; font-size: .92rem; line-height: 1.45; }}
.p-nota {{ padding: .55rem .8rem; margin: .45rem 0; font-size: .9rem; line-height: 1.4; border-top: 4px solid; }}
.p-nota.neutra {{ background: var(--n-1); border-color: var(--n-9); }}
.p-nota.info {{ background: var(--secondary-soft); border-color: var(--secondary); }}
.p-nota.fatto {{ background: var(--success-soft); border-color: var(--success); }}
.p-nota.manca {{ background: var(--primary-soft); border-color: var(--primary); }}
.p-nota.avviso {{ background: var(--warning-soft); border-color: var(--warning); position: relative; padding-left: 2.3rem; }}
.p-nota.avviso::before {{ content: ""; position: absolute; left: .7rem; top: .65rem; width: 1.05rem; height: .95rem;
  background: var(--warning); clip-path: polygon(50% 0, 100% 100%, 0 100%); }}
.p-sec {{ font: 700 1.2rem/1.2 var(--text); color: var(--n-9); position: relative; padding-left: 1.6rem; margin: .4rem 0; }}
.p-sec::before {{ content: ""; position: absolute; left: 0; top: .2em; width: 1rem; height: 1rem; border-radius: 50%; background: var(--primary); }}
.forma {{ display: inline-block; width: 1.1rem; height: 1.1rem; vertical-align: -.15rem; margin-right: .45rem; }}
.forma.c {{ border-radius: 50%; }} .forma.t {{ clip-path: polygon(50% 0, 100% 100%, 0 100%); }}
.p-riga {{ margin: .35rem 0; font-size: .92rem; line-height: 1.4; }}
.p-kicker {{ font: 700 .7rem/1 var(--text); letter-spacing: .2em; text-transform: uppercase; color: var(--primary-text); }}
.p-muted {{ color: var(--n-7); }}
.p-link {{ color: var(--n-9); text-decoration: underline; text-decoration-color: var(--primary); text-decoration-thickness: 2px; text-underline-offset: 2px; }}
.p-link.hover {{ background: var(--primary-soft); }}
.p-mark {{ background: var(--warning-soft); padding: 0 .15em; }}
.p-quote {{ border-left: 5px solid var(--n-4); padding: .2rem .7rem; margin: .4rem 0; font-size: .92rem; }}
.p-code {{ font: 12.5px/1.55 var(--mono); background: var(--surface); border: 2px solid var(--n-9); padding: .5rem .7rem; white-space: pre; overflow-x: auto; }}
.p-out {{ font: 12.5px/1.55 var(--mono); background: var(--n-1); padding: .4rem .7rem; margin-top: .4rem; }}
.p-out::before {{ content: "OUTPUT"; display: block; font: 700 .6rem/1.4 var(--text); letter-spacing: .2em; color: var(--primary-text); }}
.p-code .k {{ color: var(--primary-text); font-weight: 700; }} .p-code .s {{ color: var(--secondary-text); }}
.p-code .n {{ color: var(--success-text); }} .p-code .c {{ color: var(--n-7); font-style: italic; }}
.p-tabs {{ display: flex; }} .p-tabs span {{ font: 700 .66rem/1.8 var(--text); letter-spacing: .1em; text-transform: uppercase;
  border: 2px solid var(--n-9); border-bottom: 0; padding: 0 .6rem; margin-right: -2px; color: var(--n-9); }}
.p-tabs span:first-child {{ background: var(--n-9); color: var(--n-0); }}
.p-tabs + div {{ border-top: 2px solid var(--n-9); padding-top: .4rem; }}
.p-indice {{ list-style: none; padding: 0; margin: 0; counter-reset: v; font-size: .92rem; }}
.p-indice li {{ counter-increment: v; position: relative; padding-left: 1.9rem; margin: .3rem 0; }}
.p-indice li::before {{ content: counter(v); position: absolute; left: 0; top: .05rem; width: 1.3rem; height: 1.3rem; border-radius: 50%;
  background: var(--primary); color: #fff; font: 700 .7rem/1.3rem var(--text); text-align: center; }}
.p-card {{ border-top: 4px solid var(--secondary); background: var(--secondary-soft); padding: .5rem .7rem; font-size: .88rem; margin: .4rem 0; }}
.p-card b {{ display: block; }}
.p-table {{ width: 100%; border-collapse: collapse; font-size: .85rem; border-top: 3px solid var(--n-9); border-bottom: 3px solid var(--n-9); background: var(--surface); }}
.p-table caption {{ text-align: left; font-weight: 700; padding-bottom: .2rem; }}
.p-table th {{ text-align: left; border-bottom: 2px solid var(--n-9); padding: .25rem .4rem; }}
.p-table td {{ padding: .25rem .4rem; border-top: 1px solid var(--n-3); }}
.p-table tr.g td {{ background: var(--n-1); font-weight: 700; }}
.p-table .bar {{ display: inline-block; height: .6rem; background: var(--secondary); vertical-align: middle; }}
</style>"""

nbText: """
<p class="kicker">8 November 2026</p>

# Reviewing the design: a palette by roles

<p class="lede">The pages of tabelline grew faster than their palette. Six colours named after
Munari's shapes still paint everything, but which colour a new element should take is decided
case by case, the yellow that should only warn does five other jobs, and galleries are copied
from post to post. This post looks at what we have, proposes a palette by roles (neutral,
primary, secondary, status and data) for both looks, maps every component to it, and lists the
choices to make. What is chosen becomes the new Design Ref.</p>

Everything below that shows a colour uses the proposed tokens, live, in the look picked at the top
of the page: switch it to see the quaderno's version. The contrast numbers are computed when the
page is built, from the fixed values of the two looks.
"""
nbIndice

# ------------------------------------------------------------------------------------- part 1
nbText: """
## What we have

The [Design Ref](../../design/) records the design as it is. Munari draws everything with six
colours named after where they go: paper, ink, and the circle, the square, the triangle and a
fourth. Here are the jobs each one does today:
"""

block:
  let jobs = tableData:
    colour: ["paper", "ink", "circle", "square", "triangle", "fourth"]
    jobs: [1, 6, 8, 3, 6, 2]
    what: ["the page, and mixed into every tint",
           "text, headings, links, rules, code edges, the switch and the tabs",
           "section markers, the indice, kickers, `###` headings, link underlines, code keywords, the rosa note, the line under a table's heading",
           "the cover, code strings, the azzurra note",
           "the cover, the plain note, table group headings, quotes, link hover, highlights",
           "the verde note, numbers in code"]
  let t = tabella(jobs, rownameCol = "colour"):
    tabHeader "Six colours, and their jobs", "in the Munari look, on 8 November 2026"
    colsLabel {"what": "where it goes"}
    fmtMarkdown "what"
    fmtBar "jobs", color = "var(--secondary)", width = "4em"
    tabSourceNote "From docs/munari.nim and the devlog post Munari meets Japan."
    optQuaderno()
  nbTable t

# Fixed colours written in each source of the pages. Counted once, on 8 November 2026, and saved
# as a dated snapshot (the post is dated: its numbers must not move as the pages change). Delete
# the file to count again.
let hexSnapshot = docs / "devlog" / "data" / "design-review" / "hex-colours.tsv"
if not fileExists(hexSnapshot):
  var lines = @["source\tcolours"]
  for path in walkDirRec(docs):
    if not path.endsWith(".nim") or "design_review" in path: continue
    var found: seq[string]
    let s = readFile(path)
    var i = 0
    while i < s.len - 6:
      if s[i] == '#' and allIt(s[i+1 .. i+6], it in HexDigits) and (i + 7 >= s.len or s[i+7] notin HexDigits + Letters):
        found.add s[i .. i+6].toUpperAscii
        i += 7
      else: inc i
    found = found.deduplicate
    if found.len >= 3:
      lines.add path.relativePath(docs) & "\t" & $found.len
  createDir(hexSnapshot.parentDir)
  writeFile(hexSnapshot, lines.join("\n") & "\n")

block:
  var files: seq[string]
  var counts: seq[int]
  for line in readFile(hexSnapshot).strip.splitLines[1 .. ^1]:
    let f = line.split('\t')
    files.add f[0]
    counts.add parseInt(f[1])
  var order = toSeq(0 ..< files.len)
  order.sort(proc (a, b: int): int = cmp(counts[b], counts[a]))
  let fixed = tableData:
    source: order.mapIt(files[it])
    colours: order.mapIt(counts[it])
  let total = counts.sum
  let t = tabella(fixed, rownameCol = "source"):
    tabHeader "Fixed colours in the sources of the pages", &"distinct hex values per file, {total} in all"
    colsLabel {"colours": "hex values"}
    fmtBar "colours", color = "var(--primary)", width = "6em"
    tabSourceNote "Counted on 8 November 2026 (snapshot in devlog/data/design-review/); files with fewer than three are left out."
    optQuaderno()
  nbTable t

nbText: """
Five things don't hold up:

1. **The roles are implicit.** A colour named *circle* tells you its shape, not its job; to pick
   one for a new element you look for something similar and copy it.
2. **The triangle should only warn**, the rule says, yet its yellow fills plain notes, group
   headings, quotes, link hover and highlights. A real warning has nothing left to look like.
3. **Notes have colours but no meanings.** *azzurra* has come to mean a living document and
   *verde* something done, by habit; *rosa* and the plain note mean whatever the writer wanted.
4. **Components are copied, not shared.** Each post with a gallery carries its own CSS for it;
   the tables of the docs take `optQuaderno()` and Munari paints over it with `!important`.
5. **The quaderno has fixed colours only**, so it can't follow a palette, and a few posts
   (the palettes post most of all) write their own hex values.

## Shape is one thing, colour another

Today shape and colour are welded together. Each shape has one colour (the circle is always the
circle's colour) and the colours are named after the shapes (`--m-cerchio`), so a colour means
"the circle's job" and a circle can only be one colour. They can be pulled apart: two channels,
each saying one thing.

- **Shape says what kind of thing it is.** The circle is a place in the page: a section, an entry
  of the indice. The triangle is attention: a warning. The square is a sheet set apart: a note, a
  card, a figure; it is the shape of the sheet itself (square corners, a straight top edge), never
  a separate mark, so it can't be mistaken for a checkbox.
- **Colour says which role it plays**: primary, secondary, a status (warning, success,
  missing), a part of the page, a category of data.

Each shape keeps a default colour (the circle primary, the triangle warning, the square
secondary) and takes another only for a reason that can be said in words. Here is what that
allows, drawn with the tokens below:
"""

nbRawHtml: """<div class="ruoli" style="grid-template-columns:repeat(auto-fill,minmax(15rem,1fr))">
<div><p class="p-kicker">Parts of a page</p>
<p class="p-riga"><span class="forma c" style="background:var(--primary)"></span>Part 1: from zero</p>
<p class="p-riga"><span class="forma c" style="background:var(--secondary)"></span>Part 2: the pieces</p>
<p class="p-riga"><span class="forma c" style="background:var(--success)"></span>Part 3: how it is built</p>
<p class="p-muted" style="font-size:.85rem">A page in three parts colours each section's circle by its part; the indice shows the parts at a glance.</p></div>
<div><p class="p-kicker">How serious</p>
<p class="p-riga"><span class="forma t" style="background:var(--warning)"></span>Careful: this may change</p>
<p class="p-riga"><span class="forma t" style="background:var(--primary)"></span>This breaks: the API changed</p>
<p class="p-muted" style="font-size:.85rem">Always a triangle, so always a warning; the colour says how serious.</p></div>
<div><p class="p-kicker">Categories in data</p>
<p class="p-riga"><span class="forma" style="background:var(--secondary)"></span><span class="forma c" style="background:var(--primary)"></span><span class="forma t" style="background:var(--success)"></span>three series</p>
<p class="p-muted" style="font-size:.85rem">Colour and shape together tell series apart, and still do without colour.</p></div>
</div>"""

nbText: """
**What it gains**

1. **Meaning never rests on colour alone.** The kind of thing is in its shape, so a reader who
   doesn't see the colours (colour blindness, a print in black and white) still gets it; WCAG's
   *Use of Color* asks exactly this.
2. **Colour is free to say more**: the part of a page (your three-part structure), how serious a
   warning is, a category of data.
3. **A palette changes colours only.** Swapping Haru for another palette, or the quaderno for
   Munari, leaves every shape where it is; the tokens below are named by role, not by shape.
4. **Shapes can mark data**: a legend or a column of markers can use shape and colour together.

**What it costs**

1. **It departs from Munari's covers**, where the three shapes come in three fixed colours. The
   page cover can keep that as a picture; the rule is about what shapes and colours *mean*.
2. **More combinations, more noise.** A shape in a colour with no reason is decoration, which
   the pages forbid. Hence the rule: the default colour, unless the reason can be said.
3. **The yellow triangle is a convention** the world reads as "warning". A triangle in another
   colour reads a little less so; its colours stay among the status colours.
4. **The square needs a job** or it is decoration. As the shape of the sheet itself it has one;
   as a separate mark it would look like a checkbox, and is not allowed.

So: **shape for kind, colour for role**, a default colour per shape, and another colour only with
a reason.

## A palette by roles

Design systems agree on a simple idea: name colours after what they do, and give every role the
same few shades. Here are five roles, simplest first.

### Neutral

A scale from paper to ink in ten steps, mixed in OKLab. It does most of the work: the page, the
text, rules, code backgrounds, grey text. `--n-0` is the paper and `--n-9` the ink; one more
token, `--surface`, is a sheet a little whiter than the paper, for code and tables.
"""

block:
  var s = """<div class="scala">"""
  for i in 0 .. 9: s.add &"""<span style="background:var(--n-{i})"></span>"""
  s.add """</div><div class="scala-num">"""
  for i in 0 .. 9: s.add &"<span>{i}</span>"
  s.add "</div>"
  nbRawHtml: s

nbText: """
### Primary, secondary, and two for status

Each colour role has three tokens: the colour itself (`--primary`) for shapes and edges, a
**soft** version mixed into the paper (`--primary-soft`, for backgrounds) and a **text** version
mixed with ink (`--primary-text`), dark enough to read.

- **Primary** is the circle: sections, the indice, kickers, link underlines, keywords. One colour
  that says "this is tabelline".
- **Secondary** is the square: information and navigation, living documents, strings, the bars
  of tables.
- **Warning** is the triangle, and only warnings.
- **Success** is the fourth colour: what is done, what works, numbers in code.
"""

block:
  var s = """<div class="ruoli">"""
  for (role, what) in [("primary", "the circle: sections, kickers, links"), ("secondary", "the square: info, living documents"),
                       ("warning", "the triangle: warnings only"), ("success", "the fourth: done, works")]:
    s.add &"""<div class="ruolo-c"><div class="tre"><span style="background:var(--{role})"></span><span style="background:var(--{role}-soft)"></span><span style="background:var(--{role}-text)"></span></div><strong>{role}</strong>{what}<br><span class="p-muted">colour · soft · text</span></div>"""
  s.add "</div>"
  nbRawHtml: s

nbText: """
### Data

Tables and charts need more colours than a page does. Three kinds, each from the roles above so a
table belongs to the page it is on:

- **categorical**: the seven soft tints of the parts of a table (already Haru's neighbours,
  `docs/parti.nim`), for things that are just different;
- **sequential**: from `--n-0` to `--secondary`, for more and less;
- **diverging**: from `--secondary` through the paper to `--primary`, for below and above a middle.

Since a tabelline colour can be a CSS variable (`fmtBar(color = "var(--secondary)")`), a table
can use them directly.

### Can it be read?

Text tokens must reach 4.5:1 against the paper (WCAG AA for body text). With a colour mixed half
and half with ink, primary, secondary and success pass in both looks, on paper and on their soft
tints. Warning doesn't, in either look. Today's `--m-cerchio-testo`, which has only a quarter of
ink, passes on paper but not on its own soft background.
"""

block:
  var names, looks: seq[string]
  var onPaper, onSoft: seq[float]
  for (l, ts) in [(munari, munariTokens), (quadernoLook, quadernoTokens)]:
    for name in ["--n-7", "--primary-text", "--secondary-text", "--warning-text", "--success-text"]:
      looks.add l.name
      names.add "`" & name & "`"
      onPaper.add contrast(ts.value(name), ts.value("--n-0"))
      let soft = if name == "--n-7": ts.value("--n-1") else: ts.value(name.replace("-text", "-soft"))
      onSoft.add contrast(ts.value(name), soft)
  # today's circle text in Munari, for comparison
  let old = mix(munari.primary, munari.ink, 0.75)
  looks.add "Munari today"
  names.add "`--m-cerchio-testo`"
  onPaper.add contrast(old, munari.paper)
  onSoft.add contrast(old, mix(munari.primary, munari.paper, 0.20))
  let c = tableData:
    look: looks
    token: names
    paper: onPaper
    soft: onSoft
  let t = tabella(c, rownameCol = "token", groupnameCol = "look"):
    tabHeader "Contrast of the text tokens", "WCAG 2 ratio; 4.5 or more reads as body text"
    colsLabel {"paper": "on paper", "soft": "on its soft"}
    fmtNumber ["paper", "soft"], decimals = 2
    fmtMarkdown "token"
    tabStyle style.text(color = "var(--primary-text)", weight = "bold"), loc.body(cols = ["paper", "soft"], rows = where(it["paper"] < 4.5))
    tabStyle style.text(color = "var(--primary-text)", weight = "bold"), loc.body(cols = "soft", rows = where(it["soft"] < 4.5))
    tabSourceNote md("`--n-7` (grey text) is measured on `--n-1`. In bold: below 4.5. Computed when this page was built.")
    optQuaderno()
  nbTable t

nbText: """
The yellow is the hardest: even mixed half with ink, which turns it olive, it falls short in both looks.
So the rule stays as it is, and `--warning-text` is dropped: **the warning colour is never text**; a warning is ink on its soft
background, with the triangle beside it.

## Every component, mapped

Each component of the pages takes its colours from a token. The table is the proposal, grouped
from the simplest piece to the most complex, with today's colour for comparison.
"""

block:
  type Row = object
    group, component, token, today: string
  var rows: seq[Row]
  template r(g, c, tok, td: string) = rows.add Row(group: g, component: c, token: tok, today: td)
  r "Page", "background", "--n-0", "paper"
  r "Page", "text", "--n-9", "ink"
  r "Page", "grey text (captions, dates, footer)", "--n-7", "ink 62% in paper"
  r "Page", "rules and borders", "--n-3", "ink 12% in paper"
  r "Text", "section marker, indice numbers (a circle)", "--primary", "circle"
  r "Text", "kicker, `###` headings", "--primary-text", "circle text"
  r "Text", "link underline", "--primary", "circle text"
  r "Text", "link hover", "--primary-soft", "triangle"
  r "Text", "highlight (`<mark>`)", "--warning-soft", "triangle 55%"
  r "Text", "quote edge", "--n-4", "triangle"
  r "Code", "code sheet", "--surface", "white 60% in paper"
  r "Code", "output, inline code", "--n-1", "ink 6% in paper"
  r "Code", "keywords", "--primary-text", "circle text"
  r "Code", "strings", "--secondary-text", "square text"
  r "Code", "numbers", "--success-text", "fourth text"
  r "Code", "comments", "--n-7", "grey"
  r "Code", "\"show code\" fold under a table", "--secondary", "square (from #16)"
  r "Notes", "plain note", "--n-1", "triangle 38% in paper"
  r "Notes", "info, living document", "--secondary-soft", "square 20% (azzurra)"
  r "Notes", "done, works", "--success-soft", "fourth 26% (verde)"
  r "Notes", "missing, differs from gt", "--primary-soft", "circle 20% (rosa)"
  r "Notes", "warning (new), with the triangle", "--warning-soft", "none"
  r "Navigation", "cards of living documents", "--secondary-soft", "square 20%"
  r "Navigation", "tabs, look switch (selected)", "--n-9", "ink"
  r "Navigation", "gallery card edge", "--n-3", "currentColor 18%"
  r "Navigation", "gallery card number", "--n-7", "currentColor 60%"
  r "Tables", "top and bottom rule", "--n-9", "ink, over optQuaderno"
  r "Tables", "line under the heading", "--primary", "circle"
  r "Tables", "row lines", "--n-3", "ink 12% in paper"
  r "Tables", "group headings", "--n-1", "triangle 22% in paper"
  r "Tables", "bars (`fmtBar`)", "--secondary", "fixed per table"
  r "Tables", "data colours", "data palettes", "fixed per table"
  let m = tableData:
    group: rows.mapIt(it.group)
    component: rows.mapIt(it.component)
    swatch: rows.mapIt("")
    token: rows.mapIt(if it.token.startsWith("--"): "`" & it.token & "`" else: it.token)
    today: rows.mapIt(it.today)
  var t = tabella(m, rownameCol = "component", groupnameCol = "group"):
    tabHeader "Every component and its token", "the proposal, and today's colour in the Munari look"
    colsLabel {"swatch": "", "token": "proposed", "today": "today"}
    fmtMarkdown ["token", "today"]
    fmtMarkdown "component"
    optQuaderno()
  for i, row in rows:
    if row.token.startsWith("--"):
      t = t.tabStyle(style.fill(&"var({row.token})"), loc.body(cols = "swatch", rows = [i]))
  nbTable t

nbText: """
Shapes keep their default colour in this table; a page in parts or a warning that breaks
something may give them another, as above. Four changes stand out. **The yellow is freed**: plain notes, quotes and group headings go
neutral, and link hover takes the primary's soft tint, so the triangle's colour is left to warnings
(and to the highlighter pen, a choice below). **Notes get meanings**: info, done, missing, and a
new warning note with the triangle. **Tables follow the page** instead of being painted twice.
**The quaderno gets the same tokens**, mixed from its own seven values (blue pen as primary, red
pen as secondary), so a component is written once for both looks.

### The components, in the proposed palette

Swipe through the components, drawn with the tokens only. Switch the look at the top to see the
same cards as a quaderno.
"""

block:
  var cards: seq[string]
  proc card(num, title, body: string) =
    cards.add "<div class=\"scheda\"><span class=\"numero\">" & num & " of 6</span><h3>" & title & "</h3>" & body & "</div>"
  card "1", "Text", """<p class="p-kicker">Kicker</p><p class="p-sec">A section</p>
<p>Body text in ink, a <span class="p-link">link</span>, a <span class="p-link hover">touched link</span>,
a <span class="p-mark">highlight</span> and <span class="p-muted">grey text</span>.</p>
<div class="p-quote">A quote: a grey edge, nothing else.</div>"""
  card "2", "Notes", """<div class="p-nota neutra"><b>Plain</b>: an aside.</div>
<div class="p-nota info"><b>Info</b>: a living document, a page to go to.</div>
<div class="p-nota fatto"><b>Done</b>: what works.</div>
<div class="p-nota manca"><b>Missing</b>: a gap, or a difference from gt.</div>
<div class="p-nota avviso"><b>Warning</b>: the API will change.</div>"""
  card "3", "Code", """<div class="p-code"><span class="k">let</span> answer = <span class="n">6</span> * <span class="n">7</span>  <span class="c"># a comment</span>
<span class="k">echo</span> <span class="s">"the answer is "</span>, answer</div>
<div class="p-out">the answer is 42</div>"""
  card "4", "Navigation", """<ol class="p-indice"><li>What we have</li><li>A palette by roles</li><li>Every component</li></ol>
<div class="p-card"><b>Design Ref</b>a card of a living document</div>
<div class="p-tabs"><span>👑 Nim</span><span>🐍 Python</span><span>🏴‍☠️ R</span></div><div class="p-muted" style="font-size:.85rem">the tabs, the switch</div>"""
  card "5", "A table", """<table class="p-table"><caption>Three tabelline</caption>
<tr><th>×</th><th>result</th><th></th></tr>
<tr class="g"><td colspan="3">small</td></tr>
<tr><td>2 × 3</td><td>6</td><td><span class="bar" style="width:.7rem"></span></td></tr>
<tr><td>4 × 5</td><td>20</td><td><span class="bar" style="width:2.4rem"></span></td></tr>
<tr class="g"><td colspan="3">bigger</td></tr>
<tr><td>6 × 7</td><td>42</td><td><span class="bar" style="width:5rem"></span></td></tr></table>"""
  var seqs = """<p style="font-size:.85rem;margin:.2rem 0">sequential</p><div class="scala" style="grid-template-columns:repeat(7,1fr)">"""
  for p in [0, 15, 30, 45, 60, 80, 100]:
    seqs.add &"""<span style="background:color-mix(in oklab, var(--secondary) {p}%, var(--n-0))"></span>"""
  seqs.add """</div><p style="font-size:.85rem;margin:.6rem 0 .2rem">diverging</p><div class="scala" style="grid-template-columns:repeat(7,1fr)">"""
  for (c, p) in [("secondary", 100), ("secondary", 60), ("secondary", 25), ("n-0", 100), ("primary", 25), ("primary", 60), ("primary", 100)]:
    seqs.add &"""<span style="background:color-mix(in oklab, var(--{c}) {p}%, var(--n-0))"></span>"""
  seqs.add """</div><p style="font-size:.85rem;margin:.6rem 0 .2rem">categorical (the parts of a table)</p><div class="scala" style="grid-template-columns:repeat(7,1fr)">"""
  for hex in ["#FAECAC", "#C7DFEA", "#F1BEC7", "#FDDFC4", "#CDC7DE", "#CAE2B7", "#D7EEEC"]:
    seqs.add &"""<span style="background:{hex}"></span>"""
  seqs.add "</div>"
  card "6", "Data", seqs
  nbRawHtml: &"""<div class="galleria" tabindex="0" aria-label="the components: swipe or scroll sideways">{cards.join("\n")}</div>"""

nbText: """
## Choices to make

Each has my recommendation first. What you pick goes into the next PR and the Design Ref.

1. **Token names.** English role names (`--n-0`…`--n-9`, `--primary`, `--primary-soft`,
   `--primary-text`, …), the same in both looks, *or* Italian ones like the rest of the theme
   (`--neutro-*`, `--primario`, …). *Recommended: English*, since agents and other projects
   read them.
2. **Shape apart from colour.** Shape says the kind (circle a place, triangle a warning, square a
   sheet), colour says the role, each shape has a default colour and takes another only with a
   reason, *or* each shape keeps its one colour as today. *Recommended: apart.*
3. **"Missing / differs" notes.** The primary's soft tint (as the rosa note is today), *or* a
   separate accent (an orange such as 洒落柿 sharegaki) so primary stays only "this is tabelline".
   *Recommended: primary soft*: one colour fewer.
4. **The highlighter.** `<mark>` keeps the warning's soft yellow (a highlighter pen is yellow), *or*
   it takes the primary's soft tint so yellow means warning only. *Recommended: keep yellow*;
   it is never a shape, so it can't be mistaken for the triangle.
5. **Tables.** A preset in the library that uses the tokens (`optTokens()`: colours as
   `var(--n-9)`, …, so a table follows whichever look the page has) and replaces `optQuaderno()`
   in every page; `optQuaderno` itself is removed before 0.1 is tagged, *or* kept as a library
   preset for people who like it. *Recommended: replace, and keep `optQuaderno` out of 0.1*;
   that needs a word with the 0.1 build thread.
6. **The quaderno.** It gets the same tokens from its seven values (blue pen primary, red pen
   secondary), *or* stays as it is, frozen. *Recommended: tokens*, so new components work in both.
7. **Coloured parts.** On a page in parts, each section's circle (and its entry in the indice)
   takes the colour of its part, *or* every circle stays primary. *Recommended: try it on the
   Design Ref first*, the first page written in three parts.

## What happens next

When you have picked, one PR does it all:

- the tokens go into `docs/munari.nim` (from the six palette values, as now) and
  `docs/quaderno.nim`, and the components use them instead of fixed colours;
- the shared components move into the theme with a helper each: notes with a kind
  (`nbNota(text, "info")`, …, and `"avviso"` with the triangle), galleries (`nbGalleria`), cards;
- the table preset, and every page switched to it; the "show code" fold under tables
  (`nbShowCode`, from the Milano Cortina post) goes in the Design Ref and on the explainer's tables;
- the posts' own hex values replaced where they are not data;
- the Design Ref rewritten from this post: the roles, the tokens, the components and their rules.

## How it is built

This page computes everything it shows. Each look is seven hex values (paper, ink, primary,
secondary, warning, success, and the paper again for the surface); `tokens` mixes them in OKLab,
the space CSS's `color-mix(in oklab, ...)` uses, with Björn Ottosson's matrices: the ten neutral
steps put 0, 4, 8, 14, 25, 40, 55, 65, 80 and 100% of ink in the paper; a soft tint is 22% of the
colour in paper; a text colour is 50% of the colour in ink. The tokens are written as CSS
variables on `html` (the quaderno) and on `html[data-tema="munari"]`, so every swatch, card and
table here changes with the look switch. Contrast is the WCAG 2 ratio of the two relative
luminances. The fixed-colour count read every `.nim` file under `docs/` and counted the distinct
`#RRGGBB` values once, on 8 November 2026; it is kept as a dated snapshot,
`docs/devlog/data/design-review/hex-colours.tsv`, so the post keeps its numbers as the pages change.
"""
nbSave
