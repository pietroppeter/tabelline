## MODIFIED Requirements

### Requirement: Locales
A table SHALL take a `locale` (as `tabella(data, locale = "it")`) that sets the digit group and
decimal marks of its number formats, the pattern of its percentages and currencies, and the
names and order of its dates and times, from Unicode CLDR; a format's own `locale`, `sepMark` or
`decMark` SHALL win. A tag SHALL be read in any case, with `-` or `_`; an unknown region SHALL
fall back to its language, and an unknown language to English.

```nim
let d = tableData:
  n: [1234.5, 0.25]
let p = tableData:
  share: [0.123, 0.5]
echo tabella(d, locale = "it").fmtNumber("n", decimals = 2)
echo tabella(d, locale = "de_CH").fmtNumber("n", decimals = 2)
echo tabella(p, locale = "fr").fmtPercent("share")
echo getLocale("pt-XX").tag, " ", getLocale("it").months[10], " ", getLocale("ja").daysAbbr[0]
```

```text
┌──────────┐
│        n │
╞══════════╡
│ 1.234,50 │
│     0,25 │
└──────────┘
┌──────────┐
│        n │
╞══════════╡
│ 1'234.50 │
│     0.25 │
└──────────┘
┌────────┐
│  share │
╞════════╡
│ 12,3 % │
│ 50,0 % │
└────────┘
pt novembre 日
```

## ADDED Requirements

### Requirement: Currencies
`fmtCurrency(columns, rows, currency, decimals, placement, accounting, useSubunits, locale)` SHALL
take any ISO 4217 code that CLDR knows, with its symbol and its number of decimals; the symbol
SHALL go where the locale's pattern puts it, or on the `placement` given ("left", "right"), with a
no-break space when the symbol ends or starts with a letter. `accounting` SHALL write negative
amounts in parentheses; `useSubunits = false` SHALL drop the decimals.

```nim
let d = tableData:
  amount: [1234.5, -3.25]
echo tabella(d).fmtCurrency("amount", currency = "CAD", accounting = true)
echo tabella(d, locale = "it").fmtCurrency("amount", currency = "EUR")
echo tabella(d).fmtCurrency("amount", currency = "BHD", placement = "right")
echo formatCurrency(1500, "JPY"), " ", currencyInfo("CHF")
```

```text
┌─────────────┐
│      amount │
╞═════════════╡
│ CA$1,234.50 │
│   (CA$3.25) │
└─────────────┘
┌────────────┐
│     amount │
╞════════════╡
│ 1.234,50 € │
│    −3,25 € │
└────────────┘
┌───────────────┐
│        amount │
╞═══════════════╡
│ 1,234.500 BHD │
│    −3.250 BHD │
└───────────────┘
¥1,500 (name: "Swiss Franc", symbol: "CHF", digits: 2)
```

### Requirement: Dates and times in every locale
`fmtDate`, `fmtTime` and `fmtDatetime` SHALL take a `locale` (or the table's) for the names of
months, days, quarters, eras, AM and PM. A date style SHALL be one of gt's fixed styles
(`dateStyles`: "iso", "wday_month_day_year", "day_month_year", "year_week", ...) or one of gt's
flexible styles (`dateSkeletons`: "yMMMd", "yMMMEd", "yQQQQ", ...), written in the locale's
order; a time style SHALL be one of `timeStyles` or of `timeSkeletons` ("Hm", "hm", "hms", ...).

```nim
let d = tableData:
  day: ["2026-11-07", "2015-01-15"]
echo tabella(d, locale = "de").fmtDate("day", dateStyle = "yMMMEd")
for loc in ["en", "it", "ja", "ru"]:
  echo loc, ": ", formatDate("2026-11-07", "wday_day_month_year", loc), " · ",
    formatDate("2026-11-07", "yMMMd", loc), " · ", formatTime("14:35", "hm", loc)
```

```text
┌────────────────────┐
│ day                │
╞════════════════════╡
│ Sa., 7. Nov. 2026  │
│ Do., 15. Jan. 2015 │
└────────────────────┘
en: Saturday 7 November 2026 · Nov 7, 2026 · 2:35 PM
it: sabato 7 novembre 2026 · 7 nov 2026 · 2:35 PM
ja: 土曜日 7 11月 2026 · 2026年11月7日 · 午後2:35
ru: суббота 7 ноября 2026 · 7 нояб. 2026 г. · 2:35 PM
```
