import tabbook
bookInit()

# The passengers of the chapter (book/data/contest/titanic_train.csv), read when it is compiled;
# here and not in gtdata.nim, which every chapter imports.
const titanicCsv = staticRead(currentSourcePath().parentDir & "/../data/contest/titanic_train.csv")

nbText: "# Titanic Challenge: Data Analysis to Predict Passenger Survival"

attribution Source(title: "“Titanic Challenge: Data Analysis to Predict Passenger Survival”, a Posit Table Contest entry",
  url: "https://github.com/fralfaro/Titanic-Challenge/blob/main/docs/project/01_eda.ipynb",
  authors: "Francisco Alfaro (2024), honourable mention", license: "MIT",
  licenseUrl: "https://github.com/fralfaro/Titanic-Challenge/blob/main/LICENSE",
  changes: "The entry is a site and a Streamlit app about the Titanic's passengers; its tables " &
    "are made with Great Tables by one function, `gt_tables`, in the notebook *Exploratory " &
    "Data Analysis*, ported here. The notebook's text is kept; its plots, and the code that " &
    "only prints (the data's types, its duplicates), are left out, and its tables are made " &
    "in the tabs where it makes them, with the entry's functions from `utils.py`. The data " &
    "are the entry's `train.csv` (Kaggle's Titanic training set), cut to the columns the " &
    "tables use: `book/data/contest/titanic_train.csv`. The R tab is written for the book.")
nbText: """
## 📊 Exploratory Data Analysis

## Introduction 

The Titanic dataset is one of the most well-known datasets in the field of data science and machine learning. It contains detailed information about the passengers aboard the Titanic, a British passenger liner that tragically sank in the North Atlantic Ocean on April 15, 1912, after hitting an iceberg. This disaster resulted in the loss of over 1,500 lives and has since become a poignant example of maritime tragedy.

Exploratory Data Analysis (EDA) is a crucial step in any data analysis project. It involves examining the dataset to uncover underlying patterns, spot anomalies, test hypotheses, and check assumptions through summary statistics and graphical representations. For the Titanic dataset, EDA helps us understand the factors that influenced survival rates, such as passenger demographics, socio-economic status, and travel details.

The dataset comprises variables such as passenger age, gender, ticket class, fare paid, and whether or not the passenger survived. By analyzing these variables, we can gain insights into which groups of passengers were more likely to survive and the reasons behind these trends. For instance, we might explore questions like:

- Did gender play a significant role in survival rates?
- Were first-class passengers more likely to survive than those in lower classes?
- How did the age of passengers affect their chances of survival?

Through various visualizations and statistical analyses, EDA provides a foundation for more complex modeling and predictive analysis. It allows us to clean and preprocess the data, handle missing values, and create new features that might improve the performance of machine learning models.

## About Data

>  🔑**Note**: For now, we will focus on the train dataset, but the same should be done for the test dataset.

To perform an Exploratory Data Analysis (EDA) with visualizations, whether univariate, bivariate or not, it is essential to consider the type of data we are working with. Additionally, we can perform a deep scan of all columns or an in-depth scan of individual columns, depending on the desired speed and detail of our EDA. The goal is to present all findings in a detailed and clear manner to ensure maximum understanding.

In this case, the 'Age' column should be an integer, but it contains null values (or `NaN`), which automatically converts it to a `float` type column. For now, let's treat it as a `float` type column.

## About EDA

There are columns used to identify each individual, typically indicated by the term 'ID' in their name. It is essential that these identifiers do not have a value of zero.

It is important to note that these identifiers should not be duplicated unless there is more than one record due to analysis in relation to other columns (e.g., the **period**). In these specific cases, duplication may be relevant and is associated with certain analytical contexts involving other variables or time periods.

Now, we will proceed to work on the remaining columns.

To analyze variables with float values, the approach depends on the distribution of the data. For univariate analysis, a Histogram is usually used as a starting point (First Case). However, if the dataset is extensive or there is a noticeable concentration of values around zero (a common scenario), it is more effective to transform the data into discrete intervals (Second Case).

The definition of these intervals can be done automatically using a function that generates equidistant ranges. However, sometimes it is preferable to define these intervals manually, as automation could create numerous bins, making data interpretation and analysis more difficult. In such cases, a manual approach allows for adjusting the intervals more appropriately according to the specific nature of the data, facilitating better understanding and analysis.
"""

tabs """
import pandas as pd
from great_tables import GT, html

train = pd.read_csv("../data/contest/titanic_train.csv").set_index("PassengerId")


# from the entry's utils.py
def calculate_percentage_vo_int(data, column, vo):
    '''
    Calculates the relative percentages of each group divided by a target variable (vo) in a DataFrame,
    keeping the column of interest as the index in the pivot table.
    '''

    # Calculate the count of each group and restructure the data
    counts = data.groupby([vo, column]).size().reset_index(name='Count')

    # Calculate the percentages by category
    counts['Percentage'] = counts.groupby(vo)['Count'].transform(lambda x: (x / x.sum()))

    # Create a pivot table with the percentages
    pivot_counts = counts.pivot_table(values=['Count', 'Percentage'], index=column, columns=vo)

    return pivot_counts

def calculate_percentage_vo(data, column, bins, vo):
    '''
    Calculates the relative percentages of each group divided by a target variable (vo) in a DataFrame,
    within specific ranges defined by column and bins.
    '''

    # Add a new column to the DataFrame with the ranges of the specific column
    data[column + 'Range'] = pd.cut(data[column], bins=bins, right=False)

    # Calculate the count of each group and restructure the data
    counts = data.groupby([vo, column + 'Range']).size().reset_index(name='Count')

    # Calculate the percentages by category
    counts['Percentage'] = counts.groupby(vo)['Count'].transform(lambda x: (x / x.sum()))

    # Create a pivot table with the percentages
    pivot_counts = counts.pivot_table(values=['Count', 'Percentage'], index=column + 'Range', columns=vo)

    # Remove extra column
    data.drop(column + 'Range', axis=1, inplace=True)

    return pivot_counts


def gt_tables(table,col,vo):
    # Flattening the MultiIndex columns
    table.columns = [f'{i}_{j}' for i, j in table.columns]

    # Resetting the index to make 'FareRange' a column again
    table.reset_index(inplace=True)

    # Displaying the DataFrame
    gt_table = ((
        GT(table)
        .tab_header(
            title="Count and Percentage Table",
            subtitle=f"{col} vs {vo}"
        )

        .tab_spanner(
            label="0",
            columns=["Count_0", "Percentage_0"]
        )
        .tab_spanner(
            label="1",
            columns=["Count_1", "Percentage_1"]
        )
        .tab_spanner(
            label=vo,
            columns=["Count_0", "Percentage_0", "Count_1", "Percentage_1"]
        )

        .cols_label(
            Count_0=html("Count"),
            Count_1=html("Count"),
            Percentage_0=html("Percentage"),
            Percentage_1=html("Percentage")

        )
    )
    )
    gt_table = gt_table.fmt_number(columns=["Percentage_0", "Percentage_1"],
                                   decimals=2)  # .opt_stylize(style = 1, color = "blue")

    gt_table = gt_table.tab_options(
        table_background_color="white",
        # table_font_color="darkblue",
        table_font_style="italic",
        table_font_names="Times New Roman",
        heading_background_color="skyblue"
    )

    return gt_table


float_columns = ["Age", "Fare"]
bins = {
    'Age': [0, 10, 20, 30, 40, 50, 60, 70, 80, 90],
    'Fare':  [0, 10, 25, 50, 100, 1000]
}

target = 'Survived'

# the notebook displays each table in its loop; the book shows the list of them
[gt_tables(calculate_percentage_vo(train, col, bins[col], target), col, target) for col in float_columns]
""", """
library(dplyr)
library(tidyr)
library(gt)

train <- read.csv("../data/contest/titanic_train.csv")

# the count and the share of each group among the passengers who died (0) and survived (1)
percentage_vo <- function(data, column, vo = "Survived") {
  data |>
    filter(!is.na(.data[[column]]), .data[[column]] != "") |>
    count(.data[[vo]], .data[[column]], name = "Count") |>
    group_by(.data[[vo]]) |>
    mutate(Percentage = Count / sum(Count)) |>
    ungroup() |>
    pivot_wider(names_from = all_of(vo), values_from = c(Count, Percentage), values_fill = 0) |>
    arrange(.data[[column]])
}

# the same within the ranges of a column of numbers, closed on the left
percentage_vo_bins <- function(data, column, bins, vo = "Survived") {
  data[[paste0(column, "Range")]] <- cut(data[[column]], breaks = bins, right = FALSE, dig.lab = 4)
  percentage_vo(data, paste0(column, "Range"), vo)
}

gt_tables <- function(table, col, vo = "Survived") {
  table |>
    gt() |>
    tab_header(title = "Count and Percentage Table", subtitle = paste(col, "vs", vo)) |>
    tab_spanner(label = "0", columns = c(Count_0, Percentage_0), id = "died") |>
    tab_spanner(label = "1", columns = c(Count_1, Percentage_1), id = "survived") |>
    tab_spanner(label = vo, spanners = c("died", "survived")) |>
    cols_label(Count_0 = "Count", Count_1 = "Count",
               Percentage_0 = "Percentage", Percentage_1 = "Percentage") |>
    fmt_number(columns = c(Percentage_0, Percentage_1), decimals = 2) |>
    tab_options(table.background.color = "white", table.font.style = "italic",
                table.font.names = "Times New Roman", heading.background.color = "skyblue")
}

bins <- list(Age = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90), Fare = c(0, 10, 25, 50, 100, 1000))
lapply(c("Age", "Fare"), \(col) gt_tables(percentage_vo_bins(train, col, bins[[col]]), col))
""":
  nbCode:
    import std/[sequtils, streams]
    import nanuq
    import tabelline, tabelline/nanuq

    let train = readCsv(newStringStream(titanicCsv))

    proc percentageVo(data: DataFrame, column: string, vo = "Survived"): DataFrame =
      ## The count and the share of each group among the passengers who died (0) and survived
      ## (1), a row for each group, in the order of the column.
      data.filter(col(column).isNotNull)
        .sort(column)
        .groupBy(vo, column)  # nanuq keeps the groups in the order they come
        .agg(len().alias("Count"))
        .withColumns((col("Count") / col("Count").sum.over(vo)).alias("Percentage"))
        .pivot(on = vo, index = column, values = ["Count", "Percentage"], sortColumns = true)
        .fillNull(FillNullStrategy.Zero)

    proc percentageVoBins(data: DataFrame, column: string, bins: openArray[float],
                          vo = "Survived"): DataFrame =
      ## The same within the ranges of a column of numbers, closed on the left: "[0, 10)".
      let labels = (0 ..< bins.high).mapIt("[" & $bins[it].int & ", " & $bins[it + 1].int & ")")
      data.filter(col(column) >= lit(bins[0]) and col(column) < lit(bins[^1]))
        .sort(column)
        .withColumns(col(column).cut(bins[1 .. ^2], labels, leftClosed = true).alias(column & "Range"))
        .percentageVo(column & "Range", vo)

    proc gtTables(table: DataFrame, column: string, vo = "Survived"): Tabella =
      tabella(table):
        tabHeader "Count and Percentage Table", column & " vs " & vo
        tabSpanner "0", ["Count_0", "Percentage_0"]
        tabSpanner "1", ["Count_1", "Percentage_1"]
        tabSpanner vo, ["Count_0", "Percentage_0", "Count_1", "Percentage_1"], level = 2
        colsLabel:
          Count_0: "Count"
          Count_1: "Count"
          Percentage_0: "Percentage"
          Percentage_1: "Percentage"
        fmtNumber ["Percentage_0", "Percentage_1"], decimals = 2
        tabOptions(tableBackgroundColor = "white", tableFontStyle = "italic",
                   tableFontNames = "'Times New Roman'", headingBackgroundColor = "skyblue")

    nbTable train.percentageVoBins("Age", [0.0, 10, 20, 30, 40, 50, 60, 70, 80, 90]).gtTables("Age")
    nbTable train.percentageVoBins("Fare", [0.0, 10, 25, 50, 100, 1000]).gtTables("Fare")

tabelline """
The 🐍 tab is the notebook's: pandas counts the passengers of each group (`groupby().size()`),
takes each count's share of its group of the target, and turns the target's two values into
columns with `pivot_table`, whose two levels of names `gt_tables` joins (`Count_0`). The 👑
tab does the same with nanuq: `len()` by group, the share with a sum `over` the target, and
`pivot` with two values, which names its columns the same way; the ranges are nanuq's `cut`,
closed on the left as `pd.cut(right=False)`, with pandas' labels. The two spanners over
spanners are a `tabSpanner` at `level = 2`. pandas' pivot gives the counts as floats, so the
🐍 tables show `269.0`, where the 👑 and 🏴‍☠️ ones show `269`.
"""
nbText: """
To visually represent variables of type `int` or `object`, it is initially recommended to use the `value_counts` method from Pandas to count the unique values in that column. However, different considerations should be taken into account:

- When the number of unique values is small, it is appropriate to use `value_counts` directly for both `int` and `object` type variables.
- For `int` type variables with a large number of categories, it is useful to work with **value intervals** before creating graphical visualizations.
- For `object` type variables with multiple categories, it may be helpful to prioritize the most frequent ones and group the rest under a general label such as "others". However, if most values are unique, that variable may not provide relevant information for graphical representation (e.g., information such as addresses, phone numbers, emails, etc.).
"""

tabs """
[gt_tables(calculate_percentage_vo_int(train, col, target).fillna(0), col, target)
 for col in ['Pclass', 'SibSp', 'Parch', 'Sex', 'Embarked']]
""", """
lapply(c("Pclass", "SibSp", "Parch", "Sex", "Embarked"), \(col) gt_tables(percentage_vo(train, col), col))
""":
  nbCode:
    for column in ["Pclass", "SibSp", "Parch", "Sex", "Embarked"]:
      nbTable train.percentageVo(column).gtTables(column)

tabelline """
A `for` makes the five tables, each shown with `nbTable`, as the notebook's loop does with
`display`. The two passengers with no port of embarkation are left out, as pandas leaves out
missing keys when it groups.
"""
nbText: """
To perform exploratory analysis on the 'Cabin', 'Name', and 'Ticket' columns in the Titanic dataset, you can follow various approaches depending on the information they contain and the specific objectives of your analysis.


## Conclusion

In conclusion, we conducted an Exploratory Data Analysis (EDA) on the Titanic dataset, focusing on understanding the characteristics and distribution of various columns. We identified the data types and non-null values, checked for duplicates, and performed univariate and bivariate analyses on numerical and categorical variables. Through graphical representations and interval-based transformations, we gained insights into the data's structure and key factors influencing survival rates. This comprehensive EDA serves as a foundation for further in-depth analysis and modeling.
"""

bookSave()

