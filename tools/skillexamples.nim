## The Nim examples of the skills, run against the code, so a skill cannot teach what tabelline
## does not do.
##
## Every ```nim block in `skills/**/*.md` that imports tabelline is a program. It is compiled and
## run; when a ```text block follows it, what it prints must equal that text (as for the examples
## of the specs, `tools/specexamples.nim`). A block opts out with a `# snippet: skip` line.
##
##   nim r tools/skillexamples.nim            # run them, exit 1 if one fails
##   nim r tools/skillexamples.nim --verbose  # also print what each one printed

import std/[os, osproc, strutils, sequtils, algorithm]

let
  root = currentSourcePath().parentDir.parentDir
  verbose = "--verbose" in commandLineParams()
  # inside the repository, so nim.cfg and config.nims put tabelline and its dependencies on the path
  work = root / "nimcache" / "skillexamples"

type Fence = object
  lang, code: string
  line: int

proc fences(path: string): seq[Fence] =
  ## The fenced code blocks of a Markdown file, in order.
  var inFence = false
  var cur: Fence
  for i, line in readFile(path).splitLines.toSeq:
    let l = line.strip
    if not inFence and l.startsWith("```"):
      inFence = true
      cur = Fence(lang: l[3..^1].strip, line: i + 1)
    elif inFence and l == "```":
      inFence = false
      result.add cur
    elif inFence:
      cur.code.add line & "\n"

proc tidy(s: string): string =
  s.splitLines.mapIt(it.strip(leading = false)).join("\n").strip

var passed, failed, skipped = 0

proc report(ok: bool, label: string, detail = "") =
  if ok: inc passed else: inc failed
  echo (if ok: "pass  " else: "fail  "), label
  if detail.len > 0 and (verbose or not ok): echo detail.indent(4)

removeDir(work)
createDir(work)
var files: seq[string]
for md in walkDirRec(root / "skills"):
  if md.endsWith(".md") and (DirSep & "evals" & DirSep) notin md: files.add md
files.sort
var n = 0
for md in files:
  let fs = fences(md)
  for k, f in fs:
    if f.lang != "nim" or "import tabelline" notin f.code: continue
    let label = md.relativePath(root) & ":" & $f.line
    if "# snippet: skip" in f.code:
      inc skipped
      echo "skip  ", label
      continue
    inc n
    let file = work / ("snippet" & $n & ".nim")
    writeFile(file, f.code)
    let (output, code) = execCmdEx("nim r --hints:off --warnings:off --nimcache:" &
      quoteShell(work / ("cache" & $n)) & " " & quoteShell(file), workingDir = work)
    if code != 0:
      report(false, label & " compiles and runs", output)
    elif k + 1 < fs.len and fs[k + 1].lang == "text":
      let (want, got) = (tidy(fs[k + 1].code), tidy(output))
      report(got == want, label & " prints its text block",
             if got == want: "" else: "expected:\n" & want & "\ngot:\n" & got)
    else:
      report(true, label & " compiles and runs", output)

removeDir(work)
echo n, " examples, ", failed, " failing, ", skipped, " skipped"
if failed > 0: quit 1
