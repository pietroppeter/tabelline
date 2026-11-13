## Edge cases of tabellaPreview's moreRows (the specs' examples cover the main path).
import std/[unittest, strutils]
import tabelline, tabelline/datasets

proc stubOf(t: Tabella): string =
  ## The stub of a preview's text, one cell per line.
  for line in ($t).splitLines:
    if line.startsWith("│"): result.add line.split("│")[1].strip & " "

suite "preview, more rows":
  test "a set of indices and ranges":
    let t = tabellaPreview(planets(), topN = 1, bottomN = 1, moreRows = {3, 5..5})
    check t.stubOf.strip == "1 2..3 4 5 6 7 8"   # 4 and 6 are runs of one row, so shown
  test "a run of one row is shown":
    check tabellaPreview(planets(), topN = 1, bottomN = 1, moreRows = 2).stubOf.strip == "1 2 3 4..7 8"
  test "a chosen row among the first is shown once":
    check tabellaPreview(planets(), topN = 2, bottomN = 1, moreRows = 0..1).stubOf.strip == "1 2 3..7 8"
  test "where":
    check tabellaPreview(planets(), topN = 1, bottomN = 1,
                         moreRows = where(it.planet == "Saturn")).stubOf.strip == "1 2..5 6 7 8"
  test "without moreRows, as before":
    check tabellaPreview(planets(), topN = 2, bottomN = 1).stubOf.strip == "1 2 3..7 8"
