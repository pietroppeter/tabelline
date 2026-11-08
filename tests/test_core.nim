import std/[unittest, options, math]
import tabelline, tabelline/datasets

suite "values and data":
  test "values from Nim values":
    check toValue(3).kind == vkInt
    check toValue(2.5).kind == vkFloat
    check toValue(NaN).isNull
    check toValue(none(int)).isNull
    check toValue(some("x")) == "x"
    check toValue(3) == toValue(3.0)
    check toValue(3) > 2
    check 2 < toValue(3)

  test "rows as objects and tuples":
    let d = toTableData(@[(name: "a", x: 1), (name: "b", x: 2)])
    check d.names == @["name", "x"]
    check d.nrows == 2
    check d["x", 1] == 2

  test "tableData macro mixes nil with numbers":
    let d = tableData:
      a: [1, nil, 3]
      b: ["x", "y", "z"]
    check d["a", 1].isNull
    check d["a"].kindOf == vkInt
    check d["b"].kindOf == vkString

  test "csv inference":
    let d = parseCsv("a,b,c,d\n1,2.5,x,true\n2,,y,false\n")
    check d["a"].kindOf == vkInt
    check d["b"].kindOf == vkFloat
    check d["b", 1].isNull
    check d["c"].kindOf == vkString
    check d["d"].kindOf == vkBool

  test "csv comment lines":
    let text = "# source: somewhere\na,b\n# a note\n1,x\n  # indented\n2,#y\n"
    let d = parseCsv(text, comment = "#")
    check d.nrows == 2
    check d["b", 1] == toValue("#y")
    check parseCsv("a\n#1\n")["a", 0] == toValue("#1")

  test "datasets":
    check planets().nrows == 8
    check planets()["mass"].kindOf == vkFloat
    check exibble().nrows == 8
    check tavolaPitagorica(3)["3", 2] == 9

  test "unknown columns fail with the column list":
    expect KeyError:
      discard tabella(planets()).fmtNumber("massa")

suite "selectors":
  let d = planets()
  test "columns":
    check startsWith("d").resolve(d) == @["diameter", "density", "day_length", "distance"]
    check numeric().resolve(d).len == 9   # not planet, type (text) or rings (bool)
    check textual().resolve(d) == @["planet", "type"]
    check toColSel(["mass", "moons"]).resolve(d) == @["mass", "moons"]
  test "rows":
    check where(it["type"] == "Ice giant").resolve(d) == @[6, 7]
    check toRowSel(1..2).resolve(d) == @[1, 2]
    check where(it["moons"] > 20).resolve(d) == @[4, 5, 6]
