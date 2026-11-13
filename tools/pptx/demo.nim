## Writes the PowerPoint experiment's examples: `nim r tools/pptx/demo.nim [outdir]`.
import std/[os]
import tabelline, tabelline/[pptx, datasets]

let outDir = if paramCount() > 0: paramStr(1) else: "pptx-demo"
createDir outDir

# 1. the simplest: a data frame, no options
let small = tableData:
  planet: ["Mercury", "Venus", "Earth", "Mars"]
  moons: [0, 0, 1, 2]
  rings: [false, false, false, false]
let simplest = tabella(small)

# 2. the home page's table: header, labels with Markdown, formats, dataColor, a source note
let home = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  tabHeader md("The **planets**"), "of the Solar System"
  colsHide ["density", "gravity", "day_length", "distance", "orbital_period", "rings"]
  colsLabel {"mass": md("mass<br>10^24^ kg"), "diameter": md("diameter<br>km"),
             "mean_temp": md("mean<br>°C"), "moons": md("moons")}
  fmtNumber "mass", decimals = 3, dropTrailingZeros = true
  fmtInteger "diameter"
  dataColor "mean_temp", palette = palette("rdbu"), domain = (-200.0, 200.0)
  tabSourceNote "NASA Planetary Fact Sheet"
  optCssTheme()

# 3. every part: spanners, stubhead, footnotes, a style, a ready-made look
let parts = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  tabHeader "Table header: title", "and subtitle"
  tabStubhead "stub head"
  tabSpanner "Size", ["diameter", "mass"]
  colsHide ["density", "gravity", "day_length", "orbital_period", "mean_temp", "rings"]
  fmtNumber "mass", decimals = 2
  fmtInteger "diameter"
  fmtNumber "distance", decimals = 1
  tabFootnote "The biggest of them all.", loc.body(cols = "mass", rows = [4])
  tabFootnote "In millions of km.", loc.columnLabels("distance")
  tabStyle style.text(weight = "bold", color = "#D64545"), loc.body(cols = "moons", rows = [5])
  tabSourceNote "NASA Planetary Fact Sheet"
  optStylize 2, "cyan"

writeFile outDir / "simplest.pptx", toPptx([simplest])
home.savePptx outDir / "home.pptx"
parts.savePptx outDir / "parts.pptx"
[simplest, home, parts].savePptx outDir / "all.pptx"
for (n, t) in {"simplest": simplest, "home": home, "parts": parts}:
  writeFile outDir / (n & ".html"), t.toHtml(makePage = true)
echo "wrote ", outDir

# the clipboard form: HTML with inline styles, and a page with a button that copies it
for (n, t) in {"simplest": simplest, "home": home, "parts": parts}:
  let frag = t.toClipboardHtml
  writeFile outDir / (n & ".clipboard.html"), frag

# a page to try the clipboard by hand: each table with a button that copies it as HTML
var page = """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Copy a tabelline table into PowerPoint</title>
<style>body{margin:0;padding:16px;font:15px/1.45 system-ui,sans-serif;color:#1c1c1c}
[hidden]{display:none!important} section{margin:28px 0} .scroll{overflow-x:auto}
button{font:inherit;padding:6px 12px;margin:8px 8px 8px 0;border:1px solid #1c1c1c;background:#fff;border-radius:4px}
.ok{color:#1D5C2E}</style></head><body>
<h1>Copy a tabelline table into PowerPoint</h1>
<p>An experiment. Each table below is the HTML that <code>toClipboardHtml</code> makes: every style
inline on its cells. <b>Copy</b> puts it on the clipboard as HTML; paste it in a PowerPoint slide
(⌘V, or Paste Special → HTML) and it becomes a native table. If Copy is blocked here, press
<b>Select</b> and then ⌘C: the browser copies the same HTML.</p>
"""
for (n, t) in {"simplest": simplest, "home": home, "parts": parts}:
  page.add "<section><h2>" & n & "</h2><button data-copy=\"" & n & "\">Copy</button><button data-select=\"" & n &
    "\">Select</button><span class=\"ok\" id=\"ok-" & n & "\"></span><div class=\"scroll\" id=\"t-" & n & "\">" &
    t.toClipboardHtml & "</div></section>\n"
page.add """<script>
for (const b of document.querySelectorAll('[data-copy]')) b.onclick = async () => {
  const el = document.getElementById('t-' + b.dataset.copy), ok = document.getElementById('ok-' + b.dataset.copy)
  try {
    await navigator.clipboard.write([new ClipboardItem({
      'text/html': new Blob([el.innerHTML], {type: 'text/html'}),
      'text/plain': new Blob([el.innerText], {type: 'text/plain'})})])
    ok.textContent = 'copied: paste it in a slide'
  } catch (e) { ok.textContent = 'copy blocked here: use Select, then ⌘C' }
}
for (const b of document.querySelectorAll('[data-select]')) b.onclick = () => {
  const r = document.createRange(); r.selectNode(document.getElementById('t-' + b.dataset.select).firstElementChild)
  const s = getSelection(); s.removeAllRanges(); s.addRange(r)
}
</script></body></html>
"""
writeFile outDir / "copy.html", page
