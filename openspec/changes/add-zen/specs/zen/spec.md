## ADDED Requirements

### Requirement: The Zen as text
`import tabelline/this` SHALL print *The Zen of tabelline* when the program starts: a first line
that credits the Zen of Great Tables and Francesco Bruzzesi, an empty line, and the nineteen
aphorisms after PEP 20, one per line; then an empty line, a line that credits the Zen of Nim and
Andreas Rumpf (Araq), an empty line and nine aphorisms after the Zen of Nim. `import tabelline/zen` SHALL give the same text as `zenText` without
printing it.

```nim
echo zenText.splitLines[0 .. 4].join("\n")
```

```text
The Zen of tabelline, after the Zen of Great Tables by Francesco Bruzzesi

Beautiful is better than ugly, even at the console.
A data table is input. A display table is output.
Simple is better than complex.
```

#### Scenario: Nineteen aphorisms, then nine
- **WHEN** a program reads `aphorisms` and `pep20`, `nimAphorisms` and `nimZen`
- **THEN** the first two have nineteen entries and the others nine, and aphorism `i` retells the original `i`

### Requirement: The Zen as a table
`zenTable()` SHALL make a `Tabella` of the Zen: one row per aphorism numbered in Roman numerals,
a twentieth row left to Francesco, the part of tabelline that embodies each aphorism, and its
faithfulness to PEP 20 as a percentage, from `faithfulness(aphorism, original)`: one minus the
edit distance of the two, lower case and without Markdown marks, over the length of the longer.

```nim
echo zenTable().colsHide("aphorism").tabHeader("The Zen of tabelline")
```

```text
          The Zen of tabelline
┌───────┬────────────────────┬──────────┐
│       │    Embodied by     │ Faithful │
╞═══════╪════════════════════╪══════════╡
│ I     │       echo t       │   59%    │
│ II    │       save()       │   27%    │
│ III   │     colsHide()     │   100%   │
│ IV    │     tabStyle()     │   57%    │
│ V     │    tabSpanner()    │   48%    │
│ VI    │ tavolaPitagorica() │   45%    │
│ VII   │    fmtNumber()     │   30%    │
│ VIII  │     rownameCol     │   86%    │
│ IX    │   optCssTheme()    │   49%    │
│ X     │    dataColor()     │   69%    │
│ XI    │    subMissing()    │   71%    │
│ XII   │    colsLabel()     │   58%    │
│ XIII  │     tabella()      │   78%    │
│ XIV   │      Tabella       │   90%    │
│ XV    │   fmtDatetime()    │   100%   │
│ XVI   │     fmtRoman()     │   68%    │
│ XVII  │  tabFootnote()^1   │   59%    │
│ XVIII │    tabHeader()     │   67%    │
│ XIX   │     loc.body()     │   74%    │
│ XX    │                    │          │
└───────┴────────────────────┴──────────┘
1 See?
Faithful: how close an aphorism stays to its PEP 20 original, one minus the edit distance of the two over the length of the longer one.
Originals: PEP 20, The Zen of Python, by Tim Peters. Remixed by Francesco Bruzzesi in The Zen of Great Tables, and remixed again here.
```

#### Scenario: A table like any other
- **WHEN** a page calls `zenTable().optCssTheme()`
- **THEN** the table takes the page's colours, as any `Tabella` does

#### Scenario: Printed as text
- **WHEN** a program calls `echo zenTable()`
- **THEN** each aphorism prints with its original in brackets, without Markdown marks

### Requirement: The Zen of Nim beside the Zen of Python
`nimZenTable()` SHALL make a `Tabella` of the nine aphorisms after the Zen of Nim: each with its
original, the part of tabelline that embodies it, the aphorism of PEP 20 it meets or argues with
(*nothing* where PEP 20 has none), and its faithfulness to the Zen of Nim.

```nim
echo nimZenTable().colsHide(["aphorism", "faithful"]).tabHeader("After Nim")
```

```text
                                              After Nim
┌──────┬─────────────────────┬───────────────────────────────────────────────────────────────────────┐
│      │     Embodied by     │ Python says                                                           │
╞══════╪═════════════════════╪═══════════════════════════════════════════════════════════════════════╡
│ I    │     tabHeader()     │ nothing                                                               │
│ II   │        Value        │ Explicit is better than implicit.                                     │
│ III  │ tabella(data): body │ Although practicality beats purity.                                   │
│ IV   │       nbTable       │ Now is better than never.                                             │
│ V    │    sink Tabella     │ nothing                                                               │
│ VI   │       where()       │ Sparse is better than dense.                                          │
│ VII  │     tabOptions      │ Simple is better than complex.                                        │
│ VIII │        fmt()        │ Special cases aren't special enough to break the rules.               │
│ IX   │  import tabelline   │ There should be one-- and preferably only one --obvious way to do it. │
└──────┴─────────────────────┴───────────────────────────────────────────────────────────────────────┘
Faithful: how close an aphorism stays to its Zen of Nim original, one minus the edit distance of the two over the length of the longer one.
Originals: Zen of Nim, by Andreas Rumpf (Araq), NimConf 2021, and PEP 20, The Zen of Python, by Tim Peters.
```
