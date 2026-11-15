# Backlog

Ideas for tabelline. A loose list, not a roadmap: nothing here is committed. When an idea is
picked up it becomes an OpenSpec change (`/opsx:propose`) and is marked *in progress* here with
the change name; when the change is archived, its entry is removed and a line goes to
[CHANGELOG.md](CHANGELOG.md).

Rough size: S (hours), M (a day or two), L (more).

## Parts

- **Stub that does not wrap** (S). An option (or a `colsWidth` setting) to keep the stub on one
  line: "600 BCE" broke in two in diagrammari's era tables, fixed there with page CSS
  (`td.tb_stub{white-space:nowrap}`).

## Formats

- **Gaps from the month article** (S each, 0.1 use-it thread, [A month of building with Claude](https://pietroppeter.github.io/claude-artifacts/a-month-with-claude/)): an `html()` cell format
  (`fmtMarkdown` escapes every tag but `<br>`); Markdown in row group labels; a TSV or
  `quote = ""` option for `readCsv` (a `"` inside a field is taken as quoting and dropped);
  document that colours such as `style.fill("var(--x)")` can use the page's CSS variables.

- **Gaps from the Milano Cortina post** (S each, 0.1 use-it thread): a `head`/`rowsKeep` that cuts the rows after `rowOrder`, for a top ten
  by another column; a rank helper; `fmtNumberSi` with a powered unit (`m³`) writes cubic
  megametres; `textCaseMatch(cases, loc...)` needs `locations =` because `default` and `replace`
  come first; say in the docs that text transforms run after `fmtMarkdown` (Markdown in a
  replacement stays as text, HTML works); `subZero(zeroText = "")` cannot write an empty cell (an empty text means no
  substitution).

- **More pictures** (S-M). Icons and images are in 0.2 (#63). Left: SVG flags (emoji flags
  are in 0.1); gt's `local_image()`, `web_image()`, `ggplot_image()`.
- **More of the locales** (S-M). Every CLDR locale is in 0.2 (#62). Left: country names in
  other languages, `system = "ind"`, flexible styles with a time zone.
- **Rounding** (S). `formatFloat` rounds half to even (2.25 → "2.2"); decide whether to round
  half away from zero as gt does in some cases.

## Plots in cells

- **More nanoplots** (M). Nanoplots are in 0.2 (#63). Left: x values as dates, per-point
  options (a list of colours), `alt` from a column.

## Options and building

- **Show the parts** (S). The docs' `showParts` (docs/table_parts.nim) as a library preset, `optParts()`,
  with a legend: a way to learn the parts of a gt table on your own data.
- **Option presets** (S-M). A page that styles every table the same way repeats six or seven
  `tabOptions` fields per table. A user-defined preset (`let sea = tabOptions(...)`, then
  `tabOptions sea` or `optPreset sea`), like `optCssTheme` but your own; a docs theme would ship
  one.
- **Named font stacks** (S, from the book's port of the Great Tables blog). Great Tables'
  `system_fonts()` ("industrial", "humanist", ...) as `systemFonts(name)`, for `optTableFont`
  and `tableFontNames`: no fonts to load.
- **Scroll on narrow screens** (S). Wrap wide tables in a container with `overflow-x: auto` by
  default (an option to turn it off), instead of each page adding it.

## Interop

- **datamancer** (S). The same for SciNim's datamancer.
- **Arraymancer tensors** (S). A 2D tensor as a table.
- **unchained** (S-M). Vindaar's unchained (units checked at compile time) as an optional
  module `tabelline/unchained`: a column of `KiloGram` or `Meter•Second⁻¹` values becomes a column
  of floats whose unit, read from the type, is set as with `colsUnits` (written in gt's notation,
  so it shows as kg or m s⁻¹ in every output); `toUnit` converts a column before it is shown.
  From the 0.2 review (Pietro, 10 Nov 2026).

## Outputs

- **LaTeX** (M). `toLatex`, booktabs style, as gt's `as_latex`.
- **Images** (M). `saveImage` with headless Chromium.
- **Tabellone** (L). A Tabella shown as a grid: `toGrid(t)` and `nbGrid`, with virtual rows,
  sort, filter, sticky header and stub, spanners as column groups, and the table's header and
  footer around the grid. In this repository as a module; rows served from Nim (a row model)
  later, maybe in its own repository. See the devlog post
  [Tabellone](https://pietroppeter.github.io/tabelline/devlog/tabellone/), which has a sketch.
  Optional: `tabelline/aggrid`, AG Grid column definitions from a Tabella.
- **RTF / Word** (L). For the pharma use case.

## nimib

- **nimibook and nimiSlides** (S). Check that tables look right in their themes.

## Docs

- **What the islands story cost** (S, Pietro, 13 Nov 2026). When the story of the islands of the
  Mediterranean is done: an estimate of its effort, with the pages beside it (the story of the
  data, the photos, the Italian page and its translation notes): the machine side (tokens,
  runs, builds) and the review side (rounds, comments handled, conversations), and the features
  it brought to tabelline (the shape nanoplot, `moreRows`, the citations).

- **FOSDEM devroom picker** (M, Pietro, from the FOSDEM story): once the story is in Nim, a
  small widget (nimib JS block, data inlined) where a reader picks a devroom (its family, across
  renames) and sees its talks of the last three editions, plus the 2027 call for participation
  until the schedule is out. Goes with the parked interactive tables (`opt_interactive`).
- **A skill for users** (M). `skill.md` and `llms.txt` written from the specs and their examples
  while the pages are built, served from the site, as Great Docs does for Great Tables. From the
  skills part of [A month of building with Claude](https://pietroppeter.github.io/claude-artifacts/a-month-with-claude/#part-three) (0.1 use-it thread).
- **A small skill benchmark** (S). Five tasks with and without the user skill, graded by building
  the result.
- **Port the gt user guide** (M). A second part of the book: the guide of R's gt
  (gt.rstudio.com/articles), its text kept, with 👑 Nim, 🏴‍☠️ R (the original) and, where Great
  Tables has it, 🐍 Python. Check its licence (MIT) first.

- **A gallery** (M). Rebuild well-known gt tables and Table Contest entries with tabelline.
- **API reference** (S). `nim doc` for `src/tabelline.nim`, published with the pages.
- **A Table Contest entry** (M). For the next Posit Table Contest.

## From the tabelline book (0.1 port thread, book/gaps.md in PR #11)

- **Summary cells in a column with no format** (S, from the 0.2 book port). tabelline formats
  them as numbers (5,552.33); Great Tables shows the raw value (5552.3331). Keep ours, but say so
  in the summary rows spec and its list of differences.

## From agents building hard tables (skills thread, 15 Nov 2026)

Six hard tables of the book were given to coding agents, twice each; their notes say where they
lost time ([Hard tables: nobody looked](https://github.com/pietroppeter/skills/pull/6), the
skills devlog). What tabelline itself could do:

- **An unknown palette name fails when the verb is called** (S). `palette("oranges")` is accepted
  and fails only when the table is drawn, with `not a colour: oranges`. Check the name in
  `dataColor` and list the names in the error.
- **A format that sees its row** (M). A `fmt` proc gets one cell. A drawing made of two columns
  (points for and against) needs both packed in one column first. gt's `fmt` has the same limit;
  gt-extras works around it the same way.
- **`fmt` for a whole list** (S). A cell that holds a list is formatted item by item, so a chart of
  the list needs the values written as text first. An option to give the proc the whole value.
- **A page of several tables** (S). `savePage(tables, "t.html")`, or `save` taking a list: today
  it is `tabellaStyle` once and `toHtml(withStyle = false)` for each, written by hand.
- **`optCss` says when it drops a rule** (S). An `@import` in the CSS is dropped without a word.
- **api.md for agents** (S). A shorter index (it is 37 KB, more than one tool read), entries filed
  under their full name (`style.text` is under `### text`), and an example for `fmt` with a proc
  that returns HTML and for `dataColor` with a palette.
- **A clearer error for a block of pairs** (S). In `colsLabel:` a name with a space and no quotes
  gives a macro error that does not say to quote it.
