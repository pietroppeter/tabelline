# review-mode Specification

## Purpose
The review mode of a page: a reader comments on the page where it is, and exports the comments
in one text for a coding agent. It lives in `docs/review.nim`, a module that can move to nimib.

## Requirements

### Requirement: Turning the review mode on
`import review` SHALL add `nbReview`, a block that turns the review mode on for the page, with
every argument optional: `page` (the key the comments are kept under, the source by default),
`title` (the page's title by default), `source` (the notebook's path from the root of its
repository by default) and `script` (a link to a shared copy of the script; inlined by default).
The page SHALL open in reading mode, with nothing of the review mode but a version line and a
**✎ Review** button.

A notebook turns it on with `import review` and `nbReview()` after `nbInit`, and `nbReview()`
finds its settings with `reviewSettings`: for the notebook `docs/notes.nim` of a repository,
titled *Notes*, they are

```nim
echo reviewSettings("/home/me/notes/docs/notes.nim", root = "/home/me/notes", title = "Notes")
```

```text
page: docs/notes.nim
source: docs/notes.nim
title: Notes
```

#### Scenario: A plain nimib page
- **WHEN** a nimib notebook calls `nbReview()`
- **THEN** its page has the review mode, with plain colours when the page has no tokens

### Requirement: The version comes from git
The version of a page SHALL be the number of commits that touched its source, with the last
one's short hash and date. Outside git it SHALL be the first 7 characters of a hash of the
source, with no date. A page built from a source with uncommitted changes SHALL show the number
followed by `+`.

```nim
echo reviewVersion(commits = @["a1b2c3d|2026-11-10", "9f8e7d6|2026-11-09"], dirty = false)
```

```text
version: 2, commit: a1b2c3d, updated: 10 Nov 2026
```

#### Scenario: A new commit
- **WHEN** a commit changes a page's source and the site is built again
- **THEN** the page's version goes up by one, and its comments start empty

### Requirement: The version line
A page with the review mode SHALL show *Version N · updated D* under its lede, or under its title
when it has none, with **✎ Review** beside it. `nbVersion()` SHALL put the line where it is
called instead.

#### Scenario: A page with no version line of its own
- **WHEN** a page calls `nbReview()` and not `nbVersion()`
- **THEN** the line and the button are under its lede

### Requirement: Reviewing
In the review mode a reader SHALL be able to select words and comment on them, or write a note on
the whole page; go through the comments in the order of the page with **‹** and **›**; delete one;
paste screenshots in a note. The comment that is open SHALL be in a comment box at the top, saved
as it is typed; an empty one SHALL be dropped. The comments SHALL be kept in the browser, one key
per page and version.

#### Scenario: Coming back tomorrow
- **WHEN** a reader comments, closes the browser, and opens the page again
- **THEN** the comments are there, marked on the text, and the page opens in the mode it was left in

### Requirement: The export
**Export** SHALL give one text: a title, a ```yaml block (`format: nimib-review/5`, `title`,
`page`, `source`, `version`, `commit`, `exported`, `comments`), then one section per comment in the
order of the page (`## n. In “Heading” (#id)`, `## n. At the top`, `## n. On the whole page`) with
the quote, the words around it and the note. A comment written on another version than the
exported one SHALL say `From version N (commit c).` under its heading, and one whose words the
page no longer has SHALL say `(Not found on the page any more.)`. Each screenshot SHALL be named
in its note and have its own **Copy image**. **Copy** SHALL copy the text only. The export SHALL
also have **History** and **Close review**.

#### Scenario: An agent knows what changed
- **WHEN** an export of version 12 (commit `a1b2c3d`) is pasted after the page reached version 14
- **THEN** the agent can see what changed since the review with `git diff a1b2c3d -- <source>`
### Requirement: History
**History** SHALL list the versions of the page that have comments in this browser, this one
first, then the others newest first, each with its number of comments and **Clear** (which asks
with a second tap). An older version SHALL also have **Bring here**, which moves to this version
its comments on the whole page and those whose words this version still has, and keeps the
others on their version, and **Export**, which exports its comments. **Export everything** SHALL
export the comments of every version of the page.

#### Scenario: Comments on an old build
- **WHEN** the page is at version 14 and the browser keeps comments on version 12
- **THEN** History lists version 12 with its comments, and Clear deletes them

#### Scenario: Bringing comments to the new version
- **WHEN** version 12 has three comments, and version 14 still has the words of two of them
- **THEN** Bring here moves those two to version 14 and keeps the third on version 12, and
  Export everything exports all three, the third marked as not found
