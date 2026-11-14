## How a page of the islands story speaks two languages: included by isole.nim and isole_tutte.nim,
## after `lang` (the page's language), `data` (the folder data/isole/) and `catalog` (the file of
## its translations there).

# ------------------------------------------------------------------------------ in two languages
# The story is written in English, and every text a reader sees goes through `tr`: in the English
# page it is the text itself, in the Italian one its translation, from data/isole/italiano.txt
# (an English text, `en:`, then its Italian, `it:`, or nothing for the same; spaces and line
# breaks do not count). A text
# without one is listed in data/isole/italiano-missing.txt, and the Italian page fails to build.
var italian: Table[string, string]
var missing: seq[string]
var used: HashSet[string]   # the texts looked up, so the ones no longer on the page can be found
proc key(s: string): string = s.splitWhitespace.join(" ")
when lang == "it":
  var (english, translated, side) = ("", "", "")
  proc flush() =
    if english.strip.len > 0:   # an empty translation keeps the English: a name, a number
      italian[key(english)] = if translated.strip.len == 0: english.strip else: translated.strip(chars = {'\n'})
    (english, translated) = ("", "")
  for line in lines(data / catalog):
    if line.startsWith("en:"): (flush(); side = "en"; english = line[3 .. ^1].strip & "\n")
    elif line.startsWith("it:"): (side = "it"; translated = line[3 .. ^1].strip & "\n")
    elif side == "en": english.add line & "\n"
    elif side == "it": translated.add line & "\n"
  flush()

var readings: seq[Source]
  ## The books the story quotes, numbered in this order: a text cites one with `[^key]` where it
  ## first quotes it (`citing`), and "To read more" lists them (`nbSources`).

proc tr(s: string): string =
  ## `s` in the page's language, with its citations.
  when lang == "en": result = s
  else:
    if key(s) in italian: (used.incl key(s); result = italian[key(s)])
    else:
      if s notin missing: missing.add s
      result = s
  if "[^" in result: result = citing(result, readings)

