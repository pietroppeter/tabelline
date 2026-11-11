## Cells that hold more than one value: lists and records.
import std/[unittest, strutils, math]
import tabelline

type Point = object
  x, y: float

suite "lists and records":
  test "made from Nim values":
    let l = toValue(@[1, 4, 2])
    check l.kind == vkList and l.len == 3 and l[1] == 4
    check toValue([1.5, 2.5]).isList
    let r = toValue((name: "Io", radius: 1821.6))
    check r.kind == vkRecord and r["name"] == "Io" and r.radius == 1821.6
    check toValue(Point(x: 1, y: 2)).y == 2.0
    check list(1, "a", nil)[2].isNull
    check record({"x": toValue(1)}).x == 1
    check "radius" in r and "mass" notin r
  test "text, equality and order":
    check $toValue(@[1, 4, 2]) == "1, 4, 2"
    check $toValue((x: 1, y: @[2, 3])) == "x: 1, y: [2, 3]"
    check toValue(@[1, 2]) == toValue(@[1, 2])
    check toValue(@[1, 2]) != toValue(@[2, 1])
    check toValue(@[1, 2]) < toValue(@[1, 3])
    check toValue(@[1, 2]) < toValue(@[1, 2, 0])
    check not (toValue((x: 1)) < toValue((x: 2)))
    check not toValue(@[1]).isNumber
    expect ValueError: discard toValue(@[1]).toFloat
  test "missing names and items fail clearly":
    let r = toValue((x: 1, y: 2))
    expect KeyError: discard r.z
    expect KeyError: discard toValue(3)["x"]
    expect ValueError: discard r[0]
    check r.kind == vkRecord   # a name Value has is not a field
  test "in a table: a list column is not numeric, and shows its items":
    let d = tableData:
      moon: ["Io", "Europa"]
      sizes: [@[1.0, 2.5], @[3.0]]
    check d["sizes"].kindOf == vkList and not d["sizes"].isNumeric
    check "1.0, 2.5" in tabella(d).toText
  test "row predicates read columns by name":
    let d = tableData:
      planet: ["Mercury", "Jupiter"]
      mass: [0.33, 1898.0]
    let t = tabella(d):
      rowsHide where(it.mass > 1)
    check "Jupiter" notin t.toText and "Mercury" in t.toText
  test "formats work item by item":
    let d = tableData:
      m: [@[1234.5, 2.0], @[7.25]]
      p: [(x: 0.5, y: 1234.0), (x: 2.0, y: 3.0)]
    let t = tabella(d):
      fmtNumber ["m", "p"], decimals = 1
    let txt = t.toText
    check "1,234.5, 2.0" in txt and "x: 0.5, y: 1,234.0" in txt
  test "icons, images and flags take a list":
    let d = tableData:
      icon: [@["star", "circle-check"]]
      flag: [@["IT", "FR"]]
    let t = tabella(d):
      fmtIcon "icon"
      fmtFlag "flag"
    let html = t.toHtml
    check html.count("class=\"tb_icon\"") == 2
    check "🇮🇹 🇫🇷" in html
    check "star, circle-check" in t.toText

suite "nanoplots of lists and records":
  test "a list is the values; a record of x and y places them":
    check nanoplotValues(toValue(@[1, 3])) == @[1.0, 3.0]
    check nanoplotValues(list(1, nil, 3))[1].isNaN
    let r = toValue((x: @[3.0, 1, 2], y: @[30.0, 10, 20]))
    check nanoplotValues(r) == @[30.0, 10, 20]
    check nanoplotXValues(r) == @[3.0, 1, 2]
    expect ValueError: discard nanoplotValues(toValue((x: @[1])))
  test "x moves the points, in the order of x":
    let even = nanoplotSvg(@[1.0, 2, 3])
    let atX = nanoplotSvg(@[1.0, 2, 3], x = @[0.0, 1, 10])
    check even != atX
    check "cx=\"50\"" in atX and "cx=\"200\"" in atX
    check "cx=\"65\"" in atX       # x = 1 of 0..10, on a width of 150
    expect ValueError: discard nanoplotSvg(@[1.0, 2], x = @[1.0])
  test "fmtNanoplot reads records, and its text follows x":
    let d = tableData:
      run: [(x: @[2.0, 1, 3], y: @[5.0, 1, 9]), (x: @[1.0, 2], y: @[4.0, 4])]
    let t = tabella(d).fmtNanoplot("run", autoscale = true)
    check t.toHtml.count("class=\"tb_nanoplot\"") == 2
    check "▁▅█ 1–9" in t.toText
    let bad = tableData:
      run: [(x: @[1.0], y: @[5.0, 1])]
    expect ValueError: discard tabella(bad).fmtNanoplot("run")
