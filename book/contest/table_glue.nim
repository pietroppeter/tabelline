import tabbook
bookInit()

nbText: "# Guide to table making, with table.glue"

attribution contestEntry("rounding, tabulation, and inline presentation with table.glue",
  "https://github.com/bcjaeger/table.glue/blob/master/vignettes/table_guide.Rmd",
  "Byron Jaeger (2020)", "MIT", "https://github.com/bcjaeger/table.glue/blob/master/LICENSE.md",
  "This is the package's vignette *Guide to table making*, up to the table; its last part, " &
  "about inline objects (R lists for the text of a report), is about R, not tables, and is left " &
  "out. The data are `dplyr::starwars`, cut as the vignette does, in `book/data/contest/`.")

nbText: """
## Why this guide?

I have made a lot of tables and, if I'm being honest, they are not much fun. The primary reason I wrote `table.glue` was to help abstract away some of the really tedious aspects of dealing with tables, but there is also a basic system that `table.glue` fits into to make tables far less painful. I have boiled that system down into three main ideas

- Structuring data for a table

- Making table values

- Making an inline object

If you find yourself working on a manuscript with lots of tables, I think you will find this framework to be extremely helpful.

## Make the table data
"""

tabs """
import pandas as pd
from great_tables import GT, md

# dplyr's starwars, cut as in the R tab: no missing values, blue, brown or hazel eyes
starwars = pd.read_csv("../data/contest/starwars.csv", comment="#")

quartiles = {"lwr": 0.25, "est": 0.50, "upr": 0.75}
starwars_smry = starwars.groupby(["sex", "eye_color"]).agg(
    **{f"{col}_{q}": (col, lambda x, p=p: x.quantile(p))
       for col in ["height", "mass"] for q, p in quartiles.items()}
).reset_index()
""", """
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(gt)
library(table.glue)

starwars_smry <- na.omit(starwars) %>%
  filter(eye_color %in% c('blue', 'brown', 'hazel')) %>%
  group_by(sex, eye_color) %>%
  summarize(
    across(
      c(height, mass),
      .fns = list(
        lwr = ~quantile(.x, probs = 0.25),
        est = ~quantile(.x, probs = 0.50),
        upr = ~quantile(.x, probs = 0.75)
      )
    )
  )
""":
  nbCode:
    import tabelline
    import std/[algorithm, math, strutils, tables]

    # dplyr's starwars, cut as in the R tab: no missing values, blue, brown or hazel eyes
    const starwarsCsv = staticRead("../data/contest/starwars.csv")
    let starwars = parseCsv(starwarsCsv, comment = "#")

    proc quantile(xs: seq[float], p: float): float =
      ## R's default quantile (type 7): between the two values around p·(n - 1).
      let s = xs.sorted
      let h = p * float(s.high)
      let lo = int(floor(h))
      s[lo] + (h - float(lo)) * (s[min(lo + 1, s.high)] - s[lo])

    var groups: OrderedTable[(string, string), array[2, seq[float]]]
    for i in 0 ..< starwars.nrows:
      let key = ($starwars["sex", i], $starwars["eye_color", i])
      groups.mgetOrPut(key, [newSeq[float](), newSeq[float]()])[0].add starwars["height", i].toFloat
      groups[key][1].add starwars["mass", i].toFloat
    groups.sort(proc (a, b: auto): int = cmp(a[0], b[0]))  # as group_by: by sex, then eye color

tabelline """
tabelline is for the table, not the data: there is no `group_by` or `quantile` (it reads no data
frames yet), so the groups are a Nim table and the quartiles a short proc, R's default way to
compute them.
"""

nbText: """
## Make the table values

Tabulated data should provide both a point estimate and a measure of uncertainty that goes along with the estimate, e.g. a 95% confidence interval. `table_glue()` is a nice function for putting together a point estimate and confidence interval. I use a magnitude based rounding specification to keep presentations consistent between height and mass.
"""

tabs """
def table_value(x):
    # half to even (as Python's round), 2 digits under 1, 1 under 100, then none
    digits = 2 if abs(x) < 1 else 1 if abs(x) < 100 else 0
    return f"{round(x, digits):.{digits}f}"

def glue(row, col):
    est, lwr, upr = (table_value(row[f"{col}_{q}"]) for q in ["est", "lwr", "upr"])
    return f"{est} ({lwr} - {upr})"

starwars_tbl = starwars_smry[["sex", "eye_color"]].assign(
    tbv_height=starwars_smry.apply(glue, axis=1, col="height"),
    tbv_mass=starwars_smry.apply(glue, axis=1, col="mass"),
)
starwars_tbl
""", """
rspec <- round_spec() %>%
  round_half_even() %>%
  round_using_magnitude(breaks = c(1, 10, 100, Inf),
                        digits = c(2, 1,  1, 0))

names(rspec) <- paste('table.glue', names(rspec), sep = '.')

options(rspec)

starwars_tbl <- starwars_smry %>%
  transmute(
    sex,
    eye_color,
    tbv_height = table_glue("{height_est} ({height_lwr} - {height_upr})"),
    tbv_mass = table_glue("{mass_est} ({mass_lwr} - {mass_upr})")
  )
starwars_tbl
""":
  nbCode:
    proc tableValue(x: float): string =
      ## Half to even, 2 digits under 1, 1 under 100, then none: the vignette's rounding.
      let digits = if abs(x) < 1: 2 elif abs(x) < 100: 1 else: 0
      let y = x * 10.0 ^ digits
      var r = round(y)
      if abs(y - trunc(y)) == 0.5 and r mod 2 != 0: r -= copySign(1.0, y)
      if digits == 0: $int(r) else: formatFloat(r / 10.0 ^ digits, ffDecimal, digits)

    proc glue(xs: seq[float]): string =
      tableValue(xs.quantile(0.5)) & " (" & tableValue(xs.quantile(0.25)) & " - " &
        tableValue(xs.quantile(0.75)) & ")"

    type Row = object
      sex, eye_color, tbv_height, tbv_mass: string

    var rows: seq[Row]
    for key, values in groups:
      rows.add Row(sex: key[0], eye_color: key[1],
                   tbv_height: glue(values[0]), tbv_mass: glue(values[1]))
    let starwarsTbl = toTableData(rows)
    nbTable tabella(starwarsTbl)

tabelline """
table.glue's rounding (half to even, digits by magnitude) is a short proc here. tabelline's
`fmtNumber` rounds a whole column to the same digits, as gt's `fmt_number()`; rounding by
magnitude, and gluing three numbers into one cell, are done in the data, as the vignette does.
"""

nbText: """
## Make the table

Keeping your data in a tidy table format makes it fairly straightforward to make a publication ready `gt` table. Most of the code is spent on re-naming things and labeling, which is how it should be.
"""

tabs """
(
    GT(
        starwars_tbl.replace({
            "sex": {"female": "Female characters", "male": "Male characters"},
            "eye_color": {"blue": "Blue", "brown": "Brown", "hazel": "Hazel"},
        }),
        groupname_col="sex",
        rowname_col="eye_color",
    )
    .cols_label(tbv_height="Height, cm", tbv_mass="Mass, kg")
    .cols_align("center")
    .tab_stubhead(label="Eye color")
    .tab_spanner(label="Median (25th, 75th percentile)", columns=["tbv_height", "tbv_mass"])
    .tab_source_note(md("For more on these data, see `?dplyr::starwars`"))
)
""", """
starwars_tbl %>%
  mutate(
    sex = recode(sex,
                 'female' = 'Female characters',
                 'male'   = 'Male characters'),
    eye_color = recode(eye_color,
                       blue  = 'Blue',
                       brown = 'Brown',
                       hazel = 'Hazel')
  ) %>%
  gt(groupname_col = 'sex',  rowname_col = 'eye_color') %>%
  cols_label(tbv_height = 'Height, cm', tbv_mass = 'Mass, kg') %>%
  cols_align('center') %>%
  tab_stubhead(label = 'Eye color') %>%
  tab_spanner(label = 'Median (25th, 75th percentile)',
              columns = starts_with('tbv')) %>%
  tab_source_note(md('For more on these data, see `?dplyr::starwars`'))
""":
  nbCode:
    let
      sexes = {"female": "Female characters", "male": "Male characters"}.toTable
      eyes = {"blue": "Blue", "brown": "Brown", "hazel": "Hazel"}.toTable

    var named = rows
    for r in named.mitems:
      r.sex = sexes[r.sex]
      r.eye_color = eyes[r.eye_color]

    let starwarsGt = tabella(toTableData(named), groupnameCol = "sex", rownameCol = "eye_color"):
      colsLabel:
        tbv_height: "Height, cm"
        tbv_mass: "Mass, kg"
      colsAlign alCenter
      tabStubhead "Eye color"
      tabSpanner "Median (25th, 75th percentile)", columns = startsWith("tbv")
      tabSourceNote md("For more on these data, see `?dplyr::starwars`")
    nbTable starwarsGt

tabelline """
Everything this table needs is in tabelline 0.1: row groups and a stub from the data
(`groupnameCol`, `rownameCol`), labels, alignment, a stub head, a spanner chosen with
`startsWith`, and a source note in Markdown. The vignette goes on to make an *inline object*,
an R list of the same values for the text of a report: that is about R, not tables, and is not
ported.
"""

bookSave()
