import std/[json, strutils, sequtils, math, os]
import tabelline

# ------------------------------------------------------------------ data
let rows = parseFile("nfl_2011_stats.json")

proc loadData(part: JsonNode): TableData =
  ## One column per key of the JSON records. "Avg PF" holds the pair [PF, PA]: the dumbbell draws both.
  result = TableData()
  for key in ["Team", "Record", "Wins", "Avg PF", "Avg PA", "Point Diff", "Games", "Streak",
              "team_division", "team_conf", "team_name", "team_logo_espn"]:
    var vs: seq[Value]
    for r in part:
      let x = r[key]
      if key == "Avg PF":
        vs.add toValue(@[x.getFloat, r["Avg PA"].getFloat]); continue
      case x.kind
      of JString: vs.add toValue(x.getStr)
      of JInt: vs.add toValue(x.getInt)
      of JFloat: vs.add toValue(x.getFloat)
      of JArray: vs.add toValue(x.mapIt(it.getFloat))
      else: vs.add null()
    result.addColumn(key, vs)

proc floats(v: Value): seq[float] = v.items.mapIt(it.toFloat)

# ------------------------------------------------------------------ cells drawn by hand
proc fx(x: float): string = formatFloat(x, ffDecimal, 1)

proc winLoss(v: Value, ctx: RenderContext): string =
  # gt_plt_winloss: win_color blue, loss_color orange, tie_color gray, 120 x 40
  let g = v.floats
  if ctx == rcText: return g.mapIt(if it == 1.0: "W" elif it == 0.0: "L" else: "T").join("")
  const w = 120.0
  const h = 40.0
  let step = w / float(g.len)
  let bw = step * 0.7
  var s = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"120\" height=\"40\" viewBox=\"0 0 120 40\" role=\"img\" aria-label=\"win-loss record\">"
  s.add "<line x1=\"0\" y1=\"20\" x2=\"120\" y2=\"20\" stroke=\"#bbbbbb\" stroke-width=\"0.5\"/>"
  for i, r in g:
    let x = float(i) * step + (step - bw) / 2
    if r == 1.0: s.add "<rect x=\"" & fx(x) & "\" y=\"3\" width=\"" & fx(bw) & "\" height=\"16\" fill=\"blue\"/>"
    elif r == 0.0: s.add "<rect x=\"" & fx(x) & "\" y=\"21\" width=\"" & fx(bw) & "\" height=\"16\" fill=\"orange\"/>"
    else: s.add "<rect x=\"" & fx(x) & "\" y=\"17\" width=\"" & fx(bw) & "\" height=\"6\" fill=\"gray\"/>"
  s & "</svg>"

proc rankChange(v: Value, ctx: RenderContext): string =
  # gt_fa_rank_change, icon "turn": turn-up in blue for a positive streak, turn-down in orange
  let n = v.i
  if ctx == rcText: return (if n > 0: "▲ " else: "▼ ") & $abs(n)
  let (_, icon) = findIcon(if n > 0: "fas fa-turn-up" else: "fas fa-turn-down")
  let color = if n > 0: "blue" else: "orange"
  "<span style=\"white-space:nowrap;color:" & color & ";display:inline-flex;align-items:center;gap:4px;\">" &
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 " & $icon.width & " 512\" height=\"14\" width=\"" &
    fx(14.0 * float(icon.width) / 512.0) & "\" fill=\"" & color & "\" aria-hidden=\"true\"><path d=\"" & icon.path &
    "\"/></svg><span>" & $abs(n) & "</span></span>"

proc dumbbell(lo, hi: float): FormatFn =
  # gt_plt_dumbbell: PF green, PA red, 300 x 40, 0 decimals; the scale is the table's own
  result = proc (v: Value, ctx: RenderContext): string =
    let pf = v.items[0].toFloat
    let pa = v.items[1].toFloat
    if ctx == rcText: return formatNumber(pf, decimals = 0) & " vs " & formatNumber(pa, decimals = 0)
    const w = 300.0
    let (l, r) = (20.0, w - 20.0)
    proc px(x: float): float = l + (x - lo) / (hi - lo) * (r - l)
    let (a, b) = (px(pf), px(pa))
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"300\" height=\"40\" viewBox=\"0 0 300 40\" role=\"img\" aria-label=\"" &
      "points for " & formatNumber(pf, decimals = 0) & ", points against " & formatNumber(pa, decimals = 0) & "\">" &
      "<line x1=\"" & fx(a) & "\" y1=\"22\" x2=\"" & fx(b) & "\" y2=\"22\" stroke=\"#aaaaaa\" stroke-width=\"3\"/>" &
      "<circle cx=\"" & fx(a) & "\" cy=\"22\" r=\"5\" fill=\"green\"/><circle cx=\"" & fx(b) & "\" cy=\"22\" r=\"5\" fill=\"red\"/>" &
      "<text x=\"" & fx(a) & "\" y=\"12\" font-size=\"12\" text-anchor=\"middle\" fill=\"green\">" & formatNumber(pf, decimals = 0) & "</text>" &
      "<text x=\"" & fx(b) & "\" y=\"38\" font-size=\"12\" text-anchor=\"middle\" fill=\"red\">" & formatNumber(pa, decimals = 0) & "</text></svg>"

proc colorBox(v: Value, ctx: RenderContext): string =
  # gt_color_box: palette green-yellow-red over the domain [14, -14] (14 is green)
  let x = v.toFloat
  let txt = formatNumber(x, decimals = 1)
  if ctx == rcText: return txt
  let fill = interpolate(["green", "yellow", "red"].mapIt(cssColor(it)), (14.0 - x) / 28.0)
  "<div style=\"background-color:" & fill & ";color:" & idealTextColor(fill) &
    ";padding:2px 8px;border-radius:2px;text-align:center;font-weight:bold;\">" & txt & "</div>"

proc logo(v: Value, ctx: RenderContext): string =
  if ctx == rcText: return ""
  let url = v.s
  let name = url.splitFile.name.toUpperAscii
  "<img src=\"" & url & "\" alt=\"" & name & "\" style=\"height:2em;vertical-align:middle\">"

proc whole(t: sink Tabella): Tabella =
  ## the last format gets the whole list, not each item
  result = t
  result.formats[^1].wholeValue = true

# ------------------------------------------------------------------ the table
proc makeTable(part: JsonNode): Tabella =
  let data = loadData(part)
  var lo, hi = data["Avg PF"].values[0].items[0].toFloat
  for v in data["Avg PF"].values:
    for x in v.items:
      lo = min(lo, x.toFloat); hi = max(hi, x.toFloat)
  var t = tabella(data, rownameCol = "Team", groupnameCol = "team_division"):
    tabStubhead "Team"
    tabSpanner "Scoring", ["Avg PF", "Avg PA", "Point Diff"]
    tabSpanner "Season Trends", ["Games", "Streak"]
    colsHide ["Wins", "team_conf", "team_name", "Avg PA"]
    colsMoveToStart "team_logo_espn"
    colsLabel:
      team_logo_espn: ""
      "Avg PF": "Points For vs Points Against"
    colsAlign alCenter, ["Games", "Streak"]
    fmt "team_logo_espn", logo
    fmt "Games", winLoss
    whole()
    fmt "Streak", rankChange
    fmt "Avg PF", dumbbell(lo, hi)
    whole()
    fmt "Point Diff", colorBox
  # stub fill, then the two highlighted teams (gt_highlight_rows: all cells, stub included)
  t = t.tabStyle(style.fill("lightgray"), loc.stub())
  for (team, colour) in [("NYG", "gold"), ("NE", "silver")]:
    let sel = where($it["Team"] == team)
    t = t.tabStyle(style.fill(colour, alpha = 0.3), loc.body(rows = sel), loc.stub(rows = sel))
  # gt_add_divider: a dark blue 3px line at the right of Point Diff
  t = t.tabStyle(style.borders({sRight}, color = "darkblue", weight = "3px"), loc.body(cols = "Point Diff"))
  # gt_theme_538, as far as tabelline has it
  t = t.tabOptions(
    tableFontNames = "Chivo, Arial, Helvetica, sans-serif", tableFontSize = "14px",
    tableBorderTopStyle = "none", tableBorderBottomStyle = "none",
    headingAlign = "left", headingBorderBottomColor = "white",
    headingTitleFontWeight = "bold", headingTitleFontSize = "150%",
    columnLabelsBackgroundColor = "white", columnLabelsFontSize = "12px", columnLabelsFontWeight = "bold",
    columnLabelsTextTransform = "uppercase", columnLabelsBorderBottomColor = "black",
    columnLabelsBorderBottomWidth = "2px", dataRowPadding = "3px",
    tableBodyHlinesColor = "#ededed", rowGroupFontWeight = "bold", rowGroupBorderColor = "black",
    sourceNotesFontSize = "12px")
  t

let h1 = rows.elems[0 ..< 16]
let h2 = rows.elems[16 ..< 32]
let title = "2011 NFL Season at a Glance"
let subtitle = "Super Bowl XLVI: New York Giants def. New England Patriots"
let note = html("<span style=\"float: right;\">Source: <a href=\"https://github.com/nflverse/nfldata\">Lee Sharpe, nflverse</a></span>")

let t1 = makeTable(%h1).tabSourceNote(note)
let t2 = makeTable(%h2).tabSourceNote(note)

# text
echo title
echo subtitle
echo ""
echo t1
echo t2

# page: one header, two tables side by side (gt_two_column_layout, header from table 1)
let page = "<!doctype html>\n<html lang=\"en\"><head><meta charset=\"utf-8\">" &
  "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>" & title & "</title>" &
  tabellaStyle & "<style>body{margin:0;padding:24px;font-family:Chivo,Arial,Helvetica,sans-serif}" &
  "h1{font-size:150%;margin:0 0 4px}p.sub{margin:0 0 16px;font-size:85%}" &
  ".two{display:flex;flex-wrap:wrap;gap:24px;align-items:flex-start}.two>div{flex:1 1 640px;min-width:0;overflow-x:auto}</style></head>\n<body>\n" &
  "<h1>" & title & "</h1><p class=\"sub\">" & subtitle & "</p>\n<div class=\"two\"><div>" &
  t1.toHtml(withStyle = false) & "</div><div>" & t2.toHtml(withStyle = false) & "</div></div>\n</body></html>\n"
writeFile("table.html", page)
