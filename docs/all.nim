## Builds every page in one program: `nim r -d:release docs/all.nim`.
## A page is a nimib notebook in docs/, docs/devlog/ or docs/stories/; each renders when its module is
## initialised, in import order.
{.warning[UnusedImport]: off.}
import index, explainer, design, agents, specs, coverage, roadmap
import devlog/[blocks_review, design_review, day_one, tabellone, two_looks, palettes, three_threads, designing_0_1, book_found, index as devlogIndex]
import stories/[milano_cortina, fosdem, index as storiesIndex]
