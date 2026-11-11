import std/[unittest, strutils, tables]
import tabelline, tabelline/[datasets, pptx]
import xoffy, xoffy/opc

suite "PowerPoint output, with xoffy":
  test "CSS colours become DrawingML colours":
    check toColor("#abc").hex == "AABBCC"
    check toColor("rgba(128,128,128,0.05)").alpha == 5000
    check toColor("transparent").none
    check toColor("var(--ink, #1C1C1C)").hex == "1C1C1C"
    check toColor("var(--ink, #1C1C1C)", PptxOptions(vars: {"--ink": "#FF0000"}.toTable)).hex == "FF0000"
    check toColor("color-mix(in oklab, #000000 50%, #FFFFFF)").hex == "808080"

  test "the parts become rows and merged cells":
    let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
      tabHeader "The planets", "of the Solar System"
      tabSpanner "Size", ["diameter", "mass"]
      colsHide ["density", "gravity", "day_length", "orbital_period", "mean_temp", "rings", "distance"]
      tabSourceNote "NASA"
    let g = t.toGrid
    check g.cols.len == 4                     # stub, mass, diameter, moons
    let x = tableXml(g)
    check "gridSpan=\"4\"" in x                # title, subtitle, groups, source note
    check "gridSpan=\"2\"" in x                # the spanner
    check "rowSpan=\"2\"" in x                 # stubhead and moons, beside the spanner
    check ">Terrestrial<" in x and ">NASA<" in x

  test "a .pptx is a package with a slide per table":
    let t = tabella(planets())
    let p = readPackage(toPptx([t, t]))
    check p.has("ppt/slides/slide2.xml")
    check "<a:tbl>" in p["ppt/slides/slide1.xml"]

  test "a link in a cell stays a link":
    let t = tabella(planets()):
      tabSourceNote md("[NASA](https://nssdc.gsfc.nasa.gov/planetary/factsheet/)")
    var found = false
    for r in t.toGrid.rows[^1].cells[0].text.paragraphs[0].runs:
      if r.link == "https://nssdc.gsfc.nasa.gov/planetary/factsheet/": found = true
    check found

  test "a wide table is scaled to fit":
    let t = tabella(planets())
    check t.toGrid(maxWidth = 300).width <= 300.pt + 1.pt

  test "the clipboard HTML has no classes and no style block":
    let h = tabella(planets()).tabHeader("Planets").toClipboardHtml
    check "<style" notin h and "class=" notin h and "var(" notin h
    check "colspan=" in h
