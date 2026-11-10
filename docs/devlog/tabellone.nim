## devlog: 07 Nov 2026 B | Tabellone: when a table becomes a grid | gt and Great Tables make tables to read; dashboards need grids to explore. What a grid is, how AG Grid and friends do it, and whether tabelline should have a big brother.
## A dated post: a piece of research, written once and not updated afterwards.
import std/[os, json, strutils, math, sequtils, strformat]
import nimib
import tabelline, tabelline/[nimib, build]
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "tabellone" / "index.html"
nb.useTabelline(title = "Tabellone: when a table becomes a grid", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "7 November 2026 · research", "Tabellone: when a table becomes a grid", """
gt and Great Tables make tables to read; dashboards need grids to explore. What a grid is, how AG Grid and friends do it, and whether tabelline should have a big brother.
"""
nbText: """
In an Italian school the *tabellone* is the big board in the hallway where the end-of-year
marks are posted: every pupil, every subject, one huge table that everybody crowds around to
search for one name. *Tabelline* are the little times tables of the first years. The two words
make a good pair for the question of this post.

Reading gt and Great Tables for tabelline showed something they do *not* do much of: let a
reader explore a big table. They make tables to be read, in a report, a paper, a notebook. A
dashboard needs something else, and the JavaScript world has a name for it: a **data grid**.
The one Pietro remembered using from Streamlit, the best he had seen, is
[AG Grid](https://www.ag-grid.com/).

<div class="nota"><b>In short.</b> A table is a document; a grid is an application. They share a
data model (columns, labels, formats, styles, groups) and almost nothing else. tabelline should
keep making documents, and a *tabellone* can grow next to it, in the same repository, starting as
one more renderer of the same <code>Tabella</code>. A small working sketch is at the end.</div>

## A table and a grid

The same rows can be shown in two ways that want opposite things:
"""

nbCode:
  type Contrast = object
    aspect, table, grid: string
  let contrast = @[
    Contrast(aspect: "made for", table: "reading: a report, a paper, a notebook", grid: "exploring: a dashboard, an app, a tool"),
    Contrast(aspect: "size", table: "what fits on a page: tens of rows", grid: "thousands to millions of rows"),
    Contrast(aspect: "who decides", table: "the author: order, groups, emphasis", grid: "the reader: sort, filter, resize, pin"),
    Contrast(aspect: "parts", table: "title, spanners, stub, groups, footnotes, source notes", grid: "column headers, maybe column groups"),
    Contrast(aspect: "formats", table: "rich and exact: 1.2 M, €3.50, MCMXC", grid: "a formatter function per column"),
    Contrast(aspect: "rendering", table: "all the rows, once, as HTML (or PDF, Word, text)", grid: "only the rows on screen, again at every scroll"),
    Contrast(aspect: "lives", table: "on paper as well as on screen", grid: "only in a browser"),
  ]
  let t1 = tabella(contrast, rownameCol = "aspect"):
    tabHeader "A table and a grid", "the same rows, shown for two different jobs"
    colsLabel {"table": "a table (gt, tabelline)", "grid": "a grid (AG Grid, Tabulator, ...)"}
    colsWidth {"table": "42%", "grid": "42%"}
    optCssTheme()
  nbTable t1

nbText: """
## What a grid does

Read the feature lists of a few grids and the same list comes back. The core is that a grid
**renders only what is on screen** (*virtualization*): a scroll of a million rows draws about
forty of them, and draws them again as you move. Everything else is built on that:
"""

nbCode:
  type Feature = object
    family, features, agCommunity, agEnterprise, gt: string
  let features = @[
    Feature(family: "Scale", features: "virtual rows and columns; data loaded in blocks as you scroll; data kept on a server", agCommunity: "client-side and infinite row models", agEnterprise: "server-side and viewport row models", gt: "pagination only"),
    Feature(family: "Find", features: "sort by one or more columns; filters per column (text, number, date, set); a quick search over everything", agCommunity: "yes (multi-column sort is Enterprise)", agEnterprise: "set filter, advanced filter", gt: "sort, search, filters"),
    Feature(family: "Arrange", features: "resize, reorder, pin and hide columns; column groups; a side panel to choose columns", agCommunity: "yes", agEnterprise: "tool panels", gt: "resize"),
    Feature(family: "Summarise", features: "group rows and aggregate; pivot; tree data; master and detail rows", agCommunity: "tree data", agEnterprise: "row grouping, pivoting, aggregation, master/detail", gt: "row groups (fixed)"),
    Feature(family: "Act", features: "select rows or ranges; edit cells; copy and paste; context menus", agCommunity: "row selection, editing", agEnterprise: "range selection, clipboard, menus", gt: "row selection"),
    Feature(family: "Export", features: "CSV, Excel with styles, charts from a selection", agCommunity: "CSV", agEnterprise: "Excel, integrated charts", gt: "none in the page"),
    Feature(family: "Live", features: "streaming updates, flashing changed cells, transactions", agCommunity: "yes", agEnterprise: "viewport row model", gt: "no"),
  ]
  let t2 = tabella(features, rownameCol = "family"):
    tabHeader "What a grid does", "the families of features of a data grid, and who has them"
    tabSpanner "AG Grid", ["agCommunity", "agEnterprise"]
    colsLabel {"features": "features", "agCommunity": "Community (MIT)", "agEnterprise": "Enterprise (paid)",
               "gt": "gt opt_interactive()"}
    colsWidth {"features": "34%"}
    tabSourceNote md("AG Grid: [Community vs Enterprise](https://www.ag-grid.com/javascript-data-grid/community-vs-enterprise/), version 36.3. gt: [`opt_interactive()`](https://gt.rstudio.com/reference/opt_interactive.html). Great Tables has nothing interactive yet.")
    optCssTheme()
  nbTable t2

nbText: """
## AG Grid, the one from Streamlit

AG Grid began as a side project. Niall Crosby made the first commit in 2015 and worked on it about
twenty hours a week; in March 2016 he
[quit his job](https://www.ag-grid.com/blog/ag-grid-goes-commercial/) to work on it full time, and
version 4 was the first with two editions: the core under the MIT licence, and *ag-Grid-Enterprise*
under a commercial one. The company stayed [self-funded](https://www.ag-grid.com/about.md) and
grew to about sixty people in London. Niall Crosby died in an accident in the summer of 2024
([AG Grid's post](https://www.ag-grid.com/blog/in-memory-of-niall-crosby/)).

The split is still the same. **Community** is MIT and free in production. **Enterprise** needs a
licence per developer and per deployment, perpetual, with a year of support and updates; without
a key it runs with a watermark, so it can be tried locally. Enterprise holds what makes a grid a
small spreadsheet: row grouping and pivoting, the server-side row model, range selection and the
clipboard, Excel export, integrated charts, master/detail.

The part worth copying is the idea of **row models**: where the rows live, and who sorts them.

- *Client-side* (the default): all the data is in the browser, which sorts, filters and groups it;
  fine past 100,000 rows, until the browser runs out of memory.
- *Infinite*: rows come in blocks from the server as the user scrolls; a flat list.
- *Server-side* (Enterprise): the same, with grouping and aggregation done by the server.
- *Viewport* (Enterprise): the grid tells the server which rows are on screen and the server sends
  only those, for live data.

In Streamlit, AG Grid came through [streamlit-aggrid](https://github.com/PablocFonseca/streamlit-aggrid),
a component by an independent developer, Pablo Fonseca, which passes AG Grid's options from
Python.

## The other grids

- [**Tabulator**](https://tabulator.info/): MIT and free, all in one library: virtual DOM, sorting,
  filters, grouping, editing, tree data, CSV and XLSX download. Started on GitHub by Oli Folkerd,
  now with Beekeeper Studio behind it; version 6.5.
- [**Glide Data Grid**](https://github.com/glideapps/glide-data-grid): MIT, draws on a `<canvas>`
  instead of HTML, for millions of rows with native scrolling; sorting and filtering are left to
  the app. Streamlit's own `st.dataframe` is built on it.
- [**Perspective**](https://perspective.finos.org/): a C++ engine compiled to WebAssembly, with
  Apache Arrow in and out, for large and streaming data, with a grid and charts on top.
- [**DataTables**](https://datatables.net/): the old favourite that enhances an HTML `<table>`;
  MIT core, now at version 3. In Python, [itables](https://github.com/mwouts/itables) wraps it for
  notebooks.
- [**reactable**](https://glin.github.io/reactable/): R, on top of TanStack (React) Table:
  sorting, filters, pagination, grouping and aggregation, virtual scrolling.

## gt, Great Tables and the gap

gt has one door into this world: [`opt_interactive()`](https://gt.rstudio.com/reference/opt_interactive.html)
(since gt 0.9) turns a table into an interactive one, with pagination, sorting, and optionally a
search box, column filters and resizable columns. Under the hood gt hands the table to
reactable, and not everything a gt table can say carries over to the interactive version. Great
Tables has no interactive mode at all.

So today there are two worlds that do not meet. Grids have the scale and the interaction, but a
grid's "table" is just headers and cells: no title, no stub, no spanner hierarchy, no footnotes,
no source notes, and formats are code you write per column. Tables have all of that, but stop at
what fits on a page.

## Mixing the two?

Here is how the parts of a gt table map onto a grid. Most have a counterpart; the ones that do not
are exactly the parts that make a table a document:
"""

nbCode:
  type Part = object
    part, grid, how: string
  let parts = @[
    Part(part: "title and subtitle", grid: "none", how: "a header above the grid"),
    Part(part: "column labels", grid: "column headers (headerName)", how: "direct"),
    Part(part: "spanners", grid: "column groups", how: "direct, several levels"),
    Part(part: "stub", grid: "a pinned first column", how: "direct"),
    Part(part: "row groups", grid: "row grouping (Enterprise in AG Grid)", how: "fixed groups, or let the reader regroup"),
    Part(part: "formats", grid: "value formatters", how: "formatted in Nim, sorted on the raw value"),
    Part(part: "styles and dataColor", grid: "cell styles and class rules", how: "the CSS tabelline computes per cell"),
    Part(part: "footnotes", grid: "none", how: "marks in cells, notes under the grid"),
    Part(part: "source notes", grid: "none", how: "a footer under the grid"),
  ]
  let t3 = tabella(parts, rownameCol = "part"):
    tabHeader "A gt table, as a grid", "where each part of a table goes"
    colsLabel {"grid": "in a grid", "how": "in a tabellone"}
    tabStyle style.text(color = "#C62828", weight = "bold"),
      loc.body(cols = "grid", rows = where(it["grid"] == "none"))
    optCssTheme()
  nbTable t3

nbText: """
That suggests what a *tabellone* would be: **a Tabella shown as a grid**. Same data, same verbs,
same formats and styles, but rendered for exploring, with the document parts kept around it.
None of the grids above, and neither gt nor Great Tables, does that.

There are four ways to get there, and one is to not go:
"""

nbCode:
  type Way = object
    way, what, good, bad: string
  let options = @[
    Way(way: "A. Don't", what: "tabelline stays a table library; for grids, use AG Grid or Tabulator directly", good: "no work; tabelline stays small and sharp", bad: "the formats and styles stop at the page; two tools for one dataset"),
    Way(way: "B. Wrap a grid", what: "toAgGrid(t) or toTabulator(t): a Tabella becomes a grid's options, like gt hands off to reactable", good: "every feature of a mature grid, quickly", bad: "a big JavaScript dependency to inline (pages here load nothing remote); Enterprise licences for the best parts; the document parts get lost, as in gt"),
    Way(way: "C. Write a small grid", what: "a renderer of our own: virtual rows, sort, filter, sticky header and stub, keeping every part of the Tabella", good: "standalone pages, nothing remote; everything tabelline knows survives; in the spirit of writing rather than wrapping", bad: "we maintain JavaScript; pivoting, editing and Excel export are far away"),
    Way(way: "D. Rows from Nim", what: "C plus a row model on the server: a Nim process (or WebAssembly) sorts and slices, the page shows a window", good: "real scale: millions of rows, live data, Nim doing the heavy part", bad: "needs a server or a wasm build; a project of its own"),
  ]
  let t4 = tabella(options, rownameCol = "way"):
    tabHeader "Should tabelline have a big brother?", "four ways, from none to a lot"
    colsLabel {"what": "what it means", "good": "for", "bad": "against"}
    colsWidth {"what": "30%", "good": "25%", "bad": "30%"}
    tabStyle style.fill("#E8F5E9"), loc.body(rows = [2])
    tabStyle style.fill("#E8F5E9"), loc.stub(rows = [2])
    optCssTheme()
  nbTable t4

nbText: """
### A proposal

**C first, in this repository; D later, maybe in its own.** A tabellone starts as one more
renderer of the same `Tabella`, next to `toHtml`, `toText` and `toMarkdown`: a module
`tabelline/tabellone` with `toGrid(t)`, and a `nbGrid` block for nimib. It shares the data
model, `build.nim`, the formats and the styles, so it must live where they live, and the specs
would say what it keeps of a table. The JavaScript can be small, plain and inlined, or written in
Nim and compiled with `nbJsFromCode`, which is how nimib already does interactive blocks.

A separate repository makes sense only when the grid needs things the table does not: a server,
a WebAssembly build, its own release cycle. That is option D, and by then the name is ready.

B stays possible as a small optional module (`tabelline/aggrid`, giving AG Grid its column
definitions) for anyone who already has AG Grid in an app; it does not need to be the main road.

And A is a real answer too: if tabellone never happens, tabelline loses nothing. That is why it
should begin as a sketch and an OpenSpec change, not as a promise.

## A sketch

Below is a first tabellone, about seventy lines of Nim and sixty of JavaScript written for this
post, not part of the library. It takes a Tabella, lets tabelline **build** it (formats, styles,
`dataColor`), and writes the rows as JSON with their raw values for sorting. The browser draws
only the rows on screen. The data: the numbers from 1 to 3,999 (the largest that Roman numerals write without a bar),
with their Roman numerals, squares, square roots, divisors and whether they are prime.

Click a column label to sort (again to reverse); type in the box to filter. Scroll: there are
3,999 rows, and about twenty in the page at any time.
"""

nbCode:
  proc numbers(n: int): TableData =
    var ns, squares, divisors, primes, roots: seq[Value]
    for i in 1 .. n:
      var d = 0
      for k in 1 .. int(sqrt(float(i))):
        if i mod k == 0: d += (if k * k == i: 1 else: 2)
      ns.add toValue(i)
      squares.add toValue(i * i)
      roots.add toValue(sqrt(float(i)))
      divisors.add toValue(d)
      primes.add toValue(d == 2)
    toTableData({"n": ns, "roman": ns, "square": squares, "root": roots,
                 "divisors": divisors, "prime": primes})

  let numeri = tabella(numbers(3999), rownameCol = "n"):
    tabHeader "I numeri da 1 a 3.999", "a tabellone: sort, filter and scroll, drawn in your browser"
    tabStubhead "n"
    fmtRoman "roman"
    colsAlign alLeft, "roman"
    fmtInteger "square"
    fmtNumber "root", decimals = 3
    fmtTf "prime", trueText = "prime", falseText = ""
    dataColor "divisors", palette = palette("blues")
    colsLabel {"roman": "in Roman", "root": "√n"}
    tabSourceNote "Every row is computed when the page is built."
    optCssTheme()

nbCode:
  proc gridData(t: Tabella): JsonNode =
    ## The built table as JSON: column labels and alignments, then per row the raw values (to
    ## sort and filter) and the formatted cells with their styles (to show).
    let b = t.build(rcHtml)
    let cols = (if t.hasStub: @[t.colInfo(t.rownameCol)] else: @[]) & b.columns
    result = %*{"title": renderText(t.title, rcHtml), "subtitle": renderText(t.subtitle, rcHtml),
                "notes": t.sourceNotes.mapIt(renderText(it, rcHtml)),
                "columns": cols.mapIt(%*{"label": renderText(it.label, rcHtml),
                  "right": it.align == alRight or (it.align == alAuto and t.data[it.name].isNumeric)}),
                "rows": newJArray()}
    for g in b.groups:
      for r in g.rows:
        let shown = (if t.hasStub: @[r.stub] else: @[]) & r.cells
        result["rows"].add %*{
          "raw": cols.mapIt(%(let v = t.data[it.name, r.index]; if v.isNumber: %v.toFloat else: %($v))),
          "html": shown,
          "css": cols.mapIt(b.styles.getOrDefault(cellKey(r.index, it.name), ""))}

  let data = gridData(numeri)
  echo data["rows"].len, " rows, ", ($data).len div 1024, " kB of JSON"

let gridJs = """
(function () {
  const d = JSON.parse(document.getElementById('tabellone-data').textContent);
  const root = document.getElementById('tabellone');
  const H = 30, VIEW = 20;
  root.innerHTML = `<div class="tb-title">${d.title}</div><div class="tb-sub">${d.subtitle}</div>
    <input class="tb-find" placeholder="filter: type part of any cell">
    <div class="tb-scroll"><div class="tb-head"></div><div class="tb-body" style="height:${H * VIEW}px"><div class="tb-space"></div></div></div>
    <div class="tb-foot"></div>`;
  const head = root.querySelector('.tb-head'), body = root.querySelector('.tb-body'),
        space = root.querySelector('.tb-space'), foot = root.querySelector('.tb-foot'),
        find = root.querySelector('.tb-find');
  const n = d.columns.length, tpl = `minmax(4rem, 1fr) repeat(${n - 1}, minmax(7rem, 1fr))`;
  head.style.gridTemplateColumns = tpl;
  d.rows.forEach(r => r.text = r.html.map(h => h.replace(/<[^>]*>/g, '')).join(' ').toLowerCase());
  let shown = d.rows, sortCol = -1, sortDir = 1;
  head.innerHTML = d.columns.map((c, i) =>
    `<div class="tb-h${c.right ? ' r' : ''}" data-i="${i}">${c.label}<span></span></div>`).join('');
  head.onclick = e => {
    const h = e.target.closest('.tb-h'); if (!h) return;
    const i = +h.dataset.i; sortDir = (i === sortCol) ? -sortDir : 1; sortCol = i;
    head.querySelectorAll('span').forEach((s, k) => s.textContent = k === i ? (sortDir > 0 ? ' ▲' : ' ▼') : '');
    apply();
  };
  find.oninput = apply;
  function apply() {
    const q = find.value.trim().toLowerCase();
    shown = q ? d.rows.filter(r => r.text.includes(q)) : d.rows.slice();
    if (sortCol >= 0) shown.sort((a, b) => {
      const x = a.raw[sortCol], y = b.raw[sortCol];
      return (x < y ? -1 : x > y ? 1 : 0) * sortDir;
    });
    space.style.height = shown.length * H + 'px';
    body.scrollTop = 0; draw();
  }
  function draw() {
    const first = Math.floor(body.scrollTop / H), last = Math.min(shown.length, first + VIEW + 2);
    let html = '';
    for (let k = first; k < last; k++) {
      const r = shown[k];
      html += `<div class="tb-row" style="top:${k * H}px;grid-template-columns:${tpl}">` +
        r.html.map((h, i) => `<div class="tb-c${d.columns[i].right ? ' r' : ''}${i === 0 ? ' stub' : ''}" style="${r.css[i]}">${h}</div>`).join('') + '</div>';
    }
    space.innerHTML = html;
    foot.innerHTML = `<b>${shown.length.toLocaleString()}</b> of ${d.rows.length.toLocaleString()} rows · ` +
      `${last - first} drawn now · ` + d.notes.join(' ');
  }
  body.onscroll = () => requestAnimationFrame(draw);
  apply();
})();
"""

let gridCss = """
#tabellone { font-family: var(--text, system-ui); background: #fff; border: 2px solid var(--ink, #23395b);
  border-radius: 6px; padding: .8rem; box-shadow: 3px 3px 0 rgba(35,57,91,.15); max-width: 100%; }
#tabellone .tb-title { font: 1.5rem var(--hand, cursive); text-align: center; }
#tabellone .tb-sub { text-align: center; color: #666; font-size: .9rem; margin-bottom: .6rem; }
#tabellone .tb-find { width: 100%; box-sizing: border-box; font: inherit; padding: .4rem .6rem; margin-bottom: .5rem;
  border: 1px solid #bbb; border-radius: 4px; }
#tabellone .tb-head { display: grid; border-bottom: 2px solid #333; font-weight: 600; font-size: .85rem; }
#tabellone .tb-h { padding: .35rem .5rem; cursor: pointer; user-select: none; white-space: nowrap; }
#tabellone .tb-h:hover { background: #FFF3B0; }
#tabellone .tb-scroll { overflow-x: auto; }
#tabellone .tb-head, #tabellone .tb-body { min-width: 39rem; }
#tabellone .tb-body { overflow-y: auto; position: relative; }
#tabellone .tb-space { position: relative; }
#tabellone .tb-row { position: absolute; left: 0; right: 0; height: 30px; display: grid; border-bottom: 1px solid #eee; }
#tabellone .tb-c { padding: 0 .5rem; line-height: 30px; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }
#tabellone .r { text-align: right; font-variant-numeric: tabular-nums; }
#tabellone .stub { font-weight: 600; border-right: 1px solid #ccc; }
#tabellone .tb-foot { font-size: .8rem; color: #555; padding-top: .5rem; border-top: 2px solid #333; }
"""

nbRawHtml: "<style>" & gridCss & "</style><div id=\"tabellone\"></div>" &
  "<script type=\"application/json\" id=\"tabellone-data\">" & ($data).replace("</", "<\\/") & "</script>" &
  "<script>" & gridJs & "</script>"

nbText: """
What the sketch already shows: the formats, the `dataColor` fills and the stub come from
tabelline unchanged, sorting uses the raw values (so 10 sorts after 9, and `MMM` is not compared
as text), and the browser holds 3,999 rows but draws twenty. What it does not do yet: column
groups (spanners), row groups, footnotes, resizing, keyboard navigation, accessibility (a real
grid needs ARIA roles), and anything past a few tens of thousands of rows, because every row is
formatted into the page; that is where the row models, and option D, come in.

## Next

The proposal goes in the backlog as **tabellone**, to become an OpenSpec change when it is
picked up: a first scope of `toGrid` and `nbGrid` with virtual rows, sort, filter, sticky header
and stub, spanners as column groups, and the header and footer of the table around the grid.
"""

nbSave
