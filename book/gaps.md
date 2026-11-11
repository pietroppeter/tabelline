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
| Data | Data frames (pandas' `head`, `select`, `loc`, Polars' pivot: the book's helpers in `gtdata` and plain Nim) | every page, [v0.2.0](blog/v0_2.html) and [v0.4.0](blog/v0_4.html) the most | later |
| Data | `readCsv` reads `"0400"` as the number 400; text with leading zeros could stay text | [Colorizing with Data](get-started/colorizing_with_data.html) | **new** |
| Parts | `tabStub` (the stub is only chosen in `tabella(rownameCol = ...)`) | [Stub](get-started/basic_stub.html) | **new** |
| Parts | `tabSpanner` gathers its columns, in the order given (tabelline leaves them where they are) | [Column Labels](get-started/basic_column_labels.html) | **new** |
| Parts | Summary rows of the same label from two calls make one row, as in gt (Great Tables, like tabelline, makes two) | [Creating Summary Lines](vignettes/summary_lines.html) | **new** |
| Parts | Markdown (a link) in a row group label, as gt's `tab_row_group(label = md(...))` | [Find an example by feature](features.html) | **new** |
| Columns | Columns by position, negative ones too (`["date", 1, -1]`) | [Column Selection](get-started/column_selection.html) | **new** |
| Columns | Columns by any function of the name, and rules combined: `\|`, `&`, `exclude`; gt's `matches()` | [Column Selection](get-started/column_selection.html), [Styling the Table Body](get-started/basic_styling.html) | **new** |
| Rows | Negative row indices (`[0, -1]`; in Nim, `^1`) | [Row Selection](get-started/row_selection.html) | **new** |
| Formats | The format functions with every argument of their verb: `pattern`, `locale` (`formatDate` has it, `formatNumber` not), `expStyle` | [Formatting Values](get-started/basic_formatting.html), [Creating Summary Lines](vignettes/summary_lines.html) | **new** |
| Formats | Nanoplots with dates as the *x* values, and a colour for each point | [Nanoplots](get-started/nanoplots.html) | **new** |
| Text | Full Markdown in `md()`, HTML entities included | [Header and Footer](get-started/basic_header.html) | **new** |
| Options | White text on every dark background set by options (the stub; a heading given by colour name: tabelline picks the text colour only for `#rrggbb` colours) | [Table Theme Options](get-started/table_theme_options.html) | **new** |
| Options | `optStylize` with gt's six styles | [Premade Themes](get-started/table_theme_premade.html) | **new** |
| Options | `optAllCaps` on the stub and the row group labels too | [Premade Themes](get-started/table_theme_premade.html), [v0.3.0](blog/v0_3.html) | **new** |
| Options | `systemFonts`, Great Tables' font stacks by name (`"industrial"`), for `tableFontNames` and `optTableFont` | [v0.3.0](blog/v0_3.html) | **new** |
| Styles | `loc.stub` by row label (`"banana"`), and mixed with indices | [Location selection](get-started/loc_selection.html) | **new** |
| Styles | `loc.rowGroups` by a row of the group, or by a condition | [Location selection](get-started/loc_selection.html) | **new** |
| Styles | `loc.body(mask = ...)`: a condition for each cell | [Styling the Table Body](get-started/basic_styling.html), [Location selection](get-started/loc_selection.html) | **new** |
| Styles | A fill on a spanner colours its whole cell, not only the label | [Styling the whole table](get-started/targeted_styles.html) | **new** |
| Styles | Every CSS colour name (tabelline knows 17; `rebeccapurple`, `bisque` and `darkgreen` fail; R does not know `rebeccapurple` either) | [Colorizing with Data](get-started/colorizing_with_data.html), [v0.2.0](blog/v0_2.html) | **new** |
| Styles | `dataColor`'s defaults: Great Tables' palette and its grey for missing values | [Colorizing with Data](get-started/colorizing_with_data.html) | **new** |
| Export | `extractSummary` gives the summary cells as shown (text); gt's `extract_summary()` gives the values | [Creating Summary Lines](vignettes/summary_lines.html) | **new** |
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

