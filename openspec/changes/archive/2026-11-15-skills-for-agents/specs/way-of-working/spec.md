## ADDED Requirements

### Requirement: Skills for agents, tested
The repository SHALL hold, in `skills/`, the skills for agents that use tabelline: `tabelline`
(what the docs do not say: how to work, the traps agents met, recipes for hard tables) and
`table-building` (true of any table with any library: what to decide first, in what order to
build, and to look at the page before saying it is done), installable as a Claude Code plugin
from the repository. A skill SHALL NOT copy the API or the book. Every Nim example of a skill
SHALL run against the code and print the text shown after it (`tools/skillexamples.nim`, in CI).
Every rule of a skill SHALL come from an agent's run, with an eval case in the skill's `evals/`
that `tools/skillevals.nim` grades.

#### Scenario: A skill's example goes out of date
- **WHEN** a change to tabelline alters what an example of `skills/tabelline/SKILL.md` prints
- **THEN** `nim r tools/skillexamples.nim` fails in CI until the skill is updated in the same PR

#### Scenario: An agent's table is graded
- **WHEN** an agent has ported a table in a folder and `nim r tools/skillevals.nim skills/tabelline/evals/port-gt-extras <folder>` runs
- **THEN** each grader of the case is printed as passed or failed, and the exit code is 1 if one failed
