## Why

The skills for agents that use tabelline were made in Pietro's personal skills repository
(pietroppeter/skills#6, never merged). Three rounds of tests with agents showed what a skill for
tabelline is worth: little when it copies the docs, a lot when it says how to work and makes the
agent look at its table. Pietro, 15 Nov 2026: "Maybe we should move both the skill and a devlog
post (from scratch) to tabelline?" In the repository a skill is tested against the code of the
same commit, changes in the PR that changes the behaviour, and is found by whoever finds tabelline.

## What Changes

- `skills/tabelline/` and `skills/table-building/`, moved as they are, with their references,
  the script that takes the screenshots and their eval cases.
- `.claude-plugin/`: the repository is a Claude Code plugin and its own marketplace.
- `tools/skillexamples.nim` runs the skills' Nim examples (in CI); `tools/skillevals.nim` grades
  an agent's run against an eval case (a port to Nim of the Python grader of the skills repository).
- The page For coding agents, llms.txt, the README and AGENTS.md say where the skills are and how
  they are kept.
- A devlog post, *Skills for tabelline*, tells the three rounds from zero.

## Differences from gt and Great Tables

gt and Great Tables ship no skills for coding agents. Not a feature of the library: nothing to
add to *Not from gt*.
