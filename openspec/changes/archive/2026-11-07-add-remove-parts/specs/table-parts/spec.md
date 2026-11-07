## ADDED Requirements

### Requirement: Removing parts
`rmHeader()`, `rmStubhead()`, `rmCaption()`, `rmSpanners(spanners, levels)`, `rmFootnotes(indices)`
and `rmSourceNotes(indices)` SHALL take parts away, so tables built from a shared start can drop
what they do not need. With no arguments, `rmSpanners`, `rmFootnotes` and `rmSourceNotes` SHALL
remove all of them; indices SHALL count from 0 in the order the parts were added.

```nim
let base = tabella(tavolaPitagorica(2), rownameCol = "×").tabHeader("Times", "of two")
  .tabSourceNote("One.").tabSourceNote("Two.")
echo base.rmHeader().rmSourceNotes([0])
```

```text
┌───┬───┬───┐
│   │ 1 │ 2 │
╞═══╪═══╪═══╡
│ 1 │ 1 │ 2 │
│ 2 │ 2 │ 4 │
└───┴───┴───┘
Two.
```
