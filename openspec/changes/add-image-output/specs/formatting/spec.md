## ADDED Requirements

### Requirement: Nanoplots are SVG 1.1
A nanoplot's SVG SHALL say `none`, never `transparent`, for a `fill` or `stroke` that draws
nothing, so programs that read SVG 1.1 (LibreOffice, PowerPoint, resvg) draw it as browsers do.

```nim
let d = tableData:
  trend: ["1 4 2 8 5"]
let h = tabella(d).fmtNanoplot("trend").toHtml
echo "\"transparent\"" in h, " ", "fill=\"none\"" in h
```

```text
false true
```

#### Scenario: Hover boxes in LibreOffice
- **WHEN** a table with an interactive nanoplot is saved as SVG and opened in LibreOffice
- **THEN** the hover boxes are not drawn black
