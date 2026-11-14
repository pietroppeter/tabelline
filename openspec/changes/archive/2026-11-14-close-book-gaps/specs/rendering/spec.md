## ADDED Requirements

### Requirement: Numbers on one line, and a stub in view
A formatted number in a data cell (aligned right) SHALL not break inside its cell, so a minus
or a power of ten stays with its digits on a phone. With `tabOptions(stubSticky = true)` the stub
and the stub head SHALL stay in view while a wide table scrolls sideways in its container (not
in gt or Great Tables).

```nim
let t = tabella(planets(), rownameCol = "planet"):
  tabOptions(stubSticky = true)
echo "class=\"tb_table tb_sticky_stub\"" in t.toHtml, " ", "td.tb_right { white-space: nowrap; }" in tabellaCss
```

```text
true true
```
