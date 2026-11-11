## The reference check of the layout: draws each image table (`tables.nim`) with Chrome (the
## HTML, exact by definition), as an SVG drawn by Chrome, and as a PNG painted by pixie, checks
## that the layout's box is within 4 CSS pixels of Chrome's, and writes the three pictures one
## under the other (`<name>-compare.png`, scale 2). Needs Chrome and the atlas feature `pixie`.
## `nim r -d:release tools/image/compare.nim [dir]` (default build/image); exits with 1 when a
## box is off.
import std/[os, strformat, math]
import tabelline, tabelline/[chrome, pixie]
import pkg/pixie as px except Mark, Paint, Image
import tables as shared

const tolerance = 4.0

when isMainModule:
  let dir = if paramCount() > 0: paramStr(1) else: "build/image"
  createDir dir
  let c = startChrome()
  var bad = 0
  echo "| table | Chrome (CSS px) | layout | difference |"
  echo "|---|---|---|---|"
  for (name, t) in imageTables():
    let d = t.drawing
    c.viewport(992, 600, 2.0)
    c.show(t.picturePage)
    let b = c.box(".tabella > table")
    let (dw, dh) = (d.width - b.width, d.height - b.height)
    let ok = abs(dw) <= tolerance and abs(dh) <= tolerance
    if not ok: inc bad
    echo &"| {name} | {b.width:.1f} × {b.height:.1f} | {d.width:.1f} × {d.height:.1f} | {dw:+.1f}, {dh:+.1f}{(if ok: \"\" else: \" ✗\")} |"
    let html = decodeImage(c.screenshot(b))
    c.show("<!doctype html><html><head><style>html,body{margin:0;background:#fff}svg{display:block}</style></head><body>" &
           d.toSvg & "</body></html>")
    let svg = decodeImage(c.screenshot(c.box("svg")))
    let png = d.toImage(2.0)
    let gap = 24
    let w = max(html.width, max(svg.width, png.width))
    let all = newImage(w, html.height + svg.height + png.height + 2 * gap)
    all.fill(color(1, 1, 1, 1))
    all.draw(html)
    all.draw(svg, translate(vec2(0, float32(html.height + gap))))
    all.draw(png, translate(vec2(0, float32(html.height + svg.height + 2 * gap))))
    all.writeFile(dir / name & "-compare.png")
  c.close()
  echo "top: Chrome draws the HTML; middle: Chrome draws the SVG; bottom: pixie paints the PNG"
  if bad > 0: quit 1
