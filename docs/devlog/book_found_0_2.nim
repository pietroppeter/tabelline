## devlog: 11 Nov 2026 C | What the book found for 0.2 | For 0.2 the tabelline book ported nanoplots, four Great Tables release posts and three of gt's articles, two of them whole case studies. Fifteen findings, each told: what the book could not write, what gt and Great Tables do, and what tabelline does now. Thirteen went into 0.2, data frames among them; two stay as differences.
## A dated post: it tells what the book's port for 0.2 found, and is not updated afterwards.
import std/os
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "book-found-0-2" / "index.html"
nb.useTabelline(title = "What the book found for 0.2", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026", "What the book found for 0.2", """
For 0.2 the tabelline book ported nanoplots, four Great Tables release posts and three of gt's
articles, two of them whole case studies. Fifteen findings, each told: what the book could not
write, what gt and Great Tables do, and what tabelline does now.
"""

nbText: """
[The tabelline book](../../book/) takes pages written for gt and Great Tables and makes every
table again in Nim, next to the original R and Python. Each page asks tabelline for what a user
asks, in the order a user meets it, so the book is the test that no spec writes. For 0.1 it
found two bugs and a dozen gaps ([What the book found for 0.1](../book-found/)). For 0.2 it went
further: from a guide to release posts, then to articles that build a whole table, as someone
would at work. The release waited for it.

This post goes from the simplest to the most complex: what the book ported, the list of what it
found, then each finding told on its own, in the order a table is made, and last how the work
was done.

## What the book ported

Eight new chapters in three sections, each with R, Python and Nim.
"""

nbShowCode:
  type Ported = object
    section, chapter, source, shows: string
  let rows = @[
    Ported(section: "Great Tables: Get Started", chapter: "[Nanoplots](../../book/get-started/nanoplots.html)",
           source: "Great Tables' guide",
           shows: "line, bar and box plots in a cell; reference lines and areas; *x* and *y* pairs"),
    Ported(section: "Great Tables: the blog", chapter: "[Introducing Great Tables](../../book/blog/introducing.html)",
           source: "Great Tables' blog", shows: "the parts of a table, formats, styles, the stub"),
    Ported(section: "Great Tables: the blog", chapter: "[v0.2.0: Easy Data Coloring](../../book/blog/v0_2.html)",
           source: "Great Tables' blog", shows: "`dataColor` on populations"),
    Ported(section: "Great Tables: the blog", chapter: "[v0.3.0: So Many Style Options!](../../book/blog/v0_3.html)",
           source: "Great Tables' blog", shows: "column widths, options, images, font stacks"),
    Ported(section: "Great Tables: the blog", chapter: "[v0.4.0: Nanoplots and More](../../book/blog/v0_4.html)",
           source: "Great Tables' blog", shows: "nanoplots from lists of values; the Paris Metro"),
    Ported(section: "gt: articles", chapter: "[Creating Summary Lines](../../book/vignettes/summary_lines.html)",
           source: "gt's documentation", shows: "summary rows, grand summary rows, their formats and locations"),
    Ported(section: "gt: articles", chapter: "[Case Study: gtcars](../../book/vignettes/case_study_gtcars.html)",
           source: "gt's documentation", shows: "one table built step by step, merges with HTML, footnotes"),
    Ported(section: "gt: articles", chapter: "[Case Study: Clinical Tables](../../book/vignettes/case_study_clinical.html)",
           source: "gt's documentation", shows: "a demographic summary, event rates, protocol deviations")]
  let t = tabella(rows, rownameCol = "chapter", groupnameCol = "section"):
    colsHide "source"
    colsLabel:
      shows: "What it shows"
    fmtMarkdown ["chapter", "shows"]
    optCssTheme()
  nbTable t

nbText: """
The last three are the first sources written in R. gt's articles are longer than a guide's
page: the clinical tables case study builds three tables, each in a dozen steps, from data it
first counts, groups and pivots. The Python tab is written for the book, the way Great Tables
would make the same table.

## What the book found

Every line the book could not write in tabelline became a finding, sent to the build of 0.2 as
it was found. Thirteen went into 0.2. Three of those were still open when this post was first
written (every colour name, a table in one step, data frames); Pietro asked for them too, so
nothing this port found is left open. Two findings stay as differences, on purpose.

The list goes from the simplest step of making a table to the most complex, as the
[list of gaps](../../book/gaps.html) does. Each finding links to its story below; *Found in* is
the chapter that found it.
"""

nbShowCode:
  type Finding = object
    outcome, step, title, where, now: string
  let clinical = "[Clinical Tables](../../book/vignettes/case_study_clinical.html)"
  let summaryLines = "[Summary Lines](../../book/vignettes/summary_lines.html)"
  let nanoplots = "[Nanoplots](../../book/get-started/nanoplots.html)"
  let built = "Built in 0.2"
  let kept = "Kept as a difference"
  let findings = @[
    Finding(outcome: built, step: "Data", title: "gt's datasets in tabelline",
            where: "[the blog](../../book/blog/index.html)", now: "`tabelline/datasets`: `gtcars()`, `countrypops()`, `illness()`, `metro()`"),
    Finding(outcome: built, step: "Data", title: "A cell with many values",
            where: nanoplots, now: "lists and records in a cell"),
    Finding(outcome: built, step: "Data", title: "Data frames",
            where: clinical, now: "`tabella(df)` for nanuq, `import tabelline/nanuq`"),
    Finding(outcome: built, step: "Rows", title: "A row's columns with a dot",
            where: "every chapter", now: "`it.Temp`"),
    Finding(outcome: built, step: "Columns", title: "Columns by position, and rules joined",
            where: clinical, now: "`positions(0, -1)`; `a + b`; `startsWith([\"pct_\", \"ci_\"])`"),
    Finding(outcome: built, step: "Columns", title: "Spanners that gather their columns",
            where: clinical, now: "`tabSpanner` gathers, as gt's does"),
    Finding(outcome: built, step: "Text", title: "Line breaks in Markdown",
            where: clinical, now: "two spaces, or a backslash, before a newline"),
    Finding(outcome: built, step: "Summaries", title: "Summary rows of one label in one row",
            where: summaryLines, now: "one row, as in gt"),
    Finding(outcome: built, step: "Summaries", title: "Summary values, not only text",
            where: summaryLines, now: "`extractSummary(t, values = true)`"),
    Finding(outcome: built, step: "Formats", title: "A nanoplot point by point",
            where: nanoplots, now: "an option for each point; dates on *x*"),
    Finding(outcome: built, step: "Options", title: "Font stacks by name",
            where: "[v0.3.0](../../book/blog/v0_3.html)", now: "`systemFonts(\"industrial\")`"),
    Finding(outcome: built, step: "Styles", title: "Every CSS colour name",
            where: "[v0.2.0](../../book/blog/v0_2.html)", now: "148 names, `\"darkgreen\"` too"),
    Finding(outcome: built, step: "Notebooks", title: "A table in one step",
            where: "every chapter", now: "`nbTable data: body`"),
    Finding(outcome: kept, step: "Summaries", title: "Aggregates skip missing values",
            where: summaryLines, now: "as Polars does; gt needs `na.rm = TRUE`"),
    Finding(outcome: kept, step: "Summaries", title: "A summary cell takes its column's format",
            where: summaryLines, now: "unless `fmt` says otherwise")]

  # each title links to its section below
  var rows = findings
  for f in rows.mitems: f.title = "[" & f.title & "](#" & slugify(f.title) & ")"

  let t = tabella(rows, rownameCol = "title", groupnameCol = "outcome"):
    colsLabel:
      step: "Step"
      title: "Finding"
      where: "Found in"
      now: "Now"
    fmtMarkdown ["title", "where", "now"]
    optCssTheme()
  nbTable t

nbText: """
Three of them were findings of 0.1 that came back: columns by position, column rules joined
and spanners that gather their columns. The 0.1 port had found them in small examples and left
them for later. The case studies needed each of them, and wrote a line of Nim around it. A gap
that a real table works around is worth more than one a guide mentions, so 0.2 closed them.

## The findings, one by one

Each finding in three parts: what the book wanted to write, what gt and Great Tables do, and
what tabelline does now.

### gt's datasets in tabelline

The Great Tables blog posts make their tables from gt's datasets: `gtcars` for the cars of the
v0.3.0 post, `countrypops` for v0.2.0, `illness` and `metro` for v0.4.0. tabelline had only its
own (`planets`, `exibble`, `isole`, `citta`), so the book read copies of the CSV files from a
helper of its own. gt has them in R and Great Tables in Python, so a reader of either can try any
example at once. Now tabelline has them too, with gt's licence:

```nim
import tabelline, tabelline/datasets
let t = tabella(gtcars(), rownameCol = "model"):
  colsHide ["trim", "bdy_style"]
```

### A cell with many values

The finding that changed tabelline the most came from the last example of the Nanoplots page.
Great Tables draws a scatter in a cell from a Polars `struct`: a dictionary with a list of *x*
and a list of *y*. tabelline's cells held one value each, so the book could show that example
only in Python and R. gt keeps one value per cell too, and its `cols_nanoplot()` reads several
columns. The question went from the book to Pietro: how should Nim say it? The answer is two
new kinds of value. A list is a cell of values (`@[1.0, 4, 2]`), and a record is a cell of named
values, a Nim tuple, read with a dot like a field (`v.x`). A format applies to each item.

The book's example, now in Nim:
"""

nbCode:
  let weather = tableData:
    station: ["Station 1", "Station 2", "Station 3"]
    temperatures: [
      (x: @[6.1, 8.0, 10.1, 10.5, 11.2, 12.4, 13.1, 15.3],
       y: @[24.2, 28.2, 30.2, 30.5, 30.5, 33.1, 33.5, 32.7]),
      (x: @[7.1, 8.2, 10.3, 10.75, 11.25, 12.5, 13.5, 14.2],
       y: @[18.2, 18.1, 20.3, 20.5, 21.4, 21.9, 23.1, 23.3]),
      (x: @[6.3, 7.1, 10.3, 11.0, 12.07, 13.1, 15.12, 16.42],
       y: @[15.2, 17.77, 21.42, 21.63, 25.23, 26.84, 27.2, 27.44])]
  let scatter = tabella(weather):
    fmtNanoplot "temperatures", plotType = "line",
      expandX = @[5.0, 16.0], expandY = @[10.0, 40.0],
      options = nanoplotOptions(showDataArea = false, showDataLine = false)
    optCssTheme()
  nbTable scatter

nbNote """
Each cell of `temperatures` is a record, a tuple with the fields `x` and `y`. `fmtNanoplot`
places each *y* at its *x*, and `expandX` and `expandY` give every plot the same scale.
""", nkCode

nbText: """
### Data frames

The case studies start from raw data: one row for each subject of a trial. Before gt sees it, R
counts the subjects of each arm, groups, summarises and pivots with dplyr and tidyr, and Great
Tables takes a Polars or pandas DataFrame as it is, `GT(df)`. tabelline makes tables, not data,
and Nim's standard library has no data frames, so the book first wrote those steps in plain Nim:
rows as `OrderedTable`s, a loop for each arm of the trial, about fifty lines for the demographic
summary. The answer is not inside tabelline: it is to take the data frames Nim has.
`import tabelline/nanuq` makes `tabella(df)` work for a DataFrame of
[nanuq](https://github.com/pietroppeter/nanuq), Polars for Nim, and the case study now counts and
pivots as R does:

```nim
import nanuq
import tabelline, tabelline/nanuq

let bySex = subjects
  .groupBy("TRTA", "SEX")
  .agg(len().alias("val"))
  .withColumns((col("val") / col("val").sum.over("TRTA")).alias("pct"))
  .pivot("TRTA", index = "SEX", values = ["val", "pct"])
let t = tabella(bySex, rownameCol = "SEX"):
  fmtPercent startsWith("pct_"), decimals = 1
```

It is an optional module: the core of tabelline still needs only Nim's standard library, and
only a program that imports `tabelline/nanuq` downloads nanuq's Polars library (about 50 MB, once).
One step stays in Nim: neither Nim's standard library nor nanuq has the quantiles of the F
distribution that R's Clopper-Pearson interval uses, so the book finds the interval from the
binomial probabilities, by bisection, and its numbers match R's.

### A row's columns with a dot

Every condition on a row was written with brackets, `where(it["Temp"] > 80)`. gt reads the column
by its name (`Temp > 80`) and Great Tables with a Polars expression (`pl.col("Temp") > 80`); in
Nim the brackets were the noise of every chapter. With records came the dot, and the same dot
reads a row's columns:

```nim
let hot = tabella(weatherDays):
  tabStyle style.fill("var(--warning-soft)"), loc.body(rows = where(it.Temp > 80))
```

A name the row already has (`kind`, `len`, `index`) or a word of Nim (`type`) still takes the
brackets: `it["type"]`.

### Columns by position, and rules joined

The clinical tables align the first column by its place, `cols_align(columns = 1)`, and format
several groups of columns with one rule, `starts_with(c("val_", "min_", "max_"))`. Great Tables
does the same with `columns=0` and Polars' selectors (`cs.starts_with("val_", "min_")`).
tabelline took names or one rule, so the book named the first column and wrote a helper that
listed the names. Now:

```nim
colsAlign alLeft, positions(0)                   # 0 is the first, -1 the last
fmtInteger startsWith(["val_", "min_", "max_"])  # in brackets: several prefixes
colsHide startsWith("ci_") + endsWith("_up")     # a + b: either; a - b: a but not b
```

Positions count from 0, as in Python; gt counts from 1.

### Spanners that gather their columns

gt's `tab_spanner()` moves the columns it spans next to the first one, in the order given
(`gather = TRUE`). tabelline left them where they were, so a spanner over columns that are not
side by side could not be drawn, and the clinical tables moved each column by hand first
(`colsMove`). Now `tabSpanner` gathers them, as gt does, and `gather = false` leaves them where
they are:

```nim
tabSpanner "Placebo", cols("n_resp_Placebo", "ci_low_Placebo")
```

### Line breaks in Markdown

The protocol deviations table puts three lines in a spanner, each arm with its size:
`md("Placebo  \n  N=90 (100%)  \n   n (%)")`. In Markdown two spaces before a newline break the
line, and gt draws three lines. tabelline's `md` joined them into one. Now two spaces, or a
backslash, before a newline break the line.

### Summary rows of one label in one row

Creating Summary Lines calls `summary_rows()` twice, once for `num` and once for `currency`, both
with a row labelled *avg*. gt squashes them into one row *avg* with both cells; Great Tables adds
a row for each call, and so did tabelline. Now two calls with the same label make one row, as in
gt:

```nim
summaryRows fnsLabels, columns = "num"
summaryRows fnsLabels, columns = "currency"   # the same rows, now with currency too
```

### Summary values, not only text

gt's `extract_summary()` gives the summary rows as data, to check them or to make a new table
from them, formatted again. Great Tables has no such function. tabelline's `extractSummary` gave
the cells as shown (`2.926 × 10²`), which cannot be formatted again. Now `values = true` gives
the numbers:

```nim
let standalone = tabella(extractSummary(t, values = true), rownameCol = "label"):
  fmtNumber "num", decimals = 1
```

### A nanoplot point by point

Great Tables' `nanoplot_options()` takes one value for every point, or a list with a value for
each point (a colour, a size), and the *x* values of a plot can be dates. tabelline took one
value only, and numbers. Now each option of points and bars takes a value or a list, and *x*
takes ISO dates (`"2026-11-11"`), placed by time:

```nim
nanoplotOptions(dataPointFillColor = @["white", "white", "red"])
```

### Font stacks by name

The v0.3.0 post sets a table's font to a stack, fonts that are on most systems, by name:
`system_fonts("industrial")` in Great Tables, `opt_table_font(stack = "industrial")` in gt.
tabelline had no names, so the book wrote the stack out, font by font. Now `systemFonts` knows
Great Tables' fifteen stacks:

```nim
tabOptions tableFontNames = systemFonts("industrial")
```

### Every CSS colour name

The [v0.2.0 post](../../book/blog/v0_2.html) colours the cells of `currency` from light blue to
dark green, with a palette of two names:

```python
GT(exibble_mini).data_color(columns="currency", palette=["lightblue", "darkgreen"])
```

The same line in tabelline stopped with `ValueError: not a colour: darkgreen`. A plain fill
(`style.fill("darkgreen")`) works, because the name goes to the browser as it is. But
`dataColor` computes the colours in between, and the choice of white or dark text on each cell:
for that tabelline needs the red, green and blue of each colour, and it knew them for 17 names.
Great Tables knows every name of CSS, and gt every name of R (R lacks `rebeccapurple`). Now
tabelline knows the 148 names of CSS, checked against a browser, and a dark heading given by
name gets white text too:

```nim
dataColor "currency", palette = @["lightblue", "darkgreen"]
```

### A table in one step

Every chapter, and every page of this site, named a table before showing it:

```nim
let t = tabella(planets()):
  tabHeader "Planets"
nbTable t
```

The shorter form, `nbTable tabella(planets()): tabHeader "Planets"`, does not compile: Nim gives
the indented body to `nbTable`, the outer call, and not to `tabella`. A notebook in R or Python
has no such step, because it shows the last value of a cell. Now `nbTable` takes the data and
the body itself, with `tabella`'s other arguments:

```nim
nbTable planets(), rownameCol = "planet":
  tabHeader "Planets"
```

When the code is shown on the page, as in the book, naming the table still reads best; the
short form is for a table whose code is not shown.

## Two differences kept

### Aggregates skip missing values

In Creating Summary Lines, `grp_b` has a missing `num`. gt's `mean()` then gives `NA`, shown as a
dash, and the article's next example writes `~ mean(., na.rm = TRUE)` to get a number. Polars
skips missing values, so Great Tables gives the number at once, and so does tabelline: `agg.mean`,
`agg.sum` and the others leave missing values out. A summary of the numbers a reader sees is what
a table means, and an aggregate of your own (`aggregate(proc ...)`) gets every value, missing
ones too, when the missing matter.

### A summary cell takes its column's format

gt formats a summary cell with `fmt_number()` when the call gives no `fmt`; Great Tables leaves it
as it is. tabelline formats it as its column, with the column's locale: one
`fmtScientific "num", decimals = 3` serves the body and the summary rows, and a `fmt` in
`summaryRows` still says otherwise. It saves a line in almost every summary of the book, and a
table whose totals look like its rows reads as one.

## How it worked

As for 0.1, a thread ported the pages while another built 0.2, and every finding went from one
to the other as it was found. Four things were new.

- **R first.** gt's articles are written in R, so the book's tabs could say which side is the
  original. Running them showed one thing about gt itself: a summary function named in a formula
  (`~ f(.)`) is found only in R's global environment, where knitr runs. The book's runner now
  runs there too.
- **The release waited for the book.** Pietro decided that the 0.2 tag waits for the gt articles
  and their fixes. A finding in the last chapter could still change 0.2.
- **The open findings were built too.** This post first ended with three findings still open;
  reading it, Pietro asked for all three, and they went into 0.2 the same day.
- **The book is a test.** Every change to tabelline rebuilds every chapter, so lists and records,
  the dot for rows and the blocks of pairs reached every page as soon as they were built, and a
  chapter that broke showed up in the pull request that broke it.

The next sources are the later Great Tables release posts, gt's own user guide and the Table
Contest, and the [plan](../../book/next.html) lists them.
"""

nbSave
