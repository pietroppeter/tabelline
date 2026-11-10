## ADDED Requirements

### Requirement: Icons
`fmtIcon(columns, rows, height = "1em", sep, ...)` SHALL show each cell's names of Font Awesome
Free icons (several separated by commas) as inline SVG, `height` high and as wide as their
shape, in the text's colour unless `fillColor` or, by name, `fillColors` is given. A name SHALL
be a short name (the regular style when there are two), a full name ("fas fa-star") or an older
name ("user-large"); an unknown name SHALL raise `ValueError` when the verb is called. In text
output the names SHALL stay.

```nim
let d = tableData:
  planet: ["Earth", "Jupiter"]
  kind: ["mountain", "cloud, star"]
let t = tabella(d):
  fmtIcon "kind", fillColors = {"star": "gold"}
echo t
echo t.toHtml.count("class=\"tb_icon\""), " ", icon("star").style, " ", icon("fas fa-star").style, " ", hasIcon("user-large")
```

```text
┌─────────┬─────────────┐
│ planet  │ kind        │
╞═════════╪═════════════╡
│ Earth   │ mountain    │
│ Jupiter │ cloud, star │
└─────────┴─────────────┘
3 regular solid true
```

### Requirement: Images
`fmtImage(columns, rows, height, width, sep, path, filePattern = "{x}", encode = true, alt)`
SHALL show each cell's file names (several separated by commas) as images, found in `path` and
written with `filePattern`. With `encode`, a local file SHALL be read when the verb is called
and inlined as a data URL, its type from its extension; an address (`https://...`) SHALL be
left as it is. Without `height` or `width` an image SHALL be 2em high. In text output the names
SHALL stay.

```nim
let dir = getTempDir()
writeFile(dir / "dot.svg", "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 2 2'><circle cx='1' cy='1' r='1'/></svg>")
let d = tableData:
  pic: ["dot"]
let t = tabella(d):
  fmtImage "pic", path = dir, filePattern = "{x}.svg"
echo t
echo t.toHtml.contains("<img src=\"data:image/svg+xml;base64,")
```

```text
┌─────┐
│ pic │
╞═════╡
│ dot │
└─────┘
true
```

### Requirement: Nanoplots
`fmtNanoplot(columns, rows, plotType = "line", plotHeight = "2em", missingVals = "gap",
autoscale, referenceLine, referenceArea, expandY, options, alt)` SHALL draw a plot in each cell,
as inline SVG: a line plot ("line"), a bar plot ("bar") or a box plot ("boxplot") of the cell's
values (numbers separated by spaces, commas or semicolons, `NA` for a missing one), or, in a
column of numbers, a horizontal bar or line from a zero line shared by the rows. The values
SHALL show when the pointer is over the plot, without JavaScript. A missing value SHALL break
the line ("gap"), be marked ("marker"), count as 0 ("zero") or be left out ("remove").
`referenceLine` SHALL be a number or a statistic of the values ("mean", "median", "min", "max",
"q1", "q3", "first", "last"), and `referenceArea` two of them. With `autoscale` every plot of the
column SHALL share its y axis. `nanoplotOptions(...)` SHALL hold the look, with Great Tables'
defaults. In text output a nanoplot SHALL be a sparkline, a bar of blocks beside a zero line, or
the five numbers of a box plot.

```nim
let d = tableData:
  city: ["Oslo", "Rome"]
  trend: ["1 4 2 8 5", "3, NA, 6, 2"]
  change: [4.2, -1.5]
let t = tabella(d, rownameCol = "city"):
  fmtNanoplot "trend", referenceLine = "mean"
  fmtNanoplot "change", plotType = "bar"
echo t
echo t.toHtml.count("class=\"tb_nanoplot\""), " ", nanoplotLabel(1234), " ", nanoplotLabel(0.25)
```

```text
┌──────┬───────────┬───────────────────┐
│      │ trend     │            change │
╞══════╪═══════════╪═══════════════════╡
│ Oslo │ ▁▄▂█▅ 1–8 │    │███████ 4.20  │
│ Rome │ ▃ █▁ 2–6  │ ███│        −1.50 │
└──────┴───────────┴───────────────────┘
4 1.23K 0.25
```
