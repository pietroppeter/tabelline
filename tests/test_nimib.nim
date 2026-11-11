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
