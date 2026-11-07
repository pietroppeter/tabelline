## ADDED Requirements

### Requirement: Bytes
`fmtBytes(columns, rows, standard, decimals, inclSpace)` SHALL show sizes in bytes with decimal
(kB, MB, GB, powers of 1000) or binary (KiB, MiB, GiB, powers of 1024) units, dropping trailing
zeros; sizes below one unit SHALL show whole bytes.

```nim
let d = tableData:
  size: [512, 1500, 1536, 3_200_000_000]
echo tabella(d).fmtBytes("size").fmtBytes("size", rows = [2], standard = "binary")
```

```text
┌─────────┐
│    size │
╞═════════╡
│   512 B │
│  1.5 kB │
│ 1.5 KiB │
│  3.2 GB │
└─────────┘
```
