## tabelline/nanuq: a table from a nanuq (Polars) DataFrame. Needs the `docs` feature (nanuq and
## its prebuilt Polars library), so it is not in tests/all.nim: `nim r tests/test_nanuq.nim`.
import std/[unittest, strutils, options]
import nanuq
import tabelline, tabelline/nanuq

suite "nanuq":
  test "every column, in order, with its kind":
    let df = newDataFrame:
      planet: ["Mercury", "Venus", "Earth"]
      moons: [0, 0, 1]
      mass: [0.33, 4.87, 5.97]
      rings: [false, false, false]
    let d = df.toTableData
    check d.names == @["planet", "moons", "mass", "rings"]
    check d.nrows == 3
    check d["moons", 2] == 1.toValue
    check d["moons", 2].kind == vkInt
    check d["mass", 1].kind == vkFloat
    check d["rings", 0].kind == vkBool
    check d["planet", 0] == "Mercury".toValue

  test "nulls are missing values":
    let df = newDataFrame:
      x: [some(1), none(int), some(3)]
    check df.toTableData["x", 1].isNull

  test "tabella(df): body":
    let df = newDataFrame:
      planet: ["Mercury", "Venus"]
      moons: [0, 0]
    let t = tabella(df, rownameCol = "planet"):
      tabHeader "Two planets"
    let h = t.toHtml
    check "Two planets" in h
    check "tb_stub\">Venus" in h
