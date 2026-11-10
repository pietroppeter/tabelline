## Kept only for the pages written before the blocks module (open PRs at the time of the
## migration): import `blocchi` instead. `useQuaderno` is `useTabelline`, and `nbNota` with a
## colour name maps it to a kind. Remove this module once no page imports it.
import nimib
import blocchi
export blocchi

proc useQuaderno*(nb: var Nb, nome = "tabelline", materia = "", classe = "", title = "", description = "",
                  homeHref = "", backLabel = "tabelline", nameHref = "") {.deprecated: "use useTabelline".} =
  nb.useTabelline(nome, materia, classe, title, description, homeHref, backLabel, nameHref)

func kindOf*(colour: string): NotaKind =
  ## The kind of note an old colour name meant.
  case colour
  of "azzurra": nkInfo
  of "verde": nkDone
  of "rosa": nkMissing
  else: nkPlain

template nbNota*(ttext: string, colour: string) {.deprecated: "use nbNota(text, kind)".} =
  nb.nota(ttext, kindOf(colour))
