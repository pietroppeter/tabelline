## 1. Assets

- [ ] 1.1 `docs/stile.nim` writes the CSS of both looks to `docs/assets/site.css`, and the fonts as `docs/assets/fonts/*.woff2` links
- [ ] 1.2 `useTabelline` links `site.css` (relative to the page) instead of inlining it; `-d:standalone` inlines as today
- [ ] 1.3 The book's theme: check whether it can link the same files (`book/theme/`)

## 2. Previews and checks

- [ ] 2.1 Port `tools/preview.py` to Nim (`tools/preview.nim`, like the other tools), and make it copy `docs/assets/`
- [ ] 2.2 `tools/links.nim` checks links to assets
- [ ] 2.3 AGENTS.md, the design guide (*Two looks*), README: the new rule

## 3. Checks

- [ ] 3.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim`
- [ ] 3.2 Rebuild the docs (`nim r -d:release docs/all.nim`) and the book; check pages at 390px in Munari, and a `-d:standalone` page alone
