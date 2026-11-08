# What the port found

Everything tabelline still lacks to do what the Great Tables *Get Started* guide does, found
while porting it. What the port found that tabelline has gained since, in 0.1, is told in the
devlog post [What the book found for 0.1](https://pietroppeter.github.io/tabelline/devlog/book-found/).

The gaps go from the simplest to the most complex, in the order a table is made: the data, the
parts of the table, its columns and rows, then formats, text, options and styles. Each says
where it is planned in the [feature map](https://pietroppeter.github.io/tabelline/coverage/),
or **new** when the map does not have it; the new ones go to the build of the next release and
to the backlog.

## The gaps

| Step | What | Where it shows | Plan |
| ---- | ---- | -------------- | ---- |
| Data | Datasets `islands`, `airquality`, `sza` (the book reads copies) | every page | 0.2 |
| Data | Data frames (pandas' `head`, `select`, `loc`, Polars' pivot: the book's helpers in `gtdata` and plain Nim) | every page | 0.3 |
| Data | `readCsv` reads `"0400"` as the number 400; text with leading zeros could stay text | [Colorizing with Data](get-started/colorizing_with_data.html) | **new** |
| Parts | `tabStub` (the stub is only chosen in `tabella(rownameCol = ...)`) | [Stub](get-started/basic_stub.html) | **new** |
| Parts | `tabSpanner` gathers its columns, in the order given (tabelline leaves them where they are) | [Column Labels](get-started/basic_column_labels.html) | **new** |
| Parts | Summary rows and their locations | [Styling the whole table](get-started/targeted_styles.html), [Table Theme Options](get-started/table_theme_options.html) | 0.2 |
| Columns | `colsAdd` (the book adds columns to the data) | [Intro](get-started/intro.html) | 0.2 |
| Columns | Columns by position, negative ones too (`["date", 1, -1]`) | [Column Selection](get-started/column_selection.html) | **new** |
| Columns | Columns by any function of the name, and rules combined: `\|`, `&`, `exclude`; gt's `matches()` | [Column Selection](get-started/column_selection.html), [Styling the Table Body](get-started/basic_styling.html) | **new** |
| Rows | Negative row indices (`[0, -1]`; in Nim, `^1`) | [Row Selection](get-started/row_selection.html) | **new** |
| Formats | Every date style of gt, in every language (`wday_day_month_year` is missing) | [Formatting Values](get-started/basic_formatting.html) | 0.3 |
| Formats | The format functions with every argument of their verb: `pattern`, `locale`, `expStyle` | [Formatting Values](get-started/basic_formatting.html) | **new** |
| Formats | Nanoplots (the guide's page is left out) | | 0.4 |
| Text | Full Markdown in `md()`, HTML entities included | [Header and Footer](get-started/basic_header.html) | **new** |
| Options | The rest of `tabOptions`: column label top border, hlines style and width, vlines, font style, source notes background, container width, stub border, row group top and bottom borders | [Table Theme Options](get-started/table_theme_options.html) | 0.2 |
| Options | White text on every dark background set by options (the stub; a heading given by colour name: tabelline picks the text colour only for `#rrggbb` colours) | [Table Theme Options](get-started/table_theme_options.html) | **new** |
| Options | `optStylize` with gt's six styles | [Premade Themes](get-started/table_theme_premade.html) | **new** |
| Options | `optAllCaps` on the stub and the row group labels too | [Premade Themes](get-started/table_theme_premade.html) | **new** |
| Styles | `fromColumn` and `tabStyleBody`: styles whose values come from a column | [Styling the Table Body](get-started/basic_styling.html) | 0.2 |
| Styles | `loc.stub` by row label (`"banana"`), and mixed with indices | [Location selection](get-started/loc_selection.html) | **new** |
| Styles | `loc.rowGroups` by a row of the group, or by a condition | [Location selection](get-started/loc_selection.html) | **new** |
| Styles | `loc.body(mask = ...)`: a condition for each cell | [Styling the Table Body](get-started/basic_styling.html), [Location selection](get-started/loc_selection.html) | **new** |
| Styles | A fill on a spanner colours its whole cell, not only the label | [Styling the whole table](get-started/targeted_styles.html) | **new** |
| Styles | Every CSS colour name (tabelline knows 17; `rebeccapurple` and `bisque` fail; R does not know `rebeccapurple` either) | [Colorizing with Data](get-started/colorizing_with_data.html) | **new** |
| Styles | `dataColor`'s defaults: Great Tables' palette and its grey for missing values | [Colorizing with Data](get-started/colorizing_with_data.html) | **new** |

## Differences kept

Not gaps, but worth knowing:

- tabelline stops on a column that does not exist, where Great Tables lets it pass and gt stops
  too ([Premade Themes](get-started/table_theme_premade.html)).
- Missing values are blank, where Great Tables writes `None` and gt `NA`; `subMissing` shows a
  dash.
- `loc.body` takes `cols =`, Great Tables `columns=`; `style.borders` takes a set of sides.
- Styles join with `&`, not in a list; locations are any number of arguments.
