## Why

Pietro (10 Nov 2026, 0.2 build thread) had three comments on an older version of the post
Designing tabelline 0.2 and wanted them back on the latest one: comments are kept per version,
so a new commit to a page hides them. He asked to bring them to the last version when possible,
or at least to export them, to have **Export everything** instead of **Clear everything**, and
for the nimib-review skill to check comments from older versions before applying them.

## What Changes

- History: each older version with comments has **Bring here**, which moves to this version the
  comments whose words it still has (and comments on the whole page), and keeps the others on
  their version; and **Export**, which exports them.
- **Export everything** (in place of **Clear everything**) exports the comments of every version
  of the page, this version's first, then the older ones, newest first.
- A comment remembers the commit it was written on. The export is `nimib-review/5`: a comment
  from an older version says `From version N (commit c).` under its heading, and one whose
  words are gone says `(Not found on the page any more.)`.
- The nimib-review skill checks a comment from an older version against the diff since its
  commit: valid (apply), already done, or moot.

## Capabilities

### Modified Capabilities
- `review-mode`: the export and History.

## Impact

`docs/assets/review.js` (History, the export), `docs/review.nim` (the styles of History),
`.claude/skills/nimib-review/SKILL.md`, AGENTS.md, the post Review mode (the History card).
Clearing every comment of every page is gone; clearing a version stays.
