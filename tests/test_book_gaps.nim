## The gaps the tabelline book found while porting for 0.2 (book/gaps.md), closed before the tag.
import std/[unittest, strutils]
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
