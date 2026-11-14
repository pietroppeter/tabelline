## ADDED Requirements

### Requirement: The stub of a table already made
`tabStub(rownameCol, groupnameCol)` SHALL choose the stub (and the row groups) of a table already
made, as Great Tables' `tab_stub()`, the same as `tabella(data, rownameCol = ..., groupnameCol =
...)`; `tabStub(["a", "b"])` SHALL make a stub of several columns. Verbs called before it SHALL
keep what they did to the other columns. `tabRowGroup(label, id = ...)` SHALL give a new label,
plain or Markdown, to a group that is already there (one made by `groupnameCol` is named by its
value).

```nim
let t = tabella(planets()):
  colsHide ["mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "moons"]
  tabStub "planet", groupnameCol = "type"
  tabRowGroup md"*Gas* giants", id = "Gas giant"
echo t
```

```text
┌─────────┬───────┐
│         │ rings │
╞═════════╪═══════╡
│ Terrestrial     │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Mercury │ false │
│ Venus   │ false │
│ Earth   │ false │
│ Mars    │ false │
├─────────┼───────┤
│ Gas giants      │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Jupiter │ true  │
│ Saturn  │ true  │
├─────────┼───────┤
│ Ice giant       │
├┄┄┄┄┄┄┄┄┄┼┄┄┄┄┄┄┄┤
│ Uranus  │ true  │
│ Neptune │ true  │
└─────────┴───────┘
```

### Requirement: Fuller Markdown
`md()` SHALL also read HTML entities (`&mdash;`, `&#x1F310;`), `_em_` and `__strong__` (not
inside a word, so `snake_case` stays), `~~struck~~`, `<https://...>` links, paragraphs (a blank
line) and lists (`- a`, `1. a`), as gt's Markdown does in a cell; one paragraph SHALL have no
`<p>`. `mdToHtml(text)` SHALL give the HTML.

```nim
echo mdToHtml("A &mdash; _it_ ~~old~~ snake_case")
echo mdToHtml("- a\n- b")
echo textToPlain(md("A &#x2014; B"))
```

```text
A &mdash; <em>it</em> <del>old</del> snake_case
<ul><li>a</li><li>b</li></ul>
A — B
```
