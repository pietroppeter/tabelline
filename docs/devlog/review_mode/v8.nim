## Version 8 of the devlog post "Review mode" (docs/devlog/review_mode.nim has the post's first line).
## A version knows its number from its file name, vN.nim. The newest version is the post, built into
## devlog/review-mode/; an older one is kept as it was and built into devlog/review-mode/vN/.
import std/[os, strutils, strformat, times]
import nimib except md
import tabelline, tabelline/nimib
import ../../[blocchi, review]
import storia

const
  questa = parseInt(currentSourcePath().splitFile.name[1 .. ^1])   # v1.nim is version 1
  newest = questa == storico.len
  title = "Review mode"
let docs = currentSourcePath().parentDir.parentDir.parentDir
let source = currentSourcePath().relativePath(docs.parentDir)
let shots = docs / "devlog" / "data" / "review-mode"
nbInit
nb.doc.filename = docs / "devlog" / "review-mode" / (if newest: "" else: &"v{questa}") / "index.html"
nb.useTabelline(nome = "tabelline", title = title,
                homeHref = (if newest: "../" else: "../../"), backLabel = "Devlog",
                nameHref = (if newest: "../../" else: "../../../"))
var dates: seq[string]
for v in storico: dates.add v.date
nbReview(questa, "devlog/review-mode", title, source, dates)

# above the title, the day the post was written; beside the version, the day of its last update
proc long(date: string): string = parse(date, "d MMM yyyy").format("d MMMM yyyy")
let written = storico[0].date
let updated = storico[questa - 1].date
nbTitolo long(written), title, """
Reviewing a page on a phone takes screenshots, notes, and many trips between the page and the
chat. A review mode for nimib pages: select text, comment on it, go through the comments with a
bar, and export them all in one text to paste in the chat, where an agent makes the changes. This
post is reviewed with its own review mode, round by round, and keeps every version.
"""

nbVersion questa, (if updated != written: updated else: "")

if not newest:
  nbNota &"This is version {questa}, kept as it was when it was reviewed. The newest is " &
    &"[version {storico.len}](../).", nkWarning

nbInReview:
  block:   # what changed, one numbered line per change (`what` lists them separated by "; ")
    var what = storico[questa - 1].what
    if what.startsWith("Round") and ": " in what: what = what[what.find(": ") + 2 .. ^1]
    var list = ""
    let changes = what.strip(chars = {'.', ' '}).split("; ")
    for i, change in changes:
      list.add &"{i + 1}. {change}\n"
    nbNota list & "\nWhat the review asked for is in [Versions and rounds](#versions-and-rounds).",
      nkDone, &"New in version {questa}"
  nbNota """
Select a few words and tap **Comment ✓** in the bar at the bottom, then write what should change
(paste a screenshot in it if it helps): it is kept as you type. With nothing selected, the same
button is **Page note**, a note on the whole page. **‹** and **›** open your comments one by one;
**Export** gives the text to copy into the chat. **Close review**, above, goes back to reading.
""", nkInfo, "You are reviewing this page"

nbIndice

nbText: """
## The problem

More and more pages are written by coding agents: a notebook, a report, the docs of a library.
Someone has to read them and say what to change. Pietro has Claude Code write his pages, and he
reviews them mostly from his phone. Today a comment goes like this:
take a screenshot of the page, paste it in the chat, write what to change, then go back to the
page, which in a claude.ai artifact takes a few seconds to load again. A page merged and served
by GitHub Pages opens faster, but every comment is still a trip from the page to the chat and
back. Ten comments are ten round trips.

## The idea

A review mode keeps the whole review on the page and makes one trip at the end. Open it with a
button, select some words, comment on them, paste a screenshot where words are not enough, and
go on reading; when the reading is done, export everything at once. The agent gets one text that
says which page, which version, and what to change where, in the order of the page, and then the
screenshots. Closed, the review mode leaves the page as it was.

## The simplest review: one comment

Tap **✎ Review**, beside the version under the title: a bar appears at the bottom of the screen.
Select *ten round trips* in the first section and tap **Comment ✓**: the words are marked, and a
comment box opens at the top. Write *Replace with: ten trips, a minute each*. There is nothing to
save: the note is kept as it is typed. Tap **Export**, and the text reads

```text
## 1. In “The problem” (#the-problem)

> ten round trips

Around it: “…chat and back. Ten comments are ⟦ten round trips⟧. The idea A review mode kee…”

Replace with: ten trips, a minute each
```

A comment is three things: the words selected, the place they are in (the heading above them),
and a note. Everything else is there to make many of these quick to write, to find again, and
to hand over. When the review is done, **Close review** goes back to reading: the same button
that opened it, or the one in the export, so a long page need not be scrolled back to its top.

## The pieces of the screen

Four screens of this page on a phone, one card each: reading, reviewing with a comment open, the
export, and History. Each card numbers its pieces from 1 and says what they do, and what is
still open about them.
"""

nbGalleria "The screens of the review mode":
  nbScheda "Reading":
    nbSchermata shots / "reading-v8.jpg", shots / "reading-v8.json", "The page as it is, with one button"
    nbText """
1. **✎ Review**, under the lede, beside the version and the day of its last update: opens the
   review mode.
"""
  nbScheda "Reviewing":
    nbSchermata shots / "reviewing-v8.jpg", shots / "reviewing-v8.json", "A comment open in the comment box, its words under it"
    nbText """
1. **Close review**: the same button, closes the review mode.
2. **Marks**: the words of each comment, in the soft colour of notes; the open one, darker. A tap
   opens it. A note on the whole page has no mark: its box says *On the whole page*.
3. **‹ ›** and the count: the previous and next comment, in the order of the page (notes on the
   whole page first), each opened in the comment box; *2/5* says which.
4. **Delete** deletes the comment that is open.
5. **Comment ✓** on the words selected; **Page note** on the whole page, when nothing is selected.
6. **Export** opens the export.
7. **The comment box**: the comment that is open, kept as it is typed. Empty, it says how to ask
   for new words (*Replace with:*) or none (*Remove*). A tap on the page closes it; left empty,
   the comment is dropped. *Still open: is a tap on the page the best way to close it?*
8. **Screenshots**, pasted in the note: small under it, × removes one, a tap shows it large.
"""
  nbScheda "Export":
    nbSchermata shots / "export-v8.jpg", shots / "export-v8.json", "The text of every comment, and each screenshot"
    nbText """
1. **The text** of every comment, Markdown after a block of YAML, to edit before it goes.
2. **Each screenshot**, named as the text names it, with **Copy image**, to paste after the text.
3. **History** opens the versions of the page.
4. **Close review** ends the review, back to reading.
5. **Copy** copies the text only.
"""
  nbScheda "History":
    nbSchermata shots / "history-v8.jpg", shots / "history-v8.json", "The versions of the page, and the comments kept on each"
    nbText """
1. **A version**, newest first, with the comments this browser keeps on it; a tap opens it.
2. **Clear** deletes the comments of that version (a second tap confirms).
3. **Clear everything** deletes every comment of the review mode in this browser.
4. **Export** goes back to the export.
"""

nbText: """
## The modes, and how to move between them

A page with the review mode is read in one of two modes, and the review mode has three places of
its own: the comment box, the export and History. The drawing has them all, and the buttons that
take you from one to the next.
"""

nbDisegno shots / "modi-v8.svg", "Reading and reviewing, with the comment box, the export and History, and the buttons between them"

nbText: """
- **Reading** is the page as it is, with one button beside the version: **✎ Review**. No bar, no
  marks.
- **Reviewing** adds the bar at the bottom, marks the words of every comment, and shows what is
  new in this version under the title. **Close review**, the same button, goes back to reading.
  The page remembers the mode it was left in.
- **The comment box** shows one comment, the one the arrows stopped on, at the top of the screen.
  It is open while you write and while you go from comment to comment; a tap on the page closes
  it.
- **Export** is the text of every comment, to edit and copy; **Close review** is there too.
- **History** is the versions of the page, with the comments this browser keeps on each.

## What it lets you do

The review mode is for two readers: the reviewer on the page, and the agent that gets the export.
Each row is something one of them wants to do, why, and how the review mode does it.
"""

block:
  type Storia = object
    who, want, why, how: string
  let rows = @[
    Storia(who: "The reviewer", want: "read the page with nothing in the way",
           why: "reviewing is a choice, not the default", how: "the page opens in reading mode; **✎ Review** opens the review"),
    Storia(who: "The reviewer", want: "comment on a few words", why: "the agent knows where",
           how: "select them, **Comment ✓**"),
    Storia(who: "The reviewer", want: "say something about the whole page", why: "not every note is about some words",
           how: "**Page note**, with nothing selected"),
    Storia(who: "The reviewer", want: "ask for new words, or for none", why: "the agent changes exactly those words",
           how: "*Replace with:* and the new text, or *Remove*, in the note"),
    Storia(who: "The reviewer", want: "show what words can't", why: "a layout or a colour is clear at a glance",
           how: "paste a screenshot in the note"),
    Storia(who: "The reviewer", want: "look at a screenshot closely", why: "check it before it goes",
           how: "a tap on it shows it large"),
    Storia(who: "The reviewer", want: "go through my comments again", why: "read them over, change one",
           how: "**‹** and **›**, or a tap on marked words"),
    Storia(who: "The reviewer", want: "drop a comment", why: "I changed my mind", how: "**Delete**, or empty the note"),
    Storia(who: "The reviewer", want: "stop, and go on tomorrow", why: "a review takes time",
           how: "the comments stay in the browser"),
    Storia(who: "The reviewer", want: "send the whole review at once", why: "one trip to the chat",
           how: "**Export**, **Copy**, then each screenshot"),
    Storia(who: "The reviewer", want: "start again from nothing", why: "a version reviewed is done",
           how: "**History**: clear one version, or everything"),
    Storia(who: "The agent", want: "know which file and version to change", why: "the page's address is not its source",
           how: "the YAML block: `source` and `version`"),
    Storia(who: "The agent", want: "find each comment's words in the source", why: "the same words may be in many places",
           how: "the quote, and the words around it"),
    Storia(who: "The agent", want: "know that nothing was lost in the paste", why: "a long paste can be cut short",
           how: "the YAML block says how many comments there are")]
  let t = tabella(rows, groupnameCol = "who"):
    colsLabel {"want": "I want to", "why": "so that", "how": "How"}
    fmtMarkdown ["how"]
    optCssTheme()
  nbTable t

nbText: """
## The decisions behind it

The review mode rests on the ten decisions below. They are like the decision records of a
project: each says what was chosen and why, and stays until a review changes it.
[Versions and rounds](#versions-and-rounds) has what each round asked.

1. **Reading first.** The review mode opens with a button and closes with the same one; closed,
   it leaves nothing on the page but that button. *Added in round 6.*
2. **One reviewer, one browser.** The comments are kept in the browser's `localStorage`, and
   nothing is sent anywhere. Another phone, or clearing the site's data, starts with no comments:
   the export is the way out.
3. **Comments belong to a version.** Version 2 of a page starts with no comments; the ones on
   version 1 stay with version 1.
4. **A comment points at text**, the words selected and a few around them, not at a place in
   the HTML. When the words are no longer on the page, the comment is kept and the export says so.
5. **One kind of comment.** A comment is a note on the words selected, or on the whole page
   when nothing is selected (*Page note*). To ask for new words, the note says *Replace with:*
   and the new text; to drop them, *Remove*. *Changed in rounds 3, 4 and 6.*
6. **Nothing to save.** What is typed is kept as it is typed, and a comment left empty is
   dropped. The comment the arrows stop on is the one open: there is no Edit, Save or Cancel.
   *Added in round 6.*
7. **The export goes through the clipboard.** The text can be edited before it goes. **Copy**
   copies the text only: a chat message has a limit, and screenshots written into the text go
   past it. Each screenshot has a **Copy image** of its own, to paste in the chat after the text;
   or attach them from the phone's photos. Where the clipboard is blocked (inside an artifact it
   can be), select the text in its box and copy by hand. There is no Share: on a phone, sharing
   to Claude opens a new session, outside the project the page belongs to. *Changed in rounds 1,
   2, 3 and 6.*
8. **The bar is at the bottom, the comment box at the top.** The thumb reaches the bottom of a
   phone; the box to write in is at the top, where the keyboard does not cover it, and is kept small,
   so the words it is about stay in view under it. *Changed in rounds 2 and 6.*
9. **A screenshot is pasted in the note, like text**: no button to press. It is kept in the
   browser too, made smaller (900 pixels wide, JPEG), next to the comments; a tap shows it
   large. A browser keeps about 5 MB for a site, some twenty screenshots: when it is full, the
   bar says so, and exporting and clearing makes room. *Added in round 1, changed in rounds 3
   and 6.*
10. **Every version is kept as its notebook.** An old version is built again from its own source
    with today's blocks: its text is exactly as it was, its look and its review mode follow the
    site.
"""

nbText: """
## The bar and the comment box

While reviewing, a bar stays at the bottom of the screen:

- **‹** and **›** go to the previous and next comment, in the order of the page, scroll to it,
  and open it in the comment box; the count between them says which one it is (*2/5*);
- **Delete** deletes the comment that is open;
- **Comment ✓** writes a new comment on the selected words; with nothing selected, the same
  button is **Page note**, a note on the whole page;
- **Export** shows the text of all the comments, to edit and copy.

The comment box at the top holds the comment that is open, and nothing else: no buttons. The bar
keeps working while it is open, so **›** takes the box to the next comment. Every button is at least
44 pixels high, the size a finger hits. On a phone, tapping a button can clear the selection
before the button sees it, so the page keeps the selection as soon as it is made.

## The export

The export is for two readers, the reviewer who checks it before pasting it, and the agent that
applies it. JSON would be easy for the second and tiring for the first. Markdown is easy for
both, and a chat shows it well: a title, a block of YAML that holds what a program needs (which
page, which source file, which version, how many comments), and each comment a short section
with its place, the heading it is under, the words as a quote, and the note.

````text
# Review of “Review mode”, version 8

```yaml
format: nimib-review/3
title: "Review mode"
page: "https://pietroppeter.github.io/tabelline/devlog/review-mode/"
source: "docs/devlog/review_mode/v8.nim"
version: 8
exported: "2026-11-10T06:40:00.000Z"
comments: 2
```

## 1. On the whole page

Shorter: half the sections could be one paragraph.

## 2. In “The bar and the comment box” (#the-bar-and-the-comment-box)

> Every button is at least 44 pixels high, the size a finger hits.

Around it: “…s the box to the next comment. ⟦Every button is at least 44 pixels high, the size a finger hits.⟧ On a phone, tapping a button ca…”

Remove

Screenshots: review-v8-2-1.jpg
````

The quote is the text as the page shows it, so the agent searches the source for it (without
the Markdown marks) and uses the words around it when it appears more than once. A comment with
screenshots adds a line that names them (`Screenshots: review-v8-2-1.jpg`). **Copy** copies the
text alone, and each screenshot is copied by its own button, under the text.

## Where a comment points

A page is rebuilt from its source every time it changes, so a path in the HTML (the third
paragraph of the second section) breaks as soon as a paragraph is added above it. What stays is
the text. A comment keeps the words selected, the 32 characters before and after them, and the
heading they are under: the same idea as the *text quote selector* of the
[W3C Web Annotation model](https://www.w3.org/TR/annotation-model/#text-quote-selector).

To find a comment again, the page looks for every place the words appear, and keeps the one whose
surroundings match best: *the* is everywhere, *the* followed by *page* and preceded by *opens*
is in one place.

## Keeping the comments

The comments of a page are kept in the browser, under one key per page and version
(`nimib-review:devlog/review-mode@v8` for this one). Reload the page, close the browser, come
back tomorrow: they are still there, marked on the text. Nothing leaves the phone until the
export. To start from nothing, open **History** from the export: it clears the comments of one
version, or every comment of the review mode in this browser.

## Processing an export: a skill

An export pasted in the chat should be enough: no instructions around it. A skill teaches the
agent what to do with one. The five steps below are a summary; the whole skill is
[`.claude/skills/nimib-review/SKILL.md`](https://github.com/pietroppeter/tabelline/blob/main/.claude/skills/nimib-review/SKILL.md),
in this repository for now (it can move elsewhere once it works).

1. read the YAML block, and check that the number of comments matches the sections: a long paste
   can arrive cut short, and the count is how the agent notices;
2. find each quote in the source, knowing that it is rendered text (no Markdown marks, and the
   text of a table is made by code, not written in the notebook);
3. make the changes: in the page's source, or, on a page that keeps its versions as this post
   does, in a copy that becomes the next version;
4. rebuild and check the page on a phone;
5. answer by theme, not in the order of the comments: each theme says what was asked and what
   changed, or the question it raises; comments that only say something works go in a section
   of their own.

Saving each round's export with the page, and adding the round to a record, is something this
post does (below), not a step of the skill.

## Versions and rounds

This post changes in rounds: a review of version 1 makes version 2, and so on. Because it is
about the review mode, it keeps every version, and a card for each: what it changed, and what
its review found. Another page with the review mode doesn't need to: **History**, in the export,
lists the versions whose comments the browser keeps. Each version of this post is a notebook of
its own, `review_mode/v1.nim`, `review_mode/v2.nim`: a new round copies the newest to the next
number and changes the copy, so every version that was read is kept as it was, and a comment of
a round can be checked against the text it was written on. Each round's export is saved beside
the post's data, `round-1.md`, `round-2.md`, and linked from its card.
"""

nbCards "The versions of this post":
  for i in 0 ..< questa:
    let v = storico[i]
    var what = v.what
    if what.startsWith("Round") and ": " in what: what = what[what.find(": ") + 2 .. ^1]
    var body = "**What it changed:** " & what
    body.add "\n\n**What its review found:** " & v.review
    if v.comments > 0: body.add &" ({v.comments} comments)"
    nbCard(&"Version {i + 1}", versionHref(i + 1, questa, storico.len), &"{v.date} · {v.time}"):
      nbText body

nbText: """
## How it is built

**The review mode exists because the page is a nimib notebook.** A nimib notebook is a Nim
program that writes its page from blocks: text, code, tables, and any block a project adds of
its own. So the review mode is a block: one line in the notebook puts a script, its settings and
its styles in the page. And a notebook knows its own source file, which is how an export can
tell the agent which file to change. Another framework could do the same; this one is done with
nimib. Three parts: where it lives, how a page turns it on, and the script.

### Where it lives
"""

block:
  type Pezzo = object
    file, holds: string
  let rows = @[
    Pezzo(file: "`docs/review.nim`",
          holds: "A module of its own, with English names, that can move to nimib: the blocks (`nbReview` turns the review mode on, `nbVersion` writes the version and makes room for **✎ Review**, `nbInReview` holds blocks shown only while reviewing) and their styles, `reviewCss`, from the page's colours or plain ones."),
    Pezzo(file: "`docs/assets/review.js`", holds: "The script, in nine parts (below)."),
    Pezzo(file: "`.claude/skills/nimib-review/SKILL.md`", holds: "The skill that turns an export into changes."),
    Pezzo(file: "`docs/devlog/review_mode/`", holds: "This post: a notebook per version, and `storia.nim`, the versions and rounds.")]
  let t = tabella(rows):
    colsLabel {"file": "File", "holds": "What it holds"}
    fmtMarkdown ["file", "holds"]
    optCssTheme()
  nbTable t

nbText: """
### A page with the review mode

A plain nimib page:

```nim
import nimib

nbInit
nbText: "# Notes\n\nSome text to review."
nbSave
```

The same page with the review mode is one import and one line:

```nim
import nimib
import review

nbInit
nbReview()
nbText: "# Notes\n\nSome text to review."
nbSave
```

`nbReview()` finds what it needs by itself. The source is the notebook's own file, from the
root of its repository (`docs/notes.nim`); it goes in the export, so the agent knows which file
to change. The page, which names the key the comments are kept under, is the source too. The
title, also in the export, is the page's title. The version is 1. **✎ Review** goes under the
title.

Each can be given. This post gives them all:
`nbReview(questa, "devlog/review-mode", title, source, dates)`: its version, a page that stays
the same when the post moves, its title and source, and the day of each version, for
**History**. `nbVersion 8, "10 Nov 2026"` writes *Version 8 · updated 10 Nov 2026* and gives
**✎ Review** its place beside it. Blocks inside `nbInReview:` show only while reviewing, as
*New in version 8* does on this page.

The script is inlined, so the page stays one file that works anywhere, even as a claude.ai
artifact. When every page of a site has the review mode, they can share one copy:
`nbReview(tscript = "../assets/review.js")` writes a link to the script instead, and the browser
loads it once for all of them. The blocks, in full:
"""

let blocchiSrc = readFile(docs / "review.nim")
let blockCode = blocchiSrc[blocchiSrc.find("func versionHref*") ..< blocchiSrc.find("newNbBlock(NbVersions):")]
nbPiega "review.nim: the blocks", blockCode

nbText: """
### The script

`docs/assets/review.js` is plain JavaScript with no dependencies, in nine parts. It could be
written in Nim and compiled to JavaScript; for now plain JavaScript is shorter, both to read and
to load. What each part does, and its code, folded:
"""

const parts = [("anchor", "Where a comment points", "Finds the words selected in the text of the page, with the words around them and the heading above, and finds them again later."),
               ("mark", "Marking the text", "Wraps the words of each comment in a mark, and puts the comments in the order of the page."),
               ("store", "Keeping the comments", "Keeps the comments, and the mode, in the browser's localStorage, one key per page and version."),
               ("mode", "Reading and reviewing", "Adds **✎ Review** beside the version, and opens and closes the review mode."),
               ("bar", "The bar", "The bar at the bottom: the arrows, Delete, a new comment, Export; it keeps a selection as soon as it is made."),
               ("sheet", "The comment box", "Opens the comment the arrows stop on, keeps the note as it is typed, takes pasted screenshots, drops an empty comment."),
               ("zoom", "A screenshot, large", "Shows a screenshot as large as the screen allows."),
               ("export", "The export", "Writes the text of every comment, and lets the reviewer copy it and each screenshot."),
               ("history", "History", "Lists the versions with the comments kept on each, and clears them.")]
let script = readFile(docs / "assets" / "review.js")
let chunks = script.split("  // part: ")[1 .. ^1]
block:
  type Parte = object
    part, does: string
    lines: int
  var rows: seq[Parte]
  for chunk in chunks:
    let key = chunk.splitLines[0].strip
    for (k, name, does) in parts:
      if k == key: rows.add Parte(part: name, does: does, lines: chunk.strip.countLines)
  let t = tabella(rows):
    colsLabel {"part": "Part", "does": "What it does", "lines": "Lines"}
    fmtMarkdown ["does"]
    optCssTheme()
  nbTable t

for chunk in chunks:
  let lines = chunk.splitLines
  var heading = lines[0].strip
  for (key, name, does) in parts:
    if key == heading: heading = name
  nbPiega heading, lines[1 .. ^1].join("\n").strip(leading = false).unindent(2), "js"

nbSave
