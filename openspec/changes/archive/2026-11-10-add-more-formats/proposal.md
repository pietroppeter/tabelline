## Why

Pietro asked (10 Nov 2026, 0.2 build thread) to bring into 0.2 everything planned for 0.3 and
0.4. This change is the third of five PRs: the formats gt has and tabelline 0.1 did not. It
comes from the Feature map rows of units, fractions, chemical formulas, bins, automatic formats,
passthrough and country names, and the BACKLOG.md entry "More formats". It is built in the PR
stacked on the rows and columns PR, and needs nothing from it.

## What Changes

- Units in gt's notation (`"kg/m^3"`, `"m /s"`, `"T_eff"`, `":mu:g"`, `"degC"`): `formatUnits`,
  `fmtUnits(columns)` for cells, `colsUnits({"density": "kg/m^3"}, unitsPattern = "{1}, {2}")`
  for column labels, and `{{...}}` inside any column label, spanner or stubhead.
- Chemical formulas and reactions (`"CuSO4 * 5H2O"`, `"2H2 + O2 -> 2H2O"`, `"SO4^2-"`):
  `formatChem` and `fmtChem(columns)`; a part between `%` signs inside units is a formula.
- Fractions: `formatFraction`, `fmtFraction(columns, accuracy = "low" | "med" | "high",
  denominator, simplify, layout = "inline" | "diagonal")`.
- Bins: `formatBins`, `fmtBins(columns, sep = "--", fmt)`, from `"[10,20)"` to "10–20".
- `fmtPassthrough(columns, escape, pattern)`: values as they are, in a pattern.
- `fmtAuto(columns, scope, lgNumPref)`: a format for each column from its values.
- Country names: `countryName`, `formatCountry`, `fmtCountry(columns, pattern, sep)`, in English,
  from Unicode CLDR 49 (a module written by `tools/cldr.nim`, under the Unicode License v3).
- `fmtFlag` and `formatFlag` take three-letter codes too (`"ITA"`), as `fmtCountry` does.
- Text output shows superscripts and subscripts with Unicode characters (`kg/m³`, `H₂O`), so
  units and formulas read in the text and Markdown outputs too.

## Differences from gt and Great Tables

- Text output uses Unicode super- and subscripts; when a character has none, it writes `^x` or
  `_x`. gt's plain-text context leaves the notation as it is.
- Units and formulas are plain Unicode where they can be: `µ`, `°C`, `Ω`, Greek letters, the
  arrows of reactions (gt draws reaction arrows as inline SVG). The three equilibrium arrows are
  all `⇌`.
- A charge is written after a caret (`Fe^3+`), as in gt; a sign after a count (`NH4+`) is a
  charge too, as in gt.
- `fmtFraction` takes `accuracy` as "low", "med" or "high" and a fixed denominator as
  `denominator = 16` (gt: one `accuracy` argument for both). A mixed fraction is "2 1/4" inline and
  "2¹⁄₄" diagonal.
- `fmtBins`'s `fmt` is a proc of a float (gt: a formula that formats a gt table).
- `fmtCountry` joins several codes with `", "` (gt: `" "`) and is English only until locales come
  (PR 4 of 0.2); it takes two- and three-letter codes, as gt does.
- `fmtAuto` drops trailing zeros in scientific notation too ("2.5 × 10⁶", gt: "2 × 10⁶" in a
  column of whole numbers, "2.500 × 10⁶" otherwise).
- `fmtAuto` knows the currency codes of `autoCurrencies` (gt: every ISO 4217 code), until the
  currencies of CLDR come in PR 4.
- `colsUnits` takes pairs of a column and its units (gt: `...` of name = units); Great Tables has
  `cols_units` too, and `{{...}}` in `cols_label`, as here.

## Capabilities

### Modified Capabilities
- `formatting`: units, chemistry, fractions, bins, passthrough, automatic formats, country names.

## Impact

`units.nim` (new: units and chemistry), `formats.nim` (fractions, bins, passthrough, auto,
country names, Unicode scripts), `countries.nim` (new, generated), `core.nim` (`ColInfo.units`),
`build.nim` (`renderLabel`, `columnLabel`), the renderers (labels, the CSS of `tb_supsub` and
`tb_frac`), `tools/cldr.nim` (new), `licenses/unicode-cldr-LICENSE.txt` (new), the docs.
