## 1. Rendering

- [ ] 1.1 Before: build the docs and the book on `main`, record each page's size and its bytes of table styles, and take 390px Munari screenshots of every page with a table
- [ ] 1.2 `render_html.nim`: `tabellaCss`, the rules of `tableCss` on `.tabella` with every option as `var(--tb-<option>, <default>)` (nested fallbacks where an option falls back to another), nanoplot rules included
- [ ] 1.3 The `<div>` keeps its id and gets `style="--tb-…"` for each option that differs from the default (and `onDark` values); `toHtml(t, makePage, withStyle = true)`; `optCss` stays in a per-table `<style>` scoped to the id
- [ ] 1.4 Tests in `tests/`: default options write no variables; each option writes its variable; every `var(--tb-…)` in `tabellaCss` names a real option and its default; `toHtml(withStyle = false)` holds no `tabellaCss`; ids and `aria-labelledby` unchanged; a pixel check that a few tables (docs, book, nanoplots) look the same before and after

## 2. nimib

- [ ] 2.1 `tabelline/nimib`: a flag in `nb.doc.context`; `nb.table(t)` writes `tabellaCss` only with the first table; `nb.tableHtml(t)` with the same rule
- [ ] 2.2 `docs/blocks.nim`: blocks that call `toHtml` on a table (`nbParts` and the others) use `nb.tableHtml`; the book's `tabbook.nim` too
- [ ] 2.3 A test notebook: three tables with different options give `tabellaCss` once; a page made with `nbInitMd` is unchanged

## 3. Docs

- [ ] 3.1 `docs/coverage.nim`: a line in *Not from gt* (`tabellaCss`, options as CSS variables, `withStyle`; closest: `as_raw_html(inline_css = TRUE)`)
- [ ] 3.2 A section of the guide, "A table's HTML and its style": what `toHtml` writes (the `<div>`, the `<style>`, the `<table>`), the one stylesheet and the variables each table carries, how to set a variable for every table of a page, how to use `withStyle = false` outside nimib (one page, a site stylesheet linked as a file, another notebook library), and the risk (a page rule stronger than two classes wins), each with a small example
- [ ] 3.3 Fix any page rule whose result changed with the lower specificity (from the screenshots), in `docs/theme.nim` or `book/theme/edo.css`

## 4. Checks

- [ ] 4.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes` (correct the outputs with `--update` once built)
- [ ] 4.2 Rebuild the docs (`nim r -d:release docs/all.nim`) and the book; `nim r tools/links.nim` and `nim r tools/drift.nim`
- [ ] 4.3 After: the same sizes and screenshots as 1.1; before and after sizes in the PR, screenshots that differ in the reply
- [ ] 4.4 Rebase the reference page (PR #65) on this and record its size before and after
