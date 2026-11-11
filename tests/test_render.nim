import std/[unittest, strutils, tables]
import tabelline, tabelline/datasets

suite "building and rendering":
  let base = tabella(planets(), rownameCol = "planet", groupnameCol = "type")
    .colsHide(["density", "gravity", "day_length", "orbital_period", "mean_temp", "rings", "distance"])

  test "groups keep the order of first appearance":
    let b = base.build(rcText)
    check b.groups.len == 3
    check b.groups[0].label == "Terrestrial"
    check b.groups[2].rows.len == 2

  test "footnotes are numbered in reading order":
    let t = base.tabFootnote("second", loc.body(cols = "moons", rows = [0]))
      .tabFootnote("first", loc.columnLabels("mass"))
      .tabFootnote("first", loc.columnLabels("moons"))
    let b = t.build(rcText)
    check b.notes == @["first", "second"]
    check b.marks[colKey("moons")] == @[1]
    check b.marks[cellKey(0, "moons")] == @[2]

  test "html has the parts, the stylesheet and a stable id":
    let t = base.tabHeader("Planets", "subtitle").tabSpanner("Size", ["mass", "diameter"])
      .tabSourceNote("NASA").tabStyle(style.fill("#FFF3B0"), loc.body(cols = "moons", rows = [2]))
    let h = t.toHtml
    check h.startsWith("<div id=\"tabella-")
    check h == t.toHtml
    check tabellaStyle in h
    for part in ["tb_title", "tb_subtitle", "tb_spanner", "tb_stubhead", "tb_group_heading", "tb_stub", "tb_sourcenote"]:
      check part in h
    check "background-color: #FFF3B0" in h
    check h.count("<tr class=\"tb_group_heading_row\">") == 3

  test "one stylesheet, options as variables":
    check tabellaCss notin base.toHtml(withStyle = false)
    check "<style>" notin base.toHtml(withStyle = false)
    check base.toHtml(withStyle = false).splitLines[0] == "<div id=\"" & base.toHtml[9 ..< base.toHtml.find('"', 9)] & "\" class=\"tabella\">"
    let small = tabella(planets(), id = "p").tabOptions(tableFontSize = "14px", headingTitleFontWeight = "bold")
    check small.toHtml(withStyle = false).startsWith("<div id=\"p\" class=\"tabella\" style=\"--tb-table-font-size: 14px; --tb-heading-title-font-weight: bold\">")
    check "var(--tb-table-font-size, 16px)" in tabellaCss
    check "var(--tb-heading-background-color, var(--tb-table-background-color, #FFFFFF))" in tabellaCss
    # every rule weighs what an id weighs
    for line in tabellaCss.splitLines:
      if "{" in line and not line.startsWith(":where(.tabella.tb_css_theme)"): check line.startsWith(":where(.tabella):not(#_)")
  test "the page's theme: one class instead of its variables":
    let themed = tabella(planets(), id = "t").optCssTheme()
    check themed.toHtml(withStyle = false).splitLines[0] == "<div id=\"t\" class=\"tabella tb_css_theme\">"
    let changed = tabella(planets(), id = "t").optCssTheme().tabOptions(tableFontSize = "14px", tableBorderTopWidth = "2px")
    check changed.toHtml(withStyle = false).splitLines[0] == "<div id=\"t\" class=\"tabella tb_css_theme\" style=\"--tb-table-font-size: 14px; --tb-table-border-top-width: 2px\">"
    # another theme is not the default theme: its variables go on the table
    let other = tabella(planets(), id = "t").optCssTheme(ink = "--fg").toHtml(withStyle = false).splitLines[0]
    check "tb_css_theme" notin other and "--tb-table-font-color: var(--fg" in other
    check ":where(.tabella.tb_css_theme) { --tb-table-font-color: var(--ink, #1C1C1C);" in tabellaCss
  test "the table's own rules, scoped to its id":
    let h = tabella(planets(), id = "p").tabOptions(tableBodyVlinesColor = "red").optCss(".tb_row { color: blue }").toHtml(withStyle = false)
    check "#p .tb_row, #p .tb_col_headings th { border-left: 1px solid red" in h
    check "#p .tb_row { color: blue }" in h
  test "an explicit id":
    check tabella(planets(), id = "my-table").toHtml.startsWith("<div id=\"my-table\"")

  test "text and markdown agree with the html":
    let t = base.tabHeader("Planets").fmtNumber("mass", decimals = 1)
    let txt = t.toText
    check "Planets" in txt
    check "1,898.0" in txt
    check "│ Terrestrial" in txt
    let md = t.toMarkdown
    check md.startsWith("**Planets**")
    check "| **Gas giant** |" in md
    check "|:--|--:|--:|--:|" in md

  test "the recipe macro equals the chain":
    let a = tabella(planets(), rownameCol = "planet"):
      tabHeader "Planets"
      fmtNumber "mass", decimals = 1
      for c in ["density", "gravity"]:
        colsHide c
    let b = tabella(planets(), rownameCol = "planet").tabHeader("Planets")
      .fmtNumber("mass", decimals = 1).colsHide(["density", "gravity"])
    check a.toHtml == b.toHtml

  test "tabOptions sets fields by name":
    let t = tabella(planets()).tabOptions(rowStriping = true, tableFontSize = "12px")
    check t.options.rowStriping
    check t.options.tableFontSize == "12px"
    check t.options.headingAlign == "center"   # the others keep their defaults
    check "tb_striped" in t.toHtml

  test "dataColor picks readable text":
    let t = tabella(tavolaPitagorica(3)).dataColor(everything(), palette = @["#FFFFFF", "#000000"])
    let h = t.toHtml
    check "background-color: #000000; color: #FFFFFF" in h
    check "background-color: #FFFFFF; color: #1a1a1a" in h

  test "spanners over two levels":
    let t = tabella(planets()).colsHide(["type", "density", "gravity", "day_length", "mean_temp", "rings", "moons"])
      .tabSpanner("Size", ["mass", "diameter"]).tabSpanner("Orbit", ["distance", "orbital_period"])
      .tabSpanner("Numbers", ["mass", "diameter", "distance", "orbital_period"], level = 2)
    let h = t.toHtml
    check h.count("tb_spanner_row") == 2
    check "rowspan=\"3\"" in h    # planet, with no spanner, spans both spanner rows
    check "Numbers" in t.toText
