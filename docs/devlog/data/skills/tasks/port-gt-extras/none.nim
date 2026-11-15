## Port of table.py (Great Tables + gt-extras) to Nim with tabelline 0.2.
import std/[json, strutils, math, sequtils]
import tabelline

# ---------------------------------------------------------------- data
let raw = parseFile("nfl_2011_stats.json")

proc halfData(first, count: int): TableData =
  ## The rows first ..< first+count of the JSON, as columns (the `.head()` / `.slice()` of table.py).
  result = TableData()
  var names: seq[string]
  for k, _ in raw[0]: names.add k
  for n in names:
    var vals: seq[Value]
    for i in first ..< first + count:
      let j = raw[i][n]
      vals.add(case j.kind
        of JInt: toValue(j.getInt)
        of JFloat: toValue(j.getFloat)
        of JString: toValue(j.getStr)
        of JArray: toValue(j.mapIt(it.getFloat))
        else: null())
    result.addColumn(n, vals)

# ------------------------------------------------- gt-extras look-alikes
const
  blue = "blue"
  orange = "orange"

func f0(x: float): string = $int(round(x))

proc winLoss(v: Value, ctx: RenderContext): string =
  ## gt_plt_winloss: a strip of bars, up for a win, down for a loss, a short grey one for a tie.
  let (w, h) = (120.0, 40.0)
  let games = v.items.mapIt(it.toFloat)
  if ctx == rcText:
    return games.mapIt(if it == 1.0: "▲" elif it == 0.0: "▼" else: "·").join
  let slot = w / games.len.float
  let mid = h / 2
  var bars = ""
  for i, g in games:
    let x = i.float * slot + slot * 0.15
    let bw = slot * 0.7
    if g == 1.0: bars.add "<rect x=\"" & $x & "\" y=\"" & $(mid - 14) & "\" width=\"" & $bw & "\" height=\"14\" fill=\"" & blue & "\"/>"
    elif g == 0.0: bars.add "<rect x=\"" & $x & "\" y=\"" & $mid & "\" width=\"" & $bw & "\" height=\"14\" fill=\"" & orange & "\"/>"
    else: bars.add "<rect x=\"" & $x & "\" y=\"" & $(mid - 2) & "\" width=\"" & $bw & "\" height=\"4\" fill=\"gray\"/>"
  let wins = games.countIt(it == 1.0)
  "<svg role=\"img\" aria-label=\"" & $wins & " wins of " & $games.len & " games\" width=\"" & $w & "\" height=\"" & $h &
    "\" viewBox=\"0 0 " & $w & " " & $h & "\" style=\"vertical-align:middle\">" & bars & "</svg>"

proc rankChange(v: Value, ctx: RenderContext): string =
  ## gt_fa_rank_change (icon "turn"): an arrow, blue up / orange down, and the number.
  let x = v.toFloat
  let n = $abs(x.int)
  if ctx == rcText: return (if x > 0: "▲" else: "▼") & n
  let (name, color) = if x > 0: ("turn-up", blue) else: ("turn-down", orange)
  "<span style=\"white-space:nowrap;color:" & color & "\">" &
    iconSvg(name, height = "14px", fill = color, a11y = "decorative") & " " & n & "</span>"

proc dumbbellFn(lo, hi: float): FormatFn =
  ## gt_plt_dumbbell: Avg PF (green) and Avg PA (red) as two dots on one axis shared by the table.
  result = proc (v: Value, ctx: RenderContext): string =
    let (a, b) = (v["pf"].toFloat, v["pa"].toFloat)
    if ctx == rcText: return f0(a) & " vs " & f0(b)
    let (w, h, pad) = (300.0, 40.0, 26.0)
    let pos = proc (x: float): float = pad + (x - lo) / (hi - lo) * (w - 2 * pad)
    let (xa, xb) = (pos(a), pos(b))
    let y = h / 2
    func label(x: float, left: bool, color: string, val: float): string =
      "<text x=\"" & $(if left: x - 8 else: x + 8) & "\" y=\"" & $(y + 4) & "\" font-size=\"12\" text-anchor=\"" &
        (if left: "end" else: "start") & "\" fill=\"" & color & "\">" & f0(val) & "</text>"
    "<svg role=\"img\" aria-label=\"Points for " & f0(a) & ", points against " & f0(b) & "\" width=\"" & $w & "\" height=\"" & $h &
      "\" viewBox=\"0 0 " & $w & " " & $h & "\" style=\"vertical-align:middle\">" &
      "<line x1=\"" & $xa & "\" y1=\"" & $y & "\" x2=\"" & $xb & "\" y2=\"" & $y & "\" stroke=\"gray\" stroke-width=\"2\"/>" &
      "<circle cx=\"" & $xa & "\" cy=\"" & $y & "\" r=\"5\" fill=\"green\"/>" &
      "<circle cx=\"" & $xb & "\" cy=\"" & $y & "\" r=\"5\" fill=\"red\"/>" &
      label(xa, a <= b, "green", a) & label(xb, b < a, "red", b) & "</svg>"

proc colorBox(v: Value, ctx: RenderContext): string =
  ## gt_color_box: the number in a box coloured green -> yellow -> red over the domain 14 .. -14.
  let x = v.toFloat
  let txt = formatNumber(x, decimals = 1)
  if ctx == rcText: return txt
  let bg = interpolate(["green", "yellow", "red"], (x - 14.0) / (-14.0 - 14.0))
  "<span style=\"display:inline-block;min-width:3.2em;padding:2px 6px;border-radius:4px;background-color:" & bg &
    ";color:" & idealTextColor(bg) & "\">" & txt & "</span>"

proc logo(v: Value, ctx: RenderContext): string =
  ## fmt_image: the logo from its address (the page loads it); in text, the file's name.
  let url = $v
  if ctx == rcText: return url.split('/')[^1].split('.')[0]
  "<img src=\"" & escapeHtml(url) & "\" alt=\"" & escapeHtml(url.split('/')[^1].split('.')[0]) &
    "\" style=\"height:2em;vertical-align:middle\">"

proc whole(t: Tabella): Tabella =
  result = t
  result.formats[^1].wholeValue = true

const
  title = "2011 NFL Season at a Glance"
  subtitle = "Super Bowl XLVI: New York Giants def. New England Patriots"
  sourceNote = "<span style=\"float: right;\">Source: <a href=\"https://github.com/nflverse/nfldata\">Lee Sharpe, nflverse</a></span>"

proc makeTable(first, count: int): Tabella =
  var d = halfData(first, count)
  # the dumbbell plot takes the place of Avg PF and reads Avg PA as well: put both in one record
  var pfpa: seq[Value]
  var lo, hi = NaN
  for i in 0 ..< d.nrows:
    let (a, b) = (d["Avg PF", i].toFloat, d["Avg PA", i].toFloat)
    pfpa.add toValue((pf: a, pa: b))
    for x in [a, b]:
      if lo.isNaN or x < lo: lo = x
      if hi.isNaN or x > hi: hi = x
  let dd = TableData()
  for c in d.columns:
    dd.addColumn(c.name, if c.name == "Avg PF": pfpa else: c.values)
  var t = initTabella(dd, rownameCol = "Team", groupnameCol = "team_division")
  t = t.tabStubhead("Team")
  t = t.tabSpanner("Scoring", ["Avg PF", "Avg PA", "Point Diff"])
  t = t.tabSpanner("Season Trends", ["Games", "Streak"])
  t = t.fmt("team_logo_espn", logo).whole
  t = t.colsHide(cols("Wins", "team_conf", "team_name"))
  t = t.colsAlign(alCenter, cols("Avg PF", "Avg PA", "Games"))
  t = t.colsMoveToStart("team_logo_espn")
  t = t.colsLabel("team_logo_espn", "")
  t = t.fmt("Games", winLoss).whole
  t = t.fmt("Streak", rankChange).whole
  t = t.fmt("Avg PF", dumbbellFn(lo, hi)).whole
  t = t.colsLabel("Avg PF", "Points For vs Points Against")
  t = t.colsHide("Avg PA")
  t = t.fmt("Point Diff", colorBox).whole
  t = t.tabStyle(style.fill("lightgray"), loc.stub())
  for (team, c) in [("NYG", "gold"), ("NE", "silver")]:
    let st = style.fill(c, alpha = 0.3)
    t = t.tabStyle(proc (r: Row): CellStyle = (if $r["Team"] == team: st else: CellStyle()),
                   loc.body(), loc.stub())
  # gt_add_divider: a dark blue line on the right of Point Diff, label included
  let div3 = style.borders({sRight}, "darkblue", weight = "3px")
  t = t.tabStyle(div3, loc.body("Point Diff"), loc.columnLabels("Point Diff"))
  # gt_theme_538
  t = t.tabOptions(tableFontNames = "Arial, Helvetica, sans-serif", tableFontSize = "14px",
                   tableBackgroundColor = "#FFFFFF", tableBorderTopStyle = "none",
                   tableBorderBottomStyle = "none", columnLabelsBackgroundColor = "#FFFFFF",
                   columnLabelsFontWeight = "bold", columnLabelsTextTransform = "uppercase",
                   columnLabelsFontSize = "80%", columnLabelsBorderBottomColor = "#333333",
                   columnLabelsBorderBottomWidth = "3px", tableBodyHlinesColor = "#DDDDDD",
                   rowGroupBackgroundColor = "#F0F0F0", rowGroupFontWeight = "bold",
                   rowGroupBorderColor = "#DDDDDD",
                   headingAlign = "left", headingBorderBottomStyle = "none")
  t

let t1 = makeTable(0, 16)
let t2 = makeTable(16, 16)

# ---------------------------------------------------------------- text
# gt_two_column_layout(table_header_from=1): one header, the two tables, the source note once.
echo title
echo subtitle
echo ""
echo t1
echo ""
echo t2
echo "Source: Lee Sharpe, nflverse (https://github.com/nflverse/nfldata)"

# ---------------------------------------------------------------- html
let page = """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>""" & title & """</title>
<style>
body{margin:0;padding:24px;font-family:Arial,Helvetica,sans-serif}
.layout-head h1{font-size:125%;margin:0;font-weight:bold}
.layout-head p{font-size:85%;margin:4px 0 12px;color:#333}
.layout{display:flex;gap:24px;align-items:flex-start;flex-wrap:wrap}
.layout > div{flex:1 1 0;min-width:0;overflow-x:auto}
.layout-foot{text-align:right;font-size:90%;margin-top:8px}
</style></head>
<body>
<div class="layout-head"><h1>""" & title & "</h1><p>" & subtitle & """</p></div>
<div class="layout">
<div>
""" & t1.toHtml(withStyle = true) & """
</div>
<div>
""" & t2.toHtml(withStyle = false) & """
</div>
</div>
<div class="layout-foot">""" & sourceNote & """</div>
</body></html>
"""
writeFile("table.html", page)
