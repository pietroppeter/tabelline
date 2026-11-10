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
echo tabella(d).fmtNumber("x", decimals = 1).fmtNumber("x", decimals = 3, rows = [0])
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
echo tabella(d).fmtNumber("n", decimals = 2)
echo tabella(d).fmtNumber("n", compact = true)
echo tabella(d).fmtPercent("n", decimals = 1)
echo tabella(d).fmtCurrency("n", currency = "EUR")
echo tabella(d).fmtScientific("n", decimals = 1)
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
decimal marks of its number formats; a format's own `locale`, `sepMark` or `decMark` SHALL win.

```nim
let d = tableData:
  n: [1234.5, 0.25]
echo tabella(d, locale = "it").fmtNumber("n", decimals = 2)
echo tabella(d, locale = "fr").fmtNumber("n", decimals = 2)
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
│ 1 234,50 │
│     0,25 │
└──────────┘
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
echo tabella(d).fmtDate("day", dateStyle = "day_month_year").fmtTf("ok", trueText = "yes", falseText = "no")
  .fmt("stars", proc (v: Value): string = "*".repeat(v.i))
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
echo tabella(d).subMissing().subZero(zeroText = "none")
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
echo tabella(d).fmtEngineering("x")
echo tabella(d).fmtNumberSi("x", unit = "g")
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
echo tabella(d).fmtPartsper("co2", toUnits = "ppm", decimals = 0)
echo tabella(d).fmtPartsper("co2", decimals = 3)
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
echo tabella(d).fmtBytes("size").fmtBytes("size", rows = [2], standard = "binary")
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
echo tabella(d).fmtIndex("n", upper = false)
echo tabella(d).fmtSpelledNum("n")
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
echo tabella(d).fmtDatetime("launch", dateStyle = "day_m_year", timeStyle = "h_m_p")
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
echo tabella(d).fmtDuration("secs")
echo tabella(d).fmtDuration("secs", durationStyle = "colon-sep")
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
echo tabella(d).fmtTf("rings", tfStyle = "circles", naText = "?")
let t = tabella(d).fmtTf("rings", trueText = "<b>yes</b>", falseText = "no", html = true, colors = ["green", "gray"])
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
let t = tabella(d).fmtUrl("site")
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
echo tabella(d).fmtFlag("country")
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
echo tabella(d).fmtNumber("x").subSmallVals().subLargeVals().subValues(values = [-99], replacement = "n/a")
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
echo tabella(planets(), rownameCol = "planet").tabStubhead("planet")
  .colsHide(["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "moons"])
  .textTransform(toUpperAscii, loc.stub())
  .fmtTf("rings", tfStyle = "yes-no")
  .textCaseMatch({"yes": "rings!"}, default = "", locations = loc.body("rings"))
  .textReplace("planet", "Planet", loc.stubhead())
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
echo tabella(d, rownameCol = "quantity").fmtUnits("units").colsLabel({"value": "at {{20 degC}}"})
echo tabella(planets(), rownameCol = "planet")
  .colsHide(everything()).colsUnhide(["density", "gravity"])
  .colsUnits({"density": "kg m^-3", "gravity": "m s^-2"}, unitsPattern = "{1} ({2})")
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
echo tabella(d, rownameCol = "name").fmtChem("formula")
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
echo tabella(d).colsAdd("diagonal", d["x"].values).colsAdd("sixteenths", d["x"].values)
  .fmtFraction("x")
  .fmtFraction("diagonal", layout = "diagonal")
  .fmtFraction("sixteenths", denominator = 16)
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
echo tabella(d).fmtBins("population", fmt = proc (x: float): string = formatCompact(x, 0))
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
echo tabella(d).fmtAuto().fmtPassthrough("item", pattern = "item {x}")
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
echo tabella(d).colsAdd("names", d["codes"].values).fmtCountry("names")
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
