## The specs page, docs/specs/index.html: every OpenSpec spec and open change of tabelline,
## with each example run against the code while the page builds (tools/specexamples.nim), its
## output, and the table it makes. Kept up to date, not a dated post: CI rebuilds it on every push.
## `?spec=<names>` and `?change=<names>` (or the same after `#`) show only those; see the
## "Links" box on the page.
import std/[os, strutils, json, algorithm, strformat, sequtils]
import nimib
import blocchi
import ../tools/specexamples

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "specs" / "index.html"
nb.useTabelline(nome = "tabelline", materia = "Specs", classe = "kept up to date",
               title = "tabelline specs", homeHref = "../",
               description = "How tabelline behaves today: OpenSpec requirements with examples that run.")

type
  Scenario = object
    name: string
    bullets: seq[string]
  Requirement = object
    name, body: string
    scenarios: seq[Scenario]
    examples: seq[int]   # indices in the example list
  Spec = object
    cap, purpose, path: string
    sections: seq[(string, seq[Requirement])]
  Change = object
    name, proposal, tasks: string
    done, total: int
    deltas: seq[Spec]

let examples = collect(withChanges = true)
let results = run(examples)

proc exampleAt(path: string, line: int): int =
  for k, ex in examples:
    if ex.path == path and ex.line == line: return k
  -1

proc parseSpec(file, rel, cap: string): Spec =
  result = Spec(cap: cap, path: rel)
  let lines = readFile(file).splitLines
  var inPurpose = false
  var purpose: seq[string]
  var i = 0
  template reqs: untyped = result.sections[^1][1]
  while i < lines.len:
    let l = lines[i]
    if l.startsWith("## Purpose"): inPurpose = true
    elif l.startsWith("## "):
      inPurpose = false
      result.sections.add (l[3 .. ^1].strip, newSeq[Requirement]())
    elif l.startsWith("### Requirement:"):
      if result.sections.len == 0: result.sections.add ("Requirements", newSeq[Requirement]())
      reqs.add Requirement(name: l[16 .. ^1].strip)
    elif l.startsWith("#### Scenario:"):
      reqs[^1].scenarios.add Scenario(name: l[14 .. ^1].strip)
    elif l.strip == "```nim" or l.strip == "```text":
      if l.strip == "```nim" and result.sections.len > 0 and reqs.len > 0:
        let k = exampleAt(rel, i + 1)
        if k >= 0: reqs[^1].examples.add k
      inc i
      while i < lines.len and lines[i].strip != "```": inc i
    elif inPurpose: purpose.add l
    elif result.sections.len > 0 and reqs.len > 0:
      if reqs[^1].scenarios.len > 0:
        let s = l.strip
        if s.startsWith("- "): reqs[^1].scenarios[^1].bullets.add s[2 .. ^1]
        elif s.len > 0 and reqs[^1].scenarios[^1].bullets.len > 0: reqs[^1].scenarios[^1].bullets[^1].add " " & s
      else:
        reqs[^1].body.add l & "\n"
    inc i
  result.purpose = purpose.join("\n").strip


var specs: seq[Spec]
var caps: seq[string]
for kind, p in walkDir(root / "openspec" / "specs"):
  if kind == pcDir and fileExists(p / "spec.md"): caps.add p.lastPathPart
caps.sort
for cap in caps:
  specs.add parseSpec(root / "openspec" / "specs" / cap / "spec.md", "openspec/specs/" & cap & "/spec.md", cap)
var changes: seq[Change]
var names: seq[string]
for kind, p in walkDir(root / "openspec" / "changes"):
  if kind == pcDir and p.lastPathPart != "archive": names.add p.lastPathPart
names.sort
for n in names:
  let dir = root / "openspec" / "changes" / n
  var ch = Change(name: n)
  if fileExists(dir / "proposal.md"): ch.proposal = readFile(dir / "proposal.md")
  if fileExists(dir / "tasks.md"):
    ch.tasks = readFile(dir / "tasks.md")
    for l in ch.tasks.splitLines:
      if l.strip.startsWith("- [x]"): (inc ch.done; inc ch.total)
      elif l.strip.startsWith("- [ ]"): inc ch.total
  for kind, p in walkDir(dir / "specs"):
    if kind == pcDir and fileExists(p / "spec.md"):
      ch.deltas.add parseSpec(p / "spec.md", "openspec/changes/" & n & "/specs/" & p.lastPathPart & "/spec.md", p.lastPathPart)
  changes.add ch

func esc(s: string): string = s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"))

proc whenThen(b: string): string =
  var s = markdownToHtml(b).replace("<p>", "").replace("</p>", "").strip
  for (k, cls) in [("WHEN", "when"), ("THEN", "then"), ("AND", "and"), ("GIVEN", "given")]:
    s = s.replace("<strong>" & k & "</strong>", &"<b class=\"kw {cls}\">{k}</b>")
  s

proc exampleHtml(k: int): string =
  let ex = examples[k]
  let r = results[k]
  let v = verdict(ex, r)
  let label = case v
    of "pass": "✓ the output matches"
    of "ran": "ran (no expected output)"
    of "fail": "✗ the output differs"
    else: (if ex.path.startsWith("openspec/changes"): "to do: not built yet" else: "✗ error")
  result = &"""<div class="example {v}"><div class="ex-head"><span class="timbro {(if v in ["pass", "ran"]: "ok" else: "ko")}">{label}</span> <code>{ex.path}:{ex.line}</code></div>"""
  result.add """<pre><code class="nohighlight nim">""" & highlightNim(ex.code) & "</code></pre>"
  for h in r["html"]: result.add h.getStr
  let o = r["out"].getStr
  if o.len > 0:
    let open = if r["html"].len == 0: " open" else: ""
    result.add &"""<details class="ex-out"{open}><summary>what it prints</summary><pre class="nb-output">{esc(o)}</pre>"""
    if v == "fail": result.add &"""<p>expected:</p><pre class="nb-output">{esc(ex.expected)}</pre>"""
    result.add "</details>"
  result.add "</div>"

proc specHtml(s: Spec, kind = "spec"): string =
  var nreq, nscen, nex = 0
  for (_, rs) in s.sections:
    nreq += rs.len
    for r in rs: (nscen += r.scenarios.len; nex += r.examples.len)
  result = &"""<details class="spec" data-{kind}="{s.cap}" id="{kind}-{s.cap}"><summary><b>{s.cap}</b> <span class="counts">{nreq} requirements · {nscen} scenarios · {nex} examples</span>"""
  if s.purpose.len > 0: result.add "<span class=\"purpose\">" & markdownToHtml(s.purpose).replace("<p>", "").replace("</p>", "") & "</span>"
  result.add "</summary>"
  for (title, rs) in s.sections:
    if title != "Requirements": result.add &"<h4 class=\"section\">{title}</h4>"
    for r in rs:
      result.add &"""<div class="req"><h4>{esc(r.name)}</h4>""" & markdownToHtml(r.body)
      for k in r.examples: result.add exampleHtml(k)
      for sc in r.scenarios:
        result.add &"""<div class="scen"><span class="scen-name">Scenario: {esc(sc.name)}</span><ul>"""
        for b in sc.bullets: result.add "<li>" & whenThen(b) & "</li>"
        result.add "</ul></div>"
      result.add "</div>"
  # a pull request is built from its branch (GITHUB_HEAD_REF), where a new change's files already exist
  let branch = getEnv("GITHUB_HEAD_REF", "main")
  result.add &"""<p class="src">source: <a href="{repoUrl}/blob/{branch}/{s.path}"><code>{s.path}</code></a></p></details>"""

var total, passing, nreq = 0
for k, ex in examples:
  if ex.path.startsWith("openspec/specs"):
    inc total
    if verdict(ex, results[k]) in ["pass", "ran"]: inc passing
for s in specs:
  for (_, rs) in s.sections: nreq += rs.len

nbTitolo "Specs · rebuilt on every push", "How tabelline behaves", &"""
Every behaviour agreed so far, written down with [OpenSpec](https://github.com/Fission-AI/OpenSpec):
{specs.len} specs, {nreq} requirements, {total} examples. Each example ran against the code while
this page was built: **{passing} of {total} pass**.
"""

nbText: """
A **spec** in `openspec/specs/` says how one part of tabelline behaves today: requirements, each
with an example (Nim code and what it prints) and scenarios (WHEN this, THEN that). A **change** in
`openspec/changes/` proposes new behaviour, with its spec deltas and tasks; when it ships, it is
archived and its deltas join the specs. The examples are checked by
`nim r tools/specexamples.nim`, here and in CI. Tap a spec to open it.
"""

nbNota("""
Add `spec=` or `change=` to this page's link to show only some of it, opened:
[`?spec=formatting`](?spec=formatting), [`?spec=table-*`](?spec=table-*) (a prefix),
[`?spec=formatting,styling`](?spec=formatting,styling), [`?change=all`](?change=all).
The same works after `#` (`#spec=formatting`). The filter runs in the browser; a tool that does
not run JavaScript gets the whole page, so to read one spec, read its markdown:
`openspec/specs/<name>/spec.md` in the repository.
""", nkInfo, "Links to a part of this page, for people and agents")

# The specs and changes are rendered from OpenSpec's markdown by this page's own procs above: a
# one-off renderer, so they go in as HTML. Their CSS is in stile.nim, the filter in blocchi.nim.
nbText "## Specs"
var specsHtml = """<div class="filterbar nota info" id="filterbar" hidden></div>"""
for s in specs: specsHtml.add specHtml(s)
nbRawHtml: specsHtml

nbText "## Open changes"
if changes.len == 0: nbText "None at the moment: see the backlog for what may come next."
var changesHtml = ""
for c in changes:
  changesHtml.add &"""<details class="spec change" data-change="{c.name}" id="change-{c.name}"><summary><b>{c.name}</b> <span class="counts">tasks {c.done}/{c.total}</span></summary>"""
  changesHtml.add "<div class=\"req\">" & markdownToHtml(c.proposal) & "</div>"
  for d in c.deltas: changesHtml.add specHtml(d, "delta")
  if c.tasks.len > 0: changesHtml.add "<div class=\"req\"><h4>Tasks</h4>" & markdownToHtml(c.tasks) & "</div>"
  changesHtml.add "</details>"
nbRawHtml: changesHtml

nbSave
