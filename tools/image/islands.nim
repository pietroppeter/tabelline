## A fifth table for the image-output proofs of concept: the islands' shape nanoplots (PR #88),
## with `autoscale`, beside a line nanoplot. Needs the islands' data of the story (`docs/stories/
## data/isole/`). `import islands` and call `islandsTable()`.

import std/[os, strutils, sequtils]
import tabelline

const root = currentSourcePath().parentDir.parentDir.parentDir

proc islandsTable*(): Tabella =
  let islands = readCsv(root / "docs" / "stories" / "data" / "isole" / "islands.csv", comment = "#")
  proc nums(v: Value): seq[float] = ($v).splitWhitespace.mapIt(it.parseFloat)
  var names: seq[string]
  var shapes: seq[Value]
  for island in ["Sicily", "Sardinia", "Corsica", "Crete", "Mallorca"]:
    for i in 0 ..< islands.nrows:
      if islands["island", i] == toValue(island) and not islands["x", i].isNull:
        names.add island
        shapes.add toValue((x: nums(islands["x", i]), y: nums(islands["y", i])))
        break
  let d = tableData:
    island: names
    shape: shapes
  tabella(d, rownameCol = "island"):
    tabHeader "Five islands at one scale", "their outlines as shape nanoplots"
    fmtNanoplot "shape", plotType = "shape", plotHeight = "3em", autoscale = true
    colsLabel:
      shape: "outline"
    tabSourceNote "The outlines from Natural Earth (public domain)."

when isMainModule:
  let dir = if paramCount() > 0: paramStr(1) else: "build/image"
  createDir dir
  islandsTable().save(dir / "islands.html")
  echo dir / "islands.html"
