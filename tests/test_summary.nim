## Edge cases of summary rows (the specs' examples cover the main path).
import std/[unittest, strutils, sequtils, sugar]
import tabelline, tabelline/datasets

proc vals(xs: varargs[Value]): seq[Value] = @xs

suite "aggregates":
  test "built in":
    check agg.sum.fn(vals(1.toValue, 2.toValue)) == 3.toValue
    check agg.sum.fn(vals(1.toValue, 2.toValue)).kind == vkInt
    check agg.sum.fn(vals(1.toValue, 0.5.toValue)).kind == vkFloat
    check agg.sum.fn(@[]).isNull
    check agg.mean.fn(vals(1.toValue, 2.toValue)) == 1.5
    check agg.median.fn(vals(3.toValue, 1.toValue, 2.toValue)) == 2
    check agg.median.fn(vals(4.toValue, 1.toValue, 2.toValue, 3.toValue)) == 2.5
    check agg.min.fn(vals("b".toValue, "a".toValue)) == "a"
    check agg.max.fn(vals(1.toValue, 5.toValue, 2.toValue)) == 5
    check agg.count.fn(vals(1.toValue, "x".toValue)) == 2
    check agg.std.fn(vals(2.toValue, 4.toValue, 4.toValue, 4.toValue, 5.toValue, 5.toValue, 7.toValue, 9.toValue)).toFloat > 2.13
    check agg.std.fn(vals(1.toValue)).isNull
  test "of your own":
    let a = aggregate(proc (vs: seq[Value]): int = vs.len * 10, "tens")
    check a.fn(vals(1.toValue)) == 10
    check a.name == "tens"

suite "summary rows":
  let base = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
    .colsHide(["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"])
  test "per group, above":
    let b = base.summaryRows(fns = {"n": agg.count}, side = sTop).build(rcText)
    check b.groups[0].summaryTop.len == 1
    check b.groups[0].summaryBottom.len == 0
    check b.groups[0].summaryTop[0].cells == @["4"]
  test "only some groups":
    let b = base.summaryRows(fns = {"total": agg.sum}, groups = ["Ice giant"]).build(rcText)
    check b.groups.mapIt(it.summaryBottom.len) == @[0, 0, 1]
  test "needs groups":
    expect ValueError:
      discard tabella(planets()).summaryRows(fns = {"total": agg.sum})
    expect KeyError:
      discard base.summaryRows(fns = {"total": agg.sum}, groups = ["Dwarf"])
  test "side must be top or bottom":
    expect ValueError:
      discard base.grandSummaryRows(fns = {"total": agg.sum}, side = sLeft)
  test "nothing to sum up":
    let t = tabella(toTableData({"g": toValues(["a", "a"]), "x": @[null(), null()]}), groupnameCol = "g")
      .summaryRows(fns = {"total": agg.sum}, columns = "x", missingText = "n/a")
    check t.build(rcText).groups[0].summaryBottom[0].cells == @["n/a"]
  test "columns not summarised":
    let b = tabella(planets()).colsHide(numeric()).colsUnhide("moons")
      .grandSummaryRows(fns = {"total": agg.sum}, columns = "moons").build(rcText)
    check b.grandBottom[0].cells == @["—", "—", "288", "—"]   # planet, type, moons, rings
  test "formats: the column's, count as an integer, or fmt":
    let t = base.fmtNumber("moons", decimals = 1)
    check t.grandSummaryRows(fns = {"total": agg.sum}).build(rcText).grandBottom[0].cells == @["288.0"]
    check t.grandSummaryRows(fns = {"n": agg.count}).build(rcText).grandBottom[0].cells == @["8"]
    check t.grandSummaryRows(fns = {"total": agg.sum}, fmt = (x: float) => $int(x) & " moons")
      .build(rcText).grandBottom[0].cells == @["288 moons"]
  test "a stub for the labels":
    let t = tabella(planets()).colsHide(numeric()).colsUnhide("moons")
      .grandSummaryRows(fns = {"total": agg.sum}, columns = "moons")
    check t.hasStub
    check "│ total │" in $t
  test "html: classes, styles and footnotes":
    let h = base.summaryRows(fns = {"total": agg.sum}).grandSummaryRows(fns = {"all": agg.sum}, side = sTop)
      .tabStyle(style.fill("red"), loc.summary(groups = ["Gas giant"]))
      .tabStyle(style.text(weight = "bold"), loc.grandSummaryStub())
      .tabFootnote("all of them", loc.grandSummary(columns = "moons"))
      .toHtml
    check h.count("tb_first_summary_row\"") + h.count("tb_first_summary_row ") >= 3
    check "tb_last_grand_summary_row_top" in h
    check h.count("background-color: red") == 1
    check "font-weight: bold\">all" in h
    check "tb_footnote_marks" in h
  test "footnote numbers in reading order":
    let b = base.grandSummaryRows(fns = {"all": agg.sum}, side = sTop)
      .tabFootnote("second", loc.body(cols = "moons", rows = [0]))
      .tabFootnote("first", loc.grandSummary())
      .build(rcText)
    check b.notes == @["first", "second"]
  test "markdown":
    let md = base.summaryRows(fns = {"total": agg.sum}).toMarkdown
    check "| *total* | 3 |" in md

suite "row groups (0.1.0 fix)":
  test "a row with no group is shown once, before the groups":
    let d = tableData:
      g: ["a", "b", nil]
      x: [1, 2, 3]
    let b = tabella(d, groupnameCol = "g").build(rcText)
    check b.groups.mapIt(it.id) == @["", "a", "b"]
    check b.groups.mapIt(it.rows.mapIt(it.cells[0])) == @[@["3"], @["1"], @["2"]]
