## The versions of the post "Review mode" and the review rounds that made them, oldest first.
## Every version's notebook (v1.nim, v2.nim, ...) reads this, so an old version links the newer ones.

type Versione* = object
  date*: string      ## when the version was written
  what*: string      ## what it changed, in Markdown
  review*: string    ## what the round that read it found, in Markdown ("" while it waits)
  comments*: int     ## how many comments that round had

const storico* = [
  Versione(date: "9 Nov 2026", what: "The first draft: the review mode and this post, before any review.",
           review: "Waiting for the first round.", comments: 0),
]

func lista*(vs: openArray[Versione]): seq[(string, string)] =
  ## `(date, what)` of each version, for `nbVersioni`.
  for v in vs: result.add (v.date, v.what)
