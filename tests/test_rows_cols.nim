## Edge cases of merges, added and hidden rows and columns, stub indent and decimal alignment.
import std/[unittest, strutils, sequtils, tables]
import tabelline, tabelline/datasets

suite "merges":
  test "pattern parts dropped when a value is missing":
    check fillPattern("{1}<< ({2})>>", @["a", ""], @[false, true]) == "a"
    check fillPattern("{1}<< ({2})>>", @["a", "b"], @[false, false]) == "a (b)"
    check fillPattern("{2}–{1}", @["a", "b"], @[false, false]) == "b–a"
  test "merged cells use the formats, and hide the other columns":
    let t = tabella(planets(), rownameCol = "planet").fmtInteger("diameter")
      .colsMerge(["mass", "diameter"], pattern = "{1} / {2}")
    check "diameter" notin t.visibleData.mapIt(it.name)
    check t.build(rcText).groups[0].rows[2].cells[t.visibleData.mapIt(it.name).find("mass")] == "5.97 / 12,756"
  test "only some rows":
    let t = tabella(planets()).colsMergeRange("moons", "distance", rows = [0])
    let b = t.build(rcText)
    let j = t.visibleData.mapIt(it.name).find("moons")
    check b.groups[0].rows[0].cells[j] == "0–57.9"
    check b.groups[0].rows[1].cells[j] == "0"
  test "n and percent":
    let d = tableData:
      n: [0, 3, 4]
      pct: [0.0, 0.25, nil]
    let b = tabella(d).fmtPercent("pct", decimals = 0).colsMergeNPct("n", "pct").build(rcText)
    check b.groups[0].rows.mapIt(it.cells[0]) == @["0", "3 (25%)", "4"]
  test "a column that does not exist":
    expect KeyError:
      discard tabella(planets()).colsMerge(["mass", "weight"])

suite "added columns and rows":
  test "columns at a place, the data of the old table untouched":
    let base = tabella(planets())
    let t = base.colsAdd("n", toSeq(1..8), after = "planet")
    check t.boxhead.mapIt(it.name)[0 .. 1] == @["planet", "n"]
    check not base.data.hasColumn("n")
    expect KeyError:
      discard base.colsAdd("x", toSeq(1..8), before = "nothing")
  test "summary columns, then summary rows of them":
    let t = tabella(planets(), rownameCol = "planet").colsHide(everything()).colsUnhide(["mass", "moons"])
      .summaryColumns(fns = {"both": agg.sum, "n": agg.count}, columns = ["mass", "moons"], side = sLeft)
      .grandSummaryRows(fns = {"total": agg.sum}, columns = ["moons", "n"])
    check t.visibleData.mapIt(it.name) == @["both", "n", "mass", "moons"]
    let b = t.build(rcText)
    check b.groups[0].rows[2].cells[0] == "6.97"
    check b.grandBottom[0].cells == @["—", "16", "—", "288"]
  test "rows: at the end, before, in a new group":
    let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
      .rowsAdd([(planet: "Pluto", `type`: "Dwarf", moons: 5)])
      .rowsAdd([(planet: "Ceres", `type`: "Dwarf", moons: 0)], before = 8)
    let b = t.build(rcText)
    check b.groups[^1].label == "Dwarf"
    check b.groups[^1].rows.mapIt(it.stub) == @["Ceres", "Pluto"]
    check t.data.nrows == 10
    expect KeyError:
      discard t.rowsAdd([(weight: 1)])
  test "hidden rows are not shown nor summed up":
    let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
      .rowsHide(where(it["planet"] == "Saturn"))
      .summaryRows(fns = {"moons": agg.sum}, columns = "moons")
    let b = t.build(rcText)
    check b.groups[1].rows.mapIt(it.stub) == @["Jupiter"]
    check b.groups[1].summaryBottom[0].cells[t.visibleData.mapIt(it.name).find("moons")] == "95"
    check t.rowsUnhide().build(rcText).groups[1].rows.len == 2

suite "stub indent and decimal alignment":
  test "levels from 0 to 5":
    let t = tabella(planets(), rownameCol = "planet").tabStubIndent([0], 7).tabStubIndent([1], "decrease")
      .tabStubIndent([2], "increase").tabStubIndent([2], "increase")
    check t.indents[0] == 5
    check t.indents[1] == 0
    check t.indents[2] == 2
    check "tb_indent_2" in t.toHtml
    expect ValueError:
      discard t.tabStubIndent([0], "more")
  test "decimal marks line up":
    let d = tableData:
      x: [1.5, 10.25, 3.0]
      y: [1, 22, 333]
    let b = tabella(d).fmtNumber("x", decimals = 2, dropTrailingZeros = true)
      .colsAlignDecimal("x").build(rcText)
    check b.groups[0].rows.mapIt(it.cells[0]) == @["1.5 ", "10.25", "3   "]
  test "a comma for an Italian table":
    let d = tableData:
      x: [1.5, 10.25]
    let b = tabella(d, locale = "it").fmtNumber("x", decimals = 2, dropTrailingZeros = true)
      .colsAlignDecimal("x").build(rcText)
    check b.groups[0].rows.mapIt(it.cells[0]) == @["1,5 ", "10,25"]
