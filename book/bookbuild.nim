## Builds the tabelline book into docs/book/, rerunning only the chapters whose inputs changed.
##
##     nim r book/bookbuild.nim [--force] [--from:<url of the published book>]
##
## (from the root of the repository; `BOOK_FORCE=1` and `BOOK_FROM=<url>` do the same.)
##
## The same way as the Nanuq book (nanuq-book/bookbuild.nim), made smaller:
##
## - A chapter that runs saves its nimib document as JSON next to its page
##   (`docs/book/<chapter>.json`, see `bookSave` in book/tabbook.nim). This program adds to it a
##   *build record*: every file the chapter depended on, with its SHA1. These are what Nim
##   compiled (its own list, `depfiles`, with `-d:nimBetterRun`: the chapter, the helpers,
##   tabelline's sources, nimib, nimibook and the data, read with `staticRead`; the standard
##   library is left out, as it comes with the Nim version, which is recorded),
##   and what the chapter names in its context (`book_inputs`: its Great Tables outputs).
## - A chapter is stale when its record is missing, the Nim version changed, or one of its
##   inputs changed. The stale chapters are compiled as ONE program, so Nim compiles tabelline,
##   nimib and nimibook once; each runs when its module is initialised. If that program does
##   not compile, or stops at a failing chapter, the chapters it did not finish are built one
##   by one, so the failing one gets its own log (`book/<chapter>.log`, as nimibook does).
## - Then one pass renders every page from the chapters' JSON with the current theme and table
##   of contents, plus the Markdown pages: adding a chapter or changing the theme reruns no
##   chapter.
##
## `--from` downloads the JSON of the chapters that have none in docs/book from the published
## book, so CI starts from what is live and a pull request reruns only what it changed.
import std/[os, osproc, json, strutils, sequtils, tables, sets, strformat, times, parseopt]
{.warning[Deprecated]: off.}  # std/sha1: the same SHA1 Nim writes in its depfiles
import std/sha1
{.warning[Deprecated]: on.}
import tabbook  # the theme of the pages
import ../docs/stile  # the palette: the tokens of tabelline's pages, in the Edo values
import nimibook/commands

const recordVersion = 1

let bookDir = currentSourcePath().parentDir
let root = bookDir.parentDir
let home = root / "docs" / "book"

type Chapter = object
  path: string      # relative to book/, e.g. get-started/intro.nim
  jsonPath: string  # absolute, docs/book/get-started/intro.json
  cacheDir: string  # absolute, nimcache/book/<path without extension>
  reason: string    # why it is rebuilt ("" = up to date)

proc rel(path: string): string =
  ## Files are recorded relative to the repository root (the stdlib with its absolute path).
  if path.isAbsolute and path.startsWith(root & "/"): path.relativePath(root) else: path

proc absPath(p: string): string = (if p.isAbsolute: p else: root / p)

var hashCache: Table[string, string]

proc fileHash(p: string): string =
  let a = absPath(p)
  if a notin hashCache:
    hashCache[a] = if fileExists(a): $secureHashFile(a) else: ""
  hashCache[a]

proc nimVersion(): string =
  execProcess("nim", args = ["--version"], options = {poUsePath}).splitLines()[0].strip

const globalInputs = ["book/gt/uv.lock"]

proc staleReason(c: Chapter, nimVer: string): string =
  if not fileExists(c.jsonPath): return "no previous build"
  let j = try: parseFile(c.jsonPath) except CatchableError: return "unreadable JSON"
  let b = j{"build"}
  if b.isNil: return "no build record"
  if b{"version"}.getInt != recordVersion: return "old record format"
  if b{"nim"}.getStr != nimVer: return "Nim version changed"
  for item in b{"inputs"}.getElems:
    if fileHash(item[0].getStr) != item[1].getStr: return "changed: " & item[0].getStr
  ""

proc depfiles(cacheDir: string): seq[string] =
  ## The files Nim compiled, from the nimcache JSON (`-d:nimBetterRun`).
  for f in walkFiles(cacheDir / "*.json"):
    for d in parseFile(f){"depfiles"}.getElems: result.add d[0].getStr

proc writeRecord(c: Chapter, nimVer: string, deps: seq[string]) =
  var j = parseFile(c.jsonPath)
  var inputs: seq[string]
  var seen: HashSet[string]
  for p in deps & j{"context"}{"book_inputs"}.getElems.mapIt(it.getStr) & @globalInputs:
    let r = rel(p)
    # the standard library comes with the Nim version, recorded apart; nimcache is generated
    if r.isAbsolute or r.startsWith("nimcache/"): continue
    if r notin seen:
      seen.incl r
      inputs.add r
  var record = %*{"version": recordVersion, "nim": nimVer,
                  "built": now().utc.format("yyyy-MM-dd'T'HH:mm:ss'Z'"), "inputs": []}
  hashCache.clear()
  for p in inputs: record["inputs"].add %*[p, fileHash(p)]
  j["build"] = record
  writeFile(c.jsonPath, $j)

proc logFailure(c: Chapter, output: string) =
  writeFile(bookDir / c.path.changeFileExt("log"), output)  # as nimibook does
  discard tryRemoveFile(c.jsonPath)  # never render an old page for a failing chapter

proc runShared(chapters: seq[Chapter], nimVer: string): seq[Chapter] =
  ## Compiles the chapters into one program and runs it. Returns the chapters left to build one
  ## by one: all of them if it does not compile, else the ones it did not finish.
  let dir = root / "nimcache" / "book" / "all"
  createDir dir
  var src = "# generated by book/bookbuild.nim: the chapters to rerun, in book order\n" &
            "{.warning[UnusedImport]: off.}\n"
  for c in chapters: src.add "import " & escape(bookDir / c.path.changeFileExt("")) & "\n"
  writeFile(dir / "chapters.nim", src)
  let exe = dir / "chapters"
  let cmd = "nim c -d:nimBetterRun --hints:off --path:" & quoteShell(bookDir) & " --nimcache:" &
            quoteShell(dir / "cache") & " -o:" & quoteShell(exe) & " " & quoteShell(dir / "chapters.nim")
  echo "[bookbuild] ", cmd
  var t = epochTime()
  let (cout, ccode) = execCmdEx(cmd, workingDir = bookDir)
  if ccode != 0:
    echo "[bookbuild] the chapters do not compile as one program; building them one by one\n", cout
    return chapters
  echo &"[bookbuild] compiled {chapters.len} chapters as one program in {int(epochTime() - t)} s"
  for c in chapters:
    discard tryRemoveFile(bookDir / c.path.changeFileExt("log"))
    discard tryRemoveFile(c.jsonPath)  # the chapter writes a new one
  t = epochTime()
  let (rout, rcode) = execCmdEx(quoteShell(exe), workingDir = bookDir)
  echo &"[bookbuild] ran them in {int(epochTime() - t)} s"
  # compile-time inputs: all the program's files but the other chapters' sources
  let deps = depfiles(dir / "cache")
  let sources = chapters.mapIt(bookDir / it.path).toHashSet
  for c in chapters:
    if not fileExists(c.jsonPath):
      result.add c
      continue
    let own = bookDir / c.path
    writeRecord(c, nimVer, deps.filterIt(it == own or absPath(it) notin sources))
  if rcode != 0:
    let lines = rout.splitLines
    echo "[bookbuild] the program stopped at a failing chapter; building ", result.len,
         " chapters one by one\n", lines[max(0, lines.len - 30) .. ^1].join("\n")

proc runSingle(c: Chapter, nimVer: string): bool =
  discard tryRemoveFile(bookDir / c.path.changeFileExt("log"))
  createDir c.cacheDir
  let exe = c.cacheDir / "chapter"
  let cmd = "nim c -d:nimBetterRun --hints:off --nimcache:" & quoteShell(c.cacheDir) & " -o:" &
            quoteShell(exe) & " " & quoteShell(bookDir / c.path)
  echo "[bookbuild] ", cmd
  let (cout, ccode) = execCmdEx(cmd, workingDir = bookDir)
  if ccode != 0:
    logFailure(c, cout)
    return false
  discard tryRemoveFile(c.jsonPath)
  let (rout, rcode) = execCmdEx(quoteShell(exe), workingDir = bookDir)
  if rcode != 0 or not fileExists(c.jsonPath):
    logFailure(c, rout)
    return false
  writeRecord(c, nimVer, depfiles(c.cacheDir))
  true

proc fetch(url, dest: string): bool =
  createDir(dest.parentDir)
  execCmd("curl -fsL --retry 2 -o " & quoteShell(dest) & " " & quoteShell(url)) == 0

proc renderChapter(path, jsonPath: string) =
  ## A page from its chapter's JSON: blocks and source as the chapter left them, the rest
  ## (theme, table of contents, previous/next) as the book is now.
  let saved = readFile(jsonPath).fromJson(NbDoc)
  nbInit(theme = useTabBook, thisFileRel = path)
  nb.doc.blocks = saved.blocks
  nb.doc.source = saved.source
  nb.doc.sourceFiles = saved.sourceFiles
  for key, value in saved.context:  # what the chapter itself added to the context
    if not nb.doc.context.hasKey(key): nb.doc.context[key] = value
  nbSave
  setCurrentDir nb.doc.initDir

proc assets() =
  ## nimibook's assets, fresh, with the book's look added at the end of chrome.css and book.js
  ## (so Markdown pages get it too), its fonts, and the images of the chapters.
  let nim = "nim r -d:release --hints:off " & quoteShell(bookDir / "nbook.nim")
  for cmd in [nim & " dump", nim & " update"]:
    if execCmd("cd " & quoteShell(bookDir) & " && " & cmd) != 0: quit 1
  let css = home / "assets" / "css" / "chrome.css"
  writeFile css, readFile(css) & "\n" & paletteCss(edo) & readFile(bookDir / "theme" / "edo.css")
  let js = home / "assets" / "js" / "book.js"
  writeFile js, readFile(js) & "\n" & readFile(bookDir / "theme" / "book.js")
  createDir home / "assets" / "fonts-edo"
  for f in ["jost-400-normal.woff2", "jost-400-italic.woff2", "jost-700-normal.woff2", "OFL-jost.txt"]:
    copyFile(root / "docs" / "assets" / "fonts" / f, home / "assets" / "fonts-edo" / f)
  copyDir(bookDir / "images", home / "images")

proc main =
  var force = getEnv("BOOK_FORCE") in ["1", "true"]
  var fromUrl = getEnv("BOOK_FROM").strip(chars = {'/'}, leading = false)
  for kind, key, val in getopt():
    case key
    of "force": force = true
    of "from": fromUrl = val.strip(chars = {'/'}, leading = false)
    else: discard

  assets()
  let book = load(home / "book.json")
  let nimVer = nimVersion()
  var chapters: seq[Chapter]
  for e in book.toc.entries:
    if e.isDraft or not e.path.endsWith(".nim"): continue
    let name = e.path.changeFileExt("")
    var c = Chapter(path: e.path, jsonPath: home / name & ".json",
                    cacheDir: root / "nimcache" / "book" / name)
    if fromUrl.len > 0 and not fileExists(c.jsonPath):
      if fetch(fromUrl & "/" & name & ".json", c.jsonPath): echo "[bookbuild] fetched ", c.jsonPath
    c.reason = if force: "forced" else: staleReason(c, nimVer)
    chapters.add c

  let stale = chapters.filterIt(it.reason.len > 0)
  echo &"[bookbuild] {chapters.len - stale.len} of {chapters.len} chapters up to date"
  for c in stale: echo "[bookbuild] rebuild ", c.path, " (", c.reason, ")"
  var failed: seq[string]
  if stale.len > 0:
    for c in runShared(stale, nimVer):
      if not runSingle(c, nimVer): failed.add c.path
  if failed.len > 0:
    echo "[bookbuild] ", failed.len, " chapters failed:"
    for f in failed: echo "\n  ❌ ", f, "\n", readFile(bookDir / f.changeFileExt("log"))
    quit 1

  # one pass renders every page
  setCurrentDir bookDir
  for e in book.toc.entries:
    if e.isDraft: continue
    if e.path.endsWith(".nim"): renderChapter(e.path, home / e.path.changeFileExt("json"))
    elif not buildMd(e): quit 1
  check book

main()
