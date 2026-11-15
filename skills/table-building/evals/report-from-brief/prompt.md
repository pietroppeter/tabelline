---
tags: [tabelline, table-building]
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, WebFetch]
---

pizzaplace.csv has one row for each of 5,000 pizzas a pizzeria sold in 2015 (type, size, price).
Make one table for the owner's yearly report that shows how the sales split by type and size,
with tabelline 0.2 (github.com/pietroppeter/tabelline): write report.nim, which prints the table
as text and saves it as report.html. Make it a table you would be proud to see printed in the
report.
