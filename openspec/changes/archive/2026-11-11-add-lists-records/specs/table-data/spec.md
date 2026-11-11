## ADDED Requirements

### Requirement: Lists and records in a cell
A cell SHALL hold a list (`vkList`, items in order) or a record (`vkRecord`, named fields in
order). `toValue` SHALL make a list from a seq or an array and a record from an object or a
named tuple, so `tableData:` and `toTableData` take them as they are; CSV SHALL never make them.
`v[i]` SHALL be an item and `v["x"]` a field (`KeyError` when there is none), `len` their count.
`$` SHALL write a list as "1, 4, 2" and a record as "x: 1, y: 2"; `==` SHALL compare item by
item; `<` SHALL order lists item by item; a list or record SHALL NOT be a number, and `toFloat`
SHALL raise `ValueError` on it. A column of them SHALL have the kind of its cells and not be
numeric.

```nim
let moons = tableData:
  planet: ["Earth", "Mars", "Jupiter"]
  moons: [@["Moon"], @["Phobos", "Deimos"], @["Io", "Europa", "Ganymede", "Callisto"]]
  biggest: [(name: "Moon", km: 3474.8), (name: "Phobos", km: 22.5), (name: "Ganymede", km: 5268.2)]
echo tabella(moons, rownameCol = "planet")
let r = moons["biggest", 2]
echo r.name, " ", r.km, " ", moons["moons", 1][0], " ", moons["moons", 2].len
```

```text
┌─────────┬────────────────────────────────┬────────────────────────────┐
│         │ moons                          │ biggest                    │
╞═════════╪════════════════════════════════╪════════════════════════════╡
│ Earth   │ Moon                           │ name: Moon, km: 3474.8     │
│ Mars    │ Phobos, Deimos                 │ name: Phobos, km: 22.5     │
│ Jupiter │ Io, Europa, Ganymede, Callisto │ name: Ganymede, km: 5268.2 │
└─────────┴────────────────────────────────┴────────────────────────────┘
Ganymede 5268.2 Phobos 4
```
