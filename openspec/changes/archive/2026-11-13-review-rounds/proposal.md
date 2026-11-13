## Why

Pietro reviews the same version of a page more than once: he exports some comments, sends them,
and goes on reviewing before the page changes (13 Nov 2026, the thread of the islands story).
The review mode did not expect that. The next export held every comment again, numbered from 1,
so he had to remember to delete the comments already sent, by hand, one by one; when he did, the
new ones were numbered from 1 again, and the numbers of two exports collided ("in one case I
deleted 3 comments already sent and the 4th was 4, in others the new comments were 1..."). He
asked for a **Delete** beside **History**, and for the review skill to handle the repeated rounds.
He also asked whether copying a comment should count as sending it: yes, that is this change.
Thread "Improve review mode for repeated reviews"; the PR that builds it is still to be opened.

## What Changes

- **Copy sends.** Copying an export sends the comments of this version in it: each gets its
  number then, the next after the last number given on this version, and keeps it. The round
  of the export is the last round sent plus one.
- **The next export holds only what is new**: the comments not sent yet, numbered after the last
  one sent, and those changed since they were sent, under their old number, marked *changed since
  round N*. Nothing new: the export says so, and points to History.
- **Numbers never repeat on a version.** How far the rounds went (the last round and number) is
  kept in the browser apart from the comments, so deleting the comments sent does not give their
  numbers again.
- **On the page**, a comment sent stays marked, quieter (a dashed line under its words), and its
  comment box says *Comment 3, sent in round 1*.
- **Delete**, beside **History** in the export, deletes the comments of the export (a second tap
  confirms).
- **History's Export** gives every comment of this version, sent or not, each saying its round;
  History says how many of a version's comments are sent.
- The export is `nimib-review/6`: the title says the round, the YAML block adds `round` and
  `sent` (the last number sent before this round), and a heading says when its comment was sent
  before. Comments of an older version are numbered `11.3` in **Export everything**.
- **Bring here** brings comments to this version as new ones, not sent here.
- The nimib-review skill handles a round after the first on the same version: the earlier rounds
  are already done, so it checks the work in progress before it changes anything again, and a
  changed comment replaces its earlier text.

## Differences from gt and Great Tables

None: the review mode is part of the docs, not of tables, and not from gt or Great Tables.

## Capabilities

### Modified Capabilities
- `review-mode`: the export, in rounds; Delete in the export; History's Export.

## Impact

`docs/assets/review.js` (rounds, Delete), `docs/review.nim` (styles of sent marks and the export's
buttons), `.claude/skills/nimib-review/SKILL.md`, AGENTS.md, the post Review mode. The copy of the
review mode in pietroppeter/claude-artifacts (`shared/review/`) is synced after merge.
