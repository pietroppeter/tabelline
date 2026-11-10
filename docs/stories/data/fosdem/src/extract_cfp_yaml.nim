## Read every version of content/devrooms-cfp.yaml in FOSDEM's archived website repo
## (github.com/FOSDEM/website, 2012-2019 CfP seasons, so editions 2013-2020).
##
## Usage: extract_cfp_yaml <website git clone> <stage dir>
## For each edition (a commit from August on belongs to the next year's edition), keeps the
## last version of the file and writes one row per devroom: edition, day, devroom,
## announcement URL, deadline, and the date the devroom first appeared in the file.

import std/[osproc, tables, algorithm, unicode]
import common

type Row = object
  day, devroom, ann, deadline: string

let repo = paramStr(1)
let stage = paramStr(2)
const path = "content/devrooms-cfp.yaml"

proc git(args: varargs[string]): string =
  execProcess("git", args = @["-C", repo] & @args, options = {poUsePath}).replace("\r\n", "\n").replace("\r", "\n")

proc trimQuotes(s: string): string = s.strip(chars = {'\'', '"', ' '})

proc parse(text: string): seq[Row] =
  var day = ""
  var cur = -1
  if "\ndeadlines:" in text:  # 2012 layout: devroom -> ann (short ids), deadline, days
    for line in text.splitLines:
      let m = line.match(rx"""^  (?! )['"]?(.+?)['"]?:\s*$""")
      if m.ok:
        result.add Row(devroom: m.group(1).pyStrip); cur = result.high; continue
      let kv = line.match(rx"^\s+(ann|deadline|days):\s*(.*?)\s*$")
      let n = line.match(rx"^\s+-\s*(\S+)")
      if cur < 0: continue
      if kv.ok:
        let v = kv.group(2).trimQuotes
        case kv.group(1)
        of "days": result[cur].day = v
        of "ann": result[cur].ann = v
        else: result[cur].deadline = v
      elif n.ok and result[cur].ann.len == 0:
        result[cur].ann = n.group(1)
    for r in result.mitems:
      if r.ann.match(rx"^\d{4}-\w+/\d+$").ok:
        r.ann = "https://lists.fosdem.org/pipermail/fosdem/" & r.ann & ".html"
    return
  for line in text.splitLines:
    let d = line.match(rx"^  (\w+):\s*$")
    if d.ok and d.group(1) in ["both", "saturday", "sunday"]:
      day = d.group(1); continue
    let m = line.match(rx"""^    (?! )['"]?(.+?)['"]?:\s*$""")
    if m.ok and day.len > 0 and m.group(1) notin ["ann", "deadline"]:  # some versions lost an indent
      result.add Row(day: day, devroom: m.group(1).pyStrip); cur = result.high; continue
    let kv = line.match(rx"^\s+(ann|deadline):\s*(.*?)\s*$")
    if kv.ok and cur >= 0:
      if kv.group(1) == "ann": result[cur].ann = kv.group(2).trimQuotes
      else: result[cur].deadline = kv.group(2).trimQuotes

var editions: Table[int, (string, string, seq[Row])]
var firstSeen: Table[(int, string), string]
for line in git("log", "--reverse", "--format=%H %ad", "--date=short", "--", path).split("\n"):
  if line.pyStrip.len == 0: continue
  let parts = line.pySplit
  let (sha, date) = (parts[0], parts[1])
  let y = parseInt(date[0 ..< 4])
  let mo = parseInt(date[5 ..< 7])
  let ed = if mo >= 8: y + 1 else: y
  let rows = parse(git("show", sha & ":" & path))
  for r in rows:
    discard firstSeen.hasKeyOrPut((ed, unicode.toLower(r.devroom)), date)
  if rows.len > 0:
    editions[ed] = (sha, date, rows)

var table: seq[seq[string]]
var eds = toSeq(editions.keys)
eds.sort
var summary: seq[string]
for ed in eds:
  let (sha, date, rows) = editions[ed]
  summary.add $ed & ": " & $rows.len
  for r in rows:
    table.add @[$ed, r.day, r.devroom, r.ann, r.deadline, firstSeen[(ed, unicode.toLower(r.devroom))],
              date & " " & sha[0 ..< 7]]
writeCsv(stage, "cfp_yaml.csv", ["edition", "day", "devroom", "announcement", "deadline", "first_listed",
                                 "last_commit"], table)
echo summary.join(", ")
