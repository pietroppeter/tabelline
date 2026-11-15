import tabelline

type Row = tuple[city: string, temps: seq[int], rain: int]
let rows = @[
  (city: "Trento", temps: @[2, 4, 9, 13, 17, 21, 23, 22, 18, 12, 7, 3], rain: 55),
  (city: "Bari", temps: @[9, 10, 12, 15, 19, 24, 27, 27, 23, 18, 14, 10], rain: 60),
  (city: "Oslo", temps: @[-4, -4, 0, 5, 11, 15, 17, 16, 11, 6, 1, -3], rain: 49)]

let t = tabella(rows, rownameCol = "city"):
  tabHeader("Monthly temperatures", md("means of **1991–2020**"))
  fmtNanoplot("temps", plotType = "line", referenceLine = "mean")
  fmtNanoplot("rain", plotType = "bar")
  colsLabel:
    temps: "Temperature (°C)"
    rain: md("Rain (*mm*)")
  tabSourceNote "Climate normals, rounded"
  optStylize(style = 3, color = "green")
echo t
t.save "temps.html"
