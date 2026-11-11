## Puts two pictures of the same table side by side, each under its name and size, for the
## findings: `nim r tools/image/compare.nim left.png Chrome right.png pixie out.png`
import std/os
import pkg/pixie
import tabelline/pixie as tp

let (a, la, b, lb, outp) = (paramStr(1), paramStr(2), paramStr(3), paramStr(4), paramStr(5))
let left = readImage(a)
let right = readImage(b)
const gap = 40
const head = 70
let img = newImage(left.width + right.width + 3 * gap, max(left.height, right.height) + head + gap)
img.fill(rgba(240, 240, 240, 255))
let font = newFont(tp.pictureFonts().bold)
font.size = 32
font.paint.color = color(0.2, 0.2, 0.2, 1)
img.fillText(font, la & "  " & $left.width & " × " & $left.height, translate(vec2(gap, 18)))
img.fillText(font, lb & "  " & $right.width & " × " & $right.height, translate(vec2(float32(2 * gap + left.width), 18)))
img.draw(left, translate(vec2(gap, head)))
img.draw(right, translate(vec2(float32(2 * gap + left.width), head)))
img.writeFile(outp)
