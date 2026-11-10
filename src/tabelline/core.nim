## The data model of tabelline.
##
## Two layers, like gt and Great Tables:
##
## - the **table data** (`TableData`): named columns of `Value`s, read once and never changed;
## - the **table spec** (`Tabella`): everything said about how to show that data, the parts of the
##   table (header, stub, spanners, column labels, body, footer), the formats, the styles and the
##   options. Every verb (`tabHeader`, `fmtNumber`, ...) takes a `Tabella` and returns a new one,
##   and nothing is computed for display until the table is rendered.
##
## The data is a `ref`, so copying a `Tabella` (as every verb does, or moves with `sink`) copies only
## the spec, never the data.

import std/[strutils, math, options, sequtils, tables]
export options

# ------------------------------------------------------------------------------------------ values

type
  ValueKind* = enum
    vkNull, vkBool, vkInt, vkFloat, vkString

  Value* = object
    ## One cell of the table data. `vkNull` is a missing value.
    case kind*: ValueKind
    of vkNull: discard
    of vkBool: b*: bool
    of vkInt: i*: int
    of vkFloat: f*: float
    of vkString: s*: string

func null*(): Value = Value(kind: vkNull)
func toValue*(v: Value): Value = v
func toValue*(x: bool): Value = Value(kind: vkBool, b: x)
func toValue*(x: SomeInteger): Value = Value(kind: vkInt, i: int(x))
func toValue*(x: SomeFloat): Value =
  if x.isNaN: Value(kind: vkNull) else: Value(kind: vkFloat, f: float(x))
func toValue*(x: string): Value = Value(kind: vkString, s: x)
func toValue*(x: char): Value = Value(kind: vkString, s: $x)
func toValue*(x: enum): Value = Value(kind: vkString, s: $x)
func toValue*[T](x: Option[T]): Value =
  if x.isSome: toValue(x.get) else: Value(kind: vkNull)
func toValue*(x: typeof(nil)): Value = Value(kind: vkNull)

func isNull*(v: Value): bool = v.kind == vkNull
func isNumber*(v: Value): bool = v.kind in {vkInt, vkFloat}

func toFloat*(v: Value): float =
  ## The value as a float; NaN for anything that is not a number.
  case v.kind
  of vkInt: float(v.i)
  of vkFloat: v.f
  of vkBool: (if v.b: 1.0 else: 0.0)
  else: NaN

func `$`*(v: Value): string =
  ## The value as plain text, unformatted ("" for a missing value).
  case v.kind
  of vkNull: ""
  of vkBool: $v.b
  of vkInt: $v.i
  of vkFloat: $v.f
  of vkString: v.s

func `==`*(a, b: Value): bool =
  if a.kind != b.kind:
    if a.isNumber and b.isNumber: return a.toFloat == b.toFloat
    return false
  case a.kind
  of vkNull: true
  of vkBool: a.b == b.b
  of vkInt: a.i == b.i
  of vkFloat: a.f == b.f
  of vkString: a.s == b.s

# comparisons with plain Nim values, for row predicates: `where(it["mass"] > 1.0)`
func `==`*(a: Value, b: SomeNumber): bool = a.isNumber and a.toFloat == float(b)
func `==`*(a: Value, b: string): bool = a.kind == vkString and a.s == b
func `==`*(a: Value, b: bool): bool = a.kind == vkBool and a.b == b
func `<`*(a: Value, b: SomeNumber): bool = a.isNumber and a.toFloat < float(b)
func `<`*(a: SomeNumber, b: Value): bool = b.isNumber and float(a) < b.toFloat
func `<=`*(a: Value, b: SomeNumber): bool = a.isNumber and a.toFloat <= float(b)
func `<=`*(a: SomeNumber, b: Value): bool = b.isNumber and float(a) <= b.toFloat
func `<`*(a: Value, b: string): bool = a.kind == vkString and a.s < b
func `<`*(a, b: Value): bool =
  if a.isNumber and b.isNumber: a.toFloat < b.toFloat
  elif a.kind == vkString and b.kind == vkString: a.s < b.s
  else: false

# -------------------------------------------------------------------------------------------- data

type
  Column* = object
    name*: string
    values*: seq[Value]

  TableData* = ref object
    ## Named columns of equal length. Built once (from rows, columns or CSV) and only read.
    columns*: seq[Column]

func nrows*(d: TableData): int = (if d.columns.len == 0: 0 else: d.columns[0].values.len)
func ncols*(d: TableData): int = d.columns.len
func names*(d: TableData): seq[string] = d.columns.mapIt(it.name)

func colIndex*(d: TableData, name: string): int =
  for i, c in d.columns:
    if c.name == name: return i
  -1

func hasColumn*(d: TableData, name: string): bool = d.colIndex(name) >= 0

func `[]`*(d: TableData, name: string): lent Column =
  let i = d.colIndex(name)
  if i < 0: raise newException(KeyError, "no column named " & name.escape & " (columns: " & d.names.join(", ") & ")")
  d.columns[i]

func `[]`*(d: TableData, name: string, row: int): Value = d[name].values[row]

func kindOf*(c: Column): ValueKind =
  ## The kind of a column: the kind of its non-missing values (vkFloat when ints and floats mix).
  result = vkNull
  for v in c.values:
    if v.kind == vkNull: continue
    if result == vkNull: result = v.kind
    elif result != v.kind:
      if {result, v.kind} == {vkInt, vkFloat}: result = vkFloat
      else: return vkString

func isNumeric*(c: Column): bool = c.kindOf in {vkInt, vkFloat}

proc addColumn*(d: TableData, name: string, values: seq[Value]) =
  if d.columns.len > 0 and values.len != d.nrows:
    raise newException(ValueError, "column " & name.escape & " has " & $values.len &
      " values, the table has " & $d.nrows & " rows")
  if d.hasColumn(name): raise newException(ValueError, "duplicate column " & name.escape)
  d.columns.add Column(name: name, values: values)

proc toTableData*[T: object | tuple](rows: openArray[T]): TableData =
  ## Rows as Nim objects or named tuples, one field per column:
  ## `toTableData(@[(name: "Mercury", moons: 0), (name: "Earth", moons: 1)])`.
  result = TableData()
  var cols: seq[Column]
  var first = true
  for r in rows:
    var k = 0
    for fieldName, field in fieldPairs(r):
      if first: cols.add Column(name: fieldName)
      cols[k].values.add toValue(field)
      inc k
    first = false
  if first:   # no rows: still name the columns
    var r: T
    for fieldName, field in fieldPairs(r): cols.add Column(name: fieldName)
  result.columns = cols

proc toTableData*(columns: openArray[(string, seq[Value])]): TableData =
  ## Columns given as `("name", @[values])` pairs (see also the `columns:` sugar).
  result = TableData()
  for (n, vs) in columns: result.addColumn(n, vs)

func toValues*[T](xs: openArray[T]): seq[Value] =
  for x in xs: result.add toValue(x)

func inferValue(s: string): Value =
  let t = s.strip
  if t.len == 0 or t in ["NA", "NaN", "null", "NULL"]: return null()
  try:
    if t.allCharsInSet({'0'..'9', '-', '+'}) and t.len < 19: return toValue(parseInt(t))
  except ValueError: discard
  try:
    if t[0] in {'0'..'9', '-', '+', '.'} and t.allCharsInSet({'0'..'9', '-', '+', '.', 'e', 'E'}):
      return toValue(parseFloat(t))
  except ValueError: discard
  if t in ["TRUE", "true", "FALSE", "false"]: return toValue(t.toLowerAscii == "true")
  toValue(s)

func parseCsvLine(line: string, sep: char): seq[string] =
  var cur = ""
  var quoted = false
  var i = 0
  while i < line.len:
    let c = line[i]
    if quoted:
      if c == '"':
        if i + 1 < line.len and line[i + 1] == '"': (cur.add '"'; inc i)
        else: quoted = false
      else: cur.add c
    elif c == '"': quoted = true
    elif c == sep: (result.add cur; cur = "")
    else: cur.add c
    inc i
  result.add cur

proc parseCsv*(text: string, sep = ',', comment = ""): TableData =
  ## A CSV text with a header line. Each value is read as an int, a float, a bool, a missing value
  ## (empty, NA) or else a string; a column mixing ints and floats is a float column. With a
  ## `comment` such as `"#"`, a line that starts with it (after any spaces) is skipped, so a file
  ## can say where its data comes from.
  result = TableData()
  var header: seq[string]
  var cols: seq[seq[Value]]
  for line in text.splitLines:
    if line.strip.len == 0: continue
    if comment.len > 0 and line.strip(trailing = false).startsWith(comment): continue
    let fields = parseCsvLine(line, sep)
    if header.len == 0:
      header = fields
      cols.setLen header.len
    else:
      for k in 0 ..< header.len:
        cols[k].add inferValue(if k < fields.len: fields[k] else: "")
  for k, h in header:
    var vs = cols[k]
    if Column(values: vs).kindOf == vkFloat:
      for v in vs.mitems:
        if v.kind == vkInt: v = toValue(float(v.i))
    result.addColumn(h, vs)

proc readCsv*(path: string, sep = ',', comment = ""): TableData =
  ## `parseCsv` of a file.
  parseCsv(readFile(path), sep, comment)

type Row* = object
  ## One row of the data, as seen by a row predicate (`where`): `it["mass"]`, `it.index`.
  data*: TableData
  index*: int

func `[]`*(r: Row, name: string): Value = r.data[name, r.index]

# -------------------------------------------------------------------------------------------- text

type
  TextKind* = enum
    tkPlain, tkMarkdown, tkHtml
  Text* = object
    ## A label or note: plain text (escaped when rendered), Markdown, or raw HTML.
    kind*: TextKind
    s*: string

func md*(s: string): Text = Text(kind: tkMarkdown, s: s)
  ## Markdown text, for labels and notes: `md("**Mass** (10^24^ kg)")`.
func html*(s: string): Text = Text(kind: tkHtml, s: s)
  ## Raw HTML text, used as is.
converter toText*(s: string): Text = Text(kind: tkPlain, s: s)
func isEmpty*(t: Text): bool = t.s.len == 0

# --------------------------------------------------------------------------------------- selectors

type
  ColSelKind* = enum
    csNames, csAll, csStartsWith, csEndsWith, csContains, csNumeric, csTextual
  ColSel* = object
    ## Which columns a verb applies to. A string or an array of strings converts to one, and
    ## `everything()`, `startsWith(...)`, `endsWith(...)`, `containing(...)`, `numeric()`,
    ## `textual()` select by rule. Resolved against the data when the verb is called.
    case kind*: ColSelKind
    of csNames: names*: seq[string]
    of csStartsWith, csEndsWith, csContains: part*: string
    else: discard

converter toColSel*(name: string): ColSel = ColSel(kind: csNames, names: @[name])
converter toColSel*[N: static int](names: array[N, string]): ColSel = ColSel(kind: csNames, names: @names)
converter toColSel*(names: seq[string]): ColSel = ColSel(kind: csNames, names: names)
func cols*(names: varargs[string]): ColSel = ColSel(kind: csNames, names: @names)
func everything*(): ColSel = ColSel(kind: csAll)
func startsWith*(prefix: string): ColSel = ColSel(kind: csStartsWith, part: prefix)
func endsWith*(suffix: string): ColSel = ColSel(kind: csEndsWith, part: suffix)
func containing*(part: string): ColSel = ColSel(kind: csContains, part: part)
func numeric*(): ColSel = ColSel(kind: csNumeric)
func textual*(): ColSel = ColSel(kind: csTextual)

func resolve*(sel: ColSel, d: TableData): seq[string] =
  case sel.kind
  of csNames:
    for n in sel.names:
      if not d.hasColumn(n):
        raise newException(KeyError, "no column named " & n.escape & " (columns: " & d.names.join(", ") & ")")
    sel.names
  of csAll: d.names
  of csStartsWith: d.names.filterIt(it.startsWith(sel.part))
  of csEndsWith: d.names.filterIt(it.endsWith(sel.part))
  of csContains: d.names.filterIt(sel.part in it)
  of csNumeric: d.columns.filterIt(it.isNumeric).mapIt(it.name)
  of csTextual: d.columns.filterIt(it.kindOf == vkString).mapIt(it.name)

type
  RowSelKind* = enum
    rsAll, rsIndices, rsWhere
  RowSel* = object
    ## Which rows a verb applies to: all of them (the default), indices (`[0, 2]`, `0..3`, 0-based)
    ## or a predicate (`where(it["mass"] > 1)`).
    case kind*: RowSelKind
    of rsIndices: indices*: seq[int]
    of rsWhere: pred*: proc (r: Row): bool
    of rsAll: discard

func allRows*(): RowSel = RowSel(kind: rsAll)
converter toRowSel*(i: int): RowSel = RowSel(kind: rsIndices, indices: @[i])
converter toRowSel*[N: static int](ix: array[N, int]): RowSel = RowSel(kind: rsIndices, indices: @ix)
converter toRowSel*(ix: seq[int]): RowSel = RowSel(kind: rsIndices, indices: ix)
converter toRowSel*(s: HSlice[int, int]): RowSel = RowSel(kind: rsIndices, indices: toSeq(s))

template where*(cond: untyped): RowSel =
  ## Rows where `cond` holds, with `it` the row: `where(it["type"] == "Gas giant")`.
  RowSel(kind: rsWhere, pred: proc (it {.inject.}: Row): bool = cond)

proc resolve*(sel: RowSel, d: TableData): seq[int] =
  case sel.kind
  of rsAll: toSeq(0 ..< d.nrows)
  of rsIndices:
    for i in sel.indices:
      if i < 0 or i >= d.nrows: raise newException(IndexDefect, "row " & $i & " out of 0..<" & $d.nrows)
    sel.indices
  of rsWhere: toSeq(0 ..< d.nrows).filterIt(sel.pred(Row(data: d, index: it)))

# ------------------------------------------------------------------------------------------ styles

type
  CellStyle* = object
    ## CSS declarations for some cells. Build with `style.fill`, `style.text`, `style.borders` and
    ## join with `&`: `style.fill("#fff3b0") & style.text(weight = "bold")`.
    css*: seq[(string, string)]

  StyleNs* = object ## the `style` namespace: `style.fill(...)`, as in Great Tables
  LocNs* = object   ## the `loc` namespace: `loc.body(...)`, as in Great Tables

const
  style* = StyleNs()
  loc* = LocNs()

func `&`*(a, b: CellStyle): CellStyle = CellStyle(css: a.css & b.css)

func fill*(_: StyleNs, color: string): CellStyle =
  CellStyle(css: @{"background-color": color})

func text*(_: StyleNs, color = "", font = "", size = "", align = "", weight = "", style = "",
           decorate = "", transform = "", whitespace = ""): CellStyle =
  for (k, v) in {"color": color, "font-family": font, "font-size": size, "text-align": align,
                 "font-weight": weight, "font-style": style, "text-decoration": decorate,
                 "text-transform": transform, "white-space": whitespace}:
    if v.len > 0: result.css.add (k, v)

type Side* = enum sTop = "top", sRight = "right", sBottom = "bottom", sLeft = "left"

func borders*(_: StyleNs, sides: set[Side] = {sTop, sRight, sBottom, sLeft}, color = "#000000",
              style = "solid", weight = "1px"): CellStyle =
  for s in sides:
    result.css.add ("border-" & $s, weight & " " & style & " " & color)

func css*(_: StyleNs, declarations: string): CellStyle =
  ## Any CSS, as declarations: `style.css("letter-spacing: 0.1em; font-variant: small-caps")`.
  for d in declarations.split(';'):
    let kv = d.split(':', 1)
    if kv.len == 2 and kv[0].strip.len > 0: result.css.add (kv[0].strip, kv[1].strip)

func toCss*(s: CellStyle): string = s.css.mapIt(it[0] & ": " & it[1]).join("; ")

# ------------------------------------------------------------------------------------------- spec

type
  Align* = enum
    alAuto = "auto", alLeft = "left", alCenter = "center", alRight = "right"

  ColRole* = enum
    crData, crStub, crGroup

  ColInfo* = object
    ## The boxhead entry of one column: how its label and cells are shown.
    name*: string
    label*: Text
    align*: Align
    width*: string
    hidden*: bool
    role*: ColRole

  Spanner* = object
    ## A label over a run of columns; `level` 1 sits right above the column labels.
    label*: Text
    columns*: seq[string]
    level*: int

  RenderContext* = enum
    rcHtml, rcText

  FormatFn* = proc (v: Value, ctx: RenderContext): string
    ## Turns one value into its shown text. In `rcHtml` the result is HTML (escape what you add).

  FormatRule* = object
    columns*: seq[string]
    rows*: seq[int]         ## empty: every row
    fn*: FormatFn
    nullsToo*: bool         ## also called on missing values (substitutions are)

  LocKind* = enum
    lkTitle, lkSubtitle, lkStubhead, lkSpanners, lkColumnLabels, lkStub, lkRowGroups, lkBody,
    lkFootnotes, lkSourceNotes, lkHeader, lkColumnHeader, lkFooter,
    lkSummary, lkSummaryStub, lkGrandSummary, lkGrandSummaryStub

  Target* = object
    ## A resolved location: `cells` for the body and the stub (row, column), `names` for
    ## column labels, spanners and row groups. For summary rows, `names` are the groups, `labels`
    ## the labels of the summary rows (empty: all of them) and `columns` the columns.
    kind*: LocKind
    cells*: seq[(int, string)]
    names*: seq[string]
    labels*: seq[string]
    columns*: seq[string]

  Loc* = object
    ## An unresolved location, from the `loc` namespace: `loc.body(cols = "mass", rows = [0])`.
    kind*: LocKind
    cols*: ColSel
    rows*: RowSel
    names*: seq[string]
    labels*: seq[string]   ## summary rows, by label

  StyleRule* = object
    target*: Target
    style*: CellStyle

  Footnote* = object
    note*: Text
    target*: Target

  TransformRule* = object
    ## A proc over the shown text of the cells at a location (`textTransform`).
    target*: Target
    fn*: proc (s: string): string

  Aggregate* = object
    ## How a summary row sums up a column: a proc from the column's non-missing values (of the
    ## group, or of the whole table) to one value. Built in: `agg.sum`, `agg.mean`, `agg.median`,
    ## `agg.min`, `agg.max`, `agg.count`, `agg.sd`; any proc with `aggregate(myProc)`.
    name*: string          ## "sum", "count", ... ("" for a proc of your own)
    fn*: proc (values: seq[Value]): Value

  AggNs* = object ## the `agg` namespace: `agg.sum`, `agg.mean`, ...

  SummaryRule* = object
    ## Summary rows added by `summaryRows` (for some groups) or `grandSummaryRows` (`grand`).
    grand*: bool
    groups*: seq[string]       ## the groups summarised (empty: all of them)
    columns*: seq[string]      ## the columns summarised; the others show `missingText`
    fns*: seq[(string, Aggregate)]   ## (label, aggregate): one row each
    top*: bool                 ## above the group (or the table) instead of below
    fmt*: FormatFn             ## nil: the column's format
    missingText*: string

  FootnoteMarks* = enum
    fmNumbers, fmLetters, fmCapitals, fmStandard, fmExtended

  TabOptions* = object
    ## Table-wide looks, like gt's `tab_options()`. Change any subset with
    ## `tabOptions(rowStriping = true, tableFontSize = "14px")`.
    tableWidth* = "auto"
    tableMarginLeft* = "auto"
    tableMarginRight* = "auto"
    tableFontNames* = "system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
    tableFontSize* = "16px"
    tableFontColor* = "#333333"
    tableBackgroundColor* = "#FFFFFF"
    tableBorderTopColor* = "#A8A8A8"
    tableBorderTopWidth* = "2px"
    tableBorderBottomColor* = "#A8A8A8"
    tableBorderBottomWidth* = "2px"
    headingAlign* = "center"
    headingBackgroundColor* = ""
    headingTitleFontSize* = "125%"
    headingTitleFontWeight* = "initial"
    headingSubtitleFontSize* = "85%"
    headingSubtitleFontWeight* = "normal"
    headingBorderBottomColor* = "#D3D3D3"
    columnLabelsBackgroundColor* = ""
    columnLabelsFontSize* = "100%"
    columnLabelsFontWeight* = "normal"
    columnLabelsTextTransform* = "inherit"
    columnLabelsBorderBottomColor* = "#D3D3D3"
    columnLabelsBorderBottomWidth* = "2px"
    rowGroupBackgroundColor* = ""
    rowGroupFontWeight* = "initial"
    rowGroupBorderColor* = "#D3D3D3"
    stubBackgroundColor* = ""
    stubFontWeight* = "initial"
    headingPadding* = "4px"
    headingPaddingHorizontal* = "5px"
    columnLabelsPadding* = "5px"
    columnLabelsPaddingHorizontal* = "5px"
    dataRowPadding* = "8px"
    dataRowPaddingHorizontal* = "5px"
    tableBorderTopStyle* = "solid"
    tableBorderBottomStyle* = "solid"
    tableBorderLeftStyle* = "none"
    tableBorderLeftWidth* = "2px"
    tableBorderLeftColor* = "#D3D3D3"
    tableBorderRightStyle* = "none"
    tableBorderRightWidth* = "2px"
    tableBorderRightColor* = "#D3D3D3"
    tableBodyVlinesColor* = "" ## "" for no vertical lines
    tableBodyHlinesColor* = "#D3D3D3"
    rowStriping* = false
    rowStripingBackgroundColor* = "rgba(128,128,128,0.05)"
    summaryRowBackgroundColor* = ""     ## "" for the table's background
    summaryRowTextTransform* = "inherit"
    summaryRowPadding* = "8px"
    summaryRowPaddingHorizontal* = "5px"
    summaryRowBorderStyle* = "solid"
    summaryRowBorderWidth* = "2px"
    summaryRowBorderColor* = "#D3D3D3"
    grandSummaryRowBackgroundColor* = ""
    grandSummaryRowTextTransform* = "inherit"
    grandSummaryRowPadding* = "8px"
    grandSummaryRowPaddingHorizontal* = "5px"
    grandSummaryRowBorderStyle* = "double"
    grandSummaryRowBorderWidth* = "6px"
    grandSummaryRowBorderColor* = "#D3D3D3"
    footnotesFontSize* = "90%"
    footnotesMarks* = fmNumbers
    footnotesMarksCustom*: seq[string]  ## marks of your own; when set, `footnotesMarks` is ignored
    footnotesSpecRef* = "^"     ## how marks look in the table: ^ raised, i italic, b bold, ( or [ around
    footnotesSpecFtr* = "^"     ## the same, in the footer
    footnotesOrder* = "marks_first"  ## or "marks_last", "preserve_order"
    sourceNotesFontSize* = "90%"
    containerOverflowX* = "auto"
    extraCss* = ""          ## more CSS, scoped to the table when it starts with ` ` or `.`

  Tabella* = object
    ## A display table: the data and everything said about how to show it.
    data*: TableData
    boxhead*: seq[ColInfo]
    title*, subtitle*: Text
    caption*: Text
    stubhead*: Text
    rownameCol*, groupnameCol*: string
    groupLabels*: OrderedTable[string, Text]   ## group id -> label, in display order
    rowGroups*: seq[string]                    ## group id of each row ("" when ungrouped)
    rowOrder*: seq[int]                        ## rows in display order (empty: as in the data)
    spanners*: seq[Spanner]
    formats*: seq[FormatRule]
    substitutions*: seq[FormatRule]
    styles*: seq[StyleRule]
    transforms*: seq[TransformRule]
    footnotes*: seq[Footnote]
    sourceNotes*: seq[Text]
    summaries*: seq[SummaryRule]
    options*: TabOptions
    locale*: string
    id*: string

func colInfo*(t: Tabella, name: string): ColInfo =
  for c in t.boxhead:
    if c.name == name: return c
  raise newException(KeyError, "no column named " & name.escape)

func visibleData*(t: Tabella): seq[ColInfo] =
  ## The data columns shown in the body, in display order (not the stub, groups or hidden ones).
  t.boxhead.filterIt(it.role == crData and not it.hidden)

func hasSummaries*(t: Tabella): bool = t.summaries.len > 0
func hasStub*(t: Tabella): bool = t.rownameCol.len > 0 or t.hasSummaries
  ## A stub is shown for the row names, and for the labels of summary rows (as in gt, a table
  ## with summary rows and no row names gets an empty stub).
func hasRowNames*(t: Tabella): bool = t.rownameCol.len > 0
func hasGroups*(t: Tabella): bool = t.groupLabels.len > 0
