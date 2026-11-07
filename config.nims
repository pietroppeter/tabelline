# Dependencies from deps.sh (TABELLINE_DEPS, default ./deps) and the library in src/.
# No nimble needed to build the docs or run the tests: `sh deps.sh` once, then `nim r ...`.
import std/os
let deps = getEnv("TABELLINE_DEPS", thisDir() / "deps")
for d in ["nimib", "fusion", "markdown", "parsetoml", "jsony"]:
  switch("path", deps / d / "src")
switch("path", thisDir() / "src")
switch("hints", "off")

task test, "Run the tests and the spec examples":
  exec "nim r tests/all.nim"

task docs, "Build every page: explainer, devlog, specs":
  exec "nim r -d:release docs/all.nim"
