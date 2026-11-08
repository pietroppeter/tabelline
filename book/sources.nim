## The sources the book plans to port, as tables: book/plan/sources.json (written by hand) and
## book/plan/pages.json (written by book/plan/plan.py), read when the chapter compiles.
import std/[json, strutils, sequtils, algorithm]
import tabelline
export json

const
  sourcesJson = staticRead("plan/sources.json")
  pagesJson = staticRead("plan/pages.json")
  releases = ["0.1", "0.2", "0.3", "0.4", "0.5", "new", "later"]

let
  sources* = parseJson(sourcesJson)
  pages* = parseJson(pagesJson)

proc whenLabel(r: string): string =
  case r
  of "0.1": "now"
  of "new": "a new gap"
  of "later": "later"
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
    let ps = pages[s["id"].getStr].getElems
    var counts: seq[string]
    if s["status"].getStr == "ported":
      counts.add "ported (Nanoplots in 0.4)"
    else:
      for r in releases:
        let n = ps.countIt(it["ready"].getStr == r)
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
  var ps = pages[id].getElems
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
    var ready = whenLabel(p["ready"].getStr).capitalizeAscii
    if p["port"].getStr == "skip": ready = "Left out"
    elif ported and p["ready"].getStr != "0.4": ready = "Ported"
    rows.add PageRow(page: page, ready: ready,
                     needs: needs.join("<br>"))
  tabella(rows, rownameCol = "", groupnameCol = ""):
    colsLabel {"page": "Page", "ready": "Can be ported", "needs": "What it waits for"}
    fmtMarkdown ["page", "needs"]
    optCssTheme()
