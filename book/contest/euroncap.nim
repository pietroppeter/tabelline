import tabbook
bookInit()

nbText: "# Euro NCAP Safety Ratings - 2023"

attribution contestEntry("Euro NCAP Safety Ratings - 2023",
  "https://github.com/jrycw/posit-gt-2024/blob/master/euroncap_2023.ipynb",
  "Jerry Wu (2024), Best Table that Uses Polars", "MIT",
  "https://github.com/jrycw/posit-gt-2024/blob/master/LICENSE",
  "The entry's notebook, made with Great Tables 0.7 and Polars 0.20: its text and code are kept, " &
  "without the pictures of each step and the video. The table is made once, at *Constructing " &
  "the Pipeline*, by one program that gathers the notebook's functions, for Great Tables 1.1 " &
  "and Polars 1: the data are read from a CSV (`book/data/contest/euroncap_2023.csv`, the " &
  "entry's JSON, which Polars 1 no longer reads) and the car makers' logos from the entry's " &
  "repository. The R tab is written for the book.")

nbText: """
## 0. Introduction

This project aims to integrate the [great-tables 0.7.0](https://github.com/posit-dev/great-tables) and [Polars 0.20.31](https://github.com/pola-rs/polars) packages in Python to create a table displaying the ratings of 17 cars from Euro NCAP for the year 2023. You can find all the code and the tables in this [repository](https://github.com/jrycw/posit-gt-2024). 

Hereafter, I'll use the abbreviation `gt` to refer to the Python package **great-tables** and `{gt}` to refer to the R package **gt**.

We will divide the content into four parts as follows:

1. **Data Collection**: Discussing where the data is gathered from and what information it includes.
2. **Tweaking the Polars DataFrame**: Explaining how to manipulate the collected data into a Polars DataFrame.
3. **Enhancing Presentation with great-tables**: Demonstrating how to transform the Polars DataFrame into a great table using `gt`.
4. **Final Thoughts**: Sharing some concluding thoughts and insights.

## 1. Data Collection

All data, including logos, has been gathered from the [EuroNCAP website](https://www.euroncap.com/en/ratings-rewards/latest-safety-ratings) in JSON format and stored as `euroncap_2023.json`. Next, we'll load the data into a Polars `DataFrame` named `df_mini` using [pl.read_json()](https://docs.pola.rs/py-polars/html/reference/api/polars.read_json.html) and preview the first row along with its column names.

```python
from enum import Enum
from itertools import chain
from pathlib import Path
from typing import Callable, Iterable

import polars as pl
from great_tables import GT, html, loc, style, system_fonts
from polars import selectors as cs
```

```python
json_file = "euroncap_2023.json"
df_mini = pl.read_json(json_file).head(1)
df_mini
```

```python
df_mini.columns
```

The first few columns contain basic information such as `Make`, `Model`, `Class`, and the `Url` from which the data was gathered. Following these, there's a `Stars` column indicating the car's rating, accompanied by thirteen columns detailing testing scores across four categories: `Adult Occupant`, `Child Occupant`, `Vulnerable Road Users`, and `Safety Assist`. It's worth noting that there may be some rounding errors, which could lead to discrepancies in the sum of each test within each category, as compared to the numbers outlined on the website.

Subsequently, we'll define some variables related to the testing categories for later use.

```python
adult_occupant_columns = [
    "Frontal Impact",
    "Lateral Impact",
    "Rear Impact",
    "Rescue and Extrication",
]

child_occupant_columns = [
    "Crash Test Performance",
    "Safety Features",
    "CRS Installation Check",
]

vulnerable_road_users_columns = ["VRU Impact Protection", "VRU Impact Mitigation"]

safety_assist_columns = [
    "Speed Assistance",
    "Occupant Status Monitoring",
    "Lane Support",
    "AEB Car-to-Car",
]

testing_columns = (
    adult_occupant_columns
    + child_occupant_columns
    + vulnerable_road_users_columns
    + safety_assist_columns
)

testing_groups = (
    adult_occupant_columns,
    child_occupant_columns,
    vulnerable_road_users_columns,
    safety_assist_columns,
)

testing_group_names = ("adult", "child", "vru", "assist")

testing_columns_with_rank = []
for _grp, _grp_name in zip(testing_groups, testing_group_names):
    testing_columns_with_rank.extend(chain(_grp, [_grp_name]))
```

> **Note**
>
> Employing the [`itertools.chain`](https://docs.python.org/3/library/itertools.html#itertools.chain) function facilitates the seamless merging of multiple iterables, treating them as a cohesive whole. From personal experience, leveraging it often streamlines tasks and saves time, particularly when combining various types of iterables.
>

## 2. Tweaking the Poalrs Dataframe

### 2.0 Consolidating Data Wrangling into a Single Function

We'll apply a technique learned from [Matt Harrison](https://www.linkedin.com/in/panela/), the author of *Effective Pandas* and *Effective Polars*, by consolidating all adjustments into a single function called `tweak_df`. This approach allows us to easily track the modifications made to the raw data at the outset of the Jupyter notebook. First, we'll move the previous `pl.read_json()` call into `tweak_df()` and save it as a temporary variable `df`. Then, we'll use Polars expressions to modify or create several columns.

```python
def tweak_df(json_file: str) -> pl.DataFrame:
    df = pl.read_json(json_file)
    ...
```

### 2.1 `Make` Column Expression

To enhance the visual appeal of the `Make` column, we'll transform plain strings into images sourced from the URLs provided in the `euroncap_2023.json` file. These images, stored in the `logo` folder, are suffixed with either `.png` or `.jpg`. The transformation process will be handled by `gt` later. Our immediate goal is to modify the `Make` column to lowercase and append the correct suffix to each entry. For instance, the cell value for *BMW* should be `bmw.png` since the associated image is a `.png` file. Similarly, for *Lexus*, the cell value should be `lexus.jpg`. This can be achieved using the [pl.when().then().otherwise()](https://docs.pola.rs/py-polars/html/reference/expressions/api/polars.when.html) syntax, which is the Polars equivalent of an `if-else` conditional branch, allowing us to dynamically select the appropriate suffix.

```python
logo_path = Path("logo")


def tweak_df(json_file: str) -> pl.DataFrame:
    ...
    _make = pl.col("Make").str.to_lowercase()
    logo_pngs = [l.stem for l in logo_path.glob("*png")]
    make = (
        pl.when(_make.is_in(logo_pngs))
        .then(_make.add(".png"))
        .otherwise(_make.add(".jpg"))
    )
```

### 2.2 `Model` Column Expression

In the `Model` column, we aim to format the entries as hyperlinks that direct users to the URLs containing the rating reports of the respective cars. Again, the formatting task will be delegated to `gt`. Our objective now is to construct strings in **Markdown** format. To accomplish this, we'll create a function called `cols_merge_as_str` to facilitate the transformation.

```python
def _str_exprize(elem: str | pl.Expr) -> pl.Expr:
    if isinstance(elem, pl.Expr):
        return elem.cast(pl.Utf8)
    return pl.lit(str(elem))


def cols_merge_as_str(*elems: pl.Expr | str, alias: str = "merged_col") -> pl.Expr:
    if not elems:
        raise ValueError("At least one str or Polars expression must be provided.")
    cols = None
    for elem in elems:
        if cols is None:
            cols = _str_exprize(elem)
            continue
        cols = cols.add(_str_exprize(elem))
    return cols.alias(alias)


def tweak_df(json_file: str) -> pl.DataFrame:
    ...
    model = cols_merge_as_str(
        "[", pl.col("Model"), "](", pl.col("Url"), ")", alias="Model"
    )
```

> **Note**
>
> You may also find the [pl.concat_str()](https://docs.pola.rs/py-polars/html/reference/expressions/api/polars.concat_str.html) function relevant; it's worth exploring for additional insights. Additionally, the `gt` documentation provides an [example](https://github.com/posit-dev/great-tables/blob/main/docs/examples/sports-earnings/index.ipynb) of how to perform a similar operation using [pl.Expr.map_elements()](https://docs.pola.rs/py-polars/html/reference/expressions/api/polars.Expr.map_elements.html).
>

### 2.3 `Stars` Column Expression

While images are visually appealing, sometimes it's convenient to express certain ideas using emojis. Therefore, for the `Stars` column, we'll simply concatenate it with the ⭐ emoji.

```python
def tweak_df(json_file: str) -> pl.DataFrame:
    ...
    stars = pl.col("Stars").add("⭐")
```

### 2.4 Four Column Expressions for Categories

Creating temporary columns can often simplify the process of writing downstream Polars expressions. In this case, we’ll use generator expressions to create a generator that calculates the sum for each of the four categories. It's worth noting that functions like [pl.sum_horizontal()](https://docs.pola.rs/py-polars/html/reference/expressions/api/polars.sum_horizontal.html) are vectorized in Polars, which eliminates the need for slow for-loops when handling operations across different columns.

```python
def tweak_df(json_file: str) -> pl.DataFrame:
    ...
    grps = (
        pl.sum_horizontal(grp).alias(grp_name)
        for grp, grp_name in zip(testing_groups, testing_group_names)
    )
```

### 2.5 `SubRanks` Column Expression

When computing the ranks for the four `SubRank` columns, we calculate the rank for each category individually. We use the `min` method with [pl.Expr.rank()](https://docs.pola.rs/py-polars/html/reference/expressions/api/polars.Expr.rank.html) to determine the rank. Consequently, there may be occasional gaps in the ranking if multiple entries share the same rank. Since a higher score signifies a better result, we apply `descending=True` to ensure the correct ranking order.

```python
def tweak_df(json_file: str) -> pl.DataFrame:
    ...
    sub_ranks = (
        pl.col(grp_name).rank("min", descending=True).cast(pl.UInt8)
        for grp_name in testing_group_names
    )
```

### 2.6 `Rank` Column Expression

For the `Rank` column, we'll use [pl.mean_horizontal()](https://docs.pola.rs/py-polars/html/reference/expressions/api/polars.mean_horizontal.html) to calculate the average rank across the four categories. We will then rank these averages to determine the final rank using the `min` method with `pl.Expr.rank()`. Since a lower average rank is better, we'll set `descending=False`.

```python
def tweak_df(json_file: str) -> pl.DataFrame:
    ...
    rank = (
        pl.mean_horizontal(testing_group_names)
        .rank("min", descending=False)
        .cast(pl.UInt8)
        .alias("Rank")
    )
```

### 2.7 `tweak_df()` Function

Now, it's time to actually tweak `df`. The function comprises six chained methods:

* `.with_columns(pl.col(testing_columns).cast(pl.Float64))`: Casting all `testing_columns` to `pl.Float64`.
* `.with_columns(model, make, stars, *grps)`: Creating or modifying the corresponding columns.
* `.with_columns(sub_ranks)`: Adding fours `SubRank` columns.
* `.with_columns(rank)`: Adding a `Rank` column.
* `.sort("Class", "Rank", *testing_group_names, descending=[True, False] + [False] * len(testing_group_names))`: Sorting `df` by the specified columns in different orders.
* `.select(chain(("Class", "Model", "Make", "Stars", "Rank"), testing_columns_with_rank))`: Rearranging the final desired columns.

```python
def tweak_df(json_file: str) -> pl.DataFrame:
    ...
    
    return (
        df.with_columns(pl.col(testing_columns).cast(pl.Float64))
        .with_columns(model, make, stars, *grps)
        .with_columns(sub_ranks)
        .with_columns(rank)
        .sort(
            "Class",
            "Rank",
            *testing_group_names,
            descending=[True, False] + [False] * len(testing_group_names),
        )
        .select(
            chain(
                ("Class", "Model", "Make", "Stars", "Rank"), testing_columns_with_rank
            )
        )
    )
```

> **Note**
>
>
> * [df.with_columns()](https://docs.pola.rs/py-polars/html/reference/dataframe/api/polars.DataFrame.with_columns.html) and [df.select()](https://docs.pola.rs/py-polars/html/reference/dataframe/api/polars.DataFrame.select.html) are referred to as [contexts](https://docs.pola.rs/user-guide/concepts/contexts/), where column expressions are applied.
> * [pl.col()](https://docs.pola.rs/py-polars/html/reference/expressions/col.html) not only accepts a string as a column name but also multiple strings or even an iterable of strings to select multiple columns simultaneously.
>

### 2.8 Code Snippet

The code snippet for this section is shown below:

```python
logo_path = Path("logo")


def _str_exprize(elem: str | pl.Expr) -> pl.Expr:
    if isinstance(elem, pl.Expr):
        return elem.cast(pl.Utf8)
    return pl.lit(str(elem))


def cols_merge_as_str(*elems: pl.Expr | str, alias: str = "merged_col") -> pl.Expr:
    '''
    Parameters
    ----------
    elems
        str or Polars expressions.
    alias
        alias for the final Polars expressions.

    Returns:
    ----------
    pl.Expr
        Polars expressions
    '''
    if not elems:
        raise ValueError("At least one str or Polars expression must be provided.")
    cols = None
    for elem in elems:
        if cols is None:
            cols = _str_exprize(elem)
            continue
        cols = cols.add(_str_exprize(elem))
    return cols.alias(alias)


def tweak_df(json_file: str) -> pl.DataFrame:
    df = pl.read_json(json_file)

    _make = pl.col("Make").str.to_lowercase()
    logo_pngs = [l.stem for l in logo_path.glob("*png")]
    make = (
        pl.when(_make.is_in(logo_pngs))
        .then(_make.add(".png"))
        .otherwise(_make.add(".jpg"))
    )

    model = cols_merge_as_str(
        "[", pl.col("Model"), "](", pl.col("Url"), ")", alias="Model"
    )

    stars = pl.col("Stars").add("⭐")

    grps = (
        pl.sum_horizontal(grp).alias(grp_name)
        for grp, grp_name in zip(testing_groups, testing_group_names)
    )

    sub_ranks = (
        pl.col(grp_name).rank("min", descending=True).cast(pl.UInt8)
        for grp_name in testing_group_names
    )

    rank = (
        pl.mean_horizontal(testing_group_names)
        .rank("min", descending=False)
        .cast(pl.UInt8)
        .alias("Rank")
    )

    return (
        df.with_columns(pl.col(testing_columns).cast(pl.Float64))
        .with_columns(model, make, stars, *grps)
        .with_columns(sub_ranks)
        .with_columns(rank)
        .sort(
            "Class",
            "Rank",
            *testing_group_names,
            descending=[True, False] + [False] * len(testing_group_names),
        )
        .select(
            chain(
                ("Class", "Model", "Make", "Stars", "Rank"), testing_columns_with_rank
            )
        )
    )


df = tweak_df(json_file)
```

## 3. Enhancing Presentation with great-tables

### 3.0 Refining Table Presentation with Pipeline

The core concept of utilizing the pipeline is that each callable (typically a function) receives an instance of a `GT` object as the first input parameter and returns an instance of a `GT` object. This allows us to chain multiple callables together, forming a pipeline.

In this section, we'll gradually build each callable and observe how the table is constructed. Instead of rendering the table in HTML directly, we'll use the `make_table()` function to generate multiple **PNG** tables, which internally calls [GT.save()](https://posit-dev.github.io/great-tables/reference/GT.save.html#great_tables.GT.save). These tables will be shown at the end of each subsection. This approach allows us to save each progress step in the `tables` folder. However, since the hyperlinks in the table won't be functional when saved in **PNG** format, this is a minor drawback I hope you can accept. You can find the final table in HTML at [3.15 Final Table in HTML](./#final-table-in-html).

```python
def make_table(
    gtbl: GT,
    *funcs: Callable[[GT], GT] | Iterable[Callable[[GT], GT]],
    tbl_dir: str | Path = "tables",
    save_png: bool = False,
) -> GT:
    first = funcs[0]
    if isinstance(first, Iterable) and len(funcs) == 1:
        funcs = first

    table_dir = Path(tbl_dir)
    table_dir.mkdir(exist_ok=True)

    for i, func in enumerate(funcs, start=1):
        gtbl = func(gtbl)
        if save_png:
            gtbl.save(str(table_dir / f"{i:02}_{func.__name__}.png"))
    return gtbl
```

Before moving on, we need to define the color palette for later use. Next, we'll set up some boilerplate code for the table labels. Fortunately, `gt` offers [GT.html()](https://posit-dev.github.io/great-tables/reference/html.html) and [GT.md()](https://posit-dev.github.io/great-tables/reference/md.html) utility functions to assist us. The numbers used here can be easily found in the rating report.

```python
class EuroNCAPPalette(str, Enum):
    TABLE_BACKGROUND: str = "#F5F5F5"
    HIGHLIGHT1: str = "#C0DA80"
    HIGHLIGHT2: str = "#C3EBD7"
    HIGHLIGHT3: str = "#A0E0D0"
    STUB_COLUMN_LABEL: str = "#D4E6A8"
    ROW_GROUP: str = "#BFE2A7"
    CELL: str = "#F4FAF1"
    TITLE: str = "#30937B"
    GRADIENT1: str = "#E7CE91"
    GRADIENT2: str = "#F2E4C0"
    GRADIENT3: str = "#F5EFE7"


domain_nominal_max = {
    "Frontal Impact": 16,
    "Lateral Impact": 16,
    "Rear Impact": 4,
    "Rescue and Extrication": 4,
    "Crash Test Performance": 24,
    "Safety Features": 13,
    "CRS Installation Check": 12,
    "VRU Impact Protection": 36,
    "VRU Impact Mitigation": 27,
    "Speed Assistance": 3,
    "Occupant Status Monitoring": 3,
    "Lane Support": 3,
    "AEB Car-to-Car": 9,
}

adult_occupant_top_score = 40
adult_occupant_labels = zip(
    adult_occupant_columns,
    (
        html(
            f"Frontal<br>Impact<br><i>({domain_nominal_max['Frontal Impact']}/{adult_occupant_top_score})</i>"
        ),
        html(
            f"Lateral<br>Impact<br><i>({domain_nominal_max['Lateral Impact']}/{adult_occupant_top_score})</i>"
        ),
        html(
            f"Rear<br>Impact<br><i>({domain_nominal_max['Rear Impact']}/{adult_occupant_top_score})</i>"
        ),
        html(
            f"Rescue&<br>Extrication<br><i>({domain_nominal_max['Rescue and Extrication']}/{adult_occupant_top_score})</i>"
        ),
    ),
)

child_occupant_top_score = 49
child_occupant_labels = zip(
    child_occupant_columns,
    (
        html(
            f"Crash<br>Test<br><i>({domain_nominal_max['Crash Test Performance']}/{child_occupant_top_score})</i>"
        ),
        html(
            f"Safety<br>Features<br><i>({domain_nominal_max['Safety Features']}/{child_occupant_top_score})</i>"
        ),
        html(
            f"CRS<br>Installation<br>Check<br><i>({domain_nominal_max['CRS Installation Check']}/{child_occupant_top_score})</i>"
        ),
    ),
)

vulnerable_road_users_score = 63
vulnerable_road_users_labels = zip(
    vulnerable_road_users_columns,
    (
        # add empty space
        html(
            f"Impact&nbsp;<br>Protection&nbsp;<br><i>({domain_nominal_max['VRU Impact Protection']}/{vulnerable_road_users_score})&nbsp;</i>"
        ),
        html(
            f"Impact&nbsp;<br>Mitigation&nbsp;<br><i>({domain_nominal_max['VRU Impact Mitigation']}/{vulnerable_road_users_score})&nbsp;</i>"
        ),
    ),
)

safety_assist_score = 18
safety_assist_labels = zip(
    safety_assist_columns,
    (
        html(
            f"Speed<br>Assistance<br><i>({domain_nominal_max['Speed Assistance']}/{safety_assist_score})</i>"
        ),
        html(
            f"Occupant<br>Status<br>Monitoring<br><i>({domain_nominal_max['Occupant Status Monitoring']}/{safety_assist_score})</i>"
        ),
        html(
            f"Lane<br>Support<br><i>({domain_nominal_max['Lane Support']}/{safety_assist_score})</i>"
        ),
        html(
            f"AEB C2C<b><i><sup>3</sup></i></b><br><i>({domain_nominal_max['AEB Car-to-Car']}/{safety_assist_score})</i>"
        ),
    ),
)


testing_labels = dict(
    chain(
        adult_occupant_labels,
        child_occupant_labels,
        vulnerable_road_users_labels,
        safety_assist_labels,
    )
)
```

> **Tip**
>
> You might want to check out [GT.pipe()](https://github.com/posit-dev/great-tables/pull/363), which may possibly be merged as you review the project.
>

### 3.1 Defaults

Before applying styling to `df` using `gt`, let's first preview how the defaults look with `df`:

```python
def default_table(gtbl: GT) -> GT:
    return gtbl
```

### 3.2 `grouping_table`

Currently, the `gt` team is working on refactoring the codebase to give users more granular control over `groupname_col` and `rowname_col`. Hence, I actually cheated a little bit to access the underlying `_tbl_data` (the Polars DataFrame `df`) for use in the pipeline.

```python
def grouping_table(
    gtbl: GT, groupname_col: str = "Class", rowname_col: str = "Model"
) -> GT:
    return GT(gtbl._tbl_data, groupname_col=groupname_col, rowname_col=rowname_col)
```

### 3.3 `add_formatter`

Here we showcase the use of three types of [GT.fmt_*()](https://posit-dev.github.io/great-tables/reference/#formatting-column-data) methods:

* `.fmt_image("Make", path=logo_path)`: Rendering the located image for the `Make` column.
* `.fmt_number(columns=testing_columns, decimals=1)`: Formatting the float numbers to one decimal place for all `testing_columns`.
* `.fmt_markdown(columns=["Model"])`: Rendering the **Markdown** format in the `Model` column.

```python
def add_formatter(gtbl: GT) -> GT:
    return (
        gtbl.fmt_image("Make", path=logo_path)
        .fmt_number(columns=testing_columns, decimals=1)
        .fmt_markdown(columns=["Model"])
    )
```

### 3.4 `adjust_cols`

The [GT.cols_*()](https://posit-dev.github.io/great-tables/reference/#modifying-columns) methods provided by `gt` allow us to modify entire columns.
Here we include four chained `cols_*` method calls:

* `.cols_width(cols_width)`: Defining the column widths for corresponding columns.
* `.cols_align(align="center", columns=["Make", "Stars"])`: Centering the alignment of the `Make` and `Stars` columns.
* `.cols_align(align="right", columns=["Rank"])`: Aligning the `Rank` column to the right.
* `.cols_label(**cols_label)`: Renaming the labels for the respective columns.

It's important to note that the `GT.cols_label()` method doesn't actually change the names of the columns in `df`; it only changes the display names.

```python
def adjust_cols(gtbl: GT) -> GT:
    cols_width = dict.fromkeys(testing_columns, "60px") | dict.fromkeys(
        testing_group_names, "30px"
    )
    cols_label = (
        {"Rank": html("<b>Rank<i><sup>1</sup></i></b>")}
        | testing_labels
        | dict.fromkeys(testing_group_names, html(f"<b>SRank<i><sup>2</sup></i></b>"))
    )
    return (
        gtbl.cols_width(cols_width)
        .cols_align(align="center", columns=["Make", "Stars"])
        .cols_align(align="right", columns=["Rank", *testing_group_names])
        .cols_label(**cols_label)
    )
```

### 3.5 `add_tab_header`

The [GT.tab_header()](https://posit-dev.github.io/great-tables/reference/GT.tab_header.html#great_tables.GT.tab_header) method allows us to define a `title` and `subtitle`.

```python
def add_tab_header(gtbl: GT) -> GT:
    return gtbl.tab_header(
        title=html(
            f'''<h1><span style="color: {EuroNCAPPalette.TITLE.value}">Euro NCAP SAFETY RATINGS - 2023</span></h1>'''
        ),
        subtitle=html('''<h2>The more stars, the better.</h2>'''),
    )
```

### 3.6 `add_tab_spanner`

The [GT.tab_spanner()](https://posit-dev.github.io/great-tables/reference/GT.tab_spanner.html#great_tables.GT.tab_spanner) method allows us to group different columns together. Here, we consecutively call it five times to create five spanners.

```python
def a_html(text: str, url: str, is_bold: bool = True, align: str = "center") -> html:
    fragment = '<a href="{url}" style="float: {align};">{text}</a>'
    if is_bold:
        fragment = f"<b>{fragment}</b>"
    return html(fragment.format(url=url, text=text, align=align))


def add_tab_spanner(gtbl: GT) -> GT:
    gtbl = gtbl.tab_spanner(
        a_html(
            "Rating", "https://www.euroncap.com/en/car-safety/the-ratings-explained/"
        ),
        columns=["Stars", "Rank"],
    )
    
    labels = (
        a_html(
            "Adult Occupant",
            "https://www.euroncap.com/en/car-safety/the-ratings-explained/adult-occupant-protection/",
        ),
        a_html(
            "Child Occupant",
            "https://www.euroncap.com/en/car-safety/the-ratings-explained/child-occupant-protection/",
        ),
        a_html(
            "Vulnerable Road Users",
            "https://www.euroncap.com/en/car-safety/the-ratings-explained/vulnerable-road-user-vru-protection/",
        ),
        a_html(
            "Safety Assist",
            "https://www.euroncap.com/en/car-safety/the-ratings-explained/safety-assist/",
        ),
    )
    for label, grp, grp_name in zip(labels, testing_groups, testing_group_names):
        gtbl = gtbl.tab_spanner(label, columns=[*grp, grp_name])
    return gtbl
```

### 3.7 `add_tab_stubhead`

Here we'll set up the stubhead as the EuroNCAP logo (downloaded from this [URL](https://www.euroncap.com/gfx/Euro%20NCAP%20logo%202023_pos.svg)) in **SVG** format using [GT.tab_stubhead()](https://posit-dev.github.io/great-tables/reference/GT.tab_stubhead.html#great_tables.GT.tab_stubhead).

```python
def add_tab_stubhead(gtbl: GT) -> GT:
    img_src = "https://raw.githubusercontent.com/jrycw/posit-gt-2024/master/euroncap_logo/euroncap_pos.svg"
    return gtbl.tab_stubhead(html(f'<img src="{img_src}"/></br></br>'))
```

### 3.8 `add_tab_option`

[GT.tab_options()](https://posit-dev.github.io/great-tables/reference/GT.tab_options.html#great_tables.GT.tab_options) provides numerous options that allow us to exercise fine-grained control over the table. You should definitely explore these options and tailor them to suit your own table. Enjoy experimenting!

```python
def add_tab_option(gtbl: GT) -> GT:
    return gtbl.tab_options(
        stub_background_color=EuroNCAPPalette.STUB_COLUMN_LABEL.value,
        table_background_color=EuroNCAPPalette.TABLE_BACKGROUND.value,
        heading_align="left",
        heading_subtitle_font_size="16px",
        heading_subtitle_font_weight="bold",
        column_labels_font_size="14px",
        column_labels_background_color=EuroNCAPPalette.STUB_COLUMN_LABEL.value,
        row_group_font_size="18px",
        row_group_font_weight="bold",
        row_group_background_color=EuroNCAPPalette.ROW_GROUP.value,
        table_font_names=system_fonts("industrial"),
    )
```

### 3.9 `add_tab_style`

[GT.tab_style()](https://posit-dev.github.io/great-tables/reference/GT.tab_style.html#great_tables.GT.tab_style) allows us to apply styles to specific cells using the `locations` parameter. With the help of [loc.body()](https://posit-dev.github.io/great-tables/reference/loc.body.html#great_tables.loc.body), we can [target rows using Polars expressions](https://posit-dev.github.io/great-tables/get-started/row-selection.html#using-polars-expressions) and [locate columns using Polars selectors](https://posit-dev.github.io/great-tables/get-started/column-selection.html#using-polars-selectors), which is a neat feature provided by `gt`.

Here we apply two types of styling:

* Assigning all columns a default style color `EuroNCAPPalette.CELL`.
* Highlighting the cars in the `Stars` column that have a five-star rating with the style color `EuroNCAPPalette.HIGHLIGHT1`.

```python
def add_tab_style(gtbl: GT) -> GT:
    return gtbl.tab_style(
        style=style.fill(color=EuroNCAPPalette.CELL.value),
        locations=loc.body(columns=cs.all()),
    ).tab_style(
        style=style.fill(color=EuroNCAPPalette.HIGHLIGHT1.value),
        locations=loc.body(columns="Stars", rows=pl.col("Stars").eq("5⭐")),
    )
```

> **Tip**
>
> If you're using `gt` 0.6.2 or above along with Polars 0.20.30 or above, you can use Polars expressions for column selection as well. Many thanks to [Polars for their support](https://github.com/posit-dev/great-tables/pull/368).
>

### 3.10 `add_data_color`

Here, we're employing [GT.data_color()](https://posit-dev.github.io/great-tables/reference/GT.data_color.html#great_tables.GT.data_color) to achieve a gradient palette effect for the `Rank` column. This enables us to visually represent that darker cells correspond to better ranks.

```python
def add_data_color(gtbl: GT) -> GT:
    return gtbl.data_color(
        domain=[1, df.height],
        palette=[
            g.value
            for g in (
                EuroNCAPPalette.GRADIENT1,
                EuroNCAPPalette.GRADIENT2,
                EuroNCAPPalette.GRADIENT3,
            )
        ],
        columns=["Rank", *testing_group_names],
    )
```

### 3.11 `add_tab_footnote`

Currently, the footnote feature is not yet implemented in `gt`. However, we can leverage [GT.tab_source_note()](https://posit-dev.github.io/great-tables/reference/GT.tab_source_note.html#great_tables.GT.tab_source_note) to achieve a similar result.

```python
def add_tab_footnote(gtbl: GT) -> GT:
    return (
        gtbl.tab_source_note(
            html(
                "<i><sup>1 </sup></i>Rank is derived from the rank of the averaged ranks across the four categories."
            )
        )
        .tab_source_note(
            html(
                "<i><sup>2 </sup></i>SRank refers to ranking by the sum of each category."
            )
        )
        .tab_source_note(html("<i><sup>3 </sup></i>AEB C2C stands for AEB Car-to-Car."))
    )
```

### 3.12 `add_source_note`

Again, we'll use `GT.tab_source_note()` to add the data source, the table creator, and the URL of this repository.

```python
def add_source_note(gtbl: GT) -> GT:
    source = 'Source: <a href="https://www.euroncap.com/en">Euro NCAP</a>'
    table = 'Table: <a href="https://cv.ycwu.space">Jerry Wu</a>'
    repo = 'Repo: <a href="https://github.com/jrycw/posit-gt-2024">posit-gt-2024</a>'
    return gtbl.tab_source_note(html(" | ".join([source, table, repo])))
```

### 3.13 `final_table`

`final_table` serves as the culminating pipeline, representing the last step in the process. In this scenario, it simply returns the table it receives without any modifications. Regarding the image, you may notice a small gray area on the right side of the table. This could be due to the use of `groupname_col` and `rowname_col`, with the current logic not fully optimized for these conditions. For now, I manually adjusted the table to remove the small pieces on the left and right sides for aesthetic reasons.

```python
def final_table(gtbl: GT) -> GT:
    return gtbl
```

### 3.14 Constructing the Pipeline
"""

tabs """
from enum import Enum
from itertools import chain

import polars as pl
from great_tables import GT, html, loc, style, system_fonts
from polars import selectors as cs

# The book reads the data as CSV (the JSON of Polars 0.20 is not read by Polars 1)
# and the logos from the entry's repository.
csv_file = "../data/contest/euroncap_2023.csv"
logo_path = "https://raw.githubusercontent.com/jrycw/posit-gt-2024/master/logo/"
logo_pngs = ["bmw", "hyundai", "kia", "smart", "vinfast", "xpeng"]

adult_occupant_columns = ["Frontal Impact", "Lateral Impact", "Rear Impact", "Rescue and Extrication"]
child_occupant_columns = ["Crash Test Performance", "Safety Features", "CRS Installation Check"]
vulnerable_road_users_columns = ["VRU Impact Protection", "VRU Impact Mitigation"]
safety_assist_columns = ["Speed Assistance", "Occupant Status Monitoring", "Lane Support", "AEB Car-to-Car"]
testing_columns = (
    adult_occupant_columns + child_occupant_columns
    + vulnerable_road_users_columns + safety_assist_columns
)
testing_groups = (
    adult_occupant_columns, child_occupant_columns,
    vulnerable_road_users_columns, safety_assist_columns,
)
testing_group_names = ("adult", "child", "vru", "assist")
testing_columns_with_rank = []
for _grp, _grp_name in zip(testing_groups, testing_group_names):
    testing_columns_with_rank.extend(chain(_grp, [_grp_name]))


def tweak_df(csv_file: str) -> pl.DataFrame:
    df = pl.read_csv(csv_file, schema_overrides={"Stars": pl.Utf8})
    _make = pl.col("Make").str.to_lowercase()
    make = (
        pl.when(_make.is_in(logo_pngs))
        .then(_make.add(".png"))
        .otherwise(_make.add(".jpg"))
    )
    model = pl.concat_str(pl.lit("["), pl.col("Model"), pl.lit("]("), pl.col("Url"), pl.lit(")")).alias("Model")
    stars = pl.col("Stars").add("⭐")
    grps = (
        pl.sum_horizontal(grp).alias(grp_name)
        for grp, grp_name in zip(testing_groups, testing_group_names)
    )
    sub_ranks = (
        pl.col(grp_name).rank("min", descending=True).cast(pl.UInt8)
        for grp_name in testing_group_names
    )
    rank = (
        pl.mean_horizontal(testing_group_names)
        .rank("min", descending=False)
        .cast(pl.UInt8)
        .alias("Rank")
    )
    return (
        df.with_columns(pl.col(testing_columns).cast(pl.Float64))
        .with_columns(model, make, stars, *grps)
        .with_columns(sub_ranks)
        .with_columns(rank)
        .sort(
            "Class", "Rank", *testing_group_names,
            descending=[True, False] + [False] * len(testing_group_names),
        )
        .select(chain(("Class", "Model", "Make", "Stars", "Rank"), testing_columns_with_rank))
    )


df = tweak_df(csv_file)


class EuroNCAPPalette(str, Enum):
    TABLE_BACKGROUND: str = "#F5F5F5"
    STUB_COLUMN_LABEL: str = "#D4E6A8"
    ROW_GROUP: str = "#BFE2A7"
    CELL: str = "#F4FAF1"
    HIGHLIGHT1: str = "#C0DA80"
    TITLE: str = "#30937B"
    GRADIENT1: str = "#E7CE91"
    GRADIENT2: str = "#F2E4C0"
    GRADIENT3: str = "#F5EFE7"


domain_nominal_max = {
    "Frontal Impact": 16, "Lateral Impact": 16, "Rear Impact": 4, "Rescue and Extrication": 4,
    "Crash Test Performance": 24, "Safety Features": 13, "CRS Installation Check": 12,
    "VRU Impact Protection": 36, "VRU Impact Mitigation": 27,
    "Speed Assistance": 3, "Occupant Status Monitoring": 3, "Lane Support": 3, "AEB Car-to-Car": 9,
}
top_scores = {"adult": 40, "child": 49, "vru": 63, "assist": 18}
short_names = {
    "Frontal Impact": "Frontal<br>Impact", "Lateral Impact": "Lateral<br>Impact",
    "Rear Impact": "Rear<br>Impact", "Rescue and Extrication": "Rescue&<br>Extrication",
    "Crash Test Performance": "Crash<br>Test", "Safety Features": "Safety<br>Features",
    "CRS Installation Check": "CRS<br>Installation<br>Check",
    "VRU Impact Protection": "Impact&nbsp;<br>Protection&nbsp;",
    "VRU Impact Mitigation": "Impact&nbsp;<br>Mitigation&nbsp;",
    "Speed Assistance": "Speed<br>Assistance",
    "Occupant Status Monitoring": "Occupant<br>Status<br>Monitoring",
    "Lane Support": "Lane<br>Support", "AEB Car-to-Car": "AEB C2C<b><i><sup>3</sup></i></b>",
}
testing_labels = {
    col: html(f"{short_names[col]}<br><i>({domain_nominal_max[col]}/{top_scores[name]})</i>")
    for grp, name in zip(testing_groups, testing_group_names)
    for col in grp
}


def a_html(text: str, url: str) -> html:
    return html(f'<b><a href="{url}" style="float: center;">{text}</a></b>')


explained = "https://www.euroncap.com/en/car-safety/the-ratings-explained/"
spanners = (
    a_html("Adult Occupant", explained + "adult-occupant-protection/"),
    a_html("Child Occupant", explained + "child-occupant-protection/"),
    a_html("Vulnerable Road Users", explained + "vulnerable-road-user-vru-protection/"),
    a_html("Safety Assist", explained + "safety-assist/"),
)

gtbl = (
    GT(df, groupname_col="Class", rowname_col="Model")
    .fmt_image("Make", path=logo_path)
    .fmt_number(columns=testing_columns, decimals=1)
    .fmt_markdown(columns=["Model"])
    .cols_width(dict.fromkeys(testing_columns, "60px") | dict.fromkeys(testing_group_names, "30px"))
    .cols_align(align="center", columns=["Make", "Stars"])
    .cols_align(align="right", columns=["Rank", *testing_group_names])
    .cols_label(
        **{"Rank": html("<b>Rank<i><sup>1</sup></i></b>")}
        | testing_labels
        | dict.fromkeys(testing_group_names, html("<b>SRank<i><sup>2</sup></i></b>"))
    )
    .tab_header(
        title=html(f'<h1><span style="color: {EuroNCAPPalette.TITLE.value}">Euro NCAP SAFETY RATINGS - 2023</span></h1>'),
        subtitle=html("<h2>The more stars, the better.</h2>"),
    )
    .tab_spanner(a_html("Rating", explained), columns=["Stars", "Rank"])
)
for label, grp, grp_name in zip(spanners, testing_groups, testing_group_names):
    gtbl = gtbl.tab_spanner(label, columns=[*grp, grp_name])

source = 'Source: <a href="https://www.euroncap.com/en">Euro NCAP</a>'
table = 'Table: <a href="https://cv.ycwu.space">Jerry Wu</a>'
repo = 'Repo: <a href="https://github.com/jrycw/posit-gt-2024">posit-gt-2024</a>'
(
    gtbl.tab_stubhead(html('<img src="https://raw.githubusercontent.com/jrycw/posit-gt-2024/master/euroncap_logo/euroncap_pos.svg"/></br></br>'))
    .tab_options(
        stub_background_color=EuroNCAPPalette.STUB_COLUMN_LABEL.value,
        table_background_color=EuroNCAPPalette.TABLE_BACKGROUND.value,
        heading_align="left",
        heading_subtitle_font_size="16px",
        heading_subtitle_font_weight="bold",
        column_labels_font_size="14px",
        column_labels_background_color=EuroNCAPPalette.STUB_COLUMN_LABEL.value,
        row_group_font_size="18px",
        row_group_font_weight="bold",
        row_group_background_color=EuroNCAPPalette.ROW_GROUP.value,
        table_font_names=system_fonts("industrial"),
    )
    .tab_style(style=style.fill(color=EuroNCAPPalette.CELL.value), locations=loc.body(columns=cs.all()))
    .tab_style(
        style=style.fill(color=EuroNCAPPalette.HIGHLIGHT1.value),
        locations=loc.body(columns="Stars", rows=pl.col("Stars").eq("5⭐")),
    )
    .data_color(
        domain=[1, df.height],
        palette=[EuroNCAPPalette.GRADIENT1.value, EuroNCAPPalette.GRADIENT2.value, EuroNCAPPalette.GRADIENT3.value],
        columns=["Rank", *testing_group_names],
    )
    .tab_source_note(html("<i><sup>1 </sup></i>Rank is derived from the rank of the averaged ranks across the four categories."))
    .tab_source_note(html("<i><sup>2 </sup></i>SRank refers to ranking by the sum of each category."))
    .tab_source_note(html("<i><sup>3 </sup></i>AEB C2C stands for AEB Car-to-Car."))
    .tab_source_note(html(" | ".join([source, table, repo])))
)
""", """
library(gt)
library(dplyr)

logo_path <- "https://raw.githubusercontent.com/jrycw/posit-gt-2024/master/logo/"
logo_pngs <- c("bmw", "hyundai", "kia", "smart", "vinfast", "xpeng")

testing_groups <- list(
  adult = c("Frontal Impact", "Lateral Impact", "Rear Impact", "Rescue and Extrication"),
  child = c("Crash Test Performance", "Safety Features", "CRS Installation Check"),
  vru = c("VRU Impact Protection", "VRU Impact Mitigation"),
  assist = c("Speed Assistance", "Occupant Status Monitoring", "Lane Support", "AEB Car-to-Car")
)
group_names <- names(testing_groups)
testing_columns <- unlist(testing_groups, use.names = FALSE)
testing_columns_with_rank <- unlist(lapply(group_names, \(g) c(testing_groups[[g]], g)))

df <- read.csv("../data/contest/euroncap_2023.csv", check.names = FALSE,
               colClasses = c(Stars = "character"))
for (g in group_names) df[[g]] <- rowSums(df[testing_groups[[g]]])
df <- df |>
  mutate(
    Model = paste0("[", Model, "](", Url, ")"),
    Make = paste0(tolower(Make), ifelse(tolower(Make) %in% logo_pngs, ".png", ".jpg")),
    Stars = paste0(Stars, "⭐")
  ) |>
  mutate(across(all_of(group_names), \(x) min_rank(desc(x)))) |>
  mutate(Rank = min_rank(rowMeans(pick(all_of(group_names))))) |>
  arrange(desc(Class), Rank, adult, child, vru, assist) |>
  select(Class, Model, Make, Stars, Rank, all_of(testing_columns_with_rank))

domain_nominal_max <- c(
  "Frontal Impact" = 16, "Lateral Impact" = 16, "Rear Impact" = 4, "Rescue and Extrication" = 4,
  "Crash Test Performance" = 24, "Safety Features" = 13, "CRS Installation Check" = 12,
  "VRU Impact Protection" = 36, "VRU Impact Mitigation" = 27,
  "Speed Assistance" = 3, "Occupant Status Monitoring" = 3, "Lane Support" = 3, "AEB Car-to-Car" = 9
)
top_scores <- c(adult = 40, child = 49, vru = 63, assist = 18)
short_names <- c(
  "Frontal<br>Impact", "Lateral<br>Impact", "Rear<br>Impact", "Rescue&<br>Extrication",
  "Crash<br>Test", "Safety<br>Features", "CRS<br>Installation<br>Check",
  "Impact&nbsp;<br>Protection&nbsp;", "Impact&nbsp;<br>Mitigation&nbsp;",
  "Speed<br>Assistance", "Occupant<br>Status<br>Monitoring", "Lane<br>Support",
  "AEB C2C<b><i><sup>3</sup></i></b>"
)
group_of <- rep(group_names, lengths(testing_groups))
testing_labels <- setNames(
  lapply(seq_along(testing_columns), \(i) html(paste0(
    short_names[i], "<br><i>(", domain_nominal_max[[testing_columns[i]]], "/",
    top_scores[[group_of[i]]], ")</i>"
  ))),
  testing_columns
)
srank_labels <- setNames(rep(list(html("<b>SRank<i><sup>2</sup></i></b>")), 4), group_names)

a_html <- function(text, url) html(paste0('<b><a href="', url, '" style="float: center;">', text, "</a></b>"))
explained <- "https://www.euroncap.com/en/car-safety/the-ratings-explained/"
spanners <- list(
  adult = a_html("Adult Occupant", paste0(explained, "adult-occupant-protection/")),
  child = a_html("Child Occupant", paste0(explained, "child-occupant-protection/")),
  vru = a_html("Vulnerable Road Users", paste0(explained, "vulnerable-road-user-vru-protection/")),
  assist = a_html("Safety Assist", paste0(explained, "safety-assist/"))
)

gtbl <- df |>
  gt(groupname_col = "Class", rowname_col = "Model") |>
  fmt_image(Make, path = logo_path) |>
  fmt_number(all_of(testing_columns), decimals = 1) |>
  fmt_markdown(Model) |>
  cols_width(all_of(testing_columns) ~ px(60), all_of(group_names) ~ px(30)) |>
  cols_align("center", c(Make, Stars)) |>
  cols_align("right", c(Rank, all_of(group_names))) |>
  cols_label(.list = c(list(Rank = html("<b>Rank<i><sup>1</sup></i></b>")), testing_labels, srank_labels)) |>
  tab_header(
    title = html('<h1><span style="color: #30937B">Euro NCAP SAFETY RATINGS - 2023</span></h1>'),
    subtitle = html("<h2>The more stars, the better.</h2>")
  ) |>
  tab_spanner(a_html("Rating", explained), c(Stars, Rank), id = "rating")
for (g in group_names) {
  gtbl <- gtbl |> tab_spanner(spanners[[g]], all_of(c(testing_groups[[g]], g)), id = paste0("spanner_", g))
}

gtbl |>
  tab_stubhead(html('<img src="https://raw.githubusercontent.com/jrycw/posit-gt-2024/master/euroncap_logo/euroncap_pos.svg"/></br></br>')) |>
  tab_options(
    stub.background.color = "#D4E6A8",
    table.background.color = "#F5F5F5",
    heading.align = "left",
    heading.subtitle.font.size = "16px",
    heading.subtitle.font.weight = "bold",
    column_labels.font.size = "14px",
    column_labels.background.color = "#D4E6A8",
    row_group.font.size = "18px",
    row_group.font.weight = "bold",
    row_group.background.color = "#BFE2A7"
  ) |>
  opt_table_font(stack = "industrial") |>
  tab_style(cell_fill(color = "#F4FAF1"), cells_body()) |>
  tab_style(cell_fill(color = "#C0DA80"), cells_body(columns = Stars, rows = Stars == "5⭐")) |>
  data_color(
    columns = c(Rank, all_of(group_names)),
    palette = c("#E7CE91", "#F2E4C0", "#F5EFE7"),
    domain = c(1, nrow(df))
  ) |>
  tab_source_note(html("<i><sup>1 </sup></i>Rank is derived from the rank of the averaged ranks across the four categories.")) |>
  tab_source_note(html("<i><sup>2 </sup></i>SRank refers to ranking by the sum of each category.")) |>
  tab_source_note(html("<i><sup>3 </sup></i>AEB C2C stands for AEB Car-to-Car.")) |>
  tab_source_note(html(paste(
    'Source: <a href="https://www.euroncap.com/en">Euro NCAP</a>',
    'Table: <a href="https://cv.ycwu.space">Jerry Wu</a>',
    'Repo: <a href="https://github.com/jrycw/posit-gt-2024">posit-gt-2024</a>',
    sep = " | "
  )))
""":
  nbCode:
    import std/[sequtils, streams, tables]
    import nanuq
    import tabelline, tabelline/nanuq, gtdata

    const
      logoPath = "https://raw.githubusercontent.com/jrycw/posit-gt-2024/master/logo/"
      logoPngs = ["bmw", "hyundai", "kia", "smart", "vinfast", "xpeng"]

    let testingGroups = {
      "adult": @["Frontal Impact", "Lateral Impact", "Rear Impact", "Rescue and Extrication"],
      "child": @["Crash Test Performance", "Safety Features", "CRS Installation Check"],
      "vru": @["VRU Impact Protection", "VRU Impact Mitigation"],
      "assist": @["Speed Assistance", "Occupant Status Monitoring", "Lane Support", "AEB Car-to-Car"]}.toOrderedTable
    let groupNames = toSeq(testingGroups.keys)
    var testingColumns, testingColumnsWithRank: seq[string]
    for name, grp in testingGroups:
      testingColumns.add grp
      testingColumnsWithRank.add grp & name

    let make = col("Make").str.toLowercase
    let df = readCsv(newStringStream(euroncapCsv), schemaOverrides = {"Stars": String})
      .withColumns(testingColumns.mapIt(col(it).`cast`(Float64)))
      .withColumns(
        concatStr([lit("["), col("Model"), lit("]("), col("Url"), lit(")")]).alias("Model"),
        `when`(make.isIn(logoPngs)).then(concatStr([make, lit(".png")]))
          .otherwise(concatStr([make, lit(".jpg")])).alias("Make"),
        concatStr([col("Stars"), lit("⭐")]).alias("Stars"))
      .withColumns(toSeq(testingGroups.pairs).mapIt(sumHorizontal(it[1].mapIt(col(it))).alias(it[0])))
      .withColumns(groupNames.mapIt(col(it).rank(RankMethod.Min, descending = true)))
      .withColumns(meanHorizontal(groupNames.mapIt(col(it))).rank(RankMethod.Min).alias("Rank"))
      .sort(@["Class", "Rank"] & groupNames, descending = [true, false, false, false, false, false])
      .select(@["Class", "Model", "Make", "Stars", "Rank"] & testingColumnsWithRank)

    # Euro NCAP's palette
    const
      tableBackground = "#F5F5F5"
      highlight1 = "#C0DA80"
      stubColumnLabel = "#D4E6A8"
      rowGroup = "#BFE2A7"
      cell = "#F4FAF1"
      title = "#30937B"
      gradient = @["#E7CE91", "#F2E4C0", "#F5EFE7"]

    let domainNominalMax = {
      "Frontal Impact": 16, "Lateral Impact": 16, "Rear Impact": 4, "Rescue and Extrication": 4,
      "Crash Test Performance": 24, "Safety Features": 13, "CRS Installation Check": 12,
      "VRU Impact Protection": 36, "VRU Impact Mitigation": 27,
      "Speed Assistance": 3, "Occupant Status Monitoring": 3, "Lane Support": 3,
      "AEB Car-to-Car": 9}.toTable
    let topScores = {"adult": 40, "child": 49, "vru": 63, "assist": 18}.toTable
    let shortNames = {
      "Frontal Impact": "Frontal<br>Impact", "Lateral Impact": "Lateral<br>Impact",
      "Rear Impact": "Rear<br>Impact", "Rescue and Extrication": "Rescue&<br>Extrication",
      "Crash Test Performance": "Crash<br>Test", "Safety Features": "Safety<br>Features",
      "CRS Installation Check": "CRS<br>Installation<br>Check",
      "VRU Impact Protection": "Impact&nbsp;<br>Protection&nbsp;",
      "VRU Impact Mitigation": "Impact&nbsp;<br>Mitigation&nbsp;",
      "Speed Assistance": "Speed<br>Assistance",
      "Occupant Status Monitoring": "Occupant<br>Status<br>Monitoring",
      "Lane Support": "Lane<br>Support", "AEB Car-to-Car": "AEB C2C<b><i><sup>3</sup></i></b>"}.toTable

    var labels = @[("Rank", html"<b>Rank<i><sup>1</sup></i></b>")]
    for name, grp in testingGroups:
      for c in grp:
        labels.add (c, html(shortNames[c] & "<br><i>(" & $domainNominalMax[c] & "/" & $topScores[name] & ")</i>"))
      labels.add (name, html"<b>SRank<i><sup>2</sup></i></b>")

    proc aHtml(text, url: string): Text =
      html("<b><a href=\"" & url & "\" style=\"float: center;\">" & text & "</a></b>")

    const explained = "https://www.euroncap.com/en/car-safety/the-ratings-explained/"
    let spanners = {
      "adult": aHtml("Adult Occupant", explained & "adult-occupant-protection/"),
      "child": aHtml("Child Occupant", explained & "child-occupant-protection/"),
      "vru": aHtml("Vulnerable Road Users", explained & "vulnerable-road-user-vru-protection/"),
      "assist": aHtml("Safety Assist", explained & "safety-assist/")}.toTable

    let widths = testingColumns.mapIt((it, "60px")) & groupNames.mapIt((it, "30px"))

    let ncap = tabella(df, groupnameCol = "Class", rownameCol = "Model"):
      fmtImage "Make", path = logoPath
      fmtNumber testingColumns, decimals = 1
      fmtMarkdown "Model"
      colsWidth widths
      colsAlign alCenter, ["Make", "Stars"]
      colsAlign alRight, @["Rank"] & groupNames
      colsLabel labels
      tabHeader html("<h1><span style=\"color: " & title & "\">Euro NCAP SAFETY RATINGS - 2023</span></h1>"),
        html"<h2>The more stars, the better.</h2>"
      tabSpanner aHtml("Rating", explained), ["Stars", "Rank"]
      for name, grp in testingGroups:
        tabSpanner spanners[name], grp & name
      tabStubhead html"<img src=""https://raw.githubusercontent.com/jrycw/posit-gt-2024/master/euroncap_logo/euroncap_pos.svg""/></br></br>"
      tabOptions(stubBackgroundColor = stubColumnLabel, tableBackgroundColor = tableBackground,
                 headingAlign = "left", headingSubtitleFontSize = "16px",
                 headingSubtitleFontWeight = "bold", columnLabelsFontSize = "14px",
                 columnLabelsBackgroundColor = stubColumnLabel, rowGroupFontSize = "18px",
                 rowGroupFontWeight = "bold", rowGroupBackgroundColor = rowGroup)
      optTableFont systemFonts("industrial")
      tabStyle style.fill(cell), loc.body()
      tabStyle style.fill(highlight1), loc.body(cols = "Stars", rows = where(it["Stars"] == "5⭐"))
      dataColor @["Rank"] & groupNames, domain = (1.0, df.len.float), palette = gradient
      tabSourceNote html"<i><sup>1 </sup></i>Rank is derived from the rank of the averaged ranks across the four categories."
      tabSourceNote html"<i><sup>2 </sup></i>SRank refers to ranking by the sum of each category."
      tabSourceNote html"<i><sup>3 </sup></i>AEB C2C stands for AEB Car-to-Car."
      tabSourceNote html("Source: <a href=\"https://www.euroncap.com/en\">Euro NCAP</a> | " &
        "Table: <a href=\"https://cv.ycwu.space\">Jerry Wu</a> | " &
        "Repo: <a href=\"https://github.com/jrycw/posit-gt-2024\">posit-gt-2024</a>")
    nbTable ncap

tabelline """
The original is Python, so the 🐍 tab is the entry's own code, gathered into one program, and
the 👑 tab follows it step by step: the data steps in nanuq, with the same expressions
(`sumHorizontal`, `meanHorizontal`, `rank(RankMethod.Min)`), and each function of the
pipeline as a few verbs of the `tabella` block. A `for` in the block makes the four spanners,
as the notebook's loop does.
"""

nbText: """
With the `make_table` function provided at the beginning of this section, we can now easily generate our well-designed table.

### 3.15 Final Table in HTML

You can find the final table in HTML format on [Quarto Pub](https://jrycw.quarto.pub/euroncap-2023/).

## 4. Final Thoughts

* `gt` is mainly maintained by [@rich-iannone](https://github.com/rich-iannone) and [@machow](https://github.com/machow), with occasional contributions from others, including myself, [@jrycw](https://gh.ycwu.space). Our goal is to port everything from `{gt}` to `gt`, and we welcome more contributors to help make `gt` even better. Join us if you're interested in creating great tables!
* With more features being implemented in `gt`, such as functions similar to [fmt_url()](https://gt.rstudio.com/reference/fmt_url.html?q=fmt_url) and [cols_merge()](https://gt.rstudio.com/reference/cols_merge.html) in `{gt}`, many operations can be offloaded to `gt` instead of directly manipulating the Polars DataFrame. This flexibility allows users to choose the most convenient approach for their application, whether from the data layer or the presentation layer.
* Thanks to [Curtis](https://www.linkedin.com/in/curtiskephart/) for suggesting rendering the table in HTML on Quarto Pub.
* This project is accomplished through collaboration with AI models.
"""

bookSave()
