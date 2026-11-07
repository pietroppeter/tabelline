# Working on tabelline

Notes for coding agents (and people) changing this repository. How tabelline behaves is in
`openspec/specs/` (rendered at `specs/`); how it is laid out is in README.md. This file holds the
working rules that are easy to miss.

## Behaviour lives in the specs

- Every agreed behaviour is a requirement with scenarios in `openspec/specs/`. New work starts as
  an OpenSpec change in `openspec/changes/` (`/opsx:propose`), is built in a PR (`/opsx:apply`),
  and is archived when it ships (`/opsx:archive`). `openspec/config.yaml` has the rules.
- Ideas go in BACKLOG.md, not straight into work. When a change is archived, remove its BACKLOG
  entry and add a CHANGELOG.md line under Unreleased with the PR number.
- Every requirement about the API has an example: a ```nim block followed by a ```text block with
  what it prints (`echo t` prints a table as text). `nim r tools/specexamples.nim` runs them all;
  `--update` rewrites the outputs after a change is built; `--changes` includes open changes.
- Name verbs after gt in camelCase (`tab_header` is `tabHeader`), and list differences from gt and
  Great Tables in every proposal.

## Code

- The core (`src/tabelline/`) needs only Nim's standard library. nimib is used only by
  `src/tabelline/nimib.nim` and the docs. Optional interop goes in its own module.
- Verbs take a `Tabella` (`sink`) and return the new one; formats and styles resolve columns and
  rows when the verb is called and run when the table is rendered (`build.nim`), so every renderer
  agrees. Macros only where a proc cannot do the job (today: `tabella(data): body`, `tableData:`,
  `tabOptions`).
- `nim r tests/all.nim` runs the tests; `sh deps.sh` once fetches the pinned docs dependencies
  (into `deps/`, put on the path by `config.nims`); no nimble needed.

## Pages

- Every page is a nimib notebook in `docs/` in the quaderno theme (`docs/quaderno.nim`) and
  writes a standalone HTML file (fonts inlined, nothing remote). The HTML is not committed: CI
  builds every page (`nim r -d:release docs/all.nim`) and deploys `docs/` to GitHub Pages from
  `main`. Notebooks that import nimib and tabelline use `import nimib except md`.
- Living documents (the explainer, the specs page) are kept up to date. A devlog post
  (`docs/devlog/<slug>.nim`, first line `## devlog: dd Mon yyyy | title | lede`) is dated and not
  updated afterwards; the devlog index finds it, and it gets a line in the README.
- A link can show part of the specs page: `specs/?spec=<names>` or `specs/?change=<names>`
  (comma-separated, `name*` for a prefix, `all`, or the same after `#`).

## Previews and PRs

- Show Pietro a published preview of the pages before asking to merge; he reviews on his phone.
- Nothing goes to `main` without his go. One clean PR per change; keep the PR description in sync
  with the branch.
