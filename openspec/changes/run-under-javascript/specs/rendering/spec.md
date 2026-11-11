## ADDED Requirements

### Requirement: Under JavaScript
tabelline SHALL compile with `nim js` and write the same output as when compiled to C, byte for
byte: a tie rounds to the even digit on both (`formatNumber(2.25, 1)` is "2.2"). Under
JavaScript a file name for an image SHALL raise a `ValueError` (there are no files); an address
works. `-d:tabellineIcons=false` SHALL leave the icons out of a build and
`-d:tabellineDatasets=false` the datasets but `planets`, `exibble` and `tavolaPitagorica`; what
is left out SHALL raise a `ValueError` that names the define. Both are true by default, on every
backend.

```nim
echo formatNumber(2.25, 1), " ", formatNumber(2.35, 1), " ", formatNumber(2.5, 0)
echo tabellineIcons, " ", tabellineDatasets
```

```text
2.2 2.4 2
true true
```

#### Scenario: The tests in Node
- **WHEN** the tests are compiled with `nim js -d:nodejs` and run in Node (`tests/js.nim`)
- **THEN** they pass, as they do in C

#### Scenario: A lean build
- **WHEN** a program is compiled with `-d:tabellineIcons=false -d:tabellineDatasets=false`
- **THEN** `fmtIcon` and `gtcars()` raise a `ValueError` naming the define, and every other verb works
