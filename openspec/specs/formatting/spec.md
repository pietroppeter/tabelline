# formatting Specification

## Purpose
How values become text: formatting functions usable on their own, and `fmt*` verbs that attach
them to columns and rows, applied when the table is rendered.

## Requirements

### Requirement: Formats are applied at render time
A `fmt*` verb SHALL resolve its columns and rows when it is called and store a format; the
formats SHALL run when the table is rendered, and for each cell the last format that covers it
SHALL win. Missing values SHALL render blank unless a substitution says otherwise.

```nim
let d = tableData:
  x: [1.5, 2.25, nil]
let t = tabella(d):
  fmtNumber "x", decimals = 1
  fmtNumber "x", decimals = 3, rows = [0]
echo t
```

```text
┌───────┐
│     x │
╞═══════╡
│ 1.500 │
│   2.2 │
│       │
└───────┘
```

### Requirement: Number formats
`fmtNumber` SHALL format numbers with `decimals`, digit grouping (`useSeps`), `dropTrailingZeros`,
`scaleBy`, `compact` suffixes (K, M, B, T), `forceSign` and a `pattern` around the value (`"{x} kg"`).
`fmtInteger`, `fmtPercent`, `fmtCurrency`, `fmtScientific` and `fmtRoman` SHALL be the usual
special cases. Negative numbers SHALL use the minus sign (−).

```nim
let d = tableData:
  n: [1234567.891, -0.5, 0.0123]
let number = tabella(d):
  fmtNumber "n", decimals = 2
echo number
let compact = tabella(d):
  fmtNumber "n", compact = true
echo compact
let percent = tabella(d):
  fmtPercent "n", decimals = 1
echo percent
let currency = tabella(d):
  fmtCurrency "n", currency = "EUR"
echo currency
let scientific = tabella(d):
  fmtScientific "n", decimals = 1
echo scientific
```

```text
┌──────────────┐
│            n │
╞══════════════╡
│ 1,234,567.89 │
│        −0.50 │
│         0.01 │
└──────────────┘
┌───────┐
│     n │
╞═══════╡
│ 1.23M │
│  −0.5 │
│  0.01 │
└───────┘
┌────────────────┐
│              n │
╞════════════════╡
│ 123,456,789.1% │
│         −50.0% │
│           1.2% │
└────────────────┘
┌───────────────┐
│             n │
╞═══════════════╡
│ €1,234,567.89 │
│        −€0.50 │
│         €0.01 │
└───────────────┘
┌─────────────┐
│           n │
╞═════════════╡
│   1.2 × 10⁶ │
│ −5.0 × 10⁻¹ │
│  1.2 × 10⁻² │
└─────────────┘
```

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
let italian = tabella(d, locale = "it"):
  fmtNumber "n", decimals = 2
echo italian
let swiss = tabella(d, locale = "de_CH"):
  fmtNumber "n", decimals = 2
echo swiss
let french = tabella(p, locale = "fr"):
  fmtPercent "share"
echo french
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

### Requirement: Other formats
`fmtDate` SHALL format ISO dates in a named style or a std/times pattern; `fmtTf` SHALL show
booleans as two texts; `fmtMarkdown` SHALL read cells as inline Markdown; `fmt(columns, proc)`
SHALL take any proc from a `Value` to a string.

```nim
let d = tableData:
  day: ["2026-11-07", "2015-01-15"]
  ok: [true, false]
  stars: [3, 1]
let t = tabella(d):
  fmtDate "day", dateStyle = "day_month_year"
  fmtTf "ok", trueText = "yes", falseText = "no"
  fmt "stars", proc (v: Value): string = "*".repeat(v.i)
echo t
```

```text
┌─────────────────┬─────┬───────┐
│ day             │ ok  │ stars │
╞═════════════════╪═════╪═══════╡
│ 7 November 2026 │ yes │   *** │
│ 15 January 2015 │ no  │     * │
└─────────────────┴─────┴───────┘
```

### Requirement: Substitutions
`subMissing` SHALL show missing values as a text (by default an em dash), `subZero` SHALL show
zeros as a text. Substitutions SHALL apply after the formats.

```nim
let d = tableData:
  n: [0, nil, 3]
let t = tabella(d):
  subMissing()
  subZero zeroText = "none"
echo t
```

```text
┌──────┐
│    n │
╞══════╡
│ none │
│    — │
│    3 │
└──────┘
```

### Requirement: Value functions
The functions behind the verbs (`formatNumber`, `formatInteger`, `formatCompact`,
`formatScientific`, `formatEngineering`, `formatNumberSi`, `formatPercent`, `formatPartsper`,
`formatCurrency`, `formatBytes`, `formatRoman`, `formatIndex`, `formatSpelledNum`, `formatDate`,
`formatTime`, `formatDatetime`, `formatDuration`, `formatTf`, `formatFlag`) SHALL be public, for use
outside tables.

```nim
echo formatNumber(1234567.891), " ", formatCompact(1234567.891), " ", formatScientific(5.97e24)
echo formatPercent(0.1234), " ", formatCurrency(-49.95, "EUR"), " ", formatRoman(2026)
echo formatInteger(1234.6), " ", formatEngineering(12345), " ", formatNumberSi(1500, "W"), " ", formatPartsper(0.0042)
echo formatBytes(2048, "binary"), " ", formatIndex(3), " ", formatSpelledNum(7), " ", formatDuration(3725)
echo formatTime("09:05", "h_m_p"), " ", formatDatetime("2026-11-07T09:05", "m_day_year"), " ", formatTf(true, "yes-no"), " ", formatFlag("IT")
```

```text
1,234,567.89 1.2M 5.97 × 10²⁴
12.3% −€49.95 MMXXVI
1,235 12.35 × 10³ 1.50 kW 4.20‰
2 KiB C seven 1h 2m 5s
9:05 AM Nov 7, 2026 09:05:00 yes 🇮🇹
```

### Requirement: Engineering notation and SI prefixes
`fmtEngineering(columns, rows, decimals)` SHALL show numbers in scientific notation with exponents
in steps of three; `fmtNumberSi(columns, rows, unit, decimals, inclSpace)` SHALL show them with an
SI prefix (from quecto to quetta) before an optional unit.

```nim
let d = tableData:
  x: [12345.0, 0.000123, 1.5]
let engineering = tabella(d):
  fmtEngineering "x"
echo engineering
let si = tabella(d):
  fmtNumberSi "x", unit = "g"
echo si
```

```text
┌───────────────┐
│             x │
╞═══════════════╡
│   12.35 × 10³ │
│ 123.00 × 10⁻⁶ │
│          1.50 │
└───────────────┘
┌───────────┐
│         x │
╞═══════════╡
│  12.35 kg │
│ 123.00 µg │
│    1.50 g │
└───────────┘
```

### Requirement: Parts per
`fmtPartsper(columns, rows, toUnits, decimals, scaleValues, inclSpace)` SHALL show fractions as
parts per thousand (`"per-mille"`, ‰), ten thousand (`"per-myriad"`, ‱), hundred thousand
(`"pcm"`), million (`"ppm"`), billion (`"ppb"`), trillion (`"ppt"`) or quadrillion (`"ppq"`).
With `inclSpace = "auto"` there SHALL be a space before letters and none before ‰ and ‱.

```nim
let d = tableData:
  co2: [0.000421, 0.000280]
let ppm = tabella(d):
  fmtPartsper "co2", toUnits = "ppm", decimals = 0
echo ppm
let perMille = tabella(d):
  fmtPartsper "co2", decimals = 3
echo perMille
```

```text
┌─────────┐
│     co2 │
╞═════════╡
│ 421 ppm │
│ 280 ppm │
└─────────┘
┌────────┐
│    co2 │
╞════════╡
│ 0.421‰ │
│ 0.280‰ │
└────────┘
```

### Requirement: Bytes
`fmtBytes(columns, rows, standard, decimals, inclSpace)` SHALL show sizes in bytes with decimal
(kB, MB, GB, powers of 1000) or binary (KiB, MiB, GiB, powers of 1024) units, dropping trailing
zeros; sizes below one unit SHALL show whole bytes.

```nim
let d = tableData:
  size: [512, 1500, 1536, 3_200_000_000]
let t = tabella(d):
  fmtBytes "size"
  fmtBytes "size", rows = [2], standard = "binary"
echo t
```

```text
┌─────────┐
│    size │
╞═════════╡
│   512 B │
│  1.5 kB │
│ 1.5 KiB │
│  3.2 GB │
└─────────┘
```

### Requirement: Letters and spelled numbers
`fmtIndex(columns, rows, upper, indexAlgo)` SHALL show whole numbers as letters (1 is A, 26 is Z,
27 is AA, then BB with `"repeat"` or AB with `"excel"`); `fmtSpelledNum(columns, rows)` SHALL
spell numbers from zero to one hundred in English, and leave others as digits.

```nim
let d = tableData:
  n: [1, 3, 27, 42]
let index = tabella(d):
  fmtIndex "n", upper = false
echo index
let spelled = tabella(d):
  fmtSpelledNum "n"
echo spelled
```

```text
┌────┐
│  n │
╞════╡
│  a │
│  c │
│ aa │
│ pp │
└────┘
┌──────────────┐
│            n │
╞══════════════╡
│          one │
│        three │
│ twenty-seven │
│    forty-two │
└──────────────┘
```

### Requirement: Times and datetimes
`fmtTime(columns, rows, timeStyle)` SHALL show times ("14:35", "14:35:07", or the time part of an
ISO datetime) in a named style (`timeStyles`: `"iso"`, `"iso-short"`, `"h_m_s_p"`, `"h_m_p"`,
`"h_p"`, ...); `fmtDatetime(columns, rows, dateStyle, timeStyle, sep)` SHALL show ISO datetimes as
a date and a time, each in its style. Text that is not a time SHALL be left as it is.

```nim
let d = tableData:
  launch: ["1969-07-16T13:32:00", "2026-11-07 09:05", "soon"]
let t = tabella(d):
  fmtDatetime "launch", dateStyle = "day_m_year", timeStyle = "h_m_p"
echo t
echo formatTime("14:35:07", "iso-short"), " ", formatTime("14:35", "h_p")
```

```text
┌─────────────────────┐
│ launch              │
╞═════════════════════╡
│ 16 Jul 1969 1:32 PM │
│ 7 Nov 2026 9:05 AM  │
│ soon                │
└─────────────────────┘
14:35 2 PM
```

### Requirement: Durations
`fmtDuration(columns, rows, inputUnits, outputUnits, durationStyle, trimZeroUnits, maxOutputUnits)`
SHALL show numbers as lengths of time in weeks, days, hours, minutes and seconds, in the styles
`"narrow"` (2h 5m), `"wide"` (2 hours 5 minutes), `"colon-sep"` (02:05:03) and `"iso"` (PT2H5M).
The smallest output unit SHALL be rounded.

```nim
let d = tableData:
  secs: [7503.0, 90061.0, 45.0]
let narrow = tabella(d):
  fmtDuration "secs"
echo narrow
let colons = tabella(d):
  fmtDuration "secs", durationStyle = "colon-sep"
echo colons
echo formatDuration(1.5, inputUnits = "days", durationStyle = "wide")
```

```text
┌─────────────┐
│        secs │
╞═════════════╡
│    2h 5m 3s │
│ 1d 1h 1m 1s │
│         45s │
└─────────────┘
┌──────────┐
│     secs │
╞══════════╡
│ 02:05:03 │
│ 25:01:01 │
│ 00:00:45 │
└──────────┘
1 day 12 hours
```

### Requirement: Booleans
`fmtTf(columns, rows, tfStyle, trueText, falseText, naText, colors, html)` SHALL show booleans in
a named style (`tfStyles`: `"true-false"`, `"yes-no"`, `"up-down"`, `"check-mark"`, `"circles"`,
`"squares"`, `"diamonds"`, `"arrows"`, `"triangles"`, `"triangles-lr"`) or as two texts of your
own, with `naText` for missing values and `colors` for true and false in HTML. With `html = true`
the texts SHALL be HTML (an SVG symbol, say), not escaped.

```nim
let d = tableData:
  rings: [false, true, nil]
let circles = tabella(d):
  fmtTf "rings", tfStyle = "circles", naText = "?"
echo circles
let t = tabella(d):
  fmtTf "rings", trueText = "<b>yes</b>", falseText = "no", html = true, colors = ["green", "gray"]
echo "<span style=\"color: green\"><b>yes</b></span>" in t.toHtml
```

```text
┌───────┐
│ rings │
╞═══════╡
│ ○     │
│ ●     │
│ ?     │
└───────┘
true
```

### Requirement: Links
`fmtUrl(columns, rows, label, asButton, color, target, showUnderline)` SHALL make links of
addresses, with the address as text unless `label` is given or the cell is a Markdown link
`[label](address)`; `fmtEmail` SHALL do the same with `mailto:` links. In text, the label SHALL be
shown.

```nim
let d = tableData:
  site: ["https://nim-lang.org", "[nimib](https://github.com/pietroppeter/nimib)"]
let t = tabella(d):
  fmtUrl "site"
echo t
echo "<a href=\"https://github.com/pietroppeter/nimib\">nimib</a>" in t.toHtml
```

```text
┌──────────────────────┐
│ site                 │
╞══════════════════════╡
│ https://nim-lang.org │
│ nimib                │
└──────────────────────┘
true
```

### Requirement: Flags
`fmtFlag(columns, rows, sep, useTitle)` SHALL show country codes (ISO 3166-1, two or three
letters, several separated by commas) as flag emoji, built from regional indicator letters, so
nothing is loaded and every renderer shows them; with `useTitle` the code SHALL be the HTML title.

```nim
let d = tableData:
  country: ["IT", "JPN", "FR,DE"]
let t = tabella(d):
  fmtFlag "country"
echo t
```

```text
┌─────────┐
│ country │
╞═════════╡
│ 🇮🇹      │
│ 🇯🇵      │
│ 🇫🇷 🇩🇪   │
└─────────┘
```

### Requirement: Small, large and given values
`subSmallVals(columns, rows, threshold = 0.01, smallPattern = "<{x}", sign)` SHALL show numbers
closer to zero than the threshold (but not zero) as the pattern, with the threshold for `{x}`;
`subLargeVals(columns, rows, threshold = 1e12, largePattern = ">={x}", sign)` SHALL do the same for
numbers at or beyond the threshold; `sign = "-"` SHALL apply them to negative numbers.
`subValues(columns, rows, values, replacement)` SHALL show the given values, or the values for which
a proc `fn` holds, as a text.

```nim
let d = tableData:
  x: [0.004, 2.5, 3e13, -99.0]
let t = tabella(d):
  fmtNumber "x"
  subSmallVals()
  subLargeVals()
  subValues values = [-99], replacement = "n/a"
echo t
```

```text
┌───────┐
│     x │
╞═══════╡
│ <0.01 │
│  2.50 │
│  >=1T │
│   n/a │
└───────┘
```

### Requirement: Text transforms
`textTransform(fn, locations)` SHALL change the shown text at locations (by default the body) with a
proc: for body and stub cells the proc SHALL get the formatted text when the table is rendered, for
labels and notes their text when the verb is called. `textReplace(pattern, replacement, locations)`
SHALL replace a plain text, and `textCaseMatch(cases, default, replace, locations)` SHALL change
texts that match a case (or, with `replace = "partial"`, the matching parts).

```nim
let t = tabella(planets(), rownameCol = "planet"):
  tabStubhead "planet"
  colsHide ["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "moons"]
  textTransform toUpperAscii, loc.stub()
  fmtTf "rings", tfStyle = "yes-no"
  textCaseMatch:
    yes: "rings!"
    default = ""
    locations = loc.body("rings")
  textReplace "planet", "Planet", loc.stubhead()
echo t
```

```text
┌─────────┬────────┐
│ Planet  │ rings  │
╞═════════╪════════╡
│ MERCURY │ no     │
│ VENUS   │ no     │
│ EARTH   │ no     │
│ MARS    │ no     │
│ JUPITER │ rings! │
│ SATURN  │ rings! │
│ URANUS  │ rings! │
│ NEPTUNE │ rings! │
└─────────┴────────┘
```

### Requirement: Units
`formatUnits(s, ctx)` SHALL read units in gt's notation: tokens separated by spaces, `^` before a
power, `_` before a subscript, `[_a^b]` for both stacked, a token after a lone `/` as a power −1
(`"m /s"` is "m s⁻¹"), `:name:` for a symbol (`:mu:`, `:ohm:`, `:degree:`, the Greek letters),
`degC`, `degF`, `um`, `ug`, `uL`, `ohm`, `x10` as "×10", `*...*` for emphasis and `%...%` for a
chemical formula. HTML SHALL use `<sup>` and `<sub>`; text SHALL use Unicode superscripts and
subscripts, or `^x` and `_x` when a character has none. `fmtUnits(columns, rows)` SHALL show cells
as units, `colsUnits(units, unitsPattern = "{1}, {2}")` SHALL add units to column labels, and
units between `{{` and `}}` in a column label, a spanner or the stubhead SHALL be shown as units.

```nim
let d = tableData:
  quantity: ["speed of sound", "gravity", "air density"]
  value: [343.0, 9.81, 1.204]
  units: ["m /s", "m s^-2", "kg m^-3"]
let quantities = tabella(d, rownameCol = "quantity"):
  fmtUnits "units"
  colsLabel:
    value: "at {{20 degC}}"
echo quantities
let gravity = tabella(planets(), rownameCol = "planet"):
  colsHide everything()
  colsUnhide ["density", "gravity"]
  colsUnits:
    density: "kg m^-3"
    gravity: "m s^-2"
    unitsPattern = "{1} ({2})"
echo gravity
```

```text
┌────────────────┬──────────┬────────┐
│                │ at 20 °C │ units  │
╞════════════════╪══════════╪════════╡
│ speed of sound │    343.0 │ m s⁻¹  │
│ gravity        │     9.81 │ m s⁻²  │
│ air density    │    1.204 │ kg m⁻³ │
└────────────────┴──────────┴────────┘
┌─────────┬──────────────────┬─────────────────┐
│         │ density (kg m⁻³) │ gravity (m s⁻²) │
╞═════════╪══════════════════╪═════════════════╡
│ Mercury │             5429 │             3.7 │
│ Venus   │             5243 │             8.9 │
│ Earth   │             5514 │             9.8 │
│ Mars    │             3934 │             3.7 │
│ Jupiter │             1326 │            23.1 │
│ Saturn  │              687 │             9.0 │
│ Uranus  │             1270 │             8.7 │
│ Neptune │             1638 │            11.0 │
└─────────┴──────────────────┴─────────────────┘
```

### Requirement: Chemical formulas
`formatChem(s, ctx)` SHALL read formulas and reactions in gt's notation: digits after an element
or a bracket as subscripts, a count before a formula (`2H2O`), a charge after `^` or after a
count (`SO4^2-`, `NH4+`), an isotope before an element (`^14C`, `^{235}_{92}U`), `->`, `<-`,
`<->`, `<-->`, `<=>` as arrows, `^` and `v` alone as a gas and a precipitate, `*` and `.` alone as
a dot. `fmtChem(columns, rows)` SHALL show cells as formulas.

```nim
let d = tableData:
  name: ["water", "copper sulfate", "sulfate", "carbon-14"]
  formula: ["H2O", "CuSO4 * 5H2O", "SO4^2-", "^14C"]
let t = tabella(d, rownameCol = "name"):
  fmtChem "formula"
echo t
echo formatChem("2H2 + O2 -> 2H2O")
```

```text
┌────────────────┬─────────────┐
│                │ formula     │
╞════════════════╪═════════════╡
│ water          │ H₂O         │
│ copper sulfate │ CuSO₄⋅5 H₂O │
│ sulfate        │ SO₄²⁻       │
│ carbon-14      │ ¹⁴C         │
└────────────────┴─────────────┘
2 H₂ + O₂ → 2 H₂O
```

### Requirement: Fractions
`formatFraction(x, accuracy, denominator, simplify, layout, useSeps, sepMark, ctx)` SHALL show a
number as a mixed fraction: the whole part, then the closest fraction with a denominator up to 9
(`accuracy = "low"`), 99 (`"med"`) or 999 (`"high"`), or with the given `denominator` (reduced
when `simplify`). A fraction that rounds to a whole number SHALL show just the number.
`layout = "diagonal"` SHALL show the fraction as a superscript, a fraction slash and a subscript.
`fmtFraction(columns, rows, ...)` SHALL format cells so.

```nim
let d = tableData:
  x: [0.25, 1.5, 2.333, 0.999, -0.125]
let t = tabella(d):
  colsAdd "diagonal", d["x"].values
  colsAdd "sixteenths", d["x"].values
  fmtFraction "x"
  fmtFraction "diagonal", layout = "diagonal"
  fmtFraction "sixteenths", denominator = 16
echo t
```

```text
┌───────┬──────────┬────────────┐
│     x │ diagonal │ sixteenths │
╞═══════╪══════════╪════════════╡
│   1/4 │      ¹⁄₄ │        1/4 │
│ 1 1/2 │     1¹⁄₂ │      1 1/2 │
│ 2 1/3 │     2¹⁄₃ │     2 5/16 │
│     1 │        1 │          1 │
│  −1/8 │     −¹⁄₈ │       −1/8 │
└───────┴──────────┴────────────┘
```

### Requirement: Bins
`formatBins(s, sep = "--", fmt)` SHALL show an interval written as `[a,b)`, `(a,b]`, `[a,b]` or
`(a,b)` as `a`, `sep` (where `--` is an en dash), `b`; `fmt`, a proc of a float, SHALL format each
end. Other text SHALL be shown as it is. `fmtBins(columns, rows, sep, fmt)` SHALL format cells so.

```nim
let d = tableData:
  population: ["[0,1e+06)", "[1e+06,1e+07)", "[1e+07,1e+08)"]
  countries: [52, 61, 83]
let t = tabella(d):
  fmtBins "population", fmt = proc (x: float): string = formatCompact(x, 0)
echo t
```

```text
┌────────────┬───────────┐
│ population │ countries │
╞════════════╪═══════════╡
│ 0–1M       │        52 │
│ 1M–10M     │        61 │
│ 10M–100M   │        83 │
└────────────┴───────────┘
```

### Requirement: Passthrough and automatic formats
`fmtPassthrough(columns, rows, escape = true, pattern = "{x}")` SHALL show values as they are, in
the pattern; with `escape = false` a value SHALL be HTML. `fmtAuto(columns, rows, scope =
["numbers", "currency"], lgNumPref = "sci")` SHALL give each numeric column a format: a currency
when the column's name ends with `_` or `.` and a currency code, else numbers with no decimals in a
column of whole numbers and up to three otherwise (trailing zeros dropped), and scientific
notation, with up to three decimals, for values below 0.001 or from a million (`lgNumPref = "suf"`: a suffix, "12.3M", up to
10¹⁵).

```nim
let d = tableData:
  item: ["a", "b", "c"]
  count: [3, 2500000, 12]
  ratio: [0.5, 0.0000123, 1.25]
  price_eur: [3.5, 10.0, 99.99]
let t = tabella(d):
  fmtAuto()
  fmtPassthrough "item", pattern = "item {x}"
echo t
```

```text
┌────────┬───────────┬─────────────┬───────────┐
│ item   │     count │       ratio │ price_eur │
╞════════╪═══════════╪═════════════╪═══════════╡
│ item a │         3 │         0.5 │     €3.50 │
│ item b │ 2.5 × 10⁶ │ 1.23 × 10⁻⁵ │    €10.00 │
│ item c │        12 │        1.25 │    €99.99 │
└────────┴───────────┴─────────────┴───────────┘
```

### Requirement: Country names
`countryName(code)` SHALL give the English name of a country or territory by its two- or
three-letter code (ISO 3166-1, any case), from Unicode CLDR, and the code itself when it is not
one. `formatCountry(codes, sep = ", ")` SHALL do so for several codes separated by commas or
spaces, and `fmtCountry(columns, rows, pattern, sep)` SHALL format cells so.

```nim
let d = tableData:
  codes: ["IT", "jpn", "FR, DE", "XX"]
let t = tabella(d):
  colsAdd "names", d["codes"].values
  fmtCountry "names"
echo t
```

```text
┌────────┬─────────────────┐
│ codes  │ names           │
╞════════╪═════════════════╡
│ IT     │ Italy           │
│ jpn    │ Japan           │
│ FR, DE │ France, Germany │
│ XX     │ XX              │
└────────┴─────────────────┘
```

### Requirement: Currencies
`fmtCurrency(columns, rows, currency, decimals, placement, accounting, useSubunits, locale)` SHALL
take any ISO 4217 code that CLDR knows, with its symbol and its number of decimals; the symbol
SHALL go where the locale's pattern puts it, or on the `placement` given ("left", "right"), with a
no-break space when the symbol ends or starts with a letter. `accounting` SHALL write negative
amounts in parentheses; `useSubunits = false` SHALL drop the decimals.

```nim
let d = tableData:
  amount: [1234.5, -3.25]
let accounting = tabella(d):
  fmtCurrency "amount", currency = "CAD", accounting = true
echo accounting
let euro = tabella(d, locale = "it"):
  fmtCurrency "amount", currency = "EUR"
echo euro
let dinar = tabella(d):
  fmtCurrency "amount", currency = "BHD", placement = "right"
echo dinar
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
let german = tabella(d, locale = "de"):
  fmtDate "day", dateStyle = "yMMMEd"
echo german
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

### Requirement: Icons
`fmtIcon(columns, rows, height = "1em", sep, ...)` SHALL show each cell's names of Font Awesome
Free icons (several separated by commas) as inline SVG, `height` high and as wide as their
shape, in the text's colour unless `fillColor` or, by name, `fillColors` is given. A name SHALL
be a short name (the regular style when there are two), a full name ("fas fa-star") or an older
name ("user-large"); an unknown name SHALL raise `ValueError` when the verb is called. In text
output the names SHALL stay.

```nim
let d = tableData:
  planet: ["Earth", "Jupiter"]
  kind: ["mountain", "cloud, star"]
let t = tabella(d):
  fmtIcon "kind", fillColors = {"star": "gold"}
echo t
echo t.toHtml.count("class=\"tb_icon\""), " ", icon("star").style, " ", icon("fas fa-star").style, " ", hasIcon("user-large")
```

```text
┌─────────┬─────────────┐
│ planet  │ kind        │
╞═════════╪═════════════╡
│ Earth   │ mountain    │
│ Jupiter │ cloud, star │
└─────────┴─────────────┘
3 regular solid true
```

### Requirement: Images
`fmtImage(columns, rows, height, width, sep, path, filePattern = "{x}", encode = true, alt)`
SHALL show each cell's file names (several separated by commas) as images, found in `path` and
written with `filePattern`. With `encode`, a local file SHALL be read when the verb is called
and inlined as a data URL, its type from its extension; an address (`https://...`) SHALL be
left as it is. Without `height` or `width` an image SHALL be 2em high. In text output the names
SHALL stay.

```nim
let dir = getTempDir()
writeFile(dir / "dot.svg", "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 2 2'><circle cx='1' cy='1' r='1'/></svg>")
let d = tableData:
  pic: ["dot"]
let t = tabella(d):
  fmtImage "pic", path = dir, filePattern = "{x}.svg"
echo t
echo t.toHtml.contains("<img src=\"data:image/svg+xml;base64,")
```

```text
┌─────┐
│ pic │
╞═════╡
│ dot │
└─────┘
true
```

### Requirement: Nanoplots
`fmtNanoplot(columns, rows, plotType = "line", plotHeight = "2em", missingVals = "gap",
autoscale, referenceLine, referenceArea, expandY, options, alt)` SHALL draw a plot in each cell,
as inline SVG: a line plot ("line"), a bar plot ("bar") or a box plot ("boxplot") of the cell's
values (numbers separated by spaces, commas or semicolons, `NA` for a missing one), or, in a
column of numbers, a horizontal bar or line from a zero line shared by the rows. The values
SHALL show when the pointer is over the plot, without JavaScript. A missing value SHALL break
the line ("gap"), be marked ("marker"), count as 0 ("zero") or be left out ("remove").
`referenceLine` SHALL be a number or a statistic of the values ("mean", "median", "min", "max",
"q1", "q3", "first", "last"), and `referenceArea` two of them. With `autoscale` every plot of the
column SHALL share its y axis. `nanoplotOptions(...)` SHALL hold the look, with Great Tables'
defaults. In text output a nanoplot SHALL be a sparkline, a bar of blocks beside a zero line, or
the five numbers of a box plot.

```nim
let d = tableData:
  city: ["Oslo", "Rome"]
  trend: ["1 4 2 8 5", "3, NA, 6, 2"]
  change: [4.2, -1.5]
let t = tabella(d, rownameCol = "city"):
  fmtNanoplot "trend", referenceLine = "mean"
  fmtNanoplot "change", plotType = "bar"
echo t
echo t.toHtml.count("class=\"tb_nanoplot\""), " ", nanoplotLabel(1234), " ", nanoplotLabel(0.25)
```

```text
┌──────┬───────────┬───────────────────┐
│      │ trend     │            change │
╞══════╪═══════════╪═══════════════════╡
│ Oslo │ ▁▄▂█▅ 1–8 │    │███████ 4.20  │
│ Rome │ ▃ █▁ 2–6  │ ███│        −1.50 │
└──────┴───────────┴───────────────────┘
4 1.23K 0.25
```

### Requirement: Formats on lists and records
A format SHALL apply to a list item by item and to a record field by field, keeping the
separators of `$` ("1.2, 1.6", "lo: 0.8, hi: 1.6"); an item that the format does not take
SHALL be shown as it is. `fmtIcon`, `fmtImage` and `fmtFlag` SHALL take a list of names as
they take names separated by commas.

```nim
let d = tableData:
  sensor: ["north", "south"]
  readings: [@[1.24, 1.56], @[12.71]]
  span: [(lo: 0.82, hi: 1.56), (lo: 9.13, hi: 12.71)]
let t = tabella(d, rownameCol = "sensor"):
  fmtNumber ["readings", "span"], decimals = 1
echo t
```

```text
┌───────┬──────────┬───────────────────┐
│       │ readings │ span              │
╞═══════╪══════════╪═══════════════════╡
│ north │ 1.2, 1.6 │ lo: 0.8, hi: 1.6  │
│ south │ 12.7     │ lo: 9.1, hi: 12.7 │
└───────┴──────────┴───────────────────┘
```

### Requirement: Nanoplots of lists and of x and y
`fmtNanoplot` SHALL read a list of numbers as the values of a cell, and a record as its field
`y`, with its field `x` (as many) the places of the values on the x axis of a line plot, in the
order of `x`; a bar or box plot SHALL leave `x` out. With `autoscale` the rows SHALL share the x
axis too, and `expandX` SHALL widen it; on a shared x axis every row's plot SHALL have the same
width, so the axes line up. A record without `y`, or with an `x` of another length,
SHALL raise `ValueError` when the verb is called. In text output the sparkline SHALL follow the
order of `x`.

```nim
let d = tableData:
  runner: ["Anna", "Bruno"]
  laps: [(x: @[0.0, 1, 2, 5], y: @[62.0, 60, 61, 58]), (x: @[0.0, 3, 4, 5], y: @[65.0, 63, 66, 59])]
  kit: [@["person-running", "stopwatch"], @["person-biking"]]
let t = tabella(d, rownameCol = "runner"):
  fmtNanoplot "laps", autoscale = true
  fmtIcon "kit"
echo t
echo nanoplotXValues(d["laps", 1]), " ", t.toHtml.count("class=\"tb_nanoplot\"")
```

```text
┌───────┬────────────┬───────────────────────────┐
│       │ laps       │ kit                       │
╞═══════╪════════════╪═══════════════════════════╡
│ Anna  │ ▅▃▄▁ 58–62 │ person-running, stopwatch │
│ Bruno │ ▇▅█▂ 59–66 │ person-biking             │
└───────┴────────────┴───────────────────────────┘
@[0.0, 3.0, 4.0, 5.0] 2
```

### Requirement: Vertical reference lines
`fmtNanoplot` SHALL take `referenceX`, a list of places on the x axis (numbers, or ISO dates
such as "2020-03-11"), and in a line plot of records of `x` and `y` SHALL draw a dashed vertical
line at each place inside the axis, its text shown on hover. A place outside the axis SHALL
draw nothing; a place that is neither a number nor a date SHALL raise `ValueError` when the verb
is called. Text output SHALL be unchanged.

```nim
let d = tableData:
  airport: ["north", "south"]
  flights: [(x: @["2018-07-01", "2019-07-01", "2020-07-01", "2021-07-01"], y: @[6.8, 7.3, 1.8, 2.7]),
            (x: @["2019-07-01", "2020-07-01", "2021-07-01"], y: @[3.4, 1.0, 1.9])]
let t = tabella(d, rownameCol = "airport"):
  fmtNanoplot "flights", autoscale = true, referenceX = @["2020-03-11"]
echo t
echo t.toHtml.count("2020-03-11"), " lines"
```

```text
┌───────┬────────────────┐
│       │ flights        │
╞═══════╪════════════════╡
│ north │ ▇█▂▃ 1.80–7.30 │
│ south │ ▄▁▂ 1.00–3.40  │
└───────┴────────────────┘
2 lines
```

### Requirement: Images anywhere
`localImage(file, height = "2em", alt = "")` SHALL give an `<img>` as `Text` (HTML), the file
read when called and inlined as a data URL, and `webImage(url, height = "2em", alt = "")` the
same with the address left as it is, as gt's `local_image()` and `web_image()`; they go in a
title, a label, a note, or a cell through `fmtMarkdown` or `html`. `alt` SHALL be by default the
file's name (the last part of the address), and text output SHALL show it.

```nim
let t = tabella(planets()):
  colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "moons", "rings", "diameter", "type"]
  rowsHide [1, 2, 3, 4, 5, 6, 7]
  tabHeader webImage("https://example.org/sun.png", alt = "☉"), "The first planet"
echo t
echo t.toHtml.count("<img src=\"https://example.org/sun.png\"")
```

```text
        ☉
 The first planet
┌─────────┬──────┐
│ planet  │ mass │
╞═════════╪══════╡
│ Mercury │ 0.33 │
└─────────┴──────┘
1
```

### Requirement: Named font stacks
`systemFonts(name = "system-ui")` SHALL give one of Great Tables' fifteen font stacks
(`fontStackNames`: "system-ui", "transitional", "old-style", "humanist", "geometric-humanist",
"classical-humanist", "neo-grotesque", "monospace-slab-serif", "monospace-code", "industrial",
"rounded-sans", "slab-serif", "antique", "didone", "handwritten") as CSS text, for
`optTableFont`; another name SHALL raise `ValueError`. `defaultFonts()` SHALL give gt's default
stack.

```nim
echo systemFonts("old-style")
echo fontStackNames.len
let t = tabella(planets()):
  optTableFont systemFonts("humanist")
echo t.options.tableFontNames.startsWith("'Seravek'")
```

```text
'Iowan Old Style', 'Palatino Linotype', 'URW Palladio L', 'P052', serif
15
true
```

### Requirement: Nanoplot options for each point
The options of `nanoplotOptions` for points and bars (`dataPointRadius`,
`dataPointStrokeColor`, `dataPointStrokeWidth`, `dataPointFillColor`, `dataBarStrokeColor`,
`dataBarStrokeWidth`, `dataBarFillColor`) SHALL take a list as well as one value: the n-th point
or bar takes the n-th value, and the list repeats. The `x` of a record SHALL also take ISO dates
and times ("2026-11-11", "2026-11-11 10:30"), placed by time.

```nim
let d = tableData:
  week: ["one", "two"]
  steps: [toValue(@[4, 8, 6]), toValue((x: @["2026-11-02", "2026-11-03", "2026-11-09"], y: @[5, 7, 9]))]
let t = tabella(d, rownameCol = "week"):
  fmtNanoplot "steps", options = nanoplotOptions(dataPointFillColor = @["#D64545", "#2E7D32"])
echo t
let x = nanoplotXValues(d["steps", 1])
echo t.toHtml.count("fill=\"#2E7D32\""), " green points; the last is ", (x[2] - x[0]) / 86400, " days after the first"
```

```text
┌─────┬─────────┐
│     │ steps   │
╞═════╪═════════╡
│ one │ ▁█▅ 4–8 │
│ two │ ▁▅█ 5–9 │
└─────┴─────────┘
2 green points; the last is 7.0 days after the first
```

### Requirement: Shape nanoplots
`fmtNanoplot(columns, plotType = "shape", ...)` SHALL draw each cell's record of `x` and `y` as
one outline: the points joined in their order and closed, filled, at the same scale across and
up, in a square as high as the plot (not from gt or Great Tables). With `autoscale` every shape
of the column SHALL have the scale of the largest one; a missing value SHALL start a new ring.
The fill and the line SHALL be `dataBarFillColor` and `dataBarStrokeColor`. A cell that is not
a record of `x` and `y` SHALL raise `ValueError`. In text a shape SHALL be "◆ shape of N points".

```nim
let d = tableData:
  field: ["square", "strip"]
  outline: [toValue((x: @[0, 2, 2, 0], y: @[0, 0, 2, 2])), toValue((x: @[0, 4, 4, 0], y: @[0, 0, 1, 1]))]
let t = tabella(d, rownameCol = "field"):
  fmtNanoplot "outline", plotType = "shape", autoscale = true
echo t
echo t.toHtml.count("class=\"tb_shape\""), " shapes; the square is ", shapeSide(@[0.0, 0, 2, 2], @[0.0, 2, 2, 0]), " wide"
```

```text
┌────────┬─────────────────────┐
│        │ outline             │
╞════════╪═════════════════════╡
│ square │ ◆ shape of 4 points │
│ strip  │ ◆ shape of 4 points │
└────────┴─────────────────────┘
2 shapes; the square is 2.0 wide
```
