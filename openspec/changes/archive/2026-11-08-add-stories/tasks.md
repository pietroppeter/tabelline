## 1. Build

- [x] 1.1 `docs/stories/index.nim`: the stories page, read from the stories' first lines, a card with a small table for each
- [x] 1.2 Move *Milano Cortina 2026* and its data to `docs/stories/`; forward `devlog/milano-cortina/`
- [x] 1.3 The gallery of the stories (`docs/stories/storie.nim`) on the home page and the stories page, `href` in `docs/piano.nim` and links on the roadmap
- [x] 1.4 AGENTS.md, README.md, the llms.txt list; add the requirement "Stories" to `way-of-working`

## 2. Checks

- [x] 2.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim`
- [x] 2.2 Rebuild the docs (`nim r -d:release docs/all.nim`)
