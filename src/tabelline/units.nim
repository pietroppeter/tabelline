## Units and chemical formulas written as text, in gt's units notation: `"kg/m^3"`,
## `"m s^-2"`, `"m /s"` (a unit after a solidus is a power −1), `"T_eff"`, `":mu:g"`,
## `"degC"`, `"%H2O%"`. `formatUnits` and `formatChem` turn them into HTML (`<sup>`, `<sub>`)
## or into plain text with Unicode super- and subscripts (`kg/m³`), so the text and Markdown
## outputs show them too. In a label, units go between `{{` and `}}`: `"Density, {{kg/m^3}}"`.

import std/[strutils, sequtils]
from std/unicode import runes, runeLen, `$`
import core, formats

const
  nsp = "{nsp}"   # no space here: the spaces around it are removed when the tokens are joined

  symbols = [
    (":micro:", "µ"), (":mu:", "µ"), (":ohm:", "Ω"), (":angstrom:", "Å"), (":times:", "×"),
    (":plusminus:", "±"), (":permil:", "‰"), (":permille:", "‰"), (":degrees:", "°"),
    (":degree:", "°"), ("degC", "°C"), ("degF", "°F"), (":space:", " "),
    (":thinspace:", " "), (":dot:", "⋅"), (":darr:", "↓"), (":uarr:", "↑"),
    (":Alpha:", "Α"), (":alpha:", "α"), (":Beta:", "Β"), (":beta:", "β"), (":Gamma:", "Γ"),
    (":gamma:", "γ"), (":Delta:", "Δ"), (":delta:", "δ"), (":Epsilon:", "Ε"), (":epsilon:", "ε"),
    (":Zeta:", "Ζ"), (":zeta:", "ζ"), (":Eta:", "Η"), (":eta:", "η"), (":Theta:", "Θ"),
    (":theta:", "θ"), (":Iota:", "Ι"), (":iota:", "ι"), (":Kappa:", "Κ"), (":kappa:", "κ"),
    (":Lambda:", "Λ"), (":lambda:", "λ"), (":Mu:", "Μ"), (":Nu:", "Ν"), (":nu:", "ν"),
    (":Xi:", "Ξ"), (":xi:", "ξ"), (":Omicron:", "Ο"), (":omicron:", "ο"), (":Pi:", "Π"),
    (":pi:", "π"), (":Rho:", "Ρ"), (":rho:", "ρ"), (":Sigma:", "Σ"), (":sigmaf:", "ς"),
    (":sigma:", "σ"), (":Tau:", "Τ"), (":tau:", "τ"), (":Upsilon:", "Υ"), (":upsilon:", "υ"),
    (":Phi:", "Φ"), (":phi:", "φ"), (":Chi:", "Χ"), (":chi:", "χ"), (":Psi:", "Ψ"),
    (":psi:", "ψ"), (":Omega:", "Ω"), (":omega:", "ω")]
  wholeUnits = [("um", "µm"), ("uL", "µL"), ("ug", "µg"), ("ohm", "Ω")]

func plainPart(s: string, ctx: RenderContext): string =
  ## A part of a unit: `*x*` is emphasis, the rest is text.
  if ctx == rcHtml: (if '*' in s: inlineMarkdown(s) else: escapeHtml(s))
  else: s.replace("*", "")

func supPart(s: string, ctx: RenderContext): string =
  let s = s.replace("-", "−")
  if ctx == rcHtml: "<sup>" & plainPart(s, ctx) & "</sup>" else: toSuperscript(s.replace("*", ""))

func subPart(s: string, ctx: RenderContext): string =
  if ctx == rcHtml: "<sub>" & plainPart(s, ctx) & "</sub>" else: toSubscript(s.replace("*", ""))

func stacked(sup, sub: string, ctx: RenderContext): string =
  ## A superscript over a subscript (`m[_0^2]`, isotopes): stacked in HTML, side by side in text.
  if ctx == rcHtml:
    "<span class=\"tb_supsub\"><sup>" & plainPart(sup.replace("-", "−"), ctx) & "</sup><sub>" &
      plainPart(sub, ctx) & "</sub></span>"
  else: supPart(sup, ctx) & subPart(sub, ctx)

func symbolsIn(s: string): string =
  result = s
  for (w, u) in wholeUnits:
    if result == w: return u
  if result.startsWith("umol"): result = "µmol" & result[4 .. ^1]
  if "x10" in result: result = result.replace("x10", "×10")
  for (name, u) in symbols: result = result.replace(name, u)

func unbrace(s: string): string =
  if s.len >= 2 and s[0] == '{' and s[^1] == '}': s[1 ..< ^1] else: s

func unitToken(token: string, ctx: RenderContext): string =
  ## One unit: a name, then a subscript after `_` and a power after `^`.
  var tok = token
  if tok.len > 1 and tok[0] == '/': tok = tok[1 .. ^1] & "^-1"
  if tok.startsWith(nsp): return nsp & unitToken(tok[nsp.len .. ^1], ctx)
  let o = tok.find("[_")
  if o > 0 and tok.endsWith("]") and '^' in tok[o .. ^1]:
    let inner = tok[o + 2 ..< ^1]
    let k = inner.find('^')
    return plainPart(symbolsIn(tok[0 ..< o]), ctx) & stacked(inner[k + 1 .. ^1], inner[0 ..< k], ctx)
  let u = tok.find('_')
  let p = tok.find('^')
  if u > 0 and (p < 0 or u < p):
    result = plainPart(symbolsIn(tok[0 ..< u]), ctx)
    if p > u: result.add subPart(symbolsIn(unbrace(tok[u + 1 ..< p])), ctx) & supPart(unbrace(tok[p + 1 .. ^1]), ctx)
    else: result.add subPart(symbolsIn(unbrace(tok[u + 1 .. ^1])), ctx)
  elif p > 0:
    result = plainPart(symbolsIn(tok[0 ..< p]), ctx) & supPart(unbrace(tok[p + 1 .. ^1]), ctx)
  else:
    result = plainPart(symbolsIn(tok), ctx)

func joinTokens(parts: seq[string], units: seq[string]): string =
  ## Tokens joined with spaces, none after "(" or "[" or before ")" or "]", and none around a
  ## lone solidus ("m / s" is "m/s").
  for i, p in parts:
    let tight = result.len == 0 or result.endsWith("(") or result.endsWith("[") or
                p.startsWith(")") or p.startsWith("]") or
                (units.len == 3 and units[1] == "/")
    if not tight: result.add " "
    result.add p
  while true:   # "{nsp}" takes the spaces around it with it
    let i = result.find(nsp)
    if i < 0: break
    var (a, b) = (i, i + nsp.len)
    while a > 0 and result[a - 1] == ' ': dec a
    while b < result.len and result[b] == ' ': inc b
    result = result[0 ..< a] & result[b .. ^1]

# ------------------------------------------------------------------------------------ chemistry

const arrows = [("<-->", "⇄"), ("<=>>", "⇌"), ("<<=>", "⇌"), ("<=>", "⇌"), ("<->", "↔"),
                ("->", "→"), ("<-", "←")]

func chemToken(x: string, ctx: RenderContext): string =
  ## One token of a formula: `H2O` is H₂O, `SO4^2-` and `Fe3+` carry a charge, `2H2` a count,
  ## `^14C` an isotope (write a charge after a caret, `Fe^3+`, or after a count, `NH4+`); `^` and `v` alone are a gas and a precipitate, `*` and `.` a dot.
  for (a, s) in arrows:
    if x == a: return s
  case x
  of "^", "(^)": return nsp & "↑"
  of "v", "(v)": return nsp & "↓"
  of "*", ".": return nsp & "⋅" & nsp
  of "x": return plainPart("*x*", ctx)
  else: discard
  var i = 0
  template readScript(): string =
    var s = ""
    if i < x.len and x[i] == '{':
      let j = x.find('}', i)
      if j > i: (s = x[i + 1 ..< j]; i = j + 1)
    else:
      while i < x.len and x[i] in {'0'..'9', '+', '-', 'n', 'x'} : (s.add x[i]; inc i)
    s
  if x.len > 1 and x[0] == '^':   # an isotope: mass number, then the atomic number
    inc i
    let mass = readScript()
    var atomic = ""
    if i < x.len and x[i] == '_': (inc i; atomic = readScript())
    result.add (if atomic.len > 0: stacked(mass, atomic, ctx) else: supPart(mass, ctx))
  if i < x.len and x[i] in Digits:   # a count before a formula: "2H2O"
    var j = i
    while j < x.len and x[j] in Digits: inc j
    if j < x.len and x[j] in Letters:
      result.add x[i ..< j] & " "
      i = j
  var prev = ' '
  while i < x.len:
    let c = x[i]
    if prev == ']' and x[i .. ^1].allCharsInSet(Digits + {'+', '-'}):   # [Fe(CN)6]3-
      result.add supPart(x[i .. ^1], ctx); break
    if c in Digits and prev in Letters + {')', ']'}:
      var j = i
      while j < x.len and x[j] in Digits: inc j
      result.add subPart(x[i ..< j], ctx); i = j
      prev = '0'; continue
    if c == '^':
      inc i
      var s = readScript()
      if s.len == 0: s = x[i .. ^1]; i = x.len
      result.add supPart(s.replace("n", "*n*"), ctx); prev = '^'; continue
    if c == '_':
      inc i
      var s = readScript()
      if s.len == 0 and i < x.len: (s = $x[i]; inc i)
      result.add subPart(if s == "x": "*x*" else: s, ctx); prev = '_'; continue
    if c in {'+', '-'} and i == x.len - 1 and prev in Letters + {'0', ')', ']'}:   # NH4+, OH-
      result.add supPart($c, ctx); inc i; continue
    result.add (if ctx == rcHtml: escapeHtml($c) else: $c)
    prev = c; inc i

func formatChem*(s: string, ctx = rcText): string =
  ## A chemical formula or reaction, in gt's notation: `formatChem("CuSO4 * 5H2O")` is "CuSO₄⋅5 H₂O",
  ## `formatChem("2H2 + O2 -> 2H2O")` is "2 H₂ + O₂ → 2 H₂O".
  var parts: seq[string]
  for tok in s.splitWhitespace: parts.add chemToken(tok, ctx)
  joinTokens(parts, @[])

func formatUnits*(s: string, ctx = rcText): string =
  ## Units in gt's notation: `formatUnits("kg/m^3")` is "kg/m³", `formatUnits("m /s")` is
  ## "m s⁻¹", `formatUnits("T_eff")` is "Tₑff" in text and `T<sub>eff</sub>` in HTML. A part
  ## between `%` signs is a chemical formula: `"g %CO2%"`.
  var input = s.strip
  if input.startsWith("{{") and input.endsWith("}}"): input = input[2 ..< ^2].strip
  let a = input.find('%')
  let b = if a >= 0: input.find('%', a + 1) else: -1
  if b > a:
    let chem = formatChem(input[a + 1 ..< b], ctx)
    let before = if a > 0: formatUnits(input[0 ..< a], ctx) else: ""
    let after = if b + 1 < input.len: formatUnits(input[b + 1 .. ^1], ctx) else: ""
    return [before, chem, after].filterIt(it.len > 0).join(" ")
  let tokens = input.splitWhitespace
  var parts: seq[string]
  for t in tokens: parts.add unitToken(t, ctx)
  joinTokens(parts, tokens)

func withUnits*(s: string, ctx: RenderContext, plain: proc (s: string): string {.noSideEffect.}): string =
  ## A label with units between `{{` and `}}`: the units are formatted, the rest goes through
  ## `plain`.
  var i = 0
  while i < s.len:
    let a = s.find("{{", i)
    let b = if a >= 0: s.find("}}", a + 2) else: -1
    if a < 0 or b < 0:
      result.add plain(s[i .. ^1]); break
    if a > i: result.add plain(s[i ..< a])
    result.add formatUnits(s[a + 2 ..< b], ctx)
    i = b + 2

# ------------------------------------------------------------------------------------- verbs

proc fmtUnits*(t: sink Tabella, columns: ColSel, rows = allRows()): Tabella =
  ## Cells written in gt's units notation, shown as units: `"m s^-2"` is "m s⁻²".
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string = formatUnits($v, ctx), rows)

proc fmtChem*(t: sink Tabella, columns: ColSel, rows = allRows()): Tabella =
  ## Cells written as chemical formulas or reactions: `"H2SO4"` is "H₂SO₄".
  fmt(t, columns, proc (v: Value, ctx: RenderContext): string = formatChem($v, ctx), rows)

proc colsUnits*(t: sink Tabella, units: openArray[(string, string)], unitsPattern = ""): Tabella =
  ## Units for column labels, in gt's notation: `colsUnits({"density": "kg/m^3"})` shows the
  ## label "density, kg/m³". `unitsPattern` places them: `{1}` is the label, `{2}` the units ("": the option
  ## `columnLabelsUnitsPattern`, "{1}, {2}").
  ## Inside `tabella(data): body`, also as a block, one pair per line (see `tabella`):
  ## `colsUnits:` then `density: "kg/m^3"`.
  result = t
  for (name, u) in units:
    if not result.data.hasColumn(name): raise newException(KeyError, "no column named " & name.escape)
    for c in result.boxhead.mitems:
      if c.name == name: (c.units = u; c.unitsPattern = unitsPattern)
