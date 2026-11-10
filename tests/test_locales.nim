## Locales from CLDR: marks, percentages, currencies, dates and times.
import std/[unittest, strutils]
import tabelline

suite "locales":
  test "tags: any case and separator, unknown regions and languages fall back":
    check getLocale("de_ch").tag == "de-CH"
    check getLocale("it-XX").tag == "it"
    check getLocale("xx").tag == "en"
    check getLocale("").tag == "en"
    check hasLocale("pt-PT") and not hasLocale("xx")
  test "marks":
    check localeMarks("it") == (".", ",")
    check localeMarks("de-CH") == ("'", ".")
    check localeMarks("fr") == (" ", ",")
    check localeMarks("en-IN") == (",", ".")
  test "a region inherits from its parent":
    check getLocale("en-AU").months == getLocale("en").months
    check getLocale("en-GB").dateFormats[3] == "dd/MM/y"
    check getLocale("en").dateFormats[3] == "M/d/yy"

suite "percentages and currencies":
  test "percent patterns":
    check formatPercent(0.123) == "12.3%"
    let fr = getLocale("fr")
    check formatPercent(0.123, decMark = ",", pattern = fr.percentPattern) == "12,3\u00A0%"
    check formatPercent(-0.5, 0) == "−50%"
  test "every ISO code, its symbol and decimals":
    check currencyInfo("BHD").digits == 3
    check currencyInfo("JPY") == ("Japanese Yen", "¥", 0)
    check formatCurrency(12, "BHD") == "BHD 12.000"
    check formatCurrency(-1500, "JPY") == "−¥1,500"
    check formatCurrency(1234.5, "CAD") == "CA$1,234.50"
    check formatCurrency(1234.6, "EUR", useSubunits = false) == "€1,235"
  test "placement and accounting":
    check formatCurrency(49.95, "EUR", sepMark = ".", decMark = ",", pattern = getLocale("it").currencyPattern) == "49,95 €"
    check formatCurrency(49.95, "EUR", placement = "right") == "49.95 €"
    check formatCurrency(-49.95, "USD", accounting = true) == "($49.95)"
  test "fmtCurrency follows the table's locale":
    let d = tableData:
      price: [49.95, -3.5]
    check tabella(d, locale = "it").fmtCurrency("price", currency = "EUR").toText.contains("49,95 €")
    check tabella(d, locale = "de-CH").fmtCurrency("price", currency = "CHF").toText.contains("CHF 49.95")
    check tabella(d).fmtCurrency("price", currency = "USD", accounting = true).toText.contains("($3.50)")
    expect ValueError: discard tabella(d).fmtCurrency("price", placement = "middle")

suite "dates and times":
  test "fixed styles in the locale's language":
    check formatDate("2015-01-15", "day_month_year") == "15 January 2015"
    check formatDate("2015-01-15", "day_month_year", "it") == "15 gennaio 2015"
    check formatDate("2015-01-15", "wday_month_day_year", "de") == "Donnerstag, Januar 15, 2015"
    check formatDate("2015-01-15", "month", "ru") == "январь"
    check formatDate("2015-01-15", "year_quarter") == "2015-Q1"
    check formatDate("2021-01-01", "year_week") == "2020-W53"
  test "flexible styles in the locale's order":
    check formatDate("2015-01-15", "yMMMd") == "Jan 15, 2015"
    check formatDate("2015-01-15", "yMMMd", "it") == "15 gen 2015"
    check formatDate("2015-01-15", "yMMMd", "de") == "15. Jan. 2015"
    check formatDate("2015-01-15", "yMMMM", "ru") == "январь 2015 г."
    check formatDate("2015-01-15", "yQQQQ") == "1st quarter 2015"
    check formatDate("2015-01-15", "GyMMMd") == "Jan 15, 2015 AD"
  test "not a date, and std/times patterns":
    check formatDate("not a date", "yMMMd") == "not a date"
    check formatDate("2015-02-30", "yMMMd") == "2015-02-30"
    check formatDate("2015-01-15", "dd.MM.yyyy") == "15.01.2015"
  test "times":
    check formatTime("14:35", "h_m_p") == "2:35 PM"
    check formatTime("14:35", "Hm", "it") == "14:35"
    check formatTime("14:35", "hm") == "2:35 PM"
    check formatTime("14:35", "h_m_p", "ko").endsWith("오후")
    check formatDatetime("2026-11-07T14:35", "yMMMd", "Hm", locale = "fr") == "7 nov. 2026 14:35"
    expect ValueError: discard formatTime("14:35", "Hmv")
  test "fmtDate takes the table's locale":
    let d = tableData:
      day: ["2026-11-07"]
    check tabella(d, locale = "es").fmtDate("day", dateStyle = "day_month_year").toText.contains("7 noviembre 2026")
    check tabella(d).fmtDate("day", dateStyle = "yMMMEd", locale = "ja").toText.contains("2026年11月7日(土)")
