## tabelline/pixie (the atlas feature `pixie`): `nim r tests/test_pixie.nim`.
import std/[unittest, math, os]
import tabelline, tabelline/[datasets, pixie]

suite "tabelline/pixie":
  test "the picture is the drawing's size times the scale":
    let t = tabella(planets()).tabHeader("Planets")
    let d = t.drawing
    let img = t.toImage(scale = 2)
    check img.width == int(ceil(d.width * 2))
    check img.height == int(ceil(d.height * 2))

  test "a PNG, and save(t, \"t.png\")":
    let t = tabella(planets())
    check t.toPng(scale = 1)[1 .. 3] == "PNG"
    let path = getTempDir() / "tabelline-test.png"
    t.save(path)
    check readFile(path)[1 .. 3] == "PNG"
    removeFile path

  test "nanoplots are painted":
    let d = tableData:
      trend: ["1 4 2 8 5"]
    let img = tabella(d).fmtNanoplot("trend").toImage
    check img.width > 0
