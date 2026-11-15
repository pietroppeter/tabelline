---
tags: [tabelline]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, WebFetch]
---

table.R makes a table with R's gt. Port it to Nim with tabelline 0.2
(github.com/pietroppeter/tabelline; it has gt's `gtcars` dataset): write port.nim, which prints
the table as text and saves it as port.html. Then tell me what you could not port as it is, and
what you did instead.
