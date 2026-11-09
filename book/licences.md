# Sources and licences

The book's own text and code are licensed under the [MIT licence](https://github.com/pietroppeter/tabelline/blob/main/LICENSE), as tabelline.

Ported pages keep the licence of their source. Each one says so in the box at its top, together
with its authors and what the port changed. A source is only ported when its licence allows it.

| Source | Licence | Pages | Data |
| ------ | ------- | ----- | ---- |
| [Great Tables user guide](https://posit-dev.github.io/great-tables/get-started/), by Rich Iannone, Michael Chow and the Great Tables contributors (Posit Software, PBC) | [MIT](https://github.com/posit-dev/great-tables/blob/main/LICENSE) ([copy](https://github.com/pietroppeter/tabelline/blob/main/licenses/great-tables-MIT.txt)) | Get Started: Intro, Overview, Header and Footer, Stub, Column Labels, Formatting Values, Styling the Table Body, Styling the whole table, Colorizing with Data, Table Theme Options, Premade Themes, Column Selection, Row Selection, Location selection; the figures *tables from the web* and *the parts of a table* | `book/data/great-tables/` (`islands`, `airquality` and `sza`, from the `great_tables` package, which ships them under its MIT licence; `islands` and `airquality` come from R's datasets, from *The World Almanac and Book of Facts* (1975) and the New York State Department of Conservation and the National Weather Service; `sza` is computed). `exibble` is in `tabelline/datasets`. |
| [*Guide to table making*](https://github.com/bcjaeger/table.glue/blob/master/vignettes/table_guide.Rmd), a vignette of [table.glue](https://github.com/bcjaeger/table.glue), by Byron Jaeger, a 2020 Posit Table Contest entry | [MIT](https://github.com/bcjaeger/table.glue/blob/master/LICENSE.md) ([copy](https://github.com/pietroppeter/tabelline/blob/main/licenses/table-glue-MIT.txt)) | The Table Contest: Guide to table making, with table.glue | `book/data/contest/starwars.csv`: `starwars` from [dplyr](https://dplyr.tidyverse.org) (MIT), from the Star Wars API, cut as the vignette does. |

The Great Tables side of every example ran with the versions in `book/gt/uv.lock`, and its
outputs are kept in `book/gt/outputs/`. The R side was written for the book (MIT, as the rest
of it) and ran with [gt](https://gt.rstudio.com) 1.4.0 (MIT, by Richard Iannone, Joe Cheng,
Barret Schloerke, Shannon Haughton, Ellis Hughes, Alexandra Lauer, Romain François, JooYoung
Seo, Ken Brevoort and Olivier Roy; copyright Posit Software, PBC), on R's `islands` and `airquality` and gt's `exibble` and `sza` (and the Table Contest entries' own R code, with their packages, such as table.glue 0.0.5 and dplyr 1.2.1); its
outputs are kept in `book/gt/outputs-r/`.

The book is built with [nimib](https://github.com/pietroppeter/nimib) and
[nimibook](https://github.com/pietroppeter/nimibook), whose theme and assets have their own
licences (MPL-2.0 theme, fonts under Apache 2.0 and SIL OFL 1.1, Font Awesome). Its look uses
[Jost](https://github.com/indestructible-type/Jost) by Owen Earl (SIL OFL 1.1).
