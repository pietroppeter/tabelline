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
booleans as two texts; `fmtMarkdown` SHALL read cells as inline Markdown; `fmtBar` SHALL draw a
bar scaled to the column's range; `fmt(columns, proc)` SHALL take any proc from a `Value` to a
string.

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
The functions behind the verbs (`formatNumber`, `formatCompact`, `formatScientific`,
`formatPercent`, `formatCurrency`, `formatRoman`, `formatDate`) SHALL be public, for use outside
tables.

```nim
echo formatNumber(1234567.891), " ", formatCompact(1234567.891), " ", formatScientific(5.97e24)
echo formatPercent(0.1234), " ", formatCurrency(-49.95, "EUR"), " ", formatRoman(2026)
```

```text
1,234,567.89 1.2M 5.97 × 10²⁴
12.3% −€49.95 MMXXVI
```
