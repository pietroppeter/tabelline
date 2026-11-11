## Formatting values: plain functions that turn numbers into text (`formatNumber`, `formatPercent`,
## ..., usable on their own, like Great Tables' `vals`), and the `fmt*` verbs that attach them to
## columns and rows of a table. A verb resolves its columns and rows when it is called, and the
## formats run when the table is rendered: the last format given for a cell wins.

import std/[strutils, math, times, sequtils, strformat]
from std/unicode import Rune, runes, runeLen, `$`
import core, countries, localize
export localize

# ----------------------------------------------------------------------------------- locales

type Marks* = tuple[sep, dec: string]

func localeMarks*(locale: string): Marks =
  ## Digit group and decimal marks for a locale, from CLDR: `localeMarks("it")` is (".", ","),
  ## `localeMarks("de-CH")` is ("'", "."), `localeMarks("fr")` is (" ", ",") with a narrow
  ## no-break space. An unknown locale, or "", is "en".
  let l = getLocale(locale)
  (l.group, l.decimal)

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

const
  superChars = [("0", "⁰"), ("1", "¹"), ("2", "²"), ("3", "³"), ("4", "⁴"), ("5", "⁵"), ("6", "⁶"),
    ("7", "⁷"), ("8", "⁸"), ("9", "⁹"), ("+", "⁺"), ("-", "⁻"), ("−", "⁻"), ("=", "⁼"), ("(", "⁽"),
    (")", "⁾"), ("a", "ᵃ"), ("b", "ᵇ"), ("c", "ᶜ"), ("d", "ᵈ"), ("e", "ᵉ"), ("f", "ᶠ"), ("g", "ᵍ"),
    ("h", "ʰ"), ("i", "ⁱ"), ("j", "ʲ"), ("k", "ᵏ"), ("l", "ˡ"), ("m", "ᵐ"), ("n", "ⁿ"), ("o", "ᵒ"),
    ("p", "ᵖ"), ("r", "ʳ"), ("s", "ˢ"), ("t", "ᵗ"), ("u", "ᵘ"), ("v", "ᵛ"), ("w", "ʷ"), ("x", "ˣ"),
    ("y", "ʸ"), ("z", "ᶻ"), (".", "·"), ("/", "ᐟ")]
  subChars = [("0", "₀"), ("1", "₁"), ("2", "₂"), ("3", "₃"), ("4", "₄"), ("5", "₅"), ("6", "₆"),
    ("7", "₇"), ("8", "₈"), ("9", "₉"), ("+", "₊"), ("-", "₋"), ("−", "₋"), ("=", "₌"), ("(", "₍"),
    (")", "₎"), ("a", "ₐ"), ("e", "ₑ"), ("h", "ₕ"), ("i", "ᵢ"), ("j", "ⱼ"), ("k", "ₖ"), ("l", "ₗ"),
    ("m", "ₘ"), ("n", "ₙ"), ("o", "ₒ"), ("p", "ₚ"), ("r", "ᵣ"), ("s", "ₛ"), ("t", "ₜ"), ("u", "ᵤ"),
    ("v", "ᵥ"), ("x", "ₓ")]

func script(s: string, chars: openArray[(string, string)], mark: string): string =
  ## `s` in Unicode super- or subscripts; when a character has none, `^s` or `_s` (with
  ## parentheses around a longer `s`).
  for r in s.runes:
    var found = false
    for (c, sc) in chars:
      if c == $r: (result.add sc; found = true; break)
    if not found:
      return mark & (if s.runeLen > 1: "(" & s & ")" else: s)

func toSuperscript*(s: string): string =
  ## `toSuperscript("-2")` is "⁻²" (`^s` when a character has no superscript).
  script(s, superChars, "^")

func toSubscript*(s: string): string =
  ## `toSubscript("2")` is "₂" (`_s` when a character has no subscript).
  script(s, subChars, "_")

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

func formatPercent*(x: float, decimals = 1, scaleValues = true, decMark = ".", sepMark = ",",
                    pattern = "#,##0%", percentSign = "%"): string =
  ## `formatPercent(0.123)` is "12.3%"; `pattern` is a locale's (`getLocale("fr").percentPattern`
  ## is "#,##0 %", with a no-break space).
  let (pre, suf) = splitPattern(pattern)
  let n = formatNumber(if scaleValues: x * 100 else: x, decimals, sepMark = sepMark, decMark = decMark)
  let sign = if n.startsWith("−"): "−" else: ""
  sign & pre.replace("%", percentSign) & n[sign.len .. ^1] & suf.replace("%", percentSign)

func currencySymbol*(code: string): string =
  ## The symbol of an ISO 4217 code, from CLDR (English): "EUR" is "€", "CHF" is "CHF", "CAD"
  ## is "CA$". An unknown code is its own symbol.
  currencyInfo(code).symbol

func formatCurrency*(x: float, currency = "USD", decimals = -1, sepMark = ",", decMark = ".",
                     placement = "", pattern = "¤#,##0.00", accounting = false,
                     useSubunits = true): string =
  ## `formatCurrency(49.95, "EUR")` is "€49.95". `decimals = -1` takes the currency's (0 for JPY,
  ## 3 for BHD, 2 for most); `useSubunits = false` drops them. The symbol goes where `pattern`
  ## puts it (a locale's `currencyPattern`: "#,##0.00 ¤" in Italian), or `placement` "left" or
  ## "right". `accounting` writes a negative amount in parentheses.
  let info = currencyInfo(currency)
  let d = if not useSubunits: 0 elif decimals >= 0: decimals else: info.digits
  let n = formatNumber(abs(x), d, sepMark = sepMark, decMark = decMark)
  let negative = x < 0 and n.anyIt(it in {'1'..'9'})
  let p = case placement
          of "left": "¤#,##0.00"
          of "right": "#,##0.00\u00A0¤"
          else: pattern
  result = withCurrency(n, info.symbol, p)
  if negative:
    result = if accounting: "(" & result & ")" else: "−" & result

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
  ("iso", "y-MM-dd"), ("wday_month_day_year", "EEEE, MMMM d, y"), ("wd_m_day_year", "EEE, MMM d, y"),
  ("wday_day_month_year", "EEEE d MMMM y"), ("month_day_year", "MMMM d, y"), ("m_day_year", "MMM d, y"),
  ("day_m_year", "d MMM y"), ("day_month_year", "d MMMM y"), ("day_month", "d MMMM"), ("day_m", "d MMM"),
  ("year", "y"), ("month", "LLLL"), ("day", "dd"), ("year.mn.day", "y/MM/dd"), ("y.mn.day", "yy/MM/dd"),
  ("year_week", "Y-'W'ww"), ("year_quarter", "y-'Q'Q"), ("year_month", "LLLL y"),
  ("dd/mm/yyyy", "dd/MM/y"), ("mm/dd/yyyy", "MM/dd/y")]
  ## gt's fixed date styles, as CLDR patterns, with names in the locale's language. The flexible
  ## ones (`dateSkeletons`: "yMMMd", "yMMMEd", ...) also follow the locale's order.

func parseIsoDate(s: string): (int, int, int, bool) =
  ## Year, month and day of "2015-01-15" (or the date part of a datetime).
  let t = s.strip
  if t.len < 10 or t[4] != '-' or t[7] != '-': return (0, 0, 0, false)
  try:
    let (y, m, d) = (parseInt(t[0 ..< 4]), parseInt(t[5 ..< 7]), parseInt(t[8 ..< 10]))
    if m notin 1..12 or d notin 1..getDaysInMonth(Month(m), y): return (0, 0, 0, false)
    (y, m, d, true)
  except ValueError: (0, 0, 0, false)

proc formatDate*(s: string, dateStyle = "iso", locale = ""): string =
  ## An ISO date ("2015-01-15", or the date part of a datetime) in one of `dateStyles`, a
  ## flexible style of `dateSkeletons` ("yMMMd"), or a std/times pattern (English names), in the
  ## language of `locale`: `formatDate("2015-01-15", "day_month_year", "it")` is "15 gennaio 2015".
  ## Text that is not a date is returned as is.
  let (y, m, d, ok) = parseIsoDate(s)
  if not ok: return s
  let l = getLocale(locale)
  var pattern = l.skeleton(dateStyle)
  if pattern.len == 0:
    for (name, p) in dateStyles:
      if name == dateStyle: pattern = p
  let weekday = (ord(getDayOfWeek(MonthdayRange(d), Month(m), y)) + 1) mod 7
  if pattern.len > 0:
    return formatPattern(l, pattern, y, m, d, weekday)
  try: dateTime(y, Month(m), MonthdayRange(d), zone = utc()).format(dateStyle)
  except CatchableError: s

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
  ## Named time styles: 14:35:00, 14:35, 2:35:00 PM, 2:35 PM, 2 PM, 14:35, 14:35:00. The
  ## flexible ones (`timeSkeletons`: "Hm", "hm", ...) follow the locale.

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

func formatTime*(s: string, timeStyle = "iso", locale = ""): string =
  ## A time ("14:35", "14:35:07", or the time of an ISO datetime) in one of `timeStyles` or
  ## `timeSkeletons`, with the locale's AM and PM: `formatTime("14:35", "hm", "it")` is "2:35 PM".
  ## Text that is not a time is returned as is.
  let (h, m, sec, ok) = parseClock(splitDatetime(s)[1])
  if not ok: return s
  let l = getLocale(locale)
  let h12 = (if h mod 12 == 0: 12 else: h mod 12)
  let ap = if h < 12: l.am else: l.pm
  case timeStyle
  of "iso", "h_m_s": &"{h:02}:{m:02}:{sec:02}"
  of "iso-short", "h_m": &"{h:02}:{m:02}"
  of "h_m_s_p": &"{h12}:{m:02}:{sec:02} {ap}"
  of "h_m_p": &"{h12}:{m:02} {ap}"
  of "h_p": &"{h12} {ap}"
  else:
    let p = if timeStyle in timeSkeletons: l.skeleton(timeStyle) else: ""
    if p.len == 0: raise newException(ValueError, "unknown time style " & timeStyle.escape)
    formatPattern(l, p, hour = h, minute = m, second = sec)

proc formatDatetime*(s: string, dateStyle = "iso", timeStyle = "iso", sep = " ", locale = ""): string =
  ## An ISO datetime ("2026-11-07T14:35:00" or "2026-11-07 14:35") as a date and a time, in the
  ## date and time styles; a date without a time shows only the date.
  let (d, t) = splitDatetime(s)
  if d.len == 0: return s
  result = formatDate(d, dateStyle, locale)
  if t.len > 0 and parseClock(t)[3]: result.add sep & formatTime(t, timeStyle, locale)

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
  ## Country codes (ISO 3166-1, two or three letters, comma or space separated) as flag emoji:
  ## `formatFlag("IT")` and `formatFlag("ITA")` are "🇮🇹". Anything else is left as it is.
  var flags: seq[string]
  for c in codes.split({',', ' '}):
    var code = c.strip.toUpperAscii
    if code.len == 0: continue
    if code.len == 3:   # a three-letter code, ISO 3166-1 alpha-3
      for (a3, a2) in countryAlpha3:
        if a3 == code: (code = a2; break)
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
  ## and `<br>`, two spaces before a newline or a backslash before it for a line break.
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
    if c == ' ' and s.continuesWith("  \n", i):   # Markdown's hard line break: two spaces, a newline
      var j = i
      while j < s.len and s[j] == ' ': inc j
      if j < s.len and s[j] == '\n': (result.add "<br>"; i = j + 1; continue)
    if c == '\\' and s.continuesWith("\\\n", i): (result.add "<br>"; i += 2; continue)
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
  ## The text of some HTML: tags dropped, an image read as its `alt`.
  var inTag = false
  var tag = ""
  for c in s:
    if c == '<': (inTag = true; tag = "")
    elif c == '>' and inTag:
      inTag = false
      if tag.toLowerAscii.startsWith("br") and (tag.len == 2 or tag[2] in {' ', '/'}): result.add " "
      elif tag.toLowerAscii.startsWith("img"):
        let a = tag.find("alt=\"")
        if a >= 0:
          let e = tag.find('"', a + 5)
          if e > a: result.add tag[a + 5 ..< e]
    elif inTag: tag.add c
    else: result.add c
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
  ## Fractions as percentages: 0.123 is "12.3%" (`scaleValues = false` for values already in %),
  ## "12,3 %" in French.
  let m = t.marksFor(locale, "", "")
  let l = getLocale(if locale.len > 0: locale else: t.locale)
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatPercent(v.toFloat, decimals, scaleValues, m.dec, m.sep, l.percentPattern, l.percentSign), rows)

proc fmtCurrency*(t: sink Tabella, columns: ColSel, rows = allRows(), currency = "USD", decimals = -1,
                  placement = "", accounting = false, useSubunits = true, locale = ""): Tabella =
  ## Numbers as amounts of a currency (any ISO 4217 code), with its symbol and its decimals, in the
  ## locale's way: "€49.95" in English, "49,95 €" in Italian. `placement` "left" or "right"
  ## puts the symbol there whatever the locale; `accounting` writes negative amounts in parentheses.
  let m = t.marksFor(locale, "", "")
  let l = getLocale(if locale.len > 0: locale else: t.locale)
  if placement notin ["", "left", "right"]:
    raise newException(ValueError, "placement is \"left\" or \"right\", not " & placement.escape)
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    escapeHtml(formatCurrency(v.toFloat, currency, decimals, m.sep, m.dec, placement,
                              l.currencyPattern, accounting, useSubunits)), rows)

proc fmtScientific*(t: sink Tabella, columns: ColSel, rows = allRows(), decimals = 2, locale = ""): Tabella =
  let m = t.marksFor(locale, "", "")
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatScientific(v.toFloat, decimals, m.dec, ctx), rows)

proc fmtRoman*(t: sink Tabella, columns: ColSel, rows = allRows(), upper = true): Tabella =
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatRoman(int(round(v.toFloat)), upper), rows)

proc fmtDate*(t: sink Tabella, columns: ColSel, rows = allRows(), dateStyle = "iso", locale = ""): Tabella =
  ## ISO date strings in a `dateStyles` style ("month_day_year", ...), a flexible style
  ## ("yMMMd"), or a std/times pattern, in the locale's language.
  let loc = if locale.len > 0: locale else: t.locale
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    escapeHtml(formatDate($v, dateStyle, loc)), rows)

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
    applies: proc (v: Value): bool = v.isNumber and v.toFloat == 0,
    fn: proc (v: Value, ctx: RenderContext): string = (if ctx == rcHtml: escapeHtml(txt) else: txt))


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

proc fmtTime*(t: sink Tabella, columns: ColSel, rows = allRows(), timeStyle = "iso", locale = ""): Tabella =
  ## Times ("14:35:00", or the time of a datetime) in one of `timeStyles` or `timeSkeletons`.
  let loc = if locale.len > 0: locale else: t.locale
  discard formatTime("00:00", timeStyle)
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    escapeHtml(formatTime($v, timeStyle, loc)), rows)

proc fmtDatetime*(t: sink Tabella, columns: ColSel, rows = allRows(), dateStyle = "iso", timeStyle = "iso",
                  sep = " ", locale = ""): Tabella =
  ## ISO datetimes as a date and a time, each in its style.
  let loc = if locale.len > 0: locale else: t.locale
  discard formatTime("00:00", timeStyle)
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    escapeHtml(formatDatetime($v, dateStyle, timeStyle, sep, loc)), rows)

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
  ## Two-letter country codes as flag emoji (nothing is loaded), one or several (a list, or
  ## separated by commas); with `useTitle` the code is the HTML title, shown on hover.
  result = fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    let codes = cellNames(v).join(",")
    let f = formatFlag(codes, sep)
    if ctx == rcText or not useTitle: escapeHtml(f)
    else: "<span title=\"" & escapeHtml(cellNames(v).join(", ")) & "\">" & escapeHtml(f) & "</span>", rows)
  result.formats[^1].wholeValue = true

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
    applies: proc (v: Value): bool =
      v.isNumber and v.toFloat != 0 and abs(v.toFloat) < threshold and (v.toFloat < 0) == neg,
    fn: proc (v: Value, ctx: RenderContext): string = (if ctx == rcHtml: escapeHtml(txt) else: txt))

proc subLargeVals*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), threshold = 1e12,
                   largePattern = ">={x}", sign = "+"): Tabella =
  ## Shows numbers at or beyond `threshold` as `largePattern`: ">=1T". `sign = "-"` does the
  ## same for numbers at or below minus the threshold.
  result = t
  let neg = sign == "-"
  let txt = largePattern.replace("{x}", (if neg: "−" else: "") & thresholdText(threshold))
  result.substitutions.add FormatRule(columns: columns.resolve(result.data), rows: result.targetRows(rows),
    applies: proc (v: Value): bool =
      v.isNumber and ((not neg and v.toFloat >= threshold) or (neg and v.toFloat <= -threshold)),
    fn: proc (v: Value, ctx: RenderContext): string = (if ctx == rcHtml: escapeHtml(txt) else: txt))

proc subValues*(t: sink Tabella, columns: ColSel = everything(), rows = allRows(),
                fn: proc (v: Value): bool, replacement: string): Tabella =
  ## Shows the values for which `fn` holds as `replacement`.
  result = t
  let (f, txt) = (fn, replacement)
  result.substitutions.add FormatRule(columns: columns.resolve(result.data), rows: result.targetRows(rows),
    applies: f,
    fn: proc (v: Value, ctx: RenderContext): string = (if ctx == rcHtml: escapeHtml(txt) else: txt))

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


# ------------------------------------------------------------------------ fractions, bins, ...

func bestFraction(f: float, maxDen: int): (int, int) =
  ## The fraction n/d closest to `f` (in [0, 1]) with d up to `maxDen`, the smallest d on a tie.
  result = (0, 1)
  var best = f
  for d in 1 .. maxDen:
    let n = int(round(f * float(d)))
    let err = abs(f - float(n) / float(d))
    if err < best - 1e-12: (best = err; result = (n, d))

func formatFraction*(x: float, accuracy = "low", denominator = 0, simplify = true,
                     layout = "inline", useSeps = true, sepMark = ",", ctx = rcText): string =
  ## A number as a mixed fraction: `formatFraction(2.25)` is "2 1/4", `formatFraction(0.333)`
  ## is "1/3". `accuracy` is "low" (denominators up to 9), "med" (99) or "high" (999); a
  ## `denominator` fixes it ("2/16"), reduced when `simplify`. `layout = "diagonal"` shows
  ## "2¼"-style fractions (`<sup>` and `<sub>` in HTML).
  if x.isNaN: return "NaN"
  if x.classify in {fcInf, fcNegInf}: return formatNumber(x)
  let a = abs(x)
  var whole = floor(a)
  var (n, d) =
    if denominator > 0: (int(round((a - whole) * float(denominator))), denominator)
    else: bestFraction(a - whole, case accuracy
                                  of "med": 99
                                  of "high": 999
                                  else: 9)
  if n == d: (whole += 1; n = 0)
  if n > 0 and simplify:
    let g = gcd(n, d)
    (n, d) = (n div g, d div g)
  let sign = if x < 0 and (whole > 0 or n > 0): "−" else: ""
  let w = if whole > 0 or n == 0: formatNumber(whole, 0, useSeps, sepMark = sepMark) else: ""
  if n == 0: return sign & w
  let frac =
    if layout == "diagonal":
      if ctx == rcHtml: "<span class=\"tb_frac\"><sup>" & $n & "</sup>⁄<sub>" & $d & "</sub></span>"
      else: toSuperscript($n) & "⁄" & toSubscript($d)
    else: $n & "/" & $d
  sign & w & (if w.len > 0 and layout != "diagonal": " " else: "") & frac

proc formatBins*(s: string, sep = "--", fmt: proc (x: float): string = nil): string =
  ## A bin written as an interval, `"[10,20)"` or `"(0,5]"`, as a range: "10–20". `sep` goes
  ## between the two ends (`--` is an en dash); `fmt` formats each end.
  let t = s.strip
  if t.len < 3 or t[0] notin {'(', '['} or t[^1] notin {')', ']'} or ',' notin t: return s
  let parts = t[1 ..< ^1].split(',', 1)
  var ends = @[parts[0].strip, parts[1].strip]
  if fmt != nil:
    for e in ends.mitems:
      try: e = fmt(parseFloat(e))
      except ValueError: discard
  ends.join(sep.replace("--", "–"))

func countryName*(code: string): string =
  ## The English name of a country or territory by its two- or three-letter code (ISO 3166-1),
  ## from Unicode CLDR: `countryName("IT")` and `countryName("ITA")` are "Italy". Other text
  ## is returned as it is.
  var c = code.strip.toUpperAscii
  if c.len == 3:
    for (a3, a2) in countryAlpha3:
      if a3 == c: (c = a2; break)
  for (a2, name) in countryNames:
    if a2 == c: return name
  code.strip

func formatCountry*(codes: string, sep = ", "): string =
  ## Country codes (comma or space separated) as names: `formatCountry("IT, FR")` is
  ## "Italy, France".
  codes.split({',', ' '}).filterIt(it.strip.len > 0).mapIt(countryName(it)).join(sep)

proc fmtFraction*(t: sink Tabella, columns: ColSel = numeric(), rows = allRows(), accuracy = "low",
                  denominator = 0, simplify = true, layout = "inline", useSeps = true,
                  pattern = "{x}", locale = ""): Tabella =
  ## Numbers as mixed fractions: 2.25 is "2 1/4" (see `formatFraction`).
  let m = t.marksFor(locale, "", "")
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    formatFraction(v.toFloat, accuracy, denominator, simplify, layout, useSeps, m.sep, ctx).withPattern(pattern), rows)

proc fmtBins*(t: sink Tabella, columns: ColSel, rows = allRows(), sep = "--",
              fmt: proc (x: float): string = nil): Tabella =
  ## Intervals such as "[10,20)" as ranges, "10–20"; `fmt` formats both ends:
  ## `fmtBins("size", fmt = x => formatNumber(x, 0))`.
  let f = fmt
  formats.fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    let s = formatBins($v, sep, f)
    if ctx == rcHtml: escapeHtml(s) else: s, rows)

proc fmtPassthrough*(t: sink Tabella, columns: ColSel = everything(), rows = allRows(), escape = true,
                     pattern = "{x}"): Tabella =
  ## Values shown as they are, in a `pattern`; with `escape = false` a value is HTML.
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    let s = ($v).withPattern(pattern)
    if ctx == rcHtml and escape: escapeHtml(s)
    elif ctx == rcText and not escape: textToPlain(Text(kind: tkHtml, s: s))
    else: s, rows)

proc fmtCountry*(t: sink Tabella, columns: ColSel, rows = allRows(), pattern = "{x}", sep = ", "): Tabella =
  ## Two- or three-letter country codes as English names, from CLDR: "IT" is "Italy".
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    let s = formatCountry($v, sep).withPattern(pattern)
    if ctx == rcHtml: escapeHtml(s) else: s, rows)

func autoNumber(isInt, suf: bool, m: Marks): FormatFn =
  ## The format `fmtAuto` gives a numeric column (a proc of its own, so that each column's
  ## closure keeps its own `isInt`).
  result = proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    let x = v.toFloat
    let a = abs(x)
    if x != 0 and (a < 1e-3 or a >= 1e6):
      if suf and a >= 1e6 and a < 1e15: return formatCompact(x, 1, m.dec)
      let mant = a / pow(10.0, floor(log10(a)))
      var d = 3   # as few decimals as the mantissa needs, up to 3
      while d > 0 and abs(round(mant, d - 1) - round(mant, 3)) < 1e-9: dec d
      return formatScientific(x, d, m.dec, ctx)
    formatNumber(x, if isInt: 0 else: 3, dropTrailingZeros = true, sepMark = m.sep, decMark = m.dec)

proc fmtAuto*(t: sink Tabella, columns: ColSel = everything(), rows = allRows(),
              scope: openArray[string] = ["numbers", "currency"], lgNumPref = "sci", locale = ""): Tabella =
  ## A format for each column, from its values: numbers with as many decimals as they need (up
  ## to 3), very small or large ones in scientific notation (`lgNumPref = "suf"`: large ones
  ## with a suffix, "12.3M"), and a currency when the column's name ends with an ISO 4217 code
  ## ("price_eur").
  result = t
  let m = result.marksFor(locale, "", "")
  let sc = @scope
  for name in columns.resolve(result.data):
    let col = result.data[name]
    if not col.values.anyIt(it.isNumber): continue
    let lower = name.toLowerAscii
    let code = if lower.len > 4 and lower[^4] in {'_', '.'}: lower[^3 .. ^1] else: ""
    if "currency" in sc and code.len == 3 and isCurrency(code):
      result = result.fmtCurrency(name, rows, currency = code.toUpperAscii, locale = locale)
      continue
    if "numbers" notin sc: continue
    let isInt = col.values.allIt(not it.isNumber or it.toFloat == round(it.toFloat))
    result = fmt(result, name, autoNumber(isInt, lgNumPref == "suf", m), rows)
