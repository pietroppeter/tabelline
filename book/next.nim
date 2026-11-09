import tabbook, sources
bookInit()

nbText: """
# What the book will port

Every source the book plans to port, page by page, with the release of tabelline that can
port it. Sources go from the simplest to the most complex, and so do their pages: first the
ones that can be ported now, then the ones that wait for a release. The
[first page](index.html) has the sources in one table.

How the pages are found: each source says where its pages are, a GitHub repository and the
paths of its pages, and `book/plan/plan.nim` lists the repository, so a page added there shows
up here (marked *To triage* until someone reads it), and a page that is gone is reported. The
Table Contest entries are listed by hand, one repository each, and their code is read whole;
saving the table as a picture (`gtsave`) does not count.

How it is measured: `book/plan/plan.nim` reads each page's code, finds the gt and Great Tables
functions it calls, and looks each one up in the
[feature map](https://pietroppeter.github.io/tabelline/coverage/), where every gt feature
has its status and the release it is planned for. A page can be ported in the first release
that has every feature it calls. It is a first sieve: it sees the functions, not their
arguments, so a page that can be ported "now" can still find gaps when it is ported, as the
*Get Started* guide found a dozen. Those go to [What the port found](gaps.html) and to the
build of the next release.
"""

for s in sources["sources"]:
  let id = s["id"].getStr
  var text = "## " & s["title"].getStr & "\n\n" & s["what"].getStr & ". By " & s["by"].getStr &
    ", " & s["licence"].getStr & " licence. [Read it](" & s["url"].getStr & ")."
  if s.isContest:
    # a few hundred entries: they have a page of their own
    text.add "\n\nIts " & $pagesOf(id).len & " entries with code on GitHub, and which of them " &
      "tabelline can redo, are in [The Table Contest](contest.html)."
  elif s.isReference:
    # a help page per function: too many for a table here, so they are found by feature
    text.add "\n\nIts " & $pagesOf(id).len & " pages with examples, one per function, are found " &
      "by the features they show, in [Find an example by feature](features.html)."
  nbText: text
  if not s.isReference and not s.isContest:
    nbTable pagesTable(id, ported = s["status"].getStr == "ported")

nbText: """
## Not yet mapped

Sources the book wants to port too, once their pages are listed and their licence allows it.
"""
nbTable candidatesTable()

bookSave()
