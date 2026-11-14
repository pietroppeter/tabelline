## Make a preview copy of the built pages, for a claude.ai artifact.
##
##   nim r tools/preview.nim [out]      (default out: ../tabelline-preview)
##
## Run it after `nim r -d:release docs/all.nim`. An artifact serves files but not directories, so
## every relative link to a folder (`../roadmap/`) is rewritten to its index.html. The home page
## also gets a small router: a link to the artifact ending in `#<page>` opens that page, where
## <page> is the page's folder with `/` as `-`: `#devlog-three-threads`, `#roadmap`, `#coverage`.
## Artifacts pass only a plain `#name` to the page, so this is the one form a deep link can take.
## The router is added to the preview only, not to the site.
##
## The files the pages share (`docs/assets/`: site.css, the fonts, review.js) are copied too, and
## the pictures beside a page (`pictures/`). The
## book (docs/book/, built by `nim r book/bookbuild.nim`) is copied with the assets its pages use;
## a page of the book is `#book-` and its path with `/` as `-`, without `.html`: `#book` (its first
## page), `#book-get-started-intro`, `#book-gaps`.
## (A port of tools/preview.py, which it replaces.)

import std/[os, nre, strutils, algorithm, sequtils]

let
  docs = currentSourcePath().parentDir.parentDir / "docs"
  output = if paramCount() >= 1: paramStr(1).absolutePath else: docs.parentDir.parentDir / "tabelline-preview"
  book = docs / "book"

proc parts(rel: string): seq[string] = rel.split('/')

var pages: seq[string]
for f in walkDirRec(docs, relative = true):
  let rel = f.replace('\\', '/')
  if rel.extractFilename == "index.html" and "assets" notin rel.parts:
    pages.add rel
pages.sort
if dirExists(book):
  var bookPages: seq[string]
  for f in walkDirRec(book, relative = true):
    let rel = "book/" & f.replace('\\', '/')
    if rel.endsWith(".html") and rel.extractFilename != "index.html": bookPages.add rel
  pages.add bookPages.sorted
if dirExists(output): removeDir(output)

proc route(rel: string): string =
  if rel.extractFilename == "index.html":
    (if rel == "index.html": "." else: rel.parentDir).replace("/", "-")
  else:
    rel.changeFileExt("").replace("/", "-")

proc writeTo(rel, content: string) =
  let dest = output / rel
  createDir dest.parentDir
  writeFile dest, content

let
  folderLink = re"""href="((?!https?:|#|mailto:|data:)[^"?#]*/)([?#][^"]*)?""""
  dotLink = re"""href="(\.\.?)([?#][^"]*)?""""
for rel in pages:
  var s = readFile(docs / rel)
  s = s.replace(folderLink, proc (m: RegexMatch): string =
    "href=\"" & m.captures[0] & "index.html" & (if 1 in m.captures: m.captures[1] else: "") & "\"")
  s = s.replace(dotLink, proc (m: RegexMatch): string =
    "href=\"" & m.captures[0] & "/index.html" & (if 1 in m.captures: m.captures[1] else: "") & "\"")
  if rel == "index.html":
    let routes = pages.filterIt(it != rel).mapIt("\"" & route(it) & "\":\"" & it & "\"").join(",")
    let js = "<script>(function(){var r={" & routes & "};var h=location.hash.slice(1);" &
             "if(r[h])location.replace(r[h]);})();</script>"
    s = s.replace("</head>", js & "</head>")
  writeTo rel, s
  echo rel, (if rel != "index.html": " #" & route(rel) else: "")

# the pictures a page shows from a folder beside it (`pictures/`, as nbPhotoHeading copies them)
for rel in pages:
  let dir = docs / rel.parentDir / "pictures"
  if rel.extractFilename == "index.html" and dirExists(dir):
    for f in walkDir(dir, relative = true):
      if f.kind == pcFile: writeTo rel.parentDir / "pictures" / f.path, readFile(dir / f.path)

# the files the pages share (not the fonts' licences, which artifacts may not serve)
for f in walkDirRec(docs / "assets", relative = true):
  if f.splitFile.ext != ".txt":
    writeTo "assets" / f, readFile(docs / "assets" / f)

# the files the book's pages load (not the chapters' JSON, nor nimibook's unused fonts; of Font
# Awesome's fonts only woff and woff2, which every browser reads and artifacts serve)
if dirExists(book):
  for f in walkDirRec(book, relative = true):
    let r = f.replace('\\', '/').parts
    let ext = f.splitFile.ext
    if r[0] in ["assets", "images"] and not (r.len > 1 and r[0] == "assets" and r[1] == "fonts") and
        ext notin [".eot", ".otf", ".ttf", ".txt"] and f.extractFilename != "fontawesome-webfont.svg":
      writeTo "book" / f, readFile(book / f)
