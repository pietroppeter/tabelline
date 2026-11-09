import tabbook, sources
bookInit()

nbText: """
# Find an example by feature

Every feature of tabelline's [feature map](https://pietroppeter.github.io/tabelline/coverage/),
with the pages of the book's sources that show it: the guides, the blog posts, the examples
and the Table Contest entries of [What the book will port](next.html), and the help page of every function of gt (R) and of
Great Tables (Python). When a feature lands, these are the examples to port with it, and to try
it on.

Under each feature, the release of tabelline that has it ("now" or "in 0.2") and how many
pages show it. *Where to start* has the best three: first the help pages of the
feature's own functions, then the other pages from the smallest, the one with fewest calls; 🐍
for Python, 🏴‍☠️ for R, as in the tabs of the chapters, 🏆 for an entry of the Posit Table
Contest. A page is counted for every feature its code calls (`fmt_currency()`) or names
as an argument (`groupname_col=`), so it sees the functions, not what they are asked to do.

All of them, from the repository: `python3 book/plan/plan.py fmt_currency` (a gt function, or
words of the feature's name, `"row groups"`) prints every page that shows it, with its link and
the release it can be ported in.
"""

nbTable featuresTable()

bookSave()
