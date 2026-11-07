## MODIFIED Requirements

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
