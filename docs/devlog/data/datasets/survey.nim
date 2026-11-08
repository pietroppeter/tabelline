## Counts the datasets that the first pages of gt and Great Tables use: writes survey.csv.
## Run: nim r -d:ssl survey.nim
##
## Reads the sources from raw.githubusercontent.com (the docs' own sites may be blocked). The post
## keeps the file as a dated snapshot (8 November 2026).
import std/[algorithm, httpclient, os, re, sequtils, strutils, tables]

const
  raw = "https://raw.githubusercontent.com/"
  names = ["countrypops", "sza", "gtcars", "sp500", "pizzaplace", "exibble", "towny", "peeps", "films",
           "metro", "gibraltar", "constants", "illness", "reactions", "photolysis", "nuclides",
           "rx_adsl", "rx_addv", "islands", "airquality"]
  gs = ["index", "overview", "basic-header", "basic-stub", "basic-column-labels", "basic-formatting",
        "nanoplots", "basic-styling", "targeted-styles", "colorizing-with-data", "table-theme-options",
        "table-theme-premade", "column-selection", "row-selection", "loc-selection"]
  reference = ["format_data", "tab_create_modify", "data_color", "utils_render_html"]

proc csvLine(fields: openArray[string]): string =
  ## One CSV line: a field with a comma or a quote goes in quotes.
  var cells: seq[string]
  for x in fields:
    cells.add(if ',' in x or '"' in x: '"' & x.replace("\"", "\"\"") & '"' else: x)
  cells.join(",")

proc get(path: string): string =
  ## A file of a GitHub repository, through the proxy in HTTPS_PROXY when there is one.
  let proxy = getEnv("HTTPS_PROXY")
  let client = newHttpClient(userAgent = "tabelline-docs/0.1",
                             proxy = if proxy.len > 0: newProxy(proxy) else: nil)
  defer: client.close()
  client.getContent(raw & path)

proc code(text: string): string =
  ## The code chunks of a page (```{python} / ```{r} / ```r / ```python).
  var chunks: seq[string]
  var start = 0
  while true:
    var m: array[1, string]
    let (a, b) = text.findBounds(re("```[ ]*\\{?(?:python|r)\\b[^\\n]*\\n(.*?)```", {reDotAll}), m, start)
    if a < 0: break
    chunks.add m[0]
    start = b + 1
  chunks.join("\n")

var pages = @[("gt", "README", "rstudio/gt/master/README.md"),
              ("gt", "Introduction (vignette)", "rstudio/gt/master/vignettes/gt.Rmd"),
              ("Great Tables", "README", "posit-dev/great-tables/main/README.md")]
for p in gs: pages.add ("Great Tables", "Get Started: " & p, "posit-dev/great-tables/main/docs/get-started/" & p & ".qmd")
pages.add ("Great Tables", "Examples", "posit-dev/great-tables/main/docs/examples/index.qmd")

var lines = @["# The datasets used by the code of gt's and Great Tables' first pages, counted on 8 Nov 2026 by survey.nim",
              "library,page,source,datasets,inline"]
for (lib, page, path) in pages:
  let c = code(get(path))
  let used = names.filterIt(c.contains(re("\\b" & it & "\\b")))
  let inline = c.findAll(re"\b(?:pl|pd)\.DataFrame\(|\btibble\(|\bdata\.frame\(").len
  lines.add [lib, page, path, used.join(" "), $inline].csvLine

var counts: OrderedTable[string, int]
for f in reference:
  for line in get("rstudio/gt/master/R/" & f & ".R").splitLines:
    var m: array[1, string]
    if line.match(re"^#' +(\w+) \|>", m) and m[0] in names: counts.mgetOrPut(m[0], 0) += 1
lines.add "# gt's reference examples (R/" & reference.join(", ") & "): examples that start from each dataset"
var sorted = toSeq(counts.pairs)
sorted.sort(proc (a, b: (string, int)): int = cmp(b[1], a[1]), SortOrder.Ascending)
for (n, k) in sorted: lines.add ["gt", "reference examples", n, n, $k].csvLine
writeFile(currentSourcePath().parentDir / "survey.csv", lines.join("\n") & "\n")
echo lines.join("\n")
