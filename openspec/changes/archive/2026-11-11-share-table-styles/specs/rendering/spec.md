## MODIFIED Requirements

### Requirement: HTML with scoped CSS
`toHtml` SHALL render a `<div class="tabella">` with an id, holding a `<style>` with
`tabellaCss` and a `<table class="tb_table">`: the heading and column labels in `<thead>`,
groups, stub and body in `<tbody>`, footnotes then source notes in one `<tfoot>`. Without an
explicit `id`, the id SHALL come from a hash of the table, so the same table always renders the
same HTML. `toHtml(makePage = true)` SHALL return a standalone page holding the table, titled
after it, and `save(path)` SHALL write that page to a file.

```nim
let t = tabella(planets(), id = "planets").tabHeader("Planets")
let h = t.toHtml
echo h.startsWith("<div id=\"planets\" class=\"tabella\""), " ", tabellaCss in h, " ", h == t.toHtml
let page = t.toHtml(makePage = true)
echo page.startsWith("<!doctype html>"), " ", "<title>Planets</title>" in page, " ", h in page
```

```text
true true true
true true true
```

#### Scenario: A whole page
- **WHEN** `toHtml(makePage = true)` is called, or `save("x.html")`
- **THEN** the result is a whole HTML page with the table's fragment in its body

#### Scenario: Two tables on a page
- **WHEN** a page holds two tables with different options
- **THEN** each table looks as its own options say

## ADDED Requirements

### Requirement: One stylesheet for every table
`tabellaCss` SHALL be the rules of every table, the same for all of them, with each value read
from a CSS variable named `--tb-` and the option in kebab-case, falling back to the option's
default. A table SHALL carry, in the `style` of its `<div>`, a variable for each option it sets
to a value other than the default, and none for the others.

```nim
echo tabella(planets()).toHtml(withStyle = false).splitLines[0].contains("style=")
echo tabella(planets(), id = "p").tabOptions(tableFontSize = "14px").toHtml(withStyle = false).splitLines[0]
echo "var(--tb-table-font-size, 16px)" in tabellaCss
```

```text
false
<div id="p" class="tabella" style="--tb-table-font-size: 14px">
true
```

#### Scenario: Options a page sets for all its tables
- **WHEN** a page's CSS sets `.tabella { --tb-table-font-size: 14px }`
- **THEN** every table on it without its own `tableFontSize` has 14px text

#### Scenario: A table's own rules
- **WHEN** `optCss` adds rules to a table
- **THEN** they are in a `<style>` inside that table's `<div>`, scoped to its id, as before

### Requirement: A table without the stylesheet
`toHtml(t, withStyle = false)` SHALL render the same fragment without `tabellaCss`, so a page can
write the stylesheet once, or link it as a file, for many tables.

```nim
let t = tabella(planets())
echo tabellaCss in t.toHtml(withStyle = false), " ", t.toHtml(withStyle = false).len < t.toHtml.len
```

```text
false true
```

#### Scenario: Many tables, one stylesheet
- **WHEN** a page writes `tabellaCss` once and then `toHtml(x, withStyle = false)` for many tables
- **THEN** every table looks as it does with `toHtml(x)`
