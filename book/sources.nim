## The sources the book plans to port, as tables: book/plan/sources.json (written by hand) and
## book/plan/pages.json (written by book/plan/plan.nim, which searches each source's repository
## for its pages), read when the chapter compiles. `featureButtons` and `featurePages` turn them
## around: for every feature of the coverage map (docs/coverage/gt.json), the pages that show it.
import std/[json, strutils, sequtils, algorithm, tables, sets]
import tabelline
export json

const
  sourcesJson = staticRead("plan/sources.json")
  pagesJson = staticRead("plan/pages.json")
  coverageJson = staticRead("../docs/coverage/gt.json")
  releases = ["now", "new", "later", "other"]  ## as in book/plan/plan.nim

let
  sources* = parseJson(sourcesJson)
  pages* = parseJson(pagesJson)
  coverage = parseJson(coverageJson)

proc pagesOf*(id: string): seq[JsonNode] = pages[id]["pages"].getElems

proc isReference*(s: JsonNode): bool = s["kind"].getStr == "reference"

proc isContest*(s: JsonNode): bool = s["kind"].getStr == "contest"

proc whenLabel(r: string): string =
  case r
  of "now": "now"
  of "new": "a new gap"
  of "later": "later"
  of "other": "not with gt"
  else: "in " & r

proc mdLink(title, url: string): string = "[" & title & "](" & url & ")"

type SourceRow = object
  source: string
  pages: int
  ready: string

proc sourcesTable*(): Tabella =
  ## One row per source, in the order of sources.json (from the simplest to the most complex).
  var rows: seq[SourceRow]
  for s in sources["sources"]:
    let ps = pagesOf(s["id"].getStr)
    var counts: seq[string]
    if s["status"].getStr == "ported":
      counts.add "ported"
    else:
      let inBook = ps.countIt(it{"book"}.getStr != "")
      if inBook > 0: counts.add $inBook & " ported"
      for r in releases:
        let n = ps.countIt(it["ready"].getStr == r and it["port"].getStr != "skip" and
                           it{"book"}.getStr == "")
        if n > 0: counts.add $n & " " & (if r == "new": "with a new gap" else: whenLabel(r))
    rows.add SourceRow(source: mdLink(s["title"].getStr, s["url"].getStr) & "<br>*" &
                         s["licence"].getStr & " licence*",
                       pages: ps.len, ready: counts.join("<br>"))
  tabella(rows, rownameCol = "", groupnameCol = ""):
    colsLabel {"source": "Source", "pages": "Pages", "ready": "Can be ported"}
    fmtMarkdown ["source", "ready"]
    optCssTheme()

type CandidateRow = object
  source, what: string

proc candidatesTable*(): Tabella =
  var rows: seq[CandidateRow]
  for c in sources["candidates"]:
    rows.add CandidateRow(source: mdLink(c["title"].getStr, c["url"].getStr) & "<br>*" &
                            c["licence"].getStr & "*", what: c["what"].getStr)
  tabella(rows, rownameCol = "", groupnameCol = ""):
    colsLabel {"source": "Source", "what": "What it has"}
    fmtMarkdown ["source"]
    optCssTheme()

type PageRow = object
  page, ready, needs: string

proc pagesTable*(id: string, ported = false): Tabella =
  ## The pages of one source, from the ones that can be ported now to the ones that wait longest.
  ## For a source already ported, its pages say so, except the ones left out.
  var ps = pagesOf(id)
  ps.sort(proc (a, b: JsonNode): int =
    cmp(releases.find(a["ready"].getStr), releases.find(b["ready"].getStr)), SortOrder.Ascending)
  var rows: seq[PageRow]
  for p in ps:
    var needs: seq[string]
    for r in releases:
      if p["needs"].hasKey(r):
        needs.add "*" & whenLabel(r).capitalizeAscii & ":* " & p["needs"][r].getElems.mapIt(it.getStr).join(", ")
    var page = mdLink(p["title"].getStr, p["url"].getStr)
    if p["note"].getStr != "": page.add "<br>" & p["note"].getStr
    if p{"book"}.getStr != "": page.add "<br>**[In this book](" & p["book"].getStr & ")**"
    var ready = whenLabel(p["ready"].getStr).capitalizeAscii
    if p["port"].getStr == "skip": ready = "Left out"
    elif p["port"].getStr == "triage": ready = "To triage: " & ready
    elif ported or p{"book"}.getStr != "": ready = "Ported"
    rows.add PageRow(page: page, ready: ready,
                     needs: needs.join("<br>"))
  tabella(rows, rownameCol = "", groupnameCol = ""):
    colsLabel {"page": "Page", "ready": "Can be ported", "needs": "What it waits for"}
    fmtMarkdown ["page", "needs"]
    optCssTheme()

# ---------------------------------------------------------------- the Table Contest

proc entryCell(p: JsonNode): string =
  ## An entry: its title (to its code), then year, author, prize, what it is made with, licence.
  result = mdLink(p["title"].getStr, p["url"].getStr)
  var facts = @[$p["year"].getInt & ", " & p{"by"}.getStr]
  if p{"prize"}.getStr != "": facts.add "**" & p["prize"].getStr & "**"
  if p{"package"}.getStr != "": facts.add p["package"].getStr
  facts.add(if p{"licence"}.getStr != "": p["licence"].getStr else: "no licence")
  result.add "<br>*" & facts.join(" · ") & "*"
  if p["note"].getStr != "": result.add "<br>" & p["note"].getStr
  if p{"post"}.getStr != "": result.add "<br>[The post](" & p["post"].getStr & ")"
  if p{"book"}.getStr != "": result.add " · **[In this book](" & p["book"].getStr & ")**"

proc contestEntries*(id: string, upTo = "", since = "", other = false): seq[JsonNode] =
  ## The entries of a contest source made with gt, ready by `upTo` (or from `since` on), or the
  ## ones made with another package (`other`): by readiness, then awarded first, then by year.
  for p in pagesOf(id):
    let r = releases.find(p["ready"].getStr)
    if other != (p["ready"].getStr == "other"): continue
    if upTo != "" and r > releases.find(upTo): continue
    if since != "" and r < releases.find(since): continue
    result.add p
  result.sort(proc (a, b: JsonNode): int =
    result = cmp(releases.find(a["ready"].getStr), releases.find(b["ready"].getStr))
    if result == 0: result = cmp(b{"prize"}.getStr != "", a{"prize"}.getStr != "")
    if result == 0: result = cmp(b["year"].getInt, a["year"].getInt))

type EntryRow = object
  entry, ready, needs: string

proc contestTable*(entries: seq[JsonNode]): Tabella =
  ## Entries made with gt: the release that can redo each, and what it waits for.
  var rows: seq[EntryRow]
  for p in entries:
    var needs: seq[string]
    for r in releases:
      if p["needs"].hasKey(r):
        needs.add "*" & whenLabel(r).capitalizeAscii & ":* " & p["needs"][r].getElems.mapIt(it.getStr).join(", ")
    let ready = if p{"book"}.getStr != "": "Done" else: whenLabel(p["ready"].getStr).capitalizeAscii
    rows.add EntryRow(entry: entryCell(p), ready: ready,
                      needs: needs.join("<br>"))
  tabella(rows, rownameCol = "", groupnameCol = ""):
    colsLabel {"entry": "Entry", "ready": "Can be done", "needs": "What it waits for"}
    fmtMarkdown ["entry", "needs"]
    optCssTheme()

type OtherRow = object
  entry: string

proc otherTable*(entries: seq[JsonNode]): Tabella =
  ## Entries made without gt: what they are, and what they are made with.
  tabella(entries.mapIt(OtherRow(entry: entryCell(it))), rownameCol = "", groupnameCol = ""):
    colsLabel {"entry": "Entry"}
    fmtMarkdown ["entry"]
    optCssTheme()

proc countReady*(entries: seq[JsonNode], r: string): int = entries.countIt(it["ready"].getStr == r)

# ---------------------------------------------------------------- by feature

proc planOf(row: JsonNode): string =
  ## The release a row of the coverage map is ready in (as `planOf` in book/plan/plan.nim).
  let plan = row{"plan"}.getStr
  let planned = if plan in ["0.1", "0.2"]: "now" elif plan in releases: plan else: "later"
  case row["status"].getStr
  of "done": "now"
  of "partial": (if plan != "": planned else: "now")
  of "no": (if row["feature"].getStr == "Sizes": "now" else: "later")
  else: planned

proc gtNames(gt: string): HashSet[string] =
  ## The functions a row of the coverage map names, without namespaces: fmt_number, cells_body.
  for part in gt.split(", "):
    if part.endsWith("()"): result.incl part[0 ..< ^2].split(".")[^1]

type Shown = object
  page: JsonNode
  lang, source: string
  own: bool  ## the help page of one of the feature's own functions

proc byFeature(): Table[string, seq[Shown]] =
  ## For every feature, the pages that show it: the help pages of its own functions first, then
  ## the others from the smallest (fewest calls), as `plan.nim <feature>` lists them.
  var lang: Table[string, string]
  for s in sources["sources"]: lang[s["id"].getStr] = s["lang"].getStr
  var own: Table[string, HashSet[string]]
  for a in coverage["areas"]:
    for r in a["rows"]:
      result[r["feature"].getStr] = @[]
      own[r["feature"].getStr] = gtNames(r["gt"].getStr)
  for id, o in pages:
    for p in o["pages"]:
      if p["port"].getStr == "skip": continue
      let name = p["title"].getStr.replace("()", "").split(".")[^1]
      for f in p["uses"]:
        result[f.getStr].add Shown(page: p, lang: lang[id], source: id, own: name in own[f.getStr])
  for f, ps in result.mpairs:
    ps.sort(proc (a, b: Shown): int =
      result = cmp(b.own, a.own)
      if result == 0: result = cmp(a.page["calls"].getInt, b.page["calls"].getInt)
      if result == 0: result = cmp(a.page["title"].getStr, b.page["title"].getStr))

proc removePrefix2(s, prefix: string): string =
  if s.startsWith(prefix): s[prefix.len .. ^1] else: s

proc featureId*(feature: string): string =
  ## The anchor of a feature's pages: `f-` and its name in lower case, words joined by `-`.
  result = "f"
  for w in feature.toLowerAscii.split({' ', ',', '(', ')', '/', '.', '\'', '`'}):
    if w.len > 0: result.add "-" & w

proc features*(): seq[string] =
  ## Every feature of the coverage map, in its order.
  for a in coverage["areas"]:
    for r in a["rows"]: result.add r["feature"].getStr

let featureIndex = byFeature()

proc button(feature: string): string =
  ## A feature as a link to its pages, with how many there are: drawn as a plain button.
  "[" & feature & " **" & $featureIndex[feature].len & "**](#" & featureId(feature) & ")"

type FinderRow = object
  area, release, features: string

proc featureButtons*(): Tabella =
  ## The features of the coverage map by area: the ones in tabelline now, then the ones to come,
  ## each a button that shows the pages using it.
  var rows: seq[FinderRow]
  for a in coverage["areas"]:
    var now, coming: seq[string]
    for r in a["rows"]:
      if planOf(r) == "now": now.add button(r["feature"].getStr)
      else: coming.add button(r["feature"].getStr)
    if now.len > 0: rows.add FinderRow(area: a["title"].getStr, release: "Now", features: now.join(" "))
    if coming.len > 0: rows.add FinderRow(area: a["title"].getStr, release: "Coming", features: coming.join(" "))
  tabella(rows, rownameCol = "release", groupnameCol = "area"):
    colsLabel {"features": "Features, with how many pages show each"}
    fmtMarkdown ["features"]
    optCssTheme()

proc featureTitle*(feature: string): string =
  ## The heading of a feature's pages: its name, the release that has it and how many pages.
  var row: JsonNode
  for a in coverage["areas"]:
    for r in a["rows"]:
      if r["feature"].getStr == feature: row = r
  let n = featureIndex[feature].len
  feature & " (" & whenLabel(planOf(row)) & ", " & (if n == 1: "1 page" else: $n & " pages") & ")"

type FoundRow = object
  source, page: string

proc featurePages*(feature: string): Tabella =
  ## Every page that uses `feature`, by source (in the order of sources.json), the help pages of
  ## the feature's own functions first, then from the smallest: what to port with it. Under each
  ## page, when it can be ported and how many calls its code makes.
  var bySource: Table[string, seq[Shown]]
  for sh in featureIndex[feature]: bySource.mgetOrPut(sh.source, @[]).add sh
  var rows: seq[FoundRow]
  for s in sources["sources"]:
    let id = s["id"].getStr
    if id notin bySource: continue
    let emoji = (case s["lang"].getStr
                 of "R": " 🏴‍☠️"
                 of "Python": " 🐍"
                 else: " 🏆")
    for sh in bySource[id]:
      let p = sh.page
      var ready = whenLabel(p["ready"].getStr).capitalizeAscii
      if p{"book"}.getStr != "" or s["status"].getStr == "ported": ready = "Ported"
      let calls = p["calls"].getInt
      var page = mdLink(p["title"].getStr, p["url"].getStr) & "<br>*" & ready & " · " &
        (if calls == 1: "1 call" else: $calls & " calls") & "*"
      if p{"book"}.getStr != "": page.add " · **[In this book](" & p["book"].getStr & ")**"
      rows.add FoundRow(source: s["title"].getStr & emoji, page: page)
  tabella(rows, rownameCol = "", groupnameCol = "source"):
    colsLabel {"page": "Page"}
    fmtMarkdown ["page"]
    optCssTheme()
