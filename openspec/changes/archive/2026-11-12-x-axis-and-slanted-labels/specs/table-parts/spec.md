## MODIFIED Requirements

### Requirement: Rotated labels
`colsLabelRotate(columns, dir)` SHALL turn the column labels of `columns` on their side in HTML,
read from the bottom up (`"sideways-lr"`, the default), from the top down (`"sideways-rl"`), or
slanted at 45 degrees, read upwards to the right (`"slanted"`, not from gt); the text and
Markdown outputs SHALL keep them as they are. Another `dir` SHALL raise a
`ValueError`.

```nim
let t = tabella(planets(), rownameCol = "planet"):
  colsHide ["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp"]
  colsLabelRotate ["moons", "rings"]
echo t.toHtml.count("writing-mode: vertical-rl; transform: rotate(180deg)")
```

```text
2
```

