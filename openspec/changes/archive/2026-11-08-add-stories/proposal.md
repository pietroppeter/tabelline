## Why

The *use it* thread of every release tells a real subject in tables made with tabelline. The
first one, *Milano Cortina 2026, in small numbers* (PR #16), was published as a devlog post, and
there it sits between design reviews, sorted by day and never updated. Pietro asked for these
stories to be featured and given a better place than the devlog (project thread "Feature use-it
explainers in tabelline docs", 8 November 2026), and picked a section of their own. Built in one
docs PR.

## What Changes

- A new section, *Stories* (`docs/stories/`): one story for every release, found from the first
  line of its source (`## story: <release> | title | lede`), shown on the stories page as a card
  with a small table from the story, newest release first.
- A story is kept up to date, like a living document, and is not a dated post.
- *Milano Cortina 2026* moves from `docs/devlog/` to `docs/stories/`, with its data; its old
  address (`devlog/milano-cortina/`) forwards to the story.
- The home page shows the stories as a gallery of their own, after the simplest example and
  apart from the living documents, ending with a card for the stories to come; the roadmap links
  each *use it* thread to its story.

## Differences from gt and Great Tables

None: this is about the docs, not the API. Great Tables has an examples gallery and a blog; gt has
case studies. Stories are closer to the blog's longer posts, one per release.

## Capabilities

### New requirements in `way-of-working`
- Stories

## Impact

`docs/stories/` (new), `docs/all.nim`, `docs/index.nim`, `docs/piano.nim`, `docs/roadmap.nim`,
`docs/devlog/index.nim`, `docs/devlog/three_threads.nim` (keeps showing the first *use it* thread),
`docs/agents.nim`, `docs/olimpiadi.nim`, AGENTS.md, README.md.
