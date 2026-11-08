## Formatting values: plain functions that turn numbers into text (`formatNumber`, `formatPercent`,
## ..., usable on their own, like Great Tables' `vals`), and the `fmt*` verbs that attach them to
## columns and rows of a table. A verb resolves its columns and rows when it is called, and the
## formats run when the table is rendered: the last format given for a cell wins.

import std/[strutils, math, times, sequtils, strformat]
from std/unicode import Rune, `$`
import core

# ----------------------------------------------------------------------------------- locales

type Marks* = tuple[sep, dec: string]

func localeMarks*(locale: string): Marks =
  ## Digit group and decimal marks for a locale ("en", "it", "de", "fr", "ch", ...).
  case locale.toLowerAscii.split({'-', '_'})[0]
  of "", "en", "ja", "zh", "ko", "he", "th": (",", ".")
  of "it", "de", "es", "nl", "da", "id", "tr", "el", "pt", "ro", "sl", "hr", "sr": (".", ",")
  of "fr", "nb", "sv", "fi", "cs", "pl", "ru", "uk", "sk", "hu", "bg", "et", "lt", "lv": (" ", ",")
  of "ch", "rm": ("’", ".")
  else: (",", ".")

func escapeHtml*(s: string): string =
  s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"), ("\"", "&quot;"))

# ---------------------------------------------------------------------------- value formatting

func groupDigits(intPart, sep: string): string =
  if sep.len == 0 or intPart.len <= 3: return intPart
  let first = intPart.len mod 3
  if first > 0: result.add intPart[0 ..< first]
  var i = first
  while i < intPart.len:
    if result.len > 0: result.add sep
    result.add intPart[i ..< i + 3]
    i += 3

func formatNumber*(x: float, decimals = 2, useSeps = true, dropTrailingZeros = false,
                   sepMark = ",", decMark = ".", forceSign = false): string =
  ## `formatNumber(1234.5678)` is "1,234.57"; `formatNumber(1234.5, 1, sepMark = ".", decMark = ",")`
  ## is "1.234,5".
  if x.isNaN: return "NaN"
  if x.classify == fcInf: return "∞"
  if x.classify == fcNegInf: return "−∞"
  let s = formatFloat(abs(x), ffDecimal, decimals)
  var (ip, fp) = (s, "")
  let dot = s.find('.')
  if dot >= 0: (ip, fp) = (s[0 ..< dot], s[dot + 1 .. ^1])
  if dropTrailingZeros: fp = fp.strip(leading = false, chars = {'0'})
  let negative = x < 0 and (ip.anyIt(it in {'1'..'9'}) or fp.anyIt(it in {'1'..'9'}))
  result = (if negative: "−" elif forceSign and x > 0: "+" else: "") &
           groupDigits(ip, if useSeps: sepMark else: "")
  if fp.len > 0: result.add decMark & fp

func formatCompact*(x: float, decimals = 1, decMark = "."): string =
  ## Large numbers with a suffix: 1234567 is "1.2M".
  const suffixes = [(1e12, "T"), (1e9, "B"), (1e6, "M"), (1e3, "K")]
  for (scale, suffix) in suffixes:
    if abs(x) >= scale:
      return formatNumber(x / scale, decimals, dropTrailingZeros = true, decMark = decMark) & suffix
  formatNumber(x, decimals, dropTrailingZeros = true, decMark = decMark)

func superscript(s: string): string =
  const digits = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]
  for c in s:
    if c in {'0'..'9'}: result.add digits[ord(c) - ord('0')]
    elif c == '-': result.add "⁻"
    elif c == '+': discard
    else: result.add c

func formatScientific*(x: float, decimals = 2, decMark = ".", ctx = rcText): string =
  ## `formatScientific(5.97e24)` is "5.97 × 10²⁴".
  if x == 0: return formatNumber(0, decimals, decMark = decMark)
  let e = floor(log10(abs(x)))
  var m = x / pow(10.0, e)
  var ei = int(e)
  if round(abs(m), decimals) >= 10: (m /= 10; inc ei)
  let mant = formatNumber(m, decimals, decMark = decMark)
  if ei == 0: return mant
  if ctx == rcHtml: mant & " × 10<sup>" & (if ei < 0: "−" & $(-ei) else: $ei) & "</sup>"
  else: mant & " × 10" & superscript($ei)

func formatPercent*(x: float, decimals = 1, scaleValues = true, decMark = ".", sepMark = ","): string =
  formatNumber(if scaleValues: x * 100 else: x, decimals, sepMark = sepMark, decMark = decMark) & "%"

const currencySymbols* = [("USD", "$"), ("EUR", "€"), ("GBP", "£"), ("JPY", "¥"), ("CHF", "CHF "),
                          ("CNY", "¥"), ("INR", "₹"), ("BRL", "R$"), ("KRW", "₩"), ("ITL", "L. ")]

func currencySymbol*(code: string): string =
  for (c, s) in currencySymbols:
    if c == code.toUpperAscii: return s
  code

func formatCurrency*(x: float, currency = "USD", decimals = -1, sepMark = ",", decMark = ".",
                     placement = "left"): string =
  ## `formatCurrency(49.95, "EUR")` is "€49.95"; `decimals = -1` picks 0 for JPY and ITL, else 2.
  let d = if decimals >= 0: decimals elif currency.toUpperAscii in ["JPY", "KRW", "ITL"]: 0 else: 2
  let sym = currencySymbol(currency)
  let n = formatNumber(abs(x), d, sepMark = sepMark, decMark = decMark)
  let sign = if x < 0: "−" else: ""
  if placement == "right": sign & n & " " & sym.strip else: sign & sym & n

func formatRoman*(n: int, upper = true): string =
  ## `formatRoman(2026)` is "MMXXVI".
  const table = [(1000, "M"), (900, "CM"), (500, "D"), (400, "CD"), (100, "C"), (90, "XC"),
                 (50, "L"), (40, "XL"), (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")]
  if n <= 0 or n >= 4000: return $n
  var r = n
  for (v, s) in table:
    while r >= v: (result.add s; r -= v)
  if not upper: result = result.toLowerAscii

const dateStyles* = [
  ("iso", "yyyy-MM-dd"), ("wday_month_day_year", "dddd, MMMM d, yyyy"), ("month_day_year", "MMMM d, yyyy"),
  ("day_month_year", "d MMMM yyyy"), ("day_m_year", "d MMM yyyy"), ("m_day_year", "MMM d, yyyy"),
  ("year_month", "MMMM yyyy"), ("dd/mm/yyyy", "dd/MM/yyyy"), ("mm/dd/yyyy", "MM/dd/yyyy")]

proc formatDate*(s: string, dateStyle = "iso"): string =
  ## An ISO date ("2015-01-15", or the date part of a datetime) in one of `dateStyles`, or in any
  ## std/times pattern. Text that is not a date is returned as is.
  var pattern = dateStyle
  for (name, p) in dateStyles:
    if name == dateStyle: pattern = p
  try:
    let d = parse(s.strip[0 ..< min(10, s.strip.len)], "yyyy-MM-dd")
    d.format(pattern)
  except CatchableError:
    s


func formatInteger*(x: float, useSeps = true, sepMark = ","): string =
  ## `formatInteger(1234.6)` is "1,235".
  formatNumber(x, 0, useSeps, sepMark = sepMark)

func formatEngineering*(x: float, decimals = 2, decMark = ".", ctx = rcText): string =
  ## Scientific notation with exponents in steps of three: `formatEngineering(12345)` is
  ## "12.35 × 10³".
  if x == 0 or x.isNaN or x.classify in {fcInf, fcNegInf}: return formatNumber(x, decimals, decMark = decMark)
  var e = int(floor(log10(abs(x)) / 3)) * 3
  var m = x / pow(10.0, float(e))
  if round(abs(m), decimals) >= 1000: (m /= 1000; e += 3)
  let mant = formatNumber(m, decimals, decMark = decMark)
  if e == 0: return mant
  if ctx == rcHtml: mant & " × 10<sup>" & (if e < 0: "−" & $(-e) else: $e) & "</sup>"
  else: mant & " × 10" & superscript($e)

const siPrefixes = ["q", "r", "y", "z", "a", "f", "p", "n", "µ", "m", "", "k", "M", "G", "T", "P",
                    "E", "Z", "Y", "R", "Q"]

func formatNumberSi*(x: float, unit = "", decimals = 2, inclSpace = true, decMark = "."): string =
  ## A number with an SI prefix: `formatNumberSi(12345, "g")` is "12.35 kg".
  var k = 0
  if x != 0 and not x.isNaN and x.classify notin {fcInf, fcNegInf}:
    k = clamp(int(floor(log10(abs(x)) / 3)), -10, 10)
  var m = x / pow(10.0, float(3 * k))
  if round(abs(m), decimals) >= 1000 and k < 10: (m /= 1000; inc k)
  let suffix = siPrefixes[k + 10] & unit
  formatNumber(m, decimals, decMark = decMark) & (if suffix.len == 0: "" elif inclSpace: " " else: "") & suffix

const partsPer = [("per-mille", 1e3, "‰"), ("per-myriad", 1e4, "‱"), ("pcm", 1e5, "pcm"),
                  ("ppm", 1e6, "ppm"), ("ppb", 1e9, "ppb"), ("ppt", 1e12, "ppt"), ("ppq", 1e15, "ppq")]

func formatPartsper*(x: float, toUnits = "per-mille", decimals = 2, scaleValues = true,
                     inclSpace = "auto", decMark = ".", sepMark = ","): string =
  ## Fractions as parts per thousand ("per-mille", ‰), ten thousand ("per-myriad", ‱), hundred
  ## thousand ("pcm"), million ("ppm"), billion ("ppb"), trillion ("ppt") or quadrillion ("ppq").
  ## `inclSpace = "auto"` puts a space before the letters and none before ‰ and ‱.
  for (name, scale, sym) in partsPer:
    if name == toUnits:
      let space = if inclSpace == "auto": sym.len > 0 and sym[0] in {'a'..'z'} else: inclSpace in ["true", "yes"]
      return formatNumber(if scaleValues: x * scale else: x, decimals, sepMark = sepMark, decMark = decMark) &
        (if space: " " else: "") & sym
  raise newException(ValueError, "unknown parts-per unit " & toUnits.escape)

func formatBytes*(x: float, standard = "decimal", decimals = 1, inclSpace = true, decMark = "."): string =
  ## Sizes in bytes: `formatBytes(1500)` is "1.5 kB", `formatBytes(1536, "binary")` is "1.5 KiB".
  let (base, units) = if standard == "binary": (1024.0, ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"])
                      else: (1000.0, ["B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"])
  var k = 0
  var v = x
  while abs(v) >= base and k < units.high: (v /= base; inc k)
  if k > 0 and round(abs(v), decimals) >= base and k < units.high: (v /= base; inc k)
  let n = if k == 0: formatNumber(v, 0, useSeps = false) else: formatNumber(v, decimals, false, true, "", decMark)
  n & (if inclSpace: " " else: "") & units[k]

func formatIndex*(n: int, upper = true, indexAlgo = "repeat"): string =
  ## Letters for 1, 2, 3, ...: "A", "B", ... "Z", then "AA", "BB" (`indexAlgo = "repeat"`) or
  ## "AA", "AB" (`"excel"`).
  if n <= 0: return $n
  if indexAlgo == "excel":
    var r = n
    while r > 0:
      result = $chr(ord('A') + (r - 1) mod 26) & result
      r = (r - 1) div 26
  else:
    result = $chr(ord('A') + (n - 1) mod 26)
    result = result.repeat((n - 1) div 26 + 1)
  if not upper: result = result.toLowerAscii

func formatSpelledNum*(n: int): string =
  ## Numbers from zero to one hundred in English words: `formatSpelledNum(42)` is "forty-two";
  ## other numbers stay as digits.
  const ones = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
                "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen",
                "eighteen", "nineteen"]
  const tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
  if n < 0 or n > 100: return $n
  if n == 100: return "one hundred"
  if n < 20: return ones[n]
  result = tens[n div 10]
  if n mod 10 > 0: result.add "-" & ones[n mod 10]

const timeStyles* = ["iso", "iso-short", "h_m_s_p", "h_m_p", "h_p", "h_m", "h_m_s"]
  ## Named time styles: 14:35:00, 14:35, 2:35:00 PM, 2:35 PM, 2 PM, 14:35, 14:35:00.

func splitDatetime(s: string): (string, string) =
  ## The date and the time of "2026-11-07T14:35:00", "2026-11-07 14:35" or "14:35".
  let t = s.strip
  if t.len >= 10 and t[4] == '-' and t[7] == '-':
    let rest = if t.len > 10: t[11 .. ^1] else: ""
    (t[0 ..< 10], rest)
  else: ("", t)

func parseClock(s: string): (int, int, int, bool) =
  ## Hours, minutes, seconds of "14:35" or "14:35:07.5"; false when it is not a time.
  let parts = s.strip.split({'Z', '+'})[0].split(':')
  if parts.len < 2 or parts.len > 3: return (0, 0, 0, false)
  try:
    let h = parseInt(parts[0])
    let m = parseInt(parts[1])
    let sec = if parts.len == 3: int(parseFloat(parts[2])) else: 0
    if h notin 0..23 or m notin 0..59 or sec notin 0..60: return (0, 0, 0, false)
    (h, m, sec, true)
  except ValueError: (0, 0, 0, false)

func formatTime*(s: string, timeStyle = "iso"): string =
  ## A time ("14:35", "14:35:07", or the time of an ISO datetime) in one of `timeStyles`. Text
  ## that is not a time is returned as is.
  let (h, m, sec, ok) = parseClock(splitDatetime(s)[1])
  if not ok: return s
  let h12 = (if h mod 12 == 0: 12 else: h mod 12)
  let ap = if h < 12: "AM" else: "PM"
  case timeStyle
  of "iso", "h_m_s": &"{h:02}:{m:02}:{sec:02}"
  of "iso-short", "h_m": &"{h:02}:{m:02}"
  of "h_m_s_p": &"{h12}:{m:02}:{sec:02} {ap}"
  of "h_m_p": &"{h12}:{m:02} {ap}"
  of "h_p": &"{h12} {ap}"
  else: raise newException(ValueError, "unknown time style " & timeStyle.escape)

proc formatDatetime*(s: string, dateStyle = "iso", timeStyle = "iso", sep = " "): string =
  ## An ISO datetime ("2026-11-07T14:35:00" or "2026-11-07 14:35") as a date and a time, in the
  ## date and time styles; a date without a time shows only the date.
  let (d, t) = splitDatetime(s)
  if d.len == 0: return s
  result = formatDate(d, dateStyle)
  if t.len > 0 and parseClock(t)[3]: result.add sep & formatTime(t, timeStyle)

const durationUnits = [("weeks", 604800.0, "w", "week"), ("days", 86400.0, "d", "day"),
                       ("hours", 3600.0, "h", "hour"), ("minutes", 60.0, "m", "minute"),
                       ("seconds", 1.0, "s", "second")]

func unitSeconds(name: string): float =
  for (n, secs, _, _) in durationUnits:
    if n == name: return secs
  raise newException(ValueError, "unknown duration unit " & name.escape)

func formatDuration*(x: float, inputUnits = "seconds", outputUnits: openArray[string] = [],
                     durationStyle = "narrow", trimZeroUnits = true, maxOutputUnits = 0): string =
  ## A length of time in weeks, days, hours, minutes and seconds: `formatDuration(7503)` is
  ## "2h 5m 3s"; `durationStyle` "wide" (2 hours 5 minutes 3 seconds), "colon-sep" (02:05:03)
  ## or "iso" (PT2H5M3S). The smallest output unit is rounded.
  if x.isNaN: return "NaN"
  let units = if outputUnits.len == 0:
                (if durationStyle == "colon-sep": @["hours", "minutes", "seconds"]
                 else: durationUnits.mapIt(it[0]))
              else: @outputUnits
  let total = abs(x) * unitSeconds(inputUnits)
  let smallest = unitSeconds(units[^1])
  var rest = round(total / smallest) * smallest
  var parts: seq[(string, int)]
  for u in units:
    let secs = unitSeconds(u)
    let n = int(floor(rest / secs + 1e-9))
    rest -= float(n) * secs
    parts.add (u, n)
  let sign = if x < 0 and parts.anyIt(it[1] > 0): "−" else: ""
  if durationStyle == "colon-sep":
    return sign & parts.mapIt(align($it[1], 2, '0')).join(":")
  var shown = if trimZeroUnits: parts.filterIt(it[1] > 0) else: parts
  if shown.len == 0: shown = @[parts[^1]]
  if maxOutputUnits > 0 and shown.len > maxOutputUnits: shown.setLen(maxOutputUnits)
  case durationStyle
  of "narrow":
    sign & shown.mapIt($it[1] & durationUnits[durationUnits.mapIt(it[0]).find(it[0])][2]).join(" ")
  of "wide":
    sign & shown.mapIt(block:
      let w = durationUnits[durationUnits.mapIt(it[0]).find(it[0])][3]
      $it[1] & " " & w & (if it[1] == 1: "" else: "s")).join(" ")
  of "iso":
    var date, time = ""
    for (u, n) in shown:
      case u
      of "weeks": date.add $n & "W"
      of "days": date.add $n & "D"
      of "hours": time.add $n & "H"
      of "minutes": time.add $n & "M"
      else: time.add $n & "S"
    sign & "P" & date & (if time.len > 0: "T" & time else: "")
  else: raise newException(ValueError, "unknown duration style " & durationStyle.escape)

const tfStyles* = [("true-false", "true", "false"), ("yes-no", "yes", "no"), ("up-down", "up", "down"),
                   ("check-mark", "✓", "✗"), ("circles", "●", "○"), ("squares", "■", "□"),
                   ("diamonds", "◆", "◇"), ("arrows", "↑", "↓"), ("triangles", "▲", "▼"),
                   ("triangles-lr", "▶", "◀")]
  ## Named pairs of texts for booleans, as gt's `tf_style`.

func formatTf*(b: bool, tfStyle = "check-mark"): string =
  ## A boolean in one of `tfStyles`: `formatTf(true, "yes-no")` is "yes".
  for (name, yes, no) in tfStyles:
    if name == tfStyle: return (if b: yes else: no)
  raise newException(ValueError, "unknown tf style " & tfStyle.escape)

func formatFlag*(codes: string, sep = " "): string =
  ## Two-letter country codes (ISO 3166-1 alpha-2, comma or space separated) as flag emoji:
  ## `formatFlag("IT")` is "🇮🇹". Anything else is left as it is.
  var flags: seq[string]
  for c in codes.split({',', ' '}):
    let code = c.strip.toUpperAscii
    if code.len == 0: continue
    if code.len != 2 or not code.allCharsInSet({'A'..'Z'}): flags.add c.strip; continue
    var f = ""
    for ch in code: f.add $Rune(0x1F1E6 + ord(ch) - ord('A'))
    flags.add f
  flags.join(sep)

func splitLink(s: string): (string, string) =
  ## The label and the address of "[label](address)", or ("", s).
  let t = s.strip
  if t.startsWith("[") and t.endsWith(")"):
    let j = t.find("](")
    if j > 0: return (t[1 ..< j], t[j + 2 ..< ^1])
  ("", t)

# --------------------------------------------------------------------------- inline markdown

func inlineMarkdown*(s: string): string =
  ## A small inline Markdown: `**bold**`, `*italic*`, `` `code` ``, `[text](url)`, `~sub~`, `^sup^`,
  ## and `<br>` for a line break.
  ## Enough for labels and notes, with no dependency (nimib's full Markdown is not needed here).
  var i = 0
  var open: seq[string]
  template toggle(tag: string) =
    if open.len > 0 and open[^1] == tag: (result.add "</" & tag & ">"; discard open.pop)
    else: (result.add "<" & tag & ">"; open.add tag)
  while i < s.len:
    let c = s[i]
    if c == '<' and s.continuesWith("<br>", i):
      result.add "<br>"; i += 4; continue
    if c == '\\' and i + 1 < s.len: (result.add escapeHtml($s[i + 1]); i += 2; continue)
    if c == '*' and i + 1 < s.len and s[i + 1] == '*': (toggle("strong"); i += 2; continue)
    if c == '*': (toggle("em"); inc i; continue)
    if c in {'~', '^'}:   # H~2~O, 10^24^: only when closed with no space between, as in Pandoc
      let tag = if c == '~': "sub" else: "sup"
      if open.len > 0 and open[^1] == tag: (toggle(tag); inc i; continue)
      let j = s.find(c, i + 1)
      if j > i + 1 and not s[i + 1 ..< j].anyIt(it in Whitespace):
        toggle(tag); inc i; continue
    if c == '`':
      let j = s.find('`', i + 1)
      if j > i:
        result.add "<code>" & escapeHtml(s[i + 1 ..< j]) & "</code>"
        i = j + 1; continue
    if c == '[':
      let j = s.find("](", i)
      let k = if j > 0: s.find(')', j) else: -1
      if j > 0 and k > 0:
        result.add "<a href=\"" & escapeHtml(s[j + 2 ..< k]) & "\">" & inlineMarkdown(s[i + 1 ..< j]) & "</a>"
        i = k + 1; continue
    result.add escapeHtml($c)
    inc i
  while open.len > 0: result.add "</" & open.pop & ">"

func textToHtml*(t: Text): string =
  case t.kind
  of tkPlain: escapeHtml(t.s)
  of tkMarkdown: inlineMarkdown(t.s)
  of tkHtml: t.s

func stripTags(s: string): string =
  var inTag = false
  for c in s:
    if c == '<': inTag = true
    elif c == '>': inTag = false
    elif not inTag: result.add c
  result.multiReplace(("&lt;", "<"), ("&gt;", ">"), ("&quot;", "\""), ("&amp;", "&"))

func textToPlain*(t: Text): string =
  case t.kind
  of tkPlain: t.s
  of tkMarkdown: stripTags(inlineMarkdown(t.s))
  of tkHtml: stripTags(t.s)

# ------------------------------------------------------------------------------------- verbs

proc targetRows(t: Tabella, rows: RowSel): seq[int] =
  if rows.kind == rsAll: @[] else: rows.resolve(t.data)

proc fmt*(t: sink Tabella, columns: ColSel, fn: FormatFn, rows = allRows()): Tabella =
  ## The general formatter: `fn(value, ctx)` gives the text of each (non-missing) cell.
  result = t
  result.formats.add FormatRule(columns: columns.resolve(result.data), rows: result.targetRows(rows), fn: fn)

proc fmt*(t: sink Tabella, columns: ColSel, fn: proc (v: Value): string, rows = allRows()): Tabella =
  ## A formatter that gives plain text (escaped in HTML): `t.fmt("moons", v => $v.i & " 🌙")`.
  let f = fn
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    (if ctx == rcHtml: escapeHtml(f(v)) else: f(v)), rows)

proc marksFor(t: Tabella, locale, sepMark, decMark: string): Marks =
  result = localeMarks(if locale.len > 0: locale else: t.locale)
  if sepMark.len > 0: result.sep = sepMark
  if decMark.len > 0: result.dec = decMark

func withPattern(s, pattern: string): string =
  if pattern == "{x}": s else: pattern.replace("{x}", s)

proc fmtNumber*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), decimals = 2,
                dropTrailingZeros = false, useSeps = true, scaleBy = 1.0, compact = false,
                pattern = "{x}", forceSign = false, locale = "", sepMark = "", decMark = ""): Tabella =
  ## Numbers with a fixed number of decimals and digit grouping: `fmtNumber("mass", decimals = 1)`.
  let m = t.marksFor(locale, sepMark, decMark)
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    let x = v.toFloat * scaleBy
    let s = if compact: formatCompact(x, decimals, m.dec)
            else: formatNumber(x, decimals, useSeps, dropTrailingZeros, m.sep, m.dec, forceSign)
    s.withPattern(pattern), rows)

proc fmtInteger*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), useSeps = true,
                 scaleBy = 1.0, pattern = "{x}", locale = "", sepMark = ""): Tabella =
  fmtNumber(t, columns, rows, decimals = 0, useSeps = useSeps, scaleBy = scaleBy, pattern = pattern,
            locale = locale, sepMark = sepMark)

proc fmtPercent*(t: sink Tabella, columns: ColSel, rows = allRows(), decimals = 1, scaleValues = true,
                 locale = ""): Tabella =
  ## Fractions as percentages: 0.123 is "12.3%" (`scaleValues = false` for values already in %).
  let m = t.marksFor(locale, "", "")
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatPercent(v.toFloat, decimals, scaleValues, m.dec, m.sep), rows)

proc fmtCurrency*(t: sink Tabella, columns: ColSel, rows = allRows(), currency = "USD", decimals = -1,
                  placement = "left", locale = ""): Tabella =
  let m = t.marksFor(locale, "", "")
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    escapeHtml(formatCurrency(v.toFloat, currency, decimals, m.sep, m.dec, placement)), rows)

proc fmtScientific*(t: sink Tabella, columns: ColSel, rows = allRows(), decimals = 2, locale = ""): Tabella =
  let m = t.marksFor(locale, "", "")
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatScientific(v.toFloat, decimals, m.dec, ctx), rows)

proc fmtRoman*(t: sink Tabella, columns: ColSel, rows = allRows(), upper = true): Tabella =
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatRoman(int(round(v.toFloat)), upper), rows)

proc fmtDate*(t: sink Tabella, columns: ColSel, rows = allRows(), dateStyle = "iso"): Tabella =
  ## ISO date strings in a `dateStyles` style ("month_day_year", ...) or a std/times pattern.
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    escapeHtml(formatDate($v, dateStyle)), rows)

proc fmtMarkdown*(t: sink Tabella, columns: ColSel, rows = allRows()): Tabella =
  ## Cell text as Markdown (inline: emphasis, code, links).
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if ctx == rcHtml: inlineMarkdown($v) else: $v, rows)

proc subMissing*(t: sink Tabella, columns: ColSel = everything(), rows = allRows(), missingText = "—"): Tabella =
  ## Shows missing values as `missingText` (by default they are blank).
  result = t
  let txt = missingText
  result.substitutions.add FormatRule(columns: columns.resolve(result.data), rows: result.targetRows(rows),
    nullsToo: true, fn: proc (v: Value, ctx: RenderContext): string =
      (if ctx == rcHtml: escapeHtml(txt) else: txt))

proc subZero*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), zeroText = "nil"): Tabella =
  ## Shows zeros as `zeroText`.
  result = t
  let txt = zeroText
  result.substitutions.add FormatRule(columns: columns.resolve(result.data), rows: result.targetRows(rows),
    fn: proc (v: Value, ctx: RenderContext): string =
      if v.isNumber and v.toFloat == 0: (if ctx == rcHtml: escapeHtml(txt) else: txt) else: "")


proc fmtEngineering*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), decimals = 2,
                     locale = ""): Tabella =
  ## Scientific notation with exponents in steps of three: 12345 is "12.35 × 10³".
  let m = t.marksFor(locale, "", "")
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatEngineering(v.toFloat, decimals, m.dec, ctx), rows)

proc fmtNumberSi*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), unit = "", decimals = 2,
                  inclSpace = true, locale = ""): Tabella =
  ## Numbers with SI prefixes and a unit: 12345 with `unit = "g"` is "12.35 kg".
  let m = t.marksFor(locale, "", "")
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    escapeHtml(formatNumberSi(v.toFloat, unit, decimals, inclSpace, m.dec)), rows)

proc fmtPartsper*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), toUnits = "per-mille",
                  decimals = 2, scaleValues = true, inclSpace = "auto", locale = ""): Tabella =
  ## Fractions as parts per thousand (‰), ten thousand (‱), million (ppm), ... see `formatPartsper`.
  let m = t.marksFor(locale, "", "")
  discard formatPartsper(0, toUnits)   # an unknown unit fails now, not when rendering
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    escapeHtml(formatPartsper(v.toFloat, toUnits, decimals, scaleValues, inclSpace, m.dec, m.sep)), rows)

proc fmtBytes*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), standard = "decimal",
               decimals = 1, inclSpace = true, locale = ""): Tabella =
  ## Sizes in bytes: kB, MB, GB (`standard = "decimal"`) or KiB, MiB, GiB (`"binary"`).
  let m = t.marksFor(locale, "", "")
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatBytes(v.toFloat, standard, decimals, inclSpace, m.dec), rows)

proc fmtIndex*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), upper = true,
               indexAlgo = "repeat"): Tabella =
  ## Whole numbers as letters: 1 is "A", 27 is "AA" (see `formatIndex`).
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatIndex(int(round(v.toFloat)), upper, indexAlgo), rows)

proc fmtSpelledNum*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows()): Tabella =
  ## Whole numbers from zero to one hundred in English words.
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatSpelledNum(int(round(v.toFloat))), rows)

proc fmtTime*(t: sink Tabella, columns: ColSel, rows = allRows(), timeStyle = "iso"): Tabella =
  ## Times ("14:35:00", or the time of a datetime) in one of `timeStyles`.
  discard formatTime("00:00", timeStyle)
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    escapeHtml(formatTime($v, timeStyle)), rows)

proc fmtDatetime*(t: sink Tabella, columns: ColSel, rows = allRows(), dateStyle = "iso", timeStyle = "iso",
                  sep = " "): Tabella =
  ## ISO datetimes as a date and a time, each in its style.
  discard formatTime("00:00", timeStyle)
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    escapeHtml(formatDatetime($v, dateStyle, timeStyle, sep)), rows)

proc fmtDuration*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), inputUnits = "seconds",
                  outputUnits: openArray[string] = [], durationStyle = "narrow", trimZeroUnits = true,
                  maxOutputUnits = 0): Tabella =
  ## Numbers as lengths of time: 7503 seconds is "2h 5m 3s" (see `formatDuration`).
  let units = @outputUnits
  discard formatDuration(0, inputUnits, units, durationStyle)
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatDuration(v.toFloat, inputUnits, units, durationStyle, trimZeroUnits, maxOutputUnits), rows)

proc linkFormat(t: sink Tabella, columns: ColSel, rows: RowSel, prefix, label: string, asButton: bool,
                color, target: string, showUnderline: bool): Tabella =
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    var (text, address) = splitLink($v)
    if label.len > 0: text = label
    if text.len == 0: text = address
    if ctx == rcText: return text
    var css: seq[string]
    if asButton:
      let fill = if color.len > 0: color else: "#4C7DAF"
      css.add ["display: inline-block", "padding: 2px 8px", "border-radius: 4px",
               "background-color: " & fill, "color: #FFFFFF", "text-decoration: none"]
    else:
      if color.len > 0: css.add "color: " & color
      if not showUnderline: css.add "text-decoration: none"
    let href = (if address.startsWith(prefix) or prefix.len == 0: address else: prefix & address)
    "<a href=\"" & escapeHtml(href) & "\"" & (if target.len > 0: " target=\"" & escapeHtml(target) & "\"" else: "") &
      (if css.len > 0: " style=\"" & css.join("; ") & "\"" else: "") & ">" & escapeHtml(text) & "</a>", rows)

proc fmtUrl*(t: sink Tabella, columns: ColSel, rows = allRows(), label = "", asButton = false, color = "",
             target = "", showUnderline = true): Tabella =
  ## Addresses as links: the address is the text, unless `label` is given or the cell is a
  ## Markdown link `[label](address)`; `asButton` draws them as small buttons.
  linkFormat(t, columns, rows, "", label, asButton, color, target, showUnderline)

proc fmtEmail*(t: sink Tabella, columns: ColSel, rows = allRows(), label = "", asButton = false,
               color = "", target = "", showUnderline = true): Tabella =
  ## Email addresses as `mailto:` links, as `fmtUrl` does for web addresses.
  linkFormat(t, columns, rows, "mailto:", label, asButton, color, target, showUnderline)

proc fmtFlag*(t: sink Tabella, columns: ColSel, rows = allRows(), sep = " ", useTitle = true): Tabella =
  ## Two-letter country codes as flag emoji (nothing is loaded); with `useTitle` the code is
  ## the HTML title, shown on hover.
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    let f = formatFlag($v, sep)
    if ctx == rcText or not useTitle: escapeHtml(f)
    else: "<span title=\"" & escapeHtml(($v).strip) & "\">" & escapeHtml(f) & "</span>", rows)

# ------------------------------------------------------------------------------ substitutions

func thresholdText(x: float): string =
  if abs(x) >= 1000: return formatCompact(x, 1)
  var d = 0
  while d < 12 and abs(round(x, d) - x) > 1e-12 * max(1.0, abs(x)): inc d
  formatNumber(x, d, useSeps = false)

proc subSmallVals*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), threshold = 0.01,
                   smallPattern = "<{x}", sign = "+"): Tabella =
  ## Shows numbers closer to zero than `threshold` (but not zero) as `smallPattern`, with the
  ## threshold for `{x}`: "<0.01". `sign = "-"` does the same for negative numbers ("<−0.01").
  result = t
  let neg = sign == "-"
  let txt = smallPattern.replace("{x}", (if neg: "−" else: "") & thresholdText(threshold))
  result.substitutions.add FormatRule(columns: columns.resolve(result.data), rows: result.targetRows(rows),
    fn: proc (v: Value, ctx: RenderContext): string =
      if not v.isNumber: return ""
      let x = v.toFloat
      if x != 0 and abs(x) < threshold and (x < 0) == neg: (if ctx == rcHtml: escapeHtml(txt) else: txt)
      else: "")

proc subLargeVals*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), threshold = 1e12,
                   largePattern = ">={x}", sign = "+"): Tabella =
  ## Shows numbers at or beyond `threshold` as `largePattern`: ">=1T". `sign = "-"` does the
  ## same for numbers at or below minus the threshold.
  result = t
  let neg = sign == "-"
  let txt = largePattern.replace("{x}", (if neg: "−" else: "") & thresholdText(threshold))
  result.substitutions.add FormatRule(columns: columns.resolve(result.data), rows: result.targetRows(rows),
    fn: proc (v: Value, ctx: RenderContext): string =
      if not v.isNumber: return ""
      let x = v.toFloat
      if (not neg and x >= threshold) or (neg and x <= -threshold): (if ctx == rcHtml: escapeHtml(txt) else: txt)
      else: "")

proc subValues*(t: sink Tabella, columns: ColSel = everything(), rows = allRows(),
                fn: proc (v: Value): bool, replacement: string): Tabella =
  ## Shows the values for which `fn` holds as `replacement`.
  result = t
  let (f, txt) = (fn, replacement)
  result.substitutions.add FormatRule(columns: columns.resolve(result.data), rows: result.targetRows(rows),
    fn: proc (v: Value, ctx: RenderContext): string =
      if f(v): (if ctx == rcHtml: escapeHtml(txt) else: txt) else: "")

proc subValues*[T](t: sink Tabella, columns: ColSel = everything(), rows = allRows(),
                   values: openArray[T], replacement: string): Tabella =
  ## Shows these values as `replacement`: `subValues(values = [-99], replacement = "n/a")`.
  let vs = toValues(values)
  subValues(t, columns, rows, proc (v: Value): bool = v in vs, replacement)

proc fmtTf*(t: sink Tabella, columns: ColSel, rows = allRows(), tfStyle = "check-mark", trueText = "",
            falseText = "", naText = "", colors: openArray[string] = [], html = false): Tabella =
  ## Booleans as two texts: a named `tfStyle` ("true-false", "yes-no", "check-mark", "circles",
  ## "arrows", ... see `tfStyles`) or your own `trueText` and `falseText`; `naText` for missing
  ## values; `colors` (for true, false) colour them in HTML; with `html = true` the texts are
  ## HTML (an SVG symbol, say) and are not escaped.
  var yes = formatTf(true, tfStyle)
  var no = formatTf(false, tfStyle)
  if trueText.len > 0: yes = trueText
  if falseText.len > 0: no = falseText
  let cs = @colors
  let raw = html
  result = fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if v.kind != vkBool: return escapeHtml($v)
    let txt = if v.b: yes else: no
    if ctx == rcText: return (if raw: textToPlain(Text(kind: tkHtml, s: txt)) else: txt)
    let h = if raw: txt else: escapeHtml(txt)
    let k = if v.b: 0 else: 1
    if k < cs.len: "<span style=\"color: " & cs[k] & "\">" & h & "</span>" else: h, rows)
  if naText.len > 0: result = result.subMissing(columns, rows, naText)

