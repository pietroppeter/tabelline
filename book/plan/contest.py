"""Collects the entries of the Posit Table Contest into book/plan/sources.json.

    python3 book/plan/contest.py          # fetch, then update the source "table-contest"
    python3 book/plan/contest.py --offline  # from the copies in book/plan/cache/contest/

Where the entries are:
- 2020 to 2024: every submission is a topic of Posit Community (forum.posit.co, once
  community.rstudio.com) with the tag `table-contest` (2020) or `table-contest-<year>`; its
  first post links the code, usually a GitHub repository. The forum's JSON API is read.
- 2025: submissions are GitHub Discussions of rich-iannone/table-contest; the winners post on
  posit.co lists the ones that were awarded or mentioned, with their repositories, and that is
  what is read here (the Discussions need the GitHub API).
- Every year, the winners post (posit.co/blog) gives each awarded entry its prize.

An entry is the repository its post links first (with the folder, when the link points inside
it), the year, the title of the post, its author and its prize. Entries with no repository on
GitHub are left out: there is no code to read. What is already in sources.json for an entry,
written by hand (a title, a note, `port`, `found`, a licence), is kept. `plan.py` then reads
each entry's code and measures it like any other page.
"""
import collections, html, json, os, re, sys, time, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "cache", "contest")
FORUM = "https://forum.posit.co"
TAGS = ["table-contest", "table-contest-2021", "table-contest-2022", "table-contest-2024"]
WINNERS = {2020: "winners-of-the-2020-rstudio-table-contest", 2021: "winners-of-the-2021-table-contest",
           2022: "winners-of-the-2022-table-contest", 2024: "2024-table-contest-winners",
           2025: "2025-table-contest-winners"}
# links in a post that are tools, not the entry's own code
TOOLS = {"rstudio/gt", "glin/reactable", "posit-dev/great-tables", "rstudio/rmarkdown", "rstudio/shiny",
         "tidyverse/dplyr", "kcuilla/reactablefmtr", "jthomasmock/gtExtras", "davidgohel/flextable",
         "ddsjoberg/gtsummary", "rstudio/DT", "haozhu233/kableExtra", "quarto-dev/quarto-cli",
         "rfordatascience/tidytuesday", "posit-dev/gt-extras", "rich-iannone/table-contest",
         "machow/reactable-py", "tidyverse/ggplot2", "rstudio/bslib", "rstudio/rstudio"}
NOT_ENTRY = re.compile(r"announc|winners|^about the|deadline|judging", re.I)


def get(url, offline, as_json=True):
    path = os.path.join(CACHE, re.sub(r"[^\w.-]+", "_", url))
    if not os.path.exists(path):
        if offline:
            raise SystemExit(f"not in the cache: {url} (run without --offline)")
        os.makedirs(CACHE, exist_ok=True)
        for attempt in range(4):
            try:
                req = urllib.request.Request(url, headers={"Accept": "application/json" if as_json else "text/html"})
                with urllib.request.urlopen(req, timeout=30) as r:
                    open(path, "wb").write(r.read())
                break
            except OSError:
                if attempt == 3:
                    raise
                time.sleep(2 ** (attempt + 1))
        time.sleep(0.3)  # the forum is a shared service: no bursts
    s = open(path, encoding="utf-8", errors="replace").read()
    return json.loads(s) if as_json else s


def repo_of(url):
    """owner/repo, and the folder and branch when the link points inside the repository."""
    m = re.match(r"https?://github\.com/([\w.-]+)/([\w.-]+?)(?:\.git)?(?:/(tree|blob)/([^/]+)(?:/(.*?))?)?/?(?:[?#].*)?$", url)
    if not m or m.group(2) in ("issues", "pulls", "discussions"):
        return None
    repo, kind, ref, path = f"{m.group(1)}/{m.group(2)}", m.group(3), m.group(4), m.group(5) or ""
    if kind == "blob":
        path = os.path.dirname(path)
    return repo, ref, path


def forum_entries(offline):
    topics = {}
    for tag in TAGS:
        page = 0
        while True:
            d = get(f"{FORUM}/tag/{tag}.json?page={page}", offline)
            ts = d["topic_list"]["topics"]
            for t in ts:
                topics.setdefault(t["id"], t)
            if not ts or not d["topic_list"].get("more_topics_url"):
                break
            page += 1
    for tid, t in sorted(topics.items()):
        if NOT_ENTRY.search(t["title"]):
            continue
        post = get(f"{FORUM}/t/{tid}.json", offline)["post_stream"]["posts"][0]
        links = re.findall(r'href="(https?://github\.com/[^"]+)"', post["cooked"])
        found = [r for r in map(repo_of, links) if r and r[0] not in TOOLS]
        repo, ref, path = found[0] if found else (None, None, "")  # the winners post may know it
        # the tag of a year wins; the plain tag was used every year, so then the date says
        names = [g if isinstance(g, str) else g.get("name", "") for g in t.get("tags", [])]
        years = [int(g[-4:]) for g in names if re.fullmatch(r"table-contest-\d{4}", g)]
        year = years[0] if years else int(t["created_at"][:4])
        year = 2022 if year == 2023 else year  # the 2022 contest closed in January 2023
        yield dict(repo=repo, ref=ref, path=path, year=year, title=html.unescape(t["title"]),
                   by=post.get("name") or post["username"], post=f"{FORUM}/t/{t['slug']}/{tid}")


def post_key(url):
    """The same entry in a winners post and in the forum: the topic's number (the forum moved
    from community.rstudio.com, the numbers stayed), or the number of the 2025 Discussion."""
    m = re.search(r"/t/(?:[^/]+/)?(\d+)", url) or re.search(r"/discussions/(\d+)", url)
    return ("d" if "/discussions/" in url else "t") + m.group(1) if m else url


REPO_FIRST = {2020, 2021}  # these posts link the repository before the forum topic


def winners(offline):
    """Every entry named in a winners post: its prize, its title and the repository the post
    links. The post is read as a stream of headings and links: a heading names the prize, a
    link to a forum topic (or a 2025 Discussion) is an entry, and its repository is the
    GitHub link just before it (2020, 2021: "Repo – Community") or just after it (2024, 2025:
    the title, then "Code"). 2020's winner and runner up have no forum link: they are found by
    their repository, in order under their heading."""
    named, by_repo = {}, {}
    for year, slug in WINNERS.items():
        s = get(f"https://posit.co/blog/{slug}/", offline, as_json=False)
        s = re.sub(r"<script.*?</script>|<style.*?</style>", "", s, flags=re.S)
        s = s[:s.find("Related Content")] if "Related Content" in s else s
        heading, current, pending, under = "", None, None, 0
        toks = r"<h[2-4][^>]*>(.*?)</h[2-4]>|<p class=\"h4[^\"]*\">(.*?)</p>|<a [^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>"
        for tok in re.finditer(toks, s, re.S):
            h, h4, href, text = tok.groups()
            h = h if h is not None else h4
            if h is not None:
                t = html.unescape(re.sub(r"<[^>]+>", "", h)).strip()
                inner = re.search(r'href="([^"]+)"[^>]*>(.*?)</a>', h, re.S)
                if inner and re.search(r"forum\.posit\.co/t/|discussions/\d", inner.group(1)):
                    href, text = inner.groups()  # 2025: the title in a heading is the entry
                elif t:
                    heading, current, pending, under = t, None, None, 0
                    continue
                else:
                    continue
            if re.search(r"forum\.posit\.co/t/|community\.rstudio\.com/t/|table-contest/discussions/\d", href):
                key = post_key(href)
                if key in named:
                    continue
                current = dict(post=href, prize=heading, year=year,
                               title=html.unescape(re.sub(r"<[^>]+>", "", text)).strip())
                named[key] = current
                if year in REPO_FIRST and pending:
                    current["repo"], current["ref"], current["path"] = pending
                    current = None  # its repository came first; what follows is the next entry's
                pending = None
                continue
            r = repo_of(href)
            if not r or r[0] in TOOLS:
                continue
            if year in REPO_FIRST:
                pending = pending or r
                if re.search(r"Winner and the Runner", heading) and r[0] not in by_repo:
                    under += 1
                    by_repo[r[0]] = "Winner" if under == 1 else "Runner up"
            elif current is not None and "repo" not in current:
                current["repo"], current["ref"], current["path"] = r
    return named, by_repo


def label(prize):
    p = re.sub(r"^(The\s+|Special Prize Categories\s*)", "", prize).strip()
    if re.fullmatch(r"Static Tables|Tutorials|Table Packages", p):
        return "Honourable mention"  # 2020 grouped its honourable mentions by kind
    if re.search(r"honou?rable", p, re.I):
        return "Honourable mention"
    if re.search(r"runner", p, re.I):
        return "Runner up"
    if re.fullmatch(r"winner.*", p, re.I) or p.lower().startswith("winner"):
        return "Winner"
    return p


def main(offline):
    named, by_repo = winners(offline)
    found = []
    for e in forum_entries(offline):
        w = named.pop(post_key(e["post"]), None)
        if e["repo"] in by_repo:  # 2020's winner and runner up share one heading
            w = dict(w or {}, prize=by_repo[e["repo"]])
        if w:
            e["prize"] = w["prize"]
            if w.get("repo"):  # the code the winners post links, when it names one
                e["repo"], e["ref"], e["path"] = w["repo"], w.get("ref"), w.get("path", "")
        if e["repo"]:
            found.append(e)
    # entries named in a winners post and not found in the forum: 2025 (GitHub Discussions)
    found += [w for w in named.values() if w.get("repo") and w["year"] == 2025]
    path = os.path.join(HERE, "sources.json")
    sources = json.load(open(path), object_pairs_hook=collections.OrderedDict)
    src = next(s for s in sources["sources"] if s["id"] == "table-contest")
    old = {e["repo"]: e for e in src["find"]["entries"]}
    entries, seen = [], set()
    for e in sorted(found, key=lambda e: (e["year"], e["title"].lower())):
        if e["repo"] in seen:
            continue
        seen.add(e["repo"])
        hand = old.get(e["repo"], {})
        out = collections.OrderedDict(repo=e["repo"])
        if e.get("ref"):
            out["ref"] = e["ref"]
        if e.get("path"):
            out["path"] = e["path"]
        out["year"] = e["year"]
        out["title"] = hand.get("title", re.sub(r"\s*[-|:]?\s*(?:\|>\s*)?Table Contest( Submission)?\s*$", "",
                                               e["title"], flags=re.I).strip() or e["title"])
        out["by"] = hand.get("by", e.get("by", ""))
        out["post"] = e["post"]
        if e.get("prize") and not re.search(r"closing", e["prize"], re.I):
            out["prize"] = label(e["prize"])
        for k in ("package", "licence", "note", "port", "found"):
            if k in hand:
                out[k] = hand[k]
        entries.append(out)
    for repo, e in old.items():  # an entry listed by hand that the search does not find stays
        if repo not in seen:
            entries.append(e)
    src["find"]["entries"] = entries
    json.dump(sources, open(path, "w"), indent=1, ensure_ascii=False)
    open(path, "a").write("\n")
    print(len(entries), "entries:", dict(collections.Counter(e["year"] for e in entries)))


if __name__ == "__main__":
    main("--offline" in sys.argv)
