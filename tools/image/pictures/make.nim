## Draws the four small pictures of the planets that `tables.nim` puts in cells (`fmtImage`):
## a disc with a light side, 96 × 96 pixels. Made with pixie: `nim r tools/image/pictures/make.nim`.
import std/os
import pixie

const here = currentSourcePath().parentDir
for (name, light, dark) in [("mercury", "#B8B0A8", "#5E5650"), ("venus", "#F2D49B", "#A87A3A"),
                            ("earth", "#6FB3E8", "#1D4E89"), ("mars", "#E07A4F", "#7A2E14")]:
  let img = newImage(96, 96)
  let paint = newPaint(RadialGradientPaint)
  paint.gradientHandlePositions = @[vec2(34, 34), vec2(90, 34), vec2(34, 90)]
  paint.gradientStops = @[ColorStop(color: parseHtmlColor(light).asRgbx.color, position: 0),
                          ColorStop(color: parseHtmlColor(dark).asRgbx.color, position: 1)]
  img.fillPath((block: (var p = newPath(); p.circle(48, 48, 44); p)), paint)
  img.writeFile(here / name & ".png")
