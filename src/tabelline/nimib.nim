## tabelline in nimib notebooks: `nbTable t` shows a table as a block of the page.
##
## ```nim
## import nimib, tabelline, tabelline/nimib
## nbInit
## nbCode:
##   let t = tabella(planets()):
##     tabHeader "The planets"
## nbTable t
## nbSave
## ```
##
## The block keeps the HTML and the Markdown of the table, so it renders with both of nimib's
## backends (`nbInit` for HTML, `nbInitMd` for Markdown, as in a README). The first table of a
## page carries `tabellaCss`, the stylesheet of every table; the others leave it out.

import std/json
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
  let first = not nb.doc.context.hasKey(cssWritten)
  if first: nb.doc.context[cssWritten] = %true
  t.toHtml(withStyle = first)

proc table*(nb: var Nb, t: Tabella) =
  nb.add newNbTable(html = nb.tableHtml(t), markdown = t.toMarkdown)

template nbTable*(t: Tabella) =
  ## Adds the table `t` to the page.
  nb.table(t)
