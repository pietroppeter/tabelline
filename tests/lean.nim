## A build without the icons and the bigger datasets, as a web page wants it:
## `nim r -d:tabellineIcons=false -d:tabellineDatasets=false tests/lean.nim` (and the same with `nim js -d:nodejs`).
import std/[unittest, strutils]
import tabelline, tabelline/datasets

suite "a lean build":
  test "the icons and the bigger datasets are left out, and say so":
    check not tabellineIcons and not tabellineDatasets
    let d = tableData:
      icon: ["star"]
    try:
      discard tabella(d).fmtIcon("icon")
      check false
    except ValueError as e:
      check "-d:tabellineIcons=false" in e.msg
    try:
      discard gtcars()
      check false
    except ValueError as e:
      check "gtcars" in e.msg and "-d:tabellineDatasets=false" in e.msg
  test "the rest works as before":
    let t = tabella(planets(), rownameCol = "planet"):
      fmtNumber "mass", decimals = 1
    check "Jupiter" in t.toHtml and exibble().nrows == 8 and tavolaPitagorica(3).nrows == 3
