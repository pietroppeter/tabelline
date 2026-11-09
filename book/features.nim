import tabbook, sources
bookInit()

nbText: """
# Find an example by feature

Every feature of tabelline's [feature map](https://pietroppeter.github.io/tabelline/coverage/),
with the pages of the book's sources that show it: the guides, the blog posts, the examples
and the Table Contest entries of [What the book will port](next.html), and the help page of every
function of gt (R) and of Great Tables (Python). When a feature lands, these are the examples to
port with it, and to try it on.

Press a feature to see its pages. The number on it is how many there are.
"""

finder:
  choices:
    nbTable featureButtons()

  noChoice:
    nbText: """
*No feature chosen yet: its pages show up here.*
"""

  for f in features():
    choice featureId(f):
      nbText: "## " & featureTitle(f)
      nbTable featurePages(f)
      nbText: "[↑ Another feature](#choices)"

nbText: """
## How the pages are found

A page is counted for every feature its code calls (`fmt_currency()`) or names as an argument
(`groupname_col=`), so it sees the functions, not what they are asked to do. The pages of a
feature come by source; in each, the help pages of the feature's own functions first, then the
others from the smallest, the one with fewest calls. 🐍 is for Python, 🏴‍☠️ for R, as in the tabs
of the chapters, 🏆 for an entry of the Posit Table Contest.

All of them, from the repository: `python3 book/plan/plan.py fmt_currency` (a gt function, or
words of the feature's name, `"row groups"`) prints every page that shows it, with its link and
the release it can be ported in.
"""

bookSave()
