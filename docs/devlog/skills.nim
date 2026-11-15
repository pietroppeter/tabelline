## devlog: 15 Nov 2026 A | Skills for tabelline | A skill is a page an agent reads before a task. Three rounds of tests on what a skill for tabelline is worth: one that copied the docs and added little, a small one that sent agents to the docs and held one rule that did harm, and a round on hard tables where every program ran and no agent looked at its table. What came out: two skills, one for tabelline and one for any table, and why they now live in this repository.
## A dated post: the three rounds of tests behind the skills in skills/, told from zero. The skills
## are kept up to date; the numbers here are those of the runs, 10 to 15 November 2026.
import std/os
import nimib
import tabelline, tabelline/nimib
import ../blocks

let docs = currentSourcePath().parentDir.parentDir
let shots = docs / "devlog" / "data" / "skills"
nbInit
nb.doc.filename = docs / "devlog" / "skills" / "index.html"
nb.useTabelline(title = "Skills for tabelline", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "15 November 2026", "Skills for tabelline", """
A skill is a page an agent reads before a task. Three rounds of tests on what a skill for tabelline is worth, the two skills that came out of them, and why they now live in this repository.
"""

nbText: """
More and more tables are written by a coding agent: someone asks for a table, and a model writes
the Nim. tabelline is new, so no model has seen it. What should an agent read before it makes a
table with it? This post tells how the answer was found, in three rounds, each with agents doing
real tasks. The skills began in Pietro's [personal skills
repository](https://github.com/pietroppeter/skills) and move here with this post.
"""

nbToc()

nbText: """
## What a skill is

A skill is a folder with a Markdown file, `SKILL.md`. The file starts with a name and one
sentence that says when to use it. An agent keeps that sentence in mind all the time. When a task
matches it, the agent reads the rest of the file, and only then. So a skill costs almost nothing
until it is needed, and then it costs its length, every time. A skill can also hold other files
(a page on one subject, a script) that the agent opens only if `SKILL.md` sends it there.

A skill is written for a reader who is clever, in a hurry, and takes every sentence as an order.
That last part matters most, as the second round shows.

## How a skill is tested

The same task goes to two agents, each in an empty folder. One is told to read the skill. The
other is not. Both have tabelline installed, and nothing else. When they finish, checks run on
the files they made: the page exists, it has a summary row, the top three rows are shaded. A
check is a file in the skill's `evals/` folder, so the same task can be given again after the
skill changes.

A skill is worth keeping when the agent that read it does better, or does the same with less
time and fewer tokens. All the runs here used Sonnet, a mid-sized model: a skill that only helps
the largest model helps few people.

## Round one: a skill that copied the docs

The first skill was written for tabelline 0.1, on 10 November. It held the list of the verbs, a
map from gt's and Great Tables' names to tabelline's, and three examples. Four tasks, one run
each way:
"""

block:
  let d = tableData:
    arm: ["with the skill", "without"]
    passed: ["4 of 4", "4 of 4"]
    seconds: [29, 37]
  let t = tabella(d, rownameCol = "arm"):
    tabHeader "Round one: the 0.1 skill", "four tasks, one run each"
    colsLabel:
      passed: "tasks passed"
      seconds: "seconds, mean"
    optCssTheme()
  nbTable t

nbText: """
The agent without the skill passed everything. It read the sources that nimble had installed,
where every verb has a doc comment, and it guessed the names, because they are gt's in camelCase.
The skill saved eight seconds. Pietro's verdict: "0.1 skills did not add that much". The copy of
the API in the skill would also go out of date at every release.

The lesson is about tabelline more than about skills: **names that follow gt, and docs in the
source, already do most of a skill's work.**

## Round two: send the agent to the docs

For 0.2 the skill was made small. What it copied moved to where it belongs, tabelline's own docs,
in a form an agent reads well ([PR #108](https://github.com/pietroppeter/tabelline/pull/108)):

- [api.md](../../api.md): the whole [Reference](../../api/) in one Markdown file. An agent
  searches it for `fmt_number` and finds `fmtNumber`, with its signature and an example that ran.
- [llms.txt](../../llms.txt): a map of the site for models, with the plain-text files first.

The skill kept only what the docs do not say: where they are, how to work (write the table one
verb per line, print it as text with `echo t`, then write the page), one example, and the traps
agents had met.

The tasks got harder: a gt table with summary rows and merged columns, a Great Tables table with
small plots in the cells, and a sort followed by "shade the top three rows". Each ran three times
in three ways: with nothing, with a line saying where the docs are, and with the skill.
"""

block:
  let runs = tableData:
    task: ["gt port", "Great Tables port", "Top three rows", "Top three rows, rule fixed"]
    noneOk: ["3 of 3", "3 of 3", "2 of 3", ""]
    noneS: [60, 73, 257, 0]
    docsOk: ["3 of 3", "3 of 3", "2 of 3", ""]
    docsS: [70, 70, 92, 0]
    skillOk: ["3 of 3", "3 of 3", "0 of 3", "3 of 3"]
    skillS: [57, 66, 100, 38]
  let t = tabella(runs, rownameCol = "task"):
    tabHeader "Round two: three ways, three runs each", "runs passed, and seconds on average"
    tabSpanner "nothing", ["noneOk", "noneS"]
    tabSpanner "docs", ["docsOk", "docsS"]
    tabSpanner "skill", ["skillOk", "skillS"]
    colsLabel:
      noneOk: "passed"
      noneS: "s"
      docsOk: "passed"
      docsS: "s"
      skillOk: "passed"
      skillS: "s"
    subZero ["noneS", "docsS"], zeroText = ""
    tabSourceNote "14 November 2026, tabelline 0.2.0. One run with nothing took 560 s on the third task; without it the mean is 106 s."
    optCssTheme()
  nbTable t

nbText: """
The two ports passed every time, in every way. With the skill they used about a tenth fewer
tokens. Ports of this size are no test of a skill any more.

The third task is where the skill did **worse than nothing**. In tabelline `rows = [0]` is the
first row of the data, not the first row shown, so after a sort it is the wrong row. The skill
warned about it in one sentence: rows count in data order, and "to mean rows by content, use
`where`". All three agents with the skill obeyed. Two wrote the names of the three planets in the
code. One wrote `moons > 20`. The page looked right and the checks passed, but the shading no
longer followed the sort: change the data and the wrong rows are shaded. The agents without the
skill had read the docs and found `displayOrder`, which gives the rows as they are shown.

The sentence was true. It was also incomplete, and an agent follows a skill more closely than
anything it finds by itself. The rule now says what to do: build the table, take
`t.displayOrder()[0 .. 2]`, style those rows. The task gained a check that reads the code. Three
new runs passed, in 38 seconds.

**A rule in a skill says what to do, not only what to avoid. And a check reads the code, not
only the page.**

## Round three: hard tables

So far the tables were easy. Pietro asked how the skill should handle hard ones, and which
examples to give it, since the [book](../../book/) has some forty ported tables to choose from.

Choosing by taste would repeat round one. So six hard tasks went to agents, with the skill and
without, and each agent also wrote notes for tabelline's maintainers: what it tried first, what
failed, where it found the answer. The tasks:

- three tables with charts drawn in the cells and data shaped in code first: the Euro NCAP
  ranking, the lemurs, an NFL season (entries of Posit's Table Contest and a gt-extras example);
- a railway timetable, with twenty columns;
- a board of Super Bowl squares, which is a grid and not rows of data;
- a brief with no table to copy: "one table for the owner's yearly report", from 5,000 pizza
  orders.

All twelve programs compiled and ran. The notes say where the time went:
"""

block:
  let found = tableData:
    what: ["Did not look at the page", "Finding a name in the docs", "Data made in code",
           "A drawing in a cell", "A number printed as `28.`"]
    runs: [12, 12, 11, 8, 3]
    detail: ["Every agent searched the HTML for its styles. None took a screenshot.",
             "The index of api.md was too long to print in one go, and `style.text` is filed under `text`.",
             "tabelline does not group, join or pivot, by design. Each agent worked out alone how to build a table from columns it computed.",
             "`fmt` with a simple proc escapes HTML, so the cell shows `<svg ...>` as text. The proc that may return HTML takes a second argument.",
             "Nim's `{x:.0f}` keeps the dot. With `width=\"120.\"` a drawing loses its size."]
  let t = tabella(found, rownameCol = "what"):
    tabHeader "Where twelve runs lost time", "runs whose notes mention it, of 12"
    colsLabel:
      runs: "runs"
      detail: "what happened"
    fmtMarkdown columns = ["what", "detail"]
    colsWidth:
      detail: "58%"
    tabSourceNote "Counted in the agents' notes, 15 November 2026, tabelline 0.2.0."
    optCssTheme()
  nbTable t

nbText: """
The first line is the one that matters. Here is the NFL table as one agent delivered it, with
the skill of round two. Every check on its HTML passed.
"""

nbScreenshot shots / "before.jpg", shots / "before.json", "Round three, before: the program ran, the checks passed, and nobody looked", twide = true

nbText: """
1. The title is there twice: once from the table and once written by hand above it.
2. A column of addresses that should have been logos, or hidden.
3. The table runs off the page: the last columns cannot be seen.

Another run drew its charts with `width="120."` and got rows 170 pixels tall around a small
drawing. No agent knew, because no agent looked. A person would have seen all of it in a second.

## One skill or two

Pietro's question was whether to split the skill: one for building a table, one for tabelline's
specifics. The findings split themselves in those two kinds, so the answer is two.

**What is specific to tabelline** goes in the skill `tabelline`:

- how to search api.md without printing it whole;
- a page on data made in code: read a cell, group, join, pivot and sort in plain Nim, then make
  the table's data, in one program of thirty lines;
- a page on drawings in cells: a `fmt` proc that returns HTML, what it answers for the text
  output, two numbers in one cell, one scale for all rows, a size with no dot;
- a table of seven kinds of hard table, each with the book chapter to read.

The two pages are separate files. An agent making a plain table never opens them. The book is
not copied into the skill: the table links each chapter's source at the release's tag.
"""

block:
  let kinds = tableData:
    kind: ["Charts or boxes drawn in cells", "A timetable, or any table with twenty columns",
           "A grid that is not rows of data", "A statistical summary by groups", "Many summary rows",
           "A ranking with pictures and a heavy style", "Every style and option, one by one"]
    chapter: ["[An NFL season](../../book/extras/nfl_season.html), [the lemurs](../../book/contest/lemurs.html)",
              "[SEPTA's timetable](../../book/blog/septa.html)",
              "[Super Bowl squares](../../book/blog/superbowl.html), [the periodic table](../../book/contest/periodic_table.html)",
              "[A clinical table](../../book/vignettes/case_study_clinical.html)",
              "[Summary lines](../../book/vignettes/summary_lines.html)",
              "[Euro NCAP](../../book/contest/euroncap.html)",
              "[Styling with gt](../../book/contest/gt_styling.html)"]
  let t = tabella(kinds, rownameCol = "kind"):
    tabHeader "Which chapter for which table", "the skill's index of the book"
    colsLabel:
      chapter: "read"
    fmtMarkdown "chapter"
    optCssTheme()
  nbTable t

nbText: """
**What is true of any table**, with any library, goes in a new skill, `table-building`. It has
five steps:

1. Say what the table is for, in one sentence: who reads it and what they compare.
2. Shape the data first, and check two or three numbers by hand.
3. Build in the order of the parts: stub and groups, labels and spanners, formats, totals, title
   and notes, and emphasis last and little.
4. Look at it.
5. Say what you checked.

It works for gt and Great Tables too, and it does not change when tabelline does.

## Look at it

Step 4 is the reason the second skill exists. It comes with a script, `look.js`. The agent runs
it on its page and gets two screenshots, one 1100 pixels wide and one at the width of a phone,
and a list of what a program can measure: a page that scrolls sideways, cells that are cut, rows
far taller than the others, pictures that did not load. Then the agent reads the two pictures,
with a list of what only eyes find: a title shown twice, a drawing off its line, labels that wrap
into three lines, text on a colour it cannot be read on.

The same six tasks ran again, once each, with both skills. The book was held out this time: it
holds the answers to five of the six, and an agent that reads the answer tests nothing. All six
agents took the screenshots and read them. The same NFL table:
"""

nbScreenshot shots / "after.jpg", shots / "after.json", "Round three, after: the same task with both skills", twide = true

nbText: """
The agent that made the lemurs table wrote that the axes of its line charts had vanished, with
`x1="48."`, and that it found out "only by looking at the screenshot". The page on drawings warns
about that dot. The agent had read the warning, and wrote the dot anyway. Then it looked, saw it,
and fixed it.

**A warning is read and forgotten. A picture of the result is not.**

Two new eval cases keep this. One ports the NFL table and checks that the drawings are in the
HTML and not escaped, that no size ends in a dot, and that the screenshots exist. One gives the
pizza brief. The runs of the first half of this round fail them, and the runs of the second half
pass.

## Why the skills live here

The skills began in another repository because they were an experiment. They move here for three
reasons.

- **They are tested against the same code.** Every Nim example in a skill runs in tabelline's CI
  and must print what the skill shows. A change that alters an example fails until the skill is
  updated, in the same PR.
- **They are found.** Whoever finds tabelline finds its skills: in the README, in llms.txt, on
  the page [For coding agents](../../agents/).
- **Each trap is a bug report.** A trap in a skill is a place where tabelline could be clearer.
  Seven of them are now in the backlog: an unknown palette name that fails only when the table is
  drawn, a format that cannot see its row, an index of api.md that is too long. When tabelline
  fixes one, the trap leaves the skill.

## What three rounds say

1. Names that follow gt, and docs in the source, do most of the work. Put effort there first.
2. A skill holds what the docs do not: how to work, the traps, a few recipes. It links the rest.
3. Every rule says what to do. A true warning that stops halfway did more harm than no skill.
4. Checks read the code and the page, and the hardest task is the only one that tests anything.
5. Agents do not look at what they make, unless a skill gives them the tool and tells them to.
6. Choose what goes in a skill from what agents wrote down, not from what seems useful.

## How it is built

Everything is in `skills/`, at the root of the repository:

- `skills/tabelline/SKILL.md`, with `references/data.md` and `references/cells.md`, the two pages
  for hard tables;
- `skills/table-building/SKILL.md`, with `scripts/look.js`;
- `evals/` in each skill: one folder per task, with the prompt, the files the agent finds, and
  one small file per check.

`.claude-plugin/` has two small JSON files that make the repository a plugin for Claude Code and
its own marketplace, so the two skills install in one line. Any other agent can be pointed at the
files.

Two tools keep the skills honest, both in Nim:

- `tools/skillexamples.nim` finds every Nim block in the skills that imports tabelline, runs it,
  and compares what it prints with the text block after it. It works like the tool that runs the
  examples of the [specs](../../specs/), and CI runs it on every PR.
- `tools/skillevals.nim` grades what an agent made against a task: it reads the checks of the
  task and says which pass. A check is that a file exists, or that a pattern is, or is not, in a
  file or in the agent's reply.

The two skills, as an agent reads them:
"""

nbFoldCode "skills/tabelline/SKILL.md", title = "The skill `tabelline`", lang = "markdown"
nbFoldCode "skills/table-building/SKILL.md", title = "The skill `table-building`", lang = "markdown"
nbFoldCode "skills/table-building/scripts/look.js", title = "The script `look.js`"

nbSave
