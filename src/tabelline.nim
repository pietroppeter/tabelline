## tabelline: great tables for Nim.
##
## Display tables built from parts (a header, a stub, spanners, column labels, the body, a
## footer), with formatted values and styles, rendered to HTML (and to text and Markdown).
## Inspired by R's gt and Python's Great Tables, written in plain Nim.
##
## ```nim
## import tabelline
## let t = tabella(planets, rownameCol = "planet", groupnameCol = "type"):
##   tabHeader "The planets", "of the Solar System"
##   tabSpanner "Size", ["diameter", "mass"]
##   fmtNumber "mass", decimals = 3
##   dataColor "moons", palette = palette("pastelli")
## echo t          # a text table
## t.save "planets.html"
## ```
##
## Two macros, where plain procs cannot do the job: `tabella(data): body`, which reads each
## line of `body` as a verb applied to the table (no chaining dots needed, and a verb that takes
## a list of pairs may take them as an indented block, one per line), and `tableData:`, which
## reads columns as `name: [values]`, with `nil` for a missing value.

import std/[macros, strutils]
import tabelline/[core, formats, units, colors, verbs, build, render_html, render_text, extract]
export core, formats, units, colors, verbs, build, render_html, render_text, extract

const pairVerbs = ["colsLabel", "colsWidth", "colsUnits", "textCaseMatch", "summaryRows",
                   "grandSummaryRows", "summaryColumns"]
  ## The verbs whose first argument is a list of pairs, which `tabella(data): body` also takes
  ## as an indented block.

func verbName(n: NimNode): string =
  if n.kind in {nnkOpenSymChoice, nnkClosedSymChoice}: n[0].strVal
  elif n.kind in {nnkIdent, nnkSym}: n.strVal
  else: ""

proc pairLabel(n: NimNode): NimNode =
  ## The label of a block line: `total`, `"all moons"` or `` `mass (kg)` `` is a string.
  case n.kind
  of nnkIdent, nnkSym: newLit(n.strVal)
  of nnkOpenSymChoice, nnkClosedSymChoice: newLit(n[0].strVal)
  of nnkStrLit, nnkRStrLit, nnkTripleStrLit: n
  of nnkAccQuoted: (var s = ""; (for p in n: s.add p.strVal); newLit(s))
  else: (error("expected a label: a name or a string", n); n)

proc blockArgs(verb: string, blk: NimNode): seq[NimNode] =
  ## The arguments an indented block stands for. In a verb of `pairVerbs`, a line `label: value`
  ## is a pair of the list; in any verb, a line `name = value` is that named argument; in a
  ## summary verb, a line `fmtNumber(decimals = 1)` is `fmt`, a proc of a float that calls
  ## `formatNumber(x, decimals = 1)`.
  var pairs = newNimNode(nnkTableConstr)
  for line in blk:
    if line.kind in {nnkCall, nnkCommand} and line.len == 2 and line[1].kind == nnkStmtList and
        verb in pairVerbs:
      let value = if line[1].len == 1: line[1][0] else: line[1]
      pairs.add newColonExpr(pairLabel(line[0]), value)
    elif line.kind == nnkAsgn:
      result.add newNimNode(nnkExprEqExpr).add(line[0], line[1])
    elif line.kind in {nnkCall, nnkCommand} and verbName(line[0]).startsWith("fmt") and
        verb in ["summaryRows", "grandSummaryRows", "summaryColumns"]:
      let name = verbName(line[0])
      let f = ident("format" & name[3 .. ^1])
      let x = ident("x")
      var call = newCall(f, x)
      for k in 1 ..< line.len: call.add line[k]
      let lambda = newProc(params = [ident("string"), newIdentDefs(x, ident("float"))],
                           body = newStmtList(call), procType = nnkLambda)
      result.add newNimNode(nnkExprEqExpr).add(ident("fmt"), lambda)
    else:
      error("a line of a " & verb & " block is `label: value`, `name = value`" &
            (if verb in ["summaryRows", "grandSummaryRows", "summaryColumns"]: " or a fmt* call" else: ""), line)
  if pairs.len > 0: result.insert(pairs, 0)

proc rewriteVerbs(body, it: NimNode): NimNode =
  ## Each call statement `verb(args)` becomes `it = verb(it, args)`; `for`, `if`, `when` and
  ## `block` bodies are rewritten too, other statements are left as they are. A verb may end in
  ## an indented block (`blockArgs`): `summaryRows:` then `total: agg.sum` on the next line.
  case body.kind
  of nnkStmtList:
    result = newStmtList()
    for s in body: result.add rewriteVerbs(s, it)
  of nnkCall, nnkCommand:
    if body[0].kind in {nnkIdent, nnkSym, nnkOpenSymChoice, nnkClosedSymChoice} and
        verbName(body[0]) notin ["echo", "discard", "doAssert", "assert", "debugEcho"]:
      var call = newCall(body[0], it)
      let verb = verbName(body[0])
      let hasBlock = body.len >= 2 and body[^1].kind == nnkStmtList and verb != "tabOptions"
      for k in 1 ..< body.len - (if hasBlock: 1 else: 0): call.add body[k]
      if hasBlock:
        let extra = blockArgs(verb, body[^1])
        # the list of pairs is the verb's first argument; named arguments may follow anywhere
        for a in extra:
          if a.kind == nnkTableConstr: call.insert(2, a)
          else: call.add a
      elif body.len >= 2 and body[^1].kind == nnkStmtList and verb == "tabOptions":
        call.del(call.len - 1)
        for line in body[^1]:
          if line.kind != nnkAsgn: error("a line of a tabOptions block is `name = value`", line)
          call.add newNimNode(nnkExprEqExpr).add(line[0], line[1])
      result = newAssignment(it, call)
    else:
      result = body
  of nnkForStmt, nnkWhileStmt, nnkBlockStmt:
    result = body.copyNimTree
    result[^1] = rewriteVerbs(body[^1], it)
  of nnkIfStmt, nnkWhenStmt:
    result = body.copyNimTree
    for k in 0 ..< result.len: result[k][^1] = rewriteVerbs(body[k][^1], it)
  else:
    result = body

proc withBody(init, args: NimNode): NimNode =
  ## `init(args)`, and when the last argument is a body, that table changed by the body's verbs.
  let hasBody = args.len >= 2 and args[^1].kind == nnkStmtList
  var create = newCall(init)
  for k in 0 ..< args.len - (if hasBody: 1 else: 0): create.add args[k]
  if not hasBody: return create
  let it = genSym(nskVar, "tabella")
  result = newBlockStmt(newStmtList(newVarStmt(it, create), rewriteVerbs(args[^1], it), it))

macro tabella*(args: varargs[untyped]): untyped =
  ## `tabella(data, rownameCol = "name")` is a table for `data` (see `initTabella`), and with a body,
  ## `tabella(data): body` is that table changed by the verbs in `body`, one per line, without
  ## repeating the table: `tabHeader "Title"` stands for `t = t.tabHeader("Title")`.
  ##
  ## A verb in `body` may end with an indented block. In a verb whose first argument is a list of
  ## pairs (`colsLabel`, `colsWidth`, `colsUnits`, `textCaseMatch`, `summaryRows`,
  ## `grandSummaryRows`, `summaryColumns`) a line `label: value` is a pair; in any verb a line
  ## `name = value` is a named argument; in a summary verb a line `fmtNumber(decimals = 1)` is
  ## `fmt = (x: float) => formatNumber(x, decimals = 1)`; `tabOptions:` takes `name = value`:
  ##
  ## ```nim
  ## let t = tabella(planets(), rownameCol = "planet", groupnameCol = "type"):
  ##   colsLabel:
  ##     mass: "mass, {{10^24 kg}}"
  ##   summaryRows:
  ##     total: agg.sum
  ##     "the largest": agg.max
  ##     columns = "mass"
  ##     fmtNumber(decimals = 1)
  ## ```
  ## (A macro, not a proc: a proc overload would make Nim check the body before rewriting it.)
  withBody(bindSym("initTabella", brOpen), args)

macro tabellaPreview*(args: varargs[untyped]): untyped =
  ## `tabellaPreview(data, topN = 5, bottomN = 1)` is a preview of a big table (see
  ## `initTabellaPreview`), and with a body it is changed by the verbs in the body, as in `tabella`:
  ##
  ## ```nim
  ## let t = tabellaPreview(citta(), topN = 3):
  ##   fmtInteger "population"
  ## ```
  withBody(bindSym("initTabellaPreview", brOpen), args)

proc columnName(n: NimNode): string =
  ## The name of a `tableData:` column: `mass`, `size.mass` (a dotted name, for `tabSpannerDelim`)
  ## or anything quoted, `` `mass (kg)` ``.
  case n.kind
  of nnkIdent, nnkSym, nnkStrLit: n.strVal
  of nnkAccQuoted: (var s = ""; (for p in n: s.add p.strVal); s)
  of nnkOpenSymChoice, nnkClosedSymChoice: n[0].strVal   # a name bound inside a template (`count`)
  of nnkDotExpr: columnName(n[0]) & "." & columnName(n[1])
  else: (error("expected a column name", n); "")

proc columnLines(body, data: NimNode): NimNode =
  ## The lines of a `tableData:` body, each `name: values` becoming `data.addColumn(name, values)`;
  ## `for` and `if` bodies are read the same way.
  case body.kind
  of nnkStmtList:
    result = newStmtList()
    for line in body: result.add columnLines(line, data)
  of nnkForStmt:
    result = body.copyNimTree
    result[^1] = columnLines(body[^1], data)
  of nnkIfStmt:
    result = body.copyNimTree
    for k in 0 ..< result.len: result[k][^1] = columnLines(body[k][^1], data)
  else:
    var name, vals: NimNode
    if body.kind in {nnkCall, nnkCommand} and body.len == 2:
      # `mass: [...]`, or `(expr): [...]` for a name computed when the line runs
      name = (if body[0].kind == nnkPar: body[0][0] else: newLit(columnName(body[0])))
      vals = body[1]
    elif body.kind == nnkPrefix and body.len == 3:
      # `$j: [...]`: Nim reads the colon's block as the prefix call's last argument
      name = newCall(body[0], body[1])
      vals = body[2]
    else:
      error("expected `name: [values]`, or a `for` or `if` of them", body)
    if vals.kind == nnkStmtList: vals = vals[0]
    var values: NimNode
    if vals.kind == nnkBracket:
      var vs = newNimNode(nnkBracket)
      for v in vals: vs.add newCall(bindSym"toValue", v)
      values = prefix(vs, "@")
    else:
      values = newCall(bindSym"toValues", vals)
    result = newCall(bindSym"addColumn", data, name, values)

macro tableData*(body: untyped): TableData =
  ## Columns as `name: [values]` lines, each value converted on its own, so a column can mix
  ## numbers with `nil` (missing). A name can have dots, `size.mass: [...]`, or be quoted.
  ## Values can be any list, such as a `collect`. A `for` (or `if`) adds the columns in its body,
  ## and their names can be computed: `$j: [...]`, or any expression in parentheses.
  ##
  ## ```nim
  ## let d = tableData:
  ##   planet: ["Mercury", "Venus"]
  ##   moons: [0, nil]
  ## let tavola = tableData:
  ##   `×`: collect(for i in 1 .. 3: i)
  ##   for j in 1 .. 3:
  ##     $j: collect(for i in 1 .. 3: i * j)
  ## ```
  let data = genSym(nskVar, "data")
  result = newBlockStmt(newStmtList(
    newVarStmt(data, nnkObjConstr.newTree(bindSym"TableData")),
    columnLines(body, data),
    data))
