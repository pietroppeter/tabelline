# Package

version       = "0.1.0"
author        = "Pietro Peterlongo"
description   = "Great tables for Nim: display tables built from parts, formatted and styled, rendered to HTML"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0.0"
# The core needs only the standard library. nimib is for the docs and `import tabelline/nimib`
# (nbTable): the `docs` feature, pinned in atlas.lock (`sh tools/setup.sh` replays it).

feature "docs":
  requires "nimib >= 0.4.3"
