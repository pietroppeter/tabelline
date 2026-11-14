## devlog: 11 Nov 2026 C | What the book found for 0.2 | The tabelline book ported 25 chapters for 0.2: release posts, gt's articles, Great Tables' examples, entries of the Table Contest. They found 47 things tabelline could not do yet, in two rounds: 15 while 0.2 was built, 29 more before the tag, 3 left for later. Each told: what the book could not write, what gt and Great Tables do, and what tabelline does now.
## A dated post (11 Nov 2026), brought up to date on 14 Nov, before the tag, with the second round: Pietro asked for it.
import std/[os, strutils]
import nimib
import tabelline, tabelline/[nimib, datasets]
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "book-found-0-2" / "index.html"
nb.useTabelline(title = "What the book found for 0.2", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "11 November 2026, brought up to date on 14 November", "What the book found for 0.2", """
The tabelline book ported 25 chapters for 0.2: release posts, gt's articles, Great Tables'
examples, entries of the Table Contest. They found 47 things tabelline could not do yet, in two
rounds: 15 while 0.2 was built, 29 more before the tag, 3 left for later.
"""

nbToc()

nbText: """
[The tabelline book](../../book/) takes pages written for gt and Great Tables and makes every
table again in Nim, next to the original R and Python. Each page asks tabelline for what a user
asks, in the order a user meets it, so the book is the test that no spec writes. For 0.1 it
found two bugs and a dozen gaps ([What the book found for 0.1](../book-found/)). For 0.2 it went
further: from a guide to release posts, then to articles that build a whole table, as someone
would at work, and last to tables other people made, for the Table Contest. The release waited
for it.

It came in two rounds. The first, on 11 November, ported eight chapters while 0.2 was built, and
its fifteen findings went into 0.2 as they were found. The second, on 13 November, ported
seventeen more; its findings were first written down as gaps for a later release, and Pietro
answered: *that is indeed why we update the book before release*. So 0.2 waited again, and 29 of
the 32 were built before the tag. This post was first written after the first round; it now
tells both.

It goes from the simplest to the most complex: what the book ported, the list of what it found,
then each finding told on its own, in the order a table is made, and last how the work was done.

## What the book ported

### The first round: eight chapters

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

### Before the tag: seventeen more

The second round finished the Great Tables blog, added Great Tables' own examples, one page of
gt-extras, gt's article on its datasets, and six entries of the
[Table Contest](../../book/contest.html): tables people made with gt and Great Tables for a
contest, with data and choices of their own.
"""

nbShowCode:
  type Ported = object
    section, chapter, shows: string
  let later = @[
    Ported(section: "Great Tables: the blog", chapter: "[Using Polars to Win at Super Bowl Squares](../../book/blog/superbowl.html)",
           shows: "a grid of chances coloured by value"),
    Ported(section: "Great Tables: the blog", chapter: "[The Design Philosophy of Great Tables](../../book/blog/design.html)",
           shows: "the parts of a table, one at a time"),
    Ported(section: "Great Tables: the blog", chapter: "[Great Tables for Scientific Publishing](../../book/blog/scientific.html)",
           shows: "units, scientific notation, nanoplots"),
    Ported(section: "Great Tables: the blog", chapter: "[v0.12.0: Google Fonts and zebra stripes](../../book/blog/v0_12.html)",
           shows: "font stacks and stripes"),
    Ported(section: "Great Tables: the blog", chapter: "[v0.13.0: Applying styles to all table locations](../../book/blog/v0_13.html)",
           shows: "styles on every part, Markdown for missing values"),
    Ported(section: "Great Tables: the blog", chapter: "[v0.15.0: Flags, Icons, and Other Formatting Goodies](../../book/blog/v0_15.html)",
           shows: "flags, icons, accounting"),
    Ported(section: "Great Tables: the blog", chapter: "[v0.18.0: Easy Column Spanners and More!](../../book/blog/v0_18.html)",
           shows: "spanners from names, columns by kind, datetimes"),
    Ported(section: "Great Tables: the blog", chapter: "[Recreating Septa Transit Timetables in Python](../../book/blog/septa.html)",
           shows: "a timetable as wide as a wall"),
    Ported(section: "Great Tables: examples", chapter: "[Examples](../../book/examples/examples.html)",
           shows: "the gallery of Great Tables' home page"),
    Ported(section: "Great Tables: examples", chapter: "[Sports earnings](../../book/examples/sports_earnings.html)",
           shows: "a ranking with images and HTML"),
    Ported(section: "gt-extras", chapter: "[An NFL season](../../book/extras/nfl_season.html)",
           shows: "bars, ratings and logos made with plain formats"),
    Ported(section: "gt: articles", chapter: "[gt Datasets](../../book/vignettes/gt_datasets.html)",
           shows: "every dataset of gt, as a table"),
    Ported(section: "The Table Contest", chapter: "[Euro NCAP Safety Ratings - 2023](../../book/contest/euroncap.html)",
           shows: "ratings as stars and bars"),
    Ported(section: "The Table Contest", chapter: "[Lemurs at Duke Lemur Center](../../book/contest/lemurs.html)",
           shows: "pictures, groups, aligned text"),
    Ported(section: "The Table Contest", chapter: "[Mapping the Latin American Pharmaceutical Landscape](../../book/contest/latam_pharma.html)",
           shows: "flags and colour by value"),
    Ported(section: "The Table Contest", chapter: "[Titanic Challenge](../../book/contest/titanic.html)",
           shows: "counts and percents side by side"),
    Ported(section: "The Table Contest", chapter: "[Basic gt Styling Reference](../../book/contest/gt_styling.html)",
           shows: "every style of a cell, one per row"),
    Ported(section: "The Table Contest", chapter: "[Periodic table of elements](../../book/contest/periodic_table.html)",
           shows: "a table laid out as a picture")]
  let second = tabella(later, rownameCol = "chapter", groupnameCol = "section"):
    colsLabel:
      shows: "What it shows"
    fmtMarkdown ["chapter", "shows"]
    optCssTheme()
  nbTable second

nbText: """
With the first round, that is 25 chapters, 12 of them posts of the Great Tables blog, and the
book has [a page that finds an example by feature](../../book/features.html).

## What the book found

### The first round: fifteen

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

### Before the tag: twenty-nine more

The second round found 32 more. Pietro chose to build all but three before the tag. Here are the
29, in the order of the [list of gaps](../../book/gaps.html), which this table reads, and
*Where it shows* is the chapter that uses it now.
"""

nbShowCode:
  type Gap = object
    step, what, where: string
  var gaps: seq[Gap]
  var inRound = false
  for line in readFile(docs.parentDir / "book" / "gaps.md").splitLines:
    if "Text with a zero in front" in line: inRound = true
    if inRound and line.startsWith("| "):
      let cells = line.strip(chars = {'|', ' '}).split(" | ")
      gaps.add Gap(step: cells[0], what: cells[1],
                   where: cells[2].replace("](", "](../../book/"))
    if "stubSticky" in line: inRound = false
  let round2 = tabella(gaps, rownameCol = "what", groupnameCol = "step"):
    colsLabel:
      where: "Where it shows"
    fmtMarkdown ["what", "where"]
    optCssTheme()
  nbTable round2

nbText: """
Most are small: an argument gt has and tabelline did not, a name that Great Tables takes. They
are the kind a guide never meets, because each page of a guide shows one thing; a real table
meets them all at once. Three stay open, by Pietro's choice: saving a table as an image (gt's
`gtsave()`), which is the next release, *Out of the browser*; a small chart in each row drawn
from other data (gt's `ggplot_image()`, gt-extras' plots), which a proc of your own already
draws through `fmt`; and the book's own helpers for pandas' `head`, `select` and `loc`, which
nanuq has and the chapters will move to.

## The first round, one by one

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

## Before the tag, one by one

Seven of the 29, from the simplest step to the most complex. Each is a small table, made here
with what 0.2 has now.

### A zero in front stays text

[Colorizing with Data](../../book/get-started/colorizing_with_data.html) reads a CSV with true
solar times, `0530` and `1200`. tabelline read them as numbers, so `0530` lost its zero. pandas
and Polars keep a column like that as text, because a number is never written with a zero in
front: codes, times and postcodes are. tabelline does too now.
"""

nbCode:
  let sza = parseCsv("tst,sza\n0530,84.9\n1200,\n")
  echo sza["tst", 0], " is ", sza["tst", 0].kind
  echo sza["sza", 0], " is ", sza["sza", 0].kind

nbText: """
### The stub of a table already made

Great Tables writes `GT(df).tab_stub(rowname_col="name")`, and the stub can be set after the
table is made. tabelline took the stub only when the table was made, so the
[Stub](../../book/get-started/basic_stub.html) chapter and [SEPTA](../../book/blog/septa.html)
made the table again. Now `tabStub` sets it, with the groups too:
"""

nbCode:
  let lunch = tableData:
    fruit: ["apple", "banana", "cherry"]
    kind: ["tree", "herb", "tree"]
    price: [0.5, 0.25, 3.0]
  let fruits = tabella(lunch):
    tabStub "fruit", groupnameCol = "kind"
    fmtCurrency "price"
    optCssTheme()
  nbTable fruits

nbText: """
### Columns by kind, by a test of the name, and rows from the end

Great Tables picks columns by their type (`cs.by_dtype(pl.Boolean)`) and gt by a test
(`where(is.logical)`, `matches()`); the [v0.18.0](../../book/blog/v0_18.html) post and
[Column Selection](../../book/get-started/column_selection.html) use them. A row from the end is
`-1` in Python and `n()` in gt. tabelline has all three now, and `&` for the columns two rules
share:
"""

nbCode:
  let ringed = tabella(planets(), rownameCol = "planet"):
    colsHide named(it notin ["moons", "rings"])
    tabStyle style.text(weight = "bold"),
      loc.body(ofKind(vkBool), rows = -1)
    optCssTheme()
  nbTable ringed

nbNote("""
`ofKind(vkBool)` is the columns of Booleans, `named(cond)` the columns whose name `it` passes `cond`, and `-1` the last row (Nim's `^1` too).
""", nkCode)

nbText: """
### Three figures, and the minus in parentheses

The [Examples](../../book/examples/examples.html) show three significant figures (gt's
`n_sigfig`), and [v0.15.0](../../book/blog/v0_15.html) shows money as an accountant writes it,
a loss in parentheses. Both are arguments of `fmtNumber` now, and `accounting` of `fmtInteger`,
`fmtPercent` and `fmtCurrency` too:
"""

nbCode:
  let books = tableData:
    item: ["sales", "costs", "a fee"]
    amount: [24334.2345, -18110.5, -0.01632]
  let ledger = tabella(books, rownameCol = "item"):
    fmtNumber "amount", nSigfig = 3, accounting = true
    optCssTheme()
  nbTable ledger

nbText: """
### gt's six styles

`optStylize` had one style. gt has six, each in six colours, and
[Premade Themes](../../book/get-started/table_theme_premade.html) shows them all. tabelline
has them now, with gt's colours: a premade look for a table that is not on a page of its own
style.
"""

nbCode:
  let styled = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    colsHide named(it notin ["moons", "mass"])
    optStylize style = 6
  nbTable styled

nbText: """
### A test for each cell

Great Tables' `loc.body(mask=...)` styles the cells that pass a Polars expression, column by
column: the largest of each column, in
[Styling the Table Body](../../book/get-started/basic_styling.html). gt has no mask; it needs one
`tab_style()` for each column. In tabelline a mask is a proc of the cell's value and of its
column:
"""

nbCode:
  let largest = tabella(planets(), rownameCol = "planet"):
    colsHide named(it notin ["moons", "mass", "diameter"])
    tabStyle style.text(weight = "bold"),
      loc.body(mask = proc (v: Value, col: Column): bool =
        v == agg.max.fn(col.values))
    optCssTheme()
  nbTable largest

nbText: """
### A stub that stays in view

[SEPTA](../../book/blog/septa.html) is a timetable with a column for each train. On a phone it is
wider than the screen and scrolls inside its box, and the stations scroll away with the trains.
`stubSticky = true` keeps the stub in view. Neither gt nor Great Tables has it: it is in the
feature map's list of what is worth porting back. Scroll this table sideways:
"""

nbCode:
  let wide = tabella(planets(), rownameCol = "planet"):
    tabOptions:
      stubSticky = true
    optCssTheme()
  nbTable wide

nbText: """
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
- **A second round, before the tag.** The second round's findings were first written as gaps
  for a later release. Pietro read them and asked for them in 0.2: the book is updated before a
  release so that what it finds goes in. In one day 29 were built, each with its spec, a test
  and the chapter that needed it rewritten without its workaround; three stay open by his
  choice, and [the list of gaps](../../book/gaps.html) says why.
- **The book is a test.** Every change to tabelline rebuilds every chapter, so lists and records,
  the dot for rows and the blocks of pairs reached every page as soon as they were built, and a
  chapter that broke showed up in the pull request that broke it.

What the book will port next is in [its plan](../../book/next.html).
"""

nbSave
