## Links: every link of the built site leads somewhere.
##
##   nim r tools/links.nim               # links inside the site: files and #anchors
##   nim r tools/links.nim --external    # and links to other sites (needs the network)
##
## Run it after building the pages (`docs/all.nim`) and the book (`book/bookbuild.nim`): it reads
## every `.html` file under docs/. A link inside the site fails when its file is missing, or when
## its `#anchor` is no `id` of that page. A link to another site fails only when the site answers
## 404 or 410, so a page that moved or went away is caught (Great Tables renamed its Get Started
## guide into the User Guide, and every link to it broke); a timeout, a refusal or a 5xx is a
## warning, since it says nothing sure about the link. CI runs it on every PR and once a week.
import std/[os, strutils, sets, tables, uri, httpclient, asyncdispatch, algorithm, sequtils]

const
  root = currentSourcePath().parentDir.parentDir
  site = root / "docs"
  # the site's own address: a link to it is checked as a link inside the site
  ownBase = "https://pietroppeter.github.io/tabelline/"
  # pages written by hand that link to what only exists on the live site
  agent = "tabelline-links (+https://github.com/pietroppeter/tabelline)"
  parallel = 16
  skipped = ["github.com/pietroppeter/tabelline/edit/", "github.com/pietroppeter/tabelline/new/"]
  # a link to a file of this repository on main is checked in the checkout: a PR that adds the
  # file (a new OpenSpec change) links it before it is on main
  ownBlob = "https://github.com/pietroppeter/tabelline/blob/main/"

type Link = object
  page, href: string

proc attrValues(html, attr: string): seq[string] =
  ## The values of `attr="..."` (or '...') in the HTML, `href` or `id`.
  for q in ['"', '\'']:
    let key = " " & attr & "=" & q
    var i = html.find(key)
    while i >= 0:
      let start = i + key.len
      let stop = html.find(q, start)
      if stop < 0: break
      result.add html[start ..< stop]
      i = html.find(key, stop)

proc withoutCode(html: string): string =
  ## The HTML without `<pre>` and `<script>` blocks: a link written in code is text, not a link.
  result = html
  for (open, close) in [("<pre", "</pre>"), ("<script", "</script>")]:
    var i = result.find(open)
    while i >= 0:
      let stop = result.find(close, i)
      if stop < 0: break
      result.delete(i ..< stop + close.len)
      i = result.find(open, i)

proc htmlDecode(s: string): string =
  s.multiReplace(("&amp;", "&"), ("&#39;", "'"), ("&quot;", "\""))

proc check(url: string): Future[(int, string)] {.async.} =
  ## The status code of `url` (HEAD, then GET when HEAD is refused), or 0 and the error.
  for verb in [HttpHead, HttpGet]:
    let client = newAsyncHttpClient(userAgent = agent, maxRedirects = 10)
    try:
      let r = client.request(url, httpMethod = verb)
      if not await r.withTimeout(20_000):
        return (0, "timeout")
      let code = r.read.code.int
      if verb == HttpGet or code notin [403, 404, 405, 501]:
        return (code, "")
    except CatchableError as e:
      return (0, e.msg.splitLines[0])
    finally:
      client.close()

proc checkAll(urls: seq[string]): Future[seq[(int, string)]] {.async.} =
  ## `check` for every url, `parallel` at a time.
  result = newSeq[(int, string)](urls.len)
  var next = 0
  proc worker(res: ptr seq[(int, string)]) {.async.} =
    while next < urls.len:
      let i = next
      inc next
      res[][i] = await check(urls[i])
  var workers: seq[Future[void]]
  for _ in 1 .. parallel: workers.add worker(addr result)
  await all(workers)

proc main() =
  let external = "--external" in commandLineParams()
  var ids: Table[string, HashSet[string]]
  var links: seq[Link]
  for path in walkDirRec(site):
    if not path.endsWith(".html"): continue
    let rel = path.relativePath(site).replace('\\', '/')
    if rel.startsWith("book/assets/") or rel.startsWith("book/theme/"): continue
    let html = readFile(path).withoutCode
    ids[rel] = toHashSet(html.attrValues("id") & html.attrValues("name"))
    for href in html.attrValues("href"):
      links.add Link(page: rel, href: href.htmlDecode)
  if ids.len == 0:
    quit "no pages under docs/: build them first (docs/all.nim, book/bookbuild.nim)"

  var broken, warnings: seq[string]
  var outside: Table[string, seq[string]]   # url -> pages that link it
  for l in links:
    var href = l.href.strip
    if href.len == 0 or href.startsWith("mailto:") or href.startsWith("javascript:") or
       href.startsWith("data:") or href.startsWith("tel:"): continue
    if href.startsWith(ownBase):
      href = relativePath(site / href[ownBase.len .. ^1], site / l.page.parentDir).replace('\\', '/')
    if href.startsWith(ownBlob):
      let path = href[ownBlob.len .. ^1].split('#')[0].decodeUrl
      if not (fileExists(root / path) or dirExists(root / path)):
        broken.add l.page & ": " & l.href & " (no " & path & " in the repository)"
      continue
    if href.startsWith("http://") or href.startsWith("https://") or href.startsWith("//"):
      if not skipped.anyIt(it in href):
        outside.mgetOrPut(href.split('#')[0], @[]).add l.page
      continue
    let parts = href.split('#', 1)
    var target = parts[0].split('?')[0].decodeUrl
    let anchor = if parts.len > 1: parts[1].decodeUrl else: ""
    var file = if target.len == 0: l.page
               else: normalizedPath(l.page.parentDir / target).replace('\\', '/')
    if file.startsWith("../"):
      broken.add l.page & ": " & l.href & " (leaves the site)"
      continue
    if target.len > 0 and (dirExists(site / file) or target.endsWith("/")):
      file = file.strip(leading = false, chars = {'/'}) & "/index.html"
      if file == "/index.html": file = "index.html"
    if not fileExists(site / file):
      broken.add l.page & ": " & l.href & " (no " & file & ")"
    elif anchor.len > 0 and file.endsWith(".html") and file in ids and anchor notin ids[file]:
      broken.add l.page & ": " & l.href & " (no #" & anchor & " in " & file & ")"

  if external:
    var urls = toSeq(outside.keys)
    urls.sort
    let answers = waitFor checkAll(urls)
    for i, url in urls:
      let (code, err) = answers[i]
      let where = outside[url].deduplicate.join(", ")
      if code in [404, 410]:
        broken.add where & ": " & url & " (" & $code & ")"
      elif code == 0 or code >= 400:
        warnings.add where & ": " & url & " (" & (if code == 0: err else: $code) & ")"

  for w in warnings: echo "warning: ", w
  for b in broken: echo "broken: ", b
  echo ids.len, " pages, ", links.len, " links, ", outside.len, " to other sites",
       (if external: " (checked)" else: " (not checked: --external)"),
       ", ", broken.len, " broken, ", warnings.len, " warnings"
  if broken.len > 0: quit 1

main()
