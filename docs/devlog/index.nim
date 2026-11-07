## The devlog's index, docs/devlog/index.html: the living documents (a table below: add a row for
## a new one), then every dated post, newest first, read from the first line of its source
## (`## devlog: <dd Mon yyyy> <letter> | <title> | <lede>`). Posts of the same day take a letter
## in the order they were written (07 Nov 2026 A, B, C, ...), so the newest is still first; the
## letter can be left out for a day with one post. A new post needs no entry here.
import std/[os, strutils, times, algorithm, strformat]
import nimib except md
import ../quaderno

let here = currentSourcePath().parentDir

type Post = object
  slug, date, title, lede: string
  day: DateTime
  letter: string

var posts: seq[Post]
for kind, path in walkDir(here):
  let (_, name, ext) = path.splitFile
  if kind != pcFile or ext != ".nim" or name == "index": continue
  let first = readFile(path).splitLines[0]
  if not first.startsWith("## devlog:"): continue
  let parts = first["## devlog:".len .. ^1].split('|')
  if parts.len < 3: continue
  let stamp = parts[0].strip.splitWhitespace   # dd Mon yyyy, then maybe a letter
  posts.add Post(slug: name.replace('_', '-'), date: parts[0].strip, title: parts[1].strip,
                 lede: parts[2 .. ^1].join("|").strip, day: parse(stamp[0 .. 2].join(" "), "dd MMM yyyy"),
                 letter: (if stamp.len > 3: stamp[3] else: ""))
posts.sort(proc (a, b: Post): int = cmp((b.day, b.letter), (a.day, a.letter)))

nbInit
nb.doc.filename = here / "index.html"
nb.useQuaderno(nome = "tabelline", materia = "Devlog", classe = "living pages · posts",
               title = "tabelline devlog", homeHref = "../")

type Living = tuple[href, title, what, updated: string]
let living: seq[Living] = @[
  ("../explainer/", "Explainer", "What gt and Great Tables are, how they work, who uses them, and tabelline step by step.",
   "as tabelline grows"),
  ("../specs/", "Specs", "How tabelline behaves today: requirements with examples that run, and the tables they make.",
   "on every push, from openspec/"),
  ("../coverage/", "Coverage map", "Every feature group of gt and Great Tables, what tabelline has, and the releases that plan the rest.",
   "when a status changes, from docs/coverage/gt.json"),
]
var docs = ""
for d in living:
  docs.add &"""<div class="nota azzurra"><span class="titolo"><a href="{d.href}">{d.title}</a></span>{d.what}<br><small>updated {d.updated}</small></div>"""
var items = ""
for p in posts:
  items.add &"""<div class="nota"><small>{p.date}</small><span class="titolo"><a href="{p.slug}/">{p.title}</a></span>{p.lede}</div>"""

nbRawHtml: &"""<p class="kicker">Devlog</p>
<h1>How tabelline is made</h1>
<p class="lede">Living documents that say how tabelline is today, then dated posts on the steps that led here.</p>
<h2>Living documents</h2>
<p>Kept up to date as tabelline changes.</p>
<div class="cards">{docs}</div>
<h2>Posts</h2>
<p>Each tells one step as it happened, and is not updated afterwards. Newest first.</p>
{items}"""
nbSave
