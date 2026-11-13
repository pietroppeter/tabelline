## devlog: 13 Nov 2026 A | Toward a dark tabelline | tabelline's tables are white and its pages are light, so a reader who asks for dark gets a guess from the browser or an extension. Is it white or light? How a reader asks for dark, and how Dark Reader decides that a page is dark already; what a dark tabelline has to change; three ways to build it; and nine sources to draw from, from the Matrix to the Bloomberg Terminal, each with a table in its colours.
## A dated post: research for a dark look (BACKLOG "A dark look"), with options to choose from; it is not rewritten afterwards.
import std/[os, strutils]
import nimib
import tabelline, tabelline/[nimib, datasets]
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
let shots = currentSourcePath().parentDir / "data" / "dark"
nbInit
nb.doc.filename = docs / "devlog" / "dark" / "index.html"
nb.useTabelline(title = "Toward a dark tabelline", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../",
                nights = [("munari", "munari-notte"), ("quaderno", "terminale")], textTables = true)

nbTitle "13 November 2026", "Toward a dark tabelline", """
tabelline's tables are white and its pages are light, so a reader who asks for dark gets a guess
from the browser or an extension. What we have, how a reader asks for dark, what a dark tabelline
has to change, three ways to build it, and nine sources to draw from. Research, not yet a design.
"""

nbToc

nbText: """
Pietro: "this is not as easy as it sounds, I think natively tabelline work in white mode (is it
white? or light? mmh). This is important for those who use a dark reader that automatically tries
to fit a dark mode", as Hugo, nimib's co-maintainer, does. "I guess if we have a dark mode and mark
it as such it should pick it up." And: "maybe the dark theme could be more sci fi related".

This post answers the first question, checks the guess, and lays out the options. It is lighter
than [the Mediterranean look](../mediterranean/): no rounds yet, and no tournament.

## White or light?

Both, in two places. tabelline's own defaults are gt's: a white table with dark grey text and light
grey rules (the table below has their values). A table that takes `optCssTheme()` takes the page's colours
instead, and the pages are light, not white: Haru's white silk, a warm off-white, under sumi ink.
"""

type Ground = object
  where, paper, ink: string
  contrast, lightness: float

func srgbLightness(hex: string): float =
  ## Dark Reader's measure of a colour (`getSRGBLightness`): 0 is black, 1 white.
  let c = parseColor(hex)
  (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) / 255

let grounds = block:
  var rows: seq[Ground]
  for (where, paper, ink) in [("tabelline's defaults (gt's)", TabOptions().tableBackgroundColor, TabOptions().tableFontColor),
                              ("Munari, palette Haru", haru.paper, haru.ink),
                              ("the quaderno", quadernoLook.paper, quadernoLook.ink),
                              ("the Minoan look", minoanLook.paper, minoanLook.ink),
                              ("the book, palette Edo", edo.paper, edo.ink)]:
    rows.add Ground(where: where, paper: paper, ink: ink,
                    contrast: contrast(parseColor(ink), parseColor(paper)), lightness: srgbLightness(paper))
  rows

var groundsTable = tabella(grounds, rownameCol = "where"):
  tabHeader "Every ground we have is light", "the paper and the ink of each, and how light the paper is"
  colsLabel:
    paper: "paper"
    ink: "ink"
    contrast: "ink on paper"
    lightness: "lightness"
  fmtNumber "contrast", decimals = 1, pattern = "{x}:1"
  fmtNumber "lightness", decimals = 2
  tabSourceNote "Lightness as Dark Reader measures it (0 black, 1 white): it takes a page whose background is over 0.6 for a light one."
  optCssTheme()
for i, g in grounds:
  groundsTable = groundsTable.tabStyle(style.fill(g.paper) & style.text(color = g.ink), loc.body(cols = "paper", rows = [i]))
  groundsTable = groundsTable.tabStyle(style.fill(g.ink) & style.text(color = g.paper), loc.body(cols = "ink", rows = [i]))
nbTable groundsTable

nbText: """
So the guess is right on both counts: everything is light, and nothing tells a browser that a dark
version exists. Nothing on the site sets `color-scheme` or reads `prefers-color-scheme` today.

## How a reader asks for dark

Five ways, from the simplest:

1. **The system's setting.** A reader who picks dark in the system (or the browser) gets
   `prefers-color-scheme: dark`, a media query the page can read in its CSS. A page that does
   not read it stays light.
2. **`color-scheme`.** A CSS property (or `<meta name="color-scheme" content="light dark">` in the
   head) that tells the browser which schemes the page draws itself in. The browser then draws
   its own parts to match: the page's default background, scrollbars, form controls. It is also
   how a page opts out of the browser's automatic darkening: `only light` says "never darken me"
   ([Chrome's post on Auto Dark Theme](https://developer.chrome.com/blog/auto-dark-theme)).
3. **The browser darkens the page itself.** Chrome on Android has *Auto-darken web pages*
   (desktop Chrome has it behind a flag): an algorithm recolours a light page. It works on
   pages that do not say they have a dark scheme.
4. **An extension.** [Dark Reader](https://github.com/darkreader/darkreader) is the best known: it
   rewrites a page's CSS to dark, page after page, unless it decides the page is dark already
   (below).
5. **The page's own switch.** Our header already has one, Munari or quaderno; a dark look could
   be a third button, or a light and dark switch of its own.

### How Dark Reader decides a page is dark already

Read in its source (`src/inject/detector.ts`, main at 12 November 2026). Its setting *Detect dark
theme* is on by default, and then it steps aside on a page it finds dark. In this order:

1. A `<meta name="color-scheme">` that says exactly `dark` or `only dark`: dark. Exactly
   `light` or `only light`: light, and Dark Reader darkens it. Anything else (`light dark`)
   goes on to the next checks.
2. A class `dark` on `<html>` or `<body>`, or `data-theme="dark"` on `<html>`: dark. (Our
   switch writes `data-tema`, which it does not read.)
3. The page as drawn: if the root's computed `color-scheme` is `dark`, the page is dark;
   otherwise it samples up to sixteen points of the window, and any background lighter than 0.6
   makes the page light; at the end, the root and the body must be darker than 0.5.

A page can also tell it to stand down with `<meta name="darkreader-lock">`. Not for us while the
pages are light: Hugo would lose his dark.

So Pietro's guess holds, with one detail: *marking* the dark look is not enough, it has to be on.
A dark look that sets `color-scheme: dark` on `<html>` when it is shown passes check 3 at once.
A reader whose system is dark gets it through `prefers-color-scheme`, and Dark Reader steps aside;
a reader whose system is light but who runs Dark Reader everywhere still gets Dark Reader's
version, unless they pick dark in our switch once (the choice is remembered).

### What a reader with a dark setting sees today

The guide's first screen and its sixth step, as they are, with Chrome's auto-darkening and with
Dark Reader (its engine, from the npm package `darkreader` 4.9.135, at its default settings). Both
do well on text and on the table. Chrome's loses which look is on in the switch; Dark Reader turns
code blocks into pale grey with pale text, and keeps the warm paper as a brown cast.
"""

nbScreenshot shots / "top-three.jpg", shots / "top-three.json", "The guide's first screen: as it is, with Chrome's auto-darkening, with Dark Reader"
nbScreenshot shots / "step6-three.jpg", shots / "step6-three.json", "Step 6 of the guide: a code block and a table with optCssTheme(), the same three ways"

nbText: """
## What a dark tabelline has to change

Every colour of the pages is mixed from six values, so the first experiment is the simplest: swap
the paper and the ink of Munari. Most of the page follows. Three things show that they were made
for a light page: code blocks turn grey (the same as Dark Reader's), because the sheet they sit on,
`--surface`, is the paper mixed with white; the middle of the temperature scale glows; and the
Munari logo keeps its light colours, which is right.
"""

nbScreenshot shots / "swap-two.jpg", shots / "swap-two.json", "Munari with paper and ink swapped: the first screen and step 6"

type Piece = object
  piece, today, dark, size: string

nbTable tabella(@[
  Piece(piece: "Page tokens (neutrals, soft and text colours)", today: "mixed from paper and ink in the browser",
        dark: "follow by themselves", size: "—"),
  Piece(piece: "`--surface`, the sheet of code blocks and cards", today: "white mixed into the paper",
        dark: "a little ink in the paper, lighter than it (done in this post: `Look.dark`)", size: "S"),
  Piece(piece: "Tables with `optCssTheme()`", today: "take the page's tokens",
        dark: "follow by themselves", size: "—"),
  Piece(piece: "Tables without it", today: "gt's white and greys, fixed",
        dark: "stay white: see *For the library* below", size: "S–M"),
  Piece(piece: "`dataColor` scales", today: "fixed palettes (`blues` starts almost white)",
        dark: "the light end glows; a scale from the look's own colours", size: "S"),
  Piece(piece: "Nanoplots", today: "fixed colours, white strokes, light grey axis boxes",
        dark: "colours from the tokens", size: "S"),
  Piece(piece: "Parts of a table (the guide's tints)", today: "seven fixed pastels",
        dark: "a dark twin of each", size: "S"),
  Piece(piece: "Photos and screenshots", today: "as taken", dark: "a little dimmer, maybe", size: "S"),
  Piece(piece: "Code highlighting, diagrams, review mode", today: "from the tokens",
        dark: "check each on a dark paper", size: "S")]):
  tabHeader "What a dark look touches", "from what follows by itself to what has to change"
  colsLabel:
    piece: "piece"
    today: "today"
    dark: "in a dark look"
    size: "size"
  fmtMarkdown everything()
  optCssTheme()

nbText: """
## Three ways to build it

**A. A night palette for Munari.** Six values, Munari's rules, a dark button in the switch. The
smallest step: the swap above, with `--surface` fixed and colour scales from the palette. Yoru
(night), below, is the obvious candidate: Haru's four colours on a deep indigo.

**B. A dark look of its own.** As the Minoan look was made for the islands: a source, its
typefaces, its motifs, for one page or the whole site. The sci-fi sources below are this kind:
a terminal look with a monospace, a Matrix look, a Blade Runner look. The most design, for one look.

**C. A dark twin of every look.** Dark becomes a mode, not a look: Munari at night, the quaderno
as a blackboard (*la lavagna*, chalk on slate), the Minoan look as a red-figure vase (terracotta
figures on black glaze). The page follows `prefers-color-scheme` until the reader picks, and the
switch has two parts: which look, light or dark. The most work, and the only way that answers
"dark mode" everywhere.

The three are steps of one road. A first is C's machinery (the media query, `color-scheme`, a
remembered switch) with A's palette; the twins of the other looks, and a sci-fi look if we want
one, come later.

### For the library

A table that takes `optCssTheme()` already follows any palette, dark ones too (the gallery below
is made of such tables). What is left is for tables that don't:

- **Nothing.** gt's defaults are white, and so are Great Tables'; neither has a dark option as
  far as I found (`opt_stylize`'s six styles are all light). A page that wants dark tables uses
  `optCssTheme()`.
- **Defaults that follow the page.** CSS's `light-dark()` picks one of two colours by the
  element's `color-scheme`, so every default colour could be written as `light-dark(` the light
  value, a dark one `)`. A plain table would be dark on a dark page, with no option set. A
  difference from gt, for the *Not from gt* table.
- **A colour scale from the page.** `dataColor` mixes its palette at build time, from hex values,
  so it cannot take a token today. A palette named by tokens (`"--secondary"`, `"--paper"`,
  `"--primary"`), mixed by the browser with `color-mix()`, would follow any look. This is the gap
  that shows first.

## From a source to six dark colours

The rules of the Mediterranean look, turned for a dark paper:

1. The paper is dark: under 0.15 in Dark Reader's lightness, well under its 0.5.
2. The paper is not pure black: a sheet set above it must be able to be lighter, and pure black
   next to light text smears on many phone screens.
3. The ink is at least 10:1 on the paper, and at most 17:1: pure white on near-black glares.
4. Primary, secondary and success are at least 3:1 on the paper, so a shape in them is seen.
5. The secondary is at least 60° of hue from the primary; the warning is a yellow (35°–60°),
   the success a green (80°–170°), as in every look.

The colours are picked by eye from each source, or taken from the design system's published
values; *added* marks a role the source has no colour for. The table that checks them is folded
at the end of the sources.

## Where to find excellent dark tables

Nine sources, from the nearest to the farthest from Munari: a night for our own palette, three
screens from films and television, two kinds of screens that people read tables on for hours, and three design systems that
wrote their dark rules down. Each card has the same small table in its colours (a table with
`optCssTheme()`, its temperature scale from the palette's secondary, paper and primary). Its
button paints this whole page in the palette, every element, until you press it again or reload.
"""

proc planetsIn(key: string): Tabella =
  let l = darkLook(key)
  tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    tabHeader "The planets", "mean temperature"
    colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "rings"]
    colsLabel:
      moons: "moons"
      mean_temp: "°C"
    dataColor "mean_temp", palette = @[l.secondary, l.paper, l.primary], domain = (-200.0, 200.0)
    optCssTheme()

template sourceCard(key, short, heading, era, text, links: string) =
  nbGalleryCard(heading, era):
    nbText text
    nbSwatches darkSwatches(key)
    nbTryPalette key, short, darkLook(key)
    nbInPalette key, darkLook(key):
      nbText heading
      nbTable planetsIn(key)
    nbText links

nbGallery "nine sources for a dark look":
  sourceCard("yoru", "Yoru", "Yoru: Munari at night", "Japanese colour names", """
**Who.** The same traditional Japanese colour names that gave Munari its palette, Haru (spring),
as collected on [nipponcolors.com](https://nipponcolors.com/).

**What.** Yoru (night) keeps Haru's four colours, red plum, forget-me-not, rapeseed and seedling,
and puts them on 濃藍 koai, the deepest of the indigo dyes, under white silk.

**Why it fits.** The smallest step: the same site, the same shapes and colours, after dark.

**For a page.** Way A as it stands: Munari's rules with six new values.
""", """[Munari meets Japan](../palettes/) · [nipponcolors.com](https://nipponcolors.com/)""")

  sourceCard("matrix", "the Matrix", "The Matrix", "1999", """
**Who.** The Wachowskis' film; its falling code was designed by Simon Whiteley, who has said the
glyphs came from Japanese cookbooks.

**What.** The *digital rain*: columns of green glyphs falling on black, the brightest at the head
of each string, fading behind it. One hue in every step of lightness; the only other colours in
the story are two pills.

**Why it fits.** The picture of data on a dark screen that everyone knows, and a column of
characters is already half a table.

**For a page.** Green on black, a monospace for figures, the brightest step for what changed or
matters (the head of the string), and one other colour, the blue pill, for links. One hue cannot
fill six roles: the warning is added.
""", """[Matrix digital rain](https://en.wikipedia.org/wiki/Matrix_digital_rain)""")

  sourceCard("androids", "Blade Runner", "Electric sheep and Blade Runner", "1968–2017", """
**Who.** Philip K. Dick's novel *Do Androids Dream of Electric Sheep?* (1968), Ridley Scott's
*Blade Runner* (1982) made from it, and Denis Villeneuve's *Blade Runner 2049* (2017), shot by
Roger Deakins.

**What.** The novel is full of things that are tables: the Penfield mood organ, where a number
dialled gives a mood, and the Voight-Kampff test, questions against measured reactions. The films
are the night city in rain and neon, and in 2049 a Las Vegas lost in orange haze.

**Why it fits.** Pietro's own pick of the sci-fi, and the source of the most copied palette of
the genre: orange against teal, warm light in a cold night.

**For a page.** A warm ink on a cold ground, sodium orange for the circle, neon cyan for the
square; a table read like the Voight-Kampff screen. (The *Electric Sheep* screensaver, Scott
Draves's fractal flames glowing on black, is named after the novel.)
""", """[The novel](https://en.wikipedia.org/wiki/Do_Androids_Dream_of_Electric_Sheep%3F) ·
[Blade Runner](https://en.wikipedia.org/wiki/Blade_Runner) ·
[Blade Runner 2049](https://en.wikipedia.org/wiki/Blade_Runner_2049) ·
[Electric Sheep](https://en.wikipedia.org/wiki/Electric_Sheep)""")

  sourceCard("phosphor", "phosphor", "Phosphor terminals", "1970s–1980s", """
**Who.** The video terminals that tables were first read on, after paper: green and amber
monochrome screens (the P1 and P3 phosphors), DEC's VT100 (1978), the IBM PC's colour adapter and
its sixteen colours, and the films that showed them, from *Alien*'s Nostromo to *WarGames*.

**What.** One light ink glowing on dark glass, characters in a grid, colour (when there was any)
only for status: the bright red, cyan, yellow and green of the PC's sixteen.

**Why it fits.** On screens, the dark table is older than the light one.

**For a page.** Amber ink, a monospace that aligns every figure, colour only where it says
something. Long text in amber is heavy: for tables and code, not for prose.
""", """[Monochrome monitor](https://en.wikipedia.org/wiki/Monochrome_monitor) ·
[VT100](https://en.wikipedia.org/wiki/VT100) ·
[Color Graphics Adapter](https://en.wikipedia.org/wiki/Color_Graphics_Adapter)""")

  sourceCard("lcars", "LCARS", "LCARS", "1987", """
**Who.** Michael Okuda, who designed the computer screens of *Star Trek: The Next Generation*.

**What.** LCARS: black screens framed by rounded bars and elbows in orange, peach and lilac, with
labels in tall capitals and panels of data between them. The colours here are fans'
reconstructions, not the studio's values.

**Why it fits.** A sci-fi interface made almost only of labels, figures and frames: a table
dressed for a starship.

**For a page.** Colour on the frame, not on the figures: spanners, row-group bars and the stub
as coloured bars, the cells left plain. Pure black fails rule 2.
""", """[LCARS](https://en.wikipedia.org/wiki/LCARS) ·
[Michael Okuda](https://en.wikipedia.org/wiki/Michael_Okuda)""")

  sourceCard("bloomberg", "Bloomberg", "The Bloomberg Terminal", "since 1982", """
**Who.** Bloomberg L.P.'s terminal, on the desks of traders since 1982.

**What.** Black screens dense with figures: amber labels, white values, green for up and red for
down, a yellow for what needs attention now. The colours here are by eye from public pictures.

**Why it fits.** The dark table that people read for hours every day, with money on it: dense,
and every colour has a job.

**For a page.** Density, amber for labels and white for figures, colour only for direction. A
good test of tabelline's compact options. Pure black fails rule 2.
""", """[Bloomberg Terminal](https://en.wikipedia.org/wiki/Bloomberg_Terminal)""")

  sourceCard("solarized", "Solarized", "Solarized", "2011", """
**Who.** Ethan Schoonover, a designer, for terminals and code editors.

**What.** Sixteen colours picked in CIELAB so that the same eight accents work on a dark ground
and on a light one; the dark ground is base03, a deep blue-green.

**Why it fits.** It answers our question as a design: one palette, two grounds. Its ink is softer
than our rule on purpose (about 6:1), for long hours of reading.

**For a page.** Way C in one palette: the accents shared by the light and the dark twin, only the
grounds swapped.
""", """[Solarized](https://ethanschoonover.com/solarized/)""")

  sourceCard("primer", "Primer", "GitHub's dark themes", "since 2020", """
**Who.** GitHub's design system, Primer, which brought dark mode to github.com in December 2020
and has added dimmed and high-contrast versions since.

**What.** A blue-black canvas, not black; borders instead of shadows; the same roles (accent,
success, attention, danger) in a lighter tone for the dark ground. The values here are Primer's
published ones.

**Why it fits.** The dark tables most programmers read: Markdown tables and diffs, on the site
where tabelline lives.

**For a page.** Several dark versions for several eyes (dimmed, high contrast), and the roles
kept, only their tones moved.
""", """[Primer](https://primer.style/)""")

  sourceCard("material", "Material", "Material's dark theme", "2019", """
**Who.** Google's Material Design, whose guide added a dark theme in 2019.

**What.** The clearest written rules for dark screens: a surface of very dark grey, not black; higher
surfaces lighter, by a veil of white; text in white at 87%, 60% and 38% for its levels; accents in
lighter, less saturated tones (the 200s). It has no warning or success colour: those are added
from Material's own palette.

**Why it fits.** Its surfaces gave this post the fix for `--surface`: on a dark paper, a sheet set
above it is lighter, not whiter.

**For a page.** The rules more than the colours.
""", """[Material Design: dark theme](https://m2.material.io/design/color/dark-theme.html)""")

type DarkCheck = object
  source, role, colour, swatch: string
  contrast, hue: float
  verdict: string

func hueOf(c: Rgb): float =
  let (r, g, b) = (c.r / 255, c.g / 255, c.b / 255)
  let (hi, lo) = (max(r, max(g, b)), min(r, min(g, b)))
  if hi == lo: return 0.0
  let d = hi - lo
  result = (if hi == r: (g - b) / d elif hi == g: (b - r) / d + 2 else: (r - g) / d + 4) * 60
  if result < 0: result += 360

func hueGap(a, b: float): float = min(abs(a - b), 360 - abs(a - b))

let checks = block:
  var rows: seq[DarkCheck]
  for (key, colours) in darkSources:
    let paper = parseColor(colours[0].hex)
    var why: seq[string]
    if srgbLightness(colours[0].hex) >= 0.15: why.add "not dark enough"
    if luminance(paper) == 0: why.add "pure black"
    rows.add DarkCheck(source: key, role: "paper", colour: colours[0].name, contrast: NaN,
                       hue: srgbLightness(colours[0].hex), verdict: (if why.len == 0: "✓" else: why.join(", ")))
    for k in 1 .. 5:
      let x = colours[k]
      let c = parseColor(x.hex)
      let (ratio, h) = (contrast(c, paper), hueOf(c))
      why = @[]
      case x.role
      of "ink":
        if ratio < 10: why.add "under 10:1"
        if ratio > 17: why.add "over 17:1"
      of "primary", "secondary", "success":
        if ratio < 3: why.add "under 3:1"
      else: discard
      if x.role == "secondary" and hueGap(h, hueOf(parseColor(colours[2].hex))) < 60: why.add "too close to primary"
      if x.role == "warning" and (h < 35 or h > 60): why.add "not a yellow"
      if x.role == "success" and (h < 80 or h > 170): why.add "not a green"
      rows.add DarkCheck(source: key, role: x.role, colour: x.name & (if x.added: " (added)" else: ""),
                         contrast: ratio, hue: h, verdict: (if why.len == 0: "✓" else: why.join(", ")))
  rows

var checkTable = tabella(checks, groupnameCol = "source"):
  tabHeader "Every colour, checked", "the rules above, on the six colours of each source"
  colsLabel:
    role: ""
    swatch: ""
    contrast: "on paper"
    hue: "hue"
    verdict: "rules"
  fmtNumber "contrast", decimals = 1, pattern = "{x}:1"
  fmtNumber "hue", decimals = 0, pattern = "{x}°"
  subMissing "contrast", missingText = ""
  colsWidth:
    swatch: "1.6em"
  tabSourceNote "Contrast after WCAG 2; hue in degrees, red at 0°, yellow at 60°, green at 120°, blue at 240°. For the paper, the hue column holds its lightness (Dark Reader's measure, 0 to 1)."
  optCssTheme()
for i, r in checks:
  checkTable = checkTable.tabStyle(style.fill(darkColours(r.source)[["paper", "ink", "primary", "secondary", "warning", "success"].find(r.role)].hex),
                                   loc.body(cols = "swatch", rows = [i]))
nbFold "Every colour of every source, checked":
  nbTable checkTable

nbText: """
## What to decide

The questions of round 1, and Pietro's answers (13 November, round 2):

1. **The way**: A (a night palette for Munari), B (a dark look of its own) or C (a dark twin of
   every look). *Answer:* C, a *giorno* / *notte* switch.
2. **The source**, for the first dark palette. *Answer:* at night Munari becomes Munari notte, and
   the quaderno, the playful look of the day, becomes a retro terminal, after the Matrix and Blade
   Runner, called Terminal.
3. **The switch**: a third button beside Munari and quaderno, or a light and dark switch of its
   own. *Answer:* a switch of its own.
4. **The library**: nothing, defaults with `light-dark()`, and a `dataColor` palette named by
   tokens. Still open; my pick is the token palette first, it is the gap that shows.

Two sources I could not read from here, because the sandbox's network does not reach them:
ProPublica's design guide on dark mode, and Datawrapper's notes on its automatic dark mode for
embedded charts (it recolours a chart by contrast when the page is dark, and a custom theme can give
a dark twin for each colour of its palette). Both are worth a look before the design.

## Giorno and notte

This page has the switch, in its header: **☀ giorno** and **☾ notte**, beside the look. Until
you press it, it follows your system (`prefers-color-scheme`); then it remembers. At night:

- **Munari notte** is Munari with six night values, Yoru's: Haru's four colours on 濃藍 koai,
  deep indigo, under white silk. Every rule is Munari's; the only token that changes how it is
  made is `--surface`, lighter than the paper instead of whiter.
- **Terminal** is the quaderno's night, and the switch calls it so at night: a monitor's dark glass, green phosphor for the text,
  Blade Runner's sodium orange for the circle and links, neon cyan for the square, the Matrix's
  code-rain green for what works. One monospace for everything, headings in capitals with a
  faint glow, scan lines over the page, a cursor after the wordmark. And **every table is shown
  as text**, as `echo t` prints it (`toText`), in box-drawing characters; the cards' sample
  tables above stay in colour, they are there to show a palette.

Both set `color-scheme: dark`, so a browser draws its own parts dark, and Dark Reader sees a dark
page and steps aside.

For now only this page has it: `useTabelline(nights = ..., textTables = true)`. A site-wide
switch needs the night looks of the other looks (the Minoan one has none yet), a check of every
page and block at night, and the text tables on by default (every table is written twice, so
pages grow; a terminal page could write only the text).

## A page to try them on

The blocks and tables of the other pages, borrowed to see what the night does to a page that is
not about the night. Switch between the four (giorno and notte, Munari and quaderno) and scroll.

### The guide's planets

From [the guide](../../explainer/): a spanner, a colour scale and summary rows, with its code.
"""

nbCode:
  let planetsTable = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
    tabHeader md("The **planets** of the Solar System"), "from the smallest orbit to the largest"
    colsHide ["density", "gravity", "day_length", "rings", "orbital_period"]
    tabSpanner "Size", ["mass", "diameter"]
    fmtNumber "mass", decimals = 3, dropTrailingZeros = true
    dataColor "mean_temp", palette = palette("rdbu"), domain = (-200.0, 200.0)
    summaryRows fns = {"total": agg.sum}, columns = ["mass", "moons"], missingText = ""
    optCssTheme()
nbTable planetsTable

nbNote("""
A note about the code, the green card, as the guide puts one under each table: `dataColor` takes
a fixed palette, `rdbu`, so at night its pale middle still glows.
""", nkCode)

nbText: """
### Formats, icons and a nanoplot

gt's `exibble`, one format per column, and the guide's warm planets with icons and bars:
"""

nbTable exibble(), rownameCol = "row", groupnameCol = "group":
  tabHeader "Formats on exibble", "one column, one format; missing values shown as —"
  fmtScientific "num", decimals = 2
  fmtCurrency "currency", currency = "EUR"
  fmtDate "date", dateStyle = "day_month_year"
  subMissing everything(), missingText = "—"
  colsHide ["fctr", "time", "datetime", "char"]
  optCssTheme()

nbTable planets(), rownameCol = "planet":
  colsAdd "kind", proc (r: Row): Value =
    toValue(case r["type"].s
      of "Terrestrial": "mountain"
      of "Gas giant": "cloud"
      else: "snowflake")
  colsHide ["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "rings"]
  fmtIcon "kind"
  fmtNanoplot "mean_temp", plotType = "bar",
    options = nanoplotOptions(dataBarFillColor = "var(--primary)", dataBarStrokeColor = "var(--primary)",
                              dataBarNegativeFillColor = "var(--secondary)", dataBarNegativeStrokeColor = "var(--secondary)")
  colsLabel:
    mean_temp: "mean temperature, °C"
  optCssTheme()

nbText: """
### Islands, side by side

The five largest islands of the Mediterranean, from [the islands story](../../stories/isole/),
in two small tables beside each other:
"""

let lastIsland = isole().nrows - 1
nbBeside:
  nbTable isole(), rownameCol = "island":
    tabHeader "Largest", "area, km²"
    rowsHide 5 .. lastIsland
    colsHide ["population", "city"]
    fmtNumber "area", decimals = 0
    optCssTheme()
  nbTable isole(), rownameCol = "island":
    tabHeader "Who lives there", "and the largest city"
    rowsHide 5 .. lastIsland
    colsHide ["area", "country"]
    fmtNumber "population", decimals = 0
    optCssTheme()

nbText: """
### Code, its output, and three languages

A code block and what it prints: here a table printed with `echo`, the same text the terminal
shows in place of every table.
"""

nbCode:
  let moons = tableData:
    planet: ["Earth", "Mars", "Jupiter"]
    moons: [1, 2, 95]
  let moonsTable = tabella(moons, rownameCol = "planet"):
    tabHeader "Moons"
  echo moonsTable

nbTabs(python = """
import polars as pl
from great_tables import GT

moons = pl.DataFrame({"planet": ["Earth", "Mars", "Jupiter"], "moons": [1, 2, 95]})
GT(moons, rowname_col="planet").tab_header("Moons")""", r = """
library(gt)

moons <- data.frame(planet = c("Earth", "Mars", "Jupiter"), moons = c(1, 2, 95))
moons |> gt(rowname_col = "planet") |> tab_header("Moons")"""):
  nbCode:
    nbTable moonsTable  # the same table, shown

nbText: """
### The parts of a table

From [the design guide](../../design/): a table, and a switch that shows its parts in their
colours (the seven tints are fixed pastels, one of the things to give a night twin).
"""

let partsTable = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  tabHeader "Planets", "a few columns"
  colsHide ["mass", "density", "gravity", "day_length", "distance", "orbital_period", "rings", "mean_temp"]
  tabSourceNote "NASA Planetary Fact Sheet"
nbParts partsTable

nbText: """
### Notes, cards and swatches

Every kind of note:
"""

nbNote("A plain note: an aside.")
nbNote("An information note: a page to go to, such as [the roadmap](../../roadmap/).", nkInfo)
nbNote("What is done: the switch works on this page.", nkDone)
nbNote("What is missing: the Minoan look has no night yet.", nkMissing)
nbNote("A warning: the text tables double the size of every table on the page.", nkWarning)

nbCards "Pages to go to":
  nbCard("The guide", "../../explainer/", "1"):
    nbText "Great tables, for Nim, from zero."
  nbCard("The design guide", "../../design/", "2"):
    nbText "Tokens, shapes and blocks."

nbSwatches [("--paper", "paper", "the ground"), ("--ink", "ink", "text"), ("--primary", "primary", "the circle, links"),
            ("--secondary", "secondary", "the square"), ("--warning", "warning", "the triangle"),
            ("--success", "success", "what works")]

nbText: """
And plain Markdown: a list, a quote and a small table.

- a list item with **bold**, *italic* and `code`
- a [link](../../)

> "Complicare è facile, semplificare è difficile." Bruno Munari

| look | at night |
|---|---|
| Munari | Munari notte |
| quaderno | Terminal |

## How this post is built

The switch is `useTabelline(nights = [("munari", "munari-notte"), ("quaderno", "terminale")])`
(`docs/blocks.nim`): a script in the head reads the time of day (`?ora=`, then the last choice,
then `prefers-color-scheme`) before the page is drawn, and sets `data-tema` to the night look of
the chosen one, keeping the choice in `data-look`. The two night looks are `munariNotte` and
`terminale` in `docs/theme.nim`: their six values, every token mixed from them, and for the
terminal its own rules. `textTables = true` makes tabelline's nimib module write every table twice,
its HTML and its `toText` (`tableHtml` in `src/tabelline/nimib.nim`), and only the terminal shows
the text.


The candidates are `darkSources` in `docs/theme.nim`, beside the Mediterranean ones; `darkLook`
turns one into a `Look` with `dark = true`. A dark look changes one token: its `--surface` is the
paper with 7% of the ink, lighter than the paper, instead of the paper with white, and its CSS
sets `color-scheme: dark`. The tables of the cards are drawn by `nbInPalette` (`docs/blocks.nim`),
which writes a look's six values and every token mixed from them on one element, so a table with
`optCssTheme()` inside takes them; its CSS class is in `theme.nim`.

The screenshots were taken at 390px with Chromium, as the guide is built: as it is; with
`--blink-settings=forceDarkModeEnabled=true` (Chrome's auto-darkening); with Dark Reader's engine
from its npm package, `DarkReader.enable()` with the extension's default settings; and with Haru's
paper and ink swapped by one CSS rule.
"""

nbSave
