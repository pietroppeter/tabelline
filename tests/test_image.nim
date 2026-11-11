## The layout of a table as a picture, the SVG, and `save` by the extension (core only).
import std/[unittest, strutils, os, sequtils]
import tabelline, tabelline/datasets
import ../tools/image/tables as shared

suite "image output":
  test "the image tables keep the size Chrome gives them (within 4 px, measured by tools/image/compare.nim)":
    # Chrome's boxes (CSS px) for the four tables, from compare.nim on 11 Nov 2026
    let chrome = [("planets", 706.0, 237.0), ("cars", 525.7, 945.4), ("styles", 530.5, 414.0), ("plots", 473.8, 314.0)]
    for (name, t) in imageTables():
      let d = t.drawing
      for (n, w, h) in chrome:
        if n == name:
          check abs(d.width - w) <= 4
          check abs(d.height - h) <= 4

  test "a narrow page wraps the lines":
    let d = tableData:
      planet: ["Mercury", "Venus"]
      note: ["the smallest planet, and the closest to the Sun, with no moons at all",
             "the hottest planet, under clouds of sulphuric acid, turning the other way"]
    let t = tabella(d)
    let wide = t.drawing
    let narrow = t.drawing(width = 380)
    check narrow.width < wide.width
    check narrow.height > wide.height

  test "marks: backgrounds and rules, then text with a place for each letter":
    let d = tabella(planets()).tabHeader("Planets").drawing
    check d.marks.anyIt(it.kind == mkLine)
    for m in d.marks:
      if m.kind == mkText:
        check m.xs.len == m.glyphs.len
        check m.glyphs.allIt(it > 0)

  test "tabular figures in right-aligned numbers":
    let d = tabella(planets()).drawing
    check d.marks.anyIt(it.kind == mkText and it.tabular)

  test "SVG with the font inside, or letters as paths":
    let t = tabella(planets()).tabHeader("Planets")
    let s = t.toSvg
    check s.startsWith("<svg xmlns=\"http://www.w3.org/2000/svg\"")
    check "@font-face" in s and "<text" in s
    let p = t.toSvg(text = stPaths)
    check "@font-face" notin p and "<text" notin p and "<path id=" in p
    check s.count("<svg") == 1

  test "a nanoplot goes in as its own SVG, with none for transparent":
    let d = tableData:
      trend: ["1 4 2 8 5"]
    let t = tabella(d).fmtNanoplot("trend")
    check "\"transparent\"" notin t.toHtml
    let s = t.toSvg
    check s.count("<svg") == 2
    check "\"transparent\"" notin s

  test "save by the extension":
    let dir = getTempDir() / "tabelline-test-image"
    createDir dir
    let t = tabella(planets())
    t.save(dir / "p.svg")
    check readFile(dir / "p.svg").startsWith("<svg")
    t.save(dir / "p.html")
    check readFile(dir / "p.html").startsWith("<!doctype html>")
    check hasWriter(".svg") and hasWriter(".HTML")
    expect ValueError: t.save(dir / "p.docx")
    removeDir dir

  test "a writer added for an extension, the higher priority winning":
    var got = ""
    addWriter(".xyz", proc (t: Tabella, path: string, scale, width: float) = got = "low", priority = 1)
    addWriter(".xyz", proc (t: Tabella, path: string, scale, width: float) = got = "high", priority = 5)
    addWriter(".xyz", proc (t: Tabella, path: string, scale, width: float) = got = "lower", priority = 2)
    tabella(planets()).save("x.xyz")
    check got == "high"
