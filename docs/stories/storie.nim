## *Storie*: the stories (`docs/stories/<slug>.nim`) and their gallery, shown on the home page and
## on the stories page. A story is found from the first line of its source
## (`## story: <release> | <title> | <lede>`), so a new story needs no entry here; its card shows a
## small table from it when `preview` has one. The last card says which story comes next, from the
## roadmap's data (`docs/piano.nim`).
import std/[os, strutils, algorithm, options, sequtils, parsecsv, streams]
import nimib
import tabelline, tabelline/nimib
import ../blocks, ../olimpiadi, ../piano

type Story* = object
  slug*, release*, title*, lede*: string

proc useIt(slug: string): bool =
  ## Is this the story of a release's *use it* thread (the roadmap links it)?
  for r in releases:
    for th in r.threads:
      if th.kind == "use" and th.href == "stories/" & slug & "/": return true

proc stories*(): seq[Story] =
  ## Every story, in release order (the first release first); in a release, the story of its
  ## *use it* thread first, then the others by title.
  for kind, path in walkDir(currentSourcePath().parentDir):
    let (_, name, ext) = path.splitFile
    if kind != pcFile or ext != ".nim": continue
    let first = readFile(path).splitLines[0]
    if not first.startsWith("## story:"): continue
    let parts = first["## story:".len .. ^1].split('|')
    if parts.len < 3: continue
    result.add Story(slug: name.replace('_', '-'), release: parts[0].strip, title: parts[1].strip,
                     lede: parts[2 .. ^1].join("|").strip)
  result.sort(proc (a, b: Story): int =
    result = cmp(a.release, b.release)
    if result == 0: result = cmp(not useIt(a.slug), not useIt(b.slug))
    if result == 0: result = cmp(a.title, b.title))

proc preview*(slug: string): Option[Tabella] =
  ## One small table of the story, for its card, if it has one.
  case slug
  of "milano-cortina":
    let d = readTsv("medals.tsv").top(3, ["total", "gold", "silver"])
    let t = tabella(d, rownameCol = "team"):
      tabHeader "Most medals, top three"
      colsHide ["rank", "code"]
      colsLabel {"gold": "🥇", "silver": "🥈", "bronze": "🥉", "total": "all"}
      optCssTheme()
    some t
  of "fosdem":
    let path = currentSourcePath().parentDir / "data" / "fosdem" / "story" / "devrooms_longest.csv"
    let d = readCsv(path, comment = "#").top(3, ["editions"])
    let t = tabella(d, rownameCol = "devroom"):
      tabHeader "The longest-running devrooms"
      colsHide ["first", "last", "longest_run", "talks", "n_names", "names", "in_2027"]
      colsLabel {"editions": "editions"}
      optCssTheme()
    some t
  of "fosdem-data":
    type File = object
      table: string
      rows: int
    var files: seq[File]
    for name in ["events", "people", "stands"]:
      let path = currentSourcePath().parentDir / "data" / "fosdem" / name & ".csv"
      var p: CsvParser
      p.open(newStringStream(readFile(path).splitLines.filterIt(not it.startsWith("#")).join("\n")), path)
      p.readHeaderRow()
      var n = 0
      while p.readRow(): inc n
      files.add File(table: name & ".csv", rows: n)
    let t = tabella(files, rownameCol = "table"):
      tabHeader "Three of the ten tables"
      fmtInteger ["rows"]
      optCssTheme()
    some t
  of "isole":
    let path = currentSourcePath().parentDir / "data" / "isole" / "islands.csv"
    let d = readCsv(path, comment = "#")
    var names: seq[string]
    var shapes: seq[Value]
    for i in 0 ..< 3:
      names.add $d["island", i]
      shapes.add toValue((x: ($d["x", i]).splitWhitespace.mapIt(it.parseFloat),
                          y: ($d["y", i]).splitWhitespace.mapIt(it.parseFloat)))
    let shapesData = tableData:
      island: names
      outline: shapes
      km2: toSeq(0 ..< 3).mapIt(d["km2", it])
    let t = tabella(shapesData, rownameCol = "island"):
      tabHeader "The three largest, at one scale"
      fmtNanoplot "outline", plotType = "shape", autoscale = true, plotHeight = "3.5em"
      fmtInteger "km2"
      colsLabel:
        outline: ""
        km2: "km²"
      optCssTheme()
    some t
  else: none(Tabella)

proc next*(): string =
  ## The next story on the roadmap: the first *use it* thread not done yet, with its release.
  for r in releases:
    for th in r.threads:
      if th.kind == "use" and th.status != "done":
        return th.title.replace("Use it: ", "") & " (tabelline " & r.version & ")"

template nbStorie*(base: string) =
  ## The gallery of the stories: one card for each, linked (`base` is the path to docs/stories/
  ## from the page), and a last card for the stories to come.
  nbGallery "the stories, in release order":
    for s in stories():
      nbGalleryCard("[" & s.title & "](" & base & s.slug & "/)", "tabelline " & s.release):
        nbText s.lede
        let t = preview(s.slug)
        if t.isSome: nbTable t.get
    nbGalleryCard("More stories will come", "next"):
      nbText "One for every release, on real data. Next: " & next() & "."
