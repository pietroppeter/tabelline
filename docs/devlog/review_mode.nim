## devlog: 09 Nov 2026 A | Review mode | Reviewing a page on a phone takes screenshots, notes and many trips between the page and the chat. A review mode for nimib pages: select text, comment, go through the comments with a bar, export them in one text to paste in the chat. The post is reviewed with itself, round by round.
## The post is reviewed with its own review mode. Its version comes from git (review.nim): each commit
## of this file is one. review_mode/storia.nim records the rounds, and the notebooks of versions
## 1 to 8, one file each until the API was settled, are in git at commit 64f87e2.
import std/[os, strutils, strformat, times]
import nimib
import tabelline, tabelline/nimib
import ../[blocks, review]
import review_mode/storia

const title = "Review mode"
let docs = currentSourcePath().parentDir.parentDir
let shots = docs / "devlog" / "data" / "review-mode"
nbInit
nb.doc.filename = docs / "devlog" / "review-mode" / "index.html"
nb.useTabelline(title = title, homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../",
                reviewPage = "devlog/review-mode")   # the key its comments were kept under before git

# above the title, the day the post was written; beside the version, the day of its last update
proc long(date: string): string = parse(date, "d MMM yyyy").format("d MMMM yyyy")
let written = storico[0].date
nbTitle long(written), title, """
Reviewing a page on a phone takes screenshots, notes, and many trips between the page and the
chat. A review mode for nimib pages: select text, comment on it, go through the comments with a
bar, and export them all in one text to paste in the chat, where an agent makes the changes. This
post is reviewed with its own review mode, round by round.
"""

nbInReview:
  block:   # what changed, one numbered line per change (`what` lists them separated by "; ")
    var what = storico[^1].what
    if what.startsWith("Round") and ": " in what: what = what[what.find(": ") + 2 .. ^1]
    var list = ""
    let changes = what.strip(chars = {'.', ' '}).split("; ")
    for i, change in changes:
      list.add &"{i + 1}. {change}\n"
    nbNote list & "\nWhat the review asked for is in [Versions and rounds](#versions-and-rounds).",
      nkDone, "New in this version"
  nbNote """
Select a few words and tap **Comment ✓** in the bar at the bottom, then write what should change
(paste a screenshot in it if it helps): it is kept as you type. With nothing selected, the same
button is **Page note**, a note on the whole page. **‹** and **›** open your comments one by one;
**Export** gives the text to copy into the chat. **Close review**, above, goes back to reading.
""", nkInfo, "You are reviewing this page"

nbToc

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

Tap **✎ Review**, beside the version under the lede: a bar appears at the bottom of the screen.
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

nbGallery "The screens of the review mode":
  nbGalleryCard "Reading":
    nbScreenshot shots / "reading-v9.jpg", shots / "reading-v9.json", "The page as it is, with one button"
    nbText """
1. **✎ Review**, under the lede, beside the version and the day of its last update: opens the
   review mode. Every page of this site has it.
"""
  nbGalleryCard "Reviewing":
    nbScreenshot shots / "reviewing-v9.jpg", shots / "reviewing-v9.json", "A comment open in the comment box, its words under it"
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
  nbGalleryCard "Export":
    nbScreenshot shots / "export-v9.jpg", shots / "export-v9.json", "The text of every comment, and each screenshot"
    nbText """
1. **The text** of every comment, Markdown after a block of YAML, to edit before it goes.
2. **Each screenshot**, named as the text names it, with **Copy image**, to paste after the text.
3. **History** opens the versions of the page.
4. **Close review** ends the review, back to reading.
5. **Copy** copies the text only.
"""
  nbGalleryCard "History":
    nbScreenshot shots / "history-v9.jpg", shots / "history-v9.json", "The versions of the page, and the comments kept on each"
    nbText """
1. **A version** with comments in this browser, this one first, then the others, newest first.
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

nbDrawing shots / "modi-v8.svg", "Reading and reviewing, with the comment box, the export and History, and the buttons between them"

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
   version 1 stay with version 1. A version is a commit that changed the page's source: git
   counts them, so a page needs no number of its own. *Changed in version 9.*
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
10. **Git keeps the versions.** A page is one notebook, and its old versions are its commits:
    the export names the commit it was made on, so the agent sees what changed since with `git
    diff`. Versions 1 to 8 of this post were a notebook each, built as pages of their own; that
    was part of the experiment, and ended when the review mode went on every page. *Changed in
    version 9.*
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
page, which source file, which version and commit, how many comments), and each comment a short section
with its place, the heading it is under, the words as a quote, and the note.

````text
# Review of “Review mode”, version 9

```yaml
format: nimib-review/4
title: "Review mode"
page: "https://pietroppeter.github.io/tabelline/devlog/review-mode/"
source: "docs/devlog/review_mode.nim"
version: "9"
commit: "1a2b3c4"
exported: "2026-11-10T06:40:00.000Z"
comments: 2
```

## 1. On the whole page

Shorter: half the sections could be one paragraph.

## 2. In “The bar and the comment box” (#the-bar-and-the-comment-box)

> Every button is at least 44 pixels high, the size a finger hits.

Around it: “…s the box to the next comment. ⟦Every button is at least 44 pixels high, the size a finger hits.⟧ On a phone, tapping a button ca…”

Remove

Screenshots: review-v9-2-1.jpg
````

The quote is the text as the page shows it, so the agent searches the source for it (without
the Markdown marks) and uses the words around it when it appears more than once. A comment with
screenshots adds a line that names them (`Screenshots: review-v9-2-1.jpg`). **Copy** copies the
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
(`nimib-review:devlog/review-mode@v9` for this one). Reload the page, close the browser, come
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
2. see what changed since the review, `git diff <commit> -- <source>`, and find each quote in
   the source, knowing that it is rendered text (no Markdown marks, and the text of a table is
   made by code, not written in the notebook);
3. make the changes in the page's source: the commit that holds them is the next version;
4. rebuild and check the page on a phone;
5. answer by theme, not in the order of the comments: each theme says what was asked and what
   changed, or the question it raises; comments that only say something works go in a section
   of their own.

Saving each round's export with the page, and adding the round to a record, is something this
post does (below), not a step of the skill.

## Versions and rounds

This post changes in rounds: a review of a version makes the next one. A card for each version
says what it changed and what its review found, and links the export of the round, saved beside
the post's data (`round-1.md`, `round-2.md`). Versions 1 to 8 were a notebook each, and their
cards link it as it was; since version 9 the post is one notebook, and its versions are the
commits that changed it, so their card links the history of the file.
"""

const kept = "https://github.com/pietroppeter/tabelline/blob/64f87e2ab3de1121fa750a6aed5cb84b4ffd9a15/docs/devlog/review_mode/"
const commits = "https://github.com/pietroppeter/tabelline/commits/main/docs/devlog/review_mode.nim"
nbCards "The versions of this post":
  for i, v in storico:
    var what = v.what
    if what.startsWith("Round") and ": " in what: what = what[what.find(": ") + 2 .. ^1]
    var body = "**What it changed:** " & what
    body.add "\n\n**What its review found:** " & v.review
    if v.comments > 0: body.add &" ({v.comments} comments)"
    let href = if i < 8: kept & &"v{i + 1}.nim" else: commits
    nbCard(&"Version {i + 1}", href, (if v.time.len > 0: &"{v.date} · {v.time}" else: v.date)):
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
          holds: "A module of its own, with English names, that can move to nimib: the blocks (`nbReview` turns the review mode on, `nbVersion` puts the version line somewhere else, `nbInReview` holds blocks shown only while reviewing), the version from git, and their styles, `reviewCss`, from the page's colours or plain ones."),
    Pezzo(file: "`docs/blocks.nim`", holds: "`useTabelline`, which every page of this site calls, turns the review mode on with the shared script."),
    Pezzo(file: "`docs/assets/review.js`", holds: "The script, in nine parts (below)."),
    Pezzo(file: "`.claude/skills/nimib-review/SKILL.md`", holds: "The skill that turns an export into changes."),
    Pezzo(file: "`docs/devlog/review_mode/`", holds: "This post's data: `storia.nim`, the versions and rounds; the post is `docs/devlog/review_mode.nim`.")]
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
title, also in the export, is the page's title.

The version comes from git when the page is built: the number of commits that changed the
source, the last one's short hash and its day. Commit a change, build again, and the page is at
the next version, with no comments yet. A page built from changes not yet committed shows the
number with a `+` (*Version 12+*); a notebook outside git gets 7 characters of a hash of its
source, which changes when the source does. The page shows *Version 9 · updated 10 Nov 2026*
under its lede, or under its title when it has none, with **✎ Review** beside it;
`nbVersion()` puts that line where it is called instead. Blocks inside `nbInReview:` show only
while reviewing, as *New in this version* does on this page.

By default the script is inlined, so a page stays one file that works anywhere, even as a
claude.ai artifact. The pages of a site share one copy instead:
`nbReview(tscript = "../assets/review.js")` writes a link to the script, and the browser loads it
once for all of them.

Every page of this site has the review mode without asking for it: `useTabelline`, the line
each page calls after `nbInit` for its look, calls `nbReview` with the shared script, and its
style is in the site's shared style sheet. A page that should not have it passes
`review = false`. This post passes `reviewPage = "devlog/review-mode"`, so its comments keep the
key they had when it was a notebook per version. The blocks, in full:
"""

nbFoldCode "docs/review.nim", start = "type ReviewVersion*"

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

for i, (key, name, does) in parts:
  nbFoldCode "docs/assets/review.js", start = "// part: " & key,
             stop = (if i < parts.high: "// part: " else: "})();"), title = name

nbSave

# Versions 1 to 8 were pages of their own, devlog/review-mode/vN/: their address forwards to the
# post, and links the notebook the version was built from.
for n in 1 .. 8:
  let dir = docs / "devlog" / "review-mode" / &"v{n}"
  createDir(dir)
  writeFile(dir / "index.html", "<!doctype html>\n<html lang=\"en\"><head><meta charset=\"utf-8\">" &
    "<meta http-equiv=\"refresh\" content=\"0; url=../\"><title>Moved</title></head>\n<body><p>" &
    &"Version {n} of this post is now in git: <a href=\"{kept}v{n}.nim\">review_mode/v{n}.nim</a>. " &
    "The post is <a href=\"../\">Review mode</a>.</p></body></html>\n")
