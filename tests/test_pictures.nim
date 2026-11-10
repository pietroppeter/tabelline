## Pictures in cells: icons, images and nanoplots.
import std/[unittest, strutils, os, math]
import tabelline, tabelline/datasets

suite "icons":
  test "names, full names and older names":
    check icon("star").style == "regular"
    check icon("fas fa-star").style == "solid"
    check icon("fa-solid fa-star").style == "solid"
    check icon("fab fa-github").style == "brands"
    check icon("github").style == "brands"
    check icon("user-large").name == "user"
    check not hasIcon("no-such-icon")
    check not hasIcon("far fa-github")
    expect ValueError: discard icon("no-such-icon")
  test "inline SVG, as wide as its shape":
    let s = iconSvg("star", height = "2em")
    check s.startsWith("<svg viewBox=\"0 0 576 512\" role=\"img\" aria-label=\"Star\"")
    check "height:2em;width:2.25em" in s
    check "fill:currentColor" in s
    check "aria-hidden" in iconSvg("star", a11y = "decorative")
    expect ValueError: discard iconSvg("star", height = "big")
  test "fmtIcon: several per cell, colours by name, names in text":
    let d = tableData:
      icon: ["star", "circle-check, circle-xmark", nil]
    let t = tabella(d):
      fmtIcon "icon", fillColor = "gray", fillColors = {"circle-check": "green"}
    let html = t.toHtml
    check html.count("class=\"tb_icon\"") == 3
    check html.count("fill:green") == 1 and html.count("fill:gray") == 2
    check "circle-check, circle-xmark" in t.toText
    expect ValueError: discard tabella(d).fmtIcon("icon", a11y = "loud")
  test "an unknown icon fails when the verb is called":
    let d = tableData:
      icon: ["star", "nope"]
    expect ValueError: discard tabella(d).fmtIcon("icon")

suite "images":
  let dir = getTempDir() / "tabelline-images"
  createDir(dir)
  writeFile(dir / "dot.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2 2"><circle cx="1" cy="1" r="1"/></svg>""")
  test "a file is inlined as a data URL":
    check imageDataUrl(dir / "dot.svg").startsWith("data:image/svg+xml;base64,PHN2Zy")
    expect ValueError: discard imageDataUrl(dir / "none.png")
    expect ValueError: discard imageDataUrl(dir / "dot.txt")
  test "fmtImage: path, pattern, size, alt; addresses left as they are":
    let d = tableData:
      pic: ["dot", "dot, dot"]
    let t = tabella(d):
      fmtImage "pic", path = dir, filePattern = "{x}.svg", height = "3em", alt = "a {x}"
    let html = t.toHtml
    check html.count("<img src=\"data:image/svg+xml;base64,") == 3
    check "alt=\"a dot\"" in html and "height:3em" in html
    check "dot, dot" in t.toText
    let u = tabella(d).fmtImage("pic", path = "https://example.org/img", filePattern = "{x}.png").toHtml
    check "src=\"https://example.org/img/dot.png\"" in u and "height:2em" in u
    expect ValueError: discard tabella(d).fmtImage("pic", path = dir)

suite "nanoplots":
  test "values from a cell":
    check nanoplotValues(toValue("1 2, 3;4")) == @[1.0, 2, 3, 4]
    check nanoplotValues(toValue(2.5)) == @[2.5]
    check nanoplotValues(toValue("[1, NA]"))[1].isNaN
    check nanoplotValues(null()).len == 0
    expect ValueError: discard nanoplotValues(toValue("1 two"))
  test "labels, short":
    check nanoplotLabel(0) == "0"
    check nanoplotLabel(12, asInteger = true) == "12"
    check nanoplotLabel(2.5) == "2.50"
    check nanoplotLabel(123.4) == "123"
    check nanoplotLabel(999.6) == "1.00K"
    check nanoplotLabel(12345) == "12.3K"
    check nanoplotLabel(999999) == "1.00M"
    check nanoplotLabel(0.005) == "5.0E−3"
    check nanoplotLabel(-0.3) == "−0.30"
    check nanoplotLabel(1500, currency = "EUR") == "€1.5K"
  test "a line, a bar and a box plot":
    let line = nanoplotSvg(@[1.0, 4, 2, 8])
    check line.count("<circle") == 4 and line.count("class=\"vert-line\"") == 4
    check "aria-label=\"Line plot of 4 values from 1 to 8, ending at 8\"" in line
    check "viewBox=\"0 0 300 130\"" in line
    let bar = nanoplotSvg(@[3.0, -1, 0], plotType = "bar")
    check bar.count("<rect") >= 3 and "#D75A68" in bar and "#808080" in bar
    let box = nanoplotSvg(@[1.0, 2, 3, 4, 100], plotType = "boxplot")
    check "class=\"boxplot-line\"" in box and "1 outlier" in box
  test "missing values: gap, marker, zero, remove":
    let y = @[1.0, NaN, 3, 4]
    check nanoplotSvg(y).count("<path d=\"M") == 2
    check "stroke=\"red\"" in nanoplotSvg(y, missingVals = "marker")
    check "with 1 missing" notin nanoplotSvg(y, missingVals = "zero")
    check "of 3 values" in nanoplotSvg(y, missingVals = "remove")
    check nanoplotSvg(@[NaN]) == ""
    expect ValueError: discard nanoplotSvg(y, missingVals = "skip")
  test "reference lines and areas":
    let s = nanoplotSvg(@[1.0, 5, 3], referenceLine = "mean", referenceArea = ("q1", "4"))
    check "class=\"ref-line\"" in s and "#A6E6F2" in s
    check ">3</text>" in s
    expect ValueError: discard nanoplotSvg(@[1.0, 2], referenceLine = "average")
  test "fmtNanoplot: a single number per row is a bar from a shared zero line":
    let d = tableData:
      x: [4.0, -2, 8]
    let t = tabella(d).fmtNanoplot("x", plotType = "bar")
    let html = t.toHtml
    check html.count("class=\"horizontal-line\"") == 3
    check ".tb_nanoplot .vert-line:hover" in html
    check "  │████     4  │" in t.toText and " ██│         −2 │" in t.toText
  test "fmtNanoplot in text: sparklines":
    let d = tableData:
      trend: ["1 2 3 4 5 6 7 8", "8 1", nil]
    let t = tabella(d).fmtNanoplot("trend")
    check "▁▂▃▄▅▆▇█ 1–8" in t.toText
    check "█▁ 1–8" in t.toText
    check tabella(d).fmtNanoplot("trend", plotType = "boxplot").toText.contains("1 ┤2.75 │4.50│ 6.25├ 8")
  test "autoscale shares the y axis":
    let d = tableData:
      trend: ["1 2", "10 20"]
    let a = tabella(d).fmtNanoplot("trend", autoscale = true).toHtml
    check a.count(">20</text>") >= 2
  test "no nanoplot CSS without nanoplots":
    check ".tb_nanoplot" notin tabella(planets()).toHtml
  test "colsNanoplot: a plot of several columns":
    let d = tableData:
      name: ["a", "b"]
      q1: [1, 4]
      q2: [3, nil]
      q3: [2, 6]
    let t = tabella(d, rownameCol = "name"):
      colsNanoplot ["q1", "q2", "q3"], newColLabel = "Quarters", plotType = "bar"
    let txt = t.toText
    check "Quarters" in txt and "q1" notin txt
    check t.toHtml.count("class=\"tb_nanoplot\"") == 2
    let kept = tabella(d).colsNanoplot(["q1", "q2"], autohide = false, after = "name", newColName = "p").toText
    check "q1" in kept
  test "colours can be CSS variables":
    let s = nanoplotSvg(@[1.0, -2], plotType = "bar",
                        options = nanoplotOptions(dataBarFillColor = "var(--primary)", dataBarNegativeFillColor = "var(--secondary)"))
    check "style=\"fill:var(--primary)\"" in s and "style=\"fill:var(--secondary)\"" in s
    check "fill=\"var(" notin s
