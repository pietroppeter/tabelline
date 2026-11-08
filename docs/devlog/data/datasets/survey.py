"""Counts the datasets that the first pages of gt and Great Tables use: writes survey.tsv.

Run from anywhere: python3 survey.py. Reads the sources from raw.githubusercontent.com (the docs'
own sites may be blocked). The post keeps the file as a dated snapshot (8 November 2026).
"""
import re, urllib.request, pathlib

RAW = "https://raw.githubusercontent.com/"
NAMES = ["countrypops", "sza", "gtcars", "sp500", "pizzaplace", "exibble", "towny", "peeps", "films",
         "metro", "gibraltar", "constants", "illness", "reactions", "photolysis", "nuclides",
         "rx_adsl", "rx_addv", "islands", "airquality"]
GS = ["index", "overview", "basic-header", "basic-stub", "basic-column-labels", "basic-formatting",
      "nanoplots", "basic-styling", "targeted-styles", "colorizing-with-data", "table-theme-options",
      "table-theme-premade", "column-selection", "row-selection", "loc-selection"]
PAGES = (
    [("gt", "README", "rstudio/gt/master/README.md")] +
    [("gt", "Introduction (vignette)", "rstudio/gt/master/vignettes/gt.Rmd")] +
    [("Great Tables", "README", "posit-dev/great-tables/main/README.md")] +
    [("Great Tables", "Get Started: " + p, f"posit-dev/great-tables/main/docs/get-started/{p}.qmd") for p in GS] +
    [("Great Tables", "Examples", "posit-dev/great-tables/main/docs/examples/index.qmd")])
REFERENCE = ["format_data", "tab_create_modify", "data_color", "utils_render_html"]

def get(path):
    with urllib.request.urlopen(RAW + path, timeout=30) as r:
        return r.read().decode()

def code(text):
    """The code chunks of a page (```{python} / ```{r} / ```r / ```python)."""
    return "\n".join(re.findall(r"```[ ]*\{?(?:python|r)\b[^\n]*\n(.*?)```", text, re.S))

rows = ["# The datasets used by the code of gt's and Great Tables' first pages, counted on 8 Nov 2026 by survey.py",
        "library\tpage\tsource\tdatasets\tinline"]
for lib, page, path in PAGES:
    c = code(get(path))
    used = [n for n in NAMES if re.search(rf"\b{n}\b", c)]
    inline = len(re.findall(r"\b(?:pl|pd)\.DataFrame\(|\btibble\(|\bdata\.frame\(", c))
    rows.append(f"{lib}\t{page}\t{path}\t{' '.join(used)}\t{inline}")
counts = {}
for f in REFERENCE:
    for m in re.findall(r"^#' +(\w+) \|>", get(f"rstudio/gt/master/R/{f}.R"), re.M):
        if m in NAMES: counts[m] = counts.get(m, 0) + 1
rows.append("# gt's reference examples (R/" + ", ".join(REFERENCE) + "): examples that start from each dataset")
for n, k in sorted(counts.items(), key=lambda x: -x[1]):
    rows.append(f"gt\treference examples\t{n}\t{n}\t{k}")
pathlib.Path(__file__).with_name("survey.tsv").write_text("\n".join(rows) + "\n")
print("\n".join(rows))
