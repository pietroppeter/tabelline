## MODIFIED Requirements

### Requirement: Datasets
`tabelline/datasets` SHALL provide `planets()` (NASA's planetary fact sheet), `exibble()` (gt's
example table), `tavolaPitagorica(n)` (the n×n times table), `isole()` (the islands of the
Mediterranean, the twin of gt's `islands`) and `citta()` (the largest cities of the European
Union, the twin of gt's `towny`), built into the module.

```nim
echo tabella(tavolaPitagorica(4), rownameCol = "×")
echo isole().nrows, " islands, ", citta().nrows, " cities; the largest: ", isole()["island", 0], ", ", citta()["city", 0]
```

```text
┌───┬───┬───┬────┬────┐
│   │ 1 │ 2 │  3 │  4 │
╞═══╪═══╪═══╪════╪════╡
│ 1 │ 1 │ 2 │  3 │  4 │
│ 2 │ 2 │ 4 │  6 │  8 │
│ 3 │ 3 │ 6 │  9 │ 12 │
│ 4 │ 4 │ 8 │ 12 │ 16 │
└───┴───┴───┴────┴────┘
194 islands, 95 cities; the largest: Sicily, Berlin
```
