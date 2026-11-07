"""Make a preview copy of the built pages, for a claude.ai artifact.

    python3 tools/preview.py [out]      (default out: ../tabelline-preview)

Run it after `nim r -d:release docs/all.nim`. An artifact serves files but not directories, so
every relative link to a folder (`../roadmap/`) is rewritten to its index.html. The home page
also gets a small router: a link to the artifact ending in `#<page>` opens that page, where
<page> is the page's folder with `/` as `-`: `#devlog-three-threads`, `#roadmap`, `#coverage`.
Artifacts pass only a plain `#name` to the page, so this is the one form a deep link can take.
The router is added to the preview only, not to the site.
"""
import re, shutil, sys
from pathlib import Path

docs = Path(__file__).resolve().parent.parent / "docs"
out = Path(sys.argv[1]) if len(sys.argv) > 1 else docs.parent.parent / "tabelline-preview"

pages = sorted(p.relative_to(docs) for p in docs.rglob("index.html") if "assets" not in p.parts)
if out.exists():
    shutil.rmtree(out)

link = re.compile(r'href="((?!https?:|#|mailto:|data:)[^"?#]*/)([?#][^"]*)?"')
for rel in pages:
    s = (docs / rel).read_text()
    s = link.sub(lambda m: f'href="{m.group(1)}index.html{m.group(2) or ""}"', s)
    s = re.sub(r'href="(\.\.?)([?#][^"]*)?"', lambda m: f'href="{m.group(1)}/index.html{m.group(2) or ""}"', s)
    if rel == Path("index.html"):
        routes = {str(p.parent).replace("/", "-"): str(p) for p in pages if p != rel}
        js = ("<script>(function(){var r=%s;var h=location.hash.slice(1);"
              "if(r[h])location.replace(r[h]);})();</script>") % (
              "{" + ",".join(f'"{k}":"{v}"' for k, v in routes.items()) + "}")
        s = s.replace("</head>", js + "</head>", 1)
    dest = out / rel
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(s)
    print(dest.relative_to(out), f"#{str(rel.parent).replace('/', '-')}" if rel.parent != Path(".") else "")
