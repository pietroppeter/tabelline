## A small reader of TrueType fonts (standard library only), for the SVG renderer: the widths of
## the letters (`hmtx`, through `cmap`), kerning (`GPOS` pair adjustments of the `kern` feature),
## the line metrics (`hhea`), and a subset of the font with only the glyphs a picture uses.
## Proof of concept for tabelline 0.3 (image output): it reads the fonts tabelline ships
## (Arimo, Cousine), not every font there is.

import std/[tables, sets, algorithm, unicode, strutils]

type
  Font* = ref object
    data*: string
    tables*: OrderedTable[string, (int, int)]   ## tag -> (offset, length)
    unitsPerEm*: int
    ascender*, descender*, lineGap*: int
    numGlyphs*: int
    advances*: seq[int]                         ## advance width of each glyph
    cmap*: Table[int32, int]                    ## code point -> glyph
    kerning*: Table[(int, int), int]            ## (left, right) glyph -> adjustment
    name*: string

func u8(s: string, o: int): int = ord(s[o])
func u16(s: string, o: int): int = (ord(s[o]) shl 8) or ord(s[o + 1])
func i16(s: string, o: int): int =
  result = u16(s, o)
  if result >= 0x8000: result -= 0x10000
func u32(s: string, o: int): int =
  (ord(s[o]) shl 24) or (ord(s[o + 1]) shl 16) or (ord(s[o + 2]) shl 8) or ord(s[o + 3])

proc readCmap(f: Font) =
  let (base, _) = f.tables["cmap"]
  let d = f.data
  let n = u16(d, base + 2)
  var best = -1
  var bestScore = 0
  for k in 0 ..< n:
    let r = base + 4 + k * 8
    let (pid, eid) = (u16(d, r), u16(d, r + 2))
    let off = base + u32(d, r + 4)
    let fmt = u16(d, off)
    let score = if pid == 3 and eid == 10 and fmt == 12: 3
                elif pid == 3 and eid == 1 and fmt == 4: 2
                elif pid == 0 and fmt in [4, 12]: 1
                else: 0
    if score > bestScore: (best = off; bestScore = score)
  if best < 0: raise newException(ValueError, "no Unicode cmap in " & f.name)
  let fmt = u16(d, best)
  if fmt == 4:
    let segs = u16(d, best + 6) div 2
    let ends = best + 14
    let starts = ends + segs * 2 + 2
    let deltas = starts + segs * 2
    let ranges = deltas + segs * 2
    for s in 0 ..< segs:
      let (a, b) = (u16(d, starts + 2 * s), u16(d, ends + 2 * s))
      let delta = i16(d, deltas + 2 * s)
      let ro = u16(d, ranges + 2 * s)
      if a == 0xFFFF: continue
      for c in a .. b:
        var g: int
        if ro == 0: g = (c + delta) and 0xFFFF
        else:
          let p = ranges + 2 * s + ro + 2 * (c - a)
          g = u16(d, p)
          if g != 0: g = (g + delta) and 0xFFFF
        if g != 0: f.cmap[int32(c)] = g
  else:
    let groups = u32(d, best + 12)
    for k in 0 ..< groups:
      let g = best + 16 + 12 * k
      let (a, b, start) = (u32(d, g), u32(d, g + 4), u32(d, g + 8))
      for c in a .. b: f.cmap[int32(c)] = start + (c - a)

proc coverage(d: string, off: int): seq[int] =
  ## The glyphs of a coverage table, in coverage order.
  case u16(d, off)
  of 1:
    for k in 0 ..< u16(d, off + 2): result.add u16(d, off + 4 + 2 * k)
  of 2:
    for k in 0 ..< u16(d, off + 2):
      let r = off + 4 + 6 * k
      for g in u16(d, r) .. u16(d, r + 2): result.add g
  else: discard

proc classDef(d: string, off: int): Table[int, int] =
  case u16(d, off)
  of 1:
    let start = u16(d, off + 2)
    for k in 0 ..< u16(d, off + 4): result[start + k] = u16(d, off + 6 + 2 * k)
  of 2:
    for k in 0 ..< u16(d, off + 2):
      let r = off + 4 + 6 * k
      for g in u16(d, r) .. u16(d, r + 2): result[g] = u16(d, r + 4)
  else: discard

func valueSize(fmt: int): int = 2 * countSetBits(fmt and 0xFF)
func xAdvance(d: string, o, fmt: int): int =
  ## The XAdvance of a value record (0 when the format has none).
  if (fmt and 4) == 0: return 0
  var p = o
  if (fmt and 1) != 0: p += 2
  if (fmt and 2) != 0: p += 2
  i16(d, p)

proc readKerning(f: Font) =
  ## Pair adjustments (lookup type 2, also through extension lookups) of the `kern` feature, in
  ## any script: what a browser applies by default to Latin text.
  if "GPOS" notin f.tables: return
  let d = f.data
  let (base, _) = f.tables["GPOS"]
  let features = base + u16(d, base + 6)
  let lookups = base + u16(d, base + 8)
  var wanted: HashSet[int]
  for k in 0 ..< u16(d, features):
    let r = features + 2 + 6 * k
    if d[r ..< r + 4] != "kern": continue
    let ft = features + u16(d, r + 4)
    for j in 0 ..< u16(d, ft + 2): wanted.incl u16(d, ft + 4 + 2 * j)
  for li in wanted:
    let lk = lookups + u16(d, lookups + 2 + 2 * li)
    var kind = u16(d, lk)
    for s in 0 ..< u16(d, lk + 4):
      var st = lk + u16(d, lk + 6 + 2 * s)
      var k = kind
      if k == 9:                     # extension
        k = u16(d, st + 2)
        st = st + u32(d, st + 4)
      if k != 2: continue
      let fmt = u16(d, st)
      let cov = coverage(d, st + u16(d, st + 2))
      let (vf1, vf2) = (u16(d, st + 4), u16(d, st + 6))
      let (s1, s2) = (valueSize(vf1), valueSize(vf2))
      if fmt == 1:
        for ci, first in cov:
          let ps = st + u16(d, st + 10 + 2 * ci)
          for p in 0 ..< u16(d, ps):
            let r = ps + 2 + p * (2 + s1 + s2)
            let adj = xAdvance(d, r + 2, vf1)
            if adj != 0 and (first, u16(d, r)) notin f.kerning: f.kerning[(first, u16(d, r))] = adj
      elif fmt == 2:
        let c1 = classDef(d, st + u16(d, st + 8))
        let c2 = classDef(d, st + u16(d, st + 10))
        let (n1, n2) = (u16(d, st + 12), u16(d, st + 14))
        var byClass2: seq[seq[int]] = newSeq[seq[int]](n2)
        for g, c in c2: (if c < n2: byClass2[c].add g)
        for first in cov:
          let a = c1.getOrDefault(first, 0)
          if a >= n1: continue
          for b in 1 ..< n2:          # class 0 of the second glyph: every glyph not listed
            let r = st + 16 + (a * n2 + b) * (s1 + s2)
            let adj = xAdvance(d, r, vf1)
            if adj == 0: continue
            for second in byClass2[b]:
              if (first, second) notin f.kerning: f.kerning[(first, second)] = adj

proc readFont*(data: string, name = ""): Font =
  ## Reads a TrueType font (a `.ttf` file's bytes).
  result = Font(data: data, name: name)
  let n = u16(data, 4)
  for k in 0 ..< n:
    let r = 12 + 16 * k
    result.tables[data[r ..< r + 4]] = (u32(data, r + 8), u32(data, r + 12))
  for t in ["head", "hhea", "hmtx", "maxp", "cmap"]:
    if t notin result.tables: raise newException(ValueError, "no " & t & " table in " & name)
  let head = result.tables["head"][0]
  result.unitsPerEm = u16(data, head + 18)
  let hhea = result.tables["hhea"][0]
  result.ascender = i16(data, hhea + 4)
  result.descender = i16(data, hhea + 6)
  result.lineGap = i16(data, hhea + 8)
  let nh = u16(data, hhea + 34)
  result.numGlyphs = u16(data, result.tables["maxp"][0] + 4)
  let hmtx = result.tables["hmtx"][0]
  for g in 0 ..< result.numGlyphs:
    result.advances.add(if g < nh: u16(data, hmtx + 4 * g) else: result.advances[nh - 1])
  result.readCmap()
  result.readKerning()

func glyph*(f: Font, r: Rune): int = f.cmap.getOrDefault(int32(r), 0)
func hasGlyph*(f: Font, r: Rune): bool = int32(r) in f.cmap

proc width*(f: Font, s: string, size: float, kern = true): float =
  ## How wide `s` is at `size` pixels, kerning included.
  var units = 0
  var prev = -1
  for r in s.runes:
    let g = f.glyph(r)
    units += f.advances[g]
    if kern and prev >= 0: units += f.kerning.getOrDefault((prev, g), 0)
    prev = g
  units.float * size / f.unitsPerEm.float

func lineHeight*(f: Font, size: float): float =
  ## CSS's `line-height: normal`, as Chrome works it out from `hhea`.
  (f.ascender - f.descender + f.lineGap).float * size / f.unitsPerEm.float
func ascent*(f: Font, size: float): float = f.ascender.float * size / f.unitsPerEm.float
func descent*(f: Font, size: float): float = -f.descender.float * size / f.unitsPerEm.float

# ------------------------------------------------------------------------------------- subsets

proc putU16(s: var string, o, v: int) =
  s[o] = chr((v shr 8) and 0xFF); s[o + 1] = chr(v and 0xFF)
proc putU32(s: var string, o, v: int) =
  for k in 0 .. 3: s[o + k] = chr((v shr (24 - 8 * k)) and 0xFF)
proc addU16(s: var string, v: int) = s.add chr((v shr 8) and 0xFF); s.add chr(v and 0xFF)
proc addU32(s: var string, v: int) =
  for k in 0 .. 3: s.add chr((v shr (24 - 8 * k)) and 0xFF)

func checksum(s: string): int =
  var t = s
  while t.len mod 4 != 0: t.add '\0'
  var sum: uint32
  for k in countup(0, t.len - 1, 4): sum += uint32(u32(t, k))
  int(sum)

proc subset*(f: Font, text: string, dropLayout = true): string =
  ## The font with the outlines of only the glyphs `text` needs (the others are left empty, so
  ## every glyph keeps its number and `cmap` and `hmtx` stay as they are). Hinting goes with
  ## the glyphs; with `dropLayout`, so do `GSUB`, `GPOS` and `kern` (the drawing is placed
  ## letter by letter already) and the glyph names (`post` version 3).
  let d = f.data
  let head = f.tables["head"][0]
  let longLoca = i16(d, head + 50) == 1
  let (loca, _) = f.tables["loca"]
  let (glyf, _) = f.tables["glyf"]
  proc span(g: int): (int, int) =
    if longLoca: (u32(d, loca + 4 * g), u32(d, loca + 4 * g + 4))
    else: (2 * u16(d, loca + 2 * g), 2 * u16(d, loca + 2 * g + 2))
  var keep = initHashSet[int]()
  var todo = @[0]
  for r in text.runes: todo.add f.glyph(r)
  for c in [0x20, 0x2007, 0x2008, 0xA0]: todo.add f.cmap.getOrDefault(int32(c), 0)
  while todo.len > 0:
    let g = todo.pop
    if g in keep: continue
    keep.incl g
    let (a, b) = span(g)
    if b - a <= 0 or i16(d, glyf + a) >= 0: continue
    var p = glyf + a + 10                 # a composite: keep its parts
    while true:
      let flags = u16(d, p)
      todo.add u16(d, p + 2)
      p += 4 + (if (flags and 1) != 0: 4 else: 2)
      if (flags and 8) != 0: p += 2
      elif (flags and 0x40) != 0: p += 4
      elif (flags and 0x80) != 0: p += 8
      if (flags and 0x20) == 0: break
  var newGlyf = ""
  var offsets: seq[int]
  for g in 0 ..< f.numGlyphs:
    offsets.add newGlyf.len
    if g in keep:
      let (a, b) = span(g)
      newGlyf.add d[glyf + a ..< glyf + b]
      while newGlyf.len mod 4 != 0: newGlyf.add '\0'
  offsets.add newGlyf.len
  var newLoca = ""
  for o in offsets: newLoca.addU32 o
  var tabs: seq[(string, string)]
  for tag, (o, n) in f.tables:
    if dropLayout and tag in ["GSUB", "GPOS", "GDEF", "kern", "hdmx", "LTSH", "VDMX", "DSIG"]: continue
    var body = case tag
      of "glyf": newGlyf
      of "loca": newLoca
      else: d[o ..< o + n]
    if tag == "head":
      body.putU16(50, 1)                # long offsets
      body.putU32(8, 0)                 # checksum adjustment, set below
    if tag == "post" and dropLayout:
      body = body[0 ..< 32]
      body.putU32(0, 0x00030000)
    tabs.add (tag, body)
  tabs.sort(proc (a, b: (string, string)): int = cmp(a[0], b[0]))
  var outp = d[0 ..< 4]
  let n = tabs.len
  var es = 0
  while (1 shl (es + 1)) <= n: inc es
  outp.addU16 n
  outp.addU16 16 * (1 shl es)
  outp.addU16 es
  outp.addU16 16 * n - 16 * (1 shl es)
  var offset = 12 + 16 * n
  var bodies = ""
  var headAt = 0
  for (tag, body) in tabs:
    outp.add tag
    outp.addU32 checksum(body)
    outp.addU32 offset
    outp.addU32 body.len
    if tag == "head": headAt = offset
    var b = body
    while b.len mod 4 != 0: b.add '\0'
    bodies.add b
    offset += b.len
  outp.add bodies
  outp.putU32(headAt + 8, int(0xB1B0AFBA'u32 - uint32(checksum(outp))))
  outp
