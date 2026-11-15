## devlog: 15 Nov 2026 A | Skills for tabelline | Two skills for agents that make tables with tabelline, measured on five tasks, three runs each, with and without them, on Sonnet and Haiku. The tables are right either way. With the skills the agent checks its page on a phone, fewer pages break, and a run costs a fifth to a third less. Then how four rounds of tests got there, and why the skills live in this repository.
## A dated post: the result of the skills in skills/ first, then the rounds of tests behind them,
## told from zero. The skills are kept up to date; the numbers here are those of the runs, 10 to
## 15 November 2026.
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
Two skills for agents that make tables with tabelline. What they are worth, measured: the tables are right either way, but with the skills the agent checks its page on a phone, fewer pages break, and a run costs a fifth to a third less. Then how four rounds of tests got there.
"""

nbText: """
More and more tables are written by a coding agent: someone asks for a table, and a model writes
the Nim. tabelline is new, so no model has seen it. What should an agent read before it makes a
table with it? The answer is two skills, in `skills/` in this repository. This post starts from
what they are worth, and tells afterwards how they were found.
"""

nbToc()

nbText: """
## The result

Five tasks, each given three times to an agent with the two skills installed and three times to
an agent without. The agent is Claude Sonnet 5.5, a mid-sized model, at medium effort, in an
empty folder with tabelline installed and nothing else ([how it was
measured](#how-it-was-measured)).
"""

block:
  let res = tableData:
    what: ["The table is right", "The agent read the skill", "It looked at a picture of its page",
           "It checked the page at a phone's width", "Every check passes", "Tokens of a run, mean",
           "Cost of a run, mean", "Time of a run, mean"]
    none: ["15 of 15", "", "1 of 15", "0 of 15", "9 of 15", "455,000", "$0.24", "80 s"]
    skill: ["15 of 15", "15 of 15", "15 of 15", "15 of 15", "13 of 15", "401,000", "$0.17", "67 s"]
  let t = tabella(res, rownameCol = "what"):
    tabHeader "With the skills and without", "Sonnet 5.5, five tasks, three runs each"
    colsLabel:
      none: "without"
      skill: "with the two skills"
    colsAlign alRight, ["none", "skill"]
    tabSourceNote "15 November 2026, tabelline 0.2.0, Claude Sonnet 5.5 (claude-sonnet-5-5), medium effort. Picture: the agent opened a screenshot of its page. Phone: its reply says what the page shows at a phone's width. Cost: what Claude Code reports for the run."
    optCssTheme()
  nbTable t

nbText: """
Task by task, tokens and cost, and how much they change with the skills:
"""

block:
  let u = tableData:
    task: ["gt summary rows", "Great Tables plots", "Sort, shade top three", "NFL season",
           "Brief for a report", "All fifteen runs"]
    tokN: [387, 282, 335, 877, 391, 455]
    tokS: [294, 330, 214, 1047, 331, 401]
    tokD: [-24.0, 17.0, -36.0, 19.0, -15.0, -12.0]
    costN: [0.204, 0.133, 0.148, 0.524, 0.198, 0.241]
    costS: [0.14, 0.138, 0.097, 0.43, 0.138, 0.171]
    costD: [-32.0, 4.0, -34.0, -18.0, -30.0, -29.0]
  let t = tabella(u, rownameCol = "task"):
    tabHeader "Tokens and cost, task by task", "Sonnet 5.5, means of three runs"
    colsHide ["tokN", "tokS"]
    tabSpanner "tokens", ["tokD"]
    tabSpanner "cost of a run, $", ["costN", "costS", "costD"]
    colsLabel:
      tokN: "without"
      tokS: "with"
      tokD: "change"
      costN: "without"
      costS: "with"
      costD: "change"
    fmtNumber ["costN", "costS"], decimals = 2
    fmtNumber ["tokD", "costD"], decimals = 0, forceSign = true, pattern = "{x}%"
    tabSourceNote "Change: with the skills against without. Tokens: all the model read and wrote in the run, the parts read again from the cache included, which cost a tenth. One run of the NFL task with the skills deleted the report of its cost: that cell is the mean of two."
    optCssTheme()
  nbTable t

nbText: """
What the skills buy:

- **The agent checks its page on a phone.** With the skills, every agent took a screenshot at
  the width of a screen and one at the width of a phone, looked at them, and said what the phone
  shows. Without them, one agent of fifteen looked at a picture of its page, and none at a
  phone's width.
- **Fewer pages that break.** Of the three NFL pages made without the skills, one is 758 pixels
  wide on a phone and scrolls sideways; none of the three made with them does.
- **Less money.** A run costs 29% less over all fifteen runs, and a third less on three of the
  five tasks. It reads 12% fewer tokens: the skill says where the answer is, and the agent stops
  searching for it. On the Great Tables plots the cost is the same and on the NFL port the agent
  reads more, because it looks at its pages, but it still costs less.
- **Less time**, 17% on average, mostly on the sort, where the agents without the skills spent
  close to two minutes reading tabelline's sources.

What they do not buy:

- **The right table.** Every one of the thirty tables is right, with the skills or without. The
  names follow gt, every verb has a doc comment in the installed sources, and these tasks hand
  the agent the original program to port. Sonnet does not need help to get them right.
- **A better looking table**, as far as I can tell: side by side, apart from the page that
  scrolls, I could not tell the two groups apart.

The limits: one task of each kind, three runs each. The numbers say the direction, not the size.

### The checks

Each task has six to eight checks, run on the files the agent leaves and on its last message.
"The table is right" counts the checks on the table and its code; "every check passes" adds the
ones on looking (the screenshots exist, the reply says what the phone shows) and on how the
table goes in the page.
"""

block:
  let checks = tableData:
    task: ["A gt table with summary rows", "A Great Tables table with small plots",
           "Sort, then shade the top three rows", "An NFL season, with drawings in the cells",
           "A brief: one table for a yearly report"]
    n: [8, 7, 7, 7, 6]
    what: ["The page exists; three totals of the summary rows are right (601, 420, $1,416,362); a range is written `20–30`; the code uses `summaryRows`; the cars the original leaves out are left out; the colours are viridis.",
           "The page exists; six drawings; the reference line at the mean; the bold and the italic of the original (`1991–2020`, `mm`); `optStylize`; the source note.",
           "The page exists; **moons** in bold; the table goes in the page with `nbTable`; Saturn and Uranus shaded, Mercury, Venus and Earth not; the rows come from the sort (`displayOrder` or a sort), not written by hand.",
           "The page exists; the drawings are in the HTML; none is escaped into text; no size ends in a dot (`width=\"120.\"`); the spanner *Season Trends*; the format that may return HTML (`RenderContext`); the phone screenshot.",
           "The page exists; the wide and the phone screenshots; a total row; a title (`tabHeader`); the reply says what the phone shows."]
  let t = tabella(checks, rownameCol = "task"):
    tabHeader "The checks", "what tools/skillevals.nim reads after each run"
    colsLabel:
      n: "checks"
      what: "what they check"
    fmtMarkdown "what"
    colsWidth:
      what: "60%"
    optCssTheme()
  nbTable t

nbText: """
With the skills, 13 runs of 15 pass every check, and 9 without. The two that fail with the
skills took the phone picture of the NFL page, looked at it and did not keep it. Without the
skills, the six that fail are those of the two tasks that ask for the pictures. A check that
passes does not make a good table, as round three shows: the checks catch what an agent got
wrong before, and the pictures let the agent, and a person, see the rest.

## A smaller model, and other libraries

A skill has no model of its own: it is read by the model of whoever uses it. So the same five
tasks went to Claude Haiku 5.5, the small model, three runs each way.
"""

block:
  let res = tableData:
    what: ["The table is right", "The agent read the skill", "It looked at a picture of its page",
           "It checked the page at a phone's width", "Every check passes", "Tokens of a run, mean",
           "Cost of a run, mean", "Time of a run, mean"]
    none: ["14 of 15", "", "3 of 15", "0 of 15", "8 of 15", "1,779,000", "$0.11", "146 s"]
    skill: ["15 of 15", "15 of 15", "5 of 15", "10 of 15", "13 of 15", "1,444,000", "$0.09", "137 s"]
  let t = tabella(res, rownameCol = "what"):
    tabHeader "Haiku, with the skills and without", "Haiku 5.5, five tasks, three runs each"
    colsLabel:
      none: "without"
      skill: "with the two skills"
    colsAlign alRight, ["none", "skill"]
    tabSourceNote "15 November 2026, tabelline 0.2.0, Claude Haiku 5.5 (claude-haiku-5-5), medium effort."
    optCssTheme()
  nbTable t

block:
  let u = tableData:
    task: ["gt summary rows", "Great Tables plots", "Sort, shade top three", "NFL season",
           "Brief for a report", "All fifteen runs"]
    tokN: [876, 515, 831, 5931, 741, 1779]
    tokS: [738, 428, 517, 4639, 624, 1444]
    tokD: [-16.0, -17.0, -38.0, -22.0, -16.0, -19.0]
    costN: [0.024, 0.016, 0.021, 0.473, 0.024, 0.111]
    costS: [0.021, 0.014, 0.014, 0.369, 0.02, 0.093]
    costD: [-12.0, -10.0, -30.0, -22.0, -17.0, -17.0]
  let t = tabella(u, rownameCol = "task"):
    tabHeader "Tokens and cost, task by task", "Haiku 5.5, means of three runs"
    colsHide ["tokN", "tokS"]
    tabSpanner "tokens", ["tokD"]
    tabSpanner "cost of a run, $", ["costN", "costS", "costD"]
    colsLabel:
      tokN: "without"
      tokS: "with"
      tokD: "change"
      costN: "without"
      costS: "with"
      costD: "change"
    fmtNumber ["costN", "costS"], decimals = 3
    fmtNumber ["tokD", "costD"], decimals = 0, forceSign = true, pattern = "{x}%"
    tabSourceNote "Change: with the skills against without. Tokens: all the model read and wrote in the run, cached reads included. One run of the brief with the skills deleted the report of its cost: that cell is the mean of two."
    optCssTheme()
  nbTable t

nbText: """
Haiku got 29 tables of 30 right. The one it got wrong, without the skills, shades the three
planets by name, so the shading does not follow the sort. That surprised me less once I read
what the agents without the skills did:

- **The answer is on the machine.** Every run opened tabelline's installed sources, where each
  verb has a doc comment with an example. The names are gt's in camelCase, so a gt name finds the
  tabelline verb. For the NFL port, some runs even installed the Python original in their folder
  to read how it draws its charts.
- **The tasks hand over the original.** Four of the five give the gt or Great Tables program to
  port: the agent translates, it does not design. The fifth, the brief, is a plain cross table.
- **Haiku reads more.** It used about four times Sonnet's tokens (1.8 million a run, against
  0.45), at a tenth of the price per token. It makes up for knowing less by reading more.

What the skills change on Haiku: a fifth less money and tokens, the one wrong table, and two
of the three NFL pages without the skills that scroll sideways on any screen (1,344 and 1,286
pixels), against none with them. What they change less than on Sonnet is looking: Haiku read
the skill every time, and still took the screenshots in only five runs of fifteen, though ten
replies say something about the phone. A small model follows the first steps of a skill and
drops the later ones.

The skill `table-building` says it is for any library. That was not tested until Pietro asked.
The brief went to Sonnet in Python with Great Tables and in R with gt, three runs each way, with
the skill installed and not named.
"""

block:
  let res = tableData:
    what: ["The agent read the skill", "It looked at a picture of its page",
           "It checked the page at a phone's width", "Cost of a run, mean"]
    pyNone: ["", "3 of 3", "0 of 3", "$0.08"]
    pySkill: ["2 of 3", "3 of 3", "2 of 3", "$0.09"]
    rNone: ["", "3 of 3", "0 of 3", "$0.12"]
    rSkill: ["3 of 3", "3 of 3", "3 of 3", "$0.13"]
  let t = tabella(res, rownameCol = "what"):
    tabHeader "The brief in Python and in R", "Great Tables 1.1 and gt 1.4, three runs each"
    tabSpanner "Python", ["pyNone", "pySkill"]
    tabSpanner "R", ["rNone", "rSkill"]
    colsLabel:
      pyNone: "without"
      pySkill: "with"
      rNone: "without"
      rSkill: "with"
    colsAlign alRight, ["pyNone", "pySkill", "rNone", "rSkill"]
    tabSourceNote "15 November 2026, Claude Sonnet 5.5, medium effort."
    optCssTheme()
  nbTable t

nbText: """
Here the agents look without being told: in Python and in R every agent without the skill took
a screenshot of its page. What the skill adds is the phone, five runs of six, at about a cent
more. One Python run did not load the skill at all: its first sentence, unlike `tabelline`'s,
is still a description. All twelve tables are right and look alike. Models know gt and Great
Tables well, and the skill does not make their tables better on a task this easy.

## What I make of it

Useful, but modest, and worth less than the work that went into them. Keep them, keep them
small, and put the next effort into tabelline itself.

**What they do well.** They make the agent check its page at a phone's width, which without
them it almost never does. That is the one thing good docs cannot give: it is a habit, not a
fact, and it is what caught real defects (three of six NFL pages without the skills scroll
sideways, none of six with them). And they cut the cost of a run by a fifth to a third, by
telling the agent where the answer is instead of letting it search the sources.

**What they do not do.** They do not make tables more correct: on these tasks the agents got
the table right anyway, Haiku too. The credit goes to tabelline: gt's names, a doc comment with
an example on every verb, in the installed sources. That is the strongest finding of the whole
exercise, and it is about the library, not the skills. They do not make tables better looking,
as far as I could see. And on a small model they half work: Haiku reads the skill every time and
drops the step that looks.

**How much to trust the numbers.** Moderately. Five tasks, three runs each, two models. Every
measurement found a fault in the one before (the repository's notes leaking into the agents,
then the project's memory, a wrong count of "looked", a wrong install command), and this round
may well have one more. The direction is credible; the percentages are not precise.

### What next

In this order, each with what it would change:

1. **Make `table-building`'s first sentence an order** (S). One Python run did not load it. The
   same change took `tabelline` from five skipped runs of fifteen to one, on Haiku.
2. **Make the look step stick on a small model** (S). Haiku took the screenshots in five runs of
   fifteen with the skills. Try the step as the skill's first instruction, before any code, and
   run the Haiku cases again.
3. **No new rule without an agent that fails without it.** The tasks are now too easy to tell the
   two groups apart on correctness. A harder case needs a design task with no original to port:
   the brief is the only one, and it is a plain cross table. Candidates: a timetable from raw
   departures, a ranking with a chart per row from a long table, a report table from a messy
   spreadsheet.
4. **Fix in tabelline the seven traps from round three**, now in the
   [backlog](https://github.com/pietroppeter/tabelline/blob/main/BACKLOG.md), so the skill can
   lose the lines that work around them:
"""

block:
  let next = tableData:
    fix: ["An unknown palette name fails when the verb is called", "A format that sees its row",
          "`fmt` for a whole list", "A page of several tables", "`optCss` says when it drops a rule",
          "api.md for agents", "A clearer error for a block of pairs"]
    size: ["S", "M", "S", "S", "S", "S", "S"]
    today: ["`palette(\"oranges\")` is accepted and fails only when the table is drawn. The skill says which names exist.",
            "A drawing of two columns needs both packed in one cell as text first. The page on drawings shows how.",
            "A cell with a list is formatted item by item, so a chart of the list gets one number. The page on drawings says to write the list as text.",
            "`tabellaStyle` once, then `toHtml(withStyle = false)` for each table, by hand. The skill gives the recipe.",
            "An `@import` in the CSS (a web font, say) is dropped without a word. The skill does not cover it yet.",
            "The index is 37 KB, more than one read, and `style.text` is under `### text`. The skill says how to grep it.",
            "In `colsLabel:` a name with a space and no quotes gives a macro error that does not say to quote it. The skill says to."]
  let t = tabella(next, rownameCol = "fix"):
    tabHeader "Seven traps for tabelline to fix", "size, and what agents (and the skill) do today"
    colsLabel:
      size: "size"
      today: "today"
    fmtMarkdown columns = ["fix", "today"]
    colsWidth:
      today: "60%"
    tabSourceNote "From the agents' notes in round three. S: a small change, M: a medium one."
    optCssTheme()
  nbTable t

nbText: """
5. **Run the eval at every release**, as a check that nothing got worse, not as research: the
   same cases, both models, the same isolation, and the numbers next to these.

## What the two skills are

A skill is a folder with a Markdown file, `SKILL.md`. The file starts with a name and one
sentence that says when to use it. An agent keeps that sentence in mind all the time. When a task
matches it, the agent reads the rest of the file, and only then. So a skill costs almost nothing
until it is needed, and then it costs its length, every time. A skill can also hold other files
(a page on one subject, a script) that the agent opens only if `SKILL.md` sends it there.

- **`tabelline`** holds what is specific to tabelline and is not in its docs: where the docs are
  and how to search them, how to work (one verb per line, print the table as text, write the
  page, look at it), the traps agents met, and two pages for hard tables, one on data made in
  code and one on drawings in cells.
- **`table-building`** holds what is true of any table, with any library: say what the table is
  for, shape the data first, build in the order of the parts, look at it, say what you checked.
  It comes with `look.js`, the script that takes the two screenshots and measures what a program
  can measure.

Both are at the end of this post, as an agent reads them. In Claude Code they install as one
plugin, with two commands: the first adds this repository as a marketplace, the second installs
the plugin `tabelline` from it.

```
/plugin marketplace add pietroppeter/tabelline
/plugin install tabelline@tabelline
```

Any other agent can be pointed at the two `SKILL.md` files. The page [For coding
agents](../../agents/) has the same, and the README.

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

## How it was measured

Each task is a folder in a skill's `evals/`: the prompt, the files the agent finds, and one small
file per check. A check is that a file exists, or that a pattern is, or is not, in a file or in
the agent's reply: the page has a summary row, the code takes the rows from the display order,
no drawing has a size that ends in a dot, the screenshots exist.

How the runs are kept apart from everything else, since an agent that knows the answer tests
nothing:

- Every run is a new agent process (`claude -p`), not a helper of the session that writes the
  skills, so it gets none of that conversation.
- It starts in an empty folder outside any repository, with the task's files only, so it finds
  no CLAUDE.md or AGENTS.md. User settings are left out (`--setting-sources local`), and with
  them every installed plugin; no connector is given (`--strict-mcp-config`); the project's
  memory is switched off.
- With the skills, the plugin is a copy of `skills/` without the `evals/` folders, so the agent
  cannot read its checks. The prompt never names a skill: the agent loads it, or not, from its
  first sentence, as it would for a user.
- Caches are per run, and the agents installed packages only in their own folder.
- What is not enforced is asked, then checked. The prompt tells the agent not to open the
  repository, the other runs or the book (which holds the answer to the NFL task). A script read
  every tool call of every run: none did.
- Both groups run at the same time on the same four CPUs, six to ten at once, so seconds depend
  on the neighbours: compare the two groups, not a time with another. Tokens and cost do not have
  this problem.

When a run ends, `tools/skillevals.nim` grades its folder.

A skill is worth keeping when the agent that has it does better, or does the same with less time
and money.

## How we got there

It took four rounds. The first three were measured in a simpler way, which the fourth shows was
not good enough: the agent was told to read the skill, and it was a helper of the session that
was working on tabelline, so it also carried this repository's notes for agents. Their numbers
are kept as they were found.

### Round one: a skill that copied the docs

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

### Round two: send the agent to the docs

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

### Round three: hard tables

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

### One skill or two

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

It does not change when tabelline does, and it was written to work for gt and Great Tables too
(tested later: see the result).

### Look at it

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

### Round four: measure it properly

Pietro asked what the final skills are worth, in numbers. Measuring it showed two faults, one
in the method and one in the skills.

**The method.** In the first three rounds the agent "without the skill" was a helper started
from the session that was working on tabelline. It had been given this repository's notes for
agents, which say how tabelline's examples are written and where its docs are. So it was not
without. And the agent "with the skill" was told to read it, which is not how a skill is used:
a user installs it and the agent decides. The result at the top of this post comes from new
agent processes, in a folder outside any repository, with the skills installed and not named.

**The skills.** In the first proper run, the skill `tabelline` loaded in all fifteen runs with
the skills. The skill `table-building` loaded only for the brief. For the other twelve, the
agent had read in `tabelline` a sentence that sent it to `table-building` for the look step,
and did not follow it: twelve agents of twelve did not look at their page. The step is now in
`tabelline` itself, as the third step of its way of working, with the command to run. The twelve
runs were made again: twelve of twelve looked.

The same tasks on Haiku, the small model, found one more: five runs of fifteen never opened the
skill. Its first sentence now starts with "Read this first, before writing any code". Of nine
new runs on the three tasks where it had been skipped, eight opened it.

**An agent does what the skill it is reading says, not what another skill would say. Put the
step where the agent already is.**

Writing down how the runs were kept apart found one more fault, after Pietro asked: every agent,
in both groups, had this project's memory in its prompt, a page of notes about tabelline and
its docs. And "looked" had been counted from the screenshots left in the folder, so an agent
that looked and deleted its pictures counted as not looking. The result at the top comes from
all the runs made again, 72 of them, with the memory switched off and "looked" counted from the
pictures the agent opened. Without the memory, agents without the skills looked more often than
before, and the skills' advantage on the right table went away; the phone, the pages that break
and the cost remained.

**Write down how the experiment is isolated, and check each line against the transcripts. Two
of the faults here were found that way.**

### What four rounds say

1. Names that follow gt, and docs in the source, do most of the work. Put effort there first.
2. A skill holds what the docs do not: how to work, the traps, a few recipes. It links the rest.
3. Every rule says what to do. A true warning that stops halfway did more harm than no skill.
4. Checks read the code and the page, and the hardest task is the only one that tests anything.
5. Agents rarely check what they make on a phone, unless a skill gives them the tool and tells
   them to.
6. Choose what goes in a skill from what agents wrote down, not from what seems useful.
7. A pointer from one skill to another is not followed. Each skill holds its own steps.
8. The sentence that says when to use a skill is an order, not a description: a small model
   skips a description.
9. Measure with agents that know nothing: a new process, an empty folder, no memory, skills
   that load by themselves. A helper of the working session knows too much.
10. Count what the agent did, from its transcript, not what it left behind.

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
