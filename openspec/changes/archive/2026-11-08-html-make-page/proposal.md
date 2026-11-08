## Why

`toHtmlPage` gave a table as a whole HTML page, a name that is in neither gt nor Great Tables, and
only `save` used it. Great Tables does the same with an argument: `as_raw_html(make_page = True)`.
Pietro chose on 8 Nov 2026 to fold it into `toHtml` before 0.1.

## What Changes

- **Breaking (before 0.1)**: `toHtmlPage` is removed; `toHtml(t, makePage = true)` returns the
  whole page, titled after the table. `toHtml(t)` is unchanged, and so is `save(path)`.
- The Feature map's *Not from gt* table drops the line on `save` and `toHtmlPage`: `save` is gt's
  `gtsave()` for HTML.

## Differences from gt and Great Tables

- gt has no function that returns the page: `as_raw_html()` gives the fragment and `gtsave("x.html")`
  writes the page. tabelline follows Great Tables' `make_page`.
- `save` writes HTML only; `gtsave()` also writes images, PDF, Word, RTF and LaTeX, and Great
  Tables' `save()` writes images (Images and PDF are planned for 0.5).
- Great Tables' `as_raw_html` also takes `inline_css` and `all_important`; tabelline's CSS is
  always scoped in a `<style>`.

## Capabilities

### Modified requirement in `rendering`
- HTML with scoped CSS

## Impact

`src/tabelline/render_html.nim`, the spec `rendering`, `docs/coverage.nim`, `docs/coverage/gt.json`,
CHANGELOG.
