"""Runs the Great Tables side of a chapter of the tabelline book.

    uv run --project book/gt python book/gt/run.py < cells.json > outputs.json

Reads `{"chapter": <name>, "cells": [<python code>, ...]}` and runs the cells in order, in one
namespace, like the cells of a notebook. For each cell it writes what the cell printed and the
HTML of its last expression, if it ends with one: a GT table (or a list of them) as `as_raw_html()`, a DataFrame as
its `_repr_html_()`. The book's build (book/tabbook.nim) calls this only when a chapter's Python
changed, and keeps the outputs in book/gt/outputs/<chapter>.json, which is committed: building
the book needs no Python otherwise.

Great Tables gives every table a random id; the random generator is seeded with the chapter's
name, so running a chapter again gives the same HTML.
"""
import ast, contextlib, html, io, json, os, random, re, sys

os.chdir(os.path.dirname(os.path.abspath(__file__)))  # cells read data relative to book/gt


def shown(value):
    if value is None:
        return ""
    if hasattr(value, "as_raw_html"):  # a GT table
        return value.as_raw_html()
    if isinstance(value, (list, tuple)) and value and all(hasattr(v, "as_raw_html") for v in value):
        return "".join(v.as_raw_html() for v in value)  # tables one after the other
    if hasattr(value, "_repr_html_"):
        h = value._repr_html_()
        if h:
            return h
    return '<pre class="nb-output">' + html.escape(repr(value)) + "</pre>"


def run(code, ns):
    tree = ast.parse(code)
    last = None
    if tree.body and isinstance(tree.body[-1], ast.Expr):
        last = ast.Expression(tree.body.pop().value)
    out = io.StringIO()
    with contextlib.redirect_stdout(out):
        exec(compile(tree, "<python>", "exec"), ns)
        value = eval(compile(last, "<python>", "eval"), ns) if last is not None else None
    h = shown(value)
    # nothing remote in the book's pages
    h = re.sub(r"@import url\([^)]*\);?", "", h)
    return {"printed": out.getvalue(), "html": h}


def main():
    req = json.load(sys.stdin)
    random.seed(req["chapter"])
    ns = {}
    outputs = []
    for code in req["cells"]:
        try:
            outputs.append(run(code, ns))
        except Exception as e:  # shown in the page, and the build says so
            outputs.append({"printed": "", "html": "", "error": f"{type(e).__name__}: {e}"})
    json.dump(outputs, sys.stdout)


if __name__ == "__main__":
    main()
