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
## line of `body` as a verb applied to the table (no chaining dots needed), and `tableData:`,
## which reads columns as `name: [values]`, with `nil` for a missing value.

import std/macros
import tabelline/[core, formats, units, colors, verbs, build, render_html, render_text]
export core, formats, units, colors, verbs, build, render_html, render_text

proc rewriteVerbs(body, it: NimNode): NimNode =
  ## Each call statement `verb(args)` becomes `it = verb(it, args)`; `for`, `if`, `when` and
  ## `block` bodies are rewritten too, other statements are left as they are.
  case body.kind
  of nnkStmtList:
    result = newStmtList()
    for s in body: result.add rewriteVerbs(s, it)
  of nnkCall, nnkCommand:
    if body[0].kind in {nnkIdent, nnkSym, nnkOpenSymChoice, nnkClosedSymChoice} and
        body[0].strVal notin ["echo", "discard", "doAssert", "assert", "debugEcho"]:
      var call = newCall(body[0], it)
      for k in 1 ..< body.len: call.add body[k]
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

macro tabella*(args: varargs[untyped]): untyped =
  ## `tabella(data, rownameCol = "name")` is a table for `data` (see `initTabella`), and with a body,
  ## `tabella(data): body` is that table changed by the verbs in `body`, one per line, without
  ## repeating the table: `tabHeader "Title"` stands for `t = t.tabHeader("Title")`.
  ## (A macro, not a proc: a proc overload would make Nim check the body before rewriting it.)
  let hasBody = args.len >= 2 and args[^1].kind == nnkStmtList
  var create = newCall(bindSym("initTabella", brOpen))
  for k in 0 ..< args.len - (if hasBody: 1 else: 0): create.add args[k]
  if not hasBody: return create
  let it = genSym(nskVar, "tabella")
  result = newBlockStmt(newStmtList(newVarStmt(it, create), rewriteVerbs(args[^1], it), it))

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
