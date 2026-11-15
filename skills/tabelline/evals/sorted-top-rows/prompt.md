---
tags: [tabelline, nimib]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Make a nimib page, moons.nim, built into moons.html, with one table made with tabelline
(github.com/pietroppeter/tabelline; it has a `planets()` dataset). Show only the planet and its
number of moons, sorted with the most moons first. Shade the first three rows of the table as
the reader sees it. The title should be "The **moons** of the planets", with "moons" in bold.
