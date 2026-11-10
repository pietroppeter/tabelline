## Draws the modes of the review mode (modi.svg for version 7, modi-v8.svg after it) for the post "Review mode", with diagrammari
## (github.com/pietroppeter/diagrammari, cloned beside tabelline; needs Node). tabelline does not
## depend on it: the SVG is committed. Run from tabelline:
##   nim r --path:../diagrammari/src docs/devlog/data/review-mode/modi.nim
import std/[os, strutils]
import mari

proc modes(box, name: string): Diagram = diagram("""
stateDiagram-v2
  direction TB
  [*] --> Reading
  Reading --> Reviewing: ✎ Review
  Reviewing --> Reading: Close review
  state Reviewing {
    state "NAME" as Sheet
    [*] --> Page
    Page --> Sheet: Comment ✓, Page note, ‹ ›, a mark
    Sheet --> Sheet: ‹ ›
    Sheet --> Page: a tap, Delete
    Page --> Export: Export
    Export --> History: History
    History --> Export: Export
    Export --> Page: Close
    History --> Page: Close
  }
""".replace("NAME", name).replace("Sheet", box))

let here = currentSourcePath().parentDir
# modi.svg, version 7's drawing, was drawn before the comment box had its name (and without the
# `state "..." as` line); it is kept as it was
let v8 = modes("Box", "Comment box")
echo v8
v8.save here / "modi-v8.svg"
