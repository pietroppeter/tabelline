## Custom blocks for tabelline's pages. A first, provisional module (name still to be decided):
## the devlog post "Blocks, not HTML" proposes moving every recurring piece of page HTML here,
## as a nimib block, so that a page says what it shows and not how it is drawn. Its CSS is in the
## theme (`docs/quaderno.nim`, `docs/munari.nim`).
import std/strformat
import nimib

newNbBlock(NbGalleria of NbContainer):
  label: string
  toHtml:
    &"""<div class="nb-galleria" tabindex="0" aria-label="{blk.label}">""" & nbContainerToHtml(blk, nb) & "</div>"

newNbBlock(NbScheda of NbContainer):
  title: string
  toHtml:
    &"""<div class="nb-scheda"><h3>{blk.title}</h3>""" & nbContainerToHtml(blk, nb) & "</div>"

template nbGalleria*(what: string, body: untyped) =
  ## A row of cards to swipe sideways; `what` says what they are, for screen readers.
  let galleria = newNbGalleria(label = what)
  nb.withContainer(galleria):
    body
  nb.add galleria

template nbScheda*(heading: string, body: untyped) =
  ## One card of a gallery: a heading, then any blocks (text, code, tables). Cards are numbered
  ## by the theme.
  let scheda = newNbScheda(title = heading)
  nb.withContainer(scheda):
    body
  nb.add scheda
