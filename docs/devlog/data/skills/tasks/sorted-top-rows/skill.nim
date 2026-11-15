import nimib except md
import tabelline, tabelline/datasets, tabelline/nimib

nbInit
nbText: "# The **moons** of the planets"

var t = tabella(planets(), rownameCol = "planet"):
  colsHide ["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "rings"]
  rowOrder columns = "moons", reverse = true
  colsLabel:
    moons: md("Moons")

let top = t.displayOrder()[0 .. 2]
t = t.tabStyle(style.fill("#FFE8A3"), loc.body(rows = top))
t = t.tabStyle(style.fill("#FFE8A3"), loc.stub(rows = top))
echo t
nbTable t
nbSave
