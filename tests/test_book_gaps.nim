## The gaps the tabelline book found while porting for 0.2 (book/gaps.md), closed before the tag.
import std/[unittest, strutils, options]
import tabelline

let planets = tableData:
  planet: ["Mercury", "Venus", "Earth"]
  moons: [0, 0, 1]
  rings: [false, false, true]
  y2020: [1.0, 2.0, 3.0]

suite "book gaps: data, parts, columns, rows":
  test "a number written with a zero in front stays text":
    let d = parseCsv("code,n\n0400,1\n1234,2\n,3\n")
    check d["code", 0] == "0400".toValue
    check d["code", 1] == "1234".toValue
    check d["code", 2].isNull
    check d["n", 0].kind == vkInt
    check parseCsv("x\n0.5\n0\n")["x", 1].kind == vkFloat

  test "tabStub chooses the stub of a table already made":
    let t = tabella(planets):
      colsLabel {"moons": "Moons"}
      tabStub "planet"
    check t.rownameCol == "planet"
    check "tb_stub\">Venus" in t.toHtml
    check "Moons" in t.toHtml

  test "tabRowGroup relabels a group made by groupnameCol":
    let t = tabella(planets, groupnameCol = "rings"):
      tabRowGroup md("[ringed](https://example.org)"), id = "true"
    check "<a href=\"https://example.org\">ringed</a>" in t.toHtml

  test "a colsLabel block mixes plain and Markdown labels":
    let t = tabella(planets):
      colsLabel:
        moons: "Moons"
        rings: md("**Rings**")
    let h = t.toHtml
    check "Moons" in h
    check "<strong>Rings</strong>" in h

  test "selectors by kind, by any rule on the name, and of both":
    check ofKind(vkBool).resolve(planets) == @["rings"]
    check ofKind(vkInt, vkFloat).resolve(planets) == @["moons", "y2020"]
    check named(it.len == 5).resolve(planets) == @["moons", "rings", "y2020"]
    check matches(proc (n: string): bool = n.startsWith("y")).resolve(planets) == @["y2020"]
    check (numeric() & startsWith("y")).resolve(planets) == @["y2020"]

  test "negative row indices count from the end":
    check toRowSel(-1).resolve(planets) == @[2]
    check toRowSel(^1).resolve(planets) == @[2]
    check toRowSel([0, -1]).resolve(planets) == @[0, 2]

suite "book gaps: formats and text":
  test "significant figures":
    check formatNumber(0.012345, nSigfig = 3) == "0.0123"
    check formatNumber(12345.0, nSigfig = 3) == "12,300"
    check formatNumber(1.0, nSigfig = 3) == "1.00"
    check formatCompact(1234567, nSigfig = 3) == "1.23M"
    let t = tabella(planets):
      fmtNumber "y2020", nSigfig = 2
    check "1.0" in t.toText

  test "accounting in numbers, integers and percents":
    check formatNumber(-12.5, accounting = true) == "(12.50)"
    check formatPercent(-0.123, accounting = true) == "(12.3%)"
    let d = tableData:
      x: [-1234.0, 5.0]
    check "(1,234)" in tabella(d).fmtInteger("x", accounting = true).toText
    check "(1,234.00)" in tabella(d).fmtNumber("x", accounting = true).toText

  test "the format functions take pattern, locale and expStyle":
    check formatNumber(1234.5678, locale = "it") == "1.234,57"
    check formatNumber(2.0, pattern = "{x} kg") == "2.00 kg"
    check formatScientific(12345.0, expStyle = "e") == "1.23e4"
    check formatScientific(0.00012, expStyle = "E") == "1.20E−4"

  test "a datetime by a strftime format":
    check formatDatetime("2026-11-07T14:35:00", formatStr = "%d %B %Y, %H:%M") == "07 November 2026, 14:35"
    check formatDatetime("2026-11-07", formatStr = "%A %e %b") == "Saturday 7 Nov"
    check formatDatetime("2026-11-07", formatStr = "%d/%m/%Y", locale = "it") == "07/11/2026"
    check strftimeToCldr("%Y-%m-%d at %H") == "y'-'MM'-'dd' at 'HH"

  test "Markdown in subMissing":
    let d = tableData:
      x: [some(1.0), none(float)]
    let t = tabella(d):
      subMissing missingText = md("**STABLE**")
    check "<strong>STABLE</strong>" in t.toHtml
    check "STABLE" in t.toText

  test "flags: the name on hover, and round flags":
    let d = tableData:
      c: ["IT", "FRA"]
    let h = tabella(d).fmtFlag("c").toHtml
    check "title=\"Italy\"" in h
    check "title=\"France\"" in h
    let r = tabella(d).fmtFlag("c", round = true).toHtml
    check r.count("<svg") == 2
    check "id=\"cf-IT\"" in r
    check circleFlag("XX") == ""

  test "fuller Markdown: entities, underscores, struck text, autolinks, paragraphs, lists":
    check markdownToHtml("A &mdash; B") == "A &mdash; B"
    check textToPlain(md("A &mdash; B &#x2014; C")) == "A — B — C"
    check markdownToHtml("_it_ __bold__ ~~old~~ snake_case") == "<em>it</em> <strong>bold</strong> <del>old</del> snake_case"
    check markdownToHtml("<https://gt.rstudio.com>") == "<a href=\"https://gt.rstudio.com\">https://gt.rstudio.com</a>"
    check markdownToHtml("One\n\nTwo") == "<p>One</p><p>Two</p>"
    check markdownToHtml("- a\n- b") == "<ul><li>a</li><li>b</li></ul>"
    check markdownToHtml("1. a\n2. b") == "<ol><li>a</li><li>b</li></ol>"
    check textToPlain(md("- a\n- b")) == "a; b"

suite "book gaps: options, styles, look":
  test "optStylize: gt's six styles in six colours":
    for s in 1 .. 6:
      for c in ["blue", "cyan", "pink", "green", "red", "gray"]:
        discard tabella(planets).optStylize(s, c).toHtml
    let o = tabella(planets).optStylize(1).options
    check o.stubBackgroundColor == "#0076BA"
    check o.rowStriping
    check not tabella(planets).optStylize(1, addRowStriping = false).options.rowStriping
    check tabella(planets).optStylize(2).options.tableBorderLeftStyle == "solid"
    expect ValueError: discard tabella(planets).optStylize(7)

  test "optAllCaps: only the locations named":
    let o = tabella(planets).optAllCaps(locations = ["stub"]).options
    check o.stubTextTransform == "uppercase"
    check o.columnLabelsTextTransform == "inherit"

  test "R's colour names, as gt and Great Tables take them":
    check rColor("sienna4") == "#8B4726"
    check rColor("grey50") == "#7F7F7F"
    check rColor("darkgreen") == ""
    check parseColor("sienna4") == parseColor("#8B4726")
    check "#8B4726" in tabella(planets).tabStyle(style.fill("sienna4"), loc.body()).toHtml
    check palette("great-tables").len == 8

  test "a fill with alpha, text aligned up and indented":
    check "rgba(255, 0, 0, 0.5)" in tabella(planets).tabStyle(style.fill("red", alpha = 0.5), loc.body()).toHtml
    let h = tabella(planets).tabStyle(style.text(vAlign = "top", indent = "2em"), loc.body()).toHtml
    check "vertical-align: top" in h
    check "text-indent: 2em" in h

  test "the stub by its labels, groups by their rows, cells by a mask":
    let a = tabella(planets, rownameCol = "planet").tabStyle(style.fill("#FFF3B0"), loc.stub(labels = ["Venus"])).toHtml
    check a.count("#FFF3B0") == 1
    check "Venus" in a.split("#FFF3B0")[1].split("</th>")[0]
    let b = tabella(planets, groupnameCol = "rings")
      .tabStyle(style.fill("#FFF3B0"), loc.rowGroups(rows = [2])).toHtml
    check b.count("#FFF3B0") == 1
    let c = tabella(planets).tabStyle(style.fill("#FFF3B0"),
      loc.body(cols = "moons", mask = proc (v: Value): bool = v > 0)).toHtml
    check c.count("#FFF3B0") == 1
    let top = tabella(planets).tabStyle(style.fill("#FFF3B0"),
      loc.body(cols = ["moons", "y2020"], mask = proc (v: Value, col: Column): bool = v == agg.max.fn(col.values))).toHtml
    check top.count("#FFF3B0") == 2

  test "the format functions take a locale":
    check formatScientific(1234.5, locale = "de") == "1,23 × 10³"
    check formatPercent(0.5, locale = "fr").startsWith("50,0")
    check formatCurrency(1234.5, "EUR", locale = "it").contains("1.234,50")
    check formatInteger(1234.6, locale = "it") == "1.235"
    check formatCompact(1234567, locale = "it") == "1,2M"

  test "dataColor leaves the stub alone":
    let h = tabella(planets, rownameCol = "planet").dataColor(everything()).toHtml
    let stub = h.split("<tbody")[1].split("tb_stub")[1].split("</th>")[0]
    check "background-color" notin stub
    check "background-color" in h.split("<tbody")[1]

  test "numbers do not break; the stub can stay in view":
    let t = tabella(planets)
    check "td.tb_right { white-space: nowrap; }" in t.toHtml
    check "class=\"tb_table\"" in t.toHtml
    let s = tabella(planets, rownameCol = "planet"):
      tabOptions(stubSticky = true)
    check "class=\"tb_table tb_sticky_stub\"" in s.toHtml
