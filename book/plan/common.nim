## What book/plan/plan.nim and book/plan/contest.nim share: regular expressions that read as
## Python's (Unicode words and spaces), files read as UTF-8, fetching with curl and git into
## book/plan/cache/, and JSON written as the files have always been written (indent 1, UTF-8).
import std/[os, osproc, re, strutils, json, unicode, tables, sequtils, streams]
export re, json, os, strutils, tables, sequtils

const
  here* = currentSourcePath().parentDir
  root* = here.parentDir.parentDir
  cache* = here / "cache"

# ---------------------------------------------------------------- regular expressions
# PCRE in UTF-8 and Unicode mode, as Python's `re` on text: `\w`, `\s` and `\b` know letters
# beyond ASCII. `rx` caches the compiled expressions.

var compiled: Table[(string, set[RegexFlag]), Regex]

proc rx*(pattern: string, flags: set[RegexFlag] = {}): Regex =
  let key = (pattern, flags)
  if key notin compiled:
    compiled[key] = re("(*UTF8)(*UCP)" & pattern, flags + {reStudy})
  compiled[key]

type Match* = object
  s: string
  first*, last*: int                 ## the match is s[first ..< last]
  groups: seq[tuple[first, last: int]]  ## first = -1: the group did not take part

proc found*(m: Match): bool = m.first >= 0
proc text*(m: Match): string = m.s[m.first ..< m.last]
proc has*(m: Match, i: int): bool = m.groups[i - 1].first >= 0
proc group*(m: Match, i: int): string =
  ## Group `i` (from 1), "" when it did not take part (Python's None, as the scripts use it).
  let g = m.groups[i - 1]
  if g.first < 0: "" else: m.s[g.first .. g.last]
proc `[]`*(m: Match, i: int): string = m.group(i)

proc search*(s: string, r: Regex, start = 0): Match =
  ## The first match in `s` from `start` (Python's `re.search`); `found` says if there is one.
  var groups = newSeq[tuple[first, last: int]](20)
  for g in groups.mitems: g = (-1, 0)
  let (a, b) = findBounds(s, r, groups, start)
  result = Match(s: s, first: a, last: b + 1, groups: groups)
  if a < 0: result.first = -1

proc search*(s, pattern: string, flags: set[RegexFlag] = {}): Match = s.search(rx(pattern, flags))

proc matchStart*(s, pattern: string, flags: set[RegexFlag] = {}): Match =
  ## Python's `re.match`: a match that starts at the start.
  s.search(rx("\\A(?:" & pattern & ")", flags))

proc fullMatch*(s, pattern: string, flags: set[RegexFlag] = {}): bool =
  ## Python's `re.fullmatch`.
  s.search(rx("\\A(?:" & pattern & ")\\z", flags)).found

proc has*(s, pattern: string, flags: set[RegexFlag] = {}): bool = s.search(pattern, flags).found

iterator finditer*(s: string, r: Regex): Match =
  ## Every match, not overlapping, from the start (Python's `re.finditer`).
  var start = 0
  while start <= s.len:
    let m = s.search(r, start)
    if not m.found: break
    yield m
    start = if m.last > m.first: m.last else: m.last + 1

iterator finditer*(s, pattern: string, flags: set[RegexFlag] = {}): Match =
  for m in s.finditer(rx(pattern, flags)): yield m

proc findAll1*(s, pattern: string, flags: set[RegexFlag] = {}): seq[string] =
  ## Python's `re.findall` for a pattern with one group.
  for m in s.finditer(pattern, flags): result.add m[1]

proc sub*(s, pattern, by: string, flags: set[RegexFlag] = {}): string =
  ## Python's `re.sub` with a plain replacement (no group references).
  var last = 0
  for m in s.finditer(pattern, flags):
    result.add s[last ..< m.first]
    result.add by
    last = m.last
  result.add s[last .. ^1]

# ---------------------------------------------------------------- text

proc utf8*(s: string): string =
  ## `s` as valid UTF-8: a byte that is not becomes U+FFFD (Python's `errors="replace"`).
  if validateUtf8(s) < 0: return s
  var i = 0
  while i < s.len:
    let c = s[i].uint8
    var n = 0
    if c < 0x80: n = 1
    elif c shr 5 == 0b110: n = 2
    elif c shr 4 == 0b1110: n = 3
    elif c shr 3 == 0b11110: n = 4
    if n > 0 and i + n <= s.len and validateUtf8(s[i ..< i + n]) < 0:
      result.add s[i ..< i + n]
      i += n
    else:
      result.add "\u{FFFD}"
      inc i

proc readText*(path: string): string = utf8(readFile(path))

proc ustrip*(s: string): string = unicode.strip(s)
  ## Python's `str.strip()`: Unicode spaces too.

proc ulower*(s: string): string = unicode.toLower(s)

const entities = {"amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": "\u00A0",
  "ndash": "–", "mdash": "—", "hellip": "…", "lsquo": "‘", "rsquo": "’", "ldquo": "“",
  "rdquo": "”", "laquo": "«", "raquo": "»", "middot": "·", "bull": "•", "copy": "©",
  "reg": "®", "trade": "™", "times": "×", "eacute": "é", "egrave": "è", "aacute": "á",
  "agrave": "à", "iacute": "í", "oacute": "ó", "uacute": "ú", "ntilde": "ñ", "uuml": "ü",
  "ouml": "ö", "auml": "ä", "ccedil": "ç", "deg": "°", "rarr": "→", "larr": "←"}.toTable

proc unescapeHtml*(s: string): string =
  ## Python's `html.unescape`, for the entities that pages use.
  var last = 0
  for m in s.finditer(r"&(#[0-9]+;?|#[xX][0-9a-fA-F]+;?|[A-Za-z][A-Za-z0-9]*;)"):
    result.add s[last ..< m.first]
    let e = m[1].strip(chars = {';'}, leading = false)
    var r = ""
    if e.startsWith("#x") or e.startsWith("#X"): r = $Rune(parseHexInt(e[2 .. ^1]))
    elif e.startsWith("#"): r = $Rune(parseInt(e[1 .. ^1]))
    else: r = entities.getOrDefault(e)
    result.add(if r.len > 0: r else: m.text)
    last = m.last
  result.add s[last .. ^1]

proc dirname*(p: string): string =
  ## Python's `os.path.dirname`.
  let i = p.rfind('/')
  if i < 0: "" else: p[0 ..< i]

proc basename*(p: string): string = p[p.rfind('/') + 1 .. ^1]

proc stem*(p: string): string =
  ## Python's `os.path.splitext(p)[0]`.
  let b = p.rfind('/')
  let d = p.rfind('.')
  if d > b + 1 and p[b + 1 ..< d].strip(chars = {'.'}).len > 0: p[0 ..< d] else: p

proc quoteUrl*(path: string): string =
  ## Python's `urllib.parse.quote`: everything but letters, digits, `_.-~` and `/` as %XX.
  for c in path:
    if c in {'a'..'z', 'A'..'Z', '0'..'9', '_', '.', '-', '~', '/'}: result.add c
    else: result.add "%" & toHex(ord(c), 2)

# ---------------------------------------------------------------- fetching

proc run*(cmd: string, args: openArray[string], dir = ""): tuple[output: string, code: int] =
  let p = startProcess(cmd, workingDir = dir, args = args, options = {poUsePath, poStdErrToStdOut})
  result.output = p.outputStream.readAll
  result.code = p.waitForExit
  p.close

proc curl*(url, path: string, accept = ""): bool =
  ## Downloads `url` into `path`; false when it fails.
  createDir path.parentDir
  var args = @["-sSfL", "--max-time", "30", "-o", path]
  if accept.len > 0: args.add ["-H", "Accept: " & accept]
  args.add url
  run("curl", args).code == 0

# ---------------------------------------------------------------- JSON as Python writes it

proc pyQuote(s: string): string =
  result = "\""
  for c in s:
    case c
    of '"': result.add "\\\""
    of '\\': result.add "\\\\"
    of '\n': result.add "\\n"
    of '\r': result.add "\\r"
    of '\t': result.add "\\t"
    of '\b': result.add "\\b"
    of '\f': result.add "\\f"
    of '\0'..'\7', '\11', '\14'..'\31': result.add "\\u" & toHex(ord(c), 4).toLowerAscii
    else: result.add c
  result.add "\""

proc pyJson*(n: JsonNode, level = 0): string =
  ## `json.dumps(n, indent=1, ensure_ascii=False)`.
  let pad = repeat(' ', level + 1)
  case n.kind
  of JObject:
    if n.len == 0: return "{}"
    var items: seq[string]
    for k, v in n: items.add pad & pyQuote(k) & ": " & pyJson(v, level + 1)
    "{\n" & items.join(",\n") & "\n" & repeat(' ', level) & "}"
  of JArray:
    if n.len == 0: return "[]"
    "[\n" & n.elems.mapIt(pad & pyJson(it, level + 1)).join(",\n") & "\n" & repeat(' ', level) & "]"
  of JString: pyQuote(n.str)
  of JInt: $n.num
  of JBool: (if n.bval: "true" else: "false")
  of JNull: "null"
  of JFloat: $n.fnum
