---
name: tabelline
description: Makes display tables in Nim with tabelline (titles, stubs, row groups, spanners, formats, colours, summary rows, nanoplots) and checks them on a phone; says where its docs are and which traps agents met. Read it before writing any code whenever a task names tabelline, asks for a display table in Nim (in a program, a README or a nimib page), or ports a gt (R) or Great Tables (Python) table to Nim, even if the user never says "tabelline".
metadata:
  status: draft
---

# tabelline

[tabelline](https://github.com/pietroppeter/tabelline) makes display tables in Nim after R's gt
and Python's Great Tables. This skill targets **0.2**. It holds only what tabelline's own docs do
not: where they are, how to work, and the traps agents met. Look names up there.

## Where the docs are

- **[llms.txt](https://pietroppeter.github.io/tabelline/llms.txt)**: the map, plain text.
- **[api.md](https://pietroppeter.github.io/tabelline/api.md)**: the whole API in one Markdown
  file, about 8,000 lines: never print it whole. It opens with an index, one line per name with
  gt's name (lines 13 to 445, too long for one read: take it in two halves, or grep it). Then
  each name has an entry with its signatures, its doc comment and an example with what it prints.
  - a tabelline name: `grep -n "^### fmtNumber" api.md`, then `sed -n` the forty lines after;
  - a gt or Great Tables name: `grep -n "fmt_number" api.md`;
  - `loc.body`, `style.text`, `agg.sum`: the entry is the last word, `### body`, `### text`;
  - the names of `tabOptions` are the fields of `### TabOptions`; the values of an enum
    (`alCenter`) are in its entry, `### Align`.
- Offline: the doc comments in the installed sources (`nimble path tabelline`) are the same text.

Most of gt and Great Tables is there in 0.2, under the same names in camelCase (`summary_rows`
is `summaryRows`, `cells_body()` is `loc.body()`, `cell_fill()` is `style.fill()`). Before
writing a workaround, grep api.md for the gt name. What is missing is in the feature map,
[gt.json](https://pietroppeter.github.io/tabelline/coverage/gt.json) (`status` not `done`).

## Install

Not in nimble's package list. From a folder that is not a nimble project (inside one, nimble
0.26 skips the package you name):

```sh
nimble install -y "https://github.com/pietroppeter/tabelline@#v0.2.0"
```

## Work like this

1. Write the table as a recipe, one verb per line, then `echo t` and run
   (`nim r --hints:off t.nim`). Text shows the parts, groups, formats, summary rows and
   nanoplots (as sparklines); not styles, colours or superscripts.
2. Then write what was asked: `t.save "t.html"` (a page), `t.toHtml`, `t.toMarkdown`, or
   `nbTable t` in nimib, and grep the HTML for the colours and styles you set.
3. Then look at the page, every time, also for a small table. From this skill's folder:
   `node ../table-building/scripts/look.js t.html` writes `t-wide.png` (1100px) and
   `t-phone.png` (390px) and lists what it can measure. Read both pictures: a title shown twice,
   a column that should be hidden, a drawing too big, a table cut at the edge of a phone. Fix
   and look again. In your reply say what the phone shows, or that you could not look.

```nim
import tabelline, tabelline/datasets

let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  tabHeader md("The **planets**")
  colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
  colsLabel:
    moons: md("*moons*")
  summaryRows:
    total: agg.sum
    columns = "moons"
echo t
```

```text
    The planets
┌─────────┬───────┐
│         │ moons │
╞═════════╪═══════╡
│ Terrestrial     │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mercury │     0 │
│ Venus   │     0 │
│ Earth   │     1 │
│ Mars    │     2 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │     3 │
├─────────┼───────┤
│ Gas giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter │    95 │
│ Saturn  │   146 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │   241 │
├─────────┼───────┤
│ Ice giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus  │    28 │
│ Neptune │    16 │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ total   │    44 │
└─────────┴───────┘
```

## When the table is hard

Two things take most of the time in a hard table, and neither is a verb to look up. Read the
page before you start on one:

- **The data is made in code** (a group-by, a join, a pivot, a sort, a JSON file, anything the
  Python did with Polars or the R with dplyr): [references/data.md](references/data.md).
- **A cell holds a drawing or HTML of your own** (a small chart, a coloured box, anything from
  gt-extras): [references/cells.md](references/cells.md).

For a whole table like yours, the book ports real ones, with the original Python or R beside
the Nim. Read the one closest to your table (the Nim is after each `""":`); they shape their
data with nanuq, which you can replace with plain Nim:

| Your table | Read (under `https://raw.githubusercontent.com/pietroppeter/tabelline/v0.2.0/book/`) |
| --- | --- |
| charts or boxes drawn in cells | `extras/nfl_season.nim`, `contest/lemurs.nim` |
| a timetable, or any table with twenty columns | `blog/septa.nim` |
| a grid that is not rows of data (a calendar, a board, a periodic table) | `blog/superbowl.nim`, `contest/periodic_table.nim` |
| a statistical summary by groups (counts and percents, a clinical table) | `vignettes/case_study_clinical.nim` |
| many summary rows | `vignettes/summary_lines.nim` |
| a ranking with pictures, links and a heavy style | `contest/euroncap.nim` |
| every style and option, one by one | `contest/gt_styling.nim` |

For the order to build a table in, and what to look for in the pictures, read the skill
`table-building`.

## Traps agents met

- **`md` with nimib 0.4.3** (the released nimib): `import nimib` and tabelline give
  `ambiguous call; both boost.md ... and core.md`. Write `import nimib except md`.
- **Rows are rows of the data, from 0, not rows as shown.** After `rowOrder`, `rows = [0]` is
  still the first row of the data. For the first rows as shown, build the table, then take
  `t.displayOrder()[0 .. 2]` and style those rows (`t = t.tabStyle(..., loc.body(rows = top))`),
  so the shading follows the data; do not write the names or a threshold by hand. To mean rows by
  content, `where(...)`.
- **A cell is a `Value`, not a string**: `where(it["planet"] in ["Saturn", "Jupiter"])` does not
  compile; write `where($it["planet"] in ["Saturn", "Jupiter"])`. Comparisons with numbers and
  strings work as they are (`it["moons"] > 20`, `it["type"] == "Ice giant"`).
- **A verb outside the recipe returns a new table**: `t.tabHeader("x")` alone changes nothing.
  Inside the recipe every call is read as a verb, except `echo`, `discard` and asserts.
- **A list of pairs is a block in the recipe** (`colsLabel:`, `summaryRows:`, `colsWidth:`), one
  pair per line, and there a `fmtNumber(decimals = 0)` line formats the summary cells.
- **`md` escapes HTML tags.** A `<span>` or an `<a>` in a title, a label or a note goes in
  `html(...)`.
- **A palette is a name tabelline has, or colours.** `palette("oranges")` is not one and fails
  when the table is drawn, with `not a colour: oranges`. Grep api.md for `### palette` for the
  names, or give the colours: `palette = @["#FFF4E5", "#C2410C"]`.
- **Not in tabelline, write this instead**: a selector's negation is `everything() - sel`;
  `system_fonts("industrial")` is `systemFonts("industrial")`; there is no `google_font()` (name
  the font and a stack of the reader's own after it); a regular expression in `matches` is a proc
  of the name.
- **A list of pairs as a block takes pairs written out.** A name with a space, or a label with
  one, goes in quotes (`"Avg PF": "Points for"`, `"All types": agg.sum`). Pairs computed in a
  loop are a `seq[(string, string)]` made before the recipe and given to the verb:
  `colsWidth widths`.
- **`loc.body`, `loc.stub` and `loc.columnLabels` take `cols =`**, not `columns =` as the verbs do.
- **Several tables on one page**: `tabellaStyle` once, then each `t.toHtml(withStyle = false)`.
- **The first compile takes a minute or two**; later ones are fast.
- **Colours on a styled page**: `optCssTheme()` takes them from the page's CSS variables
  (`--ink`, `--paper`, ...), so in a nimib page with a theme write no hex values.

## Before you finish

The program ran and you read `echo t`; the output asked for exists and holds the styles you set;
you ran `look.js` and read the wide and the phone picture (step 3), or said that you could not;
every feature of a gt or Great Tables table you could not port is named in your reply, after a
grep of api.md for its gt name.
