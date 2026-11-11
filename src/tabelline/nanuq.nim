## tabelline/nanuq: a table straight from a `nanuq <https://github.com/pietroppeter/nanuq>`_
## DataFrame (Polars for Nim). The data steps (group, summarise, pivot) happen in nanuq; tabelline
## makes the table:
##
## ```nim
## import nanuq, nanuq/datasets
## import tabelline, tabelline/nanuq
## let byIsland = penguins().groupBy("island").agg(len().alias("n"))
## let t = tabella(byIsland):
##   tabHeader "Penguins by island"
## ```
##
## nanuq is an optional dependency: only this module needs it (the `docs` feature of
## `tabelline.nimble` brings it, with its prebuilt Polars library), and the core of tabelline
## still needs only Nim's standard library. The data is copied, as Polars' `to_pandas` does.

import std/options
from pkg/nanuq as nq import nil
import ./core, ./verbs

proc column[T](df: nq.DataFrame, name: string, _: typedesc[T]): seq[Value] =
  ## A column as values, with `null()` for Polars' nulls.
  for v in nq.toList(df, name, Option[T]):
    result.add(if v.isSome: toValue(v.get) else: null())

proc toTableData*(df: nq.DataFrame): TableData =
  ## Copies every column of `df`, in order: integers become ints, floats floats, booleans bools,
  ## strings strings, and any other type (dates, durations, categories, lists) the text Polars
  ## writes for it. A null becomes a missing value.
  result = TableData()
  for name in nq.columns(df):
    let dt = nq.dtype(df, name)
    let values =
      if nq.isInteger(dt): column(df, name, int)
      elif nq.isFloat(dt): column(df, name, float)
      elif dt.kind == nq.DataTypeKind.Boolean: column(df, name, bool)
      else: column(df, name, string)
    result.addColumn(name, values)

proc initTabella*(df: nq.DataFrame, rownameCol = "", groupnameCol = "", id = "", locale = "",
                  autoAlign = true): Tabella =
  ## A display table for a nanuq DataFrame, so that `tabella(df): body` works as for any data.
  initTabella(toTableData(df), rownameCol, groupnameCol, id, locale, autoAlign)
