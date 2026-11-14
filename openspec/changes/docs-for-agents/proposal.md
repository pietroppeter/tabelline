## Why

Pietro, 11 Nov 2026, on the skills for tabelline: "when building skills if there is anything we
need to improve (eg a better llms.txt, markdown and or json version of the docs) to have more
efficient skills we should do it". The 0.1 skill copied the API into the skill and still added
little: agents found their way by reading the installed sources. The Reference (0.2) has every
name, but as an HTML page of 400 entries, which an agent reads badly. A skill can stay small when
tabelline's own docs come in plain text, at stable addresses.

## What Changes

- The Reference's notebook (`docs/api.nim`) also writes `docs/api.md`: an index of one line per
  name at the top, then every entry with its signatures, doc comment, gt's and Great Tables'
  names and the shortest spec example with what it prints; and `docs/api.json`, the same as data.
  Built and published with the site, not committed, like the HTML.
- `llms.txt` lists the plain-text docs first: api.md, api.json, the feature map's `gt.json`, the
  specs' Markdown at the release's tag, the README; then the pages.
- The README says how to install tabelline (it is not in nimble's package list) and points
  coding agents to llms.txt.

## Differences from gt and Great Tables

gt's pkgdown site and Great Tables' quartodoc site have no llms.txt and no Markdown or JSON
version of their reference. Not a feature of the library: nothing to add to *Not from gt*.
