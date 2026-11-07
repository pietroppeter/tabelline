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
- `nim r tests/all.nim` runs the tests. Dependencies are managed with atlas: nimib is the `docs`
  feature of `tabelline.nimble`, pinned in `atlas.lock`, cloned into `deps/` (not committed) and
  put on the path by `nim.cfg` (committed, written by atlas).

## Setup

- In a fresh checkout or sandbox, run `sh tools/setup.sh` before anything else. It installs what is
  missing (Nim from GitHub nightlies, atlas, libpcre3) and the pinned dependencies, and is safe to
  rerun. It prints the `export PATH=...` line to use when it installed Nim or atlas.
- To change a dependency: `atlas use <pkg>` or edit the `docs` feature, `atlas install
  --feature=docs`, run the tests and the pages, then `atlas pin --feature=docs` and commit
  `atlas.lock` and `nim.cfg`. Without `--feature=docs`, atlas leaves nimib out.
- `atlas.lock` keeps a copy of `tabelline.nimble`, and `atlas rep` (so `tools/setup.sh`) writes that
  copy back: after editing `tabelline.nimble`, run `atlas pin --feature=docs` before the setup.

## Pages

- Every page is a nimib notebook in `docs/` in the quaderno theme (`docs/quaderno.nim`) and
  writes a standalone HTML file (fonts inlined, nothing remote). Every page also carries the
  Munari look (`docs/munari.nim`, all rules under `html[data-tema="munari"]`), which is the
  default; the header switches between the two and the choice is remembered. Check new page
  elements in both looks. The HTML is not committed: CI
  builds every page (`nim r -d:release docs/all.nim`) and deploys `docs/` to GitHub Pages from
  `main`. Notebooks that import nimib and tabelline use `import nimib except md`.
- Living documents (the explainer, the specs page) are kept up to date. A devlog post
  (`docs/devlog/<slug>.nim`, first line `## devlog: dd Mon yyyy X | title | lede`) is dated and not
  updated afterwards; the devlog index finds it, and it gets a line in the README. `X` is a letter
  for posts of the same day, in the order they were written (A, B, C, ...), so the index can
  show the newest first.
- In the Munari look, nothing that only decorates may look like something to press or drag (no
  dots, holes or knobs on cards). Its colours are six variables in `docs/munari.nim` (`--m-*`);
  mix new colours from them rather than adding fixed ones.
- A link can show part of the specs page: `specs/?spec=<names>` or `specs/?change=<names>`
  (comma-separated, `name*` for a prefix, `all`, or the same after `#`).

## Previews and PRs

- Show Pietro a published preview of the pages before asking to merge; he reviews on his phone.
- Nothing goes to `main` without his go. One clean PR per change; keep the PR description in sync
  with the branch.
