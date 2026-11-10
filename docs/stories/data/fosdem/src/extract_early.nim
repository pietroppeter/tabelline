## Parse the main schedule grids of FOSDEM 2001-2006 (OSDEM 2001, FOSDEM 2002-2006).
##
## Usage: extract_early <raw/archive/html dir> <stage dir>
## Writes early_events.csv: year, day, start, end, room, cell (as printed), title, speakers.
## Each year printed its grid a bit differently, so the split of a cell into title and
## speakers follows the year's convention (see `split`). Cells that span all rooms are
## plenary talks in the first room.

import std/[algorithm, sets]
import common, grid

let root = paramStr(1)
let stage = paramStr(2)
const files = [(2001, "2001/program/index.html"), (2002, "2002/schedule/index.html"),
               (2003, "2003/index/schedule.html"), (2004, "2004/2004/index/schedule.html"),
               (2005, "2005/2005/index/schedule.html"), (2006, "2006/2006/index/schedule.html")]
let time = rx"^(\d\d?)[:h](\d\d)\s*(?:-|->|→)\s*(\d\d?)[:h](\d\d)"
let skip = rx"(?i)^(-|/|lunch.*|party|)$"
let devroom = rx"(?i)developers?'? ?room"

proc hhmm(h, m: string): string = align($parseInt(h), 2, '0') & ":" & m

proc split(year: int, cell: string): (string, string, string) =
  ## (title, speakers, room) for a schedule cell.
  var c = cell
  var room = ""
  let j = c.search(rx"\((Jan?s?son)\)")
  if j.ok:
    room = "Janson"; c = (c[0 ..< j.start] & c[j.stop .. ^1]).strip(chars = {' ', '/'})
  if year == 2001:
    let m = c.match(rx"(.+?):\s*(.+)")
    if m.ok and m.group(1).pySplit.len <= 3 and not c.search(rx"(?i)round table|strategies").ok:
      return (m.group(2).pyStrip, m.group(1).pyStrip, room)
    let b = c.match(rx"(.+?) by (.+)")
    if b.ok: return (b.group(1).pyStrip, b.group(2).pyStrip, room)
    return (c, "", room)
  if year == 2002:
    let m = c.match(rx"(.+?):\s*(.+)")
    if m.ok:
      return (m.group(1).pyStrip, m.group(2).sub(rx"\s*[-(]\s*(USA|UK)\)?$", "").strip(chars = {' ', '.'}), room)
    return (c, "", room)
  let parts = c.split(" / ").mapIt(it.pyStrip).filterIt(it.len > 0)
  if parts.len >= 2: return (parts[0 ..< ^1].join(" "), parts[^1], room)
  (c, "", room)

proc normRoom(room: string): string =
  var r = room
  let m = r.search(rx"\((\w+?)(?: room)?$")
  if m.ok: r = m.group(1)
  r = r.sub(rx"\s*\(\d+\)|:\s*\d+ places", "").replace(" / ", " ").pyStrip
  if r == "Jansson": r = "Janson"
  r.capitalFirst

var rows: seq[seq[string]]
var devrooms: HashSet[(int, string, string)]
var years: seq[int]
for (year, fn) in files:
  for g in tables(root / fn):
    var header: seq[string]
    var hasHeader = false
    var day = ""
    for r in g:
      if r.len == 0: continue
      let first = r[0]
      let dm = r[0 ..< min(3, r.len)].join(" ").search(rx"(Saturday|Sunday)")
      if dm.ok and not first.match(time).ok:
        day = dm.group(1)
        if r[1 .. ^1].anyIt(it.search(rx"(?i)room|places|\(\d+\)|chavanne|janson|lameere").ok):
          header = r; hasHeader = true
        continue
      if not hasHeader and r[1 .. ^1].anyIt(it.search(rx"(?i)\(\d+\)|chavanne|lameere").ok):
        header = r; hasHeader = true
        continue
      let m = first.match(time)
      if not m.ok or day.len == 0: continue
      let start = hhmm(m.group(1), m.group(2))
      let stop = hhmm(m.group(3), m.group(4))
      let cells = r[1 .. ^1]
      let filled = cells.filterIt(not it.pyStrip.match(skip).ok)
      var seen: HashSet[string]
      for i, raw in cells:
        let cell = raw.pyStrip
        let inHeader = header.len > 0 and i + 1 < header.len
        if cell.search(devroom).ok and cell notin seen:
          devrooms.incl (year, cell.sub(rx"(?i)\s*developers?'? ?room", "").pyStrip,
                         (if inHeader: normRoom(header[i + 1]) else: ""))
        if cell.match(skip).ok or cell.search(devroom).ok or cell in seen: continue
        seen.incl cell
        let plenary = filled.len > 1 and filled.allIt(it == cell)
        var room = if inHeader: header[i + 1] else: ""
        var (title, speakers, room2) = split(year, cell)
        if plenary or room2.len > 0:
          room = if room2.len > 0: room2 elif header.len > 0: header[1] else: ""
        room = normRoom(room)
        if year == 2006 and title.startsWith("Welcome of visitors"):
          (title, speakers) = ("Welcome of visitors followed by Richard M Stallman's keynote", "Richard M Stallman")
        if title.startsWith("FOSDEM Return Operation"):
          (title, speakers) = (cell.replace(" / ", " "), "")
        rows.add @[$year, day, start, stop, room, cell, title, speakers]
        years.add year

var dr = toSeq(devrooms)
dr.sort
writeCsv(stage, "early_events.csv", ["year", "day", "start", "end", "room", "cell", "title", "speakers"], rows)
writeCsv(stage, "early_grid_devrooms.csv", ["year", "devroom", "room"], dr.mapIt(@[$it[0], it[1], it[2]]))
echo dr.len, " devrooms in the grids; ", counts(years)
