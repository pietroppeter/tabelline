## Draws the modes of the review mode (modi.svg) for the post "Review mode", with diagrammari
## (github.com/pietroppeter/diagrammari, cloned beside tabelline; needs Node). tabelline does not
## depend on it: the SVG is committed. Run from tabelline:
##   nim r --path:../diagrammari/src docs/devlog/data/review-mode/modi.nim
import std/os
import mari

let modes = diagram"""
stateDiagram-v2
  direction TB
  [*] --> Reading
  Reading --> Reviewing: ✎ Review
  Reviewing --> Reading: Close review
  state Reviewing {
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
"""
echo modes
modes.save currentSourcePath().parentDir / "modi.svg"
