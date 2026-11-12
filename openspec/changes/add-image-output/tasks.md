## 1. Layout and SVG (core)

- [x] 1.1 `ttf.nim` and the fonts from #94 (Inter 4.1 four faces, DejaVu Sans Mono, licences beside them)
- [x] 1.2 `layout.nim`: #94's grid and placement, and `drawing(t, width, vars)` giving a `Drawing` of marks (rect, line, text, plot, image)
- [x] 1.3 `render_svg.nim`: `toSvg(drawing, text)` and `toSvg(t, width, text, vars)`, `stFont` (font subset) and `stPaths` (outlines)
- [x] 1.4 `save.nim`: `save(t, path, scale, width)` by the extension, `addWriter`, `hasWriter`; `save` moves out of `render_html.nim`
- [x] 1.5 Nanoplots write `none` instead of `transparent`
- [x] 1.6 Tests (`tests/test_image.nim`): sizes of the image tables, both SVG modes well formed, `save` errors, a writer added

## 2. pixie

- [x] 2.1 The atlas feature `pixie` in `tabelline.nimble` (pixie 6.1), pinned in `atlas.lock`; `tools/setup.sh` installs it
- [x] 2.2 `src/tabelline/pixie.nim`: `toImage`, `toPng`, `.png` for `save`; letters glyph by glyph at the layout's places (tabular figures), nanoplots through pixie's SVG reader (text and hatching drawn apart), images decoded
- [x] 2.3 A test, run when the feature is installed

## 3. Chrome

- [x] 3.1 `src/tabelline/chrome.nim` from #92: `startChrome`, `saveImage`, `close`; `.pdf`, `.jpg`, `.webp`, and `.png` below pixie, for `save`
- [x] 3.2 `tools/image/compare.nim`: the image tables drawn by Chrome, the SVG and pixie, boxes compared (within 4 px), pictures side by side

## 4. Docs

- [x] 4.1 `docs/coverage/gt.json`: *Images and PDF* done; `docs/coverage.nim` *Not from gt*: `toSvg` and its two modes, `drawing`, `addWriter`
- [x] 4.2 The guide: a section *A table as a picture* (`save` by the extension, SVG modes, pixie, Chrome, fonts, `vars` for themed tables), with a picture made by the page itself
- [x] 4.3 README (modules, the pixie feature), CHANGELOG under Unreleased
- [ ] 4.4 BACKLOG: remove the *Images* entry when the change is archived

## 5. Checks

- [x] 5.1 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes` (correct the outputs with `--update` once built)
- [x] 5.2 Rebuild the docs (`nim r -d:release docs/all.nim`); `nim r tools/links.nim` and `nim r tools/drift.nim`
- [x] 5.3 Pictures of the four tables, Chrome beside SVG and PNG, in the reply; a selection in the PR
