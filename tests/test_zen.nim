## The Zen of tabelline (`tabelline/zen`; `tabelline/this` only adds the print).
import std/[unittest, strutils]
import tabelline, tabelline/zen

suite "the Zen":
  test "nineteen aphorisms, each after its PEP 20 original":
    check aphorisms.len == 19 and pep20.len == 19
    check zenText.splitLines.len == 2 + 19 + 3 + 9
    check nimAphorisms.len == 9 and nimZen.len == 9
    check zenText.startsWith("The Zen of tabelline, after the Zen of Great Tables by Francesco Bruzzesi\n\n")

  test "faithfulness":
    check faithfulness("Simple is better than complex.", "Simple is better than complex.") == 1.0
    check faithfulness("`Now` is *better*", "now is better") == 1.0
    check faithfulness("abc", "xyz") == 0.0

  test "the table":
    let txt = zenTable().toText
    check "XX" in txt and "Left for Francesco to write." in txt
    check "(Beautiful is better than ugly.)" in txt
    check "*" notin txt.splitLines[5]
    let html = zenTable().toHtml
    check "<br><small><em>Beautiful is better than ugly.</em></small>" in html
    check "<code>tabFootnote()</code>" in html

  test "the table after the Zen of Nim":
    let txt = nimZenTable().toText
    check "IX" in txt and "Special cases aren't special enough to break the rules." in txt
    check "nothing" in txt
