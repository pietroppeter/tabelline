## The API reference, docs/api/index.html: every name tabelline exports, from the source. Kept up
## to date, not a dated post: CI rebuilds it on every push.
##
## The names, kinds, signatures and lines come from `nim jsondoc`, the doc comments and the
## sections from the source (tools/apidoc.nim); the examples are the specs' (tools/specexamples.nim),
## run while the page builds; gt's names come from the feature map (docs/coverage/gt.json).
import std/[os, strutils, json, sequtils, strformat, sets, tables, re]
import nimib
import blocks
import ../tools/[apidoc, specexamples]

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "api" / "index.html"
nb.useTabelline(section = "Reference", cadence = "kept up to date",
               title = "tabelline reference", homeHref = "../",
               description = "Every name tabelline exports: signatures, doc comments, examples that run.")

# ------------------------------------------------------------------------------------- the data

let api = apiReference()

# The modules in the order a reader meets them: the macro that makes a table, the verbs, what
# they take (formats, units, colours, locales), what a table is made of, and the output.
const order = [
  ("tabelline", "Making a table", "`import tabelline` brings every module below but the last two."),
  ("tabelline/verbs", "The verbs", ""),
  ("tabelline/formats", "Formats", ""),
  ("tabelline/units", "Units", ""),
  ("tabelline/localize", "Locales", ""),
  ("tabelline/colors", "Colours", ""),
  ("tabelline/core", "Data, text and selectors", ""),
  ("tabelline/build", "Building a table", ""),
  ("tabelline/render_html", "HTML", ""),
  ("tabelline/render_text", "Text and Markdown", ""),
  ("tabelline/extract", "Reading a table back", ""),
  ("tabelline/datasets", "Datasets", "`import tabelline/datasets`: small tables for examples."),
  ("tabelline/nimib", "In nimib", "`import tabelline/nimib`: tables in a nimib notebook."),
]

func sectionTitle(s: string): string =
  ## The source's section names are short (`cols`); the page spells some out.
  case s
  of "": ""
  of "cols": "Columns"
  of "dataColor": "Colour from the data"
  else: s[0].toUpperAscii & s[1 .. ^1]

# gt's names, from the feature map: `tab_header()` is `tabHeader`
let coverage = parseJson(readFile(docs / "coverage" / "gt.json"))
var gtNames = initTable[string, string]()   # snake name -> where ("R", "Py", "both")
for a in coverage["areas"]:
  for r in a["rows"]:
    for part in r["gt"].getStr.split(", "):
      let p = part.strip
      if p.endsWith("()") and p.len > 2 and p[0] in {'a'..'z'}:
        gtNames[p[0 .. ^3]] = r{"where"}.getStr("both")

func snake(name: string): string =
  for c in name:
    if c.isUpperAscii: result.add '_' & c.toLowerAscii
    else: result.add c

# tabelline's own names, from the feature map's table "Not from gt"
var ownNames = initHashSet[string]()
for l in readFile(docs / "coverage.nim").splitLines:
  if l.strip.startsWith("N(what:"):
    for m in l.findAll(re"`(\w+)`"): ownNames.incl m.strip(chars = {'`'})

# an example for each verb: the shortest spec example that uses it, run now
let examples = collect()
let results = run(examples)
proc exampleFor(name: string): int =
  result = -1
  if name.len < 4 or not name.allCharsInSet(IdentChars): return
  let word = re("\\b" & name & "\\b")
  for k, ex in examples:
    if results[k]["ok"].getBool and results[k]["html"].len > 0 and ex.code.contains(word):
      if result < 0 or ex.code.len < examples[result].code.len: result = k

# anchors: the name, or kind-name when two symbols share it
var seen = initCountTable[string]()
for m in api:
  for s in m.symbols: seen.inc s.name.toLowerAscii
proc anchorOf(m: ApiModule, s: ApiSymbol): string =
  if seen[s.name.toLowerAscii] > 1: m.name.lastPathPart & "-" & s.name else: s.name
var anchors = initTable[string, string]()  # name -> anchor of its first symbol
for m in api:
  for s in m.symbols:
    if s.name notin anchors: anchors[s.name] = anchorOf(m, s)

func phoneSignature(sig: string): string =
  ## A signature that fits a phone: Nim wraps at 80 columns, so a long one goes one argument per
  ## line instead, like a long call in the docs.
  let flat = sig.splitLines.mapIt(it.strip).join(" ")
  if flat.len <= 40: return flat
  # the argument list: the first `(` outside brackets, and its `)`
  var depth = 0
  var open, close = -1
  for i, c in flat:
    case c
    of '[': inc depth
    of ']': dec depth
    of '(':
      if depth == 0 and open < 0: open = i
      inc depth
    of ')':
      dec depth
      if depth == 0 and open >= 0 and close < 0: close = i
    else: discard
  if open < 0 or close < 0: return sig
  var args: seq[string]
  var cur = ""
  depth = 0
  for c in flat[open + 1 ..< close]:
    if c in {'(', '['}: inc depth
    elif c in {')', ']'}: dec depth
    if c == ';' and depth == 0:
      args.add cur.strip
      cur = ""
    else: cur.add c
  if cur.strip.len > 0: args.add cur.strip
  if args.len == 0: return flat
  flat[0 .. open] & "\n" & args.mapIt("    " & it).join(",\n") & "\n" & flat[close .. ^1]

proc linked(md: string): string =
  result = ""
  var i = 0
  while i < md.len:
    if md[i] == '`' and (i == 0 or md[i - 1] != '`'):
      let j = md.find('`', i + 1)
      if j > i:
        let inner = md[i + 1 ..< j]
        if inner in anchors and (j + 1 >= md.len or md[j + 1] != '`'):
          result.add &"[`{inner}`](#{anchors[inner]})"
          i = j + 1
          continue
    result.add md[i]
    inc i

var total, documented = 0
for m in api:
  total += m.symbols.len
  documented += m.symbols.countIt(it.doc.len > 0)

# ------------------------------------------------------------------------------------- the page

nbTitle "Reference · rebuilt on every push", "Every name tabelline exports", &"""
{total} names in {api.len} modules: the signature of each, its doc comment, and an example
that ran when this page was built.
"""

nbText: &"""
This page is made from the source. Each entry says what kind of name it is (a proc, a template,
a macro, a type), shows its signatures (one for each overload), its doc comment, and, when one of
the [specs](../specs/)' examples uses it, that example and the table it makes. A name from gt
links to gt's own page; a name that is tabelline's own links to [Not from gt](../coverage/#not-from-gt).
**{documented} of {total}** names have a doc comment so far; the others say so.

Start from the [Guide](../explainer/) to learn tabelline: this page is for looking a name up.
"""
nbToc

for (module, title, intro) in order:
  let m = api.filterIt(it.name == module)[0]
  nbText: &"## {title}"
  var head = &"`{module}` · [{m.path}]({repoUrl}/blob/main/{m.path})"
  if intro.len > 0: head.add " · " & intro
  nbText: head
  if m.doc.len > 0: nbText: linked(m.doc)
  # sections in the order of the source
  var sections: seq[string]
  for s in m.symbols:
    if s.section notin sections: sections.add s.section
  for sec in sections:
    let syms = m.symbols.filterIt(it.section == sec)
    if sec.len > 0 and sections.len > 1:
      nbText: &"### {sectionTitle(sec)}"
    if syms.len > 3:
      nbText: syms.mapIt(&"[`{it.name}`](#{anchorOf(m, it)})").deduplicate.join(" · ")
    for s in syms:
      var links: seq[ApiLink]
      let sn = snake(s.name)
      if sn in gtNames and s.kind in ["proc", "func", "template", "macro"]:
        let w = gtNames[sn]
        if w == "Py":
          links.add ApiLink(label: "Great Tables", text: &"`GT.{sn}()`",
                            href: &"https://posit-dev.github.io/great-tables/reference/GT.{sn}.html")
        else:
          links.add ApiLink(label: "gt", text: &"`{sn}()`", href: &"https://gt.rstudio.com/reference/{sn}.html")
      elif s.name in ownNames:
        links.add ApiLink(label: "tabelline's own:", text: "Not from gt", href: "../coverage/#not-from-gt")
      links.add ApiLink(label: "source", text: &"`{m.path.lastPathPart}:{s.lines[0]}`",
                        href: &"{repoUrl}/blob/main/{m.path}#L{s.lines[0]}")
      var exCode, exHtml = ""
      if s.kind in ["proc", "func", "template", "macro"]:
        let k = exampleFor(s.name)
        if k >= 0:
          exCode = examples[k].code
          exHtml = results[k]["html"].getElems.mapIt(it.getStr).join
          links.add ApiLink(label: "spec", text: examples[k].capability,
                            href: &"../specs/?spec={examples[k].capability}")
      let sigs = if s.kind in ["type", "const"]: s.signatures else: s.signatures.mapIt(phoneSignature(it))
      nbApi s.name, anchorOf(m, s), s.kind, sigs, linked(s.doc), links, exCode, exHtml

nbText: """
## How it is built

The page is a nimib notebook, `docs/api.nim`, like every page of the site. Its data comes from
three places:

1. **`nim jsondoc`**, run on each module by `tools/apidoc.nim`: every exported name, its kind, its
   signature as Nim prints it (here without the effects Nim inferred, `raises` and `tags`), and
   its line. The JSON is kept in `nimcache/apidoc/` until a source file changes.
2. **The source**: each name's doc comment, as written (Markdown), and its section, the
   `# ---- name` line above it. jsondoc has the doc comments too, but rendered as
   reStructuredText, which reads `*`, `|` and backticks its own way.
3. **The specs**: the shortest example that uses a name, run while the page builds
   (`tools/specexamples.nim`), and the feature map for gt's names.

Each entry is one block, `nbApi` (in `docs/blocks.nim`), so the page has no HTML of its own.
`nim r tools/apidoc.nim` prints the same data as JSON, for an agent or another page.
"""

nbSave
