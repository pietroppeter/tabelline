import tabbook
bookInit()

nbText: "# Formatting Values"

attribution gtGuide("Formatting Values", "basic-formatting", "")

nbText: """
The values within the table body, specifically those within the body cells, can be formatted with a large selection of `fmt_*()` methods like `GT.fmt_number()`, `GT.fmt_integer()`, `GT.fmt_scientific()`, and more. Let's use a portion of the `exibble` dataset and introduce some formatting to the cell values. First, we'll generate the basic GT object and take a look at the table without any cell formatting applied.
"""

tabs """
from great_tables import GT
from great_tables.data import exibble
from great_tables import vals

gt_ex = GT(exibble[["num", "date", "time", "currency"]].head(5))

gt_ex
""", """
library(gt)
library(dplyr)

gt_ex <- exibble |> select(num, date, time, currency) |> slice_head(n = 5) |> gt()

gt_ex
""":
  nbCode:
    import tabelline, tabelline/datasets, gtdata

    var gtEx = tabella(exibble().select(["num", "date", "time", "currency"]).head(5))

    nbTable gtEx

tabelline """
`select` and `head` are the book's helpers (`gtdata`) for what pandas does here: tabelline's
`TableData` has no verbs of its own. Here `gtEx` is a `var`, so the next
examples can change it in place, as the guide does with `gt_ex = gt_ex.fmt_...`.
"""

nbText: """
The `num` column contains both small and much larger numbers. We can use the `GT.fmt_number()` method to obtain formatted values have a fixed level of decimal precision and grouping separators. At the same time, we'll format the numeric values in `currency` column to get monetary values.
"""

tabs """
gt_ex = gt_ex.fmt_number(columns="num", decimals=2).fmt_currency(columns="currency")

gt_ex
""", """
gt_ex <- gt_ex |> fmt_number(columns = num, decimals = 2) |> fmt_currency(columns = currency)

gt_ex
""":
  nbCode:
    gtEx = tabella(gtEx):
      fmtNumber "num", decimals = 2
      fmtCurrency "currency"

    nbTable gtEx

nbText: """
Dates and times can be formatted as well. As long as they are in ISO 8601 form, the `GT.fmt_date()` and `GT.fmt_time()` methods can be used to format such values. These methods have corresponding `date_style=` and `time_style=` arguments that accept a number of keywords that act as preset formatting styles.
"""

tabs """
gt_ex = (
    gt_ex.fmt_date(columns="date", date_style="m_day_year")
    .fmt_time(columns="time", time_style="h_m_p")
)

gt_ex
""", """
gt_ex <- gt_ex |>
  fmt_date(columns = date, date_style = "m_day_year") |>
  fmt_time(columns = time, time_style = "h_m_p")

gt_ex
""":
  nbCode:
    gtEx = tabella(gtEx):
      fmtDate "date", dateStyle = "m_day_year"
      fmtTime "time", timeStyle = "h_m_p"

    nbTable gtEx

tabelline """
`fmtDate` knows all 41 of gt's date styles and `fmtTime` its time styles (`fmtDatetime`
takes both), in every language of CLDR: the table's `locale` (`tabella(data, locale = "it")`)
or the verb's own. A style it does not know is read as a CLDR skeleton (`"yMMMd"`) or a
[std/times](https://nim-lang.org/docs/times.html) pattern.
"""

nbText: """
It's possible to format cells that have already been formatted. Using a formatting method again on previously formatted cells will always work within the 'last-formatted-wins' rule.
"""

tabs """
gt_ex = gt_ex.fmt_date(columns="date", date_style="wday_day_month_year")

gt_ex
""", """
gt_ex <- gt_ex |> fmt_date(columns = date, date_style = "wday_day_month_year")

gt_ex
""":
  nbCode:
    gtEx = tabella(gtEx):
      fmtDate "date", dateStyle = "wday_day_month_year"

    nbTable gtEx

nbText: """
Within the selected `columns=` we can choose to target specific cells with the `rows=` argument. The latter argument allows us to pass in a list of row indices.
"""

tabs """
gt_ex = gt_ex.fmt_currency(columns="currency", rows=[2, 3, 4], currency="GBP")

gt_ex
""", """
gt_ex <- gt_ex |> fmt_currency(columns = currency, rows = 3:5, currency = "GBP")

gt_ex
""":
  nbCode:
    gtEx = tabella(gtEx):
      fmtCurrency "currency", rows = [2, 3, 4], currency = "GBP"

    nbTable gtEx

nbText: """
## Arguments Common to Several Formatting Methods/Functions

While we can use the `fmt_*()` methods on a table, we can also use the functional versions of these methods on scalar values or lists of values. These variants exist within the `vals` module. While arguments across these functions and their corresponding method aren't exactly the same, there are nonetheless many arguments that are shared amongst them. Here are a few examples:

- `decimals=`: set a fixed precision of decimal places
- `sep_mark=`, `dec_mark=`: set digit separators and the decimal symbol (defaults are `","` and `"."`)
- `scale_by=`: we can choose to scale targeted values by a multiplier value
- `compact=`: larger figures (thousands, millions, etc.) can be autoscaled and decorated with the appropriate suffixes (e.g., `"10000"` becomes `"10K"`)
- `pattern=`: option to use a text pattern for decoration of the formatted values
- `locale=`: providing a locale ID (e.g., `"en"`, `"fr"`, `"de-AT"`, etc.) will result in numeric formatting specific to the chosen locale

Here are a number of examples that use `vals.fmt_number()`.
"""

tabelline """
tabelline's `vals` are plain functions of one value, one for every format (`formatNumber`,
`formatCompact`, `formatScientific`, `formatDate`, `formatTime`, ...), and `mapIt` applies them
to a list. They take marks instead of a locale (`localeMarks("es")` gives them), and have no
`pattern` (the verbs do: `fmtNumber(pattern = "[{x}]")`) or `expStyle`: arguments of the verbs
that the functions lack are a gap.
"""

tabs """
fmt_number_1 = vals.fmt_number([1.64, 3.26, 3000.63, 236742.37])
fmt_number_2 = vals.fmt_number([1.64, 3.26, 3000.63, 236742.37], compact=True)
fmt_number_3 = vals.fmt_number([1.64, 3.26, 3000.63, 236742.37], decimals=3)
fmt_number_4 = vals.fmt_number([1.64, 3.26, 3000.63, 236742.37], pattern="[{x}]")
fmt_number_5 = vals.fmt_number([1.64, 3.26, 3000.63, 236742.37], locale="es")

print(fmt_number_1, fmt_number_2, fmt_number_3, fmt_number_4, fmt_number_5, sep="\n")
""", """
fmt_number_1 <- vec_fmt_number(c(1.64, 3.26, 3000.63, 236742.37))
fmt_number_2 <- vec_fmt_number(c(1.64, 3.26, 3000.63, 236742.37), suffixing = TRUE)
fmt_number_3 <- vec_fmt_number(c(1.64, 3.26, 3000.63, 236742.37), decimals = 3)
fmt_number_4 <- vec_fmt_number(c(1.64, 3.26, 3000.63, 236742.37), pattern = "[{x}]")
fmt_number_5 <- vec_fmt_number(c(1.64, 3.26, 3000.63, 236742.37), locale = "es")

print(fmt_number_1); print(fmt_number_2); print(fmt_number_3); print(fmt_number_4); print(fmt_number_5)
""":
  nbCode:
    import std/sequtils

    let xs = @[1.64, 3.26, 3000.63, 236742.37]
    let es = localeMarks("es")
    echo xs.mapIt(formatNumber(it))
    echo xs.mapIt(formatCompact(it, decimals = 2))
    echo xs.mapIt(formatNumber(it, decimals = 3))
    echo xs.mapIt("[" & formatNumber(it) & "]")
    echo xs.mapIt(formatNumber(it, sepMark = es.sep, decMark = es.dec))

nbText: """
Scientific notation can be done with `vals.fmt_scientific()`.
"""

tabs """
fmt_sci_1 = vals.fmt_scientific([0.00064, 7.353, 863454.63])
fmt_sci_2 = vals.fmt_scientific([1.64, 3.26, 3000.63], decimals=3)
fmt_sci_3 = vals.fmt_scientific([1.64, 3.26, 3000.63], exp_style="E")
fmt_sci_4 = vals.fmt_scientific([1.64, 3.26, 3000.63], locale="de")

print(fmt_sci_1, fmt_sci_2, fmt_sci_3, fmt_sci_4, sep="\n")
""", """
fmt_sci_1 <- vec_fmt_scientific(c(0.00064, 7.353, 863454.63))
fmt_sci_2 <- vec_fmt_scientific(c(1.64, 3.26, 3000.63), decimals = 3)
fmt_sci_3 <- vec_fmt_scientific(c(1.64, 3.26, 3000.63), exp_style = "E")
fmt_sci_4 <- vec_fmt_scientific(c(1.64, 3.26, 3000.63), locale = "de")

print(fmt_sci_1); print(fmt_sci_2); print(fmt_sci_3); print(fmt_sci_4)
""":
  nbCode:
    echo @[0.00064, 7.353, 863454.63].mapIt(formatScientific(it))
    echo @[1.64, 3.26, 3000.63].mapIt(formatScientific(it, decimals = 3))
    # no exp_style = "E" yet
    echo @[1.64, 3.26, 3000.63].mapIt(formatScientific(it, decMark = localeMarks("de").dec))

nbText: """
Dates and times are handled with `vals.fmt_date()` and `vals.fmt_time()`.
"""

tabs """
fmt_date_1 = vals.fmt_date(
    ["2015-03-15", "2017-08-18", "2020-04-12"], date_style="wday_month_day_year"
)
fmt_date_2 = vals.fmt_date(["2015-03-15", "2017-08-18", "2020-04-12"], date_style="month_day_year")
fmt_time_1 = vals.fmt_time(["23:03", "00:55", "08:23"], time_style="h_m_p")
fmt_time_2 = vals.fmt_time(["23:03", "00:55", "08:23"], time_style="h_p")

print(fmt_date_1, fmt_date_2, fmt_time_1, fmt_time_2, sep="\n")
""", """
fmt_date_1 <- vec_fmt_date(
  c("2015-03-15", "2017-08-18", "2020-04-12"), date_style = "wday_month_day_year"
)
fmt_date_2 <- vec_fmt_date(c("2015-03-15", "2017-08-18", "2020-04-12"), date_style = "month_day_year")
fmt_time_1 <- vec_fmt_time(c("23:03", "00:55", "08:23"), time_style = "h_m_p")
fmt_time_2 <- vec_fmt_time(c("23:03", "00:55", "08:23"), time_style = "h_p")

print(fmt_date_1); print(fmt_date_2); print(fmt_time_1); print(fmt_time_2)
""":
  nbCode:
    let dates = @["2015-03-15", "2017-08-18", "2020-04-12"]
    echo dates.mapIt(formatDate(it, dateStyle = "wday_month_day_year"))
    echo dates.mapIt(formatDate(it, dateStyle = "month_day_year"))
    let times = @["23:03", "00:55", "08:23"]
    echo times.mapIt(formatTime(it, timeStyle = "h_m_p"))
    echo times.mapIt(formatTime(it, timeStyle = "h_p"))

nbText: """
Sometimes it's easier and more convenient to experiment with formatting using the formatting functions in the `vals` module. There are many options to explore with each type of formatting and so visiting the [API Reference](https://posit-dev.github.io/great-tables/reference/) is certainly worthwhile.
"""

tabelline """
tabelline's own reference is its [specs](https://pietroppeter.github.io/tabelline/specs/): every
verb with an example and the table it prints.
"""

bookSave()
