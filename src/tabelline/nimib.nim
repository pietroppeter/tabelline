## tabelline in nimib notebooks: `nbTable t` shows a table as a block of the page.
##
## ```nim
## import nimib, tabelline, tabelline/nimib
## nbInit
## nbCode:
##   let t = tabella(planets()).tabHeader("The planets")
## nbTable t
## nbSave
## ```
##
## The block keeps the HTML and the Markdown of the table, so it renders with both of nimib's
## backends (`nbInit` for HTML, `nbInitMd` for Markdown, as in a README).

import pkg/nimib
import ../tabelline

newNbBlock(NbTable):
  html: string
  markdown: string
  toHtml:
    blk.html

func nbTableToMd*(blk: NbBlock, nb: Nb): string = blk.NbTable.markdown
nbToMd.funcs["NbTable"] = nbTableToMd

proc table*(nb: var Nb, t: Tabella) =
  nb.add newNbTable(html = t.toHtml, markdown = t.toMarkdown)

template nbTable*(t: Tabella) =
  ## Adds the table `t` to the page.
  nb.table(t)
