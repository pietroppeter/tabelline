## A shared x axis lines the rows up, and `referenceX` draws vertical lines on it.
import std/[unittest, strutils, re]
import tabelline

proc viewBoxes(html: string): seq[string] =
  for m in html.findAll(re"""viewBox="[^"]*""""): result.add m

suite "nanoplots on a shared x axis":
  let d = tableData:
    island: ["long", "short"]
    years: [toValue((x: @["2000-07-01", "2010-07-01", "2020-07-01", "2024-07-01"], y: @[1.0, 3, 1, 4])),
            toValue((x: @["2015-07-01", "2019-07-01", "2020-07-01"], y: @[2.0, 3, 1]))]

  test "every row has the same width, so the axes line up":
    let t = tabella(d, rownameCol = "island"):
      fmtNanoplot "years", expandX = @[946_684_800.0, 1_735_689_600.0]
    let vb = t.toHtml.viewBoxes
    check vb.len == 2
    check vb[0] == vb[1]

  test "without a shared axis a row is as wide as its points":
    let t = tabella(d, rownameCol = "island"):
      fmtNanoplot "years"
    let vb = t.toHtml.viewBoxes
    check vb[0] != vb[1]

  test "referenceX: a dashed vertical line at a date, in every row":
    let t = tabella(d, rownameCol = "island"):
      fmtNanoplot "years", autoscale = true, referenceX = @["2020-03-11"]
    let h = t.toHtml
    check h.count("stroke-dasharray") == 2
    check h.count("2020-03-11") == 2

  test "referenceX outside the axis draws nothing, and a bad one is an error":
    let t = tabella(d, rownameCol = "island"):
      fmtNanoplot "years", referenceX = @["1990"]
    check t.toHtml.count("stroke-dasharray") == 0
    expect ValueError:
      discard tabella(d, rownameCol = "island").fmtNanoplot("years", referenceX = @["soon"])
