## The names in gt's and Great Tables' reference indexes, so a page can link a name to its
## reference page only when that page exists (the link check fails on a 404).
##
##   nim r -d:ssl tools/references.nim   # rewrites docs/coverage/references.json
##
## Both indexes are YAML in the projects' repositories (gt's pkgdown config, Great Tables'
## quartodoc config), read from raw.githubusercontent.com, which sandboxes usually reach when
## gt.rstudio.com and posit-dev.github.io are blocked. Rerun it when gt.json is checked for a
## release.

import std/[httpclient, json, os, strutils, sequtils, algorithm]

const
  notPublished = ["loc.summary", "loc.summary_stub"]
    ## In Great Tables' index but without a page on its site (the link check found them, 11 Nov
    ## 2026): left out, so no link leads to a 404.
  gtYml = "https://raw.githubusercontent.com/rstudio/gt/master/pkgdown/_pkgdown.yml"
  greatTablesYml = "https://raw.githubusercontent.com/posit-dev/great-tables/main/docs/_quarto.yml"

proc names(yml: string, ok: set[char]): seq[string] =
  ## The `- name` lines of a reference index.
  for l in yml.splitLines:
    let s = l.strip
    if s.startsWith("- ") and s.len > 2 and s[2 .. ^1].allCharsInSet(ok):
      result.add s[2 .. ^1]
  result.sort
  result = result.deduplicate(isSorted = true)

when isMainModule:
  let client = newHttpClient()
  let gt = names(client.getContent(gtYml), {'a'..'z', '0'..'9', '_'})
  let greatTables = names(client.getContent(greatTablesYml), {'a'..'z', 'A'..'Z', '0'..'9', '_', '.'})
    .filterIt(not it.endsWith(".css") and it != "interlinks" and it notin notPublished)
  let outFile = currentSourcePath().parentDir.parentDir / "docs" / "coverage" / "references.json"
  writeFile(outFile, pretty(%*{
    "gt": {"source": gtYml, "url": "https://gt.rstudio.com/reference/{name}.html", "names": gt},
    "greatTables": {"source": greatTablesYml,
                    "url": "https://posit-dev.github.io/great-tables/reference/{name}.html", "names": greatTables}}))
  echo "gt: ", gt.len, " names, Great Tables: ", greatTables.len, " names -> ", outFile
