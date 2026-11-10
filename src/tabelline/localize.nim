## Locales: the conventions of a language and region, from Unicode CLDR (`locales.nim`,
## `currencies.nim`, written by `tools/cldr.nim`). `getLocale("de-CH")` gives the marks of numbers,
## the patterns of percentages and currencies, and the names and patterns of dates and times.
## Dates and times are written with CLDR's patterns (`formatPattern`): `y`, `MMMM`, `d`, `EEEE`,
## `HH`, `mm`, `a`, ...

import std/[strutils, algorithm, times]
import locales, currencies

type
  Locale* = object
    tag*: string                    ## the tag found in CLDR ("de-CH"; "en" for an unknown tag)
    decimal*, group*, percentSign*: string
    percentPattern*, currencyPattern*, accountingPattern*: string   ## CLDR patterns: "#,##0 %"
    months*, monthsAbbr*: array[12, string]            ## names in a date: "1 gennaio"
    monthsAlone*, monthsAloneAbbr*: array[12, string]  ## names on their own: "gennaio 2026"
    days*, daysAbbr*: array[7, string]                 ## Sunday first
    quarters*, quartersAbbr*: array[4, string]
    am*, pm*, eraBC*, eraAD*: string
    dateFormats*, timeFormats*: array[4, string]       ## full, long, medium, short
    dateTime*: string                                  ## "{1}, {0}": the date, then the time
    skeletons*: seq[(string, string)]                  ## "yMMMd" -> "d MMM y"

const dateSkeletons* = ["yMd", "yMEd", "yMMM", "yMMMM", "yMMMd", "yMMMEd", "GyMd", "GyMMMd",
                        "GyMMMEd", "yM", "Md", "MEd", "MMMd", "MMMEd", "MMMMd", "GyMMM", "yQQQ",
                        "yQQQQ", "Gy", "y", "M", "MMM", "d", "Ed"]
  ## The flexible date styles of gt: each is a CLDR skeleton, written in each locale's own order.
const timeSkeletons* = ["Hms", "Hm", "H", "hms", "hm", "h", "ms"]
  ## The flexible time styles of gt that need no time zone.

func normalizeTag*(tag: string): string =
  ## "de_CH", "DE-ch" and "de-CH" are the same locale.
  let parts = tag.strip.replace('_', '-').split('-')
  for i, p in parts:
    if i > 0: result.add '-'
    result.add(if i == 0: p.toLowerAscii
               elif p.len == 4: p[0].toUpperAscii & p[1 .. ^1].toLowerAscii
               elif p.len == 2: p.toUpperAscii
               else: p)

func findRecord(tag: string): int =
  localeTable.binarySearch(tag, proc (a: (string, string), b: string): int = cmp(a[0], b))

func hasLocale*(tag: string): bool =
  ## Whether CLDR has data for this tag (after `normalizeTag`).
  findRecord(normalizeTag(tag)) >= 0

func parentLocale(tag: string): string =
  if tag == "und": return ""
  for (a, b) in localeParents:
    if a == tag: return b
  let i = tag.rfind('-')
  if i < 0: return "und"
  let p = tag[0 ..< i]
  if findRecord(p) >= 0: p else: parentLocale(p)

func knownTag(tag: string): string =
  ## The tag itself, or the nearest one CLDR knows: "it-XX" is "it"; "" and "xx" are "en".
  var t = normalizeTag(tag)
  if t.len == 0: return "en"
  while t.len > 0 and findRecord(t) < 0:
    let i = t.rfind('-')
    t = if i < 0: "" else: t[0 ..< i]
  if t.len == 0: "en" else: t

func resolved(tag: string): seq[string] =
  ## Every field of a locale: its own, then its parents'.
  result = newSeq[string](localeFields.len)
  var have = newSeq[bool](localeFields.len)
  var t = tag
  while t.len > 0:
    let i = findRecord(t)
    if i >= 0:
      let parts = localeTable[i][1].split('\x1F')
      for k, v in parts:
        if k < result.len and not have[k] and v.len > 0:
          result[k] = (if v == "\x1E": "" else: v)
          have[k] = true
    t = parentLocale(t)

func getLocale*(tag: string): Locale =
  ## The conventions of a locale: `getLocale("it").months[0]` is "gennaio". An unknown region
  ## falls back to its language ("it-XX" is "it"), an unknown language to "en".
  let tag = knownTag(tag)
  let r = resolved(tag)
  var k = 0
  proc next(): string =
    result = r[k]
    inc k
  result.tag = tag
  result.decimal = next()
  result.group = next()
  result.percentSign = next()
  result.percentPattern = next()
  result.currencyPattern = next()
  result.accountingPattern = next()
  for i in 0..11: result.months[i] = next()
  for i in 0..11: result.monthsAbbr[i] = next()
  for i in 0..11: result.monthsAlone[i] = next()
  for i in 0..11: result.monthsAloneAbbr[i] = next()
  for i in 0..6: result.days[i] = next()
  for i in 0..6: result.daysAbbr[i] = next()
  for i in 0..3: result.quarters[i] = next()
  for i in 0..3: result.quartersAbbr[i] = next()
  result.am = next()
  result.pm = next()
  result.eraBC = next()
  result.eraAD = next()
  for i in 0..3: result.dateFormats[i] = next()
  for i in 0..3: result.timeFormats[i] = next()
  result.dateTime = next()
  for s in dateSkeletons: result.skeletons.add (s, next())
  for s in timeSkeletons: result.skeletons.add (s, next())

func skeleton*(l: Locale, name: string): string =
  ## The pattern of a flexible style in this locale ("" when it is not one).
  for (k, v) in l.skeletons:
    if k == name: return v

# ----------------------------------------------------------------------------------- currencies

func currencyInfo*(code: string): tuple[name, symbol: string, digits: int] =
  ## The English name, the symbol and the decimals of an ISO 4217 code:
  ## `currencyInfo("JPY")` is ("Japanese Yen", "¥", 0). An unknown code is its own symbol.
  let c = code.strip.toUpperAscii
  let i = currencyTable.binarySearch(c, proc (a: (string, string, string, int), b: string): int = cmp(a[0], b))
  if i >= 0: (currencyTable[i][1], currencyTable[i][2], currencyTable[i][3]) else: (c, c, 2)

func isCurrency*(code: string): bool =
  ## Whether CLDR knows this ISO 4217 code.
  let c = code.strip.toUpperAscii
  currencyTable.binarySearch(c, proc (a: (string, string, string, int), b: string): int = cmp(a[0], b)) >= 0

# --------------------------------------------------------------------------------- the patterns

func splitPattern*(pattern: string): tuple[prefix, suffix: string] =
  ## The text before and after the number in a CLDR number pattern (its positive part):
  ## "#,##0.00 ¤" is ("", " ¤"), "¤#,##0.00" is ("¤", "").
  let p = pattern.split(';')[0]
  var a = 0
  while a < p.len and p[a] notin {'#', '0', ',', '.'}: inc a
  var b = p.len
  while b > a and p[b - 1] notin {'#', '0', ',', '.'}: dec b
  (p[0 ..< a], p[b .. ^1])

func negativePattern*(pattern: string): tuple[prefix, suffix: string] =
  ## The text around a negative number: the pattern's negative part, or "" (a minus sign is added).
  let parts = pattern.split(';')
  if parts.len < 2: return ("", "")
  splitPattern(parts[1])

func isSymbolChar(r: string): bool =
  ## Whether the first or last character of a currency symbol is itself a symbol ($, €, ¥):
  ## CLDR puts a space between a number and a symbol that ends in a letter ("CHF 12.00").
  r.len > 0 and not (r[0] in {'A'..'Z', 'a'..'z'})

func withCurrency*(number, symbol, pattern: string): string =
  ## The number and the symbol, placed and spaced as the pattern says.
  let (pre, suf) = splitPattern(pattern)
  var p = pre
  var s = suf
  if p.contains("¤"):
    let joined = p.endsWith("¤")
    p = p.replace("¤", symbol)
    if joined and symbol.len > 0 and not isSymbolChar($symbol[^1]): p.add " "
  if s.contains("¤"):
    let joined = s.startsWith("¤")
    s = s.replace("¤", symbol)
    if joined and symbol.len > 0 and symbol[0] in {'A'..'Z', 'a'..'z'}: s = " " & s
  p & number & s

# ------------------------------------------------------------------------------- dates and times

func pad(n, width: int): string = intToStr(n, width)

func isoWeek(year, month, day: int): (int, int) =
  ## The ISO year and week of a date (the year of its Thursday).
  if month notin 1..12 or day notin 1..31: return (year, 0)
  {.cast(noSideEffect).}:
    try:
      let d = dateTime(year, Month(month), MonthdayRange(day), zone = utc())
      let (w, y) = d.getIsoWeekAndYear
      (y.int, w.int)
    except CatchableError: (year, 0)

func formatPattern*(l: Locale, pattern: string, year = 0, month = 0, day = 0, weekday = -1,
                    hour = -1, minute = 0, second = 0): string =
  ## Writes a date or a time with a CLDR pattern: `formatPattern(getLocale("it"), "d MMMM y",
  ## 2026, 11, 7)` is "7 novembre 2026". `weekday` is 0 for Sunday. Text between quotes is kept.
  var i = 0
  while i < pattern.len:
    let c = pattern[i]
    if c == '\'':
      if i + 1 < pattern.len and pattern[i + 1] == '\'':
        result.add '\''
        i += 2
        continue
      var j = i + 1
      while j < pattern.len and pattern[j] != '\'': inc j
      result.add pattern[i + 1 ..< j]
      i = j + 1
      continue
    if c notin {'A'..'Z', 'a'..'z'}:
      result.add c
      inc i
      continue
    var n = 1
    while i + n < pattern.len and pattern[i + n] == c: inc n
    let h12 = if hour mod 12 == 0: 12 else: hour mod 12
    case c
    of 'G': result.add(if year <= 0: l.eraBC else: l.eraAD)
    of 'y', 'u': result.add(if n == 2: pad(year mod 100, 2) else: pad(year, n))
    of 'Y': result.add pad(isoWeek(year, month, day)[0], n)
    of 'M', 'L':
      let alone = c == 'L'
      if month in 1..12:
        result.add(case n
          of 1: $month
          of 2: pad(month, 2)
          of 3: (if alone: l.monthsAloneAbbr[month - 1] else: l.monthsAbbr[month - 1])
          else: (if alone: l.monthsAlone[month - 1] else: l.months[month - 1]))
    of 'd': result.add pad(day, n)
    of 'E', 'c', 'e':
      if weekday in 0..6:
        result.add(if n >= 4: l.days[weekday] else: l.daysAbbr[weekday])
    of 'Q', 'q':
      let q = (month - 1) div 3
      if q in 0..3:
        result.add(case n
          of 1, 2: $(q + 1)
          of 3: l.quartersAbbr[q]
          else: l.quarters[q])
    of 'a', 'b', 'B': result.add(if hour < 12: l.am else: l.pm)
    of 'h': result.add pad(h12, n)
    of 'K': result.add pad(hour mod 12, n)
    of 'H': result.add pad(hour, n)
    of 'k': result.add pad(if hour == 0: 24 else: hour, n)
    of 'm': result.add pad(minute, n)
    of 's': result.add pad(second, n)
    of 'w': result.add pad(isoWeek(year, month, day)[1], n)
    else: result.add pattern[i ..< i + n]
    i += n
