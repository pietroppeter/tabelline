## ADDED Requirements

### Requirement: gt's datasets
`tabelline/datasets` SHALL have four of gt's datasets as Great Tables ships them (MIT):
`gtcars()` (47 cars, 15 columns), `countrypops()` (the population of every country, 1960 to
2022), `illness()` (a patient's tests, days 3 to 9) and `metro()` (the stations of the Paris
Metro).

```nim
let cars = gtcars()
echo cars.nrows, " ", cars.ncols, " ", cars["model", 0]
echo "countrypops: ", countrypops().names.join(", "), "; illness: ", illness().nrows, " rows, metro: ", metro().nrows, " rows"
```

```text
47 15 GT
countrypops: country_name, country_code_2, country_code_3, year, population; illness: 39 rows, metro: 314 rows
```
