## Draws the image tables (`tables.nim`) in every way tabelline has: SVG with the font inside,
## SVG with letters as paths, and PNG with pixie, and reports sizes and times.
## `nim r -d:release tools/image/draw.nim [dir]` (default build/image) writes `<name>.svg`,
## `<name>-paths.svg`, `<name>.png`.
import std/[os, strutils, strformat, monotimes, times]
import tabelline, tabelline/pixie
import tables as shared

proc ms(t0: MonoTime): float = (getMonoTime() - t0).inMicroseconds.float / 1000

when isMainModule:
  let dir = if paramCount() > 0: paramStr(1) else: "build/image"
  createDir dir
  proc kb(n: int): string = formatFloat(n / 1024, ffDecimal, 1) & " KB"
  echo "| table | size (CSS px) | SVG, font inside | SVG, paths | PNG (scale 2) | layout | PNG |"
  echo "|---|---|---|---|---|---|---|"
  for (name, t) in imageTables():
    var t0 = getMonoTime()
    let d = t.drawing
    let lay = ms(t0)
    let s = d.toSvg
    let p = d.toSvg(stPaths)
    writeFile(dir / name & ".svg", s)
    writeFile(dir / name & "-paths.svg", p)
    t0 = getMonoTime()
    t.save(dir / name & ".png")
    let png = ms(t0)
    echo &"| {name} | {d.width:.1f} × {d.height:.1f} | {kb(s.len)} | {kb(p.len)} | {kb(getFileSize(dir / name & \".png\").int)} | {lay:.1f} ms | {png:.0f} ms |"
