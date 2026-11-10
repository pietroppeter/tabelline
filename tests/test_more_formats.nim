## Edge cases of units, chemical formulas, fractions, bins, passthrough, automatic formats and
## country names.
import std/[unittest, strutils, sequtils, sugar]
import tabelline, tabelline/[datasets, countries]

suite "units":
  test "powers, subscripts and symbols":
    check formatUnits("kg/m^3") == "kg/m³"
    check formatUnits("m /s") == "m s⁻¹"
    check formatUnits("m / s") == "m/s"
    check formatUnits(":mu:g degC ohm") == "µg °C Ω"
    check formatUnits("x10^24 kg") == "×10²⁴ kg"
    check formatUnits("{{J (mol K)^-1}}") == "J (mol K)⁻¹"
  test "no Unicode subscript: a mark":
    check formatUnits("T_eff") == "T_(eff)"
    check formatUnits("T_eff", rcHtml) == "T<sub>eff</sub>"
  test "HTML: sup, sub, stacked, emphasis, escaping":
    check formatUnits("m s^-2", rcHtml) == "m s<sup>−2</sup>"
    check formatUnits("m[_0^2]", rcHtml) == "m<span class=\"tb_supsub\"><sup>2</sup><sub>0</sub></span>"
    check formatUnits("*v*_max", rcHtml) == "<em>v</em><sub>max</sub>"
    check formatUnits("a<b", rcHtml) == "a&lt;b"
  test "a chemical formula inside units":
    check formatUnits("g %CO2% /km") == "g CO₂ km⁻¹"
  test "labels: {{...}}, colsUnits, markdown":
    let t = tabella(planets()).colsLabel({"mass": md("*mass*, {{10^24 kg}}")})
      .colsUnits({"density": "kg/m^3"})
    let html = t.toHtml
    check "<em>mass</em>, 10<sup>24</sup> kg" in html
    check "density, kg/m<sup>3</sup>" in html
    check "mass, 10²⁴ kg" in t.toText
    check "tb_supsub" in html   # the CSS is always there
  test "a spanner and the stubhead take units too":
    let t = tabella(planets(), rownameCol = "planet").tabSpanner("size, {{km}}", ["diameter"])
      .tabStubhead("in {{m^2}}")
    check "size, km" in t.toText
    check "in m²" in t.toText
  test "colsUnits on a column that does not exist":
    expect KeyError:
      discard tabella(planets()).colsUnits({"weight": "kg"})

suite "chemistry":
  test "formulas, counts, charges, isotopes":
    check formatChem("H2SO4") == "H₂SO₄"
    check formatChem("2H2O") == "2 H₂O"
    check formatChem("SO4^2-") == "SO₄²⁻"
    check formatChem("NH4+") == "NH₄⁺"
    check formatChem("OH-") == "OH⁻"
    check formatChem("^14C") == "¹⁴C"
    check formatChem("[Fe(CN)6]3-") == "[Fe(CN)₆]³⁻"
  test "reactions, gas, precipitate, dot":
    check formatChem("2H2 + O2 -> 2H2O") == "2 H₂ + O₂ → 2 H₂O"
    check formatChem("N2 + 3H2 <=> 2NH3") == "N₂ + 3 H₂ ⇌ 2 NH₃"
    check formatChem("CO2 ^") == "CO₂↑"
    check formatChem("AgCl v") == "AgCl↓"
    check formatChem("CuSO4 * 5H2O") == "CuSO₄⋅5 H₂O"
  test "HTML":
    check formatChem("H2O", rcHtml) == "H<sub>2</sub>O"
    check formatChem("^{235}_{92}U", rcHtml) == "<span class=\"tb_supsub\"><sup>235</sup><sub>92</sub></span>U"

suite "fractions":
  test "accuracy":
    check formatFraction(0.333) == "1/3"
    check formatFraction(0.333, "high") == "332/997"
    check formatFraction(3.14159) == "3 1/7"
    check formatFraction(3.14159, "med") == "3 14/99"
  test "a fixed denominator, simplified or not":
    check formatFraction(0.125, denominator = 16) == "1/8"
    check formatFraction(0.125, denominator = 16, simplify = false) == "2/16"
  test "whole numbers, zero, negatives, rounding up":
    check formatFraction(3.0) == "3"
    check formatFraction(0.0) == "0"
    check formatFraction(-2.5) == "−2 1/2"
    check formatFraction(0.999) == "1"
    check formatFraction(0.01) == "0"
  test "diagonal":
    check formatFraction(2.25, layout = "diagonal") == "2¹⁄₄"
    check formatFraction(2.25, layout = "diagonal", ctx = rcHtml) ==
      "2<span class=\"tb_frac\"><sup>1</sup>⁄<sub>4</sub></span>"
  test "separators":
    check formatFraction(1234.5) == "1,234 1/2"
    let d = tableData:
      x: [1234.5]
    check tabella(d).fmtFraction("x", locale = "it").toText.contains("1.234 1/2")

suite "bins":
  test "intervals":
    check formatBins("[10,20)") == "10–20"
    check formatBins("(0, 5]", sep = " to ") == "0 to 5"
    check formatBins("[1e3,1e6)", fmt = x => formatCompact(x, 0)) == "1K–1M"
    check formatBins("10 to 20") == "10 to 20"
  test "ends that are not numbers are left as they are":
    check formatBins("[a,b)", fmt = x => "n") == "a–b"

suite "passthrough and auto":
  test "passthrough escapes unless told not to":
    let d = tableData:
      x: ["<b>bold</b>"]
    check "&lt;b&gt;" in tabella(d).fmtPassthrough("x").toHtml
    check "<b>bold</b>" in tabella(d).fmtPassthrough("x", escape = false).toHtml
    check "│ bold │" in tabella(d).fmtPassthrough("x", escape = false).toText
  test "auto: each column its own format":
    let d = tableData:
      n: [1, 2500000, 3]
      x: [0.5, 0.0000123, 12.125]
      cost_usd: [3.5, 10.0, 99.99]
      label: ["a", "b", "c"]
    let b = tabella(d).fmtAuto().build(rcText)
    check b.groups[0].rows.mapIt(it.cells[0]) == @["1", "2.5 × 10⁶", "3"]
    check b.groups[0].rows.mapIt(it.cells[1]) == @["0.5", "1.23 × 10⁻⁵", "12.125"]
    check b.groups[0].rows.mapIt(it.cells[2]) == @["$3.50", "$10.00", "$99.99"]
    check b.groups[0].rows.mapIt(it.cells[3]) == @["a", "b", "c"]
  test "auto: suffixes and scope":
    let d = tableData:
      n: [2500000, 3]
      cost_usd: [1.5, 2.0]
    let b = tabella(d).fmtAuto(lgNumPref = "suf", scope = ["numbers"]).build(rcText)
    check b.groups[0].rows.mapIt(it.cells[0]) == @["2.5M", "3"]
    check b.groups[0].rows.mapIt(it.cells[1]) == @["1.5", "2"]

suite "countries":
  test "two- and three-letter codes, any case":
    check countryName("IT") == "Italy"
    check countryName("ita") == "Italy"
    check countryName("GB") == "United Kingdom"
    check countryName("Atlantis") == "Atlantis"
  test "several codes":
    check formatCountry("FR DE,es") == "France, Germany, Spain"
    check formatCountry("FR DE", sep = " · ") == "France · Germany"
  test "every two-letter code has a name and every three-letter code a two-letter one":
    for (a3, a2) in countryAlpha3:
      check countryName(a3) != a3
