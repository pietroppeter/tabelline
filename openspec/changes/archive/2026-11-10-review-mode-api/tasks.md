## 1. Before

- [x] 1.1 Build on `share-site-assets` (shared style, fonts and script) and on PR #34's `nbFoldCode`

## 2. The version from git

- [x] 2.1 `reviewVersion` in `docs/review.nim`: commits, short hash, date, `+` for uncommitted changes; a hash of the source outside git
- [x] 2.2 `nbReview(page, title, source, script)`: drop `version` and `versions`; write the version, commit and date in `#review`
- [x] 2.3 `reviewSettings(nb)` for the spec examples; make `tools/specexamples.nim` able to import `docs/review.nim`
- [x] 2.4 CI: `fetch-depth: 0` in every workflow that builds the pages

## 3. The script

- [x] 3.1 The version line, written under the lede (or the title) when the page has no `nbVersion`; `nbVersion()` with no arguments
- [x] 3.2 Export `nimib-review/4`: `commit`, `version` from git
- [x] 3.3 History: the versions with comments in this browser, no links
- [x] 3.4 Remove `nbVersions`, `versionHref`, `versionsJson`

## 4. Every page

- [x] 4.1 `useTabelline(review = true)` calls `nbReview` with the shared script
- [x] 4.2 Check the version line and the review mode at 390px in Munari on the home page, the Guide, a devlog post, the specs page, a story

## 5. The post Review mode

- [x] 5.1 One notebook, `docs/devlog/review_mode.nim`, with `nbReview(page = "devlog/review-mode")`; remove `review_mode/v1.nim` … `v8.nim` and `nbVersions`
- [x] 5.2 *Versions and rounds*: each card links its commit and its round's export (round links to `blob/main`)
- [x] 5.3 The post says what changed: one version line, versions in git

## 6. Words

- [x] 6.1 The skill: `/4`, the diff from `commit`, no versions to keep
- [x] 6.2 AGENTS.md (review mode on every page; devlog posts take edits), the design guide, README
- [x] 6.3 BACKLOG: remove "Review mode: one notebook, not one per version" and "Review-mode rounds made site-wide changes outside a change"

## 7. Checks

- [x] 7.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [x] 7.2 Rebuild the docs (`nim r -d:release docs/all.nim`), the book, `tools/links.nim`, `tools/drift.nim`
