## The versions of the post "Review mode" and the review rounds that made them, oldest first.
## Every version's notebook (v1.nim, v2.nim, ...) reads this, so an old version links the newer ones.

type Versione* = object
  date*: string      ## when the version was written
  what*: string      ## what it changed, in Markdown
  review*: string    ## what the round that read it found, in Markdown ("" while it waits)
  comments*: int     ## how many comments that round had

const storico* = [
  Versione(date: "9 Nov 2026", what: "The first draft: the review mode and this post, before any review.",
           review: "[Round 1](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-1.md): " &
             "a section on the pieces of the screen is missing; typing a comment zooms the page; a comment " &
             "should take screenshots; what **Edit** opens was unclear; the export should be editable.",
           comments: 3),
  Versione(date: "9 Nov 2026", what: "Round 1: a section on the pieces of the screen, no zoom while typing, " &
             "screenshots in a comment, an export to edit before copying or sharing, **Edit** explained.",
           review: "Waiting for the second round.", comments: 0),
]

func lista*(vs: openArray[Versione]): seq[(string, string)] =
  ## `(date, what)` of each version, for `nbVersioni`.
  for v in vs: result.add (v.date, v.what)
