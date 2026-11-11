# Package

version       = "0.2.0"
author        = "Pietro Peterlongo"
description   = "Great tables for Nim: display tables built from parts, formatted and styled, rendered to HTML"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.2.0"  # nimble 0.18+ (Nim 2.2) reads the `feature` block below
# The core needs only the standard library. nimib is for the docs and `import tabelline/nimib`
# (nbTable) and nanuq for `import tabelline/nanuq`: the `docs` feature, pinned in atlas.lock (`sh tools/setup.sh` replays it).

feature "docs":
  requires "nimib >= 0.4.3"
  requires "nimibook >= 0.4.0"  # the tabelline book (book/)
  # `import tabelline/nanuq` (tabella(df) for a Polars DataFrame) and the book's case studies;
  # nanuq downloads its prebuilt Polars library (about 50 MB) the first time it is compiled
  requires "https://github.com/pietroppeter/nanuq >= 0.6.1"
  # the devlog post *tabelline in eight languages* imports its capi/ and shows its code
  requires "https://github.com/pietroppeter/tabelline-polyglot#adbb882fa6a8dedafceab09f9ec3713fa4c05251"
