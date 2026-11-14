## ADDED Requirements

### Requirement: Text with a zero in front
`parseCsv` SHALL read a column as text when one of its values is a number written with a zero in
front (`"0400"`, not `"0"` or `"0.5"`), as pandas and Polars keep such codes, times and postcodes;
a missing value SHALL stay missing. `import tabelline/nanuq` SHALL turn a list column of a nanuq
DataFrame (of integers, floats, Booleans or strings) into lists, which nanoplots draw.

```nim
let d = parseCsv("tst,sza\n0530,84.9\n1200,\n")
echo d["tst", 0], " ", d["tst", 0].kind, " ", d["sza", 0].kind, " ", d["sza", 1].isNull
```

```text
0530 vkString vkFloat true
```
