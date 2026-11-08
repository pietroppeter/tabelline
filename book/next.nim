import tabbook, sources
bookInit()

nbText: """
# What the book will port

Every source the book plans to port, page by page, with the release of tabelline that can
port it. Sources go from the simplest to the most complex, and so do their pages: first the
ones that can be ported now, then the ones that wait for a release. The
[first page](index.html) has the sources in one table.

How it is measured: `book/plan/plan.py` reads each page's code, finds the gt and Great Tables
functions it calls, and looks each one up in the
[coverage map](https://pietroppeter.github.io/tabelline/coverage/), where every gt feature
has its status and the release it is planned for. A page can be ported in the first release
that has every feature it calls. It is a first sieve: it sees the functions, not their
arguments, so a page that can be ported "now" can still find gaps when it is ported, as the
*Get Started* guide found a dozen. Those go to [What the port found](gaps.html) and to the
build of the next release.
"""

for s in sources["sources"]:
  let id = s["id"].getStr
  nbText: "## " & s["title"].getStr & "\n\n" & s["what"].getStr & ". By " & s["by"].getStr &
    ", " & s["licence"].getStr & " licence. [Read it](" & s["url"].getStr & ")."
  nbTable pagesTable(id, ported = s["status"].getStr == "ported")

nbText: """
## Not yet mapped

Sources the book wants to port too, once their pages are listed and their licence allows it.
"""
nbTable candidatesTable()

bookSave()
