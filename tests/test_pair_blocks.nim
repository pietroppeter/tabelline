## The indented block form of the verbs that take a list of pairs.
import std/[unittest, strutils, sugar]
import tabelline, tabelline/datasets

suite "blocks for lists of pairs":
  test "the same table as the pair form":
    let a = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
      colsLabel:
        mass: "mass, {{10^24 kg}}"
        `day_length`: "day"
      colsWidth:
        mass: "20%"
      colsUnits:
        diameter: "km"
      summaryRows:
        total: agg.sum
        "most of all": agg.max
        columns = "mass"
        missingText = ""
      grandSummaryRows:
        mean: agg.mean
        fmtNumber(decimals = 1)
      summaryColumns:
        both: agg.sum
        columns = ["moons", "diameter"]
      tabOptions:
        rowStriping = true
        headingAlign = "left"
    var b = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
    b = b.colsLabel({"mass": "mass, {{10^24 kg}}", "day_length": "day"}).colsWidth({"mass": "20%"})
      .colsUnits({"diameter": "km"})
      .summaryRows(fns = {"total": agg.sum, "most of all": agg.max}, columns = "mass", missingText = "")
      .grandSummaryRows(fns = {"mean": agg.mean}, fmt = (x: float) => formatNumber(x, decimals = 1))
      .summaryColumns(fns = {"both": agg.sum}, columns = ["moons", "diameter"])
      .tabOptions(rowStriping = true, headingAlign = "left")
    check a.toText == b.toText
    check a.toHtml == b.toHtml
  test "textCaseMatch and a named argument in any verb":
    let t = tabella(planets()):
      textCaseMatch:
        "Gas giant": "giant"
        "Ice giant": "giant"
        default = "rock"
        locations = loc.body("type")
      fmtNumber:
        columns = "mass"
        decimals = 0
    check t.toText.count("giant") == 4
    check t.toText.count("rock") == 4
    check t.toText.contains("1,898 ")
