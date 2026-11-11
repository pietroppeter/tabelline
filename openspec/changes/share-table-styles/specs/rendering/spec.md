## MODIFIED Requirements

### Requirement: HTML with scoped CSS
`toHtml` SHALL render a `<div>` with an id and a style class, holding a `<style>` whose rules are
all prefixed with that class and a `<table class="tb_table">`: the heading and column labels in
`<thead>`, groups, stub and body in `<tbody>`, footnotes then source notes in one `<tfoot>`. The
class SHALL be `tb-s-` and a hash of the style, so tables with the same style share it. Without
an explicit `id`, the id SHALL come from a hash of the table, so the same table always renders
the same HTML. `toHtml(makePage = true)` SHALL return a standalone page holding the table, titled
after it, and `save(path)` SHALL write that page to a file.

```nim
let t = tabella(planets(), id = "planets").tabHeader("Planets")
let h = t.toHtml
let c = t.styleClass
echo h.startsWith("<div id=\"planets\" class=\"tabella " & c & "\""), " ", ("." & c & " .tb_table") in h, " ", h == t.toHtml
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
- **THEN** each table's CSS applies only to it

#### Scenario: Two tables with the same options
- **WHEN** two tables with different data have the same options
- **THEN** they have the same style class and the same `<style>`

## ADDED Requirements

### Requirement: A table without its style
`toHtml(t, withStyle = false)` SHALL render the same fragment without its `<style>`, and
`tableStyle(t)` SHALL give that `<style>` element, so a page can write a style once for many
tables. `styleClass(t)` SHALL give the class the style is scoped to. A table with nanoplots SHALL
have their rules in its style, and so a class of its own.

```nim
let a = tabella(planets()).tabHeader("Planets")
let b = tabella(tavolaPitagorica(3)).tabHeader("Tabellina")
echo a.styleClass == b.styleClass, " ", a.tableStyle == b.tableStyle
echo "<style>" in a.toHtml(withStyle = false), " ", a.tableStyle in a.toHtml
echo a.styleClass == a.tabOptions(tableFontSize = "12px").styleClass
```

```text
true true
false true
false
```

#### Scenario: Many tables, one style
- **WHEN** a page writes `tableStyle(t)` once and then `toHtml(x, withStyle = false)` for many
  tables `x` with the same style class as `t`
- **THEN** every table looks as it does with `toHtml(x)`

#### Scenario: A rule of extraCss that names an id
- **WHEN** `optCss` adds a rule whose selector starts with `#`
- **THEN** the rule is kept as written, and the other rules are scoped to the class
