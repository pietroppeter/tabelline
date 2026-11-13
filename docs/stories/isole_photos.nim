## Photos of the Mediterranean, by the story: the openly licensed pictures gathered for the story
## *Islands of the Mediterranean* (isole.nim), one group for each of its sections, and the one
## picked for each, shown as the story shows it: the section's heading over the photo.
##
## Data in docs/stories/data/isole/photos/: `groups.json` (the groups, in the order of the story,
## and for each photo its preview file, name, pick, about and why) and `photos.json` (each photo's
## link, who, when and licence). The photos themselves are not kept: only small previews
## (`previews/`, 420 pixels) and, for the picks, the copies the story shows (`story/`, 800 pixels).
import std/[json, os, strutils]
import nimib
import tabelline, tabelline/nimib
import ../blocks, ../theme

let docs = currentSourcePath().parentDir.parentDir
let data = docs / "stories" / "data" / "isole" / "photos"
let groups = parseFile(data / "groups.json")
let links = parseFile(data / "photos.json")

# the file of each pick in the story, by its name (the story's heading uses the same copy)
const storyFiles = [("Southern Italy and Sicily, south at the top", "night-south-up"),
  ("Etna's plume", "etna-plume"), ("The dolphins of Knossos", "dolphins-knossos"),
  ("Lemnos, in Piri Reis's Book of the Sea", "lemnos-piri-reis"), ("Strombolicchio", "strombolicchio"),
  ("Venice, in Bordone's book of islands", "venice-bordone"), ("Palermo cathedral, about 1900", "palermo-cathedral"),
  ("Luzzus in Marsaxlokk, Malta", "luzzus-marsaxlokk"), ("Capri's harbour, about 1880", "capri-harbour"),
  ("Lussinpiccolo, about 1900", "lussinpiccolo"), ("Rabbit Beach, Lampedusa", "rabbit-beach"),
  ("Al-Idrisi's map, south at the top", "al-idrisi")]

func md(html: string): string =
  ## The few tags the texts use, as Markdown.
  html.multiReplace(("<i>", "*"), ("</i>", "*"), ("<p>", ""), ("</p>", "\n\n"), ("<h2>", "\n## "), ("</h2>", "\n\n")).strip

proc details(name: string): JsonNode =
  for d in links:
    if d["name"].getStr == name: return d
  newJObject()

proc credit(name: string): string =
  ## Who made it, when, its licence and a link to its source.
  let d = details(name)
  result = d{"who"}.getStr
  if d{"when"}.getStr.len > 0: result.add ", " & d{"when"}.getStr
  result.add " · " & d{"license"}.getStr & " · [source](" & d{"link"}.getStr & ")"

nbInit
nb.doc.filename = docs / "stories" / "isole-photos" / "index.html"
nb.useTabelline(title = "Photos of the Mediterranean, by the story", homeHref = "../isole/",
  backLabel = "Islands of the Mediterranean", wordmarkHref = "../../",
  looks = ["munari", "minoan"], firstLook = "minoan")

proc preview(file: string): string =
  ## A photo's preview for `nbImage`, which reads a relative link from the site's root.
  let src = pictureSrc(data / "previews" / file, nb.doc.filename)
  if src.startsWith("data:"): return src
  let page = absolutePath(nb.doc.filename).parentDir
  relativePath(page / src, normalizedPath(page / nb.doc.context{"path_to_root"}.getStr)).replace('\\', '/')

nbTitle "Islands of the Mediterranean", "Photos of the Mediterranean, by the story", md(groups["intro"].getStr)

nbToc

nbText: """
## All the photos

One line per photo, by the section of the story it could go in; ★ marks the one the story shows.
"""

block:
  type Row = object
    place, photo, pick: string
  var rows: seq[Row]
  for i, g in groups["groups"].getElems:
    for ph in g["photos"]:
      rows.add Row(place: $(i + 1) & ". " & g["title"].getStr, photo: ph["name"].getStr,
                   pick: (if ph{"pick"}.getBool: "★" else: ""))
  let t = tabella(rows, groupnameCol = "place"):
    tabHeader "Photos by section", $rows.len & " photos in " & $groups["groups"].len & " groups"
    colsLabel:
      photo: "photo"
      pick: "★"
    optCssTheme()
  nbTable t

for i, g in groups["groups"].getElems:
  let title = $(i + 1) & ". " & g["title"].getStr
  var picked = ""
  for ph in g["photos"]:
    if ph{"pick"}.getBool: picked = ph["name"].getStr
  var file = ""
  for (name, f) in storyFiles:
    if name == picked: file = f
  # the section's heading as the story shows it: over the picked photo
  if file.len > 0:
    nbPhotoHeading title, data / "story" / (file & ".jpg"), picked & ": " & credit(picked), picked
    nbText "*" & md(g["where"].getStr) & "*\n\n" & md(g["note"].getStr)
  else:
    nbText "## " & title & "\n\n*" & md(g["where"].getStr) & "*\n\n" & md(g["note"].getStr)
  nbGallery "the photos of " & g["title"].getStr & ": swipe or scroll sideways":
    for ph in g["photos"]:
      let pick = ph{"pick"}.getBool
      nbGalleryCard((if pick: "★ " else: "") & ph["name"].getStr, (if pick: "in the story" else: "")):
        nbImage preview(ph["file"].getStr), alt = ph["name"].getStr
        nbText credit(ph["name"].getStr) & "\n\n**About.** " & md(ph["about"].getStr) & "\n\n**Why here.** " & md(ph["why"].getStr)

nbText md(groups["outro"].getStr)

nbSave
