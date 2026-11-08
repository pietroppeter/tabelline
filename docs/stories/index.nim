## The stories, docs/stories/index.html: real subjects told in tables made with tabelline, one for
## every release (the *use it* thread of the roadmap), newest release first. Each story is read from
## the first line of its source (`## story: <release> | <title> | <lede>`), so a new story needs no
## entry here; its card shows a small table from it when `preview` has one.
## Stories are kept up to date: when a release makes a table of a story better, the story changes.
## A story that used to be a devlog post keeps its old address, which forwards here (`moved`).
import std/[os, strutils, algorithm, options]
import nimib except md
import tabelline, tabelline/nimib
import ../blocchi, ../olimpiadi

let here = currentSourcePath().parentDir
let docs = here.parentDir

type Story = object
  slug, release, title, lede: string

var stories: seq[Story]
for kind, path in walkDir(here):
  let (_, name, ext) = path.splitFile
  if kind != pcFile or ext != ".nim" or name == "index": continue
  let first = readFile(path).splitLines[0]
  if not first.startsWith("## story:"): continue
  let parts = first["## story:".len .. ^1].split('|')
  if parts.len < 3: continue
  stories.add Story(slug: name.replace('_', '-'), release: parts[0].strip, title: parts[1].strip,
                    lede: parts[2 .. ^1].join("|").strip)
stories.sort(proc (a, b: Story): int = cmp(b.release, a.release))

proc preview(slug: string): Option[Tabella] =
  ## One small table of the story, for its card, if it has one.
  case slug
  of "milano-cortina":
    let d = readTsv("medals.tsv").top(3, ["gold", "silver", "bronze"])
    let t = tabella(d, rownameCol = "team"):
      tabHeader "The medal table, top three"
      colsHide ["rank", "code", "total"]
      colsLabel {"gold": "🥇", "silver": "🥈", "bronze": "🥉"}
      optPageTheme()
    some t
  else: none(Tabella)

nbInit
nb.doc.filename = here / "index.html"
nb.useTabelline(nome = "tabelline", materia = "Stories", classe = "one for every release",
               title = "tabelline stories", homeHref = "../",
               description = "Real subjects told in tables made with tabelline, one for every release.")

nbTitolo "Stories", "Told with tabelline", """
Real subjects, with real data, told in tables made with tabelline: one story for every release,
written as a user would write it, with the features that release adds. Stories are kept up to
date, so a table gets better when tabelline does. How tabelline itself is made is in the
[devlog](../devlog/).
"""
nbCards "the stories, newest release first":
  for s in stories:
    nbCard(s.title, s.slug & "/", "tabelline " & s.release):
      nbText s.lede
      let t = preview(s.slug)
      if t.isSome: nbTable t.get
nbSave

# Stories that were devlog posts: their old address forwards to the story.
const moved = [("devlog/milano-cortina", "stories/milano-cortina")]
for (old, story) in moved:
  let target = "../../" & story & "/"
  createDir(docs / old)
  writeFile(docs / old / "index.html", "<!doctype html>\n<html lang=\"en\"><head><meta charset=\"utf-8\">" &
    "<meta http-equiv=\"refresh\" content=\"0; url=" & target & "\"><link rel=\"canonical\" href=\"" &
    siteUrl & story & "/\"><title>Moved</title></head>\n<body><p>This page is now a story: <a href=\"" &
    target & "\">" & story & "</a>.</p></body></html>\n")
