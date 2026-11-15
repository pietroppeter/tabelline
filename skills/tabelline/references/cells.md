# Cells you draw yourself

For what no verb draws: a small chart, a coloured box, an icon with a number, anything from
gt-extras or gtExtras (`gt_plt_winloss`, `gt_plt_dumbbell`, `gt_color_box`, `gt_fa_rank_change`,
`gt_plt_bar`), gt's `ggplot_image()`, or Great Tables' `fmt()` with a function that returns HTML.
First check that a verb does not do it: `fmtNanoplot` (line, bar and box plots from a list of
numbers), `fmtImage`, `fmtIcon`, `fmtFlag`, `dataColor`.

The rules:

- **Give `fmt` a proc that takes the `RenderContext` too.** `proc (v: Value, ctx:
  RenderContext): string` returns HTML as it is. The short form, `proc (v: Value): string`,
  is escaped, so `<svg>` or `&check;` would show as text.
- **Answer `rcText` with plain words.** `echo t` and Markdown call the same proc: without the
  `if ctx == rcText` line the text table fills with SVG.
- **A format sees one cell.** For a drawing that needs two or more numbers of the row, put them
  in one column as text (`"16 28"`) when you make the data, and hide the columns you joined.
- **A list in a cell is formatted item by item**, so a proc that wants the whole list (sixteen
  results for one strip) gets one number at a time and draws nothing. Put the list in the cell
  as text too (`"1 0 1 1"`), and split it in the proc.
- **One scale for every row**: compute the minimum and the maximum once, outside the proc.
- **Size the drawing in the SVG** (`width` and `height` attributes, in px). A drawing with only
  a `viewBox` grows to fill the cell, and the rows become very tall.
- **Raw HTML in a title, a label or a note is `html(...)`**, not `md(...)`: `md` escapes tags.
- **Round numbers yourself.** Nim's `{x:.0f}` prints `28.`, with the dot: in a text that is
  ugly, in `width="120."` the SVG loses its size. Write `{x.int}` or `{x:.1f}`.

```nim
import std/[strformat, strutils, sequtils]
import tabelline

let teams = tableData:
  team: ["Trento", "Bari"]
  points: ["16 28", "24 23"]        # two numbers for one drawing: put them in one cell, as text
  share: [0.72, 0.31]

proc dumbbell(v: Value, ctx: RenderContext): string =
  ## Points against and for: two dots on a line in HTML, plain words in text.
  let p = ($v).splitWhitespace.mapIt(parseFloat(it))
  if ctx == rcText: return &"{p[0].int} to {p[1].int}"
  let x = p.mapIt(10 + (it - 10) / 25 * 100)     # the same scale, 10 to 35, in every row
  &"""<svg width="120" height="16" role="img" aria-label="{p[0].int} to {p[1].int}">""" &
    &"""<line x1="{x[0]:.1f}" x2="{x[1]:.1f}" y1="8" y2="8" stroke="silver" stroke-width="2"/>""" &
    &"""<circle cx="{x[0]:.1f}" cy="8" r="4" fill="firebrick"/>""" &
    &"""<circle cx="{x[1]:.1f}" cy="8" r="4" fill="seagreen"/></svg>"""

proc bar(v: Value, ctx: RenderContext): string =
  let pct = int(v.toFloat * 100 + 0.5)
  if ctx == rcText: return $pct & "%"
  &"""<span style="display:inline-block;width:{pct}px;height:0.7em;background:steelblue"></span> {pct}%"""

let t = tabella(teams, rownameCol = "team"):
  fmt "points", dumbbell
  fmt "share", bar
  colsAlign alLeft, "share"
  tabSourceNote html("""<span style="float:right">Source: <a href="https://example.org">the league</a></span>""")
echo t
let page = t.toHtml
doAssert "<svg" in page and "&lt;svg" notin page   # drawn, not escaped
```

```text
┌────────┬──────────┬───────┐
│        │ points   │ share │
╞════════╪══════════╪═══════╡
│ Trento │ 16 to 28 │ 72%   │
│ Bari   │ 24 to 23 │ 31%   │
└────────┴──────────┴───────┘
Source: the league
```

The book has whole tables made this way, with the original Python beside the Nim: an
[NFL season](https://raw.githubusercontent.com/pietroppeter/tabelline/v0.2.0/book/extras/nfl_season.nim)
(win and loss strips, dumbbells, coloured boxes, a theme as a proc) and the
[lemurs](https://raw.githubusercontent.com/pietroppeter/tabelline/v0.2.0/book/contest/lemurs.nim)
(bar and line charts with axes).
