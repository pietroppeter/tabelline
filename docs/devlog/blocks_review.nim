## devlog: 08 Nov 2026 D | Blocks, not HTML | nimib exists so that a page says what it shows, with blocks made for it, and not how it is drawn. tabelline's pages drifted the other way: HTML in nbText and nbRawHtml, CSS and colours in every page. A review of all of it, measured when the page is built, the blocks that would replace it (one of them working already), where styles and colours should live, and what a nimib skill should teach so that agents don't drift the same way.
## A dated post: the review as it was on 8 November 2026, not updated afterwards. The audit tables
## are computed from the sources of the pages when this page is built. It practises what it
## preaches: no HTML in its text and no nbRawHtml; its gallery is the first custom block,
## docs/blocchi.nim.
import std/[os, strutils, strformat, sequtils, algorithm]
import nimib
import tabelline, tabelline/nimib
import ../blocchi

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "blocks-review" / "index.html"
nb.useTabelline(nome = "tabelline",
               title = "Blocks, not HTML", homeHref = "../", backLabel = "Devlog", nameHref = "../../")

nbText: """
*8 November 2026*

# Blocks, not HTML

**nimib exists to make custom blocks easy**, so that a page says what it shows and not how it is
drawn: `nbTable t` rather than a `<div>` around a string of HTML. tabelline's pages drifted the
other way. They write HTML inside `nbText`, paste it with `nbRawHtml`, carry their own `<style>`
and `<script>`, and write colours as hex values where they need them. This post measures how far
the drift went, proposes the blocks that would replace it (one of them works already, below), says
where styles and colours should live, and what a nimib skill should teach so that agents, which
wrote most of these pages, don't drift again.

This page has no HTML in its text and no `nbRawHtml`: it is written only with nimib's blocks,
tabelline's `nbTable` and the first custom block.
"""
nbIndice

# -------------------------------------------------------------------------------------- audit
type Audit = object
  file: string
  kind: string
  raw, textHtml, style, script, inline, hex: int

proc countOf(s, sub: string): int =
  var i = s.find(sub)
  while i >= 0:
    inc result
    i = s.find(sub, i + sub.len)

const tags = ["<div", "<p ", "<p>", "<span", "<ul", "<ol", "<li", "<table", "<h1", "<h2", "<h3", "<small",
              "<details", "<button", "<br", "<a href", "<strong"]

proc audit(path: string): Audit =
  let s = readFile(path)
  let rel = path.relativePath(docs)
  result.file = rel
  result.kind = if rel in ["quaderno.nim", "munari.nim", "blocchi.nim", "parti.nim"]: "theme and helpers"
                elif rel.startsWith("devlog/"): "posts"
                elif rel in ["mese.nim", "piano.nim", "olimpiadi.nim", "all.nim"]: "data"
                else: "living documents"
  result.raw = s.countOf("nbRawHtml") - s.countOf("template nbRawHtml")
  # nbText blocks whose text holds HTML tags
  var i = s.find("nbText:")
  while i >= 0:
    let a = s.find("\"\"\"", i)
    if a < 0: break
    let b = s.find("\"\"\"", a + 3)
    if b < 0: break
    let text = s[a + 3 ..< b]
    if tags.anyIt(it in text): inc result.textHtml
    i = s.find("nbText:", b)
  result.style = s.countOf("<style")
  result.script = s.countOf("<script")
  result.inline = s.countOf("style=\\\"") + s.countOf("style=\"")
  var found: seq[string]
  var k = 0
  while k < s.len - 6:
    if s[k] == '#' and allIt(s[k+1 .. k+6], it in HexDigits) and (k + 7 >= s.len or s[k+7] notin HexDigits + Letters):
      found.add s[k .. k+6].toUpperAscii
      k += 7
    else: inc k
  result.hex = found.deduplicate.len

# The audit is a dated snapshot: counted once, on 8 November 2026, and saved in
# devlog/data/blocks-review/audit.tsv, so this post keeps its numbers while the pages are
# migrated. The live check is a separate tool. Delete the file to count again.
let snapshot = docs / "devlog" / "data" / "blocks-review" / "audit.tsv"
if not fileExists(snapshot):
  var lines = @["file\tkind\tnbRawHtml\tnbTextWithHtml\tstyle\tscript\tinline\thex"]
  for path in walkDirRec(docs):
    if not path.endsWith(".nim") or path.endsWith("blocks_review.nim"): continue
    let a = audit(path)
    if a.kind != "data":
      lines.add [a.file, a.kind, $a.raw, $a.textHtml, $a.style, $a.script, $a.inline, $a.hex].join("\t")
  createDir(snapshot.parentDir)
  writeFile(snapshot, lines.join("\n") & "\n")

var audits: seq[Audit]
for line in readFile(snapshot).strip.splitLines[1 .. ^1]:
  let f = line.split('\t')
  audits.add Audit(file: f[0], kind: f[1], raw: parseInt(f[2]), textHtml: parseInt(f[3]), style: parseInt(f[4]),
                   script: parseInt(f[5]), inline: parseInt(f[6]), hex: parseInt(f[7]))
audits.sort(proc (a, b: Audit): int = cmp((a.kind, -(a.raw + a.textHtml + a.style + a.script)), (b.kind, -(b.raw + b.textHtml + b.style + b.script))))

let totalRaw = audits.filterIt(it.kind != "theme and helpers").mapIt(it.raw).foldl(a + b, 0)
let totalTextHtml = audits.mapIt(it.textHtml).foldl(a + b, 0)
let totalStyle = audits.filterIt(it.kind != "theme and helpers").mapIt(it.style).foldl(a + b, 0)
let totalScript = audits.filterIt(it.kind != "theme and helpers").mapIt(it.script).foldl(a + b, 0)
let totalHex = audits.filterIt(it.kind != "theme and helpers").mapIt(it.hex).foldl(a + b, 0)
let pages = audits.filterIt(it.kind != "theme and helpers").len
let stylePages = audits.filterIt(it.kind != "theme and helpers" and it.style > 0).len

nbText: &"""
## How far it drifted

Every `.nim` file under `docs/` was read on 8 November 2026 (the numbers are kept as a dated
snapshot, so they stay what they were when this was written). Outside the theme, the
{pages} pages call `nbRawHtml` **{totalRaw}** times, write HTML tags inside **{totalTextHtml}**
`nbText` blocks, carry **{totalStyle}** `<style>` and **{totalScript}** `<script>` blocks of
their own, and write **{totalHex}** distinct hex colours between them.
"""

block:
  let d = tableData:
    file: audits.mapIt("`" & it.file & "`")
    kind: audits.mapIt(it.kind)
    raw: audits.mapIt(it.raw)
    textHtml: audits.mapIt(it.textHtml)
    style: audits.mapIt(it.style)
    script: audits.mapIt(it.script)
    inline: audits.mapIt(it.inline)
    hex: audits.mapIt(it.hex)
  let t = tabella(d, rownameCol = "file", groupnameCol = "kind"):
    tabHeader "HTML, CSS and colours in the pages", "per source file, on 8 November 2026"
    colsLabel {"raw": "nbRawHtml", "textHtml": "nbText with HTML", "style": "<style>",
               "script": "<script>", "inline": "style=", "hex": "hex colours"}
    fmtMarkdown "file"
    tabSourceNote md("Counted in the sources on 8 November 2026; snapshot in `devlog/data/blocks-review/audit.tsv`. The theme and its helpers may hold CSS: that is their job. `style=` counts inline styles.")
    optCssTheme()
  nbTable t

nbText: &"""
Three kinds of drift show up:

1. **Page furniture written by hand.** The kicker and lede at the top of nearly every page, the
   cards of the home page and the devlog, the galleries of three posts: the same HTML, copied.
2. **Styles and scripts per page.** {stylePages} pages carry a `<style>` block, and some carry a script,
   so a component looks slightly different on each page and can't be fixed in one place.
3. **Colours where they are used.** Hex values in pages and in table options, outside the palette
   (the design review counts the colours; here they are counted with everything else).

The new pages of this week's restructure (the Design Ref and the design review) are among the
worst: they were written fast, with HTML, which is the drift this post is about.

## The blocks that would replace it

Each recurring piece of HTML becomes a block with a name that says what it is. Here they are, from
the simplest to the most complex, with where they are used today:
"""

block:
  type B = object
    block_name, what, today, uses: string
  let bs = @[
    B(block_name: "nbTitolo(kicker, title, lede)", what: "the top of a page: what it is, its title, one paragraph", today: "`<p class=\"kicker\">`, `# title`, `<p class=\"lede\">` by hand", uses: "17 pages"),
    B(block_name: "nbNota(text, kind)", what: "a note with a meaning: info, done, missing, warning (with the triangle)", today: "`nbNota(text, color)` with a colour name", uses: "6 pages"),
    B(block_name: "nbCards: nbCard(title, href, text)", what: "a grid of cards that link to pages", today: "`<div class=\"cards\">` and notes by hand", uses: "home, devlog, Design Ref"),
    B(block_name: "nbIndice", what: "the table of contents", today: "a block already", uses: "most pages"),
    B(block_name: "nbTabs(python, r): body", what: "the same example in Nim, Python and R", today: "a template that renders blocks into a string", uses: "explainer, posts, book"),
    B(block_name: "nbShowCode: body", what: "tables with their code folded below", today: "new in the Milano Cortina post", uses: "1 post"),
    B(block_name: "nbBeside: body", what: "small tables side by side", today: "`<div class=\"affiancate\">` inside a gallery card", uses: "1 post"),
    B(block_name: "nbGalleria(label): nbScheda(title): body", what: "a row of cards to swipe, each any blocks", today: "a hand-made template with `nb.blocks.setLen` and HTML strings, per post", uses: "4 pages"),
    B(block_name: "nbTinte(tokens)", what: "colour swatches with names and uses", today: "`<ul>` of swatches with inline styles", uses: "palettes, Design Ref, design review"),
    B(block_name: "nbParti(t)", what: "a table with a button that shows its parts", today: "HTML, a button and a script on the home page", uses: "home"),
    B(block_name: "nbSpecs, nbPaletteSwitch, nbGrid", what: "the few interactive pieces: the specs filter, the palette picker, the tabellone grid", today: "`<script>` in the page", uses: "3 pages"),
  ]
  let d = tableData:
    block_name: bs.mapIt("`" & it.block_name & "`")
    what: bs.mapIt(it.what)
    today: bs.mapIt(it.today)
    uses: bs.mapIt(it.uses)
  let t = tabella(d, rownameCol = "block_name"):
    tabHeader "Blocks for tabelline's pages", "proposed names; nbIndice and nbTabs exist"
    colsLabel {"what": "what it shows", "today": "how it is done today", "uses": "where"}
    fmtMarkdown ["block_name", "today"]
    optCssTheme()
  nbTable t

nbText: """
## A first block, working

nimib makes a block with `newNbBlock`: a type with its fields and a `toHtml` that renders it. A
block that holds other blocks inherits from `NbContainer`, and `nb.withContainer` collects what
its body adds. So a gallery is two small blocks and two templates, in `docs/blocchi.nim` (the
name is provisional):

```nim
""" & readFile(docs / "devlog" / "data" / "blocks-review" / "blocchi.nim").split("\n").filterIt(not it.startsWith("##")).join("\n").strip & """

```

Here it is in use. The cards hold ordinary blocks: text, code that runs, a table. The page says
*a gallery of cards*, not how one is drawn:
"""

nbGalleria "three cards: swipe or scroll sideways":
  nbScheda "Text":
    nbText "A card holds any blocks. This one holds only text, written in Markdown."
  nbScheda "Code":
    nbText "Code runs where it is, and its output follows it."
    nbCode:
      echo 6 * 7
  nbScheda "A table":
    nbText "And a table made with tabelline."
    block:
      let d = tableData:
        tabellina: ["2 × 3", "4 × 5", "6 × 7"]
        risultato: [6, 20, 42]
      nbTable tabella(d, rownameCol = "tabellina")

nbText: """
The gallery of *Designing tabelline 0.1* does the same with a 25-line template that renders blocks
into a string of HTML, cuts them off the page (`nb.blocks.setLen`) and pastes the string back with
`nbRawHtml`; each post that wanted a gallery copied its CSS too. With the block, the CSS is in the
theme once, the cards are numbered by it, and the blocks inside stay blocks (a Markdown backend
could render them too).

## Where things should live

Three places, and a page uses them without knowing what is inside:

1. **A style module** (`docs/stile.nim`, say): every styling decision. The tokens of the design
   review as Nim constants, the CSS of both looks generated from them, the fonts. No colour and no
   CSS anywhere else, so changing a colour is one line.
2. **A blocks module** (`docs/blocchi.nim`, or `my.nim` as in your earlier projects): every
   custom block of the pages, each documented. Pages `import` it and use blocks only.
3. **Data modules**, as today (`piano.nim`, `mese.nim`): what a page shows, kept apart from how.

`docs/quaderno.nim` today mixes all three (the CSS, the blocks `nbIndice`, `nbTabs`, `nbNota`,
and the header): it would split into the first two. `nbRawHtml` stays for a true one-off, with a
comment that says why it is not a block.

Tables are the exception that proves the rule: they already are a block (`nbTable`), but their
colours come from `optQuaderno()` and from hex values in `tabStyle`. A table preset that reads the
tokens (the design review's choice 5) puts their colours in the style module too.

## The rules

For `AGENTS.md`, and for whoever writes the next page:

1. **A page uses blocks.** Markdown in `nbText`, nimib's blocks, `nbTable`, and the project's
   custom blocks. No HTML tags in `nbText`.
2. **Repeated HTML becomes a block** in the blocks module, the second time it is needed, not the
   third.
3. **No styles or colours in a page.** CSS and colours live in the style module; a page that needs
   a new look for something needs a new block, or a new token.
4. **`nbRawHtml` is a last resort**, for a one-off, with a comment saying why.
5. **CI counts the drift.** The audit above becomes a check (`tools/drift.nim`) that fails when a
   page adds HTML, a `<style>` or a colour outside the allowed list.

## A nimib skill against drift

Most of these pages were written by agents, quickly, and an agent reaches for HTML because it
knows HTML better than it knows nimib's block API. A nimib skill should change that default. What
it should say:

- **The decision, in order**: is there a nimib block for it? Is there one in the project's blocks
  module? If it will be needed again, make one with `newNbBlock`; only then `nbRawHtml`.
- **How a block is made**, with two short templates to copy: a leaf block (fields, `toHtml`) and a
  container block (`of NbContainer`, `withContainer`), like the gallery above.
- **Where its CSS goes**: the style module, using tokens, never a hex value.
- **A check to run**: a small script, like this page's audit, that lists HTML in `nbText`,
  `nbRawHtml` calls, `<style>` blocks and hex colours, so the agent sees its own drift before a PR.
- **Evals**: tasks such as "add a warning note", "add a gallery of three tables", "add a page of
  cards", graded on whether the result uses blocks and adds no raw HTML or colour.

The skill would start in your personal skills repository, as you suggest, and move to nimib (or
a nimib-land repository) once it has proved itself. The earlier nimib skills (closed nimib#264)
have a *custom blocks* reference to start from.

## Choices to make

1. **Names.** Blocks module `blocchi.nim` (Italian like `quaderno`, `piano`, `parti`) *or*
   `my.nim`; style module `stile.nim` *or* `tema.nim`. *Recommended: `blocchi.nim` and
   `stile.nim`.*
2. **The theme files.** `quaderno.nim` and `munari.nim` fold into `stile.nim` (both looks) and
   `blocchi.nim` (header, footer, blocks), *or* stay as they are with only the new modules added.
   *Recommended: fold them*: one place each for style and blocks.
3. **Posts.** Dated posts keep their words, but their code is migrated to blocks too, *or* they
   are left as they were written. *Recommended: migrate*: the code is not the post, and a post
   left with its own CSS breaks when the theme changes.
4. **The CI check.** Fails on new drift (with an allow list for the theme), *or* only reports.
   *Recommended: fail*, once the migration is done.

## What happens next

One PR, after this post and the design review are agreed: the style module with the tokens, the
blocks module with the blocks above, every page moved to them (the living documents first, then
the posts), the table preset, the drift check in CI, the rules in `AGENTS.md`, and the Design Ref
rewritten around the blocks: for each block, what it shows, when to use it, and how it looks in
both looks. The skill is drafted alongside, in your skills repository.

## How it is built

The audit read every `.nim` file under `docs/` and counted, per file: calls of `nbRawHtml`;
`nbText` blocks whose triple-quoted text holds an HTML tag (`<div`, `<p`, `<span`, `<a href`, …);
`<style` and `<script`; inline `style="`; and distinct `#RRGGBB` values. Files are grouped as
living documents, posts, or theme and helpers (where CSS belongs); data modules are left out. It
ran once and was saved as `docs/devlog/data/blocks-review/audit.tsv`: the post is dated, so its
numbers stay those of 8 November 2026 while the pages are migrated (the live count will be a
check in CI, `tools/drift.nim`, that reads the pages every time). The
code of `docs/blocchi.nim` above is the module as it was on 8 November 2026, kept in
`docs/devlog/data/blocks-review/blocchi.nim`: the blocks module has grown since, and the gallery
is drawn with the same two blocks.
"""
nbSave
