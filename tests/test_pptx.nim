import std/[unittest, strutils, tables]
import tabelline, tabelline/[datasets, pptx]

suite "PowerPoint output (experiment)":
  test "a zip's checksum is the standard CRC-32":
    check crc32("The quick brown fox jumps over the lazy dog") == 0x414FA339'u32

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
    let x = t.toPptxTable
    check x.count("<a:gridCol ") == 4          # stub, mass, diameter, moons
    check "gridSpan=\"4\"" in x                # title, subtitle, groups, source note
    check "gridSpan=\"2\"" in x                # the spanner
    check "rowSpan=\"2\"" in x                 # stubhead and moons, beside the spanner
    check ">Terrestrial<" in x and ">NASA<" in x

  test "a .pptx is a zip with a slide per table":
    let t = tabella(planets())
    let z = toPptx([t, t])
    check z.startsWith("PK\x03\x04")
    check "ppt/slides/slide2.xml" in z

  test "the clipboard HTML has no classes and no style block":
    let h = tabella(planets()).tabHeader("Planets").toClipboardHtml
    check "<style" notin h and "class=" notin h and "var(" notin h
    check "colspan=" in h
