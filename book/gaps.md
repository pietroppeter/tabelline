# What the port found

Everything tabelline still lacks to do what the Great Tables *Get Started* guide, blog posts and
examples, and gt's articles, do, found while porting them. What the port found that tabelline has gained since, in 0.1, is told in the
devlog post [What the book found for 0.1](https://pietroppeter.github.io/tabelline/devlog/book-found/);
what 0.2 closed is listed at the end of this page.

The gaps go from the simplest to the most complex, in the order a table is made: the data, the
parts of the table, its columns and rows, then formats, text, options and styles, and last what is done with the table. Each says
where it is planned in the [feature map](https://pietroppeter.github.io/tabelline/coverage/),
or **new** when the map does not have it; the new ones go to the build of the next release and
to the backlog.

## The gaps

| Step | What | Where it shows | Plan |
| ---- | ---- | -------------- | ---- |
| Data | The Get Started pages and the blog still take pandas' `head`, `select` and `loc` from the book's helpers in `gtdata`: nanuq has them, the chapters have not moved to it yet | every page, [v0.2.0](blog/v0_2.html) and [v0.4.0](blog/v0_4.html) the most | later |
| Formats | A small chart in each row drawn from other data (a bar chart, a line chart with axes), as gt's `ggplot_image()` or gt-extras' plots: today a proc that writes SVG, through `fmt` | [Lemurs](contest/lemurs.html), [An NFL season](extras/nfl_season.html) | kept: `fmt` with a proc does it |
| Export | Saving a table as an image (`gtsave`); tabelline has the HTML (`toHtml`) | [v0.4.0](blog/v0_4.html) | later: *Out of the browser* |

## Differences kept

Not gaps, but worth knowing:

- tabelline has datasets of its own, `isole` (the twin of `islands`) and `citta`, not Great
  Tables' `islands`, `airquality` and `sza`: the book reads copies of those (`gtdata`).
- tabelline stops on a column that does not exist, where Great Tables lets it pass and gt stops
  too ([Premade Themes](get-started/table_theme_premade.html)).
- Aggregates skip missing values, where gt's `mean` gives `NA` without `na.rm = TRUE`
  ([Creating Summary Lines](vignettes/summary_lines.html)).
- Missing values are blank, where Great Tables writes `None` and gt `NA`; `subMissing` shows a
  dash.
- tabelline has no `google_font()`, which loads remote files: a table asks for the font by
  name, with a stack of the reader's own fonts after it ([v0.12.0](blog/v0_12.html)).
- `loc.body` takes `cols =`, Great Tables `columns=`; `style.borders` takes a set of sides.
- Styles join with `&`, not in a list; locations are any number of arguments.

## Closed by 0.2

Gaps the port found that tabelline 0.2 closed; the chapters now use what it gained.

| Step | What | Where it shows |
| ---- | ---- | -------------- |
| Parts | Summary rows and grand summary rows, with their four locations | [Styling the whole table](get-started/targeted_styles.html), [Table Theme Options](get-started/table_theme_options.html), [Location selection](get-started/loc_selection.html) |
| Columns | `colsAdd`, a column added to the table | [Intro](get-started/intro.html) |
| Columns | `colsUnits`, units in gt's notation | [Column Labels](get-started/basic_column_labels.html) |
| Formats | Every date style of gt, and its time styles, in every language of CLDR | [Formatting Values](get-started/basic_formatting.html) |
| Formats | Nanoplots: line, bar and box plots, reference lines and areas, `nanoplotOptions` | [Nanoplots](get-started/nanoplots.html) |
| Formats | Lists and records in a cell: a list of values (Polars' list columns) and pairs of *x* and *y* (Polars' struct), with `expandX` | [Nanoplots](get-started/nanoplots.html), [v0.4.0](blog/v0_4.html) |
| Options | 142 options: the container, the column label top border, hlines style and width, vlines, font style, the source notes and grand summary backgrounds, the stub border, the row group borders, the table body borders | [Table Theme Options](get-started/table_theme_options.html) |
| Styles | `fromColumn`: a style whose value comes from a column of the row | [Styling the Table Body](get-started/basic_styling.html) |
| Code | Pairs as blocks (`colsLabel:` then `Ozone: ...`), every table as `tabella(data): body` | every page |
| Code | A table in one step in a notebook, `nbTable data: body`, without naming it | every page |
| Data | Data frames: `tabella(df)` for a nanuq (Polars for Nim) DataFrame, `import tabelline/nanuq`; the case study shapes its data with nanuq, as R does with dplyr | [Case Study: Clinical Tables](vignettes/case_study_clinical.html) |
| Parts | `tabSpanner` gathers its columns next to the first, in the order given (`gather = false` leaves them) | [Column Labels](get-started/basic_column_labels.html), [Case Study: Clinical Tables](vignettes/case_study_clinical.html) |
| Parts | Summary rows of the same label from two calls make one row, as in gt | [Creating Summary Lines](vignettes/summary_lines.html) |
| Columns | Columns by position, from 0, and from the end (`positions(0, -1)`, `positions(2 .. 4)`); rules joined (`a + b`, `a - b`, `startsWith(["pop_", "pct_"])`) | [Column Selection](get-started/column_selection.html), [Case Study: Clinical Tables](vignettes/case_study_clinical.html) |
| Formats | Nanoplots with an option for each point (a colour, a size), and dates as the *x* values | [Nanoplots](get-started/nanoplots.html) |
| Text | Line breaks in `md()`: two spaces, or a backslash, before a newline | [Case Study: Clinical Tables](vignettes/case_study_clinical.html) |
| Options | `systemFonts`, Great Tables' font stacks by name (`"industrial"`) | [v0.3.0](blog/v0_3.html) |
| Export | `extractSummary(values = true)`: the summary cells as values, as gt's `extract_summary()` | [Creating Summary Lines](vignettes/summary_lines.html) |
| Styles | Every CSS colour name (148; `rebeccapurple`, `bisque`, `darkgreen`), and white text on a dark heading given by name | [Colorizing with Data](get-started/colorizing_with_data.html), [v0.2.0](blog/v0_2.html) |
| Data | Text with a zero in front (`"0400"`) stays text when a CSV is read, as pandas keeps it | [Colorizing with Data](get-started/colorizing_with_data.html) |
| Data | A list column of a nanuq data frame (a nanoplot's values) becomes a list in the table | [Examples](examples/examples.html) |
| Parts | `tabStub`, the stub (and the groups) of a table already made, as Great Tables' `tab_stub()` | [Stub](get-started/basic_stub.html), [Examples](examples/examples.html), [SEPTA timetables](blog/septa.html) |
| Parts | `tabRowGroup(label, id = ...)` relabels a group, with Markdown (a link) too | [Find an example by feature](features.html) |
| Columns | A block of `colsLabel` mixes plain labels with `html`/`md` ones | [SEPTA timetables](blog/septa.html) |
| Columns | `ofKind(vkBool)`, columns by the kind of their values, as `cs.by_dtype(pl.Boolean)` | [v0.18.0](blog/v0_18.html) |
| Columns | `named(cond)` and `matches(proc)`, columns by any test of the name; `a & b`, the columns two rules share | [Column Selection](get-started/column_selection.html), [SEPTA timetables](blog/septa.html) |
| Rows | Negative row indices, from the end (`-1`, or Nim's `^1`) | [Row Selection](get-started/row_selection.html), [SEPTA timetables](blog/septa.html) |
| Formats | `accounting` in `fmtNumber`, `fmtInteger` and `fmtPercent` | [v0.15.0](blog/v0_15.html) |
| Formats | Significant figures, `nSigfig`, in `fmtNumber`, also with `compact` | [Examples](examples/examples.html) |
| Formats | `fmtDatetime(formatStr = "%b %d %Y")`, a datetime by a strftime format | [v0.18.0](blog/v0_18.html) |
| Formats | Markdown in `subMissing`'s text, `md"**STABLE**"` | [v0.13.0](blog/v0_13.html) |
| Formats | `fmtFlag`: the country's name on hover, and Great Tables' round flags (`round = true`) | [v0.15.0](blog/v0_15.html) |
| Formats | The format functions take the arguments of their verbs: `pattern`, `locale`, `expStyle`, `accounting`, `nSigfig` | [Formatting Values](get-started/basic_formatting.html), [Creating Summary Lines](vignettes/summary_lines.html) |
| Text | Fuller Markdown in `md()`: HTML entities, `_` and `__`, `~~struck~~`, `<https://...>`, paragraphs and lists | [Header and Footer](get-started/basic_header.html) |
| Options | Light text on a dark stub, row group or summary row, as on the heading and the column labels | [Table Theme Options](get-started/table_theme_options.html) |
| Options | `optStylize` with gt's six styles, in its six colours | [Premade Themes](get-started/table_theme_premade.html) |
| Options | `optAllCaps` on the stub and the row group labels too, or on the `locations` named | [Premade Themes](get-started/table_theme_premade.html), [v0.3.0](blog/v0_3.html) |
| Styles | `style.text(vAlign = ...)` | [v0.13.0](blog/v0_13.html), [Lemurs](contest/lemurs.html), [Basic gt Styling Reference](contest/gt_styling.html) |
| Styles | `style.text(indent = ...)` and `style.fill(alpha = ...)` | [Basic gt Styling Reference](contest/gt_styling.html) |
| Styles | `loc.stub(labels = ["banana"])`, rows by their label, with indices too | [Location selection](get-started/loc_selection.html) |
| Styles | `loc.rowGroups(rows = ...)`, the groups of some rows, by index or by a condition | [Location selection](get-started/loc_selection.html) |
| Styles | `loc.body(mask = ...)`: a test for each cell, of its value and its column | [Styling the Table Body](get-started/basic_styling.html), [Location selection](get-started/loc_selection.html) |
| Styles | A fill on a spanner colours its whole cell | [Styling the whole table](get-started/targeted_styles.html) |
| Styles | `dataColor` leaves the stub alone, as Great Tables does | [Super Bowl Squares](blog/superbowl.html) |
| Styles | R's 657 colour names (`sienna4`, `chartreuse3`), which gt and Great Tables take | [Examples](examples/examples.html) |
| Styles | `palette("great-tables")`, Great Tables' default palette for `dataColor` (tabelline keeps `blues` as its own) | [Colorizing with Data](get-started/colorizing_with_data.html) |
| Look | Formatted numbers do not break inside a cell (`−$24,334.23`, `1.63 × 10⁻²`) | [v0.15.0](blog/v0_15.html), [v0.13.0](blog/v0_13.html) |
| Look | `stubSticky = true`: the stub stays in view while a wide table scrolls sideways (not in gt) | [SEPTA timetables](blog/septa.html) |
