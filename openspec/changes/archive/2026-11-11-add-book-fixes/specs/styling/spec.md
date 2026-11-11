## ADDED Requirements

### Requirement: Colour names
A colour SHALL be `#rgb`, `#rrggbb` or one of the 148 colour names of CSS (CSS Color Module
Level 4), in any case, wherever tabelline computes with a colour: `parseColor`, the palettes of
`dataColor`, `interpolate` and `idealTextColor`. Anything else SHALL raise `ValueError` there.
The text of a heading or of the column labels SHALL be white on a dark background set by
`tabOptions`, given as a hex value or as a name; a background tabelline cannot read (a
`var(--x)`) SHALL keep the text colour of the table.

```nim
echo parseColor("darkgreen").toHex, " ", parseColor("RebeccaPurple").toHex
let t = tabella(tavolaPitagorica(2)):
  dataColor everything(), palette = @["lightblue", "darkgreen"]
echo "background-color: #006400; color: #FFFFFF" in t.toHtml
```

```text
#006400 #663399
true
```
