## 1. Before

- [ ] 1.1 Build on `share-site-assets` (shared style, fonts and script) and on PR #34's `nbFoldCode`

## 2. The version from git

- [ ] 2.1 `reviewVersion` in `docs/review.nim`: commits, short hash, date, `+` for uncommitted changes; a hash of the source outside git
- [ ] 2.2 `nbReview(page, title, source, script)`: drop `version` and `versions`; write the version, commit and date in `#review`
- [ ] 2.3 `reviewSettings(nb)` for the spec examples; make `tools/specexamples.nim` able to import `docs/review.nim`
- [ ] 2.4 CI: `fetch-depth: 0` in every workflow that builds the pages

## 3. The script

- [ ] 3.1 The version line, written under the lede (or the title) when the page has no `nbVersion`; `nbVersion()` with no arguments
- [ ] 3.2 Export `nimib-review/4`: `commit`, `version` from git
- [ ] 3.3 History: the versions with comments in this browser, no links
- [ ] 3.4 Remove `nbVersions`, `versionHref`, `versionsJson`

## 4. Every page

- [ ] 4.1 `useTabelline(review = true)` calls `nbReview` with the shared script
- [ ] 4.2 Check the version line and the review mode at 390px in Munari on the home page, the Guide, a devlog post, the specs page, a story

## 5. The post Review mode

- [ ] 5.1 One notebook, `docs/devlog/review_mode.nim`, with `nbReview(page = "devlog/review-mode")`; remove `review_mode/v1.nim` … `v8.nim` and `nbVersions`
- [ ] 5.2 *Versions and rounds*: each card links its commit and its round's export (round links to `blob/main`)
- [ ] 5.3 The post says what changed: one version line, versions in git

## 6. Words

- [ ] 6.1 The skill: `/4`, the diff from `commit`, no versions to keep
- [ ] 6.2 AGENTS.md (review mode on every page; devlog posts take edits), the design guide, README
- [ ] 6.3 BACKLOG: remove "Review mode: one notebook, not one per version" and "Review-mode rounds made site-wide changes outside a change"

## 7. Checks

- [ ] 7.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [ ] 7.2 Rebuild the docs (`nim r -d:release docs/all.nim`), the book, `tools/links.nim`, `tools/drift.nim`
