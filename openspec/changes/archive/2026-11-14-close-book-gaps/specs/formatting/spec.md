## ADDED Requirements

### Requirement: Significant figures, accounting and the exponent
`fmtNumber(nSigfig = n)` SHALL show `n` significant figures instead of `decimals`, also with
`compact = true`, as gt's `n_sigfig`. `accounting = true` in `fmtNumber`, `fmtInteger`,
`fmtPercent` and `fmtCurrency` SHALL write a negative value in parentheses, without its minus.
`fmtScientific(expStyle = "e")` (or `"E"`) SHALL write the exponent as `1.23e4`, as gt's
`exp_style`. The format functions (`formatNumber`, `formatCompact`, `formatInteger`,
`formatPercent`, `formatScientific`, `formatCurrency`) SHALL take the arguments of their verbs,
`pattern` and `locale` among them.

```nim
echo formatNumber(904512.0, nSigfig = 3), " ", formatCompact(2_051_000.0, nSigfig = 3)
echo formatNumber(-24334.23, accounting = true), " ", formatPercent(-0.0523, accounting = true)
echo formatScientific(12345.0, expStyle = "e"), " ", formatScientific(12345.0, locale = "de")
echo formatNumber(1.64, pattern = "[{x}]"), " ", formatNumber(236742.37, locale = "es")
```

```text
905,000 2.05M
(24,334.23) (5.2%)
1.23e4 1,23 × 10⁴
[1.64] 236.742,37
```

### Requirement: A datetime by a strftime format
`fmtDatetime(formatStr = ...)` and `formatDatetime(formatStr = ...)` SHALL write a date and time
by a strftime format (`%b %d %Y (%a) - %I:%M %p`), in the table's language, as gt's `format` and
Great Tables' `format_str`.

```nim
echo formatDatetime("2023-05-01 18:20:00", formatStr = "%b %d %Y (%a) - %I:%M %p")
echo formatDatetime("2023-05-01 18:20:00", formatStr = "%d %B %Y", locale = "it")
```

```text
May 01 2023 (Mon) - 06:20 PM
01 maggio 2023
```

### Requirement: Round flags, and the country's name
`fmtFlag` SHALL show the country's name when a flag is hovered (its `title`), and with
`round = true` SHALL draw Great Tables' round flags (the circle-flags set, shipped with
tabelline, MIT) at `height`. `circleFlag(code)` SHALL give one as SVG, and `""` for a code it
does not know. `subMissing(missingText = md"**STABLE**")` SHALL take Markdown.

```nim
let d = tableData:
  c: ["IT", "FRA"]
echo tabella(d).fmtFlag("c").toHtml.contains("title=\"France\"")
echo tabella(d).fmtFlag("c", round = true).toHtml.count("<svg"), " ", circleFlag("XX") == ""
```

```text
true
2 true
```
