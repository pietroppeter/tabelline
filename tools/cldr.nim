## Writes `src/tabelline/countries.nim` from the Unicode CLDR JSON: the English name of every
## country and territory, by its two-letter code (ISO 3166-1 alpha-2), and the three-letter
## codes (alpha-3) that map to them.
##
##   nim r -d:ssl tools/cldr.nim            # downloads CLDR `cldrVersion` from GitHub
##   nim r tools/cldr.nim <dir>             # reads territories.json and codeMappings.json from <dir>
##
## CLDR is under the Unicode License v3, copied in `licenses/unicode-cldr-LICENSE.txt`.

import std/[json, os, strutils, algorithm, sequtils]
when defined(ssl): import std/httpclient

const
  cldrVersion = "49.0.0"
  base = "https://raw.githubusercontent.com/unicode-org/cldr-json/" & cldrVersion & "/cldr-json/"
  territoriesUrl = base & "cldr-localenames-full/main/en/territories.json"
  codesUrl = base & "cldr-core/supplemental/codeMappings.json"
  output = currentSourcePath().parentDir.parentDir / "src" / "tabelline" / "countries.nim"

proc fetch(url: string): string =
  when defined(ssl):
    newHttpClient().getContent(url)
  else:
    quit "pass a folder with territories.json and codeMappings.json, or compile with -d:ssl"

proc load(dir, file, url: string): JsonNode =
  parseJson(if dir.len > 0: readFile(dir / file) else: fetch(url))

let dir = if paramCount() > 0: paramStr(1) else: ""
let territories = load(dir, "territories.json", territoriesUrl)["main"]["en"]["localeDisplayNames"]["territories"]
let codes = load(dir, "codeMappings.json", codesUrl)["supplemental"]["codeMappings"]

var names: seq[(string, string)]
for code, name in territories:
  if code.len == 2 and code.allCharsInSet({'A'..'Z'}) and code != "ZZ":
    names.add (code, name.getStr)
names.sort()
var alpha3: seq[(string, string)]
for code, m in codes:
  if code.len == 2 and m.hasKey("_alpha3") and names.anyIt(it[0] == code):
    alpha3.add (m["_alpha3"].getStr, code)
alpha3.sort()

var s = "## Country names in English and three-letter codes, from Unicode CLDR " & cldrVersion & ".\n" &
        "## Written by `tools/cldr.nim`: do not edit. CLDR is under the Unicode License v3\n" &
        "## (`licenses/unicode-cldr-LICENSE.txt`).\n\n"
s.add "const countryNames* = [\n"
for (c, n) in names: s.add "  (" & c.escape & ", " & n.escape("\"", "\"") & "),\n"
s.add "]\n\nconst countryAlpha3* = [\n"
for (a, c) in alpha3: s.add "  (" & a.escape & ", " & c.escape & "),\n"
s.add "]\n"
writeFile(output, s)
echo "wrote ", output, ": ", names.len, " names, ", alpha3.len, " three-letter codes"
