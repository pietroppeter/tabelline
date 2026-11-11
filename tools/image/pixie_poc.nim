## PoC B (tabelline 0.3, image output): draws the four tables of `tables.nim` as PNG files with
## `tabelline/pixie`, and reports the size and time of each (layout and paint, then PNG encoding).
##
##   nim r -d:release tools/image/pixie_poc.nim [outdir] [scale]
import std/[os, strutils, strformat, monotimes, times]
import pkg/pixie
import tabelline, tabelline/pixie
import ./tables

let dir = if paramCount() > 0: paramStr(1) else: "build/image"
let scale = if paramCount() > 1: parseFloat(paramStr(2)).float32 else: 2
createDir dir
proc ms(a, b: MonoTime): float = (b - a).inMicroseconds.float / 1000
var t0 = getMonoTime()
discard pictureFonts()
echo &"fonts read in {ms(t0, getMonoTime()):.1f} ms"
for (name, t) in imageTables():
  for round in 1 .. 2:   # the second time warm
    t0 = getMonoTime()
    let img = t.toImage(scale = scale)
    let t1 = getMonoTime()
    let png = img.encodeImage(PngFormat)
    let t2 = getMonoTime()
    if round == 2:
      writeFile(dir / name & "-pixie.png", png)
      echo &"{name:<8} {img.width:5} × {img.height:5} px, {png.len div 1024:4} KB, " &
           &"draw {ms(t0, t1):6.1f} ms, PNG {ms(t1, t2):6.1f} ms"
