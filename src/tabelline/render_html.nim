## Rendering to HTML: one `<div>` holding a `<table>`, styled by `tabellaCss`, one stylesheet for
## every table, with the options the table changes as CSS variables on the `<div>`. (gt and Great
## Tables write a `<style>` per table, scoped to its id.) The parts follow gt's layout: the heading and the column labels in `<thead>`,
## the row groups, stub and body in `<tbody>`, footnotes and source notes in `<tfoot>`.
## Class names start with `tb_` (gt uses `gt_`).

import std/[strutils, strformat, sequtils, tables, hashes]
import core, formats, build, colors, verbs

func alignClass(a: Align): string =
  case a
  of alLeft, alAuto: "tb_left"
  of alCenter: "tb_center"
  of alRight: "tb_right"

func styleAttr(b: Built, key: string): string =
  let css = b.styles.getOrDefault(key)
  if css.len == 0: "" else: " style=\"" & css.replace("\"", "'") & "\""

const nanoplotCss* = """
[i] .tb_nanoplot text { font-family: ui-monospace, 'Cascadia Code', 'Source Code Pro', Menlo, Consolas, 'DejaVu Sans Mono', monospace; stroke-width: 0.15em; paint-order: stroke; stroke-linejoin: round; cursor: default; }
[i] .tb_nanoplot .vert-line:hover rect { fill: var(--tb-guide); fill-opacity: 40%; stroke: #FFFFFF60; }
[i] .tb_nanoplot .vert-line:hover text, [i] .tb_nanoplot .horizontal-line:hover text, [i] .tb_nanoplot .ref-line:hover text, [i] .tb_nanoplot .boxplot-line:hover text { stroke: white; fill: #212427; }
[i] .tb_nanoplot .ref-line:hover rect { stroke: #FFFFFF60; }
[i] .tb_nanoplot .ref-line:hover line { stroke: #FF0000; }
[i] .tb_nanoplot .y-axis-line:hover rect { fill: #EDEDED; fill-opacity: 60%; stroke: #FFFFFF60; }
[i] .tb_nanoplot .y-axis-line:hover text { stroke: white; stroke-width: 0.20em; fill: #1A1C1F; }
[i] .tb_nanoplot_static .vert-line text, [i] .tb_nanoplot_static .horizontal-line text, [i] .tb_nanoplot_static .ref-line text, [i] .tb_nanoplot_static .boxplot-line text { stroke: white; fill: #212427; }
[i] .tb_nanoplot_static .y-axis-line rect { fill: #EDEDED; fill-opacity: 60%; }
[i] .tb_nanoplot_static .y-axis-line text { stroke: white; stroke-width: 0.20em; fill: #1A1C1F; }
"""
  ## The rules that show the values on hover (or always, without `interactiveDataValues`), with
  ## `[i]` for the table: they are part of `tabellaCss`.

const scope = ":where(.tabella):not(#_)"
  ## Every rule of `tabellaCss` starts with it: it matches every table and weighs what an id
  ## weighs (`:not(#_)` counts as an id, `:where` counts nothing), as `#id` did before 0.2, so a
  ## page's theme wins or loses against a table's rule as it did then.

func kebab(name: string): string =
  ## `tableFontSize` is `table-font-size`.
  for c in name:
    if c.isUpperAscii: result.add '-'; result.add c.toLowerAscii
    else: result.add c

proc stringOptions(o: TabOptions): seq[(string, string)] =
  ## The options that are strings, as (name, value). `fieldPairs` unrolls its body once per field
  ## (there are about 160): written once here, so the other procs loop over this list instead of
  ## unrolling their own copy (four copies made 8.6 MB of C that took 40 s to compile).
  result = newSeqOfCap[(string, string)](200)
  for name, value in fieldPairs(o):
    when value is string: result.add (name, value)

proc optionDefaults(): Table[string, string] =
  for (name, value) in stringOptions(TabOptions()): result[name] = value

let defaults = optionDefaults()

proc buildTabellaCss(): (string, seq[string]) =
  ## The stylesheet of every table, and the options it reads.
  var used: seq[string]
  proc v(name: string, fallback = ""): string =
    ## The value of an option: its variable, falling back to its default (or `fallback`, when
    ## the default is "" and means "the same as another option").
    if name notin used: used.add name
    let d = defaults[name]
    "var(--tb-" & kebab(name) & ", " & (if d.len > 0: d else: fallback) & ")"
  proc w(name, fallback: string): string =
    ## A value tabelline works out from the options (it has no option of its own).
    "var(--tb-" & name & ", " & fallback & ")"
  let i = scope
  var css = fmt("""
[i] { overflow-x: [v("containerOverflowX")]; overflow-y: [v("containerOverflowY")]; width: [v("containerWidth")];
  height: [v("containerHeight")]; padding: [v("containerPaddingY")] [v("containerPaddingX")]; }
[i] table, [i] thead, [i] tbody, [i] tfoot, [i] tr, [i] td, [i] th { border-style: none; }
[i] .tb_table { display: table; border-collapse: collapse; line-height: normal;
  margin-left: [v("tableMarginLeft")]; margin-right: [v("tableMarginRight")]; width: [v("tableWidth")];
  color: [v("tableFontColor")]; font-family: [v("tableFontNames")]; font-size: [v("tableFontSize")];
  background-color: [v("tableBackgroundColor")]; table-layout: [v("tableLayout")];
  font-weight: [v("tableFontWeight")]; font-style: [v("tableFontStyle")];
  border-top: [v("tableBorderTopWidth")] [v("tableBorderTopStyle")] [v("tableBorderTopColor")];
  border-bottom: [v("tableBorderBottomWidth")] [v("tableBorderBottomStyle")] [v("tableBorderBottomColor")];
  border-left: [v("tableBorderLeftWidth")] [v("tableBorderLeftStyle")] [v("tableBorderLeftColor")];
  border-right: [v("tableBorderRightWidth")] [v("tableBorderRightStyle")] [v("tableBorderRightColor")]; }
[i] .tb_caption { caption-side: top; padding: 4px 5px; color: [v("tableFontColor")]; font-style: italic; }
[i] .tb_heading { background-color: [v("headingBackgroundColor", v("tableBackgroundColor"))]; text-align: [v("headingAlign")]; color: [w("heading-color", v("tableFontColor"))]; }
[i] .tb_heading th { border-left: [v("headingBorderLrWidth")] [v("headingBorderLrStyle")] [v("headingBorderLrColor")];
  border-right: [v("headingBorderLrWidth")] [v("headingBorderLrStyle")] [v("headingBorderLrColor")]; }
[i] .tb_title { font-size: [v("headingTitleFontSize")]; font-weight: [v("headingTitleFontWeight")];
  padding: [v("headingPadding")] [v("headingPaddingHorizontal")]; }
[i] .tb_subtitle { font-size: [v("headingSubtitleFontSize")]; font-weight: [v("headingSubtitleFontWeight")]; padding: 0 [v("headingPaddingHorizontal")] [v("headingPadding")] [v("headingPaddingHorizontal")]; }
[i] .tb_heading_last { border-bottom: [v("headingBorderBottomWidth")] [v("headingBorderBottomStyle")] [v("headingBorderBottomColor")]; }
[i] .tb_col_headings th { background-color: [v("columnLabelsBackgroundColor", v("tableBackgroundColor"))]; color: [w("column-labels-color", v("tableFontColor"))];
  font-size: [v("columnLabelsFontSize")]; font-weight: [v("columnLabelsFontWeight")];
  text-transform: [v("columnLabelsTextTransform")]; vertical-align: bottom;
  padding: [v("columnLabelsPadding")] [v("columnLabelsPaddingHorizontal")]; overflow-x: hidden; }
[i] .tb_col_headings_last th { border-bottom: [v("columnLabelsBorderBottomWidth")] [v("columnLabelsBorderBottomStyle")] [v("columnLabelsBorderBottomColor")]; }
[i] .tb_heading + .tb_col_headings th, [i] thead > .tb_col_headings:first-child th {
  border-top: [v("columnLabelsBorderTopWidth")] [v("columnLabelsBorderTopStyle")] [v("columnLabelsBorderTopColor")]; }
[i] .tb_col_headings th:first-child { border-left: [v("columnLabelsBorderLrWidth")] [v("columnLabelsBorderLrStyle")] [v("columnLabelsBorderLrColor")]; }
[i] .tb_col_headings th:last-child { border-right: [v("columnLabelsBorderLrWidth")] [v("columnLabelsBorderLrStyle")] [v("columnLabelsBorderLrColor")]; }
[i] .tb_col_headings th + th { border-left: [v("columnLabelsVlinesWidth")] [v("columnLabelsVlinesStyle")] [v("columnLabelsVlinesColor")]; }
[i] .tb_spanner { display: inline-block; width: 100%; padding-bottom: 4px;
  border-bottom: 2px solid [v("columnLabelsBorderBottomColor")]; }
[i] .tb_spanner_empty { border-bottom: none; }
[i] .tb_group_heading { background-color: [v("rowGroupBackgroundColor", v("tableBackgroundColor"))]; font-weight: [v("rowGroupFontWeight")];
  font-size: [v("rowGroupFontSize")]; text-transform: [v("rowGroupTextTransform")];
  padding: [v("rowGroupPadding")] [v("rowGroupPaddingHorizontal")]; text-align: left;
  border-top: [v("rowGroupBorderTopWidth")] [v("rowGroupBorderTopStyle")] [v("rowGroupBorderTopColor", v("rowGroupBorderColor"))];
  border-bottom: [v("rowGroupBorderBottomWidth")] [v("rowGroupBorderBottomStyle")] [v("rowGroupBorderBottomColor", v("rowGroupBorderColor"))];
  border-left: [v("rowGroupBorderLeftWidth")] [v("rowGroupBorderLeftStyle")] [v("rowGroupBorderLeftColor")];
  border-right: [v("rowGroupBorderRightWidth")] [v("rowGroupBorderRightStyle")] [v("rowGroupBorderRightColor")]; }
[i] .tb_row { padding: [v("dataRowPadding")] [v("dataRowPaddingHorizontal")]; margin: 10px;
  border-top: [v("tableBodyHlinesWidth")] [v("tableBodyHlinesStyle")] [v("tableBodyHlinesColor")]; vertical-align: middle; overflow-x: hidden; }
[i] tbody { border-top: [v("tableBodyBorderTopWidth")] [v("tableBodyBorderTopStyle")] [v("tableBodyBorderTopColor")];
  border-bottom: [v("tableBodyBorderBottomWidth")] [v("tableBodyBorderBottomStyle")] [v("tableBodyBorderBottomColor")]; }
[i] .tb_stub { background-color: [v("stubBackgroundColor", "transparent")]; font-weight: [v("stubFontWeight")]; text-align: left;
  font-size: [v("stubFontSize")]; text-transform: [v("stubTextTransform")];
  border-right: [v("stubBorderWidth")] [v("stubBorderStyle")] [v("stubBorderColor", v("tableBodyHlinesColor"))]; }
[i] tbody tr:first-child .tb_row { border-top: none; }
[i] .tb_indent_1 { text-indent: [v("stubIndentLength")]; } [i] .tb_indent_2 { text-indent: calc(2 * [v("stubIndentLength")]); }
[i] .tb_indent_3 { text-indent: calc(3 * [v("stubIndentLength")]); } [i] .tb_indent_4 { text-indent: calc(4 * [v("stubIndentLength")]); }
[i] .tb_indent_5 { text-indent: calc(5 * [v("stubIndentLength")]); }
[i] .tb_stub.tb_stub_level { border-right: none; vertical-align: top; }
[i] .tb_stub_row_group { font-size: [v("stubRowGroupFontSize")]; font-weight: [v("stubRowGroupFontWeight")];
  text-transform: [v("stubRowGroupTextTransform")]; vertical-align: top;
  border-right: [v("stubRowGroupBorderWidth")] [v("stubRowGroupBorderStyle")] [v("stubRowGroupBorderColor")]; }
[i] .tb_no_data { color: [v("tableFontColor")]; font-style: italic; }
[i] sup, [i] sub { line-height: 0; }
[i] .tb_supsub { display: inline-flex; flex-direction: column; font-size: 70%; line-height: 1.05;
  vertical-align: -0.4em; text-align: left; }
[i] .tb_supsub sup, [i] .tb_supsub sub { font-size: inherit; vertical-align: baseline; line-height: inherit; }
[i] .tb_frac { white-space: nowrap; } [i] .tb_frac sup, [i] .tb_frac sub { font-size: 70%; }
[i] .tb_striped { background-color: [v("rowStripingBackgroundColor")]; }
[i] .tb_summary_row { background-color: [v("summaryRowBackgroundColor", "transparent")]; text-transform: [v("summaryRowTextTransform")];
  padding: [v("summaryRowPadding")] [v("summaryRowPaddingHorizontal")]; vertical-align: middle; }
[i] .tb_first_summary_row { border-top: [v("summaryRowBorderWidth")] [v("summaryRowBorderStyle")] [v("summaryRowBorderColor")]; }
[i] .tb_last_summary_row_top { border-bottom: [v("summaryRowBorderWidth")] [v("summaryRowBorderStyle")] [v("summaryRowBorderColor")]; }
[i] .tb_grand_summary_row { background-color: [v("grandSummaryRowBackgroundColor", "transparent")]; text-transform: [v("grandSummaryRowTextTransform")];
  padding: [v("grandSummaryRowPadding")] [v("grandSummaryRowPaddingHorizontal")]; vertical-align: middle; }
[i] .tb_first_grand_summary_row { border-top: [v("grandSummaryRowBorderWidth")] [v("grandSummaryRowBorderStyle")] [v("grandSummaryRowBorderColor")]; }
[i] .tb_last_grand_summary_row_top { border-bottom: [v("grandSummaryRowBorderWidth")] [v("grandSummaryRowBorderStyle")] [v("grandSummaryRowBorderColor")]; }
[i] .tb_left { text-align: left; } [i] .tb_center { text-align: center; } [i] .tb_right { text-align: right; font-variant-numeric: tabular-nums; }
[i] .tb_footnotes { color: [v("tableFontColor")]; background-color: [v("footnotesBackgroundColor", v("tableBackgroundColor"))]; }
[i] .tb_sourcenotes { color: [v("tableFontColor")]; background-color: [v("sourceNotesBackgroundColor", v("tableBackgroundColor"))]; }
[i] .tb_footnote { font-size: [v("footnotesFontSize")]; padding: [v("footnotesPadding")] [v("footnotesPaddingHorizontal")]; text-align: left;
  border-left: [v("footnotesBorderLrWidth")] [v("footnotesBorderLrStyle")] [v("footnotesBorderLrColor")];
  border-right: [v("footnotesBorderLrWidth")] [v("footnotesBorderLrStyle")] [v("footnotesBorderLrColor")]; }
[i] .tb_footnotes:not(:has(+ .tb_footnotes)) .tb_footnote { border-bottom: [v("footnotesBorderBottomWidth")] [v("footnotesBorderBottomStyle")] [v("footnotesBorderBottomColor")]; }
[i] .tb_sourcenote { font-size: [v("sourceNotesFontSize")]; padding: [v("sourceNotesPadding")] [v("sourceNotesPaddingHorizontal")]; text-align: left;
  border-left: [v("sourceNotesBorderLrWidth")] [v("sourceNotesBorderLrStyle")] [v("sourceNotesBorderLrColor")];
  border-right: [v("sourceNotesBorderLrWidth")] [v("sourceNotesBorderLrStyle")] [v("sourceNotesBorderLrColor")]; }
[i] .tb_sourcenotes:last-child .tb_sourcenote { border-bottom: [v("sourceNotesBorderBottomWidth")] [v("sourceNotesBorderBottomStyle")] [v("sourceNotesBorderBottomColor")]; }
[i] tfoot tr:first-child td { padding-top: 8px; }
[i] .tb_footnote_marks { font-size: 75%; vertical-align: 0.4em; font-weight: normal; font-style: normal; }
""", '[', ']')
  css.add nanoplotCss.replace("[i]", i)
  (css, used)

let (tabellaCssValue, cssOptions) = buildTabellaCss()

proc themedDefaults(): Table[string, string] =
  ## The options as `optCssTheme()` leaves them, on a table with the default options.
  for (name, value) in stringOptions(Tabella().optCssTheme().options): result[name] = value

let themed = themedDefaults()

proc isThemed(o: TabOptions): bool =
  ## Whether the table takes the page's theme with `optCssTheme()` (its default arguments): every
  ## option that the theme points to a page's variable still does.
  for (name, value) in stringOptions(o):
    if name in cssOptions and "var(--" in themed[name] and value != themed[name]: return false
  true

proc themeRule(): string =
  ## The variables of `optCssTheme()`, once for every table that takes it (class `tb_css_theme`),
  ## instead of on each table.
  var parts: seq[string]
  for name in cssOptions:
    if themed[name] != defaults[name]: parts.add "--tb-" & kebab(name) & ": " & themed[name]
  ":where(.tabella.tb_css_theme) { " & parts.join("; ") & "; }\n"

let tabellaCss* = tabellaCssValue & themeRule()
  ## The CSS of every table, the same for all of them: each value is a CSS variable named after
  ## its option (`--tb-table-font-size` for `tableFontSize`), falling back to the default. A
  ## table sets the variables of the options it changes on its `<div>` (`toHtml`); a page can
  ## set one for all its tables (`.tabella { --tb-table-font-size: 14px }`). A table that takes
  ## the page's theme (`optCssTheme()`) gets the class `tb_css_theme`, whose rule here sets the
  ## theme's variables once for all of them.

let tabellaStyle* = "<style>\n" & tabellaCss & "</style>"
  ## `tabellaCss` in a `<style>` element, as `toHtml` writes it.

proc styleVars*(o: TabOptions): string =
  ## The variables of the options `o` changes, for the `style` of the table's `<div>`: changed
  ## from the defaults, or from `optCssTheme()` for a table that takes it (`isThemed`).
  let base = if o.isThemed: themed else: defaults
  var parts: seq[string]
  for (name, value) in stringOptions(o):
    if name in cssOptions and value != base[name]:
      parts.add "--tb-" & kebab(name) & ": " & value
  func onDark(bg: string): bool =
    ## A background that white text reads better on (by contrast, not by one channel): a hex
    ## value or a CSS colour name; anything else (a `var(--x)`, `transparent`) is left alone.
    try: idealTextColor(bg) == "#FFFFFF" except ValueError: false
  if onDark(o.headingBackgroundColor): parts.add "--tb-heading-color: " & o.tableFontColorLight
  if onDark(o.columnLabelsBackgroundColor): parts.add "--tb-column-labels-color: " & o.tableFontColorLight
  # where the table sits, unless its margins are given
  if o.tableAlign == "left" and o.tableMarginLeft == "auto": parts.add "--tb-table-margin-left: 0"
  if o.tableAlign == "right" and o.tableMarginRight == "auto": parts.add "--tb-table-margin-right: 0"
  if not o.stubSeparate: parts.add "--tb-stub-border-style: none"
  parts.join("; ").replace("\"", "'")

proc ownCss(id: string, o: TabOptions): string =
  ## The rules of one table only, scoped to its id: the vertical lines (a rule that must come
  ## after the others, and only when there are lines) and `optCss` (scoped unless a rule already
  ## names an id).
  let i = "#" & id
  if o.tableBodyVlinesColor.len > 0:
    let line = o.tableBodyVlinesWidth & " " & o.tableBodyVlinesStyle & " " & o.tableBodyVlinesColor
    result.add i & " .tb_row, " & i & " .tb_col_headings th { border-left: " & line & "; border-right: " & line & "; }\n"
  let extra = [o.extraCss, o.tableAdditionalCss].filterIt(it.strip.len > 0).join("\n")
  if extra.len == 0: return
  for rule in extra.split('}'):
    let r = rule.strip
    if r.len == 0: continue
    let parts = r.split('{', 1)
    if parts.len < 2: continue
    let sels = parts[0].split(',').mapIt(it.strip).mapIt(if it.startsWith("#"): it else: i & " " & it)
    result.add sels.join(", ") & " { " & parts[1].strip & " }\n"

proc bodyHtml(t: Tabella, b: Built): string =
  let ncols = b.columns.len + t.stubWidth
  let m = t.options
  let asColumn = t.groupAsColumn
  let stubSpan = 1 + t.stubCols.len     # the stub's columns, without the group column
  var striped = false
  var groupCell = ""                    # the group's label, still to be drawn (as a column)
  proc takeGroupCell(): string =
    result = groupCell
    groupCell = ""
  proc summaryHtml(ss: seq[BuiltSummary], grand, top: bool): string =
    # summary rows: a rule above the first (below the last, when they come first)
    let kind = if grand: "tb_grand_summary_row" else: "tb_summary_row"
    let span = if grand: t.stubWidth else: stubSpan
    let cs = if span > 1: &" colspan=\"{span}\"" else: ""
    for k, s in ss:
      var cls = kind
      if not top and k == 0: cls.add(if grand: " tb_first_grand_summary_row" else: " tb_first_summary_row")
      if top and k == ss.high: cls.add(if grand: " tb_last_grand_summary_row_top" else: " tb_last_summary_row_top")
      result.add &"""<tr class="{kind}_tr">"""
      if not grand: result.add takeGroupCell()
      result.add &"""<th scope="row"{cs} class="tb_stub tb_left {cls}"{b.styleAttr(s.key)}>{s.label}{b.marksHtml(s.key, m)}</th>"""
      for j, c in b.columns:
        let key = s.key & c.name
        result.add &"""<td class="{alignClass(c.align)} {cls}"{b.styleAttr(key)}>{s.cells[j]}{b.marksHtml(key, m)}</td>"""
      result.add "</tr>\n"
  result.add "<tbody class=\"tb_table_body\">\n"
  result.add summaryHtml(b.grandTop, true, true)
  var shown = 0
  for g in b.groups:
    let gk = groupKey(g.id)
    if asColumn:
      let n = g.summaryTop.len + g.rows.len + g.summaryBottom.len
      let rs = if n > 1: &" rowspan=\"{n}\"" else: ""
      groupCell = &"""<th scope="rowgroup"{rs} class="tb_row tb_left tb_stub_row_group" id="{escapeHtml(g.id)}"{b.styleAttr(gk)}>{g.label}{b.marksHtml(gk, m)}</th>"""
    elif g.id.len > 0 or g.label.len > 0:
      result.add &"""<tr class="tb_group_heading_row"><th colspan="{ncols}" class="tb_group_heading" scope="colgroup" id="{escapeHtml(g.id)}"{b.styleAttr(gk)}>{g.label}{b.marksHtml(gk, m)}</th></tr>""" & "\n"
    striped = false
    result.add summaryHtml(g.summaryTop, false, true)
    for r in g.rows:
      inc shown
      result.add "<tr>"
      result.add takeGroupCell()
      let on = m.rowStriping and striped
      let stripe = if on and m.rowStripingIncludeTableBody: " tb_striped" else: ""
      let stubStripe = if on and m.rowStripingIncludeStub: " tb_striped" else: ""
      for k, c in t.stubCols:
        if r.spans[k] == 0: continue
        let key = cellKey(r.index, c)
        let rs = if r.spans[k] > 1: &" rowspan=\"{r.spans[k]}\"" else: ""
        result.add &"""<th scope="rowgroup"{rs} class="tb_row tb_left tb_stub tb_stub_level"{b.styleAttr(key)}>{r.levels[k]}{b.marksHtml(key, m)}</th>"""
      if t.hasStub:
        let k = cellKey(r.index, t.rownameCol)
        let indent = if r.indent > 0: &" tb_indent_{r.indent}" else: ""
        result.add &"""<th scope="row" class="tb_row tb_left tb_stub{indent}{stubStripe}"{b.styleAttr(k)}>{r.stub}{b.marksHtml(k, m)}</th>"""
      for j, c in b.columns:
        let k = cellKey(r.index, c.name)
        result.add &"""<td class="tb_row {alignClass(c.align)}{stripe}"{b.styleAttr(k)}>{r.cells[j]}{b.marksHtml(k, m)}</td>"""
      result.add "</tr>\n"
      striped = not striped
    result.add summaryHtml(g.summaryBottom, false, false)
  if shown == 0 and b.grandTop.len == 0 and b.grandBottom.len == 0:
    result.add &"""<tr><td colspan="{max(ncols, 1)}" class="tb_row tb_center tb_no_data">{escapeHtml(m.tableNoDataMessage)}</td></tr>""" & "\n"
  result.add summaryHtml(b.grandBottom, true, false)
  result.add "</tbody>\n"

proc columnLabelsHtml(t: Tabella, b: Built): string =
  if t.options.columnLabelsHidden: return ""
  let levels = t.spannerLevels(b.columns)
  let m = t.options
  let sw = t.stubWidth
  let cs = if sw > 1: &" colspan=\"{sw}\"" else: ""
  func hasAnySpanner(c: ColInfo): bool =
    for lv in 1 .. levels:
      if t.spannerAt(c.name, lv) >= 0: return true
  proc labelCell(c: ColInfo, rowspan: int): string =
    let rs = if rowspan > 1: &" rowspan=\"{rowspan}\"" else: ""
    let w = if c.width.len > 0: &" width=\"{c.width}\"" else: ""
    &"""<th class="tb_col_heading {alignClass(c.align)}" scope="col" id="{escapeHtml(c.name)}"{rs}{w}{b.styleAttr(colKey(c.name))}>{c.columnLabel(rcHtml, m.columnLabelsUnitsPattern)}{b.marksHtml(colKey(c.name), m)}</th>"""
  for lv in countdown(levels, 1):
    let last = lv == 1 and false
    result.add "<tr class=\"tb_col_headings tb_spanner_row" & (if last: " tb_col_headings_last" else: "") & "\">"
    if lv == levels and sw > 0:
      result.add &"""<th class="tb_col_heading tb_left tb_stubhead"{cs} rowspan="{levels + 1}" scope="col"{b.styleAttr("stubhead")}>{t.stubhead.renderLabel(rcHtml)}{b.marksHtml("stubhead", m)}</th>"""
    var j = 0
    while j < b.columns.len:
      let c = b.columns[j]
      if not c.hasAnySpanner:
        if lv == levels: result.add labelCell(c, levels + 1)
        inc j
        continue
      let k = t.spannerAt(c.name, lv)
      var span = 1
      while j + span < b.columns.len and t.spannerAt(b.columns[j + span].name, lv) == k and
            (k >= 0 or b.columns[j + span].hasAnySpanner):
        inc span
      if k >= 0:
        let s = t.spanners[k]
        let key = spannerKey(s.label.s)
        result.add &"""<th class="tb_center tb_spanner_col" colspan="{span}" scope="colgroup"><span class="tb_spanner"{b.styleAttr(key)}>{s.label.renderLabel(rcHtml)}{b.marksHtml(key, m)}</span></th>"""
      else:
        result.add &"""<th class="tb_spanner_col" colspan="{span}"></th>"""
      j += span
    result.add "</tr>\n"
  result.add "<tr class=\"tb_col_headings tb_col_headings_last\">"
  if levels == 0 and sw > 0:
    result.add &"""<th class="tb_col_heading tb_left tb_stubhead"{cs} scope="col"{b.styleAttr("stubhead")}>{t.stubhead.renderLabel(rcHtml)}{b.marksHtml("stubhead", m)}</th>"""
  for c in b.columns:
    if levels == 0 or c.hasAnySpanner: result.add labelCell(c, 1)
  result.add "</tr>\n"

proc tableHtml(t: Tabella, withStyle: bool): string =
  ## The table as an HTML fragment: a `<div>`, `tabellaCss` when `withStyle`, the table's own
  ## rules if it has any, and the `<table>`.
  let b = t.build(rcHtml)
  let m = t.options
  let ncols = max(1, b.columns.len + t.stubWidth)
  var head = ""
  if not t.title.isEmpty:
    let last = if t.subtitle.isEmpty: " tb_heading_last" else: ""
    head.add &"""<tr class="tb_heading"><th colspan="{ncols}" class="tb_title{last}"{b.styleAttr("title")}>{t.title.renderText(rcHtml)}{b.marksHtml("title", m)}</th></tr>""" & "\n"
    if not t.subtitle.isEmpty:
      head.add &"""<tr class="tb_heading"><th colspan="{ncols}" class="tb_subtitle tb_heading_last"{b.styleAttr("subtitle")}>{t.subtitle.renderText(rcHtml)}{b.marksHtml("subtitle", m)}</th></tr>""" & "\n"
  let labels = t.columnLabelsHtml(b)
  let body = t.bodyHtml(b)
  var foot = ""
  if b.notes.len > 0 or b.plainNotes.len > 0 or t.sourceNotes.len > 0:
    # one <tfoot>: footnotes first, then source notes, as in gt
    foot.add "<tfoot>\n"
    let notes = b.footer.mapIt((if it[0] > 0: footMarkHtml(it[0], m) & " " else: "") & it[1])
    proc footRows(items: seq[string], multiline: bool, sep, row, cell, key: string) =
      # one row per note, or all of them in one row (`footnotesMultiline = false`)
      let lines = if multiline or items.len == 0: items else: @[items.join(escapeHtml(sep))]
      for n in lines:
        foot.add &"""<tr class="{row}"><td class="{cell}" colspan="{ncols}"{b.styleAttr(key)}>{n}</td></tr>""" & "\n"
    footRows(notes, m.footnotesMultiline, m.footnotesSep, "tb_footnotes", "tb_footnote", "footnotes")
    footRows(t.sourceNotes.mapIt(it.renderText(rcHtml)), m.sourceNotesMultiline, m.sourceNotesSep,
             "tb_sourcenotes", "tb_sourcenote", "source_notes")
    foot.add "</tfoot>\n"
  let caption = if t.caption.isEmpty: ""
                else: &"""<caption class="tb_caption">{t.caption.renderText(rcHtml)}</caption>""" & "\n"
  # a stable id: the same table always gets the same id, so built pages do not churn
  let id = if t.id.len > 0: t.id
           else: "tabella-" & toHex(hash(caption & head & labels & body & foot & $t.options), 8).toLowerAscii
  let aria = if t.title.isEmpty: "" else: &" aria-labelledby=\"{id}-title\""
  head = head.replace("class=\"tb_title", &"id=\"{id}-title\" class=\"tb_title")
  let vars = styleVars(t.options)
  let style = if vars.len > 0: &" style=\"{vars}\"" else: ""
  let cls = if t.options.isThemed: "tabella tb_css_theme" else: "tabella"
  var css = ""
  if withStyle: css.add tabellaStyle & "\n"
  let own = ownCss(id, t.options)
  if own.len > 0: css.add "<style>\n" & own & "</style>\n"
  &"""<div id="{id}" class="{cls}"{style}>
{css}<table class="tb_table"{aria}>
{caption}<thead>
{head}{labels}</thead>
{body}{foot}</table>
</div>"""

proc toHtml*(t: Tabella, makePage = false, withStyle = true): string =
  ## The table as an HTML fragment (a `<div>` holding the `<table>`), ready to put in a page.
  ## With `withStyle = true` the fragment starts with `tabellaCss` in a `<style>`, so it works
  ## alone; with `false` it leaves it out, for a page that writes `tabellaCss` once for all its
  ## tables (`nbTable` does). With `makePage = true`, a whole standalone page holding it, titled
  ## after the table, as Great Tables' `as_raw_html(make_page = True)`.
  let html = t.tableHtml(withStyle or makePage)
  if not makePage: return html
  let tt = if not t.title.isEmpty: textToPlain(t.title) else: "tabella"
  &"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>{escapeHtml(tt)}</title><style>body{{margin:0;padding:24px}}</style></head>
<body>
{html}
</body></html>
"""

proc save*(t: Tabella, path: string) =
  ## Writes the table as a standalone HTML page, as gt's `gtsave("x.html")`.
  writeFile(path, t.toHtml(makePage = true))
