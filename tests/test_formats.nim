import std/unittest
import tabelline

suite "value formatting":
  test "numbers":
    check formatNumber(1234567.891) == "1,234,567.89"
    check formatNumber(1234567.891, 1, sepMark = ".", decMark = ",") == "1.234.567,9"
    check formatNumber(-0.001, 2) == "0.00"
    check formatNumber(-3.5, 1) == "−3.5"
    check formatNumber(2.50, 2, dropTrailingZeros = true) == "2.5"
    check formatNumber(2.0, 2, dropTrailingZeros = true) == "2"
    check formatNumber(12, 0, forceSign = true) == "+12"
  test "compact, scientific, percent, currency, roman":
    check formatCompact(1234567) == "1.2M"
    check formatCompact(999) == "999"
    check formatScientific(5.97e24) == "5.97 × 10²⁴"
    check formatScientific(0.00123, 1) == "1.2 × 10⁻³"
    check formatScientific(9.999, 2) == "1.00 × 10¹"
    check formatPercent(0.1234) == "12.3%"
    check formatCurrency(49.95, "EUR") == "€49.95"
    check formatCurrency(-1500, "JPY") == "−¥1,500"
    check formatRoman(2026) == "MMXXVI"
    check formatRoman(4, upper = false) == "iv"
  test "dates":
    check formatDate("2015-01-15", "day_month_year") == "15 January 2015"
    check formatDate("2015-01-15 13:35", "month_day_year") == "January 15, 2015"
    check formatDate("not a date") == "not a date"
  test "locales":
    check localeMarks("it") == (".", ",")
    check localeMarks("en-US") == (",", ".")
  test "inline markdown":
    check inlineMarkdown("**a** *b* `c<d`") == "<strong>a</strong> <em>b</em> <code>c&lt;d</code>"
    check inlineMarkdown("10^24^ kg, H~2~O") == "10<sup>24</sup> kg, H<sub>2</sub>O"
    check inlineMarkdown("[nim](https://nim-lang.org)") == "<a href=\"https://nim-lang.org\">nim</a>"
    check inlineMarkdown("a<br>b & c") == "a<br>b &amp; c"

suite "fmt verbs":
  let d = tableData:
    x: [1.5, 2.25, nil]
    n: [1000, 0, 3]
  test "the last format for a cell wins":
    let t = tabella(d).fmtNumber("x", decimals = 1).fmtNumber("x", decimals = 3, rows = [0])
    check t.formatCell(0, "x", rcText) == "1.500"
    check t.formatCell(1, "x", rcText) == "2.2"   # round half to even in formatFloat
  test "missing values are blank unless substituted":
    let t = tabella(d).fmtNumber("x")
    check t.formatCell(2, "x", rcText) == ""
    check t.subMissing(missingText = "n/a").formatCell(2, "x", rcText) == "n/a"
  test "subZero and fmtInteger":
    let t = tabella(d).fmtInteger("n").subZero("n", zeroText = "none")
    check t.formatCell(0, "n", rcText) == "1,000"
    check t.formatCell(1, "n", rcText) == "none"
  test "table locale":
    let t = tabella(d, locale = "it").fmtNumber("x", decimals = 2).fmtInteger("n")
    check t.formatCell(1, "x", rcText) == "2,25"
    check t.formatCell(0, "n", rcText) == "1.000"
  test "custom formatter escapes in html":
    let t = tabella(d).fmt("n", proc (v: Value): string = "<" & $v & ">")
    check t.formatCell(0, "n", rcHtml) == "&lt;1000&gt;"
    check t.formatCell(0, "n", rcText) == "<1000>"
