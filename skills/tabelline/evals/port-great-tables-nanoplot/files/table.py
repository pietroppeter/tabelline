import polars as pl
from great_tables import GT, md

df = pl.DataFrame({
    "city": ["Trento", "Bari", "Oslo"],
    "temps": [
        [2, 4, 9, 13, 17, 21, 23, 22, 18, 12, 7, 3],
        [9, 10, 12, 15, 19, 24, 27, 27, 23, 18, 14, 10],
        [-4, -4, 0, 5, 11, 15, 17, 16, 11, 6, 1, -3],
    ],
    "rain": [55, 60, 49],
})

(
    GT(df, rowname_col="city")
    .tab_header(title="Monthly temperatures", subtitle=md("means of **1991–2020**"))
    .fmt_nanoplot(columns="temps", plot_type="line", reference_line="mean")
    .fmt_nanoplot(columns="rain", plot_type="bar")
    .cols_label(temps="Temperature (°C)", rain=md("Rain (*mm*)"))
    .tab_source_note("Climate normals, rounded")
    .opt_stylize(style=3, color="green")
)
