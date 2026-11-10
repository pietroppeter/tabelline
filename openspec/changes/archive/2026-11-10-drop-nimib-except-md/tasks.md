## 1. Build

- [x] 1.1 Pin nimib to a commit with nimib#268 (`atlas.lock`)
- [x] 1.2 Replace `import nimib except md` with `import nimib` in every notebook, the book and `book/tabbook.nim`'s export
- [x] 1.3 Update AGENTS.md and the comment in `docs/explainer.nim`

## 2. Checks

- [x] 2.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim`
- [x] 2.2 Rebuild the docs (`nim r -d:release docs/all.nim`) and the book

## 3. Release

- [ ] 3.1 When nimib 0.5.0 is tagged, pin nimib to the tag
- [x] 3.2 Archive the change: remove the BACKLOG entry, add a CHANGELOG line
