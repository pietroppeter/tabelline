## Parse FOSDEM 2003-2006 devroom pages: the devroom list and each devroom's schedule page.
##
## Usage: extract_early_devrooms <raw/archive/html dir> <stage dir>
## Writes early_devrooms.csv (year, key, devroom) and early_devroom_events.csv
## (year, key, day, start, end, title, speakers). The pages are free-form, so this is a
## best effort: two layouts are recognised (time before the title, or time before the speaker).

import std/[algorithm, unicode]
import common, grid

let root = paramStr(1)
let stage = paramStr(2)
const T = r"(\d\d?)[.:h](\d\d)"
var devrooms, events: seq[seq[string]]
var dyears, eyears: seq[int]

proc hhmm(h, m: string): string = align($parseInt(h), 2, '0') & ":" & m

proc heading(path: string): string =
  let s = readText(path).sub(rx"<[^>]+>", "|")
  let m = s.search(rx"\|\s*(?:Welcome to the )?([^|]{2,60}?) [Dd]evelopers?'?s?'? ?room")
  if m.ok: m.group(1).sub(spaces, " ").pyStrip else: ""

proc looksLikeName(s: string): bool =
  let w = s.pySplit
  w.len in 1..6 and not (s.endsWith(".") or s.endsWith("!") or s.endsWith("?") or s.endsWith(":")) and
    s.len > 0 and s.runeAt(0).isUpper

for y in 2003 .. 2006:
  let base = if y > 2003: root / $y / $y / "index" else: root / "2003" / "index"
  var pages: seq[string]
  for kind, f in walkDir(base):
    if f.extractFilename.startsWith("dev_room_") and f.endsWith(".html"): pages.add f
  pages.sort
  if y == 2003:
    let s = readText(base / "dev_room.html").sub(rx"<[^>]+>", " ")
    var seen: seq[string]
    for n in s.findall(rx"([A-Z][\w.+/ -]{1,40}?) (?:developers|softwares) room", 1):
      let name = n.pyStrip
      if name notin seen:
        seen.add name
        devrooms.add @[$y, unicode.toLower(name).replace(" ", ""), name]; dyears.add y
    continue
  for p in pages:
    let key = p.extractFilename.sl("dev_room_".len, -5)
    let h = heading(p)
    devrooms.add @[$y, key, (if h.len > 0: h else: key)]; dyears.add y
    let sched = base / "dev_room_" & key / "schedule.html"
    if not fileExists(sched): continue
    var day = ""
    for g in tables(sched):
      for row in g:
        let r = row.filterIt(it.pyStrip.len > 0)
        if r.len < 2: continue
        let dm = r[0].search(rx"(Saturday|Sunday|Friday)")
        if dm.ok and r[0] == r[1]:
          day = dm.group(1); continue
        if day.len == 0: continue
        let (a, b) = (r[0], r[1])
        let m = a.match(rx(T & r"(?:\s*(?:-+>?|–|→|\x{FFFD}|to)\s*" & T & r")?[\s:/.-]*(.*)"))
        if m.ok:
          let start = hhmm(m.group(1), m.group(2))
          let stop = if m.group(3).len > 0: hhmm(m.group(3), m.group(4)) else: ""
          var title = m.group(5).pyStrip
          var parts = b.split(" / ").mapIt(it.pyStrip)
          if title.len == 0:
            title = parts[0]
            parts = if parts.len > 1: parts[1 .. ^1] else: @[]
          let spk = if parts.len > 0 and looksLikeName(parts[^1]) and parts[^1] != title: parts[^1] else: ""
          events.add @[$y, key, day, start, stop, title, spk]; eyears.add y
          continue
        let n = b.match(rx(T & r"\s*\S*\s*" & T & r"\s*(?:/\s*(.*))?"))
        if n.ok:
          events.add @[$y, key, day, hhmm(n.group(1), n.group(2)), hhmm(n.group(3), n.group(4)),
                       a.pyStrip, n.group(5).pyStrip]; eyears.add y

writeCsv(stage, "early_devrooms.csv", ["year", "devroom_key", "devroom"], devrooms)
writeCsv(stage, "early_devroom_events.csv", ["year", "devroom_key", "day", "start", "end", "title", "speakers"], events)
echo counts(dyears), "| ", counts(eyears)
