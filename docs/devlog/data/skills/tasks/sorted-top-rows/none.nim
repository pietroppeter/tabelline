import std/[algorithm, sequtils]
import nimib, tabelline, tabelline/[nimib, datasets, core]

nbInit
nb.title = "The moons of the planets"

let data = planets()
# the rows are shown sorted by moons, most first: shade the three that come first
let top3 = toSeq(0 ..< data.nrows).sortedByIt(-data["moons", it].toFloat)[0 .. 2]

nbTable data, rownameCol = "planet":
  tabHeader core.md("The **moons** of the planets")
  colsHide matches(proc (n: string): bool = n notin ["planet", "moons"])
  rowOrder cols("moons"), reverse = true
  tabStyle style.fill("#FFE9A8"), loc.body(rows = top3), loc.stub(rows = top3)

nbSave
