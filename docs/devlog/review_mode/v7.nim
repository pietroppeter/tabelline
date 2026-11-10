## Version 7 of the devlog post "Review mode" (docs/devlog/review_mode.nim has the post's first line).
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

# above the title: the day the post was written, and the day of this version when it is another
proc long(date: string): string = parse(date, "d MMM yyyy").format("d MMMM yyyy")
let written = storico[0].date
let updated = storico[questa - 1].date
nbTitolo long(written) & (if updated != written: " · updated " & long(updated) else: ""), title, """
Reviewing a page on a phone takes screenshots, notes, and many trips between the page and the
chat. A review mode for nimib pages: select text, comment on it, go through the comments with a
bar, and export them all in one text to paste in the chat, where an agent makes the changes. This
post is reviewed with its own review mode, round by round, and keeps every version.
"""

nbVersion questa

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
    nbNota list & "\nWhat the review asked for is in the table of [Versions and rounds](#versions-and-rounds).",
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
sheet opens at the top with a box for the note. Write *Replace with: ten trips, a minute each*.
There is nothing to save: the note is kept as it is typed. Tap **Export**, and the text reads

```text
## 1. In “The problem” (#the-problem)

> ten round trips

Around it: “…chat and back. Ten comments are ⟦ten round trips⟧. The idea A review mode kee…”

Replace with: ten trips, a minute each
```

A comment is three things: the words selected, the place they are in (the heading above them),
and a note. Everything else is there to make many of these quick to write, to find again, and
to hand over.

## Two modes

A page with the review mode is read in one of two modes, and the review mode has three places of
its own. The drawing has them all, and what takes you from one to the next.
"""

nbDisegno shots / "modi.svg", "The modes of a page: reading, and reviewing, with the sheet, the export and History"

nbText: """
- **Reading** is the page as it is, with one button beside the version: **✎ Review**. No bar, no
  marks.
- **Reviewing** adds the bar at the bottom, marks the words of every comment, and shows what is
  new in this version under the title. **Close review**, the same button, goes back to reading.
  The page remembers the mode it was left in.
- **The sheet** shows one comment, the one the arrows stopped on, at the top of the screen. It
  is open while you write and while you go from comment to comment; a tap on the page closes it.
- **Export** is the text of every comment, to edit and copy.
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
project: each says what was chosen and why, and stays until a review changes it. A decision
that a round changed says so at its end; the table of
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
8. **The bar is at the bottom, the sheet at the top.** The thumb reaches the bottom of a phone;
   the sheet to write in is at the top, where the keyboard does not cover it, and is kept small,
   so the words it is about stay in view under it. *Changed in rounds 2 and 6.*
9. **A screenshot is pasted in the note, like text**: no button to press. It is kept in the
   browser too, made smaller (900 pixels wide, JPEG), next to the comments; a tap shows it
   large. A browser keeps about 5 MB for a site, some twenty screenshots: when it is full, the
   bar says so, and exporting and clearing makes room. *Added in round 1, changed in rounds 3
   and 6.*
10. **Every version is kept as its notebook.** An old version is built again from its own source
    with today's blocks: its text is exactly as it was, its look and its review mode follow the
    site.

## The pieces of the screen

Two screens of this page on a phone, while reviewing, with a number on each piece: a comment
open in the sheet, and the export. The table under them says what each piece does, and what is
still open about it. Comment on a row of the table to change that piece.
"""

nbAccanto:
  nbSchermata shots / "sheet-v7.jpg", shots / "sheet-v7.json", "Reviewing: a comment open in the sheet at the top, its words under it, the bar at the bottom"
  nbSchermata shots / "export-v7.jpg", shots / "export-v7.json", "The export: the text, to edit and copy, and each screenshot"

block:
  type Pezzo = object
    n: int
    piece, does, open: string
  let rows = @[
    Pezzo(n: 1, piece: "✎ Review",
          does: "Beside the version, under the title: opens the review mode, and closes it (*Close review*).",
          open: "Also in the bar, to close the review from the bottom of a long page?"),
    Pezzo(n: 2, piece: "Marks",
          does: "The words of each comment, in the soft colour of notes; the open one, darker. A tap on them opens the comment. A note on the whole page has no mark: its sheet says *On the whole page*.",
          open: ""),
    Pezzo(n: 3, piece: "‹ › and the count",
          does: "Previous and next comment, in the order of the page (notes on the whole page first), each opened in the sheet; *2/5* says which.",
          open: ""),
    Pezzo(n: 4, piece: "Delete", does: "Deletes the comment open in the sheet.", open: ""),
    Pezzo(n: 5, piece: "Comment ✓ or Page note",
          does: "A new comment: *Comment ✓* on the words selected, *Page note* on the whole page when nothing is selected.", open: ""),
    Pezzo(n: 6, piece: "Export", does: "Opens the export.", open: ""),
    Pezzo(n: 7, piece: "The sheet",
          does: "The comment open, at the top: a box for the note, kept as it is typed. Before anything is typed, the box says how to ask for new words (*Replace with:*) or for none (*Remove*). A tap on the page closes it; left empty, the comment is dropped.",
          open: "Is a tap on the page the right way to close it?"),
    Pezzo(n: 8, piece: "Screenshots",
          does: "Pasted in the note, like text, they show small under it, with × to remove one; a tap shows one large.",
          open: ""),
    Pezzo(n: 9, piece: "The export text",
          does: "Every comment as Markdown, after a block of YAML, to edit before it goes.", open: ""),
    Pezzo(n: 10, piece: "Screenshots to copy",
          does: "Each screenshot, named as the text names it, with a *Copy image* of its own, to paste after the text.", open: ""),
    Pezzo(n: 11, piece: "History",
          does: "The versions of the page, each with the comments kept on it: open one, clear its comments, or clear everything (a second tap confirms). **Export** goes back.",
          open: ""),
    Pezzo(n: 12, piece: "Copy", does: "Copies the text only.", open: "")]
  let t = tabella(rows, rownameCol = "n"):
    colsLabel {"piece": "Piece", "does": "What it does", "open": "Still open"}
    fmtMarkdown ["piece", "does", "open"]
    optCssTheme()
  nbTable t

nbText: """
## The bar and the sheet

While reviewing, a bar stays at the bottom of the screen:

- **‹** and **›** go to the previous and next comment, in the order of the page, scroll to it,
  and open it in the sheet; the count between them says which one it is (*2/5*);
- **Delete** deletes the comment that is open;
- **Comment ✓** writes a new comment on the selected words; with nothing selected, the same
  button is **Page note**, a note on the whole page;
- **Export** shows the text of all the comments, to edit and copy.

The sheet at the top holds the comment that is open, and nothing else: no buttons. The bar keeps
working while it is open, so **›** takes the sheet to the next comment. Every button is at least
44 pixels high, the size a finger hits. On a phone, tapping a button can clear the selection
before the button sees it, so the page keeps the selection as soon as it is made.

## The export

The export is for two readers, the reviewer who checks it before pasting it, and the agent that
applies it. JSON would be easy for the second and tiring for the first. Markdown is easy for
both, and a chat shows it well: a title, a block of YAML that holds what a program needs (which
page, which source file, which version, how many comments), and each comment a short section
with its place, the heading it is under, the words as a quote, and the note.

````text
# Review of “Review mode”, version 7

```yaml
format: nimib-review/3
title: "Review mode"
page: "https://pietroppeter.github.io/tabelline/devlog/review-mode/"
source: "docs/devlog/review_mode/v7.nim"
version: 7
exported: "2026-11-10T05:40:00.000Z"
comments: 2
```

## 1. On the whole page

Shorter: half the sections could be one paragraph.

## 2. In “The bar and the sheet” (#the-bar-and-the-sheet)

> Every button is at least 44 pixels high, the size a finger hits.

Around it: “… the sheet to the next comment. ⟦Every button is at least 44 pixels high, the size a finger hits.⟧ On a phone, tapping a button ca…”

Remove

Screenshots: review-v7-2-1.jpg
````

The quote is the text as the page shows it, so the agent searches the source for it (without
the Markdown marks) and uses the words around it when it appears more than once. A comment with
screenshots adds a line that names them (`Screenshots: review-v7-2-1.jpg`). **Copy** copies the
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
(`nimib-review:devlog/review-mode@v7` for this one). Reload the page, close the browser, come
back tomorrow: they are still there, marked on the text. Nothing leaves the phone until the
export. To start from nothing, open **History** from the export: it clears the comments of one
version, or every comment of the review mode in this browser.

## Processing an export: a skill

An export pasted in the chat should be enough: no instructions around it. A skill teaches the
agent what to do with one. The five steps below are a summary; the whole skill is
[`.claude/skills/nimib-review/SKILL.md`](https://github.com/pietroppeter/tabelline/blob/main/.claude/skills/nimib-review/SKILL.md),
in this repository for now (it can move to Pietro's skills once it works).

1. read the YAML block, and check that the number of comments matches the sections: a long paste
   can arrive cut short, and the count is how the agent notices;
2. find each quote in the source, knowing that it is rendered text (no Markdown marks, and the
   text of a table is made by code, not written in the notebook);
3. keep the version that was reviewed, and make the changes in a new one;
4. save the export with the page's data, and add the round to the page's record;
5. rebuild, check on a phone, and answer with one line per comment: done, or the question it
   raises.

## Versions and rounds

This post changes in rounds: a review of version 1 makes version 2, and so on. Because it is
about the review mode, it keeps a table of its versions and of what each round found; another
page with the review mode has **History**, in the export, instead. Each version is a notebook of
its own, `review_mode/v1.nim`, `review_mode/v2.nim`: a new round copies the newest to the next
number and changes the copy, so every version that was read is kept as it was, and a comment of
a round can be checked against the text it was written on.
"""

block:
  type Riga = object
    day, version, date, what, review: string
    comments: int
  # when: the versions are grouped by day; the first of a day gives its time, the others how long
  # after the one before (hours and minutes)
  proc moment(v: Versione): DateTime = parse(v.date & " " & v.time, "d MMM yyyy HH:mm")
  proc published(i: int): string =
    let v = storico[i]
    if i == 0 or storico[i - 1].date != v.date: return v.time
    let minutes = (moment(v) - moment(storico[i - 1])).inMinutes
    if minutes < 60: &"+{minutes} min" else: &"+{minutes div 60} h {minutes mod 60:02} min"
  var rows: seq[Riga]
  for i in 0 ..< questa:
    let v = storico[i]
    let href = versionHref(i + 1, questa, storico.len)
    let name = if href.len > 0: &"[v{i + 1}]({href})" else: &"v{i + 1}"
    rows.add Riga(day: v.date, version: name, date: published(i), what: v.what, review: v.review, comments: v.comments)
  let t = tabella(rows, rownameCol = "version", groupnameCol = "day"):
    colsLabel {"date": "Published (Italian time)", "what": "What it changed", "review": "What its review found", "comments": "Comments"}
    fmtMarkdown ["version", "what", "review"]
    optCssTheme()
  nbTable t

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
    Pezzo(file: "`docs/blocchi.nim`",
          holds: "The blocks: `nbRevisione` turns the review mode on, `nbVersione` writes the version and makes room for **✎ Review**, `nbInRevisione` holds blocks shown only while reviewing. Beside them, the other blocks of tabelline's pages."),
    Pezzo(file: "`docs/assets/revisione.js`", holds: "The script, in nine parts (below)."),
    Pezzo(file: "`docs/stile.nim`", holds: "`revisioneCss`, the styles, from the page's colours, added only to pages with the review mode."),
    Pezzo(file: "`.claude/skills/nimib-review/SKILL.md`", holds: "The skill that turns an export into changes."),
    Pezzo(file: "`docs/devlog/review_mode/`", holds: "This post: a notebook per version, and `storia.nim`, the versions and rounds.")]
  let t = tabella(rows):
    colsLabel {"file": "File", "holds": "What it holds"}
    fmtMarkdown ["file", "holds"]
    optCssTheme()
  nbTable t

nbText: """
It is not a module of its own yet: the blocks are among the blocks of tabelline's pages, where
the review mode is being tried. Once it works, it can move to nimib, as a module any notebook
imports.

### A page with the review mode

A plain nimib page:

```nim
import nimib

nbInit
nbText: "# Notes\n\nSome text to review."
nbSave
```

The same page with the review mode, as tabelline's pages write it (`useTabelline` gives them
their look; the review mode needs only the blocks):

```nim
import nimib except md
import tabelline/nimib
import blocchi

nbInit
nb.useTabelline(nome = "tabelline", title = "Notes")
nbRevisione("notes", 1, "Notes", "docs/notes.nim")
nbTitolo "10 November 2026", "Notes"
nbVersione 1
nbText: "Some text to review."
nbSave
```

`nbRevisione` turns the review mode on: its page and version (`"notes"`, `1`) say where its comments are
kept, the title and the source (`"Notes"`, `"docs/notes.nim"`) go in the export. `nbVersione` writes *Version 1* and gives **✎ Review** its place; a
page without it gets the button under its title. Blocks inside `nbInRevisione:` show only while
reviewing, as *New in version 7* does on this page.

The script is inlined, so the page stays one file that works anywhere, even as a claude.ai
artifact. When every page of a site has the review mode, they can share one copy:
`nbRevisione("notes", 1, "Notes", "docs/notes.nim", tscript = "../assets/revisione.js")` writes
a link to the script instead, and the browser loads it once for all of them. The blocks, in
full:
"""

nbFoldCode "docs/review.nim", start = "func versionHref*", stop = "newNbBlock(NbVersions):"

nbText: """
### The script

`docs/assets/revisione.js` is plain JavaScript with no dependencies, in nine parts. It could be
written in Nim and compiled to JavaScript; for now plain JavaScript is shorter, both to read and
to load. What each part does, and its code, folded:
"""

const parts = [("anchor", "Where a comment points", "Finds the words selected in the text of the page, with the words around them and the heading above, and finds them again later."),
               ("mark", "Marking the text", "Wraps the words of each comment in a mark, and puts the comments in the order of the page."),
               ("store", "Keeping the comments", "Keeps the comments, and the mode, in the browser's localStorage, one key per page and version."),
               ("mode", "Reading and reviewing", "Adds **✎ Review** beside the version, and opens and closes the review mode."),
               ("bar", "The bar", "The bar at the bottom: the arrows, Delete, a new comment, Export; it keeps a selection as soon as it is made."),
               ("sheet", "The sheet", "Opens the comment the arrows stop on, keeps the note as it is typed, takes pasted screenshots, drops an empty comment."),
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

for i, (key, name, does) in parts:
  nbFoldCode "docs/assets/review.js", start = "// part: " & key,
             stop = (if i < parts.high: "// part: " else: "})();"), title = name

nbSave
