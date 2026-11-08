## *Storie*: the stories (`docs/stories/<slug>.nim`) and their gallery, shown on the home page and
## on the stories page. A story is found from the first line of its source
## (`## story: <release> | <title> | <lede>`), so a new story needs no entry here; its card shows a
## small table from it when `preview` has one. The last card says which story comes next, from the
## roadmap's data (`docs/piano.nim`).
import std/[os, strutils, algorithm, options]
import nimib except md
import tabelline, tabelline/nimib
import ../blocchi, ../olimpiadi, ../piano

type Story* = object
  slug*, release*, title*, lede*: string

proc stories*(): seq[Story] =
  ## Every story, newest release first.
  for kind, path in walkDir(currentSourcePath().parentDir):
    let (_, name, ext) = path.splitFile
    if kind != pcFile or ext != ".nim": continue
    let first = readFile(path).splitLines[0]
    if not first.startsWith("## story:"): continue
    let parts = first["## story:".len .. ^1].split('|')
    if parts.len < 3: continue
    result.add Story(slug: name.replace('_', '-'), release: parts[0].strip, title: parts[1].strip,
                     lede: parts[2 .. ^1].join("|").strip)
  result.sort(proc (a, b: Story): int = cmp(b.release, a.release))

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
  nbGalleria "the stories, newest release first":
    for s in stories():
      nbScheda("[" & s.title & "](" & base & s.slug & "/)", "tabelline " & s.release):
        nbText s.lede
        let t = preview(s.slug)
        if t.isSome: nbTable t.get
    nbScheda("More stories will come", "next"):
      nbText "One for every release, on real data. Next: " & next() & "."
