## 1. Review mode

- [x] 1.1 Copy sends: numbers given at the first copy, kept; the rounds of a version kept apart from the comments
- [x] 1.2 Export holds only new and changed comments; `nimib-review/6` with `round` and `sent`
- [x] 1.3 Sent comments marked quieter on the page; the comment box says its number and round
- [x] 1.4 Delete beside History in the export; History's Export gives every comment of the version
- [x] 1.5 Bring here: comments come as new ones

## 2. Skill and docs

- [x] 2.1 The skill: rounds on the same version, changed comments, `/6`
- [x] 2.2 AGENTS.md, the post Review mode, CHANGELOG

## 3. Checks

- [x] 3.1 Checked in a browser at 390px in Munari: two rounds, a delete, a changed comment, History
- [x] 3.2 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [x] 3.3 Rebuild the docs, `tools/drift.nim`, `tools/links.nim`
