## Parse FOSDEM track pages (archive.fosdem.org/<year>/schedule/track/<slug>/), 2013-2026.
##
## Usage: extract_trackpages <raw/archive/tracks dir> <stage dir>
## Writes track_pages.csv: year, track_slug, track, group (the breadcrumb level above the
## track, such as "Developer rooms", when the site shows one), rooms, CfP link.

import std/[tables, algorithm]
import common

let src = paramStr(1)
let stage = paramStr(2)

proc listdir(d: string): seq[string] =
  for kind, f in walkDir(d, relative = true): result.add f
  result.sort

proc unique(xs: seq[string]): seq[string] =
  for x in xs:
    if x notin result: result.add x

var rows: seq[seq[string]]
var years: seq[int]
var withCfp = 0
for y in listdir(src):
  let d = src / y
  if not y.fullmatch(rx"\d+") or not dirExists(d): continue
  let idx = d / "index.html"
  var groups: Table[string, string]
  if fileExists(idx):  # the tracks index groups tracks under headings (Main tracks, Developer rooms, ...)
    let s = readText(idx)
    var heading = ""
    for m in s.finditer(rx("(?s)<h[34][^>]*>(.*?)</h[34]>|href=\"/" & y & "/schedule/track/([^/\"]+)/\"")):
      if m.has(1): heading = text(m.group(1))
      elif m.group(2).len > 0: discard groups.hasKeyOrPut(m.group(2), heading)
  for fn in listdir(d):
    if fn == "index.html": continue
    let slug = fn.sl(0, -5)
    let s = readText(d / fn)
    let h1 = s.search(rx"""(?s)<div id="pagetitles">\s*<h1>(.*?)</h1>""")
    let bstart = s.pyFind("""class="breadcrumbs"""")
    let crumbs = s.sl(bstart, s.pyFind("</ul>", bstart)).findall(rx"""(?s)<li(?: class="active")?>(.*?)</li>""", 1)
                  .mapIt(text(it)).filterIt(it.len > 0 and it != "/")
    let group = if crumbs.len >= 5: crumbs[^2] else: groups.getOrDefault(slug, "")
    let side = s.search(rx"""(?s)<p class="side-box">(.*?)</p>""")
    let rooms = if side.ok: side.group(1).findall(rx"""/schedule/room/[^"]+/">([^<]+)</a>""", 1) else: @[]
    let box = s.search(rx"""(?s)class="[^"]*track-cfp[^"]*">(.*?)</div>""")
    let cfp = if box.ok: box.group(1).search(rx"""href="([^"]+)"|(https?://[^\s<]+)""") else: Match()
    let link = if cfp.ok: (if cfp.group(1).len > 0: cfp.group(1) else: cfp.group(2)) else: ""
    rows.add @[$parseInt(y), slug, (if h1.ok: text(h1.group(1)) else: slug), group, rooms.unique.join("; "), link]
    years.add parseInt(y)
    if link.len > 0: inc withCfp

writeCsv(stage, "track_pages.csv", ["year", "track_slug", "track", "group", "rooms", "cfp_link"], rows)
echo counts(years), withCfp, " with CfP link"
