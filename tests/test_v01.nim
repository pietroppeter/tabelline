## Edge cases of the 0.1 verbs (the specs' examples cover the main path).
import std/[unittest, strutils, sequtils, tables]
import tabelline, tabelline/datasets

suite "0.1 formats":
  test "engineering and SI":
    check formatEngineering(999.999) == "1.00 × 10³"
    check formatEngineering(-0.5) == "−500.00 × 10⁻³"
    check formatNumberSi(0) == "0.00"
    check formatNumberSi(999_999, "B", decimals = 1) == "1.0 MB"
  test "parts per, bytes":
    check formatPartsper(0.5, "per-myriad", decimals = 0) == "5,000‱"
    check formatPartsper(5, "ppm", scaleValues = false, decimals = 0) == "5 ppm"
    check formatBytes(999) == "999 B"
    check formatBytes(1000) == "1 kB"
    check formatBytes(1023, "binary") == "1023 B"
  test "index and spelled numbers":
    check formatIndex(26) == "Z"
    check formatIndex(52) == "ZZ"
    check formatIndex(52, indexAlgo = "excel") == "AZ"
    check formatIndex(703, indexAlgo = "excel") == "AAA"
    check formatSpelledNum(13) == "thirteen"
    check formatSpelledNum(80) == "eighty"
    check formatSpelledNum(101) == "101"
  test "times":
    check formatTime("00:05", "h_m_p") == "12:05 AM"
    check formatTime("12:00", "h_p") == "12 PM"
    check formatTime("25:00") == "25:00"
    check formatDatetime("2026-11-07") == "2026-11-07"
  test "durations":
    check formatDuration(0) == "0s"
    check formatDuration(59.6) == "1m"
    check formatDuration(3600, outputUnits = ["minutes"]) == "60m"
    check formatDuration(694861, maxOutputUnits = 2) == "1w 1d"
    check formatDuration(-90, durationStyle = "iso") == "−PT1M30S"
  test "booleans, flags":
    check formatTf(false, "triangles") == "▼"
    check formatFlag("it") == "🇮🇹"
    check formatFlag("ITA") == "ITA"
    expect ValueError: discard formatTf(true, "nope")

suite "0.1 verbs":
  test "small values with sign":
    let d = tableData:
      x: [-0.001, 0.001, 0.0]
    let t = tabella(d).subSmallVals(sign = "-")
    check t.build(rcText).groups[0].rows.mapIt(it.cells[0]) == @["<−0.01", "0.001", "0.0"]
  test "five notes with the standard marks":
    var t = tabella(tavolaPitagorica(5), rownameCol = "×").optFootnoteMarks("standard")
    for i in 0 ..< 5: t = t.tabFootnote("note " & $i, loc.stub(rows = [i]))
    check t.build(rcText).notes.len == 5
    check "** note 4" in $t
  test "a footnote on the header marks the title once":
    let t = tabella(tavolaPitagorica(2)).tabHeader("T", "S").tabFootnote("n", loc.header())
    let b = t.build(rcText)
    check b.marks.len == 1 and "title" in b.marks
  test "spanner delim with a limit":
    let d = tableData:
      `a.b.c`: [1]
    check tabella(d).tabSpannerDelim(limit = 1).spanners[0].label.s == "a.b"
    check tabella(d).tabSpannerDelim(limit = 1, split = "first").colInfo("a.b.c").label.s == "b.c"
  test "names with no delimiter keep their label":
    let d = tableData:
      plain: [1]
      `x.y`: [2]
    let t = tabella(d).tabSpannerDelim()
    check t.colInfo("plain").label.s == "plain"
    check t.spanners.len == 1
  test "row order keeps missing values last, also reversed":
    let d = tableData:
      x: [2, nil, 3, 1]
    check tabella(d).rowOrder("x", reverse = true).rowOrder == @[2, 0, 3, 1]
  test "the header, the footer and every line in HTML":
    let t = tabella(tavolaPitagorica(2)).tabHeader("T").tabSourceNote("S")
      .tabStyle(style.fill("#ABCDEF"), loc.header(), loc.footer()).optTableLines("all")
    let h = t.toHtml
    check h.count("#ABCDEF") == 2
    check "border-left: 1px solid #D3D3D3" in h
  test "verbs check their names when called":
    expect ValueError: discard tabella(tavolaPitagorica(2)).optFootnoteOrder("random")
    expect ValueError: discard tabella(tavolaPitagorica(2)).fmtDuration("1", durationStyle = "long")
    expect KeyError: discard tabella(tavolaPitagorica(2)).rowGroupOrder(["none"])
