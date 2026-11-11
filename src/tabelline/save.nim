## `save(t, path)`: the table written to a file, in the format its extension names, as gt's
## `gtsave`. `.html` and `.svg` are written by the core; other formats come from optional
## modules that add a writer when they are imported: `tabelline/pixie` adds `.png`,
## `tabelline/chrome` adds `.pdf`, `.jpg` and `.webp` (and `.png` when pixie is not there).

import std/[os, strutils, tables]
import core, render_html, render_svg

type Writer* = proc (t: Tabella, path: string, scale, width: float)
  ## Writes `t` to `path`: `scale` is the number of pixels to a CSS pixel, `width` the width of
  ## the page the table is laid out in.

var writers: Table[string, (Writer, int)]

proc addWriter*(ext: string, writer: Writer, priority = 0) =
  ## Makes `save` write files ending in `ext` (".png") with `writer`. Of two writers for the
  ## same extension, the one with the higher `priority` is kept, whatever the order of imports.
  let e = ext.toLowerAscii
  if e notin writers or writers[e][1] <= priority: writers[e] = (writer, priority)

proc hasWriter*(ext: string): bool =
  ## Whether `save` can write files ending in `ext`.
  ext.toLowerAscii in [".html", ".htm", ".svg"] or ext.toLowerAscii in writers

proc save*(t: Tabella, path: string, scale = 2.0, width = 992.0) =
  ## Writes the table to `path`, in the format of its extension: `.html` a standalone page
  ## (`toHtml(makePage = true)`), `.svg` a picture (`toSvg`), and the formats of the optional
  ## modules imported (`.png` with `tabelline/pixie`; `.pdf`, `.jpg`, `.webp` with
  ## `tabelline/chrome`). `scale` (pixels to a CSS pixel) is for pictures made of pixels;
  ## `width` is the width of the page the table is laid out in, as `toSvg`'s.
  let ext = path.splitFile.ext.toLowerAscii
  case ext
  of ".html", ".htm": writeFile(path, t.toHtml(makePage = true))
  of ".svg": writeFile(path, t.toSvg(width))
  else:
    if ext in writers: writers[ext][0](t, path, scale, width)
    else:
      let hint = case ext
        of ".png": "import tabelline/pixie (or tabelline/chrome)"
        of ".pdf", ".jpg", ".jpeg", ".webp": "import tabelline/chrome"
        else: "use .html or .svg"
      raise newException(ValueError, "save: no writer for \"" & ext & "\" files: " & hint)
