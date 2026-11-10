## Kept only for the pages written before the blocks module (open PRs at the time of the
## migration): import `blocks` instead. `useQuaderno` is `useTabelline`, and `nbNote` with a
## colour name maps it to a kind. Remove this module once no page imports it.
import nimib
import blocks
export blocks

proc useQuaderno*(nb: var Nb, section = "", cadence = "", title = "", description = "",
                  homeHref = "", backLabel = "tabelline", wordmarkHref = "") {.deprecated: "use useTabelline".} =
  nb.useTabelline(section, cadence, title, description, homeHref, backLabel, wordmarkHref)

func kindOf*(colour: string): NoteKind =
  ## The kind of note an old colour name meant.
  case colour
  of "azzurra": nkInfo
  of "verde": nkDone
  of "rosa": nkMissing
  else: nkPlain

template nbNote*(ttext: string, colour: string) {.deprecated: "use nbNote(text, kind)".} =
  nb.addNote(ttext, kindOf(colour))
