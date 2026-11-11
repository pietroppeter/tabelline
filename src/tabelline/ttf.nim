## A small reader of TrueType fonts (standard library only), for the SVG renderer: the widths of
## the letters (`hmtx`, through `cmap`), kerning (`GPOS` pair adjustments of the `kern` feature),
## the line metrics (`hhea`), and a subset of the font with only the glyphs a picture uses.
## Proof of concept for tabelline 0.3 (image output): it reads the fonts tabelline ships
## (Arimo, Cousine), not every font there is.

import std/[tables, sets, algorithm, unicode, bitops, math, strutils, sequtils]

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
    tnum*: Table[int, int]                      ## glyph -> its tabular figure (`tnum`)
    xHeight*: int
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

proc readSingle(f: Font, feature: string): Table[int, int] =
  ## Single substitutions (lookup type 1, also through extensions) of a `GSUB` feature.
  if "GSUB" notin f.tables: return
  let d = f.data
  let (base, _) = f.tables["GSUB"]
  let features = base + u16(d, base + 6)
  let lookups = base + u16(d, base + 8)
  var wanted: HashSet[int]
  for k in 0 ..< u16(d, features):
    let r = features + 2 + 6 * k
    if d[r ..< r + 4] != feature: continue
    let ft = features + u16(d, r + 4)
    for j in 0 ..< u16(d, ft + 2): wanted.incl u16(d, ft + 4 + 2 * j)
  for li in wanted:
    let lk = lookups + u16(d, lookups + 2 + 2 * li)
    for s in 0 ..< u16(d, lk + 4):
      var st = lk + u16(d, lk + 6 + 2 * s)
      var k = u16(d, lk)
      if k == 7:
        k = u16(d, st + 2)
        st = st + u32(d, st + 4)
      if k != 1: continue
      let cov = coverage(d, st + u16(d, st + 2))
      if u16(d, st) == 1:
        let delta = i16(d, st + 4)
        for g in cov: result[g] = (g + delta) and 0xFFFF
      else:
        for i, g in cov: result[g] = u16(d, st + 6 + 2 * i)

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
  result.tnum = result.readSingle("tnum")
  if "OS/2" in result.tables:
    let os2 = result.tables["OS/2"][0]
    if u16(data, os2) >= 2: result.xHeight = i16(data, os2 + 86)
  if result.xHeight == 0: result.xHeight = result.unitsPerEm div 2

func glyph*(f: Font, r: Rune): int = f.cmap.getOrDefault(int32(r), 0)
func hasGlyph*(f: Font, r: Rune): bool = int32(r) in f.cmap

proc glyphs*(f: Font, s: string, tabular = false): seq[int] =
  ## The glyphs of `s`, one for each letter (tabular figures with `tabular`).
  for r in s.runes:
    let g = f.glyph(r)
    result.add(if tabular: f.tnum.getOrDefault(g, g) else: g)

proc advances*(f: Font, s: string, size: float, kern = true, tabular = false): seq[float] =
  ## How far each letter of `s` moves the pen at `size` pixels, kerning included.
  let gs = f.glyphs(s, tabular)
  for i, g in gs:
    var units = f.advances[g]
    if kern and i + 1 < gs.len: units += f.kerning.getOrDefault((g, gs[i + 1]), 0)
    result.add units.float * size / f.unitsPerEm.float

proc width*(f: Font, s: string, size: float, kern = true, tabular = false): float =
  ## How wide `s` is at `size` pixels, kerning included.
  for a in f.advances(s, size, kern, tabular): result += a

func ascent*(f: Font, size: float): float =
  ## The height above the baseline, rounded to a pixel as Chrome does.
  round(f.ascender.float * size / f.unitsPerEm.float)
func descent*(f: Font, size: float): float = round(-f.descender.float * size / f.unitsPerEm.float)
func lineHeight*(f: Font, size: float): float =
  ## CSS's `line-height: normal`, as Chrome works it out from `hhea`.
  f.ascent(size) + f.descent(size) + round(f.lineGap.float * size / f.unitsPerEm.float)
func xHeightPx*(f: Font, size: float): float = f.xHeight.float * size / f.unitsPerEm.float

# ------------------------------------------------------------------------------------ outlines

proc glyphPath*(f: Font, g: int): string =
  ## The outline of glyph `g` as SVG path data, in font units with y up (composites included).
  let d = f.data
  let head = f.tables["head"][0]
  let longLoca = i16(d, head + 50) == 1
  let loca = f.tables["loca"][0]
  let glyf = f.tables["glyf"][0]
  let (a, b) = if longLoca: (u32(d, loca + 4 * g), u32(d, loca + 4 * g + 4))
               else: (2 * u16(d, loca + 2 * g), 2 * u16(d, loca + 2 * g + 2))
  if b <= a: return ""
  let p0 = glyf + a
  let nc = i16(d, p0)
  func num(x: float): string =
    let r = round(x * 10) / 10
    if r == r.trunc: $int(r) else: $r
  if nc < 0:
    var p = p0 + 10
    while true:
      let flags = u16(d, p)
      let comp = u16(d, p + 2)
      p += 4
      var dx, dy: float
      if (flags and 1) != 0: (dx = i16(d, p).float; dy = i16(d, p + 2).float; p += 4)
      else:
        dx = float(cast[int8](d[p])); dy = float(cast[int8](d[p + 1])); p += 2
      var (sa, sb, sc, sd) = (1.0, 0.0, 0.0, 1.0)
      func f2(o: int): float = i16(d, o).float / 16384
      if (flags and 8) != 0: (sa = f2(p); sd = sa; p += 2)
      elif (flags and 0x40) != 0: (sa = f2(p); sd = f2(p + 2); p += 4)
      elif (flags and 0x80) != 0: (sa = f2(p); sb = f2(p + 2); sc = f2(p + 4); sd = f2(p + 6); p += 8)
      # transform the component's path: parse its numbers back (simple: rebuild from points)
      let sub = f.glyphPath(comp)
      var outp = ""
      var nums: seq[float]
      var cmd = ' '
      proc flush() =
        var k = 0
        while k + 1 < nums.len:
          let (x, y) = (nums[k], nums[k + 1])
          outp.add num(sa * x + sc * y + dx) & " " & num(sb * x + sd * y + dy) & " "
          k += 2
        nums.setLen 0
      var tok = ""
      for ch in sub & " ":
        if ch in {'M', 'L', 'Q', 'Z'}:
          if tok.len > 0: (nums.add parseFloat(tok); tok = "")
          flush()
          outp.add ch
          cmd = ch
        elif ch == ' ':
          if tok.len > 0: (nums.add parseFloat(tok); tok = "")
        else: tok.add ch
      flush()
      result.add outp
      if (flags and 0x20) == 0: break
    return
  var ends: seq[int]
  for k in 0 ..< nc: ends.add u16(d, p0 + 10 + 2 * k)
  let npts = ends[^1] + 1
  var p = p0 + 10 + 2 * nc
  p += 2 + u16(d, p)                    # instructions
  var flags: seq[int]
  while flags.len < npts:
    let fl = u8(d, p); inc p
    flags.add fl
    if (fl and 8) != 0:
      let n = u8(d, p); inc p
      for _ in 1 .. n: flags.add fl
  var xs, ys: seq[int]
  var v = 0
  for fl in flags:
    if (fl and 2) != 0: (let dx = u8(d, p); inc p; v += (if (fl and 16) != 0: dx else: -dx))
    elif (fl and 16) == 0: (v += i16(d, p); p += 2)
    xs.add v
  v = 0
  for fl in flags:
    if (fl and 4) != 0: (let dy = u8(d, p); inc p; v += (if (fl and 32) != 0: dy else: -dy))
    elif (fl and 32) == 0: (v += i16(d, p); p += 2)
    ys.add v
  var start = 0
  for e in ends:
    let n = e - start + 1
    proc pt(i: int): (float, float, bool) =
      let k = start + (i mod n)
      (xs[k].float, ys[k].float, (flags[k] and 1) != 0)
    # start at an on-curve point (or the middle of two off-curve ones)
    var first = -1
    for i in 0 ..< n:
      if pt(i)[2]: (first = i; break)
    var (sx, sy) = (0.0, 0.0)
    if first < 0:
      let (x0, y0, _) = pt(0)
      let (x1, y1, _) = pt(1)
      (sx, sy) = ((x0 + x1) / 2, (y0 + y1) / 2)
      first = 0
    else: (sx, sy) = (pt(first)[0], pt(first)[1])
    result.add "M" & num(sx) & " " & num(sy)
    var ctrl: (float, float)
    var hasCtrl = false
    for j in 1 .. n:
      let (x, y, on) = pt(first + j)
      if on:
        if hasCtrl: result.add "Q" & num(ctrl[0]) & " " & num(ctrl[1]) & " " & num(x) & " " & num(y)
        else: result.add "L" & num(x) & " " & num(y)
        hasCtrl = false
      else:
        if hasCtrl:
          let (mx, my) = ((ctrl[0] + x) / 2, (ctrl[1] + y) / 2)
          result.add "Q" & num(ctrl[0]) & " " & num(ctrl[1]) & " " & num(mx) & " " & num(my)
        ctrl = (x, y)
        hasCtrl = true
    if hasCtrl: result.add "Q" & num(ctrl[0]) & " " & num(ctrl[1]) & " " & num(sx) & " " & num(sy)
    result.add "Z"
    start = e + 1

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

proc subset*(f: Font, text: string, tabular = false): string =
  ## The font with only the glyphs `text` needs, renumbered, with a new `cmap`, `hmtx` and
  ## `loca`. Hinting stays; `GSUB`, `GPOS` and `kern` go (the drawing is placed letter by letter
  ## already), and so do the glyph names (`post` version 3). With `tabular`, the figures are
  ## drawn by their tabular forms (`tnum`), for text that asks for them.
  let d = f.data
  let head = f.tables["head"][0]
  let longLoca = i16(d, head + 50) == 1
  let (loca, _) = f.tables["loca"]
  let (glyf, _) = f.tables["glyf"]
  let hmtx = f.tables["hmtx"][0]
  let nh = u16(d, f.tables["hhea"][0] + 34)
  proc span(g: int): (int, int) =
    if longLoca: (u32(d, loca + 4 * g), u32(d, loca + 4 * g + 4))
    else: (2 * u16(d, loca + 2 * g), 2 * u16(d, loca + 2 * g + 2))
  proc lsb(g: int): int =
    if g < nh: i16(d, hmtx + 4 * g + 2) else: i16(d, hmtx + 4 * nh + 2 * (g - nh))
  # the code points, and the glyph that draws each
  var cps: Table[int, int]
  for r in (text & " \u00A0\u2007\u2008").runes:
    var g = f.glyph(r)
    if tabular: g = f.tnum.getOrDefault(g, g)
    if g != 0 and int(r) <= 0xFFFF: cps[int(r)] = g
  var keep = initHashSet[int]()
  var todo = @[0]
  for g in cps.values: todo.add g
  proc components(g: int): seq[(int, int)] =
    ## (offset in the glyph's data, component glyph) of a composite glyph.
    let (a, b) = span(g)
    if b - a <= 0 or i16(d, glyf + a) >= 0: return
    var p = 10
    while true:
      let flags = u16(d, glyf + a + p)
      result.add (p + 2, u16(d, glyf + a + p + 2))
      p += 4 + (if (flags and 1) != 0: 4 else: 2)
      if (flags and 8) != 0: p += 2
      elif (flags and 0x40) != 0: p += 4
      elif (flags and 0x80) != 0: p += 8
      if (flags and 0x20) == 0: break
  while todo.len > 0:
    let g = todo.pop
    if g in keep: continue
    keep.incl g
    for (_, c) in components(g): todo.add c
  var order = toSeq(keep.items)
  order.sort
  var newId: Table[int, int]
  for i, g in order: newId[g] = i
  var newGlyf, newLoca, newHmtx = ""
  for g in order:
    newLoca.addU32 newGlyf.len
    let (a, b) = span(g)
    var data = d[glyf + a ..< glyf + b]
    for (o, c) in components(g): data.putU16(o, newId[c])
    newGlyf.add data
    while newGlyf.len mod 4 != 0: newGlyf.add '\0'
    newHmtx.addU16 f.advances[g]
    newHmtx.addU16 (lsb(g) and 0xFFFF)
  newLoca.addU32 newGlyf.len
  # cmap: format 4, one segment for each run of code points with consecutive glyphs
  var points = toSeq(cps.keys)
  points.sort
  var segs: seq[(int, int, int)]          # start, end, delta
  for cp in points:
    let g = newId[cps[cp]]
    if segs.len > 0 and segs[^1][1] == cp - 1 and ((segs[^1][2] + cp) and 0xFFFF) == g: segs[^1][1] = cp
    else: segs.add (cp, cp, (g - cp) and 0xFFFF)
  segs.add (0xFFFF, 0xFFFF, 1)
  var sub = ""
  let n = segs.len
  var es = 0
  while (1 shl (es + 1)) <= n: inc es
  sub.addU16 4
  sub.addU16 16 + 8 * n
  sub.addU16 0
  sub.addU16 2 * n
  sub.addU16 2 * (1 shl es)
  sub.addU16 es
  sub.addU16 2 * n - 2 * (1 shl es)
  for s in segs: sub.addU16 s[1]
  sub.addU16 0
  for s in segs: sub.addU16 s[0]
  for s in segs: sub.addU16 s[2]
  for s in segs: sub.addU16 0
  var cmap = ""
  cmap.addU16 0
  cmap.addU16 1
  cmap.addU16 3
  cmap.addU16 1
  cmap.addU32 12
  cmap.add sub
  var tabs: seq[(string, string)]
  for tag, (o, n) in f.tables:
    if tag in ["GSUB", "GPOS", "GDEF", "kern", "hdmx", "LTSH", "VDMX", "DSIG", "STAT"]: continue
    var body = case tag
      of "glyf": newGlyf
      of "loca": newLoca
      of "hmtx": newHmtx
      of "cmap": cmap
      else: d[o ..< o + n]
    case tag
    of "head":
      body.putU16(50, 1)                # long offsets
      body.putU32(8, 0)                 # checksum adjustment, set below
    of "post":
      body = body[0 ..< 32]
      body.putU32(0, 0x00030000)
    of "maxp": body.putU16(4, order.len)
    of "hhea": body.putU16(34, order.len)
    else: discard
    tabs.add (tag, body)
  tabs.sort(proc (a, b: (string, string)): int = cmp(a[0], b[0]))
  var outp = d[0 ..< 4]
  let nt = tabs.len
  es = 0
  while (1 shl (es + 1)) <= nt: inc es
  outp.addU16 nt
  outp.addU16 16 * (1 shl es)
  outp.addU16 es
  outp.addU16 16 * nt - 16 * (1 shl es)
  var offset = 12 + 16 * nt
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
