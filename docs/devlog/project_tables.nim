## devlog: 13 Nov 2026 A | Tables that ran projects | Research for a story on project management: from Priestley's lives in bars (1765) and Adamiecki's harmonogram to Gantt, the Hoover Dam, Polaris, Apollo, and the matrices of who does what and who cares. Nineteen dates in one table, then fourteen designs, from the simplest, each made with tabelline on one invented project, and which of them fit two jobs: tracking activities and tracking many stakeholders.
## A dated post: research for the project-management story (activities, stakeholders, PowerPoint), and is not rewritten afterwards.
import std/[os, strutils, strformat, sequtils, tables, math, algorithm, times]
import nimib
import tabelline, tabelline/nimib
import ../blocks, ../theme

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "project-tables" / "index.html"
nb.useTabelline(title = "Tables that ran projects", homeHref = "../", backLabel = "Devlog", wordmarkHref = "../../")

nbTitle "13 November 2026", "Tables that ran projects", """
Research for a story on project management. Since Priestley drew lives as bars (1765), people
have run projects with tables: Adamiecki's harmonogram, Gantt's charts, the networks of Polaris
and DuPont, the matrices of who does what and who cares. Nineteen dates in one table, then
fourteen designs, from the simplest, each made with tabelline, and which of them fit two jobs:
tracking activities, and tracking many stakeholders.
"""

nbToc

nbText: """
The next tabelline story is about project management. It goes with tabelline's PowerPoint
output (the [xoffy](https://github.com/pietroppeter/xoffy) library), because that is where
project tables live: on slides. Pietro wants to use tabelline at work for two jobs, tracking
the activities (with a Gantt chart and its variations) and tracking the stakeholders ("there are
too many!"). This post is the research before the story: where the tables and charts of project
management come from, which famous projects they went with, and what each looks like as a
tabelline table.

Every table here is about one project, and the project is made up: a garden on the Moon, the one
of the [Gantt prototype](https://claude.ai/artifact/MoLRmA6QG7krLZGyUbhzmU). Twelve activities in
four streams, sixteen stakeholders, all invented. The history is real, and every date has a link
to its source.
"""

nbNote("""
Green cards like this one are about the code. Under every table, *show code* opens the code
that made it; it ran when the page was built. All the tables come from three lists defined once
(activities, stakeholders, milestones): the point of the post is that a project is one set of
data and many tables.
""", nkCode, "Reading the code")

# ------------------------------------------------------------------------------------- the data

type
  Activity = object
    key, stream, name: string
    first, last: int           ## ISO weeks of 2031, both included
    after: seq[string]         ## the activities that must finish first
    o, p: int                  ## optimistic and pessimistic weeks (the plan's is the most likely)
    done: int                  ## weeks of work done at today
    effort: int                ## person-weeks budgeted
    spent: int                 ## person-weeks spent at today
    raci: string               ## a letter (or .) for each role, in the order of `roles`

let plan = @[
  Activity(key: "A", stream: "Seeds", name: "Pick twelve hardy varieties", first: 14, last: 19, o: 5, p: 8, done: 6, effort: 12, spent: 13, raci: "ARCI.."),
  Activity(key: "B", stream: "Seeds", name: "Germination trials in low gravity", first: 20, last: 29, after: @["A"], o: 7, p: 16, done: 5, effort: 30, spent: 19, raci: "ARC.I."),
  Activity(key: "C", stream: "Seeds", name: "Seed vault packing", first: 30, last: 33, after: @["B"], o: 3, p: 6, effort: 8, raci: "IR..CA"),
  Activity(key: "D", stream: "Habitat", name: "Greenhouse dome design", first: 14, last: 21, o: 6, p: 12, done: 8, effort: 24, spent: 26, raci: "ACR..I"),
  Activity(key: "E", stream: "Habitat", name: "Soil from regolith", first: 22, last: 31, after: @["D"], o: 8, p: 16, done: 4, effort: 40, spent: 22, raci: "ACRI.."),
  Activity(key: "F", stream: "Habitat", name: "Water recycling loop", first: 22, last: 28, after: @["D"], o: 5, p: 9, done: 5, effort: 21, spent: 18, raci: "A.RC.I"),
  Activity(key: "G", stream: "Habitat", name: "Light and heat tests", first: 32, last: 35, after: @["E", "F"], o: 3, p: 7, effort: 12, raci: "ACRCI."),
  Activity(key: "H", stream: "Rover", name: "Rover chassis", first: 14, last: 23, o: 8, p: 13, done: 10, effort: 30, spent: 28, raci: "A.IR.C"),
  Activity(key: "I", stream: "Rover", name: "Planting arm", first: 24, last: 30, after: @["H"], o: 5, p: 10, done: 3, effort: 21, spent: 9, raci: "AC.R.I"),
  Activity(key: "J", stream: "Rover", name: "Field trials in the desert", first: 31, last: 34, after: @["I"], o: 3, p: 8, effort: 16, raci: "ICIRCA"),
  Activity(key: "K", stream: "Crew", name: "Gardener training", first: 20, last: 34, after: @["A"], o: 12, p: 18, done: 6, effort: 30, spent: 14, raci: "IC..RA"),
  Activity(key: "L", stream: "Crew", name: "Recipe book for the first harvest", first: 36, last: 38, after: @["C", "G", "J", "K"], o: 2, p: 5, effort: 6, raci: "RCII.A")]

let roles = ["Garden lead", "Seed lab", "Habitat team", "Rover team", "Crew office", "Agency board"]
let today = 27                 # 2 July 2031, in ISO week 27
const firstWeek = 14
const lastWeek = 38

func wk(w: int): string = "W" & $w
let weekCols = toSeq(firstWeek .. lastWeek).mapIt(wk(it))

nbText: """
## The story in one table

Nineteen dates, in four eras: bars on a calendar, then networks, then money and matrices, then
people. Each era added a kind of table and kept the ones before: a project today still has a
Gantt chart, and now a stakeholder grid beside it.
"""

nbShowCode:
  type Step = tuple[era, year, who, gave, read: string]
  let history: seq[Step] = @[
    ("Bars on a calendar", "1765", "Joseph Priestley, *A Chart of Biography*",
     "about 2,000 lives as lines on a scale of years: the first bars in time, a century and a half before Gantt",
     "[Wikipedia](https://en.wikipedia.org/wiki/A_Chart_of_Biography)"),
    ("Bars on a calendar", "1896", "Karol Adamiecki, in the steelworks of Poland",
     "the *harmonogram*: time running down the page, a column per job, a sliding strip for each job's time; he described it in 1903 and published it in 1931",
     "[Wikipedia](https://en.wikipedia.org/wiki/Karol_Adamiecki)"),
    ("Bars on a calendar", "1910s", "Henry Gantt, in factories",
     "charts that set what was done against what was promised, day by day, for each worker, machine and order",
     "[Wikipedia](https://en.wikipedia.org/wiki/Henry_Gantt)"),
    ("Bars on a calendar", "1912", "Hermann Schürch, a building site",
     "bars of work on a calendar for a construction job, a kind of chart then common in Germany",
     "[Wikipedia](https://en.wikipedia.org/wiki/Gantt_chart#Historical_development)"),
    ("Bars on a calendar", "1922", "Wallace Clark, *The Gantt Chart*",
     "the name, and the kinds of chart: man and machine records, layout, load and progress; translated into many languages",
     "[Wikipedia](https://en.wikipedia.org/wiki/Henry_Wallace_Clark)"),
    ("Bars on a calendar", "1931", "Six Companies, the Hoover Dam",
     "a dam planned with Gantt charts, handed over in March 1936, more than two years ahead of schedule",
     "[Wikipedia](https://en.wikipedia.org/wiki/Henry_Gantt), [Wikipedia](https://en.wikipedia.org/wiki/Hoover_Dam)"),
    ("Bars on a calendar", "1941", "George Fouch, Goodyear, then the US Navy",
     "the *line of balance*: how many units should be at each stage by today, for work that repeats",
     "[PMI](https://www.pmi.org/learning/library/line-balance-scheduling-technique-progress-2078)"),
    ("Bars on a calendar", "1942", "Leslie Groves, the Manhattan Project",
     "a project run before networks existed: several ways to the same goal pursued at once, and milestones",
     "[Wikipedia](https://en.wikipedia.org/wiki/Manhattan_Project)"),
    ("Networks", "1957", "Morgan Walker (DuPont) and James Kelley (Remington Rand)",
     "the *critical path method*, on a UNIVAC I, for building and shutting down chemical plants",
     "[PMI](https://www.pmi.org/learning/library/origins-cpm-personal-history-3762)"),
    ("Networks", "1958", "the US Navy's Special Projects Office, Booz Allen Hamilton, Lockheed",
     "*PERT* for the Polaris missile: a network of events and three estimates for each activity",
     "[Wikipedia](https://en.wikipedia.org/wiki/Program_evaluation_and_review_technique)"),
    ("Networks", "1962", "the US Department of Defense and NASA, *PERT/COST*",
     "the *work breakdown structure*, and the cost of the work in the same network",
     "[Wikipedia](https://en.wikipedia.org/wiki/Work_breakdown_structure)"),
    ("Networks", "1964", "Samuel Phillips, Apollo",
     "the program director from Minuteman: schedule, cost and configuration controlled together, and PERT at the launch site",
     "[Wikipedia](https://en.wikipedia.org/wiki/Samuel_C._Phillips), [NASA](https://www.nasa.gov/history/phillips-report/)"),
    ("Money and matrices", "1967", "the US Department of Defense, *C/SCSC*",
     "*earned value*: 35 criteria for comparing work planned, work done and money spent",
     "[Wikipedia](https://en.wikipedia.org/wiki/Earned_value_management)"),
    ("Money and matrices", "1970s", "consultants, with no known inventor",
     "the *responsibility assignment matrix* (from the linear responsibility chart), RACI its best-known form",
     "[Wikipedia](https://en.wikipedia.org/wiki/Responsibility_assignment_matrix)"),
    ("Money and matrices", "1981", "Donald Steward, *The Design Structure System*",
     "the *design structure matrix*: activities against activities, a mark where one needs another (a GE report in 1968)",
     "[Wikipedia](https://en.wikipedia.org/wiki/Design_structure_matrix)"),
    ("People", "1984", "R. Edward Freeman, *Strategic Management: A Stakeholder Approach*",
     "the *stakeholder*: anyone who can affect, or is affected by, what an organisation does",
     "[Wikipedia](https://en.wikipedia.org/wiki/Stakeholder_theory)"),
    ("People", "1991", "Aubrey Mendelow",
     "the *power-interest grid*: four boxes, and what to do with the people in each",
     "[Wikipedia](https://en.wikipedia.org/wiki/Stakeholder_analysis)"),
    ("People", "1997", "Ronald Mitchell, Bradley Agle and Donna Wood",
     "*stakeholder salience*: power, legitimacy and urgency, and seven kinds of stakeholder from them",
     "[Academy of Management Review](https://doi.org/10.5465/amr.1997.9711022105)"),
    ("People", "2013", "PMI, the *PMBOK Guide*, fifth edition",
     "stakeholder management becomes the tenth knowledge area, with the *engagement assessment matrix*",
     "[Wikipedia](https://en.wikipedia.org/wiki/Project_Management_Body_of_Knowledge)")]
  let t = tabella(history, rownameCol = "year", groupnameCol = "era"):
    optCssTheme()
    fmtMarkdown ["who", "gave", "read"]
    colsMerge ["who", "read"], pattern = "{1} ({2})"
    colsLabel:
      who: "who, where (source)"
      gave: "what it gave"
    tabStubhead "year"
    tabFootnote "Most sources cite 1991; the conference the paper is often credited to, the 2nd ICIS, met in 1981.", loc.stub(rows = 16)
  nbTable t

nbText: """
Three things in it matter for the story. First, the Gantt chart is older than Gantt: bars on a
time scale go back to Priestley, and Adamiecki had a chart for scheduling work in 1896, in
Polish and Russian, which few read in English. Gantt's own idea was another one, and it is in
the [promise and what was done](#what-was-promised-what-was-done) below. Second, the network
methods were born twice in the same two years, at DuPont and in the Polaris program, and they
are still the arithmetic inside every planning tool. Third, the stakeholder came last: the
tables of people are thirty years younger than the tables of work.
"""

nbNote("""
`tabella(history, rownameCol = "year", groupnameCol = "era")` makes the eras row groups and the
years the stub. `fmtMarkdown` reads the links and the italics of three columns, `colsMerge` puts the source
after who and where, so the table has three columns on a phone, and the footnote
sits on a stub cell (`loc.stub(rows = 16)`, the 1991 row).
""", nkCode)

nbNote("""
Not in this post: the kanban board (Toyota, 1950s), the burn-down chart of Scrum, and the risk
matrix of probability and impact. They are tables too, and may join the story.
""", nkInfo, "Left for later")

nbText: """
## A list of things to do

The simplest project table is a list. When the list grows, it becomes a tree: the project, its
parts, the parts of the parts. The Polaris program grouped its work by the product it made, and
the *PERT/COST* guide of 1962 named this tree the *work breakdown structure* (WBS); it is still
the first table of a project plan. Here is the garden's, numbered, with each level indented.
"""

nbShowCode:
  var streams: seq[string]
  for a in plan:
    if a.stream notin streams: streams.add a.stream
  type Item = tuple[code, item: string, level: int]
  var wbs: seq[Item] = @[("1", "Moon garden", 0)]
  for i, s in streams:
    wbs.add (&"1.{i + 1}", s, 1)
    for j, a in plan.filterIt(it.stream == s):
      wbs.add (&"1.{i + 1}.{j + 1}", a.name, 2)
  var t = tabella(wbs, rownameCol = "item"):
    optCssTheme()
    colsHide ["level"]
    colsMoveToStart ["code"]
    tabStubhead "work"
    tabStyle style.text(weight = "bold"), loc.stub(rows = toSeq(0 ..< wbs.len).filterIt(wbs[it].level < 2))
  for level in 1 .. 2:
    t = t.tabStubIndent(toSeq(0 ..< wbs.len).filterIt(wbs[it].level == level), level)
  nbTable t

nbNote("""
The tree is made from the plan: one row per stream, then one per activity. `tabStubIndent`
takes the rows of a level and how deep to indent them (0 to 5); a loop calls it per level.
""", nkCode)

nbText: """
## Bars on a calendar

From the list to the chart: give each activity a first and a last week, and draw one column per
week. A filled cell is a week of work. This is what most people call a Gantt chart, though it
is closer to Schürch's bars of 1912 and Priestley's lives of 1765. The weeks go under their
months, and a dotted box marks today's week, 27.
"""

# start: week helpers
proc weekData(state: proc (a: Activity, w: int): string): TableData =
  ## One row per activity, one column per week, holding the state of that week.
  var columns = @[("stream", plan.mapIt(toValue(it.stream))),
                  ("activity", plan.mapIt(toValue(it.name)))]
  for w in firstWeek .. lastWeek:
    columns.add (wk(w), plan.mapIt(toValue(state(it, w))))
  toTableData(columns)

proc monthOf(w: int): Month =
  ## The month of ISO week `w` of 2031: the month of its Thursday.
  let jan4 = dateTime(2031, mJan, 4, zone = utc())
  (jan4 - days(ord(jan4.weekday)) + weeks(w - 1) + days(3)).month

proc ganttLook(t: sink Tabella, states: openArray[(string, string)]): Tabella =
  ## A chart from a table of week states: each state a fill, the months as spanners, today boxed.
  var months: OrderedTable[Month, seq[string]]
  for w in firstWeek .. lastWeek: months.mgetOrPut(monthOf(w), @[]).add wk(w)
  result = t
    .fmt(cols(weekCols), proc (v: Value): string = "")
    .colsLabelWith(cols(weekCols), proc (s: string): string = s[1 .. ^1])
    .colsWidth(weekCols.mapIt((it, "18px")))
    .colsLabelRotate(cols(weekCols))
    .tabOptions(tableFontSize = "13px", dataRowPadding = "2px", dataRowPaddingHorizontal = "0px",
                columnLabelsFontSize = "70%")
    .tabStyle(style.css("height: 20px; line-height: 20px; padding-top: 0; padding-bottom: 0; white-space: nowrap"),
              loc.stub(), loc.body(), loc.rowGroups())
    .tabStyle(style.css("padding-left: 0; padding-right: 0"), loc.columnLabels(cols(weekCols)))
  for m, ws in months:
    result = result
      .tabSpanner(toText(($m)[0 .. 2]), cols(ws))
      .tabStyle(style.borders({sLeft}, color = tint("--line")), loc.body(cols(ws[0])))
  for (state, colour) in states:
    result = result.tabStyleBody(style.fill(colour), columns = cols(weekCols), values = [state])
  let now = cols(wk(today))
  result = result
    .tabStyle(style.borders({sLeft, sRight}, color = tint("--ink"), style = "dotted", weight = "2px"),
              loc.body(now), loc.columnLabels(now))
# stop: week helpers

nbFoldCode(currentSourcePath(), start = "# start: week helpers", stop = "# stop: week helpers", title = "the chart helpers")

nbShowCode:
  let bars = weekData(proc (a: Activity, w: int): string =
    if w in a.first .. a.last: "work" else: "")
  let t = tabella(bars, rownameCol = "activity", groupnameCol = "stream"):
    optCssTheme()
    tabStubhead "activity"
  nbTable t.ganttLook({"work": tint("--primary")})

nbNote("""
`weekData` turns the plan into one column per week holding a state (here `"work"` or nothing);
`ganttLook` hides the states (`fmt` to an empty text), turns the week numbers on their side, fills each state's cells with
`tabStyleBody(style.fill(colour), values = [state])`, puts the weeks under a spanner per month
(a week belongs to the month of its Thursday, as in ISO), and draws today's box with dotted
borders. Every row is one line, 20 pixels high, or the bars would not line up on a phone.
""", nkCode)

nbText: """
## The harmonogram, the other way round

Adamiecki drew the same chart turned a quarter: time runs down the page, one row per day or
week, and each job is a narrow column, with a strip of paper that slides along it for the job's
time. Turned this way the chart is tall and narrow, which is the shape of a phone, and twelve
columns of letters fit where twenty-five weeks did not.
"""

nbShowCode:
  var hcols = @[("week", toSeq(firstWeek .. lastWeek).mapIt(toValue(wk(it))))]
  for a in plan:
    hcols.add (a.key, toSeq(firstWeek .. lastWeek).mapIt(toValue(if it in a.first .. a.last: "work" else: "")))
  var h = tabella(toTableData(hcols), rownameCol = "week"):
    optCssTheme()
    tabStubhead "week"
    tabOptions(tableFontSize = "13px", dataRowPadding = "1px")
  for s in ["Seeds", "Habitat", "Rover", "Crew"]:
    h = h.tabSpanner(toText(s), cols(plan.filterIt(it.stream == s).mapIt(it.key)))
  let keys = plan.mapIt(it.key)
  h = h
    .fmt(cols(keys), proc (v: Value): string = "")
    .colsWidth(keys.mapIt((it, "22px")))
    .tabStyleBody(style.fill(tint("--primary")), columns = cols(keys), values = ["work"])
    .tabStyle(style.borders({sTop, sBottom}, color = tint("--ink"), style = "dotted", weight = "2px"),
              loc.body(rows = today - firstWeek), loc.stub(rows = today - firstWeek))
    .tabSourceNote(md(plan.mapIt(&"**{it.key}** {it.name}").join(" · ")))
  nbTable h

nbNote("""
The same plan, with weeks as rows and activities as columns: a column per activity key, a
spanner per stream, and the key's meaning in the source note. Today is a row now, boxed above
and below.
""", nkCode)

nbText: """
## What was promised, what was done

Gantt's charts were not plans. They compared, for each worker, machine or order, what was done
with what had been promised, so that a foreman saw at a glance who was behind. The garden's
version: a week of work done is full, a week promised before today and not done is late, a week
still to come is light. Three activities are behind: the germination trials, the regolith soil,
and the gardeners' training.
"""

nbShowCode:
  var promise = weekData(proc (a: Activity, w: int): string =
    if w notin a.first .. a.last: ""
    elif w - a.first < a.done: "done"
    elif w < today: "late"
    else: "todo")
  var behind = newSeq[Value]()
  for a in plan:
    let promised = max(0, min(today, a.last + 1) - a.first)
    behind.add toValue(max(0, promised - a.done))
  promise.addColumn("behind", behind)
  let t = tabella(promise, rownameCol = "activity", groupnameCol = "stream"):
    optCssTheme()
    tabStubhead "activity"
    colsLabel:
      behind: "weeks behind"
    fmt "behind", proc (v: Value): string = (if v.toFloat > 0: $int(v.toFloat) else: "")
  nbTable t.ganttLook({"done": tint("--primary"), "late": tint("--warning"),
                      "todo": tintMix("--primary", 25)})

nbNote("""
The week states are now four (`done`, `late`, `todo` or nothing), from the work done at today;
`ganttLook` takes a colour for each. The weeks behind are a column computed from the plan,
blank when nothing is behind.
""", nkCode)

nbText: """
## Milestones and how they drift

A milestone is a date that matters, with no length: the dome approved, the first seed in the
soil. The simplest milestone table has the date promised at the start (the *baseline*), the date
forecast today, and the difference. The second table follows the forecasts over time: each
row is a report, each column a milestone. Engineers in German-speaking countries call it the
*Meilensteintrendanalyse*, milestone trend analysis; drawn as a chart, a line that stays flat
is a milestone that holds, and one that climbs is slipping. I could not find who drew it
first.
"""

type Milestone = tuple[name: string, baseline: int, forecasts: seq[int], reached: int]
let milestones: seq[Milestone] = @[
  ("Dome design approved", 22, @[22, 22, 22, 23, 23, 23], 23),
  ("Rover in the desert", 31, @[31, 31, 31, 31, 31, 31], 0),
  ("Soil ready", 32, @[32, 32, 33, 33, 34, 35], 0),
  ("First seed in the soil", 39, @[39, 39, 39, 40, 40, 41], 0)]
let reports = @[16, 18, 20, 22, 24, 26]

nbShowCode:
  type Row1 = tuple[milestone: string, baseline, forecast, slip: int, state: string]
  let rows = milestones.mapIt((it.name, it.baseline, it.forecasts[^1], it.forecasts[^1] - it.baseline,
                               (if it.reached > 0: "reached" elif it.forecasts[^1] > it.baseline: "slipping" else: "on time")))
  let t = tabella(rows.mapIt(Row1(it)), rownameCol = "milestone"):
    optCssTheme()
    fmt ["baseline", "forecast"], proc (v: Value): string = "W" & $int(v.toFloat)
    fmt "slip", proc (v: Value): string = (if v.toFloat > 0: "+" & $int(v.toFloat) else: "")
    colsLabel:
      slip: "weeks late"
    tabStyleBody style.fill(tint("--warning-soft")), columns = "state", values = ["slipping"]
    tabStyleBody style.fill(tint("--success-soft")), columns = "state", values = ["reached"]
  nbTable t

nbShowCode:
  var mcols = @[("report", reports.mapIt(toValue(wk(it))))]
  for m in milestones:
    mcols.add (m.name, m.forecasts.mapIt(toValue(it)))
  var mt = tabella(toTableData(mcols), rownameCol = "report"):
    optCssTheme()
    tabStubhead "report of"
    tabSpanner "forecast week of each milestone", everything()
  for m in milestones:
    mt = mt
      .fmt(m.name, proc (v: Value): string = "W" & $int(v.toFloat))
      .tabStyleBody(style.fill(tint("--warning-soft")), columns = m.name,
                    fn = proc (v: Value): bool = v.toFloat > m.baseline.float)
    if m.reached > 0:
      mt = mt.tabStyle(style.fill(tint("--success-soft")),
                       loc.body(cols(m.name), rows = toSeq(0 ..< reports.len).filterIt(reports[it] > m.reached)))
  mt = mt.colsLabelRotate(dir = "slanted")
  nbTable mt.tabSourceNote("Yellow: later than the baseline. Green: reached.")

nbNote("""
The first table is made from the milestones' last forecast; the second has a column per
milestone, so its formats and styles are set in a loop: `tabStyleBody` with `fn` marks the
forecasts later than that milestone's baseline. `colsLabelRotate(dir = "slanted")` keeps the
long names in narrow columns.
""", nkCode)

nbText: """
## The network and its critical path

In 1957 Walker and Kelley gave up the calendar and kept only two facts per activity: how long it
takes, and what must finish before it starts. From those, a forward pass gives the earliest each
activity can start and finish, a backward pass from the end the latest, and the difference is the
*float*: how many weeks an activity can slip without moving the end. Activities with no float
make the *critical path*. In the garden it runs through the dome, the soil, the light tests and
the recipe book: 25 weeks.
"""

# start: two passes
var es, ef, ls, lf: Table[string, int]
func weeksOf(a: Activity): int = a.last - a.first + 1
for a in plan:                       # forward: the plan lists every activity after the ones it needs
  es[a.key] = a.after.mapIt(ef[it]).foldl(max(a, b), 0)
  ef[a.key] = es[a.key] + a.weeksOf
let finish = toSeq(ef.values).max
for a in plan.reversed:              # backward: from the end
  let next = plan.filterIt(a.key in it.after)
  lf[a.key] = next.mapIt(ls[it.key]).foldl(min(a, b), finish)
  ls[a.key] = lf[a.key] - a.weeksOf
let legend = plan.mapIt(&"**{it.key}** {it.name}").join(" · ")   # the activities' keys, for a source note
let critical = toSeq(0 ..< plan.len).filterIt(ls[plan[it].key] == es[plan[it].key])   # the rows with no float
# stop: two passes

nbFoldCode(currentSourcePath(), start = "# start: two passes", stop = "# stop: two passes", title = "the two passes")

nbShowCode:
  type Cpm = tuple[key, needs: string, weeks, es, ef, ls, lf, float: int]
  let cpm = plan.mapIt(Cpm((it.key, it.after.join(" "), it.weeksOf,
                            es[it.key], ef[it.key], ls[it.key], lf[it.key], ls[it.key] - es[it.key])))
  let t = tabella(cpm, rownameCol = "key"):
    optCssTheme()
    tabSpanner "earliest", ["es", "ef"]
    tabSpanner "latest", ["ls", "lf"]
    colsLabel:
      es: "start"
      ef: "finish"
      ls: "start"
      lf: "finish"
      needs: "after"
    tabStyle style.fill(tint("--primary-soft")), loc.body(rows = critical), loc.stub(rows = critical)
    tabStubhead "activity"
    tabSourceNote md(&"Weeks from the start, week {firstWeek}. The critical path, filled, takes {finish} weeks.")
    tabSourceNote md(legend)
  nbTable t

nbNote("""
The two passes are a few lines of Nim over the plan: `es` is the latest `ef` of what an
activity needs, and `lf` the earliest `ls` of what needs it. The plan lists every activity after
the ones it needs, so one loop each way is enough. The critical rows are those whose float is
zero.
""", nkCode)

nbText: """
## Three estimates for every activity

PERT, made for Polaris in 1958, asked for three durations instead of one: optimistic (*o*),
most likely (*m*) and pessimistic (*p*). Their weighted mean (*o* + 4*m* + *p*) / 6 is the
expected time, and (*p* − *o*) / 6 its spread. Summed along the critical path, they give a
chance of finishing by a date: the answer to "when?" is no longer one date but a probability.
Harvey Sapolsky's history of Polaris
([1972](https://ssp.mit.edu/publications/1972/the-polaris-system-development)) found PERT "as
much a device to protect the program from external interference as an effective management
tool"; the arithmetic stayed anyway.
"""

nbShowCode:
  type Pert = tuple[key: string, o, m, p: int, expected, sigma: float]
  let pert = plan.mapIt(Pert((it.key, it.o, it.last - it.first + 1, it.p,
                              (it.o + 4 * (it.last - it.first + 1) + it.p) / 6, (it.p - it.o) / 6)))
  let path = plan.filterIt(ls[it.key] == es[it.key])
  var mean, variance = 0.0
  for a in path:
    let r = pert[plan.find(a)]
    mean += r.expected
    variance += r.sigma ^ 2
  func normalCdf(z: float): float = 0.5 * (1 + erf(z / sqrt(2.0)))
  let target = 27
  let chance = normalCdf((target.float - mean) / sqrt(variance))
  let t = tabella(pert, rownameCol = "key"):
    optCssTheme()
    tabSpanner "weeks", ["o", "m", "p"]
    fmtNumber ["expected", "sigma"], decimals = 1
    colsLabel:
      o: "optimistic"
      m: "likely"
      p: "pessimistic"
      sigma: "spread"
    colsLabelRotate ["o", "m", "p"], dir = "slanted"
    tabStubhead "activity"
    tabSourceNote md(legend)
    tabStyle style.fill(tint("--primary-soft")), loc.body(rows = critical), loc.stub(rows = critical)
    tabSourceNote md(&"Along the critical path: {mean:.1f} weeks expected, give or take {sqrt(variance):.1f}; " &
                     &"a {chance * 100:.0f}% chance of finishing within {target} weeks.")
  nbTable t

nbNote("""
`expected` and `sigma` are columns computed in the tuple; the chance is the normal
distribution's, from `erf` of `std/math`, as PERT assumed. The critical rows are the ones of the
network above.
""", nkCode)

nbText: """
## Activities against activities

A network is usually drawn as boxes and arrows, which take room and get tangled. Donald Steward
put it in a square table instead, the *design structure matrix*: the activities down the side and
across the top, and a mark where the row needs the column. In the order of the plan every mark
falls below the diagonal; a mark above it would be a loop, work that must go round more than
once, which is what Steward wanted to find.
"""

nbShowCode:
  var dcols = @[("activity", plan.mapIt(toValue(it.key & " " & it.name)))]
  for b in plan:
    dcols.add (b.key, plan.mapIt(toValue(if b.key in it.after: "●" elif it.key == b.key: "◼" else: "")))
  let keys = plan.mapIt(it.key)
  let t = tabella(toTableData(dcols), rownameCol = "activity"):
    optCssTheme()
    tabStubhead "needs →"
    colsAlign alCenter, keys
    colsWidth keys.mapIt((it, "22px"))
    tabOptions(tableFontSize = "13px", dataRowPadding = "2px", dataRowPaddingHorizontal = "0px")
    tabStyleBody style.text(color = tint("--line")), columns = keys, values = ["◼"]
    tabStyleBody style.text(color = tint("--primary")), columns = keys, values = ["●"]
  nbTable t

nbNote("""
The matrix is made from the same `after` lists as the network: a column per activity, a `●`
where the row's activity needs it, the diagonal grey.
""", nkCode)

nbText: """
## Work, money and earned value

Earned value, which the US Department of Defense made a rule in 1967, adds money (or effort) to
the plan. For each activity: the effort *planned* by today, the effort *earned* (the budget of
the work actually done) and the effort *spent*. Two ratios say it all: earned over planned is
the schedule index (below 1, behind), earned over spent the cost index (below 1, over
budget). The garden counts in person-weeks; the streams sum up.
"""

nbShowCode:
  type Ev = tuple[stream, activity: string, budget, planned, earned, spent: float, spi, cpi: float]
  var ev: seq[Ev]
  for a in plan:
    let weeks = float(a.last - a.first + 1)
    let planned = a.effort.float * clamp(float(today - a.first), 0, weeks) / weeks
    let earned = a.effort.float * a.done.float / weeks
    ev.add (a.stream, a.name, a.effort.float, planned, earned, a.spent.float,
            (if planned > 0: earned / planned else: NaN), (if a.spent > 0: earned / a.spent.float else: NaN))
  let t = tabella(ev, rownameCol = "activity", groupnameCol = "stream"):
    optCssTheme()
    tabSpanner "person-weeks", ["budget", "planned", "earned", "spent"]
    tabSpanner "index", ["spi", "cpi"]
    fmtNumber ["budget", "planned", "earned", "spent"], decimals = 0
    fmtNumber ["spi", "cpi"], decimals = 2
    subMissing ["spi", "cpi"], missingText = ""
    colsLabel:
      spi: "time"
      cpi: "cost"
    summaryRows:
      total: agg.sum
      columns = ["budget", "planned", "earned", "spent"]
      fmtNumber(decimals = 0)
    tabStyleBody style.fill(tint("--warning-soft")), columns = ["spi", "cpi"], fn = proc (v: Value): bool = v.toFloat < 0.9
  nbTable t

nbNote("""
The three efforts are computed from the plan at today; `summaryRows` (new in 0.2) sums them per
stream, and `tabStyleBody` with `fn` marks the indices below 0.9. A summary of the indices would
be a ratio of the sums, not their sum, so they have no summary cells.
""", nkCode)

nbText: """
## Who does what

The responsibility matrix puts the activities down the side and the people (or roles) across
the top, and in each cell a letter: **R**esponsible does the work, **A**ccountable answers for
it (one per activity, always), **C**onsulted is asked before, **I**nformed is told after. It
has no known inventor; it grew out of the *linear responsibility chart* of management
consultants. Its strength is the check it allows: a row with no A, or with two, is a problem
found before it happens.
"""

nbShowCode:
  var rcols = @[("stream", plan.mapIt(toValue(it.stream))), ("activity", plan.mapIt(toValue(it.name)))]
  for i, r in roles:
    rcols.add (r, plan.mapIt(toValue(if it.raci[i] == '.': "" else: $it.raci[i])))
  rcols.add ("check", plan.mapIt(toValue(if it.raci.count('A') == 1: "✓" else: "one A?")))
  let t = tabella(toTableData(rcols), rownameCol = "activity", groupnameCol = "stream"):
    optCssTheme()
    colsAlign alCenter, @roles & @["check"]
    colsLabelRotate @roles, dir = "slanted"
    tabStyleBody style.fill(tint("--primary")), columns = @roles, values = ["A"]
    tabStyleBody style.text(color = tint("--paper"), weight = "bold"), columns = @roles, values = ["A"]
    tabStyleBody style.fill(tint("--primary-soft")), columns = @roles, values = ["R"]
    tabStyleBody style.text(color = tint("--muted")), columns = @roles, values = ["I"]
  nbTable t

nbNote("""
The letters come from one string per activity, a character per role; the `check` column counts
the A's. Styles go by value: A filled in the primary colour, R in its soft tint, I muted.
""", nkCode)

# --------------------------------------------------------------------------------- stakeholders

nbText: """
## Who cares, and how much

The other half of the project is people. Freeman's stakeholder (1984) is anyone who can affect
the project or is affected by it, and a project of any size has many: the garden has sixteen,
and a real one more. The first table of people is the *register*: who they are, grouped by kind,
and a few scores. Everything else about stakeholders is made from it.
"""

type Stakeholder = tuple[kind, name: string, power, interest: int, legit, urgent: bool, now, wanted: int]
const levels = ["Unaware", "Resistant", "Neutral", "Supportive", "Leading"]
let people: seq[Stakeholder] = @[
  ("Inside the project", "Garden lead", 5, 5, true, true, 4, 4),
  ("Inside the project", "Seed lab", 3, 5, true, false, 3, 3),
  ("Inside the project", "Habitat team", 3, 5, true, true, 3, 3),
  ("Inside the project", "Rover team", 3, 4, true, false, 3, 3),
  ("Inside the project", "Crew office", 3, 4, true, false, 2, 3),
  ("The agency", "Agency board", 5, 3, true, false, 2, 3),
  ("The agency", "Safety office", 5, 4, true, true, 1, 3),
  ("The agency", "Budget office", 4, 2, true, false, 2, 2),
  ("Partners", "Lunar base council", 4, 4, true, true, 3, 4),
  ("Partners", "Regolith supplier", 2, 4, true, true, 3, 3),
  ("Partners", "Rover maker", 3, 4, true, false, 3, 3),
  ("Partners", "Insurance consortium", 4, 1, false, false, 0, 2),
  ("Outside", "Crater colony next door", 2, 5, false, true, 1, 2),
  ("Outside", "Visitors' society", 1, 3, false, false, 0, 2),
  ("Outside", "Schools on Earth", 1, 4, false, false, 0, 3),
  ("Outside", "Press on Earth", 3, 2, false, true, 2, 2)]

nbShowCode:
  let t = tabella(people, rownameCol = "name", groupnameCol = "kind"):
    optCssTheme()
    colsHide ["legit", "urgent", "now", "wanted"]
    tabSpanner "from 1 to 5", ["power", "interest"]
    tabStubhead "stakeholder"
  var r = t
  for score in 1 .. 5:   # a tint of the primary colour for each score, the same in both columns
    r = r.tabStyleBody(style.fill(tintMix("--primary", score * 15 - 10)), columns = ["power", "interest"], values = [$score])
  nbTable r

nbNote("""
The register is a list of tuples; `colsHide` keeps the columns the next tables need out of
this one. Each score gets its own tint of the primary colour, from 5% for a 1 to 65% for a 5,
the same in both columns. (`dataColor` would do it in one line, but it needs colours it can
mix, and the page's colours are tokens: a gap noted at the end.)
""", nkCode)

nbText: """
## Four boxes: power and interest

Mendelow's grid sorts the register into four boxes, by power over the project and interest in it,
and gives each box a way to treat its people: *manage closely* those with both, *keep
satisfied* the powerful who care little, *keep informed* the interested with little power, and
*monitor* the rest. As a table it is two rows and two columns, and a cell holds names, not a
number. With many stakeholders this is the table that matters: it says where to spend the
time.
"""

nbShowCode:
  proc box(highPower, highInterest: bool): string =
    people.filterIt((it.power >= 4) == highPower and (it.interest >= 4) == highInterest)
          .mapIt(it.name).join(", ")
  type Box = tuple[power, low, high: string]
  let grid: seq[Box] = @[
    ("high power", "**keep satisfied**: " & box(true, false), "**manage closely**: " & box(true, true)),
    ("low power", "**monitor**: " & box(false, false), "**keep informed**: " & box(false, true))]
  let t = tabella(grid, rownameCol = "power"):
    optCssTheme()
    fmtMarkdown ["low", "high"]
    tabSpanner "interest", ["low", "high"]
    colsWidth:
      low: "45%"
      high: "45%"
    tabStyle style.fill(tint("--primary-soft")), loc.body(cols("high"), rows = 0)
    tabSourceNote "High is 4 or 5 on the register's scale."
  nbTable t

nbNote("""
Each cell is a `box`: the names of the register filtered by the two scores, joined. The grid is
made, never typed, so it changes when the register does.
""", nkCode)

nbText: """
## Power, legitimacy, urgency

Mitchell, Agle and Wood asked which stakeholders managers actually listen to, and answered with
three yes-or-no questions: does it have *power* over the project, a *legitimate* claim on it, an
*urgent* one? The eight answers are eight kinds, and their names are a table already. The more
yes, the more salient: one is *latent*, two *expectant*, three *definitive*. The last column
places the garden's stakeholders.
"""

nbShowCode:
  type Kind = tuple[kind: string, p, l, u: bool, class: string]
  let kinds: seq[Kind] = @[
    ("Definitive", true, true, true, "Definitive: all three"),
    ("Dominant", true, true, false, "Expectant: two"),
    ("Dangerous", true, false, true, "Expectant: two"),
    ("Dependent", false, true, true, "Expectant: two"),
    ("Dormant", true, false, false, "Latent: one"),
    ("Discretionary", false, true, false, "Latent: one"),
    ("Demanding", false, false, true, "Latent: one"),
    ("Not a stakeholder", false, false, false, "None")]
  var who: seq[string]
  for k in kinds:
    who.add people.filterIt((it.power >= 4) == k.p and it.legit == k.l and it.urgent == k.u)
                  .mapIt(it.name).join(", ")
  var d = tabella(kinds).data
  d.addColumn("who", who.mapIt(toValue(it)))
  let t = tabella(d, rownameCol = "kind", groupnameCol = "class"):
    optCssTheme()
    fmtTf ["p", "l", "u"], tfStyle = "circles"
    colsLabel:
      p: "power"
      l: "legitimacy"
      u: "urgency"
      who: "in the garden"
    colsLabelRotate ["p", "l", "u"], dir = "slanted"
    colsAlign alCenter, ["p", "l", "u"]
    colsWidth:
      p: "28px"
      l: "28px"
      u: "28px"
  nbTable t

nbNote("""
The eight kinds are typed in; the `who` column is computed by matching each stakeholder's power
(4 or more), legitimacy and urgency against the row. The salience classes are row groups, and
`fmtTf` shows a true as a full circle and a false as an empty one.
""", nkCode)

nbText: """
## Where they are, where they should be

The engagement assessment matrix of the *PMBOK Guide* has one row per stakeholder and five
columns, from *unaware* to *leading*; a C marks where they are now, a D where the project needs
them. A row where C and D differ is work to do, and the distance says how much. It is the
stakeholder's version of *what was promised, what was done*.
"""

nbShowCode:
  var ecols = @[("kind", people.mapIt(toValue(it.kind))), ("name", people.mapIt(toValue(it.name)))]
  for i, l in levels:
    ecols.add (l, people.mapIt(toValue(
      if it.now == i and it.wanted == i: "CD" elif it.now == i: "C" elif it.wanted == i: "D" else: "")))
  ecols.add ("gap", people.mapIt(toValue(it.wanted - it.now)))
  let t = tabella(toTableData(ecols), rownameCol = "name", groupnameCol = "kind"):
    optCssTheme()
    colsAlign alCenter, @levels
    colsLabelRotate @levels, dir = "slanted"
    colsWidth levels.mapIt((it, "34px"))
    fmt "gap", proc (v: Value): string = (if v.toFloat > 0: "+" & $int(v.toFloat) else: "")
    tabStyleBody style.fill(tint("--secondary-soft")), columns = @levels, values = ["C"]
    tabStyleBody style.fill(tint("--primary-soft")), columns = @levels, values = ["D", "CD"]
    tabStyleBody style.fill(tint("--warning-soft")), columns = "gap", fn = proc (v: Value): bool = v.toFloat >= 2
    tabStubhead "stakeholder"
  nbTable t

nbNote("""
Five columns, one per level, from the register's two numbers (`now` and `wanted`); the gap is
their difference, marked when it is two levels or more.
""", nkCode)

nbText: """
## Which table for which job

Back to the two jobs. Each design above is one way to look at the same data; the table below
says which job each one does, since when, and what tabelline still lacks for it. The PowerPoint
column says whether the design fits on a slide as it is.
"""

nbShowCode:
  type Use = tuple[job, design, since, fit, gap: string]
  let uses: seq[Use] = @[
    ("Activities", "Work breakdown", "1962", "the first page of a plan", "a tree from codes (here made by hand)"),
    ("Activities", "Bars on a calendar", "1912", "the status slide", "a verb for bars from a first and last date"),
    ("Activities", "Harmonogram", "1896", "a phone, a tall slide", "none"),
    ("Activities", "Promised and done", "1910s", "the progress meeting", "none"),
    ("Activities", "Milestones and their drift", "1970s?", "the steering committee", "a line chart of the forecasts (a nanoplot per milestone)"),
    ("Activities", "Critical path", "1957", "planning, not slides", "dates instead of week numbers"),
    ("Activities", "Three estimates", "1958", "planning, not slides", "none"),
    ("Activities", "Activities against activities", "1981", "finding loops", "none"),
    ("Activities", "Earned value", "1967", "the budget review", "a summary that is a ratio of sums"),
    ("Both", "Who does what (RACI)", "1970s", "the kick-off", "none"),
    ("Stakeholders", "Register", "1984", "an annex, too long for a slide", "filters and sorting when it is long"),
    ("Stakeholders", "Power and interest", "1991", "one slide, the key one", "a 2 × 2 grid with lists in cells"),
    ("Stakeholders", "Salience", "1997", "a workshop", "none"),
    ("Stakeholders", "Engagement, now and wanted", "2013", "the stakeholder plan", "none")]
  let t = tabella(uses, rownameCol = "design", groupnameCol = "job"):
    optCssTheme()
    colsLabel:
      fit: "where it fits"
      gap: "what tabelline lacks"
    tabStyleBody style.text(color = tint("--muted")), columns = "gap", values = ["none"]
  nbTable t

nbText: """
For tracking the activities, three tables carry most of the weight: *promised and done* (the
Gantt chart as Gantt meant it, not only a plan), the milestones with their drift, and RACI for
the kick-off. For many stakeholders, the register is the one source and the rest is made from
it: the power-interest grid for the slide, the engagement matrix for the plan, and the salience
table to settle who gets attention when there is too little of it. Keeping one register and
generating the rest is what a table library does well, and a spreadsheet does badly.

## What the story will need

What the designs above found missing in tabelline, for the build thread:

1. **Bars from dates.** Every chart here turns a first and a last week into cells by hand
   (`weekData`). A verb that takes two date columns and a time step (day, week, month) would
   make the calendar, the spanners and today's mark: the Gantt chart as one line.
2. **Dates, not week numbers.** The network and the milestones count weeks; a real plan has
   dates, holidays and a calendar. The arithmetic is small, the formats exist (`fmtDate`).
3. **A grid of lists.** The power-interest grid puts many names in one cell. It works as
   Markdown text, but a cell that holds a list, one name per line, would read better and go to
   PowerPoint as lines.
4. **Long registers.** Sixteen stakeholders fit; two hundred do not. A long register wants
   sorting, filtering and folding by group, in the page and in the slide (one slide per group).
5. **On a slide.** All of these must go through the PowerPoint writer: fills by value, slanted
   labels, the dotted box of today. Checking them there is the first job of the story.

## Sources

The history comes from these sources:
the Wikipedia articles linked in [the table](#the-story-in-one-table) (Priestley's
[Chart of Biography](https://en.wikipedia.org/wiki/A_Chart_of_Biography),
[Karol Adamiecki](https://en.wikipedia.org/wiki/Karol_Adamiecki),
[Gantt chart](https://en.wikipedia.org/wiki/Gantt_chart),
[Henry Gantt](https://en.wikipedia.org/wiki/Henry_Gantt),
[Wallace Clark](https://en.wikipedia.org/wiki/Henry_Wallace_Clark),
[PERT](https://en.wikipedia.org/wiki/Program_evaluation_and_review_technique),
[work breakdown structure](https://en.wikipedia.org/wiki/Work_breakdown_structure),
[earned value](https://en.wikipedia.org/wiki/Earned_value_management),
[responsibility assignment matrix](https://en.wikipedia.org/wiki/Responsibility_assignment_matrix),
[design structure matrix](https://en.wikipedia.org/wiki/Design_structure_matrix),
[stakeholder analysis](https://en.wikipedia.org/wiki/Stakeholder_analysis));
Kelley and Walker's own account, [The origins of CPM](https://www.pmi.org/learning/library/origins-cpm-personal-history-3762) (PMI);
[line of balance](https://www.pmi.org/learning/library/line-balance-scheduling-technique-progress-2078) (PMI);
Patrick Weaver's [Henry L. Gantt, 1861–1919: debunking the myths](https://pmworldlibrary.net/wp-content/uploads/2013/01/PMWJ5-Dec2012-WEAVER-Henry-Gantt-Debunking-Myths-Featured-Paper.pdf)
and [The origins of bar charting](https://mosaicprojects.com.au/PDF_Papers/P182_The_origins_of_bar_charting.pdf);
Clark's [*The Gantt Chart*](https://archive.org/details/cu31924004570853) (archive.org);
Wikipedia's [Hoover Dam](https://en.wikipedia.org/wiki/Hoover_Dam);
NASA's [Phillips report](https://www.nasa.gov/history/phillips-report/);
Mitchell, Agle and Wood, [Toward a theory of stakeholder identification and salience](https://doi.org/10.5465/amr.1997.9711022105).
Sapolsky's *The Polaris System Development* (Harvard, 1972) is quoted from
[its summary](https://ssp.mit.edu/publications/1972/the-polaris-system-development) at MIT.
"""

nbSave
