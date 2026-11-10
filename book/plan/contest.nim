## Collects the entries of the Posit Table Contest into book/plan/sources.json.
##
##     nim r book/plan/contest.nim            # fetch, then update the source "table-contest"
##     nim r book/plan/contest.nim --offline  # from the copies in book/plan/cache/contest/
##
## Where the entries are:
## - 2020 to 2024: every submission is a topic of Posit Community (forum.posit.co, once
##   community.rstudio.com) with the tag `table-contest` (2020) or `table-contest-<year>`; its
##   first post links the code, usually a GitHub repository. The forum's JSON API is read.
## - 2025: submissions are GitHub Discussions of rich-iannone/table-contest; the winners post on
##   posit.co lists the ones that were awarded or mentioned, with their repositories, and that is
##   what is read here (the Discussions need the GitHub API).
## - Every year, the winners post (posit.co/blog) gives each awarded entry its prize.
##
## An entry is the repository its post links first (with the folder, when the link points inside
## it), the year, the title of the post, its author and its prize. Entries with no repository on
## GitHub are left out: there is no code to read. What is already in sources.json for an entry,
## written by hand (a title, a note, `port`, `found`, a licence, `book`: its chapter), is kept.
## `plan.nim` then reads each entry's code and measures it like any other page.
import std/[algorithm, sets, math]
import common

const
  contestCache = cache / "contest"
  forum = "https://forum.posit.co"
  tags = ["table-contest", "table-contest-2021", "table-contest-2022", "table-contest-2024"]
  winnersPosts = [(2020, "winners-of-the-2020-rstudio-table-contest"), (2021, "winners-of-the-2021-table-contest"),
                  (2022, "winners-of-the-2022-table-contest"), (2024, "2024-table-contest-winners"),
                  (2025, "2025-table-contest-winners")]
  # links in a post that are tools, not the entry's own code
  tools = ["rstudio/gt", "glin/reactable", "posit-dev/great-tables", "rstudio/rmarkdown", "rstudio/shiny",
           "tidyverse/dplyr", "kcuilla/reactablefmtr", "jthomasmock/gtExtras", "davidgohel/flextable",
           "ddsjoberg/gtsummary", "rstudio/DT", "haozhu233/kableExtra", "quarto-dev/quarto-cli",
           "rfordatascience/tidytuesday", "posit-dev/gt-extras", "rich-iannone/table-contest",
           "machow/reactable-py", "tidyverse/ggplot2", "rstudio/bslib", "rstudio/rstudio"].toHashSet
  notEntry = r"announc|winners|^about the|deadline|judging"
  repoFirst = [2020, 2021]  ## these posts link the repository before the forum topic

proc get(url: string, offline: bool, asJson = true): string =
  ## A page, from the cache or fetched (and kept).
  let path = contestCache / url.sub(r"[^\w.-]+", "_")
  if not fileExists(path):
    if offline: quit "not in the cache: " & url & " (run without --offline)"
    for attempt in 0 .. 3:
      if curl(url, path, if asJson: "application/json" else: "text/html"): break
      if attempt == 3: raise newException(IOError, "cannot read " & url)
      sleep 1000 * 2 ^ (attempt + 1)
    sleep 300  # the forum is a shared service: no bursts
  readText(path)

type
  Repo = tuple[repo, gitRef, path: string]
  Entry = ref object
    repo, gitRef, path: string     ## repo "": no repository found (yet)
    year: int
    title, by, post, prize: string

proc repoOf(url: string): (bool, Repo) =
  ## owner/repo, and the folder and branch when the link points inside the repository.
  let m = url.matchStart(r"https?://github\.com/([\w.-]+)/([\w.-]+?)(?:\.git)?(?:/(tree|blob)/([^/]+)(?:/(.*?))?)?/?(?:[?#].*)?$")
  if not m.found or m[2] in ["issues", "pulls", "discussions"]: return (false, ("", "", ""))
  var path = m[5]
  if m[3] == "blob": path = dirname(path)
  (true, (m[1] & "/" & m[2], m[4], path))

proc forumEntries(offline: bool): seq[Entry] =
  var topics: OrderedTable[int, JsonNode]
  for tag in tags:
    var page = 0
    while true:
      let d = parseJson(get(forum & "/tag/" & tag & ".json?page=" & $page, offline))
      let ts = d["topic_list"]["topics"]
      for t in ts:
        if t["id"].getInt notin topics: topics[t["id"].getInt] = t
      if ts.len == 0 or d["topic_list"]{"more_topics_url"}.getStr == "": break
      inc page
  var ids = toSeq(topics.keys)
  ids.sort
  for tid in ids:
    let t = topics[tid]
    if t["title"].getStr.has(notEntry, {reIgnoreCase}): continue
    let post = parseJson(get(forum & "/t/" & $tid & ".json", offline))["post_stream"]["posts"][0]
    var e = Entry()
    for link in post["cooked"].getStr.findAll1("href=\"(https?://github\\.com/[^\"]+)\""):
      let (ok, r) = repoOf(link)
      if ok and r.repo notin tools:
        (e.repo, e.gitRef, e.path) = r  # the winners post may know it, when nothing is found
        break
    # the tag of a year wins; the plain tag was used every year, so then the date says
    var year = 0
    for g in t{"tags"}.getElems:
      let name = if g.kind == JString: g.getStr else: g{"name"}.getStr
      if name.fullMatch(r"table-contest-\d{4}"):
        year = parseInt(name[^4 .. ^1])
        break
    if year == 0: year = parseInt(t["created_at"].getStr[0 ..< 4])
    if year == 2023: year = 2022  # the 2022 contest closed in January 2023
    e.year = year
    e.title = unescapeHtml(t["title"].getStr)
    e.by = if post{"name"}.getStr != "": post["name"].getStr else: post["username"].getStr
    e.post = forum & "/t/" & t["slug"].getStr & "/" & $tid
    result.add e

proc postKey(url: string): string =
  ## The same entry in a winners post and in the forum: the topic's number (the forum moved
  ## from community.rstudio.com, the numbers stayed), or the number of the 2025 Discussion.
  var m = url.search(r"/t/(?:[^/]+/)?(\d+)")
  if not m.found: m = url.search(r"/discussions/(\d+)")
  if not m.found: return url
  (if "/discussions/" in url: "d" else: "t") & m[1]

proc stripTags(s: string): string = s.sub(r"<[^>]+>", "")

proc winners(offline: bool): (OrderedTable[string, Entry], Table[string, string]) =
  ## Every entry named in a winners post: its prize, its title and the repository the post
  ## links. The post is read as a stream of headings and links: a heading names the prize, a
  ## link to a forum topic (or a 2025 Discussion) is an entry, and its repository is the
  ## GitHub link just before it (2020, 2021: "Repo – Community") or just after it (2024, 2025:
  ## the title, then "Code"). 2020's winner and runner up have no forum link: they are found by
  ## their repository, in order under their heading.
  var named: OrderedTable[string, Entry]
  var byRepo: Table[string, string]
  for (year, slug) in winnersPosts:
    var s = get("https://posit.co/blog/" & slug & "/", offline, asJson = false)
    s = s.sub(r"<script.*?</script>|<style.*?</style>", "", {reDotAll})
    if "Related Content" in s: s = s[0 ..< s.find("Related Content")]
    var heading = ""
    var current: Entry = nil
    var pending: Repo
    var hasPending = false
    var under = 0
    let toks = "<h[2-4][^>]*>(.*?)</h[2-4]>|<p class=\"h4[^\"]*\">(.*?)</p>|<a [^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>"
    for tok in s.finditer(toks, {reDotAll}):
      var href = tok[3]
      var text = tok[4]
      if tok.has(1) or tok.has(2):
        let h = if tok.has(1): tok[1] else: tok[2]
        let t = unescapeHtml(stripTags(h)).ustrip
        let inner = h.search("href=\"([^\"]+)\"[^>]*>(.*?)</a>", {reDotAll})
        if inner.found and inner[1].has(r"forum\.posit\.co/t/|discussions/\d"):
          (href, text) = (inner[1], inner[2])  # 2025: the title in a heading is the entry
        elif t.len > 0:
          heading = t
          current = nil
          hasPending = false
          under = 0
          continue
        else:
          continue
      if href.has(r"forum\.posit\.co/t/|community\.rstudio\.com/t/|table-contest/discussions/\d"):
        let key = postKey(href)
        if key in named: continue
        current = Entry(post: href, prize: heading, year: year, title: unescapeHtml(stripTags(text)).ustrip)
        named[key] = current
        if year in repoFirst and hasPending:
          (current.repo, current.gitRef, current.path) = pending
          current = nil  # its repository came first; what follows is the next entry's
        hasPending = false
        continue
      let (ok, r) = repoOf(href)
      if not ok or r.repo in tools: continue
      if year in repoFirst:
        if not hasPending: (pending, hasPending) = (r, true)
        if heading.has(r"Winner and the Runner") and r.repo notin byRepo:
          inc under
          byRepo[r.repo] = if under == 1: "Winner" else: "Runner up"
      elif not current.isNil and current.repo.len == 0:
        (current.repo, current.gitRef, current.path) = r
  (named, byRepo)

proc label(prize: string): string =
  let p = prize.sub(r"^(The\s+|Special Prize Categories\s*)", "").ustrip
  if p.fullMatch(r"Static Tables|Tutorials|Table Packages"):
    return "Honourable mention"  # 2020 grouped its honourable mentions by kind
  if p.has(r"honou?rable", {reIgnoreCase}): return "Honourable mention"
  if p.has(r"runner", {reIgnoreCase}): return "Runner up"
  if p.fullMatch(r"winner.*", {reIgnoreCase}) or p.ulower.startsWith("winner"): return "Winner"
  p

proc main(offline: bool) =
  var (named, byRepo) = winners(offline)
  var found: seq[Entry]
  for e in forumEntries(offline):
    let key = postKey(e.post)
    var w: Entry = nil
    if key in named:
      w = named[key]
      named.del key
    if e.repo in byRepo:  # 2020's winner and runner up share one heading
      w = if w.isNil: Entry(prize: byRepo[e.repo]) else: Entry(repo: w.repo, gitRef: w.gitRef, path: w.path,
                                                                 prize: byRepo[e.repo])
    if not w.isNil:
      e.prize = w.prize
      if w.repo.len > 0:  # the code the winners post links, when it names one
        (e.repo, e.gitRef, e.path) = (w.repo, w.gitRef, w.path)
    if e.repo.len > 0: found.add e
  # entries named in a winners post and not found in the forum: 2025 (GitHub Discussions)
  for w in named.values:
    if w.repo.len > 0 and w.year == 2025: found.add w
  let path = here / "sources.json"
  let sources = parseJson(readText(path))
  var src: JsonNode
  for s in sources["sources"]:
    if s["id"].getStr == "table-contest": src = s
  var old: OrderedTable[string, JsonNode]
  for e in src["find"]["entries"]: old[e["repo"].getStr] = e
  found.sort(proc (a, b: Entry): int =
    result = cmp(a.year, b.year)
    if result == 0: result = cmp(a.title.ulower, b.title.ulower))
  var entries = newJArray()
  var seen: HashSet[string]
  for e in found:
    if e.repo in seen: continue
    seen.incl e.repo
    let hand = old.getOrDefault(e.repo, newJObject())
    var o = %*{"repo": e.repo}
    if e.gitRef.len > 0: o["ref"] = %e.gitRef
    if e.path.len > 0: o["path"] = %e.path
    o["year"] = %e.year
    if hand.hasKey("title"): o["title"] = hand["title"]
    else:
      let t = e.title.sub(r"\s*[-|:]?\s*(?:\|>\s*)?Table Contest( Submission)?\s*$", "", {reIgnoreCase}).ustrip
      o["title"] = %(if t.len > 0: t else: e.title)
    o["by"] = if hand.hasKey("by"): hand["by"] else: %e.by
    o["post"] = %e.post
    if e.prize.len > 0 and not e.prize.has(r"closing", {reIgnoreCase}): o["prize"] = %label(e.prize)
    for k in ["package", "licence", "note", "port", "found", "book"]:
      if hand.hasKey(k): o[k] = hand[k]
    entries.add o
  for repo, e in old:  # an entry listed by hand that the search does not find stays
    if repo notin seen: entries.add e
  src["find"]["entries"] = entries
  writeFile(path, pyJson(sources) & "\n")
  var years: OrderedTable[int, int]
  for e in entries: years.mgetOrPut(e["year"].getInt, 0).inc
  echo entries.len, " entries: ", toSeq(years.pairs).mapIt($it[0] & ": " & $it[1]).join(", ")

when isMainModule:
  main("--offline" in commandLineParams())
