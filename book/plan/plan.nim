## Searches the sources the book plans to port, and maps every page to the features it needs.
##
##     nim r book/plan/plan.nim                 # search the sources, write pages.json
##     nim r book/plan/plan.nim --offline       # the same, from the copies in book/plan/cache/
##     nim r book/plan/plan.nim fmt_currency    # the pages that show a feature (a gt function or
##     nim r book/plan/plan.nim "row groups"    #   words of a feature's name), simplest first
##
## Every source in book/plan/sources.json says where its pages are: a GitHub repository and the
## paths of its pages (`find`). The search lists the repository's files with a shallow, blobless
## git clone into book/plan/cache/ (no API, no token), so a page added upstream is found, and a page
## listed by hand that is no longer there is reported. The pages listed in sources.json are only
## the ones the book has something to say about (a title, `port`, a `note`, gaps `found`); a page
## found and not listed gets `port: "triage"` until someone reads it.
##
## Three kinds of source:
## - a guide, a blog, a gallery: one page per file (Quarto, R Markdown or a notebook), its code in
##   the ```{python} and ```{r} chunks;
## - a contest: one page per entry, a whole repository (`find.entries`, collected by
##   book/plan/contest.nim), its code read from every R, Python, R Markdown, Quarto and
##   notebook file but the README; `gtsave` does not count, it only shares the table;
## - a reference: the examples on the help page of every function. For gt, the `Examples` section
##   of each `man/*.Rd`; for Great Tables, the `Examples` section of the docstring of every name in
##   the API reference (`docs/_quarto.yml`), found by following the imports in `great_tables/`
##   (read with a small reader of Python's statements, below).
##
## For each page the search finds the gt and Great Tables functions its code calls and looks each
## one up in the coverage map (docs/coverage/gt.json). A page is ready in the first release that
## has every feature it calls. It sees the functions, not their arguments, so a page ready by this
## measure can still find gaps when it is ported (the Get Started guide found a dozen). Those go to
## book/gaps.md and to the page's `found`.
##
## It writes book/plan/pages.json: every page, by source, with the commit it was read at, what it
## waits for (`needs`) and every feature of the map it shows (`uses`). The book reads it, and so
## does the search by feature (the command with words), which lists first the help pages of the
## feature's own functions, then the other pages from the smallest.
import std/[algorithm, sets]
import common

const
  now = "now"          ## in tabelline on main: 0.1 and 0.2
  shipped = ["0.1", "0.2"]
  releases = [now]     ## anything planned after 0.2 is `later`
  later = "later"      ## not planned for a release yet
  newGap = "new"       ## a gap the coverage map does not have yet
  otherTool = "other"  ## a contest entry made with another table package than gt: not measured
  order = @releases & @[newGap, later, otherTool]

  # gt-extras and gtExtras functions: plots, icons and themes in cells, planned with nanoplots.
  extras = r"\bgte\.\w+|\b(?:gte\.)?(gt_plt_\w+|gt_theme_\w+|gt_color_\w+|gt_fa_\w+|gt_highlight_\w+|" &
           r"gt_hulk_\w+|gt_merge_stack|gt_add_divider|gt_img_\w+|gt_sparkline|gt_\w+_rating|" &
           r"fa_icon_repeat|fmt_pct_extra|fmt_pill|add_text_img|img_header)\s*\("
  extrasFeature = ("Plots, icons and themes from gt-extras", later)
  # Tables made with another package than gt: interactive ones (reactable, DT) wait for tabellone.
  other = r"\b(reactable|reactablefmtr|datatable|DT::datatable|flextable|kable)\s*\("
  otherFeature = "Interactive tables"

# ---------------------------------------------------------------- the coverage map

type Coverage = object
  rows: seq[JsonNode]               ## every row of the map, with its area
  exact: OrderedTable[string, int]  ## a function's name: its row
  prefix: seq[(string, int)]        ## `fmt_*`: the longest first
  args: OrderedTable[string, int]   ## an argument (`groupname_col=`): its row

proc coverage(): Coverage =
  let cov = parseJson(readText(root / "docs" / "coverage" / "gt.json"))
  for a in cov["areas"]:
    for r in a["rows"]:
      let row = r.copy
      row["area"] = a["title"]
      result.rows.add row
  for i, r in result.rows:
    let gt = r["gt"].getStr
    for tok in gt.findAll1(r"(?:^|,\s*)([a-z_]+)=?(?=,|$)"):  # an argument: groupname_col
      if tok notin result.args: result.args[tok] = i
    for t in gt.findAll1(r"([A-Za-z_][\w.]*\*?)\(\)"):
      let tok = t.split(".")[^1]
      if tok.endsWith("*"): result.prefix.add (tok[0 ..< ^1], i)
      elif tok notin result.exact: result.exact[tok] = i
  result.prefix.sort(proc (a, b: (string, int)): int = cmp(b[0].len, a[0].len))

proc planOf(row: JsonNode): string =
  ## The release a coverage row is ready in.
  let status = row["status"].getStr
  if status == "done": return now
  if status == "partial" and row{"plan"}.getStr == "":
    return now  # what is there is all that is planned (fonts: no remote Google fonts)
  if status == "no":
    # "no" with a Nim way (sizes are strings) is not a gap; without one it waits
    return (if row["feature"].getStr == "Sizes": now else: later)
  let plan = row{"plan"}.getStr
  if plan in shipped: now elif plan in releases: plan else: later

const alias = {"fill": "cell_fill", "text": "cell_text", "borders": "cell_borders"}.toTable

proc calls(code: string): OrderedTable[string, int] =
  ## The functions the code calls, and how many times.
  let code = code.sub(r"^\s*#.*$", "", {reMultiLine})  # code commented out is not called
  for m in code.finditer(r"(?:\b(loc|style|vals)\.)?\b([a-z_][a-z0-9_]*)\s*\("):
    var name = m[2]
    if m[1] == "loc": name = "cells_" & name
    elif m[1] == "style": name = alias.getOrDefault(name, name)
    result.mgetOrPut(name, 0).inc
  if code.has(r"\bGT\s*\(|\bgt\s*\("): result.mgetOrPut("gt", 0).inc

proc lookup(c: Coverage, name: string): int =
  ## The row of the map for a function, or -1.
  if name in c.exact: return c.exact[name]
  if name.startsWith("loc_") and "cells_" & name[4 .. ^1] in c.exact:
    return c.exact["cells_" & name[4 .. ^1]]
  for (p, i) in c.prefix:
    if p.len > 0 and name.startsWith(p): return i
  -1

# ---------------------------------------------------------------- reading a repository

type GitError = object of CatchableError

proc repoDir(repo: string): string = cache / "repos" / repo.replace("/", "__")

proc git(d: string, args: varargs[string]): string =
  let (output, code) = run("git", @["-C", d] & @args)
  if code != 0: raise newException(GitError, "git " & args.join(" ") & ": " & output)
  output

proc listing(repo, gitRef: string, offline: bool): (string, seq[string]) =
  ## The commit of `gitRef` and every file path in it, from a shallow blobless clone.
  let d = repoDir(repo)
  if not offline:
    if not dirExists(d):
      createDir d.parentDir
      var args = @["clone", "-q", "--depth", "1", "--filter=blob:none", "--no-checkout"]
      if gitRef != "HEAD": args.add ["--branch", gitRef]  # HEAD: the default branch
      args.add ["https://github.com/" & repo, d]
      if run("git", args).code != 0:
        removeDir d
        raise newException(GitError, "cannot clone " & repo)
    else:
      discard git(d, "fetch", "-q", "--depth", "1", "--filter=blob:none", "origin", gitRef)
      discard git(d, "update-ref", "HEAD", "FETCH_HEAD")
  if not dirExists(d): raise newException(GitError, "not in the cache: " & repo)
  let commit = git(d, "rev-parse", "HEAD").strip
  (commit, git(d, "ls-tree", "-r", "-z", "--name-only", "HEAD").split('\0').filterIt(it.len > 0))

proc read(repo, commit, path: string, offline: bool): string =
  ## A file of the repository at `commit`, from raw.githubusercontent.com, kept in the cache.
  let f = cache / "files" / repo.replace("/", "__") / commit[0 ..< 12] / path
  if not fileExists(f):
    if offline: quit "not in the cache: " & repo & " " & path & " (run without --offline)"
    let url = "https://raw.githubusercontent.com/" & repo & "/" & commit & "/" & quoteUrl(path)
    if not curl(url, f): raise newException(IOError, "cannot read " & url)
  readText(f)

proc globRx(glob: string): string =
  ## Python's `fnmatch.translate`: `*` is anything, `/` too.
  var i = 0
  while i < glob.len:
    let c = glob[i]
    case c
    of '*': result.add ".*"
    of '?': result.add "."
    of '[':
      let j = glob.find(']', i + 1)
      if j < 0: result.add "\\["
      else:
        var inside = glob[i + 1 ..< j]
        if inside.startsWith("!"): inside = "^" & inside[1 .. ^1]
        result.add "[" & inside.replace("\\", "\\\\") & "]"
        i = j
    else:
      if c in {'a'..'z', 'A'..'Z', '0'..'9', '_'}: result.add c
      else: result.add "\\" & c
    inc i

proc matches(path: string, globs: JsonNode): bool =
  if globs.isNil: return false
  for g in globs:
    if path.fullMatch(globRx(g.getStr), {reDotAll}): return true

# ---------------------------------------------------------------- pages of a guide

proc joined(source: JsonNode): string =
  ## A notebook cell's source: a list of lines or one string.
  if source.kind == JArray: source.elems.mapIt(it.getStr).join("") else: source.getStr

proc codeOf(path, s: string): string =
  if path.endsWith(".ipynb"):
    var code: seq[string]
    for c in parseJson(s)["cells"]:
      if c["cell_type"].getStr == "code": code.add c["source"].joined
    return code.join("\n")
  s.findAll1(r"```\{?(?:python|r|R)[^\n]*\n(.*?)```", {reDotAll}).join("\n")

proc titleOf(path, s: string): string =
  if path.endsWith(".ipynb"):
    for c in parseJson(s)["cells"]:
      if c["cell_type"].getStr == "markdown":
        let m = c["source"].joined.search(r"^#+\s+(.+)$", {reMultiLine})
        if m.found: return m[1].ustrip
    return basename(dirname(path))
  let m = s.search(r"^---\n.*?^title:\s*[""']?(.+?)[""']?\s*$", {reDotAll, reMultiLine})
  if m.found: m[1] else: stem(basename(path))

proc urlOf(find: JsonNode, path: string): string =
  let site = find["site"]
  let strip = site{"strip"}.getStr
  let p = if path.startsWith(strip): path[strip.len .. ^1] else: path
  let st = stem(p)
  if st == "index" or st.endsWith("/index"):
    return site["base"].getStr & st[0 ..< ^"index".len]  # a folder's page: its folder
  site["base"].getStr & st & ".html"

type Page = tuple[path, title, url, code: string]

proc guidePages(find: JsonNode, commit: string, files: seq[string], offline: bool): seq[Page] =
  for path in files:
    if path.matches(find["paths"]) and not path.matches(find{"skip"}):
      let s = read(find["repo"].getStr, commit, path, offline)
      result.add (path, titleOf(path, s), urlOf(find, path), codeOf(path, s))

# ---------------------------------------------------------------- examples of a reference (gt, R)

proc braced(s: string, start: int): (string, int) =
  ## The text inside the braces that open at s[start], and where they close.
  var depth = 0
  var i = start
  while i < s.len:
    let c = s[i]
    if c == '\\' and i + 1 < s.len and s[i + 1] in {'{', '}'}:
      i += 2
      continue
    if c == '{': inc depth
    elif c == '}':
      dec depth
      if depth == 0: return (s[start + 1 ..< i], i)
    inc i
  (s[start + 1 .. ^1], s.len)

proc rdExamples(s: string): string =
  ## The code of the Examples section of an Rd file: its \preformatted blocks.
  let m = s.search(r"\\section\{Examples\}\{")
  if not m.found: return ""
  let (body, _) = braced(s, m.last - 1)
  var code: seq[string]
  var i = 0
  while true:
    let j = body.find("\\preformatted{", i)
    if j < 0: break
    let (blk, k) = braced(body, j + "\\preformatted".len)
    i = k
    code.add blk.replace("\\{", "{").replace("\\}", "}").replace("\\%", "%")
  code.join("\n")

proc rdPages(find: JsonNode, commit: string, files: seq[string], offline: bool): seq[Page] =
  for path in files:
    if path.matches(find["paths"]):
      let s = read(find["repo"].getStr, commit, path, offline)
      let code = rdExamples(s)
      if code.strip.len > 0:
        let m = s.search(r"\\name\{(.+?)\}")
        let name = if m.found: m[1] else: basename(path)[0 ..< ^3]
        result.add (path, name & "()", urlOf(find, path), code)

# ---------------------------------------------------------------- examples of a reference (Great Tables)
# A small reader of Python's statements, enough to follow names to their docstrings as Python's
# `ast` would: the statements of a module and of its class bodies (functions, classes, `a = b`,
# `from .x import y as z`), each with the docstring that opens its body.

type
  PyKind = enum pyDef, pyClass, pyAssign, pyImport, pyOther
  PyNode = ref object
    kind: PyKind
    name, value: string             ## def or class: its name; a = b: a and b
    level: int                      ## from ..x import: the dots
    module: string
    names: seq[(string, string)]    ## from x import a as b: (a, b), b = "" without `as`
    doc: string
    hasDoc: bool
    body: seq[PyNode]               ## a class's statements
  Line = tuple[indent: int, text: string]

proc logicalLines(src: string): seq[Line] =
  ## The logical lines of Python code: joined over brackets, strings and `\`, without comments.
  var i = 0
  var depth = 0
  var cur = ""
  var indent = -1
  var atStart = true
  while i < src.len:
    let c = src[i]
    if atStart:
      var col = 0
      while i < src.len and src[i] in {' ', '\t'}:
        col = if src[i] == '\t': (col div 8 + 1) * 8 else: col + 1
        inc i
      atStart = false
      if i >= src.len: break
      if src[i] in {'\n', '#', '\r'} and cur.len == 0:  # blank or comment line
        while i < src.len and src[i] != '\n': inc i
        inc i
        atStart = true
        continue
      if cur.len == 0: indent = col
      continue
    case c
    of '#':
      while i < src.len and src[i] != '\n': inc i
    of '\\':
      if i + 1 < src.len and src[i + 1] == '\n':
        i += 2
        cur.add ' '
      else:
        cur.add c
        inc i
    of '(', '[', '{':
      inc depth; cur.add c; inc i
    of ')', ']', '}':
      dec depth; cur.add c; inc i
    of '"', '\'':
      let triple = i + 2 < src.len and src[i + 1] == c and src[i + 2] == c
      let q = if triple: c.repeat(3) else: $c
      var j = i + q.len
      while j < src.len:
        if src[j] == '\\': j += 2; continue
        if src.continuesWith(q, j): break
        if not triple and src[j] == '\n': break
        inc j
      cur.add src[i ..< min(j + q.len, src.len)]
      i = j + q.len
    of '\n':
      inc i
      if depth > 0: cur.add ' '
      else:
        if cur.strip.len > 0: result.add (indent, cur.strip)
        cur = ""
        atStart = true
    else:
      cur.add c
      inc i
  if cur.strip.len > 0: result.add (indent, cur.strip)

proc unescapePy(s: string): string =
  ## The value of a string literal's body without the `r` prefix.
  var i = 0
  while i < s.len:
    if s[i] == '\\' and i + 1 < s.len:
      let c = s[i + 1]
      case c
      of '\n': discard
      of '\\': result.add '\\'
      of '\'': result.add '\''
      of '"': result.add '"'
      of 'n': result.add '\n'
      of 't': result.add '\t'
      of 'r': result.add '\r'
      of 'a': result.add '\a'
      of 'b': result.add '\b'
      of 'f': result.add '\f'
      of 'v': result.add '\v'
      else: result.add '\\'; result.add c
      i += 2
    else:
      result.add s[i]
      inc i

proc stringLiteral(text: string): (bool, string) =
  ## A logical line that is a string and nothing else: its value.
  let m = text.matchStart(r"([rRuUbBfF]*)(""""""|'''|""|')")
  if not m.found: return (false, "")
  let q = m[2]
  let start = m.last
  if not text.endsWith(q) or text.len < start + q.len: return (false, "")
  let body = text[start ..< text.len - q.len]
  var k = 0
  while k < body.len:  # a quote not escaped: two strings, or a string and more
    if body[k] == '\\': k += 2; continue
    if body.continuesWith(q, k): return (false, "")
    inc k
  (true, if 'r' in m[1].toLowerAscii: body else: unescapePy(body))

proc cleandoc(doc: string): string =
  ## Python's `inspect.cleandoc`, as `ast.get_docstring` uses it.
  var lines = doc.replace("\t", "        ").split('\n')
  var margin = int.high
  for l in lines[1 .. ^1]:
    let content = l.strip(trailing = false)
    if content.len > 0: margin = min(margin, l.len - content.len)
  lines[0] = lines[0].strip(trailing = false)
  if margin < int.high:
    for k in 1 ..< lines.len: lines[k] = (if lines[k].len > margin: lines[k][margin .. ^1] else: "")
  while lines.len > 0 and lines[^1].len == 0: lines.setLen(lines.len - 1)
  while lines.len > 0 and lines[0].len == 0: lines.delete(0)
  lines.join("\n")

proc statements(ls: seq[Line], i: var int, indent: int): seq[PyNode] =
  ## The statements at `indent` from line `i` (deeper ones belong to them), up to a line less
  ## indented.
  while i < ls.len and ls[i].indent >= indent:
    if ls[i].indent > indent:
      inc i
      continue
    let t = ls[i].text
    inc i
    var node = PyNode(kind: pyOther)
    var m = t.matchStart(r"(?:async\s+)?(def|class)\s+(\w+)")
    if m.found:
      node = PyNode(kind: if m[1] == "def": pyDef else: pyClass, name: m[2])
      if i < ls.len and ls[i].indent > indent:
        let (isDoc, value) = stringLiteral(ls[i].text)
        if isDoc: (node.hasDoc = true; node.doc = cleandoc(value))
        if node.kind == pyClass: node.body = statements(ls, i, ls[i].indent)
    elif (m = t.matchStart(r"from\s+(\.*)\s*([\w.]*)\s+import\s+\(?([^)]*)\)?\s*$"); m.found):
      node = PyNode(kind: pyImport, level: m[1].len, module: m[2])
      for part in m[3].split(','):
        let p = part.strip
        if p.len == 0: continue
        let a = strutils.splitWhitespace(p)
        node.names.add (a[0], if a.len == 3 and a[1] == "as": a[2] else: "")
    elif (m = t.matchStart(r"([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)\s*$"); m.found):
      node = PyNode(kind: pyAssign, name: m[1], value: m[2])
    elif t.matchStart(r"[A-Za-z_]\w*\s*=[^=]").found:
      node = PyNode(kind: pyAssign, name: t.matchStart(r"([A-Za-z_]\w*)")[1])  # its value is not a name
    result.add node

type Package = ref object
  repo, commit, root: string
  offline: bool
  files: HashSet[string]
  trees: Table[string, seq[PyNode]]
  exists: Table[string, bool]
  packages: HashSet[string]

proc module(p: Package, m: string): bool =
  ## Reads the module `m` (dotted, "" for the package); false when there is none.
  if m notin p.exists:
    let base = if m.len > 0: p.root & "/" & m.replace(".", "/") else: p.root
    let path = if base & ".py" in p.files: base & ".py" else: base & "/__init__.py"
    p.exists[m] = path in p.files
    if p.exists[m]:
      let ls = logicalLines(read(p.repo, p.commit, path, p.offline))
      var i = 0
      p.trees[m] = statements(ls, i, 0)
      if path.endsWith("/__init__.py"): p.packages.incl m
  p.exists[m]

proc find(p: Package, body: seq[PyNode], isTop: bool, m, name: string, depth = 0): (PyNode, string) =
  ## The node `name` defines in `body` (a module's or a class's in module `m`), following
  ## imports and aliases, and the module it is in.
  if depth > 12: return (nil, m)
  for node in body:
    if node.kind in {pyDef, pyClass} and node.name == name: return (node, m)
  discard p.module(m)
  let top = p.trees.getOrDefault(m)
  for node in body:
    if node.kind == pyAssign and node.name == name and node.value.len > 0:
      # `fmt_number = fmt_number` in a class body
      return (if not isTop or node.value != name: p.find(top, true, m, node.value, depth + 1) else: (nil, m))
    if node.kind == pyImport and node.level >= 1:
      for (a, asname) in node.names:
        if (if asname.len > 0: asname else: a) == name:
          let parts = if m.len > 0: m.split(".") else: @[]
          let here = if m in p.packages: parts else: parts[0 ..< ^1]
          var parent = here[0 ..< here.len - (node.level - 1)]
          if node.module.len > 0: parent.add node.module
          let target = parent.join(".")
          return (if p.module(target): p.find(p.trees[target], true, target, a, depth + 1) else: (nil, m))
  if not isTop: return p.find(top, true, m, name, depth + 1)
  (nil, m)

proc resolve(p: Package, dotted: string): PyNode =
  ## `GT.fmt_number`, `loc.body`, `md`: the function or class it names.
  var parts = dotted.split(".")
  var m = ""
  if parts.len > 1 and p.module(parts[0]):
    m = parts[0]  # loc.body: the module great_tables/loc.py
    parts = parts[1 .. ^1]
  discard p.module(m)
  var (node, mm) = p.find(p.trees[m], true, m, parts[0])
  for part in parts[1 .. ^1]:
    if node.isNil or node.kind != pyClass: return nil
    (node, mm) = p.find(node.body, false, mm, part)
  node

proc pyExamples(doc: string): string =
  let m = doc.search(r"^\s*Examples\s*\n\s*-{3,}\s*\n", {reMultiLine})
  if not m.found: return ""
  let rest = doc[m.last .. ^1]
  let e = rest.search(r"^\s*\w[\w ]*\n\s*-{3,}\s*\n", {reMultiLine})  # the next numpydoc section
  codeOf("", if e.found: rest[0 ..< e.first] else: rest)

proc quartodocNames(s: string): seq[string] =
  ## The names in the API reference of a quartodoc site, in the order of the reference.
  var inside = false
  for line in s.split('\n'):
    if line.matchStart(r"quartodoc:").found: inside = true
    elif inside and line.matchStart(r"\S").found: break
    elif inside:
      let m = line.matchStart(r"\s+-\s+(?:name:\s+)?([A-Za-z_][\w.]*)\s*$")
      if m.found: result.add m[1]

proc pyPages(find: JsonNode, commit: string, files: seq[string], offline: bool): seq[Page] =
  let pkg = Package(repo: find["repo"].getStr, commit: commit, root: find["package"].getStr,
                    offline: offline, files: files.toHashSet)
  for name in quartodocNames(read(find["repo"].getStr, commit, find["quartodoc"].getStr, offline)):
    let node = pkg.resolve(name)
    let code = if not node.isNil and node.hasDoc: pyExamples(node.doc) else: ""
    if code.strip.len > 0:
      result.add ("reference/" & name, name & (if not name.startsWith("data."): "()" else: ""),
                  find["site"]["base"].getStr & name & ".html", code)

# ---------------------------------------------------------------- whole repositories (Table Contest entries)

const
  codeFile = r"\.(R|r|py)$"
  chunksFile = r"\.(Rmd|rmd|qmd|ipynb)$"
  licences = [("MIT", r"\bMIT License|Permission is hereby granted, free of charge"),
    ("Apache-2.0", r"Apache License"), ("CC0-1.0", r"CC0|Creative Commons Zero|CC0 1\.0"),
    ("CC BY-SA 4.0", r"Attribution-ShareAlike 4\.0"), ("CC BY 4.0", r"Attribution 4\.0"),
    ("CC BY-NC-ND 4.0", r"NonCommercial-NoDeriv"), ("CC BY-NC 4.0", r"Attribution-NonCommercial"),
    ("GPL-3.0", r"(?i)GNU GENERAL PUBLIC LICENSE\W+Version 3"), ("GPL-2.0", r"(?i)GNU GENERAL PUBLIC LICENSE\W+Version 2"),
    ("AGPL-3.0", r"GNU AFFERO"), ("LGPL", r"GNU LESSER"), ("BSD-3-Clause", r"Redistribution and use in source"),
    ("Unlicense", r"unlicense\.org"), ("MPL-2.0", r"Mozilla Public License")]
  packages = [("gt", r"(?:library|require)\([""']?gt[""']?\)|\bgt::|p_load\([^)]*\bgt\b|\bgt\s*\("), ("gtExtras", r"gtExtras"),
    ("Great Tables", r"great_tables"), ("gt-extras", r"gt_extras"),
    ("reactable", r"\breactable\b"), ("reactablefmtr", r"reactablefmtr"), ("DT", r"\bDT::|library\(DT\)"),
    ("flextable", r"flextable"), ("kableExtra", r"kableExtra"), ("gtsummary", r"gtsummary"),
    ("rtables", r"library\(rtables\)|\brtables::"), ("tfrmt", r"\btfrmt\b"), ("Shiny", r"library\(shiny\)|\bshiny::|shinyApp\("),
    ("pandas Styler", r"\.style\."), ("formattable", r"\bformattable\b"), ("huxtable", r"\bhuxtable\b"),
    ("tinytable", r"\btinytable\b"), ("kable", r"\bkable\s*\(")]

proc licenceOf(repo, commit: string, files: seq[string], offline: bool): string =
  ## The licence of a repository, from its LICENSE file (or the DESCRIPTION of an R package).
  if "DESCRIPTION" in files:  # an R package says it in its DESCRIPTION (LICENSE is then a stub)
    let m = read(repo, commit, "DESCRIPTION", offline).search(r"^License:\s*(.+)$", {reMultiLine})
    if m.found and m[1].strip.matchStart(r"(MIT|GPL|LGPL|AGPL|Apache|BSD|CC|MPL)").found:
      return m[1].sub(r"\s*\+\s*file LICEN[CS]E", "").strip
  for f in files:
    if f.fullMatch(r"(?i)(licen[cs]e|copying)(\.md|\.txt)?"):
      let text = read(repo, commit, f, offline)
      for (name, pat) in licences:
        if text.has(pat, if name == "Unlicense": {reIgnoreCase} else: {}): return name
      return "a licence file"
  ""

var gone: seq[string]

proc repoPages(find: JsonNode, commit: string, files: seq[string], offline: bool): seq[Page] =
  ## One page per repository: an entry with all its code. `find.entries` lists them; `listing`
  ## and `read` are called again for each entry's own repository. A link to a folder keeps the
  ## entry to that folder (moving up until it has code: links often point to the picture); an
  ## R package is read by its vignettes, what its users would write. What is found (licence,
  ## packages, how much code) is written on the entry, for the page.
  for e in find["entries"]:
    let repo = e["repo"].getStr
    let gitRef = if e{"ref"}.getStr != "": e["ref"].getStr else: "HEAD"
    var c: string
    var fs: seq[string]
    try: (c, fs) = listing(repo, gitRef, offline)
    except GitError:
      gone.add repo  # deleted, renamed or made private since the contest
      continue
    if e{"licence"}.getStr == "": e["licence"] = %licenceOf(repo, c, fs, offline)
    var coded = fs.filterIt((it.has(codeFile) or it.has(chunksFile)) and
                            not basename(it).toLowerAscii.startsWith("readme"))  # how the repository presents itself
    var base = e{"path"}.getStr
    while base.len > 0 and not coded.anyIt(it.startsWith(base & "/")): base = dirname(base)
    if base.len > 0:
      coded = coded.filterIt(it.startsWith(base & "/"))
    elif "DESCRIPTION" in fs and fs.anyIt(it.startsWith("R/")):
      e["kind"] = %"package"
      coded = coded.filterIt(it.startsWith("vignettes/") or it.startsWith("inst/examples/") or
                             it.startsWith("inst/app/") or it.startsWith("examples/"))
    e["files"] = %coded.len
    var code: seq[string]
    for f in coded[0 ..< min(150, coded.len)]:  # a repository of many projects is linked with its folder
      let text = read(repo, c, f, offline)
      code.add(if f.has(codeFile): text else: codeOf(f, text))
    var all = code.join("\n")
    if e{"package"}.getStr == "":
      e["package"] = %packages.filterIt(all.has(it[1])).mapIt(it[0]).join(", ")
    # saving the table as a picture (gtsave) is how it was shared, not what the table needs
    all = all.sub(r"\bgtsave\s*\(", "saved(")
    let url = if e{"url"}.getStr != "": e["url"].getStr
              else: "https://github.com/" & repo & (if base.len > 0: "/tree/" & gitRef & "/" & base else: "")
    result.add (repo, e["title"].getStr, url, all)

proc pagesOf(kind: string, find: JsonNode, commit: string, files: seq[string], offline: bool): seq[Page] =
  case kind
  of "pages": guidePages(find, commit, files, offline)
  of "rd": rdPages(find, commit, files, offline)
  of "quartodoc": pyPages(find, commit, files, offline)
  of "repos": repoPages(find, commit, files, offline)
  else: raise newException(ValueError, "no kind of source called " & kind)

# ---------------------------------------------------------------- the search

proc main(offline: bool) =
  let cov = coverage()
  let sources = parseJson(readText(here / "sources.json"))["sources"]
  var output = newJObject()
  var report: seq[string]
  for s in sources:
    let find = s["find"]
    let kind = if find{"kind"}.getStr != "": find["kind"].getStr else: "pages"
    let (commit, files) = listing(find["repo"].getStr, if find{"ref"}.getStr != "": find["ref"].getStr else: "main", offline)
    var listed: OrderedTable[string, JsonNode]
    for p in s{"pages"}.getElems: listed[p["path"].getStr] = p
    var pages = newJArray()
    for (path, title, url, code) in pagesOf(kind, find, commit, files, offline):
      var hand: JsonNode = nil
      if path in listed:
        hand = listed[path]
        listed.del path
      if kind == "repos":  # an entry is listed by hand, with what the book says
        for e in find["entries"]:
          if e["repo"].getStr == path: (hand = e; break)
      var needs: OrderedTable[string, HashSet[string]]
      var uses: HashSet[int]
      proc need(r, f: string) = needs.mgetOrPut(r, initHashSet[string]()).incl f
      let n = calls(code)
      for name in n.keys:
        let i = cov.lookup(name)
        if i >= 0:
          need(planOf(cov.rows[i]), cov.rows[i]["feature"].getStr)
          uses.incl i
      for name, i in cov.exact:  # a function passed by name: map(x, ggplot_image, ...)
        if "_" in name and code.has(r"[(,]\s*(?:gt::)?" & name & r"\s*[,)]"):
          need(planOf(cov.rows[i]), cov.rows[i]["feature"].getStr)
          uses.incl i
      for name, i in cov.args:
        if code.has(r"\b" & name & r"\s*="):
          need(planOf(cov.rows[i]), cov.rows[i]["feature"].getStr)
          uses.incl i
      if code.has(extras): need(extrasFeature[1], extrasFeature[0])
      if code.has(other):
        var i = 0
        while cov.rows[i]["feature"].getStr != otherFeature: inc i
        need(planOf(cov.rows[i]), otherFeature)
        uses.incl i
      if not hand.isNil:
        for f in hand{"found"}.getElems: need(newGap, f.getStr)  # gaps the map does not have, found by reading the page
      var ready = now
      for r in needs.keys:
        if order.find(r) > order.find(ready): ready = r
      if not hand.isNil and kind == "repos":
        if hand{"package"}.getStr.has(r"gtsummary|rtables|tfrmt"):
          need(later, "Statistical summary tables (gtsummary, rtables, tfrmt)")
          if ready != otherTool: ready = later
        if not hand{"package"}.getStr.has(r"\bgt\b|Great Tables"):
          ready = otherTool  # no gt: nothing to measure
          needs.clear
          if hand{"files"}.getInt == 0 and hand{"note"}.getStr == "":
            hand["note"] = %"No code found in the repository"
      let port = if not hand.isNil: (if hand.hasKey("port"): hand["port"].getStr else: "port")
                 elif s["kind"].getStr == "reference": "port" else: "triage"
      if hand.isNil and s["kind"].getStr != "reference":
        report.add "  new page in " & s["id"].getStr & ": " & path & " (" & title & ")"
      let page = %*{"title": (if not hand.isNil and hand.hasKey("title"): hand["title"].getStr else: title),
                    "path": path}
      if not hand.isNil:
        for k in ["year", "by", "licence", "package", "prize", "post", "kind", "files", "book"]:
          let v = hand{k}
          if not v.isNil and ((v.kind == JString and v.str.len > 0) or (v.kind == JInt and v.num != 0)):
            page[k] = v
      page["url"] = %(if not hand.isNil and hand.hasKey("url"): hand["url"].getStr else: url)
      page["port"] = %port
      page["note"] = %(if not hand.isNil and hand.hasKey("note"): hand["note"].getStr else: "")
      page["ready"] = %ready
      var total = 0
      for v in n.values: total += v
      page["calls"] = %total
      var ns = newJObject()
      for r in order:
        if r in needs and r != now: ns[r] = %needs[r].toSeq.sorted
      page["needs"] = ns
      page["uses"] = %(uses.toSeq.mapIt(cov.rows[it]["feature"].getStr).sorted)
      pages.add page
    for repo in gone:
      report.add "  gone from " & s["id"].getStr & ": " & repo & " (the repository cannot be cloned)"
    gone.setLen 0
    for path in listed.keys:
      report.add "  gone from " & s["id"].getStr & ": " & path & " (listed in sources.json, not in " &
        find["repo"].getStr & ")"
    output[s["id"].getStr] = %*{"commit": commit, "pages": pages}
  writeFile(here / "pages.json", pyJson(output))
  for sid, o in output:
    var counts: OrderedTable[string, int]
    for p in o["pages"]: counts.mgetOrPut(p["ready"].getStr, 0).inc
    echo sid, " ", o["pages"].len, " pages: ", toSeq(counts.pairs).mapIt(it[0] & ": " & $it[1]).join(", ")
  echo(if report.len > 0: report.join("\n") else: "every page found is listed, every page listed is found")

# ---------------------------------------------------------------- the search by feature

proc gtNames(gt: string): HashSet[string] =
  ## The functions a row of the coverage map names, without namespaces: fmt_number, cells_body.
  for t in gt.findAll1(r"([A-Za-z_][\w.]*)\(\)"): result.incl t.split(".")[^1]

proc search(words: string) =
  ## Prints the pages that show a feature, from pages.json: no fetching.
  let cov = coverage()
  let output = parseJson(readText(here / "pages.json"))
  var index: Table[string, seq[(JsonNode, string)]]
  for r in cov.rows: index[r["feature"].getStr] = @[]
  for sid, o in output:
    for p in o["pages"]:
      if p["port"].getStr != "skip":
        for f in p["uses"]: index[f.getStr].add (p, sid)
  let w = words.ulower
  var hits: seq[JsonNode]
  for r in cov.rows:
    if w in r["feature"].getStr.ulower or r["gt"].getStr.ulower.has(r"\b" & escapeRe(w) & r"\b"):
      hits.add r
  if hits.len == 0: quit "no feature of the coverage map is called " & escape(words, "'", "'")
  for r in hits:
    let own = gtNames(r["gt"].getStr)
    var ps = index[r["feature"].getStr]
    proc isMain(p: JsonNode): bool =
      var t = p["title"].getStr
      t.removeSuffix("()")
      t.split(".")[^1] in own
    ps.sort(proc (a, b: (JsonNode, string)): int =
      result = cmp(not isMain(a[0]), not isMain(b[0]))
      if result == 0: result = cmp(a[0]["calls"].getInt, b[0]["calls"].getInt)
      if result == 0: result = cmp(a[0]["title"].getStr, b[0]["title"].getStr))
    echo r["feature"].getStr, " (", r["area"].getStr, "; ", r["gt"].getStr, "), ready ", planOf(r), ": ",
      ps.len, " pages"
    for (p, sid) in ps:
      echo "  ", align($p["calls"].getInt, 4), " calls  ready ", alignLeft(p["ready"].getStr, 5), "  ",
        alignLeft(sid, 16), " ", p["title"].getStr, "  ", p["url"].getStr

when isMainModule:
  putEnv("GIT_TERMINAL_PROMPT", "0")
  var words: seq[string]
  var offline = false
  for a in commandLineParams():
    if a == "--offline": offline = true
    elif not a.startsWith("--"): words.add a
  if words.len > 0: search(words.join(" "))
  else: main(offline)
