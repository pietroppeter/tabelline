## Read the stands of every edition from FOSDEM's archived stands pages (2008-2026).
##
## Usage: extract_stands <raw/stands dir> <stage dir>
## Expects <year>.html from fetch.sh: stands.html for 2008-2012, stands/ from 2013. Writes
## stands.csv (year, stand, building, theme, position): one row per stand as the page lists it
## (a stand shared by two projects is one row, "OpenBSD + OpenSSH").

import std/algorithm
import common

let src = paramStr(1)
let stage = paramStr(2)

var names: seq[string]
for kind, f in walkDir(src, relative = true): names.add f
names.sort
var rows: seq[seq[string]]
for name in names:
  let m = name.match(rx"(\d{4})\.html$")
  if not m.ok: continue
  let year = parseInt(m.group(1))
  let s = readText(src / name)
  var found: seq[(string, string, string)]
  if year <= 2012:
    # an announcement: <h2> buildings (2012) and <li> stands, in the content node
    let a = s.pyFind("""<div class="content">""", s.pyFind("""id="node-"""))
    let b = s.pyFind("""<div class="clearfix">""", a)
    let body = s.sl(a, b)
    var building = ""
    for t in body.finditer(rx"(?s)<(h2|li)[^>]*>(.*?)</\1>"):
      if t.group(1) == "h2":
        building = text(t.group(2)).replace(" building", "").pyStrip
      else:
        found.add (text(t.group(2)), building, "")
  elif year in [2021, 2022]:
    # online: one card per stand, "<h4>Box86 stand <small>Stand</small></h4>"
    for inner in s.findall(rx"(?s)<h4>(.*?)<small>", 1):
      found.add (text(inner).sub(rx"(?i)\s+stand$", ""), "online", "")
  else:
    # tables: a building heading per table, rows of stands (2026: themes as <h5> rows)
    for table in s.findall(rx"(?s)<table.*?</table>"):
      let h = table.search(rx"(?s)<h4>(.*?)</h4>")
      let building = if h.ok: text(h.group(1)) else: ""
      var theme = ""
      for tr in table.findall(rx"(?s)<tr>(.*?)</tr>", 1):
        let h5 = tr.search(rx"(?s)<h5>(.*?)</h5>")
        if h5.ok:
          theme = text(h5.group(1))
          continue
        let p = tr.search(rx"""(?s)class="stands-table-project"[^>]*>(.*?)</td>""")
        if p.ok:
          found.add (text(p.group(1)), building, theme)
          continue
        let tds = tr.findall(rx"(?s)<td[^>]*>(.*?)</td>", 1)
        if tds.len == 2 and text(tds[0]).fullmatch(rx"\d+"):
          found.add (text(tds[1]), building, theme)
  for i, (stand, building, theme) in found:
    if stand.len > 0:
      rows.add @[$year, stand, building, theme, $(i + 1)]

writeCsv(stage, "stands.csv", ["year", "stand", "building", "theme", "position"], rows)
echo rows.len, " stands"
