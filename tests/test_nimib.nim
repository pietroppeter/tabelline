## tabelline/nimib: the stylesheet once per page.
import std/[unittest, strutils]
import nimib
import tabelline, tabelline/datasets, tabelline/nimib

suite "nimib":
  test "nbTable writes tabellaCss with the first table only":
    nbInit
    nbTable tabella(planets())
    nbTable tabella(planets()).tabOptions(tableFontSize = "14px")
    nb.table tabella(tavolaPitagorica(3))
    var css = 0
    for blk in nb.blocks:
      if blk of NbTable and tabellaCss in NbTable(blk).html: inc css
    check css == 1
    check tabellaCss in NbTable(nb.blocks[0]).html
    check tabellaCss notin nb.tableHtml(tabella(planets()))

  test "nbTable data: body in one step":
    nbInit
    nbTable planets():
      tabHeader "Planets in one step"
    nbTable planets(), rownameCol = "planet":
      tabHeader "With a stub"
    nbTable planets()
    let t = tabella(planets())
    nbTable t:
      tabHeader "A table, again"
    nbTable t
    check nb.blocks.len == 5
    check "Planets in one step" in NbTable(nb.blocks[0]).html
    check "tb_stub\">Mercury" in NbTable(nb.blocks[1]).html
    check "Mercury" in NbTable(nb.blocks[2]).html
    check "A table, again" in NbTable(nb.blocks[3]).html
    check "A table, again" notin NbTable(nb.blocks[4]).html
