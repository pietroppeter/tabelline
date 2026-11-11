## The API reference, docs/api/index.html: every name tabelline exports, from the source. Kept up
## to date, not a dated post: CI rebuilds it on every push.
##
## The names, kinds, signatures and lines come from `nim jsondoc`, the doc comments and the
## sections from the source (tools/apidoc.nim); the examples are the specs' (tools/specexamples.nim),
## run while the page builds; gt's and Great Tables' names are checked against their reference
## indexes (docs/coverage/references.json, written by tools/references.nim).
import std/[os, strutils, json, sequtils, strformat, sets, tables, re]
import nimib
import tabelline, tabelline/nimib
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
const knownOrder = [
  ("tabelline", "Making a table", "`import tabelline` brings every module below but the last two."),
  ("tabelline/verbs", "The verbs", ""),
  ("tabelline/formats", "Formats", ""),
  ("tabelline/units", "Units", ""),
  ("tabelline/localize", "Locales", ""),
  ("tabelline/colors", "Colours", ""),
  ("tabelline/pictures", "Pictures", ""),
  ("tabelline/nanoplots", "Nanoplots", ""),
  ("tabelline/core", "Data, text and selectors", ""),
  ("tabelline/build", "Building a table", ""),
  ("tabelline/render_html", "HTML", ""),
  ("tabelline/render_text", "Text and Markdown", ""),
  ("tabelline/extract", "Reading a table back", ""),
  ("tabelline/datasets", "Datasets", "`import tabelline/datasets`: small tables for examples."),
  ("tabelline/nimib", "In nimib", "`import tabelline/nimib`: tables in a nimib notebook."),
]

# a module not listed yet goes at the end, under its own name
var order = @knownOrder
for m in api:
  if not knownOrder.anyIt(it[0] == m.name): order.add (m.name, m.name, "")

func sectionTitle(s: string): string =
  ## The source's section names are short (`cols`); the page spells some out.
  case s
  of "": ""
  of "cols": "Columns"
  of "dataColor": "Colour from the data"
  else: s[0].toUpperAscii & s[1 .. ^1]

# gt's and Great Tables' reference pages (tools/references.nim): a name links to its
# counterpart only when that page exists
let refs = parseJson(readFile(docs / "coverage" / "references.json"))
let gtRef = refs["gt"]["names"].getElems.mapIt(it.getStr).toHashSet
let greatTablesRef = refs["greatTables"]["names"].getElems.mapIt(it.getStr).toHashSet

func snake(name: string): string =
  for c in name:
    if c.isUpperAscii: result.add '_' & c.toLowerAscii
    else: result.add c

# tabelline's own names, from the feature map's table "Not from gt"
var ownNames = initHashSet[string]()
for l in readFile(docs / "coverage.nim").splitLines:
  if l.strip.startsWith("N(what:"):
    for m in l.findAll(re"`(\w+)`"): ownNames.incl m.strip(chars = {'`'})

proc counterparts(m: ApiModule, s: ApiSymbol): seq[ApiLink] =
  ## gt's and Great Tables' names for the same thing, linked to their reference pages; for a
  ## name of tabelline's own, the feature map's table Not from gt.
  if s.kind notin ["proc", "func", "template", "macro"]: return
  let sn = snake(s.name)
  var r = sn
  var py = @["GT." & sn, sn]
  if s.section == "locations" and m.name == "tabelline/verbs":   # loc.body(): cells_body(), loc.body()
    r = "cells_" & sn
    py = @["loc." & sn]
  elif s.section == "styles" and m.name == "tabelline/core":     # style.fill(): cell_fill(), style.fill()
    r = "cell_" & sn
    py = @["style." & sn]
  if r in gtRef:
    result.add ApiLink(label: "gt", text: &"`{r}()`", href: &"https://gt.rstudio.com/reference/{r}.html")
  for p in py:
    if p in greatTablesRef:
      result.add ApiLink(label: "Great Tables", text: &"`{p}()`",
                         href: &"https://posit-dev.github.io/great-tables/reference/{p}.html")
      break
  if result.len == 0 and s.name in ownNames:
    result.add ApiLink(label: "tabelline's own:", text: "Not from gt", href: "../coverage/#not-from-gt")

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

# anchors: `module-name` (`verbs-tabHeader`), stable for links from outside; the first name in
# reading order also answers to its plain name (`#tabHeader`), for links that read well
proc anchorOf(m: ApiModule, s: ApiSymbol): string =
  ## An operator is spelled by its characters' codes: `&` is `core-op26`.
  let name = if s.name.allCharsInSet(IdentChars): s.name else: "op" & s.name.mapIt(it.ord.toHex(2)).join
  m.name.lastPathPart & "-" & name
var anchors = initTable[string, string]()  # plain name -> the anchor it stands for
var aliasOf = initTable[string, string]()  # anchor -> its plain name, when it has one
var headingIds = ["modules", "how-it-is-built", "indice"].toHashSet  # a name must not take a heading's id
for (module, title, _) in order:
  headingIds.incl slugify(title)
  for m in api:
    if m.name == module:
      for s in m.symbols: headingIds.incl slugify(sectionTitle(s.section))
for (module, _, _) in order:
  for m in api:
    if m.name != module: continue
    for s in m.symbols:
      if s.name notin anchors and s.name.allCharsInSet(IdentChars) and s.name notin headingIds:
        anchors[s.name] = anchorOf(m, s)
        aliasOf[anchorOf(m, s)] = s.name

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
the [specs](../specs/)' examples uses it, that example and the table it makes. A name that gt or
Great Tables has too links to their reference pages; a name that is tabelline's own links to
[Not from gt](../coverage/#not-from-gt).
**{documented} of {total}** names have a doc comment so far; the others say so.

Start from the [Guide](../explainer/) to learn tabelline: this page is for looking a name up.
"""
nbNote("""
Every name has a link of its own, the **#** beside it: the module and the name, such as
[`api/#verbs-tabHeader`](#verbs-tabHeader), which stays the same when the API grows. The plain
name works too, [`api/#tabHeader`](#tabHeader), for the first name of that spelling on the page.
Modules and sections are linked by their headings, such as [`api/#formats`](#formats).
""", nkInfo, "Links to a name, for people and agents")
nbToc

# ------------------------------------------------------------------------------------ the modules

nbText: """
## Modules

What each module is for, then what it imports: from tabelline, and from Nim's standard library.
Only `tabelline/nimib` needs a package from outside, nimib.
"""

func firstSentence(doc: string): string =
  let p = doc.split("\n\n")[0].replace("\n", " ")
  let k = p.find(". ")
  result = if k >= 0: p[0 .. k] else: p
  if result.startsWith("tabelline: "): result = result[11 .. ^1].capitalizeAscii

block:
  type
    ModuleRow = object
      module, what: string
      names: int
    ImportRow = object
      module, imports, importedBy, std: string
  func short(name: string): string = name.replace("tabelline/", "")
  proc link(name: string): string =
    for (module, title, _) in order:
      if module == name: return &"[{short(name)}](#{slugify(title)})"
    short(name)
  var rows: seq[ModuleRow]
  var deps: seq[ImportRow]
  for (module, title, _) in order:
    let m = api.filterIt(it.name == module)[0]
    let own = m.imports.filterIt(it == "tabelline" or it.startsWith("tabelline/"))
    rows.add ModuleRow(module: link(module), what: firstSentence(m.doc), names: m.symbols.len)
    deps.add ImportRow(module: link(module),
                       imports: own.mapIt(if it.lastPathPart in dataOnly: short(it) & " (data)" else: link(it)).join(", "),
                       importedBy: api.filterIt(module in it.imports).mapIt(link(it.name)).join(", "),
                       std: m.imports.filterIt(it.startsWith("std/") or it.startsWith("pkg/"))
                              .mapIt(it.replace("std/", "")).join(", "))
  let t = tabella(rows):
    tabHeader "The modules", "in the order of this page"
    colsLabel:
      module: "module"
      what: "what it is"
      names: "names"
    fmtMarkdown ["module", "what"]
    optCssTheme()
  nbTable t
  let d = tabella(deps):
    tabHeader "What each module imports", "and what imports it"
    colsLabel:
      module: "module"
      imports: "from tabelline"
      importedBy: "imported by"
      std: "from Nim"
    fmtMarkdown ["module", "imports", "importedBy"]
    tabSourceNote "From Nim: modules of the standard library (std/), and pkg/nimib, the one package outside it."
    tabOptions(tableFontSize = "14px")
    optCssTheme()
  nbTable d

for (module, title, intro) in order:
  let m = api.filterIt(it.name == module)[0]
  nbText: &"## {title}"
  var head = &"`{module}` · [{m.path}]({repoUrl}/blob/main/{m.path})"
  if intro.len > 0: head.add " · " & intro
  nbText: head & "\n\n" & linked(firstSentence(m.doc))
  let documented = m.symbols.countIt(it.doc.len > 0)
  nbFold(&"{m.symbols.len} names, {documented} with a doc comment"):
    # the module's doc comment, after the sentence already shown above the fold
    let docText = m.doc.strip
    let rest = if m.name == "tabelline": docText
               else: docText[min(firstSentence(docText).len, docText.len) .. ^1].strip
    if rest.len > 0:
      nbText linked(rest)
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
        for l in counterparts(m, s): links.add l
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
        nbApi s.name, anchorOf(m, s), aliasOf.getOrDefault(anchorOf(m, s)), s.kind, sigs, linked(s.doc), links, exCode, exHtml

nbText: """
## How it is built

The page is a nimib notebook, `docs/api.nim`, like every page of the site. Its data comes from
four places:

1. **`nim jsondoc`**, run on each module by `tools/apidoc.nim`: every exported name, its kind, its
   signature as Nim prints it (here without the effects Nim inferred, `raises` and `tags`), and
   its line. The JSON is kept in `nimcache/apidoc/` until a source file changes.
2. **The source**: each name's doc comment, as written (Markdown), and its section, the
   `# ---- name` line above it. jsondoc has the doc comments too, but rendered as
   reStructuredText, which reads `*`, `|` and backticks its own way.
3. **The specs**: the shortest example that uses a name, run while the page builds
   (`tools/specexamples.nim`).
4. **gt's and Great Tables' reference indexes**, read from their repositories by
   `tools/references.nim` into `docs/coverage/references.json`: `tabHeader` is `tab_header()` in
   gt and `GT.tab_header()` in Great Tables, `loc.body()` is `cells_body()` and `loc.body()`,
   and a name links to a page only when the index has it.

Each entry is one block, `nbApi` (in `docs/blocks.nim`), so the page has no HTML of its own.
`nim r tools/apidoc.nim` prints the same data as JSON, for an agent or another page.
"""

nbSave
