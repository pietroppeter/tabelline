## The tails of 0.2: a stub of several columns, groups as a column, the other HTML options,
## images anywhere, font stacks, per-point nanoplot options, gt's datasets.
import std/[unittest, strutils, os]
import tabelline, tabelline/datasets

let cars = tableData:
  mfr: ["Ford", "Ford", "Ferrari", "Ford"]
  model: ["GT", "Mustang", "Roma", "Bronco"]
  kind: ["sport", "sport", "sport", "suv"]
  hp: [647, 450, 612, 330]

suite "a stub of several columns":
  test "a level equal to the one above spans its rows, in its group":
    let t = initTabella(cars, rownameCol = ["mfr", "model"])
    check t.stubColumns == @["mfr", "model"]
    let h = t.toHtml
    check h.count("rowspan=\"2\"") == 1      # Ford, GT and Mustang; the last Ford starts again
    check h.count("tb_stub tb_stub_level\"") == 3
    check "colspan=\"2\" scope=\"col\"" in h   # the stubhead over both
    let txt = $t
    check "│ Ford    │ GT      │" in txt and "│         │ Mustang │" in txt
    let g = initTabella(cars, rownameCol = ["mfr", "model"], groupnameCol = "kind")
    check g.toHtml.count("rowspan=\"2\"") == 1
    check "│ Ford    │ Bronco  │" in $g          # a new group: the level is drawn again
  test "loc.stub picks stub columns; loc.body leaves them out":
    let t = tabella(cars, rownameCol = ["mfr", "model"]):
      tabStyle style.fill("#EEEEEE"), loc.stub(cols = "mfr")
      tabStyle style.text(weight = "bold"), loc.body()
    let h = t.toHtml
    check h.count("background-color: #EEEEEE") == 3
    check h.count("font-weight: bold") == 8   # kind and hp, four rows
  test "extract and Markdown":
    let t = initTabella(cars, rownameCol = ["mfr", "model"])
    let b = t.extractBody
    check b.names == @["mfr", "rowname", "kind", "hp"]
    check $b["mfr", 1] == "Ford"
    check "|  | Mustang |" in t.toMarkdown

suite "groups as a column":
  test "the label spans the group's rows and summary rows":
    let t = tabella(cars, rownameCol = "model", groupnameCol = "kind", rowGroupAsColumn = true):
      colsHide "mfr"
      summaryRows:
        total: agg.sum
    let h = t.toHtml
    check "tb_group_heading_row" notin h
    check "rowspan=\"4\" class=\"tb_row tb_left tb_stub_row_group\" id=\"sport\"" in h
    check "│ sport │ GT      │" in $t
    let o = tabella(cars, rownameCol = "model", groupnameCol = "kind"):
      tabOptions(rowGroupAsColumn = true)
    check "tb_stub_row_group" in o.toHtml

suite "the other options":
  test "hidden labels, units pattern, default group label":
    let d = tableData:
      name: ["Io", "Titan"]
      planet: ["Jupiter", ""]
      radius: [1821.6, 2574.7]
    let t = tabella(d, rownameCol = "name", groupnameCol = "planet"):
      colsUnits:
        radius: "km"
      tabOptions:
        columnLabelsUnitsPattern = "{1} [{2}]"
        rowGroupDefaultLabel = "Others"
    check "radius [km]" in $t and "│ Others" in $t
    let hidden = tabella(d):
      tabOptions(columnLabelsHidden = true)
    check "<tr class=\"tb_col_headings" notin hidden.toHtml and "radius" notin $hidden
  test "notes on one line":
    let t = tabella(planets()):
      tabSourceNote "a"
      tabSourceNote "b"
      tabFootnote "x", loc.title()
      tabFootnote "y", loc.subtitle()
      tabHeader "T", "S"
      tabOptions:
        sourceNotesMultiline = false
        sourceNotesSep = " | "
        footnotesMultiline = false
    check "a | b" in $t and t.toHtml.count("tb_sourcenote\"") == 1
    check "1 x 2 y" in $t
  test "no data, alignment, light text, stub rule, indent, extra CSS":
    let t = tabella(cars, rownameCol = "model"):
      rowsHide [0, 1, 2, 3]
      tabOptions:
        tableNoDataMessage = "Nothing here"
        tableAlign = "left"
        stubSeparate = false
        stubIndentLength = "2ch"
        tableAdditionalCss = ".tb_title { color: red }"
    let h = t.toHtml
    check "Nothing here" in h and "Nothing here" in $t
    check "--tb-table-margin-left: 0" in h and "--tb-stub-border-style: none" in h
    check "--tb-stub-indent-length: 2ch" in h
    check " .tb_title { color: red }" in h
    let dark = tabella(cars):
      tabOptions(tableFontColorLight = "#FFFFEE")
      dataColor "hp", palette = @["#000000", "#000010"]
    check "color: #FFFFEE" in dark.toHtml
  test "stripes: the body, and the stub only when asked":
    let t = tabella(cars, rownameCol = "model"):
      optRowStriping()
    check t.toHtml.count("tb_stub tb_striped\"") == 0 and t.toHtml.count("tb_striped\"") == 6
    let s = tabella(cars, rownameCol = "model"):
      optRowStriping()
      tabOptions(rowStripingIncludeStub = true, rowStripingIncludeTableBody = false)
    check s.toHtml.count("tb_stub tb_striped\"") == 2 and s.toHtml.count("tb_striped\"") == 2

suite "images, fonts, nanoplots, datasets":
  test "localImage and webImage":
    let file = getTempDir() / "tabelline_dot.svg"
    writeFile(file, "<svg xmlns=\"http://www.w3.org/2000/svg\"/>")
    let t = tabella(planets()):
      tabHeader localImage(file, alt = "dot"), webImage("https://example.org/a/sun.png")
    let h = t.toHtml
    check "src=\"data:image/svg+xml;base64," in h and "src=\"https://example.org/a/sun.png\" alt=\"sun.png\"" in h
    check "dot" in $t and "sun.png" in $t
  test "font stacks":
    check systemFonts() == "system-ui, sans-serif"
    check systemFonts("monospace-code").startsWith("ui-monospace")
    check fontStackNames.len == 15
    expect ValueError: discard systemFonts("comic")
    check defaultFonts().startsWith("system-ui, 'Segoe UI'")
  test "a value for each point, repeating":
    let d = tableData:
      v: ["1 2 3 4"]
    let t = tabella(d):
      fmtNanoplot "v", options = nanoplotOptions(dataPointFillColor = @["red", "blue"],
                                                 dataPointRadius = @[5.0, 9.0])
    let h = t.toHtml
    check h.count("fill=\"red\"") == 2 and h.count("fill=\"blue\"") == 2
    check h.count("r=\"9\"") == 2
    let bars = tabella(d):
      fmtNanoplot "v", plotType = "bar", options = nanoplotOptions(dataBarFillColor = @["#111111", "#222222", "#333333"])
    check bars.toHtml.count("fill=\"#111111\"") == 2
  test "dates on x":
    let x = nanoplotXValues(toValue((x: @["2026-01-01", "2026-01-11"], y: @[1, 2])))
    check x[1] - x[0] == 10 * 86400.0
  test "gt's datasets":
    check gtcars().nrows == 47 and gtcars().ncols == 15
    check countrypops().ncols == 5 and illness().nrows == 39 and metro().nrows == 314
