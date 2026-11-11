## Nanoplots: tiny plots in cells, as inline SVG, after Great Tables' `fmt_nanoplot()` and gt's
## `cols_nanoplot()` (ported from Great Tables' `_utils_nanoplots.py`, MIT,
## `licenses/great-tables-MIT.txt`).
##
## A cell with several values ("20 23 6.7", or "1, 2, NA") is a line plot, a bar plot or a box
## plot; a cell with one number is a horizontal bar or line from a zero line shared by all the
## rows. The values show when the pointer is over the plot (no JavaScript: CSS `:hover`). In text
## output a nanoplot is a sparkline ("▁▃▅█").

import std/[strutils, math, algorithm, sequtils, hashes, times]
from std/unicode import runeLen
import core, formats, verbs

type
  NanoplotOptions* = object
    ## The look of a nanoplot, after Great Tables' `nanoplot_options()` (see `nanoplotOptions`).
    dataPointRadius*: seq[float]     ## one value, or one per point (repeating)
    dataPointStrokeColor*, dataPointFillColor*: seq[string]
    dataPointStrokeWidth*: seq[float]
    dataLineStrokeColor*: string
    dataLineStrokeWidth*: float
    dataLineType*: string
    dataAreaFillColor*: string
    dataBarStrokeColor*, dataBarFillColor*: seq[string]   ## one value, or one per bar
    dataBarStrokeWidth*: seq[float]
    dataBarNegativeStrokeColor*, dataBarNegativeFillColor*: string
    dataBarNegativeStrokeWidth*: float
    referenceLineColor*, referenceAreaFillColor*: string
    verticalGuideStrokeColor*: string
    verticalGuideStrokeWidth*: float
    showDataPoints*, showDataLine*, showDataArea*, showReferenceLine*, showReferenceArea*,
      showVerticalGuides*, showYAxisGuide*, interactiveDataValues*: bool
    currency*: string
    yValFmtFn*, yAxisFmtFn*, yRefLineFmtFn*: proc (x: float): string

func perPoint[T](x: T | seq[T]): seq[T] =
  when x is seq: (if x.len == 0: raise newException(ValueError, "an empty list of options") else: x)
  else: @[x]

func at*[T](s: seq[T], i: int): T =
  ## The value of a per-point option for point `i`: the list repeats.
  s[i mod s.len]

func nanoplotOptions*(dataPointRadius: float | seq[float] = 10.0,
                      dataPointStrokeColor: string | seq[string] = "#FFFFFF",
                      dataPointStrokeWidth: float | seq[float] = 4.0,
                      dataPointFillColor: string | seq[string] = "#FF0000",
                      dataLineType = "curved", dataLineStrokeColor = "#4682B4",
                      dataLineStrokeWidth = 8.0, dataAreaFillColor = "#FF0000",
                      dataBarStrokeColor: string | seq[string] = "#3290CC",
                      dataBarStrokeWidth: float | seq[float] = 4.0,
                      dataBarFillColor: string | seq[string] = "#3FB5FF", dataBarNegativeStrokeColor = "#CC3243",
                      dataBarNegativeStrokeWidth = 4.0, dataBarNegativeFillColor = "#D75A68",
                      referenceLineColor = "#75A8B0", referenceAreaFillColor = "#A6E6F2",
                      verticalGuideStrokeColor = "#911EB4", verticalGuideStrokeWidth = 12.0,
                      showDataPoints = true, showDataLine = true, showDataArea = true,
                      showReferenceLine = true, showReferenceArea = true,
                      showVerticalGuides = true, showYAxisGuide = true,
                      interactiveDataValues = true, currency = "",
                      yValFmtFn: proc (x: float): string = nil,
                      yAxisFmtFn: proc (x: float): string = nil,
                      yRefLineFmtFn: proc (x: float): string = nil): NanoplotOptions =
  ## Options for `fmtNanoplot` and `colsNanoplot`, with Great Tables' defaults. Colours can be
  ## CSS variables (`"var(--primary)"`). `dataLineType` is "curved" or "straight"; `currency`
  ## writes the values as money ("EUR"); the `*FmtFn` procs write the values, the bounds of the
  ## y axis and the reference line yourself.
  if dataLineType notin ["curved", "straight"]:
    raise newException(ValueError, "dataLineType is \"curved\" or \"straight\", not " & dataLineType.escape)
  NanoplotOptions(dataPointRadius: perPoint[float](dataPointRadius),
    dataPointStrokeColor: perPoint[string](dataPointStrokeColor),
    dataPointStrokeWidth: perPoint[float](dataPointStrokeWidth),
    dataPointFillColor: perPoint[string](dataPointFillColor),
    dataLineType: dataLineType, dataLineStrokeColor: dataLineStrokeColor,
    dataLineStrokeWidth: dataLineStrokeWidth, dataAreaFillColor: dataAreaFillColor,
    dataBarStrokeColor: perPoint[string](dataBarStrokeColor),
    dataBarStrokeWidth: perPoint[float](dataBarStrokeWidth),
    dataBarFillColor: perPoint[string](dataBarFillColor), dataBarNegativeStrokeColor: dataBarNegativeStrokeColor,
    dataBarNegativeStrokeWidth: dataBarNegativeStrokeWidth,
    dataBarNegativeFillColor: dataBarNegativeFillColor, referenceLineColor: referenceLineColor,
    referenceAreaFillColor: referenceAreaFillColor,
    verticalGuideStrokeColor: verticalGuideStrokeColor,
    verticalGuideStrokeWidth: verticalGuideStrokeWidth, showDataPoints: showDataPoints,
    showDataLine: showDataLine, showDataArea: showDataArea, showReferenceLine: showReferenceLine,
    showReferenceArea: showReferenceArea, showVerticalGuides: showVerticalGuides,
    showYAxisGuide: showYAxisGuide, interactiveDataValues: interactiveDataValues,
    currency: currency, yValFmtFn: yValFmtFn, yAxisFmtFn: yAxisFmtFn, yRefLineFmtFn: yRefLineFmtFn)

# ------------------------------------------------------------------------------------ the values

func nanoplotValues*(v: Value): seq[float] =
  ## The values of a nanoplot cell: a number, a list of numbers (`@[1, 4, 2]`), a record with the
  ## values in `y` (and their places in `x`, see `nanoplotXValues`), or a text of numbers
  ## separated by spaces, commas or semicolons, maybe in brackets ("[1, 2, NA]"); `NA` (or
  ## `nan`) is a missing value, `NaN`.
  if v.isNull: return @[]
  if v.isNumber: return @[v.toFloat]
  if v.isList:
    for x in v.items:
      if x.isNull: result.add NaN
      elif x.isNumber: result.add x.toFloat
      else: result.add nanoplotValues(x)
    return
  if v.isRecord:
    if "y" notin v: raise newException(ValueError, "a nanoplot of a record reads its field y, and this one has none: " & ($v).escape)
    return nanoplotValues(v["y"])
  for w in ($v).multiReplace((";", " "), (",", " "), ("[", " "), ("]", " ")).splitWhitespace:
    if w.toUpperAscii in ["NA", "NAN", "NULL", "NONE"]: result.add NaN
    else:
      try: result.add parseFloat(w.replace("−", "-"))
      except ValueError: raise newException(ValueError, "not a number in a nanoplot: " & w.escape)

proc dateValue(s: string): float =
  ## An ISO date or date and time ("2026-11-11", "2026-11-11T10:30", "2026-11-11 10:30:00") as
  ## seconds since 1970, or NaN for anything else.
  let t = s.strip
  for f in ["yyyy-MM-dd", "yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd HH:mm", "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"]:
    try: return parse(t, f, utc()).toTime.toUnixFloat
    except TimeParseError, ValueError: discard
  NaN

proc nanoplotXValues*(v: Value): seq[float] =
  ## The places of the values on the x axis: the field `x` of a record (`(x: @[1, 2, 4], y:
  ## @[3, 5, 4])`, Great Tables' dict of x and y), numbers or ISO dates and times
  ## (`@["2026-01-05", "2026-02-11"]`, placed by time); empty for any other cell, whose values
  ## are evenly spaced.
  if not (v.isRecord and "x" in v): return @[]
  let x = v["x"]
  if x.isList and x.items.anyIt(it.kind == vkString and not dateValue($it).isNaN):
    return x.items.mapIt(if it.isNull: NaN elif it.isNumber: it.toFloat else: dateValue($it))
  nanoplotValues(x)

func present(xs: openArray[float]): seq[float] = xs.filterIt(not it.isNaN)

func byX(y, x: seq[float]): (seq[float], seq[float]) =
  ## The pairs with an x, in the order of x.
  var pairs: seq[(float, float)]
  for i in 0 ..< min(x.len, y.len):
    if not x[i].isNaN: pairs.add (x[i], y[i])
  pairs.sort(proc (a, b: (float, float)): int = cmp(a[0], b[0]))
  (pairs.mapIt(it[1]), pairs.mapIt(it[0]))

func quantile(xs: openArray[float], q: float): float =
  ## Interpolated linearly, as R's and NumPy's `quantile()`.
  let s = sorted(xs)
  let h = (s.len - 1).float * q
  let lo = floor(h).int
  let hi = min(lo + 1, s.high)
  s[lo] + (h - lo.float) * (s[hi] - s[lo])

const refKeywords* = ["mean", "median", "min", "max", "q1", "q3", "first", "last"]
  ## The keywords of a reference line or area: a statistic of the values.

func refValue(spec: string, vals: openArray[float]): float =
  ## A reference value: a number ("12.5") or a keyword of `refKeywords`.
  let s = spec.strip.toLowerAscii
  if s notin refKeywords:
    try: return parseFloat(s.replace("−", "-"))
    except ValueError:
      raise newException(ValueError, "a reference is a number or one of " & refKeywords.join(", ") & ", not " & spec.escape)
  let p = present(vals)
  if p.len == 0: raise newException(ValueError, "a reference line of " & s & " needs a value that is not missing")
  case s
  of "mean": p.sum / p.len.float
  of "median": quantile(p, 0.5)
  of "min": p.min
  of "max": p.max
  of "q1": quantile(p, 0.25)
  of "q3": quantile(p, 0.75)
  of "first": p[0]
  else: p[^1]

# ------------------------------------------------------------------------------------ the labels

func roundSig(x: float, n: int): float =
  if x == 0: return 0.0
  let p = pow(10.0, float(floor(log10(abs(x))).int - n + 1))
  round(x / p) * p

func sigfig(x: float, n: int): string =
  ## `x` with `n` significant figures, keeping the zeros at the end ("2.50").
  let r = roundSig(x, n)
  if r == 0: return "0"
  formatNumber(r, max(0, n - 1 - floor(log10(abs(r))).int))

proc nanoplotLabel*(x: float, asInteger = false, currency = "", fn: proc (x: float): string = nil): string =
  ## A value as a nanoplot writes it, short, as Great Tables does: "0", integers below 100 as
  ## they are, 3 significant figures ("2.50", "123"), K, M, B and T from a thousand ("1.23K"),
  ## and "1.2E−3" for the tiny and the huge; with a `currency`, money ("$12.50", "€1.2K").
  if fn != nil: return fn(x)
  if x.isNaN: return "NA"
  if x == 0: return "0"
  let a = abs(x)
  if currency.len > 0:
    if a < 1000: return formatCurrency(x, currency)
    return (if x < 0: "−" else: "") & currencyInfo(currency).symbol & formatCompact(a, 1)
  if a < 0.01 or a >= 1e15:
    var e = floor(log10(a)).int
    var m = x / pow(10.0, e.float)
    if abs(round(m, 1)) >= 10: (m /= 10; inc e)
    return formatNumber(m, 1) & "E" & (if e < 0: "−" else: "") & $abs(e)
  if asInteger and a < 100: return formatNumber(x, 0)
  if a < 1: return sigfig(x, 2)
  if abs(roundSig(x, 3)) < 1000: return sigfig(x, 3)
  for (scale, suffix) in [(1e12, "T"), (1e9, "B"), (1e6, "M"), (1e3, "K")]:
    if abs(roundSig(x, 3)) >= scale: return sigfig(x / scale, 3) & suffix
  sigfig(x, 3)

func isWhole(x: float): bool = x == round(x)

# ----------------------------------------------------------------------------------- the canvas

const
  safeX = 50.0
  safeY = 15.0
  dataH = 100.0
  bottomY = safeY + dataH + safeY
  fixedW = 600.0
  zeroLineColor = "#BFBFBF"
  zeroBarColor = "#808080"

func n(x: float): string =
  ## A number in SVG, with at most two decimals.
  if x.isNaN: return "0"
  result = formatFloat(round(x, 2), ffDecimal, 2)
  result = result.strip(leading = false, chars = {'0'}).strip(leading = false, chars = {'.'})
  if result == "-0": result = "0"

func pointSpacing(count: int): float =
  for (most, spacing) in [(20, 50.0), (30, 40.0), (40, 30.0), (50, 25.0)]:
    if count <= most: return spacing
  20.0

func yPos(p: float): float = safeY + (1 - p) * dataH

func hiddenText(x, y: float, label: string, anchor = ""): string =
  "<text x=\"" & n(x) & "\" y=\"" & n(y) & "\" fill=\"transparent\" stroke=\"transparent\" font-size=\"30px\"" &
    (if anchor.len > 0: " text-anchor=\"" & anchor & "\"" else: "") & ">" & escapeHtml(label) & "</text>"

func missingMarker(x, radius, strokeWidth: float, fill: string): string =
  "<circle cx=\"" & n(x) & "\" cy=\"" & n(safeY + dataH / 2) & "\" r=\"" & n(radius * 1.5) &
    "\" stroke=\"red\" stroke-width=\"" & n(strokeWidth) & "\" fill=\"" & fill & "\"></circle>"

func barStyle(v: float, o: NanoplotOptions, i = 0): (string, float, string) =
  ## The stroke, its width and the fill of bar `i` of value `v`.
  if v < 0: (o.dataBarNegativeStrokeColor, o.dataBarNegativeStrokeWidth, o.dataBarNegativeFillColor)
  elif v > 0: (o.dataBarStrokeColor.at(i), o.dataBarStrokeWidth.at(i), o.dataBarFillColor.at(i))
  else: (zeroBarColor, 4.0, zeroBarColor)

func patternId(color: string): string =
  "tb_area_" & toHex(hash(color).uint32.int, 8).toLowerAscii

func refLineTag(x0, y, width: float, color, label: string): string =
  ## A horizontal reference line, its value shown on hover.
  "<g class=\"ref-line\"><rect x=\"" & n(x0 - 10) & "\" y=\"" & n(y - 10) & "\" width=\"" & n(width + 20) &
    "\" height=\"20\" stroke=\"transparent\" stroke-width=\"1\" fill=\"transparent\"></rect>" &
    "<line class=\"ref-line\" x1=\"" & n(x0) & "\" y1=\"" & n(y) & "\" x2=\"" & n(width + safeX) & "\" y2=\"" & n(y) &
    "\" stroke=\"" & color & "\" stroke-width=\"1\" stroke-dasharray=\"4 3\" stroke-linecap=\"round\" vector-effect=\"non-scaling-stroke\"></line>" &
    hiddenText(width + safeX + 10, y + 10, label) & "</g>"

func verticalRefLineTag(x, y1, y2: float, color, label: string, onLeft: bool): string =
  ## A vertical reference line (in a single-value plot or a box plot).
  "<g class=\"ref-line\"><rect x=\"" & n(x - 10) & "\" y=\"" & n(y1) & "\" width=\"20\" height=\"" & n(y2 - y1) &
    "\" stroke=\"transparent\" stroke-width=\"1\" fill=\"transparent\"></rect>" &
    "<line class=\"ref-line\" x1=\"" & n(x) & "\" y1=\"" & n(y1) & "\" x2=\"" & n(x) & "\" y2=\"" & n(y2) &
    "\" stroke=\"" & color & "\" stroke-width=\"1\" stroke-dasharray=\"4 3\" stroke-linecap=\"round\" vector-effect=\"non-scaling-stroke\"></line>" &
    hiddenText(if onLeft: x - 10 else: x + 10, y1 - 10, label, if onLeft: "end" else: "") & "</g>"

# --------------------------------------------------------------------- plots of several values

proc severalValues(y: seq[float], plotType, missingVals, refLine: string, refArea: (string, string),
                   expandY: seq[float], o: NanoplotOptions, x: seq[float] = @[],
                   expandX: seq[float] = @[]): (string, string) =
  ## The viewBox and the layers of a line or bar plot of the values `y` (NaN for a missing one),
  ## evenly spaced, or a line plot at the places `x`, on an axis that includes `expandX`.
  let p = present(y)
  let integerlike = p.allIt(it.isWhole)
  var expand = expandY
  if expand.len == 0 and p.min == p.max:
    let d = if p.min == 0: 5.0 else: abs(p.min / 10 * 2)
    expand = @[p.min - d, p.min + d]
  let showRefLine = refLine.len > 0 and o.showReferenceLine
  let showRefArea = refArea[0].len > 0 and refArea[1].len > 0 and o.showReferenceArea
  let refL = if showRefLine: refValue(refLine, y) else: NaN
  var areaL, areaU = NaN
  if showRefArea:
    let a = refValue(refArea[0], y)
    let b = refValue(refArea[1], y)
    (areaL, areaU) = (min(a, b), max(a, b))
  let bar = plotType == "bar"
  var pool = p & expand
  if showRefLine: pool.add refL
  if showRefArea: pool.add [areaL, areaU]
  if bar: pool.add 0.0
  let (lo, hi) = (pool.min, pool.max)
  func prop(v: float): float = (if hi > lo: (v - lo) / (hi - lo) else: 0.5)
  let count = y.len
  let xd = pointSpacing(count)
  let width = count.float * xd
  var xs, ys: seq[float]
  let atX = x.len == count and plotType != "bar"
  let xPool = if atX: x & expandX else: @[]
  let (xl, xh) = if atX: (xPool.min, xPool.max) else: (0.0, 0.0)
  for i in 0 ..< count:
    if atX: xs.add width * (if xh > xl: (x[i] - xl) / (xh - xl) else: 0.5) + safeX
    else: xs.add width * (if count > 1: i / (count - 1) else: 0.0) + safeX
    ys.add(if y[i].isNaN: NaN else: yPos(prop(y[i])))
  let viewBox = "0 0 " & n(safeX + width + safeX) & " " & n(bottomY)
  var segments: seq[(int, int)]
  var start = -1
  for i in 0 .. count:
    let missing = i == count or ys[i].isNaN
    if not missing and start < 0: start = i
    elif missing and start >= 0: (segments.add (start, i); start = -1)
  var layers = ""
  # the reference area
  if showRefArea:
    let (yl, yu) = (yPos(prop(areaL)), yPos(prop(areaU)))
    layers.add "<path d=\"M" & n(xs[0]) & "," & n(yu) & "," & n(xs[^1]) & "," & n(yu) & "," & n(xs[^1]) & "," &
      n(yl) & "," & n(xs[0]) & "," & n(yl) & "Z\" stroke=\"transparent\" stroke-width=\"2\" fill=\"" &
      o.referenceAreaFillColor & "\" fill-opacity=\"0.8\"></path>"
  # the data area and the data line
  if not bar:
    if o.showDataArea:
      let bottom = bottomY - safeY + o.dataPointRadius.at(0)
      for (a, b) in segments:
        var pts: seq[string]
        for i in a ..< b: pts.add n(xs[i]) & "," & n(ys[i])
        layers.add "<path class=\"area-closed\" d=\"M " & pts.join(" ") & " " & n(xs[b - 1]) & "," & n(bottom) & " " &
          n(xs[a]) & "," & n(bottom) & " Z\" stroke=\"transparent\" stroke-width=\"2\" fill=\"url(#" &
          patternId(o.dataAreaFillColor) & ")\" fill-opacity=\"0.7\"></path>"
    if o.showDataLine:
      let stroke = " stroke=\"" & o.dataLineStrokeColor & "\" stroke-width=\"" & n(o.dataLineStrokeWidth) & "\" fill=\"none\""
      for (a, b) in segments:
        if o.dataLineType == "curved":
          var d = "M " & n(xs[a]) & "," & n(ys[a])
          for j in a + 1 ..< b:
            d.add " C " & n(xs[j - 1] + xd / 2) & "," & n(ys[j - 1]) & " " & n(xs[j] - xd / 2) & "," & n(ys[j]) &
              " " & n(xs[j]) & "," & n(ys[j])
          layers.add "<path d=\"" & d & "\"" & stroke & "></path>"
        else:
          var pts: seq[string]
          for i in a ..< b: pts.add n(xs[i]) & "," & n(ys[i])
          layers.add "<polyline points=\"" & pts.join(" ") & "\"" & stroke & "></polyline>"
  # the zero line and the bars
  if bar:
    let zeroY = yPos(prop(0))
    layers.add "<line x1=\"" & n(xs[0] - 27.5) & "\" y1=\"" & n(zeroY) & "\" x2=\"" & n(xs[^1] + 27.5) & "\" y2=\"" &
      n(zeroY) & "\" stroke=\"" & zeroLineColor & "\" stroke-width=\"4\"></line>"
    for i in 0 ..< count:
      if y[i].isNaN:
        if missingVals == "marker": layers.add missingMarker(xs[i], o.dataPointRadius.at(i), o.dataBarStrokeWidth.at(i), "transparent")
        continue
      let (ry, h) =
        if y[i] < 0: (zeroY, ys[i] - zeroY)
        elif y[i] > 0: (ys[i], zeroY - ys[i])
        else: (zeroY - 1, 2.0)
      let (stroke, sw, fill) = barStyle(y[i], o, i)
      layers.add "<rect x=\"" & n(xs[i] - (xd - 10) / 2) & "\" y=\"" & n(ry) & "\" width=\"" & n(xd - 10) &
        "\" height=\"" & n(h) & "\" stroke=\"" & stroke & "\" stroke-width=\"" & n(sw) & "\" fill=\"" & fill & "\"></rect>"
  # the reference line
  if showRefLine:
    let label = nanoplotLabel(refL, integerlike and refL.isWhole, o.currency, o.yRefLineFmtFn)
    layers.add refLineTag(xs[0], yPos(prop(refL)), width, o.referenceLineColor, label)
  # the data points
  if not bar and o.showDataPoints:
    for i in 0 ..< count:
      if y[i].isNaN:
        if missingVals == "marker": layers.add missingMarker(xs[i], o.dataPointRadius.at(i), o.dataPointStrokeWidth.at(i), "white")
        continue
      layers.add "<circle cx=\"" & n(xs[i]) & "\" cy=\"" & n(ys[i]) & "\" r=\"" & n(o.dataPointRadius.at(i)) & "\" stroke=\"" &
        o.dataPointStrokeColor.at(i) & "\" stroke-width=\"" & n(o.dataPointStrokeWidth.at(i)) & "\" fill=\"" & o.dataPointFillColor.at(i) & "\"></circle>"
  # the y axis: its bounds, on hover
  if o.showYAxisGuide:
    let asInt = lo.isWhole and hi.isWhole
    layers.add "<g class=\"y-axis-line\"><rect x=\"0\" y=\"0\" width=\"" & n(safeX + 15) & "\" height=\"" & n(bottomY) &
      "\" stroke=\"transparent\" stroke-width=\"0\" fill=\"transparent\"></rect>" &
      "<text x=\"0\" y=\"" & n(safeY + dataH / 25) & "\" fill=\"transparent\" stroke=\"transparent\" font-size=\"25\">" &
      escapeHtml(nanoplotLabel(hi, asInt, o.currency, o.yAxisFmtFn)) & "</text>" &
      "<text x=\"0\" y=\"" & n(bottomY - dataH / 25) & "\" fill=\"transparent\" stroke=\"transparent\" font-size=\"25\">" &
      escapeHtml(nanoplotLabel(lo, asInt, o.currency, o.yAxisFmtFn)) & "</text></g>"
  # the vertical guides: each value, on hover
  if o.showVerticalGuides:
    for i in 0 ..< count:
      let guide =
        if o.interactiveDataValues:
          "<rect x=\"" & n(xs[i] - 10) & "\" y=\"0\" width=\"20\" height=\"" & n(bottomY) &
            "\" stroke=\"transparent\" stroke-width=\"" & n(o.verticalGuideStrokeWidth) & "\" fill=\"transparent\"></rect>"
        else:
          "<line x1=\"" & n(xs[i]) & "\" y1=\"0\" x2=\"" & n(xs[i]) & "\" y2=\"" & n(bottomY) & "\" stroke=\"" &
            o.verticalGuideStrokeColor & "\" stroke-opacity=\"0.25\" stroke-width=\"1\" vector-effect=\"non-scaling-stroke\"></line>"
      let label = nanoplotLabel(y[i], integerlike, o.currency, if y[i].isNaN: nil else: o.yValFmtFn)
      layers.add "<g class=\"vert-line\">" & guide & hiddenText(xs[i] + 10 + (if label == "NA": 2.0 else: 0.0), safeY + 5, label) & "</g>"
  (viewBox, layers)

# ----------------------------------------------------------------------- plots of a single value

proc singleValue(y: float, all: seq[float], plotType, refLine: string, o: NanoplotOptions): string =
  ## The layers of a horizontal bar or line from the zero line to `y`, on the scale of `all`.
  let others = present(all)
  let refL = if refLine.len > 0 and o.showReferenceLine: refValue(refLine, others) else: NaN
  let thick = o.dataPointRadius.at(0) * 4
  let mid = bottomY / 2
  let (y1, y2) = (mid - thick * 1.5, mid + thick * 1.5)
  var pool = others & @[y, 0.0]
  if not refL.isNaN: pool.add refL
  let (lo, hi) = (pool.min, pool.max)
  func prop(v: float): float = (if hi > lo: (v - lo) / (hi - lo) else: 0.5)
  let (valX, zeroX) = (prop(y) * fixedW, prop(0) * fixedW)
  let label = nanoplotLabel(y, y.isWhole, o.currency, o.yValFmtFn)
  let labelTag =
    if y > 0: hiddenText(zeroX + 10, safeY + 10, label)
    elif y < 0: hiddenText(zeroX - 10, safeY + 10, label, "end")
    elif others.allIt(it == 0): hiddenText(zeroX + 10, mid + 10, label, "start")
    elif others.allIt(it < 0): hiddenText(zeroX - 10, mid + 10, label, "end")
    else: hiddenText(zeroX + (if plotType == "bar": 10.0 else: 15.0), mid + 10, label, "start")
  let guide = "<g class=\"horizontal-line\"><rect x=\"0\" y=\"" & n(mid - thick / 2) & "\" width=\"" & n(fixedW) &
    "\" height=\"" & n(thick) & "\" stroke=\"transparent\" stroke-width=\"" & n(o.verticalGuideStrokeWidth) &
    "\" fill=\"transparent\"></rect>" & labelTag & "</g>"
  let zeroLine = "<line x1=\"" & n(zeroX) & "\" y1=\"" & n(y1) & "\" x2=\"" & n(zeroX) & "\" y2=\"" & n(y2) &
    "\" stroke=\"" & zeroLineColor & "\" stroke-width=\"4\"></line>"
  let refTag =
    if refL.isNaN: ""
    else: verticalRefLineTag(prop(refL) * fixedW, y1, y2, o.referenceLineColor,
                             nanoplotLabel(refL, y.isWhole and refL.isWhole, o.currency, o.yRefLineFmtFn), prop(refL) > 0.5)
  if plotType == "bar":
    let (rx, w) =
      if y < 0: (valX, zeroX - valX)
      elif y > 0: (zeroX, valX - zeroX)
      else: (zeroX - 2.5, 5.0)
    let (stroke, sw, fill) = barStyle(y, o)
    return zeroLine & "<rect x=\"" & n(rx) & "\" y=\"" & n(mid - thick / 2) & "\" width=\"" & n(w) & "\" height=\"" &
      n(thick) & "\" stroke=\"" & stroke & "\" stroke-width=\"" & n(sw) & "\" fill=\"" & fill & "\"></rect>" & guide & refTag
  let (x1, x2) = if y > 0: (zeroX, valX) else: (valX, zeroX)
  let px = if y < 0: x1 else: x2
  "<line x1=\"" & n(x1) & "\" y1=\"" & n(mid) & "\" x2=\"" & n(x2) & "\" y2=\"" & n(mid) & "\" stroke=\"" &
    o.dataLineStrokeColor & "\" stroke-width=\"" & n(o.dataLineStrokeWidth) & "\"></line>" & guide & zeroLine & refTag &
    "<circle cx=\"" & n(px) & "\" cy=\"" & n(mid) & "\" r=\"" & n(o.dataPointRadius.at(0)) & "\" stroke=\"" &
    o.dataPointStrokeColor.at(0) & "\" stroke-width=\"" & n(o.dataPointStrokeWidth.at(0)) & "\" fill=\"" & o.dataPointFillColor.at(0) & "\"></circle>"

# -------------------------------------------------------------------------------------- box plots

type BoxStats = object
  q1, median, q3, low, high: float
  outliers: seq[float]

func boxStats(vals: seq[float]): BoxStats =
  ## Tukey's box: the quartiles, whiskers to the farthest values within 1.5 times the box's
  ## height, and the values beyond them.
  let (q1, m, q3) = (quantile(vals, 0.25), quantile(vals, 0.5), quantile(vals, 0.75))
  let fence = 1.5 * (q3 - q1)
  let inside = vals.filterIt(it >= q1 - fence and it <= q3 + fence)
  BoxStats(q1: q1, median: m, q3: q3, low: inside.min, high: inside.max,
           outliers: vals.filterIt(it < q1 - fence or it > q3 + fence))

const goldenConjugate = (sqrt(5.0) - 1) / 2

proc boxplot(y, all: seq[float], refLine: string, refArea: (string, string), expandY: seq[float],
             o: NanoplotOptions): string =
  ## The layers of a horizontal box plot of `y`, on the scale of `all` (the values of every row).
  let vals = present(y)
  let s = boxStats(vals)
  let refL = if refLine.len > 0 and o.showReferenceLine: refValue(refLine, vals) else: NaN
  var areaL, areaU = NaN
  if refArea[0].len > 0 and refArea[1].len > 0 and o.showReferenceArea:
    let a = refValue(refArea[0], vals)
    let b = refValue(refArea[1], vals)
    (areaL, areaU) = (min(a, b), max(a, b))
  var pool = vals & present(all) & expandY
  for v in [refL, areaL, areaU]:
    if not v.isNaN: pool.add v
  let (lo, hi) = (pool.min, pool.max)
  func x(v: float): float = (if hi > lo: (v - lo) / (hi - lo) * fixedW else: fixedW / 2)
  let allInt = vals.allIt(it.isWhole)
  proc label(v: float, fn: proc (x: float): string): string = nanoplotLabel(v, allInt and v.isWhole, o.currency, fn)
  let mid = bottomY / 2
  let thick = o.dataPointRadius.at(0) * 6
  let (top, bot) = (mid - thick / 2, mid + thick / 2)
  let stroke = " stroke=\"" & o.dataBarStrokeColor.at(0) & "\" stroke-width=\"" & n(o.dataBarStrokeWidth.at(0)) & "\""
  proc vline(px, half: float): string =
    "<line x1=\"" & n(px) & "\" y1=\"" & n(mid - half) & "\" x2=\"" & n(px) & "\" y2=\"" & n(mid + half) & "\"" & stroke & "></line>"
  proc boxLabel(px, py: float, text, anchor: string): string =
    let w = text.len.float * 18
    let (l, r) = case anchor
      of "start": (0.0, w)
      of "middle": (w / 2, w / 2)
      else: (w, 0.0)
    hiddenText(max(l, min(px, fixedW - r)), py, text, anchor)
  var layers = ""
  if not areaL.isNaN:
    layers.add "<rect x=\"" & n(x(areaL)) & "\" y=\"" & n(mid - thick) & "\" width=\"" & n(x(areaU) - x(areaL)) &
      "\" height=\"" & n(2 * thick) & "\" stroke=\"transparent\" fill=\"" & o.referenceAreaFillColor & "\" fill-opacity=\"0.8\"></rect>"
  layers.add "<line x1=\"" & n(x(s.low)) & "\" y1=\"" & n(mid) & "\" x2=\"" & n(x(s.high)) & "\" y2=\"" & n(mid) & "\"" & stroke & "></line>"
  layers.add "<rect x=\"" & n(x(s.q1)) & "\" y=\"" & n(top) & "\" width=\"" & n(x(s.q3) - x(s.q1)) & "\" height=\"" &
    n(thick) & "\"" & stroke & " fill=\"white\"></rect>"
  layers.add vline(x(s.low), thick / 4) & vline(x(s.high), thick / 4)
  layers.add vline(x(s.median), thick / 2)
  if o.showDataPoints:
    if vals.len >= 20:
      for v in s.outliers:
        layers.add "<circle cx=\"" & n(x(v)) & "\" cy=\"" & n(mid) & "\" r=\"4\" stroke=\"" & o.dataBarStrokeColor.at(0) &
          "\" stroke-width=\"2\" fill=\"white\"></circle>"
    else:
      for i, v in vals:
        let off = if vals.len == 1: 0.0 else: thick / 5 * (2 * ((float(i + 1) * goldenConjugate) mod 1.0) - 1)
        layers.add "<circle cx=\"" & n(x(v)) & "\" cy=\"" & n(mid + off) & "\" r=\"" & (if vals.len < 10: "6" else: "4") &
          "\" stroke=\"#000000\" stroke-opacity=\"" & n(round(1 - vals.len / 25, 2)) & "\" stroke-width=\"2\" fill=\"transparent\"></circle>"
  let labels =
    if s.low == s.high: boxLabel(x(s.median), safeY + 15, label(s.median, o.yValFmtFn), "middle")
    else:
      boxLabel(x(s.low) - 10, mid + 10, label(s.low, o.yValFmtFn), "end") &
        boxLabel(x(s.q1) - 6, bottomY - 10, label(s.q1, o.yValFmtFn), "end") &
        boxLabel(x(s.median), safeY + 12.5, label(s.median, o.yValFmtFn), "middle") &
        boxLabel(x(s.q3) + 6, bottomY - 10, label(s.q3, o.yValFmtFn), "start") &
        boxLabel(x(s.high) + 10, mid + 10, label(s.high, o.yValFmtFn), "start")
  layers.add "<g class=\"boxplot-line\"><rect x=\"0\" y=\"" & n(top) & "\" width=\"" & n(fixedW) & "\" height=\"" & n(thick) &
    "\" stroke=\"transparent\" stroke-width=\"" & n(o.verticalGuideStrokeWidth) & "\" fill=\"transparent\"></rect>" & labels & "</g>"
  if not refL.isNaN:
    layers.add verticalRefLineTag(x(refL), mid - thick, mid + thick, o.referenceLineColor, label(refL, o.yRefLineFmtFn), x(refL) > fixedW / 2)
  layers

# ------------------------------------------------------------------------------------ the svg

func varsAsStyle(svg: string): string =
  ## Moves each `fill` or `stroke` that is a CSS variable (`fill="var(--primary)"`) into the
  ## element's `style`: SVG attributes take colours, not variables.
  var i = 0
  while i < svg.len:
    let a = svg.find('<', i)
    if a < 0: (result.add svg[i .. ^1]; break)
    let b = svg.find('>', a)
    result.add svg[i ..< a]
    var tag = svg[a .. b]
    var style: seq[string]
    for attr in ["fill", "stroke"]:
      let key = " " & attr & "=\"var("
      let k = tag.find(key)
      if k >= 0:
        let e = tag.find('"', k + attr.len + 3)
        style.add attr & ":" & tag[k + attr.len + 3 ..< e]
        tag = tag[0 ..< k] & tag[e + 1 .. ^1]
    if style.len > 0:
      let close = if tag.endsWith("/>"): tag.len - 2 else: tag.len - 1
      tag = tag[0 ..< close] & " style=\"" & style.join(";") & "\"" & tag[close .. ^1]
    result.add tag
    i = b + 1

proc nanoplotSummary*(y: seq[float], plotType: string, single = false): string =
  ## The values in words, for a screen reader: "Line plot of 8 values from 12 to 47, ending at 30".
  proc sl(x: float): string = nanoplotLabel(x, x.isWhole)
  let kind = if plotType == "line": "Line" elif plotType == "bar": "Bar" else: "Box"
  if single: return kind & " of " & sl(y[0])
  let p = present(y)
  let missing = if y.len > p.len: ", with " & $(y.len - p.len) & " missing" else: ""
  if p.len == 0: return kind & " plot with no values"
  if p.len == 1: return kind & " plot of 1 value: " & sl(p[0]) & missing
  if plotType == "boxplot":
    let s = boxStats(p)
    let outl = if s.outliers.len > 0: ", " & $s.outliers.len & " outlier" & (if s.outliers.len == 1: "" else: "s") else: ""
    return "Box plot of " & $p.len & " values: median " & sl(s.median) & ", quartiles " & sl(s.q1) &
      " and " & sl(s.q3) & ", whiskers from " & sl(s.low) & " to " & sl(s.high) & outl & missing
  kind & " plot of " & $p.len & " values from " & sl(p.min) & " to " & sl(p.max) &
    ", ending at " & sl(p[^1]) & missing

proc nanoplotSvg*(y: seq[float], plotType = "line", height = "2em", missingVals = "gap",
                  referenceLine = "", referenceArea = ("", ""), expandY: seq[float] = @[],
                  all: seq[float] = @[], single = false, options = nanoplotOptions(),
                  alt = "", x: seq[float] = @[], expandX: seq[float] = @[]): string =
  ## One nanoplot as inline SVG: a line, bar or box plot of the values `y` (NaN for a missing
  ## one), or with `single` a horizontal bar or line for `y[0]`, on the scale of `all` (the
  ## values of every row: single values and box plots share their scale). "" when there is
  ## nothing to plot. `alt` is read by a screen reader ("{x}" is a summary of the values).
  ## With `x` (as many as `y`) a line plot puts each value at its place on an x axis that also
  ## includes `expandX`; a bar plot and a box plot leave `x` out.
  if plotType notin ["line", "bar", "boxplot"]:
    raise newException(ValueError, "plotType is \"line\", \"bar\" or \"boxplot\", not " & plotType.escape)
  if missingVals notin ["gap", "marker", "zero", "remove"]:
    raise newException(ValueError, "missingVals is \"gap\", \"marker\", \"zero\" or \"remove\", not " & missingVals.escape)
  var vals = y
  var xv = x
  if xv.len > 0:
    if xv.len != y.len: raise newException(ValueError, "a nanoplot has " & $y.len & " values and " & $xv.len & " places on the x axis")
    (vals, xv) = byX(vals, xv)
  case missingVals
  of "zero": vals = vals.mapIt(if it.isNaN: 0.0 else: it)
  of "remove":
    if xv.len > 0:
      var (v2, x2) = (newSeq[float](), newSeq[float]())
      for i, v in vals:
        if not v.isNaN: (v2.add v; x2.add xv[i])
      (vals, xv) = (v2, x2)
    else: vals = present(vals)
  else: discard
  if present(vals).len == 0: return ""
  let summary = nanoplotSummary(vals, plotType, single and plotType != "boxplot")
  let label = if alt.len > 0: alt.replace("{x}", summary) else: summary
  var viewBox = "0 0 " & n(fixedW) & " " & n(bottomY)
  var layers: string
  if plotType == "boxplot": layers = boxplot(vals, all, referenceLine, referenceArea, expandY, options)
  elif single: layers = singleValue(vals[0], all, plotType, referenceLine, options)
  else: (viewBox, layers) = severalValues(vals, plotType, missingVals, referenceLine, referenceArea, expandY, options, xv, expandX)
  let o = options
  let defs = "<defs><pattern id=\"" & patternId(o.dataAreaFillColor) & "\" width=\"8\" height=\"8\" patternUnits=\"userSpaceOnUse\">" &
    "<path class=\"pattern-line\" d=\"M 0,8 l 8,-8 M -1,1 l 4,-4 M 6,10 l 4,-4\" stroke=\"" & o.dataAreaFillColor &
    "\" stroke-width=\"1.5\" stroke-linecap=\"round\" shape-rendering=\"geometricPrecision\"></path></pattern></defs>"
  let cls = if o.interactiveDataValues: "tb_nanoplot" else: "tb_nanoplot tb_nanoplot_static"
  "<svg class=\"" & cls & "\" role=\"img\" aria-label=\"" & escapeHtml(label) & "\" viewBox=\"" & viewBox &
    "\" style=\"height: " & height & "; --tb-guide: " & o.verticalGuideStrokeColor &
    "; margin-left: auto; margin-right: auto; font-size: inherit; overflow: visible; vertical-align: middle; position: relative;\">" &
    varsAsStyle(defs & layers) & "</svg>"

# ---------------------------------------------------------------------------------- in text

const sparks = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]

proc nanoplotText*(y: seq[float], plotType = "line", missingVals = "gap", all: seq[float] = @[],
                   single = false, expandY: seq[float] = @[], options = nanoplotOptions()): string =
  ## A nanoplot in text: a sparkline of the values ("▁▃▅█ 1–9", on the axis of `expandY` too), a
  ## bar of blocks for a single value, left of a zero line when it is negative ("███│ −4", "│█ 2"),
  ## the five numbers of a box plot ("1 ┤2 │3│ 5├ 9").
  var vals = y
  case missingVals
  of "zero": vals = vals.mapIt(if it.isNaN: 0.0 else: it)
  of "remove": vals = present(vals)
  else: discard
  let p = present(vals)
  if p.len == 0: return ""
  let integerlike = p.allIt(it.isWhole)
  proc lab(x: float): string = nanoplotLabel(x, integerlike and x.isWhole, options.currency, options.yValFmtFn)
  if plotType == "boxplot":
    let s = boxStats(p)
    return lab(s.low) & " ┤" & lab(s.q1) & " │" & lab(s.median) & "│ " & lab(s.q3) & "├ " & lab(s.high)
  if single:
    let others = present(all) & @[vals[0], 0.0]
    let (lo, hi) = (others.min, others.max)
    let span = hi - lo
    let cells = proc (x: float): int = (if span > 0: int(round(abs(x) / span * 10)) else: 0)
    let v = vals[0]
    # the labels of the column are as wide as the widest, so the zero lines line up
    var w = 0
    for x in others: w = max(w, lab(x).runeLen)
    let label = lab(v) & " ".repeat(w - lab(v).runeLen)
    if lo >= 0: return "█".repeat(cells(v)) & " ".repeat(10 - cells(v)) & " " & label
    let left = cells(lo)
    let bar = if v < 0: " ".repeat(left - cells(v)) & "█".repeat(cells(v)) & "│" & " ".repeat(10 - left)
              else: " ".repeat(left) & "│" & "█".repeat(cells(v)) & " ".repeat(max(0, 10 - left - cells(v)))
    return bar & " " & label
  var lo = min(p.min, if expandY.len > 0: expandY.min else: Inf)
  var hi = max(p.max, if expandY.len > 0: expandY.max else: -Inf)
  if plotType == "bar": (lo = min(lo, 0.0); hi = max(hi, 0.0))
  for v in vals:
    if v.isNaN: result.add(if missingVals == "marker": "×" else: " ")
    else:
      let k = if hi > lo: int(round((v - lo) / (hi - lo) * 7)) else: 3
      result.add sparks[k]
  result.add " " & lab(p.min) & "–" & lab(p.max)

# ---------------------------------------------------------------------------------- the verbs

proc fmtNanoplot*(t: sink Tabella, columns: ColSel, rows = allRows(), plotType = "line",
                  plotHeight = "2em", missingVals = "gap", autoscale = false,
                  referenceLine = "", referenceArea = ("", ""), expandY: seq[float] = @[],
                  options = nanoplotOptions(), alt = "", expandX: seq[float] = @[]): Tabella =
  ## Nanoplots of the values in each cell (see `nanoplotValues`: a list, a record of `x` and `y`,
  ## or a text of numbers): a line plot ("line"), a bar plot
  ## ("bar") or a box plot ("boxplot"). A numeric column gets one horizontal bar or line per row,
  ## from a zero line shared by the rows. `referenceLine` is a number ("10") or a statistic of the
  ## cell's values ("mean", "median", "min", "max", "q1", "q3", "first", "last"), and
  ## `referenceArea` two of them. `missingVals` says what a missing value does: "gap" breaks the
  ## line, "marker" marks it, "zero" counts it as 0, "remove" leaves it out. With `autoscale`
  ## every plot of the column has the same y axis (and x axis, for records of `x` and `y`);
  ## `expandY` and `expandX` widen them to include some values. In text output a nanoplot is a
  ## sparkline, its values in the order of `x`.
  if plotType notin ["line", "bar", "boxplot"]:
    raise newException(ValueError, "plotType is \"line\", \"bar\" or \"boxplot\", not " & plotType.escape)
  if missingVals notin ["gap", "marker", "zero", "remove"]:
    raise newException(ValueError, "missingVals is \"gap\", \"marker\", \"zero\" or \"remove\", not " & missingVals.escape)
  for r in [referenceLine, referenceArea[0], referenceArea[1]]:
    if r.len > 0: discard refValue(r, [1.0])
  let names = columns.resolve(t.data)
  let ix = rows.resolve(t.data)
  result = t
  for name in names:
    let single = result.data[name].isNumeric
    var all, allX: seq[float]
    for i in ix:
      let cell = result.data[name, i]
      let ys = nanoplotValues(cell)
      let xs = nanoplotXValues(cell)
      if xs.len > 0 and xs.len != ys.len:
        raise newException(ValueError, "row " & $i & " of " & name.escape & " has " & $ys.len & " values of y and " & $xs.len & " of x")
      allX.add present(xs)
      for v in ys:
        if not v.isNaN: all.add v
        elif missingVals == "zero": all.add 0.0
    var ey = expandY
    if autoscale and not single and all.len > 0: ey = @[all.min, all.max] & expandY
    var ex = expandX
    if autoscale and allX.len > 0: ex = @[allX.min, allX.max] & expandX
    let (pt, ph, mv, rl, ra, o, a) = (plotType, plotHeight, missingVals, referenceLine, referenceArea, options, alt)
    result = fmt(result, name, proc (v: Value, ctx: RenderContext): string =
      var y = nanoplotValues(v)
      let x = nanoplotXValues(v)
      if ctx == rcText:
        if x.len > 0: y = byX(y, x)[0]
        nanoplotText(y, pt, mv, all, single, ey, o)
      else: nanoplotSvg(y, pt, ph, mv, rl, ra, ey, all, single, o, a, x, ex), rows)
    result.formats[^1].wholeValue = true

proc colsNanoplot*(t: sink Tabella, columns: ColSel, rows = allRows(), plotType = "line",
                   plotHeight = "2em", missingVals = "gap", autoscale = false,
                   referenceLine = "", referenceArea = ("", ""), expandY: seq[float] = @[],
                   newColName = "nanoplots", newColLabel = "", before = "", after = "",
                   autohide = true, options = nanoplotOptions(), alt = ""): Tabella =
  ## A new column of nanoplots, one per row, of the values of several `columns` (in their order):
  ## after gt's `cols_nanoplot()`. The columns are hidden (`autohide`); the new one is
  ## `newColName`, labelled `newColLabel` (its name by default), at the end or `before` or
  ## `after` a column. The other arguments are those of `fmtNanoplot`.
  let names = columns.resolve(t.data)
  if names.len == 0: raise newException(ValueError, "colsNanoplot needs columns of numbers")
  var cells: seq[Value]
  for i in 0 ..< t.data.nrows:
    var parts: seq[string]
    for name in names:
      let v = t.data[name, i]
      parts.add(if v.isNumber: $v.toFloat else: "NA")
    cells.add toValue(parts.join(" "))
  result = colsAdd(t, newColName, cells, before, after)
  if autohide: result = colsHide(result, names)
  result = colsLabel(result, newColName, toText(if newColLabel.len > 0: newColLabel else: newColName))
  result = fmtNanoplot(result, newColName, rows, plotType, plotHeight, missingVals, autoscale,
                       referenceLine, referenceArea, expandY, options, alt)
