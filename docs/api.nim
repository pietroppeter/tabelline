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

# The modules from the most fundamental to the one that brings them all: a module comes after
# every module it imports (`dependencyOrder`), and among those that could come next, in the order
# of this list, which also gives each its heading.
const knownOrder = [
  ("tabelline/core", "Data, text and selectors", ""),
  ("tabelline/colors", "Colours", ""),
  ("tabelline/localize", "Locales", ""),
  ("tabelline/formats", "Formats", ""),
  ("tabelline/units", "Units", ""),
  ("tabelline/verbs", "The verbs", ""),
  ("tabelline/build", "Building a table", ""),
  ("tabelline/render_html", "HTML", ""),
  ("tabelline/render_text", "Text and Markdown", ""),
  ("tabelline/extract", "Reading a table back", ""),
  ("tabelline/pictures", "Pictures", ""),
  ("tabelline/nanoplots", "Nanoplots", ""),
  ("tabelline", "Everything at once", "`import tabelline` brings every module above."),
  ("tabelline/datasets", "Datasets", "`import tabelline/datasets`: small tables for examples."),
  ("tabelline/nimib", "In nimib", "`import tabelline/nimib`: tables in a nimib notebook."),
  ("tabelline/nanuq", "From nanuq", "`import tabelline/nanuq`: a table from a nanuq (Polars) DataFrame."),
]

# a module not listed yet goes at the end of the list, under its own name
var listed = @knownOrder
for m in api:
  if not knownOrder.anyIt(it[0] == m.name): listed.add (m.name, m.name, "")

proc dependencyOrder(listed: seq[(string, string, string)]): seq[(string, string, string)] =
  ## Each module after the modules it imports (the data modules are not on the page); among the
  ## modules whose imports are all placed, the first in `listed`.
  var left = listed
  while left.len > 0:
    var k = 0
    while k < left.len:
      let m = api.filterIt(it.name == left[k][0])[0]
      var waiting = false
      for imp in m.imports:
        if imp != m.name and left.anyIt(it[0] == imp): waiting = true
      if not waiting: break
      inc k
    if k == left.len: k = 0   # a cycle: take the first
    result.add left[k]
    left.delete k

let order = dependencyOrder(listed)

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
var headingIds = ["modules", "reading-a-signature", "how-it-is-built", "indice"].toHashSet  # a name must not take a heading's id
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
nbPart 1, "", prPrimary

# ------------------------------------------------------------------------------------ the modules

nbText: """
## Modules

What each module is for, what it exports, and what it imports: from tabelline, and from Nim's
standard library. Only two need a package from outside: `tabelline/nimib` needs nimib, and
`tabelline/nanuq` needs nanuq.
"""

func firstSentence(doc: string): string =
  let p = doc.split("\n\n")[0].replace("\n", " ")
  let k = p.find(". ")
  result = if k >= 0: p[0 .. k] else: p
  if result.startsWith("tabelline: "): result = result[11 .. ^1].capitalizeAscii

func short(name: string): string = name.replace("tabelline/", "")
proc moduleLink(name: string): string =
  for (module, title, _) in order:
    if module == name: return &"[{short(name)}](#{slugify(title)})"
  short(name)

func kindsOf(m: ApiModule): string =
  ## What a module exports, by kind: "41 procs, 20 types, 2 consts".
  var counts: seq[(string, int)]
  for s in m.symbols:
    var found = false
    for c in counts.mitems:
      if c[0] == s.kind: (inc c[1]; found = true)
    if not found: counts.add (s.kind, 1)
  counts.mapIt(&"{it[1]} {it[0]}" & (if it[1] > 1: "s" else: "")).join(", ")

proc linkedGroups(t: sink Tabella, rowGroup: seq[string], labels, anchors: seq[string]): Tabella =
  ## Row groups whose labels link to a heading of the page: rows whose `rowGroup` is `labels[k]`
  ## go in a group labelled with a link to `#anchors[k]`.
  result = t
  for k, label in labels:
    var rows: seq[int]
    for i, g in rowGroup:
      if g == label: rows.add i
    if rows.len > 0:
      result = result.tabRowGroup(md(&"[{label}](#{anchors[k]})"), rows = rows, id = label)

block:
  # one group per module, the facts as rows: a table a phone reads down
  type ModuleFact = object
    module, fact, value: string
  var facts: seq[ModuleFact]
  for (module, title, _) in order:
    let m = api.filterIt(it.name == module)[0]
    let own = m.imports.filterIt(it == "tabelline" or it.startsWith("tabelline/"))
    let users = api.filterIt(module in it.imports).mapIt(moduleLink(it.name))
    let other = m.imports.filterIt(it.startsWith("std/") or it.startsWith("pkg/")).mapIt(it.replace("std/", ""))
    let g = "tabelline" & (if module == "tabelline": "" else: "/" & short(module))
    facts.add ModuleFact(module: g, fact: "what it is", value: firstSentence(m.doc))
    facts.add ModuleFact(module: g, fact: "exports",
                         value: &"[{m.symbols.len} names](#{slugify(title)}): {kindsOf(m)}")
    facts.add ModuleFact(module: g, fact: "exports again",
                         value: m.reexports.mapIt(if it.startsWith("std/"): it else: moduleLink(it)).join(", "))
    facts.add ModuleFact(module: g, fact: "imports",
                         value: own.mapIt(if it.lastPathPart in dataOnly: short(it) & " (data)" else: moduleLink(it)).join(", "))
    facts.add ModuleFact(module: g, fact: "imported by", value: users.join(", "))
    facts.add ModuleFact(module: g, fact: "from Nim", value: other.join(", "))
  for f in facts.mitems:
    if f.value.len == 0: f.value = "—"
  var t = tabella(facts, rownameCol = "fact"):
    colsHide "module"
    tabHeader "The modules", "each after the modules it imports, as on this page"
    colsLabel:
      value: ""
    fmtMarkdown "value"
    tabSourceNote "From Nim: modules of the standard library, and pkg/nimib, the one package from outside. (data): a module of CLDR tables, not documented here."
    optCssTheme()
  t = t.linkedGroups(facts.mapIt(it.module), order.mapIt("tabelline" & (if it[0] == "tabelline": "" else: "/" & short(it[0]))),
                     order.mapIt(slugify(it[1])))
  nbTable t

# ----------------------------------------------------------------------------- reading a signature
# The signatures are what Nim sees; a table is written with tabelline's sugar, which leaves out
# part of them. What the sugar does, and the few words of Nim a signature uses, counted live.

nbText: """
## Reading a signature

A signature here is what Nim sees, and it is not always what you write. tabelline has some
sugar, and it changes how a signature reads:

- **A verb inside `tabella(data): body` drops its table.** Every verb takes the table first and
  returns the new one:

  ```nim
  proc tabHeader(
      t: sink Tabella,
      title: Text,
      subtitle: Text = toText("")
  ): Tabella
  ```

  In the body of [`tabella`](#tabelline-tabella), the macro passes the table in and takes the
  result back: `tabHeader "Title", "Subtitle"` stands for `t = t.tabHeader("Title", "Subtitle")`.
  So in a body, read a verb's signature from its second argument, and ignore what it returns.
- **A list of pairs can be a block.** The verbs whose first argument is a list of pairs
  (`colsLabel`, `colsWidth`, `colsUnits`, `textCaseMatch`, `summaryRows`, `grandSummaryRows`,
  `summaryColumns`) also take it as an indented block, one `label: value` per line, and any verb
  takes `name = value` lines as named arguments.
- **[`tabOptions`](#tabOptions) is a macro.** Its signature says `varargs[untyped]`: it takes
  any field of [`TabOptions`](#TabOptions) by name, `rowStriping = true`, checked when compiling.
- **Converters fill in the types.** An argument of type [`Text`](#Text) takes a plain string
  ([`toText`](#toText)); a [`ColSel`](#ColSel), a column's name or a list of names
  ([`toColSel`](#toColSel)); a [`RowSel`](#RowSel), a row, a list or a range of rows
  ([`toRowSel`](#toRowSel)), or [`where`](#where) with a condition on `it`. A cell's
  [`Value`](#Value) comes from a number, a text or a date, a list from a `seq`, and a record
  from an object or a named tuple ([`toValue`](#toValue)); [`list`](#list) and
  [`record`](#record) make them by hand.
- **The dot reads by name.** `it.mass` is `it["mass"]` on a [`Row`](#Row), and `v.x` is
  `v["x"]` on a record: a template `` `.` `` under Nim's experimental `dotOperators`, which the
  compiler calls only when the name is not a field or a proc. So a name the type already has
  (`kind`, `len`) is that, and a keyword (`type`) needs brackets.

Beside types, a signature uses a few words of Nim. The one you meet most is `sink`, on the table
every verb takes. It tells Nim that the proc takes ownership of the value: when the caller does
not use it again, as in a chain or a `tabella` body, Nim moves it instead of copying it; when the
caller does, Nim copies it. The code means the same either way, and you never write `sink`
yourself.

`sink` and `lent` are Nim's *move semantics* annotations (the manual speaks of sink parameters,
and of `lent` as a borrowed result). They come from the same idea as Rust's ownership and
borrowing, but as an opt-in: Rust's borrow checker rejects code that uses a value after giving it
away, while Nim, which manages memory for you, takes these words as permission to move a value
instead of copying it. Where it cannot move, it copies, so the code compiles either way: the
compiler gets to optimise, and you never fight it. `var` marks a parameter the proc may change;
`openArray`, `varargs` and `static` are something else, types made for parameters. The
[guide](../explainer/#the-spec) has a note on `sink` too.
"""

block:
  type Word = object
    word, means, uses: string
  let words = @[
    ("sink", "tabHeader", "takes ownership of the argument: moved when the caller is done with it, copied otherwise; you write nothing"),
    ("lent", "[]", "returns a value borrowed from the argument, without a copy, which you cannot change"),
    ("var", "table", "can change the argument, which must be a variable"),
    ("openArray", "interpolate", "takes an array or a seq"),
    ("varargs", "tabella", "takes any number of arguments; in a macro, `varargs[untyped]` takes code"),
    ("static", "toColSel", "a value known when compiling, such as the length of an array"),
  ]
  var rows: seq[Word]
  for (w, example, means) in words:
    var n = 0
    var first = ""
    for (module, _, _) in order:
      for m in api:
        if m.name != module: continue
        for sym in m.symbols:
          if sym.signatures.anyIt(it.contains(re("\\b" & w & "[ \\[]"))):
            inc n
            if sym.name == example: first = "[`" & sym.name & "`](#" & anchorOf(m, sym) & ")"
    doAssert n == 0 or first.len > 0, w & ": no " & example & " among the names that use it"
    rows.add Word(word: "`" & w & "`", means: means,
                  uses: if n == 0: "—" else: $n & (if n == 1: " name: " else: " names, such as ") & first)
  var t = tabella(rows, rownameCol = "word"):
    tabHeader "The words of Nim in a signature"
    colsLabel:
      means: "what it means"
      uses: "on this page"
    fmtMarkdown columns = ["word", "means", "uses"]
    tabStyle style.css("white-space: nowrap"), loc.stub()
    optCssTheme()
  nbTable t

nbPart 2, "", prSecondary
for (module, title, intro) in order:
  let m = api.filterIt(it.name == module)[0]
  nbText: &"## {title}"
  var head = &"`{module}` · [{m.path}]({repoUrl}/blob/main/{m.path})"
  if intro.len > 0: head.add " · " & intro
  nbText: head & "\n\n" & linked(firstSentence(m.doc))
  block:
    # every name the module exports, with its kind, grouped by the source's sections
    type NameRow = object
      section, name, kind: string
    var sectionsSeen: seq[string]
    for s in m.symbols:
      if s.section notin sectionsSeen: sectionsSeen.add s.section
    let grouped = sectionsSeen.len > 1
    var names: seq[NameRow]
    for sec in sectionsSeen:
      for s in m.symbols.filterIt(it.section == sec):
        let n = if s.signatures.len > 1: &" ×{s.signatures.len}" else: ""
        names.add NameRow(section: sectionTitle(sec), name: &"[`{s.name}`](#{anchorOf(m, s)})", kind: s.kind & n)
    var t = tabella(names):
      colsHide "section"
      fmtMarkdown "name"
      tabSourceNote "×3: three overloads. A name opens its entry below."
      optVerticalPadding(scale = 0.4)
      tabOptions(tableFontSize = "15px", tableWidth = "100%")
      optCssTheme()
    if grouped:
      t = t.linkedGroups(names.mapIt(it.section), sectionsSeen.mapIt(sectionTitle(it)),
                         sectionsSeen.mapIt(slugify(sectionTitle(it))))
    nbTable t
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

nbPart 3, "", prSuccess
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
