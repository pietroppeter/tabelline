## A project plan as a Gantt chart, in a tabelline table: a prototype (invented data).
## `nim r tools/gantt/gantt.nim` writes tools/gantt/out/index.html (the Munari page, which shows
## the data, the code and the table at each step) and tools/gantt/out/gantt.pptx (one slide, a
## native PowerPoint table, from the pptx draft).
import std/[os, sugar, times, strutils, sequtils, tables, math]
import nimib
import tabelline, tabelline/[nimib, pptx]
import ../../docs/blocchi

let here = currentSourcePath().parentDir
nbInit
nb.doc.filename = here / "out" / "index.html"
nb.useTabelline(nome = "tabelline", title = "A Gantt chart in a table")

nbTitolo "A prototype · tabelline", "A Gantt chart in a table", """
A project plan, in weeks, made with tabelline: row groups for the streams, a spanner for each
month, a filled cell for each week of an activity, a dashed line for today, milestones and
deliverables, and the notes of the week under it. The project is fictional: a garden on the Moon. The page goes from the data to
the chart in six steps, with the code of each and the table it makes.
"""

nbNota("""
Green cards like this one are about the code. Every block of code on this page ran when the page
was built, in this order: the tables under them are what it made. The same table goes to a
PowerPoint slide at the end, with the draft PowerPoint output of tabelline (#57).
""", nkCode, "Reading the code")

nbIndice()

nbText: """
## The data

A plan is a list of activities. Each belongs to a stream and runs from a first week to a last
week, both included: weeks of the year, as ISO counts them (week 1 is the week with 4 January).
That is all the data there is, and it is a table already.
"""

nbCode:
  type Activity = tuple[stream, activity: string, first, last: int]

  let plan: seq[Activity] = @[
    ("Seeds", "Pick twelve hardy varieties", 14, 22),
    ("Seeds", "Germination trials in low gravity", 18, 30),
    ("Seeds", "Seed vault packing", 28, 34),
    ("Habitat", "Greenhouse dome design", 15, 24),
    ("Habitat", "Soil from regolith", 20, 36),
    ("Habitat", "Water recycling loop", 25, 39),
    ("Habitat", "Light and heat tests", 31, 37),
    ("Rover", "Rover chassis", 16, 26),
    ("Rover", "Planting arm", 22, 33),
    ("Rover", "Field trials in the desert", 30, 39),
    ("Crew", "Gardener training", 19, 39),
    ("Crew", "Recipe book for the first harvest", 33, 39)]

nbTable tabella(plan, rownameCol = "activity", groupnameCol = "stream")
  .colsLabel({"first": "first week", "last": "last week"})
  .optCssTheme()

nbNota("""
`tabella` takes a sequence of tuples (or objects): one column per field. `rownameCol` puts the
activity in the stub, the column on the left, and `groupnameCol` groups the rows by stream, in
the order they come.
""", nkCode)

nbText: """
## One column per week

A Gantt chart turns the two numbers of each activity into a row of weeks: for each week from 14
to 39, is the activity running? So the table of the chart has one column per week, `W14` to
`W39`, holding 1 when the activity runs that week and 0 when it does not.
"""

nbCode:
  const firstWeek = 14
  const lastWeek = 39
  func wk(w: int): string = "W" & $w
  let weekCols = toSeq(firstWeek .. lastWeek).mapIt(wk(it))

  var columns: seq[(string, seq[Value])] = @[
    ("stream", plan.mapIt(toValue(it.stream))),
    ("activity", plan.mapIt(toValue(it.activity)))]
  for w in firstWeek .. lastWeek:
    columns.add (wk(w), plan.mapIt(toValue(if w in it.first .. it.last: 1 else: 0)))
  let data = toTableData(columns)

  let step2 = tabella(data, rownameCol = "activity", groupnameCol = "stream")

nbTable step2.optCssTheme().tabOptions(tableFontSize = "12px", dataRowPadding = "2px")

nbNota("""
`toTableData` builds a table from columns given by name, each a sequence of `Value`s: here 2
columns of text and 26 of numbers, made in a loop because their names are made in a loop too.
""", nkCode)

nbText: """
## Months and weeks

The numbers are not for reading: they say which cells to fill. So a formatter hides them. The
column labels lose their `W`, and the weeks go under the month they belong to: a week belongs
to the month of its Thursday, as ISO weeks belong to the year of their Thursday.
"""

nbCode:
  const year = 2031
  proc monday(w: int): DateTime =
    ## The Monday of ISO week `w` of `year`.
    let jan4 = dateTime(year, mJan, 4, zone = utc())
    jan4 - days(ord(jan4.weekday)) + weeks(w - 1)
  proc monthOf(w: int): Month = (monday(w) + days(3)).month

  var months: OrderedTable[Month, seq[string]]   # the week columns of each month
  for w in firstWeek .. lastWeek: months.mgetOrPut(monthOf(w), @[]).add wk(w)

  var step3 = step2
    .fmt(cols(weekCols), (v: Value) => "")
    .colsLabelWith(cols(weekCols), (s: string) => s[1 .. ^1])
    .colsWidth(weekCols.mapIt((it, "22px")))
    .tabStubhead("Stream and activity")
    .tabOptions(tableFontSize = "13px", dataRowPadding = "3px",
                dataRowPaddingHorizontal = "0px", columnLabelsFontSize = "70%")
  for m, ws in months:
    step3 = step3.tabSpanner(toText(($m).toUpperAscii), cols(ws))

  # every row the same height, on a phone too: one line of text, 22px high
  let oneLine = style.css("height: 22px; line-height: 22px; padding-top: 0; " &
                          "padding-bottom: 0; white-space: nowrap")
  step3 = step3.tabStyle(oneLine, loc.stub(), loc.body(), loc.rowGroups())
  step3 = step3.tabStyle(style.css("padding-left: 0; padding-right: 0"),
                         loc.columnLabels(cols(weekCols)))

nbTable step3

nbNota("""
`fmt` with a proc of a value gives the text of each cell: an empty one. `tabSpanner` puts a label
over some columns, one call per month. The options make the table small: a 13px font, no
padding at the sides of a cell. Rows of a chart must all be the same height, or the bars do not
line up: `style.css` sets the height of every cell of the stub, the body and the group labels to
22px, with one line of text (`white-space: nowrap`), so a long activity does not wrap on a
phone and make its row taller.
""", nkCode)

nbText: """
## The bars

Now the colours. Each stream has one; a week before today is filled in full colour, a week from
today on in a lighter one, so the plan shows what is done and what is to come. Today, in
this plan, is 2 July 2031: week 27.
"""

nbCode:
  let today = dateTime(2031, mJul, 2, zone = utc())
  let todayWeek = getIsoWeekAndYear(today).isoweek.int
  let streams = {"Seeds": "#00897B", "Habitat": "#C2185B", "Rover": "#E09F00",
                 "Crew": "#455A64"}.toOrderedTable

  proc lighter(hex: string, k = 0.55): string =
    ## `hex` mixed with white.
    result = "#"
    for i in 0 .. 2:
      let c = parseHexInt(hex[1 + 2*i .. 2 + 2*i])
      result.add toHex(int(c.float + (255 - c).float * k), 2)
  proc colorOf(stream: string, w: int): string =
    if w < todayWeek: streams[stream] else: lighter(streams[stream])

  var step4 = step3
  for i, a in plan:
    for w in a.first .. a.last:
      step4 = step4.tabStyle(style.fill(colorOf(a.stream, w)), loc.body(cols(wk(w)), rows = i))
  for s, color in streams:
    step4 = step4.tabStyle(style.text(color = color, weight = "bold"), loc.rowGroups(s))

nbTable step4

nbNota("""
`tabStyle(style, location)` adds CSS to the cells at a location: here one cell at a time,
`loc.body(column, rows = i)`, so a loop over the weeks of each activity. The fill of a cell is
the bar. `loc.rowGroups(s)` is the label of a group: the stream's name, in its colour.
""", nkCode)

nbText: """
## Today and the notes

Two last touches: a solid line starts each month and a dashed line marks today's week. Then the
notes of the week go under the table.
"""

nbCode:
  var t = step4
    .tabHeader(md("Plan and progress at " & today.format("d MMMM")))
  for m, ws in months:
    t = t.tabStyle(style.borders({sLeft}, color = "#9A9A9A", weight = "1px"),
                   loc.body(cols(ws[0])))
  let now = cols(wk(todayWeek))
  t = t
    .tabStyle(style.borders({sLeft}, color = "#1A1A1A", style = "dashed", weight = "2px"),
              loc.body(now), loc.columnLabels(now))
    .tabStyle(style.text(color = "#1A1A1A", weight = "bold"), loc.columnLabels(now))

  t = t
    .tabSourceNote(md("**Key events of the week.** The first seeds sprouted in the low-gravity " &
                      "trials; the dome design is signed off."))
    .tabSourceNote(md("In progress: soil from regolith, waiting for the second batch of samples; " &
                      "the planting arm is being assembled."))
    .tabSourceNote(md("Proposed: the crew visits the desert test field in August."))

nbTable t

nbNota("""
The lines are borders on the left of a column: `style.borders({sLeft}, ...)`, solid for a
month, dashed for today, on the body and on today's label. `tabSourceNote` adds a note under the
table; `md` lets it use Markdown.
""", nkCode)

nbText: """
## Milestones and deliverables

A plan also has moments, not only spans. A **milestone** is a moment of the project, such as a
first sprout, marked ◆ in the week it happens. A **deliverable** is something handed over, such
as a drawing or a recipe book, marked with its number (D1, D2, ...) in the week it is due. Both
sit in the row of the activity they belong to, and a key under the table names them.
"""

nbCode:
  type Mark = tuple[activity: string, week: int, label: string]
  let milestones: seq[Mark] = @[
    ("Germination trials in low gravity", 24, "first sprout"),
    ("Greenhouse dome design", 20, "dome concept chosen"),
    ("Field trials in the desert", 36, "the rover drives 10 km"),
    ("Gardener training", 39, "crew certified")]
  let deliverables: seq[Mark] = @[
    ("Pick twelve hardy varieties", 22, "seed list"),
    ("Greenhouse dome design", 24, "dome drawings"),
    ("Rover chassis", 26, "rover chassis"),
    ("Soil from regolith", 36, "soil recipe"),
    ("Recipe book for the first harvest", 39, "recipe book")]

  proc rowOf(activity: string): int = plan.mapIt(it.activity).find(activity)
  proc mark(t: sink Tabella, m: Mark, text: string): Tabella =
    let i = rowOf(m.activity)
    let fill = colorOf(plan[i].stream, m.week)
    t.fmt(cols(wk(m.week)), (v: Value) => text, rows = i)
     .tabStyle(style.text(color = idealTextColor(fill), weight = "bold", size = "80%"),
               loc.body(cols(wk(m.week)), rows = i))

  var key = "**Milestones** ◆ "
  for m in milestones:
    t = t.mark(m, "◆")
  key.add milestones.mapIt(it.label & " (week " & $it.week & ")").join(", ")
  key.add ". **Deliverables** "
  for k, d in deliverables:
    t = t.mark(d, "D" & $(k + 1))
    key.add (if k > 0: ", " else: "") & "D" & $(k + 1) & " " & d.label
  t = t.tabSourceNote(md(key & "."))

nbTable t

nbNota("""
A mark is the text of one cell: `fmt` again, on one column and one row, which wins over the
format of step 3 because it comes later (the last format of a cell is the one used). Its colour
is `idealTextColor` of the fill: white on a dark fill, black on a light one. The key is one more
source note, written in a loop as the marks are placed.
""", nkCode)

nbText: """
## On a slide

The same table goes to PowerPoint as a native table, which can be edited there: one call writes
a .pptx file with one slide. The fills, the borders (the dashed one too), the spanners, the
groups and the notes come through.

A slide is read from across a room, so its table needs bigger text than a page: the body at
18px (13.5 points on the slide, against 13px on the page), the notes as big as the body, the
weeks' numbers a little smaller, wider week columns so their numbers do not wrap, and each row
taller to hold them. A slide is 540 points high, and these sizes are about
as big as the chart can be and still fit: the PowerPoint writer makes a wide table smaller to fit
the slide, but not a tall one.
"""

nbCode:
  let slide = t
    .tabOptions(tableFontSize = "18px", columnLabelsFontSize = "70%",
                sourceNotesFontSize = "100%", headingTitleFontSize = "130%")
    .tabStyle(style.css("height: 24px; line-height: 24px"),
              loc.stub(), loc.body(), loc.rowGroups())
    .colsWidth(weekCols.mapIt((it, "26px")))
  createDir here / "out"
  slide.savePptx(here / "out" / "gantt.pptx")

nbTable slide

nbText: """
## After Clark, 1922

Wallace Clark's charts were drawn by hand, in ink, and kept up to date every week. Each row has
two lines. A **thin line** across a week says work is planned that week. A **thick line** under
it says how much work is done, all of it laid end to end from the start, so it can end before
today (behind) or after it (ahead). An open **V** over today's week shows where the thick line
should have reached. Here the same plan is drawn that way, in one ink, with the work done by
today invented as weeks of work.
"""

nbCode:
  const ink = "#1A1A1A"
  let done = {"Pick twelve hardy varieties": 9.0, "Germination trials in low gravity": 7.0,
              "Greenhouse dome design": 10.0, "Soil from regolith": 5.5,
              "Water recycling loop": 2.5, "Rover chassis": 11.0, "Planting arm": 3.0,
              "Gardener training": 8.0}.toTable

  proc append(suffix: string): proc (s: string): string =
    ## A proc that adds `suffix` to a text (a proc of its own, so each row keeps its suffix).
    result = (s: string) => s & suffix

  func line(top, height: int, width = 1.0): string =
    ## A horizontal line in a cell, `width` of it from the left, as a CSS background.
    "linear-gradient(" & ink & ", " & ink & ") left " & $top & "px / " &
      $int(width * 100) & "% " & $height & "px no-repeat"

  var clark = step3
    .tabHeader("Plan and progress at 2 July", "After Wallace Clark's Gantt progress chart")
    .tabStyle(style.css("font-weight: bold"), loc.columnLabels(cols(wk(todayWeek))))
    .textTransform((s: string) => "V", loc.columnLabels(cols(wk(todayWeek))))
    .colsWidth(weekCols.mapIt((it, "18px")))
  for i, a in plan:
    let worked = done.getOrDefault(a.activity, 0.0)
    let planned = max(0, min(a.last, todayWeek - 1) - a.first + 1)   # weeks planned by today
    for w in a.first .. a.last:
      var lines = @[line(4, 1)]                             # planned: the thin line
      let k = float(w - a.first)
      if worked > k: lines.add line(10, 6, min(1.0, worked - k))   # done: the thick line
      clark = clark.tabStyle(style.css("background: " & lines.join(", ")),
                             loc.body(cols(wk(w)), rows = i))
    if planned > 0 or worked > 0:
      let gap = worked - planned.float
      let weeks = if gap == round(gap): $int(abs(gap)) else: formatFloat(abs(gap), ffDecimal, 1)
      let status = if gap == 0: "on time" elif gap < 0: weeks & " wk behind"
                   else: weeks & " wk ahead"
      clark = clark.textTransform(append(" · " & status), loc.stub(rows = i))
  clark = clark.tabStyle(style.text(color = ink, weight = "bold"), loc.rowGroups())

nbTable clark

nbNota("""
The lines are CSS backgrounds: `linear-gradient` of one colour is a plain rectangle, placed at a
height in the cell and given a width, so one cell can hold a thin line and a part of a thick one
(`style.css("background: ...")`). The V is the label of today's column, changed with
`textTransform`, which also writes the state of each activity after its name: `append` makes
a proc for each row, because a closure made in a loop sees the loop's last values (Nim
closures capture variables, not their values). CSS backgrounds
have no PowerPoint equivalent: this version stays in the page.
""", nkCode)

nbText: """
## After Tufte

Edward Tufte's advice for project graphics: take away what is not data, and put the data in
words where it helps. So: no grid, bars as thin strokes, the dates of each activity written
after its name, today as a hairline, and what moved since last week's plan shown in place: the
weeks an activity was pushed are a paler stroke, and its name says by how much.
"""

nbCode:
  let lastWeekPlan = {"Germination trials in low gravity": 28, "Soil from regolith": 33,
                      "Planting arm": 31, "Recipe book for the first harvest": 37}.toTable

  func stroke(color: string): string =
    "linear-gradient(" & color & ", " & color & ") left center / 100% 6px no-repeat"
  proc dates(a: Activity): string =
    monday(a.first).format("d MMM") & "–" & (monday(a.last) + days(4)).format("d MMM")

  var tufte = step3
    .tabHeader("Plan and progress at 2 July", "After Edward Tufte: less grid, more data")
    .optTableLines("none")
    .colsWidth(weekCols.mapIt((it, "18px")))
    .tabStyle(style.text(color = ink, weight = "bold"), loc.columnLabels(now))
  for i, a in plan:
    let was = lastWeekPlan.getOrDefault(a.activity, a.last)
    for w in a.first .. a.last:
      let c = if w > was: lighter(streams[a.stream], 0.75) else: colorOf(a.stream, w)
      tufte = tufte.tabStyle(style.css("background: " & stroke(c)), loc.body(cols(wk(w)), rows = i))
    let moved = if was != a.last: " (+" & $(a.last - was) & " wk)" else: ""
    tufte = tufte.textTransform(append(" · " & dates(a) & moved), loc.stub(rows = i))
  for s, color in streams:
    tufte = tufte.tabStyle(style.text(color = color, weight = "bold"), loc.rowGroups(s))
  tufte = tufte.tabStyle(style.borders({sLeft}, color = ink, weight = "1px"), loc.body(now))
  for m in milestones:
    tufte = tufte.fmt(cols(wk(m.week)), (v: Value) => "◆", rows = rowOf(m.activity))
      .tabStyle(style.text(size = "10px"), loc.body(cols(wk(m.week)), rows = rowOf(m.activity)))
  tufte = tufte.tabSourceNote(md("◆ " & milestones.mapIt(it.label).join(", ") &
                                 ". A paler stroke: weeks added since last week's plan."))

nbTable tufte

nbNota("""
`optTableLines("none")` takes every rule away; the only line left is today's, a 1px border. A
stroke is the same CSS background as Clark's lines, 6px high and centred. The dates come from
the week numbers (`monday` of the first week to the Friday of the last), and last week's plan is
a small table of the activities that moved.
""", nkCode)

nbText: """
## Where the ideas come from

The chart borrows from older and newer charts. A short selection, and what this page took from
each:

- **Wallace Clark, *The Gantt Chart: A Working Tool of Management* (1922).** The book that spread
  Henry Gantt's charts, with dozens of real ones from factories and offices
  ([on archive.org](https://archive.org/search?query=%22gantt+chart%22+wallace+clark)). Clark
  draws the work planned and the work done in the same row, and marks today at the top of the
  chart: here, a full colour for the weeks done, a lighter one for the weeks to come, and the
  dashed line.
- **Edward Tufte's forum thread *Project Management Graphics (or Gantt Charts)*.** Many
  redesigns of real plans, all asking for less grid and more data: here, no rule between weeks,
  a thin one between months, and no numbers in the cells.
- **Mermaid's [gantt syntax](https://mermaid.js.org/syntax/gantt.html).** A plan written as
  text: sections, tasks with a start and an end, milestones. The data of this page has the same
  shape (streams, activities with a first and a last week), and the milestones come from there.
- **Spreadsheet Gantt charts,** made with conditional formatting: a cell per week, filled or
  not. That is what this page does, with a table instead of a sheet. The
  [Gantt chart of Vega-Lite](https://vega.github.io/vega-lite/examples/bar_gantt.html) is the
  other way, with bars drawn on an axis.
"""

nbText: """
## What is missing

- **Styling one cell at a time.** Half of the code above is loops of `tabStyle` over cells. A
  verb that fills cells by a rule (like `dataColor`, but with a function from a cell to a
  colour) would make each of those loops one line.
- **A phone.** 26 weeks do not fit 390 pixels: the table scrolls sideways.
"""

nbSave
