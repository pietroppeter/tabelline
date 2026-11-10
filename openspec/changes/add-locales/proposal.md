## Why

Pietro asked (10 Nov 2026, 0.2 build thread) to bring into 0.2 everything planned for 0.3 and
0.4. This change is the first part of the fourth of five PRs: every locale. tabelline 0.1 knew
the marks of about 40 languages, the symbols of ten currencies, and month names in English only.
It comes from the Feature map rows Locales, Currency and Dates, and the BACKLOG.md entry
"Locales".

## What Changes

- `tools/cldr.nim` reads Unicode CLDR 49 (the JSON of cldr-json, full) once and writes
  `locales.nim` (657 locales) and `currencies.nim` (305 currencies) next to `countries.nim`. They
  are committed: nothing is read when tabelline builds or runs, and the core still needs only
  Nim's standard library. A locale keeps only what differs from its parent.
- `localize.nim`: `getLocale(tag)` (an object with the marks, the patterns and the names of a
  locale), `normalizeTag`, `hasLocale`, `currencyInfo(code)`, `isCurrency`, `formatPattern` (a
  date or a time in a CLDR pattern), `dateSkeletons`, `timeSkeletons`.
- `localeMarks` comes from CLDR: every locale, with its own characters (the narrow no-break
  space of French, the apostrophe of `de-CH`).
- `fmtPercent` follows the locale's pattern ("12,3 %" in French).
- `fmtCurrency` takes every ISO 4217 code, with its symbol and its decimals (BHD has three), puts
  the symbol where the locale does ("49,95 €" in Italian; `placement = "left"` or `"right"` to
  choose), and takes `accounting` and `useSubunits`.
- `fmtDate`, `fmtTime` and `fmtDatetime` take a `locale` (or the table's): month and day names in
  its language, and gt's flexible styles (`"yMMMd"`, `"yMMMEd"`, `"yQQQQ"`, `"Hm"`, `"hm"`, ...)
  in its order. The fixed styles of gt that tabelline lacked are added (`"wd_m_day_year"`,
  `"day_month"`, `"year_week"`, `"year_quarter"`, ...).
- `fmtAuto` recognises every currency code of CLDR in a column's name.

## Differences from gt and Great Tables

- The data is CLDR 49 for every locale CLDR has (657); gt has its own tables, from CLDR, for 574.
  Great Tables has 574 too, for numbers, and dates in a few languages.
- `localeMarks("de-CH")` is ("'", "."), as CLDR says, where 0.1 had ("’", ".") for "ch"; "ch" is
  now Chamorro (an unknown region or language falls back to its language, then to English).
- The symbol of a currency is the English one of CLDR ("CA$", "CHF"), as in gt; its place and the
  space beside it follow the locale's pattern, where gt puts it on the left unless told otherwise
  (`placement = "left"` does that here). The space is a no-break space.
- `fmtCurrency` takes ISO codes, not gt's symbol names (`"dollar"`); `accounting` writes
  "($3.50)" as gt does.
- Numbers are always grouped by three (gt: the same): CLDR's minimum grouping digits (Spanish
  "1234") and the Indian grouping ("12,34,567") are left out; gt's `system = "ind"` is not yet.
- Digits are always Latin, also where a locale prefers others (Arabic, Persian, Bengali).
- The flexible styles take the locale's CLDR pattern; gt's `"GGGGGyMd"` and the times with a zone
  (`"Hmv"`) or a weekday are not yet.
- Country names stay in English (gt: in the locale's language).

## Capabilities

### Modified Capabilities

- `formatting`: Locales, Currencies (new), Dates and times in every locale (new).

## Impact

- New: `src/tabelline/localize.nim`, `locales.nim`, `currencies.nim` (generated), `tests/test_locales.nim`.
- Changed: `tools/cldr.nim`, `formats.nim` (marks, percent, currency, dates, times, auto).
