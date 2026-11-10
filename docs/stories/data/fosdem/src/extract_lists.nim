## Flatten the fosdem@lists.fosdem.org archive (mbox export, 2006-) into a staging CSV.
##
## Usage: extract_lists <fosdem.mbox> <stage dir>
## Keeps sender *names* only (no e-mail addresses) and no message bodies, apart from
## a few fields read from them: the FOSDEM year they mention and the first pretalx /
## CfP link. Cleaning and classification happen in nanuq (process.nim).
##
## It reads mail as Python's email package does (the compat32 policy, with which this
## table was first made): the same headers, the same text part, the same sender name.

import std/[algorithm, base64, encodings, unicode, sets, tables]
import common

let src = paramStr(1)
let stage = paramStr(2)

# --------------------------------------------------------------------------- the mbox

proc messages(mbox: string): seq[string] =
  ## Each message without its "From " line; the blank line before the next one is not part of it.
  var starts, stops: seq[int]
  var lastEmpty = false
  var pos = 0
  while true:
    if pos >= mbox.len:
      stops.add(if lastEmpty: pos - 1 else: pos)
      break
    let nl = mbox.find('\n', pos)
    let next = if nl < 0: mbox.len else: nl + 1
    if mbox.continuesWith("From ", pos):
      if stops.len < starts.len: stops.add(if lastEmpty: pos - 1 else: pos)
      starts.add pos
      lastEmpty = false
    elif next - pos == 1 and mbox[pos] == '\n': lastEmpty = true
    else: lastEmpty = false
    pos = next
  for i, a in starts:
    let nl = mbox.find('\n', a)
    let body = if nl < 0: mbox.len else: nl + 1
    result.add mbox[min(body, stops[i]) ..< stops[i]]

# ------------------------------------------------------------------------------ a message

type Part = ref object
  headers: seq[(string, string)]   # name, raw value (continuation lines kept)
  body: string                     # bytes; for a multipart, its parts instead
  parts: seq[Part]
  multipart: bool
  default: string                  # the content type when the part has none

proc toAscii(s: string): string =
  ## For matching a line of raw bytes: every 8-bit byte becomes \x01, which no pattern here takes.
  result = s
  for c in result.mitems:
    if c.ord >= 128: c = '\x01'

proc sl2(xs: seq[string]): seq[string] =
  ## Drop the empty last piece that a final line break leaves (as str.splitlines does).
  result = xs
  if result.len > 0 and result[^1].len == 0: discard result.pop

proc lines(s: string): seq[string] =
  ## Lines with their endings (\r\n, \r or \n), as the email parser splits them.
  var a = 0
  var i = 0
  while i < s.len:
    if s[i] == '\n':
      result.add s[a .. i]; a = i + 1
    elif s[i] == '\r':
      if i + 1 < s.len and s[i + 1] == '\n': inc i
      result.add s[a .. i]; a = i + 1
    inc i
  if a < s.len: result.add s[a .. ^1]

proc get(p: Part, name: string): (bool, string) =
  for (k, v) in p.headers:
    if cmpIgnoreCase(k, name) == 0: return (true, v)

proc params(value: string): seq[(string, string)] =
  ## Python's _parseparam and decode_params: the parameters of a header, values unquoted.
  var s = ";" & value
  var plist: seq[string]
  while s.len > 0 and s[0] == ';':
    s = s[1 .. ^1]
    var stop = s.find(';')
    while stop > 0 and (s[0 ..< stop].count('"') - s[0 ..< stop].count("\\\"")) mod 2 == 1:
      stop = s.find(';', stop + 1)
    if stop < 0: stop = s.len
    var f = s[0 ..< stop]
    let i = f.find('=')
    if i >= 0: f = f[0 ..< i].pyStrip.toLowerAscii & "=" & f[i + 1 .. ^1].pyStrip
    plist.add f.pyStrip
    s = s[stop .. ^1]
  for p in plist:
    let i = p.find('=')
    var (k, v) = if i < 0: (p.pyStrip, "") else: (p[0 ..< i].pyStrip, p[i + 1 .. ^1].pyStrip)
    if v.len > 1 and v[0] == '"' and v[^1] == '"':
      v = v[1 ..< ^1].replace("\\\\", "\\").replace("\\\"", "\"")
    result.add (k, v)

proc param(p: Part, name: string): (bool, string) =
  let (has, v) = p.get("content-type")
  if not has: return
  for (k, x) in params(v)[1 .. ^1]:
    if cmpIgnoreCase(k, name) == 0: return (true, x)

proc contentType(p: Part): string =
  let (has, v) = p.get("content-type")
  if not has: return p.default
  let t = v.split(';')[0].pyStrip.toLowerAscii
  if t.count('/') != 1: "text/plain" else: t

let headerLine = rx"^(From |[\x21-\x39\x3B-\x7E]*:|[\t ])"

proc parsePart(data: seq[string], default = "text/plain"): Part =
  result = Part(default: default)
  var i = 0
  var hs: seq[seq[string]]
  while i < data.len:
    let line = data[i]
    if not line.toAscii.search(headerLine).ok:
      if line in ["\n", "\r\n", "\r"]: inc i
      break
    if line[0] in {' ', '\t'}:
      if hs.len > 0: hs[^1].add line
    elif not (i == 0 and line.startsWith("From ")):
      hs.add @[line]
    inc i
  for h in hs:
    let c = h[0].find(':')
    if c <= 0: continue
    let value = (h[0][c + 1 .. ^1].strip(trailing = false, chars = {' ', '\t'}) & h[1 .. ^1].join).strip(leading = false, chars = {'\r', '\n'})
    result.headers.add (h[0][0 ..< c], value)
  let ctype = result.contentType
  let body = data[i .. ^1]
  if ctype.startsWith("multipart/"):
    let (has, b) = result.param("boundary")
    if has:
      let sep = rx("^" & rxEscape("--" & b.pyStrip) & r"(--)?[ \t]*(\r\n|\r|\n)?$")
      var cur: seq[string]
      var inPart = false
      var closed = false
      for line in body:
        let m = line.toAscii.search(sep)
        if m.ok:
          if inPart:
            if cur.len > 0: cur[^1] = cur[^1].strip(leading = false, chars = {'\r', '\n'})
            result.parts.add parsePart(cur, if ctype == "multipart/digest": "message/rfc822" else: "text/plain")
          cur = @[]
          inPart = true
          if m.has(1): closed = true; break
        elif inPart: cur.add line
      if inPart and not closed:
        result.parts.add parsePart(cur, if ctype == "multipart/digest": "message/rfc822" else: "text/plain")
      result.multipart = inPart
      if inPart: return
  elif ctype.startsWith("message/") and ctype != "message/delivery-status":
    result.parts.add parsePart(body)
    result.multipart = true
    return
  result.body = body.join

iterator walk(p: Part): Part =
  var stack = @[p]
  while stack.len > 0:
    let x = stack.pop
    yield x
    for i in countdown(x.parts.high, 0): stack.add x.parts[i]

# ------------------------------------------------------------------------------ decoding

proc qpDecode(s: string, header = false): string =
  ## binascii.a2b_qp.
  var i = 0
  while i < s.len:
    if s[i] == '=':
      inc i
      if i >= s.len: break
      if s[i] in {'\n', '\r'}:
        if s[i] != '\n':
          while i < s.len and s[i] != '\n': inc i
        if i < s.len: inc i
      elif s[i] == '=':
        result.add '='; inc i
      elif i + 1 < s.len and s[i] in HexDigits and s[i + 1] in HexDigits:
        result.add chr(parseHexInt(s[i .. i + 1])); i += 2
      else: result.add '='
    elif header and s[i] == '_':
      result.add ' '; inc i
    else:
      result.add s[i]; inc i

proc b64(s: string): (bool, string) =
  ## binascii.a2b_base64 (not strict): other characters skipped, stops at the padding.
  const alphabet = {'A'..'Z', 'a'..'z', '0'..'9', '+', '/'}
  var clean = ""
  var pads = 0
  for c in s:
    if c in alphabet:
      if pads > 0: break
      clean.add c
    elif c == '=':
      if clean.len mod 4 >= 2:
        inc pads
        if clean.len mod 4 + pads >= 4: break
  let r = clean.len mod 4
  if r == 1: return (false, "")
  if r != 0 and clean.len mod 4 + pads < 4: return (false, "")
  (true, base64.decode(clean & "=".repeat((4 - r) mod 4)))

proc decodeB(s: string): string =
  ## email._encoded_words.decode_b, as get_payload(decode=True) uses it.
  let (ok, v) = b64(s)
  if ok: return v
  let (ok2, v2) = b64(s & "==")
  if ok2: v2 else: s

proc latin1(s: string): string =
  for c in s: result.add $Rune(c.ord)

proc decodeAs(s, charset: string): (bool, string) =
  ## bytes.decode(charset, "replace"); false when Python does not know the charset.
  let cs = charset.toLowerAscii.replace("_", "-")
  case cs
  of "utf-8", "utf8", "u8", "utf", "utf-8-sig": (true, s.utf8Replace)
  of "us-ascii", "ascii", "646", "us":
    var r = ""
    for c in s: r.add(if c.ord < 128: $c else: "�")
    (true, r)
  of "iso-8859-1", "iso8859-1", "latin-1", "latin1", "l1", "8859", "cp819", "iso-ir-100", "latin":
    (true, latin1(s))
  of "windows-1252", "cp1252": (true, s.fromCp1252)
  else:
    try: (true, convert(s, "UTF-8", cs).utf8Replace)
    except CatchableError: (false, "")

proc rawUnicodeEscape(s: string): string =
  ## str.encode("raw-unicode-escape"): characters under 256 as one byte each.
  for r in s.runes:
    if r.int < 0x100: result.add chr(r.int)
    elif r.int < 0x10000: result.add "\\u" & toHex(r.int, 4).toLowerAscii
    else: result.add "\\U" & toHex(r.int, 8).toLowerAscii

proc isSpaceStr(s: string): bool = s.len > 0 and s.pyStrip.len == 0

proc lstrip(s: string): string =
  var i = 0
  for r in s.runes:
    if not (r.isWhiteSpace or r.int in 0x1C..0x1F): break
    i += r.size
  s[i .. ^1]

proc splitLinesPy(s: string): seq[string] =
  ## str.splitlines().
  s.resplit(rx"\r\n|[\n\r\x0b\x0c\x1c\x1d\x1e\x{85}\x{2028}\x{2029}]").sl2()

let ecre = rx"""=\?([^?]*?)\?([qQbB])\?(.*?)\?="""

proc qWord(w: string): string =
  ## email.quoprimime.header_decode, then raw-unicode-escape.
  let s = w.replace("_", " ")
  var r = ""
  var i = 0
  while i < s.len:
    if s[i] == '=' and i + 2 < s.len and s[i + 1] in HexDigits and s[i + 2] in HexDigits:
      r.add $Rune(parseHexInt(s[i + 1 .. i + 2])); i += 3
    else:
      r.add s[i]; inc i
  r.rawUnicodeEscape

proc decodeHeader(v: string): (bool, string) =
  ## email.header.decode_header, then each part decoded with its charset (utf-8 when it has none).
  if not v.search(ecre).ok: return (true, v)
  var words: seq[(string, string, string)]   # text, encoding ("" when not encoded), charset
  for line in v.splitLinesPy:
    var at = 0
    var first = true
    for m in line.finditer(ecre):
      var plain = line[at ..< m.start]
      if first: plain = plain.lstrip; first = false
      if plain.len > 0: words.add (plain, "", "")
      words.add (m.group(3), m.group(2).toLowerAscii, unicode.toLower(m.group(1)))
      at = m.stop
    var plain = line[at .. ^1]
    if first: plain = plain.lstrip
    if plain.len > 0: words.add (plain, "", "")
  var drop: seq[int]
  for n, w in words:
    if n > 1 and w[1].len > 0 and words[n - 2][1].len > 0 and words[n - 1][0].isSpaceStr:
      drop.add n - 1
  for d in drop.reversed: words.delete(d)
  var collapsed: seq[(string, string)]
  var have = false
  var lastWord, lastCs: string
  for (w, enc, cs) in words:
    var bytes: string
    case enc
    of "": bytes = w.rawUnicodeEscape
    of "q": bytes = qWord(w)
    else:
      var e = w
      if e.len mod 4 != 0: e.add "===".sl(0, 4 - e.len mod 4)
      let (ok, b) = b64(e.rawUnicodeEscape)
      if not ok: return (false, "")
      bytes = b
    if not have:
      lastWord = bytes; lastCs = cs; have = true
    elif cs != lastCs:
      collapsed.add (lastWord, lastCs); lastWord = bytes; lastCs = cs
    elif lastCs.len == 0: lastWord.add " " & bytes
    else: lastWord.add bytes
  collapsed.add (lastWord, lastCs)
  var s = ""
  for (b, cs) in collapsed:
    let (ok, t) = decodeAs(b, if cs.len > 0: cs else: "utf-8")
    if not ok: return (false, "")
    s.add t
  (true, s)

proc unknown8bit(raw: string): string =
  ## A header's 8-bit bytes become one U+FFFD each (a Header with the unknown-8bit charset).
  for c in raw: result.add(if c.ord < 128: $c else: "�")

proc dec(h: (bool, string)): string =
  ## The scripts' `dec`: a header decoded (RFC 2047), its whitespace collapsed.
  if not h[0]: return ""
  let v = unknown8bit(h[1])
  let (ok, s) = decodeHeader(v)
  (if ok: s else: v).sub(spaces, " ").pyStrip

# ---------------------------------------------------------------------- the sender's name

proc stripQuotedRealnames(a: string): string =
  if '"' notin a: return a
  var start = 0
  var open = -1
  var esc = false
  for pos, ch in a:
    if esc: esc = false; continue
    if ch == '\\': esc = true; continue
    if ch == '"':
      if open < 0: open = pos
      else:
        if start != open: result.add a[start ..< open]
        start = pos + 1; open = -1
  if start < a.len: result.add a[start .. ^1]

proc parenthesesOk(a: string): bool =
  var opens = 0
  var esc = false
  for ch in stripQuotedRealnames(a):
    if esc: esc = false; continue
    if ch == '\\': esc = true; continue
    if ch == '(': inc opens
    elif ch == ')':
      dec opens
      if opens < 0: return false
  opens == 0

type Addr = object
  f: string
  pos: int
  comments: seq[string]

const specials = "()<>@,:;.\"[]"
const lws = " \t"
const cr = "\r\n"
const atomends = specials & lws & cr
const phraseends = "()<>@,:;\"[]" & lws & cr

proc delimited(p: var Addr, begin: char, ends: string, comments: bool): string
proc comment(p: var Addr): string = p.delimited('(', ")\r", true)
proc delimited(p: var Addr, begin: char, ends: string, comments: bool): string =
  if p.f[p.pos] != begin: return ""
  var quote = false
  inc p.pos
  while p.pos < p.f.len:
    let c = p.f[p.pos]
    if quote: result.add c; quote = false
    elif c in ends: inc p.pos; break
    elif comments and c == '(': result.add p.comment; continue
    elif c == '\\': quote = true
    else: result.add c
    inc p.pos

proc gotonext(p: var Addr): string =
  while p.pos < p.f.len:
    let c = p.f[p.pos]
    if c in lws & "\n\r":
      if c notin "\n\r": result.add c
      inc p.pos
    elif c == '(': p.comments.add p.comment
    else: break

proc atom(p: var Addr, ends = atomends): string =
  while p.pos < p.f.len and p.f[p.pos] notin ends:
    result.add p.f[p.pos]; inc p.pos

proc phraselist(p: var Addr): seq[string] =
  while p.pos < p.f.len:
    let c = p.f[p.pos]
    if c in lws & cr: inc p.pos
    elif c == '"': result.add p.delimited('"', "\"\r", false)
    elif c == '(': p.comments.add p.comment
    elif c in phraseends: break
    else: result.add p.atom(phraseends)

proc domainLiteral(p: var Addr): string = "[" & p.delimited('[', "]\r", false) & "]"

proc domain(p: var Addr): string =
  while p.pos < p.f.len:
    let c = p.f[p.pos]
    if c in lws: inc p.pos
    elif c == '(': p.comments.add p.comment
    elif c == '[': result.add p.domainLiteral
    elif c == '.': inc p.pos; result.add '.'
    elif c == '@': return ""
    elif c in atomends: break
    else: result.add p.atom

proc addrspec(p: var Addr): string =
  var parts: seq[string]
  discard p.gotonext
  while p.pos < p.f.len:
    var keepWs = true
    let c = p.f[p.pos]
    if c == '.':
      if parts.len > 0 and parts[^1].strip.len == 0: discard parts.pop
      parts.add "."; inc p.pos; keepWs = false
    elif c == '"':
      parts.add "\"" & p.delimited('"', "\"\r", false).replace("\\", "\\\\").replace("\"", "\\\"") & "\""
    elif c in atomends:
      if parts.len > 0 and parts[^1].strip.len == 0: discard parts.pop
      break
    else: parts.add p.atom
    let ws = p.gotonext
    if keepWs and ws.len > 0: parts.add ws
  if p.pos >= p.f.len or p.f[p.pos] != '@': return parts.join
  inc p.pos
  discard p.gotonext
  let d = p.domain
  if d.len == 0: return ""
  parts.join & "@" & d

proc routeaddr(p: var Addr): string =
  if p.f[p.pos] != '<': return
  var route = false
  inc p.pos
  discard p.gotonext
  while p.pos < p.f.len:
    if route: discard p.domain; route = false
    elif p.f[p.pos] == '>': inc p.pos; break
    elif p.f[p.pos] == '@': inc p.pos; route = true
    elif p.f[p.pos] == ':': inc p.pos
    else:
      result = p.addrspec; inc p.pos; break
    discard p.gotonext

proc address(p: var Addr): seq[(string, string)] =
  p.comments = @[]
  discard p.gotonext
  let oldpos = p.pos
  let plist = p.phraselist
  discard p.gotonext
  if p.pos >= p.f.len:
    if plist.len > 0: result = @[(p.comments.join(" "), plist[0])]
  elif p.f[p.pos] in ".@":
    p.pos = oldpos
    let a = p.addrspec
    result = @[(p.comments.join(" "), a)]
  elif p.f[p.pos] == ':':
    inc p.pos
    while p.pos < p.f.len:
      discard p.gotonext
      if p.pos < p.f.len and p.f[p.pos] == ';':
        inc p.pos; break
      result.add p.address
  elif p.f[p.pos] == '<':
    let r = p.routeaddr
    if p.comments.len > 0: result = @[(plist.join(" ") & " (" & p.comments.join(" ") & ")", r)]
    else: result = @[(plist.join(" "), r)]
  else:
    if plist.len > 0: result = @[(p.comments.join(" "), plist[0])]
    elif p.f[p.pos] in specials: inc p.pos
  discard p.gotonext
  if p.pos < p.f.len and p.f[p.pos] == ',': inc p.pos

proc parseaddr(s: string): (string, string) =
  ## email.utils.parseaddr (strict, as in Python 3.13): ("", "") unless there is exactly one address.
  let a = if parenthesesOk(s): s else: "('', '')"
  var p = Addr(f: a)
  var list: seq[(string, string)]
  if a.len > 0:
    while p.pos < p.f.len:
      let ad = p.address
      if ad.len > 0: list.add ad else: list.add ("", "")
  for x in list.mitems:
    if '[' in x[1]: x = ("", "")
  if list.len != 1: ("", "") else: list[0]

# ---------------------------------------------------------------------------------- dates

const monthnames = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec",
                    "january", "february", "march", "april", "may", "june", "july", "august",
                    "september", "october", "november", "december"]
const daynames = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

proc parseDate(h: (bool, string)): (bool, int, int, int) =
  ## email.utils.parsedate_to_datetime: year, month and day as the header writes them.
  if not h[0] or h[1].anyIt(it.ord >= 128): return
  var data = h[1].pySplit
  if data.len == 0: return
  if data[0].endsWith(",") or data[0].toLowerAscii in daynames: data.delete(0)
  else:
    let i = data[0].rfind(',')
    if i >= 0: data[0] = data[0][i + 1 .. ^1]
  if data.len == 3:
    let stuff = data[0].split('-')
    if stuff.len == 3: data = stuff & data[1 .. ^1]
  if data.len == 4:
    let s = data[3]
    var i = s.find('+')
    if i == -1: i = s.find('-')
    if i > 0: data = data[0 ..< 3] & @[s[0 ..< i], s[i .. ^1]]
    else: data.add ""
  if data.len < 5: return
  var (dd, mm, yy, tm) = (data[0], data[1], data[2], data[3])
  if dd.len == 0 or mm.len == 0 or yy.len == 0: return
  mm = mm.toLowerAscii
  if mm notin monthnames:
    (dd, mm) = (mm, dd.toLowerAscii)
    if mm notin monthnames: return
  var month = monthnames.find(mm) + 1
  if month > 12: month -= 12
  if dd[^1] == ',': dd = dd[0 ..< ^1]
  if yy.find(':') > 0: (yy, tm) = (tm, yy)
  if yy.len > 0 and yy[^1] == ',': yy = yy[0 ..< ^1]
  if yy.len == 0: return
  if not yy[0].isDigit: yy = data[4]
  if tm.len > 0 and tm[^1] == ',': tm = tm[0 ..< ^1]
  let t = tm.split(':')
  if t.len notin 2..3 and not (t.len == 1 and '.' in t[0]): return
  var y, d: int
  try:
    y = parseInt(yy); d = parseInt(dd)
    let fields = if t.len == 1: t[0].split('.') else: t
    for x in fields: discard parseInt(x)
  except ValueError: return
  if y < 100: y += (if y > 68: 1900 else: 2000)
  const mdays = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  let leap = y mod 4 == 0 and (y mod 100 != 0 or y mod 400 == 0)
  if y < 1 or y > 9999 or d < 1 or d > mdays[month - 1] or (month == 2 and d == 29 and not leap): return
  (true, y, month, d)

# ---------------------------------------------------------------------------------- the table

proc body(p: Part): string =
  ## The first text/plain part, decoded with its charset.
  for x in p.walk:
    if x.contentType == "text/plain" and not x.multipart:
      let (_, cte0) = x.get("content-transfer-encoding")
      let cte = cte0.pyStrip.toLowerAscii
      let bytes = case cte
        of "quoted-printable": qpDecode(x.body)
        of "base64": decodeB(x.body.replace("\r\n", "").replace("\n", "").replace("\r", ""))
        else: x.body
      let (has, cs) = x.param("charset")
      let charset = if has and cs.len > 0: cs.toLowerAscii else: "utf-8"
      let (ok, t) = decodeAs(bytes, charset)
      return (if ok: t else: "")

var rows: seq[seq[string]]
for msg in messages(readFile(src)):
  let p = parsePart(lines(msg))
  let d = parseDate(p.get("date"))
  var (name, address) = parseaddr(dec(p.get("from")))
  name = name.pyStrip.strip(chars = {'"'}).strip(chars = {'\''})
  if name.len == 0 or '@' in name:
    name = if address.len > 0: address.split('@')[0] else: ""
    name = name.sub(rx"\s+at\s+.*", "")
  let subj = dec(p.get("subject"))
  let b = body(p)
  let head = b.toRunes
  let scan = subj & " " & $head[0 ..< min(3000, head.len)]
  var years: seq[int]
  for y in scan.findall(rx"(?i)FOSDEM\s*'?(20\d\d|\d\d)\b", 1):
    let v = if y.len == 4: parseInt(y) else: 2000 + parseInt(y)
    if v notin years: years.add v
  years.sort
  let link = b.search(rx"https?://(?:pretalx\.fosdem\.org|penta\.fosdem\.org)[^\s>)\]]*")
  let reply = subj.sub(rx"(?i)^\[FOSDEM\]\s*", "").match(rx"(?i)\s*(re|aw|sv)\s*:").ok
  rows.add @[(if d[0]: $d[1] & "-" & align($d[2], 2, '0') & "-" & align($d[3], 2, '0') else: ""),
             (if d[0]: $d[1] else: ""), name, subj, (if reply: "1" else: "0"), years.join(" "),
             link.group, $head.len]
rows.sort(proc (a, b: seq[string]): int = cmp(a[0], b[0]))
writeCsv(stage, "list_messages.csv", ["date", "year", "sender", "subject", "is_reply", "years_mentioned",
                                      "pretalx_link", "body_chars"], rows)
echo rows.len, " messages"
