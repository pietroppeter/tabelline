# What the port found

Everything tabelline still lacks to do what the Great Tables *Get Started* guide and blog posts,
and gt's articles, do, found while porting them. What the port found that tabelline has gained since, in 0.1, is told in the
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
| Data | `readCsv` reads `"0400"` as the number 400; text with leading zeros could stay text | [Colorizing with Data](get-started/colorizing_with_data.html) | **new** |
| Parts | `tabStub` (the stub is only chosen in `tabella(rownameCol = ...)`) | [Stub](get-started/basic_stub.html) | **new** |
| Parts | Markdown (a link) in a row group label, as gt's `tab_row_group(label = md(...))` | [Find an example by feature](features.html) | **new** |
| Columns | A block of `colsLabel` that mixes plain labels with `html`/`md` ones | [SEPTA timetables](blog/septa.html) | **new** |
| Columns | A selector by the type of a column, as `cs.by_dtype(pl.Boolean)` and gt's `where(is.logical)` | [v0.18.0](blog/v0_18.html) | **new** |
| Columns | Columns by any function of the name; the columns two rules share (`&`: `a + b` and `a - b` are there); gt's `matches()` | [Column Selection](get-started/column_selection.html), [Styling the Table Body](get-started/basic_styling.html), [Case Study: Clinical Tables](vignettes/case_study_clinical.html) | **new** |
| Rows | Negative row indices (`[0, -1]`; in Nim, `^1`) | [Row Selection](get-started/row_selection.html) | **new** |
| Formats | `accounting` in `fmtNumber`, `fmtInteger` and `fmtPercent` (`fmtCurrency` has it) | [v0.15.0](blog/v0_15.html) | **new** |
| Formats | `fmtDatetime(formatStr = ...)`, a datetime by a format string | [v0.18.0](blog/v0_18.html) | **new** |
| Formats | Markdown in `subMissing`'s text, as `missing_text=md("**STABLE**")` | [v0.13.0](blog/v0_13.html) | **new** |
| Formats | `fmtFlag`: the country's name on hover (it shows the code) and Great Tables' round flags (emoji are drawn by the reader's system, as two letters on Windows) | [v0.15.0](blog/v0_15.html) | **new** |
| Formats | The format functions with every argument of their verb: `pattern`, `locale` (`formatDate` has it, `formatNumber` not), `expStyle` | [Formatting Values](get-started/basic_formatting.html), [Creating Summary Lines](vignettes/summary_lines.html) | **new** |
| Text | Full Markdown in `md()`, HTML entities included | [Header and Footer](get-started/basic_header.html) | **new** |
| Options | White text on a dark stub background set by options (tabelline picks the text colour for the heading and the column labels only) | [Table Theme Options](get-started/table_theme_options.html) | **new** |
| Options | `optStylize` with gt's six styles | [Premade Themes](get-started/table_theme_premade.html) | **new** |
| Options | `optAllCaps` on the stub and the row group labels too | [Premade Themes](get-started/table_theme_premade.html), [v0.3.0](blog/v0_3.html) | **new** |
| Styles | `style.text(vAlign = ...)` (`style.css("vertical-align: middle")` does it) | [v0.13.0](blog/v0_13.html) | **new** |
| Styles | `loc.stub` by row label (`"banana"`), and mixed with indices | [Location selection](get-started/loc_selection.html) | **new** |
| Styles | `loc.rowGroups` by a row of the group, or by a condition | [Location selection](get-started/loc_selection.html) | **new** |
| Styles | `loc.body(mask = ...)`: a condition for each cell | [Styling the Table Body](get-started/basic_styling.html), [Location selection](get-started/loc_selection.html) | **new** |
| Styles | A fill on a spanner colours its whole cell, not only the label | [Styling the whole table](get-started/targeted_styles.html) | **new** |
| Styles | `dataColor` colours the stub's column too when it is numeric; Great Tables leaves the stub out | [Super Bowl Squares](blog/superbowl.html) | **new** |
| Styles | `dataColor`'s defaults: Great Tables' palette and its grey for missing values | [Colorizing with Data](get-started/colorizing_with_data.html) | **new** |
| Look | On a phone, numbers break inside a cell: `−$24,334.23` puts its minus on a line of its own, `1.63 × 10⁻²` its power of ten (`white-space: nowrap` on formatted numbers) | [v0.15.0](blog/v0_15.html), [v0.13.0](blog/v0_13.html) | **new** |
| Look | Columns that stay in place (the stub, the first columns) while a wide table scrolls sideways, for a timetable on a phone | [SEPTA timetables](blog/septa.html) | **new** |
| Export | Saving a table as an image (`gtsave`); tabelline has the HTML (`toHtml`) | [v0.4.0](blog/v0_4.html) | **new** |

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

