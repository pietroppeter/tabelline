## PoC A (native SVG): draws the image-output tables with `toSvg`, in three ways (font subset
## embedded, whole font, letters as paths), and reports size and time. `nim r -d:release
## tools/image/svgdraw.nim out/` writes `<name>.svg`, `<name>-full.svg`, `<name>-paths.svg`.
import std/[os, times, strutils, strformat, monotimes]
import tabelline, tabelline/svg
import tables as shared, islands
export shared

when isMainModule:
  let dir = if paramCount() > 0: paramStr(1) else: "build/image/svg"
  createDir dir
  echo "| table | SVG, subset font | whole font | no font | as paths | first | next |"
  echo "|---|---|---|---|---|---|---|"
  for (name, t) in imageTables() & @[("islands", islandsTable())]:
    var t0 = getMonoTime()
    let s = t.toSvg()
    let first = (getMonoTime() - t0).inMicroseconds.float / 1000
    t0 = getMonoTime()
    discard t.toSvg()
    let next = (getMonoTime() - t0).inMicroseconds.float / 1000
    writeFile(dir / name & ".svg", s)
    let full = t.toSvg(subsetFont = false)
    writeFile(dir / name & "-full.svg", full)
    let none = t.toSvg(textAs = "none")
    writeFile(dir / name & "-nofont.svg", none)
    let paths = t.toSvg(textAs = "paths")
    writeFile(dir / name & "-paths.svg", paths)
    proc kb(x: string): string = formatFloat(x.len / 1024, ffDecimal, 1) & " KB"
    echo &"| {name} | {kb(s)} | {kb(full)} | {kb(none)} | {kb(paths)} | {first:.0f} ms | {next:.1f} ms |"
