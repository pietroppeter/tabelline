"""Maps every page the book plans to port to the tabelline features it needs.

    python3 book/plan/plan.py            # fetch the pages, write book/plan/pages.json
    python3 book/plan/plan.py --offline  # use the copies already in book/plan/cache/

Reads the sources in book/plan/sources.json, downloads each page's source (Quarto, R Markdown
or a notebook) from raw.githubusercontent.com into book/plan/cache/ (not committed), finds the
gt and Great Tables functions its code calls, and looks each one up in the coverage map
(docs/coverage/gt.json). A page is ready in the first release that has every feature it calls.

This is a first sieve: it sees the functions, not their arguments, so a page ready by this
measure can still find gaps when it is ported (the Get Started guide found a dozen). Those go
to book/gaps.md as they are found.
"""
import collections, json, os, re, sys, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
CACHE = os.path.join(HERE, "cache")
RELEASES = ["0.1", "0.2", "0.3", "0.4", "0.5"]
LATER = "later"  # not planned for a release yet
NEW = "new"  # a gap the coverage map does not have yet

# gt-extras and gtExtras functions: plots, icons and themes in cells, planned with nanoplots.
EXTRAS = re.compile(r"\b(?:gte\.)?(gt_plt_\w+|gt_theme_\w+|gt_color_\w+|gt_fa_\w+|gt_highlight_\w+|"
                    r"gt_hulk_\w+|gt_merge_stack|gt_add_divider|gt_img_\w+|gt_sparkline|gt_\w+_rating|"
                    r"fa_icon_repeat|fmt_pct_extra|fmt_pill|add_text_img|img_header)\s*\(")
EXTRAS_FEATURE = ("Plots, icons and themes from gt-extras", "0.4")


def coverage():
    cov = json.load(open(os.path.join(ROOT, "docs", "coverage", "gt.json")))
    rows = [dict(r, area=a["title"]) for a in cov["areas"] for r in a["rows"]]
    exact, prefix = {}, []
    for i, r in enumerate(rows):
        for tok in re.findall(r"([A-Za-z_][\w.]*\*?)\(\)", r["gt"]):
            tok = tok.split(".")[-1]
            if tok.endswith("*"):
                prefix.append((tok[:-1], i))
            else:
                exact.setdefault(tok, i)
    prefix.sort(key=lambda x: -len(x[0]))
    return rows, exact, prefix


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


def code_of(path):
    s = open(path, encoding="utf-8", errors="replace").read()
    if path.endswith(".ipynb"):
        cells = json.loads(s)["cells"]
        return "\n".join("".join(c["source"]) for c in cells if c["cell_type"] == "code")
    return "\n".join(re.findall(r"```\{?(?:python|r|R)[^\n]*\n(.*?)```", s, re.S))


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


def fetch(raw, offline):
    path = os.path.join(CACHE, raw.replace("/", "__"))
    if not offline and not os.path.exists(path):
        os.makedirs(CACHE, exist_ok=True)
        with urllib.request.urlopen("https://raw.githubusercontent.com/" + raw, timeout=30) as r:
            open(path, "wb").write(r.read())
    return path


def main():
    offline = "--offline" in sys.argv
    rows, exact, prefix = coverage()
    sources = json.load(open(os.path.join(HERE, "sources.json")))["sources"]
    out = {}
    for s in sources:
        pages = []
        for p in s["pages"]:
            code = code_of(fetch(p["raw"], offline))
            needs = collections.defaultdict(set)
            for name in calls(code):
                i = lookup(name, exact, prefix)
                if i is not None:
                    needs[plan_of(rows[i])].add(rows[i]["feature"])
            if EXTRAS.search(code):
                needs[EXTRAS_FEATURE[1]].add(EXTRAS_FEATURE[0])
            for f in p.get("found", []):  # gaps the map does not have, found by reading the page
                needs[NEW].add(f)
            order = RELEASES + [NEW, LATER]
            ready = max((r for r in needs), key=order.index, default="0.1")
            pages.append({"title": p["title"], "url": p["url"], "port": p["port"],
                          "note": p.get("note", ""), "ready": ready,
                          "needs": {r: sorted(needs[r]) for r in order if r in needs and r != "0.1"}})
        out[s["id"]] = pages
    json.dump(out, open(os.path.join(HERE, "pages.json"), "w"), indent=1, ensure_ascii=False)
    for sid, pages in out.items():
        print(sid, collections.Counter(p["ready"] for p in pages))


if __name__ == "__main__":
    main()
