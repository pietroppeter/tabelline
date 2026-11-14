## Writes `src/tabelline/data/r-colors.tsv`: the colour names R knows (and so gt and Great Tables)
## beyond the 148 of CSS, such as `sienna4` and `grey50`, one line `name, hex`. They come from
## Great Tables' `COLOR_NAME_TO_HEX` (MIT, `licenses/great-tables-MIT.txt`), R's `colors()`:
##
##   curl -sSO https://raw.githubusercontent.com/posit-dev/great-tables/main/great_tables/_data_color/constants.py
##   nim r tools/rcolors.nim constants.py

import std/[os, strutils, algorithm, sets]
import ../src/tabelline/colors

const outFile = currentSourcePath().parentDir.parentDir / "src" / "tabelline" / "data" / "r-colors.tsv"

if paramCount() < 1: quit "pass Great Tables' _data_color/constants.py"
let src = readFile(paramStr(1))
let start = src.find("COLOR_NAME_TO_HEX")
var lines: seq[string]
var seen: HashSet[string]
for line in src[start .. ^1].splitLines:
  let parts = line.split('"')   # `    "sienna4": "#8B4726",`
  if parts.len < 5 or not parts[3].startsWith("#") or parts[3].len != 7: continue
  let (name, hex) = (parts[1], parts[3].toUpperAscii)
  if name in seen or isCssColorName(name): continue
  seen.incl name
  lines.add name & "\t" & hex
lines.sort()
writeFile(outFile, "# R's colour names beyond CSS's, from Great Tables' COLOR_NAME_TO_HEX (MIT): " &
  "licenses/great-tables-MIT.txt. Written by tools/rcolors.nim: do not edit.\n" & lines.join("\n") & "\n")
echo outFile.extractFilename, ": ", lines.len, " names"
