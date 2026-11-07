## ADDED Requirements

### Requirement: Text transforms
`textTransform(fn, locations)` SHALL change the shown text at locations (by default the body) with a
proc: for body and stub cells the proc SHALL get the formatted text when the table is rendered, for
labels and notes their text when the verb is called. `textReplace(pattern, replacement, locations)`
SHALL replace a plain text, and `textCaseMatch(cases, default, replace, locations)` SHALL change
texts that match a case (or, with `replace = "partial"`, the matching parts).

```nim
echo tabella(planets(), rownameCol = "planet").tabStubhead("planet")
  .colsHide(["type", "mass", "diameter", "density", "gravity", "day_length", "distance", "orbital_period", "mean_temp", "moons"])
  .textTransform(toUpperAscii, loc.stub())
  .fmtTf("rings", tfStyle = "yes-no")
  .textCaseMatch({"yes": "rings!"}, default = "", locations = loc.body("rings"))
  .textReplace("planet", "Planet", loc.stubhead())
```

```text
┌─────────┬────────┐
│ Planet  │ rings  │
╞═════════╪════════╡
│ MERCURY │ no     │
│ VENUS   │ no     │
│ EARTH   │ no     │
│ MARS    │ no     │
│ JUPITER │ rings! │
│ SATURN  │ rings! │
│ URANUS  │ rings! │
│ NEPTUNE │ rings! │
└─────────┴────────┘
```
