## Rotated labels, styles from the data, the preview of a big table, and the built table as data.
import std/[unittest, strutils, sugar]
import tabelline, tabelline/datasets

let d = tableData:
  name: ["Mercury", "Earth", "Mars"]
  colour: ["#b1adad", "#4f7cac", nil]
  moons: [0, 1, 2]

suite "rotated labels":
  test "two directions, HTML only":
    let t = tabella(d).colsLabelRotate("moons", dir = "sideways-rl")
    check t.toHtml.count("writing-mode: vertical-rl; text-align") == 1
    check t.toText == tabella(d).toText
    expect ValueError: discard tabella(d).colsLabelRotate("moons", dir = "up")

suite "styles from the data":
  test "fromColumn, with a value for missing ones":
    let html = tabella(d).tabStyle(style.fill(fromColumn("colour")), loc.body("name")).toHtml(withStyle = false)
    check html.count("style=\"background-color: #") == 2
    expect KeyError: discard tabella(d).tabStyle(style.fill(fromColumn("nope")), loc.body("name"))
    expect ValueError: discard tabella(d).tabStyle(style.fill(fromColumn("colour")), loc.title())
  test "a proc of the row":
    let html = tabella(d).tabStyle((r: Row) => (if r["moons"] > 0: style.text(weight = "bold") else: CellStyle()),
                                   loc.body("name")).toHtml(withStyle = false)
    check html.count("font-weight: bold") == 2
  test "tabStyleBody: values, pattern, fn, targets":
    check tabella(d).tabStyleBody(style.text(weight = "bold"), values = ["2"]).toHtml(withStyle = false).count("font-weight: bold") == 1
    check tabella(d).tabStyleBody(style.text(weight = "bold"), pattern = "rs").toHtml(withStyle = false).count("font-weight: bold") == 1
    check tabella(d).tabStyleBody(style.text(weight = "bold"), columns = "moons",
                                  fn = (v: Value) => v > 0, targets = "column").toHtml(withStyle = false).count("font-weight: bold") == 3
    expect ValueError: discard tabella(d).tabStyleBody(style.text(weight = "bold"))
    expect ValueError: discard tabella(d).tabStyleBody(style.text(weight = "bold"), values = ["x"], targets = "table")

suite "preview":
  test "a small table whole, row numbers optional":
    check tabellaPreview(d).toText.count("..") == 0
    let p = tabellaPreview(planets(), topN = 2, bottomN = 2, inclRownums = false)
    check p.toText.contains("3..6")
    check not p.toText.contains("│ 1 ")

suite "extract":
  test "cells, body and summary":
    let t = tabella(d, rownameCol = "name").fmtNumber("moons", decimals = 1).grandSummaryRows(fns = {"all": agg.sum})
    check extractCells(t, "moons") == @["0.0", "1.0", "2.0"]
    check extractCells(t, "name", rows = [1]) == @["Earth"]
    let body = extractBody(t)
    check body.names == @["rowname", "colour", "moons"]
    check $body["moons", 2] == "2.0"
    let s = extractSummary(t)
    check $s["label", 0] == "all" and $s["moons", 0] == "3.0" and $s["group", 0] == ""
    check extractCells(tabella(d).fmtMarkdown("name"), "name", ctx = rcHtml).len == 3
