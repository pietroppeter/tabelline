import std/[strutils, json, sequtils]
import tabbook, sources
bookInit()

const id = "table-contest"
let
  all = pagesOf(id)
  soon = contestEntries(id, upTo = "now")
  later = contestEntries(id, since = "0.3")
  other = contestEntries(id, other = true)
  licensed = soon.countIt(it{"licence"}.getStr != "")

nbText: """
# The Table Contest

Every year since 2020 (but 2023), Posit has run a contest for tables made with code: the
[Posit Table Contest](https://github.com/rich-iannone/table-contest). Each entry shares its
code. These are the entries whose code is on GitHub: """ & $all.len & """ of them, from the
forum posts of 2020 to 2024 and the winners post of 2025, with the prize each won.

For every entry made with gt or Great Tables, the book reads all its code and finds the gt
functions it calls, as for the pages of [What the book will port](next.html): an entry *can be
done* in the first release of tabelline that has every feature it calls. """ & $soon.len &
""" can be done with tabelline now, """ & $later.len & """ wait for a later release, and
""" & $other.len & """ are made with another package (reactable, DT, kableExtra, flextable, …),
which this does not measure.

An entry with no licence is an idea to redo, not code to port: the book can make the same
table in tabelline, with its own code, and link the original. """ & $licensed & " of the " &
$soon.len & """ that can be done now have a licence.
"""

nbText: """
## Can be done now

The first ones to redo, from the ones that need the fewest new features; the awarded ones first.
*Done* marks the ones already redone in this book, in the chapters that follow this page.
"""
nbTable contestTable(soon)

nbText: """
## Made with gt, for a later release

What they wait for is what tabelline needs to redo them: gt-extras' plots, icons and themes
come first.
"""
nbTable contestTable(later)

nbText: """
## Made with another package

Interactive tables (reactable, DT, Shiny apps) are for tabellone, a later idea; static tables
made with kableExtra, flextable or formattable can still be redone with tabelline, by hand.
"""
nbTable otherTable(other)

nbText: """
## How the entries are found

`book/plan/contest.nim` reads the forum topics with the contest's tags (2020 to 2024) through
the forum's JSON API, and the winners posts on posit.co: an entry is the GitHub repository its
post links first, or the one its winners post links. The 2025 entries are GitHub Discussions,
read here from the winners post. Repositories deleted since are left out. Then
`book/plan/plan.nim` clones each one (only the list of its files), reads its R, Python, R
Markdown, Quarto and notebook files, and finds its licence and the packages it uses.
"""

bookSave()
