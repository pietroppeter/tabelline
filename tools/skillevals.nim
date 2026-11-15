## Grades what an agent made against an eval case of a skill (`skills/<skill>/evals/<case>/`).
##
## A case is a folder in the format of `claude plugin eval`: `prompt.md` (the task), `case.yaml`,
## `files/` (what the agent finds in its folder) and `graders/`, one Markdown file per check, with
## a front matter. Where `claude plugin eval` cannot run, give the prompt to an agent in an empty
## folder with the case's files, with the skill and without, then grade each folder here:
##
##   nim r tools/skillevals.nim skills/tabelline/evals/port-gt-extras <run dir> [--final:reply.md]
##
## The graders that need no judge are evaluated: `file_exists` (a path in the run's folder) and
## `regex` (on a file of the run, or on the agent's last message, given with `--final`). The
## others (`llm`, `tool_used`) are listed and not counted. Exit code 1 when a grader fails.

import std/[os, strutils, re, parseopt, algorithm, tables]

type Grader = object
  fields: Table[string, string]   ## the front matter, flat: `target.path` for a nested key
  body: string

proc unquote(v: string): string =
  if v.len >= 2 and v[0] == '"' and v[^1] == '"': v[1 .. ^2].replace("\\\\", "\\").replace("\\\"", "\"")
  else: v

proc parseGrader(path: string): Grader =
  ## The small part of YAML the graders use: `key: value` and one level of nesting.
  let text = readFile(path)
  if not text.startsWith("---\n"): return
  let stop = text.find("\n---", 4)
  if stop < 0: return
  var parent = ""
  for line in text[4 ..< stop].splitLines:
    if line.strip.len == 0 or line.strip.startsWith("#"): continue
    let parts = line.strip.split(':', 1)
    let (key, val) = (parts[0].strip, (if parts.len > 1: parts[1].strip else: ""))
    if line.startsWith("  ") and parent.len > 0: result.fields[parent & "." & key] = unquote(val)
    elif val.len == 0: parent = key
    else:
      parent = ""
      result.fields[key] = unquote(val)
  result.body = text[stop + 4 .. ^1].strip

proc flags(s: string): set[RegexFlag] =
  result = {reStudy}
  if 'i' in s: result.incl reIgnoreCase
  if 'm' in s: result.incl reMultiLine
  if 's' in s: result.incl reDotAll

when isMainModule:
  var args: seq[string]
  var final = ""
  for kind, key, val in getopt():
    if kind == cmdArgument: args.add key
    elif key == "final": final = val
  if args.len != 2:
    quit "usage: nim r tools/skillevals.nim <case dir> <run dir> [--final:reply.md]"
  let (caseDir, runDir) = (args[0], args[1])
  var names: seq[string]
  for f in walkFiles(caseDir / "graders" / "*.md"): names.add f
  names.sort
  var passed, failed = 0
  proc report(ok: bool, what, evidence: string) =
    if ok: inc passed else: inc failed
    echo (if ok: "pass  " else: "fail  "), what, "  [", evidence, "]"
  for f in names:
    let g = parseGrader(f)
    let kind = g.fields.getOrDefault("type")
    case kind
    of "file_exists":
      let path = g.fields["path"]
      let want = g.fields.getOrDefault("exists", "true") == "true"
      let have = fileExists(runDir / path) or dirExists(runDir / path)
      report(have == want, path & (if want: " exists" else: " does not exist"), if have: "found" else: "missing")
    of "regex":
      let pattern = g.fields.getOrDefault("pattern", g.body)
      let match = g.fields.getOrDefault("match", "contains")
      let path = g.fields.getOrDefault("target.path")
      let (where, file) = if path.len > 0: (path, runDir / path) else: ("the last message", final)
      let what = where & " " & match & " /" & pattern & "/"
      if file.len == 0 or not fileExists(file):
        report(false, what, where & " not available")
        continue
      let hits = readFile(file).findAll(re(pattern, flags(g.fields.getOrDefault("flags"))))
      let ok = case match
        of "contains": hits.len > 0
        of "not_contains": hits.len == 0
        else: hits.len == parseInt(match.split(':')[1])
      report(ok, what, $hits.len & " found" & (if hits.len > 0: ", first: " & hits[0][0 ..< min(60, hits[0].len)] else: ""))
    of "": discard
    else:
      echo "----  ", f.extractFilename, " (", kind, ": needs a judge or the transcript)"
  echo passed, " of ", passed + failed, " graders passed"
  if failed > 0: quit 1
