## 1. Rendering

- [ ] 1.1 Before: build the docs and the book on `main`, record each page's size and its bytes of table styles, and take 390px Munari screenshots of every page with a table
- [ ] 1.2 `render_html.nim`: write the CSS with a placeholder selector (table rules, nanoplot rules, `extraCss`), hash it into `styleClass(t)` (`tb-s-<8 hex>`), scope every rule to `.tb-s-…`; `#` rules of `extraCss` as written
- [ ] 1.3 The `<div>` keeps its id and gets `class="tabella tb-s-…"`; `toHtml(t, makePage, withStyle = true)`, `tableStyle(t)` (the `<style>` element), `styleClass(t)`, exported from `tabelline`
- [ ] 1.4 Tests in `tests/`: same options give the same class and style; different options, nanoplots and `extraCss` give another; `toHtml(withStyle = false)` holds no `<style>`; ids and `aria-labelledby` unchanged

## 2. nimib

- [ ] 2.1 `tabelline/nimib`: a set of written classes in `nb.doc.context`; `nb.table(t)` adds the style only for a class not yet written; `nb.tableHtml(t)` with the same rule
- [ ] 2.2 `docs/blocks.nim`: blocks that call `toHtml` on a table (`nbParts` and the others) use `nb.tableHtml`; the book's `tabbook.nim` too
- [ ] 2.3 A test notebook: two tables with the same options give one `<style>`, a third with other options a second one; a page made with `nbInitMd` is unchanged

## 3. Docs

- [ ] 3.1 `docs/coverage.nim`: a line in *Not from gt* (`withStyle`, `tableStyle`: one style per page; closest: `as_raw_html(inline_css = TRUE)`)
- [ ] 3.2 The guide (explainer) says how a page writes a style once, under "How it is built"
- [ ] 3.3 Fix any page rule whose result changed with the lower specificity (from the screenshots), in `docs/theme.nim` or `book/theme/edo.css`

## 4. Checks

- [ ] 4.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes` (correct the outputs with `--update` once built)
- [ ] 4.2 Rebuild the docs (`nim r -d:release docs/all.nim`) and the book; `nim r tools/links.nim` and `nim r tools/drift.nim`
- [ ] 4.3 After: the same sizes and screenshots as 1.1; before and after sizes in the PR, screenshots that differ in the reply
- [ ] 4.4 Rebase the reference page (PR #65) on this and record its size before and after
