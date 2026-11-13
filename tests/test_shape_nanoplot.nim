## Shape nanoplots: a record of x and y drawn as one closed outline (plotType = "shape").
import std/[unittest, strutils, math]
import tabelline

let square = toValue((x: @[0, 2, 2, 0], y: @[0, 0, 2, 2]))
let strip = toValue((x: @[0, 4, 4, 0], y: @[0, 0, 1, 1]))

suite "shape nanoplots":
  test "points in their order, closed, at one scale across and up":
    let svg = nanoplotSvg(@[0.0, 0, 2, 2], "shape", x = @[0.0, 2, 2, 0])
    check "class=\"tb_shape\"" in svg
    check "M0,100 L100,100 L100,0 L0,0 Z" in svg.replace("\"", " ").replace(" Z ", " Z")
    # a strip 4 by 1 fills the square across and a quarter of it up
    let s2 = nanoplotSvg(@[0.0, 0, 1, 1], "shape", x = @[0.0, 4, 4, 0])
    check "M0,62.5 L100,62.5 L100,37.5 L0,37.5 Z" in s2
    check "aria-label=\"Shape of 4 points\"" in s2

  test "the points are not sorted by x":
    let s = nanoplotSvg(@[0.0, 2, 0], "shape", x = @[2.0, 1, 0])
    check "M100,100 L50,0 L0,100 Z" in s

  test "autoscale: every shape at the scale of the largest":
    let d = tableData:
      field: ["square", "strip"]
      outline: [square, strip]
    let html = tabella(d, rownameCol = "field").fmtNanoplot("outline", plotType = "shape", autoscale = true).toHtml
    # the square, 2 wide, is half the side of the strip's 4
    check "M25,75 L75,75 L75,25 L25,25 Z" in html
    let own = tabella(d).fmtNanoplot("outline", plotType = "shape").toHtml
    check "M0,100 L100,100 L100,0 L0,0 Z" in own

  test "a missing value starts a new ring":
    let s = nanoplotSvg(@[0.0, 0, 1, NaN, 3, 3, 4], "shape", x = @[0.0, 1, 0, NaN, 3, 4, 3])
    check s.count("M") == 2 and s.count("Z") == 2

  test "colours, text and errors":
    let o = nanoplotOptions(dataBarFillColor = "var(--secondary)", dataBarStrokeColor = "navy")
    let s = nanoplotSvg(@[0.0, 0, 1], "shape", x = @[0.0, 1, 0], options = o)
    check "fill:var(--secondary)" in s and "stroke=\"navy\"" in s
    check "fill=\"none\"" in nanoplotSvg(@[0.0, 0, 1], "shape", x = @[0.0, 1, 0], options = nanoplotOptions(showDataArea = false))
    let d = tableData:
      a: [square]
    check $tabella(d).fmtNanoplot("a", plotType = "shape") == $tabella(d).fmtNanoplot("a", plotType = "shape")
    check "◆ shape of 4 points" in $tabella(d).fmtNanoplot("a", plotType = "shape")
    let bad = tableData:
      a: [toValue(@[1, 2, 3])]
    expect ValueError: discard tabella(bad).fmtNanoplot("a", plotType = "shape")
    expect ValueError: discard nanoplotSvg(@[1.0, 2], "shape", x = @[1.0])
    check shapeSide(@[0.0, 1], @[0.0, 4]) == 4.0
