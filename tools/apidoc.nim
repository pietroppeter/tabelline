## The API of tabelline as data, for the reference page (docs/api.nim) and for agents.
##
## `nim jsondoc` gives every exported symbol of a module: its kind, its signature as Nim prints
## it, its line. The doc comments come from the source instead, as they are written (Markdown),
## because jsondoc renders them as reStructuredText, which reads `*`, `` ` `` and `|` its own way.
## The source also gives each symbol its section: the `# ---- name` line above it.
##
##   nim r tools/apidoc.nim            # prints the API as JSON
##   nim r tools/apidoc.nim --summary  # one line per module: symbols, documented
##
## Each module is compiled once by `nim jsondoc` (a second or two), and the JSON is kept in
## nimcache/apidoc/ until a source file changes. Not `--project`, which would
## include locales.nim, only data: on it, Nim 2.2.4's docgen stops with a RangeDefect (a const of
## 150 000 characters); Nim 2.4 does not.

import std/[os, osproc, json, strutils, sequtils, hashes, tables]

type
  ApiSymbol* = object
    name*, kind*: string        ## kind: proc, func, template, macro, type, const, converter, iterator
    signatures*: seq[string]    ## one per overload, as Nim prints it, without the effect pragmas
    doc*: string                ## the doc comment of the first overload that has one, Markdown
    lines*: seq[int]            ## line of each overload in the module's source
    section*: string            ## the `# ---- name` line above the first overload
  ApiModule* = object
    name*, path*: string        ## path: relative to the repository root
    doc*: string                ## the module's doc comment, Markdown
    imports*: seq[string]       ## what it imports: `std/strutils`, `pkg/nimib`, `tabelline/core`
    symbols*: seq[ApiSymbol]

let root* = currentSourcePath().parentDir.parentDir

const dataOnly* = ["locales", "countries", "currencies"]
  ## Modules that hold only data (CLDR tables), left out: a user never imports them.

proc modules*(): seq[string] =
  ## Every module a user imports: `tabelline` and src/tabelline/*.nim but the data.
  result = @["tabelline"]
  for f in walkFiles(root / "src" / "tabelline" / "*.nim"):
    let n = f.splitFile.name
    if n notin dataOnly: result.add "tabelline/" & n

func importsOf(lines: seq[string], module: string): seq[string] =
  ## The modules named by the `import` and `from ... import` lines at the top level, written
  ## in full: `import core` in tabelline/verbs is `tabelline/core`.
  var stmts: seq[string]
  var i = 0
  while i < lines.len:
    let l = lines[i]
    if l.startsWith("import ") or l.startsWith("from "):
      var st = l
      while st.strip.endsWith(",") and i + 1 < lines.len:
        inc i
        st.add " " & lines[i].strip
      stmts.add st
    inc i
  let dir = if "/" in module: module.parentDir else: "tabelline"
  for st in stmts:
    var body = if st.startsWith("from "): st[5 .. ^1].split(" import ")[0] else: st[7 .. ^1]
    body = body.split(" except ")[0]
    var items: seq[string]
    let br = body.find('[')
    if br >= 0:
      let prefix = body[0 ..< br].strip
      for x in body[br + 1 ..< body.rfind(']')].split(","):
        items.add prefix & x.strip
    else:
      for x in body.split(","): items.add x.strip
    for it in items:
      let it = it.strip
      if it.len == 0: continue
      let full =
        if it.startsWith("std/") or it.startsWith("pkg/"): it
        elif it == "../tabelline": "tabelline"
        elif it.startsWith("tabelline/"): it
        elif "/" notin it: dir & "/" & it
        else: it
      if full notin result: result.add full

proc kindName(k: string): string = k.replace("sk", "").toLowerAscii

proc jsondoc(module: string): JsonNode =
  let src = root / "src" / module & ".nim"
  let cache = root / "nimcache" / "apidoc"
  # a module's JSON also depends on the modules it imports: key on the whole of src/
  var h: Hash = 0
  for f in walkDirRec(root / "src"):
    if f.endsWith(".nim"): h = h !& hash(readFile(f))
  let key = cache / module.replace("/", "_") & "-" & $(!$h).uint64 & ".json"
  if not fileExists(key):
    createDir(cache)
    let tmp = cache / "out"
    let (output, code) = execCmdEx("nim jsondoc --hints:off --warnings:off --outdir:" & quoteShell(tmp) &
                                   " " & quoteShell(src), workingDir = root)
    let made = tmp / module.lastPathPart & ".json"
    if not fileExists(made):
      quit "nim jsondoc failed on " & src & " (" & $code & "):\n" & output
    moveFile(made, key)
  parseJson(readFile(key))

func docBlock(lines: seq[string], start: int): string =
  ## The `##` lines after line `start` (0-based): the doc comment of the declaration there. It
  ## skips the rest of the declaration (a signature can take several lines) up to the first `##`.
  var i = start
  var found: seq[string]
  while i < lines.len and i < start + 12:
    let s = lines[i].strip
    if s.startsWith("##"):
      found.add s
    elif found.len > 0:
      break
    inc i
  result = found.mapIt(if it.startsWith("## "): it[3 .. ^1] elif it == "##": "" else: it[2 .. ^1]).join("\n")

func moduleDoc(lines: seq[string]): string =
  var found: seq[string]
  for l in lines:
    if l.startsWith("##"): found.add(if l.startsWith("## "): l[3 .. ^1] elif l == "##": "" else: l[2 .. ^1])
    elif l.strip.len == 0 and found.len > 0: break
    elif l.strip.len > 0: break
  found.join("\n")

func sectionAt(lines: seq[string], line: int): string =
  ## The section of line `line` (1-based): the last `# ---- name` line above it.
  for i in countdown(min(line - 1, lines.high), 0):
    let s = lines[i]
    if s.startsWith("# ---"):
      return s.strip(chars = {'#', ' ', '-'})
  ""

func cleanSignature(code: string): string =
  ## Nim's signature without the effects it inferred (`raises`, `tags`, `forbids`, `gcsafe`):
  ## a reader needs the arguments; the effects are in the source.
  result = code
  let a = result.find("{.")
  if a < 0: return
  let b = result.find(".}", a)
  if b < 0: return
  var kept: seq[string]
  for p in result[a + 2 ..< b].split(", "):
    let p = p.strip
    if p.len == 0: continue
    if p.startsWith("raises:") or p.startsWith("tags:") or p.startsWith("forbids:") or p in ["gcsafe", "noSideEffect"]:
      continue
    kept.add p
  # a list inside a pragma (`raises: [A, B]`) was split too: only keep the pragma when no part of
  # a list is left over
  let rest = if kept.len == 0 or kept.anyIt(it.endsWith("]") or it.contains("[")): "" else: " {." & kept.join(", ") & ".}"
  result = (result[0 ..< a].strip(leading = false) & rest).strip(leading = false)
  # Nim wraps a long signature before the pragma: a lone indented line may be left empty
  result = result.splitLines.filterIt(it.strip.len > 0).join("\n")

proc apiModule*(module: string): ApiModule =
  let j = jsondoc(module)
  let path = "src" / module & ".nim"
  let lines = readFile(root / path).splitLines
  result = ApiModule(name: module, path: path, doc: moduleDoc(lines), imports: importsOf(lines, module))
  var byName = initOrderedTable[string, int]()
  for e in j["entries"]:
    # an operator comes quoted and HTML-escaped: `&lt;`
    let name = e["name"].getStr.strip(chars = {'`'}).multiReplace(("&lt;", "<"), ("&gt;", ">"), ("&quot;", "\""), ("&amp;", "&"))
    let code = e["code"].getStr
    # jsondoc calls a func a proc: the signature's first word says which it is
    let first = code.split({' ', '[', '('}, 1)[0]
    let kind = if first in ["proc", "func", "template", "macro", "iterator", "converter", "method"]: first
               else: kindName(e["type"].getStr)
    let line = e["line"].getInt
    let key = kind & " " & name
    if key notin byName:
      byName[key] = result.symbols.len
      result.symbols.add ApiSymbol(name: name, kind: kind, section: sectionAt(lines, line))
    let k = byName[key]
    result.symbols[k].signatures.add cleanSignature(e["code"].getStr)
    result.symbols[k].lines.add line
    if result.symbols[k].doc.len == 0 and e{"description"}.getStr.len > 0:
      result.symbols[k].doc = docBlock(lines, line - 1)

proc apiReference*(): seq[ApiModule] =
  for m in modules(): result.add apiModule(m)

when isMainModule:
  let api = apiReference()
  if "--summary" in commandLineParams():
    for m in api:
      echo m.name.alignLeft(24), ($m.symbols.len).align(4), " symbols, ",
           ($m.symbols.countIt(it.doc.len > 0)).align(3), " documented"
  else:
    echo pretty(%api)
