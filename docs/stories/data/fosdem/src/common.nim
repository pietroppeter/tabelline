## What the extract_*.nim scripts share: reading files as text, the text of a piece of HTML,
## regular expressions with the groups of a match, and staging CSVs.
## Standard library only (std/re needs libpcre, as nanuq does).

import std/[re, strutils, unicode, os, htmlparser, sets, sequtils]
export Regex, strutils, os, sequtils

# ------------------------------------------------------------------------------------ text

proc utf8Replace*(s: string): string =
  ## `s` as UTF-8, each broken sequence replaced by U+FFFD (as Python's errors="replace").
  result = newStringOfCap(s.len)
  var i = 0
  while i < s.len:
    let b = s[i].ord
    if b < 0x80:
      result.add s[i]; inc i; continue
    var need = 0
    var lo = 0x80
    var hi = 0xBF
    case b
    of 0xC2..0xDF: need = 1
    of 0xE0: need = 2; lo = 0xA0
    of 0xE1..0xEC, 0xEE..0xEF: need = 2
    of 0xED: need = 2; hi = 0x9F
    of 0xF0: need = 3; lo = 0x90
    of 0xF1..0xF3: need = 3
    of 0xF4: need = 3; hi = 0x8F
    else: need = 0
    if need == 0:
      result.add "�"; inc i; continue
    var k = 1
    while k <= need:
      if i + k >= s.len: break
      let c = s[i + k].ord
      let (l, h) = if k == 1: (lo, hi) else: (0x80, 0xBF)
      if c < l or c > h: break
      inc k
    if k > need:
      result.add s[i ..< i + k]
    else:
      result.add "�"
    i += k

const cp1252 = [0x20AC, 0, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, 0x02C6, 0x2030, 0x0160,
                0x2039, 0x0152, 0, 0x017D, 0, 0, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013,
                0x2014, 0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0, 0x017E, 0x0178]

proc fromCp1252*(s: string): string =
  ## `s` read as Windows-1252, its five undefined bytes replaced by U+FFFD.
  for c in s:
    let b = c.ord
    if b < 0x80: result.add c
    elif b < 0xA0: result.add (if cp1252[b - 0x80] == 0: "�" else: $Rune(cp1252[b - 0x80]))
    else: result.add $Rune(b)

proc readText*(path: string): string =
  ## A file as Python reads it in text mode: UTF-8 with replacement, newlines as "\n".
  readFile(path).utf8Replace.replace("\r\n", "\n").replace("\r", "\n")

proc isPySpace(r: Rune): bool =
  r.int in 0x1C..0x1F or r.isWhiteSpace

proc pyStrip*(s: string): string =
  ## Python's `str.strip()`: Unicode whitespace at both ends.
  let rs = s.toRunes
  var a = 0
  var b = rs.len
  while a < b and rs[a].isPySpace: inc a
  while b > a and rs[b - 1].isPySpace: dec b
  $rs[a ..< b]

proc pySplit*(s: string): seq[string] =
  ## Python's `str.split()`: the words between runs of whitespace.
  var cur = ""
  for r in s.runes:
    if r.isPySpace:
      if cur.len > 0: result.add cur; cur = ""
    else: cur.add $r
  if cur.len > 0: result.add cur

proc chars*(s: string): int = s.runeLen   ## Python's len(): characters, not bytes

proc pyFind*(s, sub: string, start = 0): int =
  ## Python's `str.find`: a negative start counts from the end.
  var a = start
  if a < 0: a = max(0, s.len + a)
  if a > s.len: return -1
  s.find(sub, a)

proc sl*(s: string, a: int, b = int.high): string =
  ## Python's `s[a:b]`, negative bounds included.
  var x = a
  var y = b
  if x < 0: x = max(0, s.len + x)
  if y < 0: y = max(0, s.len + y)
  x = min(x, s.len)
  y = min(y, s.len)
  if y <= x: "" else: s[x ..< y]

proc capitalFirst*(s: string): string =
  ## The first character in upper case (Python's `r[:1].upper() + r[1:]`).
  if s.len == 0: return s
  let r = s.runeAt(0)
  ($r).toUpper & s[r.size .. ^1]

# ------------------------------------------------------------------------- regular expressions

type Match* = object
  ok*: bool
  first*, last*: int                 ## the whole match, `last` inclusive
  caps: seq[tuple[first, last: int]]
  src: string

proc rx*(p: string): Regex =
  ## A pattern as Python reads it on str: Unicode \w, \s, \d. (?s) and (?i) as in Python.
  re("(*UTF8)(*UCP)" & p, {})

proc search*(s: string, p: Regex, start = 0): Match =
  var caps: array[20, tuple[first, last: int]]
  let (a, b) = findBounds(s, p, caps, start)
  if a < 0: return Match(ok: false)
  Match(ok: true, first: a, last: b, caps: @caps, src: s)

proc match*(s: string, p: Regex): Match =
  ## Python's re.match: a match that starts where the string starts.
  result = search(s, p)
  if result.ok and result.first != 0: result = Match(ok: false)

proc fullmatch*(s: string, p: Regex): bool =
  let m = match(s, p)
  m.ok and m.last == s.len - 1

proc has*(m: Match, i: int): bool =
  ## Did group `i` take part in the match (Python: `m.group(i) is not None`)?
  m.ok and (i == 0 or m.caps[i - 1].first >= 0)

proc group*(m: Match, i = 0): string =
  if not m.has(i): return ""
  if i == 0: m.src[m.first .. m.last]
  else: m.src[m.caps[i - 1].first .. m.caps[i - 1].last]

proc start*(m: Match): int = m.first
proc stop*(m: Match): int = m.last + 1

iterator finditer*(s: string, p: Regex): Match =
  var at = 0
  while at <= s.len:
    let m = search(s, p, at)
    if not m.ok: break
    yield m
    at = if m.last >= m.first: m.last + 1 else: m.first + 1

proc findall*(s: string, p: Regex, g = 0): seq[string] =
  ## The matches, or group `g` of each (Python's findall with one group is `g = 1`).
  for m in finditer(s, p): result.add m.group(g)

proc sub*(s: string, p: Regex, by: string): string =
  ## Python's re.sub with a plain replacement.
  var at = 0
  for m in finditer(s, p):
    result.add s[at ..< m.first]
    result.add by
    at = m.last + 1
  result.add s[min(at, s.len) .. ^1]

proc resplit*(s: string, p: Regex): seq[string] =
  ## Python's re.split (patterns without groups).
  var at = 0
  for m in finditer(s, p):
    result.add s[at ..< m.first]
    at = m.last + 1
  result.add s[min(at, s.len) .. ^1]

# ------------------------------------------------------------------------------------ HTML

const legacy = ["AElig", "AMP", "Aacute", "Acirc", "Agrave", "Aring", "Atilde", "Auml", "COPY",
  "Ccedil", "ETH", "Eacute", "Ecirc", "Egrave", "Euml", "GT", "Iacute", "Icirc", "Igrave", "Iuml",
  "LT", "Ntilde", "Oacute", "Ocirc", "Ograve", "Oslash", "Otilde", "Ouml", "QUOT", "REG", "THORN",
  "Uacute", "Ucirc", "Ugrave", "Uuml", "Yacute", "aacute", "acirc", "acute", "aelig", "agrave",
  "amp", "aring", "atilde", "auml", "brvbar", "ccedil", "cedil", "cent", "copy", "curren", "deg",
  "divide", "eacute", "ecirc", "egrave", "eth", "euml", "frac12", "frac14", "frac34", "gt",
  "iacute", "icirc", "iexcl", "igrave", "iquest", "iuml", "laquo", "lt", "macr", "micro", "middot",
  "nbsp", "not", "ntilde", "oacute", "ocirc", "ograve", "ordf", "ordm", "oslash", "otilde", "ouml",
  "para", "plusmn", "pound", "quot", "raquo", "reg", "sect", "shy", "sup1", "sup2", "sup3", "szlig",
  "thorn", "times", "uacute", "ucirc", "ugrave", "uml", "uuml", "yacute", "yen", "yuml"].toHashSet

let charref = rx"&(#[0-9]+;?|#[xX][0-9a-fA-F]+;?|[^\t\n\f <&#;]{1,32};?)"

proc entity(name: string): string =
  ## A named reference ("amp;" or a legacy "amp"), as Python's html5 table: "" when unknown.
  if name.endsWith(";"):
    let r = entityToRune(name[0 ..< ^1])
    if r.int != 0: return $r
  elif name in legacy:
    return $entityToRune(name)

proc numeric(num: int): string =
  const invalid = [(0x00, 0xFFFD), (0x0d, 0x0D), (0x80, 0x20AC), (0x81, 0x81), (0x82, 0x201A),
    (0x83, 0x0192), (0x84, 0x201E), (0x85, 0x2026), (0x86, 0x2020), (0x87, 0x2021), (0x88, 0x02C6),
    (0x89, 0x2030), (0x8a, 0x0160), (0x8b, 0x2039), (0x8c, 0x0152), (0x8d, 0x8D), (0x8e, 0x017D),
    (0x8f, 0x8F), (0x90, 0x90), (0x91, 0x2018), (0x92, 0x2019), (0x93, 0x201C), (0x94, 0x201D),
    (0x95, 0x2022), (0x96, 0x2013), (0x97, 0x2014), (0x98, 0x02DC), (0x99, 0x2122), (0x9a, 0x0161),
    (0x9b, 0x203A), (0x9c, 0x0153), (0x9d, 0x9D), (0x9e, 0x017E), (0x9f, 0x0178)]
  for (n, r) in invalid:
    if n == num: return $Rune(r)
  if num in 0xD800..0xDFFF or num > 0x10FFFF: return "�"
  if num in 0x1..0x8 or num in 0xE..0x1F or num in 0x7F..0x9F or num in 0xFDD0..0xFDEF or
     num == 0xB or (num and 0xFFFE) == 0xFFFE: return ""
  $Rune(num)

proc htmlUnescape*(s: string): string =
  ## Python's html.unescape.
  if '&' notin s: return s
  var at = 0
  for m in finditer(s, charref):
    result.add s[at ..< m.first]
    at = m.last + 1
    let r = m.group(1)
    if r[0] == '#':
      let digits = r.strip(leading = false, chars = {';'})
      let hex = digits[1] in {'x', 'X'}
      let ds = if hex: digits[2 .. ^1] else: digits[1 .. ^1]
      let significant = ds.strip(trailing = false, chars = {'0'})
      if significant.len > 8: result.add "�"
      else: result.add numeric(if significant.len == 0: 0 elif hex: parseHexInt(significant) else: parseInt(significant))
    else:
      let e = entity(r)
      if e.len > 0: result.add e
      else:
        var done = false
        for x in countdown(r.len - 1, 2):
          let e = entity(r[0 ..< x])
          if e.len > 0:
            result.add e & r[x .. ^1]; done = true; break
        if not done: result.add "&" & r
  result.add s[at .. ^1]

let tags = rx"<[^>]+>"
let spaces* = rx"\s+"

proc text*(s: string): string =
  ## The text of a piece of HTML: tags out, references resolved, whitespace collapsed.
  s.sub(tags, " ").htmlUnescape.sub(spaces, " ").pyStrip

# ------------------------------------------------------------------------------------ CSV

proc field(f: string): string =
  if f.contains({',', '"', '\r', '\n'}): '"' & f.replace("\"", "\"\"") & '"' else: f

proc writeCsv*(dir, name: string, header: openArray[string], rows: seq[seq[string]]) =
  ## A staging CSV as Python's csv module writes it (minimal quoting, "\r\n" line endings).
  createDir(dir)
  var s = header.join(",") & "\r\n"
  for r in rows:
    s.add (if r.len == 1 and r[0] == "": "\"\"" else: r.mapIt(it.field).join(",")) & "\r\n"
  writeFile(dir / name, s)

proc counts*(xs: seq[int]): string =
  ## How many rows each year has, for the line a script prints.
  var years: seq[int]
  for x in xs:
    if x notin years: years.add x
  for y in years: result.add $y & ": " & $xs.count(y) & "  "

proc rxEscape*(s: string): string =
  ## `s` as a literal in a pattern.
  for c in s:
    if c.isAlphaNumeric or c.ord >= 128: result.add c
    else: result.add '\\' & c
