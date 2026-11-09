## Version 4 of the devlog post "Review mode" (docs/devlog/review_mode.nim has the post's first line).
## A version knows its number from its file name, vN.nim. The newest version is the post, built into
## devlog/review-mode/; an older one is kept as it was and built into devlog/review-mode/vN/.
import std/[os, strutils, strformat]
import nimib except md
import tabelline, tabelline/nimib
import ../../blocchi
import storia

const
  questa = parseInt(currentSourcePath().splitFile.name[1 .. ^1])   # v1.nim is version 1
  newest = questa == storico.len
  title = "Review mode"
let docs = currentSourcePath().parentDir.parentDir.parentDir
let source = currentSourcePath().relativePath(docs.parentDir)
nbInit
nb.doc.filename = docs / "devlog" / "review-mode" / (if newest: "" else: &"v{questa}") / "index.html"
nb.useTabelline(nome = "tabelline", title = title,
                homeHref = (if newest: "../" else: "../../"), backLabel = "Devlog",
                nameHref = (if newest: "../../" else: "../../../"))
nbRevisione("devlog/review-mode", questa, title, source)

nbTitolo &"9 November 2026 · version {questa}", title, """
Reviewing a page on a phone takes screenshots, notes, and many trips between the page and the
chat. A review mode for nimib pages: select text, comment on it, go through the comments with a
bar, and export them all in one text to paste in the chat, where an agent makes the changes. This
post is reviewed with its own review mode, round by round, and keeps every version.
"""

nbVersioni storico.lista, questa

if not newest:
  nbNota &"This is version {questa}, kept as it was when it was reviewed. The newest is " &
    &"[version {storico.len}](../).", nkWarning

nbNota storico[questa - 1].what & " What the review asked is in the table of " &
  "[Versions and rounds](#versions-and-rounds).", nkDone, &"New in version {questa}"

nbNota """
Select a few words of this page and tap **Comment** in the bar at the bottom: write what should
change (paste a screenshot in it if it helps), and save. **‹** and **›** go from comment to comment, and
**Edit** opens the one they stopped on (or tap any marked words). **Export** gives the text, to
edit, copy or share in the chat. The comments stay in this browser only.
""", nkInfo, "Try it on this page"

nbIndice

nbText: """
## The problem

Pietro reviews the pages made in these threads on his phone. Today a comment goes like this:
take a screenshot of the page, paste it in the chat, write what to change, then go back to the
page, which in a claude.ai artifact takes a few seconds to load again. A page merged and served
by GitHub Pages opens faster, but every comment is still a trip from the page to the chat and
back. Ten comments are ten trips.

A review mode keeps the whole review on the page and makes one trip at the end: select, comment,
and when the reading is done, export everything at once. The agent gets one text that says which
page, which version, and what to change where, in the order of the page.

## What the review mode assumes

The first pass was built without questions, so its choices are written down here, to be changed
by the reviews. Round 1 changed the fifth and added the ninth, round 2 changed the fifth again
and the sixth, round 3 the fourth, the fifth and the ninth:

1. **One reviewer, one browser.** The comments are kept in the browser's `localStorage`, and
   nothing is sent anywhere. Another phone, or clearing the site's data, starts with no comments:
   the export is the way out.
2. **Comments belong to a version.** Version 2 of a page starts with no comments; the ones on
   version 1 stay with version 1.
3. **A comment points at text**, the words selected and a few around them, not at a place in
   the HTML. When the words are no longer on the page, the comment is kept and the export says so.
4. **Two kinds, and the whole page.** A comment, or a replacement: the new text, written in
   place, starting from the words selected. Leave it empty and the words are removed (version 3
   had a third kind for that, *Cut*, which round 3 did not understand). With nothing selected, a
   comment is about the whole page.
5. **The export goes through the clipboard, or the share sheet.** The text can be edited
   before it goes. **Copy** copies the text only: a chat message has a limit, and round 3 found
   that screenshots written into the text go past it. Each screenshot has a **Copy image** of its own,
   to paste in the chat after the text. Where the clipboard is blocked (inside an artifact it can
   be), select the text in its box and copy by hand. **Share** sends the text as a file, with the
   screenshots at full size, to an app such as Claude.
6. **The bar is at the bottom, the sheet at the top.** The thumb reaches the bottom of a phone;
   the sheet to write in slides down from the top, where the keyboard does not cover it, and is
   kept small, so the words it is about stay in view under it.
7. **It is a block of tabelline's pages for now**, `nbRevisione` in `docs/blocchi.nim`. Once
   it works, it can become a nimib block for any page.
8. **Every version is kept as its notebook.** An old version is built again from its own source
   with today's blocks: its text is exactly as it was, its look follows the site.
9. **A screenshot is pasted in the note, like text**: no button to press. It is kept in the
   browser too, made smaller (900 pixels wide, JPEG), next to
   the comments. A browser keeps about 5 MB for a site, some twenty screenshots: when it is
   full, the bar says so, and exporting and clearing makes room.

## The simplest review: one comment

A comment is three things: what it is about (the words selected), what to do (comment or replace)
and a note. Select *ten trips* in the first section, tap **Comment**, choose **Replace**,
write *ten round trips*, and save: the words are marked on the page, and the export reads

```text
## 1. Replace, in “The problem” (#the-problem)

> ten trips

Around it: “…chat and back. Ten comments are ⟦ten trips⟧. A review mode keeps the whol…”

Replace with:

~~~text
ten round trips
~~~
```

Everything else is there to make many of these quick to write, to find again, and to hand over.

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
(`nimib-review:devlog/review-mode@v4` for this one). Reload the page, close the browser, come
back tomorrow: they are still there, marked on the text. Nothing leaves the phone until the
export.

## The pieces of the screen

Two screens of this page on a phone, with a number on each piece: writing a comment, and the
export. The table under them says what each piece does and what is still open about it.
Comment on a row of the table to change that piece.
"""

let shots = docs / "devlog" / "data" / "review-mode"
nbAccanto:
  nbSchermata shots / "sheet.jpg", shots / "sheet.json", "Writing a comment: the sheet at the top, the words under it"
  nbSchermata shots / "export.jpg", shots / "export.json", "The export: the text, to edit, copy or share"

block:
  type Pezzo = object
    n: int
    piece, does, open: string
  let rows = @[
    Pezzo(n: 1, piece: "Marks",
          does: "The words of each comment, in the soft colour of notes; the one the arrows stopped on, darker. Tap one to open it. While a comment is written, its words are marked already.",
          open: "Should a comment on the whole page show somewhere on it?"),
    Pezzo(n: 2, piece: "‹ › and the count",
          does: "In the bar at the bottom, in reach of the thumb: previous and next comment in the order of the page; *2/5* says which.",
          open: "Could the bar fold away while reading, and show only the count?"),
    Pezzo(n: 3, piece: "Edit",
          does: "Opens the comment the arrows stopped on. Greyed out until they stop on one.",
          open: "Unclear in round 1: should it say *Open 2* instead?"),
    Pezzo(n: 4, piece: "Comment",
          does: "A new comment: on the words selected (it shows *Comment ✓*), or on the whole page.", open: ""),
    Pezzo(n: 5, piece: "Export", does: "Opens the export sheet.", open: ""),
    Pezzo(n: 6, piece: "The sheet's first row",
          does: "× to cancel, the kind (comment or replace), Delete for a comment already saved, Save. The sheet slides down from the top and keeps to a few lines, so the words stay in view under it; the page does not zoom while it is open.",
          open: ""),
    Pezzo(n: 7, piece: "Note",
          does: "What should change, and why. For a replacement, a second field above it holds the new text, starting from the words selected; empty, it removes them.",
          open: ""),
    Pezzo(n: 8, piece: "Screenshots",
          does: "Pasted in the note, like text, they show small under it, with × to remove one. The row is there only when there are some.",
          open: "Draw on a screenshot, to circle what is wrong?"),
    Pezzo(n: 9, piece: "The export text",
          does: "Every comment as Markdown, after a block of YAML, to edit before it goes.", open: ""),
    Pezzo(n: 10, piece: "Copy",
          does: "Copies the text only. Each screenshot is listed above, with a *Copy image* of its own, to paste after the text.", open: ""),
    Pezzo(n: 11, piece: "Share",
          does: "Sends the text as a file, with the screenshots at full size, to an app such as Claude.",
          open: "Clear after Share, or ask?"),
    Pezzo(n: 12, piece: "Clear all", does: "Deletes every comment of this version; tap twice.", open: ""),
    Pezzo(n: 13, piece: "Versions (under the title)",
          does: "One box per version, each a link; the one shown has a line under it.", open: "")]
  let t = tabella(rows, rownameCol = "n"):
    colsLabel {"piece": "Piece", "does": "What it does", "open": "Still open"}
    fmtMarkdown ["does", "open"]
    optCssTheme()
  nbTable t

nbText: """
## The bar

Once a page has review mode, a bar stays at the bottom of the screen while it scrolls:

- **‹** and **›** go to the previous and next comment, in the order of the page, and scroll to
  it; the count between them says which one it is (*2/5*);
- **Edit** opens a comment you have reached with the arrows: after **›** stops on comment 2, its
  words are marked darker, the count says *2/5*, and **Edit** opens it, to change it or delete
  it. Before the arrows stop on one, **Edit** is greyed out. To open any comment directly, tap its
  marked words;
- **Comment** writes a new one: on the selected words when there are some (the button says
  *Comment ✓*), on the whole page when there are none;
- **Export** shows the text of all the comments, to edit, copy or share.

Every button is at least 44 pixels high, the size a finger hits. On a phone, tapping a button can
clear the selection before the button sees it, so the page keeps the selection as soon as it is
made.

## The export

The export is for two readers, the reviewer who checks it before pasting it, and the agent that
applies it. JSON would be easy for the second and tiring for the first. Markdown is easy for
both, and a chat shows it well: a title, a block of YAML that holds what a program needs (which
page, which source file, which version), and each comment a short section with its kind and its
place in the heading, the words as a quote, the replacement in a fence of its own. Up to version 3
the YAML was a front matter, between two `---` lines: round 3 found that a chat shows those as a
rule and a pile of loose lines, so from version 4 it is a `yaml` block (`format: nimib-review/2`).

````text
# Review of “Review mode”, version 4

```yaml
format: nimib-review/2
title: "Review mode"
page: "https://pietroppeter.github.io/tabelline/devlog/review-mode/"
source: "docs/devlog/review_mode/v4.nim"
version: 4
exported: "2026-11-09T09:40:00.000Z"
comments: 2
```

## 1. Comment, on the whole page

Shorter: half the sections could be one paragraph.

## 2. Remove, in “The bar” (#the-bar)

> Every button is at least 44 pixels high, the size a finger hits.

Around it: “…nts, to edit, copy or share. ⟦Every button is at least 44 pixels high, the size a finger hits.⟧ On a phone, tapping a button ca…”

Remove these words.

Screenshots: review-v4-2-1.jpg
````

The quote is the text as the page shows it, so the agent searches the source for it (without
the Markdown marks) and uses the words around it when it appears more than once. A comment with
screenshots adds a line that names them (`Screenshots: review-v4-2-1.jpg`). **Share** sends them
with the text, under those names. **Copy** copies the text alone, and each screenshot is copied
by its own button, under the text: in version 3 Copy wrote them into the text, small, and a chat
refused the message as too long.

## Processing an export: a skill

An export pasted in the chat should be enough: no instructions around it. A skill teaches the
agent what to do with one, `.claude/skills/nimib-review/SKILL.md` in this repository for now
(it can move to Pietro's skills once it works). In short:

1. read the YAML block (or the front matter, before version 4), and check that the number of comments matches;
2. find each quote in the source, knowing that it is rendered text (no Markdown marks, and the
   text of a table is made by code, not written in the notebook);
3. keep the version that was reviewed, and make the changes in a new one;
4. save the export with the page's data, and add the round to the page's record;
5. rebuild, check on a phone, and answer with one line per comment: done, or the question it
   raises.

## Versions and rounds

This post changes in rounds: a review of version 1 makes version 2, and so on. The strip at the
top switches between them. Each version is a notebook of its own, `review_mode/v1.nim`,
`review_mode/v2.nim`: a new round copies the newest to the next number and changes the copy, so
every version that was read is kept as it was, and a comment of a round can be checked against
the text it was written on.
"""

block:
  type Riga = object
    version, date, what, review: string
    comments: int
  var rows: seq[Riga]
  for i in 0 ..< questa:
    let v = storico[i]
    rows.add Riga(version: &"v{i + 1}", date: v.date, what: v.what, review: v.review, comments: v.comments)
  let t = tabella(rows, rownameCol = "version"):
    colsLabel {"date": "Written", "what": "What it changed", "review": "What its review found", "comments": "Comments"}
    fmtMarkdown ["what", "review"]
    optCssTheme()
  nbTable t

nbText: """
## How it is built

Three pieces: a block that puts the review mode on a page, a script that does the work in the
browser, and the styles. Nothing is loaded from elsewhere: the script is inlined in the page,
which stays one standalone file.

### The block

A page turns the review mode on with one line after `useTabelline`: here
`nbRevisione("devlog/review-mode", 4, "Review mode", "docs/devlog/review_mode/v4.nim")`. The
block writes the settings on an empty element, for the script to read, and the script itself;
its styles (`revisioneCss` in `docs/stile.nim`, from the tokens) go in the head, so pages
without review mode don't carry them.
"""

let blocchiSrc = readFile(docs / "blocchi.nim")
let blockCode = blocchiSrc[blocchiSrc.find("newNbBlock(NbRevisione):") ..< blocchiSrc.find("newNbBlock(NbVersioni):")]
nbText "```nim\n" & blockCode.strip & "\n```"

nbText: """
### The script

`docs/assets/revisione.js`, about three hundred lines of plain JavaScript with no dependencies,
in six parts. Each starts with what it does.
"""

const headings = [("anchor", "Where a comment points"), ("mark", "Marking the text"),
                  ("store", "Keeping the comments"), ("bar", "The bar"), ("sheet", "Writing a comment"),
                  ("export", "The export")]
let script = readFile(docs / "assets" / "revisione.js")
for chunk in script.split("  // part: ")[1 .. ^1]:
  let lines = chunk.splitLines
  var heading = lines[0].strip
  for (key, words) in headings:
    if key == heading: heading = words
  let code = lines[1 .. ^1].join("\n").strip(leading = false).unindent(2)
  nbText "#### " & heading & "\n\n```js\n" & code & "\n```"

nbText: """
### The versions

`nbVersioni` draws the strip at the top from a list of `(date, what changed)`, oldest first,
and the number of the version shown. A version's notebook knows its number from its file name
(`v1.nim` is 1) and whether it is the newest from the length of that list, `storia.nim`: the
newest builds into `devlog/review-mode/`, an older one into `devlog/review-mode/v1/`. The post's
own file, `review_mode.nim`, holds only the first line the devlog reads and the import of every
version.
"""

nbSave
