## Builds every page in one program: `nim r -d:release docs/all.nim`.
## A page is a nimib notebook in docs/, docs/devlog/ or docs/stories/; each renders when its module is
## initialised, in import order.
{.warning[UnusedImport]: off.}
import index, explainer, design, agents, specs, coverage, roadmap, api
import devlog/[review_mode, image_output, image_findings, datasets, blocks_review, design_review, day_one, tabellone, two_looks, palettes, three_threads, designing_0_1, designing_0_2, book_found, book_found_0_2, reference, sharing_styles, index as devlogIndex]
import stories/[milano_cortina, fosdem_data, fosdem, index as storiesIndex]
