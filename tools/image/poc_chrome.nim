## Proof of concept C for image output (0.3): draws the tables of `tables.nim` (shared by the three proofs) with Chrome,
## through `tabelline/chrome`, and reports sizes and times. These pictures are the reference
## for the SVG and pixie proofs of concept.
##
##   nim r -d:release tools/image/poc_chrome.nim [outdir]
##
## Writes, for each table, `<name>.png` (zoom 2), `<name>.pdf` and `<name>.html` (the page
## Chrome drew), and a `report.md`.
import std/[os, strformat, strutils, times]
import tabelline, tabelline/chrome
import "./tables"

let outDir = if paramCount() >= 1: paramStr(1) else: "poc-chrome"
createDir(outDir)

proc kb(path: string): string = formatFloat(getFileSize(path).float / 1024, ffDecimal, 1) & " KB"

var report = "| table | PNG (zoom 2) | pixels | PDF | PNG, warm | PDF, warm |\n" &
             "|---|---|---|---|---|---|\n"

let all = imageTables()

# cold: a Chrome started for one picture, as `t.saveImage(path)` does
var t0 = epochTime()
all[0][1].saveImage(outDir / "cold.png")
let cold = epochTime() - t0
removeFile(outDir / "cold.png")

t0 = epochTime()
let c = startChrome()
let startup = epochTime() - t0
for (name, t) in all:
  writeFile(outDir / name & ".html", t.picturePage)
  let png = outDir / name & ".png"
  let pdf = outDir / name & ".pdf"
  t0 = epochTime()
  c.saveImage(t, png)
  let warm = epochTime() - t0
  t0 = epochTime()
  c.saveImage(t, pdf)
  let warmPdf = epochTime() - t0
  # the PNG's size, from its header
  let head = readFile(png)[16 ..< 24]
  proc be32(s: string): int = ord(s[0]) shl 24 or ord(s[1]) shl 16 or ord(s[2]) shl 8 or ord(s[3])
  let px = &"{be32(head[0..3])} × {be32(head[4..7])}"
  report.add &"| {name} | {kb(png)} | {px} | {kb(pdf)} | {int(warm*1000)} ms | {int(warmPdf*1000)} ms |\n"
c.close()

report.add &"\nChrome: start and open a tab {int(startup*1000)} ms; one picture with its own Chrome " &
           &"(start, draw, stop) {int(cold*1000)} ms.\n"
writeFile(outDir / "report.md", report)
echo report
