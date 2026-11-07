## ADDED Requirements

### Requirement: Flags
`fmtFlag(columns, rows, sep, useTitle)` SHALL show two-letter country codes (ISO 3166-1 alpha-2,
several separated by commas) as flag emoji, built from regional indicator letters, so nothing is
loaded and every renderer shows them; with `useTitle` the code SHALL be the HTML title.

```nim
let d = tableData:
  country: ["IT", "JP", "FR,DE"]
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
