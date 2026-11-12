## ADDED Requirements

### Requirement: A table laid out as a picture
`drawing(t, width = 992, vars)` SHALL lay the table out as Chrome lays out `toHtml(t)` in a page
`width` CSS pixels wide, and give a `Drawing`: its `width` and `height` in CSS pixels, its
`background`, and its `marks` (rectangles, lines, letters, nanoplots, images), each placed from
the table's top left corner. The letters SHALL be measured with the fonts tabelline ships (Inter,
and DejaVu Sans Mono for code and nanoplots), with kerning, and with tabular figures where the
HTML asks for them (`font-variant-numeric: tabular-nums`). Lines SHALL break at spaces when the
table is wider than `width`; column widths SHALL follow an automatic table layout (from the
widest word to the longest line of each column, `colsWidth` kept), and borders where cells meet
SHALL collapse, the stronger winning. `vars` SHALL give the values of the page's CSS variables
for a table that reads them (`optCssTheme`).

```nim
let t = tabella(planets(), rownameCol = "planet"):
  colsHide ["type", "diameter", "density", "gravity", "day_length", "distance",
            "orbital_period", "mean_temp", "rings"]
  tabHeader "Moons"
let d = t.drawing
echo d.width.int, " × ", d.height.int
var texts = 0
for m in d.marks:
  if m.kind == mkText: inc texts
echo texts, " pieces of text"
```

```text
203 × 365
27 pieces of text
```

#### Scenario: Close to Chrome
- **WHEN** a table of the docs is laid out by `drawing`, and drawn by Chrome from `toHtml`
- **THEN** the two boxes differ by at most 4 CSS pixels in width and in height

#### Scenario: A narrow page
- **WHEN** a table of long texts is laid out with `width = 380`
- **THEN** its lines break at the words Chrome breaks them at, and the picture is at most 380 pixels wide unless a word is wider

### Requirement: SVG
`toSvg(t, width = 992, text = stFont, vars)` SHALL write the drawing of `t` as a standalone SVG.
With `stFont`, the letters SHALL be text, each with its own x, and the SVG SHALL hold a subset of
each font it uses (only the letters used), so the text can be selected and draws the same in
every browser. With `stPaths`, each letter SHALL be its outline from the font and the SVG SHALL
need no font. Nanoplots SHALL be their own SVG, placed in the cell; images (`fmtImage`) SHALL be
`<image>`.

```nim
let t = tabella(planets()):
  tabHeader "Planets"
let s = t.toSvg
echo s.startsWith("<svg xmlns=\"http://www.w3.org/2000/svg\""), " ", "@font-face" in s, " ", "<text" in s
let p = t.toSvg(text = stPaths)
echo "@font-face" in p, " ", "<text" in p, " ", "<path id=" in p
```

```text
true true true
false false true
```

#### Scenario: An SVG in another program
- **WHEN** an SVG written with `stPaths` is opened in resvg, Inkscape, LibreOffice or PowerPoint
- **THEN** it looks as in a browser, letters included

### Requirement: Saving by the extension
`save(t, path, scale = 2, width = 992)` SHALL write the format the extension of `path` names:
`.html` a standalone page, `.svg` `toSvg(t, width)`, and any extension a writer was added for
with `addWriter(ext, writer, priority)`, the one of highest priority when there are two. An
extension with no writer SHALL raise a `ValueError` that names the module to import.
`hasWriter(ext)` SHALL say whether `save` can write it.

```nim
let t = tabella(planets())
echo hasWriter(".svg"), " ", hasWriter(".png")
try: t.save("planets.png")
except ValueError as e: echo e.msg
```

```text
true false
save: no writer for ".png" files: import tabelline/pixie (or tabelline/chrome)
```

#### Scenario: Two writers for one extension
- **WHEN** both `tabelline/pixie` and `tabelline/chrome` are imported, in any order
- **THEN** `save(t, "t.png")` paints with pixie, and `save(t, "t.pdf")` prints with Chrome

### Requirement: PNG with pixie
`import tabelline/pixie` (an optional module, with pixie as the atlas feature `pixie`) SHALL
paint the drawing of a table into a pixie `Image` with `toImage(t, scale = 2, width = 992)`, give
its PNG bytes with `toPng(t, scale, width)`, and add `.png` to `save`. Letters SHALL be painted
at the places of the layout, tabular figures included. A line nanoplot's hatching SHALL be drawn
as lines; a static nanoplot's values as text.

#### Scenario: The same size as the SVG
- **WHEN** a table is painted with `toImage(t, scale = 2)`
- **THEN** the image is twice the drawing's width and height, rounded up

### Requirement: Pictures through Chrome
`import tabelline/chrome` (an optional module, standard library only) SHALL find a Chrome
(`CHROME_PATH`, then Chrome, Chromium or Edge on the PATH, then the usual places), start it
headless and talk to it over the DevTools protocol. `saveImage(t, path, scale = 2)` SHALL draw
`toHtml(t, makePage = true)` and write a picture of the table's box: `.png`, `.jpg`, `.webp`, or
`.pdf` (one page as big as the table). `startChrome()` SHALL give a `Chrome` that draws many
pictures, `c.saveImage(t, path)`, until `c.close()`. The module SHALL add `.pdf`, `.jpg`, `.jpeg`
and `.webp` to `save`, and `.png` below pixie's priority. Without Chrome, it SHALL raise a
`ChromeError` that says where it looked.

#### Scenario: Many pictures
- **WHEN** one `Chrome` draws ten tables
- **THEN** Chrome starts once, and each picture takes a fraction of a second
