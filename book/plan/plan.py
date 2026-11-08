"""Searches the sources the book plans to port, and maps every page to the features it needs.

    python3 book/plan/plan.py                 # search the sources, write pages.json
    python3 book/plan/plan.py --offline       # the same, from the copies in book/plan/cache/
    python3 book/plan/plan.py fmt_currency    # the pages that show a feature (a gt function or
    python3 book/plan/plan.py "row groups"    #   words of a feature's name), simplest first

Every source in book/plan/sources.json says where its pages are: a GitHub repository and the
paths of its pages (`find`). The search lists the repository's files with a shallow, blobless
git clone into book/plan/cache/ (no API, no token), so a page added upstream is found, and a page
listed by hand that is no longer there is reported. The pages listed in sources.json are only
the ones the book has something to say about (a title, `port`, a `note`, gaps `found`); a page
found and not listed gets `port: "triage"` until someone reads it.

Two kinds of source:
- a guide, a blog, a gallery: one page per file (Quarto, R Markdown or a notebook), its code in
  the ```{python} and ```{r} chunks;
- a reference: the examples on the help page of every function. For gt, the `Examples` section
  of each `man/*.Rd`; for Great Tables, the `Examples` section of the docstring of every name in
  the API reference (`docs/_quarto.yml`), found by following the imports in `great_tables/`.

For each page the search finds the gt and Great Tables functions its code calls and looks each
one up in the coverage map (docs/coverage/gt.json). A page is ready in the first release that
has every feature it calls. It sees the functions, not their arguments, so a page ready by this
measure can still find gaps when it is ported (the Get Started guide found a dozen). Those go to
book/gaps.md and to the page's `found`.

It writes book/plan/pages.json: every page, by source, with the commit it was read at, what it
waits for (`needs`) and every feature of the map it shows (`uses`). The book reads it, and so
does the search by feature (the command with words), which lists first the help pages of the
feature's own functions, then the other pages from the smallest.
"""
import ast, collections, fnmatch, json, os, re, signal, subprocess, sys, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
CACHE = os.path.join(HERE, "cache")
RELEASES = ["0.1", "0.2", "0.3", "0.4", "0.5"]
LATER = "later"  # not planned for a release yet
NEW = "new"  # a gap the coverage map does not have yet
ORDER = RELEASES + [NEW, LATER]

# gt-extras and gtExtras functions: plots, icons and themes in cells, planned with nanoplots.
EXTRAS = re.compile(r"\b(?:gte\.)?(gt_plt_\w+|gt_theme_\w+|gt_color_\w+|gt_fa_\w+|gt_highlight_\w+|"
                    r"gt_hulk_\w+|gt_merge_stack|gt_add_divider|gt_img_\w+|gt_sparkline|gt_\w+_rating|"
                    r"fa_icon_repeat|fmt_pct_extra|fmt_pill|add_text_img|img_header)\s*\(")
EXTRAS_FEATURE = ("Plots, icons and themes from gt-extras", "0.4")


# ---------------------------------------------------------------- the coverage map

def coverage():
    cov = json.load(open(os.path.join(ROOT, "docs", "coverage", "gt.json")))
    rows = [dict(r, area=a["title"]) for a in cov["areas"] for r in a["rows"]]
    exact, prefix, args = {}, [], {}
    for i, r in enumerate(rows):
        for tok in re.findall(r"(?:^|,\s*)([a-z_]+)=?(?=,|$)", r["gt"]):  # an argument: groupname_col
            args.setdefault(tok, i)
        for tok in re.findall(r"([A-Za-z_][\w.]*\*?)\(\)", r["gt"]):
            tok = tok.split(".")[-1]
            if tok.endswith("*"):
                prefix.append((tok[:-1], i))
            else:
                exact.setdefault(tok, i)
    prefix.sort(key=lambda x: -len(x[0]))
    return rows, exact, prefix, args


def plan_of(row):
    """The release a coverage row is ready in."""
    if row["status"] == "done":
        return "0.1"
    if row["status"] == "partial" and not row.get("plan"):
        return "0.1"  # what is there is all that is planned (fonts: no remote Google fonts)
    if row["status"] == "no":
        # "no" with a Nim way (sizes are strings) is not a gap; without one it waits
        return "0.1" if row["feature"] == "Sizes" else LATER
    return row.get("plan") or LATER


ALIAS = {"fill": "cell_fill", "text": "cell_text", "borders": "cell_borders"}


def calls(code):
    out = collections.Counter()
    for m in re.finditer(r"(?:\b(loc|style|vals)\.)?\b([a-z_][a-z0-9_]*)\s*\(", code):
        ns, name = m.groups()
        if ns == "loc":
            name = "cells_" + name
        elif ns == "style":
            name = ALIAS.get(name, name)
        out[name] += 1
    if re.search(r"\bGT\s*\(|\bgt\s*\(", code):
        out["gt"] += 1
    return out


def lookup(name, exact, prefix):
    if name in exact:
        return exact[name]
    if name.startswith("loc_") and "cells_" + name[4:] in exact:
        return exact["cells_" + name[4:]]
    for p, i in prefix:
        if p and name.startswith(p):
            return i
    return None


# ---------------------------------------------------------------- reading a repository

def repo_dir(repo):
    return os.path.join(CACHE, "repos", repo.replace("/", "__"))


def listing(repo, ref, offline):
    """The commit of `ref` and every file path in it, from a shallow blobless clone."""
    d = repo_dir(repo)
    git = lambda *a: subprocess.run(["git", "-C", d, *a], check=True, capture_output=True, text=True).stdout
    if not offline:
        if not os.path.exists(d):
            os.makedirs(os.path.dirname(d), exist_ok=True)
            subprocess.run(["git", "clone", "-q", "--depth", "1", "--filter=blob:none", "--no-checkout",
                            "--branch", ref, f"https://github.com/{repo}", d], check=True)
        else:
            git("fetch", "-q", "--depth", "1", "--filter=blob:none", "origin", ref)
            git("update-ref", "HEAD", "FETCH_HEAD")
    return git("rev-parse", "HEAD").strip(), git("ls-tree", "-r", "--name-only", "HEAD").split("\n")


def read(repo, commit, path, offline):
    """A file of the repository at `commit`, from raw.githubusercontent.com, kept in the cache."""
    f = os.path.join(CACHE, "files", repo.replace("/", "__"), commit[:12], path)
    if not os.path.exists(f):
        if offline:
            raise SystemExit(f"not in the cache: {repo} {path} (run without --offline)")
        os.makedirs(os.path.dirname(f), exist_ok=True)
        url = f"https://raw.githubusercontent.com/{repo}/{commit}/{path}"
        with urllib.request.urlopen(url, timeout=30) as r:
            open(f, "wb").write(r.read())
    return open(f, encoding="utf-8", errors="replace").read()


def matches(path, globs):
    return any(fnmatch.fnmatchcase(path, g) for g in globs)


# ---------------------------------------------------------------- pages of a guide

def code_of(path, s):
    if path.endswith(".ipynb"):
        cells = json.loads(s)["cells"]
        return "\n".join("".join(c["source"]) for c in cells if c["cell_type"] == "code")
    return "\n".join(re.findall(r"```\{?(?:python|r|R)[^\n]*\n(.*?)```", s, re.S))


def title_of(path, s):
    if path.endswith(".ipynb"):
        for c in json.loads(s)["cells"]:
            if c["cell_type"] == "markdown":
                m = re.search(r"^#+\s+(.+)$", "".join(c["source"]), re.M)
                if m:
                    return m.group(1).strip()
        return os.path.basename(os.path.dirname(path))
    m = re.search(r"^---\n.*?^title:\s*[\"']?(.+?)[\"']?\s*$", s, re.S | re.M)
    return m.group(1) if m else os.path.splitext(os.path.basename(path))[0]


def url_of(find, path):
    site = find["site"]
    p = path[len(site.get("strip", "")):] if path.startswith(site.get("strip", "")) else path
    stem = os.path.splitext(p)[0]
    if stem == "index" or stem.endswith("/index"):
        return site["base"] + stem[:-len("index")]  # a folder's page: its folder
    return site["base"] + stem + ".html"


def guide_pages(find, commit, files, offline):
    for path in files:
        if matches(path, find["paths"]) and not matches(path, find.get("skip", [])):
            s = read(find["repo"], commit, path, offline)
            yield path, title_of(path, s), url_of(find, path), code_of(path, s)


# ---------------------------------------------------------------- examples of a reference (gt, R)

def braced(s, start):
    """The text inside the braces that open at s[start], and where they close."""
    depth, i = 0, start
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s) and s[i + 1] in "{}":
            i += 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return s[start + 1:i], i
        i += 1
    return s[start + 1:], len(s)


def rd_examples(s):
    """The code of the Examples section of an Rd file: its \\preformatted blocks."""
    m = re.search(r"\\section\{Examples\}\{", s)
    if not m:
        return ""
    body, _ = braced(s, m.end() - 1)
    code, i = [], 0
    while (j := body.find("\\preformatted{", i)) >= 0:
        block, i = braced(body, j + len("\\preformatted"))
        code.append(block.replace("\\{", "{").replace("\\}", "}").replace("\\%", "%"))
    return "\n".join(code)


def rd_pages(find, commit, files, offline):
    for path in files:
        if matches(path, find["paths"]):
            s = read(find["repo"], commit, path, offline)
            code = rd_examples(s)
            if code.strip():
                m = re.search(r"\\name\{(.+?)\}", s)
                name = m.group(1) if m else os.path.basename(path)[:-3]
                yield path, name + "()", url_of(find, path), code


# ---------------------------------------------------------------- examples of a reference (Great Tables)

def py_examples(doc):
    m = re.search(r"^\s*Examples\s*\n\s*-{3,}\s*\n", doc or "", re.M)
    if not m:
        return ""
    rest = doc[m.end():]
    end = re.search(r"^\s*\w[\w ]*\n\s*-{3,}\s*\n", rest, re.M)  # the next numpydoc section
    return code_of("", rest[:end.start()] if end else rest)


class Package:
    """Follows the names of a Python package (imports, aliases, class bodies) to their docstrings."""

    def __init__(self, repo, commit, root, files, offline):
        self.repo, self.commit, self.root, self.offline = repo, commit, root, offline
        self.files, self.trees, self.packages = set(files), {}, {""}

    def module(self, mod):
        if mod not in self.trees:
            base = self.root + "/" + mod.replace(".", "/") if mod else self.root
            path = base + ".py" if base + ".py" in self.files else base + "/__init__.py"
            if path not in self.files:
                self.trees[mod] = None
            else:
                self.trees[mod] = ast.parse(read(self.repo, self.commit, path, self.offline))
                if path.endswith("/__init__.py"):
                    self.packages.add(mod)
        return self.trees[mod]

    def find(self, body, mod, name, depth=0):
        """The node `name` defines in `body` (a module's or a class's in module `mod`), following
        imports and aliases, and the module it is in."""
        if depth > 12:
            return None, mod
        for node in body:
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)) and node.name == name:
                return node, mod
        top = self.module(mod).body
        for node in body:
            if isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == name for t in node.targets):
                if isinstance(node.value, ast.Name):  # `fmt_number = fmt_number` in a class body
                    return self.find(top, mod, node.value.id, depth + 1) if body is not top or \
                        node.value.id != name else (None, mod)
            if isinstance(node, ast.ImportFrom) and node.level >= 1:
                for a in node.names:
                    if (a.asname or a.name) == name:
                        parts = mod.split(".") if mod else []
                        here = parts if mod in self.packages else parts[:-1]
                        parent = here[:len(here) - (node.level - 1)]
                        target = ".".join(parent + ([node.module] if node.module else []))
                        tree = self.module(target)
                        return self.find(tree.body, target, a.name, depth + 1) if tree else (None, mod)
        if body is not top:
            return self.find(top, mod, name, depth + 1)
        return None, mod

    def resolve(self, dotted):
        """`GT.fmt_number`, `loc.body`, `md`: the function or class it names."""
        parts, mod = dotted.split("."), ""
        if len(parts) > 1 and self.module(parts[0]) is not None:
            mod, parts = parts[0], parts[1:]  # loc.body: the module great_tables/loc.py
        node, mod = self.find(self.module(mod).body, mod, parts[0])
        for p in parts[1:]:
            if not isinstance(node, ast.ClassDef):
                return None
            node, mod = self.find(node.body, mod, p)
        return node


def quartodoc_names(s):
    """The names in the API reference of a quartodoc site, in the order of the reference."""
    names, inside = [], False
    for line in s.split("\n"):
        if re.match(r"^quartodoc:", line):
            inside = True
        elif inside and re.match(r"^\S", line):
            break
        elif inside and (m := re.match(r"^\s+-\s+(?:name:\s+)?([A-Za-z_][\w.]*)\s*$", line)):
            names.append(m.group(1))
    return names


def py_pages(find, commit, files, offline):
    pkg = Package(find["repo"], commit, find["package"], files, offline)
    for name in quartodoc_names(read(find["repo"], commit, find["quartodoc"], offline)):
        node = pkg.resolve(name)
        code = py_examples(ast.get_docstring(node)) if node else ""
        if code.strip():
            yield "reference/" + name, name + ("()" if not name.startswith("data.") else ""), \
                find["site"]["base"] + name + ".html", code


# ---------------------------------------------------------------- the search

KINDS = {"pages": guide_pages, "rd": rd_pages, "quartodoc": py_pages}


def main(offline):
    rows, exact, prefix, args = coverage()
    sources = json.load(open(os.path.join(HERE, "sources.json")))["sources"]
    out, report = {}, []
    for s in sources:
        find = s["find"]
        commit, files = listing(find["repo"], find.get("ref", "main"), offline)
        listed = {p["path"]: p for p in s.get("pages", [])}
        pages = []
        for path, title, url, code in KINDS[find.get("kind", "pages")](find, commit, files, offline):
            hand = listed.pop(path, None)
            needs, uses = collections.defaultdict(set), set()
            n = calls(code)
            for name in n:
                i = lookup(name, exact, prefix)
                if i is not None:
                    needs[plan_of(rows[i])].add(rows[i]["feature"])
                    uses.add(i)
            for name, i in args.items():
                if re.search(r"\b" + name + r"\s*=", code):
                    needs[plan_of(rows[i])].add(rows[i]["feature"])
                    uses.add(i)
            if EXTRAS.search(code):
                needs[EXTRAS_FEATURE[1]].add(EXTRAS_FEATURE[0])
            for f in (hand or {}).get("found", []):  # gaps the map does not have, found by reading the page
                needs[NEW].add(f)
            ready = max((r for r in needs), key=ORDER.index, default="0.1")
            port = hand["port"] if hand else ("port" if s["kind"] == "reference" else "triage")
            if not hand and s["kind"] != "reference":
                report.append(f"  new page in {s['id']}: {path} ({title})")
            page = {"title": (hand or {}).get("title", title), "path": path,
                    "url": (hand or {}).get("url", url), "port": port,
                    "note": (hand or {}).get("note", ""), "ready": ready,
                    "calls": sum(n.values()),
                    "needs": {r: sorted(needs[r]) for r in ORDER if r in needs and r != "0.1"},
                    "uses": sorted(rows[i]["feature"] for i in uses)}
            pages.append(page)
        for path in listed:
            report.append(f"  gone from {s['id']}: {path} (listed in sources.json, not in {find['repo']})")
        out[s["id"]] = {"commit": commit, "pages": pages}
    json.dump(out, open(os.path.join(HERE, "pages.json"), "w"), indent=1, ensure_ascii=False)
    for sid, o in out.items():
        print(sid, len(o["pages"]), "pages:", dict(collections.Counter(p["ready"] for p in o["pages"])))
    print("\n".join(report) or "every page found is listed, every page listed is found")


def gt_names(gt):
    """The functions a row of the coverage map names, without namespaces: fmt_number, cells_body."""
    return {t.split(".")[-1] for t in re.findall(r"([A-Za-z_][\w.]*)\(\)", gt)}


def by_feature():
    """For every feature of the coverage map, the pages that show it, best first: the help pages
    of its own functions, then the other pages from the smallest (fewest calls)."""
    rows = coverage()[0]
    out = json.load(open(os.path.join(HERE, "pages.json")))
    index = {r["feature"]: [] for r in rows}
    for sid, o in out.items():
        for p in o["pages"]:
            if p["port"] != "skip":
                for f in p["uses"]:
                    index[f].append(dict(p, source=sid))
    for r in rows:
        own = gt_names(r["gt"])
        main = lambda p: p["title"].removesuffix("()").split(".")[-1] in own
        index[r["feature"]].sort(key=lambda p: (not main(p), p["calls"], p["title"]))
    return rows, index


def search(words):
    """Prints the pages that show a feature, from pages.json: no fetching."""
    rows, index = by_feature()
    w = words.lower()
    hits = [r for r in rows if w in r["feature"].lower() or
            re.search(r"\b" + re.escape(w) + r"\b", r["gt"].lower())]
    if not hits:
        raise SystemExit(f"no feature of the coverage map is called {words!r}")
    for r in hits:
        ps = index[r["feature"]]
        print(f"{r['feature']} ({r['area']}; {r['gt']}), ready {plan_of(r)}: {len(ps)} pages")
        for p in ps:
            print(f"  {p['calls']:4} calls  ready {p['ready']:5}  {p['source']:16} {p['title']}  {p['url']}")


if __name__ == "__main__":
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)  # `plan.py fmt_currency | head` stops quietly
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if args:
        search(" ".join(args))
    else:
        main("--offline" in sys.argv)
