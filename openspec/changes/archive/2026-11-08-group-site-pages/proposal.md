## Why

The home page listed nine "living documents" with names from the way tabelline is made (The
Great Explainer, Design Ref, Coverage map, Agents) and descriptions that spoke of threads. A
newcomer had to know that way of working before picking a page. Pietro asked to rethink the
names (project thread "Rethink the living documents names in tabelline") and chose three groups
with plain names; Specs keeps its name, in "How it's made", because it is written for agents
first and people second.

## What Changes

- The home page groups the pages by the question a reader brings: Learn tabelline (Guide, Book),
  Where it's going (Roadmap, Feature map), How it's made (Devlog, Specs, Design guide, For coding
  agents). "Living documents" is no longer a heading.
- Renamed cards and page labels: The Great Explainer is the Guide (the page keeps its name inside),
  Coverage map is the Feature map, Design Ref is the Design guide, Agents is For coding agents.
  URLs do not change.
- The requirement "Living documents and a devlog" says what is true today: the devlog index lists
  only posts, and the home page lists the pages.

## Differences from gt and Great Tables

None: this changes the docs site, not the API.

## Capabilities

### Modified requirements in `way-of-working`
- Living documents and a devlog, renamed "Pages kept up to date, and a devlog"

## Impact

`docs/index.nim`, the labels of `docs/explainer.nim`, `coverage.nim`, `design.nim`, `agents.nim`
(and its llms.txt list), `roadmap.nim`, `specs.nim`; README.md, AGENTS.md; links in the book.
Dated devlog posts keep the old names.
