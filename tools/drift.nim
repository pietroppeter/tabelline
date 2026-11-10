## Drift: what the pages write as HTML, CSS or fixed colours instead of using the blocks.
##
##   nim r tools/drift.nim            # checks every page against tools/drift.tsv
##   nim r tools/drift.nim --update   # writes the counts of today into tools/drift.tsv
##
## For each `.nim` file under docs/ it counts calls of nbRawHtml, nbText blocks whose text holds
## an HTML tag, `<style`, `<script`, inline `style="` and distinct `#RRGGBB` colours. Code shown in
## prose (Markdown code spans and fences in nbText) and Nim comments are not counted. The style
## and the blocks (docs/stile.nim, docs/blocchi.nim, and docs/review.nim, which has both) are where
## CSS and HTML belong, and dated
## snapshots (docs/devlog/data/) are left out. The check fails when a file counts more of anything
## than its line in tools/drift.tsv: a new page has none, and the dated posts keep what they had.
## The same counter ships with the nimib-blocks skill (pietroppeter/skills).
import std/[os, strutils, sequtils, strformat, tables, algorithm]

const
  root = currentSourcePath().parentDir.parentDir
  baseline = root / "tools" / "drift.tsv"
  allowed = ["stile.nim", "blocchi.nim", "review.nim"]
  kinds = ["nbRawHtml", "nbText html", "<style", "<script", "style=", "hex colours"]
  tags = ["<div", "<p ", "<p>", "<span", "<ul", "<ol", "<li", "<table", "<h1", "<h2", "<h3",
          "<small", "<details", "<button", "<br", "<a href", "<strong", "<em>", "<img"]

func countOf(s, sub: string): int =
  var i = s.find(sub)
  while i >= 0:
    inc result
    i = s.find(sub, i + sub.len)

func withoutCode(md: string): string =
  ## Markdown text without its code fences and `code spans`.
  var fence = false
  for line in md.splitLines:
    if line.strip.startsWith("```"):
      fence = not fence
      continue
    if fence: continue
    var inSpan = false
    for c in line:
      if c == '`': inSpan = not inSpan
      elif not inSpan: result.add c
    result.add '\n'

func proseless(src: string): string =
  ## The source without Nim comments, and without the code shown in nbText prose.
  for line in src.splitLines:
    if not line.strip.startsWith("#"): result.add line & "\n"
  var i = result.find("nbText:")
  while i >= 0:
    let a = result.find("\"\"\"", i)
    if a < 0: break
    let b = result.find("\"\"\"", a + 3)
    if b < 0: break
    let text = withoutCode(result[a + 3 ..< b])
    result = result[0 .. a + 2] & text & result[b .. ^1]
    i = result.find("nbText:", a + 6 + text.len)

func count(src: string): seq[int] =
  let s = proseless(src)
  var textHtml = 0
  var i = s.find("nbText:")
  while i >= 0:
    let a = s.find("\"\"\"", i)
    if a < 0: break
    let b = s.find("\"\"\"", a + 3)
    if b < 0: break
    if tags.anyIt(it in s[a + 3 ..< b]): inc textHtml
    i = s.find("nbText:", b)
  var hex: seq[string]
  var k = 0
  while k < s.len - 6:
    if s[k] == '#' and allIt(s[k+1 .. k+6], it in HexDigits) and
       (k + 7 >= s.len or s[k+7] notin HexDigits + Letters):
      hex.add s[k .. k+6].toUpperAscii
      k += 7
    else: inc k
  @[s.countOf("nbRawHtml") - s.countOf("template nbRawHtml"), textHtml, s.countOf("<style"),
    s.countOf("<script"), s.countOf("style=\\\"") + s.countOf("style=\""), hex.deduplicate.len]

var now: seq[(string, seq[int])]
for f in walkDirRec(root / "docs"):
  let rel = f.relativePath(root)
  if not f.endsWith(".nim") or f.lastPathPart in allowed or rel.startsWith("docs/devlog/data/"): continue
  let c = count(readFile(f))
  if c.anyIt(it > 0): now.add (rel, c)
now.sort(proc (a, b: (string, seq[int])): int = cmp(a[0], b[0]))

if "--update" in commandLineParams():
  var tsv = "file\t" & kinds.join("\t") & "\n"
  for (f, c) in now: tsv.add f & "\t" & c.join("\t") & "\n"
  writeFile(baseline, tsv)
  echo &"wrote {baseline.relativePath(root)}: {now.len} files with drift"
  quit 0

var before: Table[string, seq[int]]
for line in readFile(baseline).splitLines[1 .. ^1]:
  if line.len > 0:
    let f = line.split('\t')
    before[f[0]] = f[1 .. ^1].mapIt(parseInt(it))
var failed = false
for (f, c) in now:
  let b = before.getOrDefault(f, newSeq[int](kinds.len))
  for i, k in kinds:
    if c[i] > b[i]:
      echo &"✗ {f}: {c[i]} × {k}, the baseline allows {b[i]}"
      failed = true
  if c != b and c.zip(b).allIt(it[0] <= it[1]): echo &"  {f}: below its baseline; run with --update to lower it"
if failed:
  echo "\nUse a block from docs/blocchi.nim (or make one), and put CSS and colours in docs/stile.nim."
  quit 1
let total = now.mapIt(it[1].foldl(a + b, 0)).foldl(a + b, 0)
echo &"✓ no new drift ({total} counted in {now.len} files, none above tools/drift.tsv)"
