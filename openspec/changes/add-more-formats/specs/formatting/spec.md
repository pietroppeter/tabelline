## ADDED Requirements

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

## MODIFIED Requirements

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
