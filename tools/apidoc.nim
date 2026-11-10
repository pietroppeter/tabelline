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
    symbols*: seq[ApiSymbol]

let root* = currentSourcePath().parentDir.parentDir

const modules* = ["tabelline", "tabelline/verbs", "tabelline/formats", "tabelline/units",
                  "tabelline/localize", "tabelline/colors", "tabelline/core", "tabelline/build",
                  "tabelline/render_html", "tabelline/render_text", "tabelline/extract",
                  "tabelline/datasets", "tabelline/nimib"]
  ## Every module a user imports, in no particular order; locales, countries and currencies hold
  ## only data.

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
  result = ApiModule(name: module, path: path, doc: moduleDoc(lines))
  var byName = initOrderedTable[string, int]()
  for e in j["entries"]:
    let name = e["name"].getStr
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
  for m in modules: result.add apiModule(m)

when isMainModule:
  let api = apiReference()
  if "--summary" in commandLineParams():
    for m in api:
      echo m.name.alignLeft(24), ($m.symbols.len).align(4), " symbols, ",
           ($m.symbols.countIt(it.doc.len > 0)).align(3), " documented"
  else:
    echo pretty(%api)
