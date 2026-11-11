## 1. Layout and SVG (core)

- [ ] 1.1 `ttf.nim` and the fonts from #94 (Inter 4.1 four faces, DejaVu Sans Mono, licences beside them)
- [ ] 1.2 `layout.nim`: #94's grid and placement, and `drawing(t, width, vars)` giving a `Drawing` of marks (rect, line, text, plot, image)
- [ ] 1.3 `render_svg.nim`: `toSvg(drawing, text)` and `toSvg(t, width, text, vars)`, `stFont` (font subset) and `stPaths` (outlines)
- [ ] 1.4 `save.nim`: `save(t, path, scale, width)` by the extension, `addWriter`, `hasWriter`; `save` moves out of `render_html.nim`
- [ ] 1.5 Nanoplots write `none` instead of `transparent`
- [ ] 1.6 Tests (`tests/test_layout.nim`): sizes of the image tables, both SVG modes well formed, `save` errors, a writer added

## 2. pixie

- [ ] 2.1 The atlas feature `pixie` in `tabelline.nimble` (pixie 6.1), pinned in `atlas.lock`; `tools/setup.sh` installs it
- [ ] 2.2 `src/tabelline/pixie.nim`: `toImage`, `toPng`, `.png` for `save`; letters glyph by glyph at the layout's places (tabular figures), nanoplots through pixie's SVG reader (text and hatching drawn apart), images decoded
- [ ] 2.3 A test, run when the feature is installed

## 3. Chrome

- [ ] 3.1 `src/tabelline/chrome.nim` from #92: `startChrome`, `saveImage`, `close`; `.pdf`, `.jpg`, `.webp`, and `.png` below pixie, for `save`
- [ ] 3.2 `tools/image/compare.nim`: the image tables drawn by Chrome, the SVG and pixie, boxes compared (within 4 px), pictures side by side

## 4. Docs

- [ ] 4.1 `docs/coverage/gt.json`: *Images and PDF* done; `docs/coverage.nim` *Not from gt*: `toSvg` and its two modes, `drawing`, `addWriter`
- [ ] 4.2 The guide: a section *A table as a picture* (`save` by the extension, SVG modes, pixie, Chrome, fonts, `vars` for themed tables), with a picture made by the page itself
- [ ] 4.3 README (modules, the pixie feature), BACKLOG (*Images* entry), CHANGELOG under Unreleased

## 5. Checks

- [ ] 5.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes` (correct the outputs with `--update` once built)
- [ ] 5.2 Rebuild the docs (`nim r -d:release docs/all.nim`); `nim r tools/links.nim` and `nim r tools/drift.nim`
- [ ] 5.3 Pictures of the four tables, Chrome beside SVG and PNG, in the reply; a selection in the PR
