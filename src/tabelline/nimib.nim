## tabelline in nimib notebooks: `nbTable t` shows a table as a block of the page.
##
## ```nim
## import nimib, tabelline, tabelline/nimib
## nbInit
## nbCode:
##   let t = tabella(planets()):
##     tabHeader "The planets"
## nbTable t
## nbTable planets():          # or in one step, when the code need not be shown
##   tabHeader "The planets"
## nbSave
## ```
##
## The block keeps the HTML and the Markdown of the table, so it renders with both of nimib's
## backends (`nbInit` for HTML, `nbInitMd` for Markdown, as in a README). The first table of a
## page carries `tabellaCss`, the stylesheet of every table; the others leave it out.

import std/[json, macros, strutils]
import pkg/nimib
import ../tabelline

newNbBlock(NbTable):
  html: string
  markdown: string
  toHtml:
    blk.html

func nbTableToMd*(blk: NbBlock, nb: Nb): string = blk.NbTable.markdown
nbToMd.funcs["NbTable"] = nbTableToMd

const cssWritten = "tabelline_css_written"

proc tableHtml*(nb: var Nb, t: Tabella): string =
  ## The HTML of `t` for this page: with `tabellaCss` the first time on the page, without it
  ## afterwards. For a block that puts a table inside its own HTML.
  ## A page that asks for tables as text too (`nb.doc.context["tableText"] = %true`) gets each
  ## table twice: its HTML in `<div class="tabella-html">`, then `toText` in
  ## `<pre class="tabella-text">`, for its CSS to show one of them (a terminal look shows the text).
  let first = not nb.doc.context.hasKey(cssWritten)
  if first: nb.doc.context[cssWritten] = %true
  result = t.toHtml(withStyle = first)
  if nb.doc.context{"tableText"}.getBool:
    let text = t.toText.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"))
    result = "<div class=\"tabella-html\">" & result & "</div><pre class=\"tabella-text\">" & text & "</pre>"

proc table*(nb: var Nb, t: Tabella) =
  nb.add newNbTable(html = nb.tableHtml(t), markdown = t.toMarkdown)

template asTabella(x: typed): Tabella =
  when x is Tabella: x else: initTabella(x)

macro nbTable*(args: varargs[untyped]): untyped =
  ## Adds a table to the page: `nbTable t` for a table `t`, and `nbTable data` for a table of
  ## `data` as it is. With a body, `nbTable data: body` adds `tabella(data): body`, in one step,
  ## without naming the table (the other arguments of `tabella`, such as `rownameCol`, go too):
  ##
  ## ```nim
  ## nbTable planets(), rownameCol = "planet":
  ##   tabHeader "Planets"
  ##   fmtNumber "mass", decimals = 1
  ## ```
  ## A body works on a table too: `nbTable t: tabHeader "Again"` adds `t` with a heading.
  ## (A macro: written as a template, Nim would give the body to `nbTable`, not to `tabella`.)
  let nb = ident"nb"
  let hasBody = args.len >= 2 and args[^1].kind == nnkStmtList
  if args.len == 1 and not hasBody:
    result = newCall(bindSym"table", nb, newCall(bindSym"asTabella", args[0]))
  else:
    var call = newCall(bindSym"tabella")
    for a in args: call.add a
    result = newCall(bindSym"table", nb, call)
