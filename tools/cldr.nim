## Writes three modules of `src/tabelline/` from the Unicode CLDR JSON (cldr-json, full):
##
## - `countries.nim`: the English name of every country and territory, by its two-letter code
##   (ISO 3166-1 alpha-2), and the three-letter codes (alpha-3) that map to them;
## - `currencies.nim`: every currency of CLDR, by its ISO 4217 code: its English name, its symbol
##   and its number of decimals;
## - `locales.nim`: for every locale of CLDR, the marks and patterns of numbers, percentages and
##   currencies, and the names and patterns of dates and times (Gregorian calendar, Latin digits).
##
##   nim r -d:ssl tools/cldr.nim            # downloads CLDR `cldrVersion` from GitHub (many files)
##   nim r tools/cldr.nim <dir>             # reads an unzipped cldr-<version>-json-full.zip
##
## The data is generated once and committed: nothing is read when tabelline builds or runs. Run
## it again for a new CLDR release. A locale stores only the fields that differ from its parent
## (`en-IN` from `en-001`, `en-001` from `en`, `en` from `und`), so the table stays small.
##
## CLDR is under the Unicode License v3, copied in `licenses/unicode-cldr-LICENSE.txt`.

import std/[json, os, strutils, algorithm, sequtils, tables]
when defined(ssl): import std/httpclient

const
  cldrVersion = "49.0.0"
  base = "https://raw.githubusercontent.com/unicode-org/cldr-json/" & cldrVersion & "/cldr-json/"
  srcDir = currentSourcePath().parentDir.parentDir / "src" / "tabelline"
  header = "## Written by `tools/cldr.nim` from Unicode CLDR " & cldrVersion & ": do not edit.\n" &
           "## CLDR is under the Unicode License v3 (`licenses/unicode-cldr-LICENSE.txt`).\n"

let dir = if paramCount() > 0: paramStr(1) else: getTempDir() / "tabelline-cldr-" & cldrVersion

proc lit(s: string): string =
  ## A Nim string literal that keeps UTF-8 as it is (std's `escape` writes every byte above 127
  ## as `\xHH`).
  result = "\""
  for c in s:
    case c
    of '"': result.add "\\\""
    of '\\': result.add "\\\\"
    of '\0'..'\x1F', '\x7F': result.add "\\x" & toHex(ord(c), 2)
    else: result.add c
  result.add '"'

proc load(path: string): JsonNode =
  ## A file of the cldr-json tree, downloaded into `dir` when it is not there.
  let local = dir / path
  if not fileExists(local):
    when defined(ssl):
      createDir(local.parentDir)
      writeFile(local, newHttpClient().getContent(base & path))
    else:
      quit "no " & local & ": pass the folder of an unzipped cldr-json, or compile with -d:ssl"
  parseFile(local)

# ------------------------------------------------------------------------------------ countries

block:
  let territories = load("cldr-localenames-full/main/en/territories.json")["main"]["en"]["localeDisplayNames"]["territories"]
  let codes = load("cldr-core/supplemental/codeMappings.json")["supplemental"]["codeMappings"]
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
  var s = "## Country names in English and three-letter codes.\n" & header & "\n"
  s.add "const countryNames* = [\n"
  for (c, n) in names: s.add "  (" & c.lit & ", " & n.lit & "),\n"
  s.add "]\n\nconst countryAlpha3* = [\n"
  for (a, c) in alpha3: s.add "  (" & a.lit & ", " & c.lit & "),\n"
  s.add "]\n"
  writeFile(srcDir / "countries.nim", s)
  echo "countries.nim: ", names.len, " names, ", alpha3.len, " three-letter codes"

# ----------------------------------------------------------------------------------- currencies

block:
  let names = load("cldr-numbers-full/main/en/currencies.json")["main"]["en"]["numbers"]["currencies"]
  let fractions = load("cldr-core/supplemental/currencyData.json")["supplemental"]["currencyData"]["fractions"]
  let defaultDigits = fractions["DEFAULT"]["_digits"].getStr.parseInt
  var rows: seq[(string, string, string, int)]
  for code, c in names:
    if code.len != 3 or not code.allCharsInSet({'A'..'Z'}) or code == "XXX": continue
    let digits = if fractions.hasKey(code): fractions[code]["_digits"].getStr.parseInt else: defaultDigits
    rows.add (code, c{"displayName"}.getStr(code), c{"symbol"}.getStr(code), digits)
  rows.sort()
  var s = "## Currencies by ISO 4217 code: English name, symbol, decimals.\n" & header & "\n"
  s.add "const currencyTable* = [\n"
  for (code, name, sym, d) in rows:
    s.add "  (" & code.lit & ", " & name.lit & ", " & sym.lit & ", " & $d & "),\n"
  s.add "]\n"
  writeFile(srcDir / "currencies.nim", s)
  echo "currencies.nim: ", rows.len, " currencies"

# -------------------------------------------------------------------------------------- locales

const
  dateSkeletons = ["yMd", "yMEd", "yMMM", "yMMMM", "yMMMd", "yMMMEd", "GyMd", "GyMMMd", "GyMMMEd",
                   "yM", "Md", "MEd", "MMMd", "MMMEd", "MMMMd", "GyMMM", "yQQQ", "yQQQQ", "Gy", "y",
                   "M", "MMM", "d", "Ed"]
  timeSkeletons = ["Hms", "Hm", "H", "hms", "hm", "h", "ms"]

proc fieldNames(): seq[string] =
  result = @["decimal", "group", "percentSign", "percentPattern", "currencyPattern",
             "accountingPattern"]
  for i in 1..12: result.add "month" & $i
  for i in 1..12: result.add "monthAbbr" & $i
  for i in 1..12: result.add "monthAlone" & $i
  for i in 1..12: result.add "monthAloneAbbr" & $i
  for d in ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]: result.add "day-" & d
  for d in ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]: result.add "dayAbbr-" & d
  for i in 1..4: result.add "quarter" & $i
  for i in 1..4: result.add "quarterAbbr" & $i
  result.add ["am", "pm", "eraBC", "eraAD"]
  for f in ["full", "long", "medium", "short"]: result.add "date-" & f
  for f in ["full", "long", "medium", "short"]: result.add "time-" & f
  result.add "dateTime"
  for k in dateSkeletons: result.add "skeleton-" & k
  for k in timeSkeletons: result.add "skeleton-" & k

let fields = fieldNames()

proc record(loc: string): seq[string] =
  ## Every field of a locale, resolved (cldr-json writes each locale in full).
  let n = load("cldr-numbers-full/main/" & loc & "/numbers.json")["main"][loc]["numbers"]
  let sym = n["symbols-numberSystem-latn"]
  result.add [sym["decimal"].getStr, sym["group"].getStr, sym["percentSign"].getStr,
              n["percentFormats-numberSystem-latn"]["standard"].getStr,
              n["currencyFormats-numberSystem-latn"]["standard"].getStr,
              n["currencyFormats-numberSystem-latn"]["accounting"].getStr]
  let g = load("cldr-dates-full/main/" & loc & "/ca-gregorian.json")["main"][loc]["dates"]["calendars"]["gregorian"]
  for ctx in ["format", "stand-alone"]:
    for width in ["wide", "abbreviated"]:
      for i in 1..12: result.add g["months"][ctx][width][$i].getStr
  for width in ["wide", "abbreviated"]:
    for d in ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]: result.add g["days"]["format"][width][d].getStr
  for width in ["wide", "abbreviated"]:
    for i in 1..4: result.add g["quarters"]["format"][width][$i].getStr
  let periods = g["dayPeriods"]["format"]["abbreviated"]
  result.add [periods["am"].getStr, periods["pm"].getStr,
              g["eras"]["eraAbbr"]["0"].getStr, g["eras"]["eraAbbr"]["1"].getStr]
  for f in ["full", "long", "medium", "short"]: result.add g["dateFormats"][f].getStr
  for f in ["full", "long", "medium", "short"]: result.add g["timeFormats"][f].getStr
  let dt = g["dateTimeFormats"]
  result.add (if dt["medium"].kind == JString: dt["medium"].getStr else: dt["medium"]["_value"].getStr)
  let avail = dt["availableFormats"]
  for k in dateSkeletons: result.add avail{k}.getStr
  for k in timeSkeletons: result.add avail{k}.getStr
  doAssert result.len == fields.len
  for v in result: doAssert '\x1F' notin v and '\x1E' notin v

let available = load("cldr-core/availableLocales.json")["availableLocales"]["full"].mapIt(it.getStr)
let explicitParents = load("cldr-core/supplemental/parentLocales.json")["supplemental"]["parentLocales"]["parentLocale"]

proc parentOf(loc: string): string =
  ## The locale `loc` inherits from: CLDR's explicit parent, or `loc` without its last subtag
  ## (a script subtag such as `sr-Latn` starts a new language: its parent is `und`).
  if loc == "und": return ""
  if explicitParents.hasKey(loc): return explicitParents[loc].getStr.replace("root", "und")
  let i = loc.rfind('-')
  if i < 0: return "und"
  let p = loc[0 ..< i]
  if p in available or p == "und": p else: parentOf(p)

var records = initTable[string, seq[string]]()
records["und"] = record("und")
for loc in available:
  if loc != "und": records[loc] = record(loc)

var s = "## Number, currency, date and time conventions of every locale of CLDR.\n" & header
s.add "##\n## `localeFields` names the fields of a record. A locale keeps only the fields that differ\n"
s.add "## from its parent (`localeParents`, or the tag without its last subtag); `und` is the root,\n"
s.add "## written in full. Each value is written once, in `localeValues` (joined by '\\x1F'; '\\x1E'\n"
s.add "## is an empty value). `localeTable` gives each locale's first cell: a cell is a field\n"
s.add "## (`localeCellField`) and the number of its value (`localeCellValue`).\n\n"
s.add "const localeFields* = [" & fields.mapIt(it.lit).join(", ") & "]\n\n"
s.add "const localeParents* = [\n"
var ps: seq[(string, string)]
for loc in available:
  if explicitParents.hasKey(loc): ps.add (loc, parentOf(loc))
ps.sort()
for (a, b) in ps: s.add "  (" & a.lit & ", " & b.lit & "),\n"
s.add "]\n\n"
var names = toSeq(records.keys)
names.sort()
var pool: seq[string]
var poolIx: Table[string, int]
var cellField, cellValue: seq[int]
var starts: seq[(string, int)]
for loc in names:
  let r = records[loc]
  let parent = parentOf(loc)
  var diff = newSeq[string](r.len)
  if parent.len > 0:
    let pr = records[parent]
    for i in 0 ..< r.len:
      if r[i] != pr[i]: diff[i] = (if r[i].len == 0: "\x1E" else: r[i])
  else:
    diff = r
  starts.add (loc, cellField.len)
  for i, v in diff:
    if v.len == 0: continue
    if v notin poolIx:
      poolIx[v] = pool.len
      pool.add v
    cellField.add i
    cellValue.add poolIx[v]
doAssert pool.len < 65536 and fields.len < 256
proc numbers(xs: seq[int]): string =
  for k, x in xs:
    if k mod 24 == 0: result.add "\n  "
    result.add $x & ", "
s.add "const localeValues* =\n"
var line = ""
for k, v in pool:
  line.add v & (if k < pool.high: "\x1F" else: "")
  if line.len > 80 or k == pool.high:
    s.add "  " & line.lit & (if k == pool.high: "\n" else: " &\n")
    line = ""
s.add "\nconst localeTable* = [\n"
for (loc, first) in starts: s.add "  (" & loc.lit & ", " & $first & "),\n"
s.add "]\n\nconst localeCellField*: array[" & $cellField.len & ", uint8] = [" & numbers(cellField) & "]\n"
s.add "\nconst localeCellValue*: array[" & $cellValue.len & ", uint16] = [" & numbers(cellValue) & "]\n"
writeFile(srcDir / "locales.nim", s)
var bytes = cellField.len * 3
for v in pool: bytes += v.len + 1
echo "locales.nim: ", names.len, " locales, ", pool.len, " values, ", cellField.len, " cells, ", bytes, " bytes of data"
