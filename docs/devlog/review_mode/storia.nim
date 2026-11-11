## The versions of the post "Review mode" and the review rounds that made them, oldest first.
## Versions 1 to 8 were a notebook each (in git at commit 64f87e2); since version 9 the post is one
## notebook, and a version is a commit. Add a line here when a round makes a new version.

type Versione* = object
  date*: string      ## the day the version was published
  time*: string      ## and the time, Italian time (HH:MM): when its pull request was merged
  what*: string      ## what it changed, in Markdown
  review*: string    ## what the round that read it found, in Markdown ("" while it waits)
  comments*: int     ## how many comments that round had

const storico* = [
  Versione(date: "9 Nov 2026", time: "09:37", what: "The first draft: the review mode and this post, before any review.",
           review: "[Round 1](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-1.md): " &
             "a section on the pieces of the screen is missing; typing a comment zooms the page; a comment " &
             "should take screenshots; what **Edit** opens was unclear; the export should be editable.",
           comments: 3),
  Versione(date: "9 Nov 2026", time: "11:36", what: "Round 1: a section on the pieces of the screen, no zoom while typing, " &
             "screenshots in a comment, an export to edit before copying or sharing, **Edit** explained.",
           review: "[Round 2](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-2.md): " &
             "no zoom works; tapping an older version should open it; a screenshot should be pasted, not " &
             "picked; the comment sheet hides the words it is about and takes too much room; the pieces of " &
             "the screen should start from an annotated screenshot.",
           comments: 4),
  Versione(date: "9 Nov 2026", time: "11:56", what: "Round 2: a compact comment sheet that slides down from the top and " &
             "leaves the words in view, screenshots pasted, the whole version box a link, an annotated " &
             "screenshot of the pieces of the screen.",
           review: "[Round 3](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-3.md): " &
             "the strip should show only the newest version and the one before, with a short animation; " &
             "the compact sheet is better; pasting an image should just work, with no buttons; Delete " &
             "belongs at the top; *Cut* is not clear. And the copy with screenshots inside was too long " &
             "for the chat, where the front matter of the text showed as loose lines.",
           comments: 2),
  Versione(date: "9 Nov 2026", time: "13:17", what: "Round 3: an image pasted in the note just works, no buttons; " &
             "Delete in the top row; no *Cut* (an empty replacement removes the words); Copy copies the " &
             "text only, and each screenshot has its own Copy image; the export opens with a YAML block, " &
             "not a front matter, so it reads well in a chat; the strip shows only the newest version and " &
             "the one before it, and moving between them is a short slide.",
           review: "[Round 4](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-4.md): " &
             "pasting an image works on an iPhone; how to write a note on the whole page; number the " &
             "changes of a version, without *Round 3*; a heading for the idea, with screenshots in it; " &
             "the assumptions read like decision records, and their opening assumed the reader knew " &
             "the rounds.",
           comments: 6),
  Versione(date: "9 Nov 2026", time: "14:54", what: "With nothing selected, the comment button says *Page note*: a " &
             "note on the whole page; the changes of a version are a numbered list; the idea has a " &
             "heading of its own, *The idea*, and mentions screenshots; the assumptions are now " &
             "*The decisions behind it*, each saying which round changed it.",
           review: "[Round 5](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-5.md): " &
             "every heading of the site should lead back to the contents; the problem assumed the reader " &
             "knew these threads; the versions should say the time, and how long after the one before.",
           comments: 3),
  Versione(date: "9 Nov 2026", time: "16:04", what: "Every heading of the site has an arrow back to the contents; " &
             "the problem says who makes the pages (coding agents, Claude Code from a phone); the table of " &
             "versions gives the day and time of the first of each day, then how long after the one before.",
           review: "[Round 6](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-6.md): " &
             "no kinds, a replacement is said in the note; rethink the post from scratch, with a diagram " &
             "of the modes and the stories the review mode serves; a Review button that opens and " &
             "closes the mode, and no review UI without it; a sheet with no buttons that saves by " &
             "itself; screenshots that open large; History instead of Clear all; Share opens a new " &
             "session, outside the project; *How it is built* from zero, starting from nimib.",
           comments: 27),
  Versione(date: "10 Nov 2026", time: "06:35", what: "Round 6: reading is the default, and a **Review** button " &
             "beside the version opens and closes the review mode; outside it, no bar and no marks; " &
             "no kinds: a replacement is written in the note; the comment the arrows stop on is open " &
             "in a sheet with no buttons, which saves as you type; a screenshot opens large with a tap; " &
             "**History** lists the versions and clears their comments; no **Share**, since it opens " &
             "a new session; the post rethought from scratch, with a diagram of the modes and the " &
             "stories they serve; *How it is built* starts from nimib.",
           review: "[Round 7](https://github.com/pietroppeter/tabelline/blob/main/docs/devlog/data/review-mode/round-7.md): " &
             "the date above the title reads badly; the pieces of the screen should come before the modes, " &
             "one card per screen, History too; *Close review* in the export; *sheet* is not a clear name; " &
             "the table of versions is unreadable; the folded code looks like headings; the review mode " &
             "deserves a module of its own, in English, and a simpler call; the skill keeps versions and " &
             "rounds that only this post needs, and its answers should be grouped.",
           comments: 22),
  Versione(date: "10 Nov 2026", time: "06:35", what: "Round 7: the date the post was written above the title, " &
             "the last update beside the version; the pieces of the screen before the modes, one card per " &
             "screen, History included; *Close review* in the export too; the *sheet* is now the *comment " &
             "box*; the versions are cards; folded code reads *show code*; the review mode is a module of " &
             "its own, `review.nim`, in English, and `nbReview()` needs no arguments; the skill keeps versions " &
             "and rounds only for pages that ask for them, and answers by theme.",
           review: "No round on the page: the API was discussed in the chat, and became the change " &
             "*review-mode-api*, now in [the specs of the review mode](../../specs/?spec=review-mode): " &
             "the newest version by default, or only the newest; the version from git; the review mode on every page; " &
             "devlog posts take edits.",
           comments: 0),
  Versione(date: "10 Nov 2026", time: "", what: "The review mode is on every page of the site, and its version " &
             "comes from git: a commit that changes a page is its next version, and the export names it; " &
             "the post is one notebook, and versions 1 to 8 are linked as they were, in git; " &
             "**History** lists only the versions with comments in this browser; the export is `nimib-review/4`.",
           review: "Waiting for the ninth round.", comments: 0),
]

