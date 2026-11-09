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
           review: "[Round 2](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-2.md): " &
             "no zoom works; tapping an older version should open it; a screenshot should be pasted, not " &
             "picked; the comment sheet hides the words it is about and takes too much room; the pieces of " &
             "the screen should start from an annotated screenshot.",
           comments: 4),
  Versione(date: "9 Nov 2026", what: "Round 2: a compact comment sheet that slides down from the top and " &
             "leaves the words in view, screenshots pasted, the whole version box a link, an annotated " &
             "screenshot of the pieces of the screen.",
           review: "[Round 3](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-3.md): " &
             "the strip should show only the newest version and the one before, with a short animation; " &
             "the compact sheet is better; pasting an image should just work, with no buttons; Delete " &
             "belongs at the top; *Cut* is not clear. And the copy with screenshots inside was too long " &
             "for the chat, where the front matter of the text showed as loose lines.",
           comments: 2),
  Versione(date: "9 Nov 2026", what: "Round 3: an image pasted in the note just works, no buttons; " &
             "Delete in the top row; no *Cut* (an empty replacement removes the words); Copy copies the " &
             "text only, and each screenshot has its own Copy image; the export opens with a YAML block, " &
             "not a front matter, so it reads well in a chat; the strip shows only the newest version and " &
             "the one before it, and moving between them is a short slide.",
           review: "Waiting for the fourth round.", comments: 0),
]

func lista*(vs: openArray[Versione]): seq[(string, string)] =
  ## `(date, what)` of each version, for `nbVersioni`.
  for v in vs: result.add (v.date, v.what)
