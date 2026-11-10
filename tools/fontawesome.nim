## Writes `src/tabelline/data/fontawesome.tsv` from the npm package of Font Awesome Free: every
## free icon (solid, regular and brands) as one line `name, style, width, label, path`, then its
## other names as lines `alias, =, name`. `fmtIcon` reads the file when compiling.
##
##   curl -sSO https://registry.npmjs.org/@fortawesome/fontawesome-free/-/fontawesome-free-7.3.1.tgz
##   tar xzf fontawesome-free-7.3.1.tgz
##   nim r tools/fontawesome.nim package
##
## Run it again for a new release of Font Awesome. The icons are under CC BY 4.0, copied in
## `licenses/fontawesome-LICENSE.txt` with the package's license text.

import std/[json, os, strutils, algorithm]

const outFile = currentSourcePath().parentDir.parentDir / "src" / "tabelline" / "data" / "fontawesome.tsv"

if paramCount() < 1: quit "pass the folder of the unpacked npm package (`package`)"
let pkg = paramStr(1)
let version = parseFile(pkg / "package.json")["version"].getStr
let families = parseFile(pkg / "metadata" / "icon-families.json")

var icons, aliases: seq[string]
for name, icon in families:
  let label = icon{"label"}.getStr(name).replace('\t', ' ')
  var styles: seq[string]
  for fs in icon{"familyStylesByLicense", "free"}.getElems:
    if fs["family"].getStr == "classic": styles.add fs["style"].getStr
  for style in styles:
    let svg = icon["svgs"]["classic"][style]
    let path = if svg["path"].kind == JArray: svg["path"][^1].getStr else: svg["path"].getStr
    doAssert svg["height"].getInt == 512, name
    icons.add [name, style, $svg["width"].getInt, label, path].join("\t")
  if styles.len > 0:
    for a in icon{"aliases", "names"}.getElems: aliases.add [a.getStr, "=", name].join("\t")
icons.sort()
aliases.sort()
writeFile(outFile, "# Font Awesome Free " & version & " (https://fontawesome.com), icons under CC BY 4.0: " &
  "licenses/fontawesome-LICENSE.txt. Written by tools/fontawesome.nim: do not edit.\n" &
  icons.join("\n") & "\n" & aliases.join("\n") & "\n")
echo outFile.extractFilename, ": ", icons.len, " icons, ", aliases.len, " aliases (Font Awesome Free ", version, ")"
