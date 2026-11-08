"""Expand HTML tables (rowspan/colspan aware) into cells: table, row, col, text.

Usage: python3 -I grid.py <html file> [min_cols]   prints the tables as TSV rows, for inspection,
or import it and call tables(path).
"""
import html.parser, re, sys

class P(html.parser.HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack, self.out = [], []
    def handle_starttag(self, tag, a):
        a = dict(a)
        if tag == "table":
            self.stack.append({"rows": [], "row": None, "cell": None})
        elif not self.stack:
            return
        elif tag == "tr":
            self.stack[-1]["row"] = []
            self.stack[-1]["rows"].append(self.stack[-1]["row"])
        elif tag in ("td", "th"):
            t = self.stack[-1]
            if t["row"] is None:
                t["row"] = []; t["rows"].append(t["row"])
            t["cell"] = {"text": "", "rs": int(re.sub(r"\D", "", a.get("rowspan") or "1") or 1),
                         "cs": int(re.sub(r"\D", "", a.get("colspan") or "1") or 1)}
            t["row"].append(t["cell"])
        elif tag == "br" and self.stack[-1]["cell"] is not None:
            self.stack[-1]["cell"]["text"] += " / "
    def handle_endtag(self, tag):
        if tag == "table" and self.stack:
            self.out.append(self.stack.pop()["rows"])
        elif tag in ("td", "th") and self.stack:
            self.stack[-1]["cell"] = None
    def handle_data(self, d):
        if self.stack and self.stack[-1]["cell"] is not None:
            self.stack[-1]["cell"]["text"] += d

def expand(rows):
    grid, pending = [], {}
    for r in rows:
        line, c = [], 0
        cells = list(r)
        while cells or any(k[0] == len(grid) for k in pending):
            if (len(grid), c) in pending:
                line.append(pending.pop((len(grid), c))); c += 1; continue
            if not cells:
                if any(k[0] == len(grid) and k[1] > c for k in pending):
                    line.append(""); c += 1; continue
                break
            cell = cells.pop(0)
            txt = " / ".join(x for x in (re.sub(r"\s+", " ", y).strip() for y in cell["text"].split(" / ")) if x)
            for j in range(cell["cs"]):
                for i in range(1, cell["rs"]):
                    pending[(len(grid) + i, c + j)] = txt
                line.append(txt)
            c += cell["cs"]
        grid.append(line)
    return grid

def tables(path):
    raw = open(path, "rb").read()
    try:
        txt = raw.decode("utf-8")
    except UnicodeDecodeError:
        txt = raw.decode("cp1252", errors="replace")
    p = P(); p.feed(txt)
    return [expand(t) for t in p.out]

if __name__ == "__main__":
    mc = int(sys.argv[2]) if len(sys.argv) > 2 else 3
    for i, g in enumerate(tables(sys.argv[1])):
        if max((len(r) for r in g), default=0) >= mc:
            print(f"### table {i}")
            for r in g:
                print("\t".join(r))
