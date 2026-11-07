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
import tabelline/[core, formats, colors, verbs, build, render_html, render_text]
export core, formats, colors, verbs, build, render_html, render_text

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

macro tableData*(body: untyped): TableData =
  ## Columns as `name: [values]` lines, each value converted on its own, so a column can mix
  ## numbers with `nil` (missing):
  ##
  ## ```nim
  ## let d = tableData:
  ##   planet: ["Mercury", "Venus"]
  ##   moons: [0, nil]
  ## ```
  result = newCall(bindSym"toTableData")
  var pairs = newNimNode(nnkBracket)
  for line in body:
    if line.kind notin {nnkCall, nnkCommand} or line.len != 2:
      error("expected `name: [values]`", line)
    var name = ""
    if line[0].kind == nnkAccQuoted:   # `size.mass`: every part of the quoted name
      for p in line[0]: name.add p.strVal
    else: name = line[0].strVal
    var vals = line[1]
    if vals.kind == nnkStmtList: vals = vals[0]
    var vs = newNimNode(nnkBracket)
    if vals.kind == nnkBracket:
      for v in vals: vs.add newCall(bindSym"toValue", v)
      pairs.add nnkTupleConstr.newTree(newLit(name), prefix(vs, "@"))
    else:
      pairs.add nnkTupleConstr.newTree(newLit(name), newCall(bindSym"toValues", vals))
  result.add pairs
