## The stories, docs/stories/index.html: real subjects told in tables made with tabelline, one for
## every release (the *use it* thread of the roadmap), in release order, in the gallery of
## `storie.nim` (the home page shows the same gallery).
## Stories are kept up to date: when a release makes a table of a story better, the story changes.
## A story that used to be a devlog post keeps its old address, which forwards here (`moved`).
import std/os
import nimib
import ../blocks, storie

let here = currentSourcePath().parentDir
let docs = here.parentDir

nbInit
nb.doc.filename = here / "index.html"
nb.useTabelline(section = "Stories", cadence = "one for every release",
               title = "tabelline stories", homeHref = "../",
               description = "Real subjects told in tables made with tabelline, one for every release.")

nbTitle "Stories", "Told with tabelline", """
Real subjects, with real data, told in tables made with tabelline: one story for every release,
written as a user would write it, with the features that release adds. Stories are kept up to
date, so a table gets better when tabelline does. How tabelline itself is made is in the
[devlog](../devlog/).
"""
nbStorie ""
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
