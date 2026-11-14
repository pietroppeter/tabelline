## Helpers shared by the chapters of the tabelline book.
##
## The main one is `tabs`: an example in tabelline, the original Great Tables code and the same
## example in R with gt, side by side in three tabs: 👑 Nim, 🐍 Python, 🏴‍☠️ R. Every side shows its
## table. The Nim blocks run when the chapter is built, as in any nimib page. The Python cells of
## a chapter run with Great Tables (`book/gt/run.py`, in the uv project `book/gt`) and the R
## cells with gt (`book/gt/run.R`) only when they changed: their outputs are kept in
## `book/gt/outputs/<chapter>.json` and `book/gt/outputs-r/<chapter>.json`, which are committed,
## so building the book needs neither Python nor R unless a chapter's code in them changed. With
## `BOOK_NO_PYTHON=1` and `BOOK_NO_R=1` (as in CI) a chapter whose outputs are out of date fails
## instead, and says how to update them.
##
## Every remark of the book (how tabelline differs, what it lacks) goes in `tabelline "<markdown>"`,
## a box set apart from the text of the original, which is kept as it is.
import std/[os, osproc, strutils, json, xmltree]
import nimib
import nimibook, markdown
import tabelline/nimib as tabNimib
export nimib
export nimibook, tabNimib

type Source* = object
  title*, url*: string       ## the original page
  authors*: string
  license*, licenseUrl*: string
  changes*: string           ## what this port changes, in a sentence or two
  fromR*: bool               ## the original is R with gt (a Table Contest entry), not Great Tables

const gtLicenseUrl* = "https://github.com/posit-dev/great-tables/blob/main/LICENSE"

const gtGuidePages = {
  # The book ported the Get Started guide, which Great Tables has since made into its User Guide,
  # with other names: page of Get Started -> where it is in the User Guide.
  "index": "introduction.html", "overview": "introduction.html#the-anatomy-of-a-table",
  "basic-header": "header-footer-stub.html",
  "basic-stub": "header-footer-stub.html#the-stub-row-labels",
  "basic-column-labels": "column-labels.html", "basic-formatting": "formatting-values.html",
  "basic-styling": "styling-the-table-body.html", "targeted-styles": "styling-the-whole-table.html",
  "table-theme-premade": "premade-themes.html", "loc-selection": "location-selection.html"}

proc gtGuide*(title, page, changes: string): Source =
  ## A page of the Great Tables user guide, by its name in the Get Started guide the book ported
  ## (posit-dev.github.io/great-tables/user-guide/, `gtGuidePages`).
  var url = page & ".html"
  for (old, now) in gtGuidePages:
    if old == page: url = now
  Source(title: "“" & title & "” in the Great Tables user guide",
         url: "https://posit-dev.github.io/great-tables/user-guide/" & url,
         authors: "Rich Iannone, Michael Chow and the Great Tables contributors",
         license: "MIT", licenseUrl: gtLicenseUrl, changes: changes)

proc gtBlog*(title, url, author, date, changes: string): Source =
  ## A post of the Great Tables blog (posit-dev.github.io/great-tables/blog/), by its address.
  Source(title: "“" & title & "”, a post of the Great Tables blog (" & date & ")",
         url: "https://posit-dev.github.io/great-tables/blog/" & url,
         authors: author, license: "MIT", licenseUrl: gtLicenseUrl, changes: changes)

proc gtExample*(title, url, changes: string): Source =
  ## An example of the Great Tables site (posit-dev.github.io/great-tables/examples/), by its
  ## address there or on GitHub.
  Source(title: "“" & title & "”, an example of Great Tables", url: url,
         authors: "Rich Iannone, Michael Chow and the Great Tables contributors",
         license: "MIT", licenseUrl: gtLicenseUrl, changes: changes)

proc gtVignette*(title, page, changes: string): Source =
  ## An article of gt's site (gt.rstudio.com/articles/), from its vignettes in R.
  Source(title: "“" & title & "”, an article of gt", url: "https://gt.rstudio.com/articles/" &
         page & ".html", authors: "Richard Iannone and the gt contributors",
         license: "MIT", licenseUrl: "https://github.com/rstudio/gt/blob/master/LICENSE.md",
         changes: changes, fromR: true)

proc noteHtml(label, text: string): string =
  "<aside class=\"tb-note\"><p class=\"tb-note-label\">" & label & "</p>" &
    markdown(text, config = initGfmConfig()) & "</aside>"

proc contestEntry*(title, url, authors, license, licenseUrl, changes: string): Source =
  ## An entry of the Posit Table Contest, made with gt in R (see the page The Table Contest).
  Source(title: "“" & title & "”, a Posit Table Contest entry", url: url, authors: authors,
         license: license, licenseUrl: licenseUrl, changes: changes, fromR: true)

proc tabsText(s: Source): string =
  if s.fromR:
    "Every example shows tabelline in the 👑 Nim tab, the original R code with gt, with the " &
      "table it makes, in the 🏴‍☠️ R tab, and the same example with Great Tables, gt's Python " &
      "twin, in the 🐍 Python tab (written for this book). "
  else:
    "Every example shows tabelline in the 👑 Nim tab, the original Great Tables code, " &
      "with the table it makes, in the 🐍 Python tab, and the same example with gt, the R " &
      "package Great Tables comes from, in the 🏴‍☠️ R tab (written for this book). "

template tabelline*(text: string) =
  ## A remark of the book (how tabelline differs, what it lacks yet), set apart from the text of
  ## the original page.
  nbRawHtml: noteHtml("× tabelline", text)

template attribution*(s: Source) =
  ## The box at the top of every ported chapter: where it comes from, its licence, what changed.
  nbRawHtml: noteHtml("× About this port", "**Ported from** [" & s.title & "](" & s.url &
    ") by " & s.authors & ", licensed under [" & s.license & "](" & s.licenseUrl & "). " &
    "The text of the original is kept as it is; the book's own remarks are in boxes like this " &
    "one. " & tabsText(s) & s.changes)

# ------------------------------------------------------------------------------- python and r

const pyKeywords = ["False", "None", "True", "and", "as", "assert", "async", "await", "break",
  "class", "continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global",
  "if", "import", "in", "is", "lambda", "nonlocal", "not", "or", "pass", "raise", "return", "try",
  "while", "with", "yield"]

const rKeywords = ["if", "else", "repeat", "while", "function", "for", "in", "next", "break",
  "TRUE", "FALSE", "NULL", "Inf", "NaN", "NA", "library"]

func highlight(code: string, keywords: openArray[string]): string =
  ## Python or R with the classes of highlight.js (keywords, strings, numbers, comments), done
  ## when the page is built, so the page loads no highlighter.
  var i = 0
  proc span(cls, s: string): string = "<span class=\"hljs-" & cls & "\">" & xmltree.escape(s) & "</span>"
  while i < code.len:
    let c = code[i]
    if c == '#':
      var j = i
      while j < code.len and code[j] != '\n': inc j
      result.add span("comment", code[i ..< j]); i = j
    elif c in {'"', '\''}:
      let triple = i + 2 < code.len and code[i + 1] == c and code[i + 2] == c
      let q = if triple: c.repeat(3) else: $c
      var j = i + q.len
      while j < code.len and code[j ..< min(code.len, j + q.len)] != q:
        if code[j] == '\\': inc j
        inc j
      j = min(code.len, j + q.len)
      result.add span("string", code[i ..< j]); i = j
    elif c in {'0'..'9'} and (i == 0 or code[i - 1] notin IdentChars + {'.'}):
      var j = i
      while j < code.len and code[j] in {'0'..'9', '.', '_', 'e', 'x', 'a'..'f', 'L'}: inc j
      result.add span("number", code[i ..< j]); i = j
    elif c in IdentStartChars:
      var j = i
      while j < code.len and code[j] in IdentChars + {'.'}: inc j
      let w = code[i ..< j]
      result.add(if w in keywords: span("keyword", w) else: xmltree.escape(w)); i = j
    else:
      result.add xmltree.escape($c); inc i

func highlightPython*(code: string): string = highlight(code, pyKeywords)
func highlightR*(code: string): string = highlight(code, rKeywords)

type
  Lang = enum langPython = "python", langR = "r"
  RefCell = object
    code: array[Lang, string]
    blk: NbRawHtml   ## filled in by bookSave, with the code and what it shows
    inTabs: bool     ## else Python and R with no tabelline version

const
  bookDir* = currentSourcePath().parentDir
  langInfo: array[Lang, tuple[tool, outputs, envVar, label, run: string]] = [
    ("Great Tables", "outputs", "BOOK_NO_PYTHON", "🐍 Python",
     "uv run --quiet --project book/gt python book/gt/run.py"),
    ("gt", "outputs-r", "BOOK_NO_R", "🏴‍☠️ R", "Rscript book/gt/run.R")]
  noCode: array[Lang, string] = [
    "<p class=\"tb-no-r\">Great Tables has no version of this example.</p>",
    "<p class=\"tb-no-r\">gt has no version of this example.</p>"]

var refCells: seq[RefCell]

proc outputsPath(nb: Nb, lang: Lang): string =
  bookDir / "gt" / langInfo[lang].outputs / nb.doc.thisFileRel.string.changeFileExt("json")

proc runCells(lang: Lang, chapter: string, cells: seq[string]): JsonNode =
  let info = langInfo[lang]
  if getEnv(info.envVar) in ["1", "true"]:
    raise newException(IOError, "the " & $lang & " cells of " & chapter & " changed and " &
      info.envVar & " is set: run `nim r book/bookbuild.nim` (with uv and R) and commit " &
      "book/gt/" & info.outputs & "/")
  let req = $(%*{"chapter": chapter, "cells": cells})
  echo "[tabbook] running the ", $lang, " cells of ", chapter, " with ", info.tool
  let (output, code) = execCmdEx(info.run, input = req, workingDir = bookDir.parentDir)
  if code != 0:
    raise newException(IOError, info.tool & " failed on " & chapter & ":\n" & output)
  # uv and R may print a warning before the JSON, and R one after it (a cell's `warning()`)
  let j = parseJson(output[output.find({'[', '{'}) .. output.rfind({']', '}'})])
  if j.kind == JArray: %*{"outputs": j} else: j

proc cellHtml(lang: Lang, code: string, o: JsonNode, errors: var seq[string]): string =
  let hl = if lang == langR: highlightR(code) else: highlightPython(code)
  result = "<pre><code class=\"nohighlight " & $lang & " hljs\">" & hl & "</code></pre>"
  let printed = o{"printed"}.getStr
  if printed.strip.len > 0:
    result.add "<pre class=\"nb-output\">" & xmltree.escape(printed.strip(leading = false)) & "</pre>"
  if o.hasKey("error"):
    errors.add code & "\n--> " & o["error"].getStr
    result.add "<pre class=\"nb-output tb-error\">" & xmltree.escape(o["error"].getStr) & "</pre>"
  let shown = o{"html"}.getStr
  if shown.len > 0: result.add "<div class=\"gt-output\">" & shown & "</div>"

var versions: array[Lang, string]  ## of Great Tables and gt, for the page's foot

proc fillCells(nb: var Nb, lang: Lang) =
  ## Gives every cell of `lang` its output: from the committed outputs when the cells are the
  ## same, else by running them all.
  var cells: seq[string]
  for c in refCells:
    if c.code[lang].len > 0: cells.add c.code[lang]
  let path = nb.outputsPath(lang)
  if cells.len == 0:
    discard tryRemoveFile(path)
    return
  var saved: JsonNode = nil
  if fileExists(path):
    saved = parseFile(path)
    var same = saved{"cells"}.len == cells.len
    if same:
      for k, c in cells:
        if saved["cells"][k].getStr != c: (same = false; break)
    if not same: saved = nil
  if saved.isNil:
    let ran = runCells(lang, nb.doc.thisFileRel.string, cells)
    saved = %*{"cells": cells, "outputs": ran["outputs"]}
    if lang == langPython: saved["greatTables"] = %"see book/gt/uv.lock"
    else: (saved["gt"] = ran["gt"]; saved["R"] = ran["r"])
    createDir path.parentDir
    writeFile(path, pretty(saved))
  versions[lang] = if lang == langPython: "1.1.0" else: saved{"gt"}.getStr
  var errors: seq[string]
  var k = 0
  for c in refCells:
    let mark = "<!--" & $lang & "-->"
    if c.code[lang].len == 0:
      c.blk.html = c.blk.html.replace(mark, noCode[lang])
      continue
    let html = cellHtml(lang, c.code[lang], saved["outputs"][k], errors)
    inc k
    c.blk.html = c.blk.html.replace(mark, html)
  if errors.len > 0:
    raise newException(ValueError, $lang & " cells failed in " & nb.doc.thisFileRel.string &
      ":\n" & errors.join("\n\n"))
  # the build reruns the chapter when its outputs change (book/bookbuild.nim)
  if not nb.doc.context.hasKey("book_inputs"): nb.doc.context["book_inputs"] = newJArray()
  nb.doc.context["book_inputs"].add %path.relativePath(bookDir.parentDir)

func tabButton(lang, label: string, selected: bool): string =
  "<button type=\"button\" class=\"tb-tab\" role=\"tab\" data-lang=\"" & lang &
    "\" aria-selected=\"" & $selected & "\">" & label & "</button>"

func tabsHtml(nimSide: string): string =
  ## The tabs of an example. Without a Nim side (Python and R only), whichever is not chosen
  ## shows the first tab.
  result = "<div class=\"tb-tabs\"><div class=\"tb-tablist\" role=\"tablist\">"
  if nimSide.len > 0: result.add tabButton("nim", "👑 Nim", true)
  result.add tabButton("python", "🐍 Python", nimSide.len == 0)
  result.add tabButton("r", "🏴‍☠️ R", false)
  result.add "</div>"
  if nimSide.len > 0:
    result.add "<div class=\"tb-panel\" data-lang=\"nim\">" & nimSide & "</div>"
  result.add "<div class=\"tb-panel\" data-lang=\"python\"" & (if nimSide.len > 0: " hidden" else: "") &
    "><!--python--></div><div class=\"tb-panel\" data-lang=\"r\" hidden><!--r--></div></div>"

template tabs*(py, r: string, body: untyped) =
  ## The tabelline version (the blocks of `body`), the original Great Tables code `py` and the
  ## same example in gt, `r`, in tabs, Nim first. The Python cells of a chapter share one
  ## namespace, as in a notebook, and so do the R cells; a cell that ends with a value shows it
  ## (a table, a list of tables, a data frame). An empty `r` says that gt has no version of the example.
  let first = nb.blocks.len
  body
  var nimSide = ""
  for i in first ..< nb.blocks.len:
    nimSide.add nb.render(nb.blocks[i])
  nb.blocks.setLen(first)
  let blk = newNbRawHtml(html = tabsHtml(nimSide))
  nb.add blk
  refCells.add RefCell(code: [py.strip, r.strip], blk: blk, inTabs: true)

template python*(py, r: string) =
  ## Python and R with no tabelline version, in tabs, with what they make.
  let blk = newNbRawHtml(html = tabsHtml(""))
  nb.add blk
  refCells.add RefCell(code: [py.strip, r.strip], blk: blk)

template sideBySide* =
  ## The examples up to `endSideBySide` go side by side, as many as fit (one on a phone): for
  ## small tables that are best compared at a glance.
  nbRawHtml: "<div class=\"tb-side\">"

template endSideBySide* =
  nbRawHtml: "</div>"

# ---------------------------------------------------------------------------------------- finder
# A page that shows one part at a time, chosen by a link to its id (`#id`): plain HTML and CSS
# (`:target`), no script. The links of `choices` are drawn as plain buttons.

template finder*(body: untyped) =
  ## The choices and the parts they show.
  nbRawHtml: "<div class=\"tb-finder\">"
  body
  nbRawHtml: "</div>"

template choices*(body: untyped) =
  ## The blocks whose links (`[name](#id)`) choose a part: drawn as buttons. A link to
  ## `#choices` goes back to them.
  nbRawHtml: "<div class=\"tb-choices\" id=\"choices\">"
  body
  nbRawHtml: "</div>"

template noChoice*(body: untyped) =
  ## Shown until a part is chosen.
  nbRawHtml: "<div class=\"tb-no-choice\">"
  body
  nbRawHtml: "</div>"

template choice*(id: string, body: untyped) =
  ## A part, shown when a link to `#id` is followed.
  nbRawHtml: "<section class=\"tb-choice\" id=\"" & id & "\">"
  body
  nbRawHtml: "</section>"

# ----------------------------------------------------------------------------------------- theme
# The look lives in theme/ (edo.css, book.js); `nim r book/bookbuild.nim` adds it to nimibook's
# own assets, so the Markdown pages get it too.

proc useTabBook*(nb: var Nb) =
  ## nimibook, in the Munari look of tabelline's pages with the Edo palette.
  nb.useNimibook
  nb.doc.context["theme_option"] = %*{"light": "Edo"}
  nb.doc.context["disableHighlightJs"] = %true  # Nim, Python and R are highlighted when built

let startDir = getCurrentDir()  # nbInit moves to the book's root; the next chapter starts here again

template bookInit* =
  ## Starts a chapter. The build runs the chapters in one program, so each starts afresh.
  refCells.setLen 0
  setCurrentDir startDir
  nbInit(theme = useTabBook)

proc sourceHtml(nb: Nb): string =
  let rel = nb.doc.thisFileRel.string.replace('\\', '/')
  let url = "https://github.com/pietroppeter/tabelline/blob/main/book/" & rel
  "<details class=\"tb-source\"><summary></summary>" &
    "<pre><code class=\"nohighlight nim hljs\">" & highlightNim(nb.doc.source) &
    "</code></pre><p class=\"tb-source-link\">On GitHub: <a href=\"" & url & "\">book/" & rel &
    "</a></p></details>" &
    "<div class=\"tb-foot\">Made with <a href=\"https://github.com/pietroppeter/tabelline\">tabelline</a>, " &
    "<a href=\"https://github.com/pietroppeter/nimib\">nimib</a> and " &
    "<a href=\"https://github.com/pietroppeter/nimibook\">nimibook</a>. The Nim code ran when this " &
    "page was built; the Python ran with Great Tables " & versions[langPython] & " and the R with gt " &
    versions[langR] & ".</div>"

template bookSave* =
  ## Ends a chapter: the Python and R outputs, a "Show source" button, `nbSave`, and the document as
  ## JSON next to the page, which book/bookbuild.nim renders from and adds a build record to.
  for lang in Lang: fillCells(nb, lang)
  nbRawHtml: sourceHtml(nb)
  nbSave
  writeFile(nb.doc.filename.changeFileExt("json"), nb.doc.dump())
