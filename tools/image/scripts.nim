## How far pixie's text goes: one table with the name of a city in eleven scripts, drawn with
## Inter alone, then with fallback fonts of the system (DejaVu Sans, FreeSerif, WenQuanYi Zen Hei,
## Noto Color Emoji), beside Chrome's picture of the HTML. `nim r tools/image/scripts.nim [outdir]`
import std/os
import pkg/pixie
import tabelline, tabelline/pixie

proc scriptsTable*(): Tabella =
  let cities = tableData:
    script: ["Latin, accents", "Greek", "Cyrillic", "Arabic", "Hebrew", "Devanagari", "Chinese",
             "Japanese", "Korean", "Thai", "Emoji"]
    city: ["Città di Ålesund, Straße", "Αθήνα", "Москва", "القاهرة", "ירושלים", "दिल्ली", "北京",
           "東京", "서울", "กรุงเทพมหานคร", "🏝️ 🇮🇹 ☀"]
    note: ["Latin-1 and Extended", "polytonic not tried", "", "joins, right to left", "right to left",
           "conjuncts, vowel signs", "", "", "Hangul syllables", "no spaces between words", "colour font"]
  tabella(cities, rownameCol = "script"):
    tabHeader "One city, eleven scripts"

when isMainModule:
  let dir = if paramCount() > 0: paramStr(1) else: "build/image"
  createDir dir
  let t = scriptsTable()
  t.save(dir / "scripts.html")
  t.savePng(dir / "scripts-pixie.png")
  var fallbacks: seq[Typeface]
  for f in ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/truetype/freefont/FreeSerif.ttf",
            "/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf"]:
    if fileExists(f):
      try: fallbacks.add readTypeface(f)
      except CatchableError as e: echo f, ": ", e.msg
  const cjk = "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc"
  if fileExists(cjk):
    try: fallbacks.add readTypefaces(cjk)[0]
    except CatchableError as e: echo cjk, ": ", e.msg
  t.savePng(dir / "scripts-pixie-fallbacks.png", fonts = pictureFonts().withFallbacks(fallbacks))
