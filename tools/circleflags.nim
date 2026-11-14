## Writes `src/tabelline/data/circle-flags.tsv` from HatScripts' circle-flags (MIT), the round
## flags Great Tables' `fmt_flag()` draws: one line `code, svg` for every two-letter code of
## `countryNames` that has a flag. `fmtFlag(round = true)` reads the file when compiling.
##
##   git clone --depth 1 --branch gh-pages https://github.com/HatScripts/circle-flags
##   nim r tools/circleflags.nim circle-flags
##
## The license is copied in `licenses/circle-flags-MIT.txt`.

import std/[os, strutils, algorithm]
import ../src/tabelline/countries

const outFile = currentSourcePath().parentDir.parentDir / "src" / "tabelline" / "data" / "circle-flags.tsv"

if paramCount() < 1: quit "pass the folder of the circle-flags checkout"
let dir = paramStr(1) / "flags"
var lines: seq[string]
var missing: seq[string]
for (code, name) in countryNames:
  let f = dir / code.toLowerAscii & ".svg"
  if fileExists(f):
    var svg = readFile(f).strip.replace("\n", "").replace("\t", " ")
    # the same mask id in every flag of a page would clash: make it the code's
    svg = svg.replace("id=\"a\"", "id=\"cf-" & code & "\"").replace("url(#a)", "url(#cf-" & code & ")")
    lines.add code & "\t" & svg
  else: missing.add code
lines.sort()
writeFile(outFile, "# circle-flags by HatScripts (https://github.com/HatScripts/circle-flags), MIT: " &
  "licenses/circle-flags-MIT.txt. Written by tools/circleflags.nim: do not edit.\n" & lines.join("\n") & "\n")
echo outFile.extractFilename, ": ", lines.len, " flags; no flag for ", missing.join(" ")
