## Formatting values: plain functions that turn numbers into text (`formatNumber`, `formatPercent`,
## ..., usable on their own, like Great Tables' `vals`), and the `fmt*` verbs that attach them to
## columns and rows of a table. A verb resolves its columns and rows when it is called, and the
## formats run when the table is rendered: the last format given for a cell wins.

import std/[strutils, math, times, sequtils]
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
    if c == '~': (toggle("sub"); inc i; continue)
    if c == '^': (toggle("sup"); inc i; continue)
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

proc fmtTf*(t: sink Tabella, columns: ColSel, rows = allRows(), trueText = "✓", falseText = "✗"): Tabella =
  ## Booleans as two symbols (or words).
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if v.kind != vkBool: return escapeHtml($v)
    escapeHtml(if v.b: trueText else: falseText), rows)

proc fmtMarkdown*(t: sink Tabella, columns: ColSel, rows = allRows()): Tabella =
  ## Cell text as Markdown (inline: emphasis, code, links).
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string =
    if ctx == rcHtml: inlineMarkdown($v) else: $v, rows)

proc fmtBar*(t: sink Tabella, columns: ColSel, rows = allRows(), color = "#7fb3d5", width = "8em",
             showValue = true, decimals = 0, domain = (NaN, NaN)): Tabella =
  ## A small horizontal bar for each number, scaled to the column's range (or `domain`):
  ## the tiniest of nanoplots.
  let names = columns.resolve(t.data)
  var lo, hi = NaN
  for n in names:
    for v in t.data[n].values:
      if v.isNumber:
        let x = v.toFloat
        if lo.isNaN or x < lo: lo = x
        if hi.isNaN or x > hi: hi = x
  if not domain[0].isNaN: lo = domain[0]
  if not domain[1].isNaN: hi = domain[1]
  lo = min(lo, 0.0)
  let m = t.marksFor("", "", "")
  fmt(t, names, proc (v: Value, ctx: RenderContext): string =
    if not v.isNumber: return escapeHtml($v)
    let x = v.toFloat
    let frac = if hi > lo: clamp((x - lo) / (hi - lo), 0.0, 1.0) else: 0.0
    let label = if showValue: formatNumber(x, decimals, sepMark = m.sep, decMark = m.dec) else: ""
    if ctx == rcText:
      return "█".repeat(int(round(frac * 10))) & (if showValue: " " & label else: "")
    "<span class=\"tb_bar\"><span class=\"tb_bar_track\" style=\"width:" & width &
      "\"><span class=\"tb_bar_fill\" style=\"width:" & formatFloat(frac * 100, ffDecimal, 1) &
      "%;background:" & color & "\"></span></span>" & (if showValue: "<span class=\"tb_bar_label\">" & label & "</span>" else: "") &
      "</span>", rows)

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

