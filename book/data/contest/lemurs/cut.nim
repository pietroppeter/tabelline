## Cuts TidyTuesday's `lemur_data.csv` (2021-08-24, from the Duke Lemur Center) to what the
## Lemurs chapter uses: one row per lemur (`lemurs.csv`) and every weight of a male or female
## lemur (`weights.csv`). Run with the path of the downloaded file:
##   nim r book/data/contest/lemurs/cut.nim lemur_data.csv
import std/[os, parsecsv, sets, strutils]

proc csvField(s: string): string =
  if s.contains({',', '"'}): "\"" & s.replace("\"", "\"\"") & "\"" else: s

var p: CsvParser
p.open(paramStr(1))
p.readHeaderRow()
let dir = currentSourcePath().parentDir
var lemurs = open(dir / "lemurs.csv", fmWrite)
var weights = open(dir / "weights.csv", fmWrite)
lemurs.writeLine "taxon,dlc_id,name,sex,dod"
weights.writeLine "taxon,sex,age_at_wt_mo,weight_g"
var seen: HashSet[string]
while p.readRow():
  let (taxon, id, sex) = (p.rowEntry("taxon"), p.rowEntry("dlc_id"), p.rowEntry("sex"))
  if id notin seen:
    seen.incl id
    lemurs.writeLine [taxon, id, csvField(p.rowEntry("name")), sex, p.rowEntry("dod")].join(",")
  let (age, wt) = (p.rowEntry("age_at_wt_mo"), p.rowEntry("weight_g"))
  if sex in ["F", "M"] and age != "NA" and wt != "NA":
    weights.writeLine [taxon, sex, age, wt].join(",")
lemurs.close()
weights.close()
