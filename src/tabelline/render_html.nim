## Rendering to HTML: one `<div>` with a `<style>` scoped to its id and a `<table>`, as gt and
## Great Tables do. The parts follow gt's layout: the heading and the column labels in `<thead>`,
## the row groups, stub and body in `<tbody>`, footnotes and source notes in `<tfoot>`.
## Class names start with `tb_` (gt uses `gt_`).

import std/[strutils, strformat, sequtils, tables, hashes]
import core, formats, build, colors

func alignClass(a: Align): string =
  case a
  of alLeft, alAuto: "tb_left"
  of alCenter: "tb_center"
  of alRight: "tb_right"

func styleAttr(b: Built, key: string): string =
  let css = b.styles.getOrDefault(key)
  if css.len == 0: "" else: " style=\"" & css.replace("\"", "'") & "\""

proc tableCss*(id: string, o: TabOptions): string =
  ## The table's CSS, every rule scoped to `#id`.
  let headingBg = if o.headingBackgroundColor.len > 0: o.headingBackgroundColor else: o.tableBackgroundColor
  let labelsBg = if o.columnLabelsBackgroundColor.len > 0: o.columnLabelsBackgroundColor else: o.tableBackgroundColor
  let groupBg = if o.rowGroupBackgroundColor.len > 0: o.rowGroupBackgroundColor else: o.tableBackgroundColor
  let stubBg = if o.stubBackgroundColor.len > 0: o.stubBackgroundColor else: "transparent"
  let summaryBg = if o.summaryRowBackgroundColor.len > 0: o.summaryRowBackgroundColor else: "transparent"
  let grandBg = if o.grandSummaryRowBackgroundColor.len > 0: o.grandSummaryRowBackgroundColor else: "transparent"
  let footBg = if o.footnotesBackgroundColor.len > 0: o.footnotesBackgroundColor else: o.tableBackgroundColor
  let sourceBg = if o.sourceNotesBackgroundColor.len > 0: o.sourceNotesBackgroundColor else: o.tableBackgroundColor
  let groupTop = if o.rowGroupBorderTopColor.len > 0: o.rowGroupBorderTopColor else: o.rowGroupBorderColor
  let groupBottom = if o.rowGroupBorderBottomColor.len > 0: o.rowGroupBorderBottomColor else: o.rowGroupBorderColor
  let stubBorder = if o.stubBorderColor.len > 0: o.stubBorderColor else: o.tableBodyHlinesColor
  func onDark(bg: string): bool =
    ## A background that white text reads better on (by contrast, not by one channel).
    bg.len == 7 and bg.startsWith("#") and idealTextColor(bg) == "#FFFFFF"
  let headingColor = if onDark(o.headingBackgroundColor): "#FFFFFF" else: o.tableFontColor
  let labelsColor = if onDark(o.columnLabelsBackgroundColor): "#FFFFFF" else: o.tableFontColor
  let i = "#" & id
  let vlines = if o.tableBodyVlinesColor.len == 0: ""
               else: i & " .tb_row, " & i & " .tb_col_headings th { border-left: " & o.tableBodyVlinesWidth & " " &
                     o.tableBodyVlinesStyle & " " & o.tableBodyVlinesColor & "; border-right: " &
                     o.tableBodyVlinesWidth & " " & o.tableBodyVlinesStyle & " " & o.tableBodyVlinesColor & "; }\n"
  var css = fmt("""
[i] { overflow-x: [o.containerOverflowX]; overflow-y: [o.containerOverflowY]; width: [o.containerWidth];
  height: [o.containerHeight]; padding: [o.containerPaddingY] [o.containerPaddingX]; }
[i] table, [i] thead, [i] tbody, [i] tfoot, [i] tr, [i] td, [i] th { border-style: none; }
[i] .tb_table { display: table; border-collapse: collapse; line-height: normal;
  margin-left: [o.tableMarginLeft]; margin-right: [o.tableMarginRight]; width: [o.tableWidth];
  color: [o.tableFontColor]; font-family: [o.tableFontNames]; font-size: [o.tableFontSize];
  background-color: [o.tableBackgroundColor]; table-layout: [o.tableLayout];
  font-weight: [o.tableFontWeight]; font-style: [o.tableFontStyle];
  border-top: [o.tableBorderTopWidth] [o.tableBorderTopStyle] [o.tableBorderTopColor];
  border-bottom: [o.tableBorderBottomWidth] [o.tableBorderBottomStyle] [o.tableBorderBottomColor];
  border-left: [o.tableBorderLeftWidth] [o.tableBorderLeftStyle] [o.tableBorderLeftColor];
  border-right: [o.tableBorderRightWidth] [o.tableBorderRightStyle] [o.tableBorderRightColor]; }
[i] .tb_caption { caption-side: top; padding: 4px 5px; color: [o.tableFontColor]; font-style: italic; }
[i] .tb_heading { background-color: [headingBg]; text-align: [o.headingAlign]; color: [headingColor]; }
[i] .tb_heading th { border-left: [o.headingBorderLrWidth] [o.headingBorderLrStyle] [o.headingBorderLrColor];
  border-right: [o.headingBorderLrWidth] [o.headingBorderLrStyle] [o.headingBorderLrColor]; }
[i] .tb_title { font-size: [o.headingTitleFontSize]; font-weight: [o.headingTitleFontWeight];
  padding: [o.headingPadding] [o.headingPaddingHorizontal]; }
[i] .tb_subtitle { font-size: [o.headingSubtitleFontSize]; font-weight: [o.headingSubtitleFontWeight]; padding: 0 [o.headingPaddingHorizontal] [o.headingPadding] [o.headingPaddingHorizontal]; }
[i] .tb_heading_last { border-bottom: [o.headingBorderBottomWidth] [o.headingBorderBottomStyle] [o.headingBorderBottomColor]; }
[i] .tb_col_headings th { background-color: [labelsBg]; color: [labelsColor];
  font-size: [o.columnLabelsFontSize]; font-weight: [o.columnLabelsFontWeight];
  text-transform: [o.columnLabelsTextTransform]; vertical-align: bottom;
  padding: [o.columnLabelsPadding] [o.columnLabelsPaddingHorizontal]; overflow-x: hidden; }
[i] .tb_col_headings_last th { border-bottom: [o.columnLabelsBorderBottomWidth] [o.columnLabelsBorderBottomStyle] [o.columnLabelsBorderBottomColor]; }
[i] .tb_heading + .tb_col_headings th, [i] thead > .tb_col_headings:first-child th {
  border-top: [o.columnLabelsBorderTopWidth] [o.columnLabelsBorderTopStyle] [o.columnLabelsBorderTopColor]; }
[i] .tb_col_headings th:first-child { border-left: [o.columnLabelsBorderLrWidth] [o.columnLabelsBorderLrStyle] [o.columnLabelsBorderLrColor]; }
[i] .tb_col_headings th:last-child { border-right: [o.columnLabelsBorderLrWidth] [o.columnLabelsBorderLrStyle] [o.columnLabelsBorderLrColor]; }
[i] .tb_col_headings th + th { border-left: [o.columnLabelsVlinesWidth] [o.columnLabelsVlinesStyle] [o.columnLabelsVlinesColor]; }
[i] .tb_spanner { display: inline-block; width: 100%; padding-bottom: 4px;
  border-bottom: 2px solid [o.columnLabelsBorderBottomColor]; }
[i] .tb_spanner_empty { border-bottom: none; }
[i] .tb_group_heading { background-color: [groupBg]; font-weight: [o.rowGroupFontWeight];
  font-size: [o.rowGroupFontSize]; text-transform: [o.rowGroupTextTransform];
  padding: [o.rowGroupPadding] [o.rowGroupPaddingHorizontal]; text-align: left;
  border-top: [o.rowGroupBorderTopWidth] [o.rowGroupBorderTopStyle] [groupTop];
  border-bottom: [o.rowGroupBorderBottomWidth] [o.rowGroupBorderBottomStyle] [groupBottom];
  border-left: [o.rowGroupBorderLeftWidth] [o.rowGroupBorderLeftStyle] [o.rowGroupBorderLeftColor];
  border-right: [o.rowGroupBorderRightWidth] [o.rowGroupBorderRightStyle] [o.rowGroupBorderRightColor]; }
[i] .tb_row { padding: [o.dataRowPadding] [o.dataRowPaddingHorizontal]; margin: 10px;
  border-top: [o.tableBodyHlinesWidth] [o.tableBodyHlinesStyle] [o.tableBodyHlinesColor]; vertical-align: middle; overflow-x: hidden; }
[i] tbody { border-top: [o.tableBodyBorderTopWidth] [o.tableBodyBorderTopStyle] [o.tableBodyBorderTopColor];
  border-bottom: [o.tableBodyBorderBottomWidth] [o.tableBodyBorderBottomStyle] [o.tableBodyBorderBottomColor]; }
[i] .tb_stub { background-color: [stubBg]; font-weight: [o.stubFontWeight]; text-align: left;
  font-size: [o.stubFontSize]; text-transform: [o.stubTextTransform];
  border-right: [o.stubBorderWidth] [o.stubBorderStyle] [stubBorder]; }
[i] tbody tr:first-child .tb_row { border-top: none; }
[i] .tb_indent_1 { text-indent: 1em; } [i] .tb_indent_2 { text-indent: 2em; } [i] .tb_indent_3 { text-indent: 3em; }
[i] .tb_indent_4 { text-indent: 4em; } [i] .tb_indent_5 { text-indent: 5em; }
[i] sup, [i] sub { line-height: 0; }
[i] .tb_supsub { display: inline-flex; flex-direction: column; font-size: 70%; line-height: 1.05;
  vertical-align: -0.4em; text-align: left; }
[i] .tb_supsub sup, [i] .tb_supsub sub { font-size: inherit; vertical-align: baseline; line-height: inherit; }
[i] .tb_frac { white-space: nowrap; } [i] .tb_frac sup, [i] .tb_frac sub { font-size: 70%; }
[i] .tb_striped { background-color: [o.rowStripingBackgroundColor]; }
[i] .tb_summary_row { background-color: [summaryBg]; text-transform: [o.summaryRowTextTransform];
  padding: [o.summaryRowPadding] [o.summaryRowPaddingHorizontal]; vertical-align: middle; }
[i] .tb_first_summary_row { border-top: [o.summaryRowBorderWidth] [o.summaryRowBorderStyle] [o.summaryRowBorderColor]; }
[i] .tb_last_summary_row_top { border-bottom: [o.summaryRowBorderWidth] [o.summaryRowBorderStyle] [o.summaryRowBorderColor]; }
[i] .tb_grand_summary_row { background-color: [grandBg]; text-transform: [o.grandSummaryRowTextTransform];
  padding: [o.grandSummaryRowPadding] [o.grandSummaryRowPaddingHorizontal]; vertical-align: middle; }
[i] .tb_first_grand_summary_row { border-top: [o.grandSummaryRowBorderWidth] [o.grandSummaryRowBorderStyle] [o.grandSummaryRowBorderColor]; }
[i] .tb_last_grand_summary_row_top { border-bottom: [o.grandSummaryRowBorderWidth] [o.grandSummaryRowBorderStyle] [o.grandSummaryRowBorderColor]; }
[i] .tb_left { text-align: left; } [i] .tb_center { text-align: center; } [i] .tb_right { text-align: right; font-variant-numeric: tabular-nums; }
[i] .tb_footnotes { color: [o.tableFontColor]; background-color: [footBg]; }
[i] .tb_sourcenotes { color: [o.tableFontColor]; background-color: [sourceBg]; }
[i] .tb_footnote { font-size: [o.footnotesFontSize]; padding: [o.footnotesPadding] [o.footnotesPaddingHorizontal]; text-align: left;
  border-left: [o.footnotesBorderLrWidth] [o.footnotesBorderLrStyle] [o.footnotesBorderLrColor];
  border-right: [o.footnotesBorderLrWidth] [o.footnotesBorderLrStyle] [o.footnotesBorderLrColor]; }
[i] .tb_footnotes:not(:has(+ .tb_footnotes)) .tb_footnote { border-bottom: [o.footnotesBorderBottomWidth] [o.footnotesBorderBottomStyle] [o.footnotesBorderBottomColor]; }
[i] .tb_sourcenote { font-size: [o.sourceNotesFontSize]; padding: [o.sourceNotesPadding] [o.sourceNotesPaddingHorizontal]; text-align: left;
  border-left: [o.sourceNotesBorderLrWidth] [o.sourceNotesBorderLrStyle] [o.sourceNotesBorderLrColor];
  border-right: [o.sourceNotesBorderLrWidth] [o.sourceNotesBorderLrStyle] [o.sourceNotesBorderLrColor]; }
[i] .tb_sourcenotes:last-child .tb_sourcenote { border-bottom: [o.sourceNotesBorderBottomWidth] [o.sourceNotesBorderBottomStyle] [o.sourceNotesBorderBottomColor]; }
[i] tfoot tr:first-child td { padding-top: 8px; }
[i] .tb_footnote_marks { font-size: 75%; vertical-align: 0.4em; font-weight: normal; font-style: normal; }
""", '[', ']') & vlines
  let extra = o.extraCss.strip
  if extra.len > 0:
    # scope each rule of extraCss to the table, unless it already names it
    for rule in o.extraCss.split('}'):
      let r = rule.strip
      if r.len == 0: continue
      let parts = r.split('{', 1)
      if parts.len < 2: continue
      let sels = parts[0].split(',').mapIt(it.strip).mapIt(if it.startsWith("#"): it else: i & " " & it)
      css.add sels.join(", ") & " { " & parts[1].strip & " }\n"
  css

proc bodyHtml(t: Tabella, b: Built): string =
  let ncols = b.columns.len + (if t.hasStub: 1 else: 0)
  let m = t.options
  var striped = false
  proc summaryHtml(ss: seq[BuiltSummary], grand, top: bool): string =
    # summary rows: a rule above the first (below the last, when they come first)
    let kind = if grand: "tb_grand_summary_row" else: "tb_summary_row"
    for k, s in ss:
      var cls = kind
      if not top and k == 0: cls.add(if grand: " tb_first_grand_summary_row" else: " tb_first_summary_row")
      if top and k == ss.high: cls.add(if grand: " tb_last_grand_summary_row_top" else: " tb_last_summary_row_top")
      result.add &"""<tr class="{kind}_tr">"""
      result.add &"""<th scope="row" class="tb_stub tb_left {cls}"{b.styleAttr(s.key)}>{s.label}{b.marksHtml(s.key, m)}</th>"""
      for j, c in b.columns:
        let key = s.key & c.name
        result.add &"""<td class="{alignClass(c.align)} {cls}"{b.styleAttr(key)}>{s.cells[j]}{b.marksHtml(key, m)}</td>"""
      result.add "</tr>\n"
  result.add "<tbody class=\"tb_table_body\">\n"
  result.add summaryHtml(b.grandTop, true, true)
  for g in b.groups:
    if g.id.len > 0:
      result.add &"""<tr class="tb_group_heading_row"><th colspan="{ncols}" class="tb_group_heading" scope="colgroup" id="{escapeHtml(g.id)}"{b.styleAttr(groupKey(g.id))}>{g.label}{b.marksHtml(groupKey(g.id), m)}</th></tr>""" & "\n"
    striped = false
    result.add summaryHtml(g.summaryTop, false, true)
    for r in g.rows:
      result.add "<tr>"
      let stripe = if t.options.rowStriping and striped: " tb_striped" else: ""
      if t.hasStub:
        let k = cellKey(r.index, t.rownameCol)
        let indent = if r.indent > 0: &" tb_indent_{r.indent}" else: ""
        result.add &"""<th scope="row" class="tb_row tb_left tb_stub{indent}{stripe}"{b.styleAttr(k)}>{r.stub}{b.marksHtml(k, m)}</th>"""
      for j, c in b.columns:
        let k = cellKey(r.index, c.name)
        result.add &"""<td class="tb_row {alignClass(c.align)}{stripe}"{b.styleAttr(k)}>{r.cells[j]}{b.marksHtml(k, m)}</td>"""
      result.add "</tr>\n"
      striped = not striped
    result.add summaryHtml(g.summaryBottom, false, false)
  result.add summaryHtml(b.grandBottom, true, false)
  result.add "</tbody>\n"

proc columnLabelsHtml(t: Tabella, b: Built): string =
  let levels = t.spannerLevels(b.columns)
  let m = t.options
  func hasAnySpanner(c: ColInfo): bool =
    for lv in 1 .. levels:
      if t.spannerAt(c.name, lv) >= 0: return true
  proc labelCell(c: ColInfo, rowspan: int): string =
    let rs = if rowspan > 1: &" rowspan=\"{rowspan}\"" else: ""
    let w = if c.width.len > 0: &" width=\"{c.width}\"" else: ""
    &"""<th class="tb_col_heading {alignClass(c.align)}" scope="col" id="{escapeHtml(c.name)}"{rs}{w}{b.styleAttr(colKey(c.name))}>{c.columnLabel(rcHtml)}{b.marksHtml(colKey(c.name), m)}</th>"""
  for lv in countdown(levels, 1):
    let last = lv == 1 and false
    result.add "<tr class=\"tb_col_headings tb_spanner_row" & (if last: " tb_col_headings_last" else: "") & "\">"
    if lv == levels and t.hasStub:
      result.add &"""<th class="tb_col_heading tb_left tb_stubhead" rowspan="{levels + 1}" scope="col"{b.styleAttr("stubhead")}>{t.stubhead.renderLabel(rcHtml)}{b.marksHtml("stubhead", m)}</th>"""
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
  if levels == 0 and t.hasStub:
    result.add &"""<th class="tb_col_heading tb_left tb_stubhead" scope="col"{b.styleAttr("stubhead")}>{t.stubhead.renderLabel(rcHtml)}{b.marksHtml("stubhead", m)}</th>"""
  for c in b.columns:
    if levels == 0 or c.hasAnySpanner: result.add labelCell(c, 1)
  result.add "</tr>\n"

proc tableHtml(t: Tabella): string =
  ## The table as an HTML fragment (a `<div>` with its own scoped `<style>`).
  let b = t.build(rcHtml)
  let m = t.options
  let ncols = b.columns.len + (if t.hasStub: 1 else: 0)
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
    for (k, n) in b.footer:
      let mark = if k > 0: footMarkHtml(k, m) & " " else: ""
      foot.add &"""<tr class="tb_footnotes"><td class="tb_footnote" colspan="{ncols}"{b.styleAttr("footnotes")}>{mark}{n}</td></tr>""" & "\n"
    for n in t.sourceNotes:
      foot.add &"""<tr class="tb_sourcenotes"><td class="tb_sourcenote" colspan="{ncols}"{b.styleAttr("source_notes")}>{n.renderText(rcHtml)}</td></tr>""" & "\n"
    foot.add "</tfoot>\n"
  let caption = if t.caption.isEmpty: ""
                else: &"""<caption class="tb_caption">{t.caption.renderText(rcHtml)}</caption>""" & "\n"
  # a stable id: the same table always gets the same id, so built pages do not churn
  let id = if t.id.len > 0: t.id
           else: "tabella-" & toHex(hash(caption & head & labels & body & foot & $t.options), 8).toLowerAscii
  let aria = if t.title.isEmpty: "" else: &" aria-labelledby=\"{id}-title\""
  head = head.replace("class=\"tb_title", &"id=\"{id}-title\" class=\"tb_title")
  &"""<div id="{id}" class="tabella">
<style>
{tableCss(id, t.options)}</style>
<table class="tb_table"{aria}>
{caption}<thead>
{head}{labels}</thead>
{body}{foot}</table>
</div>"""

proc toHtml*(t: Tabella, makePage = false): string =
  ## The table as an HTML fragment (a `<div>` with its own scoped `<style>`), ready to put in a
  ## page. With `makePage = true`, a whole standalone page holding it, titled after the table, as
  ## Great Tables' `as_raw_html(make_page = True)`.
  let html = t.tableHtml
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
